# Episodio 5 — "El Mapa Completo: Técnicas Avanzadas y Outputs"

## Briefing de ORACLE

> *"Cipher. Llegó el momento. Hemos identificado la infraestructura completa de Kronos y necesitamos un mapa irrefutable — documentado, estructurado, listo para ser presentado como evidencia.*
>
> *Los episodios anteriores te dieron las herramientas básicas. Hoy las combinas todas: UDP, firewalls complejos, y output en múltiples formatos. Cuando termines, tendrás un dossier completo de la red enemiga."*

---

## Objetivo

Dominar **escaneos UDP**, los scans TCP avanzados (NULL, FIN, Xmas, ACK, Window), los **formatos de output** de nmap (-oN, -oX, -oG, -oA), y combinar todas las técnicas en comandos de producción.

## Infraestructura del Lab

| VM | IP | Servicios | Ejercicio principal |
|---|---|---|---|
| kronos-snmp | 192.168.56.10 | SSH (22), SNMP UDP (161) | UDP scanning |
| kronos-dns | 192.168.56.11 | SSH (22), DNS TCP/UDP (53) | UDP + zone transfer |
| kronos-ntp | 192.168.56.12 | SSH (22), NTP UDP (123) | UDP scanning |
| kronos-nfs | 192.168.56.13 | SSH (22), NFS TCP (2049) | RPC/NFS |
| kronos-acktgt | 192.168.56.14 | Solo firewall rules | ACK scan, NULL/FIN/Xmas |
| kronos-mixed | 192.168.56.15 | HTTP(80), HTTPS(443), MySQL(3306), 8888, 9000 | Output formats |

```bash
cd labs/ep5-advanced-outputs
vagrant up   # Tarda más — son 6 VMs
```

---

## Ejercicios

### Ejercicio 1 — UDP Scanning (-sU): El protocolo olvidado

UDP no tiene three-way handshake. Por eso es más lento: nmap envía un paquete UDP y espera hasta que el host responda con un ICMP "port unreachable" (closed) o nada (open|filtered).

```bash
# UDP scan en los puertos más comunes
sudo nmap -sU --top-ports 20 192.168.56.10-12

# Forzar detección de SNMP, DNS, NTP (los más comunes en redes)
sudo nmap -sU -p 53,123,161 192.168.56.10-12

# ¿Por qué tarda tanto? Observa el tiempo
time sudo nmap -sU -p 1-200 192.168.56.10
```

**¿Por qué es open|filtered?** Cuando UDP no recibe respuesta, nmap no puede determinar si el puerto está abierto (servicio corriendo, ignorando el paquete) o filtrado (firewall dropea).

### Ejercicio 2 — Combinar TCP + UDP en un solo scan

```bash
# Scan completo: puertos TCP + UDP simultáneamente
sudo nmap -sS -sU -p T:1-1000,U:53,123,161,2049 192.168.56.10-13
```

### Ejercicio 3 — TCP Exóticos: NULL, FIN, Xmas

Estos scans evaden firewalls stateless que solo bloquean paquetes SYN:

| Scan | Flag | Comportamiento esperado en Linux |
|---|---|---|
| NULL (-sN) | Sin flags | open: no responde; closed: RST |
| FIN (-sF) | FIN | open: no responde; closed: RST |
| Xmas (-sX) | FIN+PSH+URG | open: no responde; closed: RST |

```bash
# NULL scan
sudo nmap -sN 192.168.56.14

# FIN scan
sudo nmap -sF 192.168.56.14

# Xmas scan (todos los flags de datos activados)
sudo nmap -sX 192.168.56.14

# Nota: en Linux, puertos open aparecerán como open|filtered
# porque Linux no responde a paquetes inválidos para puertos abiertos
```

### Ejercicio 4 — ACK Scan: Mapeando el Firewall

El ACK scan (-sA) NO detecta puertos abiertos — detecta **reglas de firewall**:
- **unfiltered**: el host responde con RST (el paquete ACK llegó)
- **filtered**: sin respuesta (el firewall bloqueó el paquete)

```bash
sudo nmap -sA -p 22,80,443,8080,3306 192.168.56.14
```

Kronos-acktgt tiene:
- Puerto 22, 80: ACCEPT → **unfiltered**
- Puerto 443: DROP → **filtered**
- Puerto 8080: REJECT → **unfiltered** (ICMP unreachable llega)

### Ejercicio 5 — Formatos de Output

```bash
# Normal (legible por humanos)
sudo nmap -sS -sV 192.168.56.10-15 -oN scan_normal.txt

# XML (para procesamiento automático)
sudo nmap -sS -sV 192.168.56.10-15 -oX scan.xml

# Grepable (para scripts de shell)
sudo nmap -sS -sV 192.168.56.10-15 -oG scan_grepable.txt

# Todos los formatos a la vez (recomendado en auditorías reales)
sudo nmap -sS -sV 192.168.56.10-15 -oA scan_completo

# Los archivos generados: scan_completo.nmap, scan_completo.xml, scan_completo.gnmap
ls scan_completo*
```

### Ejercicio 6 — Procesar el XML con Python

```bash
# Genera primero el XML
sudo nmap -sS -sV 192.168.56.10-15 -oX kronos_map.xml

# Procesa con el script incluido
python3 parse-nmap-xml.py kronos_map.xml
```

### Ejercicio 7 — El scan de producción: todo en uno

Este es el tipo de comando que usarías en una auditoría real:

```bash
sudo nmap \
  -sS -sU \
  -sV --version-intensity 7 \
  -O --osscan-guess \
  -p T:1-10000,U:53,123,161,2049 \
  --top-ports 0 \
  -T3 \
  --min-parallelism 10 \
  -oA kronos_full_audit \
  192.168.56.10-15
```

### Ejercicio 8 — Excluir hosts y usar listas

```bash
# Escanear con exclusiones
sudo nmap -sS 192.168.56.0/24 --exclude 192.168.56.1,192.168.56.2

# Leer hosts desde archivo
echo "192.168.56.10
192.168.56.11
192.168.56.15" > targets.txt
sudo nmap -sS -iL targets.txt -oA scan_selective
```

## Perspectiva Blue Team — SENTINEL

> *"Usamos nmap ofensivamente. Aquí está cómo usarlo para defender:"*

```bash
# Inventario programado de tu red (corre esto cada semana)
sudo nmap -sS -sV -O -oX inventario_$(date +%Y%m%d).xml 192.168.56.0/24

# Comparar dos inventarios para detectar cambios (nuevo host = posible intrusión)
# ndiff es parte del paquete nmap
ndiff inventario_anterior.xml inventario_$(date +%Y%m%d).xml
```

> *"Un nuevo puerto abierto que no existía la semana pasada es una alerta crítica. ndiff te lo dice en segundos."*

## Limpieza

```bash
vagrant destroy -f
```
