# T206 · Removibles: formato, validación, mapa y revisor de niveles

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T205 (con G3) · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- **RF-398 a RF-403** (removibles y extracción: el formato), D-080 y la sección M50 de `02-plan-tecnico.md` (datos, clases nuevas, `ObstacleSpec` y la tabla de archivos de T206). Escritos en T205.
- RF-262 a RF-265.
- `scripts/logic/level_file.gd` (`LEGEND_KEYS`, `_read_legend`), `scripts/logic/map_grid.gd` (`parse`, `cell_type`, `_read`), `scripts/data/level_data.gd`, `scenes/levels/level_decor.gd` (cómo se dibuja la leyenda) y `tools/check_level.gd`.
- Los tests de la leyenda: `grep -l "leyenda" tests/*.gd`.

## Objetivo
Que un nivel pueda **declarar** removibles y puntos de extracción y que el juego los **lea, valide y dibuje** como casillas bloqueadas. **Todavía no se pueden demoler:** eso es T207.

## Pasos
1. `data/obstaculos.json` con la estructura y los valores iniciales del plan M50 (RF-398), y `ObstacleCatalog`, un lector **puro** y testeable que valide claves y tipos. Un archivo ilegible deja el registro y el juego sigue sin removibles.
2. `level_file.gd`: aceptar `removible` y `extraccion` dentro de cada letra de la leyenda (`dibujo` pasa a ser opcional en ese caso, RF-399), validarlos con los errores y avisos de RF-402 en castellano, aceptar el campo `"demoledora"` del nivel (RF-411) y dejar en `LevelData.obstacles` una lista de `ObstacleSpec`: celda, clase y valores ya resueltos (los de la clase más los de la letra). Sumar `LevelData.uses_resources()` (RF-416).
3. `map_grid.gd`: un removible **intacto** es `BLOCKED`. Exponer una forma de **despejar** una celda (pasa a pasto construible) **sin recalcular recorridos**, porque nunca es camino. Test: despejar no cambia `routes`.
4. Dibujo provisional en `level_decor.gd`: el dibujo de la leyenda más una **marca de removible** (por ejemplo, un pequeño rombo ámbar en la esquina). Los dibujos nuevos de la lista cerrada (`escombro`, `mina`, `bosque_explotable`) van con figuras simples. Seguir la guía §4.
5. `check_level.gd`: en el mapa impreso, marcar los removibles y los puntos de extracción con su letra, y sumar un resumen ("3 removibles, 1 mina").
6. El editor tiene que **conservar** los campos nuevos al abrir y guardar (como RF-266). Editarlos es T212.
7. Tests:
   - formato válido, claves mal escritas y clase inexistente;
   - un removible sobre camino es un error;
   - los recorridos no cambian al despejar;
   - el editor conserva los campos;
   - los 9 niveles actuales leen igual.

## Hecho cuando
- Un mapa de ejemplo (`tools/ejemplos/mapa_removibles.json`) pasa `check_level` y se ve en el juego con sus marcas.
- Todos los tests en verde, sin `SCRIPT ERROR`.
- `CONTENIDO.md` está al día.
- Resultado, commit y PR.

## Frenar si
- Despejar una celda obliga a recalcular recorridos o cambia algún recorrido. No debería: revisar el RF.
