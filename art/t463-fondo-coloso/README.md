# T463 · Fondo del Coloso (propuesta, sin aprobar)

Fecha: 2026-10-28. Informe: `specs/tareas/informes/T463-propuesta-fondo-coloso.md`. Revisión: `revision.html`.

- `muestra_01_claro.png`, `muestra_02_sombrio.png`: 1280×720 RGB, reducidas con Lanczos desde `sources/raw_b.png` y `sources/raw_c.png` (1672×941, salida original sin retocar).
- `sources/raw_a.png`: **propuesta descartada** por la compuerta de estilo (paisaje cinematográfico casi fotorrealista, perspectiva de horizonte; no es la familia pintada y elevada del mapa). Se conserva solo como evidencia.
- `context/`: capturas reales del motor (`capture_presentation.tscn`, con ventana: `godot --path . --resolution 1280x720 res://art/t463-fondo-coloso/capture_presentation.tscn`), reducidas a 1280×720, más la captura del nivel 15 copiada de T537.
- Generador: `codex exec -m gpt-6-luna` con su herramienta de imagen integrada (el modelo interno de imagen no se expone). Prompts en `prompts.md` (la tabla de variantes es la primera ronda; las muestras 01 y 02 salieron de una segunda ronda con el encargo corregido, ver el informe §4).
- Nada de esto está en `assets/` ni en el juego. Los `.import` de esta carpeta los ignora `.gitignore`.

## Compuerta de estilo (guía de arte §4)

Referencias inspeccionadas: `assets/sprites/map/rendered/tree.png`, `rock_a.png`, `forest_idle.png`, `m79/cactus_02.png`, `assets/sprites/enemies/rendered/colossus.png` y la captura `art/t537-arte-campana/captures/level_15_active.png`. Familia: PNG pintados y dimensionales, cámara elevada, material mate, luz arriba a la izquierda, paleta apagada y terrosa, sin contorno.
