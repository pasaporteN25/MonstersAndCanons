# T228 · Textos por nivel, pantallas de entrada y victoria, y Lore en la Wiki

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T227 (aprobada) · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- La sección M52 de la spec y del plan (T227).
- `scripts/logic/level_file.gd` (`LEVEL_KEYS` y la validación), `scenes/ui/level_select.gd` (tarjetas), `scenes/ui/end_screen.gd` (victoria), `scenes/game/game.gd` (el inicio de la partida), `scripts/logic/wiki.gd` y `scenes/ui/wiki_screen.gd` (categorías y artículos), y `data/wiki/licencias.json` (ejemplo de artículo).
- `scenes/editor/`: el editor tiene que **conservar** el campo de textos.

## Pasos
1. Leer y validar el campo de textos (con mensajes claros, como RF-204) y conservarlo en el editor. Tests.
2. Lugar en la tarjeta de selección, entrada al empezar (omitible, que no bloquee la cuenta regresiva más de lo que diga el RF) y victoria en `end_screen`. En el celular, que entre en pantallas chicas.
3. Categoría Lore en la Wiki, con desbloqueo por nivel ganado y estado "bloqueado" como el del bestiario. Tests de desbloqueo con un guardado de prueba.
4. Cargar los **textos aprobados en T227**, copiados tal cual, en los JSON de los niveles 1 a 10 y en `data/wiki/lore/`. Los del 11 al 15 los agregan las tareas de cada nivel.
5. Capturas: tarjeta, entrada, victoria y Wiki Lore, en PC y en tamaño de celular.

## Hecho cuando
Los textos se ven donde dice el RF, se pueden omitir y la Wiki Lore se desbloquea. Todos los tests en verde. Resultado, `CHANGELOG.md` y `CONTENIDO.md`, commit y PR.
