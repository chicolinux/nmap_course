# Episodio 6 — "El Arsenal: Nmap Scripting Engine"

## Briefing de GHOST

> *"Cipher. Hasta ahora usaste nmap como un escáner. Hoy te lo presento como lo que realmente es: una plataforma de inteligencia.*
>
> *El NSE — Nmap Scripting Engine — convierte cada puerto abierto en una oportunidad de obtener información profunda. Kronos tiene la infraestructura expuesta. Nosotros tenemos el arsenal para leerla.*
>
> *Cada script que vas a usar hoy es un arma quirúrgica. Úsalos con precisión."*

---

## Objetivo

Comprender la **arquitectura del NSE**, usar scripts de múltiples categorías, y realizar una auditoría completa de vulnerabilidades contra la infraestructura de Kronos.

## Infraestructura del Lab

| VM | IP | Vulnerabilidad | Scripts NSE clave |
|---|---|---|---|
| kronos-sslweak | 192.168.56.10 | TLS 1.0/1.1, certificado RSA-1024 | `ssl-enum-ciphers`, `ssl-cert` |
| kronos-samba | 192.168.56.11 | Share SMB sin autenticación | `smb-security-mode`, `smb-enum-shares` |
| kronos-httpvuln | 192.168.56.12 | Dir listing, .git expuesto, backups | `http-git`, `http-enum`, `http-auth-finder` |
| kronos-sshweak | 192.168.56.13 | SSH con password débil (admin123) | `ssh-auth-methods`, `ssh-brute` |
| kronos-snmppub | 192.168.56.14 | SNMP community 'public' | `snmp-info`, `snmp-sysdescr` |

```bash
cd labs/ep6-nse
vagrant up
```

---

## Arquitectura NSE

### Dónde viven los scripts

```bash
ls /usr/share/nmap/scripts/ | head -30
ls /usr/share/nmap/scripts/ | wc -l   # ~600+ scripts disponibles

# Ver todas las categorías
ls /usr/share/nmap/scripts/*.nse | xargs grep -h '^categories' | sort -u
```

### Categorías principales

| Categoría | Descripción | ¿Seguro de usar? |
|---|---|---|
| `safe` | No causa daño ni carga | Sí |
| `default` | Balance: informativo + seguro | Sí |
| `discovery` | Enumeración de información | Sí |
| `version` | Detección de versiones | Sí |
| `auth` | Prueba autenticaciones | Con cuidado |
| `vuln` | Verifica vulnerabilidades | En redes autorizadas |
| `brute` | Ataques de fuerza bruta | Solo con autorización |
| `exploit` | Explota vulnerabilidades | Solo en laboratorio |
| `intrusive` | Puede afectar el servicio | Solo en laboratorio |

---

## Ejercicios

### Ejercicio 1 — Scripts default: la base

```bash
# Scripts default en todos los hosts
sudo nmap -sC 192.168.56.10-14

# Combinar con detección de versiones (recomendado)
sudo nmap -sC -sV 192.168.56.10-14
```

### Ejercicio 2 — Ayuda de scripts y documentación

```bash
# Ver documentación de un script específico
nmap --script-help ssl-enum-ciphers
nmap --script-help smb-enum-shares
nmap --script-help http-git

# Buscar scripts por nombre
ls /usr/share/nmap/scripts/smb*.nse
ls /usr/share/nmap/scripts/http*.nse | wc -l
```

### Ejercicio 3 — Auditoría SSL: kronos-sslweak

```bash
# Enumeración completa de cipher suites y protocolos
sudo nmap -p 443 --script ssl-enum-ciphers 192.168.56.10

# Información del certificado SSL
sudo nmap -p 443 --script ssl-cert 192.168.56.10

# ¿Parámetros Diffie-Hellman débiles?
sudo nmap -p 443 --script ssl-dh-params 192.168.56.10

# Todo junto
sudo nmap -p 443 --script "ssl-*" 192.168.56.10
```

**Observa:** ¿Qué protocolos están habilitados? ¿Cuáles son seguros hoy en día?

### Ejercicio 4 — SMB Enumeration: kronos-samba

```bash
# Modo de seguridad SMB
sudo nmap -p 139,445 --script smb-security-mode 192.168.56.11

# Enumerar shares (carpetas compartidas)
sudo nmap -p 139,445 --script smb-enum-shares 192.168.56.11

# Enumerar usuarios del dominio
sudo nmap -p 139,445 --script smb-enum-users 192.168.56.11

# Todo el arsenal SMB de una vez
sudo nmap -p 139,445 --script "smb-*" 192.168.56.11
```

**¿Qué encontraste?** ¿Hay shares sin autenticación?

### Ejercicio 5 — HTTP Enumeration: kronos-httpvuln

```bash
# Título de la página
sudo nmap -p 80 --script http-title 192.168.56.12

# Detectar directorio .git expuesto (vulnerabilidad grave)
sudo nmap -p 80 --script http-git 192.168.56.12

# Enumerar directorios y archivos comunes
sudo nmap -p 80 --script http-enum 192.168.56.12

# Headers del servidor (versión de Apache expuesta)
sudo nmap -p 80 --script http-server-header 192.168.56.12

# Métodos HTTP permitidos
sudo nmap -p 80 --script http-methods 192.168.56.12
```

### Ejercicio 6 — SSH Analysis: kronos-sshweak

```bash
# ¿Qué métodos de autenticación acepta?
sudo nmap -p 22 --script ssh-auth-methods 192.168.56.13

# Fingerprint de las host keys
sudo nmap -p 22 --script ssh-hostkey 192.168.56.13

# Algoritmos de cifrado soportados
sudo nmap -p 22 --script ssh2-enum-algos 192.168.56.13

# Fuerza bruta (solo en laboratorio autorizado — ¡la contraseña es admin123!)
sudo nmap -p 22 --script ssh-brute \
  --script-args userdb=/usr/share/nmap/nselib/data/usernames.lst,\
passdb=/usr/share/nmap/nselib/data/passwords.lst \
  192.168.56.13
```

### Ejercicio 7 — SNMP Enumeration: kronos-snmppub

```bash
# Información del sistema vía SNMP
sudo nmap -sU -p 161 --script snmp-info 192.168.56.14

# Descripción del sistema
sudo nmap -sU -p 161 --script snmp-sysdescr 192.168.56.14

# Interfaces de red
sudo nmap -sU -p 161 --script snmp-interfaces 192.168.56.14

# Procesos corriendo (si tiene permisos)
sudo nmap -sU -p 161 --script snmp-processes 192.168.56.14

# Todo el SNMP NSE arsenal
sudo nmap -sU -p 161 --script "snmp-*" 192.168.56.14
```

### Ejercicio 8 — El scan de vulnerabilidades completo

```bash
# Scan completo de la categoría 'vuln' en toda la red de Kronos
sudo nmap -sV --script vuln 192.168.56.10-14 -oA kronos_vuln_audit
```

**⚠️ Advertencia:** El script `vuln` puede tomar bastante tiempo y hacer mucho ruido. Solo úsalo en redes autorizadas.

### Ejercicio 9 — Argumentos de scripts

```bash
# Pasar argumentos a un script
sudo nmap -p 22 --script ssh-brute \
  --script-args "ssh-brute.firstonly=true" \
  192.168.56.13

# Argumentos desde archivo
echo "smbdomain=KRONOS" > smb-args.txt
sudo nmap -p 445 --script smb-enum-shares \
  --script-args-file smb-args.txt \
  192.168.56.11
```

## Completar la auditoría

Documenta todos tus hallazgos en `audit-checklist.md`.

## Perspectiva Blue Team — SENTINEL

> *"Ahora sabes lo que un atacante puede encontrar en minutos. Aquí está cómo remediar cada vulnerabilidad:"*

| Vulnerabilidad | Remediación |
|---|---|
| TLS 1.0/1.1 | Deshabilitar en nginx/apache: `ssl_protocols TLSv1.2 TLSv1.3;` |
| Certificado RSA-1024 | Regenerar con RSA-4096 o mejor: ECDSA P-256 |
| SMB sin auth | Eliminar guest access, requirir autenticación |
| Directory listing | `Options -Indexes` en Apache |
| .git expuesto | Bloquear en nginx/apache con `location ~/.git` deny |
| SSH password débil | `PasswordAuthentication no` + solo autenticación por llaves |
| SNMP community 'public' | Cambiar a string aleatorio o migrar a SNMPv3 |

## Limpieza

```bash
vagrant destroy -f
```
