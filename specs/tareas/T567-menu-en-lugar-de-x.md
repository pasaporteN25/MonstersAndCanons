# T567 · «Menú» reemplaza a la X en el celular

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T566 (mismo archivo) · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-735, RF-511, RF-114, RF-460, RF-217, RF-142. `specs/04-decisiones.md`: D-225. `scenes/game/game.gd` (`_request_exit:738`, `open_pause_menu:637`, conexiones en 230-241), `scenes/ui/pause_menu.gd`, `scenes/ui/exit_dialog.gd`.

## Objetivo

Que el botón de salir del celular lleve al menú completo de la PC, con Opciones, y que salir quede dentro de ese menú.

## Alcance

**Sí:** `scenes/game/game.gd`, `scenes/ui/pause_menu.gd` si hace falta una señal, `scenes/game/mobile_hud.gd` (ícono y nombre del botón), textos en los dos idiomas, tests y `CHANGELOG.md`. Un ícono provisional si no hay uno adecuado en `assets/ui/`.

**No:** la PC, el texto de `ExitText`, ni el «Atrás» de Android (RF-142).

## Pasos

1. `mobile_hud.exit_pressed` pasa a abrir el menú de pausa. Renombrar la señal y el botón a `menu_*` si no complica los tests.
2. En el modo celular, «Salir» del menú de pausa pide la confirmación de RF-460. `_request_exit` hoy sale antes si `pause_menu.is_open()`: resolverlo sin romper ese guardián para los otros caminos. Si se cancela, volver al menú de pausa, no a la partida.
3. Al probar un mapa desde el editor (`testing`), «Salir» sigue yendo al editor sin confirmación.
4. Cuidar el estado al cerrar: la pausa previa, el `input_blocked`, `set_modal_open` y `_exit_was_paused`.
5. Tests: abre el menú de pausa y no el diálogo; Opciones se abre; «Salir» muestra la confirmación; cancelar vuelve al menú; confirmar llama al menú principal; caso editor; la PC sigue igual.
6. Revisar los tests de `test_mobile_*` y de salida que hablaban de la X. Actualizar RF o textos de `ONBOARDING.md` si la nombran.

## Hecho cuando

El botón abre el menú de pausa con Continuar, Reintentar, Opciones y Salir. «Salir» confirma con RF-460 y al cancelar vuelve al menú. El caso del editor y la PC no cambian. Los tutoriales no se traban. Hay tests.

## Verificación

Suite completa sin `SCRIPT ERROR`. Captura del celular simulado. **No se puede probar acá:** el «Atrás» físico de Android.

## Frenar si

Hay un flujo que pierde la partida sin confirmación o deja el juego pausado sin menú.
