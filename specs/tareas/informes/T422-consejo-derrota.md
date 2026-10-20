# T422 · Medición del consejo de derrota (M70)

2026-10-20. Base: `origin/main` `52855f0`; implementación T420/T421. Godot 4.7.2.

**Resultado: se midió el comportamiento; la utilidad del consejo no quedó demostrada.** No se cambió el balance ni se ajustaron criterios a este ensayo.

## Método

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos levels=1-15 seeds=1 limite=1 consejo=probar report=/ruta/balance-report.json
```

Se usaron directorios `XDG_DATA_HOME` y `XDG_CONFIG_HOME` propios para aislar los guardados. Se jugaron 137 partidas: 15 bases y 122 alternativas. Todas terminaron en derrota. Cada base ofrecía el catálogo real del nivel y tenía un máximo de una torre, sin mejoras ni infraestructura. Tras cada base, el bot repitió el mapa y la semilla con cada torre sin costo de recursos, por separado. La clasificación usa oleada alcanzada y, a igual oleada, puntos.

El consejo puede incluir hasta dos torres. Se cuenta coincidencia si incluye alguna de las mejores torres solas. La partida «consejo» compra la primera sugerida porque el tope es una torre. No se midió sumar una torre aconsejada a una defensa existente.

## Resultados

| Nivel | Oleada base | Regla / torres aconsejadas | Mejor torre sola | Coincide | Mejora base al comprar la primera aconsejada |
|---|---:|---|---|---|---|
| 1 | 3/10 | rapido: frost, multi | sniper | No | No |
| 2 | 3/15 | rapido: frost, multi | sniper | No | No |
| 3 | 3/20 | Sin consejo | sniper | — | — |
| 4 | 2/15 | rapido: frost, multi | sniper | No | No |
| 5 | 3/20 | Sin consejo | tesla | — | — |
| 6 | 3/15 | regenera_fuego: fire | sniper | No | Sí |
| 7 | 1/20 | Sin consejo | sniper | — | — |
| 8 | 2/18 | rapido: frost, multi | tesla | No | No |
| 9 | 1/20 | Sin consejo | sniper | — | — |
| 10 | 1/20 | Sin consejo | sniper | — | — |
| 11 | 2/22 | rapido: frost, multi | sniper | No | No |
| 12 | 2/24 | rapido: frost, multi | sniper | No | No |
| 13 | 2/24 | Sin consejo | sniper | — | — |
| 14 | 1/26 | Sin consejo | sniper | — | — |
| 15 | 1/30 | Sin consejo | sniper | — | — |

- Hubo consejo en **7/15** derrotas; en **8/15** no hubo una causa con regla y peso suficiente. Predominaron fugas de Normales, sin regla propia.
- Coincidencia con alguna mejor torre sola: **0/7 (0 %)**. Referencia combinatoria impresa por la herramienta: **24 %** por azar.
- Comprar la primera aconsejada rindió más que la base: **1/7 (14 %)**, por puntos a igual oleada en el nivel 6. No demuestra avance de oleadas.

## Interpretación y límites

Este ensayo **no valida un consejo óptimo**. Hielo ralentiza y puede complementar torres de daño; comprarla como única torre es una prueba distinta de agregarla a una defensa. No se puede atribuir al consejo una mejora de la partida ni concluir que gana una estrategia. Solo hubo una semilla y un tope artificial, con derrotas tempranas: no representa las oleadas finales ni un playtest humano. No se hicieron partidas humanas ni pruebas en un celular real. El PR queda en borrador para revisión de Lucas.

Los textos siguen en borrador. Después de medir se acortó el texto de voladores a «Contra voladores, probá con {torres}.», porque otras torres también pueden golpear el aire: no corresponde afirmar exclusividad. No se cambió selección, daño ni criterios.

## Verificaciones

- Importación y suite GUT con guardados aislados: **2110/2110**, sin `SCRIPT ERROR` ni `Parse Error`; validador oficial: **15 reglas / 8 criterios OK**.
- Pantalla medida por tests: **420 × 604 px** con consejo largo y cinco récords; textos en hasta dos líneas.
- Bot: sin errores de script; al salir imprimió avisos de nueve instancias ObjectDB y cuatro recursos aún en uso. Se registran como límite de limpieza de la herramienta, no como prueba de eficacia.
- La suite y el validador se corrieron antes del último acortamiento de la frase de voladores; se conservó `{torres}` y la frase es más corta. No se repitieron durante la ventana de rendimiento.
