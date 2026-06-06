# Episodio 2 — "Las Puertas del Bastión: Escaneo de Puertos"

## Briefing de GHOST

> *"RED CELL ha identificado una subsidiaria de Kronos: Kronos Logistics. Tienen cuatro servidores expuestos. No sabemos qué hay adentro — primero necesitamos saber qué puertas tienen.*
>
> *Regla fundamental: antes de intentar entrar, mapeas. Un buen reconocimiento evita errores costosos. Hoy aprenderás a leer las puertas de un bastión."*

---

## Objetivo

Entender en profundidad cómo funcionan los escaneos TCP (Connect y SYN), los diferentes **estados de puertos** de nmap, y por qué un puerto puede aparecer como `open`, `closed`, `filtered` u `open|filtered`.

## Infraestructura del Lab

| VM | IP | Servicios | Estado esperado |
|---|---|---|---|
| kronos-web | 192.168.56.10 | SSH (22), HTTP (80), HTTPS (443) | `open` |
| kronos-ftp | 192.168.56.11 | SSH (22), FTP (21) | `open` |
| kronos-db | 192.168.56.12 | SSH (22), MySQL (3306), Redis (6379) | `open` |
| kronos-filtered | 192.168.56.13 | SSH (22) open; Puerto 80: `closed`; 443, 8080: `filtered` |

```bash
cd labs/ep2-port-scanning
vagrant up
```

---

## Ejercicios

### Ejercicio 1 — TCP Connect Scan (-sT): El más simple

El scan `-sT` realiza el three-way handshake completo. No requiere privilegios root. Es el más detectable.

```bash
# Sin root — usa TCP Connect
nmap -sT 192.168.56.10
nmap -sT 192.168.56.10-13
```

**Observa:** ¿Cuántas conexiones TCP completas se establecen? Usa Wireshark para verlo.

### Ejercicio 2 — SYN Scan (-sS): El estándar

El scan `-sS` envía un SYN, recibe SYN-ACK, y en lugar de completar el handshake, envía un RST. Más sigiloso y más rápido. **Requiere root.**

```bash
sudo nmap -sS 192.168.56.10
sudo nmap -sS 192.168.56.10-13

# Compara la velocidad
time sudo nmap -sS 192.168.56.0/24
time nmap -sT 192.168.56.0/24
```

### Ejercicio 3 — Comprendiendo los estados de puertos

Escanea el host `filtered` (192.168.56.13) y observa los diferentes estados:

```bash
sudo nmap -sS -p 22,80,443,8080,3306 192.168.56.13
```

**Estados que verás:**
- Puerto 22: `open` — SSH responde con SYN-ACK
- Puerto 80: `closed` — el host responde con RST (REJECT)
- Puerto 443: `filtered` — sin respuesta (DROP)
- Puerto 8080: `filtered` — sin respuesta (DROP)
- Puerto 3306: `filtered` — sin respuesta (DROP)

**Pregunta clave:** ¿Por qué tarda más escanear puertos `filtered` que `closed`?

### Ejercicio 4 — Especificación de puertos

```bash
# Puerto específico
sudo nmap -sS -p 80 192.168.56.10

# Rango de puertos
sudo nmap -sS -p 1-1024 192.168.56.10

# Todos los puertos (65535)
sudo nmap -sS -p- 192.168.56.10

# Los 100 puertos más comunes
sudo nmap -sS --top-ports 100 192.168.56.10-13

# Puertos específicos en múltiples hosts
sudo nmap -sS -p 22,80,443,3306,6379 192.168.56.10-13
```

### Ejercicio 5 — Scan completo de la red Kronos

Combina todo lo aprendido para generar un mapa completo de los 4 servidores:

```bash
sudo nmap -sS -p 1-10000 192.168.56.10-13 -v
```

**Documenta:** ¿Qué puertos abiertos encontraste en cada host? ¿Qué información te da eso sobre cada servidor?

### Ejercicio 6 — Sin privilegios root

```bash
# ¿Qué pasa si no tienes root?
nmap -sS 192.168.56.10   # Fallará o usará sT automáticamente
nmap 192.168.56.10        # Default sin root: usa sT
```

## Perspectiva Blue Team — SENTINEL

> *"Observa la diferencia entre lo que ven los logs con -sT vs -sS:"*

```bash
# En el servidor kronos-web, observa los logs de conexiones
vagrant ssh web
sudo tcpdump -i eth1 'tcp[tcpflags] & tcp-syn != 0' -n
```

Con `-sT` verás conexiones TCP completas (SYN → SYN-ACK → ACK → RST).
Con `-sS` verás half-open connections (SYN → SYN-ACK → RST) — nunca se completa el handshake.

> *"Ambos son detectables con un IDS decente. La diferencia está en el volumen de información que deja el atacante."*

## Limpieza

```bash
vagrant destroy -f
```
