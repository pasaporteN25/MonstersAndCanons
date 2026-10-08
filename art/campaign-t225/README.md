# T225 · Nivel 10: La mina vieja

Evidencia del nivel 10 (`data/levels/level_10.json`, spec §7.12, RF-453). Lo de acá **no es una partida humana**: son capturas controladas y corridas del bot de balance (T214). Balance humano: pendiente (G4, T226).

## Archivos

| Archivo | Qué es |
|---|---|
| `level_10.png` | Captura a 1920 × 1080 (`capture.tscn`): 8 torres en casillas legales, la mina habilitada, un Mortero comprado con sus recursos y seis enemigos congelados. Se hizo con el modo de pruebas (mucho oro) y **no** muestra una partida real. |
| `exposure.json` | Geometría del Embestidor (`exposure.tscn`): 5 rectas largas por entrada y 4 casillas a distancia de impacto, las 4 con otra casilla libre a 3 o menos para un apoyo. |

```bash
godot --path . --resolution 1920x1080 art/campaign-t225/capture.tscn    # necesita pantalla
godot --headless --path . art/campaign-t225/exposure.tscn
```

## El mapa

24 × 11, tema `desierto`, dos entradas (A: 68 casillas hasta la salida; B: 55). De las 264 casillas, **43 son libres** y el resto es `X` (cactus, rocas rojizas, huesos) o decoración (3 símbolos A, 4 columnas): un cañadón con la fila central de cada banda entre rectas, cuatro bloques libres de 2×2 para el Mortero y una casilla junto a cada esquina donde termina una recta larga (para el Embestidor). Los 7 removibles y la mina ocupan casillas del cañadón; ninguno toca el camino ni una casilla de impacto.

## Cómo se llegó a estos números (iteraciones descartadas)

1. **Mapa abierto (unas 170 casillas libres).** El bot `sin_recursos` llegaba a 100 torres y las estrategias de extracción no ganaban casi nada (1 vida o ninguna de diferencia): el oro sobraba y la mina solo ahorraba 30 de oro por Francotirador. Se descartó.
2. **Espacio limitado (36 y luego 43 casillas).** Ahí el bot llena el mapa hacia la oleada 13 y el oro sobra (más de 4000 al final): lo que vale es **capacidad por casilla**. Se agregaron 6 casillas junto a las esquinas del Embestidor (de 36 a 43), lo que volvió el mapa más fácil y obligó a subir el aumento de vida.
3. **Oleadas.** Se partió de las del nivel 9. Las oleadas de Voladores (4, 8, 12, 16) y los enjambres de Rápidos (16) decidían la partida de un solo golpe con tan pocas casillas; se achicaron. La oleada 9 (Guardián + Curandero + Arañas) también se aflojó porque castigaba a quien gastaba oro temprano en la mina.
4. **Aumento de vida** (`sin_recursos`, 5 semillas, vidas): 28 % → 14, 14, 14, 12, 14 · **30 % → 9, 9, 13, 7, 9 (el elegido)** · 33 % → 1, 0 (perdió), 1, 1, 0 (perdió): con 33 % la regla de oro **no** se cumple (3 de 5). El elegido deja 3 puntos de margen.

## Medición final (nivel 10, 5 semillas, `fixed-fps 60`)

Vidas al terminar. Las 25 partidas ganaron las 20 oleadas.

| Estrategia | Sem. 1 | Sem. 2 | Sem. 3 | Sem. 4 | Sem. 5 | Máquina | Recursos obtenidos / sobrantes | Oro en infraestructura | 1.ª torre con recursos |
|---|---|---|---|---|---|---|---|---|---|
| `sin_recursos` | 9 | 9 | 13 | 7 | 9 | — | 0 / 0 | 0 | — |
| `demoler` | 18 | 18 | 18 | 18 | 18 | — | 4/4 · 3/3 · 6/6 · 2/2 · 2/2 | 540 | — |
| `demoledora` | 18 | 18 | 18 | 18 | 18 | — (no habilitada) | igual que `demoler` | 540 | — |
| `extraer_temprano` | 17 | 17 | 17 | 17 | 17 | — | 8 / 0 | 100 | oleada 3 |
| `extraer_tarde` | 18 | 17 | 17 | 17 | 17 | — | 8 / 0 | 100 | oleada 10 |

- **Regla de oro (RF-432):** `sin_recursos` gana **5 de 5** (el resultado de `check_rule=1 levels=10` está en el Resultado de T225 de `specs/03-tareas.md`).
- **Las dos de extracción ganan con más vidas** que `sin_recursos` en las 5 semillas (17 o 18 contra 7 a 13).
- **`demoledora` es igual a `demoler`** porque el nivel no habilita la máquina (`"demoledora"` falso, como el 8 y el 9).
- **Los recursos de `demoler` sobran** (el bot demuele pero no construye con recursos).

## Lo que la medición NO dice (importante)

1. **Ninguna estrategia compra el Mortero.** Las estrategias de extracción de T214 compran la «primera torre con recursos que alcance», y el Francotirador (con su pago de 120 + 1) está antes en la barra y se paga con 1 solo recurso: los 8 recursos de la mina se gastan en **8 Francotiradores**, de la oleada 3 a la 7 (`temprano`) y de la 10 a la 14 (`tarde`). La «1.ª torre con recursos» de la tabla es un Francotirador.
2. **La ventaja no viene de los recursos.** Control (copia de prueba del bot, **no incluida en el repositorio**): comprar los mismos 8 Francotiradores **con oro** (150), desde la oleada 3, sin mina ni recursos, también termina con **17 vidas en las 5 semillas**. La mina ahorra 30 de oro por Francotirador y cuesta 100, y en este mapa el oro no escasea: lo que ayuda es **priorizar Francotiradores** (largo alcance y mucho daño por casilla) en vez del orden de compra de `mix`.
3. **El Mortero, con una variante de prueba del bot, no ayudó.** Con una copia que prioriza el Mortero (y junta los 300 de oro): `extraer_temprano` compra 2 Morteros (oleadas 3 y 5) y **pierde en la oleada 20** (0 vidas, 5 de 5); `extraer_tarde` ya no encuentra un bloque libre de 2×2 (los llenó con torres de 1×1) y gana como `sin_recursos` (7 a 11). Un Mortero ocupa 4 de las 43 casillas y cuesta 300 de oro y 3 recursos.
4. Es el **bot**, que no mejora torres, no vende, no elige el momento ni apunta como una persona. Que la extracción «valga la pena» según la regla de la ficha **no demuestra** que la mina le sirva a una persona para construir el Mortero.
