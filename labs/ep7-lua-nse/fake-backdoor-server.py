#!/usr/bin/env python3
"""
PROMETHEUS-GATE — Servidor de backdoor simulado para laboratorio.
Escucha en el puerto 31337 y responde al handshake específico de Kronos.

Parte del curso: Episodio 7 — Código de Sombra
RED CELL — Operación Prometheus

SOLO PARA USO EDUCATIVO EN ENTORNO DE LABORATORIO CONTROLADO.
"""

import socket
import threading
import sys
from datetime import datetime

PORT = 31337
HANDSHAKE = b"KRONOS\x00\x01"
RESPONSE = b"PROMETHEUS-GATE v2.3.1\x00READY"
DENIED = b"UNAUTHORIZED\x00"


def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{ts}] {msg}", flush=True)


def handle_client(conn: socket.socket, addr: tuple) -> None:
    ip, port = addr
    log(f"Conexión entrante desde {ip}:{port}")
    try:
        data = conn.recv(64)
        if not data:
            log(f"  {ip}: conexión cerrada sin datos")
            return

        log(f"  {ip}: recibido {len(data)} bytes → {data.hex()}")

        if data == HANDSHAKE:
            conn.sendall(RESPONSE)
            log(f"  {ip}: HANDSHAKE CORRECTO — backdoor identificado")
        else:
            conn.sendall(DENIED)
            log(f"  {ip}: handshake incorrecto → DENEGADO")
    except (ConnectionResetError, BrokenPipeError):
        log(f"  {ip}: conexión interrumpida")
    except Exception as e:
        log(f"  {ip}: error inesperado — {e}")
    finally:
        conn.close()


def main() -> None:
    try:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind(("0.0.0.0", PORT))
        srv.listen(10)
    except PermissionError:
        print(f"Error: Puerto {PORT} requiere privilegios o ya está en uso.", file=sys.stderr)
        sys.exit(1)

    log(f"PROMETHEUS-GATE v2.3.1 escuchando en :{PORT}")
    log("Handshake esperado: 4b524f4e4f530001 (KRONOS\\x00\\x01)")
    log("Presiona Ctrl+C para detener.")

    try:
        while True:
            conn, addr = srv.accept()
            t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
            t.start()
    except KeyboardInterrupt:
        log("Deteniendo servidor...")
    finally:
        srv.close()


if __name__ == "__main__":
    main()
