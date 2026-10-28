#!/bin/bash
# uso: run.sh nombre "prompt variante"
cd "$(dirname "$0")"
COMUN=$(sed -n 's/^COMUN: //p' prompts.md)
codex exec -m gpt-6-luna --sandbox workspace-write "Usá tu herramienta de generación de imágenes para crear UNA imagen y guardala exactamente en $PWD/sources/$1.png (copiá el PNG original sin reescalar ni retocar). Encargo: $COMUN $2 Al terminar respondé solo con la ruta y las dimensiones." > sources/$1.log 2>&1
