# T224 · Niveles 8 y 9: ruinas, piezas 1 y 2 de la Disruptora y rebalance

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T211 (colecciones) y T223 (mismo método) · **Compuerta:** G4 (T226) · **Tamaño:** mediano

## Leer
- Las fichas 8 y 9 del plan 08 §5, los RF de M50 (colecciones), y Q-25 a Q-27.
- RF-378 a RF-380 (M45: cómo se armaron el 8 y el 9 y qué hay que conservar).
- `data/levels/level_08.json` y `level_09.json`, y `art/campaign-m45/README.md`.
- El Resultado de T223, para usar el mismo método.

## Objetivo
- **Nivel 8 (Bastión, "El bastión sobre ruinas")**: tema `ruinas`, removibles comunes (sin recursos) y **un escombro con la pieza `disruptor` 1/3**. Señal de **revelación**: el símbolo A en las ruinas (T218).
- **Nivel 9 (Taller asediado, "El taller")**: tema `ruinas` y un escombro con la **pieza 2/3**.
- Las oleadas y los debuts (Guardián en el 8, Curandero en el 9) **se conservan**.
- **Regla:** la pieza tiene que ser **alcanzable sin perder**. La ruina se puede demoler con el oro de las primeras oleadas en la estrategia `demoler` del bot, y el panel dice "Pieza de la Disruptora: pendiente".

## Pasos
1. Igual que T223: ubicar los removibles, medir 5 semillas por estrategia, cumplir la regla de oro y conservar RF-379.
2. Registrar en `data/progression.json` las fuentes de la colección `disruptor` del 8 y del 9 (con el formato de T211). La del 10 la agrega T225.
3. Verificar en una partida con el bot o en un test de integración que la pieza se recoge, se confirma y se guarda en la campaña, y que **no** se genera en el modo Asedio.
4. Capturas y tabla del bot.

## Hecho cuando
Lo de arriba, con todos los tests en verde. Resultado, `CHANGELOG.md`, commit y PR.
