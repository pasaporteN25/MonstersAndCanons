# Prompts y fuentes de T372

Primera muestra pedida por Lucas, 2026-10-19. Ilustración generada con la herramienta integrada `image_gen`; no se usó la CLI ni una API externa. Los SVG son dibujo vectorial nativo reproducible con `create_sources.py`, rasterizado con Godot 4.7.2 en un proyecto aislado.

## Cabecera inicial

Use case: illustration-story
Asset type: cabecera ilustrada de novedades de Monsters & Canons, muestra T372.
Referencia visual: assets/intro/07_el_oasis.png solamente para técnica de cuaderno de bitácora, paisaje seco y oasis, no copiar personajes ni nave.
Crear panorámica muy ancha 4:1, ideal 1280x320. Pluma muy fina sepia, tramas finas, acuarela sobre papel crema con grano delicado, misma familia de la referencia pero mañana más luminosa y optimista. Campamento del oasis establecido, sin personas: pequeñas construcciones de madera y lona al centro izquierdo, agua dulce verde apagado, árboles bajos de copa redonda, tierras ocres y mesetas lejanas. Varias torres fijas diferentes forman línea defensiva en tercio superior centro izquierdo: cañón corto hierro oscuro bronce madera, mortero robusto, torre industrial oliva y torre cristal celeste. No disparan. Camino curvado detrás. A lo lejos al centro derecho, exactamente dos siluetas pequeñas y distantes: bestia grande carmesí con cuernos, y Coloso pétreo de basalto sin cara con vetas ámbar discretas, sin ataque ni amenaza inmediata. Toda información importante en 60% superior, nada vital a menos de 80 px de bordes. 40% inferior terreno oscuro oliva/ocre MUY tranquilo, de textura leve y sin detalles importantes, adecuado para superponer título crema; centro calmo. No texto, números, letras, logotipos, símbolo A, emblemas, runas, Moradores, comunidades, ruinas, animales adicionales, personas, palmeras tropicales, tecnología láser, batalla ni fuego. Imagen opaca sin marco ornamental.

Salida conservada sin modificar en `sources/header_original.png`.

## Ajuste de composición

Ajustar SOLAMENTE la composición panorámica de esta cabecera conservando técnica sepia/acuarela, oasis, cuatro torres y exactamente los dos monstruos lejanos. Entregar panorámica MUY ancha 4:1 1280x320, o si el lienzo disponible es 2.5:1 componer toda la cabecera en una banda central 4:1 (ancho completo, alto 62.5% del lienzo), con espacio prescindible arriba y abajo para recortar. Dentro de esa banda: 60% superior incluye torres, campamento, agua y dos monstruos distantes; 40% inferior es terreno oliva oscuro muy tranquilo, casi liso sin rocas, arbustos ni texturas fuertes. Torres robustas bajas con bases compactas, no torres de vigilancia altas. Una cañón hierro/bronce/madera, un mortero, una industrial oliva y una de cristal celeste. Más distancia y menor tamaño aparente de ambos monstruos. Sin personas, animales adicionales, ruinas, marcas, texto ni símbolo A. No aplastar siluetas. Mantener iluminación luminosa de mañana.

Salida conservada sin modificar en `sources/header_revised.png`. `pack.py` aplica un recorte 4:1, reducción a 1280 × 320 sin deformar y cuantización a 256 colores. El recorte deja fuera las puntas de las antenas de las dos torres altas; su silueta requiere revisión de Lucas.

## Fuentes vectoriales

Cabecera sobria: banda de hierro de tres tonos y borde de bronce, remaches periódicos y grabado abstracto circular de bajo contraste; sin escena ni texto. Patrón horizontal de 160 px y degradé vertical para conservar la costura.

Mapa: mismo medallón de hierro y bronce que la torre; mapa plegado crema, camino y cruz de bronce. Torre: cañón corto de hierro y bronce, base compacta y tres muescas crema. Contorno `#2b2233` de 2 px, degradés de tres paradas y brillo contenido. Tres familias de material: hierro, bronce y papel/crema. Sin letras ni números; alfa real alrededor del disco.

## Continuación: seis íconos (2026-10-20)

Lucas aprobó el estilo anterior y encargó completar la familia sin integración. No se hicieron nuevas llamadas a `image_gen` ni se usó CLI/API: se extendió el dibujo SVG nativo aprobado con `create_sources.py` y el mismo rasterizador Godot. Se mantuvieron intactas las fuentes y los PNG de cabeceras, mapa y torre.

Encargo normalizado común: ocho medallones de 96 × 96, disco de hierro, borde de bronce y cuatro remaches; contorno `#2b2233` de 2 px, un degradé de tres paradas por material y un brillo por pieza grande. Paleta idéntica de hierro, bronce y papel/crema, luz arriba/izquierda, fondo transparente, lectura a 64 y 48 px. Sin texto, números, emblemas, símbolo A, sombras nuevas ni filtros. Conservar exactamente el medallón aprobado.

| Fuente | Motivo normalizado |
|---|---|
| `news_icon_monster.svg` | Perfil de bestia cornuda hacia la derecha en bronce, ojo chico y colmillo crema; gesto severo, sin marcas comunitarias. |
| `news_icon_siege.svg` | Muralla crema con almenas; flecha de bronce ascendente en diagonal que golpea la muralla y dos marcas de impacto. |
| `news_icon_editor.svg` | Cuadrícula crema, una casilla de bronce y pala diagonal con mango de bronce y hoja de hierro. |
| `news_icon_mobile.svg` | Monitor con marco de bronce y pantalla de hierro; celular chico delante, pantalla crema. |
| `news_icon_book.svg` | Cuaderno abierto de hojas crema y cubierta de bronce, pliegue central y líneas abstractas sin letras. |
| `news_icon_upgrade.svg` | Flecha crema hacia arriba sobre una chispa de bronce; pieza opcional como en la ficha. |

`pack.py` amplía la hoja de contacto, las ocho filas, las maquetas y el HTML; `validate.py` deja las comprobaciones mecánicas en `validation.json`. Ninguna imagen se copió al juego.
