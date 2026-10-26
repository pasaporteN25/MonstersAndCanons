# T510 · Propuesta de rediseño del panel de torre (para T465)

**2026-10-26.** Crítica del panel de la torre elegida (PC y celular) y seis maquetas simplificadas. Para verlas, abrir `index.html` en un navegador (autocontenido: la fuente del juego va incrustada; las imágenes, con rutas relativas). La crítica completa está en `specs/tareas/informes/T510-panel-torre-critica.md`.

> **Las opciones son maquetas en HTML, no el motor.** Usan la fuente, los colores y los números reales del juego, y sus medidas las toma el navegador, pero no salen de Godot. Puede haber diferencias de ±1 renglón en las frases largas cuando se implementen.

## 1. Lo que hay hoy

| | PC (1920 × 1080 y 1280 × 720) | Celular simulado (1280 × 720) |
|---|---|---|
| Tamaño | 270 × 320 px lógicos fijos (405 × 480 en 1920 × 1080) | Barra de 96 px; el texto mide 265 × 127 y **se sale 31 px de la pantalla** |
| Scroll | En 6 de 13 casos | No hay: se corta |
| Efecto que cambia | Se borra de su renglón y aparece suelto entre Apuntar y Mejorar («saltos 2 → 3») | Tercer renglón «Al mejorar: …», que no se ve |
| Formato | Coma decimal | «Cadencia 0.60» (punto) y «Alcance 2» para 2,5 |
| Capturas | `capturas-actuales/hoja-actual-pc-1920x1080.png`, `hoja-actual-pc-1280x720.png`, recortes `T510-actual-pc-*` y pantallas `T510-actual-pc-pantalla-*` | `capturas-actuales/hoja-actual-celular-1280x720.png`, recortes `T510-actual-celular-*` y pantallas `T510-actual-celular-pantalla-*` |

El juego solo se juega apaisado (`window/handheld/orientation = 4`): no hay versión vertical. En 20:9 (ventana de 1600 × 720) el lienzo sigue siendo 1280 × 720 y la barra es idéntica.

## 2. Opciones y medidas

Medidas en px lógicos (1 px CSS = 1 px del lienzo de 1280 × 720), tomadas por el navegador con Open Sans SemiBold, la fuente del juego. «Hoy» = 270 × 320 = 86.400 px².

| Opción | Eléctrica 1 | Hielo 1 | Estandarte 1 | Cañón 3 | Ametralladora sin oro | Disruptora 1 |
|---|---|---|---|---|---|---|
| **PC-A** · Ficha con el cambio en su lugar | 270 × 240 (75 %) | 270 × 259 (81 %) | 270 × 237 (74 %) | 270 × 234 (73 %) | 270 × 196 (61 %) | 270 × 239 (75 %) |
| **PC-B** · Lo que tenés y lo que comprás | 270 × 257 (80 %) | 270 × 259 (81 %) | 270 × 293 (92 %) | 270 × 202 (63 %) | 270 × 196 (61 %) | 270 × 221 (69 %) |
| **PC-C** · Tira mínima y tooltip | 256 × 132 (39 %) | 256 × 132 (39 %) | 256 × 147 (44 %) | 256 × 132 (39 %) | 256 × 114 (34 %) | 256 × 132 (39 %) |
| **CEL-A** · El texto llena la separación de seguridad | barra 1280 × 96, texto ~650 px de ancho en 2 renglones de 20 px | | | | | |
| **CEL-B** · Mejorar muestra lo que se compra | barra 1280 × 96, Mejorar de 320 px | | | | | |
| **CEL-C** · Barra mínima y hoja de detalle | barra 1280 × 96 + hoja de 420 × ~255 | | | | | |

Comparación de información, coste, tests y enmiendas: `index.html` §5. Imágenes de las maquetas (para el PR): `maquetas/maqueta-pc-a.png`, `-pc-b`, `-pc-c`, `-pc-en-su-lugar`, `-celular-a`, `-celular-b`, `-celular-c`.

## 3. Recomendación

**PC-A + CEL-A**, empezando por el celular (hoy se corta y muestra datos equivocados). Comparten una regla («el cambio va dentro de su propia línea») y pueden compartir una función de `TowerText`. PC-A cumple RF-677.1 tal como está escrito, ocupa entre 61 y 81 % del área de hoy y no tiene scroll. CEL-A no cambia el tamaño de la barra ni de los botones: reordena la fila (×, Vender, texto, Apuntar, Mejorar) para que el texto ocupe la separación de seguridad de 35 mm entre Vender y Mejorar.

Qué habría que enmendar y qué tareas saldrían: sección 8 y 9 del informe.

## 4. Procedencia

| Qué | Quién / cómo |
|---|---|
| Capturas del panel actual y medidas `.tsv` | Godot 4.7.2 real con `fuentes/capture_t510_panel.gd` (Claude). Ventana real `DISPLAY=:0`; PC en pantalla completa (1920 × 1080) y en 1280 × 720; celular simulado (`ui_mode = 1`) en 1280 × 720. Guardado temporal `user://capture_t510_panel.json`, borrado al terminar. Se corre: `DISPLAY=:0 godot --path . -s /ruta/absoluta/art/t465-propuesta-panel/fuentes/capture_t510_panel.gd -- /salida/fuera/del/repo pc fullscreen` (o `pc 1280x720`, `celular 1280x720`). |
| Fondo de las maquetas «en su lugar» | `maquetas/T510-fondo-pc-sin-panel-*.png`: la misma herramienta, con la Eléctrica elegida y el panel oculto. |
| Hojas de contacto | Armadas con Python/PIL a partir de los recortes, sin achicar. |
| Crítica | Claude (Opus 5.5), con la skill de diseño `impeccable` (`critique` y `distill`) en modo degradado de un solo contexto: el panel es Godot, no web, y el detector de la skill no aplica. |
| Maquetas PC-A/B/C y CEL-A/B/C | Claude, en `index.html` (fuente editable: el mismo archivo; los datos de cada torre están en el objeto `T` del script, con los valores de `data/towers/*.tres`). |
| Fuente | Open Sans SemiBold, la fuente por omisión de Godot 4.7, exportada del propio motor (`ThemeDB.fallback_font`) a `fuentes/OpenSans-SemiBold-godot.woff2` e incrustada en base64. Licencia SIL Open Font License 1.1. |
| Íconos de las maquetas (ala, moneda, mira, cruz) | SVG en línea dibujados para la maqueta. **No son arte del juego** ni están aprobados: si una opción los usa, pasan por la compuerta de arte. |
| Propuesta de Codex | `codex/propuesta-codex.md` y `codex/maquetas-codex.html`: Codex CLI 0.163, modelo **`gpt-6.1-sol`**, esfuerzo medio, `-s workspace-write`. Prompt: `fuentes/prompt-codex.txt`. `gpt-6.1-astra` **no estaba disponible** (`model_not_found` con esta cuenta). Las imágenes `codex/maquetas-codex-pc.png` y `-celular.png` las renderizó Claude con Firefox (el Firefox de Codex no arrancó por el snap). |
| Imágenes de las maquetas | Firefox 158 sin ventana (`--headless --screenshot`), `index.html?tema=oscuro&solo=<sección>`, ventana de 1400 px de ancho; recortadas al contenido con PIL. |

## 5. Lo que no se pudo verificar

- Ningún teléfono real: tamaño físico de los botones, letra en sp, el pulgar sobre la barra. Las cuentas en mm usan el teléfono de referencia de T262 (6,5", 2400 × 1080).
- Que las maquetas midan igual en Godot que en el navegador (misma fuente y px, otro motor de texto).
- Windows.
- No se corrió GUT: no hubo código del juego.
