# T242 · Intro: reproducir, omitir y volver a ver

> **Estado: HECHA (2026-10-11: el paso 6 se cerró con las láminas definitivas; ver el Resultado en `03-tareas.md`).** Antes, en curso: **Lucas aprobó el guion y M57 el 2026-10-11** (P1 y P2 como se recomendaban). **Los pasos 1 a 5, 7 y 8 están hechos (2026-10-11) con imágenes provisorias** (`assets/intro/`, generadas con `tools/make_intro_placeholders.py`); **el paso 6 (medir el texto y reexportar) se hizo después**, con las láminas de T241 aprobadas. El Resultado está en `03-tareas.md`. La spec es **M57** (`01-spec.md`, RF-497 a RF-501), la decisión **D-096**, el plan técnico «M57 / T240» (`02-plan-tecnico.md`) y el guion `specs/intro/guion.md`.

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** · **Depende de:** T241 (las láminas), aunque **los pasos 1 a 5 se pueden hacer antes con imágenes provisorias** · **Tamaño:** chico a mediano (un lector de datos, una pantalla, una clave del guardado y dos botones)

## Leer
- **M57 entero** (`01-spec.md`, desde «### M57»): RF-497 a RF-501 y su criterio de aceptación.
- **D-096** y el plan «M57 / T240» (qué hay hoy en el código y qué se agrega).
- `specs/intro/guion.md` §2 (límites del texto), §5 (el resumen con los textos y duraciones) y §7 (funcionamiento).
- `scenes/ui/main_menu.gd` (cómo se conecta «Jugar»), `scenes/ui/epilogue_screen.gd` y `scenes/ui/level_intro.gd` (**el modelo**: overlay `CanvasLayer`, «solo muestra y avisa», clic que se traga), `scripts/autoload/save_manager.gd` (`save`, `load_save`, `_read_*`) y `scripts/logic/level_texts.gd` (el modelo de un validador de texto), `scenes/ui/wiki_screen.gd`.
- `.claude/rules/gdscript.md` (tabuladores, tipos estáticos, **números en `data/`**, señales hacia arriba) y `.claude/rules/tests.md` (**nada que cambie de escena**, guardados `user://test_*.json`).

## Pasos
1. **Los datos y el lector.** `data/intro/intro.json` con los siete textos **tal cual** de `guion.md` §4 y `IntroData` (lógica pura) con los errores de RF-497, en castellano y nombrando la lámina. Reusar los límites de `LevelTexts` (victoria: 2 líneas, 160 caracteres, 90 por línea) en lugar de copiarlos.
2. **La clave del guardado.** `"intro_seen"` en `SaveManager` (RF-498): **sin subir `SAVE_VERSION`**, solo `true` booleano cuenta, se guarda enseguida al marcarla. **Probar con un guardado de antes** (formato real, como en `tests/test_old_saves.gd`).
3. **`IntroFlow`** (lógica pura): cuándo se muestra sola (guardado sin la clave, no en el modo de pruebas, archivo válido) y a dónde se va al terminar (nivel 1 si no hay niveles ganados; selección si los hay, RF-500).
4. **`IntroScreen`** (overlay `CanvasLayer`, por código como `EpilogueScreen`): la lámina entera (`KEEP_ASPECT`), la franja de texto abajo con el estilo hierro y bronce, fundido de `fundido_s`, avance por clic/toque, `Espacio`, `Enter`, `→` y por tiempo, **«Omitir»** siempre visible, `Esc` y el «atrás» de Android (todo en `_input`, antes que el resto: el clic final **no** llega a la pantalla de atrás). Una señal `finished`, **una sola vez**. **No sabe a dónde se va después** (P6).
5. **Conectar.** «Jugar» en `main_menu.gd` (abre la intro o va a la selección) y el botón **«Ver la intro»** en la Wiki, solapa Lore (RF-501): al terminar solo cierra el overlay, **no toca el guardado**.
6. **Con las láminas de T241:** sustituir las provisorias, **medir el texto** a 1280 × 720 y en tamaño de celular (dos líneas de 90 caracteres es el peor caso), y **exportar otra vez** (T237): verificar que las láminas entran en el paquete y **anotar el tamaño final de la APK**.
7. **Tests** (los de «Pruebas que T242 tiene que escribir» del plan). **Probar la lógica aparte**, sin cambiar de escena: `IntroFlow`, `IntroData` y `IntroScreen` con un reloj inyectado.
8. **Documentos:** `CHANGELOG.md` (la intro, para quien juega), `README.md`, `ONBOARDING.md` (cómo probarla; cómo forzarla de nuevo borrando `intro_seen` o desde la Wiki), `CONTENIDO.md` (el formato de `intro.json`) y el Resultado en `03-tareas.md`.

## Hecho cuando
La intro funciona en PC y en tamaño de celular, **todos los tests en verde y 0 `SCRIPT ERROR`**, y las builds regeneradas. Resultado honesto (qué se probó y qué no), `CHANGELOG.md`, commit `T242: …` y PR.

## Frenar si
- **No está el OK de Lucas** al guion y a M57 (G6), o contestó una pregunta de M57 distinto de la recomendación (P1: destino al terminar; P2: dónde se vuelve a ver) y el RF no se actualizó.
- **Faltan las láminas** y se necesita una decisión de tamaño o formato que T241 no tomó: avisar en vez de recortar o redimensionar.
- **La intro tumba un test** que asume que «Jugar» va directo a la selección: arreglar el test **solo si la causa es el cambio de RF-498**; si no, frenar.
- **El texto no entra** en la franja con dos líneas de 90 caracteres: no cambiar el texto; **avisar** (es de `guion.md` y de Lucas) o achicar la fuente con un mínimo legible.
