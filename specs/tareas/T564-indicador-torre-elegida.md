# T564 · Indicador de la torre elegida en el celular

- Ejecutor · Haiku · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Chico

## Leer

`specs/01-spec.md`: RF-737, RF-678, RF-295. `specs/04-decisiones.md`: D-226. `.claude/rules/gdscript.md` y `.claude/rules/tests.md`.

## Objetivo

Que al tocar una torre se vea cuál es la que muestra la barra de abajo.

## Alcance

**Sí:** `scenes/towers/tower.gd` (dibujar la marca), `scenes/game/game.gd` (`_refresh_tower_panel`, avisarle a la torre), `data/ui/mobile_ui.json` y `scripts/data/mobile_ui_config.gd` (color, grosor, largo de esquina y velocidad del pulso), un test nuevo y `CHANGELOG.md`.

**No:** la PC (RF-737 es solo para el celular), el círculo de alcance (RF-678) ni el dibujo de la vista previa (RF-680).

## Pasos

1. Agregar a `Tower` un método `set_selected_marker(enabled: bool)`. Con la marca prendida, `_process` hace `queue_redraw` para el pulso; apagada, no gasta nada.
2. En `_draw`, dibujar cuatro esquinas amarillas sobre el cuadrado de la torre. Usar `Rules.TILE_SIZE * data.footprint` para que el Mortero marque sus cuatro casillas.
3. En `Game`, guardar la última torre marcada. En `_refresh_tower_panel`, con `mobile_hud != null`, apagar la anterior y prender la nueva. Cuidar que la anterior siga válida: pudo venderse.
4. Tests: una sola torre marcada entre dos iguales; cambia al elegir otra; se apaga al soltar y al vender; el Mortero usa su tamaño; sin marca en modo PC.
5. Capturas del celular simulado con una torre común, el Mortero y un zoom acercado, si T568 ya está.

## Hecho cuando

Solo la torre elegida lleva la marca, también en el Mortero, y se va al soltarla o venderla. Los números están en datos. No cambia ni el daño ni la selección. Hay tests y capturas.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** si se distingue bien en un teléfono real a pleno sol.

## Frenar si

Prender la marca obliga a cambiar `BuildController` más allá de leer `selected_placed()`.
