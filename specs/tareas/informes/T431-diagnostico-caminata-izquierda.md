# T431 · Diagnóstico de las caminatas izquierda/derecha

**Revisión visual:** Claude Opus sobre los 18 atlas de movimiento activos, organizados en hojas con cuadros de ~50 px para aproximar la lectura en juego. **Contraste técnico:** Codex, lectura estática de `EnemyVisual`, recursos `.tres` y `Enemy`. Fecha: 2026-10-21. No se editaron recursos de producción ni se ejecutó Godot.

## Hallazgo

Los enemigos con caminata ya tienen atlas con cuatro orientaciones dibujadas por separado. La fila 0 corresponde a derecha y la fila 2 a izquierda (`EnemyVisual.direction_row`); los cuadros progresan por columnas. En los 18 recursos configurados, `flip_when_walking_left = false`, pero `Enemy.is_drawn_mirrored()` solo refleja enemigos sin atlas de caminata/vuelo. Por lo tanto, cambiar esa bandera no arreglaría la fila izquierda ni es una opción segura: podría invertir iluminación y detalles.

La diferencia que mejor explica la percepción de Lucas es de **pose y lectura**, no una animación que se atasca: varias vistas izquierdas giran más hacia cámara y se leen más de frente que el perfil derecho. Opus prioriza para una revisión posterior:

| Prioridad | Personajes | Diferencia visual observada |
|---|---|---|
| 1 | Cargador, Coloso, Tanque, Troll, Ladrón, Chamán y Sanador | La izquierda muestra más cara/pecho hacia cámara; en Chamán y Sanador el bastón queda más al frente. |
| 2 | Jefe y Guardián | Diferencia potencial de vista y anchura; requiere confirmar con silueta medida. |
| Baja | Blindado, Araña, Arañita, Espejo, Ratero, Rápido y Fragmento del Coloso | Las dos orientaciones se leen parejas o la simetría hace que se distingan poco. |

No se encontró un salto evidente entre cuadros en las hojas: Normal, Rápido, Ratero y Fragmento del Coloso alternan las piernas de forma reconocible en ambos sentidos. Cambios de cuernos/cola o visibilidad del caparazón parecen intencionales. La hoja no sirve para juzgar apoyo de pies porque la línea de separación tapa parte de los sprites.

La comparación HTML incluye los cuatro cuadros por orientación de **los 18 atlas**: [`comparison.html`](../../../art/t431-diagnostico/comparison.html). Renderiza recursos activos a 50×50 px y distingue candidatos de baja prioridad; no añade imágenes binarias ni cambia el juego.

## Opciones y costo relativo

1. **Dejar los atlas como están:** costo nulo; válido si en partida los perfiles se leen bien.
2. **Medir antes de dibujar:** tarea chica. Medir contorno, ancho/alto y apoyo por cuadro para los nueve candidatos. La impresión de que los grandotes «engordan» a la izquierda no está confirmada. Un único `walk_art_scale` por enemigo afectaría todas sus orientaciones; para corregir solo una fila habría que agregar transformación por dirección y probarla.
3. **Retocar la pose izquierda de candidatos:** costo medio de arte para 7 atlas prioritarios (cuatro cuadros cada uno), mayor si se suman Jefe y Guardián. Mantener tamaño, apoyo, luz arriba y el perfil del resto; aprobar una hoja antes de reemplazar producción. No hace falta rehacer los 18.
4. **Crear vistas laterales específicas o rehacer ciclos completos:** costo alto; no hay evidencia de que haga falta todavía.

**Recomendación:** medir primero el ancho y la base en resolución fuente; luego pedir una muestra comparativa para un enemigo de prioridad 1. Si Lucas confirma la mejora en tamaño de juego, corregir solo los atlas seleccionados. No espejar automáticamente.

## Límites

La comparación es lectura visual, no análisis de píxeles ni partida grabada. No se verificó la animación en un mapa real ni se midieron anclaje/contorno cuadro por cuadro. Los candidatos describen una diferencia de pose visible en el atlas, no confirman por sí solos que el jugador la perciba como defecto.
