# Episodio 3 — "Identidades: ¿Qué Hay Detrás de los Puertos?"

## Briefing de SENTINEL

> *"Ghost te mostró las puertas. Yo te enseño a leer los letreros.*
>
> *Una lista de puertos abiertos no vale nada por sí sola. Lo que importa es qué versión de qué software está corriendo detrás. Apache 2.4.49 tiene una vulnerabilidad crítica. OpenSSH 7.x tiene varias. PostgreSQL 9.x está sin soporte.*
>
> *Desde ambos lados del tablero — atacante y defensor — la versión de un servicio es la pieza de información más valiosa que puedes obtener."*

---

## Objetivo

Dominar la **detección de versiones** (`-sV`) y **detección de sistema operativo** (`-O`), entender cómo funcionan internamente, y construir un perfil de inteligencia completo de un objetivo.

## Infraestructura del Lab

| VM | IP | Servicios |
|---|---|---|
| kronos-apache | 192.168.56.10 | Apache2 (80), SSH (22) — headers de versión expuestos |
| kronos-mail | 192.168.56.11 | SMTP (25), IMAP (143), POP3 (110), SSH (22) |
| kronos-db | 192.168.56.12 | MariaDB (3306), PostgreSQL (5432), SSH (22) |
| kronos-multi | 192.168.56.13 | FTP (21), nginx en 8080, DNS (53), SSH (22) |

```bash
cd labs/ep3-version-os
vagrant up
```

---

## Ejercicios

### Ejercicio 1 — Detección básica de versiones (-sV)

```bash
# Versiones en un solo host
sudo nmap -sV 192.168.56.10

# Todos los hosts de la red
sudo nmap -sV 192.168.56.10-13
```

Observa cómo nmap identifica el software y versión de cada servicio.

### Ejercicio 2 — Intensidad de detección de versiones

nmap tiene 9 niveles de intensidad (0-9) para `-sV`. Mayor intensidad = más pruebas = más tiempo:

```bash
# Intensidad mínima (más rápido, menos preciso)
sudo nmap -sV --version-intensity 0 192.168.56.10

# Intensidad media (balance)
sudo nmap -sV --version-intensity 5 192.168.56.10

# Intensidad máxima (más lento, más preciso)
sudo nmap -sV --version-intensity 9 192.168.56.10

# Compara el tiempo de cada uno
time sudo nmap -sV --version-intensity 0 192.168.56.10-13
time sudo nmap -sV --version-intensity 9 192.168.56.10-13
```

### Ejercicio 3 — Detección de sistema operativo (-O)

nmap analiza detalles del stack TCP/IP (TTL, window size, opciones TCP) para inferir el OS:

```bash
# Requiere root y al menos un puerto abierto y uno cerrado para ser preciso
sudo nmap -O 192.168.56.10

# Con posibles alternativas si no hay match perfecto
sudo nmap -O --osscan-guess 192.168.56.10

# En toda la red
sudo nmap -O 192.168.56.10-13
```

**Pregunta:** ¿Identifica correctamente Alpine Linux? ¿Por qué sí o no?

### Ejercicio 4 — El scan agresivo (-A): todo en uno

`-A` combina: `-sV` (versiones) + `-O` (OS) + `-sC` (scripts default) + `--traceroute`:

```bash
sudo nmap -A 192.168.56.10

# En toda la red (tomará más tiempo)
sudo nmap -A 192.168.56.10-13
```

**Advertencia:** `-A` genera mucho tráfico y es extremadamente detectable.

### Ejercicio 5 — Traceroute integrado

```bash
sudo nmap --traceroute 192.168.56.10-13
```

### Ejercicio 6 — Scripts de detección default (-sC)

`-sC` ejecuta los scripts NSE de la categoría "default":

```bash
# Solo scripts default
sudo nmap -sC 192.168.56.10-13

# Scripts default + versiones (equivalente a parte de -A)
sudo nmap -sC -sV 192.168.56.11

# Observa el banner de Postfix, Dovecot, etc.
```

### Ejercicio 7 — Conectar manualmente para ver banners

El banner grabbing manual confirma lo que -sV detecta:

```bash
# Banner del servidor SMTP
nc 192.168.56.11 25

# Banner IMAP
nc 192.168.56.11 143

# Banner FTP
nc 192.168.56.13 21

# Banner HTTP (Apache con versión expuesta)
curl -I http://192.168.56.10
```

### Ejercicio 8 — Construir el reporte de inteligencia

Usa el template `report-template.md` para documentar todos tus hallazgos como lo haría un pen tester profesional:

```bash
sudo nmap -A -oX ep3-scan.xml 192.168.56.10-13
```

## Perspectiva Blue Team — SENTINEL

> *"Desde el lado defensor, aquí está lo que deberías hacer con esta misma información:"*

**1. Reducir la superficie de información expuesta:**
```bash
# Apache: ocultar versión
# ServerTokens Prod  → solo muestra "Apache"
# ServerSignature Off → elimina versión del footer de errores

# Postfix: ocultar versión en el banner
# smtpd_banner = $myhostname ESMTP
```

**2. Auditar tu propio inventario:**
```bash
# Escanea TU infraestructura antes que el atacante
sudo nmap -sV -O 192.168.56.10-13 -oX inventario.xml
```

**3. Identificar versiones vulnerables:**
Con las versiones identificadas, busca CVEs en:
- `https://cve.mitre.org`
- `https://nvd.nist.gov`

## Limpieza

```bash
vagrant destroy -f
```
