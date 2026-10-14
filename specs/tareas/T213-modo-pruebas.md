# T213 · Modo de pruebas: recursos, colecciones y demolición instantánea

- **Ejecutor:** Sonnet 5.5 · esfuerzo **bajo**
- **Depende de:** T209 y T211 · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- §10.2 (modo de pruebas), RF-181 a RF-184, RF-360 (el admin habilita los estandartes sin colección) y RF-383 a RF-385.
- `scripts/autoload/dev_mode.gd`, `scenes/game/dev_panel.gd` y `tests/test_dev_mode.gd`.

## Objetivo
Que Lucas y el bot puedan probar los sistemas nuevos **sin jugar todo**. El panel de pruebas suma:
1. "+10 recursos".
2. "Terminar demolición" (completa el trabajo actual al instante).
3. "Habilitar todas las colecciones en esta partida", como RF-360: aplica al nivel actual **sin escribir** colección ni progreso normal.

## Reglas
Igual que el resto del modo de pruebas: guardado aparte, nada cuenta para el progreso real. Los RF **ya están escritos en T205: RF-436** (con RF-429 y RF-410). Esta tarea **solo programa**: no escribe `RF` ni `D`.

## Hecho cuando
- Los tests cubren las tres acciones y que **no** escriben en el guardado real.
- Todos los tests en verde. Resultado, commit y PR.
