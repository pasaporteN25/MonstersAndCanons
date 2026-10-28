# T463 · Propuesta del fondo de la presentación del Coloso

> Escrito el 2026-10-28 (Claude, Sonnet 5.5). **Preparación, sin integrar**: no se tocó `assets/`, ni código, ni datos. Las muestras viven en `art/t463-fondo-coloso/` y esperan el OK escrito de Lucas (`revision.html`).

## 1. Contexto y alcance

Lucas decidió (2026-10-28) que el fondo del jefe supremo del nivel 15 **entra en la V1**. El jefe supremo es el **Coloso** (concepto C de T243, ya aprobado y ya en el juego: `data/enemies/colossus.tres`, 600 de vida, 12 vidas, aparece en las oleadas 26, 28 y 30 del nivel 15). Esta tarea pide la muestra del fondo, el OK escrito y, **después**, una tarea de código para integrarlo. T463 depende de que Lucas apruebe el estilo de la presentación de jefes (T367).

## 2. Qué necesita exactamente la presentación del Coloso

Leído en `scenes/ui/boss_presentation.gd` (T461, RF-666 a RF-673, D-188 a D-191) y en `Game._maybe_boss_presentation` (`scenes/game/game.gd`, ~líneas 1013 a 1040):

| Capa (de abajo hacia arriba) | Qué es hoy | Qué entra con arte aprobado |
|---|---|---|
| `Backdrop` (`ColorRect`) | Color liso: negro cálido mezclado 18 % con `EnemyData.color` | Queda de base (se ve si la imagen no cubre) |
| `BackdropArt` (`TextureRect`) | **No existe** si no se pasa `backdrop` | **El fondo (T463).** `STRETCH_KEEP_ASPECT_COVERED` a toda la ventana: se recorta, no se deforma. **Estático**: el código no lo anima |
| `Column` → `Title` | «¡Llega el Jefe!», 34 px, rojo, arriba | Texto del juego (no va en el arte) |
| `Column` → `Illustration` (`TextureRect`) | `illustration` o, si falta, **`EnemyData.texture`** (el PNG de 256 px del mapa), en una caja de 360 px de alto (la mitad de 720), `KEEP_ASPECT_CENTERED`, con zoom lento 0,9 → 1,04 por código | **La ilustración quieta (T367).** Es una pieza aparte del fondo, con alfa |
| `Name`, `Line`, `Hint` | Nombre 52 px, descripción 22 px (2 renglones), pista 18 px | Texto del juego |

**Fondo e ilustración son dos archivos distintos.** El fondo es la escena (sin personaje); la ilustración es el Coloso solo, transparente. Todo el movimiento (fundido de 0,25 s, zoom, pista a los 0,3 s) sale de código (D-191); el arte no trae animación.

**Tamaños.** Viewport de diseño 1280×720 (`project.godot`, `stretch/mode=canvas_items`). Fondo: 16:9, **1920×1080 recomendado** (la ventana real puede ser 1080p, ver T476); en celular alargado (20:9) el `COVERED` recorta ~20 % del alto, así que nada importante debe estar en el 10 % superior ni inferior. Ilustración: PNG RGBA cuadrado de **1024×1024** (a 1080p se muestra a ~540 px de alto, y hoy el sprite de 256 px estirado se ve blando, comprobado en captura).

**Zonas de composición (medidas en la captura de 1280×720):**
- Arriba, centro (y ≈ 8 a 17 %): título.
- Centro (y ≈ 20 a 52 %): la ilustración.
- Abajo (y ≈ 69 a 93 %): nombre, descripción y pista. Es texto claro con contorno negro de 6 px, pero **sobre un fondo con rocas y matorrales la descripción pierde contraste** (se ve en `coloso_con_muestra_01/02.png`). Dos soluciones posibles: un degradé oscuro por código detrás del bloque de texto (no es arte) o que el fondo sea más calmo en el tercio inferior.

**Hay un hueco de integración que no es de arte:** `Game` llama `setup(enemy.data, segundos, mobile)` **sin** `illustration` ni `backdrop`. Falta definir dónde viven esas dos rutas por enemigo (campos en `EnemyData` o una tabla en `data/ui/`; el `entrada_jefes.json` viejo se retiró en T461). Eso es la tarea de código posterior, no esta.

## 3. Estilo vigente a respetar (compuerta de estilo, guía de arte §4)

Referencias inspeccionadas: `assets/sprites/map/rendered/tree.png`, `rock_a.png`, `forest_idle.png`, `m79/cactus_02.png`, `assets/sprites/enemies/rendered/colossus.png`, y las capturas reales `art/t537-arte-campana/captures/level_15_active.png` (el mapa del Coloso) y las de la presentación actual (`art/t463-fondo-coloso/context/vigente_coloso.png`, `vigente_jefe.png`, sacadas con `BossPresentation` real en una ventana de Godot).

- **Técnica:** PNG pintados y dimensionales, volúmenes esculpidos; **no** vector plano ni SVG de 64 px (esa es la familia histórica, no define el estilo).
- **Perspectiva y luz:** cámara elevada tipo 3/4 (mira hacia abajo al terreno), luz suave desde arriba a la izquierda, sombras de apoyo discretas.
- **Material y paleta:** mate, apagado y terroso: basalto gris carbón con vetas ámbar tenues (el Coloso las trae), pasto y matorral oliva, tierra ocre. Sin contornos, sin resplandores mágicos, sin niebla.
- **Escala de uso:** el fondo se ve a pantalla completa (no a 34 px); la lectura que importa es la composición con el Coloso encima y el texto abajo.
- **Lo que hoy tienen los jefes presentados:** nada propio. Ni el Jefe ni el Coloso tienen arte de presentación; ambos usan el sprite del mapa sobre fondo liso (captura vigente). `art/t367-muestras/` es del concepto viejo y no se usa.

## 4. Qué se generó y qué no

**Generador usado:** `codex exec -m gpt-6-luna` con su herramienta de imagen integrada (la misma vía que usaron T244 y T540; el modelo interno no se expone). Salida nativa 1672×941. Se corrió tres veces.

1. **Primer intento (anfiteatro de basalto): descartado.** Salió un paisaje cinematográfico casi fotorrealista, con horizonte, sol y bruma. No es la familia del mapa y la compuerta de estilo lo rechaza. Se conserva `sources/raw_a.png` como evidencia. **Corrección del proceso:** se reformuló el encargo para pedir la familia vigente.
2. **Muestra 01 · claro de frontera** (`muestra_01_claro.png`): pasto oliva y tierra, anillo de rocas facetadas y matorrales. Coincide con el nivel 15 de hoy. Es la más segura.
3. **Muestra 02 · claro sombrío** (`muestra_02_sombrio.png`): suelo oscuro con grietas ámbar, rocas de basalto con vetas (como las del Coloso) y un camino ondulado. Más de «cierre»; el Coloso se despega mejor.

Entregadas a **1280×720** (Lanczos, sin retoque). **Solo hay dos muestras, no tres**: la tercera disponible (el cañón) no pasó la compuerta y no la presento como opción.

**Cómo se verificó:** las dos se vieron a escala completa y **dentro del motor** (`art/t463-fondo-coloso/capture_presentation.tscn`: `BossPresentation` real con la muestra pasada por `setup(..., backdrop)`), capturas en `context/`. **Lo que no se hizo:** no se probó en celular real ni en modo celular simulado; no se midió rendimiento; no se midió contraste del texto con una herramienta (la observación del §2 es a ojo); no se usó 1920×1080 nativo (el generador entrega 1672×941; para integrar a 1080p hay que decidir entre reescalar con pérdida o regenerar, ver §6).

**Limitaciones de las muestras (honestas):** (a) la 02 tiene el camino justo detrás del nombre; (b) ambas tienen detalle fino en bordes que, con el degradé de texto, se resuelve en código; (c) la generación por IA no permite exigir un encuadre exacto: una segunda ronda es probable; (d) las capturas del motor salieron en una ventana mayor que 1280×720 y se redujeron con Lanczos.

## 5. Plan acotado para T367/T369 (solo lo necesario para el Coloso en V1)

**Entra (en este orden):**
1. **Compuerta de Lucas:** aprobar el estilo de la presentación (ver §6) y elegir fondo (T463: muestra 01, 02 o una nueva ronda). OK escrito.
2. **T367 (parte Coloso):** una **ilustración quieta del Coloso** (1024×1024 RGBA, misma luz y materiales que `colossus.png`, de frente o 3/4, sin suelo) con la misma compuerta de estilo y hoja a 220 y 34 px. Se parte de `art/t244-coloso/` (concepto aprobado). Sin esto el fondo se ve con un sprite blando.
3. **T463 (cierre):** el fondo elegido a 1920×1080 en `art/` con `manifest.json` y fuente, más el OK por escrito.
4. **Tarea de código (nueva, la que pide T463):** ruta de `illustration` y `backdrop` por enemigo (dato, no `if`), `preload`, degradé del bloque de texto, pruebas de que el Jefe sin arte sigue con la composición provisional y de que el Coloso carga ambos. Mueve los dos PNG a `assets/` recién con el OK.
5. **T369 (solo PC, solo Coloso):** capturas reales en PC y celular simulado, y la medición de la presentación (que no baje de 60 FPS al abrir la capa con una textura de 1920×1080).

**Queda fuera de la V1 (salvo que Lucas diga otra cosa):** arte propio del **Jefe/Soberano** (sigue con la composición provisional), el **Pedazo** (no tiene presentación: `lives_damage` 4, no es peligroso), movimiento del fondo (D-191 lo da como estático), música o voz, retrato en la tarjeta «Nuevo enemigo», variantes por tema de mapa, y celular real (queda en T454).

## 6. Preguntas abiertas para Lucas

1. **Estilo de la presentación (la compuerta de T367 y T463):** ¿te cierra el lenguaje de las muestras (pintado, elevado, el mismo del mapa) para el fondo de la presentación? ¿O querés algo más cinematográfico (como el descartado), aunque rompa con el mapa?
2. **¿Muestra 01 (claro, continuidad con el nivel 15), 02 (sombrío, de cierre), ninguna o una mezcla?**
3. **Camino:** ¿el camino ondulado de la 02 es un adorno que querés (el Coloso «viene por el camino») o lo sacamos?
4. **Texto:** ¿puedo planear un degradé oscuro por código detrás del nombre y la descripción (no es arte, no cambia la spec), o preferís un fondo más calmo abajo?
5. **Resolución:** ¿1920×1080 nítido (hay que regenerar o reescalar con pérdida porque el generador da 1672×941) o 1280×720 alcanza para V1?
6. **Ilustración del Coloso:** ¿puedo hacer una pieza quieta nueva a 1024 px a partir del concepto aprobado de T244 (o preferís reusar el sprite del mapa y aceptar que se vea blando)?
7. **Jefe (Soberano) del nivel 1:** ¿se queda con la composición provisional en V1 o querés su fondo también (amplía T367)?
8. **Procedencia:** la imagen sale de la herramienta de imagen de Codex. ¿Está bien ese origen para el arte final del juego, como en T244 y T540?
