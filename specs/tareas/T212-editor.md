# T212 · Editor: removibles, extracción, ruinas y torres del mapa

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T203, T206, T210 y T211 · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- RF-266 (el editor y la leyenda), §10.3 (el editor), RF-392 (guardar en modos) y los RF de M50 sobre el editor, si T205 los escribió. Si no los escribió, **frenar**: falta un RF del editor.
- `scenes/editor/map_editor.gd`, `editor_panel.gd`, `settings_panel.gd`, `map_view.gd` y `scripts/logic/level_draft.gd`. Los tests: `grep -l "editor\|LevelDraft" tests/*.gd`.

## Objetivo
Que un mapa con removibles, extracción, ruinas con hallazgo y lista de torres se pueda **crear y editar sin tocar el JSON a mano**, para que T222 a T234 (los niveles) se armen en el editor o, al menos, se revisen ahí.

## Pasos
1. Herramientas para pintar: árbol removible, roca removible, escombro (con un campo de hallazgo **solo** en mapas de campaña; en mapas de la comunidad o de modos queda deshabilitado, Q-31), mina y bosque explotable. Por debajo, crean o reusan letras de la leyenda (máximo 10, RF-262): avisar si se pasa del límite.
2. El panel de Ajustes:
   - "Torres del mapa", con casillas para marcar cuáles ofrece (T203);
   - "Demoledora disponible".
3. "Probar" el mapa desde el editor (RF-217) funciona con los sistemas nuevos.
4. Tests sobre `LevelDraft`:
   - pintar y borrar removibles;
   - la ida y vuelta al JSON conserva todo;
   - el límite de letras;
   - el hallazgo deshabilitado fuera de la campaña.

## Hecho cuando
- Se puede reproducir en el editor el mapa de ejemplo de T206 y T210 y queda idéntico al JSON (test de ida y vuelta).
- Todos los tests en verde. Resultado, `CHANGELOG.md` y `CONTENIDO.md`, commit y PR.
