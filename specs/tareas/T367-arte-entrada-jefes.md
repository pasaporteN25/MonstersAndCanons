# T367 · 🎨 Entrada de jefes: destello, grieta y marco del cartel (M66)

> **Estado: PENDIENTE, a la espera del OK de Lucas a la spec M66 (`01-spec.md`, RF-597 a RF-602) y a las preguntas P-66-1 y P-66-5.** Las decisiones son **D-138 a D-140**. Esta ficha es el **encargo de arte/animación**; el código lo hace T368 con dibujo provisional (`_draw` y un `StyleBox`) y T369 integra lo que Lucas apruebe. **El retrato del jefe NO se dibuja: se usa la imagen que ya tiene** (`data/enemies/boss.tres`, `assets/sprites/enemies/rendered/boss.png`).

- **Ejecutor:** **Codex `gpt-6.1-sol`, esfuerzo medio** · **Depende de:** T365 · **Compuerta:** 🎨 **Lucas aprueba las muestras antes de integrar** (nada va a `assets/` hasta entonces) · **Tamaño:** mediano

## Leer
`specs/tareas/README.md` §6, `.claude/rules/arte.md`, **`specs/05-guia-de-arte.md` entera** (sobre todo §1, §4, §5, §8 y M36 «Lectura de estados y efectos»), y de `01-spec.md` solo **M66** (RF-597, RF-598, RF-602) y **RF-466** (el cartel de entrada de nivel: hierro y bronce) y **RF-574** (la tarjeta del tutorial). Mirar `assets/sprites/enemies/rendered/boss.png` (el Soberano, carmesí), `data/levels/level_01.json` (la entrada del camino está en la esquina de arriba a la izquierda: la «A» de `mapa`) y `art/intro-v1/comparison.html` como ejemplo de HTML de revisión.

## Qué hay que producir
Tres piezas que **se tiñen con el color del enemigo** (cada jefe de los datos tiene el suyo), así que se dibujan **claras y neutras**.

1. **Destello de aparición** (`boss_burst.png`): una animación de un solo uso en la **entrada del camino**, vista desde arriba/atrás como el resto del mapa renderizado (guía §7: perspectiva ortográfica elevada, luz arriba a la izquierda). Un **resplandor que sube desde el suelo**, **polvo y esquirlas de piedra** que saltan hacia arriba y los costados, y un **aro de choque** que se abre sobre el suelo. Se tiene que sentir **«algo grande llegó»** sin tapar al jefe: el jefe aparece en el mismo instante y camina, así que el centro del destello tiene que **aclararse hacia el final**.
2. **Grieta** (`boss_crack.png`): un **decal quieto** de suelo agrietado, con **polvo apagado**, que se queda debajo del destello 0,7 s y se desvanece. Oscura (marrón-gris), **sin color propio** (no se tiñe).
3. **Marco del cartel** (`boss_card_frame.png`): un marco **hierro y bronce con remaches** (la misma familia que el cartel de entrada del nivel, RF-466) para el cartel de aparición, de **9 trozos** (9-slice): esquinas con remaches, bordes que se estiran, **centro transparente**.

**Qué evitar:** nada de texto, números ni la letra A (el marco **no** lleva «A» ni emblema de ninguna comunidad); nada que sea un fuego o un rayo (ya tienen dueño); nada que dependa de la forma de *un* jefe (el destello sirve para el Jefe, para el Coloso y para los que vengan).

## Formato (cerrado, para que T369 sea solo reemplazar archivos)
- **Destello:** PNG RGBA, atlas de **4 columnas × 2 filas = 8 cuadros de 256 × 256 px** (**1024 × 512**), `assets/sprites/effects/jefe/boss_burst.png`. **Centro del efecto = el punto de los pies del jefe = (128, 176)** de cada cuadro (más espacio arriba que abajo, porque el polvo sube). El contenido **no toca los bordes** del cuadro (margen de 8 px). **0,7 s** (8 cuadros a ~11,5 cps). Cuadro 1 casi vacío y cuadro 8 totalmente transparente. **Se muestra a 1:1** en el mapa (la casilla mide 64 px: el destello ocupa unas 3 casillas de ancho).
- **Grieta:** PNG RGBA **192 × 96**, `boss_crack.png`, centrada, bordes con alfa, sin sombra dibujada.
- **Marco:** PNG RGBA **192 × 128**, `boss_card_frame.png`, con **márgenes de 32 px** en los cuatro lados (donde el juego corta el 9-slice), **centro transparente**. Se usa a **720 × 120 px**: tiene que estirarse sin deformar los remaches (los remaches solo en las esquinas y los bordes se repiten o son lisos).
- **Alfa real; sin halo negro** en el destello (es luz y polvo). El marco **sí** lleva contorno `#2b2233` (es una pieza de hierro y bronce como las torres y el mapa; guía §2) y **un solo brillo** por pieza grande.
- **Sin sombras dibujadas.** **Peso:** destello **menos de 250 KB**, grieta **menos de 30 KB**, marco **menos de 40 KB**. Sin mipmaps. Anotar el peso real.
- **Fuentes sin perder el original** en `art/jefes-m66/sources/`; empaquetador (`pack.gd` o el script del atlas) en `art/jefes-m66/`; **prompts normalizados** en `prompts.md`; `manifest.json` (nombres, tamaños, cuadros, punto de los pies, duración, márgenes del 9-slice).

## Cómo se ve a escala real (obligatorio antes de mostrárselo a Lucas)
1. **Hoja de contacto del destello** a **100 %** (256 px) y a **34 px**, sobre el **suelo y el camino de la pradera** (el tema del nivel 1), con el Jefe de 34 px al lado como referencia.
2. **El tinte:** el destello multiplicado por el **carmesí del Jefe** (`#ba403e`) y por el color de dos jefes ficticios (azul acero, verde) para ver que el tinte no lo ensucia.
3. **Prueba sobre el nivel 1 real:** una captura de la entrada del camino del nivel 1 (esquina de arriba a la izquierda del mapa, **en 1280 × 720**, con la barra de arriba) con el destello puesto cuadro por cuadro (los 8 cuadros en fila) y el Jefe (`boss_walk.png`) encima. Se verifica que **no tape al jefe** y que **no tape la barra de arriba** (la entrada está cerca de ella).
4. **El marco, con el cartel armado:** un cuadro de **720 × 120 px** con el marco, el **retrato del Jefe** (`boss.png`) a 96 px a la izquierda y tres líneas de texto de ejemplo («¡Llega el Jefe!», «Jefe», la frase de `boss.tres`) a la derecha; en **1280 × 720** debajo de la barra de arriba, y a **150 %** (un celular de 2400 × 1080). El texto tiene que leerse al menos a **20 px**.
5. **GIF o video corto a velocidad real** (0,7 s) del destello en bucle lento.
6. **Un HTML de comparación** en `art/jefes-m66/comparison.html` que junte todo lo anterior.

## Pasos
1. Producir primero **una muestra** de las tres piezas y la hoja de comparación. **No tocar** `assets/`.
2. **Mostrarle la muestra a Lucas** (🎨). Si pide cambios, iterar solo en `art/jefes-m66/`.
3. Con el OK **por escrito** (anotado en la entrada de T367 de `03-tareas.md`), copiar los tres PNG a `assets/sprites/effects/jefe/`. **No** editar código: T369 los conecta. Si el código necesita otra cosa (por ejemplo otro punto de apoyo), **anotarlo**.

## Hecho cuando
El atlas, la grieta, el marco, las fuentes, `prompts.md`, `manifest.json`, las hojas a escala real y el HTML de comparación están en `art/jefes-m66/`; Lucas dio su OK por escrito; los PNG finales están en `assets/sprites/effects/jefe/` con el peso anotado. Commit `T367: …`.

## Frenar si
- Lucas pide **animar al jefe** (rugido, pose) o dibujar un retrato nuevo: es otro encargo (P-66-5); **preguntar** antes.
- El destello solo se ve bien con un color propio y el tinte lo arruina: **preguntar**, no hornear el carmesí del Jefe (rompería la generalización).
- Los PNG no entran en el peso sin perder calidad visible: **avisar el peso** y proponer 6 cuadros en lugar de 8.
- Aparece sola una marca que se parece a una **A** o a un símbolo de comunidad: **repetir**.
