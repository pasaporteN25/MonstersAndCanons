# T513 · Implementar el panel de torre PC-A

- Ejecutor · Sonnet · esfuerzo medio-alto.
- Depende de · T512 (spec enmendada, OK de Lucas a PC-A registrado en D-214) · Compuerta · ninguna de arte, salvo que se usen íconos nuevos (ala, moneda, mira: los de la maqueta **no son arte aprobado**) · Tamaño · Mediano.

> Ficha escrita el 2026-10-26 (T512). Cierra, junto con T514, la tarea T465.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`.
- `specs/01-spec.md`: **RF-721** (la ficha), RF-650, RF-677 y RF-686 con sus enmiendas del 2026-10-26.
- `specs/04-decisiones.md`: D-214 (y D-193, que sigue vigente).
- `specs/tareas/informes/T510-panel-torre-critica.md` §3, §4, §8 y §10 (medidas, hallazgos y mapa de tests afectados).
- La maqueta: `art/t465-propuesta-panel/maquetas/maqueta-pc-a.png` y `art/t465-propuesta-panel/index.html` (función `panelA`; los datos de cada torre están en el objeto `T`). Las capturas de hoy: `art/t465-propuesta-panel/capturas-actuales/`.

## Objetivo

Que el panel de torre de la PC mida 270 px de ancho, su alto salga del contenido (tope 320 px), no tenga barra de desplazamiento y muestre el «antes → después» **dentro de la frase de cada efecto**, con botones del tema de los menús.

## Alcance

**Sí:** `scripts/logic/tower_text.gd` (una función de frase «antes → después» por efecto), `scenes/ui/tower_panel.gd` y `.tscn`, `scripts/logic/upgrade_deltas.gd` solo si hace falta exponer el par antes/después, `tests/test_upgrade_preview.gd`, `tests/test_tower_panel_layout.gd` y los tests que dependan de los nodos que se quitan.

**No:** `scenes/game/mobile_hud.gd` (T514; si la función de frase se comparte, queda en `TowerText`, sin tocar la barra); precio, daño, venta y reglas de mejora; `data/ui/mejoras.json` (los rótulos de la animación no se tocan); el hover de «Mejorar» (RF-680).

## Pasos

1. **`TowerText`:** una función que arma la frase de cada efecto con el cambio adentro («El rayo salta a 2 → 3 enemigos más»), a partir de las plantillas que ya usa `TowerText.effects` y de los dos `TowerLevelData` (nivel actual y siguiente). En el último nivel devuelve la frase simple, sin flechas. Todos los decimales con `TowerText.decimal`.
2. **`tower_panel`:** quitar el nodo `UpgradePreview` y el filtro que borra el renglón del efecto que cambia. Filas rótulo-valor para Daño, Cadencia y Alcance, las tres a la misma letra («Cadencia 0,75 → 0,85/s» tiene que entrar en 270 px). Sin filas que no aplican (torre de apoyo: sin Daño ni Cadencia; sin Apuntar si no apunta). «Voladores» como ícono con tooltip en el encabezado (tachado si no). Tarjeta de nivel horizontal; los rectángulos vacíos con el contorno del metal que falta.
3. **Botones** con el tema de los menús (`menu_theme.tres`), no con los `StyleBoxFlat` verde, ladrillo y pizarra: «Mejorar a nivel N» a todo el ancho con el costo y `[U]`; Apuntar y Vender a media anchura; «Vender» con borde ladrillo apagado. «Mejorar» sin oro: apagado y con «faltan N» a la vista.
4. **Tamaño:** ancho 270 px; alto = contenido, con tope de 320 px. Sin `ScrollContainer` en los 12 casos de RF-686. Si el contenido pasa el tope (torre futura), ahí sí desplaza.
5. **Tests:** reescribir `tests/test_upgrade_preview.gd` (hoy `test_panel_shows_each_upgrade_value_once_…` exige borrar la frase del efecto: pasa a exigir la frase con la flecha adentro, una vez) y `tests/test_tower_panel_layout.gd` (alto según contenido, sin scroll, ancho 270, tope 320, Estandarte sin «DAÑO», «CADENCIA» ni «Apuntar», ícono de voladores, botones con el tema). Conservar el test de ancho del texto más largo (Tesla de nivel 1) y el de «sin punto decimal» del nivel 3. Precisar la tensión entre RF-74 y `test_panel_passes_map_clicks_through_passive_regions…` (T510 §10).
6. **Capturas** de RF-686: Cañón, Tesla, Hielo y Disruptora en los niveles 1 a 3, a 1280 × 720 y 1920 × 1080 (más Estandarte 1 y Ametralladora 1 sin oro), con `DISPLAY=:0` y fuera del repo. Comparar con `maqueta-pc-a.png`: puede haber ±1 renglón.

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) `TowerText` tiene una función de frase «antes → después» por efecto; `tower_panel` no usa `UpgradePreview` y la frase de cada efecto lleva su cambio adentro; el panel mide 270 px de ancho, su alto sale del contenido (tope 320) y no tiene barra de desplazamiento en los 12 casos de RF-686; sin «DAÑO 0», «CADENCIA Apoyo» ni «Apuntar» apagado en el Estandarte; «Voladores» es un ícono con tooltip; «Mejorar» sin oro dice «faltan N»; botones de hierro y bronce, con Apuntar y Vender a media anchura; la tarjeta de nivel es horizontal con contorno del metal que falta; `tests/test_upgrade_preview.gd` y `tests/test_tower_panel_layout.gd` reescritos; GUT completo sin `SCRIPT ERROR`; capturas de RF-686 a 1280 × 720 y 1920 × 1080. No cambia precio, daño, venta, reglas ni `data/ui/mejoras.json`.

## Verificación

`godot --headless --import` y GUT completo (`… 2>&1 | grep -c "SCRIPT ERROR\|Parse Error"` da 0). Después de `--import`, `git status` y devolver con `git checkout -- assets` lo que no se tocó. **No se puede probar acá:** Windows ni un teléfono real. Al terminar, anotar en `specs/03-tareas.md` el «Resultado» honesto (qué se midió, qué no) y, si T514 también está en `main`, cerrar T465.

## Frenar si

El panel no entra en 270 px sin achicar la letra de Cadencia, o sin barra de desplazamiento en alguno de los 12 casos: consultar a Lucas antes de agrandar el panel (fue justo lo que pidió evitar). Si una frase de efecto no tiene plantilla propia en `TowerText.effects`, no inventar texto: anotarla y consultar.

## Resultado

**Resultado (2026-10-26, Sonnet 5.5; PR encadenado tras #107):** hecho. `TowerText.effect_phrases(level, next, panel)` arma la frase de cada efecto con su «antes → después» (un solo lugar; `TowerText.effects` es la misma función sin nivel siguiente, así la Wiki no cambia); se retiran `panel_pulse_line`, `panel_effect_residuals`, `UpgradePreview` y el filtro que borraba el renglón. `tower_panel.tscn/.gd`: 270 px de ancho, filas rótulo-valor a 14 px, sin «Daño»/«Cadencia» en el Estandarte, sin «Apuntar» si no apunta (apoyo y pulso), «Voladores» como ícono (`flyer.svg`, ya aprobado) con tooltip y tachado, tarjeta de nivel de tres rectángulos horizontales con contorno del metal que falta, botones del tema `menu_theme.tres` (Vender con borde ladrillo apagado), «Mejorar a nivel N» con moneda (`stat_gold.svg`), costo y `[U]`, o «faltan N» sin oro, y Apuntar/Vender a media anchura. **Medido (px lógicos, Godot, 1920 × 1080 y 1280 × 720, mismos valores):** antes **270 × 320 fijo** en los 13 casos medidos (con scroll en 6); ahora **270 × 250** Eléctrica 1, Cañón 1 a 3 y Eléctrica 1 a 3; **270 × 273** Hielo 1 a 3 y Disruptora 1 y 2; 270 × 250 Disruptora 3; 270 × 275 Estandarte; 270 × 201 Ametralladora 1 sin oro; el máximo es 296 (Incendiaria 1) y ninguno de los 20 casos capturados tiene barra (la lista solo desplaza pasados 320, probado con un test). Eléctrica 1: 250 contra los 240 de la maqueta; Hielo 1: 273 contra 259 (el combo parte en 3 renglones en el motor y en 2 en el navegador, el ±1 renglón que la ficha anticipaba). Tests: `test_tower_panel_layout.gd` y `test_upgrade_preview.gd` reescritos (11 torres × 3 niveles: ancho, tope, sin barra, cada frase una sola vez, sin punto decimal), más `test_upgrade_sell.gd` y `test_repair.gd` ajustados a los textos nuevos («Mejorar a nivel 2» con el costo en `%Cost`; «Vender +35 [S]»; «Reparación recibida: 2 puntos/s», ahora con coma decimal). Los tests nuevos no compilan sobre el panel de antes (faltan `TowerText.effect_phrases`, `TowerPanel.WIDTH`…), o sea que fallan sin el cambio. GUT completo: 2482/2482, 0 `SCRIPT ERROR`. Capturas en `Capturas/T513-panel-antes|despues-*.png` (herramienta `art/t465-propuesta-panel/fuentes/capture_t513_panel.gd`). **No se probó:** Windows, un teléfono, rendimiento ni el hover real con mouse humano. **Decisiones chicas a revisar:** (1) el «después» no va en verde como en la maqueta (el panel usa `Label`, de un solo color); (2) «Apuntar» muestra solo el modo («Primero»), porque «Apuntar: Más cercano» no entra en media anchura y la maqueta usa un ícono de mira que no es arte aprobado; el tooltip dice «Apuntar: …»; (3) «Vender» con recursos parte en dos renglones (Mortero: «Vender +385 y 2 recursos [S]»); (4) el ícono de voladores es el del Vuelador del juego, provisorio hasta que arte decida. **T465 sigue abierta** (depende de T514).
