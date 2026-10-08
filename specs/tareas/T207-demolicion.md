# T207 · Demolición directa en la partida

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T206 · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- **RF-404 a RF-410** (demolición directa), **RF-417** (el drop con semilla), D-081 y D-083, y la sección M50 del plan técnico (API de `ObstacleField`, flujo y archivos de T207).
- `scenes/game/build_controller.gd`: cómo se selecciona una casilla o torre (`_handle_selection_input`, `select_placed`) y cómo se cobra (`try_build`).
- `scenes/game/level_session.gd`: `spend`, `earn`, la señal `gold_changed` y `complete_wave`.
- `scenes/game/hud.gd` y `scenes/ui/tower_panel.gd`: el panel de torre es la referencia de estilo del panel nuevo.
- `scenes/game/game.gd`: cómo se arman la partida, la pausa y la velocidad.
- `.claude/rules/gdscript.md` y `.claude/rules/tests.md`.

## Objetivo
Tocar o hacer clic en un removible abre un **panel** con el costo, el tiempo y la recompensa, y el botón **Demoler**. Al confirmar se cobra, empieza un **trabajo con reloj de juego** y, al terminar, la casilla queda **despejada y construible** y se entrega la recompensa. Hay una sola demolición a la vez y se puede cancelar con reembolso, según los RF.

## Pasos
1. **Lógica pura primero** (testeable sin escenas): `DemolitionJob` y `ObstacleField`, con la API y las señales del plan M50 (`can_order`, `cost_of`, `seconds_of`, `order`, `tick`, `cancel`, `discard_job`, `reward_of`; `job_started`, `job_progress`, `job_finished(cell, reward)`, `job_cancelled`). `setup` **sortea el drop de cada removible al empezar** con la semilla (RF-417), en orden de fila y columna.
2. Conectarla a `LevelSession` con `InfrastructureController`: cobro al ordenar y reembolso al cancelar. `reward_of` ya devuelve los `resources` sorteados, pero **sumarlos a la sesión** es de T209 (por ahora el controlador solo los muestra en el aviso flotante). El hallazgo (`finding`) lo conecta T211.
3. La selección en `build_controller.gd`:
   - un clic sobre un removible lo selecciona, con la misma lógica que una torre;
   - Escape o un clic fuera lo deselecciona;
   - en el modo construcción, el clic sobre un removible **no construye**.
   - En el celular, tocar alcanza: no agregar gestos (§11).
4. El panel "Demoler" en el HUD, con el estilo hierro y bronce del panel de torre. Si no alcanza el oro, el botón queda deshabilitado con el motivo. Si hay un trabajo en curso, dice "Hay una demolición en curso".
5. La vista provisional del trabajo: una barra de progreso sobre la casilla y el dibujo que se desvanece al terminar. Pausa y velocidad respetadas: probar con `Engine.time_scale` o con el reloj de la partida, igual que el Ladrón (RF-363).
6. Al terminar, `map_grid` despeja la celda (T206), se puede construir ahí y el panel se cierra. Al terminar la partida, el trabajo se descarta.
7. **Recompensa una sola vez:** un removible despejado no vuelve dentro de la partida. Reintentar o reiniciar el nivel lo restaura.
8. Tests:
   - cobrar, sin oro, cancelar con reembolso total;
   - una sola a la vez;
   - pausa (el reloj no avanza) y velocidad ×2;
   - terminar despeja y permite construir;
   - el fin de la partida descarta el trabajo;
   - la recompensa no se duplica;
   - la oleada termina y el trabajo sigue.
9. Sonido: reusar uno existente (`build.wav` o `sell.wav`). No crear sonidos.

## Hecho cuando
- En `tools/ejemplos/mapa_removibles.json` se demuele, se cancela y se construye en la casilla despejada. Dejar una captura en `art/m50/demolicion.png`.
- Todos los tests en verde, sin `SCRIPT ERROR`. Los niveles sin removibles no cambian: el bot da lo mismo en el 6 y en el 9.
- Resultado, `CHANGELOG.md`, commit y PR.

## Frenar si
- La selección de removibles entra en conflicto con la selección de torres o con el modo construcción, de una forma que el RF no resuelve.
