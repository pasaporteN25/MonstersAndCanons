# T547 · Muestra de retiro del arte viejo de T233

**Fecha:** 2026-10-28. **Estado:** muestra para decidir, **no mergeable**. Nada de esto toca `main`: el borrado real espera el OK de Lucas.
**Pedido:** Lucas dijo que el arte viejo de T233 «no nos sirve» y quiere ver qué se borraría antes de borrar.
**Cómo se midió:** `grep` sobre todo el repositorio, lectura de `map_drawings.gd`, `level_decor.gd`, `epilogue_screen.gd`, `level_file.gd` y los tests, capturas reales del juego a 1280×720 (`art/t547-muestra/capture.tscn`) y un ensayo de borrado con `--import` y GUT completo.

## 1. Tabla de decisión

| Candidato | ¿Quién lo usa hoy? | ¿Se ve en partida? | Qué pasa al quitarlo | Decisión |
|---|---|---|---|---|
| `map/hito.svg` | **Nadie.** No está en `MapDrawings` ni en ninguna leyenda; solo existe su `.import` y se nombra en docs (T233, T538, `CONTENIDO.md` habla del «hito» como concepto, y los niveles 11 a 13 usan `roca_marcada`). | No. | Nada: no hay `preload` ni clave. | **BORRAR YA** |
| `map/supply_conveyor.svg` | Solo el catálogo (`KINDS`, `TEXTURES` y su `preload` en `map_drawings.gd`) y la lista de `test_level_15.gd:186`. **Ningún nivel lo pide** (`data/levels/*.json`). El concepto T527 no incluye cinta transportadora. | No: ningún nivel lo dibuja. | El catálogo pasa de 33 a 32 dibujos: hay que quitarlo del código y ajustar 3 tests de conteo. Un mapa de la comunidad que lo nombrara dejaría de cargar (error «el dibujo no existe»); en el repositorio no hay ninguno. | **BORRAR YA** (con los ajustes de código y tests) |
| `map/supply_depot.svg` | `level_15.json` (letra `d`, casilla (25,5)) vía `MapDrawings`. Test: cuenta de 2 a 4 piezas al borde. | **Sí**, nivel 15: la casita de la derecha (captura `antes_1_nivel_15.png`). | Si se borra el SVG sin cambiar el código, **`map_drawings.gd` no compila** (`preload`) y rompe todo lo que lo use. Con un fallback, el nivel 15 sigue cargando. | **REEMPLAZAR** con la pieza de T527 (taller/herrería en ruinas) cuando se integre; mientras tanto fallback neutro (escombro) |
| `map/supply_line_pole.svg` | `level_15.json` (letra `p`, casilla (21,11)). | **Sí**, nivel 15: el poste de abajo a la derecha. | Igual que el anterior. | **REEMPLAZAR** con el farol roto de T527 |
| `map/supply_cart.svg` | `level_15.json` (letra `v`, casilla (15,11)). | **Sí**, nivel 15: el carrito de abajo. | Igual que el anterior. | **REEMPLAZAR** con la nave en ruinas de T527 (o fallback neutro si Lucas prefiere cerrar sin ella) |
| `story/epilogue.png` (1920×1080, 2,4 MB) | `epilogue_screen.gd:13` (`preload`) y `test_epilogue.gd:201` (exige 1920×1080). Se muestra al ganar el nivel 15. | **Sí**, en el epílogo (`antes_2_epilogo.png`). | Sin la imagen, `epilogue_screen.gd` **no compila**: no se puede borrar sin sustituto. | **REEMPLAZAR** con la imagen de T546; hasta entonces, un fondo neutro de 1920×1080 |
| `art/t233-final/` (7,5 MB: fuentes, capturas, `pack.gd`, `capture.*`, validaciones) | **El juego no carga nada de ahí.** Lo citan: `art/t537-arte-campana/revision.html` (una tarjeta con `epilogue_preview.png`), `art/t267a/contact.gd` (lee `central_master.svg` para una muestra vieja), manifiestos de T260/T267/T277/M80 y docs. | No (es material de trabajo). | Se rompe una imagen de la galería T537 (se quita la tarjeta, como pidió Lucas) y el script histórico `art/t267a/contact.gd`. | **BORRAR YA**, con una salvedad abajo |
| Lo que cita la galería `art/t537-arte-campana/` | Solo la tarjeta del epílogo apunta a T233. El resto son capturas del juego (no se tocan). | No. | Se quita esa tarjeta del `revision.html`. | **BORRAR YA** (solo esa tarjeta) |

**Salvedad sobre `art/t233-final/`.** Ahí vive también `sources/central_master.svg` y su manifiesto: son el origen de `assets/sprites/map/rendered/central_1..4.png`, que **sí están en el juego** (nivel 15, T234) y que **no** están en la lista de Lucas. Borrar la carpeta borra el origen de la central, no la central. Conviene que Lucas confirme que está bien perder esa fuente (los PNG quedan).

## 2. Evidencia de uso

- **Niveles:** solo `data/levels/level_15.json` usa `supply_*` (letras `d`, `p`, `v`). Ningún otro nivel de la campaña, ni el 14 (la captura `antes_1_nivel_14.png` no tiene piezas), usa esas claves ni `hito`. `ensayo_metadata.json` y `antes_metadata.json` lo confirman: el nivel 14 tiene 0 piezas de abastecimiento y el 15 tiene 3.
- **Código:** `LevelDecor` pinta cualquier objeto del catálogo sin casos especiales para `supply_*`; todo pasa por `MapDrawings.TEXTURES`. `LevelFile` rechaza una clave fuera del catálogo con el error «el dibujo … no existe».
- **Editor y Wiki:** `scenes/editor/` no ofrece estos dibujos (solo `banner_editor.gd` usa `MapDrawings`, y para el poste de banderines). La Wiki (`data/wiki`) no los nombra. Mapas de la comunidad guardados por jugadores: **no se pueden revisar desde el repositorio**; si alguien usó `supply_*` o `supply_conveyor`, ese mapa dejaría de cargar. No se probó.
- **Tests que los nombran:** `test_level_15.gd` (lista de ids y de 2 a 4 piezas al borde, RF-480), `test_map_drawings.gd` (33 ids, 29 objetos, «se pintaron los 33»), `test_map_legend.gd` (33 ids), `test_epilogue.gd` (imagen de 1920×1080). `test_resource_audit.gd` no los detectó como huérfanos (busca por nombre en todo el texto y `hito` aparece en muchos textos), así que no avisa de `hito.svg`.
- **Capturas** (1280×720, escena real): `art/t547-muestra/antes_1_nivel_15.png`, `antes_recortes_supply.png` (las piezas ampliadas; el depósito queda cortado por el borde derecho del recorte), `antes_1_nivel_14.png` y `antes_2_epilogo.png`.

## 3. Ensayo (commit «ENSAYO T547», no mergear)

Qué se aplicó: se borraron `hito.svg`, `supply_conveyor.svg`, `supply_depot.svg`, `supply_line_pole.svg`, `supply_cart.svg` (con sus `.import`) y `art/t233-final/`; los tres `supply_*` en uso apuntan temporalmente a `RUBBLE[0]` (escombro) en `MapDrawings.TEXTURES`; `epilogue.png` se reemplazó por un degradé oscuro de 1920×1080; se quitó la tarjeta de T233 de `revision.html`.

Resultado:

- `godot --headless --import`: **exit 0**, sin errores en la salida.
- **GUT completo: 2552 de 2552 pasan, 0 `SCRIPT ERROR`**, pero **después de ajustar 4 tests de conteo** que fallarían por el cambio de catálogo: `test_map_legend.gd` (33 → 32), `test_map_drawings.gd` (29 → 28 objetos y el mensaje «los 33»), `test_level_15.gd` (sacar `supply_conveyor` de la lista). Sin esos ajustes fallan los de conteo; sin el fallback en `map_drawings.gd` o sin sustituto de `epilogue.png`, los `preload` rompen la carga de `MapDrawings` y de `EpilogueScreen` (esto último es razonamiento, no se corrió).
- **Línea de base** (antes del ensayo, mismo `main`): 2551 de 2552; falló `test_range_preview.gd:291` («y no queda contada como viva»). No se repitió en la corrida del ensayo; parece intermitente y no tiene que ver con este arte.
- **Capturas del ensayo:** `ensayo_1_nivel_15.png` (en las tres casillas ahora hay escombros en vez de casita, carrito y poste; el nivel sigue siendo jugable y con la central intacta), `ensayo_recortes_supply.png`, `ensayo_1_nivel_14.png`, `ensayo_2_epilogo.png` (fondo neutro con el texto y los botones).

Referencias que **quedan por arreglar** si se hace el borrado real:

1. `art/t267a/contact.gd` línea 6 apunta a `art/t233-final/sources/central_master.svg` (script histórico de una muestra; ya no corre).
2. Manifiestos y docs que citan los archivos borrados: `art/t260-decoration/*`, `art/m79-inventario/inventario.md`, `art/m80-muestras/marcas/*`, `art/t267a`, `art/t267b`, `art/t277-integracion`, `art/t537-arte-campana/captures/map_metadata.json`, `art/t527-abastecimiento/revision.html`, `tools/t475_planos_postes.py` (mapa de nombres), `CONTENIDO.md`, `specs/01-spec.md`, `specs/02-plan-tecnico.md`, `specs/03-tareas.md`, `specs/tareas/T233-arte-final.md`, `specs/tareas/README.md`, `specs/intro/guion.md`, `specs/publicacion/revision-repo.md`. Son texto histórico; se actualizan o se dejan como historia.
3. El ensayo usa escombro como fallback solo para medir: no es una propuesta visual.
4. `CHANGELOG.md`/`CONTENIDO.md` (nivel 15: «también existe `supply_conveyor`»): corregir en el borrado real.

## 4. Propuesta

1. **Borrar ya:** `hito.svg`, `supply_conveyor.svg` (con ajuste de los 3 tests de conteo y del catálogo), `art/t233-final/` (si Lucas acepta perder las fuentes de la central) y la tarjeta de T233 de la galería.
2. **Reemplazar (necesitan decisión de Lucas):** `supply_depot`, `supply_line_pole`, `supply_cart` por las piezas de T527 (taller en ruinas, farol roto, nave en ruinas; hoy sin integrar y con las decisiones de alcance de T538 abiertas: reuso de `stat_resources.svg`), y `epilogue.png` por la imagen de T546. Hasta que lleguen, mantenerlos evita un nivel 15 sin abastecimiento visible y un epílogo sin imagen; si se prefiere cerrar ya, usar un fallback y que T527/T546 lo reemplacen.
3. **Mantener por ahora:** nada de la lista requiere quedarse indefinidamente; solo los cuatro «reemplazar» se mantienen hasta tener sustituto.
