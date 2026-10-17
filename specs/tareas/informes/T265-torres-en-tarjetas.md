# T265 · Torres disponibles en tarjetas de nivel

> **Estado:** propuesta visual lista para G7; la decisión de Lucas queda pendiente. Informe del 2026-10-16. Se conservaron las torres disponibles de cada nivel; no se cambió la interfaz implementada del juego.

## Resumen

Se compararon tres tratamientos para el bloque de torres dentro de las tarjetas reales de la campaña: **Arsenal**, **Insignias** e **Inventario**. Las capturas de antes y después muestran los niveles 1 y 12 en 1280 × 720 y 1600 × 720 (20:9). En esta muestra, el nivel 1 ofrece 8 torres y el 12 ofrece 10; el segundo caso ocupa dos filas. En todos los prototipos se ven todos los íconos y queda espacio antes de las estrellas y el estado de la tarjeta.

**Recomendación para Lucas: Insignias.** Enmarca cada silueta en una medalla de hierro con borde bronce, agrupada sobre una placa discreta. Destaca el arsenal sin competir con nombre, lugar, estrellas ni estado, y conversa mejor con los materiales hierro/bronce de las torres y placas del juego. La elección final de G7 sigue pendiente de Lucas.

## Comparación

| Vista | Antes | Arsenal | Insignias | Inventario |
|---|---|---|---|---|
| Nivel 1 · 1280 × 720 | [captura](../../art/t265-torres-en-tarjetas/before/nivel_01_1280x720_actual.png) | [captura](../../art/t265-torres-en-tarjetas/after/arsenal/nivel_01_1280x720_arsenal.png) | [captura](../../art/t265-torres-en-tarjetas/after/insignias/nivel_01_1280x720_insignias.png) | [captura](../../art/t265-torres-en-tarjetas/after/inventario/nivel_01_1280x720_inventario.png) |
| Nivel 12 · 1280 × 720 | [captura](../../art/t265-torres-en-tarjetas/before/nivel_12_1280x720_actual.png) | [captura](../../art/t265-torres-en-tarjetas/after/arsenal/nivel_12_1280x720_arsenal.png) | [captura](../../art/t265-torres-en-tarjetas/after/insignias/nivel_12_1280x720_insignias.png) | [captura](../../art/t265-torres-en-tarjetas/after/inventario/nivel_12_1280x720_inventario.png) |
| Nivel 1 · 20:9 | [captura](../../art/t265-torres-en-tarjetas/before/nivel_01_20x9_actual.png) | [captura](../../art/t265-torres-en-tarjetas/after/arsenal/nivel_01_20x9_arsenal.png) | [captura](../../art/t265-torres-en-tarjetas/after/insignias/nivel_01_20x9_insignias.png) | [captura](../../art/t265-torres-en-tarjetas/after/inventario/nivel_01_20x9_inventario.png) |
| Nivel 12 · 20:9 | [captura](../../art/t265-torres-en-tarjetas/before/nivel_12_20x9_actual.png) | [captura](../../art/t265-torres-en-tarjetas/after/arsenal/nivel_12_20x9_arsenal.png) | [captura](../../art/t265-torres-en-tarjetas/after/insignias/nivel_12_20x9_insignias.png) | [captura](../../art/t265-torres-en-tarjetas/after/inventario/nivel_12_20x9_inventario.png) |

## Las tres variantes

### A · Arsenal

Una placa de hierro oscura con título y cantidad en bronce; cada torre va en una casilla cuadrada sutil. Conserva íconos de 22 px y la distribución actual de hasta ocho por fila. Es el cambio más contenido: ordena el conjunto y evita que las siluetas parezcan flotar, aunque se diferencia menos de una rejilla de botones.

### B · Insignias — recomendada

La placa y el título mantienen el mismo lugar; cada torre queda dentro de un aro redondeado de bronce. La lista se lee como colección de piezas disponibles y el conteo deja claro que la tarjeta resume el arsenal del nivel. Mantiene íconos de 22 px y hasta dos filas, sin introducir controles nuevos.

### C · Inventario

Placa de hierro azulado, título arriba y una rejilla de seis columnas con más separación. En nivel 12 los diez íconos ocupan dos filas; el bloque gana altura, así que la placa termina en y=145, antes de las estrellas que empiezan en y=158. Reduce los íconos a 20 px y muestra el listado con más orden, pero es la opción más densa y los dibujos quedan algo menores.

## Lectura visual y tamaños

- **Jerarquía:** número, nombre y lugar siguen arriba; el arsenal queda debajo; estrellas y resultado conservan su franja inferior. El rótulo de cada propuesta mide 11 px y los íconos, entre 20 y 22 px.
- **Pocas torres:** nivel 1 ocupa una fila; las tres variantes dejan aire dentro del bloque y no agregan una segunda fila vacía.
- **Muchas torres:** nivel 12 ocupa dos filas. Los diez íconos caben completos; la variante Inventario separa las filas y reserva un bloque de 58 px para su rótulo y contenido. Ninguna pisa lugar, estrellas o estado, ni se corta contra los bordes de la tarjeta.
- **20:9:** el marco de captura es 1600 × 720. El proyecto conserva su lienzo de 1280 × 720 y centra la escena con 160 px negros a cada lado, igual que `stretch/aspect = keep`; las tarjetas no se estiran ni se recortan. Es una simulación en escritorio, no una prueba táctil en un celular.
- La captura actual ya muestra íconos y su indicador naranja de torre nueva; en las propuestas se conserva ese indicador y la información emergente que acompaña a cada torre. Los nombres no se imprimen junto a los íconos porque no caben con legibilidad en la tarjeta actual.

## Método y límites

Las capturas salen de `scenes/ui/level_select.tscn` corriendo con OpenGL en Godot 4.7.2. La herramienta `tools/t265/capture_t265.gd` carga la escena con `load()` y cambia estilos solo en memoria; compila con `--check-only`. Para que el nivel 12 aparezca abierto y se puedan revisar sus colores, se usó `user://test_t265_capture.json`, separado del guardado normal, y luego se restauró la ruta y el estado originales. El tamaño 20:9 agrega el marco negro alrededor del lienzo lógico, sin deformarlo.

No se probaron la lectura física de los íconos en un celular, el tacto real, la muesca ni la diferencia de densidad de pantalla; T262 ya advierte que en un 20:9 el área central sigue siendo el lienzo 16:9. Tampoco se implementó ninguna variante en `scenes/ui/level_select.gd`.

## Decisión pendiente de Lucas

Elegir en G7 una variante (A, B o C), pedir una mezcla concreta de rasgos, o dejar el diseño actual. **No se da por aprobada la recomendación ni se implementa hasta esa decisión y la spec correspondiente.**
