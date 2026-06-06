-- kronos-backdoor-detect.nse
-- Detecta el backdoor PROMETHEUS-GATE de Kronos Systems.
-- Misión final: identificar hosts comprometidos en la red de Kronos.
--
-- Uso:
--   nmap -p 31337 --script kronos-backdoor-detect <target>
--   nmap -p 31337 --script kronos-backdoor-detect 192.168.56.0/24

local nmap    = require "nmap"
local shortport = require "shortport"
local stdnse  = require "stdnse"

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

-- ─────────────────────────────────────────────────────────────────────────────
-- PASO 1: Define la regla de activación del script.
--
-- El script debe ejecutarse cuando el puerto 31337 (TCP) esté abierto.
-- Usa shortport.port_or_service() con el número de puerto 31337 y
-- el protocolo "tcp".
--
-- Documentación: https://nmap.org/nsedoc/lib/shortport.html
-- ─────────────────────────────────────────────────────────────────────────────
-- TODO: reemplaza nil con tu implementación de portrule
portrule = nil


-- ─────────────────────────────────────────────────────────────────────────────
-- PASO 2-6: Implementa la función action.
--
-- Esta función se ejecuta cuando la portrule devuelve true.
-- Recibe: host (tabla con .ip, .name) y port (tabla con .number, .protocol)
-- Debe devolver: una cadena de texto, una tabla, o nil (si no hay resultado)
-- ─────────────────────────────────────────────────────────────────────────────
action = function(host, port)

  -- ───────────────────────────────────────────────────────────────────────────
  -- PASO 2: Crear un socket TCP.
  --
  -- nmap.new_socket() devuelve un objeto socket listo para usar.
  -- ───────────────────────────────────────────────────────────────────────────
  -- TODO: local socket = ???


  -- ───────────────────────────────────────────────────────────────────────────
  -- PASO 3: Conectar el socket al target.
  --
  -- socket:connect(host, port) devuelve (status, error_message)
  -- Si status es false, retorna nil para indicar que no se pudo conectar.
  --
  -- PISTA: 'host' y 'port' son los parámetros de action(), no variables nuevas.
  -- ───────────────────────────────────────────────────────────────────────────
  -- TODO: conectar y manejar error


  -- ───────────────────────────────────────────────────────────────────────────
  -- PASO 4: Enviar el handshake de identificación.
  --
  -- El handshake son exactamente 8 bytes:
  --   "KRONOS"  (6 bytes ASCII)
  --   \x00      (byte nulo — usa string.char(0))
  --   \x01      (byte 0x01 — usa string.char(1))
  --
  -- socket:send(data) devuelve (status, error_message)
  -- ───────────────────────────────────────────────────────────────────────────
  local handshake = "KRONOS" .. string.char(0) .. string.char(1)
  -- TODO: enviar handshake y manejar error


  -- ───────────────────────────────────────────────────────────────────────────
  -- PASO 5: Recibir la respuesta del servidor.
  --
  -- socket:receive() devuelve (status, data)
  -- Si status es false, data contiene el mensaje de error.
  -- No olvides cerrar el socket antes de retornar: socket:close()
  -- ───────────────────────────────────────────────────────────────────────────
  -- TODO: recibir respuesta, cerrar socket, manejar error


  -- ───────────────────────────────────────────────────────────────────────────
  -- PASO 6: Analizar la respuesta.
  --
  -- Si la respuesta contiene "PROMETHEUS-GATE", el backdoor está presente.
  --
  -- Usa response:find("PROMETHEUS%-GATE") para buscar el patrón.
  -- (El % escapa el - porque Lua usa - como cuantificador en patrones)
  --
  -- Para formatear el resultado usa stdnse.format_output(true, tabla):
  --   stdnse.format_output(true, {
  --     "Línea 1 del resultado",
  --     "Línea 2 del resultado",
  --   })
  --
  -- Devuelve nil si el backdoor NO está presente.
  -- ───────────────────────────────────────────────────────────────────────────
  -- TODO: verificar respuesta y retornar resultado

  return nil
end
