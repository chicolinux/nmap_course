# Episodio 1 — "Cartografía: Encontrando Fantasmas en la Red"

## Briefing de GHOST

> *"RED CELL acaba de establecer una nueva safehouse. Antes de operar desde aquí, necesito que verifiques que no hay nadie más en esta red — ningún dispositivo infiltrado de Kronos.*
>
> *No me importa qué puertos tienen abiertos. Solo quiero saber QUIÉN está aquí. Para eso, usamos host discovery: identificar qué hosts están vivos sin hacer ruido innecesario."*

---

## Objetivo

Dominar las técnicas de **descubrimiento de hosts** (ping sweeps, ARP scans, ICMP, TCP/UDP discovery) y entender cuándo y por qué usar cada una.

## Infraestructura del Lab

| Host | IP | Descripción |
|---|---|---|
| Tu máquina | 192.168.56.1 (aprox.) | Atacante — ejecuta nmap desde aquí |
| safehouse-node | 192.168.56.10 | El host a descubrir |

**Nota:** La VM está en la subred `192.168.56.0/24`. Tu tarea inicial es descubrirla escaneando todo el rango.

## Instrucciones

```bash
cd labs/ep1-host-discovery
vagrant up
```

---

## Ejercicios

### Ejercicio 1 — Ping Sweep: El clásico

El scan `-sn` (anteriormente `-sP`) realiza descubrimiento de hosts sin escanear puertos.

```bash
# Escanear toda la subred /24
sudo nmap -sn 192.168.56.0/24

# Con más detalle de qué técnica usa
sudo nmap -sn -v 192.168.56.0/24
```

¿Qué hosts encontró? ¿Cuánto tardó?

### Ejercicio 2 — ARP Scan: El más confiable en LAN

En redes locales, el ARP scan es el método más preciso porque funciona a nivel de capa 2 y no puede ser bloqueado por firewalls de capa 3.

```bash
# Solo ARP (más rápido en LAN)
sudo nmap -sn -PR 192.168.56.0/24

# Comparar con un scan ICMP-only
sudo nmap -sn -PE 192.168.56.0/24
```

**Pregunta:** ¿Por qué el ARP scan no puede ser bloqueado por un firewall de capa 3?

### Ejercicio 3 — ICMP Discovery: Variantes

```bash
# ICMP Echo (el ping tradicional)
sudo nmap -sn -PE 192.168.56.10

# ICMP Timestamp request
sudo nmap -sn -PP 192.168.56.10

# ICMP Address Mask request
sudo nmap -sn -PM 192.168.56.10
```

Algunos hosts bloquean el ICMP echo pero responden a otros tipos de ICMP.

### Ejercicio 4 — TCP/UDP Discovery

```bash
# TCP SYN discovery al puerto 80
sudo nmap -sn -PS80 192.168.56.10

# TCP ACK discovery al puerto 443
sudo nmap -sn -PA443 192.168.56.10

# UDP discovery
sudo nmap -sn -PU53 192.168.56.10

# Combinar múltiples técnicas
sudo nmap -sn -PS22,80,443 -PA80 -PE 192.168.56.10
```

### Ejercicio 5 — El host que no responde a ping: -Pn

```bash
# Asumir que el host está activo (sin enviar pings)
nmap -Pn 192.168.56.10

# Útil cuando los hosts tienen ICMP bloqueado pero puertos abiertos
```

### Ejercicio 6 — Documentar tu mapa de red

Usa la plantilla `network-map-template.md` para documentar todos los hosts que encontraste. Este es el tipo de entregable que se produce en una auditoría real.

## Perspectiva Blue Team — SENTINEL

> *"Desde el lado del defensor, un sweep scan se ve así en los logs del router o firewall:"*

```
192.168.56.1 -> 192.168.56.1   ARP who-has 192.168.56.10
192.168.56.1 -> 192.168.56.10  ICMP echo request
192.168.56.1 -> 192.168.56.11  ICMP echo request
192.168.56.1 -> 192.168.56.12  ICMP echo request
... (patrón repetitivo por toda la subred)
```

> *"Un IDS bien configurado detecta este patrón en segundos. En los próximos episodios aprenderás a hacer esto más silencioso."*

## Plantillas

Completa el archivo `network-map-template.md` con los resultados de tus ejercicios.

## Limpieza

```bash
vagrant destroy -f
```
