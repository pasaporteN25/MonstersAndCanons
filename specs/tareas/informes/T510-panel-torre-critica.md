# T510 · Crítica del panel de torre (PC y celular) y propuesta de rediseño

**Fecha:** 2026-10-26 · **Base:** `origin/main` b1f178f · **Rama:** `feature/t465-propuesta-panel-torre` · **Hizo:** Claude (Opus 5.5), con propuestas de Codex (`gpt-6.1-sol`) · **Para:** T465 (sigue abierta hasta que Lucas elija).

**Origen:** Lucas (2026-10-26): «el panel es necesario pero ocupa mucho espacio y no me parece estético del todo; creo que podemos mejorarlo, simplificarlo incluso. […] opino lo mismo para mobile pero no vi la última versión». Esta tarea es **solo análisis y diseño**: no cambia código del juego, escenas, datos ni `assets/`.

Las maquetas, las capturas y la comparación están en `art/t465-propuesta-panel/` (`index.html` para ver, `index.md` para leer).

## 0. Resumen (para quien lea solo esto)

1. **PC.** El panel mide **270 × 320 px lógicos fijos** (405 × 480 en 1920 × 1080) y tapa ≈ 12 % del mapa. En **6 de 13 casos** la lista de efectos necesita barra de desplazamiento (en el Hielo de nivel 3, «Voladores: sí» queda cortado) y a la Ametralladora le sobran 64 px vacíos. Los tres botones a lo ancho se llevan el **34 % del alto**.
2. **El problema de fondo no es el tamaño, es que se pierde información.** Cuando un efecto cambia con la mejora, el panel **borra la frase del efecto** y deja un renglón suelto entre «Apuntar» y «Mejorar» con rótulos de animación: la Eléctrica nunca dice que el rayo salta («saltos 2 → 3»), la Disruptora de nivel 1 y 2 nunca dice que apaga auras («s de pulso 2,5 → 3») y el Estandarte no dice en ningún lado que da apoyo. Es exactamente el punto 1 de RF-677 que quedó sin cumplir (H-4 del cierre de M75).
3. **Celular: hay un error que se ve.** La barra de la torre elegida mide 96 px, pero el texto queda en una columna de **265 px**, se parte en **5 renglones (127 px)** y **se sale de la pantalla**: el renglón «Al mejorar: …» (RF-617) no se ve y el borde de abajo de los botones queda 31 px fuera. Además dice «Cadencia 0.60» (con punto, contra RF-677.4) y **«Alcance 2» cuando el alcance es 2,5** (`%d` trunca el número).
4. **Recomendación:** **PC-A** (ficha con el cambio en su lugar, sin scroll, ≈ 75 % del área de hoy) y **CEL-A** (reordenar la barra para que la separación de seguridad de 35 mm entre Mejorar y Vender la ocupe el texto). Las dos aplican la misma regla, «el cambio va dentro de su propia línea», y pueden compartir una función de `TowerText`. PC-A cumple RF-677.1 tal como está escrito.

## 1. Cómo se midió

| Qué | Resultado |
|---|---|
| `godot --headless --import` | Una corrida, salida 0, sin el segfault 139. No cambió nada de `assets/`. Generó 115 `.import` sueltos en `Capturas/` (las capturas viejas no tenían el suyo en este worktree); se borraron. |
| Capturas | Herramienta nueva **fuera de `tools/`**: `art/t465-propuesta-panel/fuentes/capture_t510_panel.gd` (se corre con `-s` y ruta absoluta; la carpeta tiene `.gdignore`). Arma una partida del nivel 1 en memoria con un guardado temporal que borra al terminar. Ventana real (`DISPLAY=:0`): PC en pantalla completa (1920 × 1080) y en ventana de 1280 × 720; celular simulado (`ui_mode = 1`) en 1280 × 720 y 1600 × 720. Cinco corridas, todas con salida 0 y sin `SCRIPT ERROR`. |
| Medidas | La misma herramienta escribe el alto de cada bloque del panel (px lógicos y de pantalla) y si la lista de efectos necesita scroll: `capturas-actuales/medidas-pc-1920x1080.tsv`, `…-1280x720.tsv` y `medidas-celular-1280x720.tsv`. Las de PC dan **lo mismo** en las dos resoluciones (el lienzo es siempre 1280 × 720). |
| Fuente de las maquetas | Se exportó la fuente por omisión de Godot 4.7 desde el propio motor (`ThemeDB.fallback_font`): **Open Sans SemiBold** (licencia SIL OFL 1.1). Va incrustada en `index.html`, así las maquetas miden con la misma letra que el juego. |
| Tests | **No se corrió GUT**: no se cambió código del juego. La herramienta de captura no es un test. |

**No se pudo verificar:** ningún teléfono real (tamaño físico, letra en sp, dedos), Windows, ni que las maquetas midan igual en Godot que en el navegador (misma fuente y mismos px, pero otro motor de texto: puede haber ±1 renglón en frases largas).

**Pantalla vertical:** el juego solo se juega apaisado (`project.godot`: `window/handheld/orientation = 4`, sensor apaisado; M76 dice «No cambia pantalla vertical ni orientación móvil»). No hay versión vertical que mostrar. La ventana de 20:9 (1600 × 720) da el mismo lienzo de 1280 × 720 con la barra idéntica, así que esas capturas no se suben.

## 2. ¿Qué hace falta para decidir?

El panel aparece con una torre **ya construida**: las decisiones son **mejorar**, **vender**, **cambiar a quién apunta** o **no hacer nada**. Comprar se decide en la barra de abajo (tarjetas y tooltip), no acá.

| Dato | ¿Para qué decisión? | Hoy | Propuesta |
|---|---|---|---|
| Nombre de la torre | Contexto | Título, 18 px | Igual |
| Nivel actual | Mejorar | Tarjeta de 3 barritas + el número del botón | Tres rectángulos **horizontales** bronce/plata/oro; los vacíos con contorno del metal que falta, no oscuros |
| Daño, cadencia, alcance (y su cambio) | Mejorar | Tres columnas; la cadencia en 12 px | Filas rótulo-valor, todas en 14 px |
| Qué hace la torre (efecto) y su cambio | Mejorar, vender | La frase **desaparece** si cambia | La frase completa siempre, con «antes → después» adentro |
| Costo de la mejora y si alcanza el oro | Mejorar | En el botón; «faltan N» solo en el tooltip | En el botón, con la moneda; sin oro dice «faltan N» a la vista |
| Lo que devuelve vender | Vender | «Vender (+91) [S]» | Igual, a media anchura |
| Prioridad de objetivo | Apuntar | Botón a lo ancho, apagado cuando no aplica | Media anchura; **no se muestra** si la torre no apunta |
| Golpea voladores | Contexto (ya se supo al comprar) | Un renglón entero | Ícono con tooltip en el encabezado; tachado si no |
| Combo | Ubicación (más útil al comprar) | 2 renglones | Igual en PC-A; en un tooltip en PC-C |
| Recursos invertidos | Ninguna inmediata (es historia: lo que costó) | Renglón aparte | A un tooltip o a información secundaria. **No** es lo mismo que la devolución de «Vender (+91 y 1 recurso)» (observación de Codex); revisar RF-418 antes de moverlo |
| Estado (aturdida, desgaste, apoyo recibido) | Reparar, vender | Renglón ámbar | Igual (es lo único urgente) |

## 3. Medidas del panel de PC (px lógicos)

Eléctrica de nivel 1 (los demás casos están en los `.tsv`):

| Bloque | y | Alto | % de 320 |
|---|---|---|---|
| Margen + borde arriba | 0 | 12 | 4 % |
| Título + tarjeta + × | 12 | 34 | 11 % |
| DAÑO / CADENCIA / ALCANCE | 52 | 39 | 12 % |
| Separador | 97 | 4 | 1 % |
| Efectos + Voladores (scroll) | 107 | 60 (contenido 47) | 19 % |
| Apuntar | 173 | 32 | 10 % |
| Renglón de mejora suelto | 211 | 18 | 6 % |
| Mejorar | 235 | 34 | 11 % |
| Vender | 275 | 32 | 10 % |
| Separaciones (6 px × 7) + margen abajo | — | 55 | 17 % |

Casos donde la lista de efectos **no entra** (contenido > lugar): Hielo 1 (93 > 60), Hielo 2 (70 > 39), Hielo 3 (93 > 84), Incendiaria 1 (93 > 60), Mortero 2 (70 > 60) y Estandarte 1 (20 > 18, porque el nombre se parte en dos renglones y el bloque de mejora ocupa 39). Sobra lugar en: Ametralladora sin oro (64 px vacíos), Cañón 3 y Eléctrica (13 a 14 px).

## 4. Hallazgos en la PC

Severidad: **P0** bloquea o miente, **P1** confunde una decisión, **P2** estorba, **P3** detalle.

- **P1 · El efecto que cambia desaparece** (RF-677.1, H-4). `tower_panel.gd:141-152` saca de la lista el renglón cuyo prefijo coincide con la estadística que cambia y lo reemplaza por `UpgradeDeltas.rows(...)` con las etiquetas de `data/ui/mejoras.json`, que son las del **texto flotante de la animación** («saltos», «s de pulso», «s de frenado», «disp/s», «quemadura/s»), no frases de panel. Para el jugador, la Disruptora 1 no explica qué hace.
- **P1 · Estandarte mecánico:** muestra «DAÑO 0», «CADENCIA Apoyo», «Voladores: no» y «Apuntar» apagado; ninguno aplica a una torre de apoyo. Lo que sí hace (apoyo y reparación) solo aparece como «apoyo 10 % → 15 % · reparación/s 2 → 3», partido en dos renglones.
- **P1 · Alto fijo con scroll:** seis casos de trece. Una barra de desplazamiento de 6 px dentro de un panel de 320 px es difícil de ver y de usar, y en el Hielo 3 corta un dato.
- **P2 · «Mejorar» apagado no dice por qué.** El motivo («Faltan 25 de oro») vive en el tooltip; el botón solo se ve gris.
- **P2 · Jerarquía de los tres números:** la cadencia está en 12 px y daño y alcance en 15 px (se achicó para que entrara «0,75 → 0,85/s»). Parece un dato menos importante y no lo es.
- **P2 · Los botones pesan más que la información** (110 de 320 px) y los tres tienen el mismo ancho, alto y contraste: «Vender», que es destructiva, compite con «Mejorar» a 6 px.
- **P3 · Tarjeta de nivel:** tres `ColorRect` de 9 × 7 px estirados por el `HBoxContainer` a 9 × 34. Se leen como un medidor de señal; los vacíos (`darkened(0.72)`, alfa 0,6) casi no se ven sobre el hierro.
- **P3 · Detalles:** «Recursos invertidos: 2» ocupa un renglón en la lista de efectos aunque no sirve para ninguna decisión inmediata (no es la devolución: esa ya está en «Vender»); las teclas «[U]» y «[S]» con corchetes dentro del texto del botón ocupan ancho y podrían ser una tecla dibujada.

## 5. Hallazgos en el celular (simulado)

- **P0 · La barra se sale de la pantalla.** `mobile_hud.gd:250-256` arma tres renglones («nombre», «Nivel N de 3 ●○○ · Daño · Cadencia · Alcance», «Al mejorar: …»), pero la etiqueta solo recibe 265 px de ancho (la fila tiene la X de 64, Apuntar de 172, Mejorar de 196, Vender de 150 y una separación de 35 mm ≈ 376 px virtuales entre Mejorar y Vender). Con letra de 16 px el texto se parte en 5 renglones (127 px), el `HBoxContainer` crece y se corre 31 px por debajo del borde inferior. Pasa en los siete casos capturados salvo el nivel máximo (que no tiene «Al mejorar»).
- **P0 · Datos equivocados.** `"Cadencia %.2f"` escribe «0.60», «1.00», «0.25» (con punto y ceros de más, contra RF-677.4) y `"Alcance %d"` **trunca**: el Hielo y la Eléctrica de nivel 1 dicen «Alcance 2» con alcance 2,5, mientras el renglón de abajo dice «alcance 2,5 → 3». Es un error, no un pedido de diseño: el formato único ya está en la spec.
- **P2 · «Nivel 1 de 3 ●○○»** dice el nivel dos veces.
- **P2 · Letra de 16 px:** en el teléfono de referencia de T262 (6,5", 2400 × 1080, escala 1,5) son ≈ 9,5 sp; Android pide 12 sp (≈ 20 px virtuales) para texto corrido.
- **P3 · Apuntar ocupa 172 px apagado** en la Disruptora y el Estandarte.
- **Lo que está bien:** los botones miden 172 × 88, 196 × 84 y 150 × 82 (≈ 7,9 a 8,3 mm de alto en el teléfono de referencia, sobre los 7,6 mm de Material y los 56 px de RF-550); la X mide 64 × 64 (6 mm: cumple RF-550, queda debajo de los 7,6 mm). El primer toque de Mejorar cambia a «Confirmar → N2» en ámbar y conserva el costo (RF-681). La separación de seguridad entre Mejorar y Vender es una buena decisión de T263; lo que falla es que se come el lugar del texto.

## 6. Estética frente a la interfaz actual

La interfaz que el juego fue adoptando (menús, «Pausa [P]», «x1 [F]», Opciones con solapas) usa **hierro oscuro con borde bronce de 2 px (4 abajo), radio 6 y texto que se vuelve ámbar al pasar el mouse** (`menu_theme.tres`). El panel de torre todavía usa **rellenos planos** verde (`#526c4b`), ladrillo (`#755144`) y pizarra (`#48535d`) con borde de 1 px y radio 5 (`tower_panel.gd:214-246`): es el lenguaje viejo. En la captura a 1920 × 1080 el panel se ve como tres botones de colores con un poco de texto encima, no como una pieza de la misma familia que el HUD.

Las seis maquetas usan los botones del tema (hierro y bronce), el ámbar del título, el crema del texto, el verde claro de la vista previa para el «después» y el bronce, la plata y el oro de los niveles. «Vender» conserva un borde ladrillo apagado para diferenciarse sin gritar; «Mejorar» lleva un bronce más claro y un degradé leve para ser el botón principal.

## 7. Puntuación heurística

> ⚠️ **Evaluación degradada (un solo contexto).** Se usó la skill de diseño `impeccable` (modo `critique` y `distill`) como marco. Su flujo completo pide un detector automático de HTML y dos evaluaciones independientes en subagentes; el panel es una escena de Godot, no una página web, así que el detector no aplica y la evaluación la hizo un solo agente con las capturas reales.

| # | Heurística (Nielsen) | Nota 0-4 | Motivo |
|---|---|---|---|
| 1 | Visibilidad del estado | 2 | «Mejorar» apagado no dice por qué; el estado (aturdida, desgaste) sí se ve |
| 2 | Lenguaje del jugador | 2 | «s de pulso», «disp/s», «s de frenado» son rótulos de animación |
| 3 | Control y libertad | 3 | × para ocultar; en el celular, dos toques para mejorar y confirmación de venta |
| 4 | Consistencia | 1 | Dos lenguajes de botón, cadencia en otro tamaño, coma en PC y punto en el celular, efectos que aparecen o desaparecen según el nivel |
| 5 | Prevención de errores | 2 | En PC, Vender a 6 px de Mejorar y sin confirmación (con mouse es menos grave) |
| 6 | Reconocer antes que recordar | 2 | Hay que recordar qué hace la Disruptora o la Eléctrica: el panel no lo dice al nivel 1 |
| 7 | Flexibilidad y eficiencia | 3 | Teclas U, S y hover de la ampliación del alcance |
| 8 | Estética y minimalismo | 1 | Scroll, huecos vacíos, botones que dominan, datos que no aplican |
| 9 | Reconocer y salir de errores | 2 | Sin oro: el motivo está escondido |
| 10 | Ayuda | 3 | Tooltips y la Wiki |
| | **Total** | **21/40** | Aceptable con problemas claros (en el celular, peor: se corta) |

## 8. Qué restricciones conviene enmendar

| Requisito o decisión | Qué dice hoy | Qué cambiaría con la recomendación (PC-A + CEL-A) |
|---|---|---|
| **RF-677.1** | El cambio va en su lugar; se elimina `UpgradePreview` | **Nada:** PC-A lo cumple tal cual. (Con PC-B sí habría que enmendarlo). |
| **RF-677.2 / RF-650** | «Tarjeta de tres rectángulos» bronce/plata/oro que se llenan de a uno | Precisar la forma: tres rectángulos **en fila horizontal**, los vacíos con contorno del metal que falta. El tooltip «Nivel actual: N de 3» sigue. |
| **RF-686** y la ficha de T465 | «El texto más largo entra en 270 px» (y el panel mide 320 de alto fijo) | Sumar: **alto según el contenido, sin barra de desplazamiento** en los casos de RF-686 (Cañón, Tesla, Hielo y Disruptora, niveles 1 a 3), con un tope (por ejemplo 320 px) por si una torre futura trae muchos efectos. El ancho sigue en 270. |
| **RF-650** (panel legible) | «No oculta nombre, costo ni datos necesarios para decidir» | Agregar que **no se muestran filas que no aplican** (DAÑO de una torre de apoyo, Apuntar de una torre que no apunta) y que «Mejorar» apagado **dice el motivo** a la vista. |
| **RF-617** | Celular: tercer renglón «Al mejorar: daño 5 → 8 · alcance 3 → 3,5» | El cambio pasa a ir **en su lugar** dentro del renglón de números (como PC-A); se va el prefijo «Al mejorar:». Sigue la regla de un solo origen (RF-618). |
| **RF-512** | Orden de la barra del celular | Nuevo orden en el estado «torre»: ×, Vender, texto, Apuntar, Mejorar. La separación de seguridad de 35 mm entre Vender y Mejorar se mantiene (la cubre el texto, ≥ 600 px). |
| **RF-677.4** | Coma decimal en toda la pantalla | Nada que enmendar: el celular **no lo cumple** y hay que arreglarlo (es un error). |
| **D-193** | Propuesta A del panel | Sigue vigente; una decisión nueva (la próxima libre, **D-214 o siguiente**) registraría la forma de la ficha, el alto según contenido y los botones del tema. |
| D-194 a D-197 | Alcance, ampliación en «Mejorar», arco del Estandarte, Opciones | **No se tocan.** El hover de «Mejorar» (RF-680) y los dos toques (RF-681) siguen igual en todas las opciones. |

`data/ui/mejoras.json` **no cambia** con PC-A ni CEL-A: el «antes → después» de los efectos se arma con las mismas plantillas de `TowerText.effects` (las frases que ya se ven en el nivel máximo) y los números de los dos `TowerLevelData`. PC-B sí necesitaría rótulos de panel nuevos (texto, no números).

## 9. Tareas de código que saldrían (no se crean acá)

1. **🐛 Celular: formato y desborde** (urgente, sirve con cualquier opción): coma decimal y alcance con `TowerText.decimal`, y que la barra no pase de 96 px. Tests de la barra con el Hielo 1 y la Eléctrica 1.
2. **📜 Enmiendas de spec** de la sección 8 (RF-650, RF-677.2, RF-686, RF-617, RF-512) y la decisión nueva, después de que Lucas elija.
3. **PC-A:** `TowerText` con una función que arma cada frase de efecto con «antes → después» (un solo lugar para PC y celular); `tower_panel.tscn/.gd` sin `UpgradePreview`, con filas rótulo-valor, alto según contenido, botones del tema y la fila Apuntar/Vender; reescribir `tests/test_upgrade_preview.gd` y `tests/test_tower_panel_layout.gd`; capturas de RF-686.
4. **CEL-A:** reordenar la barra en el estado «torre», dos renglones a 20 px, sin Apuntar cuando no aplica; tests de posición y de separación de seguridad.

## 10. Qué propuso Codex

Se le pidió lo mismo a Codex con las capturas, las medidas y esta crítica (prompt en `art/t465-propuesta-panel/fuentes/prompt-codex.txt`). **`gpt-6.1-astra` no está disponible** en la CLI con esta cuenta (`model_not_found`, probado una vez); se usó **`gpt-6.1-sol`** con esfuerzo medio. Entregó `codex/propuesta-codex.md` y `codex/maquetas-codex.html` (sin fuente del juego: Arial del sistema; su Firefox no arrancó por el snap, así que Claude lo renderizó para las imágenes).

| Codex | Eléctrica 1 | Área frente a hoy | Idea |
|---|---|---|---|
| PC 1 · Ficha de lectura (su recomendada) | 340 × 308 | 121 % | Como PC-A, más ancha para que la cadencia entre en columnas a 16 px |
| PC 2 · Franja de dos columnas | 700 × 220 | 178 % | Números a la izquierda, efectos a la derecha |
| PC 3 · Resumen con despliegue | 320 × 260 (420 abierta) | 96 % | «Más datos y acciones» esconde combo, Apuntar y Vender |
| Celular 1 · Banda en dos pisos (su recomendada) | 1280 × 280 | barra × 2,9 | Un piso de información y otro de botones; −33 % de alto de mapa |
| Celular 2 · Efectos desplegables | 1280 × 176 (350 abierta) | barra × 1,8 | El primer toque de Mejorar abre también los efectos |
| Celular 3 · Inspector separado | 600 × 252 + barra de 96 | — | Ficha arriba a la izquierda, botones abajo |

**Coincide** con esta crítica en lo de fondo: la flecha dentro de la frase, sin scroll, sin datos que no aplican, tres rectángulos horizontales, botones de hierro y bronce, «faltan N de oro» visible y no achicar la cadencia. **Difiere** en que sus dos recomendadas resuelven el espacio agrandando el panel, lo contrario de lo que pidió Lucas; por eso se recomienda PC-A + CEL-A. **Se toman de Codex:** la distinción entre inversión y devolución (RF-418), la frase del Estandarte «solo el mayor apoyo y la mayor reparación», la observación de que `test_panel_shows_each_upgrade_value_once_…` hoy **exige** borrar la frase del efecto (protege lo contrario de RF-677.1) y su mapa de tests afectados (U1 a U4, L1 y L2), útil para la tarea de código. También señala una tensión previa entre RF-74 («los clics del panel no llegan al mapa») y `test_panel_passes_map_clicks_through_passive_regions…`, que conviene precisar al implementar.
