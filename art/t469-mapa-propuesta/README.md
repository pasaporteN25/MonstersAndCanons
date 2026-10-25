# T469 · Muestra del mapa planetario e insignias

Maqueta artística editable para revisar la geografía de campaña y los tres estados de la insignia. Conserva la presentación visual del mapa de T428: mar, contornos, relieve, paleta y lenguaje de sus marcadores. La captura de PC conserva la pantalla de T428 y reemplaza solo el rectángulo del mapa. No se integra al juego.

## Archivos

- `mapa.svg`, `mapa-opcion-b.svg`, `mapa-opcion-c.svg`: tres propuestas editables con el mismo mar, relieve, contornos, paleta, biomas, recorrido, insignias y marcadores. Solo varía la silueta costera: A continua, B con macizo occidental y bahías, C con penínsulas y un istmo central. El progreso es ilustrativo; no se agrega un emblema canónico.
- `index.html`: visor PC/celular y comparación entre mapa móvil desplazable y mapa comprimido. La segunda opción se descarta porque encoge los marcadores.
- `render_captures.py`: genera las capturas PNG con Godot 4 y Pillow.
- [`Capturas/T469-geografia-A.png`](../../Capturas/T469-geografia-A.png), [`Capturas/T469-geografia-B.png`](../../Capturas/T469-geografia-B.png), [`Capturas/T469-geografia-C.png`](../../Capturas/T469-geografia-C.png): comparación de las tres costas sobre la captura de T428, conservando su presentación. [`Capturas/t469-mapa-celular.png`](../../Capturas/t469-mapa-celular.png): recorte de revisión celular.

## Revisión

Las capturas muestran las tres alternativas sobre la misma pantalla de PC de T428: solo cambia la silueta de la isla. En celular, el lienzo se desplaza a escala 1:1: cada círculo mide 58 px lógicos; selección, ficha y acción «Jugar» quedan fuera del área desplazable. El ajuste compacto se presenta en el visor como comparación descartada, no como solución.

Las siete manchas son estudios de ubicación y lectura de los temas ya canónicos (`pradera`, `bosque`, `desierto`, `pantano`, `nieve`, `ruinas`, `volcán`); no fijan su arte, distribución final ni la asignación definitiva de niveles. Un velo gris de borde orgánico representa tierras sin conquistar después del ejemplo de las zonas 1 y 2; no define límites jugables. Las coordenadas del aterrizaje, las zonas y el recorrido son propuestas para que Lucas las revise. La vista celular es una maqueta de revisión con el mismo lenguaje visual y un mapa desplazable.

La geografía, contornos y símbolos se dibujaron en el SVG de esta muestra. Las capturas se crean con Godot 4.7.2 para rasterizar el SVG, Pillow y DejaVu Sans instalado en el sistema. Las capturas no son assets del producto.

Esta muestra no está aprobada. Antes de integrar cualquier cambio al mapa ejecutable, Lucas decide si aprueba la costa, el recorrido, los biomas, cada estado de insignia y la composición móvil, o pide ajustes. No se cambió lógica, datos de niveles, canon, reglas, balance ni arte runtime.
