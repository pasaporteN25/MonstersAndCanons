# 11 — Textos del lore dentro del juego

> **Estado: APROBADO por Lucas (2026-10-09).** Escrito el 2026-10-08 por Claude (Sonnet 5.5), tarea **T227**. Nada de lo que está acá se cargó en el juego: lo carga **T228** (niveles 1 a 10, Wiki Lore y pantallas) y, para el 11 al 15, las tareas de cada nivel, **solo después de que Lucas diga que sí**.
>
> **OK de Lucas:** dado el 2026-10-09 («todas ✔», P1 a P8 de M52). Lo marcado «A REVISAR TRAS G4» en las fichas se confirma al cerrar su partida del 6 al 10.
>
> **Agregado por T243 (2026-10-09):** el artículo 10, «La Central», suma **un párrafo sobre el Coloso**, el jefe supremo que eligió Lucas. Es el texto de tono del informe de T243, que no cambia ningún otro texto de este documento. **Lucas todavía no lo leyó en su lugar**: si le parece mal, se corrige acá y se copia al artículo de la Wiki Lore. Dice «tres» porque el Coloso suelta tres Pedazos (RF-481): **si el balance cambia ese número, se corrige también acá.**

> **Agregado por T252 (2026-10-10):** el artículo **11, «La Cuadrilla»** (§4.11), sobre la banda de Rateros y Cargador que Lucas eligió para la V1 (M55, RF-489, D-094). **Es un borrador que Lucas todavía no leyó** y **no se carga en el juego** hasta que diga que sí (P3 de M55). No cambia ningún otro texto de este documento: en particular, el artículo 5 sigue diciendo que el Ladrón va solo.

**Qué es este documento.** Los textos finales que muestra el juego (M52, `01-spec.md`): el **lugar**, la **entrada** y la **victoria** de los 15 niveles, el **epílogo**, los **créditos** y **10 artículos** de la categoría Lore de la Wiki (más el borrador del 11, T252). Es el **único lugar** donde viven los textos: la ficha de cada nivel (§7.13 a §7.17 de la spec) y las tareas T228 a T234 los **copian tal cual** de acá, y si Lucas corrige uno se corrige acá primero.

**Cómo se escribió.** Según la biblia (`10-universo.md`, §8 «Tono y reglas de escritura»):
1. El desenlace es ambiguo: **logro y costo**, sin ganador moral.
2. Se muestran **consecuencias**, no sentencias.
3. **Nada de caricaturas**: ni colonos héroes ni habitantes villanos.
4. **Textos breves** y sin diálogos entre personajes (Q-01).
5. Español rioplatense, **voz de informe de trabajo**: sobria y concreta.

Vocabulario: sí «colonos», «la colonia», «los Moradores», «el perímetro», «asegurar»; **no** «invasores», «salvajes», «nativos», «aliens», «enemigo», «peligroso» ni «bestia» (esas tres quedan para lo mecánico). Los nombres son los de G2: el planeta **Cántaro**, la colonia **Compañía Meridiana**, las comunidades **Moradores**.

**Los límites** (RF-464, los mismos que valida el juego):

| Texto | Máximo |
|---|---|
| Lugar | 1 línea, **32 caracteres** |
| Entrada | **3 líneas**, 240 caracteres en total |
| Victoria | **2 líneas**, 160 caracteres en total |
| Epílogo (solo nivel 15) | **3 a 5 líneas**, 400 caracteres en total |
| Cualquier línea | 90 caracteres |

Una «línea» es un renglón del archivo (separado por `\n`), no lo que ocupa en pantalla.

**Reglas de esta selección que conviene saber antes de leer:**
- **Niveles 1 a 5: ningún texto explica las señales** (la roca marcada, el sendero, la herramienta, el poste con cintas). La biblia pide *mostrar antes que explicar*. La primera vez que el texto habla de la marca es en el **8**, y es la «revelación».
- **El 8, el 11 y el 14 parten de los tres ejemplos de tono de la biblia** (§8). El 11 y el 14 usan sus frases de victoria casi tal cual (partidas en dos líneas); el 8 reescribe la entrada de ejemplo en tres líneas. Esos ejemplos eran *ilustraciones de tono, no textos finales*: que Lucas haya aprobado la biblia en G2 no los vuelve definitivos, así que también necesitan su OK.
- **Las victorias no suponen nada opcional.** Ninguna menciona una pieza de colección, un recurso ni la demoledora: se ganan igual sin ellas.
- **El 13 habla de «hitos de piedra»**: depende de que se dibuje la señal `hito` (P-6 de la biblia, ver T233). Si Lucas no quiere ese dibujo, la entrada y la victoria del 13 se reescriben con «las rocas marcadas».
- **El 15 no dice nada del jefe supremo en su entrada ni en su victoria** más que «lo más grande que vimos hasta ahora»: no hace falta, el jugador lo ve venir. **El Coloso (T243, RF-484, D-092) se nombra una sola vez, en el artículo «La Central» (§4.10)**, que se abre recién al ganar el 15.

---

## 1. Los 15 niveles


### Nivel 1 · Pradera

- **Lugar** (24 caracteres): Campamento de aterrizaje
- **Entrada** (3 líneas):
  - La nave quedó en el borde del oasis.
  - Hay agua, pasto y un terreno firme donde armar el campamento.
  - Antes de descargar, hay que defenderlo.
- **Victoria** (2 líneas):
  - Campamento asegurado. Las primeras torres quedaron en pie.
  - La carga de la nave se baja esta noche.

### Nivel 2 · Desfiladero

- **Lugar** (16 caracteres): El paso del agua
- **Entrada** (3 líneas):
  - El agua dulce más cercana está al otro lado del desfiladero.
  - Sin ese paso, el campamento no aguanta.
  - Hay que sostenerlo antes de tender las cañerías.
- **Victoria** (2 líneas):
  - Paso asegurado. El agua llega al campamento por primera vez.
  - Faltan tres tramos de cañería.

### Nivel 3 · Encrucijada

- **Lugar** (11 caracteres): Las huertas
- **Entrada** (3 líneas):
  - Al norte del campamento hay tierra buena para sembrar.
  - Dos caminos se cruzan justo ahí, y por los dos llegan manadas.
  - Sin huerta no hay cosecha.
- **Victoria** (2 líneas):
  - Huertas aseguradas. Se sembró el primer surco.
  - Lo que crezca depende de que las torres aguanten.

### Nivel 4 · Espiral

- **Lugar** (7 caracteres): El pozo
- **Entrada** (3 líneas):
  - El arroyo no alcanza para toda la colonia.
  - Hay que cavar un pozo en el centro del valle.
  - El camino hasta ahí da muchas vueltas: que les cueste llegar.
- **Victoria** (2 líneas):
  - Pozo terminado. Hay agua para toda la colonia.
  - Se armó un turno de guardia para cuidarlo.

### Nivel 5 · Fortaleza

- **Lugar** (13 caracteres): La empalizada
- **Entrada** (3 líneas):
  - El campamento ya es un pueblo y todavía no tiene cerco.
  - Hoy se cierra el primer perímetro.
  - Lo que quede afuera, queda afuera.
- **Victoria** (2 líneas):
  - Empalizada cerrada. Es el primer perímetro de la colonia.
  - Por primera vez, dormimos adentro.

### Nivel 6 · Nido

- **Lugar** (10 caracteres): El lindero
- **Entrada** (3 líneas):
  - El bosque empieza donde termina el cerco.
  - Hay madera para varios años, y también criaturas que no habíamos visto.
  - Del campamento empezaron a faltar cosas.
- **Victoria** (2 líneas):
  - Lindero asegurado. Se taló el primer tramo.
  - La madera alcanza para dos casas.

### Nivel 7 · Cruce

- **Lugar** (13 caracteres): El aserradero
- **Entrada** (3 líneas):
  - El mejor sitio para cortar madera es un cruce de caminos.
  - Se arma un aserradero, y para eso hay que despejar el terreno.
  - Todo lo que estorbe se retira.
- **Victoria** (2 líneas):
  - Aserradero en marcha. La colonia ya tiene madera propia.
  - La primera carga sale mañana hacia el campamento.

### Nivel 8 · Bastión

- **Lugar** (23 caracteres): El bastión sobre ruinas
- **Entrada** (3 líneas):
  - Sobre la loma hay muros de piedra vieja, a medio enterrar.
  - Las rocas tienen la misma marca que las del campamento.
  - Alguien la puso antes que nosotros.
- **Victoria** (2 líneas):
  - Bastión asegurado. La colonia tiene una posición alta sobre la loma.
  - Los muros son de otros; los usamos igual.

### Nivel 9 · Taller asediado

- **Lugar** (9 caracteres): El taller
- **Entrada** (3 líneas):
  - Entre las ruinas hay un galpón que puede servir de taller.
  - Los que lo rodean no parecen animales: algunos curan a los suyos.
  - Hoy se prueba el primer mortero de la colonia.
- **Victoria** (2 líneas):
  - Taller asegurado. El horno se encendió por primera vez fuera del oasis.
  - La forja ya no depende de lo que trajo la nave.

### Nivel 10 · La mina vieja

- **Lugar** (31 caracteres): Primer puesto de abastecimiento
- **Entrada** (3 líneas):
  - Las galerías ya estaban cavadas cuando llegamos.
  - Si se las retoma, la colonia tiene mineral a pocos días del campamento.
  - Hay que sostener la boca de la mina.
- **Victoria** (2 líneas):
  - Mina asegurada. Es el primer puesto de abastecimiento de la colonia.
  - Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.

### Nivel 11 · Puesto seco

- **Lugar** (16 caracteres): El punto de agua
- **Entrada** (3 líneas):
  - Pasada la mina, el camino se vuelve seco.
  - Los dos pozos que hay ya tenían huellas alrededor.
  - Desde hoy, algunas torres se apagan sin que nadie las toque.
- **Victoria** (2 líneas):
  - Informe del puesto seco: paso asegurado.
  - Dos pozos quedaron dentro del perímetro.

### Nivel 12 · El cañadón

- **Lugar** (22 caracteres): El paso hacia el norte
- **Entrada** (3 líneas):
  - El único paso hacia el norte es un cañadón de paredes altas.
  - Los tiros vuelven contra las torres, como si las paredes los devolvieran.
  - Cruzarlo es la única forma de llegar al resto de la región.
- **Victoria** (2 líneas):
  - Cañadón asegurado. El paso al norte quedó abierto.
  - En las paredes quedaron las marcas de los tiros que volvieron.

### Nivel 13 · Paso alto

- **Lugar** (31 caracteres): El camino al resto de la región
- **Entrada** (3 líneas):
  - En el paso alto el camino se parte en dos.
  - Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apaga torres.
  - Hay hitos de piedra en el camino. Marcan un límite, y ya lo pasamos.
- **Victoria** (2 líneas):
  - Paso alto asegurado. La región queda comunicada con el valle.
  - Los hitos quedaron del lado de adentro.

### Nivel 14 · Los poblados vacíos

- **Lugar** (30 caracteres): Asentamientos de los Moradores
- **Entrada** (3 líneas):
  - Los poblados están a la vista, pero no sale humo de ninguno.
  - Los Moradores se llevaron lo que pudieron.
  - Aun así, algo todavía defiende el lugar.
- **Victoria** (2 líneas):
  - Los poblados están vacíos.
  - Las brasas todavía están tibias.

### Nivel 15 · La Central

- **Lugar** (24 caracteres): Energía y abastecimiento
- **Entrada** (3 líneas):
  - Falta cerrar el valle: la central de energía y la línea que la une con la mina.
  - Si se sostiene, la colonia queda asentada en esta región.
  - Hoy llega lo más grande que vimos hasta ahora, y no viene solo.
- **Victoria** (2 líneas):
  - Central encendida. La línea de abastecimiento está completa.
  - La colonia tiene luz propia.

---

## 2. Epílogo (solo el nivel 15)

Se muestra después de ganar el 15, con la imagen del final (T233) arriba: la colonia asentada y, a lo lejos, los fuegos de los Moradores. Es el único texto que describe el costo, y lo hace con un dato (los fuegos están más lejos), no con un adjetivo.

- La central se encendió al anochecer. La colonia tiene, por primera vez, luz propia.
- Hay agua, energía y un camino de abastecimiento que une la mina con el valle.
- Del otro lado del paso, los fuegos de los Moradores se ven cada vez más lejos.
- El resto de Cántaro sigue ahí.

*4 líneas, 271 caracteres.*

---

## 3. Créditos

Pantalla sencilla a la que se llega desde el epílogo (RF-472). **Solo lleva lo que se puede comprobar en el repositorio** (el copyright y la licencia salen de `data/wiki/licencias.json`). Lo que Lucas quiera sumar (nombres, agradecimientos, herramientas) lo escribe él: ver la pregunta P7 de M52.

- Monsters & Canons
- Un juego de Lucas
- Hecho con Godot Engine
- Software libre bajo la licencia GPL-3.0-or-later (los detalles, en Wiki → Licencias)

---

## 4. Artículos de Lore para la Wiki

Diez artículos aprobados en `data/wiki/lore/` (RF-469), más un **undécimo en borrador** (T252, abajo). Cada uno se **abre al ganar un nivel** de la campaña (columna «Se abre al ganar»); antes se ve cerrado, como el bestiario (RF-470). No repiten números del juego (constitución P2) y ninguno anticipa lo que el jugador todavía no vio: **un artículo nunca nombra algo que debuta después de su nivel**.

| # | Archivo | Título | Se abre al ganar |
|---|---|---|---|
| 1 | `el_oasis.json` | El oasis | nivel 1 |
| 2 | `planeta_cantaro.json` | Cántaro | nivel 2 |
| 3 | `la_compania.json` | La Compañía Meridiana | nivel 3 |
| 4 | `el_soberano.json` | El Soberano | nivel 4 |
| 5 | `criaturas_solas.json` | Las criaturas que van solas | nivel 6 |
| 6 | `las_ruinas.json` | Las ruinas | nivel 8 |
| 7 | `los_moradores.json` | Los Moradores | nivel 9 |
| 8 | `los_pozos.json` | Los pozos | nivel 11 |
| 9 | `poblados_vacios.json` | Los poblados vacíos | nivel 14 |
| 10 | `la_central.json` | La Central | nivel 15 |
| 11 *(borrador, T252)* | `la_cuadrilla.json` | La Cuadrilla | nivel 7 *(su `orden` va entre el del 5 y el del 6)* |


### 1. El oasis

- **Subtítulo:** Donde aterrizó la nave
- **Se abre al ganar:** el nivel 1 (`level_01`)
- **Texto** (un bloque `texto` por párrafo):

  > El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista que encontró el reconocimiento, y por eso la nave bajó acá.

  > Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sembrar) hay que ir a buscarlo más lejos.

  > Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.

### 2. Cántaro

- **Subtítulo:** El planeta, o lo que se conoce de él
- **Se abre al ganar:** el nivel 2 (`level_02`)
- **Texto** (un bloque `texto` por párrafo):

  > Los colonos le pusieron Cántaro al planeta, por el oasis: un poco de agua guardada en una tierra seca.

  > Lo que se conoce es un solo rincón: el oasis y lo que lo rodea. Más allá, todavía no se llegó.

  > Cada tramo que se asegura se agrega al mapa de la Compañía. El mapa tiene más blanco que dibujo.

### 3. La Compañía Meridiana

- **Subtítulo:** Quiénes somos
- **Se abre al ganar:** el nivel 3 (`level_03`)
- **Texto** (un bloque `texto` por párrafo):

  > La Compañía Meridiana armó la expedición. No es un ejército: es gente de oficio (ingenieros, herreros, carpinteros, agricultores) con herramientas, semillas y planos.

  > La nave no puede volver a despegar. Se la va desarmando de a poco para hacer casas, cañerías y torres, y lo que se rompe se arregla con lo que hay.

  > Por eso las torres son de hierro, bronce y cristal: se pueden reparar en el lugar. Entre la carga venían también planos y piezas de repuesto, que se van recuperando de entre los restos del aterrizaje.

### 4. El Soberano

- **Subtítulo:** Quien va al frente de las manadas
- **Se abre al ganar:** el nivel 4 (`level_04`)
- **Texto** (un bloque `texto` por párrafo):

  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le dicen Soberano.

  > No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.

### 5. Las criaturas que van solas

- **Subtítulo:** Lo que no pertenece a ninguna manada
- **Se abre al ganar:** el nivel 6 (`level_06`)
- **Texto** (un bloque `texto` por párrafo):

  > En el bosque hay seres que no andan con ninguna manada. El Ladrón, por ejemplo, va solo, con una capa gris y una bolsa, y se lleva lo que brilla del campamento: monedas, herramientas, un botón.

  > Los informes las llaman criaturas, para distinguirlas de los animales. No obedecen a nadie, y nadie sabe cuántas hay.

### 6. Las ruinas

- **Subtítulo:** Lo que había antes
- **Se abre al ganar:** el nivel 8 (`level_08`)
- **Texto** (un bloque `texto` por párrafo):

  > Sobre la loma del bastión hay muros de piedra y metal, a medio enterrar. Los colonos los llaman «las ruinas» y los tratan como un yacimiento: se despeja, se anota y se recupera lo que sirve.

  > Todas llevan la misma marca que las rocas del oasis. Nadie sabe qué quiere decir: puede ser «esto es nuestro», «hasta acá» o un recuerdo.

  > El informe de la Compañía dice que las dejó una gente que ya no está. No dice cómo lo sabe.

### 7. Los Moradores

- **Subtítulo:** Los que ya estaban
- **Se abre al ganar:** el nivel 9 (`level_09`)
- **Texto** (un bloque `texto` por párrafo):

  > Así llama la Compañía a las comunidades que viven en Cántaro. Es un nombre de informe: cómo se llaman ellos a sí mismos no figura en ningún registro.

  > Hasta ahora se vieron dos oficios: los que protegen, de piedra y escudo dorado, y los que curan, con una semilla en el pecho. No está claro si son un solo pueblo o varios que se juntaron.

  > Tampoco está claro si guían a los animales de las manadas o si solo cuidan sus propios caminos.

### 8. Los pozos

- **Subtítulo:** Informe del puesto seco
- **Se abre al ganar:** el nivel 11 (`level_11`)
- **Texto** (un bloque `texto` por párrafo):

  > En el camino seco hay pocos pozos, y todos tienen huellas alrededor. Dos quedaron dentro del perímetro del puesto.

  > El mismo día en que se aseguró el paso empezaron los fallos: torres que se apagan sin motivo. Las observaciones coinciden en un encapuchado con un bastón que chispea, que se acerca a las torres y no a los colonos.

  > No ataca a las personas. Ataca lo que construimos.

### 9. Los poblados vacíos

- **Subtítulo:** Lo que quedó en pie
- **Se abre al ganar:** el nivel 14 (`level_14`)
- **Texto** (un bloque `texto` por párrafo):

  > Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.

  > No hay nadie. Las brasas están tibias, así que se fueron hace poco, y se llevaron lo que podían cargar.

  > La Compañía registra los poblados como «posiciones desocupadas».

### 10. La Central

- **Subtítulo:** Energía y abastecimiento
- **Se abre al ganar:** el nivel 15 (`level_15`)
- **Texto** (un bloque `texto` por párrafo):

  > La central quedó en el valle donde aterrizó la nave. Produce la energía que necesita la colonia y alimenta la línea que la une con la mina.

  > Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.

  > Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.

  > El informe termina ahí. No dice qué se hará con lo que falta.

### 11. La Cuadrilla *(borrador de T252; Lucas todavía no lo leyó)*

- **Subtítulo:** Los que andan juntos
- **Se abre al ganar:** el nivel 7 (`level_07`)
- **`orden`:** entre el del artículo 5 y el del 6 (los artículos 6 a 10 pasan a 7 a 11; solo cambia ese campo).
- **Texto** (un bloque `texto` por párrafo):

  > Cerca del aserradero se vieron criaturas chicas y rápidas que se llevan lo que brilla, igual que el Ladrón. A diferencia de él, no andan solas: llegan juntas, y los colonos las llaman Rateros.

  > Con ellas viene siempre una más grande y lenta, con una bolsa más grande que ella misma donde parece juntarse lo de todas. La llaman el Cargador, y a todas juntas, la cuadrilla, por cómo llegan.

  > Nadie vio que alguna mande ni que alguna obedezca. Parece que van juntas porque buscan lo mismo.

- **Por qué es un artículo propio y no un párrafo del 5:** el 5 se abre al ganar el 6 y la Cuadrilla debuta en el 7; un artículo nunca nombra algo que debuta después de su nivel (arriba). Y el 5 está aprobado.
- **Lo que cuida el texto:** que **no llevan la marca** ni dependen de los Moradores (no los nombra: el artículo 7 recién se abre en el 9, y la marca se revela en el 8); que **«la cuadrilla» es un nombre de los colonos**, no un hecho; que nadie manda; y que **no hay un juicio** sobre ellas (tono de §8 de la biblia).

---

## 5. Qué se comprobó y qué no

**Se comprobó** (con un script suelto, sin dejarlo en el repositorio):
- Los 15 lugares, entradas y victorias, el epílogo y los créditos **cumplen los límites** de la tabla de arriba (lugares de 7 a 31 caracteres; entradas de 125 a 201 de 240; victorias de 59 a 134 de 160; epílogo de 271 de 400; ninguna línea pasa de 90).
- Ningún texto contiene las palabras vetadas del vocabulario («enemigo», «peligro», «bestia», «salvaje», «invasor», «nativo», «indio», «alien», «monstruo», «malvado», «héroe»).
- Cada artículo de Lore menciona solo lo que ya apareció hasta el nivel que lo abre (revisado a mano contra los debuts de la biblia §7: p. ej. «Los Moradores» se abre en el 9 y habla de **dos** oficios porque el Chamán recién debuta en el 11, donde lo cuenta «Los pozos»).

**No se comprobó:**
0. **El párrafo del Coloso** (T243) no pasó por la mirada de nadie más que la mía; revisa que no use las palabras vetadas («enemigo», «bestia», «malvado», etc.) y que no nombre nada que debute después del 15. Que «es de la misma piedra que los Guardianes» insinúe una pertenencia a los Moradores sin afirmarla es justamente la ambigüedad que Lucas aceptó.
1. **Que suenen bien dichos en el juego.** Los leí contra la sección de tono de la biblia, pero el criterio es de Lucas: puede haber frases que le parezcan frías, ambiguas de más o, al revés, demasiado explícitas.
2. **Que entren en pantalla.** Los límites son de caracteres; el cartel y la tarjeta (T228) los miden en una captura real, y si una tarjeta no alcanza para 32 caracteres se baja el límite y se acorta el lugar.
3. **Los hechos que los textos suponen del juego** (que el 9 «prueba el primer mortero», que el 11 «apaga torres», que el 13 trae una escolta por dos caminos) son los de la biblia y el plan 08 §5. Si la partida de Lucas del 6 al 10 (T226, todavía sin cerrar) cambia algo de eso, los textos afectados son el 9 (mortero) y los de las fichas marcadas **A REVISAR TRAS G4** en la spec.
4. **Los artículos de Lore no pasaron por la mirada de nadie más** que la mía. En particular «Los poblados vacíos» termina con una frase de informe burocrático («posiciones desocupadas») que busca decir mucho sin decirlo: si a Lucas le parece que subraya de más, se saca esa línea.

5. **El artículo 11, «La Cuadrilla»** (T252) **no pasó por la mirada de nadie más que la mía.** Revisé a mano que no use las palabras vetadas ni nombre nada que debute después del nivel 7 (no nombra a los Moradores, la marca ni a ningún enemigo de otros niveles) y que concuerde con el artículo 5 («va solo» / «andan juntas»). No se comprobó que suene bien ni que «Rateros» y «Cargador» sean los nombres que Lucas quiere (P3 y P4 de M55). Si cambia el nivel del debut, **cambia también el artículo que lo abre** y hay que volver a revisar qué puede nombrar.

## 6. Cómo aprobar

Alcanza con escribir, por ejemplo, *«Acepto todo salvo la entrada del 6 y el artículo de Los poblados vacíos»*. Lo que se corrija se cambia **acá**; después T228 y las tareas de nivel copian la versión aprobada. Mientras no haya OK, **nadie carga estos textos en el juego**.
