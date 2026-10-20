# T362 · 🎨 Efectos de mejora de torres (M65)

> **Estado: PENDIENTE, a la espera del OK de Lucas a la spec M65 (`01-spec.md`, RF-590 a RF-596) y a la pregunta P-65-6 (efecto único teñido o uno por familia).** La decisión es **D-135**. Esta ficha es el **encargo de arte/animación**; el código lo hace T363 con un dibujo provisional (`_draw`) y T364 integra lo que Lucas apruebe.

- **Ejecutor:** **Codex `gpt-6.1-sol`, esfuerzo medio** · **Depende de:** T360 · **Compuerta:** 🎨 **Lucas aprueba las muestras antes de integrar** (nada va a `assets/` hasta entonces) · **Tamaño:** chico

## Leer
`specs/tareas/README.md` §6, `.claude/rules/arte.md`, **`specs/05-guia-de-arte.md` enteras** (sobre todo §1, §5, §7 «Torres renderizadas» y M36 «Lectura de estados y efectos»), y de `01-spec.md` solo **M65** (RF-590, RF-592, RF-595). Mirar los efectos que ya existen en `assets/sprites/effects/rendered/` (`frost.png`, `explosion.png`) para igualar su mano, y `scenes/effects/ring_effect.gd` (el anillo de hoy).

## Qué hay que producir
**Dos efectos animados de un solo uso** que se ven **sobre una torre** cuando se mejora. Se dibujan **claros y neutros** (blanco cálido y marfil, con un toque de bronce) porque **el juego los tiñe** con el color de cada torre (`modulate`); por eso **nada del dibujo puede depender de un color propio** (si se tiñe de violeta, de celeste o de naranja, tiene que seguir viéndose bien).

| Efecto | Para | Duración | Qué se ve |
|---|---|---|---|
| **«Refuerzo»** | mejora al nivel 2 | 0,5 s (8 cuadros a 16 cps) | Un anillo de luz que **sube** desde la base hasta el mecanismo y se abre, con **5 o 6 chispas** chicas que saltan. Sobrio. |
| **«Maestría»** | mejora al nivel 3 | 0,7 s (8 cuadros a ~11 cps) | Más grande y más lleno: **doble anillo** (uno detrás del otro), un **destello en cruz** en el pico y **8 chispas en abanico**. Se tiene que **leer claramente más fuerte** que el de nivel 2 incluso a 34 px. |

Los dos cuentan **la misma historia** (algo sube y se refuerza); el segundo es el mismo gesto, mejor. Nada de humo, fuego, rayos eléctricos, engranajes ni símbolos: ya tienen dueño (fuego/quemadura, Tesla, mecánico). Nada de texto, números ni la letra A.

## Formato (cerrado, para que T364 sea solo reemplazar archivos)
- **PNG RGBA, atlas de 4 columnas × 2 filas = 8 cuadros de 192 × 192 px** (atlas de **768 × 384**), uno por efecto: `assets/sprites/effects/mejora/upgrade_l2.png` y `upgrade_l3.png`. Orden de lectura: izquierda a derecha, arriba a abajo.
- **Centro del efecto = centro del cuadro (96, 96).** El juego lo coloca sobre el **mecanismo** de la torre. El contenido **no se sale** del cuadro ni toca sus bordes (dejar 8 px de margen).
- **Escala de uso:** el cuadro de 192 px se muestra a **1:1 en el mapa** para una torre de 1 × 1 casilla (la casilla mide 64 px) y se agranda con `footprint` en el Mortero (2 × 2). El contenido visible del «refuerzo» ocupa unos **120 px de diámetro** (≈ 2 casillas) y el de la «maestría», unos **160 px** (≈ 2,5 casillas).
- **Cuadro 1 casi vacío y cuadro 8 totalmente transparente** (el efecto empieza y termina sin salto).
- **Alfa real, sin halo negro ni contorno oscuro** (es luz, no un objeto): los bordes se desvanecen con alfa. Pensados para mezclarse **normal** (el juego puede usar mezcla aditiva; el dibujo tiene que verse bien en las dos).
- **Sin sombras dibujadas, sin tinte de color propio** (saturación baja: blancos y marfiles; el bronce, apenas).
- **Peso:** cada PNG, **menos de 150 KB**. Sin mipmaps (el juego los importa sin ellos, como la intro, M62). Anotar el peso real.
- **Fuentes SVG o raster sin perder el original** en `art/mejoras-m65/sources/`; el empaquetador (`pack.gd`, o el script que arme el atlas) en `art/mejoras-m65/`; **prompts normalizados** en `prompts.md`; `manifest.json` (nombres, tamaños, cuadros, centro, duración).

## Cómo se ve a escala real (obligatorio antes de mostrárselo a Lucas)
1. **Hoja de contacto a escala real:** los 8 cuadros de cada efecto, a **100 %** (192 px) y a **34 px** (el tamaño de los íconos), sobre fondo **verde del pasto de la pradera**, **nieve**, **volcán** y **desierto** (los suelos más difíciles para algo claro; guía §4).
2. **Tinte:** cada efecto con el color de **cinco torres** (`TowerVisual.upgrade_glow_color`: ámbar por omisión, celeste del Hielo, violeta de la Tesla, naranja del Fuego, azul de la Múltiple) multiplicado como lo hace el juego (`modulate`), sobre el mismo suelo. Si alguno se pierde o se ve sucio, **se corrige el dibujo** (más contraste en el centro), no el suelo.
3. **Animación real:** un GIF o un video corto **a velocidad real** (0,5 s y 0,7 s) en bucle lento, con la Ametralladora y el Mortero (2 × 2) debajo, para ver el tamaño frente a la torre.
4. **Escala del celular:** la misma hoja a **70 %** (zoom «Ver todo») y a **150 %** (un celular de 2400 × 1080 con el mundo virtual de 1280 × 720). Tiene que leerse en las dos.
5. **Comparación con el anillo de hoy** (`RingEffect`, 0,3 s): el nuevo tiene que verse **claramente más rico** y a la vez **no tapar** la torre en su cuadro central.
6. Un HTML de comparación en `art/mejoras-m65/comparison.html` (como `art/intro-v1/comparison.html`) que junte todo lo anterior.

## Pasos
1. Producir primero **solo una muestra** del «refuerzo» (los 8 cuadros) y de la «maestría» (los 8 cuadros) y la hoja de comparación. **No tocar** `assets/`.
2. **Mostrarle la muestra a Lucas** (🎨). Si pide cambios (más sutil, más grande, otra forma de chispas), iterar solo en `art/mejoras-m65/`.
3. Con el OK **por escrito** (anotado en la entrada de T362 de `03-tareas.md`), copiar los dos PNG a `assets/sprites/effects/mejora/`. **No** editar código: T364 conecta los archivos. Si aparece algo que el código necesita (por ejemplo, otro tamaño de cuadro), **anotarlo**, no resolverlo.

## Hecho cuando
Los dos atlas, las fuentes, `prompts.md`, `manifest.json`, la hoja a escala real y el HTML de comparación están en `art/mejoras-m65/`; Lucas dio su OK por escrito; los PNG finales están en `assets/sprites/effects/mejora/` con el peso anotado. Commit `T362: …`.

## Frenar si
- Lucas no contestó P-65-6 (si quiere un efecto por familia, el encargo cambia: **preguntar**, no producir seis).
- El tinte vuelve ilegible el efecto sobre algún tema y la única solución es agregar color propio al dibujo: **preguntar**.
- Aparece sola una marca que se parece a una **A**, a un engranaje o a un rayo eléctrico: **repetir**, no dejarla.
- Los cuadros no entran en 150 KB sin perder calidad visible: **avisar el peso** y proponer alternativas, no recortar a ciegas.
