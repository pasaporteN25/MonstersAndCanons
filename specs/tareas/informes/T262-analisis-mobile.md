# T262 · Análisis de la experiencia en celular (mobile)

> **Estado: ANÁLISIS HECHO, PROPUESTAS A LA ESPERA DE LUCAS (G7).** Escrito el 2026-10-16 por Claude (Opus 5.5, esfuerzo medio), tarea **T262** (B-33, con B-34 a B-36 como entradas). **No se tocó código, escenas, datos ni assets del juego.** Lo nuevo es una herramienta de sondeo (`tools/mobile_probe.gd`), dos opciones de diagnóstico en `tools/perf_levels.gd` y las capturas de `art/t262-mobile/`.
>
> **Pedido de Lucas (2026-10-16):** analizar y optimizar la experiencia en el celular hasta equipararla con la de escritorio. Este informe es la parte de **análisis**: problemas reproducibles, mediciones, propuestas ordenadas por impacto y costo, tareas chicas y un kit para medir en el celular real. **No implementa ninguna optimización** (T262, «Hecho cuando»).
>
> **Límite principal, dicho de entrada:** en esta máquina **no hay celular** (`adb devices` no lista ningún dispositivo). Todo lo de abajo se midió **en escritorio, con la proporción de un celular** y con toques simulados. Donde un resultado depende del celular real se dice, y el §7 junta todo lo que no se probó.

## 0. Resumen (para quien lea solo esto)

1. **En el celular, el juego es el de escritorio achicado.** El lienzo es fijo de 1280 × 720 (`project.godot:34-36`) y se escala entero. En un celular de 1080 × 2400 acostado (6,5", ~405 ppi, supuesto de este informe) la escala es **1,5** y queda una **franja negra de 240 px a cada lado** (`stretch/aspect` = `keep`, verificado por la herramienta): se usa el **80 % del ancho**; el mapa ocupa el **64 % de la pantalla**.
2. **Casi todo lo que se toca mide menos de lo recomendado.** Material Design pide 48 dp (≈ 7,6 mm) para un control táctil. En el celular supuesto, **Pausa, velocidad y «← Menú» miden 3,0 mm de alto**, **Apuntar, Mejorar y Vender 3,0 a 3,2 mm**, los **botones de torre 7,1 × 5,6 mm**, las **pestañas 9,0 × 4,1 mm** y los botones de la pestaña Infraestructura **2,1 a 2,4 mm**. De 97 controles visibles medidos en 12 pantallas, solo pasan la marca las 10 tarjetas de nivel que se ven (§1.6).
3. **Las casillas también son chicas, y no hay zoom.** Una casilla mide **6,0 mm** en los niveles 1 a 9, **4,9 mm** en el 10 y el 11, **4,6 mm** en el 12 y **4,5 mm** en el 13 al 15. En el 15, **un toque a 0,6 casilla del centro ya cae en la casilla de al lado** (prueba de la herramienta). En el código no hay pinza ni desplazamiento: la cámara solo encuadra los mapas grandes (`game.gd:287-299`).
4. **Construir cobra al apoyar el dedo, sin ver antes dónde ni confirmar.** Con una torre elegida, el primer toque en el mapa **compra en ese instante** (`build_controller.gd:272-280`, al apretar y no al soltar: `:315-317`), y la elección sigue activa para la siguiente (RF-43). Con toques simulados: **arrastrar el dedo compró una torre, y una pinza de dos dedos también** (§1.3, pruebas B y C).
5. **Vender está pegado a Mejorar y no pide confirmación.** Hay **6 px virtuales (0,6 mm en el celular)** entre los dos botones; un toque simulado **8 px debajo del borde de Mejorar vendió la torre** al instante (§1.4, prueba E). Mejorar y vender cuestan **2 toques y ningún diálogo**: el problema de B-34 no es la cantidad de diálogos, sino el **panel grande que tapa el mapa** (270 × 356, la torre elegida queda debajo si está en las columnas de la derecha, prueba F) y la **cantidad de texto** que muestra.
6. **Información que solo está en el «pasar el mouse».** Los nombres de las torres y la marca «Nueva» de las tarjetas, el progreso de los avances y el motivo de un botón gris viven en `tooltip_text`, que en el celular no aparece (§1.7). La barra de arriba sí tiene alternativa táctil (al tocar un ícono se muestra su nombre).
7. **Rendimiento en escritorio: holgado en promedio, con tirones.** Con la GTX 1660 Super y la máquina cargada por los bots de T266 (carga 5 a 6 en 12 hilos), con una defensa realista el nivel 15 da **130 a 154 FPS de promedio** (el 1 % más lento, 60 FPS en la última oleada) y los niveles 1 y 7, **270 a 356**; en todas las corridas aparecen **tirones aislados de 37 a 63 ms** cuya causa no se pudo separar de la carga (§3). **Eso no dice nada de un celular:** hay que medirlo allá con el kit del §6.
8. **No hay registro de una prueba en un celular desde hace 17 días.** La última fue TA3 (2026-09-29; Lucas: «funcionó bien como concepto»). Las APK posteriores (T179, T190) se exportaron pero sus resultados dicen que no se ejecutaron en un celular, y la de la 1.0 no se había generado (`CHANGELOG.md:36`). La barra con pestañas, las tarjetas nuevas y los niveles nuevos **no tienen registro de haber corrido en Android**. En esta máquina hoy sí se puede exportar: **se generó una APK de prueba** (§6.1), así que lo primero es instalarla y correr el kit.
9. **Propuesta:** 12 tareas chicas (§5), ordenadas por impacto y costo. Las tres primeras son baratas y sacan el riesgo de perder oro por error: **confirmar o separar «Vender»**, **agrandar los botones de la barra de arriba y del panel solo en el celular** y **quitar las etiquetas de teclado en el celular**. El zoom (B-35) y la nueva colocación son las de más impacto y las más caras: las diseña T264.

## 1. Relevamiento del flujo táctil (con el código)

### 1.1 Cómo llega un toque al juego

- **No hay código táctil propio en la partida.** Los toques llegan como **clics emulados**: `input_devices/pointing/emulate_mouse_from_touch` está en `true` (valor por omisión de Godot; `project.godot` no lo cambia; la herramienta lo leyó). Solo la intro (`intro_screen.gd:250`) y el cartel de entrada (`level_intro.gd:73`) miran `InputEventScreenTouch`, y únicamente para que el toque no pase a lo de atrás.
- **RF-143 (spec §9.4)** es toda la adaptación táctil: «tocar equivale a un clic izquierdo… la vista previa aparece donde se tocó; para dejar de construir se toca otra vez el botón de la torre elegida». §11 deja fuera «controles táctiles propios (arrastrar para construir, gestos, zoom)».
- **Atrás de Android** = `Esc` (RF-142): `game_flow.gd:53-60` lo convierte en la acción `cancel`. En la partida: con torre elegida la cancela; si no, abre o cierra la pausa (`game.gd:337-349`).
- **La casilla se calcula con la posición del mouse, no con la del toque.** `BuildController` usa `get_global_mouse_position()` para la vista previa (`build_controller.gd:234`), para elegir (`:285`) y para construir (`:279`). En escritorio eso es **el cursor del sistema**: la prueba A0 (abajo) tocó la casilla (8, 3) y la torre se construyó en la (12, 8), donde estaba el cursor. En Android funcionó en TA3 (2026-09-29), lo que indica que allá la posición del «mouse» sí sigue al dedo; **queda como riesgo** (depende de cómo Godot actualiza esa posición con toques emulados), y por eso la herramienta lleva el cursor al dedo antes de cada toque.

### 1.2 Menús, selección de niveles y entrada a la partida

| Paso | Escritorio | Celular (táctil) | Código |
|---|---|---|---|
| Menú → selección | Clic en «Jugar» (o `Enter`) | 1 toque | `main_menu.gd:57-69` |
| Primera vez | La intro (avanza con clic o tecla; «Omitir») y después el **nivel 1 directo** | Igual: toques para avanzar o «Omitir»; atrás la termina | `main_menu.gd:57-77`, `intro_screen.gd:226-252` |
| Elegir nivel 1 a 10 | 1 clic en la tarjeta | **1 toque**: abre la partida sin confirmar | `level_select.gd:327` |
| Elegir nivel 11 a 15 | Rueda del mouse (la herramienta: `scroll` 0 → 55 con un paso) y clic | **Hay que desplazar**: se ven 2 filas de 5 (`level_select.gd:13-16`). Arrastrar el dedo sobre una tarjeta **no desplazó en escritorio** (0 → 0) **ni abrió el nivel**. *No es concluyente* (ver §7): hay que probarlo en el celular | `level_select.gd:120`, prueba de la herramienta |
| Cartel de entrada | Clic en cualquier parte, `Espacio`, `Enter` o `Esc` | 1 toque en cualquier parte o atrás | `level_intro.gd:55-74` |
| Editor de mapas | Botón en el menú | **No se ofrece** (RF-210), salvo en modo de pruebas | `main_menu.gd:39, 95-96` |
| Mapas de la comunidad | «Abrir carpeta» | La carpeta no se ofrece (`can_add_maps`) | `level_select.gd:302-303` |

**Pasos para jugar un nivel ya abierto: 3 toques** (Jugar → tarjeta → cartel), **0 diálogos**. Igual que en escritorio. El problema no es la cantidad de pasos sino el tamaño y lo que no se ve (§1.6 y §1.7).

### 1.3 Comprar y colocar una torre

| | Escritorio | Celular |
|---|---|---|
| Elegir torre | Clic en su botón o tecla `1` a `0` | 1 toque en su botón (7,1 × 5,6 mm) |
| Ver dónde va | La vista previa **sigue al mouse antes de comprar** (verde/rojo, alcance) | **No hay vista previa antes de tocar**: aparece donde se tocó, **después** de comprar (RF-143) |
| Construir | Clic en la casilla | **El mismo toque que «muestra» compra**, al apoyar el dedo (`build_controller.gd:272-280`; `_is_click` mira `pressed`, `:315-317`) |
| Otra igual | Otro clic (RF-43) | Otro toque: **cualquier toque en el mapa compra mientras la torre siga elegida** |
| Dejar de construir | Clic derecho o `Esc` | Tocar otra vez el botón (prueba D: deja de estar elegida) o atrás |
| En pausa | No se construye (RF-104) | Igual: elegir sí, tocar el mapa no hace nada (prueba G) |
| Torres de 2 × 2 | El cuadrado se centra en el mouse (`build_controller.gd:118-121`) | Igual, centrado en el dedo: el dedo tapa justo el centro |
| **Total** | **2 clics**, con vista previa antes | **2 toques**, sin vista previa ni confirmación |

**Pruebas con toques simulados** (`tools/mobile_probe.gd`, nivel 1, ventana 1600 × 720, salida en `art/t262-mobile/`):

- **A0 · sin llevar el cursor al dedo:** toque en la casilla (8, 3) → torre construida en la (12, 8), donde estaba el cursor del sistema. Solo pasa en escritorio; muestra la dependencia del §1.1.
- **A · toque en el botón y toque en la casilla:** la torre se construye **al apoyar el dedo** en la casilla tocada. 2 toques, 0 diálogos. Captura: `partida_n01_vista_previa_20x9.png` (la vista previa queda en la casilla recién comprada).
- **B · arrastrar 128 px (2 casillas) con la torre elegida**, como quien intenta mover el mapa: **compró una torre** donde se apoyó el dedo (torres 1 → 2).
- **C · pinza de dos dedos con la torre elegida** (el gesto de zoom): **compró una torre** bajo el primer dedo (2 → 3). Hoy no hay zoom que lo aproveche.
- **Nivel 15 con cámara (zoom 0,75):** el toque cae en la casilla correcta (la cámara no rompe la cuenta), pero **29 px virtuales de corrimiento (0,6 casilla, 2,7 mm en el celular supuesto) ya es la casilla de al lado**.

### 1.4 Mejorar y vender

| | Escritorio | Celular |
|---|---|---|
| Abrir el panel | Clic en la torre | 1 toque en la torre (casilla de 4,5 a 6,0 mm) |
| Mejorar | Clic en «Mejorar» **o tecla `U`** | 1 toque en «Mejorar» (22,8 × 3,2 mm) |
| Vender | Clic en «Vender» o tecla `S` | 1 toque en «Vender» (22,8 × 3,0 mm), **sin confirmación ni deshacer** |
| Cerrar el panel | Clic derecho, `Esc` o clic en una casilla vacía | Toque en una casilla vacía, o atrás |
| **Total** | 2 clics (o 1 clic + 1 tecla), 0 diálogos | **2 toques, 0 diálogos** |

Código: `game.gd:144-145` conecta los botones directo a `try_upgrade` y `sell`; `tower_panel.tscn:125-141` define los tres botones (32, 34 y 32 px de alto) con `separation = 6` entre ellos. Pruebas:

- **E · toque en «Mejorar»:** sube de nivel 1 a 2, sin confirmación.
- **E · toque 8 px virtuales debajo del borde de «Mejorar»** (un dedo que cae apenas más abajo; ya es «Vender»): **la torre se vende** (torres 3 → 2), sin confirmación. En el celular supuesto, esos 8 px son 0,75 mm.
- **F · torre en la columna 17:** **el panel la tapa** (el panel ocupa x 1000-1270, y 260-616 de la pantalla lógica: en un mapa de 20 × 9, las columnas ~16 a 19 de las filas ~4 a 8). Captura: `partida_n01_panel_tapa_20x9.png`, donde solo se ve el círculo de alcance asomando.
- El panel muestra título, tres números, descripción, «Voladores», efectos, combinaciones y tres botones, con letra de 12 a 19 px virtuales (`tower_panel.tscn:32-141`): **7 a 11 sp** en el celular supuesto. La descripción y los efectos se desplazan dentro de un `ScrollContainer` de pocos centímetros.

**Lectura para B-34:** hoy **no hay diálogos** en la mejora; lo que frena es el **panel**: tapa el mapa, junta información de consulta (descripción, combos) con las dos acciones, y deja la acción destructiva pegada a la principal. Esto va a T263.

### 1.5 Pausa, velocidad, salir, zoom y cámara

| Acción | Celular | Tamaño en el celular supuesto | Código |
|---|---|---|---|
| Pausa | Botón «Pausa [P]» o atrás (abre el menú de pausa) | 12,2 × 3,0 mm | `hud.tscn:244-251`, `hud.gd:241` |
| Velocidad | Botón «x1 [F]» | 9,8 × 3,0 mm | `hud.tscn:263-270`, `hud.gd:247` |
| Salir | «← Menú» → diálogo «Seguir jugando / Salir al menú» (1 diálogo, a propósito: RF-460) | 7,5 × 3,0 mm; el diálogo, 18,4 × 4,9 mm | `game.gd:433-447` |
| Empezar oleada | Botón grande | 23,0 × 5,3 mm (el más grande de la partida) | `hud.tscn:201-208` |
| Menú de pausa | Continuar, Reintentar, Opciones, Salir al menú | 30,1 × 4,9 mm cada uno | `pause_menu.tscn:62-87` |
| **Zoom** | **No existe.** Solo el encuadre automático de los mapas grandes | — | `game.gd:287-299`, `rules.gd:21-24` |
| **Mover la cámara** | **No existe** | — | ídem |

Pausar **cancela la torre elegida** (`game.gd:467-472`) y en pausa no se construye (RF-104): en el celular no se puede «parar y pensar dónde va» con la vista previa, que en escritorio se tiene gratis al mover el mouse.

### 1.6 Tamaño de lo que se toca: píxeles virtuales, reales y milímetros

Cuenta: en 1080 × 2400 acostado (2400 × 1080), escala = mín(2400 / 1280, 1080 / 720) = **1,5**. **1 px virtual = 1,5 px reales = 0,094 mm** a 405 ppi (6,5"). En un 16:9 chico de 720 × 1280 (5", ~294 ppi) la escala es 1,0 y **1 px virtual = 0,086 mm**: todo queda todavía un 8 % más chico. Para comparar: en un monitor de 24" Full HD (92 ppi) la escala también es 1,5, pero **1 px virtual = 0,41 mm** (4,4 veces más grande que en el celular), y el mouse apunta a un píxel.

| Control | Virtual (px) | Celular 1080 × 2400 (px reales) | mm (405 ppi) | mm en 16:9 chico (294 ppi) | ¿Llega a 7,6 mm? |
|---|---|---|---|---|---|
| «← Menú», «Pausa», «x1» | 80–130 × 32 | 120–195 × 48 | 7,5–12,2 × **3,0** | 6,9–11,2 × **2,8** | no |
| Botón de torre | 76 × 60 (56–57 con 11 torres) | 114 × 90 | **7,1 × 5,6** | 6,6 × 5,2 | no |
| Pestañas «Cañones» / «Infraestructura» | 96 × 44 | 144 × 66 | 9,0 × **4,1** | 8,3 × 3,8 | no |
| Botones de la pestaña Infraestructura | 30–70 × 22–26 | 45–105 × 33–39 | **2,1–2,4** de alto | 1,9–2,2 | no |
| Botones de pago (oro / oro + recursos) | según el texto × 28 | × 42 | **2,6** de alto | 2,4 | no |
| Apuntar / Mejorar / Vender | 242 × 32–34 | 363 × 48–51 | 22,8 × **3,0–3,2** | 20,9 × 2,8–2,9 | no |
| Separación Mejorar–Vender | 6 | 9 | **0,6** | 0,5 | — |
| «Empezar oleada» | 244 × 56 | 366 × 84 | 23,0 × 5,3 | 21,1 × 4,8 | no |
| Botones del menú, de la pausa y de Opciones | 320–420 × 52 | 480–630 × 78 | 30–40 × **4,9** | 4,5 | no (cerca) |
| Pestañas de la selección | 130–320 × 42 | 195–480 × 63 | × **4,0** | 3,6 | no |
| Tarjeta de nivel | 200 × 214 | 300 × 321 | 18,8 × 20,1 | 17,3 × 18,5 | **sí** |
| Ícono de torre en la tarjeta | 22 × 22 | 33 × 33 | **2,1** | 1,9 | (no se toca; se lee) |
| Casilla, niveles 1 a 9 (20 × 9) | 64 | 96 | **6,0** | 5,5 | no |
| Casilla, niveles 10 y 11 (24 × 11, zoom 0,818) | 52,4 | 79 | **4,9** | 4,5 | no |
| Casilla, nivel 12 (26 × 11, zoom 0,769) | 49,2 | 74 | **4,6** | 4,3 | no |
| Casilla, niveles 13 a 15 (26 × 12, zoom 0,75) | 48 | 72 | **4,5** | 4,1 | no |

Fuente: `art/t262-mobile/sizes_20x9.csv` y `sizes_16x9.csv` (los escribe la herramienta, un renglón por control visible) y los `custom_minimum_size` de `hud.tscn`, `tower_panel.tscn`, `bar_layout.gd:13-20`, `infrastructure_tab.gd:109-280`, `hud.gd:220`, `level_select.gd:13-19`. Los zooms salen de `Rules.map_zoom` (`rules.gd:23-24`) con los tamaños de `data/levels/*.json`. **Capturas con los controles marcados** (rojo = menos de 7,6 mm, verde = llega): `menu_objetivos_20x9.png`, `seleccion_objetivos_20x9.png`, `partida_n01_objetivos_20x9.png`, `partida_n01_panel_objetivos_20x9.png`, `partida_n15_objetivos_20x9.png`, `partida_n07_infraestructura_20x9.png`.

**Letra.** Con la misma cuenta (densidad ≈ 405 / 160 = 2,53), una letra de *f* px virtuales mide 0,59 · *f* sp en el celular supuesto: **12 px → 7 sp, 14 → 8, 16 → 9,5, 20 → 12, 22 → 13**. Android recomienda 12 sp o más para texto corrido. Por debajo quedan: el panel de torre (12–14), la línea de ayuda de construcción (15–17), las tarjetas (14–16, salvo el número de nivel), la pestaña Infraestructura y el «Próxima oleada» (14). Esto es una cuenta, **no una prueba de lectura**: cuánto se lee de verdad depende del celular y de la persona (§7).

**Superficie útil.** El mapa ocupa 1280 × 576 px virtuales (`rules.gd:13-14`) = 1920 × 864 reales en el celular supuesto = **64 % de la pantalla**; las barras de arriba y abajo, 20 % del alto usado; las franjas negras de los costados, 20 % del ancho. En un 16:9 no hay franjas.

### 1.7 Lo que en el celular no se ve: tooltips sin alternativa

| Qué | Dónde está hoy | ¿Alternativa táctil? |
|---|---|---|
| Nombres de las torres de la tarjeta y la marca «Nueva» | `card.tooltip_text` (`level_select.gd:400`) | **No.** Solo se ve el cuadradito naranja (7 × 7 px virtuales = 0,7 mm) |
| Progreso de avances tecnológicos y del Estandarte | `level_select.gd:320-324` | **No** |
| Lugar completo de la tarjeta (si se cortó con «…») | `level_select.gd:344` | **No** |
| Por qué un botón de torre está gris (falta oro o recursos) | `hud.gd:561-571` (RF-101) | **No** (el gris sí se ve) |
| Nombre y costo de cada torre de la barra | `hud.gd:418-421` | **Sí, al elegirla:** la línea de ayuda muestra nombre, costo y descripción (`hud.gd:510-539`) |
| Íconos de oro, vidas, puntos, oleada, avances y recursos | `hud.gd:136-150` | **Sí:** tienen `focus_mode = FOCUS_ALL` y al tocarlos muestran su nombre |
| Íconos de la próxima oleada (qué enemigo es, si es opcional) | `hud.gd:256-270` | **No** |
| Atajos de teclado `[P]`, `[F]`, `[U]`, `[S]`, `1`…`0` | `hud.gd:241, 247, 414-416`; `tower_panel.gd:108, 111` | Se muestran en el celular aunque no sirven: ocupan lugar y confunden |

### 1.8 Resumen de pasos y diálogos

| Flujo | Toques en el celular | Diálogos | Igual que escritorio | Riesgo táctil principal |
|---|---|---|---|---|
| Entrar a un nivel abierto | 3 | 0 | sí | Niveles 11 a 15 dependen de desplazar (sin probar en el celular) |
| Comprar y colocar | 2 | 0 | sí, pero sin vista previa antes | Compra al apoyar el dedo, al arrastrar y al pellizcar |
| Mejorar | 2 | 0 | sí (escritorio puede usar `U`) | Botón de 3,2 mm; el panel tapa el mapa |
| Vender | 2 | 0 | sí | Pegado a Mejorar, sin confirmar ni deshacer |
| Pausar | 1 | 0 (o el menú, con atrás) | sí | Botón de 3,0 mm; pausar cancela la torre elegida |
| Salir de la partida | 2 | 1 (a propósito) | sí | Botón de 3,0 mm |
| Zoom / mover el mapa | — | — | no existe en ninguno | En el celular es lo que más falta (B-35) |

## 2. Capturas a proporción de celular

Todas son **capturas reales de las escenas del juego** (Godot 4.7.2, OpenGL compatibilidad, GTX 1660 Super), sacadas por `tools/mobile_probe.gd` con un guardado temporal (niveles 1 a 9 ganados, el 10 abierto). La pantalla lógica es siempre de 1280 × 720; la herramienta la pone **dentro del marco negro que agrega `stretch/aspect = keep`** en una pantalla más ancha (20:9 → 1600 × 720), que es lo que se ve en un celular de 1080 × 2400. En 16:9 no hay marco. **No son capturas de un celular**: no muestran la muesca de la cámara, los bordes curvos ni la barra de gestos (§7).

Carpeta: [`art/t262-mobile/`](../../../art/t262-mobile/).

| Pantalla | 20:9 (1080 × 2400) | 16:9 chico (720 × 1280) | Qué se ve |
|---|---|---|---|
| Menú principal | `menu_20x9.png`, `menu_objetivos_20x9.png` | `menu_16x9.png` | Botones de 4,9 mm de alto; franjas negras a los costados |
| Opciones | `opciones_20x9.png` | `opciones_16x9.png` | Deslizadores de 52 px de alto con la perilla del tema |
| Selección de niveles | `seleccion_20x9.png`, `seleccion_objetivos_20x9.png`, `seleccion_abajo_20x9.png` | `seleccion_16x9.png` | La tercera fila (11 a 15) queda fuera; íconos de torre de 2,1 mm |
| Cartel de entrada (nivel 1) | `cartel_entrada_20x9.png` | `cartel_entrada_16x9.png` | |
| Partida nivel 1 | `partida_n01_20x9.png`, `partida_n01_objetivos_20x9.png` | `partida_n01_16x9.png` | Barra de arriba y de torres marcadas en rojo |
| Vista previa después de comprar | `partida_n01_vista_previa_20x9.png` | `…_16x9.png` | La vista previa queda donde se tocó |
| Panel de torre | `partida_n01_panel_torre_20x9.png`, `partida_n01_panel_objetivos_20x9.png` | `…_16x9.png` | Mejorar y Vender pegados |
| Panel que tapa su torre | `partida_n01_panel_tapa_20x9.png` | `…_16x9.png` | La torre de la columna 17 queda debajo del panel |
| Menú de pausa | `pausa_20x9.png` | `pausa_16x9.png` | |
| Diálogo de salir | `dialogo_salir_20x9.png` | `dialogo_salir_16x9.png` | |
| Nivel 7 con pestañas | `partida_n07_pestanas_20x9.png`, `partida_n07_infraestructura_20x9.png` | `…_16x9.png` | La pestaña Infraestructura, con botones de 22 a 26 px |
| Nivel 15 (26 × 12, zoom 0,75) | `partida_n15_20x9.png`, `partida_n15_objetivos_20x9.png` | `partida_n15_16x9.png` | Casillas de 48 px virtuales (4,5 mm) |
| Wiki | `wiki_20x9.png` | `wiki_16x9.png` | |

La versión de escritorio de referencia es la misma imagen a 1920 × 1080 (escala 1,5) en un monitor: no se agregó otra captura porque la pantalla lógica es idéntica; lo que cambia es el tamaño físico (§1.6).

## 3. Rendimiento: FPS y tirones (en escritorio)

**Qué se midió.** `tools/perf_levels.gd` juega las oleadas finales de un nivel real a velocidad 1, con la defensa que alcanza el oro, demoliciones y extracción. Se midió el nivel **1** (simple, 20 × 9), el **7** (pestañas y demoledora) y el **15** (26 × 12, el más cargado). Para T262 se le agregaron dos opciones de diagnóstico (no cambian nada del juego): `window=WxH` (fijar la ventana; sin esto `DesktopWindow` la llevó a 1777 × 1000 aunque se pidiera `--resolution`) y una línea «tirones» con **en qué segundo de la oleada** cae cada cuadro de más de 33,3 ms.

**Máquina.** Linux, GTX 1660 Super, 12 hilos, 30 GB, Godot 4.7.2 OpenGL compatibilidad, **vsync apagado**. Durante todas las mediciones corrían otros agentes y **los bots de T266** (`balance_sim.gd`, 4 procesos con `nice`) y un servidor de `ollama`: la carga se anota en cada fila.

| Corrida | Nivel | Ventana | Torres | Oleada | FPS prom. | 1 % más lento | Peor cuadro | Cuadros > 16,6 ms | Cuadros > 33,3 ms (segundo de la oleada) | Enemigos máx. | Carga antes → después (`uptime`, 1 min) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1ª | 1 | 1777 × 1000 | 123 | 8 / 9 / 10 | 132 / 135 / 132 | 71 / 74 / 67 FPS | 103 / 50 / 53 ms | 5 / 2 / 6 | (sin la línea nueva) | 15 / 16 / 28 | 4,70 → 5,63 |
| 1ª | 7 | 1777 × 1000 | 112–118 | 18 / 19 / 20 | 113 / 111 / 118 | 59 / 62 / 59 FPS | 108 / 57 / 50 ms | 19 / 17 / 40 | (sin la línea nueva) | 31 / 33 / 27 | 5,63 → 5,59 |
| 1ª | 15 | 1777 × 1000 | 64–69 | 28 / 29 / 30 | 153 / 148 / 130 | 74 / 72 / 60 FPS | 53 / 55 / 53 ms | 26 / 9 / 161 | (sin la línea nueva) | 28 / 47 / 43 | 5,59 → 6,33 |
| 2ª | 1 | **1600 × 720** | **30** | 8 / 9 / 10 | 341 / 356 / 348 | 171 / 188 / 167 FPS | 61 / 57 / 48 ms | 4 / 1 / 2 | 3 (1,8 · 6,8 · 9,8 s) / 1 (3,1 s) / 2 (4,1 · 43,6 s) | 24 / 23 / 39 | 6,13 → 5,83 |
| 2ª | 7 | **1600 × 720** | **30** | 18 / 19 / 20 | 270 / 270 / 309 | 123 / 120 / 139 FPS | 55 / 49 / 60 ms | 4 / 4 / 2 | 2 (1,4 · 9,2 s) / 4 (2,9 · 5,1 · 6,2 · 15,2 s) / 2 (5,3 · 58,2 s) | 52 / 45 / 35 | 5,83 → 5,95 |
| 2ª | 15 | **1600 × 720** | 64–69 | 28 / 29 / 30 | 154 / 148 / 130 | 72 / 77 / 60 FPS | 54 / 63 / 52 ms | 29 / 9 / 179 | 7 (0,1 a 77,7 s) / 5 (0,7 a 21,6 s) / 2 (6,1 · 128,3 s) | 28 / 47 / 43 | 5,95 → 8,05 |

Registros completos: `art/t262-mobile/perf_*.txt`. Los 4 bots de T266 corrieron durante **todas** las mediciones (no hubo un momento sin carga); la carga de 1 minuto fue de **4,7 a 8,1** en 12 hilos. Por eso se repitió cada nivel: el nivel 15, que no cambió de defensa entre tandas, dio **los mismos promedios en las dos** (153/148/130 y 154/148/130), así que el promedio es estable con esta carga. Los **tirones** no se pueden separar de la carga con estas corridas.

**Lectura (sin atribuir causas).**

- **El nivel 15 es el más pesado** con una defensa realista (64 a 69 torres, hasta 47 enemigos): 130 a 154 FPS de promedio, y en la oleada 30 el 1 % más lento queda justo en **60 FPS** (179 de 16 700 cuadros pasan de 16,6 ms). En escritorio cumple P7, sin margen en ese 1 %.
- **Los niveles 1 y 7 con 30 torres** van a 270–356 FPS. Con 112–123 torres (lo que compra `perf_levels` sin tope, irreal para una persona) bajan a 111–135.
- **En todas las corridas hay tirones aislados de 37 a 63 ms** (uno a siete por oleada), dispersos a lo largo de la oleada, no solo al empezar. Un cuadro de 50 ms se nota como un salto. **No se atribuye causa:** la máquina estaba cargada por otros procesos durante todas las mediciones, y estas corridas no permiten distinguir entre un tirón del juego y uno del sistema. Si en el celular aparecen tirones (K13), se buscan allá con el monitor de Godot (§6.4); si se quiere saber si existen en escritorio sin carga, hay que repetir las tres corridas con la máquina libre.

**Lo que esto NO dice.** Una GTX 1660 con un procesador de escritorio no se parece a un celular: el GPU de un celular de gama media es varias veces más lento y el procesador se frena cuando se calienta. Estos números sirven como **línea de base** (qué escena pesa más, dónde aparecen tirones) y para comparar después de un cambio. **El rendimiento del celular solo se sabe midiéndolo allá** (§6).

## 4. Problemas priorizados

Impacto: **alto** = se pierde oro, una partida o el acceso a algo; **medio** = incomoda o confunde siempre; **bajo** = estético o de pulido. Costo: **bajo** = cambia una o dos escenas sin tocar reglas; **medio** = toca una regla de la spec o varias pantallas; **alto** = interacción nueva (gestos, cámara) con su spec y sus casos de error.

| # | Problema | Cómo reproducirlo | Evidencia | Impacto | Costo |
|---|---|---|---|---|---|
| **P-01** | **Vender está a 0,6 mm de Mejorar y no se confirma ni se deshace.** | Elegir una torre, tocar 8 px debajo del borde de «Mejorar». | Prueba E; `tower_panel.tscn:125-141`, `game.gd:145`; `partida_n01_panel_objetivos_20x9.png` | **Alto** | **Bajo** |
| **P-02** | **Comprar cobra al apoyar el dedo, sin vista previa antes;** arrastrar y pellizcar con una torre elegida compran. | Elegir una torre; tocar, arrastrar o pellizcar el mapa. | Pruebas A, B y C; `build_controller.gd:268-280, 315-317`; RF-43, RF-143 | **Alto** | **Medio** (T264 elige el flujo) |
| **P-03** | **No hay zoom ni desplazamiento;** las casillas miden 4,5 a 6,0 mm y en el 15 un corrimiento de 2,7 mm cambia de casilla. | Nivel 13 a 15, intentar acertar una casilla con el dedo. | `game.gd:287-299`, `rules.gd:23-33`; prueba del nivel 15; §1.6 | **Alto** | **Alto** (T264) |
| **P-04** | **Botones de la barra de arriba y del panel de 3,0 a 3,2 mm de alto.** | Tocar «Pausa», «x1», «← Menú», «Apuntar», «Mejorar». | `hud.tscn:244-270`, `tower_panel.tscn:125-141`; `sizes_20x9.csv` | **Alto** | **Bajo–medio** |
| **P-05** | **El panel de torre tapa la derecha del mapa, incluida la torre elegida.** | Construir en la columna 16 a 19, filas 4 a 8, y tocarla. | Prueba F; `tower_panel.tscn:7-11`; `partida_n01_panel_tapa_20x9.png` | **Medio** | **Medio** (T263) |
| **P-06** | **Niveles 11 a 15: desplazar la selección con el dedo no está comprobado.** En escritorio, arrastrar sobre una tarjeta no movió la lista (sí lo hace la rueda). | Selección de niveles, arrastrar hacia arriba desde una tarjeta. | Prueba de la selección: `scroll` 0 → 0; `level_select.gd:13-16, 120` | **Alto si falla** en el celular (no se llega a 5 niveles) | **Bajo** si falla |
| **P-07** | **Información solo en tooltips:** torres de la tarjeta y «Nueva», avances, motivo del gris, enemigos de la próxima oleada. | Tocar una tarjeta o un botón gris: no aparece el texto. | §1.7 | **Medio** | **Bajo–medio** (T265 para las tarjetas) |
| **P-08** | **Botones de la pestaña Infraestructura de 2,1 a 2,4 mm.** Medido: «Comprar» (la demoledora), 19,3 × 2,4 mm. Del código (aparecen con un trabajo o con puntos de extracción): Cancelar 70 × 22, flechas 30 × 26, nombre 58 × 24, Habilitar × 24 px virtuales. | Nivel 7 u 11 a 15, pestaña Infraestructura. | `infrastructure_tab.gd:109, 141, 173, 177, 274, 280`; `partida_n07_infraestructura_20x9.png` | **Medio** | **Bajo** |
| **P-09** | **20 % del ancho sin usar en 20:9** (franjas negras de 240 px). | Abrir cualquier pantalla en un celular de 20:9. | `project.godot:34-36` (sin `aspect`, por omisión `keep`); la herramienta lo leyó | **Medio** | **Alto** (`expand` mueve todo el HUD y los menús; riesgo en todas las pantallas) |
| **P-10** | **Letra de 12 a 16 px virtuales = 7 a 9,5 sp** en el panel, la ayuda de construcción, las tarjetas y la pestaña Infraestructura. | Leer el panel de torre a la distancia de uso. | §1.6, `tower_panel.tscn:32-141`, `hud.tscn:224-240` | **Medio** | **Medio** |
| **P-11** | **Atajos de teclado visibles en el celular** (`[P]`, `[F]`, `[U]`, `[S]`, números). | Cualquier partida. | `hud.gd:241, 247, 414-416`; `tower_panel.gd:108, 111` | **Bajo** | **Bajo** |
| **P-12** | **La casilla depende de la posición del mouse, no del toque.** Funcionó en TA3, pero es frágil y en escritorio no se puede probar sin mover el cursor. | Prueba A0 (en escritorio). | `build_controller.gd:234, 257, 279, 285` | **Medio** (riesgo) | **Bajo** |
| **P-13** | **Pausar cancela la torre elegida y en pausa no se construye:** en el celular no hay forma de planear con calma. | Elegir torre → Pausa → tocar el mapa. | Prueba G; `game.gd:467-472`; RF-104 | **Medio** | **Medio** (cambia RF-104; lo evalúa T264) |
| **P-14** | **Tirones aislados de 37 a 63 ms en escritorio** en las oleadas finales (con la máquina cargada; §3). En el celular: desconocido. | `perf_levels.gd` en los niveles 1, 7 y 15. | §3 | **Desconocido** hasta medir en el celular | **Bajo** medir; el arreglo, según la causa |
| **P-15** | **No hay registro de prueba en celular desde TA3** (la APK de la 1.0 recién se pudo exportar ahora, §6.1). | — | `CHANGELOG.md:36`; `03-tareas.md` TA3 | **Alto** para todo lo demás (sin esto no hay evidencia real) | **Bajo** (§6.1) |

## 5. Propuestas: tareas chicas

Ordenadas por **impacto sobre costo**. Ninguna está aprobada ni especificada: antes de implementar, cada una pasa por la spec (📜, M58) y su decisión, como pide P3. Las que dependen de T263 o T264 quedan para después de G7.

| Orden | Tarea propuesta | Resuelve | Qué haría | Costo | Depende de |
|---|---|---|---|---|---|
| 1 | **Generar la APK de la 1.0 y correr el kit (§6) en el celular de Lucas** | P-15, P-06, P-14 y la verificación de todo lo demás | Exportar el preset «Android», instalar, completar la planilla del §6.3 | Bajo | — |
| 2 | **Separar y proteger «Vender»** | P-01 | Alejarlo de «Mejorar» y pedir un segundo toque («¿Vender por +35?») o dar «Deshacer» unos segundos. La forma la decide T263 | Bajo | T263 (forma) |
| 3 | **Botones táctiles más grandes solo en el celular** | P-04, P-08 | Solo con `OS.has_feature("mobile")` (como ya hace el botón del editor): subir el alto de Pausa, velocidad, «← Menú», los botones del panel y los de la pestaña Infraestructura. Los 48 dp completos serían ~81 px virtuales en el celular supuesto, demasiado para la barra de 48 px: proponer 48–56 px virtuales (4,5–5,3 mm) con más separación, y medir con el kit | Bajo–medio | — |
| 4 | **Ocultar los atajos de teclado en el celular** | P-11 | Sacar `[P]`, `[F]`, `[U]`, `[S]` y los números de los botones cuando no hay teclado | Bajo | — |
| 5 | **Usar la posición del toque para elegir la casilla** | P-12 | Que `BuildController` tome `event.position` (pasada por la cámara) en vez de `get_global_mouse_position()` al tocar | Bajo | — (con test) |
| 6 | **Alternativa táctil a los tooltips** | P-07 | Un toque largo (o un segundo toque) muestra el texto del tooltip en una línea de ayuda, como ya hacen los íconos de arriba | Bajo–medio | T265 (tarjetas) |
| 7 | **Comprobar (y si falla, arreglar) el desplazamiento de la selección con el dedo** | P-06 | Si en el celular no desplaza: flechas de página o arrastre propio | Bajo | Tarea 1 |
| 8 | **Colocación táctil protegida** | P-02, P-13 | Uno de los dos flujos de B-35: vista previa ajustable con tilde/cancelar, o colocación automática protegida. Comprar al **soltar**, nunca al apoyar; ignorar toques que se mueven más de X px o con dos dedos | Medio | **T264** |
| 9 | **Panel de torre compacto en el celular** | P-05, P-10 | La acción principal (Mejorar, con costo) grande y cerca de la torre, el resto bajo demanda; que no tape la torre elegida | Medio | **T263** |
| 10 | **Zoom con pinza y desplazamiento** | P-03 | `Camera2D` con zoom limitado y arrastre de dos dedos (o de uno sin torre elegida), sin construir ni elegir durante el gesto | Alto | **T264** |
| 11 | **Letra mínima en el celular** | P-10 | Subir la letra de 12–16 px a la que dé ≥ 12 sp (≈ 20 px virtuales en el celular supuesto) en el panel, la ayuda y las tarjetas; revisar recortes | Medio | 9 y T265 |
| 12 | **Usar el ancho de 20:9** | P-09 | `stretch/aspect = expand` con el HUD anclado a los bordes, o un fondo decorado en las franjas (barato pero no gana espacio). Medir antes con capturas | Alto | Después de 3, 9 y 10 |

**Tareas sobre el rendimiento: ninguna todavía.** P4 de la constitución: no se optimiza sin medir. Si el kit muestra menos de 60 FPS o tirones en el celular, la siguiente tarea es **ubicar la causa con el monitor de Godot** (§6.4) en ese celular; recién después se propone un arreglo. La sugerencia vieja de §13 («dibujo más liviano de torres y monstruos», `01-spec.md:1660`) queda como candidata, no como causa.

## 6. Kit de medición para el celular real

### 6.1 Preparar la APK (en la máquina Linux)

En esta máquina, el 2026-10-16, ya están el SDK (`~/Android/Sdk`, con `platform-tools`, `build-tools` y NDK), el JDK 17 y las plantillas de exportación de Android de Godot 4.7.2; la configuración del editor apunta a ellos. **Se probó exportar** (a una carpeta temporal, fuera del repositorio; no se versionó): salió una APK de **86,9 MB**, paquete `com.monsterscanons.v1` 1.0.0 (código 3), arm64, Android 7 o más nuevo (minSdk 24, target 36), **firma de depuración v2 y v3 verificada** con `apksigner`, y sin `tools/` ni `tests/` adentro. **No se instaló en ningún celular.** Para generarla en `build/` (ignorada por git):

```bash
godot --headless --path . --export-debug "Android" build/MonstersCanons.apk
```

Instalar con el cable USB y la depuración USB del celular activada (`~/Android/Sdk/platform-tools/adb install -r build/MonstersCanons.apk`) o copiando el archivo al celular. Es el paquete `com.monsterscanons.v1`: **no pisa la APK vieja** de TA3 (`com.juegoa.towerdefense`), y el progreso no pasa de una a la otra.

### 6.2 Antes de empezar (una sola vez)

1. Anotar: **marca y modelo**, **versión de Android**, **resolución y tamaño de la pantalla** (Ajustes → Acerca del teléfono, o la ficha del modelo), y si el celular tiene **muesca o agujero de cámara**.
2. En **Opciones de desarrollador** (Ajustes → Acerca del teléfono → tocar 7 veces «Número de compilación»): activar **«Mostrar toques»** (dibuja un círculo donde se apoya el dedo). Sirve para que la grabación muestre qué se tocó.
3. Batería por encima del 50 %, sin modo ahorro, brillo como se juega normalmente.
4. Para ver FPS: en el juego, **Opciones → Activar modo de pruebas**; en la partida aparece el botón **«Pruebas [F1]»** arriba (se toca) → **«Mostrar FPS»**: arriba a la derecha dice «N FPS · M ms/cuadro», promediado cada medio segundo (`hud.gd:93-101`). Después de medir, volver al modo normal desde Opciones.

### 6.3 Qué hacer y qué anotar

Grabar la pantalla del celular (la grabadora del sistema) **durante cada prueba**. Cada prueba, una fila en la planilla.

| # | Prueba | Qué mirar | Anotar |
|---|---|---|---|
| K1 | Abrir el juego y tocar **Jugar** | ¿Se ve todo? ¿La muesca tapa algo? ¿Hay franjas negras a los costados? | Sí/no y foto |
| K2 | **Selección: arrastrar la lista con el dedo** hacia arriba, empezando sobre una tarjeta | ¿Baja hasta la fila de 11 a 15? ¿Abre un nivel sin querer? | Desplaza sí/no; abrió sin querer sí/no |
| K3 | Leer una tarjeta (nombre, lugar, torres, estrellas) **a la distancia de siempre** | ¿Se leen? ¿Se distinguen los íconos de torre? | Fácil / con esfuerzo / no |
| K4 | Nivel 1: elegir una torre y **tocar una casilla** 10 veces seguidas, en casillas distintas | ¿Cae siempre en la casilla tocada? | Aciertos de 10 |
| K5 | Con una torre elegida, **arrastrar el dedo** por el mapa | ¿Compra? ¿Dónde? | Compra sí/no |
| K6 | Con una torre elegida, **pellizcar** con dos dedos | ¿Compra? ¿Hace zoom? | Compra sí/no; zoom sí/no |
| K7 | Tocar una torre, **Mejorar** 3 veces, después **cerrar el panel** | ¿Se acierta al botón? ¿El panel tapa algo que querías ver? | Fallos de 3; tapa sí/no |
| K8 | **Vender** una torre a propósito, y después intentar tocar Mejorar rápido 5 veces en otra torre | ¿Se vende alguna sin querer? | Ventas accidentales de 5 |
| K9 | **Pausa, x1/x2 y «← Menú»**, 5 veces cada uno | ¿Se acierta al primer toque? | Fallos de 15 |
| K10 | Nivel 7: pestaña **Infraestructura**, tocar sus botones | ¿Se acierta? ¿Se lee? | Fallos; se lee sí/no |
| K11 | **Nivel 13 o 15:** colocar 10 torres | ¿Cuántas cayeron donde querías? | Aciertos de 10 |
| K12 | **Atrás de Android** con torre elegida, con el panel abierto y en la selección | ¿Hace lo esperado (RF-142)? ¿Nunca cierra el juego? | Sí/no por caso |
| K13 | **FPS:** con «Mostrar FPS», jugar las **3 últimas oleadas del nivel 1, del 7 y del 15** (el modo de pruebas deja empezar desde una oleada: franja «Pruebas» de la selección) | El número más bajo que se ve y si hay **tirones** (el juego se congela un instante) | FPS típico, FPS más bajo, tirones por oleada y en qué momento (al empezar la oleada, al morir muchos, al construir…) |
| K14 | Jugar 10 minutos seguidos y volver a mirar los FPS | ¿Bajan cuando el celular se calienta? | FPS al principio y al final; ¿se calentó? |

### 6.4 Medición fina (opcional, con cable)

Si K13 o K14 muestran problemas: desde el editor de Godot en la PC, con el celular conectado por USB, **Depuración remota → Ejecutar en el dispositivo** (el ícono de Android arriba a la derecha). En el panel **Depurador → Monitores** se ven en vivo el tiempo de proceso y de física, las llamadas de dibujo y los nodos, que son los mismos números que imprime `perf_levels.gd`. Una captura de esos gráficos durante un tirón alcanza para empezar a buscar la causa.

### 6.5 Cómo reportar

Una nota (o un mensaje) con:

```text
Celular: <marca y modelo> · Android <versión> · <resolución> · <pulgadas> · muesca: sí/no
Build: <nombre del archivo APK y fecha> · modo de pruebas: sí/no
K1: ...            (una línea por prueba, con el número que pide la columna «Anotar»)
...
K13: nivel 1 típico N / mínimo N / tirones: ... · nivel 7 ... · nivel 15 ...
K14: inicio N FPS → final N FPS · se calentó: sí/no
Lo que más molestó: <texto libre>
Videos: <dónde quedaron>
```

Con eso se puede repetir el §1.6 con el tamaño real de la pantalla de Lucas (la herramienta acepta `target=WxH` y `ppi=N`) y decidir en G7 con datos del celular.

## 7. Qué no se probó

- **Nada corrió en un celular.** No hay dispositivo conectado (`adb devices` vacío). Todo es escritorio con proporción de celular. En particular, **no se probó**:
  - **el tamaño real del dedo, la oclusión y el temblor**: los toques simulados aciertan al píxel; un dedo no;
  - **el desplazamiento de la selección con el dedo** (P-06): en escritorio no desplazó, pero puede deberse a que la PC no tiene pantalla táctil; **no se atribuye ninguna causa** hasta probarlo en el celular;
  - **cómo Android entrega los toques** (el gestor de gestos del sistema, los bordes que abren la barra, la multitáctil real) y si la casilla sigue cayendo bien con la versión actual (P-12; en TA3 sí);
  - **la muesca o el agujero de la cámara**, los bordes curvos y la barra de gestos; el modo inmersivo está pedido (`export_presets.cfg:75`) pero no se vio;
  - **el rendimiento**, el calentamiento y la batería;
  - **la lectura real** de la letra (las cuentas en sp son eso, cuentas) y el brillo al aire libre;
  - **el botón atrás de Android** en las pantallas nuevas (barra con pestañas, diálogo de salir, intro).
- **El celular «supuesto» es un supuesto:** 1080 × 2400 en 6,5" (~405 ppi). Con otro celular los milímetros cambian; la herramienta los recalcula con `target=` y `ppi=`.
- **La medida de 7,6 mm (48 dp) es una guía de Android**, no una regla del proyecto ni una prueba con personas.
- **Rendimiento:** solo en escritorio, con la máquina cargada por otros agentes (carga anotada en cada medición), dos corridas por nivel (la segunda con ventana de 20:9 y, en los niveles 1 y 7, tope de 30 torres; la primera compró más de 110, más que una partida humana) y sin una corrida con la máquina libre, que no hubo.
- **No se jugó** una partida entera a mano ni se probaron todas las pantallas: quedaron afuera Récords, el ingreso de nombre (`name_entry`), el final de nivel, el epílogo, los créditos, el Asedio y el panel de un removible.
- **Desktop de referencia:** la comparación es por cuentas (misma pantalla lógica, distinto tamaño físico); no se midió cuánto tarda una persona en cada flujo en ninguna de las dos plataformas.
- **No se implementó ninguna optimización** ni se tocó una regla: todas las propuestas del §5 esperan a G7 y a la spec M58.

## 8. Cómo repetir todo

```bash
# Capturas, medidas y toques simulados (no toca el guardado: usa user://mobile_probe.json y lo borra)
XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1600x720 res://tools/mobile_probe.tscn -- res=1600x720 tag=20x9
XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1280x720 res://tools/mobile_probe.tscn -- res=1280x720 tag=16x9 target=1280x720 ppi=294

# Rendimiento (anotar `uptime` antes y después; repetir si la carga es alta)
uptime; godot --path . res://tools/perf_levels.tscn -- level=1 from=7 window=1600x720; uptime
uptime; godot --path . res://tools/perf_levels.tscn -- level=7 from=17 window=1600x720; uptime
uptime; godot --path . res://tools/perf_levels.tscn -- level=15 from=27 window=1600x720; uptime
```

La herramienta imprime una línea `PROBE …` por medición y prueba; la salida de esta corrida se resume en el §1.
