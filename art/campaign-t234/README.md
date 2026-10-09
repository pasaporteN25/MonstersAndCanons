# T234 · Nivel 15 (La Central), el Coloso y el epílogo: evidencia

Todo lo que sigue se midió el **2026-10-09** con la rama `feature/t234-nivel-15` (Godot 4.7.2, GTX 1660 SUPER, Linux). Las capturas son de la ventana del escritorio (1777 × 999; el contenido escala igual por `canvas_items`), no de 1280 × 720 exactos.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `play.gd` / `play.tscn` | Partida de verificación del 15 con la escena **real**: cartel de entrada, compras con clics reales, oleadas con el botón «Empezar oleada», y el final (Salón de la fama, victoria, epílogo, créditos, `Esc`). Opción `skip=N`: ver abajo. |
| `select.gd` / `select.tscn` | La selección de nivel con 15 tarjetas: el 15 bloqueado, abierto al ganar el 14, y un clic real sobre su tarjeta que abre la partida con el cartel. |
| `level_15_cartel.png`, `cartel_desde_seleccion.png` | El cartel de entrada (con el texto aprobado). |
| `level_15_inicio.png`, `level_15_apertura.png` | El mapa: la central de cuatro cuartos junto a la salida (derecha, abajo), la cadena de abastecimiento por el borde (depósito, poste, vagoneta), campamentos vacíos, rocas marcadas, mina y bosques; y la apertura con las primeras torres. |
| `level_15_tarjeta_coloso.png`, `level_15_tarjeta_pedazo.png` | Las tarjetas de «Nuevo enemigo» (RF-134) con la frase de RF-484. La del Coloso sale con el aviso «¡Llega el Coloso!» de la barra de próxima oleada. |
| `level_15_coloso_herido_26/28/30.png`, `level_15_pedazos_26/28/30.png` | El Coloso en el camino con su corona de «Peligroso» y los Pedazos después de partirse (oleadas 26, 28 y 30). |
| `level_15_oleada_30_fin.png` | El final de la oleada 30. |
| `level_15_salon_de_la_fama.png`, `level_15_victoria_iniciales.png` | Lo que se ve **antes** de la victoria (ver «Hallazgo»). |
| `level_15_victoria.png` | La victoria con «Epílogo», «Reintentar» y «Niveles». |
| `level_15_epilogo.png`, `level_15_creditos.png`, `level_15_epilogo_de_vuelta.png`, `level_15_victoria_de_vuelta.png` | El epílogo (imagen + 4 líneas + «Créditos» y «Niveles»), los créditos con «Volver», el epílogo al volver y la victoria al apretar `Esc`. |
| `seleccion_15_bloqueado.png`, `seleccion_15_abierto.png`, `seleccion_15_visible.png` | La tarjeta del 15 («La Central», «Energía y abastecimien…») bloqueada y abierta. |
| `play_level_15.json` | El informe de la última corrida de `play.gd` (con `skip=24`). |

## Cómo se corre

```bash
godot --path . --resolution 1280x720 art/campaign-t234/play.tscn -- speed=6 skip=24 out=art/campaign-t234
godot --path . --resolution 1280x720 art/campaign-t234/select.tscn
```

Necesitan pantalla y **mueven el puntero del escritorio** (`warp_mouse`); los clics y las teclas entran como eventos (`Input.parse_input_event`).

## Lo que se verificó en la escena real (ventana)

- **La selección:** 15 tarjetas; el 15 bloqueado hasta ganar el 14; abierto, dice «Nivel 15 · 30 oleadas», «La Central» y el lugar «Energía y abastecimien…» (con «…» porque el lugar mide 24 caracteres; el tooltip lleva el texto completo). Un clic real (después de bajar la lista hasta la tercera fila) abre la partida del nivel 15 **con el cartel de entrada** y la partida en pausa.
- **El cartel:** muestra «La Central», «Energía y abastecimiento» y las tres líneas **tal cual** de `specs/11-textos-lore.md`; un clic real lo cierra y la partida sigue.
- **El mapa:** 26 × 12, tres entradas a la izquierda que se unen, la central (cuatro cuartos, justo arriba de la salida), el depósito, el poste y la vagoneta, tres campamentos vacíos y dos rocas marcadas (ver `level_15_inicio.png`).
- **El Coloso:** en la oleada 26 sale la tarjeta «Nuevo enemigo: Coloso» y la barra avisa «¡Llega el Coloso!». Al caer **se partió en 3 Pedazos de 1215 de vida** (180 × (100 + 23 × 25) / 100: la vida de la oleada 26 con el 23 % del nivel), y salió la tarjeta del Pedazo. En la 28 (dos Colosos) y la 30 (tres, con la escolta completa por B y por C) se vieron igual.
- **El final:** al ganar el 15 con los 14 anteriores ganados, **primero se abre el Salón de la fama** (RF-194), se confirman las 5 letras y «Continuar»; **después** la victoria muestra «Epílogo» (no «Siguiente nivel») con «Reintentar» y «Niveles» y el texto «Central encendida…»; «Epílogo» abre la imagen con las **4 líneas** y los botones «Créditos» y «Niveles»; «Créditos» abre las 4 líneas de los créditos; «Volver» regresa al epílogo; **`Esc` real** cierra el epílogo y deja la victoria a la vista. **El guardado quedó idéntico** antes y después de ver el epílogo y los créditos (se comparó el texto del archivo), y `GameFlow.is_campaign_complete()` dio `true` sin ningún campo nuevo.

### Qué NO es una partida jugada

`play.gd` tiene una defensa simple (la misma orden de compra del bot, sin sus ajustes) y **pierde en la oleada 19** (la primera corrida, sin ayuda: 14 vidas en la 10, 9 en la 18, derrota en la 19). Por eso las capturas de las oleadas 26 a 30 y del final se hicieron con `skip=24`: **9000 de oro de ayuda**, la defensa comprada **con clics reales** (72 torres) y las oleadas 1 a 24 **dadas por completadas con la sesión** (`begin_wave` + `complete_wave`, lo que hacen los tests), no jugadas. Desde la 25 se juega de verdad en la ventana. El informe lo dice (`AYUDA DE VERIFICACIÓN`). Lo que sí dice esa partida es que con 72 torres el nivel se gana con 3 a 6 vidas; no es una medida de balance (eso es el bot).

### Hallazgo: el Salón de la fama va antes del epílogo

Ganar el 15 con los otros 14 ganados hace subir el total de la campaña y abre el **Salón de la fama** (RF-194) encima de la victoria. El jugador tiene que confirmar sus 5 letras y tocar «Continuar» antes de ver «Epílogo». **Es el flujo de siempre y no se tocó**, pero conviene que Lucas lo sepa: el final de la campaña es victoria → récords → Salón de la fama → «Continuar» → «Epílogo» → «Créditos». (Si prefiere que el epílogo vaya antes del Salón, es cambiar el orden de dos capas; no está en el alcance de T234.)

## El bot (5 semillas por estrategia)

Siempre dio el mismo resultado en las 5 semillas (el azar solo toca al Ladrón y a lo probabilístico). Vidas al terminar; todas las partidas llegaron a la oleada 30.

| Estrategia | Nivel 14 (T232) | **Nivel 15, final (aumento 23 %)** |
|---|---|---|
| `sin_recursos` | 3, 3, 3, 3, 3 | **2, 2, 2, 2, 2** (5 de 5 ganadas) |
| `demoler` | 16 (×5) | **2** (×5) |
| `demoledora` | 16 (×5) | **2** (×5) (el 15 no tiene demoledora: juega igual que `demoler`) |
| `extraer_temprano` | 13 (×5) | **12** (×5) |
| `extraer_tarde` | 20 (×5) | **9** (×5) |
| `mix` (con Disruptora) | pierde las 5 en la 26/26 | **pierde las 5** (28/30 la semilla 1; 30/30 las otras) |
| `mix disruptor=0` | gana las 5 con 3 vidas | **gana las 5 con 2 vidas** |

- **Regla de oro:** `check_rule=1 levels=15` → **5 de 5, «SE CUMPLE»**.
- **Las oleadas 1 a 3 no pierden vidas** (20, 20, 20) en las 5 semillas (RF-475, punto 4).
- **El 15 es el más difícil:** cada estrategia termina con igual o menos vidas que en el 14 (`sin_recursos` 2 contra 3).
- **Dónde se pierden las vidas** (`sin_recursos`, las 5 semillas iguales): oleada 7 (−4, los Embestidores), **19 (−7)**, **27 (−3)** y las del Coloso: **26: 0, 28: −1, 30: −3**. **Ningún Pedazo (4 vidas) ni ningún Coloso (12) llegó a la salida** con la defensa del bot (una fuga de un Pedazo costaría 4 y de un Coloso, 12).
- **La Disruptora no ayuda al bot** (`mix` con ella pierde, sin ella gana), igual que en el 14; el bot **no compra el Mortero** con ninguna estrategia. Ninguna de las dos cosas se tocó acá (decisión de Lucas, T217 y T232).

### Cómo se llegó al 23 % (y el precipicio)

Todo con `sin_recursos`, 5 semillas, las mismas oleadas finales (Coloso 1 / 2 / 3 en la 26 / 28 / 30):

| `aumento_vida` | 22 | **23** | 24 | 25 | 26 |
|---|---|---|---|---|---|
| Vidas al terminar | 3 (×5) | **2 (×5)** | derrota (×5, 0 vidas) | derrota (×5) | derrota (×5) |

- La ficha traía **22 %** como valor inicial. Con 22 el bot termina con **3 vidas, igual que el 14** (no más difícil); con **23** termina con **2** (más difícil, y gana 5 de 5); con **24** pierde las cinco (en las oleadas 28 y 30, las del Coloso). **El margen es de 1 punto**: lo mismo que pasó en el 14 (con 30 % terminaba con 3 vidas y con 33 % perdía). Si Lucas prefiere más aire, **se afloja una oleada final antes que el aumento**.
- Con **un solo Coloso en cada oleada** (lo que decía la ficha como valor inicial) el bot los mata sin perder una vida (26: 0, 28: −1, 30: −2 con 22 %): **no alcanzaba para que el final fuera lo más difícil**. Con dos en la 28 y tres en la 30 la oleada 30 cuesta 3 vidas con 23 % y el precipicio de los 24 % está en los Colosos.
- **Primero se midieron los Pedazos** (ficha, paso 2): con 1215 a 1380 de vida cada uno (oleadas 26 a 30) y velocidad 1.0, no se escapó ninguno en ninguna partida; no hizo falta tocar `colossus.tres` ni `colossus_shard.tres` (los números de RF-481 quedaron tal cual).

## Qué no se pudo verificar

- **El celular y Windows:** no hay un teléfono ni una máquina Windows acá; solo se miró en Linux, en una ventana de escritorio.
- **Una partida jugada por una persona:** el único jugador acá es el bot (y `play.gd`, que pierde en la 19). No se sabe cómo se siente el 15, ni si 72 torres es lo que una persona logra (el mapa tiene 72 casillas libres y el bot las llena todas; desde la oleada 25 le sobran miles de oro).
- **Los clics y las teclas** entran como eventos del motor (`Input.parse_input_event`); el puntero del escritorio sí se mueve (`warp_mouse`), pero no es un clic del sistema operativo ni un toque en pantalla.
- **El `.exe` exportado y la APK** no se probaron.
- **El arte:** la central, la cadena, el Coloso y el epílogo son los **provisionales** de T233 y T244 (esperan el OK de Lucas); no se juzgó si la central «se lee» a 64 px, solo se la miró en las capturas.
- **Los textos** salen de `specs/11-textos-lore.md`; el párrafo del Coloso en «La Central» **todavía no lo leyó Lucas en su lugar** (T243).
