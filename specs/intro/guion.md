# Guion de la intro de Monsters & Canons

> **Estado: PROPUESTA** (escrita el 2026-10-11 por Claude, Sonnet 5.5, tarea **T240**). **Falta el OK de Lucas** (compuerta 🚦 **G6**): al guion, al funcionamiento y a las cinco preguntas del final. Hasta que lo dé, **nadie dibuja las láminas (T241) ni programa la pantalla (T242)**.
>
> **Dónde vive qué.** Este documento es **el único lugar donde se escriben y se corrigen los textos de la intro** (igual que `specs/11-textos-lore.md` lo es para los niveles y la Wiki): T242 los copia tal cual a `data/intro/intro.json`. El **funcionamiento** (cuándo se ve, cómo se maneja, a dónde lleva) es requisito: está en **M57** de `specs/01-spec.md` (**RF-497 a RF-501**) y en **D-096** de `specs/04-decisiones.md`. Acá solo se resume.

## 0. Qué pidió Lucas

*(2026-10-11, en el encargo de T240; **manda sobre la ficha**.)*

- La intro es una **mini película casera hecha con imágenes tipo diapositiva**, con el **texto abajo**.
- Tiene que dar **fuerte la sensación de nave y de viaje**: la expedición, la nave que ya no va a despegar.
- **Termina con una lámina panorámica del oasis verde en medio de la nada**; **después de eso aparece el mapa jugable**.
- **Entra en la versión 1.0.**
- Funcionamiento: se ve **la primera vez que se toca «Jugar»**, **se puede omitir siempre**, **se puede volver a ver** desde la Wiki o con un botón «Intro», y **avanza con un toque o sola**.
- **De 5 a 8 láminas.** Cada una con la descripción de la ilustración (para Codex), el texto (1 o 2 líneas) y la duración sugerida.
- **No adelantar el conflicto con las comunidades**: se descubre jugando.
- **Dos referencias de estilo**, descriptas en palabras.

**Qué cambia respecto de lo que ya estaba escrito.** El 07 §11.F decía «guion, número de láminas, reproducción y posibilidad de omitir/rever se decidirán al final» y Q-01 (D-089) permitía «una intro de láminas que se pueda omitir y volver a ver». Este documento y M57 **cierran** esas dos cosas. **No se cambia ninguna regla de Q-01**: las láminas son imágenes quietas con un fundido entre ellas; ninguna se anima y no hay diálogos ni voces.

---

## 1. La idea en pocas palabras

Siete láminas, unos **50 segundos** (51 con las duraciones sugeridas), que cuentan una sola cosa: **la nave va, llega y no se vuelve a ir**.

**El arco** (el de la ficha: *el viaje, la llegada, el oasis y la decisión de quedarse*):

| Tramo | Láminas | Qué siente quien mira |
|---|---|---|
| **El viaje** | 1 · 2 · 3 | Una nave chica en un vacío enorme; gente de oficio, no soldados; años a bordo y **un viaje de ida**. |
| **El destino** | 4 | Un planeta seco, y **un único punto verde** marcado en el mapa. |
| **La llegada** | 5 · 6 | La bajada brusca y, adentro, **los motores que se apagan y no se vuelven a encender**. |
| **El oasis** | 7 | La panorámica: un valle verde chico, en medio de la nada. **Acá nos quedamos.** |

**El truco de color.** Las seis primeras láminas **no tienen verde**: hierro, bronce, ámbar de lámpara, azul de noche y ocre. El verde recién aparece como un **punto** en la 4, como un **hilo de luz** en la 6 y como **todo el cuadro** en la 7. Que el oasis sea lo único vivo es lo que hace que la última lámina pegue.

**Por qué no hay conflicto.** Nada en la intro sabe que el planeta tiene habitantes. El único «otro» del cuadro es el espacio. **«En medio de la nada» es lo que ven los colonos**, no un hecho: el juego se encarga después (símbolo A, ruinas, Moradores) de mostrar que no era cierto, y la intro **no lo desmiente ni lo confirma**.

---

## 2. Reglas del guion

**Tono** (biblia `10-universo.md` §8, las mismas que los textos de los niveles):
1. **Voz de informe de trabajo**, sobria y concreta; español rioplatense («acá», «nos quedamos»). Sin grandilocuencia.
2. **Consecuencias, no sentencias.** Dice qué pasó (los motores se apagaron), no si estuvo bien.
3. **Nada de héroes ni de caricaturas.** Gente de oficio, no soldados.
4. **Sin diálogos.** Ninguna línea la dice un personaje.
5. **Vocabulario:** sí «la Compañía», «la nave», «los colonos», «el reconocimiento»; **no** «enemigo», «peligro», «bestia», «salvaje», «invasor», «nativo», «indio», «alien», «monstruo», «malvado», «héroe».

**Qué no adelanta** (lo que Lucas pidió cuidar):
- **Ninguna lámina muestra a los Moradores, animales, criaturas, ruinas ni el símbolo A.** El primer encuentro con la marca es en el nivel 1, **sin texto** (biblia §6, regla 1); la intro no se lo gasta.
- **Ninguna lámina muestra humo, fuegos ni luces en el horizonte.** En el epílogo (nivel 15, `epilogue.png`) hay fuegos a lo lejos; en la lámina 7 el horizonte está **vacío**. La diferencia entre los dos cuadros es el único comentario que el juego hace del costo, y no hace falta decirlo.
- **No se nombra al planeta.** «Cántaro» es un nombre que le ponen los colonos **después**, por el oasis (artículo «Cántaro» de la Wiki, que se abre al ganar el 2). La intro dice «el planeta».
- **No explica cómo se juega.** La intro cuenta la llegada; las torres, el oro y las oleadas se aprenden en el nivel 1.

**Límites del texto** (los de la victoria de un nivel, RF-464; los valida el juego, RF-497):
- **1 o 2 líneas**; **90 caracteres por línea**; **160 en total**; texto plano.
- **Duración mínima** para poder leerlo: `2 s + caracteres / 20` (redondeado hacia arriba) y nunca menos de 5 s. Si el lector no llega, toca.

**La imagen no lleva texto** (T241): el texto lo pone el juego, en una franja abajo.

---

## 3. Hoja de continuidad (para Codex)

Lo que **tiene que verse igual en las siete láminas**. Si una lámina no lo cumple, se repite.

### La nave
Casco **largo y bajo de hierro remachado**, color óxido y gris pizarra, **remendado**: planchas de distinto tono, parches soldados, un costurón de remaches a lo largo. Una **franja ancha de bronce** recorre el lomo. **Tres cúpulas de cristal** azul verdoso en el lomo, con luz cálida adentro. **Proa roma** con una ventana redonda. **Popa con dos toberas grandes de bronce** con aros. Una antena corta con un trapo atado. **Sin alas, sin láseres, sin luces de neón, sin estelas de energía**: es una máquina de taller, no de ciencia ficción (07 §2; guía de arte §7, familia A: hierro, bronce y madera). Posada, se apoya en **cuatro patas anchas de hierro** y tiene una rampa de madera y hierro.

### Los colonos
Ropa de trabajo: monos de lona, chalecos de cuero, delantales, gorras, pañuelos al cuello, botas. **Herramientas, no armas**: llaves grandes, martillos, palas, serruchos, sogas. Cuerpos y edades distintos. **Sin trajes espaciales ni cascos.** Cuatro que se repiten (sin nombre; los textos no los nombran):

| Quién | Cómo se la reconoce |
|---|---|
| **La ingeniera** | Mujer de unos cuarenta, gorra de cuero con anteojos de protección levantados sobre la frente, mono azul desteñido con parches en las rodillas. |
| **El herrero** | Hombre mayor, barba gris, delantal de cuero, antebrazos fuertes, manos manchadas de hollín. |
| **La agricultora** | Sombrero de paja chato, pañuelo rojo al cuello (**el único rojo** de la intro), saco de semillas. |
| **El mecánico joven** | Gorra de lona, llave inglesa grande al cinto, mono gris. |

### Las cosas que vuelven
- **Cajones de madera** con tiras de hierro, sin letras legibles (la imagen no lleva texto).
- **Lámparas de aceite o de filamento** de luz cálida (nada fluorescente ni de pantalla).
- **Una carta de papel** con un círculo a lápiz: aparece en la 4 y en la 6 (clavada junto a la palanca).

### Guion de color

| Lámina | Dominante | Lo único que se sale |
|---|---|---|
| 1 | Azul noche | El ámbar de las cúpulas |
| 2 | Ámbar de lámparas | El azul frío de la ventana |
| 3 | Azul verdoso frío | Un solo punto cálido: la lámpara |
| 4 | Penumbra azul, ocre del planeta | **Un punto verde** |
| 5 | Naranja de fuego sobre ocres | Un parche verde diminuto, abajo |
| 6 | Ámbar oscuro de sala de máquinas | **Un haz de luz verdosa** desde afuera |
| 7 | **Verde saturado** del oasis, ocre y cielo pálido de mañana | — |

### Formato
**PNG 1920 × 1080 (16:9)**, sin texto. La lámina **se ve entera** en el juego (no se recorta; si la pantalla no es 16:9 quedan barras): no hace falta un «área segura» lateral. **El 22 % de abajo (de y = 842 a y = 1080) es la zona del texto:** tranquila, oscura y sin nada que importe, porque el juego pone ahí una franja con el texto.

---

## 4. Las siete láminas

Cada ficha trae: **qué cuenta**, la **ilustración** (para Codex: plano, quién o qué aparece, luz y qué no va), el **texto** tal como se carga en el juego, y la **duración sugerida**.

### Lámina 1 · La nave

**Qué cuenta.** Una nave sola, en un vacío enorme. Es la **escala**: la Compañía mandó una, y es chica.

**Ilustración.**
- **Plano:** general, muy abierto. La nave de lado, **avanzando hacia la derecha**, ocupa un tercio del ancho y queda **apenas por encima de la línea media**. Mucho vacío alrededor.
- **Qué aparece:** la nave de la hoja de continuidad, con **las toberas apagadas** (una brasa tenue; la nave va a la deriva). Se adivinan siluetas **adentro de las cúpulas**, chiquitas. Atrás, a la izquierda y muy chico, **un sol amarillo pálido**: de donde vienen. Estrellas y un polvo apenas visible. Nada más.
- **Luz:** contraluz lateral del sol lejano; un **filo de luz cálida** en el borde del casco. Todo lo demás, azul noche. Lo más cálido del cuadro son las cúpulas.
- **Zona de texto:** el cuarto de abajo es negro azulado casi liso, con muy pocas estrellas.
- **No:** planetas gigantes, otras naves, estelas luminosas, anillos, texto.

**Texto** *(2 líneas, 83 caracteres)*
> La Compañía Meridiana mandó una sola nave.
> No lleva soldados: lleva gente de oficio.

**Duración sugerida:** 7 s.

---

### Lámina 2 · La bodega

**Qué cuenta.** **Qué llevan.** Gente de oficio con herramientas, semillas y planos: lo necesario **para empezar de cero**. Es lo que la colonia va a necesitar después (artículo «La Compañía Meridiana»: «planos y piezas de repuesto»).

**Ilustración.**
- **Plano:** medio-general, desde un costado y un poco alto. Una **bodega de carga** con techo de costillas de hierro que se pierde arriba. Al fondo, **una ventana redonda grande** con estrellas.
- **Qué aparece:** **cinco o seis colonos trabajando**, incluidos el herrero, la agricultora y el mecánico joven. Dos aseguran con sogas un carro cargado de cajones; la agricultora acomoda sacos de semillas y cajones de plantines; el herrero ajusta una pieza grande en un banco; el mecánico joven carga un engranaje. En primer plano, **la ingeniera** despliega un plano sobre un cajón. Estantes con engranajes y repuestos, barriles, un arado desarmado atado a la pared.
- **Luz:** ámbar de lámparas colgantes, sombras largas; **el azul frío solo entra por la ventana**.
- **Zona de texto:** el piso de chapa de la bodega, oscuro y casi liso.
- **No:** armas, armaduras, cascos, pantallas, hologramas, cajones con letras.

**Texto** *(2 líneas, 125 caracteres)*
> Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio.
> Hay semillas, planos y piezas para empezar de cero.

**Duración sugerida:** 9 s.

---

### Lámina 3 · Los turnos

**Qué cuenta.** **El tiempo.** El viaje no fue un salto: fueron años de vida a bordo, durmiendo por turnos y arreglando lo que se rompía. Y es **de ida**.

**Ilustración.**
- **Plano:** medio, en un pasillo-dormitorio largo que se pierde hacia el fondo (perspectiva con punto de fuga, para la sensación de **profundidad de nave**).
- **Qué aparece:** **literas de hierro y madera en dos pisos** con cortinas de lona; una cuelga recogida y otra cerrada con un par de botas afuera. En primer plano, sentada en un cajón y despierta, **la ingeniera** con una lámpara baja, ajustando un engranaje con una llave. Al fondo, junto a una **ventanilla redonda**, una figura de guardia con una taza. Ropa tendida de una soga, un calendario hecho con **rayitas de tiza en la pared, en grupos de cinco, muchísimas** (que se vea que pasó mucho tiempo; **no** forman letras ni símbolos).
- **Luz:** azul verdoso frío de la ventanilla; **un solo punto cálido**, la lámpara de la ingeniera, que le ilumina la cara.
- **Zona de texto:** el piso del pasillo y la sombra bajo las literas.
- **No:** niños, uniformes, pantallas, pasillos limpios y brillantes. Todo está usado.

**Texto** *(2 líneas, 103 caracteres)*
> Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo.
> Era un viaje de ida.

**Duración sugerida:** 8 s.

---

### Lámina 4 · La ventana

**Qué cuenta.** **El destino.** De todo el planeta, un solo lugar con agua a la vista. Es el origen de la decisión.

**Ilustración.**
- **Plano:** medio, **desde atrás**: dos colonos de espaldas, **la ingeniera y el herrero**, frente a una **gran ventana** con marco de bronce.
- **Qué aparece:** afuera, **el planeta**: grande, seco, de ocres y rojizos, con bandas de polvo y sin mares. Sobre su superficie, **un puntito verde**, el único verde del cuadro, y la mirada tiene que encontrarlo. En primer plano, una mesa con **una carta de papel** (el mapa del reconocimiento) con un **círculo hecho a lápiz** alrededor de un punto, un compás de bronce y una taza.
- **Luz:** el planeta ilumina los rostros y la mesa de **ocre cálido** desde la ventana; el interior queda en penumbra azul.
- **Zona de texto:** la mesa y la oscuridad de abajo.
- **No:** océanos, nubes verdes, anillos, lunas, ciudades, luces en la superficie del planeta.

**Texto** *(2 líneas, 88 caracteres)*
> El reconocimiento vio agua en un solo lugar de todo el planeta.
> Hacia ahí apuntó la nave.

**Duración sugerida:** 7 s.

---

### Lámina 5 · El descenso

**Qué cuenta.** **La llegada, a los golpes.** No fue un aterrizaje prolijo. Tiene que dar sensación de **esfuerzo del casco** y de **velocidad**.

**Ilustración.**
- **Plano:** exterior, algo desde abajo y de lado, con **una diagonal fuerte**: la nave cae de arriba a la izquierda hacia abajo a la derecha.
- **Qué aparece:** la nave de la hoja de continuidad con **la proa al rojo** y una estela de fuego naranja y chispas; **chapas, un cajón de madera y una soga sueltos** en la estela (son los «restos del aterrizaje» de los que el artículo «La Compañía Meridiana» dice que se recuperan los planos y las piezas). Nubes de polvo ocre alrededor. Abajo, el paisaje seco, y **en el centro del paisaje, diminuto, un parche verde**: hacia ahí va la diagonal.
- **Luz:** el fuego de la proa ilumina el casco y el polvo; el cielo, de ocre sucio.
- **Zona de texto:** el suelo ocre oscuro de abajo, sin accidentes.
- **No:** explosiones, humo negro (que no parezca un accidente), paracaídas, propulsores azules.

**Texto** *(1 línea, 59 caracteres)*
> La bajada fue brusca. El casco crujió entero, pero aguantó.

**Duración sugerida:** 5 s.

---

### Lámina 6 · Los motores apagados

**Qué cuenta.** **La decisión.** Es la lámina que dice «la nave que ya no va a despegar». Tiene que dar la sensación de algo que **se cierra**.

**Ilustración.**
- **Plano:** interior, **sala de máquinas**, plano medio-general, con la palanca en primer plano.
- **Qué aparece:** **dos grandes máquinas de bronce** (cilindros, bielas, una caldera) **quietas y todavía humeando**; **manómetros con la aguja en cero**. En primer plano, **la palanca enorme del encendido principal**, trabada con **una cuña de madera y una cadena con candado de bronce**: se ve que ya no se va a mover. **La carta de papel** de la lámina 4, clavada junto a la palanca. **La ingeniera**, de perfil, se limpia la grasa de las manos con un trapo y mira el piso. Una **escotilla entreabierta** deja entrar un **haz de luz verdosa y dorada** de afuera que cae sobre la palanca.
- **Luz:** sala en **ámbar oscuro**; el haz exterior es lo único que no es ámbar.
- **Zona de texto:** el piso de chapa, oscuro.
- **No:** gente festejando, banderas, gestos épicos, fuego encendido. Es un momento callado.

**Texto** *(2 líneas, 68 caracteres)*
> Los motores se apagaron al tocar tierra.
> La nave ya no va a despegar.

**Duración sugerida:** 6 s.

---

### Lámina 7 · El oasis *(la panorámica final)*

**Qué cuenta.** **El oasis en medio de la nada, y la decisión de quedarse.** Es la imagen que cierra la intro y la que el jugador ve justo antes del mapa. Tiene que ser la **más abierta** de las siete, y la que más respira.

**Ilustración.**
- **Plano:** **panorámica**, horizonte bajo (el cielo ocupa un 40 %), con la mayor profundidad de las siete.
- **Qué aparece:** en el centro, **el oasis**: un valle chico con una **laguna de agua dulce**, pasto verde, **flores amarillas y blancas** y unos pocos árboles bajos. Alrededor, **hasta el horizonte, tierra seca**: arena ocre, rocas planas, nada más. **Ni un camino ni una construcción.** A la izquierda, **en el borde del valle, la nave**, posada sobre sus cuatro patas, chiquita frente al paisaje, **con la rampa bajada** y **un surco en la tierra** detrás (el rastro del aterrizaje, con un cajón suelto). **Cinco o seis figuras diminutas** en el pasto, junto a la rampa, **mirando el agua**: la ingeniera, el herrero, la agricultora y el mecánico joven entre ellas. **La carga sigue a bordo**: todavía no hay carpas, fogones ni cercos (el campamento se arma en el nivel 1).
- **Luz:** **primeras horas de la mañana**, baja y clara, sombras largas, cielo pálido. El verde del oasis es **el único color saturado de las siete láminas**.
- **El horizonte, vacío:** sin humo, sin luces, sin figuras, sin marcas. (Ver §2.)
- **Zona de texto:** el pasto oscuro y la tierra del primer plano, sin detalle.
- **No:** animales, aves, el símbolo A, rocas con marcas, construcciones, ruinas, fuegos lejanos, el nombre del planeta.

**Texto** *(2 líneas, 71 caracteres)*
> Un valle chico, con agua y pasto, en medio de la nada.
> Acá nos quedamos.

**Duración sugerida:** 9 s *(la que más se demora: es la última y se mira)*.

---

## 5. Resumen

| # | Título | Texto | Duración |
|---|---|---|---|
| 1 | La nave | La Compañía Meridiana mandó una sola nave. / No lleva soldados: lleva gente de oficio. | 7 s |
| 2 | La bodega | Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio. / Hay semillas, planos y piezas para empezar de cero. | 9 s |
| 3 | Los turnos | Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo. / Era un viaje de ida. | 8 s |
| 4 | La ventana | El reconocimiento vio agua en un solo lugar de todo el planeta. / Hacia ahí apuntó la nave. | 7 s |
| 5 | El descenso | La bajada fue brusca. El casco crujió entero, pero aguantó. | 5 s |
| 6 | Los motores apagados | Los motores se apagaron al tocar tierra. / La nave ya no va a despegar. | 6 s |
| 7 | El oasis | Un valle chico, con agua y pasto, en medio de la nada. / Acá nos quedamos. | 9 s |
| | | **Total** | **51 s**, más seis fundidos de 0,6 s |

*Quien quiere leer más rápido toca; quien no toca, ve la intro entera en menos de un minuto.*

---

## 6. Dos referencias de estilo

Pedido: **aspecto dibujado a mano**. Las dos se describen **en palabras**; ninguna copia una obra, un estudio ni un artista. Lo que importa es **qué se le pide a Codex** (la técnica, la luz, la paleta), no a quién se parece.

### Referencia A · «Cuaderno de bitácora»
Dibujo a **pluma fina con tinta sepia sobre papel crema con grano**. Las sombras se hacen con **tramas de líneas finas y cruzadas** y con **manchas de acuarela** que **no llegan a los bordes**: el papel queda a la vista alrededor y algún borde del dibujo está sin terminar. Colores **apagados y terrosos** (ocres, óxidos, azul pizarra), y el **verde del oasis como único color intenso**. Se siente como el cuaderno de alguien de la expedición que **dibujó lo que vio**.

### Referencia B · «Diapositiva pintada»
**Témpera o gouache en planos de color anchos y opacos**, con contornos suaves de lápiz de color y el **grano del papel** a la vista. Las **esquinas apenas oscurecidas**, como una diapositiva vieja proyectada en una pared, y una luz cálida con mucha atmósfera. **Pocos elementos grandes por lámina**, sin detalle menudo, composición simple. Se siente como **la película o el álbum casero** de una familia que se mudó lejos.

### Recomendación
**A.** Es la que más se lee como «dibujado a mano» y la más fácil de mantener **igual en siete láminas** (la línea de tinta es lo que une las imágenes); la zona del texto sale sola, porque el papel y la trama dejan aire. **B** queda más cerca de la pintura digital del epílogo (`epilogue.png`) y es más cálida, pero depende más de que cada lámina salga con el mismo tratamiento de luz.

**Una cosa que hay que decir:** el epílogo actual es una **pintura digital realista**; cualquiera de las dos referencias va a quedar **distinta** de él. Se puede leer como una virtud (la intro es un *recuerdo dibujado* y el final es *el lugar tal cual es*), o se puede repasar el epílogo con el estilo elegido. **Lo decide Lucas** (P3).

### La lámina de prueba (compuerta 🎨 de T241)
**La 7**, porque es la que carga el color, el paisaje y las figuras chicas. **Dos versiones, una por referencia**, para que Lucas compare con lo mismo adelante. Con su OK a una, se hacen las otras seis y una hoja con las siete en miniatura para revisar la continuidad.

### Una base de prompt para T241
*(La completa Codex en T241; no es el prompt final.)* «Ilustración [A: de cuaderno de expedición en tinta sepia y acuarela / B: pintada en gouache, como diapositiva vieja] de una expedición civil de colonos con ropa de trabajo y una nave de hierro remachado y bronce. Sin tecnología futurista, sin armas, sin texto. Cuarto inferior calmo y oscuro para poner el texto. Paleta: [ver el guion de color de la lámina]. Mismos personajes y misma nave que en el resto de la serie [adjuntar la hoja de continuidad].»

---

## 7. Funcionamiento (resumen)

El requisito completo, con su «Dado / Cuando / Entonces», es **M57 (RF-497 a RF-501)**. En corto:

| Qué | Cómo |
|---|---|
| **Cuándo se ve** | La **primera vez que se toca «Jugar»** en un guardado. Un campo nuevo y aditivo del guardado (`intro_seen`) lo recuerda; un guardado viejo la ve **una vez**. En el **modo de pruebas** no salta sola. |
| **Cómo avanza** | Con **un toque** (o clic, `Espacio`, `Enter`, `→`) y **sola** cuando pasa la duración de la lámina. Entre una y otra, un **fundido** de 0,6 s. |
| **Omitir** | Un botón **«Omitir»** siempre visible, `Esc` y el «atrás» de Android. Termina la intro entera. |
| **Qué pasa al terminar** | Si el guardado **no tiene ningún nivel ganado**, se abre **el nivel 1** (con su cartel: «La nave quedó en el borde del oasis»). Si ya tiene niveles ganados, la **selección de niveles**, como hoy. |
| **Volver a verla** | Un botón **«Ver la intro»** en la **Wiki, solapa Lore**. Al terminar, vuelve a la Wiki. No toca el guardado. |
| **Con qué sonido** | La música de menú sigue sonando. No hay sonidos nuevos. |
| **Si el archivo está roto** | «Jugar» sigue yendo a la selección de niveles. La intro es un adorno: **nunca bloquea jugar**. |

---

## 8. Cómo encaja con los textos que ya están aprobados

Se revisó contra `11-textos-lore.md` y la biblia. **No hay contradicciones**; lo que sigue es lo que hay que cuidar.

| Dónde | Dice | Cómo lo respeta la intro |
|---|---|---|
| Nivel 1, entrada | «La nave quedó en el borde del oasis. Hay agua, pasto y un terreno firme donde armar el campamento.» | La lámina 7 pone **la nave en el borde del valle**, sin campamento. |
| Nivel 1, victoria | «La carga de la nave se baja esta noche.» | En la 7 **la carga sigue a bordo**. |
| Artículo «El oasis» | «Un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista que encontró el reconocimiento…» | Láminas 4 y 7: **un solo punto con agua**; la 7 con **flores**. |
| Artículo «Cántaro» (se abre al ganar el 2) | «Los colonos le pusieron Cántaro al planeta, por el oasis.» | La intro **no nombra al planeta**: el nombre llega después, por el oasis. |
| Artículo «La Compañía Meridiana» | «Gente de oficio (ingenieros, herreros, carpinteros, agricultores) con herramientas, semillas y planos… La nave no puede volver a despegar. Se la va desarmando de a poco… planos y piezas de repuesto, que se van recuperando de entre los restos del aterrizaje.» | Láminas 2, 6 y 5 (los **cajones sueltos** en la estela). |
| Biblia §1 | «Llega para quedarse: no busca rescate ni volver.» | «Era un viaje de ida» (3), «ya no va a despegar» (6), «Acá nos quedamos» (7). |
| Biblia §3, «Aspecto de la expedición» | «Gente con ropa de trabajo, herramientas, carros y una nave que ya no va a despegar. Colores cálidos de bronce y madera sobre el verde del oasis; la nave se ve vieja y desarmándose de a poco…» | Hoja de continuidad (§3). |
| Biblia §6, regla 1 | «La primera vez que aparece una señal no lleva texto.» | La intro **no muestra** ninguna señal. |

---

## 9. Qué inventé y qué no se comprobó

**Lo que sale de documentos ya aprobados:** la expedición civil, los oficios, el reconocimiento, la nave que no vuelve a despegar, los restos del aterrizaje, el oasis con flores y la ambigüedad del «nada».

**Lo que es mío (propuesta; Lucas puede cambiarlo):**
- **«Una sola nave».** Ningún documento dice cuántas eran. Una sola da más escala y más soledad.
- **«Años de viaje».** El canon no da una duración. «Años» es vago a propósito; un número («tres años») sería más fuerte y también más fácil de contradecir.
- **Los cuatro colonos que se repiten** (ingeniera, herrero, agricultora, mecánico joven) y el **pañuelo rojo**. Son un recurso para que Codex mantenga la continuidad; no son canon ni se nombran.
- **Que la nave bajó «brusca».** Sale del «restos del aterrizaje» del artículo 3, pero la palabra es mía.
- **La hora** (primeras horas de la mañana) de la lámina 7. El epílogo es de noche y la victoria del nivel 1 dice «la carga de la nave se baja esta noche»: una mañana encaja con las dos.
- **La carta con el círculo a lápiz.** Es un objeto de la intro; el juego no lo vuelve a usar.

**Qué no se comprobó:**
1. **Que suene bien dicho en el juego.** Los textos cumplen los límites y el vocabulario (se revisó con un script suelto), pero el oído es de Lucas.
2. **Que entren en la franja de abajo** a 1280 × 720 y en el celular: lo mide T242 con una captura real.
3. **Que la lámina 7 se lea como «en medio de la nada» con las figuras y la nave.** Es lo primero que se mira en la lámina de prueba.
4. **Que Codex mantenga a la ingeniera y la nave iguales** en siete imágenes. Es el riesgo principal de T241; por eso hay hoja de continuidad y hoja de miniaturas.
5. **Cuánto pesa** cada PNG de 1920 × 1080 y el total en la APK: lo mide T242 (T237 define cómo se exporta).

---

## 10. Preguntas para Lucas

Cortas, en orden de importancia. Cada una trae mi recomendación; la respuesta puede ser «✔ todas».

1. **P1 · «Después aparece el mapa jugable».** Entendí que, **si el guardado no tiene ningún nivel ganado**, la intro termina **directo en el nivel 1** (con su cartel de entrada), y si ya hay niveles ganados, en la **selección de niveles** como hoy. **Recomiendo eso.** La otra lectura es que siempre vaya a la selección de niveles, que en un guardado nuevo solo tiene el 1 abierto. ¿Cuál querías?
2. **P2 · Dónde se vuelve a ver.** Dijiste «desde la Wiki o con un botón Intro». **Recomiendo un botón «Ver la intro» en la Wiki, solapa Lore**, y **ningún botón nuevo en el menú principal** (cada botón le saca alto al logo, RF-331, y en el celular ya está justo). Alternativa: un botón «Intro» en el menú principal, o en Opciones.
3. **P3 · El estilo.** ¿**A · Cuaderno de bitácora** o **B · Diapositiva pintada**? **Recomiendo A**, y que la lámina de prueba sean **las dos versiones de la 7**. Y: el epílogo es una pintura digital más realista, ¿aceptás que la intro se vea distinta, o querés repasarlo después con el estilo elegido?
4. **P4 · Que el planeta no tenga nombre en la intro.** Recomiendo **sí**: el nombre «Cántaro» llega después, por el oasis (artículo 2). Si querés que la intro lo diga, hay que cambiar el texto de la lámina 4 o 7.
5. **P5 · Lo que inventé** (§9): «una sola nave», «años de viaje» y los cuatro colonos que se repiten. ¿Te sirven, o preferís otra cosa?

---

## 11. Cómo aprobar

Alcanza con escribir, por ejemplo, *«Acepto todo salvo el texto de la lámina 3 y P1 es la otra opción»*. Lo que se corrija se cambia **acá** (y, si es funcionamiento, en M57); después T241 dibuja y T242 copia los textos. Cuando Lucas lo diga, se anota **la fecha y qué aprobó** en la entrada de T240 de `specs/03-tareas.md`.
