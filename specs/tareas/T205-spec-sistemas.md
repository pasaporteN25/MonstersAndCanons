# T205 · 📜 🚦 G3 · Spec de removibles, demolición, demoledora, recursos, extracción y colecciones

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (ideal: Opus). Es la tarea que más condiciona al resto.
- **Depende de:** T200 (bloques B, C y D del cuestionario respondidos) y T203 (para tomar los números siguientes) · **Compuerta:** **G3**, Lucas da el OK a la spec antes de que empiece T206 · **Tamaño:** mediano · 📜

## Leer
- `specs/07-lore-y-cierre-v1.md` §5 a §8 y §12, y las **respuestas de Lucas** en `specs/09-decisiones-pendientes-v1.md` (Q-08 a Q-27 y Q-31).
- `specs/01-spec.md`: RF-200 a RF-207 (formato y validación), RF-260 a RF-267 (tema y leyenda), RF-358 a RF-362 (avances, confirmación, Mecánico y barra) y RF-300.
- `specs/02-plan-tecnico.md`: las secciones de M15 (leyenda) y M37 (colección), para mantener el estilo.
- El código: `scripts/logic/level_file.gd` (`_read_legend`), `scripts/logic/map_grid.gd`, `scripts/logic/collectible_run.gd`, `scripts/autoload/save_manager.gd` (`_collections`), `data/progression.json`, `scenes/game/level_session.gd` y `scripts/data/tower_data.gd`.

## Objetivo
Convertir las respuestas de Lucas en `RF` con criterio Dado / Cuando / Entonces, en `D` con el porqué y las alternativas descartadas, y en un **plan técnico** lo bastante concreto como para que un Sonnet en esfuerzo medio implemente T206 a T213 **sin tomar decisiones de diseño**.

## Qué tiene que quedar escrito
Una sección nueva en `01-spec.md`, "M50 · Infraestructura: demolición, recursos y hallazgos", con subsecciones:

1. **Removibles y permanentes.** Formato **propuesto** (ajustarlo si hace falta, siempre compatible con RF-262):
   ```json
   "leyenda": {
     "t": {"dibujo": "arbol", "removible": {"clase": "arbol"}},
     "r": {"dibujo": "roca", "removible": {"clase": "roca", "recursos": 1}},
     "u": {"dibujo": "escombro", "removible": {"clase": "escombro", "hallazgo": "disruptor"}},
     "m": {"dibujo": "mina", "extraccion": {"clase": "mina"}}
   }
   ```
   - Los valores por clase (costo, tiempo, recursos, reserva, producción por oleada) van en **un archivo de datos** (propuesta: `data/obstaculos.json`). La leyenda del nivel puede sobrescribir cada valor.
   - Un removible **intacto** es una casilla bloqueada; **despejado** pasa a ser pasto construible. **Nunca es camino**: los recorridos no cambian (RF-264).
   - Validación con mensajes claros (RF-204). Hacen falta dibujos nuevos (`escombro`, `mina`, `bosque_explotable`): sumarlos a la lista cerrada de RF-263 con su dibujo provisional.
2. **Demolición directa** (Q-09 a Q-12 y Q-14 a Q-17): selección, panel, cobro, tiempo de juego (respeta pausa y velocidad), una sola a la vez, cancelación, fin de partida y entrega de la recompensa **una sola vez por partida**.
3. **Demoledora** (Q-08 y Q-13): habilitada por el nivel (propuesta: `"demoledora": true`), comprada en el panel "Infraestructura", sin venta, y precio con descuento sobre cada demolición siguiente.
4. **Recursos locales** (Q-18 y Q-21 a Q-24): un contador en el HUD **solo si el nivel usa recursos**. `TowerData` con un costo opcional en recursos (propuesta: `resource_cost`, 0 por defecto). Construir cobra los dos, vender devuelve los dos con `sell_refund_percent` (redondeando hacia abajo) y las mejoras no cuestan recursos.
5. **Extracción** (Q-19 y Q-20): se habilita con oro, produce al **completar** cada oleada hasta agotar la reserva, la reserva se ve, y no produce por esperar ni en el modo de pruebas sin oleadas.
6. **Colecciones por tecnología** (Q-25 a Q-27 y Q-31):
   - `progression.json` admite **varias colecciones**. Cada una tiene su lista de fuentes únicas y la torre que desbloquea vía `required_collection`.
   - Las piezas salen de un removible con `hallazgo` y su **id único** (propuesta: `<colección>:<nivel>`).
   - Confirmación como RF-359.
   - **Compatibilidad:** la colección `technology` actual y los guardados de la versión 1 siguen funcionando igual (guardado aditivo).
   - Las piezas solo salen en la campaña.
   - La barra (RF-362) muestra la colección del mapa actual.
7. **Regla de oro del 07 §7:** un RF que diga *"Dado cualquier nivel de campaña con recursos, cuando el bot juega la estrategia `sin_recursos` con N semillas, entonces gana en al menos M"*. Fijar N y M (propuesta: 5 y 4).
8. **Lo que no incluye:** atajos, rutas dinámicas, cola de órdenes, máquina que se mueve, mantenimiento, recursos entre niveles y sorteos.

Además:
- En `04-decisiones.md`, una `D` por bloque (demolición, demoledora, recursos, extracción y colecciones), que cite la pregunta del 09 y la fecha de la respuesta de Lucas.
- En `02-plan-tecnico.md`, la sección "M50", con:
  - **las clases nuevas** (propuesta):
    - `ObstacleField` (lógica pura, `RefCounted`): estado de cada removible y punto de extracción.
    - `DemolitionJob`: un trabajo activo, reloj y cancelación.
    - `ResourceStock` dentro de `LevelSession`, con las señales `resources_changed`.
    - `CollectionDefinitions`: generalizar `CollectibleRun.definitions`.
  - **qué archivos toca cada tarea**, de T206 a T213;
  - **los estados visuales** que tiene que dibujar Codex (T219 a T221): intacto, marcado como removible, en trabajo, despejado, mina activa, mina agotada y reserva legible.
- En `03-tareas.md`, la entrada M50 con T205 a T214 (copiar los títulos del plan 08).
- En `CONTENIDO.md`, el formato nuevo de la leyenda, con un ejemplo.

## Hecho cuando
- Spec, decisiones, plan y tareas escritos, **sin código**.
- Lucas dio el OK (G3). Anotarlo en la entrada de T205 con la fecha.
- Las fichas T206 a T214 no contradicen la spec. Si algo cambió, **editar esas fichas** en el mismo commit.

## Frenar si
- Una respuesta de Lucas en el 09 es ambigua o falta: preguntar y no elegir.
