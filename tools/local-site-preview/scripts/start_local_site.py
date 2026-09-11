#!/usr/bin/env python3
from __future__ import annotations

import argparse
import functools
import http.server
import os
from pathlib import Path
import sys


def parse_args():
    parser = argparse.ArgumentParser(
        description="Serve a static website locally without opening a browser."
    )
    parser.add_argument("path", help="Website folder or a file such as index.html")
    parser.add_argument("--port", "-p", type=int, default=8000)
    return parser.parse_args()


def main():
    args = parse_args()

    if not 1 <= args.port <= 65535:
        raise SystemExit("Port must be between 1 and 65535.")

    source = Path(args.path).expanduser()
    if not source.exists():
        raise SystemExit(f"Path not found: {source}")

    site_dir = source.parent if source.is_file() else source
    site_dir = site_dir.resolve()

    handler = functools.partial(
        http.server.SimpleHTTPRequestHandler,
        directory=str(site_dir),
    )

    try:
        server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    except OSError as exc:
        raise SystemExit(
            f"Could not start localhost server on port {args.port}: {exc}\n"
            f"Try another port, for example --port {args.port + 1}"
        )

    print()
    print(f"Serving: {site_dir}")
    print(f"Open: http://localhost:{args.port}")
    print("Stop: Ctrl+C")
    print()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
