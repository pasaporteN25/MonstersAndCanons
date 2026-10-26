# T518 · Propuestas para la pantalla de niveles

Estas seis imágenes son maquetas de composición para revisar el rediseño de la pantalla completa de niveles, tanto en PC como en celular. Se generaron a partir de las capturas vigentes de T515 (mapa) y T501 (tarjetas), que se mantienen sin redibujar.

## Opciones

- **Mesa de mando:** navegación y selector de vista en una columna lateral; información del nivel seleccionado en una ficha persistente a la derecha.
- **Bastidor de campaña:** título y progreso arriba, modos y selector de vista en una sola barra, mapa o tarjetas como área principal y selección/acción en un pie contextual. Es la recomendación de diseño: deja la navegación en un orden estable y reserva el pie para la decisión de jugar.
- **Lienzo primero:** mapa amplio con modos y acciones superpuestos para priorizar el territorio.

Las versiones para celular reorganizan los mismos controles en vertical y reservan el botón «Jugar» para una zona fácil de alcanzar. Son referencias visuales, no medidas finales de Godot ni pruebas de interacción/tacto.

## Alcance

Se revisan jerarquía, distribución, textos y lenguaje visual de toda la pantalla. El mapa, las tarjetas, las reglas de campaña, el progreso y la navegación existentes no se rediseñan funcionalmente. La implementación queda para una tarea posterior, después de la elección de Lucas y de actualizar la spec con los criterios aprobados.

## Fuentes y reproducción

`Capturas/T515-pc-1280x720-12-elegido.png` y `Capturas/T501-tarjetas-pc-1280x720-estados.png` son las referencias. `sources/generate_mockups.py` genera las seis maquetas `Capturas/T518-*.png` con Pillow.
