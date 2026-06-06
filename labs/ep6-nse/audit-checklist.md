# Checklist de Auditoría NSE — Operación Prometheus
## Infraestructura Kronos Systems

**Auditor (alias):** _______________
**Fecha:** _______________
**Herramienta:** nmap + NSE
**Alcance:** 192.168.56.10 – 192.168.56.14

---

## Sección 1 — SSL/TLS (kronos-sslweak: 192.168.56.10)

### Script: ssl-enum-ciphers
- [ ] Ejecutado correctamente
- **Protocolos detectados:**
  - [ ] SSLv3 (crítico si activo)
  - [ ] TLSv1.0 (deprecado)
  - [ ] TLSv1.1 (deprecado)
  - [ ] TLSv1.2 (aceptable)
  - [ ] TLSv1.3 (recomendado)
- **Cipher suites encontradas:** _______________
- **Calificación de nmap (A/B/C/F):** _______________
- **¿Ciphers con NULL encryption?** Sí / No
- **¿Ciphers EXPORT (debilitados)?** Sí / No

### Script: ssl-cert
- [ ] Ejecutado correctamente
- **CN (Common Name):** _______________
- **Organización:** _______________
- **Válido desde:** _______________
- **Válido hasta:** _______________
- **¿Expirado?** Sí / No
- **Tamaño de llave RSA:** _______________  bits
- **¿Es auto-firmado?** Sí / No

### Nivel de Riesgo SSL: ☐ Crítico  ☐ Alto  ☐ Medio  ☐ Bajo

---

## Sección 2 — SMB/Samba (kronos-samba: 192.168.56.11)

### Script: smb-security-mode
- [ ] Ejecutado correctamente
- **Versión SMB:** _______________
- **Message signing:** enabled / disabled
- **¿Signing required?** Sí / No
- **Nivel de autenticación:** _______________

### Script: smb-enum-shares
- [ ] Ejecutado correctamente

| Share | Tipo | Acceso sin auth | Notas |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

- **¿Shares accesibles sin autenticación?** Sí / No
- **¿Archivos sensibles encontrados?** _______________

### Script: smb-enum-users
- [ ] Ejecutado correctamente
- **Usuarios enumerados:** _______________

### Nivel de Riesgo SMB: ☐ Crítico  ☐ Alto  ☐ Medio  ☐ Bajo

---

## Sección 3 — HTTP (kronos-httpvuln: 192.168.56.12)

### Script: http-title
- [ ] Ejecutado correctamente
- **Título encontrado:** _______________

### Script: http-git
- [ ] Ejecutado correctamente
- **¿Repositorio .git expuesto?** Sí / No
- **URL encontrada:** _______________
- **¿Remote origin expuesto?** _______________

### Script: http-enum
- [ ] Ejecutado correctamente
- **Directorios encontrados:**

| Ruta | Código HTTP | Descripción |
|---|---|---|
| | | |
| | | |
| | | |

### Script: http-server-header
- [ ] Ejecutado correctamente
- **Server header:** _______________
- **¿Versión exacta expuesta?** Sí / No

### Archivos sensibles encontrados (acceso manual con curl/browser):
- [ ] /backup/config.bak — ¿Encontrado?
- [ ] /backup/credentials.txt — ¿Encontrado?
- [ ] /server-status — ¿Encontrado?
- **¿Qué información sensible se puede obtener?** _______________

### Nivel de Riesgo HTTP: ☐ Crítico  ☐ Alto  ☐ Medio  ☐ Bajo

---

## Sección 4 — SSH (kronos-sshweak: 192.168.56.13)

### Script: ssh-auth-methods
- [ ] Ejecutado correctamente
- **Métodos aceptados:**
  - [ ] publickey
  - [ ] password
  - [ ] keyboard-interactive
- **¿PermitRootLogin activo?** Sí / No

### Script: ssh-hostkey
- [ ] Ejecutado correctamente
- **Algoritmos de host key:** _______________
- **Fingerprints:** _______________

### Script: ssh2-enum-algos
- [ ] Ejecutado correctamente
- **Algoritmos de cifrado:** _______________
- **¿Algoritmos débiles (DES, RC4, arcfour)?** Sí / No

### Script: ssh-brute (si ejecutado)
- [ ] Ejecutado correctamente
- **¿Credenciales encontradas?** Sí / No
- **Usuario/Password:** _______________

### Nivel de Riesgo SSH: ☐ Crítico  ☐ Alto  ☐ Medio  ☐ Bajo

---

## Sección 5 — SNMP (kronos-snmppub: 192.168.56.14)

### Script: snmp-sysdescr
- [ ] Ejecutado correctamente
- **Descripción del sistema:** _______________

### Script: snmp-info
- [ ] Ejecutado correctamente
- **Community string funcional:** _______________
- **Ubicación física expuesta:** _______________
- **Contacto expuesto:** _______________

### Script: snmp-interfaces
- [ ] Ejecutado correctamente
- **Interfaces de red descubiertas:** _______________

### Nivel de Riesgo SNMP: ☐ Crítico  ☐ Alto  ☐ Medio  ☐ Bajo

---

## Resumen Ejecutivo

### Hallazgos por Severidad

| Severidad | Cantidad | Hosts Afectados |
|---|---|---|
| **Crítico** | | |
| **Alto** | | |
| **Medio** | | |
| **Bajo** | | |

### Top 3 Hallazgos más Críticos

1. **Host:** _____ | **Vuln:** _____ | **Impacto:** _____
2. **Host:** _____ | **Vuln:** _____ | **Impacto:** _____
3. **Host:** _____ | **Vuln:** _____ | **Impacto:** _____

### Recomendación de Remediación Prioritaria

_______________

---

## Comandos Utilizados

```bash
# Pega aquí todos los comandos nmap --script que ejecutaste


```

*Auditoría realizada para RED CELL — Operación Prometheus*
*Material educativo — Infraestructura de laboratorio controlado*
