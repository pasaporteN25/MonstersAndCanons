# T211 · Colecciones por tecnología y hallazgos en ruinas

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**. Hay que cuidar mucho la compatibilidad del guardado.
- **Depende de:** T207 · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- Los RF de M50 de **colecciones**, su D, y Q-25 a Q-27 y Q-31.
- RF-358 a RF-362 (los avances actuales y su confirmación).
- `scripts/logic/collectible_run.gd`, `scripts/autoload/save_manager.gd` (`_collections`, `collect_source`, `collection_complete`, `_read_collections`), `data/progression.json`, `scenes/game/game.gd` (`grep -n "collect\|Collectible" scenes/game/game.gd`), la barra de la colección en `scenes/game/hud.gd` (RF-362) y `scripts/data/tower_data.gd` (`required_collection`).
- Los tests actuales de la colección: `grep -l "collect" tests/*.gd`. **Todos tienen que seguir pasando sin cambiarlos**, salvo un ajuste justificado y anotado.

## Objetivo
1. `progression.json` admite **varias colecciones**. `technology` (los 5 avances por portador, niveles 1 a 5) sigue **idéntica**. Se suma una colección **por ruinas** (`disruptor`, con 3 piezas) cuyas fuentes son removibles con `hallazgo`.
2. Al terminar la demolición de una ruina con hallazgo **pendiente**, la pieza queda **recogida**. Se **confirma** con la regla de RF-359 y se guarda al terminar la partida, como hoy.
3. Si la pieza ya estaba recuperada, el panel lo dice **antes** de demoler y la recompensa es la que fijó Q-27.
4. Solo en la campaña: en los modos, la comunidad, el editor y las pruebas no se generan piezas (Q-31).
5. La barra (RF-362) muestra la colección relevante del mapa. La Wiki muestra cada colección con su progreso y qué desbloquea.

## Pasos
1. Generalizar `CollectibleRun.definitions` sin cambiar el comportamiento de `technology`. El formato nuevo del JSON es el que fijó T205.
2. `SaveManager`: guardar las piezas como **ids únicos** dentro de `_collections[colección]`. Un guardado viejo (versión 1, solo `technology`) carga igual. Test con un JSON viejo literal.
3. El flujo de la partida: pieza recogida, oleada completada, confirmada; derrota antes de confirmar, se pierde; abandonar o reintentar, se descarta (como hoy).
4. `required_collection = &"disruptor"` en la Disruptora queda para T217. Acá se prueba con una torre de test.
5. Tests:
   - las dos colecciones conviven;
   - el guardado viejo carga;
   - repetir una ruina no duplica;
   - confirmación y pérdida;
   - fuera de la campaña no se generan piezas;
   - completar la colección habilita la torre de test.

## Hecho cuando
- Los tests de M37 y M38 siguen en verde sin cambios.
- Un mapa de ejemplo de campaña de prueba (en `user://`, no en `data/`) entrega una pieza al demoler, la confirma y la guarda.
- Todos los tests en verde. Resultado, `CHANGELOG.md`, commit y PR.

## Frenar si
- Mantener `technology` idéntica obliga a cambiar el formato del guardado de una forma **no aditiva**.
