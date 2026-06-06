#!/usr/bin/env python3
"""
Parsea el output XML de nmap y genera una tabla resumen.
Uso: python3 parse-nmap-xml.py <archivo.xml>

Parte del curso: Episodio 5 — El Mapa Completo
RED CELL — Operación Prometheus
"""

import sys
import xml.etree.ElementTree as ET
from datetime import datetime


def parse_nmap_xml(filepath: str) -> None:
    tree = ET.parse(filepath)
    root = tree.getroot()

    # Metadata del scan
    args = root.get("args", "N/A")
    start_str = root.get("startstr", "N/A")
    elapsed = root.find("runstats/finished")
    elapsed_time = elapsed.get("elapsed", "N/A") if elapsed is not None else "N/A"

    print("=" * 72)
    print("  RED CELL — Mapa de Red / Operación Prometheus")
    print(f"  Generado: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"  Comando:  {args}")
    print(f"  Inicio:   {start_str}  |  Duración: {elapsed_time}s")
    print("=" * 72)
    print()

    hosts_up = 0
    total_open_ports = 0

    for host in root.findall("host"):
        status = host.find("status")
        if status is None or status.get("state") != "up":
            continue

        hosts_up += 1

        addr_el = host.find("address[@addrtype='ipv4']")
        ip = addr_el.get("addr") if addr_el is not None else "?"

        hostnames_el = host.find("hostnames")
        hostname = ""
        if hostnames_el is not None:
            hn = hostnames_el.find("hostname[@type='PTR']")
            if hn is None:
                hn = hostnames_el.find("hostname")
            if hn is not None:
                hostname = hn.get("name", "")

        os_el = host.find("os/osmatch")
        os_name = os_el.get("name", "unknown") if os_el is not None else "unknown"
        os_acc = os_el.get("accuracy", "?") if os_el is not None else "?"

        display_name = f"{ip}" if not hostname else f"{ip} ({hostname})"
        print(f"HOST: {display_name}")
        print(f"  OS: {os_name} [{os_acc}% confidence]")
        print()

        ports_el = host.find("ports")
        if ports_el is None:
            print("  (sin puertos encontrados)")
            print()
            continue

        print(f"  {'PUERTO':<12} {'ESTADO':<12} {'SERVICIO':<15} VERSIÓN")
        print(f"  {'-'*60}")

        open_count = 0
        for port in ports_el.findall("port"):
            portid = port.get("portid", "?")
            protocol = port.get("protocol", "tcp")
            state_el = port.find("state")
            state = state_el.get("state", "unknown") if state_el is not None else "unknown"

            service_el = port.find("service")
            svc_name = ""
            svc_version = ""
            if service_el is not None:
                svc_name = service_el.get("name", "")
                product = service_el.get("product", "")
                version = service_el.get("version", "")
                extra = service_el.get("extrainfo", "")
                svc_version = " ".join(filter(None, [product, version, extra]))

            port_str = f"{portid}/{protocol}"
            print(f"  {port_str:<12} {state:<12} {svc_name:<15} {svc_version}")

            if state == "open":
                open_count += 1
                total_open_ports += 1

        print(f"\n  Puertos abiertos: {open_count}")
        print()

    print("=" * 72)
    print(f"RESUMEN: {hosts_up} host(s) activos | {total_open_ports} puerto(s) abiertos en total")
    print("=" * 72)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <archivo_nmap.xml>")
        print()
        print("Genera el XML con:")
        print("  sudo nmap -sS -sV -oX scan.xml <target>")
        sys.exit(1)

    try:
        parse_nmap_xml(sys.argv[1])
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{sys.argv[1]}'")
        sys.exit(1)
    except ET.ParseError as e:
        print(f"Error: El archivo no es XML válido de nmap: {e}")
        sys.exit(1)
