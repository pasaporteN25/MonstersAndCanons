# T210 · Extracción finita: minas y bosques explotables

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T209 · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- Los RF de M50 de **extracción**, su D, y Q-19 y Q-20.
- El código de T206 (los obstáculos con `extraccion`), de T207 (el panel y la selección) y de T209 (los recursos). `LevelSession.complete_wave` y la señal `wave_completed`.

## Objetivo
Un punto de extracción (mina o bosque explotable) se **selecciona** igual que un removible. Su panel muestra el costo para habilitarlo, la producción por oleada y la reserva restante. Una vez habilitado, **al completar cada oleada** entrega su producción hasta agotar la reserva y después se ve **agotado**. No produce por esperar.

## Pasos
1. Lógica pura: `ExtractionSite` (o lo que fije el plan) con `enable()`, `on_wave_completed()`, que devuelve lo producido, y `reserve_left`. Tests: no produce sin habilitar, produce al completar, no supera la reserva, el agotado no produce y el reinicio restaura.
2. Conectarlo a `LevelSession.wave_completed` y a los recursos de T209. Un aviso flotante "+2 ⛭" sobre el punto (reusar `floating_text.gd`).
3. Panel: "Habilitar extracción (100 de oro)", "Produce 2 por oleada · Reserva 6/8" y "Agotada".
4. Vista provisional de los tres estados (sin habilitar, activa y agotada) y la reserva legible: por ejemplo, una barra de pequeños segmentos. El arte final es T220.
5. Si habilitar un punto **no se recupera** con la reserva entera (costo en oro contra el valor de los recursos), anotarlo en el Resultado para el balance (T214). No cambiar los números.
6. Tests de integración con oleadas simuladas, como en los tests de `LevelSession`.

## Hecho cuando
- Ejemplo jugable: una mina habilitada en la oleada 1 entrega 2, 2, 2 y 2 y queda agotada.
- Todos los tests en verde. Resultado, `CHANGELOG.md`, commit y PR.
