# T242 · Intro: reproducir, omitir y volver a ver

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** · **Depende de:** T241 · **Tamaño:** chico

## Leer
El RF de la intro (T240), `specs/intro/guion.md`, `scenes/ui/main_menu.gd`, `scripts/autoload/game_flow.gd`, `save_manager.gd` (para guardar "intro vista") y `scenes/ui/wiki_screen.gd`.

## Pasos
1. Una escena de intro: las láminas con un fundido, el texto abajo con el estilo hierro y bronce, avance por toque o por tiempo, y "Omitir" siempre visible. La música de menú o la que diga el RF.
2. Se muestra la primera vez que se toca "Jugar" (con un dato nuevo en el guardado, aditivo). Se puede volver a ver desde donde diga el RF.
3. Tests: la primera vez se muestra, la segunda no, omitir funciona y un guardado viejo la muestra una vez. Sin cambiar de escena dentro del test (`.claude/rules/tests.md`): probar la lógica aparte.
4. Exportar otra vez (T237) y verificar que las láminas entran en el paquete y el tamaño final de la APK.

## Hecho cuando
La intro funciona en PC y en tamaño de celular, todos los tests en verde y las builds regeneradas. Resultado, `CHANGELOG.md`, commit y PR.
