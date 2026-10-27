# T244 · 🎨 Arte del jefe supremo: el Coloso y su Pedazo

- **Ejecutor:** **Codex**
- **Depende de:** T243 (**hecha, 2026-10-09**: Lucas eligió el concepto C, «El Coloso»; RF-481 a RF-484, D-092, plan «M54 / T243») · **Compuerta:** 🎨 concepto aprobado por Lucas · **Tamaño:** mediano (son **dos** criaturas con ciclo de caminata)

## Qué hay que dibujar (lo que dice T243)
El jefe supremo del nivel 15 son **dos enemigos** que van juntos en la misma historia:

- **El Coloso** (`colossus`): un **gólem de piedra colosal**, del tamaño de dos Guardianes. **Es una masa lenta, ancha y pesada que avanza**: no tiene gesto, no mira, no tiene intención. Tiene que **leerse como «la amenaza más grande del juego»** sin ser un villano (10 §8).
- **El Pedazo** (`colossus_shard`): cada una de las **tres lascas de la misma piedra** en las que se parte cuando cae. **Chico, anguloso, rápido**, reconocible como parte del Coloso, pero que a 34 px se lea como **otra cosa más chica y más ágil**.

## Reglas de aspecto (de RF-484 y de 10 §4.5)
1. **Pertenencia ambigua:** el Coloso **no lleva el símbolo de los Moradores ni ninguna marca de las comunidades**, y no lleva escudo dorado. La única pista es que su piedra se parece a la de los Guardianes. (Si Lucas quiere que la lleve, lo dice en el concepto; no se agrega por cuenta propia.)
2. **Se distingue del Guardián por la silueta y por el color a 34 px.** El Guardián es **marfil** (`#f2e8cf` / `#c8b78c` / `#7b6a4a`); el Coloso va en una **piedra más oscura, tipo basalto, con vetas ámbar apagadas**. Los tonos de la guía (§3) **no se repiten**: el color del Coloso y el del Pedazo son **nuevos** y se suman a esa tabla cuando Lucas aprueba.
3. **Se distingue del Soberano** (`boss`, carmesí y cornudo): el Coloso es **piedra**, no una bestia. Sin colmillos, sin garras, sin ojos de criatura: es un objeto que camina. (Esto cambia la regla «bestias con carácter» de la guía §1 y se anota ahí como excepción **de este enemigo**, no de los demás.)
4. **Una sola corona:** el Coloso lleva la corona de peligro (RF-136) porque quita 12 vidas; el Pedazo (4 vidas) no. La corona la dibuja el juego, no el sprite.
5. **El Pedazo se lee como parte del Coloso** (misma piedra y mismas vetas) y como **algo que corre**: más bajo, más agudo y con un apoyo que sugiera velocidad, sin ojos ni cara.
6. **Tono:** nada de villano caricaturesco (10 §8); un cuerpo que se parte **no tiene mensaje**.

## Entregables
| Pieza | Uso | Formato |
|---|---|---|
| **Concepto** | Boceto de 2 o 3 poses del Coloso y del Pedazo, con paleta, para el **OK de Lucas**. | Imagen simple, sin integrar. |
| **`colossus.png`** y **`colossus_shard.png`** | La pose estática: la tarjeta de presentación (RF-134), el ícono, la Wiki y el respaldo si no hay atlas. | PNG RGBA **256 × 256**, **una sola vista** mirando a la derecha, luz arriba a la izquierda, **sin sombra dibujada**, pies en y = 191, en `assets/sprites/enemies/rendered/`. |
| **`colossus_walk.png`** y **`colossus_shard_walk.png`** | El ciclo de caminata (M31). | **Atlas de 1024 × 1024: 4 poses por fila, 4 filas** —derecha, abajo, izquierda, arriba—, **cuadros de 256**; **16 poses propias** (distintas entre sí), apoyo constante en **y = 191**, y margen transparente en los cuatro lados de cada cuadro. |
| **SVG de respaldo** (opcional) | Como los demás enemigos de `assets/sprites/enemies/`. | 64 × 64, guía §2. |
| **Parámetros visuales de los `.tres`** | `walk_stride_tiles` (distancia de un ciclo completo: el Coloso es lento y pesado, un paso largo), `walk_art_scale` (calibra el enmarcado del atlas contra la pose estática), `flip_when_walking_left = false` (los PNG tienen luz propia) y `visual_scale`. | Se **anotan** para T234 o se escriben en los `.tres` solo si T234 ya los creó. |
| **Hoja de contacto y captura** | Coloso y Pedazo con el Guardián, el Soberano y el Tanque, a **220 px, 112 px (Wiki) y 34 px**, sobre el suelo `pradera` del 15; y una captura en partida, en movimiento. | Imágenes. |

**Lo que T243 deja abierto para vos (lo ajustás mirando el arte):**
- **`visual_scale` del Coloso** (hoy 1.6 en el plan, sobre `size_tiles = 0.5` que es el tope del test): lo que haga falta para que se lea «del tamaño de dos Guardianes» sin tapar las casillas vecinas ni la barra de vida. El **radio lógico no se toca** (RF-339). El Pedazo queda en 1.2, como los demás.
- **Los dos colores nuevos** de la tabla de la guía (§3).
- **Cuánto cambia de forma el Coloso entre «entero» y «partido»:** no hay sprite intermedio ni animación de partirse; al morir el Coloso se hace el efecto de muerte de siempre y aparecen los tres Pedazos. **No se pide** una pose de ruptura (sería un sistema de animación nuevo).

## Leer
`specs/tareas/README.md` §6, la guía de arte completa (`specs/05-guia-de-arte.md`, §3, §7, §8 y M31) y `.claude/rules/arte.md`; **RF-481 a RF-484 y D-092** (T243) y el plan «M54 / T243» (formato y tests); `specs/10-universo.md` §4.4 y §4.5; los sprites y atlas del Guardián, el Soberano y el Tanque (`assets/sprites/enemies/rendered/`); `tests/test_enemy_visual.gd` (qué exigen los ciclos).

## Pasos
1. **Concepto** (Coloso y Pedazo, poses y paleta, con la silueta a 34 px junto al Guardián y el Soberano) → **OK de Lucas**.
2. Producción de los dos PNG y los dos atlas. Fuentes originales, `prompts.md`, `manifest.json` y el empaquetador en `art/t244-coloso/` (README §6).
3. **Tests:** sumar `colossus` y `colossus_shard` a las listas de `tests/test_enemy_visual.gd` que correspondan (regiones del ciclo, ciclos completos y únicos, ralentización de los pasos); **la lista de `visual_scale == 1.2` no vale para el Coloso** y esa excepción se escribe en el test. Correr todo (incluidos los de sprites) y mirar la salida completa: un `SCRIPT ERROR` es un fallo.
4. **Integración de rutas:** si T234 ya creó `colossus.tres` y `colossus_shard.tres`, se completan `texture`, `walk_atlas`, `walk_stride_tiles` y `walk_art_scale`; si no, se **anotan** para T234. **No se crean los `.tres`, no se tocan números ni la lógica.**
5. Guía de arte: sumar los dos colores a la tabla de §3 y la excepción de «piedra, no bestia».
6. Commit `T244: …`. Hasta que esté aprobado, **T234 usa un arte provisional hecho en código** (Q-40).

## Hecho cuando
Concepto aprobado y registrado, los dos PNG y los dos atlas integrados (o con las rutas y parámetros anotados para T234), hoja de contacto y captura en partida, la guía de arte con los dos colores nuevos, tests de sprites en verde, y el Resultado dice honestamente qué se miró en pantalla y qué no.

## Frenar si
Para que el Pedazo o el Coloso se vean bien hace falta **código** (una pose de ruptura, una animación nueva, otro tamaño de sprite). Eso se anota para T234 y no se resuelve acá.
