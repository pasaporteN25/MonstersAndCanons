# T579 · Revisión integrada de M89

Fecha: 2026-11-03 · Rama: `feature/t579-revision-integrada` (sobre `feature/m89-integracion` en `2c7d59d`) · Ejecutor: Claude Sonnet.

**Límite honesto:** todo lo de abajo se probó con tests y con capturas del **celular simulado** (Interfaz → Celular, en una ventana real de la computadora). No se probó nada en un teléfono: tamaño físico, pulgar, muesca, barra de gestos, sol y rendimiento en Android quedan para la lista de `PENDIENTES-LUCAS.md`, sección F.

## 1. Lo que cambió respecto de las rondas anteriores

- **Sí hubo forma de sacar capturas.** La máquina tiene un servidor X con `DISPLAY=:0` y Godot (OpenGL, GTX 1660 Super) abre una ventana normal sin `--headless`. Las fichas anteriores asumieron que no había ventana; sí la hay. La herramienta nueva `tools/capture_m89.tscn` abre el **host real** (`PresentationHost`, con rieles) con una ventana de 1280 × 720 (16:9) o 1600 × 720 (20:9), el `ui_mode` celular y un guardado temporal, y guarda un PNG por estado. Capturas (68, en `Capturas/`, carpeta que git ignora: quedan solo en este worktree) con nombres `T564-*`, `T565-*`, `T568-*`, `T570-*`, `T571-*` y `T574-*`, cada una con su tamaño al final del nombre.
- **Un error real encontrado y arreglado (T565):** con «Cuadrícula marcada» prendida, `MapGridOverlay._draw` llamaba a `MapGrid.map_size()`, que no existe. Los tests de T565 usaban `setup(null)` y nunca llegaban a ese dibujo; en una partida real el dibujo fallaba en cada cuadro (`Invalid call. Nonexistent function 'map_size'`) y no se veía ninguna línea. Se corrigió leyendo `width` y `height` del `MapGrid` y se sumó un test con la partida real (`tests/test_m89_integration.gd`). Con la corrección, la cuadrícula se ve en las capturas `T565-cuadricula-*` a zoom mínimo y a 2,0.
- **APK:** sí se pudo exportar (ver §5).

## 2. RF de M89: evidencia

| RF | Qué pide | Evidencia | Estado |
|---|---|---|---|
| RF-731 | Zoom hasta 2,0 | `tests/test_camera_pan_zoom.gd` (T568); capturas `T568-zoom-maximo-*` y `T568-zoom-maximo-nivel03/06/09/12/15-*` en 16:9 y 20:9 | Se cumple. El suelo y los adornos a 2,0 se ven nítidos y sin cortes en los niveles 1, 3, 6, 9, 12 y 15 (capturas). Falta ver la nitidez en un teléfono. |
| RF-732 | Un dedo mueve el mapa | test de T568 y `test_m89_integration` (desplazar y doble toque); captura `T568-zoom-maximo-desplazado-*` | Se cumple con tests. El gesto con el dedo real no es comprobable acá. |
| RF-733 | Rieles en las franjas | `tests/test_mobile_rails.gd` (22); capturas `T570-rieles-*-1600x720` (rieles) y `-1280x720` (sin rieles, igual que antes) | Se cumple. |
| RF-734 | Qué va en cada riel, «+» y «−» | `test_mobile_rails.gd`; capturas `T570-rieles-inicio/torre-elegida/carrito/fantasma` | Se cumple. Íconos de «+» y «−» provisionales. |
| RF-735 | «Menú» abre el menú de pausa | tests de T567 y `test_mobile_rails.gd`; capturas con el botón «Menú» en 16:9 y 20:9 | Se cumple. |
| RF-736 | × a la izquierda, «Vender» lejos de «Empezar oleada» | `tests/test_mobile_tower_bar.gd` (14); capturas `T564-marca-*-1280x720` y `T570-rieles-torre-elegida-1600x720` | Se cumple (en 16:9 la × está al borde; en 20:9 «Vender» está en el riel). |
| RF-737 | Marca de torre elegida | `tests/test_tower_selected_marker.gd`; captura `T564-marca-torre-elegida-*` (solo la elegida lleva las esquinas amarillas) | Se cumple. «A pleno sol» no es comprobable acá. |
| RF-738 | Presentación del jefe a pantalla completa | `test_boss_presentation_mobile.gd`; capturas `T571-jefe-*` en 16:9 y 20:9 (sin franjas, texto entero, el fondo del terreno vuelve al cerrar) | Se cumple en 16:9 y 20:9. **19,5:9 y 21:9 sin captura** (se probaron en tests de geometría). |
| RF-739 | Foco en el tutorial | `tests/test_tutorial_focus.gd` (26); capturas `T574-tutorial-00` a `14` en PC y celular, 16:9 y 20:9 | Se cumple (ver §4: el rótulo toca «Pausa» en 20:9). Cómo se percibe, no comprobable acá. |
| RF-740 | Doble toque abre la compra | `tests/test_empty_cell_double_tap.gd` y `test_m89_integration` | Se cumple con tests. |
| RF-741 | Cuadrícula marcada | `tests/test_map_grid_options.gd` **más el arreglo de esta tarea**; capturas `T565-cuadricula-*` | Se cumple **desde T579**: antes de este arreglo no dibujaba nada en una partida real. |
| RF-742 | Ráfaga 0,8 / 1,1 / 1,4 | `tests/test_new_content.gd`; bot `mix` de T563 | Se cumple. «Cómo se siente», no comprobable acá. |

**RF que no se cumplen:** ninguno al cierre de esta tarea. Quedó resuelto el de RF-741 y quedan los «no comprobable acá» de arriba.

## 3. Combinaciones del paso 2

Probadas en `tests/test_m89_integration.gd` (6 tests, partida real con rieles 20:9) y con capturas:

| Combinación | Resultado |
|---|---|
| Zoom 2,0 con rieles y fantasma | El zoom llega a 2,0 con rieles; el fantasma nace en la casilla del centro de **lo que se ve** (a menos de 3 casillas de él); los rieles siguen y no se vuelven translúcidos. Captura `T570-rieles-fantasma-1600x720`. |
| Doble toque tras desplazar | Dos casillas distintas no cuentan; la misma casilla cuenta aunque el mapa se haya movido entre los toques (un arrastre no es un toque). |
| Marca de selección con zoom y cuadrícula | La torre sigue elegida con zoom y con «Ver todo»; la cuadrícula dibuja (después del arreglo); captura `T565-cuadricula-zoom-maximo`. La marca con zoom 2,0 se mira en `T564-marca-*` (zoom 1,0) y se mide por el test; no hay una captura que junte marca, zoom 2,0 y cuadrícula. |
| «Vender» armado al abrir «Menú» | Con el menú abierto los rieles se ocultan, «Vender» no vende aunque se toque, y al cerrar la torre sigue ahí. Qué pasa con el armado al volver no se verificó con captura. |
| Presentación del jefe con rieles | La presentación oculta los rieles; cambiar de tamaño durante ella no los revive; al cerrar vuelven, sin botones duplicados (6 a la izquierda). Capturas `T571-*`. |
| Tutorial completo en 16:9 y en 20:9 | Recorrido real de los 15 pasos en las dos medidas (`T574-tutorial-00` a `14`). El carrito del riel recibe el anillo en 20:9. |
| Cambio de tamaño durante cada uno | Probado con el jefe y con el rearmado de los rieles (`test_mobile_rails`). **No** probado durante el tutorial completo ni durante «Vender» armado. |

## 4. Puntos abiertos de las tareas

- **Suelo y adornos a zoom 2,0 (T568):** capturas de seis niveles; nada se ve roto. El «Acercaste el mapa» queda sin fondo pegado a la barra de arriba (legible, con borde oscuro). Se dejó a Lucas (F12).
- **T572, caminata a la izquierda, sin partida real:** esta tarea **no** lo repitió (no se armó una partida que haga caminar enemigos hacia la izquierda ni se tomó captura). Queda en la lista de Lucas (F12) como mirar en partida. El informe de T572 no halló un error de código.
- **Anillo del tutorial sobre rieles (T574):** con rieles de 20:9 el carrito tiene el anillo y los demás botones se oscurecen (captura `T574-tutorial-04-open_cart-1600x720`). El rótulo «Tocá acá» se pone a la izquierda del carrito y **toca el botón «Pausa»** de la barra de arriba; es chico y no tapa la acción, pero conviene que Lucas lo mire. En «Vender» (paso de lectura) se marca el botón del riel sin oscurecer.
- **Nivel 12 con `mejoras=temprana` (T563):** se intentó repetir el bot `mix` (`level=12 mejoras=temprana`); pasó de 20 minutos sin terminar y se cortó. No hay dato nuevo: vale lo de T563 (pierde antes y después del cambio de la Ráfaga, así que no lo causa).
- **T563 sin partida real, T566 sin capturas, T570 sin capturas:** hay capturas nuevas de 16:9 y 20:9 de lo que T566, T570 y T574 dejaron pendiente. Quedan sin captura 19,5:9 y 21:9.
- **Tilde del estado «con fantasma» (T566):** capturada en `T570-rieles-fantasma-*`; en 20:9 la tilde queda a la derecha de la barra.
- **Ruido al cerrar la herramienta de capturas:** al salir se imprime `get_viewport_rect` desde `SideRails._rails_rects` (llamada desde `MobileHud._exit_tree`, con el nodo ya fuera del árbol). Es un mensaje de consola, no cambia nada visible ni ocurre en partida normal; **no se arregló** (no es un ajuste de integración).

## 5. APK

Sí se pudo exportar: `godot --headless --path . --export-debug "Android" build/MonstersCanons.apk` (Java 17 en `~/.local/jdk`, SDK de Android en `~/Android/Sdk`, plantillas 4.7.2 y llave de depuración presentes). Salió firmado, **86.582.409 bytes** (unos 83 MB), en `build/MonstersCanons.apk` dentro de este worktree (la carpeta `build/` no se versiona). No se instaló ni probó en ningún aparato (`adb` no tiene dispositivo). Para instalarlo, `ONBOARDING.md` §7.4.

## 6. Tests

Suite completa: 2749/2749 tests, 58.979 asserts, 0 `SCRIPT ERROR` ni `Parse Error` (antes 2743; +6 de `test_m89_integration.gd`).
