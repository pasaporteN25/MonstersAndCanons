# T451 · Frente C (B-54): «Ver todo», panel de mejora, círculo de alcance y Opciones

- **Tipo:** análisis. No se tocó código, escenas, `data/`, ni los documentos `specs/01` a `04`.
- **Base:** `origin/main` = `250e724`. Rama `feature/t451-camara-hud-opciones-analisis`.
- **Cómo se hizo:** lectura de código y de spec. **No se corrió Godot ni GUT y no se tomaron capturas.** Las maquetas de abajo son texto: sirven para discutir la distribución, no son pixel-perfect. Todo lo que dice «hoy» sale de leer el archivo citado; lo que no pude comprobar está marcado como tal.
- **Convención:** lo que depende de Lucas va marcado **PENDIENTE DE LUCAS**. Los números de RF/D que propongo son sugeridos (RF-666 en adelante, D-187 en adelante); el agente que reserva `01..04` los fija.

> Nota sobre las líneas que me pasaron: en `scenes/ui/tower_panel.gd` el título «Al nivel N:» está en `:113` (no `:114`) y el botón «Mejorar a nivel N» en `:231` (no `:229`). El resto de las referencias coincide.

---

## 1. «Ver todo»

### 1.1 Qué hace exactamente

`CameraController.view_all()` (`scenes/game/camera_controller.gd:203-207`) hace dos cosas:

1. Pone el zoom de la cámara en el **zoom mínimo** (`_minimum_zoom`), que es el encuadre de RF-251: `min(1; 1280 ÷ (ancho×64); área alta ÷ (alto×64))`. En un mapa que entra entero (por ejemplo 20×9) el mínimo es 1,0.
2. Pone el centro de la cámara en `_fit_position()` (`:160-165`), o sea el mapa centrado en el área que queda entre la barra de arriba y la de abajo.

Después llama a `_update_view_all()`, que como ya no hay zoom ni corrimiento oculta el botón. **No toca la partida**: por eso funciona también en pausa (RF-613, D-161).

Es decir: «Ver todo» no es «alejar al máximo», es **«volver al encuadre inicial»**. Con un mapa grande (26×12, zoom 0,75) sí es alejar; con un mapa chico solo deshace el acercamiento o el arrastre.

### 1.2 Cuándo aparece y desaparece

Regla en `_update_view_all()` (`:147-157`): visible si `zoom > zoom_mínimo` **o** `is_view_displaced()` (`:160`: el centro está a más de 0,5 px de `_fit_position()`).

| Situación | ¿Se ve el botón? |
|---|---|
| Recién entrado al nivel, sin tocar la cámara | No |
| Rueda hacia arriba (acerca) en el área del mapa | Sí (zoom máximo = `zoom_casilla_max_px 96 ÷ 64` = 1,5) |
| Botón central arrastrado (PC) o dos dedos (celular) con el zoom mínimo | Sí (RF-545, mapa corrido) |
| Rueda hacia abajo hasta el mínimo y sin corrimiento | No (se esconde sola) |
| Tocar el botón o apretar la tecla | No (queda en el encuadre) |
| Mapa que entra entero sin zoom (`zoom ≥ 1`) y nunca se tocó la cámara | No existe cámara (`game.gd:441-442`), `_camera == null` → no se ve |

Otros hechos que salen del código:

- En PC el botón lo arma `CameraController._build_pc_view_all_button` (`:171-187`) con **solo el texto «Ver todo»**, sin ícono, de `flotante_min_px` = 64 × 64 px, en `ver_todo_x_px 1188, ver_todo_y_px 74` (`data/ui/mobile_ui.json:27-28`). En el celular es otro botón (`mobile_hud.gd:376-388`, `show_view_all` en `:686`) con el mismo texto y la misma posición.
- La ayuda (tooltip) dice «Ver todo el mapa · V» (`:190-192`), pero solo aparece al **posar el mouse**.
- La tecla V se oye en `game.gd:580-581`, también con el juego en pausa, y no hace nada con el menú, un diálogo o el cartel de nivel abiertos.
- La tecla se cambia en Opciones, solo con interfaz de PC (RF-614).
- **Falta de pistas:** nada le dice al jugador, la primera vez, que acercó o corrió el mapa y que existe un botón/tecla para volver. El texto «Ver todo» a secas es ambiguo: puede entenderse como «mostrar todos los enemigos» o «mostrar todo el HUD». Es exactamente lo que Lucas notó.

### 1.3 Lo que dicen la spec y las decisiones

- **RF-506** (M58): el botón nace en el celular para volver del zoom.
- **RF-545**: aparece también con el mapa corrido aunque el zoom sea el mínimo (hallazgo H-12 de T289); en PC, un botón en el mismo lugar.
- **RF-612** (M68): en PC aparece con otro zoom, igual que en el celular, y su ayuda dice la tecla.
- **RF-613**: acción `view_all`, V por omisión; vale en pausa.
- **RF-614**: la tecla se elige en Opciones.
- **D-161**: pidió Lucas «botón y combinación de teclas, configurable, ambos». Alternativas descartadas: modificadores, menú general de teclas, dejar el botón como estaba.
- Nada de lo anterior fija el **rótulo** ni pide un aviso; el único texto que existe es «Ver todo» y la ayuda. **No hay conflicto de spec para mejorar la comunicación**, solo hay que enmendar la frase de RF-612 («su ayuda dice…») y el rótulo.

### 1.4 Propuesta de comunicación (sin quitarlo)

Tres capas, de menor a mayor intrusión. **Recomiendo A + B, y C solo si Lucas quiere.**

**A. Rótulo e ícono (siempre visibles, no cuestan nada)**

- Rótulo: **«Ver mapa completo»** o **«Centrar mapa»** (PENDIENTE DE LUCAS: elegir uno). Mi preferencia es «Ver mapa completo»: es lo que hace con mapas grandes y no se confunde con el HUD. Con 64 px de ancho el texto no cabe en una línea: hoy «Ver todo» ya parte en dos. Una alternativa de dos líneas: «Ver mapa / completo».
- Ícono: cuatro esquinas apuntando hacia afuera (símbolo de «encuadrar»), dibujado como los demás íconos de la barra celular (`assets/ui/mobile_demolish.svg` es el antecedente: SVG propio, no depende solo del color). Ícono arriba, el texto corto abajo.
- Ayuda al posar el mouse: «Volver a ver todo el mapa · V». Hoy es «Ver todo el mapa · V»; el cambio es mínimo.
- Mostrar la tecla **dentro** del botón en PC: «V» chico en la esquina (como los botones de torre del panel muestran `[U]` y `[S]`). Así se aprende sin posar el mouse.

**B. Aviso la primera vez (una sola línea, una sola vez)**

- Cuándo: la primera vez que el botón pasa de oculto a visible.
- Qué: una línea de unos 3 s en la franja de avisos que ya usa el juego (sin cartel modal): «Acercaste el mapa. Con **V** o este botón volvés a verlo entero.» (celular: «…con este botón…»).
- Cómo se recuerda: un campo **aditivo** en `ui_prefs` (por ejemplo `view_all_hint_seen: bool`), igual que `view_all_key` (D-162) y `intro_seen`: no cambia `SAVE_VERSION`, un guardado viejo se lee como «no visto». Lo prefiero a `settings`, por la misma razón de D-162.
- No debe salir en el nivel 1 mientras corre el tutorial (RF-574): el tutorial ya tiene su propia superposición y no conviene encimar dos avisos.
- No se pudo comprobar acá si la franja de avisos existe como componente reutilizable; si no, habría que usar la misma de «Tecla ya usada…» o crear un `Label` temporal en `ViewAllLayer`.

**C. Resaltado leve (opcional, PENDIENTE DE LUCAS)**

- Un pulso de 1 s en el botón la primera vez que aparece. Es más llamativo y en mobile compite con los flotantes; no lo recomiendo por ahora.

**Qué no se propone:** quitar el botón, ni esconderlo detrás de un menú, ni volver a un rótulo genérico. El pedido de Lucas fue «comunicarlo mejor, no sacarlo».

---

## 2. Panel de mejora T430: qué muestra y qué se repite

Archivos: `scenes/ui/tower_panel.gd` y `scenes/ui/tower_panel.tscn`. El panel es un `PanelContainer` de 270×320 px (`offset 1000,260 → 1270,580`) con un `ScrollContainer` para los detalles. Todas las líneas siguientes salen de `refresh()` (`:186-234`) y `_refresh_upgrade_preview()` (`:82-116`).

### 2.1 Inventario completo, línea por línea

Orden de arriba hacia abajo. «L1/L2/L3» = la torre está en nivel 1, 2 o 3.

| # | Qué se ve | Origen | L1 | L2 | L3 |
|---|---|---|---|---|---|
| 1 | **Nombre** de la torre (tamaño 18, hasta 2 líneas) | `_title` `:192` | sí | sí | sí |
| 2 | **Tarjeta de nivel**: tres segmentos de color (gris, cobre, dorado); los del nivel actual y menores en color, el resto oscuro | `_refresh_level_card` `:119-128` | 1 de 3 | 2 de 3 | 3 de 3 |
| 3 | Tooltip de la tarjeta: «Nivel actual: N de 3» | `:121` | sí | sí | sí |
| 4 | Botón **×** (ocultar panel), con tooltip | `.tscn:64-70` | sí | sí | sí |
| 5 | **Estado**: «Aturdida (N s)» y/o «Desgaste N %», en naranja | `:197-203` | solo si aplica | idem | idem |
| 6 | Rótulos de columna: DAÑO / CADENCIA / ALCANCE | `.tscn:85-102` | sí | sí | sí |
| 7 | **Daño**: «a → b» con el daño del nivel siguiente; en L3 solo el daño | `:101-109` | «20 → 32» | «32 → 50» | «50» |
| 8 | **Cadencia**: «0.60/s» (con punto decimal), o «Apoyo» si la torre solo da apoyo | `:205` | sí | sí | sí |
| 9 | **Alcance**: «3.0» (con punto decimal), tooltip «Distancia en casillas» | `:206` | sí | sí | sí |
| 10 | Separador | `.tscn:122` | sí | sí | sí |
| 11 | **Efectos del nivel** (`TowerText.effects`): área, rayo, púas, objetivos, quemadura, bonus a frenados/quemados, frenado, apoyo, reparación, pulso | `:208`, `tower_text.gd:8-35` | según la torre | idem | idem |
| 12 | «Recursos invertidos: N» (si la torre usa recursos) | `:209-211` | sí si aplica | idem | idem |
| 13 | «Reparación recibida: N puntos/s» | `:212-213` | si aplica | idem | idem |
| 14 | «Prestaciones actuales: N %» (apoyo desgastado) | `:214-215` | si aplica | idem | idem |
| 15 | «Apoyo recibido: +N % cadencia» | `:216-217` | si aplica | idem | idem |
| 16 | Combos: «con quién pega más fuerte» (Hielo, Incendiaria) | `:218-220`, `tower_text.gd:106` | si aplica | idem | idem |
| 17 | **Voladores: sí/no** | `:207` | sí | sí | sí |
| 18 | Botón **Apuntar: Primero/…** (apagado en torres de apoyo y de pulso) | `:223-224` | sí | sí | sí |
| 19 | **Vista previa de mejora**: «Al nivel N:» y debajo hasta 4 estadísticas «antes → después», de a 2 por renglón, **sin el daño** (que ya está en el #7) | `:113-115` | sí | sí | **no** (se oculta) |
| 20 | Botón **«Mejorar a nivel N (costo)  [U]»** (activo si alcanza el oro); en L3 «Nivel máximo» apagado | `:227-232` | «Mejorar a nivel 2 (110)  [U]» | «… nivel 3 (170)  [U]» | «Nivel máximo» |
| 21 | Tooltip de Mejorar: «Faltan N de oro» / «Mejorar torre · U» / «Nivel máximo alcanzado» | `:233` | sí | sí | sí |
| 22 | Botón **«Vender (+N)  [S]»** | `:234` | sí | sí | sí |

Ejemplo real, **Cañón** (`data/towers/cannon.tres`: daño 20/32/50, alcance 3/3/3,5, área 1/1,2/1,5, cadencia 0,6):

```
L1                                  L2                                  L3
┌ Cañón ─────── ▮▯▯ [×]             ┌ Cañón ─────── ▮▮▯ [×]             ┌ Cañón ─────── ▮▮▮ [×]
│ DAÑO  CADENCIA  ALCANCE           │ DAÑO  CADENCIA  ALCANCE           │ DAÑO  CADENCIA  ALCANCE
│ 20→32  0.60/s    3.0              │ 32→50  0.60/s    3.0              │ 50     0.60/s    3.5
│ ───────────────────               │ ───────────────────               │ ───────────────────
│ Área: radio 1.0                   │ Área: radio 1.2                   │ Área: radio 1.5
│ Voladores: no                     │ Voladores: no                     │ Voladores: no
│ [Apuntar: Primero]                │ [Apuntar: Primero]                │ [Apuntar: Primero]
│ Al nivel 2:                       │ Al nivel 3:                       │ [Nivel máximo]  (apagado)
│ área 1 → 1,2                      │ alcance 3 → 3,5 · área 1,2 → 1,5  │ [Vender (+N)  [S]]
│ [Mejorar a nivel 2 (110)  [U]]    │ [Mejorar a nivel 3 (170)  [U]]    └
│ [Vender (+N)  [S]]                │ [Vender (+N)  [S]]
└                                   └
```

(Los costos 110 y 170 salen de `cost` de los niveles 2 y 3 del `.tres`.)

### 2.2 Repeticiones

Marco cada una con su gravedad: **R** = repetición de información, **I** = inconsistencia de formato.

| Id | Tipo | Dónde | Qué se repite |
|---|---|---|---|
| **R1** | R | `:113` y `:231` | **El nivel destino** sale dos veces, en dos renglones contiguos: «Al nivel 2:» (vista previa) y «Mejorar a nivel 2 (110)». Es el ejemplo que me pidieron marcar. |
| **R2** | R | `:208` / `:113-115` | **Cada estadística que cambia sale dos veces**: el valor actual en «Efectos» («Área: radio 1.2», «El rayo salta a 3 enemigos más», «Ralentiza 50 % durante 2 s») y el «antes → después» en la vista previa («área 1,2 → 1,5», «saltos 3 → 4», «frenado 50 % → 60 %»). T430 ya fusionó solo el daño (#7); falta el resto. |
| **R3** | R | `:206` / `:113-115` | **Alcance y cadencia**: están en la fila grande (#8, #9) y vuelven en la vista previa con la misma tabla (`data/ui/mejoras.json` incluye `fire_rate` y `range_tiles`). Cañón L2: «Alcance 3.0» arriba y «alcance 3 → 3,5» abajo. |
| **R4** | R | `:209-211` (`pulse_line`) | Para la **Disruptora** la línea de efectos repite cadencia («Pulso cada 4 s» = la CADENCIA de arriba), alcance («radio») y daño («5 de daño») que ya están en la fila grande. No lo comprobé en pantalla: lo deduzco de `TowerText.pulse_line`, que usa `level.fire_rate`, `level.range_tiles` y `level.damage`. |
| **R5** | R | `:121` y la tarjeta | El **nivel actual** aparece como tarjeta de color y como tooltip; el número exacto solo se lee por tooltip (nunca está escrito en el panel). No es duplicado, pero depende del color y del tooltip. |
| **R6** | R | `:228` y `.tscn:156` | «Apuntar: Primero» (texto) y tooltip «Cambiar prioridad de objetivo». Menor. |
| **R7** | R | `:233` y `:231` | El costo está en el botón y, cuando falta oro, otra vez en el tooltip («Faltan N de oro»). Es un dato nuevo (cuánto falta), no un duplicado. |
| **R8** | R | `:192-193` | `_title.tooltip_text = _title.text`: el tooltip repite el título. Sirve cuando se corta con `…`; sin corte, es ruido. |
| **R9** | R | `:106-109` y mobile | El mismo cálculo de «antes → después» existe también en el celular (`mobile_hud.gd:278-288`, RF-617). Es duplicado de código, no de pantalla; cualquier cambio de formato se hace dos veces. |
| **I1** | I | `:205-206` vs `UpgradeDeltas` | **Decimales**: cadencia y alcance con **punto** («0.60/s», «3.0») en la fila grande y en `Área: radio 1.0`; vista previa y `pulse_line` con **coma** («3 → 3,5», «radio 2,5»). Misma magnitud, dos formatos. |
| **I2** | I | `:113` | El título «Al nivel N:» promete «lo que cambia», pero omite el daño (que está en la fila de arriba); el jugador tiene que mirar dos lugares para ver todo lo que mejora. |

Resumen: **R1 + R2 + R3 son el problema real** (la misma información dos veces en menos de 160 px de alto). El resto es menor.

### 2.3 Qué piden RF-616 y RF-650 (para no romperlos)

- **RF-616**: la vista previa va «encima de Mejorar», con el rótulo **«Al nivel N:»** y hasta 4 estadísticas «daño 5 → 8 · alcance 3 → 3,5», de a dos por renglón; con el último nivel no aparece. Hay un test que fija el texto: `tests/test_upgrade_preview.gd:133` (`begins_with("Al nivel 2:")`) y `:137` (el texto del botón).
- **RF-650**: omitir la descripción duplicada, **integrar daño actual con daño posible**, indicar «Mejorar a nivel N», mostrar la tarjeta de tres colores en lugar de un rótulo de nivel; «no oculta nombre, costo ni datos necesarios para decidir».
- **RF-651**: el panel no debe tapar la selección; no se toca acá.
- Conclusión: **la propuesta de abajo implica enmendar RF-616** (se elimina el rótulo «Al nivel N:») y la frase de RF-650 sobre «indicar Mejorar a nivel N» **se mantiene**. Es coherente con la dirección de RF-650 («integrar daño actual con daño posible»): se extiende al resto de las estadísticas.

### 2.4 Propuesta sin duplicados

**Principio:** cada dato aparece **una sola vez**. Lo que cambia con la mejora se muestra **en su lugar** con «valor actual → valor nuevo» (como ya se hace con el daño); lo que no cambia, valor simple. El número del nivel destino lo da **solo** el botón.

Cambios concretos:

1. **Se elimina el rótulo «Al nivel N:»** y el bloque aparte de la vista previa (R1).
2. **Las filas de Daño / Cadencia / Alcance** aceptan «a → b» cuando el campo cambia (generaliza lo que hoy pasa solo con el daño) (R3). El «→ b» va en verde claro (`Color(0.75, 0.9, 0.6)`, el color actual de la vista previa).
3. **Las líneas de «Efectos»** pasan a mostrar «antes → después» para lo que cambia, usando la misma tabla de `mejoras.json` (R2). Por ejemplo «Área: radio 1,2 → 1,5» en lugar de la línea aparte.
4. **Un solo formato decimal** (coma, `TowerText.decimal`) en toda la pantalla (I1).
5. **La Disruptora** deja de repetir cadencia, alcance y daño en `pulse_line`: queda «Apaga las auras N s» (R4).
6. **El número del nivel actual se escribe**: «Nivel 2/3» al lado de la tarjeta (R5). La tarjeta de color queda como refuerzo visual (RF-650 la pide) pero ya no es la única forma de saber el nivel. Es un texto de ~8 px de ancho extra en el título.
7. **El tooltip del título** solo se pone si el texto se corta (R8).
8. **El tooltip de Mejorar** conserva «Faltan N de oro» (dato nuevo).

Maqueta propuesta, Cañón en L1 y L2 y L3 (mismo ancho de 270 px):

```
L1                                  L2                                  L3
┌ Cañón   Nivel 1/3  ▮▯▯  [×]       ┌ Cañón   Nivel 2/3  ▮▮▯  [×]       ┌ Cañón   Nivel 3/3  ▮▮▮  [×]
│ DAÑO     CADENCIA   ALCANCE       │ DAÑO     CADENCIA   ALCANCE       │ DAÑO     CADENCIA   ALCANCE
│ 20→32    0,6/s      3                │ 32→50    0,6/s      3→3,5       │ 50       0,6/s      3,5
│ ───────────────────               │ ───────────────────               │ ───────────────────
│ Área: radio 1 → 1,2               │ Área: radio 1,2 → 1,5             │ Área: radio 1,5
│ Voladores: no                     │ Voladores: no                     │ Voladores: no
│ [Apuntar: Primero]                │ [Apuntar: Primero]                │ [Apuntar: Primero]
│ [Mejorar a nivel 2 · 110   U]     │ [Mejorar a nivel 3 · 170   U]     │ [Nivel máximo]  (apagado)
│ [Vender  +70   S]                 │ [Vender  +120   S]                │ [Vender  +N   S]
└                                   └                                   └
```

(En la maqueta del L1 la columna de cadencia/alcance quedó compacta a propósito; los valores de venta son ejemplos, no se calcularon.)

Ejemplo con la **Tesla** (`tesla.tres`: daño 13/19/27, cadencia 0,75/0,85/0,95, alcance 2,5/2,5/3, saltos 2/3/4, costos 130/120/180), L1:

```
┌ Eléctrica  Nivel 1/3 ▮▯▯ [×]
│ DAÑO      CADENCIA     ALCANCE
│ 13→19     0,75→0,85/s  2,5
│ ─────────────────────
│ El rayo salta a 2 → 3 enemigos más
│ Voladores: sí
│ [Apuntar: Primero]
│ [Mejorar a nivel 2 · 120   U]
│ [Vender  +N   S]
```

(El costo del nivel 2 de la Tesla es 120 según el `.tres`; el 130 es el del nivel 1.)

**Qué ganamos:** el panel sin vista previa aparte libra 2 a 3 renglones (≈ 45 a 60 px del alto de 320), y el jugador lee cada dato una vez.

**Riesgo:** si el «→ b» no entra en una columna de 270 px (Tesla L1: «0,75→0,85/s» ocupa ≈ 11 caracteres a 19 px), hay que achicar la fuente de esas filas o pasar la cadencia a la línea de abajo. **Esto no se midió**: hay que probarlo en pantalla (T4xx-1 más abajo).

**Alternativa conservadora (mínima, PENDIENTE DE LUCAS):** solo borrar «Al nivel N:» y dejar el bloque con el título «Mejora:»; arregla R1 pero no R2/R3. Cuesta menos (un texto y dos tests) y no cambia el layout.

---

## 3. Círculo de alcance

### 3.1 Cómo se dibuja hoy

| Qué | Dónde | Aspecto |
|---|---|---|
| **Torre seleccionada** | `build_controller.gd:529-530` | `_draw_range(centro, range_px)` |
| **Torre fantasma** (PC y celular) | `build_controller.gd:557` | `_draw_range(centro, tiles_to_px(levels[0].range_tiles))` |
| **`_draw_range`** | `:560-562` | `draw_circle` relleno blanco alfa **0,08** + `draw_arc` borde blanco alfa **0,7**, grosor **2** |
| **Torres de apoyo** | `tower.gd:434-435` | Arco fijo, **siempre visible**, celeste alfa **0,22**, grosor **1**, para toda torre `support_only` que no esté aturdida |

Hechos relacionados:

- Se redibuja al subir de nivel (`:238`, «el círculo de alcance puede haber crecido»).
- **No hay opción** en Opciones. Es el único elemento visual del que RF-40 y RF-73 fijan la presencia («mostrando su círculo de alcance», «se ve su círculo de alcance»).
- En el celular, **el fantasma es la única vista previa** (`_start_mobile_ghost`, `:405`) y no hay mouse: no existe «pasar el mouse».
- Las estatuas decorativas no muestran círculo (`01-spec.md:3146`).
- No verifiqué si el círculo del fantasma se oculta cuando el panel de la torre tapa el mapa (RF-651).

### 3.2 Alternativas

| Opción | Qué se ve | A favor | En contra |
|---|---|---|---|
| **A. Como hoy** (completo) | Relleno + borde 2 px | Es lo que cumple RF-40/73; muy claro | Es lo que molestó: tapa el mapa, se confunde con el arco de apoyo |
| **B. Marca sutil** | Solo un arco o el borde con alfa ≈ 0,25-0,35, 1 px, **sin relleno**; opcional: 4 marcas en las esquinas del círculo | Sigue transmitiendo el alcance sin ensuciar; es consistente con el arco de apoyo (alfa 0,22, 1 px) que ya existe | Menos legible con fondos claros (los mapas de nieve/arena); hay que probarlo sobre todos los fondos |
| **C. Solo al pasar el mouse** sobre la torre | Círculo completo mientras el cursor está encima | Cero ruido al jugar | **No existe en el celular** (sin mouse); requiere un cálculo de «¿qué torre está bajo el mouse?» que no vi hecho; parpadea al mover el mouse sobre el panel |
| **D. Solo en el fantasma** (al construir) | Círculo completo solo al elegir dónde poner | Es cuando más importa el alcance; limpia la selección | Una torre ya puesta no muestra su alcance salvo por el número «Alcance 3.0» del panel |
| **E. Oculto** | Nada | Máxima limpieza | El jugador novato pierde la forma más intuitiva de entender el alcance; viola RF-40 y RF-73 tal cual están |

Mi lectura (decisión de Lucas):

- **Fantasma:** conviene dejarlo **completo** (opción A) en cualquier caso. Es la única referencia visual al construir, sobre todo en el celular (no hay hover).
- **Torre seleccionada:** acá sí tiene sentido **B (sutil)**, que pareció ser el pedido («ocultarlo o reemplazarlo por una marca mucho más sutil»).
- **C** es atractiva en PC pero deja un hueco en el celular; la dejo como valor de la opción solo para PC.

### 3.3 Opción `range_display` en Opciones

**Dónde se guarda:** `settings["range_display"]` (entero, aditivo; ver 3.5). Es un ajuste de visualización de partida, como `damage_numbers` y `upgrade_fx`, que ya viven en `settings` con su valor por omisión en `DEFAULT_SETTINGS` (`save_manager.gd:16-26`).

**Valores propuestos:**

| Valor | Texto en Opciones | Torre seleccionada | Fantasma | Disponible |
|---|---|---|---|---|
| `0` | **Completo** | Relleno + borde (como hoy) | Completo | PC y celular |
| `1` | **Sutil** | Solo borde fino (alfa ≈ 0,3, 1 px) | Completo | PC y celular |
| `2` | **Solo al construir** | Nada | Completo | PC y celular |
| `3` | **Solo al pasar el mouse** | Completo, solo con el mouse sobre la torre | Completo | **Solo PC** (en el celular se lee como `1`) |
| `4` | **Oculto** | Nada | Nada | PC y celular (avisar en el texto que construir es a ciegas) |

**Valor por omisión: PENDIENTE DE LUCAS.** Mi recomendación, si hay que elegir, es **`1` (Sutil)**: es lo que más se acerca al pedido sin dejar a nadie sin la referencia. La alternativa conservadora es **`0` (Completo)**: así los guardados existentes y el comportamiento actual no cambian, y la opción sólo agrega la posibilidad de bajarlo. Hay que decidirlo porque con `1` por omisión un jugador con guardado viejo vería un cambio de pantalla sin haberlo pedido (ver 3.5).

**Texto en Opciones:** fila con etiqueta «Círculo de alcance» y un `OptionButton` (como «Interfaz»), en el grupo «Pantalla» (ver sección 4).

### 3.4 Impacto

- **RF-40** (spec `:100`): «Aparece una vista previa… mostrando su círculo de alcance». Con `range_display = 4` (Oculto) deja de cumplirse. Hay que redactar «salvo que el jugador lo haya ocultado en Opciones».
- **RF-73** (`:154`): «clic izquierdo sobre una torre la selecciona (se ve su círculo de alcance)». Hay que matizarlo igual.
- **RF-292** y **RF-509** (fantasma en el celular): el círculo sale del centro del cuadrado; no cambia, solo se condiciona.
- **RF-113** (`:1194`): hay que sumar la opción a su lista (la spec ya fue enmendada con RF-502, RF-576, RF-593, RF-600, RF-644; una más).
- **RF-650 / RF-651** (`:4137-4138`): **no se contradicen**. RF-650 pide no ocultar «datos necesarios para decidir» y el alcance sigue en la fila ALCANCE del panel (con o sin círculo). RF-651 trata del input del panel, no del círculo. Conviene, igual, mencionar el alcance en el criterio de la nueva RF.
- **Mobile:** el celular no tiene hover, así que (a) `3` no aplica; (b) el fantasma debe seguir completo; (c) la torre seleccionada ya no tiene panel de 270 px sino la barra baja con Mejorar/Vender (`mobile_hud.gd`), por lo que el círculo es **lo único** que muestra el área al tocar una torre. Recomiendo que en el modo celular `4` (Oculto) siga permitido pero la fila lo advierta, y que el valor `0` por omisión sea el mismo en ambos modos.
- **Torres de apoyo** (`tower.gd:434`): el arco celeste fijo es en la práctica una marca sutil permanente. Si se elige «Oculto», no está claro si ese arco también se apaga. Propuesta: **no se apaga** (es una señal de juego —quién recibe el apoyo—, no una ayuda de construcción); **PENDIENTE DE LUCAS**.
- **Código afectado** (para estimar, sin tocarlo): `build_controller.gd` (`_draw`, `_draw_range`, el hit-test para el modo `3`), `save_manager.gd` (`DEFAULT_SETTINGS` + lectura defensiva) y `options_menu.gd`. `tower.gd` solo si se decide cambiar el arco de apoyo.
- **Lo que no probé:** el aspecto real del borde sutil sobre cada fondo de los 15 mapas, ni el costo de `queue_redraw` con el hover.

### 3.5 Guardados viejos

`settings` ya tiene claves aditivas (`tutorial_enabled`, `upgrade_fx`, `boss_entrance`, `defeat_advice`, `selector_style`) y `_read_settings` valida por tipo. `range_display` sigue el mismo camino: ausente → valor por omisión sin aviso; fuera de rango → por omisión con `push_warning`. `SAVE_VERSION` no cambia. Hay que agregar el caso a `tests/test_old_saves.gd`.

---

## 4. Opciones

### 4.1 Inventario actual

Datos de `scenes/ui/options_menu.tscn` y de `options_menu.gd:95-103` (`_ready`) más los constructores. El **orden real en PC** sale de los `move_child` (lo deduje leyendo el código; **no abrí la pantalla**):

| # | Fila | Control | Creado en | Clave de guardado |
|---|---|---|---|---|
| 1 | Título «Sonido» | etiqueta de sección | `.tscn:75` | |
| 2 | Volumen de la música | slider | `.tscn:81-91` | `settings.music_volume` |
| 3 | Volumen de los efectos | slider | `.tscn:93-103` | `settings.sfx_volume` |
| 4 | Título «**Visualización**» | etiqueta de sección | `.tscn:105` | |
| 5 | Pantalla completa | casilla | `.tscn:111` | `settings.fullscreen` |
| 6 | Mostrar números de daño | casilla | `.tscn:117` | `settings.damage_numbers` |
| 7 | Animaciones de mejora | casilla | `.tscn:123`, movida en `_ready:92` | `settings.upgrade_fx` |
| 8 | Interfaz (Automática / Celular / PC) | etiqueta + `OptionButton` | `_build_ui_mode_selector` `:449` | `settings.ui_mode` |
| 9 | Tutorial del nivel 1 + «Volver a verlo» | casilla + botón | `_build_tutorial_row` | `settings.tutorial_enabled` |
| 10 | Entrada de los jefes | casilla | `_build_boss_entrance_check` | `settings.boss_entrance` |
| 11 | Tecla de «Ver todo» (+ Restaurar + aviso) | botón + botón + etiqueta | `_build_view_all_row`; **solo PC** | `ui_prefs.view_all_key` |
| 12 | Consejos en la derrota | casilla | `_build_defeat_advice_check` | `settings.defeat_advice` |
| 13 | Título «Créditos y versión» | etiqueta | `.tscn:135` (en `Side`) | |
| 14 | Etiqueta de versión | etiqueta | `.tscn:141` | |
| 15 | Ver créditos | botón | `.tscn:147` | |
| 16 | Novedades de esta versión | botón | `_build_news_button` | `news_version` (no en opciones) |
| 17 | Título «Administración» + «Activar modo de pruebas» (+ confirmación) | etiqueta + botón + bloque | `.tscn:154-203`; **solo desde el menú principal** | modo de pruebas (`DevMode`) |
| 18 | Volver | botón | `.tscn:205` | |

Sobre la distribución:

- En **PC** todo va en una sola columna (RF-555); `_arrange_columns` (`:188-204`) mueve las filas de `Side` al final de `Rows`.
- En el **celular** hay dos columnas (`MOBILE_PANEL_WIDTH 880`): izquierda = Sonido + Visualización; derecha (`Side`) = «Interfaz» al principio y después Créditos y versión + Administración.
- **Problemas del orden actual:**
  - Bajo «Visualización» hay **nueve** filas distintas; solo tres (5, 6, 7) son de pantalla. El resto son ayudas del juego (9, 10, 12), una tecla (11) y el modo de interfaz (8).
  - El orden es el de **llegada**, no el de significado: los constructores se meten con `move_child` relativo a «Mostrar números de daño» o a la fila de al lado. Resultado: la tecla de «Ver todo» queda entre «Entrada de los jefes» y «Consejos en la derrota».
  - Los tests fijan posiciones relativas: `tests/test_tutorial_options.gd:52-53` exige que el tutorial esté **después y a ≤ 4 de «Mostrar números de daño»**. RF-576, RF-593 y RF-600 lo piden con esas palabras («debajo de «Mostrar números de daño»», «debajo de «Animaciones de mejora»»). **Reagrupar obliga a enmendarlos y a reescribir ese test.**
  - Once tests importan el menú (`grep OptionsMenu tests/`): `test_audio_options_pause`, `test_game_version`, `test_menu_layout`, `test_news_menu`, `test_upgrade_fx`, `test_view_all_binding`, `test_defeat_advice_options`, `test_boss_entrance_options`, `test_mobile_ui`, `test_options_admin`, `test_tutorial_options`.

### 4.2 Propuesta de grupos

Cinco grupos con títulos de sección del mismo estilo que el actual (fuente 15, color dorado). Entre paréntesis, dónde vive hoy cada fila.

**1. Sonido**
- Volumen de la música (#2)
- Volumen de los efectos (#3)

**2. Pantalla**
- Pantalla completa (#5)
- Mostrar números de daño (#6)
- Animaciones de mejora (#7)
- **Círculo de alcance** (fila nueva de `range_display`, sección 3)
- Interfaz: Automática / Celular / PC (#8). Va acá porque define cómo se ve la pantalla.

**3. Partida y ayudas**
- Tutorial del nivel 1 + «Volver a verlo» (#9)
- Entrada de los jefes (#10) **← acá va la fila que agrega E**
- Consejos en la derrota (#12)

**4. Controles** *(solo con la interfaz de PC, igual que hoy)*
- Tecla de «Ver todo» + Restaurar + aviso (#11)
- Hueco para otras teclas si algún día se amplía D-161 (hoy solo hay una, y D-161 descartó «un menú general de teclas»).

**5. Avanzado**
- Créditos y versión: etiqueta de versión + Ver créditos + Novedades de esta versión (#13 a #16)
- Administración (#17, solo desde el menú principal)

Notas:

- «Avanzado» junta Créditos y Administración porque el celular ya los pone juntos en la columna derecha; si a Lucas no le gusta el nombre, puede ser **«Acerca de y pruebas»** (PENDIENTE DE LUCAS).
- Si «Controles» queda con una sola fila en PC (y vacío en el celular), no se justifica un título solo: en ese caso la tecla se mueve a «Pantalla» (o a «Partida y ayudas») y el grupo 4 aparece cuando haya una segunda tecla. Es una elección de diseño para Lucas.
- En el celular hay dos columnas. Propuesta: izquierda = Sonido + Pantalla (incluida «Interfaz», que hoy cabeza la derecha); derecha = Partida y ayudas + Avanzado. Esto cambia la regla de M58 de que «Interfaz» encabeza la derecha; **no probé que entre en 720 px de alto**, hoy el scroll de `_fit_scroll` ya compensa (RF-555).

Maqueta (PC, una columna, sin los valores):

```
┌──────────────── Opciones ────────────────┐
│ SONIDO                                   │
│   Volumen de la música      [━━━━━○━]    │
│   Volumen de los efectos    [━━━━○━━]    │
│ PANTALLA                                 │
│   [x] Pantalla completa                  │
│   [x] Mostrar números de daño            │
│   [x] Animaciones de mejora              │
│   Círculo de alcance  [ Sutil        ▾]  │
│   Interfaz            [ Automática   ▾]  │
│ PARTIDA Y AYUDAS                         │
│   [x] Tutorial del nivel 1  [Volver a verlo] │
│   [x] Entrada de los jefes      ← lugar de E │
│   [x] Consejos en la derrota             │
│ CONTROLES  (solo PC)                     │
│   Tecla de «Ver todo»   [ V ] [Restaurar]│
│ AVANZADO                                 │
│   Versión 0.x.x                          │
│   [Ver créditos] [Novedades de esta versión] │
│   [Activar modo de pruebas]  (solo menú principal) │
│                 [ Volver ]               │
└──────────────────────────────────────────┘
```

### 4.3 Qué hay que cambiar para ordenarlo (sin hacerlo)

- Reemplazar los `move_child` relativos por una **lista de orden declarativa** (un arreglo de nombres de nodo por grupo) que se aplica una vez en `_arrange_columns()`. Así, cuando se agregue otra opción (E, `range_display`), alcanza con agregarla a su grupo y no se rompe nada de lo de abajo.
- Renombrar «Visualización» a «Pantalla» y partir el grupo.
- Pasar las filas creadas por código al grupo que corresponde, con un `group` explícito en el constructor.
- Enmendar RF-576, RF-593, RF-600, RF-607, RF-614 y RF-644 (hoy dicen «debajo de…»; pasarían a «en el grupo X») y reescribir los asserts de posición.
- Mantener sin cambio las `name` de los nodos (`TutorialRow`, `BossEntranceCheck`, `UiModeSelector`, `ViewAllRow`, `NewsButton`, etc.): los tests las usan.

### 4.4 Coordinación con E (jefes)

Estoy dejando **«Entrada de los jefes» en el grupo «Partida y ayudas», entre «Tutorial» y «Consejos en la derrota»**, con el nombre del nodo `BossEntranceCheck`. E puede:

- **Cambiar el texto** (por ejemplo «Presentación de los jefes») sin tocar el lugar.
- **Convertir la casilla en un selector** (3 s / 5 s / Solo la primera vez / No mostrar) manteniendo el `name` o avisando para actualizar `test_boss_entrance_options.gd`. Si pasa a selector, ocupa dos líneas (etiqueta + `OptionButton`) y empuja a «Consejos» una fila más: en PC hay lugar; en el celular conviene medirlo.
- Mantener `settings.boss_entrance` como booleano o migrarlo con lectura defensiva (la clave actual es booleana: un valor viejo `true`/`false` tiene que leerse como «Mostrar»/«No mostrar» sin romper).

**Orden recomendado entre tareas** (ya lo fija la matriz, sección 5): E toca `options_menu.gd` primero; C reordena después, con la fila de E ya en su forma final. Si C sale antes, E debe respetar el `group` que aquí se define.

---

## 5. Tareas candidatas

Numeración tentativa **T4xx**; las toma el agente que reserva `03-tareas.md`. Todas son de código salvo la primera, que es 📜.

| Id | Tarea | Archivos | Tests | Depende de |
|---|---|---|---|---|
| **T4xx-1** 📜 | Spec y decisiones de C: RF nuevos (rótulo/ícono/aviso de «Ver todo»; panel sin duplicados; `range_display`; grupos de Opciones) y D nuevas; enmienda de RF-40, RF-73, RF-113, RF-576, RF-593, RF-600, RF-607, RF-612, RF-614, RF-616, RF-644, RF-650 | `specs/01-spec.md`, `02-plan-tecnico.md`, `04-decisiones.md`, `03-tareas.md` | — | Decisión de Lucas sobre este informe |
| **T4xx-2** | **«Ver todo»**: rótulo e ícono nuevos, tecla dentro del botón en PC, ayuda nueva, aviso de la primera vez (`view_all_hint_seen` aditivo en `ui_prefs`) | `scenes/game/camera_controller.gd`, `scenes/game/mobile_hud.gd`, `scripts/logic/ui_prefs.gd`, `scripts/autoload/save_manager.gd`, `assets/ui/` (ícono SVG) | actualizar `test_view_all_displaced.gd`; `test_view_all_binding.gd` (nuevo campo: ausente → no visto, sin aviso; round-trip; `SAVE_VERSION` igual); nuevo `test_view_all_hint.gd` (aparece una vez, no con el tutorial abierto) | T4xx-1 |
| **T4xx-3** | **Panel sin duplicados**: generalizar el «a → b» a cadencia, alcance y efectos; sacar «Al nivel N:»; un solo formato decimal; «Nivel N/3» escrito; limpiar `pulse_line`; unificar el cálculo con el celular | `scenes/ui/tower_panel.gd` (+ `.tscn`), `scripts/logic/tower_text.gd`, `scripts/logic/upgrade_deltas.gd`, `scenes/game/mobile_hud.gd` (RF-617) | actualizar `test_upgrade_preview.gd` (`:133`, `:137`), `test_tower_panel_layout.gd`, `test_upgrade_fx.gd`; nuevos casos para Cañón, Tesla, Hielo y Disruptora en L1/L2/L3 (nada duplicado, un solo formato decimal, L3 sin flecha); un test de ancho que verifique que el texto más largo (Tesla L1) entra en 270 px | T4xx-1; mejor medir en pantalla antes |
| **T4xx-4** | **`range_display`**: ajuste, fila en Opciones, dibujo sutil, modo «solo al pasar el mouse» (PC) | `scenes/game/build_controller.gd`, `scripts/autoload/save_manager.gd` (`DEFAULT_SETTINGS`), `scenes/ui/options_menu.gd` (+ `.tscn`), `scenes/towers/tower.gd` (solo si se toca el arco de apoyo) | `test_old_saves.gd` (sin la clave → valor por omisión, valor inválido → por omisión con aviso); nuevo `test_range_display.gd` (cada valor decide qué se dibuja; en celular `3` se lee como `1`; el fantasma sigue completo salvo en `4`); `test_mobile_ui.gd` | T4xx-1; decisión del valor por omisión |
| **T4xx-5** | **Reagrupar Opciones** con lista declarativa de orden | `scenes/ui/options_menu.gd` (+ `.tscn`) | reescribir los asserts de posición de `test_tutorial_options.gd`, `test_boss_entrance_options.gd`, `test_defeat_advice_options.gd`, `test_view_all_binding.gd`; revisar `test_menu_layout.gd`, `test_mobile_ui.gd`, `test_options_admin.gd`, `test_news_menu.gd`, `test_game_version.gd`; un test nuevo que verifica el orden por grupo y que el celular sigue entrando en 720 px | T4xx-1; **después de E** si E cambia la forma de la fila de jefes |

Orden sugerido: T4xx-1 → (T4xx-3 y T4xx-2 en paralelo, comparten solo `mobile_hud.gd`: coordinar) → T4xx-4 → T4xx-5. Los cuatro de código tocan `save_manager.gd` o `options_menu.gd`: **no más de dos a la vez** (regla de la matriz). `project.godot` no se toca en ninguno de estos.

Recordatorio de `CLAUDE.md`: al cambiar un texto que ya estaba escrito (rótulo de «Ver todo», nombre de las secciones de Opciones) hay que actualizar spec, plan, `CONTENIDO.md`, `README.md`, `ONBOARDING.md` y `CHANGELOG.md`.

---

## 6. Decisiones que quedan para Lucas

1. **Rótulo de «Ver todo»:** «Ver mapa completo», «Centrar mapa» u otro. (1.4)
2. **¿Se agrega el aviso de la primera vez?** Sí/No, y si lleva un pulso de resalte. (1.4 B y C)
3. **Panel:** versión completa (todo «a → b» en su lugar) o la conservadora (solo sacar «Al nivel N:»). (2.4)
4. **`range_display`:** qué valores se ofrecen y el **valor por omisión** (mi recomendación: Sutil; la alternativa segura: Completo). (3.3)
5. **¿El arco celeste de las torres de apoyo se apaga con «Oculto»?** (3.4)
6. **Nombre del grupo 5** («Avanzado» o «Acerca de y pruebas») y si «Controles» existe con una sola tecla. (4.2)
7. **En el celular,** si «Interfaz» sigue encabezando la columna derecha o va con Pantalla. (4.2)

## 7. Qué se probó y qué no

- **Probado:** lectura de `camera_controller.gd`, `game.gd`, `tower_panel.gd/.tscn`, `tower_text.gd`, `upgrade_deltas.gd`, `build_controller.gd`, `tower.gd`, `options_menu.gd/.tscn`, `save_manager.gd`, los `.tres` de Cañón, Hielo y Tesla, `data/ui/mejoras.json`, `data/ui/mobile_ui.json` y los fragmentos de spec/decisiones citados; búsqueda en `tests/` de los archivos que tocan Opciones y el panel.
- **No probado:** no se corrió Godot ni GUT, no se tomaron capturas, no se midió ancho de texto ni alto de panel, no se vio la pantalla de Opciones real (el orden de filas se dedujo del código), no se probó en celular ni se comprobó el aspecto del círculo sutil sobre los fondos. Las maquetas de texto son orientativas.
- Los números de RF/D/T que aparecen como «nuevos» son sugerencias.
