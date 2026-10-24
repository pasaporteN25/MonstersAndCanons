# T469 · Muestra del mapa planetario e insignias

Maqueta artística editable para revisar la geografía de campaña y los tres estados de la insignia. Parte del marco, el mar, el relieve, la paleta y el aterrizaje del mapa aplicado por T428, presentado originalmente en `art/t427-mapa-propuesta/`. No reemplaza esa muestra aprobada ni se integra al juego.

## Archivos

- `mapa.svg`: propuesta editable de costa, siete zonas temáticas conceptuales, recorrido y 15 marcadores. El progreso de los marcadores es solo un ejemplo. El jugador, la división jugador/rebelde y el candado usan colores y formas; no se agrega un emblema canónico.
- `index.html`: visor PC/celular y comparación entre mapa móvil desplazable y mapa comprimido. La segunda opción se descarta porque encoge los marcadores.
- `render_captures.py`: genera las capturas PNG con Godot 4 y Pillow.
- [`Capturas/t469-mapa-pc.png`](../../Capturas/t469-mapa-pc.png), [`Capturas/t469-mapa-celular.png`](../../Capturas/t469-mapa-celular.png): capturas para la revisión/PR. Las fuentes SVG se rasterizan desde el mismo archivo.

## Revisión

Las capturas muestran la PC con el mapa completo, y el celular con el lienzo desplazable a escala 1:1: cada círculo mide 58 px lógicos; selección, ficha y acción «Jugar» quedan fuera del área desplazable. El ajuste compacto se presenta en el visor como comparación descartada, no como solución.

Las siete manchas son estudios de ubicación y lectura de los temas ya canónicos (`pradera`, `bosque`, `desierto`, `pantano`, `nieve`, `ruinas`, `volcán`); no fijan su arte, distribución final ni la asignación definitiva de niveles. Un velo gris de borde orgánico representa tierras sin conquistar después del ejemplo de las zonas 1 y 2; no define límites jugables. Las coordenadas del aterrizaje, las zonas y el recorrido son propuestas para que Lucas las revise.

No se usaron imágenes ni fuentes externas. La captura se creó con Godot 4.7.2 para rasterizar el SVG, Pillow y DejaVu Sans instalado en el sistema. Pesos: `mapa.svg` **12.260 bytes**; `index.html` **6.400 bytes**; captura PC **160.363 bytes**; captura celular **66.606 bytes**. Las capturas no son assets del producto.

Esta muestra no está aprobada. Antes de integrar cualquier cambio al mapa ejecutable, Lucas decide si aprueba la costa, el recorrido, los biomas, cada estado de insignia y la composición móvil, o pide ajustes. No se cambió lógica, datos de niveles, canon, reglas, balance ni arte runtime.
