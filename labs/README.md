# Labs — Curso de Nmap

Cada lab incluye un `Vagrantfile` para levantar el entorno y un `README.md` con instrucciones detalladas.

| Episodio | Lab | Descripción |
|---|---|---|
| 0 | [Iniciación](ep0-iniciacion/) | Instalación de Nmap, primer escaneo contra `localhost` y el servidor de entrenamiento de RED CELL. |
| 1 | [Cartografía: Encontrando Fantasmas en la Red](ep1-host-discovery/) | Técnicas de descubrimiento de hosts: ping sweeps, ARP scans, ICMP y TCP/UDP discovery. |
| 2 | [Las Puertas del Bastión: Escaneo de Puertos](ep2-port-scanning/) | Escaneos TCP Connect y SYN, estados de puertos (`open`, `closed`, `filtered`) y lectura de resultados. |
| 3 | [Identidades: ¿Qué Hay Detrás de los Puertos?](ep3-version-os/) | Detección de versiones de servicios (`-sV`) y sistema operativo (`-O`) para construir perfiles de inteligencia. |
| 4 | [Sombras: El Arte de Moverse sin Ser Visto](ep4-evasion/) | Técnicas de evasión y sigilo: timing templates, fragmentación de paquetes, decoys y manipulación de puertos de origen. |
| 5 | [El Mapa Completo: Técnicas Avanzadas y Outputs](ep5-advanced-outputs/) | Escaneos UDP, scans TCP avanzados (NULL, FIN, Xmas, ACK) y formatos de salida (`-oN`, `-oX`, `-oG`, `-oA`). |
| 6 | [El Arsenal: Nmap Scripting Engine](ep6-nse/) | Arquitectura del NSE, uso de scripts por categoría y auditoría completa de vulnerabilidades. |
| 7 | [Código de Sombra: Lua y NSE Avanzado](ep7-lua-nse/) | Lua básico aplicado al NSE y escritura de un script personalizado para detectar el backdoor PROMETHEUS-GATE. |
