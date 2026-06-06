# Episodio 4 — "Sombras: El Arte de Moverse sin Ser Visto"

## Briefing de PHANTOM

> *"Cipher. Soy Phantom. Ghost me pidió que tomara el control de esta sesión.*
>
> *El sistema de detección de Kronos te identificó en los episodios anteriores. Dejaste huellas digitales por todas partes — cada paquete SYN, cada ICMP request, cada conexión completa. Kronos tiene logs de todo eso.*
>
> *Hoy te enseño a volverte invisible. No es magia — es física de redes y timing."*

---

## Objetivo

Aprender las técnicas de **evasión y sigilo** en nmap: timing templates, rate limiting, fragmentación de paquetes, decoys y source port manipulation. Ver ambos lados: cómo evadimos detección y cómo la detectamos.

## Infraestructura del Lab

| VM | IP | Descripción | Técnica a practicar |
|---|---|---|---|
| kronos-honeypot | 192.168.56.10 | ICMP up, todo TCP DROPped | Hosts engañosos |
| kronos-ratelim | 192.168.56.11 | Rate limiting (15 conn/seg) | Timing templates |
| kronos-stealth | 192.168.56.12 | Puerto 80 solo con src_port=53 | `--source-port` |
| kronos-normal1 | 192.168.56.13 | Sin restricciones | Decoys |
| kronos-normal2 | 192.168.56.14 | FTP + HTTP:8080 | Decoys + fragmentation |

```bash
cd labs/ep4-evasion
vagrant up
```

---

## Ejercicios

### Ejercicio 1 — El honeypot: Cuando el host miente

```bash
# El host responde a ping (parece vivo)
ping 192.168.56.10

# Pero nmap dice que todos los puertos están filtrados
sudo nmap -sS -p 1-1000 192.168.56.10

# Incluso con -Pn (asumiendo que está activo)
sudo nmap -sS -Pn -p 22,80,443 192.168.56.10
```

**Conclusión:** Un host "up" no significa que tenga servicios accesibles. Los honeypots explotan exactamente esto.

### Ejercicio 2 — Timing Templates: De Paranoico a Insano

nmap tiene 6 templates de timing (-T0 a -T5):

| Template | Nombre | Delay entre probes |
|---|---|---|
| -T0 | Paranoid | 5 minutos |
| -T1 | Sneaky | 15 segundos |
| -T2 | Polite | 0.4 segundos |
| -T3 | Normal | Adaptativo (default) |
| -T4 | Aggressive | Reducido agresivamente |
| -T5 | Insane | Sin delays |

```bash
# El IDS en kronos-ratelim bloquea scans rápidos
# Scan rápido — muchos paquetes bloqueados, resultados imprecisos
sudo nmap -sS -T5 -p 1-500 192.168.56.11

# Scan lento — debajo del umbral de rate limiting
sudo nmap -sS -T2 -p 1-500 192.168.56.11

# Control: scan normal en host sin rate limiting
sudo nmap -sS -T5 -p 1-500 192.168.56.13

# Compara los resultados de puertos encontrados
```

**Pregunta:** ¿Cuántos puertos encontró -T5 vs -T2 en kronos-ratelim? ¿Por qué difieren?

### Ejercicio 3 — Control granular de timing

```bash
# Delay mínimo entre probes
sudo nmap -sS --scan-delay 1s 192.168.56.11

# Tasa máxima de paquetes por segundo
sudo nmap -sS --max-rate 10 192.168.56.11

# Paralelismo
sudo nmap -sS --min-parallelism 1 --max-parallelism 5 192.168.56.11
```

### Ejercicio 4 — Source Port Manipulation: Explotando reglas de firewall

kronos-stealth tiene puerto 80 bloqueado... excepto si el paquete viene del puerto 53:

```bash
# Scan normal — puerto 80 aparece como filtered
sudo nmap -sS -p 80 192.168.56.12

# Con source port 53 — el firewall lo deja pasar
sudo nmap -sS -p 80 --source-port 53 192.168.56.12

# Verificar manualmente con ncat
ncat --source-port 53 192.168.56.12 80
```

**Lección de blue team:** Nunca uses el puerto de origen como criterio de seguridad — es trivialmente falsificable.

### Ejercicio 5 — Decoy Scanning: Diluyendo tu identidad

Los decoys hacen que el scan parezca provenir de múltiples IPs simultáneamente, confundiendo los logs del defensor:

```bash
# Decoys aleatorios (RND genera IPs random)
sudo nmap -sS -D RND:10 192.168.56.13

# Decoys específicos + tu IP real en el medio (ME)
sudo nmap -sS -D 10.0.0.1,10.0.0.2,ME,10.0.0.3 192.168.56.13

# Observa en Wireshark: múltiples IPs origen para el mismo scan
```

**Importante:** Los decoys solo funcionan si las IPs falsas son alcanzables desde el target (de lo contrario, el target envía RST a IPs inexistentes, lo cual es un indicador).

### Ejercicio 6 — Fragmentación de paquetes

Fragmentar los paquetes SYN puede evadir firewalls stateless y algunos IDS que no reensamblan fragmentos:

```bash
# Fragmentar en paquetes de 8 bytes
sudo nmap -sS -f 192.168.56.13

# MTU específico (debe ser múltiplo de 8)
sudo nmap -sS --mtu 16 192.168.56.13

# Captura con Wireshark para ver los fragmentos IP
```

### Ejercicio 7 — Randomizar el orden de hosts

```bash
# En lugar de escanear .10 → .11 → .12... en orden
# Randomiza el orden para parecer menos sistemático
sudo nmap -sS --randomize-hosts 192.168.56.10-14
```

## Perspectiva Blue Team — SENTINEL

> *"Todo lo que Phantom te enseñó hoy, yo te enseño a detectarlo:"*

**Detectar scans lentos (-T0/-T1):**
- Correlación temporal en logs: misma IP origen a lo largo de horas/días
- SIEM con ventanas de análisis largas (1h, 24h)
- Número anormal de RSTs desde una sola IP

**Detectar decoys:**
- IPs origen que no existen en tablas ARP
- Tráfico asimétrico: paquetes entran de IPs que nunca han respondido ARP

**Detectar source port manipulation:**
- Tráfico en puerto 80 con src_port=53 que NO viene de servidores DNS conocidos
- Correlación con tabla de servidores DNS autorizados

```bash
# En kronos-ratelim, observa los logs de iptables para ver paquetes bloqueados
vagrant ssh ratelim
sudo dmesg | grep -i iptables | tail -20
```

## Limpieza

```bash
vagrant destroy -f
```
