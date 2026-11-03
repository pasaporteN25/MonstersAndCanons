# T575 · Recursos, agua, estandartes, tutorial del nivel 1 y lo que se guarda para la parte 2 y la 3D

**Fecha:** 2026-11-02 · **Modelo:** Claude (Opus) · **Base:** `main` en `e3ad3d1` (después del merge de T562, #177) · **Ficha:** [`T575-mecanicas-y-agua.md`](../T575-mecanicas-y-agua.md) · **Decisión de origen:** D-229.

> **Qué es este informe.** Son **opciones para que Lucas elija**, con costos y una recomendación en cada punto. **No** escribe `RF` ni `D`, **no** cambia `data/` ni código y **no** completa T576 ni T577: eso pasa recién con la elección de Lucas (compuerta 🚦). Los números salen **de los datos** (`data/obstaculos.json`, `data/levels/*.json`, `data/towers/*.tres`) o **del bot** (`tools/balance_sim.gd`), y cada tabla dice de cuál. Lo que es estimación lo dice.

---

## Resumen para decidir (una línea por punto)

| # | Tema | Lo que encontré | Recomendación |
|---|---|---|---|
| 1 | **Recursos** | En los niveles 7 y 8 el recurso casi no sirve: solo baja 30 de oro el Francotirador, y conseguir uno cuesta entre 80 y 180 de oro (en el 7 el bot juntó de 1 a 4 y no usó ninguno). Del 10 al 15 una mina resuelve todo. **En ningún nivel obliga a elegir.** En el 9, ningún bot llegó al Mortero (T282). La demoledora existe **solo en el nivel 7**. | **R1 + R2:** explicarlo mejor y **sacar el azar** (todo removible con recurso lo entrega siempre). Sin usos nuevos en la V1. |
| 2 | **Estandarte** | La palabra «estandarte» nombra **tres cosas distintas**. Los avances se juntan en 1–5 sin que se sepa para qué, y si el portador escapa, se pierde sin aviso. El bot **nunca** lo construye: su valor no se midió. | **E1 + E2 + E3:** un solo nombre y una explicación, el avance se entrega igual al ganar el nivel, y medirlo con el bot antes de tocar sus números. |
| 3 | **Agua** | El canon ya la trata como lo escaso que se asegura (el oasis, «Cántaro», los dos pozos del 11). Como **moneda nueva** no tiene en qué gastarse. | **A acotada + C:** en la V1, los dos pozos del nivel 11 reemplazan a su mina (misma cantidad, sin rebalanceo). La idea grande queda para la parte 2 y la 3D. |
| 4 | **Tutorial** | Enseñar *todo jugando* en el nivel 1 choca con RF-360, RF-417 y RF-577, y alarga mucho el primer nivel. | **T-2:** el nivel 1 enseña lo básico, los gestos nuevos y **presenta** el avance y lo que viene. Cada mecánica se enseña jugando **la primera vez que aparece** (6, 7, 9, 10, 11). |
| 5 | **Parte 2 y 3D** | El agua como terreno y como segunda economía, la reparación con destrucción y un segundo uso para el recurso son ideas que piden más que la V1. | Reservarlas en `06-monsters-canons-3d.md` §15 como **semillas no prometidas**. En el juego solo se insinúan con el Lore que ya existe, sin «próximamente». |
| 6 | **Costo** | Lo recomendado son 5 o 6 tareas chicas o medianas. Ninguna cambia los niveles 1 a 6 ni el balance del 12 al 15. | Detalle en §6. |

**Una pregunta antes de todo:** cuando escribiste «afinar recursos y **estandartes**», ¿te referías al **Estandarte mecánico** (la torre de apoyo)? Este informe lo lee así. Si hablabas de los **estandartes del mapa de campaña** (RF-695) o de los **banderines de los postes** (RF-696), avisame: esos son cosméticos y la sección 2 cambia por completo.

---

## 0. Hechos de partida, comprobados

La ficha pedía comprobarlos. Los cinco son ciertos, con dos precisiones:

| Hecho de la ficha | ¿Es así? | Dónde se ve |
|---|---|---|
| Hay una sola moneda de recursos, que sale de árboles y rocas (con probabilidad), escombros, minas y bosques explotables. | **Sí.** | RF-415; `data/obstaculos.json`. |
| La demoledora aparece recién en el nivel 7; las minas y bosques, del 10 al 15. | **Sí, con una precisión:** la demoledora está **solo** en el 7. Del 11 al 15 está escrita como `"demoledora": false`, y el 8, el 9 y el 10 no la tienen. | `data/levels/level_07.json` (único `true`). |
| El Estandarte exige cinco avances y no se puede construir del 1 al 5 (RF-360). | **Sí.** Se ofrece del 6 al 10 por `torres_extra` y del 11 al 15 en la lista `torres`. | `level_06` a `level_15`. |
| RF-577 prohíbe cambiar el mapa, el oro y las oleadas del nivel 1. | **Sí.** | RF-577. |
| El agua es un dibujo de leyenda, no un objeto, en los niveles 1 a 4 y 11. | **Sí:** 1 casilla en el 1, 2 en el 2, 1 en el 3, 1 en el 4 y 2 en el 11 (los dos pozos). | Leyenda `"~"` o `"w"` con `"dibujo": "agua"`. |

**Precisión que importa para el tutorial:** el nivel 1 **ya es fuente de un avance**. La colección `technology` sale de los niveles 1 a 5 (`data/progression.json`), y en cada uno un enemigo al azar lleva el avance (RF-358). O sea que el jugador **ya se cruza con la mecánica del Estandarte en el nivel 1**, sin que nadie se la explique.

---

## 1. Recursos

### 1.1 Cuánto se gana y en qué se gasta, nivel por nivel

**Fuente: los datos.** El «esperado» suma cada removible por su probabilidad y cada punto de extracción por su reserva entera (todos los niveles con extracción tienen 20 oleadas o más, así que una mina habilitada temprano llega a entregar sus 8). El «máximo» supone que todos los sorteos salen bien.

| Nivel | Fuentes | Oro para conseguirlo todo | Recursos esperados (máx.) | En qué se puede gastar |
|---|---|---:|---:|---|
| 1–5 | ninguna | — | 0 | (el Francotirador muestra «120 + 1 recurso» deshabilitado, RF-419) |
| 6 | 2 árboles, 1 roca, todos con 0 % | 140 | 0 | nada (solo abren casillas) |
| 7 | 3 árboles y 3 rocas al 50 % · **demoledora** | 300 (213 con la máquina) | 3 (6) | Francotirador 120 + 1 |
| 8 | 3 escombros al 50 % + la ruina de la pieza | 360 | 1,5 (3) | Francotirador 120 + 1 |
| 9 | 3 escombros al **100 %** + la ruina de la pieza | 360 | 3 (3) | **Mortero 300 + 3**, Francotirador |
| 10 | 3 escombros y 3 rocas al 50 %, la ruina de la pieza, 1 mina | 640 | 11 (14) | Mortero, Francotirador |
| 11 | 2 escombros y 3 rocas al 50 %, 1 mina | 460 | 10,5 (13) | Mortero, **Disruptora 130 + 2**, Francotirador |
| 12 | ídem, con un bosque en lugar de la mina | 460 | 10,5 (13) | ídem |
| 13–14 | ídem, con mina **y** bosque | 560 | 18,5 (21) | ídem |
| 15 | 5 escombros al 50 %, 1 mina, 2 bosques | 750 | 26,5 (29) | ídem |

**Lo que cuesta un recurso, según de dónde salga** (datos, sin la máquina): árbol, 80 de oro por recurso esperado; roca, 120; escombro al 50 %, 180; escombro al 100 % (nivel 9), 90; **mina o bosque, 12,5** (100 de oro por 8).

**Lo que vale un recurso:** en el Francotirador, **30 de oro** (150 contra 120 + 1). En el Mortero y la Disruptora no tiene precio en oro: sin recursos **no se construyen**.

### 1.2 Qué le falta para sentirse una mecánica

1. **En el 7 y el 8 no hay una decisión.** Demoler para juntar recursos **pierde oro** (se paga entre 80 y 180 por algo que vale 30). Lo que justifica demoler ahí es **la casilla que se abre**, no el recurso. El contador aparece, sube y no sirve para casi nada.
2. **Del 10 al 15, la mina lo resuelve todo.** Una mina da 8 recursos por 100 de oro (12,5 por recurso, contra 80 a 180 si se demuele). El bot habilita la mina, gasta los 8 y gana; demoler por recursos nunca compite (§1.3). Los que sobran, si sobran, se pierden al ganar (RF-415) sin que se note.
3. **El único lugar donde el recurso decide algo, el 9, no se alcanza.** T282 lo midió con 5 semillas: la estrategia `mortero` juntó los 3 recursos en todas, **no compró el Mortero en ninguna** y perdió las cinco en la oleada 3; `demoler` ganó 2 de 5. Llegar al Mortero cuesta 270 + 300 de oro con 320 al empezar (RF-525, todavía sin elegir, T283).
4. **El azar confunde y no aporta.** «Puede dar 1 recurso (50 %)» es la **única excepción** a «sin sorteos» de la V1 (RF-417). En el 9 ya hubo que subirlo al 100 % para que el Mortero fuera posible (RF-523). Para alguien que recién empieza, un recurso que *a veces* no sale parece un error.
5. **La demoledora vive en un solo nivel.** Es una compra con su propia pestaña («Infraestructura», RF-457) que aparece en el 7 y nunca más.
6. **Nadie lo explica.** La Wiki no tiene ningún artículo sobre recursos, demolición, avances ni el Estandarte (`data/wiki/` tiene 7 artículos de juego y ninguno los menciona). Las fichas de torre muestran el costo en recursos, pero no de dónde salen.

### 1.3 Medición con el bot (esta tarea)

**Fuente: el bot**, `main` en `e3ad3d1`, sin mejoras de torres. No reemplaza una partida de Lucas.

**Nivel 7**, semillas 1 a 3 (`demoler,demoledora,sin_recursos level=7 seeds=3`):

| Estrategia | Resultado | Vidas | Oro en demoler | Recursos juntados | Recursos usados |
|---|---|---:|---:|---|---:|
| `demoler` | 3 de 3 | 13 | 240 | 1 · 2 · 4 | **0** |
| `demoledora` | 3 de 3 | 13 | 240 (**nunca compró la máquina**) | 1 · 2 · 4 | **0** |
| `sin_recursos` | 3 de 3 | 12 | 0 | 0 | — |

Demoler da **1 vida más** por las casillas que abre, pero los recursos **no se usan**: el único gasto posible es el Francotirador barato, y no le conviene ni al bot. El azar se nota: con el mismo mapa, de 1 a 4 recursos según la semilla. La demoledora no llega a convenir.

**Niveles 10 a 15**, semillas 1 y 2 (`extraer_temprano levels=10-15 seeds=2`): **12 victorias de 12**.

| Nivel | Vidas | Recursos (todos de extracción) | Recursos que sobraron | Oleada de la 1.ª torre con recursos | Oro al terminar |
|---|---:|---:|---:|---|---:|
| 10 | 17 | 8 | 0 | 3 | ~3400 |
| 11 | 17 | 8 | 0 | 1 | ~2150 |
| 12 | 14 | 8 | 0 | 2 | ~3660 |
| 13 | 14 | 16 | 0 | 4 | 1740 |
| 14 | 13 | 16 | 0 | 4 | 5248 |
| 15 | 12 | 24 | 0 | 4 | ~5000 |

**Lectura honesta:** del 10 al 15 el bot **usa todos** los recursos de la extracción (en Morteros y Francotiradores) y termina con **mucho oro sin gastar**. Ese oro está inflado, porque esta estrategia no mejora torres. Así que «sobra» no es exacto: lo que pasa es que **una mina resuelve todo** y el resto de las fuentes (demoler) no hace falta. No hay una decisión entre fuentes: se habilita la mina y listo. Sin `SCRIPT ERROR` en ninguna corrida.

### 1.4 Opciones

| Opción | Qué cambia | Reglas que toca | Costo | Riesgo |
|---|---|---|---|---|
| **R1 · Solo explicar** | Un artículo de Wiki «Recursos y demolición»; el panel de un removible dice **en qué sirve el recurso en este mapa** («Acá sirve para: Francotirador, Mortero»); la primera vez que aparece, una lección corta (ver §4). | RF-404 (texto del panel), nuevas lecciones (§4). | Bajo: textos, i18n y un poco de interfaz. | Muy bajo. No cambia el balance. |
| **R2 · Sacar el azar** | Todo removible que da recursos los **entrega siempre** (`probabilidad` 100 en `data/obstaculos.json` para árbol y roca; los escombros comunes de 8, 10 a 15 también). El panel dice «Da 1 recurso». Para que no sobre más, se puede **bajar la cantidad de removibles con recurso** en 10 a 15, pero solo si el bot lo muestra. | RF-417 queda sin uso: la V1 vuelve a ser «sin sorteos». RF-398 (valores). | Bajo-medio: datos, textos, tests de semilla y remedir con el bot 7 a 15. | Bajo. Todo mapa sigue ganándose sin recursos (RF-432 no usa removibles). Los niveles 7 y 8 dan más recursos (el 7 pasa de 3 esperados a 6), pero solo sirven para el Francotirador. |
| **R3 · Un uso nuevo para el recurso** | Algo en qué gastar el sobrante: la Cohetera de T447 (A3), o pagar una mejora con recursos. | Choca con Q-22 («mejorar no cuesta recursos», decisión de Lucas) o suma una torre nueva. | Alto: torre o regla nueva, arte, bot, balance de 9 a 15. | Medio-alto: puede volver obligatorios los recursos en el 13–15, que estaban al borde cuando T282 los midió (2 a 5 vidas con `sin_recursos`, 2026-10-17). |
| **R4 · Resolver el Mortero del 9** | Elegir una de las opciones de RF-525 (pendiente desde T282). | RF-525. | Depende de la opción. | Lo decide T283. |

**Recomendación: R1 + R2.** El problema principal no es que falten fuentes ni usos, sino que **no se entiende** y que el azar lo vuelve poco confiable. R2 es un cambio de datos con una buena razón ya probada en el 9. **R3 no entra en la V1** (va a §5). **R4 queda donde está** (T283, post-V1), pero conviene que lo mires junto con esto.

---

## 2. El Estandarte mecánico

### 2.1 Cómo funciona hoy (datos y spec)

- **Qué hace:** no dispara. A las torres que tiene cerca les da **+10, 15 o 20 % de cadencia** (radio 2, 2,5 o 3 casillas) y les **repara el desgaste** a 2, 3 o 4 puntos por segundo. Cuesta 120, 100 y 160 de oro. Solo vale el aura más fuerte, y no se potencia a sí mismo ni a otros estandartes (RF-361; `data/towers/mechanical_standard.tres`).
- **Cómo se consigue:** con los **cinco avances** de los niveles 1 a 5. En cada uno, un enemigo al azar lleva el avance; si muere, se recoge, y se confirma al terminar la oleada. **Si el portador escapa, el avance se pierde** y hay que volver a jugar el nivel (RF-358 y RF-359).
- **Dónde se usa:** del 6 al 15, si se tienen los cinco avances.
- **Contra qué sirve la reparación:** contra el **Embestidor**, que desgasta torres (hasta 1 por grupo en el 6, hasta 16 en el 9 y el 10, entre 7 y 10 del 11 al 15; son topes, porque algunos grupos salen con probabilidad).

### 2.2 Qué tiene de confuso

1. **Una palabra, tres cosas.** «Estandarte» es la **torre** (Estandarte mecánico); los **estandartes** del mapa de campaña muestran quién ganó cada región (RF-695); y los **banderines de los postes** de cada nivel son otra cosa más (RF-696). Además, la torre todavía aparece como «Mecánico» en varios documentos y en la descripción del Embestidor (glosario T202, Q-3).
2. **Se junta algo sin saber para qué.** Del 1 al 5 aparece un ícono plateado arriba («0/5») y un enemigo que suelta algo. Lo que desbloquea recién se ve en el 6.
3. **Se puede perder sin darse cuenta.** Si el portador escapa, no hay ningún aviso de que haya que volver a jugar ese nivel. Alguien puede llegar al 6 con 4/5 y no entender por qué no tiene la torre. *(No comprobé si el selector de niveles marca qué nivel tiene el avance pendiente.)*
4. **Hace dos cosas, y la descripción lo dice en un párrafo largo.** «Aumenta la cadencia… No dispara ni acumula… Requiere cinco avances y permiso del nivel. Repara desgaste…» (`description` del `.tres`).
5. **Nadie midió cuánto vale.** El bot **excluye** las torres de apoyo (`support_only`, `tools/balance_sim.gd` línea 493), así que ningún balance del 6 al 15 cuenta con él. No se sabe si 120 de oro en un Estandarte rinden más que 120 en un cañón.

### 2.3 Opciones

| Opción | Qué cambia | Reglas que toca | Costo | Riesgo |
|---|---|---|---|---|
| **E1 · Un nombre y una explicación** | «Estandarte mecánico» en todos lados (se termina «Mecánico»). Descripción en dos líneas: «Acelera a los cañones cercanos. Repara el desgaste.» La ayuda del ícono de avances dice **qué desbloquea** («3/5 · Con cinco, el Estandarte mecánico»). Un artículo de Wiki. | RF-362 (texto de la ayuda), descripción del `.tres`, documentos. | Bajo (Haiku o Sonnet bajo). | Muy bajo. |
| **E2 · El avance no se pierde sin aviso** | Si el portador escapa pero se **gana el nivel**, el avance se entrega igual al terminar. Sigue sin entregarse si se pierde o se abandona. | Enmienda RF-358 («si escapa, se puede rejugar») y RF-359. | Bajo-medio (Sonnet medio): lógica, tests y guardado (aditivo, igual que hoy). | Bajo. La colección se completa antes; no cambia ningún nivel. |
| **E3 · Medirlo** | El bot aprende a construir un Estandarte (por ejemplo, junto al grupo de torres más grande, a partir de la cuarta torre). Se mide con y sin él en 6 a 15. **Es solo de la herramienta**, no del juego. | Ninguna del juego. | Medio (Sonnet medio). | Ninguno. Si muestra que no conviene, recién ahí se proponen números nuevos (con otra decisión). |
| **E4 · Rediseñarlo** | Cambiar qué hace (por ejemplo, que repare torres destruidas). | La alternativa de «vida y destrucción» que la spec ya dejó para después (M37, etapas siguientes, punto 3). | Alto. | Alto: es un sistema nuevo. **No en la V1.** |

**Recomendación: E1 + E2 + E3,** en ese orden. E2 es la única regla que cambia, y conviene porque hace que **presentar el avance en el nivel 1** (§4) no enseñe algo que después se pierde sin explicación. E4 va a §5.

---

## 3. El agua

### 3.1 Qué dice el canon

- El planeta se llama **Cántaro** «por el oasis: el agua guardada en un planeta seco» (`10-universo.md` §2; Lore «Planeta Cántaro»).
- El **oasis** (niveles 1 a 5) es «el único sitio con agua a la vista», y por eso aterrizó la nave. Ahí el agua **sobra** (Lore «El oasis»). Los niveles 2 y 4 se tratan del agua: «El paso del agua» y «El pozo» (`11-textos-lore.md`).
- En el **desierto** (10 a 12) hay «poca agua, minas, caminos secos». El nivel 11, «El punto de agua», asegura **dos pozos que ya tenían huellas alrededor**: son de los Moradores (Lore «Los pozos»).
- El **recurso** de hoy es «material crudo de acá (madera, piedra, mineral)» (§3).
- Tono: «se muestran consecuencias, no sentencias». El ejemplo canónico es justamente «Dos pozos quedaron dentro del perímetro» (§8).

**Lo que eso implica:** el agua es **lo que se asegura**, no lo que se fabrica. En el oasis no hace falta extraerla, y en el desierto sacarla es **tomarla de alguien**. Cualquier opción tiene que respetar eso.

### 3.2 Las opciones

| | **A · Otra fuente de la misma moneda** (clase `pozo`) | **B · Una segunda moneda** | **C · Solo historia en la V1** |
|---|---|---|---|
| **Qué es** | Una clase de extracción nueva, `pozo`, que funciona como la mina: se habilita con oro, da recursos por oleada completada y se agota. | Un contador «agua», aparte de los recursos, con fuentes y gastos propios. | El agua sigue siendo dibujo y texto. Se presenta como idea en la parte 2. |
| **Qué niveles cambian** | **Recomendado, acotado:** solo el **11**. Sus dos casillas de agua pasan a ser **dos pozos** y **la mina se va**. Cada pozo cuesta 50, da 1 por oleada y tiene reserva 4: en total, **lo mismo que la mina** (100 de oro, 8 recursos). *(Ampliado: también el 12 y el 15; pide rebalanceo.)* | Del 10 al 15, como mínimo; además, cada torre que cueste agua. | Ninguno. |
| **Cómo se vería** | Un brocal de piedra con balde y polea sobre el agua. **Sin habilitar:** el balde abajo. **Activo:** balde arriba y segmentos de reserva, como la mina. **Agotado:** el fondo seco y marrón. Hasta que haya arte, dibujado por código (🎨 para el definitivo). | Un segundo ícono en la barra de arriba (en el celular ya está apretada), costos dobles en la barra de torres y en los paneles. | Igual que hoy. |
| **Qué cuenta** | «Asegurar los dos pozos» deja de ser solo texto: el jugador los **habilita**. Tomar el agua de los pozos con huellas es una consecuencia que se muestra y no se juzga. | Podría contar una colonia que administra su agua, pero en la V1 **no hay en qué gastarla** sin inventar torres o reglas nuevas. | La historia ya lo dice (Lore y textos de los niveles 2, 4 y 11). |
| **Costo** | Medio-bajo: clase en `obstaculos.json`, dibujo y estados, validador y editor (la lista cerrada de RF-263 y RF-399), textos en los dos idiomas, cambiar el mapa del 11, tests, `check_level` y el bot (regla de oro y `extraer_*` en el 11). **Una tarea** (Sonnet alto o Codex). | **Alto**, varias tareas: `TowerData` (`water_cost`), cobrar y devolver, HUD de PC y de celular, barra y paneles, editor, validador, Wiki, bot (estrategias y regla de oro con dos monedas), balance de 10 a 15, i18n. Si se guardara entre niveles, también el guardado. | Casi nulo. |
| **Riesgo** | Bajo, si se mantiene «misma cantidad que la mina». El 11 no está al borde. | Alto: 13 a 15 están al borde (2 a 5 vidas con `sin_recursos`) y la V1 está cerrando. | Ninguno, pero el agua sigue sin hacer nada. |
| **Reglas que toca** | RF-398 (clase nueva), RF-399, RF-401 (dibujo `pozo`), RF-402 y RF-476 (mapa del 11). RF-403 se cumple: los mapas viejos no cambian. | M50 entera (RF-415 a RF-421), RF-432 y RF-433. | Ninguna. |

**Una cuarta idea, que no recomiendo para la V1 — D · Agua como terreno.** Que las casillas de agua cambien algo: por ejemplo, que el Hielo sea más fuerte junto al agua o que un vado frene a los monstruos. Es lo que el documento 06 llama «terrenos con efecto» (§4.3). Es más interesante que A, pero es una mecánica nueva que pide mapas pensados para ella. Va a §5.

**Recomendación: A acotada (solo el 11, reemplazando su mina) + C para la idea grande.** El agua hace algo en el único nivel cuyo objetivo es literalmente «asegurar los pozos», sin rebalancear y sin tocar el oasis. Si preferís no sumar nada a la V1, **C sola** también es razonable: el canon ya cuenta el agua.

> **Por qué no en el oasis (niveles 2 y 4):** RF-417 y el bloque básico dicen que del 1 al 5 no hay removibles ni recursos, y el canon dice que ahí el agua sobra. Ponerle un pozo al nivel 4 cambiaría el balance de un nivel «básico» y contradiría la idea del oasis.

---

## 4. Tutorial del nivel 1

### 4.1 Las tres formas de hacerlo

| | **T-1 · El nivel 1, ampliado** | **T-2 · El nivel 1 presenta; cada nivel enseña lo suyo** | **T-3 · Todo jugando en el nivel 1** |
|---|---|---|---|
| **Qué** | Los 14 o 15 pasos de hoy, más los gestos nuevos y dos tarjetas: el avance y «lo que viene». | Lo mismo que T-1, más una **lección corta** (2 o 3 tarjetas) **la primera vez** que aparece cada mecánica: 6, 7, 9, 10 y 11. | Se agrega al mapa del 1 un árbol o una roca, un recurso y un Estandarte construible. |
| **Reglas que se enmiendan** | RF-571, RF-572 y RF-573 (pasos nuevos y cuáles son obligatorios). | Además: RF-570 (un tutorial por nivel), RF-575 (una marca por lección, aditiva) y RF-577 (sale en los niveles con lección). | RF-577 (mapa y balance del 1), RF-417 (el 1 sin removibles), RF-360 (Estandarte del 1 al 5), RF-416 (contador en el 1) y la idea de «básico del 1 al 5». |
| **Costo** | Bajo-medio (Sonnet medio): es T576 tal como está. | Medio-alto: T576 más una tarea nueva para las lecciones (Sonnet alto). | Alto: mapa, balance y bot del 1, más tutorial. |
| **Riesgo** | El primer nivel pasa de 14 a 17 pasos (de 15 a 20 en el celular). | Lo mismo en el 1. Las lecciones son cortas y salen una sola vez. | **Alto:** un primer nivel con demasiadas cosas, y se rompe la progresión que hoy funciona. |

**Recomendación: T-2.** Cumple lo que pediste («que el nivel 1 sirva para entender todas las mecánicas») **presentándolas**, sin cambiar el nivel 1 ni RF-360. Cada mecánica se enseña **jugando** en el nivel donde de verdad sirve. Se puede hacer en dos etapas: T576 hace T-1 y una tarea nueva suma las lecciones.

### 4.2 Pasos concretos del nivel 1 (para T-1 y T-2)

Los de hoy siguen igual. Los nuevos llevan **★**. «Acción» espera a que el jugador lo haga; «lectura» pasa con «Siguiente». Los textos son orientativos (los escribe T576, y los aprobás vos).

| # | Paso | PC | Celular | Qué hace | Regla |
|---|---|---|---|---|---|
| 1 | `welcome` | lectura | lectura | Bienvenida. | — |
| 2 | `path` | lectura | lectura | El camino. | — |
| 3 | `gold` | lectura | lectura | El oro. | — |
| 4 | `lives` | lectura | lectura | Las vidas. | — |
| 5 | ★ `zoom` | acción: **rueda** | acción: **pinza o «+»** | «Acercá el mapa para ver mejor.» Avanza al acercar (ya existe la señal `view_zoomed_in`). | RF-731 (necesita T568) |
| 6 | ★ `pan` | — (se omite) | acción: **arrastrar con un dedo** | «Con el mapa cerca, arrastrá con un dedo para moverte. La lupa vuelve a mostrar todo.» | RF-732 (T568). En la PC se omite: el botón del medio es poco conocido y se puede mencionar en la Wiki. |
| 7 | `pick_tower` / `open_cart` → `pick_card` | acción | acción | Elegir una torre. | — |
| 8 | `place_tower` / `confirm_tower` | acción | acción | Construirla. | — |
| 9 | ★ `double_tap` | — (se omite) | acción: **doble toque en una casilla vacía** | «Atajo: tocá dos veces una casilla vacía y se abre la compra.» Avanza cuando se abre el catálogo así. | RF-740 (necesita T573). En la PC la barra siempre está a la vista y el atajo aporta poco: se omite. |
| 10 | `start_wave` | acción | acción | Empezar la oleada. | — |
| 11 | `select_tower` | acción | acción | Elegir la torre construida. | — |
| 12 | `upgrade` | lectura | lectura | Mejorar. | — |
| 13 | `sell` | lectura | lectura | Vender. | — |
| 14 | `speed` | acción | acción | Velocidad. | — |
| 15 | `pause` · `resume` | acción | acción | Pausa y seguir. | — |
| 16 | ★ `advance` | lectura | lectura | Señala el **contador de avances** de arriba: «Un monstruo de este nivel lleva un avance. Si lo derrotás, es tuyo. Con cinco se arma el Estandarte mecánico, a partir del nivel 6.» | **Presenta** (no se usa). No toca RF-360. Con E2, el texto puede decir «si ganás el nivel, es tuyo». |
| 17 | ★ `later` | lectura | lectura | Nada señalado: «Más adelante vas a poder demoler rocas y árboles, juntar recursos y armar torres especiales. Te lo vamos a mostrar cuando aparezca.» | Presenta. Sin números (regla de `datos.md`). |
| 18 | `done` | lectura | lectura | Cierre. | — |

**Total:** 17 pasos en la PC (hoy 14) y 20 en el celular (hoy 15). Si te parece largo, lo primero que sacaría es `welcome` (la tarjeta ya dice «Saltar tutorial») y juntaría `advance` y `later` en una sola tarjeta.

**Dependencias nuevas para T576:** además de T574 y T575, necesita **T568** (zoom y un dedo) y **T573** (doble toque) ya integradas en `feature/m89-integracion`. Hoy la ficha de T576 no las nombra.

### 4.3 Las lecciones de nivel (solo T-2)

Cada una sale **una sola vez**, la primera vez que se entra a ese nivel desde la campaña, con la misma tarjeta del tutorial y salteable. Usan los mismos tipos de paso: lectura y acción.

| Nivel | Mecánica | Cómo | Pasos |
|---|---|---|---|
| 6 | **Demoler** · **Estandarte** (si ya tiene 5/5) | Jugando · presentado | «Tocá el árbol marcado» (acción) → «Demoler: pagás oro, esperás, y la casilla queda libre» (lectura). Si tiene los 5 avances: «El Estandarte no dispara: acelera y repara a los cañones cercanos» (lectura, señala su botón). |
| 7 | **Recursos** · **Demoledora** · **pago doble del Francotirador** | Jugando | «Algunos objetos dan un recurso al demolerlos» (lectura, señala el contador) → «La demoledora abarata todas las demoliciones del mapa» (lectura, señala la pestaña Infraestructura). |
| 8 | **Pieza** (hallazgo) | Presentado | «Esta ruina guarda una pieza. Con tres, la Disruptora» (lectura, señala la ruina). |
| 9 | **Torre con recursos** (Mortero) | Presentado | «El Mortero cuesta oro y recursos» (lectura, señala su botón). |
| 10 | **Mina** | Jugando | «Habilitá la mina: da recursos cada oleada, hasta agotarse» (lectura, señala la mina). |
| 11 | **Pozos** (si se elige A) · **Disruptora** | Presentado | Una tarjeta por cada una. |

---

## 5. Parte 2 y versión 3D

**Criterio:** lo que pide **mapas, cámara o un sistema nuevo** va para después; lo que en la V1 solo **aclara** algo que ya existe, se hace ahora. Nada de lo que sigue se promete en el juego.

| Idea | Para dónde | Por qué ahí | Qué hacer ahora |
|---|---|---|---|
| **Agua como terreno** (vados que frenan, orillas que potencian el Hielo, puentes) | **3D** | El documento 06 ya propone «terrenos con efecto» y «caminos en dos niveles» (§4.3). Con alturas, el agua corre por los valles y se lee sola. | Una entrada en `06` §15 («3D-0x · El agua del terreno»). |
| **Agua como segunda economía** (la colonia administra su agua, sus pozos y su abastecimiento) | **Parte 2** | Necesita una economía de colonia que la V1 no tiene, y conecta con «elegir bando»: los pozos son de los Moradores. | Una semilla en `10-universo.md` §9, **sin prometer**. |
| **Reparar y reconstruir torres destruidas** (E4) | **Parte 2 o 3D** | La spec ya la dejó como «alternativa futura» (M37, punto 3). | Ya está anotada; solo enlazarla desde §15. |
| **Un segundo uso para el recurso** (Cohetera, T447 A3) | **Parte 2** | Es una torre nueva con su balance; la V1 está cerrando. | Ya está en T447; enlazarla. |
| **Volcán y pantano** | **Parte 2 o 3D** | Regiones del canon «sin visitar» (§2). El pantano es agua quieta: el terreno con efecto más natural. | Ya es semilla. |

**Cómo se presenta sin prometer:** como ya hace el canon con sus semillas. En el juego, **nada de «próximamente»** ni pantallas de lo que viene. Lo que ya está alcanza para insinuarlo: el Lore «Los pozos», el oasis y el nombre Cántaro. Si querés mostrarlo a alguien (inversores, amigos, la comunidad), un documento aparte «Hacia la parte 2» con las ideas marcadas como **exploración**. Eso lo puedo armar si lo pedís; no lo hice porque no estaba en el pedido.

---

## 6. Costo por opción

Las tareas son **propuestas sin número**: los números de `T` se toman después de tu elección. «Bot» es la remedición con `tools/balance_sim.gd`.

| Opción | Tareas | Ejecutor y esfuerzo | Rebalanceo con el bot | Riesgo |
|---|---|---|---|---|
| **R1** | 1 (textos, panel, Wiki) | Sonnet bajo | No | Muy bajo |
| **R2** | 1 (datos y textos; `check_rule=1` de 6 a 15) | Sonnet medio | **Sí:** regla de oro 6–15 y `demoler`/`extraer_*` en 7–15 con 5 semillas | Bajo |
| **R3** | 3 o más (spec, torre o regla, arte, balance) | Opus spec + Sonnet alto + Codex | Sí, de 9 a 15 | Medio-alto |
| **E1** | 1 (documentos, `.tres`, textos) | Haiku alto | No | Muy bajo |
| **E2** | 1 (lógica de colección, tests) | Sonnet medio | No (los niveles no cambian) | Bajo |
| **E3** | 1 (solo `tools/`) | Sonnet medio | Es la medición | Ninguno |
| **Agua A acotada** | 1 (clase, dibujo provisional, mapa del 11, tests) + 🎨 para el arte final | Sonnet alto (o Codex Terra para el dibujo) | **Sí:** el 11 con `sin_recursos`, `extraer_temprano` y `extraer_tarde`, 5 semillas; debe dar igual que hoy | Bajo |
| **Agua B** | 4 o 5 | Opus spec + Sonnet alto ×3 + Codex | Sí, de 10 a 15, y una regla de oro nueva | Alto |
| **Agua C** | 0 en el juego; 1 nota en `06` y `10` | — | No | Ninguno |
| **Tutorial T-1** | 1 (T576) | Sonnet medio | El nivel 1 con `mix` (no debería cambiar: el tutorial no toca el juego) | Bajo |
| **Tutorial T-2** | T576 + 1 nueva (lecciones) | Sonnet medio + Sonnet alto | Igual que T-1 | Bajo-medio |
| **Tutorial T-3** | 3 o más | Opus spec + Sonnet alto | Sí, el 1 entero | Alto |

**Lo recomendado junto (R1 + R2, E1 + E2 + E3, agua A acotada + C, T-2):** unas **7 tareas**, ninguna grande. Ninguna cambia los niveles 1 a 6. Las únicas con rebalanceo son R2 y la del agua, y las dos deben dejar la regla de oro como está.

---

## 7. Qué se probó y qué no

- **Se leyó:** los datos de los 15 niveles, `obstaculos.json`, `progression.json`, las torres, el tutorial, la Wiki y las secciones de spec y de canon que pide la ficha.
- **Se midió con el bot:** el nivel 7 con 3 estrategias y 3 semillas (9 partidas) y los niveles 10 a 15 con `extraer_temprano` y 2 semillas (12 partidas), todas ganadas y sin `SCRIPT ERROR` (§1.3). **No** se volvió a correr `check_rule=1` ni `sin_recursos` del 10 al 15: los números de borde de 13 a 15 son los de T282.
- **No se probó:** ningún cambio propuesto (no se tocó `data/` ni código). Si una persona entiende mejor con T-2 que con T-1 solo se sabe jugándolo. Tampoco cuánto vale el Estandarte (eso es E3), ni el selector de niveles con un avance perdido.
- **No se jugó en un teléfono.** Los pasos del celular suponen T568 y T573 terminadas como dice su spec.

## 8. Qué tenés que elegir

Respondé con una letra por línea (o «la recomendada»):

1. **Recursos:** R1 · R2 · R3 · combinación (recomendado: **R1 + R2**).
2. **Estandarte:** E1 · E2 · E3 · E4 · combinación (recomendado: **E1 + E2 + E3**). Y confirmá que hablabas de la **torre**.
3. **Agua:** A acotada (solo el 11) · A ampliada (11, 12 y 15) · B · C · D (recomendado: **A acotada + C**).
4. **Tutorial:** T-1 · T-2 · T-3 (recomendado: **T-2**). ¿Sacamos `welcome` para acortar?
5. **Parte 2 y 3D:** ¿anoto las semillas de §5 en `06` §15 y `10` §9? (recomendado: **sí**).

Con eso, T575 escribe los `RF` y `D`, completa T576 y T577 (o cancela T577 si elegís C) y propone las tareas nuevas.
