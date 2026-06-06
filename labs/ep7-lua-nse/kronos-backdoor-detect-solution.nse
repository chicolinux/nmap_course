-- kronos-backdoor-detect-solution.nse
-- SOLUCIÓN COMPLETA — No consultar antes de intentar el ejercicio.
--
-- Uso:
--   nmap -p 31337 --script kronos-backdoor-detect-solution <target>
--   nmap -p 31337 --script kronos-backdoor-detect-solution 192.168.56.0/24

local nmap      = require "nmap"
local shortport = require "shortport"
local stdnse    = require "stdnse"

description = [[
Detecta el backdoor PROMETHEUS-GATE utilizado por Kronos Systems para
comprometer nodos de infraestructura industrial. El backdoor escucha en
el puerto 31337 (TCP) y responde a un handshake específico de 8 bytes
con su cadena de identificación.

Referencia: Operación Prometheus — RED CELL Intelligence Report #7
]]

author      = "RED CELL — Cipher"
license     = "Same as Nmap -- See https://nmap.org/book/man-legal.html"
categories  = { "discovery", "safe" }

-- portrule: activa el script para cualquier host con el puerto 31337 TCP
-- abierto o abierto|filtrado.
portrule = shortport.port_or_service(31337, "kronos-gate", "tcp")

action = function(host, port)
  -- Paso 2: Crear socket TCP
  local socket = nmap.new_socket()

  -- Paso 3: Conectar al target
  local status, err = socket:connect(host, port)
  if not status then
    stdnse.debug1("connect() falló: %s", err)
    return nil
  end

  -- Paso 4: Enviar el handshake (8 bytes: "KRONOS" + 0x00 + 0x01)
  local handshake = "KRONOS" .. string.char(0) .. string.char(1)
  local send_ok, send_err = socket:send(handshake)
  if not send_ok then
    stdnse.debug1("send() falló: %s", send_err)
    socket:close()
    return nil
  end

  -- Paso 5: Recibir respuesta
  local recv_ok, response = socket:receive()
  socket:close()

  if not recv_ok or not response then
    stdnse.debug1("receive() falló o sin datos: %s", response or "nil")
    return nil
  end

  -- Paso 6: Analizar la respuesta
  -- El % escapa el guión porque Lua lo interpreta como cuantificador "0 o más"
  if response:find("PROMETHEUS%-GATE") then
    -- Extraer la versión del backdoor (texto antes del byte nulo)
    local version = response:match("([^%z]+)")

    return stdnse.format_output(true, {
      "BACKDOOR DETECTADO: " .. (version or "PROMETHEUS-GATE"),
      "Host comprometido: " .. (host.ip or host.name),
      "Puerto: " .. port.number .. "/tcp",
      "Respuesta raw: " .. response:gsub("%z", "\\0"),
      "ALERTA CRITICA: Reportar a ORACLE de inmediato",
    })
  end

  -- El puerto 31337 está abierto pero no es el backdoor de Kronos
  stdnse.debug1("Puerto 31337 abierto pero no respondió al handshake KRONOS")
  return nil
end
