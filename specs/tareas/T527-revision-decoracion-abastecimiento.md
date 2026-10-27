# T527 · Revisar y proponer reemplazos para la cadena de abastecimiento del nivel 15

- **Ejecutor:** Codex · **Depende de:** T267/T277 (familia dimensional actual); aprobación de Lucas antes de producir o integrar assets finales · **Tamaño:** chico
- **Refs:** M52, M79, T233, T267/T277, T524; `data/levels/level_15.json`; `specs/05-guia-de-arte.md` §4–5.

## Objetivo

Identificar los tres adornos que Lucas señaló en la captura de La Central y preparar una muestra conceptual para decidir su dirección. La captura muestra los SVG históricos de la cadena de abastecimiento; no son sustituciones faltantes de M79 ni sprites de T277.

## Alcance

- Revisar el mapeo de los adornos en el nivel 15 y su uso en `MapDrawings`.
- Proponer una nave exploradora individual en ruinas para `supply_cart` y una pareja visual restaurada para una posible etapa posterior.
- Proponer un taller/herrería de frontera en ruinas para `supply_depot` y una pareja restaurada.
- Para `supply_line_pole`, evaluar reutilizar un recurso ya existente, sin producir otro asset. Candidato a revisar: `assets/sprites/ui/stat_resources.svg` (lingotes de hierro y bronce); no se cambia su uso ni tamaño sin aprobación.
- Registrar si existe un estado de zona controlada que permita alternar adornos. Si no existe, dejar la restauración como idea posterior sin diseñar progresión ni guardado.
- Guardar la hoja conceptual, el prompt y una galería de revisión. Si Lucas pide cambios, conservar la versión anterior y mostrar la revisión. No integrar sprites, alterar mapas, código, leyendas ni mecánicas.

## Hecho cuando

- La muestra compara nave y taller en estados arruinado/restaurado y explica la reutilización propuesta para el poste.
- Se identifica qué significa cada pieza en el nivel y qué decisiones faltan.
- Lucas puede aprobar, pedir cambios o descartar cada propuesta antes de producir arte final.

## Verificación

Revisión estática del JSON, `MapDrawings` y referencias de arte; revisión visual de la hoja actualizada; `git diff --check`. No correr Godot/GUT: no hay assets integrados ni cambios de juego.

## Frenar si

La propuesta requiere cambiar el significado jugable de la cadena de abastecimiento, agregar progresión por zona controlada o cambiar recursos/guardados. Eso necesita otra spec y aprobación.

## Revisión de Lucas · 2026-10-27

Lucas indicó que le gustan los conceptos y pidió que el módulo luminoso de la nave destruida se vea como un farol roto oscuro y apagado. La galería muestra la revisión `sources/conceptos-farol-roto.png` y conserva la hoja inicial para comparar. La dirección conceptual de nave/taller quedó aceptada; la reutilización de lingotes en el lugar del poste y el uso concreto de las piezas siguen pendientes de confirmación antes de cualquier integración.
