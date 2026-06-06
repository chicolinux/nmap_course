# Episodio 7 — "Código de Sombra: Lua y NSE Avanzado"

## Briefing de ORACLE — Misión Final

> *"Cipher. Es hora de contarte la verdad completa.*
>
> *Durante meses, Kronos ha estado instalando silenciosamente un backdoor en routers industriales y nodos de red críticos bajo el nombre interno PROMETHEUS-GATE. Responde en el puerto 31337 con un handshake de 8 bytes específico. Una vez activado, abre un canal de exfiltración de datos encubierto.*
>
> *El problema: no existe ningún script NSE que detecte esto. Todos los escáneres del mundo son ciegos ante PROMETHEUS-GATE.*
>
> *Esta es tu misión de graduación, Cipher. Debes escribir ese script tú mismo. Cuando termines, RED CELL tendrá la herramienta para auditar toda la infraestructura global de Kronos y exponer la operación.*
>
> *GHOST y yo estaremos contigo. Empieza."*

---

## Objetivo

Aprender **Lua básico aplicado a NSE**, entender la arquitectura de un script NSE, y escribir desde cero un script funcional que detecte el backdoor PROMETHEUS-GATE.

## Infraestructura del Lab

| VM | IP | Servicios | Rol en el lab |
|---|---|---|---|
| kronos-node1 | 192.168.56.10 | SSH (22), HTTP (80) | Nodo normal — no tiene backdoor |
| kronos-node2 | 192.168.56.11 | SSH (22), FTP (21), MySQL (3306) | Nodo normal — no tiene backdoor |
| kronos-node3 | 192.168.56.12 | SSH (22), HTTP (80), HTTPS (443) | Nodo normal — no tiene backdoor |
| kronos-backdoor | 192.168.56.13 | SSH (22), **KRONOS-GATE (31337)** | **¡Comprometido!** |

```bash
cd labs/ep7-lua-nse
vagrant up
```

---

## Parte 1 — Lua en 20 Minutos

Solo necesitas lo suficiente para entender y escribir scripts NSE.

### Variables y tipos

```lua
-- Tipos básicos
local nombre = "Cipher"         -- string
local version = 2.3             -- number
local activo = true             -- boolean
local nada = nil                -- nil (ausencia de valor)

-- Concatenación de strings: usa ..
local mensaje = "RED CELL — " .. nombre .. " activo"
```

### Funciones

```lua
-- Definición
local function saludar(nombre)
  return "Bienvenido, " .. nombre
end

-- Llamada
local resultado = saludar("Cipher")
print(resultado)
```

### Tablas (el tipo más importante de Lua)

```lua
-- Tabla como array
local hosts = {"192.168.56.10", "192.168.56.11", "192.168.56.13"}
print(hosts[1])   -- Lua indexa desde 1, no 0

-- Tabla como diccionario
local host_info = {
  ip = "192.168.56.13",
  port = 31337,
  compromised = true
}
print(host_info.ip)
print(host_info["port"])
```

### Control de flujo

```lua
-- if / elseif / else
if host_info.compromised then
  print("ALERTA: host comprometido")
elseif host_info.port == 80 then
  print("Servidor web")
else
  print("Host normal")
end

-- while
local i = 1
while i <= 3 do
  print("Intento " .. i)
  i = i + 1
end

-- for numérico
for i = 1, #hosts do   -- #hosts = longitud de la tabla
  print(hosts[i])
end
```

### Manejo de errores (patrón NSE)

```lua
-- En NSE, la mayoría de funciones devuelven (status, data_or_error)
local status, resultado = alguna_funcion()
if not status then
  -- resultado contiene el mensaje de error
  return nil
end
-- Continuar con resultado
```

---

## Parte 2 — Anatomía de un Script NSE

### Estructura mínima

```lua
-- 1. Importar librerías necesarias
local nmap      = require "nmap"
local shortport = require "shortport"
local stdnse    = require "stdnse"

-- 2. Metadata del script
description = [[ Descripción del script. ]]
author      = "Tu nombre o alias"
license     = "Same as Nmap -- See https://nmap.org/book/man-legal.html"
categories  = { "discovery", "safe" }

-- 3. Regla de activación: ¿cuándo se ejecuta el script?
portrule = shortport.port_or_service(80, "http", "tcp")

-- 4. Acción: qué hace el script cuando la regla se cumple
action = function(host, port)
  -- Aquí va la lógica
  return "Resultado para mostrar al usuario"
end
```

### La API NSE más usada

```lua
-- Socket TCP
local socket = nmap.new_socket()
local ok, err = socket:connect(host, port)
local ok, data = socket:receive()
local ok, err = socket:send("datos")
socket:close()

-- Debugging (visible con --script-trace o -d)
stdnse.debug1("Mensaje de debug: %s", variable)

-- Output formateado (tabla de resultados)
return stdnse.format_output(true, {
  "Línea 1 del resultado",
  "Línea 2 del resultado",
})

-- shortport: reglas de puerto comunes
portrule = shortport.port_or_service(80, "http", "tcp")
portrule = shortport.port_or_service({80, 8080, 8888}, "http", "tcp")
```

### Manipulación de strings en Lua

```lua
-- Bytes especiales: string.char(n) genera el byte con valor n
local nulo = string.char(0)    -- \x00
local uno  = string.char(1)    -- \x01

-- Búsqueda de patrones (similar a regex, pero diferente)
local texto = "PROMETHEUS-GATE v2.3.1\x00READY"
if texto:find("PROMETHEUS%-GATE") then  -- % escapa el guión
  print("¡Encontrado!")
end

-- Capturar grupos
local version = texto:match("([^%z]+)")  -- todo hasta el primer byte nulo
```

---

## Parte 3 — El Ejercicio: Escribir kronos-backdoor-detect.nse

### El protocolo del backdoor

```
Cliente → Servidor: "KRONOS" + \x00 + \x01  (8 bytes)
Servidor → Cliente: "PROMETHEUS-GATE v2.3.1" + \x00 + "READY"
```

### Probar el backdoor manualmente primero

```bash
# Verificar que el backdoor está corriendo
nmap -p 31337 192.168.56.13

# Interactuar manualmente (en Python desde tu máquina)
python3 -c "
import socket
s = socket.socket()
s.connect(('192.168.56.13', 31337))
s.send(b'KRONOS\x00\x01')
print(repr(s.recv(64)))
s.close()
"
```

### Instrucciones del ejercicio

1. Abre el archivo `kronos-backdoor-detect.nse`
2. Implementa cada sección marcada con `-- TODO`
3. Sigue los comentarios — cada paso tiene instrucciones detalladas
4. Prueba tu script así:

```bash
# Copiar el script al directorio de scripts de nmap
sudo cp kronos-backdoor-detect.nse /usr/share/nmap/scripts/
sudo nmap --script-updatedb   # actualizar la base de datos de scripts

# Probar en el host con backdoor
nmap -p 31337 --script kronos-backdoor-detect 192.168.56.13

# Probar en toda la red (el script solo debería reportar en .13)
nmap -p 31337 --script kronos-backdoor-detect 192.168.56.10-13

# Scan completo con tu script integrado
sudo nmap -sS -sV -p 1-40000 \
  --script kronos-backdoor-detect \
  192.168.56.10-13
```

### Output esperado cuando el script funciona correctamente

```
Nmap scan report for kronos-backdoor (192.168.56.13)
PORT      STATE SERVICE
31337/tcp open  unknown
| kronos-backdoor-detect:
|   BACKDOOR DETECTADO: PROMETHEUS-GATE v2.3.1
|   Host comprometido: 192.168.56.13
|   Puerto: 31337/tcp
|   Respuesta raw: PROMETHEUS-GATE v2.3.1\0READY
|_  ALERTA CRITICA: Reportar a ORACLE de inmediato
```

### Output esperado en hosts sin backdoor

```
Nmap scan report for kronos-node1 (192.168.56.10)
PORT      STATE  SERVICE
31337/tcp closed unknown
```

---

## Parte 4 — Debugging

```bash
# Ver output de stdnse.debug1()
nmap -p 31337 --script kronos-backdoor-detect \
  --script-trace \
  192.168.56.13

# Nivel de debug de nmap
nmap -p 31337 --script kronos-backdoor-detect \
  -d2 \
  192.168.56.13
```

---

## Solución

Si después de un esfuerzo serio no logras completarlo, la solución está en `kronos-backdoor-detect-solution.nse`. Estúdiala y entiende cada línea antes de continuar.

```bash
sudo cp kronos-backdoor-detect-solution.nse /usr/share/nmap/scripts/
sudo nmap --script-updatedb
nmap -p 31337 --script kronos-backdoor-detect-solution 192.168.56.10-13
```

---

## Misión Completada

> *"Lo lograste, Cipher. Tienes el arma. Ahora RED CELL puede auditar cada nodo de Kronos en el planeta.*
>
> *Los documentos están listos. Las pruebas están documentadas. La operación Prometheus está a punto de concluir.*
>
> *Bien hecho."*
>
> — **ORACLE**

---

## Limpieza

```bash
vagrant destroy -f
```
