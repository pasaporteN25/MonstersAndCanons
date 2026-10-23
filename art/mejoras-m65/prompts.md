# T362 · Prompts y dirección normalizados

No se usó un generador de imágenes. Las piezas son arte vectorial procedimental dibujado con Pillow por `sources/render_samples.py`, para conservar control exacto del alfa, la grilla y la tintura multiplicativa.

## Dirección común

«Efecto de mejora para una torre de Monsters & Canons, juego 2D de fantasía industrial. Luz neutra marfil/blanco cálido con un toque mínimo de bronce, alfa real y bordes limpios, sin sombra dibujada, sin color propio saturado, sin letras ni símbolos. El efecto nace casi transparente, sube desde la base hacia el mecanismo y se abre; deja visible la silueta de la torre. Debe leerse al teñirse con `modulate` ámbar, celeste, violeta, naranja o azul. Fondo transparente.»

## Refuerzo · nivel 2

«Un anillo elíptico abierto, fino y sobrio, que asciende y se expande alrededor del mecanismo. Seis destellos pequeños en torno al arco. Ocho cuadros: inicio casi vacío; ascenso, apertura y salida; cuadro final transparente. 0,5 s a 16 cps.»

## Maestría · nivel 3

«El mismo gesto del refuerzo, más amplio y claramente más intenso: dos anillos elípticos abiertos, un destello breve en cruz sobre el mecanismo y ocho chispas en abanico. No ocultar el cañón. Ocho cuadros; salida transparente. 0,7 s a ~11 cps.»

## Límites del material de revisión

Las torres y los terrenos de estas hojas son esquemas hechos en el mismo script; no son capturas del juego ni sprites candidatos. La composición comunica escala, contraste y oclusión aproximados. Antes de integrar, T364 debe revisar el arte aprobado sobre sprites y mapas reales y medir en dispositivo.
