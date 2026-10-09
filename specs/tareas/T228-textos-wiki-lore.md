# T228 · Textos por nivel, pantallas de entrada y victoria, y Lore en la Wiki

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T227 (spec M52 **con el OK de Lucas** a los textos; sin ese OK, no empezar) · **Compuerta:** ninguna propia · **Tamaño:** mediano

## Leer
- La sección **M52** de `specs/01-spec.md` (RF-464 a RF-470 y RF-473), la sección «M52 / T227» de `specs/02-plan-tecnico.md` y **D-089 y D-090**.
- **`specs/11-textos-lore.md`**: de ahí salen los textos, **copiados tal cual** (si Lucas corrigió algo, vale la versión aprobada).
- `scripts/logic/level_file.gd` (`LEVEL_KEYS` y la validación), `scenes/ui/level_select.gd` (`_make_card`), `scenes/ui/end_screen.gd` (`show_victory`), `scenes/game/game.gd` (el inicio de la partida y `restart()`), `scripts/autoload/game_flow.gd` (`start_level`), `scripts/logic/wiki.gd` y `scenes/ui/wiki_screen.gd` (categorías y artículos), y `data/wiki/licencias.json` (ejemplo de artículo).
- `scenes/editor/`: el editor tiene que **conservar** el campo de textos.

## Pasos
1. **Lógica pura primero:** `LevelTexts` (límites de RF-464, mensajes claros como RF-204) y `LoreUnlock`; `"textos"` en `LEVEL_KEYS` y en `LevelData`; el editor lo conserva. Tests.
2. **Tarjeta (RF-465):** el lugar bajo el nombre, solo en niveles desbloqueados; el tamaño de la tarjeta no cambia.
3. **Victoria (RF-467):** el texto bajo las estrellas, sin romper la entrada de iniciales ni los récords.
4. **Cartel de entrada (RF-466):** `LevelIntro`, **pausa** la partida mientras está abierto, se omite con un toque, `Espacio`, `Enter` o `Esc` (`Esc` lo recibe antes que el menú de pausa), **no** se abre al `restart()`, ni en el modo de pruebas, ni probando desde el editor, ni en los modos oficiales (RF-468). En el celular, que entre en pantalla.
5. **Wiki Lore (RF-469 y RF-470):** el proveedor nuevo, `data/wiki/lore/`, la clave `"desbloqueo"`, el estado «cerrado» con *«Se abre al ganar el nivel N.»* y la cuenta «Lore n/10» en la solapa. La Guía **no** ve la subcarpeta. Tests de desbloqueo con un guardado de prueba (`user://test_*.json`).
6. **Cargar los textos aprobados** en los niveles 1 a 10 (`"textos"`) y los **10 artículos** de `11-textos-lore.md` §4 en `data/wiki/lore/`. Los del 11 al 15 los cargan las tareas de cada nivel. Un test comprueba que los niveles oficiales cumplen los límites.
7. **Capturas:** tarjeta, cartel, victoria y Wiki Lore, en PC (1280 × 720) y en tamaño de celular.

## Hecho cuando
Los textos se ven donde dice el RF, se omiten con un toque, el cartel no vuelve al reintentar, los modos oficiales no muestran nada, y la Wiki Lore se abre al ganar. Todos los tests en verde y sin `SCRIPT ERROR`. Resultado (con lo que **no** se pudo probar, en especial el celular), `CHANGELOG.md` y `CONTENIDO.md`, commit y PR.

## Frenar si
- Los textos de `11-textos-lore.md` no tienen el OK de Lucas anotado.
- Una tarjeta no alcanza para 32 caracteres: bajar el límite es un cambio de RF-464 (📜); avisar.
- El editor reconstruye el nivel y pierde `"textos"`: hace falta tocar cómo se serializa y puede ser más que un ajuste.
