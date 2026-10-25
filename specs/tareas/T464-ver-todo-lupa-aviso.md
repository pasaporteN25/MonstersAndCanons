# T464 · «Ver todo»: solo la tecla en PC, lupa en el celular y aviso de una vez

- Ejecutor · Sonnet (código) + Codex (dibujo de la lupa, ya hecho como muestra) · esfuerzo medio.
- Depende de · OK de Lucas a T458 (registrado: ONBOARDING «La spec M75 (T458) está aprobada») · 🎨 **aprobación de Lucas de la captura de la lupa antes de integrarla (pendiente)**.
- Compuerta · 🎨 lupa · Tamaño · Mediano.

> Ficha escrita el 2026-10-25 en el cierre honesto de M75 (`specs/tareas/informes/M75-cierre-honesto.md`), **después** de que el código se integrara en `main` (PR #70). Refleja lo que ya está hecho y lo que falta; no es una ficha para empezar de cero.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`, `.claude/rules/arte.md`.
- `specs/01-spec.md` § M75: RF-674, RF-675, RF-676, RF-685.
- `specs/04-decisiones.md`: D-192 y D-207.
- `specs/tareas/T458-ficha-camara-panel-opciones.md` §2 (el plan original) y `specs/tareas/T480-aclarar-aviso-zoom.md`.

## Objetivo

En la PC «Ver todo» queda solo como tecla (`view_all`, la V por omisión). En el celular es un botón flotante con una **lupa** que aparece solo con zoom. Un aviso de una línea, una sola vez por guardado, explica cómo volver, y solo sale al **acercar** (D-207).

## Alcance

**Sí:** `scenes/game/camera_controller.gd` (señal `view_zoomed_in` solo con zoom creciente, sin botón de PC), `scenes/game/game.gd` (`_on_view_zoomed_in`: exclusiones y textos), `scenes/game/hud.gd` (`show_view_all_notice`), `scenes/game/mobile_hud.gd` (`_build_view_all_button`), `scripts/logic/ui_prefs.gd` (`view_all_hint_seen` aditivo), integrar la lupa aprobada en `assets/ui/`.

**No:** cambiar la tecla configurable (RF-614/RF-615), `SAVE_VERSION`, los textos aprobados ni la duración del aviso.

## Estado al 2026-10-25 (verificado contra `main` e121f0c)

Hecho y comprobado:
- PC sin botón: `tests/test_view_all_displaced.gd` (`test_pc_has_no_button_after_pan_or_zoom`, `test_pc_has_no_button_tooltip`) y `tests/test_view_all_hint.gd` (`test_pc_has_no_onscreen_view_all_control`).
- La tecla funciona en marcha y en pausa y no con el menú de pausa: `test_pc_view_all_key_goes_back_to_the_fit_even_while_paused`, `test_pc_view_all_key_does_nothing_with_the_pause_menu_open`.
- Celular: el botón aparece solo al acercar, no al desplazar: `test_panning_at_minimum_zoom_keeps_button_hidden_until_zoom_and_then_returns_to_fit`.
- Aviso: textos aprobados, una vez, no al alejar ni al desplazar: los siete tests de `test_view_all_hint.gd`.
- `view_all_hint_seen` ausente o inválido → «no visto»: `test_view_all_binding.gd` (`test_invalid_hint_marker_falls_back_to_unseen`) y `test_old_saves.gd`; `SAVE_VERSION` igual.

Falta:
1. **🎨 OK de Lucas a la lupa** (`art/t464-muestra-lupa/lupa.svg`, visor `index.html`) y su integración en `mobile_hud.gd:443` (hoy dice «Ver todo», como pide la ficha mientras no haya aprobación).
2. **Hallazgo:** con el texto «Ver todo» el botón mide 99 × 64 px y, en `ver_todo_x_px = 1188` (`data/ui/mobile_ui.json:27`), termina en x = 1287: **sale 7 px de la pantalla de 1280** (captura `Capturas/M75-T464-celular-simulado-ver-todo.png`). Con la lupa cuadrada de 64 px entra (1188 + 64 = 1252). Si la lupa se demora, ajustar la posición o el ancho.
3. Tests que pide el plan y no existen: que el aviso **no** salga con el tutorial del nivel 1 activo (el código lo excluye en `game.gd:617`, pero ningún test lo prueba) y que **desplazar y después acercar** sí lo muestre.
4. Test de que el botón no pisa carrito/X/demolición: hoy solo se comprobó con las posiciones por omisión en la herramienta `tools/capture_m75_cierre.gd` (no se pisan); los otros botones se pueden arrastrar.

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) En la PC no hay botón y la tecla de `view_all` sigue funcionando en marcha y en pausa; en el celular el botón lleva la lupa aprobada, aparece solo al hacer zoom y no tapa carrito/X/demolición; el aviso usa los textos aprobados, aparece una sola vez por guardado solo al aumentar el zoom y no aparece con el tutorial; `ui_prefs.view_all_hint_seen` ausente o inválido se lee como «no visto»; `SAVE_VERSION` igual; tests actualizados y `test_view_all_hint.gd` nuevo; suite completa sin `SCRIPT ERROR`; capturas de las dos interfaces.

## Verificación

`godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` sin `SCRIPT ERROR`. Captura del celular simulado con la lupa: `DISPLAY=:0 godot --path . -s res://tools/capture_m75_cierre.gd -- /ruta/fuera/del/repo 1280x720` (la línea «T464 celular · … dentro de 1280×720» tiene que decir `true`). **No se puede probar acá:** un teléfono real (tamaño táctil de la lupa, pinza) ni Windows.

## Frenar si

Lucas pide otro dibujo de lupa (volver a la muestra, no integrar) o la lupa necesita más de 64 px.
