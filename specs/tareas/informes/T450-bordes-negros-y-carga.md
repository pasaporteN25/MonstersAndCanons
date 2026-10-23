# T450 · Bordes negros en pantalla completa y pantalla de carga con fondos rotativos

> **Estado: DIAGNÓSTICO HECHO, PROPUESTAS A LA ESPERA DE LUCAS.** Escrito el 2026-10-23 por Claude (Sonnet 5.5), tarea **T450**, frente B del backlog (**B-53**). **No se tocó código, `project.godot`, `data/`, specs 01 a 04 ni `03-tareas.md`, y no se generó ni recortó ninguna imagen definitiva.** Las elecciones que faltan están marcadas **PENDIENTE DE LUCAS**.

## 0. Límite principal, dicho de entrada

- **No hay captura de pantalla real de las franjas.** En esta máquina no hay `xvfb-run` ni `Xvfb` (`which` no los encuentra) y `godot --headless` no dibuja. **No se vio ninguna franja con los ojos.**
- Lo que sí se hizo: (a) **medición** con Godot headless de cómo escala la ventana raíz (`Window.get_final_transform()` y `get_visible_rect()` con `root.size` forzado a cada resolución); (b) **cálculo** de las franjas a partir de esas escalas; (c) lectura del código; (d) medición de la carga de las 7 láminas en esta PC.
- Que la franja se vea **negra** (y no del color de borrado de la ventana) **no se verificó**: en Godot 4 el color de las barras sigue al color de borrado, que el proyecto no cambia, así que es lo esperado, pero es una afirmación sin captura.
- **No se midió nada en un celular** (ni la carga ni las franjas). Los tiempos de celular de la §3 son estimaciones y están marcados como tales.
- Una advertencia sobre la medición headless: la **primera** muestra de cada corrida salió con escala 0,05 (artefacto del arranque: la ventana todavía tenía su tamaño inicial de 64 × 64). Se descartó; las demás coinciden con la cuenta a mano.

## 1. Diagnóstico de los bordes

### 1.1 Qué hay hoy (con el código)

| Pieza | Dónde | Qué hace |
|---|---|---|
| Viewport base | `project.godot:35-37` | 1280 × 720, `stretch/mode="canvas_items"`, **sin `stretch/aspect`** (vale `keep`). |
| Ventana de escritorio | `scripts/logic/desktop_window.gd:7-25` | `fitted_size` da **siempre 16:9** (máx. 1920 × 1080, restando margen 32 × 48). Se llama una sola vez, desde `GameFlow._ready` (`game_flow.gd:55`), y **sale sin hacer nada** si la ventana no está en modo ventana, si es headless, si el SO no es Windows/Linux o si hay `--resolution`. |
| Pantalla completa | `GameFlow.apply_display_settings` (`game_flow.gd:76-83`) | Solo cambia el modo (`FULLSCREEN` o `WINDOWED`). **No toca el tamaño ni el aspecto.** |
| Zoom del mapa | `scenes/game/game.gd:442` (`if zoom >= 1.0: return`), `Rules.map_zoom` (`rules.gd:23-24`, `minf(1.0, …)`) | Tope de 1,0: un mapa chico nunca se agranda. |
| HUD | `scenes/game/hud.tscn` | `TopBar` y `BottomBar` con `offset_right = 1280.0` fijo, sin anclas. `Rules.SCREEN_SIZE` aparece 33 veces en 7 archivos (17 en `mobile_hud.gd`); `Rules.MAP_AREA` 6 veces. |

### 1.2 Resultado: hay **tres** cosas distintas, y solo una produce franjas

**(a) Viewport/ventana: ES la fuente de las franjas.** Con `keep`, el 1280 × 720 se escala por `min(ancho/1280, alto/720)` y se centra; lo que sobra es franja **fuera** del viewport (no se puede dibujar desde el juego). Medición headless (escala y origen del contenido):

| Ventana (px) | Relación | Escala medida | Origen medido | Franjas (cálculo) |
|---|---|---|---|---|
| 1920 × 1080 | 16:9 | 1,5 | (0, 0) | ninguna |
| 1920 × 1200 | 16:10 | 1,5 | (0, 60) | **60 px arriba y 60 abajo** (10 % del alto en total) |
| 2560 × 1080 | 21:9 | 1,5 | (320, 0) | **320 px a cada lado** (25 % del ancho en total) |
| 1024 × 768 | 4:3 | 0,8 | (0, 96) | **96 px arriba y 96 abajo** (25 % del alto en total) |
| 2400 × 1080 | 20:9 (celular) | 1,5 | (240, 0) | **240 px a cada lado** (20 % del ancho) |
| 800 × 1280 | vertical | 0,625 | (0, 415) | 415 px arriba y abajo (el juego pide horizontal; solo informativo) |

Cálculo (no captura) para otras pantallas frecuentes, con la misma fórmula: 2560 × 1600 (16:10) → 80 px arriba y abajo; 3440 × 1440 (21:9) → 440 px a cada lado; 2340 × 1080 (19,5:9) → 210 px a cada lado. **`visible_rect` siempre da 1280 × 720**: en `keep` el juego nunca ve más que eso.

**En modo ventana no hay franjas** salvo que el jugador cambie el tamaño a mano o maximice: `DesktopWindow` fija 16:9 al arrancar. **Quien las ve es quien juega en pantalla completa en un monitor que no es 16:9** (o en un celular alargado). `apply_display_settings` activa la pantalla completa sin mirar la relación del monitor: ese es el punto exacto del defecto.

**(b) Mapa: NO es la causa, y el tope de zoom 1,0 no la agrava.** El editor y la validación exigen un mapa de **al menos 20 casillas de ancho y 9 de alto** (`map_grid.gd:16-17`) y los 15 niveles miden 20×9 (9 niveles), 24×11 (2), 26×11 (1) y 26×12 (3). Con 64 px por casilla, 20 × 9 = **1280 × 576, que es exactamente `Rules.MAP_AREA`**: no hay mapa más chico que el área, así que un zoom mayor a 1 **no tiene nada que agrandar**. Los mapas grandes ya bajan de zoom y dejan un margen mínimo en el viewport lógico: 26×12 → zoom 0,75 → 1248 × 576 (16 px de margen a cada lado); 24×11 → zoom ≈ 0,818 → ≈ 1257 × 576 (≈ 11 px); 26×11 → zoom ≈ 0,769 → 1280 × ≈ 541 (≈ 17 px arriba y abajo). Son márgenes lógicos de 11 a 17 px **dentro** del viewport, sobre el color de borrado: son otra cosa que las franjas de pantalla (y en escritorio no hay fondo temático ahí: `MapBackdrop` solo se crea en mobile, `game.gd:427-436`). No se midió si se notan; se calcularon.

**(c) Separar bien al informar:** viewport = 1280 × 720 fijo; ventana = lo que da el SO; mapa = 1280 × 576 en el 60 % de los niveles. La franja de pantalla completa sale solo de (a).

### 1.3 Qué **no** se probó
- Ninguna captura real (ver §0). Ningún celular. Tampoco se probó Windows (la máquina es Linux). El comportamiento de `DesktopWindow` en monitores reales con barra de tareas es de lectura de código.

## 2. Propuestas de corrección (sin deformar sprites)

Todas conservan los sprites sin estirar: el escalado sigue siendo uniforme.

| # | Alternativa | Qué hace | Riesgos y costo | ¿D nueva? |
|---|---|---|---|---|
| A | **`stretch/aspect="expand"`** | El viewport crece a lo ancho o a lo alto para llenar la ventana (nunca baja de 1280 × 720): 16:10 → 1280 × 800; 21:9 (2560 × 1080) → ≈ 1707 × 720; 4:3 → 1280 × 960; 20:9 → 1600 × 720. | Es la única que **elimina** las franjas. Obliga a revisar cada HUD anclado a 1280 × 720: `TopBar`/`BottomBar` (`offset_right = 1280`), 33 usos de `Rules.SCREEN_SIZE`, 6 de `MAP_AREA`, `mobile_hud.gd`, tutorial y efectos; la cámara y el centrado del mapa; hay que **agregar el fondo temático** al lado del mapa también en escritorio (hoy solo existe en mobile). Afecta a **todos** los HUD. Con pantallas muy anchas (32:9 → 2560 × 720) el HUD se estira demasiado. | **Sí. PENDIENTE DE LUCAS** (D sobre `stretch/aspect`). |
| A+ | A con **tope de relación** (por ejemplo hasta 21:9; más ancho, franjas chicas) | Un poco de código en `GameFlow`/`DesktopWindow` que ajuste `content_scale_size` al cambiar el tamaño. | Más código que A; misma revisión de HUD. | **Sí. PENDIENTE DE LUCAS.** |
| B | **Relleno temático de las franjas** sin cambiar el viewport | En `keep` las franjas están fuera del viewport: el juego **no puede dibujar ahí**. Lo único sin tocar el viewport es cambiar el color de borrado (`rendering/environment/defaults/default_clear_color`), que pinta de un color liso, sin imagen. Un relleno con dibujo **exige A** (o una ventana de fondo aparte, fuera de lo que se probó). | Barato, pero solo color; no se probó que las barras tomen ese color. | Probablemente sí (cambia `project.godot`). **PENDIENTE DE LUCAS.** |
| C | `keep_width` o `keep_height` | `keep_height` acepta 21:9 (1707 × 720) pero en 4:3 recorta a 960 × 720 (el HUD de 1280 no entra); `keep_width` en 21:9 deja 1280 × 540 (el HUD tampoco entra). | **Descartada**: recorta HUD en algún caso. `expand` es la variante que nunca recorta. | — |
| D | **Zoom del mapa > 1** (quitar el tope de 1,0) | **No arregla las franjas** (§1.2.b: no hay mapa más chico que el área). Solo tendría sentido **con A** en 16:10 o 4:3: el área del mapa gana alto (hasta +80 o +240 px) y un mapa de 26×12 podría subir de zoom 0,75 a 0,83 o más. | Cambia el tamaño en pantalla de torres y enemigos por relación (afecta a la sensación y a cómo se tocan en mobile, T264). Es un efecto secundario deseable, no la corrección. | **Sí, si se hace** (cambia una regla de cámara, RF-251). **PENDIENTE DE LUCAS.** |
| E | Hacer que `apply_display_settings` elija una ventana 16:9 con borde (pantalla completa "sin bordes" en 16:9) | Mantiene el juego sin franjas, pero deja una **ventana** en vez de la pantalla completa en monitores no 16:9. | Cambia la promesa de «pantalla completa» (RF-113). | Sí. **PENDIENTE DE LUCAS.** |

**Recomendación (no es decisión):** A con un tope de relación (A+), más el fondo temático reutilizando `MapBackdrop` en escritorio; D solo como segunda etapa y con medición. Si Lucas no quiere tocar el HUD: B (color liso) como parche barato, sabiendo que no llena con dibujo.

**Archivos que tocaría (para el plan, cuando se decida):** `project.godot` (**también lo toca T268**, `config/version`: coordinar, el merge es trivial pero hay que avisar), `desktop_window.gd`, `game_flow.gd`, `hud.tscn`, `rules.gd`, `game.gd`, `camera_controller.gd`, `mobile_hud.gd`, `tutorial_overlay.gd`. Tests de HUD a repasar con la relación cambiada.

## 3. Pantalla de carga con varios fondos rotativos

### 3.1 Estado actual (M64)
- RF-580 dice «fondo de los menús, texto "Cargando…" y una barra […] (**sin imágenes**)» y M64 «no incluye» «un logo, un consejo o una animación elaborada» (P4). **D-133** fija la capa «dibujada por código […] **Sin escenas ni imágenes**» y descartó el mapa de fondo de los menús por trabajo pesado.
- El fondo es un `Color` liso (`LOADING_BACKGROUND`, `game_flow.gd:17`, aplicado en `:478`). El mínimo es `LOADING_MIN_SECONDS = 0.4`.
- **RF-581**: `scene_transition.gd` es un núcleo que **no nombra nada del proyecto** (hay un test que lo lee). Hoy tiene `background_color`; **no** nombra `intro` ni rutas. **Conclusión: los fondos tienen que inyectarse desde `GameFlow`**, por ejemplo con una propiedad genérica `backgrounds: Array[Texture2D]` (o `Callable` que devuelve el próximo fondo) y un modo de ajuste, sin que el núcleo sepa de dónde vienen. Si el núcleo cargara `res://assets/intro/…`, el test de RF-581 falla.

### 3.2 Inventario de `assets/intro/*.webp` (medido)

| Archivo | Píxeles | Relación | Peso del archivo | `.ctex` importado (el que va al `.pck`) |
|---|---|---|---|---|
| 01_la_nave | 1920 × 1080 | 16:9 | 2,12 MB | 0,31 MB |
| 02_la_bodega | 1920 × 1080 | 16:9 | 2,75 MB | 0,68 MB |
| 03_los_turnos | 1920 × 1080 | 16:9 | 2,63 MB | 0,62 MB |
| 04_la_ventana | 1920 × 1080 | 16:9 | 2,56 MB | 0,57 MB |
| 05_el_descenso | 1920 × 1080 | 16:9 | 2,45 MB | 0,51 MB |
| 06_los_motores_apagados | 1920 × 1080 | 16:9 | 2,83 MB | 0,74 MB |
| 07_el_oasis | 1920 × 1080 | 16:9 | 2,90 MB | 0,77 MB |
| **Total** | | | **≈ 18,2 MB** (fuentes) | **≈ 4,2 MB** (en el juego exportado; coincide con «unos 4 MiB», D-150) |

- Importación: `compress/mode=1` (sin pérdida), sin mipmaps. En memoria cada una queda **sin comprimir**: `Image` formato RGB8, **6.220.800 bytes (≈ 5,9 MiB) por lámina** (medido en esta máquina con `get_data().size()`). Una a la vez; las siete juntas serían ≈ 41,5 MiB, no conviene.
- **Observación visual** (hoja de contacto hecha para este informe, en la carpeta temporal, no se sube): las láminas tienen **borde de papel rasgado claro** y una **franja inferior oscura** (≈ 28 % de alto, probable zona de texto de la intro). Eso importa para el recorte y para el texto de la carga (ver abajo).

### 3.3 Recortes por relación de aspecto
Las láminas son 16:9 fijo. Hay dos maneras de adaptarlas; la segunda no necesita archivos nuevos:

1. **Recorte en tiempo de ejecución** con `TextureRect.stretch_mode = STRETCH_KEEP_ASPECT_COVERED` (cubre y centra, sin deformar). Es lo recomendable: cero archivos nuevos. La intro hoy usa `KEEP_ASPECT_CENTERED` (`intro_screen.gd:260`: «sobran barras si no es 16:9»), que es lo opuesto.
2. **Archivos recortados por relación** (solo si Lucas pide control artístico del encuadre): uno por relación y por lámina = 7 × N archivos. No se recomienda.

Cuánto se pierde de la lámina con *cover* (cálculo, centrado):

| Relación del viewport | Se ve | Se pierde |
|---|---|---|
| 16:9 | toda | 0 % (pero el borde rasgado queda a la vista) |
| 16:10 | 90 % del ancho | 10 % (5 % por lado) |
| 4:3 | 75 % del ancho | 25 % |
| 20:9 | 80 % del alto | 20 % (10 % arriba y abajo) |
| 21:9 | 76 % del alto | 24 % |
| 32:9 | 50 % del alto | 50 % (no recomendable sin tope, ver A+) |

Mirando la hoja de contacto, el encuadre central aguanta el recorte a 16:10 y 21:9 en la mayoría; **a 4:3 pierde la cara del hombre de la derecha en la lámina 4 y el costado derecho de la 2**. Recortar un 3 % por lado quita el borde rasgado. Necesita revisión de **Lucas/arte** si se aprueba (compuerta 🎨).

### 3.4 Costo de carga (RAM y tiempo)
- **RAM:** ≈ 5,9 MiB por fondo mostrado (RGB8, medido). Si solo hay uno vivo a la vez (se libera al terminar la carga), el pico extra es ≈ 6 MiB. **No se midió RAM en celular.**
- **Tiempo (medido en esta PC, 12 hilos, headless):** `load()` de cada lámina tardó **29 a 51 ms** (media ≈ 43 ms), la mayor parte es descomprimir el webp sin pérdida. **Estimación, no medición:** en un celular de gama media podría ser de 5 a 10 veces más, o sea **0,15 a 0,5 s**, **del mismo orden que el mínimo de 0,4 s** (RF-585). Es decir: el fondo podría tardar más en cargar que lo que dura la carga.
- **Dónde se rompe:** la capa se dibuja «en el cuadro siguiente» y la escena nueva se carga en un hilo. Un `load()` **síncrono** de la imagen justo antes de mostrar la capa congelaría el cuadro (justo lo que D-132 evita).
- **Diseño que evita el problema (propuesta):** (1) la capa aparece al instante con el color liso y la barra (como hoy); (2) la imagen se pide con `ResourceLoader.load_threaded_request` y entra con un fundido cuando llega; (3) si no llegó antes de terminar el tiempo, no se muestra (nunca retrasa el cambio de escena); (4) la imagen se **precarga en reposo** (por ejemplo, la siguiente a la última usada) para que normalmente ya esté lista; (5) un velo oscuro sobre la imagen para que «Cargando…» y la barra se lean (la mitad inferior de las láminas ya es oscura).
- **Alternativa más liviana:** fondos de carga dedicados a 1280 × 720 con pérdida (una prueba de **estimación** sobre la lámina 2: **≈ 225 KB con calidad 80 y ≈ 354 KB con calidad 90**, y 2,6 MiB en RAM). Es arte nuevo y entra en la compuerta 🎨; **no se generó ninguno** en este informe.
- **Rotación:** una por cambio de pantalla, sin repetir la anterior (orden barajado con memoria de la última), estado en `GameFlow`, no en el núcleo (RF-581). Una pregunta de contenido para Lucas: las láminas son **narrativa de la intro**; usarlas como fondo de carga las gasta y puede adelantar escenas (el oasis es el final del viaje). Alternativa: arte nuevo y neutro.

### 3.5 Enmienda necesaria (texto candidato) — **PENDIENTE DE LUCAS**
Hay que enmendar **RF-580**, la lista «**no incluye**» de M64 y **D-133** (no se pueden reordenar ni reusar números: **RF-666** y **D-187** son los siguientes libres).

**RF-666 (candidato).** *Enmienda a RF-580 y a «Lo que M64 no incluye».* «La pantalla de carga puede mostrar, detrás del texto y la barra, **una imagen de fondo elegida por rotación** entre las que `GameFlow` le inyecta. Dado un cambio de pantalla → Cuando se muestra la capa → Entonces se ve primero el fondo liso y la barra; la imagen entra con un fundido **solo si ya cargó**, nunca retrasa el cambio de escena ni el mínimo de 0,4 s, y se recorta para cubrir el viewport sin deformarla. Dado varios cambios seguidos → Entonces no se repite la misma imagen dos veces seguidas. Dado que falla la carga de una imagen → Entonces la capa sigue con el fondo liso (RF-587 sigue valiendo). **El núcleo `SceneTransition` no nombra el proyecto** (RF-581): recibe los fondos desde `GameFlow` sin conocer rutas.» *Y se quita «sin imágenes» de RF-580.*

**D-187 (candidato, reemplaza en parte a D-133).** *Qué:* la capa sigue siendo código en una capa propia (D-133 vale en todo lo demás) pero admite una textura de fondo opcional inyectada. *Por qué:* la intro ya está en el paquete (≈ 4,2 MB) y da identidad; el color liso se mantiene como respaldo. *Alternativas descartadas:* imágenes dentro del núcleo (rompe RF-581); precarga bloqueante (congela el cuadro); siete láminas en memoria (≈ 41,5 MiB). *Cambia:* `01-spec.md` (RF-580, M64), `scene_transition.gd` (una propiedad genérica), `game_flow.gd`, `test_scene_transition.gd` y `test_loading_flow.gd`; y si se elige A, una D sobre `stretch/aspect`.

## 4. Decisiones pendientes de Lucas
1. ¿Se corrige la franja? **A+** (`expand` con tope y fondo temático), **B** (solo color), **E** (ventana 16:9) o dejarlo. Es una D sobre `stretch/aspect`.
2. ¿Se sube el tope de zoom (D)? Solo tiene sentido con A.
3. ¿Fondos de carga con las láminas de la intro, con arte nuevo, o sin imágenes? Si sí: enmienda de RF-580 / M64 / D-133 (textos de la §3.5).
4. Si se usan las láminas: ¿recorte en ejecución (recomendado) o archivos recortados? ¿Quién revisa el encuadre (compuerta 🎨)?
5. Medir en un celular real (carga de imagen y franjas): **no se hizo y bloquea cualquier afirmación sobre mobile**.

## 5. Qué se probó y qué no
- **Probado:** escala y origen de la ventana raíz con `stretch=canvas_items`/`keep` en 7 tamaños (Godot 4.7.2 headless); tiempo y bytes de `load()` de las 7 láminas en esta PC; relaciones y tamaños de los 15 mapas; lectura de `project.godot`, `desktop_window.gd`, `game_flow.gd`, `game.gd`, `rules.gd`, `scene_transition.gd`, `intro_screen.gd`, `hud.tscn`.
- **No probado:** ninguna captura real; Windows; celular; si las franjas se ven negras o con el color de borrado; ninguna ejecución de la suite de tests (no se cambió código); tiempos y RAM reales en celular.
- Los scripts de medición están en la carpeta temporal de la sesión y **no se incluyen** en el repositorio.

## Decisiones de Lucas (2026-10-23)

> Registradas por Claude a partir de las respuestas de Lucas. **No son D ni RF todavía**; nada está implementado.

1. **Bordes negros:** rellenar las franjas con un **fondo temático** (la zona jugable queda igual; no se pasa a `expand`). *Pendiente:* qué fondo, de dónde sale (compuerta de arte) y cómo se ve a 16:10, 21:9 y 4:3.
2. **Fondos de la pantalla de carga:** se usan las **láminas de la intro**, recortadas en ejecución. Requiere enmendar RF-580 y D-133 («sin imágenes»).
3. **Antes de aprobar los fondos rotativos se mide el costo de carga en un celular real** (ficha T454, fase 2). Hasta entonces la aprobación del punto 2 queda **condicionada** a esa medición.
4. **Sin decidir todavía:** recorte en ejecución o archivos recortados, y el tope de zoom.
