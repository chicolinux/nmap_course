# Episodio 0 — "Iniciación"

## Briefing de ORACLE

> *"Bienvenido, Cipher. Has sido seleccionado por tus habilidades. Lo que aprenderás aquí no se enseña en ninguna universidad: el arte de ver lo que otros no ven.*
>
> *Tu primera misión es simple — aprende a conocer tu propio entorno. Antes de explorar redes enemigas, debes dominar tu propia máquina. Ghost te guiará."*

---

## Objetivo

Instalar Nmap, comprender su arquitectura básica y ejecutar tu primer escaneo — primero contra `localhost`, luego contra el servidor de entrenamiento de RED CELL.

## Infraestructura del Lab

| Host | IP | Servicios |
|---|---|---|
| Tu máquina (atacante) | host | nmap instalado |
| kronos-node-01 | 192.168.56.10 | SSH (22), HTTP (80) |

## Instrucciones

### 1. Levantar el entorno

```bash
cd labs/ep0-iniciacion
vagrant up
```

### 2. Verificar conectividad

```bash
ping 192.168.56.10
```

## Ejercicios

### Ejercicio 1 — Tu primera víctima: localhost

Escanea tu propia máquina. Esto es lo más seguro que existe.

```bash
nmap localhost
nmap 127.0.0.1
```

**Analiza el output:**
- ¿Qué puertos aparecen como `open`?
- ¿Qué servicios están corriendo?
- ¿Por qué están abiertos esos puertos?

### Ejercicio 2 — El servidor de entrenamiento

```bash
nmap 192.168.56.10
```

**Preguntas:**
- ¿Qué puertos encontró nmap?
- ¿Cuánto tiempo tardó el escaneo?
- ¿Cuál es la diferencia entre el output de localhost y el del servidor?

### Ejercicio 3 — Explorando flags básicos

```bash
# Ver la versión de nmap instalada
nmap --version

# Consultar la ayuda
nmap -h

# Scan con más verbosidad
nmap -v 192.168.56.10

# Scan con verbosidad máxima
nmap -vv 192.168.56.10
```

### Ejercicio 4 — Guardar el output

```bash
# Guardar en formato texto normal
nmap -oN mi-primer-scan.txt 192.168.56.10

# Ver el resultado
cat mi-primer-scan.txt
```

## Perspectiva Blue Team — SENTINEL

> *"Todo lo que acabas de hacer contra ese servidor, Kronos lo hace contra millones de dispositivos cada día. La diferencia es que nosotros tenemos autorización para hacerlo aquí.*
>
> *Observa el log del servidor después de tu escaneo:"*

```bash
# Conéctate a la VM y revisa los logs
vagrant ssh target
sudo tail -f /var/log/nginx/access.log
```

¿Ves las peticiones de nmap en los logs? Eso es lo que un defensor vería en tiempo real.

## Limpieza

```bash
vagrant destroy -f
```
