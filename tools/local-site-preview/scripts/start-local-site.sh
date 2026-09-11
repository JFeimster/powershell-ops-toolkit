#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") /path/to/site [port]" >&2
  exit 1
fi

SITE_PATH="$1"
PORT="${2:-8000}"

if [[ ! -e "$SITE_PATH" ]]; then
  echo "Path not found: $SITE_PATH" >&2
  exit 1
fi

if [[ -f "$SITE_PATH" ]]; then
  SITE_PATH="$(cd "$(dirname "$SITE_PATH")" && pwd)"
else
  SITE_PATH="$(cd "$SITE_PATH" && pwd)"
fi

if command -v python3 >/dev/null 2>&1; then
  PYTHON="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON="python"
else
  echo "Python was not found in PATH." >&2
  exit 1
fi

echo
echo "Serving: $SITE_PATH"
echo "Open: http://localhost:$PORT"
echo "Stop: Ctrl+C"
echo

cd "$SITE_PATH"
exec "$PYTHON" -m http.server "$PORT" --bind 127.0.0.1
