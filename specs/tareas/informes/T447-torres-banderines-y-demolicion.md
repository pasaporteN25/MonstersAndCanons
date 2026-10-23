# T447 · Torres futuras con banderines e Infraestructura, y consecuencias narrativas de demoler

**Fecha:** 2026-10-23 · **Modelo:** Claude (Opus) · **Frente:** D de la matriz del 2026-10-23 · **Backlog:** B-55 y B-56 (registrados en el PR #49) · **Base:** `origin/main` en `250e724`.

> **Qué es este informe.** Es **diseño para revisión**. No propone agregar nada al juego ahora, no toca datos, balance, reglas ni canon, y no reserva números de RF ni de D. Las decisiones que harían falta se escriben al final como texto **PENDIENTE DE LUCAS**, sin número: si Lucas aprueba algo, una tarea 📜 aparte les asigna el siguiente número libre.
>
> **Números.** Todos los números de este informe son **ORIENTATIVOS**: sirven para que la idea se entienda y se pueda comparar. No salen de ninguna medición. Antes de usarlos hay que pasarlos por el bot (`tools/balance_sim.gd`) y por partidas de Lucas.

---

## Resumen

**Parte A · Torres.** Propongo tres torres, y cada una agrega una **decisión que hoy no existe**:

| # | Torre (nombre de trabajo) | La decisión que agrega | Con qué sistema se cruza | Riesgo de que los recursos se vuelvan obligatorios | Costo | ¿V1? |
|---|---|---|---|---|---|---|
| A1 | **Puesto de banderín** | **Dónde reclamar** una casilla despejada: proteger la caja de los ladrones o poner otra torre que dispare | Banderines (muestra la receta del jugador) + demolición (se apoya en una casilla despejada) | **Bajo**: no cuesta recursos. El riesgo real es que se vuelva obligatoria **contra la Cuadrilla** | Código M · arte M | Futuro |
| A2 | **Honda de escombros** | Usar un obstáculo como **munición** (gratis, se gasta) o **demolerlo** (oro y tiempo, da casilla y quizá un recurso) | Removibles (árbol, roca, escombro) | **Bajo a medio**: compite con la demolición por los mismos obstáculos y le resta sentido a la Demoledora | Código L · arte M-L | Futuro |
| A3 | **Cohetera** (el lanzamisiles que propuso Lucas en el 07 §9) | **Gastar un recurso ahora** para una salva extra en el pico o **guardarlo** para el Mortero o la Disruptora | Recursos (D-083) y extracción (D-084), con el ritmo de las oleadas | **Medio**: le da a los recursos un uso nuevo; hay que vigilar que no sea la única respuesta a las escoltas del 13 al 15 | Código M-L · arte M | Futuro |

**Recomendación corta:** ninguna entra en la V1. Si Lucas quiere una para después de la V1, empezar por **A1** (la que menos código pide y la que mejor cuenta el canon) o por **A3** (la que Lucas ya había propuesto). **A2** es la más original y la más cara, porque el retroceso no existe hoy.

**Parte B · Demoler y arrasar el planeta.** Comparé tres caminos. **(N-A)** no agregar nada; **(N-B)** una lectura en el texto y en el mapa, sin efecto en las reglas; **(N-C)** una consecuencia mecánica leve. Recomiendo **N-B**, después de la V1 y solo en sus formas chicas: una huella en el mapa y un artículo de Lore. **N-C** queda como semilla para «elegir bando» (M&C 2): en la V1 contradice dos reglas del tono (§8.1 y §8.2) y la idea de que demoler es una inversión (07 §5).

---

## 1. De qué se parte (lo que ya está en `main`)

**Infraestructura (M50, D-080 a D-085).**
- Los **removibles** son árbol (40 de oro, 4 s), roca (60, 6 s) y escombro (90, 10 s). Se demuelen de a uno, se cobran al ordenar y dejan la casilla como **pasto construible**. Nunca cambian el camino (RF-400).
- La **Demoledora** cuesta 180 y baja cada demolición al 10 % del precio (mínimo 5) y al 80 % del tiempo. Hoy **solo la habilita el nivel 7** (`level_07.json`, `"demoledora": true`); del 11 al 15 está escrita como `false`.
- Los **recursos** son un solo material, local a la partida, que se pierde al terminar. Salen de removibles (al azar, con semilla), de minas y de bosques explotables (2 por oleada completada, reserva de 8).
- Lo que cuesta recursos: Mortero 300 + 3, Disruptora 130 + 2, y el Francotirador ofrece la forma 120 + 1 además de 150 solo oro. **Mejorar no cuesta recursos** (Q-22).
- La **regla de oro** (RF-432 y RF-433): todo mapa con recursos se gana con la estrategia `sin_recursos` en 4 de 5 semillas. Esa estrategia no demuele, no extrae y no usa nada que cueste recursos.
- Inventario de obstáculos por nivel, leído de `data/levels/*.json`. **No incluye el 1 al 5, que no tienen.**

  | Nivel | Removibles | Extracción | Demoledora |
  |---|---|---|---|
  | 6 | 2 árboles, 1 roca (sin recursos) | — | no |
  | 7 | 3 árboles, 3 rocas | — | **sí** |
  | 8 | 3 escombros + 1 con pieza | — | no |
  | 9 | 3 escombros (100 %) + 1 con pieza | — | no |
  | 10 | 3 escombros + 1 con pieza, 3 rocas | 1 mina | no |
  | 11 | 2 escombros, 3 rocas | 1 mina | no |
  | 12 | 2 escombros, 3 rocas | 1 bosque | no |
  | 13 y 14 | 2 escombros, 3 rocas | 1 mina, 1 bosque | no |
  | 15 | 5 escombros | 1 mina, 2 bosques | no |

**Banderines (M73 y M74, RF-655 a RF-665, D-181 a D-186).**
- Hoy hay **un solo poste**: el del nivel 6 (letra `p`, dibujo `poste_cintas`).
- Muestra los banderines **enemigos** mientras el nivel no se ganó y los **del jugador** después de cualquier victoria (D-181).
- El editor de banderines cambia solo la receta del jugador, con un catálogo cerrado, y la guarda **fuera** del guardado de campaña (D-186). La facción enemiga queda fija (D-185).
- **Es puramente cosmético**: no toca progreso, balance ni guardado.

> **Consecuencia de diseño, la más importante de la parte A.** Para que una torre «interactúe con banderines» sin romper D-185 y D-186, **la receta del jugador nunca puede cambiar un número**. Una torre puede **mostrar** el banderín del jugador y puede usar la **idea** de banderín (marcar, reclamar, señalar), pero sus reglas tienen que ser iguales con cualquier receta, sin receta o con el archivo dañado. Las tres propuestas lo respetan.

**Lo que dice el canon y viene al caso.**
- *«Cada victoria asegura un lugar más para la colonia, y cada lugar asegurado se lo saca a alguien»* (`10-universo.md` §1.4).
- El **poste con cintas** es una **señal de los Moradores** (§6, nivel 4: *«es una señal para otros»*). En el nivel 6, ganar cambia **sus** cintas por **las nuestras**. Eso ya es una consecuencia narrativa de conquistar, mostrada sin texto.
- Las **ruinas llevan el símbolo A** y la colonia las trata como un **yacimiento** (§5). La Disruptora usa lo de ellos contra ellos, y *«el juego lo muestra y no lo comenta»* (§5).
- El **Chamán** *«frena la infraestructura de la colonia, no mata colonos»* (§4.3).
- Los textos aprobados ya dicen lo que se hace con el terreno: *«Se taló el primer tramo»* (victoria del 6), *«Todo lo que estorbe se retira»* (entrada del 7) y *«Los muros son de otros; los usamos igual»* (victoria del 8) (`11-textos-lore.md`).

**Lo que ya se descartó y no hay que reabrir** (07 §9): la torre de asedio de largo alcance (por parecerse al Francotirador), el Aislador (por parecerse a la Disruptora), la Demoledora local con radio y los recursos persistentes. Además, §11 excluye las **habilidades activas del jugador** y los **laberintos**.

---

## 2. Parte A · Tres torres

### A1 · Puesto de banderín (id de trabajo `claim_post`)

**Qué es.** Un mástil con el banderín de la colonia sobre una base de obra. **No dispara.** Es una torre de apoyo, `support_only`, como el Estandarte mecánico. **Ojo con el nombre:** no puede llevar la palabra «Estandarte», porque ya es una torre (lo advirtió T438). Por eso «Puesto» o «Banderín».

**La decisión que agrega: dónde reclamar.** Una casilla despejada es valiosa: ahí se puede poner una torre que dispare. El Puesto ofrece otra cosa a cambio. Protege la **caja** (el oro) de los ladrones y paga un poco más por lo que se caza cerca. Hoy no hay ninguna respuesta a los robos que no sea «matarlos rápido», ni ninguna torre de economía.

**Interacción concreta.**
1. **Dónde se construye.** Hay dos variantes y la elige Lucas:
   - **A1-a, solo en casilla despejada por demolición.** Ata la torre a la Infraestructura, pero la hace imposible en los niveles 1 a 5 y en los mapas sin removibles.
   - **A1-b, en cualquier casilla construible**, con el efecto **reforzado** sobre una casilla despejada (por ejemplo, +0,5 de radio). Es más flexible pero suma una regla.
   - **Recomiendo A1-a:** es una sola regla y la frase se entiende sola, «se planta donde se despejó».
2. **Anti-robo.** Mientras un Ladrón, un Ratero o un Cargador está **dentro del radio**, su robo periódico (`gold_drain_*`) se **pausa**. Fuera del radio roba como siempre. No toca la vida ni la velocidad del ladrón: solo el robo. Es un estado más del enemigo, como la supresión de la Disruptora, y se dibuja con un ícono chico.
3. **Botín.** Cada enemigo que **muere dentro del radio** da +1, +2 o +3 de oro según el nivel del Puesto. El oro se suma al `reward` (normal 5, rápido 4, ratero 5). **No se acumula** con otro Puesto: vale el más alto, igual que el Estandarte (RF-369).
4. **Banderines.** El paño del mástil muestra la **receta del jugador** del editor de M74 (o la receta por omisión). Es solo dibujo: cualquier receta da los mismos números. En contextos sin campaña (comunidad, editor, modos) se ve la receta por omisión, que **no** es la enemiga: el Puesto es siempre de la colonia.

**Números iniciales (ORIENTATIVOS, sin medir):**

| Nivel | Costo | Radio | Botín por muerte en el radio |
|---|---|---|---|
| 1 | 70 | 2,0 | +1 |
| 2 | 60 | 2,5 | +2 |
| 3 | 90 | 3,0 | +3 |

*Cuenta de orden de magnitud, no medida:* si en un nivel mueren unos 80 enemigos dentro del radio, el nivel 1 devuelve unos 80 de oro en toda la partida, poco más que su costo. Es una inversión lenta y no un multiplicador. El valor real depende de dónde caiga la casilla despejada respecto del camino, y por eso la decisión pesa.

**Riesgo de volver obligatorios los recursos** (plan 08 §8, línea 284). **Bajo**, porque no cuesta recursos. Con A1-a necesita demoler, y `sin_recursos` no demuele, pero eso no rompe la regla de oro: el mapa se tiene que seguir ganando **sin** el Puesto. **El riesgo real es otro: que se vuelva obligatorio contra la Cuadrilla** (niveles 7, 10, 13 y 14). Si los robos se ajustaran contando con el Puesto, ganar sin él sería injusto. Hay dos cuidados: el bot tiene que ganar esos niveles sin Puesto, y el anti-robo **no anula** al ladrón, solo lo frena dentro de un círculo chico.

**Solapes con torres existentes** (`data/towers/*.tres`, solo leídos):
- **Estandarte mecánico** (`mechanical_standard`). También es `support_only` y tiene un radio de apoyo, pero el suyo es de **torres** (cadencia y reparación) y el del Puesto es de **enemigos** (robo) y de **economía**. No se pisan, pero hay dos apoyos en la barra y el jugador tiene que distinguirlos a simple vista: silueta de mástil contra estatua.
- **Disruptora.** Las dos «apagan» una habilidad enemiga. D-086 y el 07 §9 dicen expresamente que **no** se aprobó suprimir habilidades fuera de las auras. Apagar el robo es **una supresión nueva** y necesita su propia D.
- **El poste de cintas del nivel 6.** Es decoración y es una señal de los Moradores. El Puesto no se puede confundir con él (regla 2 de las señales, §6): necesita la base de torre y la marca de nivel.

**Lectura de tono.** Plantar el banderín propio donde se despejó algo **es** el canon de §1.4, mostrado. **Riesgo:** si el Puesto se puede plantar sobre la casilla de una **ruina con el símbolo A**, la imagen (nuestro banderín donde estaba su marca) es muy fuerte y puede sentirse **subrayada**, contra «el juego lo muestra y no lo comenta». Lo dejo como pregunta (P-A3).

**Costo.**
- **Código M:**
  - una regla nueva de construcción («solo sobre una casilla despejada»), con su consulta al estado de `InfrastructureController`;
  - una supresión del robo en `Enemy._update_gold_drain`, siguiendo el patrón de `suppress()`;
  - el botín por muerte dentro del radio;
  - dos campos nuevos en `TowerLevelData`;
  - la Wiki, el panel, los tests y una estrategia del bot.
- **Arte M:** el atlas de 3 niveles (base, evolución 2 y 3), el ícono y el estado «robo frenado» en el enemigo. El paño se compone en tiempo de juego con las piezas del catálogo de M74, y hay que comprobar que se lea a 34 px.

**¿V1?** **No, va a futuro.** Exige balancear los cuatro niveles con la Cuadrilla, que ya están cerrados o en compuerta (T266 y T280), y una D nueva de supresión.

---

### A2 · Honda de escombros (id de trabajo `sling`)

**Qué es.** Una cabria o un brazo de palanca de **forja** (familia A, hierro y madera) que **usa un obstáculo vecino como munición**: arroja la roca, el tronco o los bloques del escombro.

**La decisión que agrega: qué hacer con un obstáculo.** Hoy un removible tiene dos destinos, demolerlo o dejarlo. La Honda agrega un tercero: **gastarlo como munición**. Es gratis, pero se agota y **no entrega recurso**. Demoler cuesta oro y tiempo, abre la casilla y quizá da un recurso.

**Interacción concreta.**
1. Se construye en una casilla construible **pegada** (4 vecinos) a uno o más removibles **intactos**.
2. Cada removible vecino aporta una **reserva de tiros**. Cuando la reserva de ese obstáculo se agota, el obstáculo queda **despejado** (pasto construible) y **no entrega** recursos ni pieza.
3. **Lo que no es munición:**
   - un **escombro con pieza pendiente** (si no, se perdería la pieza de la Disruptora, RF-426 a RF-428);
   - un removible con un **trabajo de demolición en curso**;
   - **minas y bosques**, que no son removibles (RF-400).
4. **El disparo.** Es un golpe pesado a **un** objetivo **terrestre**, con **retroceso**: empuja al enemigo una distancia corta hacia atrás sobre su camino. **Hoy nada en el juego hace retroceder.** El Jefe, el Coloso y sus Pedazos, el Tanque y el Guardián **no retroceden**, por tamaño.
5. **Sin munición** dispara piedras chicas, con daño muy bajo: la torre no queda muerta del todo y se puede vender.

**Números iniciales (ORIENTATIVOS, sin medir):**

| | Nivel 1 | Nivel 2 | Nivel 3 |
|---|---|---|---|
| Costo | 60 | 70 | 110 |
| Daño (con munición) | 25 | 38 | 55 |
| Cadencia | 0,5/s | 0,5/s | 0,55/s |
| Alcance | 3,0 | 3,0 | 3,5 |
| Retroceso | 0,4 casillas | 0,5 | 0,6 |
| Daño sin munición | 3 | 4 | 5 |

Reserva por obstáculo: árbol 10 tiros, roca 15 y escombro 20. Es barata **porque la munición sale del mapa**.

**Riesgo de volver obligatorios los recursos.** **Bajo a medio.** No cuesta recursos y no los produce, pero **compite** con la demolición: cada obstáculo gastado como munición es un recurso que no se juntó. En un mapa donde el Mortero necesita los 3 escombros del 9 (que dan 100 %, RF-420 enmendado por M61), la Honda empuja al jugador a elegir entre una y otro. Eso es justamente la decisión, pero hay que vigilar que no deje **sin** recursos a quien ya se los gastó. **Un segundo riesgo es de economía:** despejar casillas **gratis** le resta sentido a la **Demoledora** del 7, y conviene no ofrecer las dos en el mismo mapa.

**Solapes.**
- **Cañón y Mortero:** también son golpes pesados, terrestres y de forja. La Honda se distingue por **la munición finita y local** y por el **retroceso**, no por el daño.
- **Hielo:** también controla el avance. Frenar no es lo mismo que hacer retroceder, pero los dos «ganan tiempo», y el combo `bonus_vs_slowed` del Cañón, el Francotirador y el Mortero podría duplicarse si el retroceso se combinara. **Recomiendo que no active combos.**
- **Embestidor:** carga después de 3 casillas rectas. Un retroceso le puede «regalar» otra recta para cargar de nuevo. Es un caso a resolver en la spec (propuesta: el retroceso **reinicia** la cuenta de rectas sin habilitar la carga).

**Lectura de tono.** Arrojar las piedras de las **ruinas con el símbolo A** contra los **Guardianes** es la misma ironía de la Disruptora, pero hecha **acto físico** y repetida en cada tiro. Es más explícita y puede caer en lo subrayado. Hay dos salidas: excluir los escombros (solo árbol y roca) o aceptarlo sin comentarlo en ningún texto. Lo dejo como pregunta (P-A4).

**Costo.**
- **Código L:**
  - **el retroceso**, que mueve `distance` sobre el `Path2D` (`scenes/enemies/enemy.gd`) y afecta el apuntado por `remaining_distance()`, la carga del Embestidor, el bot y las pruebas de P7;
  - la **adyacencia** y el **consumo** de removibles, que piden una API nueva en `InfrastructureController`, con el cuidado de la pieza pendiente;
  - el estado «sin munición» en el panel.
- **Arte M-L:** el atlas de 3 niveles, **tres proyectiles** (tronco, roca y bloque), el desgaste visible del obstáculo vecino a medida que se gasta y el estado «sin munición».

**¿V1?** **No, va a futuro.** Es la que más código nuevo pide y la que más se cruza con sistemas ya balanceados.

---

### A3 · Cohetera (id de trabajo `rocket_rack`): el lanzamisiles del 07 §9

**Qué es.** El candidato que **propuso Lucas** en el 07 §9: un ataque que alcanza a los enemigos de un **tramo de camino**, con **cargas** limitadas. Acá lo ato a los recursos de forma **opcional**. Es de la familia industrial: cohetes de obra, no misiles guiados, para no salir de «hierro, bronce, cristal y mecanismos» (§9).

**La decisión que agrega: gastar o guardar un recurso.** Hoy un recurso se usa **una vez, al construir** (Mortero, Disruptora o Francotirador alternativo). La Cohetera le da un **segundo uso, chico y en el momento**: pagar 1 recurso para recargar una salva justo antes del pico de una oleada, contra guardarlo para un Mortero.

**Interacción concreta.**
1. **Salva automática.** No la apunta el jugador: así no se vuelve una «habilidad activa», que §11 excluye. Cuando está lista, elige el **tramo de 3 casillas de camino** que tiene más enemigos dentro de su alcance y golpea a todos los que están **en ese tramo**. Responde la pregunta del 07: es un **tramo de camino**, no un radio alrededor del impacto, y eso la separa del círculo del Mortero.
2. **Cargas.** Tiene un máximo de 2. Las recupera de dos maneras:
   - **gratis**, 1 carga por **oleada completada** (el mismo reloj que la extracción, RF-423);
   - **pagando 1 recurso**, desde el panel de la torre: recarga 1 carga al instante.
3. **Sin recursos, la Cohetera sigue sirviendo**: dispara 1 o 2 salvas por oleada. Los recursos **aceleran**, no **habilitan**.
4. **Banderines.** El tramo elegido se marca un instante con banderines chicos (la receta del jugador o la de por omisión) antes del impacto. Es un aviso visual y no cambia ningún número.

**Números iniciales (ORIENTATIVOS, sin medir):**

| | Nivel 1 | Nivel 2 | Nivel 3 |
|---|---|---|---|
| Costo | 160 | 140 | 200 |
| Daño por salva (a cada uno en el tramo) | 45 | 70 | 100 |
| Cargas máximas | 2 | 2 | 3 |
| Espera entre salvas con carga | 3 s | 3 s | 2,5 s |
| Alcance | 4,0 | 4,0 | 4,5 |
| Recarga pagada | 1 recurso | 1 recurso | 1 recurso |

No le pega a los voladores (es fuego de suelo) y no activa combos.

**Riesgo de volver obligatorios los recursos.** **Medio, el más alto de las tres.**
- Le da a los recursos un **sumidero nuevo**: hoy, los recursos que sobran se pierden.
- **Riesgo:** si «Cohetera + mina activa» resulta ser la mejor respuesta a las escoltas coordinadas del 13 al 15, los recursos pasan a ser **de hecho** necesarios para jugar bien, aunque `sin_recursos` siga ganando.
- **Cuidados:**
  - la recarga gratis por oleada tiene que hacer a la Cohetera **útil por sí sola**;
  - el bot tiene que comparar `sin_recursos` con y sin la Cohetera;
  - hay que fijar un **tope** de recargas pagadas por oleada (propuesta: 1), para que una mina llena no se convierta en una ametralladora de salvas.
- No crea recursos de la nada ni por esperar (RF-433 sigue valiendo).

**Solapes.**
- **Mortero:** también es área, largo alcance y lento, y ya cuesta recursos. La diferencia es la **forma** (tramo contra círculo) y el **ritmo** (salvas con cargas contra un tiro cada 4 s). Si en las pruebas se sienten iguales, hay que descartar la Cohetera, no forzarla.
- **Ráfaga:** rinde en curvas. La Cohetera rinde en **rectas largas y llenas**.
- **Francotirador:** el alcance de 4 a 4,5 se queda **lejos** de su 6 a 7, para no repetir la torre de asedio que Lucas descartó.

**Lectura de tono.** Es neutra: una herramienta de obra usada como artillería. No toca el símbolo A ni las ruinas.

**Costo.**
- **Código M-L:**
  - elegir el tramo sobre la ruta (con varias entradas, el tramo puede caer en cualquiera de las rutas que pasan por el alcance);
  - las cargas y su recarga por `wave_completed`;
  - la recarga pagada en el panel de desktop **y** en la barra de la torre de mobile (D-097);
  - el bot y P7 con salvas simultáneas.
- **Arte M:** el atlas de 3 niveles, el cohete y el humo. La explosión puede salir de la del Mortero. Las marcas de banderín del tramo se reutilizan del catálogo de M74.

**¿V1?** **No, va a futuro.** De las tres es la que **Lucas ya había pedido explorar**, así que es la primera candidata si quiere una torre nueva después de la V1.

---

### 2.4 Lo que vale para las tres

- **La barra se llena.** Hoy hay 11 torres y del 11 al 15 se ofrecen 10. Sumar 3 lleva a 14 y pasa los atajos 1 a 0. Cualquier torre nueva necesita decidir **en qué niveles aparece** con el campo `"torres"` (RF-393), no sumarse a todos.
- **El bot primero.** Cada una necesita una estrategia en `balance_sim` antes de tocar un nivel, y la regla de oro se vuelve a correr en los mapas que la ofrezcan.
- **La spec de §11.** Ninguna es una habilidad activa apuntada. La recarga pagada de A3 es una **compra** desde el panel, como mejorar. Si Lucas la ve como una habilidad activa, A3 se queda sin recarga pagada (solo la gratis) y pierde su relación con los recursos.
- **Lo que no hice:** no corrí el bot, no medí ningún número, no abrí el juego y no dibujé muestras. Los costos (S/M/L) son estimaciones de lectura de código, no de una implementación.

---

## 3. Parte B · ¿Tiene consecuencias demoler, arrasar el planeta?

### 3.1 Qué cuenta ya el juego sin agregar nada

La pregunta de Lucas tiene una parte de respuesta **ya escrita y aprobada**:
- **En los textos:** *«Se taló el primer tramo. La madera alcanza para dos casas.»* (6), *«Todo lo que estorbe se retira.»* (7), *«Los muros son de otros; los usamos igual.»* (8). Son consecuencias dichas como informe, sin juicio: exactamente lo que pide §8.2.
- **En el mapa:** el poste del 6 cambia **sus** cintas por **las nuestras** al ganar (D-181). La señal de los Moradores (§6, nivel 4) se reemplaza por la marca de la colonia.
- **En el arco:** del 11 al 15, hitos de límite, campamentos vacíos con *«brasas todavía tibias»* y, en el final, las comunidades **retirándose** (§7). El costo de ocupar está en toda la campaña, no en un botón.

Lo que **no** tiene consecuencia hoy es el **acto de demoler**: un árbol, una roca y un muro marcado se retiran igual, con la misma barra y el mismo «+1 recurso». En el juego, la ruina con el símbolo A es un yacimiento más (§5: *«la colonia las trata como un yacimiento»*). Eso **también** es una lectura, y hasta es coherente con la voz de los colonos.

### 3.2 Tres alternativas

#### N-A · Sin consecuencia propia (dejar todo como está)
- **Qué es:** no se agrega nada. La demolición sigue siendo una decisión de inversión (07 §5) y el tono lo llevan los textos y el arco.
- **Riesgo de tono:** **ninguno nuevo**. Lo que se pierde es la oportunidad: la intuición de Lucas («arrasar el planeta tiene un impacto») no queda dicha en el lugar exacto donde el jugador arrasa.
- **Riesgo de balance:** ninguno.
- **Costo:** cero.

#### N-B · Lectura en el texto y en el mapa (sin efecto en las reglas)
Hay cuatro piezas independientes, que se pueden tomar por separado:
1. **Huella en el mapa.** Lo despejado no queda como pasto limpio:
   - un árbol deja un **tocón** bajo;
   - un escombro deja una **losa a ras del suelo con un trazo del símbolo A** partido.
   - Se puede construir encima como sobre pasto (no cambia RF-400). Es lo más fiel a «mostrar antes que explicar».
   - **Riesgo:** la regla 2 de las señales (no confundir con lo jugable). La huella no puede parecer un removible ni una casilla bloqueada: tiene que ser plana y sin cinta ámbar.
   - **Arte:** S-M, entre 2 y 3 calcomanías.
2. **Artículo de Lore** (Wiki, estilo de `11-textos-lore.md`), que se abre al ganar el 10 (*La mina vieja*, donde la colonia retoma galerías ajenas). **Ilustración de tono, no texto final:**
   > *Cada obra empieza despejando. Los troncos se anotan por carga. Las piedras marcadas figuran en el registro como «escombro».*

   Muestra una consecuencia (lo marcado pierde su nombre en el papel) y no dice si estuvo bien.
   - **Riesgo de tono:** bajo, si se queda en el dato.
   - **Costo:** S, pero necesita pasar por `11-textos-lore.md` y el OK de Lucas, porque esos textos están aprobados y son el único lugar donde se escriben.
3. **Parte de obra en el resultado.** Si se demolió algo, el resumen de la partida suma un dato seco: *«Obra: 3 árboles y 1 muro marcado retirados.»*
   - Solo cuenta lo de **esa** partida: no se guarda y no da puntaje (como los recursos, RF-415).
   - **Riesgo de tono: medio.** Un contador puede leerse como «medidor moral» si alguna vez se acompaña de un adjetivo o de un color rojo. Tiene que ser un dato, con la misma tipografía que el resto.
   - **Ojo:** la **victoria** tiene un tope de 2 líneas (§8.4), así que esto va en el **resumen**, no en el texto de victoria.
4. **Un recuento de toda la campaña que cambie el epílogo.** Lo **descarto**:
   - pide un campo nuevo en el guardado;
   - convierte la campaña en un medidor moral;
   - el epílogo está aprobado y su regla es *«no dice si valió la pena»*. Una versión «buena» y otra «mala» es justo eso.

- **Riesgo de balance:** ninguno; no toca reglas.

#### N-C · Mecánica leve
- **Qué es (la versión más chica y más diegética que encontré):** desde el nivel 11, donde debuta el Chamán, **el aturdimiento del Chamán prefiere las torres construidas sobre casillas de ruinas demolidas** en esa partida, en lugar de la más cercana. Es canon que el Chamán *«frena la infraestructura de la colonia»* (§4.3). No suma enemigos ni quita oro.
- **Otras versiones, peores:** una oleada con más Guardianes por cada ruina demolida o una multa de oro. Castigan más y se explican peor.
- **Riesgos de tono, altos:**
  - un sistema que **responde** a demoler es un juicio mecánico («demoler está mal, te castigo») y choca con §8.1 (sin ganador moral) y con §8.2 (consecuencias, no sentencias);
  - convierte a los Moradores en **vengadores**, un paso hacia la caricatura (§8.3);
  - si no se comunica, el castigo es injusto. Si se comunica («los Moradores lo notarán»), es una sentencia escrita.
- **Riesgos de balance, altos:**
  - **desalienta** demoler, que el 07 §5 quiere como inversión;
  - cambia el balance del 11 al 15, ya medido;
  - pide una estrategia nueva del bot.
  - No rompe la regla de oro (`sin_recursos` no demuele), pero la **invierte**: pasa a ser la estrategia «segura».
- **Dónde sí tiene sentido:** en la semilla **«elegir bando»** o **«sumarse a los rebeldes»** (§9). Ahí, que los Moradores reaccionen a lo que hace la colonia es el corazón del juego, no un castigo escondido. Conviene **anotarla ahí** y no en la V1.

### 3.3 Cómo se cruzan A y B

- **A1 (Puesto) + N-B (huella):** el banderín de la colonia plantado sobre la losa con el símbolo partido. Es la imagen más fuerte de todo el informe, y por eso la más peligrosa de subrayar. Si las dos llegan a existir, conviene probarlas **juntas** frente a Lucas antes de decidir.
- **A2 (Honda) + N-B:** gastar un escombro como munición tendría que dejar la **misma** huella que demolerlo. Si no, la Honda sería una forma de «arrasar sin dejar rastro».
- **N-C** y **A1** **no** deberían convivir: un Puesto que el Chamán busca a propósito sería un castigo por usar la torre.

---

## 4. Recomendación

1. **Nada de esto entra en la V1.** El plan vigente (08 y la auditoría T444) cierra con compuertas de Lucas sobre niveles ya balanceados, y las tres torres y N-B/N-C tocan esos niveles o sus textos.
2. **Torres para después de la V1:** primero **A3 Cohetera**, porque Lucas ya la quería, se distingue del Mortero si el tramo se siente distinto, y los recursos aceleran sin habilitar. O **A1 Puesto de banderín**, si se quiere la torre más barata en código y la que mejor cuenta el canon. **A2 Honda**, solo si después de las otras sigue sobrando ganas de un sistema nuevo (el retroceso).
3. **Demolición:** **N-B**, empezando por la **huella en el mapa** y el **artículo de Lore**, que son las piezas más baratas y las más fieles al «mostrar, no explicar». El parte de obra (N-B.3), solo si Lucas lo quiere y como dato seco. **N-C** se anota como semilla de «elegir bando».
4. **Dos principios para cualquier versión futura** (son el núcleo de las decisiones de abajo): la receta de banderines **nunca** cambia un número; y la demolición **no** tiene consecuencias mecánicas fuera de las que ya dice M50.

### Decisiones propuestas · PENDIENTE DE LUCAS (sin número; las numera la tarea 📜 que las registre)

**D-(a definir) · Las torres que usen banderines no leen la receta para ningún número.**
- **Qué:** una torre puede dibujar la receta del jugador (o la de por omisión), pero sus reglas son iguales con cualquier receta, sin archivo o con el archivo dañado. La facción enemiga nunca se usa en una torre del jugador.
- **Por qué:** mantiene D-185 y D-186 (lo cosmético queda aislado del progreso y del balance) y evita que un archivo de preferencias cambie una partida.
- **Alternativas:** (1) receta con efecto, por ejemplo un emblema que dé +1 de radio. **Descartada:** sería meta-progresión, que §11 excluye, y obligaría a validar el archivo como dato de balance. (2) Que las torres no muestren banderines. Es válida, pero pierde el vínculo que pidió Lucas.
- **Recomendación:** la propuesta.

**D-(a definir) · La demolición no tiene consecuencias mecánicas narrativas; si las tiene, son de lectura.**
- **Qué:** demoler sigue regido solo por M50. Cualquier consecuencia narrativa de demoler es de texto o de dibujo (N-B), sin efecto en el oro, los enemigos ni el puntaje.
- **Por qué:** §8.1 y §8.2 del canon; el 07 §5 (la demolición es inversión); la regla de oro.
- **Alternativas:** N-A (no agregar nada, también compatible con esta D); N-C (mecánica leve, pasada a la semilla «elegir bando»).
- **Recomendación:** la propuesta, con N-B después de la V1.

**D-(a definir), solo si se hace A1 · Suprimir el robo es una supresión nueva y aparte de la Disruptora.** Hace falta porque D-086 y el 07 §9 aprobaron suprimir **solo auras**.

---

## 5. Preguntas para Lucas

1. **P-A1.** ¿Querés una torre nueva **después** de la V1? Si sí, ¿cuál primero: la **Cohetera** (tu lanzamisiles), el **Puesto de banderín** o la **Honda**? ¿O ninguna de estas tres?
2. **P-A2.** Para la Cohetera: ¿la recarga pagando 1 recurso desde el panel te parece una compra (como mejorar) o una «habilidad activa» de las que §11 excluye?
3. **P-A3.** Para el Puesto: ¿solo sobre una casilla despejada (A1-a) o en cualquier lado con un bonus sobre lo despejado (A1-b)? ¿Se puede plantar donde estaba una **ruina con el símbolo A**?
4. **P-A4.** Para la Honda: ¿pueden servir de munición los **escombros de las ruinas** o solo árboles y rocas?
5. **P-A5.** ¿Está bien el principio de que **la receta de banderines nunca cambia un número**?
6. **P-B1.** Demolición: ¿**N-A** (nada), **N-B** (huella y texto) o **N-C** (mecánica leve)? Si es N-B, ¿cuáles de sus piezas: huella, artículo de Lore, parte de obra en el resumen?
7. **P-B2.** ¿Anotamos «los Moradores reaccionan a lo que demuele la colonia» como **semilla** de «elegir bando» en `10-universo.md` §9? Es una tarea 📜 aparte, porque el canon lo edita solo quien vos digas.
8. **P-B3.** El texto del artículo de Lore de 3.2 es una ilustración de tono. ¿Querés que una tarea lo proponga formalmente en `11-textos-lore.md`?

---

## 6. Qué se hizo y qué no

**Leído:**
- `CLAUDE.md`, `specs/00-constitucion.md` y la matriz del 2026-10-23.
- `01-spec.md`: M50 (RF-398 a RF-434), M73 y M74 (RF-655 a RF-665), §11, y M40 y M51 en lo que toca al desgaste y a la Disruptora.
- `04-decisiones.md`: D-083 a D-086 y D-181 a D-186.
- `07` §5 y §9, `08` §7 y §8, `10-universo.md` completo, `11-textos-lore.md` (niveles 6 a 9 y la tabla de Lore) y el informe T438.
- `data/towers/*.tres`, `data/obstaculos.json`, `data/levels/level_06…15.json` (leyenda y campos), `data/enemies/*.tres` (recompensas y robo) y, solo para estimar costos, `scripts/data/tower_data.gd`, `tower_level_data.gd`, `enemy_data.gd`, `scenes/enemies/enemy.gd` y `scenes/game/infrastructure_controller.gd`.

**No hice:**
- No corrí Godot, GUT ni el bot. **Ningún número está medido.**
- No hice muestras de arte ni maquetas.
- No modifiqué código, datos, spec, decisiones, tareas ni canon. El único archivo nuevo es este informe.
- No comprobé si los nombres de trabajo (Puesto, Honda, Cohetera) chocan con otros textos del juego, salvo «Estandarte», que ya está tomado.
