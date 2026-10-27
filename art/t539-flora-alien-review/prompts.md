# T539 · Prompt normalizado y decisiones

## Encargo común

Diseñar tres muestras originales de vegetación orgánica del planeta Cántaro para Monsters & Canons, pensando en un futuro reemplazo de `assets/sprites/map/flores.svg` donde hoy aparece `dibujo:flores`: niveles 1, 3, 4 y 5. Extrañas, bellas y sutiles; lectura a 34 px, apoyo en suelo y transparencia. Vista elevada lateral coherente con la decoración dimensional y el atlas de Cántaro, luz suave superior izquierda. No generar arte final ni aprobar variantes.

SVG nativo de 64 × 64, `viewBox="0 0 64 64"`, contorno `#2b2233`, trazo principal de 2 unidades con extremos/uniones redondeados. Cada degradé de relleno tiene exactamente tres paradas, vertical apenas inclinado; un único reflejo principal por dibujo. Sombra de contacto discreta con dos elipses de baja opacidad, sin filtros ni blur, siguiendo la excepción de decoración del mapa de `.claude/rules/arte.md` y el pedido de Lucas. Sin fondo opaco.

Evitar flor terrícola convencional, recursos, torres, señales, H, estandartes, letras, ojos, caras, metal, tecnología, partículas, fuego, emisión intensa, filtros, sombras SVG por efecto, contornos degradados, múltiples reflejos y detalles subpixel a escala de fuente. Las líneas estructurales de 2 unidades resultan aproximadamente de 1 px a 34 px; el antialias del visor sigue siendo parte de la rasterización.

## Direcciones

- **A / a_annular.svg:** tres láminas carnosas anulares/espiraladas, enrollado irregular abierto, tallo corto y hojas basales. Sin pupila ni órgano ocular. Probar que el enrollado se lea vegetal y no emblema a 34 px.
- **B / b_capsules.svg:** hongo-flor bajo, cápsulas de tamaños desiguales, vientre plegado y hojas anchas. Evitar sombrero simétrico de seta terrestre. Probar que no parezca recurso recolectable.
- **C / c_rosette.svg:** roseta de seis hojas curvas desiguales, estrella orgánica ancha y pequeña flor central plegada. Evitar facetas de cristal y simetría de ícono. Revisar lectura del centro.

## Técnica y decisiones de esta entrega

Dibujo manual de paths SVG originales; no se usó generación de imágenes ni se trazaron las referencias. Tres materiales compartidos (luz / medio / sombra):

| Material | Luz | Medio | Sombra |
|---|---|---|---|
| Hoja carnosa | #b0b49a | #778c79 | #455c55 |
| Lámina malva | #dcc1cb | #af879f | #725d7b |
| Interior arcilla | #dfc4ae | #bb958a | #806b76 |

No se fija el color definitivo. Una paleta común permite comparar siluetas sin proponer cuatro especies por nivel. Los cuatro JSON consultados declaran pradera. Fondos HTML/PNG oliva aproximados, sin usar ni modificar textura del juego y sin representar posiciones reales. Repetición triple únicamente para revisar ritmo/densidad aparente.

Se consultaron completas `specs/05-guia-de-arte.md` y `.claude/rules/arte.md`, y visualmente `tree.png`, `rock_a.png`, `rock_b.png`, `forest_idle.png`, `rubble_idle.png` y las once piezas PNG de `assets/sprites/map/rendered/m79/`, además de `assets/tiles/rendered/ground_pradera.png`. Se observó luz superior izquierda, masas de volumen y apoyo discreto; no se copiaron sus formas. El volumen SVG es una simplificación exploratoria: su coherencia con la familia pintada queda a revisión, no se declara resuelta por generar estas muestras.

`historical_flowers.svg` es copia byte a byte de la flor vigente, solo para comparación; sus pequeños detalles son históricos, no reglas aplicadas a las nuevas fuentes.

## Producción de las composiciones

HTML/CSS local sin scripts, fuentes remotas ni bibliotecas de navegador. PNG compuesto con Python 3, Pillow y librsvg/cairo disponibles en el sistema; SVG rasterizados directamente a 220 y 34 px, sin Godot. El PNG y el HTML son dos composiciones equivalentes de revisión, no capturas de motor. El HTML usa px CSS y su visualización depende del zoom y pantalla.

## Preguntas para Lucas

1. ¿Qué silueta se acerca más a la vegetación de Cántaro: A, B o C? Ninguna queda seleccionada automáticamente.
2. Elegida la forma, ¿conservamos malva/salvia apagados o exploramos otro acento? ¿Una paleta común o matices locales sutiles?
3. ¿Cuánta presencia debe tener frente a la decoración pintada y el suelo? Escala, densidad, material final e integración se revisan después.
