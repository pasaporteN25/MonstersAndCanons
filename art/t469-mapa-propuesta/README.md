# T469 · Muestra del mapa planetario e insignias

Maqueta artística editable para revisar la geografía de campaña y los tres estados de la insignia. Conserva la presentación visual del mapa de T428: mar, contornos, relieve, paleta y lenguaje de sus marcadores. La captura de PC conserva la pantalla de T428 y reemplaza solo el rectángulo del mapa. No se integra al juego.

## Archivos

- `mapa.svg`: propuesta editable de costa, siete zonas temáticas conceptuales, recorrido y 15 marcadores. El progreso de los marcadores es solo un ejemplo. El jugador, la división jugador/rebelde y el candado usan colores y formas; no se agrega un emblema canónico.
- `index.html`: visor PC/celular y comparación entre mapa móvil desplazable y mapa comprimido. La segunda opción se descarta porque encoge los marcadores.
- `render_captures.py`: genera las capturas PNG con Godot 4 y Pillow.
- [`Capturas/t469-mapa-pc.png`](../../Capturas/t469-mapa-pc.png), [`Capturas/t469-mapa-celular.png`](../../Capturas/t469-mapa-celular.png): capturas para la revisión/PR. Las fuentes SVG se rasterizan desde el mismo archivo.

## Revisión

Las capturas muestran la PC con el mapa completo, y el celular con el lienzo desplazable a escala 1:1: cada círculo mide 58 px lógicos; selección, ficha y acción «Jugar» quedan fuera del área desplazable. El ajuste compacto se presenta en el visor como comparación descartada, no como solución.

Las siete manchas son estudios de ubicación y lectura de los temas ya canónicos (`pradera`, `bosque`, `desierto`, `pantano`, `nieve`, `ruinas`, `volcán`); no fijan su arte, distribución final ni la asignación definitiva de niveles. Un velo gris de borde orgánico representa tierras sin conquistar después del ejemplo de las zonas 1 y 2; no define límites jugables. Las coordenadas del aterrizaje, las zonas y el recorrido son propuestas para que Lucas las revise. La vista celular es una maqueta de revisión con el mismo lenguaje visual y un mapa desplazable.

La geografía, contornos y símbolos se dibujaron en el SVG de esta muestra. Las capturas se crean con Godot 4.7.2 para rasterizar el SVG, Pillow y DejaVu Sans instalado en el sistema. Las capturas no son assets del producto.

Esta muestra no está aprobada. Antes de integrar cualquier cambio al mapa ejecutable, Lucas decide si aprueba la costa, el recorrido, los biomas, cada estado de insignia y la composición móvil, o pide ajustes. No se cambió lógica, datos de niveles, canon, reglas, balance ni arte runtime.
