# 05 — Guía de arte

Cómo se dibuja todo lo que se ve en el juego, para que **los enemigos, las torres, los temas del mapa y lo que venga después parezcan hechos por la misma mano**. Nació del rediseño de los nueve enemigos (T127) y del estilo del Tanque que Lucas aprobó como referencia (RF-151, D-023). Si un dibujo nuevo choca con esta guía, gana la guía; si la guía se queda corta, se cambia **acá** primero (igual que la spec, constitución P3).

## 1. Qué se busca

- **Excepción provisional T244 (RF-484):** Coloso y Pedazo son piedra que camina, sin ojos, cara, gesto, garras ni intención; no llevan marcas de los Moradores ni escudo. Comparte material pétreo con el Guardián, en basalto más oscuro y vetas ámbar apagadas. Pendiente de aprobación artística de Lucas.
- **Bestias con carácter, nunca infantiles:** ojos chicos y rasgados, colmillos, garras, púas. Nada de ojos redondos enormes, sonrisas ni caritas.
- **Se reconocen por la silueta.** Un enemigo tiene que distinguirse de los otros **tapando los colores**: por eso cada especie tiene una forma propia (lobo, lagarto, tortuga, wyvern, escarabajo, troll, araña…).
- **Se leen chicos.** Los dibujos se ven a **34 px** en el juego y en los íconos, y a **112 px** en la Wiki. Un detalle que desaparece a 34 px no aporta: se saca o se agranda.
- **Un color por especie**, y ese color no se repite en otra (el jugador ya los reconoce por el color, RF-151).
- **Vista lateral, mirando a la derecha.** Las torretas, también: apuntan a la derecha y giran sobre el centro.

## 2. Cómo se hace un SVG (la técnica)

| Qué | Regla |
|---|---|
| **Lienzo** | `viewBox="0 0 64 64"`, `width="64" height="64"`, **fondo transparente**. |
| **Apoyo** | Las patas de un enemigo apoyan alrededor de **y = 57**; la criatura ocupa aproximadamente de x = 4 a 58. El tamaño en el juego lo da `size_tiles` de los datos, no el dibujo. |
| **Contorno** | Enemigos: **`#202330`**, ancho **2** (1 para detalles chicos). Torres y decoración del mapa (anteriores): `#2b2233`. Son casi iguales pero **no se mezclan dentro de un mismo dibujo**. Puntas y uniones redondeadas: `stroke-linecap="round" stroke-linejoin="round"`. |
| **Relleno** | Un **degradé de 3 paradas** (luz → medio → sombra), de arriba hacia abajo y apenas inclinado (`x2="0.25"`). Cada especie tiene su terna (tabla de abajo). |
| **Hueso y cuernos** | Degradé `#fff0ce` → `#ab8c69`. |
| **Ojos** | Rasgados, amarillo cálido `#ffe19a`, con una raya de ceja oscura arriba. |
| **Brillo** | **Una** línea clara por pieza grande (lomo, placa, ala), no más. Da volumen sin ensuciar. |
| **Facetas** | Los cuerpos duros (placas, caparazones, rocas) se arman con **2 a 4 piezas** con su propia línea de luz, formas angulosas. |
| **Prohibido** | Texto, filtros y desenfoques (`blur`, sombras SVG), imágenes incrustadas, degradés en el contorno, y **sombras dibujadas**: la sombra bajo torres y enemigos la pone el juego (RF-126). |
| **Comentario** | Una línea en castellano al principio: qué es, cómo se ve, "vista lateral hacia la derecha; fondo transparente". |

## 3. La paleta de los enemigos

Cada terna es **luz / medio / sombra** del degradé de relleno. Los nuevos enemigos usan un color que **no** esté en esta tabla.

| Enemigo | Especie | Luz | Medio | Sombra |
|---|---|---|---|---|
| Normal | Lobo de ceniza (gris azulado) | `#bbc1c7` | `#7e8798` | `#40485e` |
| Rápido | Lagarto corredor (ámbar) | `#ffe188` | `#eeb333` | `#a55a24` |
| Tanque | Behemot acorazado (marrón) | `#c99559` | `#926037` | `#53362d` |
| Blindado | Escarabajo rinoceronte (azul acero) | `#abcbe6` | `#547ea9` | `#283e65` |
| Volador | Wyvern (violeta) | `#c59bf4` | `#9260cb` | `#473366` |
| Jefe | Soberano (carmesí) | `#f18466` | `#ba403e` | `#602a39` |
| Troll | Troll de musgo (verde) | `#afc77d` | `#72954e` | `#344f3e` |
| Araña | Matriarca (verde azulado) | `#76bdb5` | `#377e85` | `#234550` |
| Cría | Cría de araña (verde agua claro) | `#bbe5c9` | `#70b8ad` | `#3c787e` |
| Guardián | Gólem de piedra (marfil) con escudo dorado | `#f2e8cf` | `#c8b78c` | `#7b6a4a` |
| Curandero | Criatura con un bulbo luminoso (verde amarillento) | `#e8f08a` | `#b6cf3c` | `#5f7a23` |
| Chamán | Encapuchado con un bastón que chispea (rosa magenta) | `#f0a3d8` | `#c8449e` | `#6b1f5a` |
| Espejo | Tortuga de cristal facetado (cian frío) | `#d7f6ff` | `#7fd0e6` | `#2f7f9d` |
| Coloso (T244, **PROVISIONAL**) | Basalto cálido con vetas ámbar apagadas | `#a69b88` | `#625d54` | `#302f2d` |
| Pedazo (T244, **PROVISIONAL**) | Lasca del mismo basalto, caras de fractura oscuras | `#948a77` | `#555149` | `#292827` |
| Ratero (T257, **PROVISIONAL**) | Criatura baja y alargada, cobre rosado claro | `#f6c3a9` | `#c98269` | `#76453f` |
| Cargador (T257, **PROVISIONAL**) | Criatura ancha, terracota oscura, bolsa de lona dominante | `#dca58f` | `#a5614c` | `#583c36` |

Paletas de T244 y T257, todavía **no aprobadas**: las de T244 son referencias de material de los PNG renderizados, no tres colores planos exactos; las de T257 son las ternas exactas de los degradés SVG que se rasterizan a PNG. Se reservan para la revisión de Lucas.

**Tonos que todavía están libres** para enemigos nuevos: **ninguno de los grandes**; para un enemigo más habría que **oscurecer o aclarar** uno existente con cuidado, o usar un detalle distintivo (un brillo, una piedra). Ya se usaron el marfil y el amarillo verdoso (Guardián y Curandero) y el rosa magenta y el cian frío (Chamán y Espejo). Las crías y sus madres son de la misma familia de color, y los enemigos "de la misma banda" (por ejemplo, los que dan aura) pueden compartir un detalle (un brillo, una piedra) sin compartir el color.

## 4. Los temas del mapa (M15)

- **El camino siempre se lee sobre el suelo:** la diferencia de claridad entre suelo y camino tiene que verse **con los ojos entrecerrados**. Es lo primero que se revisa en cada tema.
- **Lo construible y lo bloqueado se distinguen de un vistazo:** un objeto de decoración (roca, cactus, pino, columna) nunca se parece a una torre ni a un enemigo.
- **Ningún enemigo se pierde sobre ningún suelo.** Cuidado especial: el Troll (verde) en el bosque y el pantano, la Araña y la Cría (verdes azulados) en la nieve y el pantano, el Lobo (gris) en las ruinas y el volcán. Cada tema se aprueba con una hoja que pone **todos los enemigos sobre su suelo y su camino**, a 34 px. Si alguno se pierde, se corrige el **suelo del tema** (menos saturado, más claro u oscuro), no el enemigo.
- **Los objetos de un tema usan la misma técnica** (contorno, degradé de 3 paradas, una línea de luz); los suelos (agua, hielo, lava, barro) son **planos con reflejos**, sin contorno grueso.
- **Los siete temas** están en la práctica en `scripts/logic/map_themes.gd` (paleta y decoración) y sus mapas de ejemplo en `tools/ejemplos/`. La revisión de M15 mostró que con el **contorno oscuro** de los enemigos ninguno se pierde sobre ningún suelo; lo que sí falló fue el **camino** (en el bosque y el pantano casi se confundía con el suelo) y por eso hay un test que mide su diferencia de claridad.
- **El pasto, el camino y el borde de cada tema** salen de una paleta en código (plan §6.12, `MapThemes`); los dibujos de decoración son SVG en `assets/sprites/map/`.

## 5. Cómo se comprueba un dibujo nuevo

1. **Importa sin errores** en Godot y tiene **64×64** (los tests de sprites lo verifican).
2. **Hoja de contacto:** todos los dibujos del grupo juntos, a **220 px** y a **34 px**, sobre el suelo del juego. Se mira: ¿se distinguen por la silueta?, ¿se lee lo que es?, ¿se parece a alguno existente?
3. **En el juego:** una captura de una partida real con el dibujo en movimiento (el brillo y las facetas se ven distinto en pantalla).
4. **Lucas aprueba** las capturas antes de darlo por terminado (como con los temas, T123).

## 6. De dónde vienen los dibujos actuales

- Los **nueve enemigos** se redibujaron en T127 con un generador (`redesign.py`, en `build/enemy-redesign/`, que **no se versiona**: la carpeta `build/` está ignorada por git). **La fuente de verdad es el SVG** de `assets/sprites/enemies/`; los originales de antes y las comparaciones "antes/después" quedaron en esa carpeta.
- **Torres, proyectiles, íconos y decoración del mapa** son los de M4/M5 (T70–T73, T84): contorno `#2b2233` y bases de madera, piedra y piedra con oro. Se pueden rediseñar más adelante con esta misma guía; hoy conviven sin problema.
- **Enemigos con habilidad** (B-07): el Guardián y el Curandero (M17) y el Chamán y el Espejo (M18) ya están; quedan el Excavador y el Ladrón. Sus ideas de aspecto están en el backlog y se ajustan a los tonos libres de la tabla.

## 7. Torres renderizadas (M23, D-049)

Para las torres nuevas, esta sección reemplaza las reglas de SVG y vista lateral de §1–2. Los enemigos y la decoración existentes siguen con sus reglas anteriores.

- **Familia A:** cañón y mortero, hierro oscuro, bronce y madera; cilindros torneados y soportes robustos.
- **Familia B:** básica, francotirador, fuego, múltiple y ráfaga, acero y blindaje industrial. Básica oliva, rifle verde oscuro, fuego cobre/naranja, múltiple azul acero, ráfaga rojo oscuro. El mecanismo diferencia más que el color.
- **Familia C:** hielo y Tesla, metal claro, bronce y cristal. Hielo celeste facetado; Tesla bobinas con energía violeta y esfera eléctrica.
- **Lo común:** perspectiva ortográfica elevada, luz arriba a la izquierda, grandes biseles y reflejos; detalles pequeños subordinados a la silueta a 64/34 px. No se trazan de nuevo como SVG las imágenes aprobadas.
- **Formato:** PNG RGBA, atlas 512×256 de 4×2 cuadros de 128×128. Orden E, SE, S, SO, O, NO, N, NE. La vista independiente y las bases miden 128×128. Mipmaps y filtrado lineal. Separar el mecanismo que gira de la base fija; la sombra del suelo la dibuja Godot.
- **Fuentes y reproducción:** art/redesign-m23/sources conserva las hojas originales; tools/prepare_tower_sprites.gd produce los recursos consumidos por el juego. No sobrescribir estos PNG mediante los generadores SVG históricos de art/prototypes.
- **Revisión:** capturas de mapa, combate, HUD y Wiki; hoja del conjunto; revisión de las ocho direcciones. Es una primera producción con imágenes generadas: cualquier deriva entre cuadros se anota y se corrige, no se da por modelado 3D real.

**Siguiente etapa de arte:** primero suelo/camino y decoración (material y perspectiva comunes), después enemigos (volumen preservando especies y tamaños), finalmente paneles/wiki/selección de niveles. El HUD ya aceptado permanece como referencia de legibilidad. No se cambia todo el juego sin revisar cada grupo.

## 8. Monstruos renderizados (M24, D-050)

Normal (diablillo rojo), Rápido (bestia turquesa) y Tanque (ogro de piedra y piel verde) son PNG RGBA de **256×256**, **una sola vista** con la luz arriba a la izquierda, sin sombra dibujada (la pone el juego). Cuerpo al 63,4 % del alto como máximo y pies al 74,55 % del alto; los genera `tools/prepare_monster_sprites.gd` desde `art/redesign-m24/sources/`. **No se reflejan en espejo** (`flip_when_walking_left = false`) y todavía no tienen cuadros de caminar: lo que falta pedir está en `art/FORMATO_PROXIMA_ENTREGA_M24.md`. Los otros diez enemigos siguen con las reglas de §1–2.

## M36 · Lectura de estados y efectos
Placa de nivel: hierro/bronce, remaches ámbar siempre legibles; no depende del brillo animado. Aturdimiento: aro roto violeta y descargas sobre el mecanismo, sin tapar base/sombra. Cura: límite verde amarillento suave y brotes en cura efectiva; no usar oro ni blanco de daño. Muerte: conservar la pose y escala de la criatura, disolver con shader y ocho fragmentos facetados; sin deformaciones corporales, sombras nuevas ni nuevos ciclos falsos. Efectos finitos respetan pausa/velocidad y topes (12 residuos de muerte,16 pulsos de cura).

### M37 · Apoyo y avance coleccionable
Avance genérico: disco plateado con silueta de nave, sin engranaje exclusivo del mecánico, reutilizable para futuros desbloqueos. Mecánico: estatua fija de hierro/plata y bronce, casco de guerra y engranaje, distingue apoyo de un cañón. Diseño vectorial inicial nativo, luz arriba/izquierda, sin sombras incrustadas; revisión por Lucas antes de declarar arte definitivo. No modifica atlas aprobados. Aura de apoyo fina y cian/gris, sin confundirla con curación verde o aturdimiento violeta.

### M39–M41 · Diseños iniciales de mecánicas
Ladrón: vector nativo encapuchado con bolsa; Embestidor: Bestia B reservada de M24, pose única. Desgaste usa grieta ámbar y reparación herramienta cian sobre base, con texturas compartidas para preservar rendimiento. No confundir con aura verde de cura enemiga ni chispas magenta de stun. Muestras reales en art/mechanics-m41; diseños iniciales revisables por Lucas, sin aprobación artística definitiva.

### M43 · Rediseños B-31 (D-070)
Embestidor: anatomía pesada del antiguo Curandero, casco óseo/cuerno frontal, placas hierro/bronce y piel oliva oscura; sin bulbo ni resplandor de cura. Curandero: criatura erguida vegetal, semilla medicinal verde amarillenta en herramienta, bolsa de hierbas; silueta distinta del Chamán por cabeza descubierta y textura orgánica. Ladrón: encapuchado gris violeta desaturado, manos/bolsa reconocibles. Mecánico: estatua fija de hierro/plata/bronce, casco y engranaje, mismas bases y luz que los cañones. PNG con alfa, cuatro direcciones por cuatro fases en enemigos; anclaje/escala uniformes. Materiales predominan sobre color; no reflejar atlas ni alterar parámetros jugables. Producción inicial para revisión de Lucas, no aprobación definitiva.

**Aprobación M43:** Lucas aprobó los cuatro rediseños el 2026-10-04 (“Excelente los apruebo”). Son la referencia vigente para estos personajes; B31 cerrado. Fuentes y prompts conservados.

### T257 · La Cuadrilla (provisional, RF-490)

Ratero y Cargador son criaturas independientes: sin símbolo A, marcas comunitarias, capucha ni capa. Ratero bajo y horizontal; Cargador ancho con bolsa más grande que el cuerpo. Familia cobre rosado / terracota; lona neutra. Fuentes SVG nativas rasterizadas a PNG RGBA 256×256 y ciclos 1024×1024 (4 direcciones × 4 fases), apoyo en y=191, sin sombra. La iluminación no se refleja con la dirección. Las paletas y siluetas están **pendientes de aprobación de Lucas**; hoja con el Ladrón aprobado en `art/t257-cuadrilla/captures/contact_sheet.png`. Es una propuesta vectorial más simple que los PNG renderizados, no arte definitivo. No integrada ni capturada en partida en este despacho.
