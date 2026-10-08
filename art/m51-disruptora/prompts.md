# Prompts normalizados · Disruptora

Herramienta: `image_gen` integrado. Se generó una única imagen con fondo RGBA transparente y tres variantes en columnas; el empaquetador conserva la fuente y solo recorta, escala y acomoda sus píxeles.

## Hoja de concepto

Crear una hoja limpia con tres variantes del mismo mecanismo para una torre de defensa fantástica, separadas en tres columnas iguales. Objeto completo en vista isométrica elevada SE, sin base de juego. La variante izquierda tiene una columna simétrica de anillos horizontales apilados de cobre y bronce, más anchos hacia arriba, y un disco emisor plano arriba. La variante central conserva la silueta y agrega un anillo y un disco superior más ancho. La variante derecha agrega dos anillos y un disco pequeño sobre el emisor. Render de juego 3D pintado, materiales pulidos con facetas grandes, luz arriba a la izquierda. Eje y soportes de hierro oscuro; cristal claro; energía blanco azulada `#DCEBFF` con borde `#7FA8FF`. Sin esfera, brazo lateral, cañón, plataforma, suelo, sombra, fondo, texto ni marca de agua. Sin violeta ni amarillo. Transparencia real y cuerpos completos, centrados y de tamaño parejo.

## Tratamiento de fuente

La herramienta devolvió una hoja RGBA de 1254 × 1254 px. `pack.gd` recorta una columna por variante según sus píxeles opacos, normaliza la caja a 128 × 128 y repite la vista SE en las ocho celdas del atlas, porque la Disruptora casi no gira. El empaquetador no repinta el diseño. El aro de pulso y el ícono se dibujan por píxel en el mismo script para conservar transparencia y formas limpias a su escala de uso.
