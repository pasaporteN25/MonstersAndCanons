# T540 · Referencias, prompts y producción

Fecha: 2026-10-27. Propuestas sin aprobar; sustituyen a nivel de revisión las SVG rechazadas de T539.

## Referencias de estilo inspeccionadas

- `assets/sprites/map/rendered/tree.png`
- `assets/sprites/map/rendered/rock_a.png`
- `assets/sprites/map/rendered/forest_idle.png`
- `assets/sprites/map/rendered/m79/cactus_02.png`
- `art/t537-arte-campana/captures/level_01_active.png`

La familia vigente usa sprites PNG pintados y dimensionales: perspectiva elevada, masas legibles, material mate, luz suave superior izquierda y apoyo discreto. `flores.svg` es referencia de contenido que se reemplaza, no referencia del acabado nuevo.

## Encargo común enviado

Crear una planta alienígena aislada para el mapa de Monsters & Canons, con fondo transparente y silueta legible en 34 px. Ilustración de utilería de juego dimensional y pintada, como prop de fantasía visto en cámara ortográfica elevada: volúmenes escultóricos, material orgánico mate, detalle superficial sutil, luz cálida suave arriba a la izquierda, paleta salvia/oliva apagada con acentos malva discretos, sombreado inferior derecho y apoyo natural pequeño. Objeto completo centrado, sin suelo opaco ni escenario. Evitar vector, caricatura plana, emoji, fotorealismo, contorno, resplandor, texto, interfaz, collage y exceso de detalle fino.

## Variantes

- **A / `a_trumpets.png`:** tres corolas trompeta carnosas enrolladas, aberturas desiguales, reversos oliva, interiores malva apagados y roseta baja.
- **B / `b_capsules.png`:** tres cápsulas de distinta altura, con coronas plegadas y tallos/hojas cortos; vegetal y no recurso.
- **C / `c_rosette.png`:** roseta baja asimétrica de hojas gruesas con un capullo lateral cerrado.

Se generó una salida nueva por variante. El modelo interno de la herramienta no se expone. Las salidas originales se conservan en `sources/generated/`. Para preparar las piezas de revisión se umbraló el alfa únicamente para hallar el rectángulo visible, se preservó proporción, se redujo con Lanczos hasta caber en 112×112 y se centró en un lienzo RGBA transparente de 128×128. No se recoloreó, espejó ni retocó la forma.

## Montaje contextual

Las tres imágenes `context/level_01_*.png` parten de la captura actual de T537. Cubren las dos flores actuales con recortes de pasto vecino de esa misma captura y ubican la propuesta centrada en ambas casillas. El parche puede mostrar una mínima discontinuidad de textura; por eso la página llama a cada imagen **montaje**, no captura del motor ni vista de integración exacta. No reemplaza una prueba dentro de Godot.

## Corrección de proceso

T539 consultó sprites actuales, pero definió SVG de 64×64 y reglas vectoriales derivadas del histórico como formato y técnica de salida. La instrucción estilística quedó subordinada a esos límites de producción. Además, no exigía validar el resultado en captura del juego antes de pedir decisión. La corrección es una compuerta en la guía de arte, aplicable a cualquier familia: identificación visual y técnica antes de producir, luego lectura a escala de juego y montaje contextual antes de presentar.
