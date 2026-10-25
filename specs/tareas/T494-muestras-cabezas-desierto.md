# T494 · 🎨 Muestras de las cabezas del desierto

- **Ejecutor:** Sonnet · muestras (propuestas, no arte final). **No Codex.**
- **Depende de / compuerta:** 🚦 T490 aprobada por Lucas y T491 hecha. **La elección es de Lucas (T495).**
- **Refs:** RF-713 (c), RF-714, D-210. **Rama:** `feature/t494-muestras-cabezas-desierto`, desde `origin/main`; un commit `T494: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M79 en `specs/01-spec.md` (RF-712 a RF-714 y las preguntas abiertas), D-210 y `specs/10-universo.md` (§4 y §6).

## Objetivo y alcance

**Estética (requisito de Lucas, 2026-10-25):** toda muestra sigue la estética **actual** de `main` (atlas de Cántaro M76/T471, postes T437/T475, decoración dimensional renderizada T277, UI vigente), **no la vieja**: no se entrega una variante plana SVG de T260. Producir muestras para que Lucas elija, sin tocar el juego. Formato: PNG RGBA de 128×128, luz arriba a la izquierda, sombra de apoyo discreta, dentro de una casilla de 64×64; se compone en la herramienta de captura, no en `assets/sprites/map/`.

Mínimo **cuatro** variantes de reemplazo de `huesos.svg` más una quinta de línea de base (cráneo de ganado mejorado): (1) cráneo de bestia alienígena de dos pares de cuernos, (2) cabeza de monstruo con cuernos curvos y mandíbula abierta, (3) cráneo con una sola cuenca grande, (4) cabeza de criatura tipo insecto con mandíbulas. Despojos de **fauna sin nombre**: no humanoides, sin símbolo A ni marcas de Moradores, sin parecerse al Lobo, la Araña ni el Escarabajo, y sin la palabra «alien» en ningún rótulo del juego (se puede usar en el nombre de archivo de trabajo). Si una muestra sugiere una especie nueva reconocible, anotarlo como pregunta; no integrarla.


## Archivos (propietario único)

Solo `art/m79-muestras/cabezas/` (fuentes, PNG, hojas y capturas). Nadie más escribe ahí; no se toca `assets/`, `scripts/`, `data/` ni `specs/`.

## Hecho cuando

Hay al menos cinco variantes numeradas, hoja a 220 y 34 px junto al cactus y la roca roja sobre el suelo del desierto, y una captura del nivel 10 con cada una puesta en lugar de `huesos`; sin integrar. El informe dice qué se probó y qué no (sin teléfono real, sin rendimiento).

## Frenar si

Falta T491 o su OK; la muestra exige cambiar el canon o un JSON de nivel; el estilo cae en SVG plano viejo; hace falta otro modelo para el arte (avisar a Lucas, no delegarlo a otro).
