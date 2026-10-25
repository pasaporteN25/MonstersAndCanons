#!/bin/sh
# Uso: capturar.sh <html> <png> <ancho> <alto>. Firefox es un snap: el perfil debe estar bajo ~/snap/firefox/common.
set -e
PROF="$HOME/snap/firefox/common/t469prof"; mkdir -p "$PROF"
H=$(readlink -f "$1"); P=$(readlink -f "$(dirname "$2")")/$(basename "$2")
timeout 90 firefox --headless --no-remote --profile "$PROF" --screenshot "$P" --window-size="$3,$4" "file://$H" >/dev/null 2>&1
