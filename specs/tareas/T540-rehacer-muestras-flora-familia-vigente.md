# T540 · Rehacer muestras de flora en la familia visual vigente

- **Ejecutor:** Codex `gpt-6.1-sol`, esfuerzo medio; revisión de Codex.
- **Depende de:** T277/T437 y guía de arte §4; T539 se sustituye tras rechazo de Lucas.
- **Refs:** pedido de Lucas del 2026-10-27; `assets/sprites/map/rendered/`; `art/t537-arte-campana/`.
- **Compuerta:** muestras solamente. Lucas elige, pide cambios o rechaza cada propuesta; su aprobación escrita precede a cualquier integración.

## Leer

`specs/00-constitucion.md`, `specs/05-guia-de-arte.md` §4, `.claude/rules/arte.md`, T277/T437/T537, `art/t539-flora-alien-review/` y `art/m79-muestras/adornos/prompts.md`.

## Objetivo

Reemplazar la galería T539, rechazada por Lucas por su estilo vectorial obsoleto, con propuestas que pertenezcan a la familia dimensional pintada vigente y revisar por qué el proceso dejó pasar la desviación. Incorporar una compuerta de estilo al procedimiento de arte del proyecto.

## Alcance (sí / no)

- **Sí:** tres conceptos rasterizados de flora alienígena; PNG RGBA de 128×128 para revisión; tamaños 220/34 px; montaje claramente identificado sobre captura vigente; procedencia y causa de la falla en T539; ajuste de la guía de arte.
- **No:** integración de sprites, sustitución de referencias de juego, cambios a niveles/mapas/código, elección de una variante por Lucas, aprobación artística final o pruebas de Godot/GUT.

## Pasos

1. Revisar visualmente al menos tres recursos activos de la familia objetivo y una captura actual del juego.
2. Definir la técnica y proporción del formato a partir de esa familia, no de un recurso histórico que se reemplaza.
3. Producir conceptos y revisarlos a escala de juego y en contexto.
4. Documentar la causa del desvío anterior y agregar la compuerta previa a cualquier futura presentación de arte.
5. Dejar visible que las variantes son propuestas y esperar elección/aprobación de Lucas antes de integrar.

## Hecho cuando

La nueva galería presenta tres conceptos a detalle y a 34 px, además de montajes sobre nivel 1; conserva las fuentes generadas y explica límites; el procedimiento exige inspección de estilo vigente y revisión contextual; no se tocan assets activos ni runtime.

## Verificación

Verificar visualmente la hoja, legibilidad a 34 px, tamaño/alfa PNG, rutas locales del HTML y `git diff --check`. No ejecutar Godot/GUT al ser una tarea de arte/documentación sin integración.

## Frenar si

Los renders no guardan coherencia de volumen/material con la familia T277; la lectura a 34 px no sostiene la silueta; un montaje puede confundirse con captura real; o una integración requiere inventar ubicaciones, densidad o canon.
