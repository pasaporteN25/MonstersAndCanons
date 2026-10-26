# T467 · La ampliación del alcance: hover en PC, dos toques en el celular y animación cosmética

- Ejecutor · Sonnet · esfuerzo medio-alto.
- Depende de · T465 y T466 (código en `main`; T465 sigue abierta por un detalle del panel que no toca la ampliación) · OK de Lucas a T458 (registrado) · Compuerta · ninguna de arte · Tamaño · Mediano.

> Ficha escrita el 2026-10-25 en el cierre honesto de M75 (`specs/tareas/informes/M75-cierre-honesto.md`), **después** de que el código se integrara en `main` (PR #72). Refleja lo hecho.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`.
- `specs/01-spec.md` § M75: RF-680, RF-681, RF-682.
- `specs/04-decisiones.md`: D-195.
- `specs/tareas/T458-ficha-camara-panel-opciones.md` §5.

## Objetivo

Que el alcance reaparezca al mejorar: en la PC con el mouse sobre «Mejorar», en el celular con un primer toque que no cobra (el segundo confirma) y durante el efecto de mejora. Todo es presentación: la mejora sigue siendo instantánea.

## Alcance

**Sí:** `scenes/effects/range_preview.gd` (nuevo), `scenes/effects/effects_layer.gd`, `scenes/ui/tower_panel.gd` (señal `upgrade_hover_changed`), `scenes/game/mobile_hud.gd` (armado), `scenes/game/game.gd` (`_sync_range_preview`), `data/tutorial/tutorial.json` (paso «upgrade» del celular).

**No:** oro, nivel, costo, balance, guardado, `SAVE_VERSION`.

## Estado al 2026-10-25 (verificado contra `main` e121f0c)

Todo comprobado:
- **Hover en PC, cableado completo:** `tower_panel.gd:51-52` (`mouse_entered`/`mouse_exited` del botón) → `upgrade_hover_changed` → `game.gd:205` → `_sync_range_preview` (`game.gd:1203`). Tests: los ocho `test_pc_*` de `tests/test_range_preview.gd`. En los tests la señal se emite a mano, así que en el cierre se probó también **con un movimiento de mouse que entra por el viewport** (`push_input`) en una ventana real, a 1920 × 1080 y a 1280 × 720: con el mouse sobre «Mejorar» aparece la ampliación (y la ayuda «Mejorar torre · U»), al sacarlo se va, y la torre sigue en el nivel 2. Captura `Capturas/M75-T467-pc-hover-real-1920x1080.png`.
- **Dos toques en el celular:** primer toque sin cobrar y con el costo visible, segundo mejora una vez, sin oro o en el máximo no arma, y un test por cada evento de RF-681 punto 3 (mapa, soltar, otra torre, otro estado de la barra, Vender, prioridad, pausa, falta de oro): los `test_mobile_*` de `test_range_preview.gd`.
- Bloqueo de 0,35 s: `test_mobile_double_tap_after_confirming_raises_only_one_level`.
- Mejora instantánea: `test_mobile_second_tap_upgrades_once_instantly`, `test_pc_click_upgrades_instantly_and_the_hover_moves_on_to_the_next_level`.
- «Animaciones de mejora» apagada: `test_with_upgrade_animations_off_the_hover_circle_is_still_and_the_effect_draws_none`, `test_mobile_keeps_the_two_taps_with_upgrade_animations_off`.
- Pausa y velocidad: `test_the_preview_waits_while_the_game_is_paused_and_resumes_after`, `test_the_preview_follows_the_game_speed`.
- Tutorial del nivel 1: `test_the_phone_tutorial_upgrade_step_explains_the_two_taps_and_the_pc_one_is_unchanged` y el recorrido completo en PC y celular de `tests/test_tutorial_game.gd` (24/24), que pasa por el paso «upgrade» sin trabarse.
- Sin `_process`: `test_the_preview_does_not_use_process`.
- Capturas PC y celular simulado: `Capturas/t467-pc-hover-mejorar.png`, `Capturas/t467-celular-simulado-primer-toque.png` y las nuevas `Capturas/M75-T467-pc-hover-real-*.png`.

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) En la PC el mouse sobre «Mejorar» activo muestra la ampliación y al salir desaparece; en el celular el primer toque no cobra y la muestra, el segundo mejora, y los eventos de RF-681 punto 3 la cancelan (un test por evento); el bloqueo de 0,35 s se conserva; la mejora es instantánea; con «Animaciones de mejora» apagada la ampliación sale quieta y el efecto no la dibuja; respeta pausa y velocidad; el tutorial del nivel 1 no se traba; `test_range_preview.gd` nuevo; sin `_process`. Capturas en PC y celular simulado; **no se prueba en un celular real y se dice**.

## Verificación

GUT completo sin `SCRIPT ERROR`. Hover real: `DISPLAY=:0 godot --path . -s res://tools/capture_m75_cierre.gd -- /ruta/fuera/del/repo 1280x720` (líneas `T467 hover real · …`). **No se puede probar acá:** dedo real en un teléfono, Windows ni rendimiento.
