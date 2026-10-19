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
