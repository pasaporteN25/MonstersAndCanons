# T289 · Auditoría independiente del modo celular ya implementado (T270–T276, T287)

> **Estado: AUDITORÍA HECHA, HALLAZGOS A LA ESPERA DE LUCAS.** Escrita el 2026-10-18 por Claude (Opus 5.5), sobre `origin/main` en `b20d94c` (merge del PR #10, con T286 y T287). **No se tocó código, escenas, datos, tests ni `specs/03-tareas.md`.** Lo único nuevo es este informe. Los sondeos se corrieron con scripts fuera del repositorio (en una carpeta temporal) y un guardado aparte; los que reproducen hallazgos van como texto en el **Apéndice A**, para que quien arregle los pegue en `tests/` si quiere.
>
> **Límite principal, dicho de entrada: no hay celular.** `adb devices` no lista ningún dispositivo y no hay emulador (G7, punto 9). Todo lo de abajo es **lectura de código** más **mediciones en Godot 4.7.2 headless** en la PC Linux (Ryzen 5 3600, carga 0,3 a 1,6 durante las corridas). Donde un resultado depende del celular real se dice, y el §6 junta todo lo que no se probó.
>
> **Sobre T288** (el botón «Empezar oleada», que arregla otro agente): no lo toqué. El hallazgo H-01 es, con mucha probabilidad, su causa; queda documentado para que lo confirme quien lo arregla.

## 0. Resumen (para quien lea solo esto)

Los cinco hallazgos más importantes, en orden de gravedad:

1. **H-01 · Crítica · En el modo celular no se puede empezar la primera oleada.** La barra de abajo del celular (`MobileStatusBar`, capa 3) cubre toda la franja de 1280 × 96 px con `MOUSE_FILTER_PASS` y se queda con todos los clics y toques que caen sobre «Empezar oleada» (que está en el HUD, capa 1). Medido: **0 de 2 pulsaciones** llegaron al botón. Como la partida arranca sin cuenta atrás (`level_session.gd:40-49`), la oleada 1 **solo** empieza con la tecla Espacio: sin teclado, **ningún nivel arranca**. Probable causa de T288.
2. **H-02 + H-03 · Altas · El catálogo falla en los niveles 6 a 15 y cada vez que cambia el oro.** En los niveles con infraestructura el catálogo **abre en la pestaña «Infraestructura»** y **vuelve a ella** cada vez que cambia el oro o los recursos (un `TabContainer` usa `visible` para elegir pestaña, y el código lo usa para «existe»). Además, **cada cambio de oro borra y recrea todas las tarjetas**: un toque que empieza sobre una tarjeta y termina después de que muere un enemigo **se pierde** (medido: 0 de 1). Los «2 toques» de RF-510 no se cumplen durante una oleada.
3. **H-04 · Alta (rendimiento) · El catálogo se reconstruye entero en cada cambio de oro, aunque esté cerrado, y eso da tirones medibles.** Cada reconstrucción tarda **14,9 ms** en esta PC (4,4 ms en listar y cargar las torres y 12,2 ms en armar 11 íconos con operaciones de imagen en la CPU). En la oleada 1 del nivel 15 con 25 torres, el modo celular tuvo **14 a 16 cuadros de más de 16,6 ms (el peor, 35 ms)**; **la PC, en la misma partida, 0 (el peor, 3 ms)**. Es la única fuente de tirones que medí que se puede atribuir al modo celular. En un celular, cuánto pesa es desconocido.
4. **H-05 + H-06 · Alta · Un mismo toque lo atienden dos controles.** «Apuntar», «Mejorar» y «Vender» reciben el clic emulado por la interfaz **y** el toque por el código propio del HUD móvil. Con el orden real de eventos de Godot (primero el clic emulado, después el toque; verificado), **un toque en «Apuntar» avanza dos modos**; «Mejorar» y «Vender» se salvan **de casualidad** por el bloqueo de 0,35 s y el mínimo de 0,4 s. Y la tilde, que no tiene límite de pantalla, **se sube sobre la barra de arriba** cuando el fantasma está en la primera fila: **un toque en «x2» cambió la velocidad y además construyó la torre** (oro 150 → 100).
5. **H-08 + H-13 · Medias · Los números «en datos» no se respetan.** (a) **42 de los 57 valores de `data/ui/mobile_ui.json` se ignoran** si se editan: Godot entrega los enteros de un JSON como `float` y `MobileUiConfig` compara el tipo con el de un entero (`mobile_ui_config.gd:82-85`). Cambiar `boton_alto_px` a 99 deja 56. Eso rompe el plan de «ajustar después de la prueba real» (D-097). (b) Los temporizadores de la barra se aceleran con la velocidad del juego: **con x2, «Vender» se desarma a 1,5 s en vez de 3 s y el bloqueo de «Mejorar» dura 0,18 s en vez de 0,35 s.**

**Lo que está bien** (comprobado): los 15 niveles cargan en modo celular sin errores ni avisos, con el mapa dentro del área (casilla de 62 px en los niveles 1 a 9, 51 en el 10 y 11, 49 en el 12 y 47 en el 13 a 15); la barra de arriba no se pisa (las estadísticas terminan en x = 545 y «Pausa» empieza en 1016); los toques que empiezan en la interfaz no llegan al mapa; el doble toque construye una sola vez; «atrás» cancela en el orden pedido; el mouse emulado ya no abre dos veces el carrito (T287); y **GUT pasa 1664/1664 con 20 119 aserciones y 0 `SCRIPT ERROR`**.

**Decisiones que necesitan a Lucas:** §7 (11 puntos; los más urgentes son D1, la pestaña del catálogo, y D2, qué torres muestra).

## 1. Cómo se midió

- **Base:** rama `feature/t289-auditoria-mobile-implementado` creada desde `origin/main` (`b20d94c`). `godot --headless --import` en el worktree (dejó dos archivos generados sin versionar, `art/t276-mobile/*.translation` y `art/t287-mobile/capture.gd.uid`, que borré antes del commit; ver H-25).
- **Sondeos:** un script `SceneTree` que instancia `game.tscn` en la raíz (sin cambiar de escena), pone `ui_mode = 1` (Celular) o `2` (PC), elige el nivel con `game.level_data = GameFlow.level(i)` y empuja eventos con `root.push_input(evento, true)` (coordenadas del lienzo de 1280 × 720). Guardado aparte (`user://test_t289.json`) y `XDG_DATA_HOME` en una carpeta temporal: el guardado real no se tocó.
- **El orden de eventos de un toque real:** con `Input.parse_input_event(InputEventScreenTouch)` Godot 4.7.2 entrega **primero el clic emulado** (`InputEventMouseButton`, `device = -1`) **y después el toque**, tanto al apoyar como al soltar (lo imprimió un nodo espía). Es el mismo código de `Input` que usa Android, así que los sondeos de botones reproducen ese orden a mano (`_real_touch` del Apéndice A). **Inferencia, no medición en Android.**
- **Por qué la PC sirve para modelar Android en los botones:** en Android, `MobileHud._input` no mira el mouse (`mobile_hud.gd:700`, `not OS.has_feature("mobile")`) y el clic emulado va directo a la interfaz; en la PC el clic emulado sale en `:703-704` sin marcarse como atendido y también va a la interfaz. **En el mapa no:** en Android `BuildController` descarta todos los clics (`build_controller.gd:316-318`) y en la PC no (eso es H-10). Por eso los sondeos del mapa mandan solo el toque.
- **Tiempo:** `--fixed-fps 60` para contar cuadros (los temporizadores) y sin él para medir CPU por cuadro. Headless **no dibuja**: lo que se mide es CPU de lógica e interfaz, no GPU.

## 2. Mediciones en headless

| Medición | Resultado | Dónde |
|---|---|---|
| Clics/toques que llegan a «Empezar oleada» (modo celular, nivel 1) | **0 de 1 clic y 0 de 1 toque** | H-01 |
| Pestaña del catálogo al abrirlo (niveles 1 / 7 / 15) | **0 / 1 / 1** (1 = Infraestructura); después de `earn(1)` desde la pestaña 0: **0 / 1 / 1** | H-02 |
| Toque en una tarjeta con un cambio de oro entre apoyar y soltar | **0 elecciones** (sin el cambio: 1) | H-03 |
| Reconstruir el catálogo (11 tarjetas) | **14,9 ms** por vez (`Wiki._all_towers()` 4,4 ms; `Tower.make_icon` ×11: 12,2 ms, 1,1 ms cada uno) | H-04 |
| Cambios de oro en la oleada 1 del nivel 15 con 25 torres | 15 | H-04 |
| Cuadros de CPU > 16,6 ms en esa oleada (1500 cuadros) | **celular 14 y 16** (peor 34,9 y 35,3 ms; p99 16,6–17,0 ms) · **PC 0 y 0** (peor 3,1 ms; p99 1,8 ms) | H-04 |
| `Game._process` por cuadro, torre elegida | celular **76 µs** · PC 0,2 µs; con «Vender» armado **100 µs**; con fantasma (Game + MobileHud) 28 µs | H-21 |
| Nodos de la partida (nivel 15) | celular 273 · PC 239 | — |
| Un toque en «Apuntar» con el orden de Android | **avanza 2 modos** (0 → 2); con un clic de mouse real, 1 | H-05 |
| Un toque en «Mejorar» con el orden de Android | sube **1** nivel (lo salva el bloqueo) | H-05 |
| Tilde con el fantasma en la casilla (0, 0) del nivel 1 | tilde en **x = −21**, cruz en **x = −97** (fuera de pantalla), **y = 23** (sobre la barra de arriba, que llega a 64) | H-06 |
| Toque donde la tilde pisa «x1/x2» (fantasma en (19, 0)) | **cambió la velocidad y construyó** (oro 150 → 100) | H-05 |
| Toque donde la tilde pisa «Pausa» (fantasma en (16, 0)) | **pausó** (y la pausa canceló el fantasma: no construyó) | H-05 |
| Elegir torre con zoom 1,5 en una esquina (nivel 15) | fantasma en pantalla (1936, 888): **fuera de la vista** | H-07 |
| «Vender» armado se desarma (60 cuadros = 1 s) | x1: **3,02 s** · x2: **1,52 s** | H-08 |
| Bloqueo de «Mejorar» | x1: **0,367 s** · x2: **0,183 s** | H-08 |
| Toque en el mapa con clic emulado + toque (PC con pantalla táctil, «Celular») | el fantasma **no se mueve** (lo toma por una pinza) | H-10 |
| Rueda del mouse sobre el panel de torre (PC) | **creó la cámara y la acercó a 1,1**; el panel no se desplazó | H-11 |
| Desplazar con dos dedos / botón central con el zoom mínimo | celular: el mapa se corrió 150 px y «Ver todo» **no aparece**; PC: se corrió 300 px y no hay cómo recentrarlo | H-12 |
| `boton_alto_px: 99` en un `mobile_ui.json` de prueba | `get_value` devuelve **56**; `toque_max_mm: 3.5` (decimal) sí se respeta | H-13 |
| Herramienta «Demoler» elegida y toque en una casilla equivocada | la herramienta **sigue activa**, un toque en una torre **no la elige**, la barra dice «Tocá el carrito…» y **no hay cruz** | H-09 |
| Tocar un removible en el nivel 7 (celular) | aparece el **panel de la PC** (1000–1270 × 260–454) con «Demoler» de **36 px de alto**; el carrito en su lugar por omisión **lo pisa** | H-14 (h) |
| «Ver todo» con el carrito arriba a la derecha | se **superponen**; «Ver todo» mide 99 × 64 y **sale 7 px de la pantalla** (x hasta 1287) | H-16 |
| Panel de pruebas abierto (modo de pruebas) | 326 × 599 en (20, 60): lo **pisa la X** flotante | H-15 |
| Catálogo del nivel 1 | 11 tarjetas en 3 columnas, se ven 345 px de 452: **Francotirador y Eléctrica** (elegibles) quedan en la 4.ª fila, **hay que desplazar**; 3 no disponibles intercaladas | H-20 |
| Los 15 niveles en modo celular | cargan sin error; mapa dentro de 64–624; casilla 62,2 / 50,9 / 49,2 / 46,7 px | — |
| APK de depuración (`--export-debug "Android"`, a una carpeta temporal) | **86,1 MB** (142 MB sin comprimir: `libgodot_android.so` 76 MB, texturas 54 MB, de las que ~28 MB son 8 imágenes de la intro 1920 × 1080 sin pérdida y con mipmaps; audio 3 MB) | H-22 |
| GUT completo | **1664/1664**, 20 119 aserciones, 0 `SCRIPT ERROR`, 64,6 s | — |

## 3. Hallazgos

Severidad: **Crítica** = no se puede jugar; **Alta** = se pierde una acción, oro o el flujo pedido, o hay tirones medidos; **Media** = incomoda, contradice la spec o deja un estado confuso; **Baja** = pulido o riesgo chico. Costo: **bajo** = unas líneas en uno o dos archivos; **medio** = toca la lógica de un flujo o varias pantallas. La etiqueta dice a qué build afecta (§5).

### H-01 · Crítica · «Empezar oleada» no recibe toques ni clics en el modo celular `[mobile]`

- **Qué pasa:** el HUD móvil (`MobileHud`, capa 3, `mobile_hud.gd:88`) crea `MobileStatusBar`, un `Control` de 1280 × 96 en y = 624 con `mouse_filter = MOUSE_FILTER_PASS` (`mobile_hud.gd:100-107`), y adentro una fila (`HBoxContainer`) también `PASS` (`:108-115`). La interfaz de Godot busca el control de más arriba que no sea `IGNORE`, y un `PASS` lo es: el evento sube a sus padres, **no** baja a la capa del HUD. «Empezar oleada» está justo debajo (`hud.tscn:201`, x 1016–1260, y 644–700, capa 1). Resultado: el botón se ve habilitado y no responde.
- **Por qué es crítica:** la partida arranca en `BUILDING`, sin cuenta atrás (`level_session.gd:40-49`; la cuenta solo corre en `COUNTDOWN`, `:57-64`, que empieza después de la primera oleada, `:164-166`). La oleada 1 solo arranca con el botón o con `Espacio` (`game.gd:538`). Sin teclado, **ningún nivel empieza**. Después de la oleada 1 la cuenta atrás sigue sola, pero **no se puede adelantar** una oleada.
- **Evidencia:** sondeo `startwave`: `visible=true disabled=false`, `mouse_clicks_reaching_button=0`, `touch_reaching_button=0`, `wave=0`.
- **Cómo reproducir:** «Interfaz: Celular» en la PC, entrar al nivel 1, clic en «Empezar oleada». No pasa nada. (Test A.1.)
- **Propuesta (para T288, no la apliqué):** `MOUSE_FILTER_IGNORE` en `_status_bar` y en la fila; los botones de adentro siguen siendo `STOP` y reciben lo suyo. Agregar un test que empuje el clic por el viewport (el que hay hoy no lo cubre).
- **Costo:** bajo.

### H-02 · Alta · En los niveles con infraestructura el catálogo abre en «Infraestructura» y vuelve ahí con cada cambio de oro `[mobile]`

- **Qué pasa:** `_refresh_catalog` hace `infrastructure_tab.visible = not _infrastructure_options.is_empty()` (`mobile_hud.gd:524-527`) para decir «esta pestaña existe». Pero un `TabContainer` **esconde** las pestañas que no son la actual y **elige** la que se hace visible. Cada reconstrucción vuelve a poner `visible = true` y salta a «Infraestructura». Y se reconstruye al abrir (`game.gd:268-271`) y con **cada** cambio de oro o recursos (`game.gd:147-148`, `:298-299`).
- **Efecto:** en los niveles 6 a 15 (los que tienen `uses_infrastructure`, medido) el camino «carrito + tarjeta» son **3 toques** (hay que tocar «Torres») y, durante una oleada, **la pestaña se cambia sola debajo del dedo** cada vez que muere un enemigo. Choca con RF-510 («2 toques para llegar al fantasma») y con el «Hecho cuando» (1) de T275, que se probó en el nivel 1.
- **Evidencia:** sondeo `tab`: nivel 1 `tab_after_open=0`; niveles 7 y 15 `tab_after_open=1` y, desde la pestaña 0, `tab_after_gold_change=1`.
- **Cómo reproducir:** nivel 7, «Celular», tocar el carrito: se ve «Infraestructura». Tocar «Torres», empezar la oleada y esperar una muerte: vuelve a «Infraestructura». (Test A.2.)
- **Propuesta:** usar `_catalog_tabs.set_tab_hidden(1, vacía)` en lugar de `visible`; abrir siempre en «Torres» (o recordar la última); no reconstruir con el catálogo cerrado (H-04).
- **Costo:** bajo.

### H-03 · Alta · Un toque en una tarjeta del catálogo se pierde si el oro cambia mientras el dedo está apoyado `[mobile]`

- **Qué pasa:** `_refresh_catalog` borra todas las tarjetas con `queue_free` (`mobile_hud.gd:489-490`, `:582-584`) y crea otras nuevas. Si entre apoyar y soltar cambia el oro (un enemigo muere, llega un bono, entra un recurso), el botón que recibió el «apretar» ya no existe al «soltar»: no se elige nada. Durante un cuadro, además, conviven las tarjetas viejas y las nuevas (la grilla duplica su alto).
- **Por qué importa:** el catálogo **no pausa** (RF-510) y las compras se hacen justamente con la oleada en marcha.
- **Evidencia:** sondeo `catalogrows`: nivel 1, `tap_while_gold_changes chosen=0 catalog_open=true`; sin cambio de oro, `chosen=1`.
- **Cómo reproducir:** abrir el catálogo durante una oleada con muchas muertes (nivel 7 o 15) y tocar tarjetas con un toque normal: algunas no responden. (Test A.3.)
- **Propuesta:** crear las tarjetas una vez por partida y actualizar en el lugar solo texto, `disabled` y motivo; reconstruir únicamente si cambia la lista de torres u opciones.
- **Costo:** bajo a medio.

### H-04 · Alta (rendimiento) · El catálogo se reconstruye en cada cambio de oro, aunque esté cerrado, y da tirones de CPU medibles `[mobile]`

- **Qué pasa:** `_refresh_mobile_catalog` (`game.gd:302-308`) se llama con **cada** `gold_changed` y `resources_changed` (`game.gd:147-148`), esté abierto o no el catálogo. Cada vez: `Wiki._all_towers()` lista la carpeta y carga los recursos (`wiki.gd:188-193`, `:472`), y para las 11 torres `Tower.make_icon` saca la imagen de la textura, la descomprime, la rota y la compone (`tower.gd:98-110`, `tower_visual.gd:15-21`) y crea una `ImageTexture` nueva (que se sube a la GPU). Más 11 botones nuevos y 11 borrados.
- **Evidencia (Ryzen 5 3600, headless, carga 0,3):** 14,9 ms por reconstrucción (4,4 + 12,2 ms). En la oleada 1 del nivel 15 con 25 torres, **mismo escenario en los dos modos, dos corridas**: celular 14 y 16 cuadros > 16,6 ms (peor 35 ms), PC 0 (peor 3 ms), con 15 cambios de oro. Es decir: **casi un tirón por cada muerte**.
- **Qué no dice:** headless no dibuja, así que esto es solo CPU; no mide la subida de texturas a la GPU, que en un celular puede pesar más. **No se sabe cuánto tarda en un celular**: un procesador de celular de gama media suele ser varias veces más lento, pero eso es una suposición, no una medida. Lo que sí se puede afirmar es que es trabajo que la PC no hace, medido.
- **Propuesta:** guardar los íconos por `id` de torre (diccionario estático: se calculan una vez por partida o por sesión), guardar la lista de torres y aplicar H-03 (actualizar en el lugar y solo con el catálogo abierto, refrescando al abrir).
- **Costo:** bajo.

### H-05 · Alta · Un mismo toque lo atienden dos controles: «Apuntar» avanza dos modos y la tilde dispara también el botón de abajo `[mobile]`

- **Qué pasa (barra):** T287 puso `MOUSE_FILTER_IGNORE` en los botones con ícono (`_style_icon_button`, `mobile_hud.gd:382-399`, `:391`) para que solo los atienda `_input`. Pero «Apuntar», «Mejorar» y «Vender» (`:139-161`) **no** pasan por ahí y quedan `STOP`; igual están en la lista de `_handle_status_touch` (`:718-737`), que emite `pressed` a mano (`:735`). En Android el clic emulado llega primero, la interfaz lo convierte en `pressed`, y después el toque vuelve a emitir `pressed`.
  - «Apuntar» avanza **dos** modos por toque (medido 0 → 2). Con cuatro modos, quien quiere «Más fuerte» no puede llegar en el orden esperado.
  - «Mejorar» sube uno solo **porque** el primer `pressed` arma el bloqueo de 0,35 s (`game.gd:966-972`) antes del segundo. Si H-08 (x2) acorta ese bloqueo no cambia nada acá (es el mismo cuadro), pero la protección depende de un efecto lateral.
  - «Vender» arma una sola vez **porque** el segundo `pressed` cae antes de los 0,4 s (`mobile_hud.gd:302-303`). Mismo comentario.
- **Qué pasa (tilde sobre la barra de arriba):** `_handle_status_touch` reclama un toque por rectángulo, aunque la tilde esté encima de otro control. Con el fantasma en la primera fila, la tilde sube sobre la barra de arriba (H-06) y pisa «Pausa» o «x1/x2», que son botones normales del HUD: el clic emulado los pulsa **y** el toque confirma la tilde. Medido: en (19, 0) **cambió la velocidad y construyó la torre**; en (16, 0) **pausó** (y la pausa canceló el fantasma). Viola G6 de T264 / RF-504 punto 5.
- **Cómo reproducir:** tests A.4 (Apuntar) y A.5 (tilde sobre x2). En la PC: «Celular», nivel 1, elegir torre, mover el fantasma a la casilla (19, 0) y tocar donde se superponen tilde y «x1».
- **Propuesta:** un solo dueño por gesto: o los tres botones de la barra también `IGNORE` (como los íconos), o `_handle_status_touch` deja de emitir para los `STOP`; y H-06 para que la tilde no salga del área del mapa. Agregar un test con el orden «clic emulado → toque» para cada botón de la barra.
- **Costo:** bajo.

### H-06 · Media · La tilde y la cruz no tienen límite: salen de la pantalla o se suben a la barra de arriba `[mobile]`

- **Qué pasa:** `_update_placement_position` (`mobile_hud.gd:890-904`) pone la tilde y la cruz arriba del fantasma, hacia el lado que elige `tick_side`, sin recortar contra el área del mapa (y 64–624, x 0–1280).
- **Evidencia:** fantasma en (0, 0), nivel 1: tilde en x = −21 (un tercio afuera), **cruz en x = −97 (entera afuera)**, y = 23 (sobre la barra de arriba). Con el zoom al máximo, en la primera fila visible, y = 20. La tilde de la barra de abajo sigue funcionando, así que no hay bloqueo, pero la del mapa se pierde y pisa la barra (H-05).
- **Propuesta:** recortar al área del mapa; si no entran arriba, ponerlas abajo del fantasma; si no entran al lado elegido, usar el otro.
- **Costo:** bajo.

### H-07 · Media · El fantasma aparece en el centro del mapa, no en el de lo que se ve (RF-505) `[mobile]`

- **Qué pasa:** `_start_mobile_ghost` busca la casilla libre más cercana al centro **del mapa** (`build_controller.gd:400-413`). RF-505 pide «el centro de lo que se ve del mapa».
- **Evidencia:** nivel 15, zoom 1,5 en una esquina: el fantasma quedó en pantalla en (1936, 888), **fuera de la vista** (y con él la tilde del mapa). Hay que desplazar o usar la tilde de la barra a ciegas.
- **Propuesta:** tomar el centro del área visible (64–624) pasado por la cámara (`_screen_to_world`) y buscar desde ahí.
- **Costo:** bajo.

### H-08 · Media · Los temporizadores de la barra se aceleran con la velocidad del juego (RF-512, RF-513) `[mobile]`

- **Qué pasa:** `MobileHud._process` descuenta `delta` (`mobile_hud.gd:877-884`) y `Engine.time_scale` (x2, `game.gd:676-679`, y las velocidades del modo de pruebas) lo multiplica.
- **Evidencia (60 cuadros fijos por segundo):** x1: «Vender» se desarma a 3,02 s y el bloqueo de «Mejorar» dura 0,367 s; **x2: 1,52 s y 0,183 s**; el mínimo de 0,4 s para el segundo toque de «Vender» pasa a 0,2 s. En el modo de pruebas, con velocidades mayores, menos todavía.
- **Propuesta:** contar con `Time.get_ticks_msec()` o con `delta / Engine.time_scale` (el doble toque del mapa ya usa tiempo real, `build_controller.gd:293`).
- **Costo:** bajo.

### H-09 · Media · Una herramienta de infraestructura queda activa sin salida a la vista `[mobile]`

- **Qué pasa:** al elegir «Demoler …» o «Habilitar …» en el catálogo, `BuildController` manda **todo** toque del mapa a la herramienta (`build_controller.gd:369-371`), incluso uno sobre una torre, y la herramienta solo se apaga si la acción salió bien (`game.gd:285-295`). Mientras tanto la barra queda en «vacía» («Tocá el carrito…», `mobile_hud.gd:165-175`, porque `game.gd:466-476` le pasa `null`) **sin cruz**. La única señal es el tinte del carrito (`set_cart_active`).
- **Evidencia:** sondeo `infratool`, nivel 7: después de un toque en una casilla equivocada, `tool_active=true`; un toque en una torre construida **no la elige**; barra «empty», cruz no visible.
- **Salida hoy:** el «atrás» de Android (o `Esc`), o abrir el carrito y elegir otra cosa. Nada en pantalla lo dice.
- **Propuesta:** un estado de barra «Demoler: tocá un …» con la cruz, y el motivo en la barra si el toque no sirve. (Es un estado nuevo de RF-512: necesita una línea de spec, §7 D3.)
- **Costo:** bajo a medio.

### H-10 · Media · En una PC con pantalla táctil y «Interfaz: Celular», tocar el mapa no hace nada `[x86]`

- **Qué pasa:** fuera de Android, el camino de mouse de `BuildController` (`build_controller.gd:315-330`) trata el **clic emulado** como un dedo de índice −1, y el toque real es el índice 0: dos dedos a la vez = pinza, y una pinza no mueve el fantasma ni elige (`touch_gesture.gd:135-171`). `MobileHud` sí filtra el clic emulado (`mobile_hud.gd:703-704`); `BuildController` no.
- **Evidencia:** sondeo `maptap`: con solo el toque, el fantasma va a la casilla pedida; con clic emulado + toque (lo que manda Windows o Linux con pantalla táctil), queda donde estaba.
- **A quién afecta:** a quien pruebe el modo celular en una notebook o tableta Windows táctil. No afecta a Android (ahí se descarta todo clic, `:316-318`) ni a la PC con mouse.
- **Propuesta:** ignorar `InputEventMouseButton`/`Motion` con `device == InputEvent.DEVICE_ID_EMULATION` en `_handle_mobile_input`.
- **Costo:** bajo.

### H-11 · Media · PC: la rueda sobre un panel hace zoom en vez de desplazar el panel (RF-502: la PC no cambia) `[x86]`

- **Qué pasa:** `CameraController` atiende la rueda en `_input`, **antes que la interfaz** (`camera_controller.gd:40-48`), y `_in_map_area` solo mira la altura (`:137-138`). Todo lo que esté sobre el mapa pierde la rueda: la descripción desplazable del panel de torre (`tower_panel.tscn:91`, `ScrollContainer`), los deslizadores de Opciones dentro del menú de pausa, el panel de pruebas.
- **Evidencia:** sondeo `pcwheel`: rueda sobre «Details» del panel (1014–1256 × 364–487): **la cámara se creó y quedó en zoom 1,1**; el panel no se movió.
- **Propuesta:** pasar rueda y botón central a `_unhandled_input` (la interfaz los consume primero si los usa) o mirar `get_viewport().gui_get_hovered_control()`.
- **Costo:** bajo.

### H-12 · Media · Con el zoom mínimo se puede correr el encuadre, y no hay «Ver todo» ni forma de volver `[mobile+x86]`

- **Qué pasa:** `_pan_by_screen_delta` mueve la cámara sin mirar el zoom (`camera_controller.gd:118-121`); el límite solo exige que el centro quede dentro del mapa (`:131-134`), así que con el zoom mínimo el mapa se puede correr hasta media pantalla. «Ver todo» se muestra solo si el zoom es mayor que el mínimo (`:141-145`).
- **Evidencia:** sondeo `panmin`: celular, el borde izquierdo del mapa pasó de x = 17,8 a 167,8 con «Ver todo» oculto; PC (botón central), de 0 a 300.
- **Por qué importa:** RF-506 dice que el mínimo **es** el encuadre de RF-251 y que «Ver todo» vuelve a él. En PC, un clic central sin querer deja el mapa corrido sin botón para recentrar (la rueda hacia atrás no recentra).
- **Propuesta:** con el zoom mínimo, fijar la posición del encuadre (o mostrar «Ver todo» si la posición difiere). Es una decisión de comportamiento (§7 D9).
- **Costo:** bajo.

### H-13 · Media · 42 de los 57 números de `mobile_ui.json` se ignoran si se editan (P2, D-097) `[mobile+x86]`

- **Qué pasa:** `MobileUiConfig.load_from` acepta un valor solo si `typeof(valor) == typeof(DEFAULTS[clave])` (`mobile_ui_config.gd:82-85`). Godot entrega los enteros de un JSON como `float` (`.claude/rules/gdscript.md` lo advierte), y 42 valores por omisión son enteros (`boton_alto_px`, `barra_alta_px`, `flotante_min_px`, `flotante_min_mm`, `toque_max_px`, `pinza_gracia_ms`, `zoom_casilla_max_px`, todos los tamaños de botones y letras…). Hoy no se nota porque el archivo y los valores por omisión coinciden.
- **Evidencia:** sondeo `probe_config`: `json_int_type=float`; con `boton_alto_px: 99`, `barra_alta_px: 80` y `flotante_min_mm: 9` devuelve 56, 64 y 6; los decimales (`toque_max_mm: 3.5`, `vender_rearmar_s: 5.0`) sí se respetan. El test `test_mobile_ui_config_loads_data_file` (`tests/test_mobile_ui.gd:28-31`) no lo detecta porque compara valores iguales.
- **Por qué importa:** D-097 y el plan dicen que los números se ajustan en el archivo después de la prueba en el celular. Hoy esos ajustes **no tendrían efecto** y nadie se enteraría.
- **Propuesta:** aceptar cualquier número (`TYPE_INT` o `TYPE_FLOAT`) y convertirlo al tipo del valor por omisión; test con un archivo que cambie un entero.
- **Costo:** bajo.

### H-14 · Media/Baja · Lo que la spec pide y el código no hace (o hace distinto) `[mobile]`

Cada punto es chico; juntos son la lista de diferencias con el criterio de RF-502 a RF-515:

| | Requisito | Qué hace el código | Evidencia | Severidad |
|---|---|---|---|---|
| a | RF-504.3: 2 mm **calculados** (el valor «va en datos») | usa 21 px fijos (`toque_max_px`) en `build_controller.gd:69`, `camera_controller.gd:34`, `mobile_hud.gd:694`, `:783`; `toque_max_mm` no se usa | grep | Media (en un 16:9 de 294 ppi son 1,8 mm; en una tableta, otra cosa) |
| b | RF-503: texto de las barras ≥ 12 sp (~20 px) | barra de abajo 16 px, botones 17, tarjetas 15 (`mobile_ui.json`) | datos | Media (≈ 9,5 sp en el celular supuesto de T262; hay que leerlo en el celular) |
| c | RF-505: «mientras se arrastra, la tilde y la cruz se esconden» | no se esconden (no hay estado de arrastre expuesto) | `build_controller.gd:306-314`, `game.gd:477-483` | Baja |
| d | RF-505 (2 × 2): tilde «arriba del cuadrado» y la barra dice **cuál** casilla falla | la posición sale de la casilla de arriba a la izquierda (`game.gd:480`): corrida media casilla (23 px en el nivel 15); el motivo es siempre «Ahí no» (`build_controller.gd:424-425`) | sondeo `mortar` | Baja |
| e | RF-506: «Ver todo» ≥ 7,6 mm | 64 px fijos (no usa el DPI); 99 × 64 y se sale 7 px de la pantalla (`mobile_hud.gd:329-340`) | sondeo `overlap` | Baja |
| f | RF-507: franja de borde de 56 px reservada | `franja_px` no se usa en ningún lado; los botones flotantes tapan la primera y la última columna del mapa | grep | Baja (§7 D4) |
| g | RF-507: choque entre botones «del mismo lado, a menos de un botón» | `FloatButtonLayout.avoid` no mira el lado y usa **dos** botones de distancia (`float_button_layout.gd:276-284`): con el carrito a la derecha arriba, la X de la izquierda se corrió de y ≈ 114 a 192 | sondeo `overlap` | Baja |
| h | RF-503: botones del panel de infraestructura ≥ 56 px | tocar un removible abre el **panel de la PC** (`game.gd:361-376`, `build_controller.gd:376-377`) con «Demoler» de 36 px; el carrito (derecha, 0,45) se superpone al panel | sondeo `obstacle` | Media |
| i | RF-510: el carrito «muestra además un puntito» | cambia de tinte (`mobile_hud.gd:625-627`) | lectura | Baja |
| j | RF-513: el armado de «Vender» se borra al pausar | el botón «Pausa» del HUD no lo borra (`game.gd:661-667`); solo el menú de pausa (por la deselección) | lectura | Baja |
| k | RF-104 + RF-505: en pausa no se construye | se puede abrir el carrito en pausa y elegir; la tilde se ve **habilitada** y no hace nada ni dice por qué (`can_build` mira la pausa, `build_controller.gd:171-176`; el motivo no, `:423-428`) | lectura | Baja |

### H-15 · Media · Modo de pruebas en el celular: la X flotante y el carrito tapan el panel de pruebas `[mobile]`

- **Qué pasa:** el panel de pruebas (`dev_panel.gd:22-23`) se abre en (20, 60) y mide 326 × 599; los botones flotantes se atienden en `_input` antes que la interfaz y quedan encima. Medido: la X (0–64 × 192–256) se superpone al panel; tocar ahí **abre el diálogo de salir** en vez del botón de pruebas. El panel también baja hasta y = 659, sobre la barra de abajo.
- **Propuesta:** esconder los flotantes (o tratar el panel como modal) mientras está abierto, o moverlo.
- **Costo:** bajo.

### H-16 · Baja · «Ver todo» queda debajo del carrito si el carrito está arriba a la derecha `[mobile]`

- **Qué pasa:** «Ver todo» está fijo en (1188, 74); el carrito a la derecha con altura cercana a 0 lo pisa, y `_float_button_at` gana siempre (`mobile_hud.gd:774-779`). Medido: se superponen.
- **Propuesta:** que `FloatButtonLayout` lo trate como un obstáculo más, o moverlo al lado contrario del carrito.
- **Costo:** bajo.

### H-17 · Baja · Gestos colgados y la regla de dos dedos entre la interfaz y el mapa `[mobile]`

- **Dedo perdido:** con `input_blocked` (catálogo, diálogo, cartel) `BuildController` descarta también el **soltar** (`build_controller.gd:276-277`) y `TouchGesture` se queda con un dedo y con «hubo dos dedos» (`touch_gesture.gd:159-171`). Medido (sondeo `stuck`): el primer toque después de cerrar el catálogo se toma como fin de pinza y **se pierde**; se recupera solo. Propuesta: dejar pasar los «soltar» a `TouchGesture` aunque la entrada esté bloqueada, o reiniciarlo al bloquear.
- **Dos dedos repartidos:** si un dedo apoya en la tilde y otro en el mapa, la tilde se queda con el suyo y el mapa ve un solo dedo: el soltar sobre la tilde **construye**. RF-504 punto 2 no se cumple a través del límite interfaz/mapa. Leído en el código, no medido.
- **«Hover» pegado:** después de un toque, el último botón tocado puede quedar con el estilo de «pasar el mouse» (el mouse emulado se queda donde tocó). Es de Godot; no lo medí.

### H-18 · Baja (riesgo) · Android con mouse o teclado (DeX, Chromebook, mouse Bluetooth) `[mobile]`

- **Qué pasa:** con «Automática» un Android siempre es «celular». Ahí `BuildController` descarta **todo** clic (`build_controller.gd:316-318`) y los íconos flotantes son `IGNORE` (`mobile_hud.gd:391`): con un mouse de verdad **no se puede tocar el mapa ni el carrito**. La salida es «Interfaz: PC» en Opciones.
- **Propuesta:** decisión de Lucas (§7 D6): aceptar la limitación, o distinguir el mouse real (`device != DEVICE_ID_EMULATION`) del emulado.
- **No probado:** no hay dispositivo.

### H-19 · Media (riesgo) · Sin área segura ni zonas de gesto del sistema `[mobile]`

- **Qué pasa:** no se usa `DisplayServer.get_display_safe_area()` ni `get_display_cutouts()` en ningún lado. Con `stretch/aspect` = `keep` (`project.godot:36`) en 20:9 hay franjas negras de ~240 px reales a los costados, donde suele caer la muesca: probablemente bien. **En un celular 16:9 o 18:9** no hay franjas (o son finas) y los botones flotantes, «pegados al borde», quedan **en la zona del gesto «atrás» de Android** (deslizar desde el costado): arrastrar el carrito desde el borde puede disparar «atrás» (= cancelar o pausa). `orientation = 4` (sensor horizontal, `project.godot:37`) gira 180°: la muesca cambia de lado.
- **Propuesta:** medir primero (kit §4); si molesta, correr la franja de los flotantes según el área segura.

### H-20 · Baja · El catálogo muestra las 11 torres mezcladas y obliga a desplazar `[mobile]`

- **Qué pasa:** el catálogo lista **todas** las torres del juego (`game.gd:305`, `Wiki._all_towers()`), con las que no son del nivel apagadas e intercaladas en el orden de la carpeta (`mobile_hud.gd:491-518`). Con 3 columnas de 192 × 107 y 345 px visibles entran 3 filas: en el nivel 1, **Francotirador y Eléctrica (elegibles) quedan en la 4.ª fila** y hay que desplazar dentro de un `ScrollContainer` lleno de botones, lo mismo que T262 (P-06) no pudo confirmar que funcione con el dedo. La grilla mide 584 px en un área de 768: sobra lugar para una 4.ª columna.
- **Propuesta:** primero las elegibles, al final (o sin mostrar) las que no son del nivel; 4 columnas si entran (§7 D2).
- **Costo:** bajo.

### H-21 · Baja (rendimiento) · Trabajo de interfaz en cada cuadro `[mobile]`

- **Qué pasa:** `Game._process` llama en **cada cuadro** a `show_selected_tower` o `show_ghost_status` + `show_placement` (`game.gd:460-483`), que vuelven a armar textos y, con «Vender» armado, crean un `StyleBoxFlat` nuevo por cuadro (`mobile_hud.gd:256-278`); sin armar, quitan las sobrescrituras de tema cada cuadro.
- **Evidencia:** 76 µs por cuadro con torre elegida y 100 µs con «Vender» armado, contra 0,2 µs en PC (Ryzen). Es poco en la PC; en un celular no se sabe.
- **Propuesta:** actualizar solo cuando cambia algo (oro, selección, estado) y crear el estilo una vez.
- **Costo:** bajo.

### H-22 · Info · APK, renderer y exportación Android `[mobile]`

- **Tamaño:** APK de depuración **86,1 MB** (142 MB sin comprimir). `libgodot_android.so` (plantilla de depuración) 76 MB; texturas 54 MB, de las que ~28 MB son las 8 imágenes de la intro y el epílogo (1920 × 1080, `compress/mode=0` sin pérdida y con mipmaps, por `project.godot:46`); audio 3 MB. **No se exportó la de release** (no hay almacén de claves de release a la vista en `export_presets.cfg`; las credenciales viven fuera del repositorio): la plantilla de release suele ser bastante más chica, pero no lo medí.
- **Renderer:** `gl_compatibility` también en celular (`project.godot:147-148`): OpenGL ES 3, la opción más compatible. Bien para la V1; no lo cambiaría sin medir.
- **Arquitecturas:** solo `arm64-v8a` (`export_presets.cfg:66-69`). Sin `x86_64` no instala en un emulador x86 ni en Chromebooks con Intel; agregarla suma ~40 MB. Como Lucas no puede usar el emulador (G7), no hace falta hoy (§7 D7).
- **Versión:** `version/code=3`, `version/name="1.0.0"` (`export_presets.cfg:70-71`), iguales que en T262 (2026-10-16), aunque desde entonces entró todo M58. Para distinguir APK de prueba conviene subir el nombre o el código en cada entrega (§7 D8).
- **Pantalla:** `screen/immersive_mode=true`; sin opción de borde a borde ni área segura (H-19). `config/quit_on_go_back=false` y `NOTIFICATION_WM_GO_BACK_REQUEST` → acción `cancel` (`game_flow.gd:50-60`): bien.
- **Al irse a segundo plano** (llamada, botón de inicio) el juego **no se pausa solo**: al volver, la oleada sigue. No es parte de M58; es una sugerencia (§7 D5).

### H-23 · Info · Estados sin salida: qué revisé

- **Sin salida real:** H-01 (no se puede empezar). **Sin salida visible:** H-09 (herramienta activa). **Controles fuera de pantalla:** H-06 (cruz). **Botón que no recibe toques:** H-01, H-16.
- **Revisado y bien:** pausa, cartel de entrada, diálogo de salir y menú de pausa esconden los flotantes (`set_modal_open`) y deseleccionan; la partida terminada esconde los flotantes y cierra el catálogo (`mobile_hud.gd:630-647`); el catálogo libera `input_blocked` en todos sus cierres (`close_catalog` emite siempre); «atrás» con el catálogo abierto lo cierra, con fantasma o torre los suelta, y si no hay nada abre la pausa; con una torre elegida «Empezar oleada» se esconde **a propósito** (RF-512) y la cuenta atrás se ve arriba (`hud.gd:678-682`).

### H-24 · Info · Los 15 niveles y los modos en el modo celular

- **Campaña (1–15):** cargan sin errores ni avisos, el mapa entra entre las barras (tabla del §2), la barra de arriba no se pisa en ningún nivel (con recursos, las estadísticas llegan a x = 545). Los niveles 6 a 15 sufren H-02; el 15 y el 12 son donde más se nota H-04 (más torres y enemigos).
- **Asedio, mapas de la comunidad y «probar» del editor:** usan la misma escena y el mismo HUD (`game.gd:87-98`), sin ninguna rama móvil propia; **no los corrí en modo celular** (solo lectura). Lo específico: probando desde el editor la X sale directo al editor (`game.gd:626-628`, cubierto por un test). Un mapa de la comunidad más chico que el área quedaría arriba a la izquierda y no centrado (zoom 1 sin cámara, `game.gd:432-433`); no lo comprobé.
- **Editor de mapas:** en Android solo aparece en el modo de pruebas (RF-210) y no tiene interfaz táctil: fuera de M58.
- **Modo de pruebas:** H-15; el botón «Pruebas [F1]» (`game.gd:758-768`, 880–1008 × 8–40) entra bien en la barra de 64 px.

### H-25 · Baja · Higiene del repositorio

- `godot --headless --import` genera `art/t276-mobile/sizes_1280x720.*.translation` (importa un CSV de medidas como traducción) y `art/t287-mobile/capture.gd.uid` (falta en el repositorio). Los borré antes del commit. Propuesta: `art/**/*.csv` como «Keep File» o en `.gdignore`, y versionar el `.uid`.

## 4. Kit de medición en el celular (lo que hay que mirar con la APK)

Se suma al kit de T262 §6 (K1–K14). Con «Mostrar FPS» del modo de pruebas y «Mostrar toques» de Android:

| # | Prueba | Qué anotar |
|---|---|---|
| M1 | Nivel 1: tocar «Empezar oleada» (después del arreglo de T288) | ¿Arranca al primer toque? |
| M2 | Nivel 7: carrito → ¿qué pestaña abre? Elegir una torre durante una oleada | Toques hasta el fantasma; toques perdidos de 10 |
| M3 | Nivel 15, oleadas finales, con el catálogo **cerrado**: FPS y tirones al morir enemigos | Tirones por oleada y si coinciden con muertes (H-04) |
| M4 | «Apuntar» 4 veces seguidas | ¿Recorre los 4 modos en orden? (H-05) |
| M5 | Fantasma en la fila de arriba, cerca de Pausa/x2 | ¿Se ven la tilde y la cruz? ¿Un toque en x2 construye? |
| M6 | Arrastrar el carrito desde el borde (en un celular sin franjas negras, si hay) | ¿Dispara el «atrás» del sistema? (H-19) |
| M7 | x2 y «Vender»: armar y esperar | ¿Se desarma a los 3 s o antes? (H-08) |
| M8 | Desplazar el catálogo con el dedo sobre las tarjetas | ¿Se mueve? ¿Elige sin querer? (H-20) |
| M9 | Muesca: girar el celular 180° | ¿Tapa algo en los dos lados? |
| M10 | Monitor de Godot por USB (T262 §6.4) durante M3 | Tiempo de proceso y llamadas de dibujo en el tirón |

## 5. Etiquetas y tareas propuestas (listas para pegar)

**Etiquetas propuestas** (no existen todavía en el proyecto): **`[mobile]`** = cambia solo el modo celular o la build de Android; **`[x86]`** = cambia la PC (builds de Windows y Linux x86_64, modo PC o el modo celular forzado en una PC); **`[mobile+x86]`** = lógica, datos o tests comunes que afectan a las dos. Con esa regla, lo ya hecho de M58 queda así: RF-514 (tarjetas) `[mobile+x86]`; rueda y botón central de RF-506 `[x86]`; todo lo demás `[mobile]`. Presets: «Windows Desktop» y «Linux» `[x86]`, «Android» `[mobile]`.

Los números son provisionales (`T289-01`…): se renumeran al pegarlas en `03-tareas.md`. Ninguna está aprobada; las que cambian un comportamiento de la spec dicen «spec antes».

- [ ] **T289-01 · `[mobile]` · La barra de abajo del celular deja pasar los toques a «Empezar oleada».** *(Si T288 ya lo hizo, cerrar como duplicada.)* Refs: H-01, RF-512. **Hecho cuando:** un test empuja por el viewport un clic y un toque (orden de Android) sobre «Empezar oleada» en modo celular y la oleada 1 empieza; Mejorar/Vender/Apuntar siguen respondiendo; GUT en verde.
- [ ] **T289-02 · `[mobile]` · La pestaña del catálogo no salta sola.** Refs: H-02, RF-510. **Hecho cuando:** en los niveles 7 y 15 el catálogo abre en «Torres»; cambiar el oro con la pestaña «Torres» elegida no la cambia; en el nivel 1 no aparece «Infraestructura»; test con los tres niveles.
- [ ] **T289-03 · `[mobile]` · El catálogo se actualiza en el lugar y solo abierto.** Refs: H-03, H-04. **Hecho cuando:** un toque sobre una tarjeta con un cambio de oro entre apoyar y soltar elige la torre (test A.3); con el catálogo cerrado, 20 cambios de oro no crean ni borran nodos; los íconos se calculan una vez por torre; en la oleada del sondeo A.6 el modo celular no tiene más cuadros > 16,6 ms que la PC.
- [ ] **T289-04 · `[mobile]` · Un solo dueño por toque en la barra y la tilde.** Refs: H-05, RF-504.5. **Hecho cuando:** con el orden «clic emulado → toque», un toque en Apuntar avanza un modo, en Mejorar sube uno y en Vender arma una vez (sin depender del bloqueo ni del mínimo); un toque donde la tilde estaría sobre «x1/x2» o «Pausa» hace una sola cosa; tests A.4 y A.5.
- [ ] **T289-05 · `[mobile]` · Tilde y cruz siempre dentro del área del mapa.** Refs: H-06. **Hecho cuando:** con el fantasma en las cuatro esquinas del nivel 1 y del 15 (con y sin zoom máximo) la tilde y la cruz quedan completas dentro de x 0–1280, y 64–624 y no se superponen a la barra de arriba; test de `FloatButtonLayout` o del HUD.
- [ ] **T289-06 · `[mobile]` · El fantasma nace en el centro de lo que se ve.** Refs: H-07, RF-505. **Hecho cuando:** con zoom 1,5 en una esquina del nivel 15, elegir una torre deja el fantasma dentro del área visible; sin zoom, igual que hoy; test.
- [ ] **T289-07 · `[mobile]` · Temporizadores de la barra en tiempo real.** Refs: H-08, RF-512, RF-513. **Hecho cuando:** con x1, x2 y la mayor velocidad del modo de pruebas, «Vender» se desarma a 3 s ± 1 cuadro y el bloqueo de Mejorar dura 0,35 s ± 1 cuadro (test con `Engine.time_scale`).
- [ ] **T289-08 · `[mobile+x86]` · `MobileUiConfig` acepta enteros del JSON.** Refs: H-13, P2. **Hecho cuando:** un archivo de prueba con `boton_alto_px: 99` y `flotante_min_mm: 9` devuelve 99 y 9 (enteros); un texto donde va un número sigue usando el valor por omisión con aviso; test.
- [ ] **T289-09 · `[x86]` · La rueda y el botón central no le roban la entrada a la interfaz.** Refs: H-11, RF-502, RF-506. **Hecho cuando:** en PC, la rueda sobre la descripción del panel de torre la desplaza y la cámara no cambia; sobre el mapa sigue acercando; test con eventos por el viewport.
- [ ] **T289-10 · `[x86]` · El mapa ignora el clic emulado en «Interfaz: Celular» fuera de Android.** Refs: H-10, G8. **Hecho cuando:** un toque con su clic emulado mueve el fantasma a la casilla tocada en una sola vez (test con el orden de A.4); con mouse real sigue funcionando.
- [ ] **T289-11 · `[mobile]` · Estado «herramienta de infraestructura» en la barra.** Refs: H-09. **Spec antes** (un estado nuevo de RF-512). **Hecho cuando:** con «Demoler» elegido la barra lo dice y muestra la cruz; la cruz y un toque en una torre la sueltan; un toque inválido muestra el motivo; test.
- [ ] **T289-12 · `[mobile+x86]` · El zoom mínimo conserva el encuadre.** Refs: H-12, RF-506. **Spec antes** (§7 D9). **Hecho cuando:** con el zoom mínimo, dos dedos o el botón central no corren el mapa (o «Ver todo» aparece y lo devuelve), según lo que decida Lucas; test.
- [ ] **T289-13 · `[mobile]` · Panel de infraestructura táctil.** Refs: H-14 (h), RF-503. **Hecho cuando:** tocar un removible en modo celular muestra sus acciones con botones de 56 px o más y sin quedar debajo de un botón flotante (o la acción se ofrece desde la barra); captura del nivel 7.
- [ ] **T289-14 · `[mobile]` · Flotantes que no tapan paneles ni «Ver todo».** Refs: H-15, H-16, H-14 (g). **Hecho cuando:** con el panel de pruebas abierto los flotantes no reciben toques encima de él; «Ver todo» nunca queda debajo del carrito y entra en la pantalla; el choque entre botones solo corre al del mismo lado; tests de `FloatButtonLayout`.
- [ ] **T289-15 · `[mobile]` · Umbral del toque en milímetros.** Refs: H-14 (a), RF-504.3. **Hecho cuando:** el umbral sale de `toque_max_mm` con el DPI y la escala (como `FloatButtonLayout.minimum_button_size`), con 21 px de respaldo; test con DPI 405 y 294.
- [ ] **T289-16 · `[mobile]` · Detalles de RF-505/RF-513.** Refs: H-14 (c, d, j, k). **Hecho cuando:** la tilde y la cruz se esconden durante el arrastre; en el Mortero van arriba del cuadrado y la barra dice qué casilla falla; el botón Pausa desarma «Vender»; en pausa la tilde se ve apagada con «En pausa»; tests.
- [ ] **T289-17 · `[mobile]` · Gestos que no quedan colgados.** Refs: H-17. **Hecho cuando:** después de cerrar el catálogo en medio de un gesto, el primer toque cuenta (test del sondeo `stuck`); una tilde apoyada con un segundo dedo en el mapa no construye.
- [ ] **T289-18 · `[mobile]` · Interfaz por cuadro solo cuando cambia algo.** Refs: H-21. **Hecho cuando:** sin cambios de estado, `Game._process` no reescribe textos ni estilos (contador en un test) y el estilo de «Vender» armado se crea una vez.
- [ ] **T289-19 · `[mobile]` · Orden y columnas del catálogo.** Refs: H-20. **Spec antes** (§7 D2). **Hecho cuando:** en el nivel 1 las 8 elegibles se ven sin desplazar; capturas de los niveles 1, 7 y 15.
- [ ] **T289-20 · `[mobile+x86]` · Tests táctiles de punta a punta.** Refs: §5.1. **Hecho cuando:** existe un archivo de tests que empuja `InputEventScreenTouch`/`ScreenDrag` (y el clic emulado) por un `SubViewport` en una partida real y cubre: toque en el mapa, arrastre del fantasma, pinza que no construye, dedo rezagado (150 ms), «atrás» por `InputEventAction`, y los casos de T289-01 a T289-04.
- [ ] **T289-21 · `[mobile]` · APK de prueba identificable y más liviana.** Refs: H-22. **Spec/decisión antes** (§7 D7, D8). **Hecho cuando:** cada APK de prueba lleva un `version/name` propio; si Lucas lo aprueba, las imágenes de la intro se importan con compresión con pérdida y sin mipmaps y la APK baja de tamaño (medido); se anota el tamaño de la de release.
- [ ] **T289-22 · `[mobile+x86]` · Higiene de la importación.** Refs: H-25. **Hecho cuando:** `godot --headless --import` en un clon limpio no deja archivos sin versionar.

### 5.1 Huecos de cobertura de los tests (f)

Lo que hoy prueban los tests móviles (`tests/test_mobile_ui.gd`, 18 tests; `tests/test_mobile_hud_input.gd`, 4) está bien para la lógica pura (`UiMode`, `TouchGesture`, `GhostPlacement`, `FloatButtonLayout`, `UiPrefs`) y para el carrito con eventos reales. Lo que **no** cubre nadie:

1. **Ningún test toca el mapa con eventos:** todos llaman a `_mobile_map_tap(...)` directamente (`test_mobile_ui.gd:241-277`); no se prueba la cadena `InputEventScreenTouch` → `_handle_mobile_input` → `TouchGesture` → casilla, ni el arrastre relativo, ni la pinza que no construye en una partida real, ni el dedo rezagado con 150 ms.
2. **Ningún test usa el orden real «clic emulado → toque»** en los botones de la barra (H-05) ni en el mapa fuera de Android (H-10).
3. **Ningún test pulsa «Empezar oleada» en modo celular** (H-01).
4. **El catálogo se prueba llamando a `card.pressed.emit()`** (`test_mobile_ui.gd:410`) y solo en el nivel 1: no se prueba la pestaña en niveles con infraestructura (H-02) ni el toque con cambios de oro (H-03).
5. **Nada prueba la velocidad del juego** contra los temporizadores (H-08), ni la tilde contra los bordes (H-06), ni el fantasma con zoom (H-07).
6. **El test del archivo de datos** compara valores iguales (H-13).
7. **No hay test de rendimiento ni de nodos creados** por cambio de oro (H-04).
8. **No hay test de la rueda sobre la interfaz en PC** (H-11): `test_pc_camera_input_adds_zoom_without_mobile_controls` llama a `_zoom_at` directo.

## 6. Qué no se probó

- **Nada corrió en un celular.** No hay dispositivo (`adb devices` vacío) ni emulador. En particular **no se probó**: el dedo real (tamaño, temblor, oclusión), la pinza y el arrastre con dedos, cómo entrega Android los eventos (el orden «clic emulado → toque» lo verifiqué en el `Input` de Godot de escritorio y **supongo** que Android, que usa el mismo código, hace igual), el DPI real y los milímetros, la muesca y las zonas de gesto, el «atrás» por gesto, el modo inmersivo, la lectura de las letras, el rendimiento y el calentamiento.
- **Rendimiento:** solo CPU en headless (sin dibujo ni GPU) en un Ryzen 5 3600 con la máquina casi libre (carga 0,3–1,6). Los tirones de H-04 son de la CPU de escritorio; **no afirmo** que en el celular haya tirones ni cuánto duran: digo que existe ese trabajo y que en la PC no está. No medí la subida de texturas a la GPU.
- **APK:** exporté **solo la de depuración** (86,1 MB) a una carpeta temporal, **no la instalé** en ningún lado y la borré. No exporté la de release (no hay claves de release a la vista).
- **No jugué** ninguna partida a mano. No saqué capturas. No corrí Asedio, mapas de la comunidad ni «probar» del editor en modo celular (solo lectura de código). No probé la selección de niveles ni el desplazamiento del catálogo con el dedo.
- **No verifiqué** el arreglo de T288 (lo hace otro agente) ni corrí el bot de balance para comparar la PC antes y después de M58 (RF-515, último criterio): no hay una corrida de referencia previa en este worktree.
- **H-17 (dos dedos repartidos), H-18 (mouse en Android), H-19 (área segura)** son lectura de código o riesgo, sin medición.

## 7. Decisiones que necesitan a Lucas

Las marcadas con *(sugerencia de Claude)* no las pidió nadie: si Lucas las quiere, van a §13 «Sugerencias de Claude» de la spec antes de programarse.

1. **D1 · Pestaña del catálogo en los niveles con infraestructura (H-02):** ¿abre siempre en «Torres», o recuerda la última que se usó en la partida?
2. **D2 · Qué torres muestra el catálogo (H-20):** hoy muestra las 11 del juego, con las que no son del nivel apagadas e intercaladas. Opciones: (a) solo las del nivel; (b) todas, pero las del nivel primero; (c) como hoy. Y si se pasa a 4 columnas para no desplazar.
3. **D3 · Estado nuevo de la barra para «Demoler/Habilitar» (H-09):** ¿se agrega a RF-512 con su cruz, o la herramienta se suelta sola si el toque no sirve?
4. **D4 · La franja de 56 px de RF-507 (H-14 f):** ¿se reserva de verdad (el mapa se achica un poco a los costados) o se saca de la spec porque los botones ya se pegan al borde?
5. **D5 · Pausa automática al ir a segundo plano (H-22)** *(sugerencia de Claude)*: al recibir una llamada o tocar «inicio», ¿la partida se pausa sola?
6. **D6 · Android con mouse (H-18):** ¿se acepta que con mouse haya que elegir «Interfaz: PC», o el modo celular también debería aceptar un mouse real?
7. **D7 · APK más liviana (H-22)** *(sugerencia de Claude)*: ¿comprimir con pérdida y sin mipmaps las 8 imágenes de la intro (~28 MB sin comprimir hoy)? Cambia cómo se ven (poco) y toca arte: necesita su OK con una muestra. ¿Y exportar también `x86_64` (+~40 MB) para Chromebooks o emuladores?
8. **D8 · Versión de las APK de prueba (H-22):** ¿subir `version/name` (por ejemplo `1.0.0-t289`) en cada APK que se manda a probar?
9. **D9 · Desplazar con el zoom mínimo (H-12):** ¿se bloquea (el mínimo es el encuadre fijo) o se permite y aparece «Ver todo»? Vale también para el botón central en PC.
10. **D10 · Construir en pausa en el celular (H-14 k):** RF-104 dice que no. ¿El carrito se apaga en pausa, o se puede preparar el fantasma en pausa y la tilde dice «En pausa»? (Lo segundo es lo que T262 echaba de menos: planear con calma.)
11. **D11 · Etiquetas `[mobile]`/`[x86]`/`[mobile+x86]` (§5):** ¿se adoptan en `03-tareas.md` con la definición propuesta?

12. **D12 · Temporizadores de la barra con velocidad x2 (H-08), pendiente desde T292:** RF-512 y RF-513 dicen «se desarma solo a los 3 s», «0,35 s sin responder» y «0,4 s entre toques» sin aclarar si son segundos **reales** o **de juego**. Hoy son de juego (con x2 duran la mitad en tiempo real: 1,5 s, 0,18 s, 0,2 s). ¿Se cuentan en tiempo real (más predecible para el dedo; el doble toque del mapa ya lo hace) o se dejan como están? No se cambió hasta que Lucas elija.

### Respuestas de Lucas (2026-10-20)

Fuente: `~/.agents/decisiones-2026-10-20.md`. Lo que sigue **no** reemplaza el texto de arriba (el hallazgo y la pregunta quedan como se escribieron); anota qué se contestó y dónde quedó.

| # | Respuesta | Dónde quedó |
|---|---|---|
| D1 / D2 | Un solo catálogo móvil, con solo las torres elegibles del nivel (sin pestañas). | M60, RF-540 y RF-541 (ya hecho en T301). |
| D4 | **La franja de 56 px de RF-507 se saca de la spec.** | M68, RF-619 y **D-164**; se borró también `franja_px`. |
| D5 | La partida se pausa sola al pasar la app a segundo plano. | M60, RF-544 (ya hecho en T303). |
| D6 | Mouse y toque conviven, por dispositivo y no por plataforma. | M61, RF-552 (ya hecho en T314). |
| D9 | Con el zoom mínimo el mapa se puede correr y aparece «Ver todo» para volver. **En PC: botón y también una combinación de teclas, configurable** (ambos). | M60, RF-545 (celular y botón de PC); M68, RF-612 a RF-615 y **D-161**, **D-162**. |
| D10 | **Construir en pausa en el celular: se bloquea el carrito.** (Lucas además quiere pensar para qué sirve la pausa, sin prisa; «planear con calma» queda como idea futura.) | M68, RF-610 y RF-611 y **D-160**. |
| D12 | Los tiempos de Vender y de Mejorar siguen contándose en tiempo de juego (sin cambio). | Sin cambio en RF-512 y RF-513. |

## Apéndice A · Scripts que reproducen los hallazgos

Son tests de GUT **escritos para este informe; no están en `tests/`** (pedido de la tarea). Quien arregle puede pegarlos en un archivo `tests/test_mobile_touch_e2e.gd`. **Verificado:** los copié a una carpeta temporal fuera de `tests/`, los corrí con `gut_cmdln.gd -gtest=…` y **los 8 fallan hoy, cada uno con el motivo del hallazgo** (0 ≠ 1 en la oleada; pestaña 1 ≠ 0 dos veces; 0 ≠ 1 en la tarjeta; 2 ≠ 1 en Apuntar; la tilde arriba de y = 64; «Vender» desarmado; 56 ≠ 99 y 6 ≠ 9; la cámara se acercó), sin `SCRIPT ERROR`. Después borré la carpeta. Un arreglo correcto debería ponerlos en verde.

```gdscript
extends GutTest
# Reproducciones de T289. Partida real en un SubViewport, modo celular, guardado de prueba.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t289_e2e.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _start(level_index: int) -> void:
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


## El orden de Godot (verificado con Input.parse_input_event): primero el clic emulado, después el toque.
func _android_touch(pos: Vector2, pressed: bool) -> void:
	var mouse := InputEventMouseButton.new()
	mouse.position = pos
	mouse.global_position = pos
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = pressed
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	_viewport.push_input(mouse, true)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = pos
	touch.pressed = pressed
	_viewport.push_input(touch, true)
	await get_tree().process_frame


func _free_cell(tower: TowerData) -> Vector2i:
	for y: int in _game.level.map_size().y:
		for x: int in _game.level.map_size().x:
			if _game.build_controller.cells_free(tower, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


# A.1 · H-01 (falla hoy): «Empezar oleada» recibe el toque en modo celular.
func test_start_wave_button_receives_touch_in_mobile_mode() -> void:
	await _start(0)
	var button: Button = _game.hud.get_node("BottomBar/StartWaveButton")
	var center: Vector2 = button.get_global_rect().get_center()
	await _android_touch(center, true)
	await _android_touch(center, false)
	assert_eq(_game.session.wave, 1, "la oleada 1 empieza con el botón")


# A.2 · H-02 (falla hoy): el catálogo abre en «Torres» y no salta con el oro.
func test_catalog_keeps_towers_tab_in_infrastructure_levels() -> void:
	await _start(6)  # nivel 7
	_game.mobile_hud.open_catalog()
	await get_tree().process_frame
	assert_eq(_game.mobile_hud._catalog_tabs.current_tab, 0, "abre en Torres")
	_game.mobile_hud._catalog_tabs.current_tab = 0
	_game.session.earn(1)
	await get_tree().process_frame
	assert_eq(_game.mobile_hud._catalog_tabs.current_tab, 0, "un cambio de oro no cambia la pestaña")


# A.3 · H-03 (falla hoy): un toque en una tarjeta cuenta aunque el oro cambie en el medio.
func test_catalog_card_tap_survives_a_gold_change() -> void:
	await _start(0)
	var chosen: Array[int] = [0]
	_game.mobile_hud.tower_chosen.connect(func(_i: int, _alt: bool) -> void: chosen[0] += 1)
	_game.mobile_hud.open_catalog()
	await get_tree().process_frame
	var card: Button = null
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		if not (child as Button).disabled:
			card = child
			break
	var center: Vector2 = card.get_global_rect().get_center()
	await _android_touch(center, true)
	_game.session.earn(1)  # muere un enemigo con el dedo apoyado
	await get_tree().process_frame
	await _android_touch(center, false)
	assert_eq(chosen[0], 1)


# A.4 · H-05 (falla hoy): un toque en «Apuntar» avanza un solo modo.
func test_targeting_advances_once_per_touch() -> void:
	await _start(0)
	var tower_data: TowerData = _game.available_towers[0]
	_game.build_controller.try_build(tower_data, _free_cell(tower_data))
	var tower: Tower = _game.tower_container.get_child(0)
	_game.build_controller.select_placed(tower)
	await get_tree().process_frame
	await get_tree().process_frame
	var before: int = tower.targeting
	var center: Vector2 = _game.mobile_hud._target_button.get_global_rect().get_center()
	await _android_touch(center, true)
	await _android_touch(center, false)
	assert_eq(tower.targeting, (before + 1) % Tower.TargetMode.size())


# A.5 · H-05/H-06 (falla hoy): la tilde no se sube a «x1/x2»; un toque ahí hace una sola cosa.
func test_tick_never_overlaps_top_bar_buttons() -> void:
	await _start(0)
	var controller: BuildController = _game.build_controller
	controller.select(0)
	await get_tree().process_frame
	controller._move_mobile_ghost(Vector2i(19, 0))
	await get_tree().process_frame
	await get_tree().process_frame
	var tick: Rect2 = _game.mobile_hud._confirm_button.get_global_rect()
	assert_true(tick.position.y >= 64.0, "la tilde queda debajo de la barra de arriba")
	assert_true(tick.position.x >= 0.0 and tick.end.x <= 1280.0, "y dentro de la pantalla")


# A.6 · H-08 (falla hoy): con x2, «Vender» armado dura 3 s reales.
func test_sell_arm_lasts_three_real_seconds_at_double_speed() -> void:
	await _start(0)
	var tower_data: TowerData = _game.available_towers[0]
	_game.build_controller.try_build(tower_data, _free_cell(tower_data))
	_game.build_controller.select_placed(_game.tower_container.get_child(0))
	await get_tree().process_frame
	_game.set_speed(2.0)
	_game.mobile_hud._on_sell_pressed()
	# 100 cuadros a 60 fps = 1,67 s reales; con time_scale = 2 Godot entrega delta = 2/60 (3,33 s «de juego»).
	for i: int in 100:
		_game.mobile_hud._process(2.0 / 60.0)
	assert_true(_game.mobile_hud._sell_armed, "a 1,67 s reales sigue armado (se desarma a los 3 s reales)")


# A.7 · H-13 (falla hoy): un entero editado en el archivo de datos se respeta.
func test_mobile_ui_config_respects_integer_values() -> void:
	var path: String = "user://test_t289_mobile_ui.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"boton_alto_px": 99, "flotante_min_mm": 9}')
	file.close()
	var config: MobileUiConfig = MobileUiConfig.load_from(path)
	assert_eq(int(config.get_value("boton_alto_px")), 99)
	assert_eq(int(config.get_value("flotante_min_mm")), 9)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


# A.8 · H-11 (falla hoy, en PC): la rueda sobre el panel de torre no mueve la cámara.
func test_pc_wheel_over_tower_panel_does_not_zoom() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	await _start(0)
	var tower_data: TowerData = _game.available_towers[0]
	_game.build_controller.try_build(tower_data, _free_cell(tower_data))
	_game.build_controller.select_placed(_game.tower_container.get_child(0))
	await get_tree().process_frame
	var details: Control = _game.hud.tower_panel.find_child("Details", true, false)
	var wheel := InputEventMouseButton.new()
	wheel.position = details.get_global_rect().get_center()
	wheel.global_position = wheel.position
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	_viewport.push_input(wheel, true)
	await get_tree().process_frame
	assert_true(_game.camera == null or is_equal_approx(_game.camera.zoom.x, _game.minimum_map_zoom))
```

**A.9 · H-04, medición de tirones (no es un test: compara los dos modos).** Partida del nivel 15 con 25 torres (`earn(20000)` y `try_build` de `available_towers[1]`), `start_next_wave()`, y 1500 cuadros midiendo `Time.get_ticks_usec()` entre `await get_tree().process_frame`: contar los cuadros de más de 16 600 µs con `ui_mode = 1` y con `ui_mode = 2`. Resultado en esta PC: 14–16 contra 0 (§2).

**A.10 · H-10 (PC con pantalla táctil).** Igual que A.4 pero sobre el mapa: con un fantasma activo, `_android_touch` sobre otra casilla libre deja el fantasma donde estaba; con solo el `InputEventScreenTouch`, se mueve.
