# T426 · Selector de niveles y fondos de muestra

## Capturas del selector

- `captura_1280x720.png`: ventana y viewport de 1280×720.
- `captura_1920x1080.png`: ventana de 1920×1080; el viewport lógico conserva 1280×720 y escala la interfaz.

Las capturas usan un guardado temporal de prueba: niveles 1–14 completados (el 1 con tres estrellas y los demás con dos), nivel 15 disponible. No se modificó el guardado de juego.

## Propuesta de fondos temáticos

- `fondos-tematicos.svg`: fuente vectorial editable, con ejemplos de pradera, bosque, ruinas, desierto y nieve.

La dirección toma como referencia los temas actuales de `scripts/logic/map_themes.gd`. Las formas y paletas son una muestra original de baja fidelidad para discutir la dirección; no son assets finales ni se integran a la UI. Sin imágenes o fuentes externas. La aprobación de Lucas sigue siendo necesaria antes de llevar fondos a producción.

## Implementación

En escritorio, las 15 tarjetas entran en tres filas. Se quitó el número de oleadas y las torres disponibles se dibujan sin cajas individuales dentro del marco de cada tarjeta. El selector móvil conserva la distribución y los tamaños anteriores.
