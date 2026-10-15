# T257 · Arte provisional de La Cuadrilla

- **Ejecutor:** Codex.
- **Tipo:** 🎨 Dos criaturas independientes, no Moradores.
- **Depende de:** T252 (hecha). No depende de los datos de T253.
- **Compuerta:** el despacho autoriza **arte provisional** para revisión; la aprobación artística de Lucas sigue pendiente. No se declara producción definitiva.
- **Tamaño:** una entrega, un commit `T257: arte provisional de La Cuadrilla`.

## Objetivo

Preparar al **Ratero**, chico, bajo, alargado y rápido, y al **Cargador**, ancho y lento, con una bolsa más grande que el cuerpo. Deben leerse distintos del Ladrón y entre sí a 34 px, sin capucha, capa, símbolo A ni marcas de las comunidades. Ninguno manda al otro.

## Leer

`specs/tareas/README.md`, `specs/00-constitucion.md`, `.claude/rules/arte.md`, `.claude/rules/specs.md`, guía completa `specs/05-guia-de-arte.md`, `specs/10-universo.md` §4.2, RF-485 a RF-491 y D-094; formato de `T244-arte-jefe-supremo.md` y Ladrón aprobado M43.

## Concepto propuesto

**Ratero:** cuerpo horizontal, hocico afilado, orejas descubiertas, cola corta y patas extendidas. Piel cobre rosada clara, ojo pequeño rasgado y colmillo; sin bolsa ni indumentaria. **Cargador:** cuerpo compacto y cabeza descubierta, pasos cortos, brazos que sujetan una bolsa vertical dominante; piel terracota oscura de la misma familia cálida. La bolsa es lona neutra, sin emblema, joyas dibujadas ni indicios de jerarquía. Las proporciones y materiales son provisionales: Lucas puede pedir cambios.

## Entregables

| Pieza | Formato y destino |
|---|---|
| `ratero.png`, `cargador.png` | PNG RGBA de 256×256 en `assets/sprites/enemies/rendered/`; pose lateral derecha, pies en y=191, luz arriba/izquierda, sin sombra dibujada. |
| `ratero_walk.png`, `cargador_walk.png` | PNG RGBA de 1024×1024; 4×4 cuadros de 256, filas derecha/abajo/izquierda/arriba, cuatro fases propias por vista. |
| Fuentes | 32 SVG nativos de 64×64 en `art/t257-cuadrilla/sources/`; degradé de tres paradas, contorno oscuro y comentarios en español. |
| Reproducción | `draw.py`, `pack.gd`, `review.py`, `manifest.json` y `prompts.md` en `art/t257-cuadrilla/`. |
| Revisión | `captures/contact_sheet.png`: 220, 112 y 34 px, siluetas a 34 px de alto visible y comparación de tamaños relativos con el Ladrón; `walk_cycles.png` y `walk_preview.gif`. |

## Alcance

Solo arte, ficha, registro de resultado y paletas provisionales de la guía. **No se tocan datos ni código del juego.** La auditoría de recursos registra los cuatro PNG en `KNOWN_UNUSED` hasta que T253 los integre; no se cambia la lógica del test. No se crean `.tres`, no se integra la banda en campaña y no se cambian estadísticas, textos jugables o balance. Los scripts de reproducción viven en `art/` y no participan del juego.

Los dos `.tres` no existen en esta rama al producir la entrega. Rutas para T253: `res://assets/sprites/enemies/rendered/ratero.png` y `ratero_walk.png`; equivalentes para `cargador`. Parámetros visuales sugeridos, **no escritos en datos**: `walk_art_scale = 1.0`, `visual_scale = 1.2`, `flip_when_walking_left = false`, `walk_stride_tiles = 0.45` para Ratero y `0.9` para Cargador. Deben calibrarse en partida; no alteran la velocidad lógica de RF-485.

## Pasos

1. Revisar canon, requisitos y referencia aprobada del Ladrón.
2. Dibujar fuentes nativas con anatomía y fases propias; rasterizar y empaquetar.
3. Comprobar dimensiones, alfa, márgenes, 16 poses únicas, apoyo constante y coincidencia estática/fase inicial.
4. Preparar hojas y vista animada para Lucas, importar en Godot y correr la suite completa.
5. Registrar resultado honesto y commit único. Sin push ni publicación externa durante este despacho.

## Hecho cuando

**Entrega provisional:** dos poses y dos ciclos, fuentes y reproducción, hoja de contacto, validación registrada y commit. **Cierre artístico de T257:** además, aprobación explícita de Lucas, integración en T253 y captura de partida real en movimiento. Se mantiene abierta la casilla global hasta ese cierre.

## Verificación

`python3 art/t257-cuadrilla/draw.py`, `godot --headless --import`, `godot --headless -s art/t257-cuadrilla/pack.gd`, `python3 art/t257-cuadrilla/review.py`; después importación final y suite GUT completa. Los resultados se conservan en `art/t257-cuadrilla/validation/`.

## Frenar si

Integrar el arte exige código, cambiar datos o reinterpretar el canon. Eso corresponde a T253 o a una nueva aprobación de Lucas.

## Resultado · 2026-10-10

Se entregaron las dos estáticas y dos atlas provisionales, 32 fuentes vectoriales, manifiesto y herramientas de reproducción; hoja comparativa con el Ladrón aprobado y vista animada de las cuatro direcciones. Se inspeccionaron visualmente la hoja y todas las fases: las siluetas son diferentes, sin capucha ni símbolos; el nivel de detalle vectorial es más simple que el del Ladrón renderizado y **no se presenta como arte definitivo**.

La comprobación estructural verificó 32 cuadros distintos, alfa real, margen en los cuatro lados, límite inferior del alfa en y=191 y estática idéntica a la fase cero derecha. La primera ejecución, antes de importar el worktree, produjo errores de clases y recursos aún no importados; se repitió después de la importación. La primera suite completa dio **1523/1524**: el único fallo fue la auditoría de recursos sin uso, que encontró los cuatro PNG todavía sin `.tres`. Se anotaron explícitamente en `KNOWN_UNUSED`, sin modificar la lógica de auditoría; T253 debe retirar esas entradas al integrar el arte. La corrida final dio **1524/1524 tests**, **17367 assertions**, **112 scripts**, salida 0 y **0 `SCRIPT ERROR` / 0 `Parse Error`**. Importación final y empaquetado también sin esos errores. GUT conserva avisos de nodos huérfanos y el error esperado del nivel `no_existe`; no se ocultan en las salidas completas.

**Pendiente:** aprobación de Lucas, captura en una partida real y calibración de parámetros visuales en T253. No se probó balance, rendimiento, exportación, Windows ni Android; no se tocaron datos ni código del juego. La hoja usa colores de suelo/camino de pradera como muestra, no es una captura de juego; el GIF usa una cadencia común para revisar fases, no las velocidades finales de cada especie.

La validación conserva salidas completas en archivos `.txt` dentro de `art/t257-cuadrilla/validation/`; los `.log` de ejecución quedan locales. La importación mostró el aviso de ADB (`cannot connect to daemon at tcp:5037`), sin errores de script. No se modificó la configuración del sistema.

## Integración · T259 · 2026-10-10

El arte quedó **integrado en los datos** (`data/enemies/ratero.tres` y `cargador.tres`: `texture`, `walk_atlas`, `walk_art_scale = 1.0`, `visual_scale = 1.2`, `flip_when_walking_left = false`, `walk_stride_tiles` 0.45 y 0.9) y sigue siendo **provisional, pendiente de aprobación de Lucas**. Los cuatro PNG salieron de `KNOWN_UNUSED`. Suite completa: 1547/1547, sin `SCRIPT ERROR`. Falta la captura en partida real y calibrar los parámetros visuales.
