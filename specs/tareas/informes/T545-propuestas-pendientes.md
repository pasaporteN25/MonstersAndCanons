# T545 · Propuestas pendientes de aprobación de Lucas (2026-10-29)

**Qué es este archivo.** T558 aplicó al juego las decisiones cerradas de `T545-decisiones-hallazgos.md`. Lo que sigue **no se cargó**: son los tres puntos que Lucas dejó para aprobar el texto antes (H1-B, H8, H12). Cada pieza trae el texto actual, de 2 a 3 opciones numeradas y la que recomiendo. Cuando Lucas elija, el texto se escribe primero en `specs/11-textos-lore.md` (o en `specs/intro/guion.md` para la lámina 4) y recién después se copia a `data/`.

**Límites que valen para todo lo que sigue** (RF-464): lugar 32 caracteres; entrada 3 líneas y 240 en total; victoria 2 líneas y 160 en total; ninguna línea pasa de 90. Vocabulario: nada de «enemigo», «peligro», «bestia», «salvaje», «invasor», «nativo», «alien», «monstruo», «malvado», «héroe».

---

## H1-B · El agua del oasis frente al nivel 2

**Decisión de Lucas:** no tocar el nivel 2; suavizar la lámina 4 de la intro y el artículo «El oasis» para que no digan que el oasis es el único lugar con agua, y revisar el «Hay agua» del nivel 1. **La lámina 4 hay que re-aprobarla con Lucas.**

La idea de fondo de las tres piezas: el oasis tiene **un poco de agua** (como ya dice el artículo «Cántaro»: «un poco de agua guardada en una tierra seca»), suficiente para aterrizar pero no para una colonia. Así el nivel 2 («El agua dulce más cercana está al otro lado del desfiladero») y el nivel 4 («El arroyo no alcanza para toda la colonia») son una continuación y no una contradicción.

### 1. Lámina 4 de la intro (`data/intro/intro.json`, `specs/intro/guion.md`)

**Texto actual** (2 líneas, ilustración «la ventana»):
> El reconocimiento vio agua en un solo lugar de todo el planeta.
> Hacia ahí apuntó la nave.

- **Opción 1 (la que recomiendo):**
  > El reconocimiento vio agua a la vista en un valle.
  > Hacia ahí apuntó la nave.

  Dice lo que se vio desde arriba (agua a la vista) y no que no haya otra. Un arroyo tras un desfiladero puede no verse desde la órbita.
- **Opción 2:**
  > De todo lo que miró el reconocimiento, un valle tenía agua dulce.
  > Hacia ahí apuntó la nave.

  Más cercana al texto actual; sigue sonando a «el único», aunque limitado a lo que se miró.
- **Opción 3:**
  > El reconocimiento encontró un valle con agua dulce.
  > Hacia ahí apuntó la nave.

  La más neutra: no compara con nada.

### 2. Artículo «El oasis», párrafo 1 (`data/wiki/lore/el_oasis.json`)

**Texto actual:**
> El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista que encontró el reconocimiento, y por eso la nave bajó acá.

- **Opción 1 (recomiendo):**
  > El oasis es un valle chico con un poco de agua dulce, pasto y flores, rodeado de tierra seca. Es el primer sitio con agua que encontró el reconocimiento, y por eso la nave bajó acá.
- **Opción 2:**
  > El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Era el sitio con agua más claro que vio el reconocimiento desde arriba, y por eso la nave bajó acá.
- **Opción 3 (mínima, solo cambia una palabra):**
  > …Es el único sitio con agua **fácil de ver** que encontró el reconocimiento…

  Nota: el párrafo 3 («Los registros de la Compañía lo llaman “el único lugar seguro”») no habla de agua y no hace falta tocarlo.

### 3. Nivel 1, entrada, línea 2 (`data/levels/level_01.json`)

**Texto actual:**
> La nave quedó en el borde del oasis.
> **Hay agua, pasto y un terreno firme donde armar el campamento.**
> Antes de descargar, hay que defenderlo.

- **Opción 1 (recomiendo):** «Hay algo de agua, pasto y un terreno firme donde armar el campamento.»
- **Opción 2:** «Hay un manantial chico, pasto y un terreno firme donde armar el campamento.» (nombra de dónde sale el agua; hay que cuidar que el nivel 4 diga «arroyo»).
- **Opción 3:** dejarlo como está. Con las opciones 1 de la lámina y del artículo, «Hay agua» ya no choca con el nivel 2, porque el nivel 2 habla del agua que falta para la colonia entera.

Nota: la victoria del 1 («La carga de la nave se baja esta noche») y la del 2 («El agua llega al campamento por primera vez») no cambian.

---

## H8 · «El Jefe» en el juego frente a «El Soberano» en el artículo

**Lo que dijo Lucas:** en el juego es «el Jefe». El artículo debe aclarar que los colonos **oyeron hablar a los monstruos de un «Soberano»**, y que nadie sabía si existía hasta el final.

**Texto actual** del artículo «El Soberano» (`data/wiki/lore/el_soberano.json`, se abre al ganar el nivel 4):
> 1. Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le dicen Soberano.
> 2. No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.

**Cuidados.** (a) El juego lo llama «Jefe» en la presentación («¡Llega el Jefe!»), el bestiario y los consejos. (b) La biblia (`10-universo.md` §8) prohíbe «monstruo»; el canon usa «criaturas» y «manadas». Por eso las opciones dicen «las criaturas de las manadas» y no «monstruos»; si Lucas prefiere su palabra, es un cambio de una palabra. (c) El artículo se abre en el nivel 4 y el «hasta el final» tiene que dejar la duda abierta sin adelantar nada del 15. (d) Un detalle de coherencia: el párrafo 2 dice que hay «uno por cada paraje», así que «Soberano» como un único gobernante convive mal con eso; las opciones 1 y 2 lo resuelven.

- **Opción 1 (recomiendo):** reescribir el párrafo 1 y dejar el 2.
  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Los partes del campamento lo anotan como «el Jefe» de la oleada. Las manadas parecen seguirlo, o dejarle paso.
  >
  > Los colonos oyeron a las criaturas de las manadas hablar de un «Soberano», y nadie sabe si es este mismo animal o alguien más. No es uno solo: hay uno por cada paraje. Nadie sabe si manda o si solo va adelante.

- **Opción 2 (más corta, solo suma una frase en el párrafo 1):**
  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Los partes lo anotan como «el Jefe»; los colonos oyeron a las criaturas de las manadas nombrar a un «Soberano» y no saben si es él. Las manadas parecen seguirlo, o dejarle paso.
  > (párrafo 2 sin cambios)

- **Opción 3 (con la palabra de Lucas, «monstruos»; requiere que Lucas acepte la excepción al vocabulario de la biblia):**
  > …Los partes lo anotan como «el Jefe». Los colonos oyeron a los monstruos hablar de un «Soberano», y hasta el final nadie supo si existía de verdad.

  Esta es la más fiel a lo que pidió, pero «hasta el final nadie supo si existía» **adelanta** el desenlace en un artículo que se abre en el 4 (la regla del documento es que un artículo no anticipe lo que el jugador todavía no vio) y obliga a mover el artículo para que se abra más tarde, o a dejar la frase solo como «nadie sabe si existe».

---

## H12 · Repeticiones entre campos del mismo nivel y apertura «X asegurado/a»

**Lo que dijo Lucas:** quitar el lugar repetido tal cual en 2, 10, 12 y 15, y reescribir la apertura de las nueve victorias que empiezan con «X asegurado/a» (1, 2, 3, 6, 8, 9, 10, 12, 13).

### A. Lugares repetidos

| Nivel | Qué se repite hoy | Opción 1 (recomiendo) | Opción 2 |
|---|---|---|---|
| 2 | Lugar «El paso del agua» y la victoria «Paso asegurado» | Cambiar la victoria (ver B) y dejar el lugar | Lugar «El desfiladero»: repite el nombre del nivel (H6), no la recomiendo |
| 10 | El lugar «Primer puesto de abastecimiento» aparece tal cual en la victoria («…es el primer puesto de abastecimiento de la colonia») | Cambiar la victoria (ver B) | Lugar «El primer puesto» (16 caracteres) |
| 12 | Lugar «El paso hacia el norte» y la entrada «El único paso hacia el norte…» | Entrada línea 1: «La única salida al norte es un cañadón de paredes altas.» | Lugar «La salida al norte» (18) |
| 15 | Lugar «Energía y abastecimiento» y la victoria «La línea de abastecimiento…» | Lugar «La Central y la línea» (20), la victoria queda | Lugar «Luz para la colonia» (19) |

### B. Victorias que abren con «X asegurado/a»

Hoy, con lo aplicado por T558 (11 y 15 ya cambiaron y no abren con la fórmula). Cada opción respeta 2 líneas, 160 caracteres en total y 90 por línea. **Opción 1** = la recomendada (cambia el verbo y deja la fórmula en las que más la merecen: 1, 8 y 12); **Opción 2** = ninguna victoria abre con «asegurado/a».

| Nivel | Texto actual | Opción 1 | Opción 2 |
|---|---|---|---|
| 1 | «Campamento asegurado. Las primeras torres quedaron en pie.» / «La carga de la nave se baja esta noche.» | *Sin cambios (es la primera vez que se usa la fórmula).* | «Las primeras torres quedaron en pie y el campamento es nuestro.» / «La carga de la nave se baja esta noche.» |
| 2 | «Paso asegurado. El agua llega al campamento por primera vez.» / «Faltan tres tramos de cañería.» | «El paso quedó abierto: el agua llega al campamento por primera vez.» / «Faltan tres tramos de cañería.» | «Por el desfiladero baja el agua: llega al campamento por primera vez.» / «Faltan tres tramos de cañería.» |
| 3 | «Huertas aseguradas. Se sembró el primer surco.» / «Lo que crezca depende de que las torres aguanten.» | «Se sembró el primer surco de las huertas.» / «Lo que crezca depende de que las torres aguanten.» | «El primer surco ya está sembrado.» / «Lo que crezca depende de que las torres aguanten.» |
| 6 | «Lindero asegurado. Se taló el primer tramo.» / «La madera alcanza para dos casas.» | «Se taló el primer tramo del lindero.» / «La madera alcanza para dos casas.» | «El lindero quedó despejado: se taló el primer tramo.» / «La madera alcanza para dos casas.» |
| 8 | «Bastión asegurado. La colonia tiene una posición alta sobre la loma.» / «Los muros son de otros; los usamos igual.» | *Sin cambios (es la revelación de la marca; la fórmula acompaña).* | «La colonia tiene una posición alta sobre la loma.» / «Los muros son de otros; los usamos igual.» |
| 9 | «Taller asegurado. El horno se encendió por primera vez fuera del oasis.» / «La forja ya no depende de lo que trajo la nave.» | «El horno se encendió por primera vez fuera del oasis.» / «La forja ya no depende de lo que trajo la nave.» | «Se encendió el horno del taller, el primero fuera del oasis.» / «La forja ya no depende de lo que trajo la nave.» |
| 10 | «Mina asegurada. Es el primer puesto de abastecimiento de la colonia.» / «Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.» | «La mina ya es de la colonia: el primer puesto fuera del campamento.» / «Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.» | «Las galerías quedaron en manos de la colonia.» / «No las cavamos nosotros, y nadie vino a reclamarlas.» |
| 12 | «Cañadón asegurado. El paso al norte quedó abierto.» / «En las paredes quedaron las marcas de los tiros que volvieron.» | *Sin cambios.* | «El cañadón quedó atrás y el camino al norte está abierto.» / «En las paredes quedaron las marcas de los tiros que volvieron.» |
| 13 | «Paso alto asegurado. La región queda comunicada con el valle de más al este.» / «Las rocas marcadas quedaron del lado de adentro.» | «La región queda comunicada con el valle de más al este.» / «Las rocas marcadas quedaron del lado de adentro.» | «El paso alto quedó cerrado detrás de nosotros: la región se comunica con el valle de más al este.» / «Las rocas marcadas quedaron del lado de adentro.» *(pasa de 90 caracteres en la línea 1: acortar si se elige)* |

Con la Opción 1 quedan **3** victorias con la fórmula (1, 8, 12), contra las 9 de antes (la 11 y la 15 ya no la tienen). Con la Opción 2, ninguna.

- **Opción 3:** no tocar las victorias y dejar la fórmula como marca de la voz de informe de la Compañía (la biblia la usa de ejemplo de tono). Es lo más barato y lo que menos cambia el texto aprobado.

### Qué hace falta de Lucas
Una letra por cada bloque (A: opción por nivel; B: columna 1, 2 o 3) y, si quiere su propia redacción, la frase exacta. Después se actualiza `11-textos-lore.md`, los JSON de `data/levels/` (y los hashes de los tests) y se carga en una tarea aparte.
