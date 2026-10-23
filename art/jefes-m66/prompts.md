# Prompts normalizados — T367 / M66

Estas instrucciones fijan el resultado visual que implementa `sources/render_sample.py`. La muestra actual se dibujó con geometría nativa en Pillow; no se usó una imagen generada ni se reemplazó ningún original del juego.

## Destello neutral de aparición

Crear un efecto de un solo uso, visto en perspectiva ortográfica elevada como el mapa de *Monsters & Canons*. Un impacto desde el suelo anuncia que llegó una criatura grande: aro de choque elíptico y bajo, polvo de piedra que se eleva en lóbulos redondeados y lascas facetadas que se abren hacia arriba y los costados. La criatura ya existe en el centro y camina: reservar despejado el punto de apoyo para que su cuerpo no se oculte. Materiales claros y neutros, alfa real, lectura limpia sobre pradera y camino de tierra. Luz suave arriba a la izquierda y bordes facetados coherentes con los PNG renderizados del mapa.

Entregar ocho momentos secuenciales de 256 × 256 en una cuadrícula 4 × 2, anclaje de pies (128,176), margen libre de 8 px, 0,7 s totales. Primer cuadro casi vacío y octavo totalmente transparente. El polvo y las lascas ascienden y se disipan; el centro aclara al final. En el juego se muestra a 1:1 y puede teñirse con el color del enemigo: carmesí `#ba403e`, azul acero `#6189b7`, verde `#709d52`.

**Evitar:** fuego, rayos, emblemas, texto, números, la letra A, marcas de comunidad, siluetas de un jefe particular, halo negro, sombra dibujada, partículas puntiformes que se confundan con estrellas o una nube que tape la criatura.

## Grieta quieta

Decal de suelo de 192 × 96 px, marrón gris apagado, con una fisura principal irregular y ramificaciones poco profundas. Polvo tenue, alfa real que se pierde en los bordes, sin sombra, sin color de facción. Se lee debajo del efecto durante 0,7 s y luego se desvanece.

## Marco 9-slice

Marco horizontal de 192 × 128 px para una tarjeta de 720 × 120 px. Hierro oscuro y bronce envejecido, perspectiva frontal de interfaz, contorno `#2b2233`, un brillo discreto, cuatro esquinas fijas con remache. Márgenes reservados de 32 px por lado; los bordes que se estiran son lisos y el centro es transparente. La placa y el texto se dibujan aparte.

**Evitar:** insignias, letra A, banderines, texto o numeración; adornos en la franja central que se deformen al estirar; metal cromado, fuego o más de una línea de brillo por pieza.
