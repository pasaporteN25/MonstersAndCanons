# T362 · Consignas normalizadas

Estas consignas documentan una producción **vectorial/procedural nativa**, sin modelo generativo ni prompts enviados a un servicio. Las fuentes son los SVG y PNG originales por cuadro en `sources/`; `pack.py` conserva la construcción y el empaquetado.

## Refuerzo · nivel 2

Efecto de mejora industrial fantástico para una torre renderizada, perspectiva elevada. Un anillo elíptico de luz marfil casi blanca nace cerca de la base, asciende hacia el mecanismo y se abre. Seis chispas pequeñas de forma facetada, sin trazos eléctricos. Un solo uso, sobrio, centro abierto, sin tapar la silueta de la torre. Ocho cuadros de 192×192, 0,5 segundos en total. Centro de anclaje 96,96; ancho visible aproximado 120 px. Inicio casi vacío y final transparente. Bordes suaves con alfa real, sin negro y sin sombras. Tinte neutro multiplicable por ámbar, celeste, violeta, naranja o azul. No fuego, humo, electricidad, engranajes, marcas, letras ni números.

## Maestría · nivel 3

Misma familia visual y mismo ascenso. Dos anillos elípticos escalonados, más llenos y amplios; ocho chispas en abanico y un destello en cruz en el pico. El destello queda por encima del mecanismo, sin cubrirlo. Tiene que distinguirse del nivel 2 por la forma a 34 px. Ocho cuadros de 192×192, 0,7 segundos en total; mismo centro 96,96. Ancho visible aproximado 160 px. Mismos materiales claros, alfa y restricciones del nivel 2; sin símbolos nuevos.

## Presentación y controles de producción

- Atlas de 768×384, cuatro columnas por dos filas, orden de lectura normal. Margen mínimo 8 px. PNG RGBA menor a 150.000 bytes por pieza.
- Rasterizar trazos y chispas a 4× y reducir con Lanczos. Guardar cada cuadro original y su SVG. No agregar desenfoques, filtros ni sombras SVG.
- Envolvente de intensidad por cuadro: 0,035; 0,46; 0,88; 1; 0,82; 0,48; 0,16; 0. Núcleo claro y capas de alfa para suavizar el borde, sin colorear el contorno.
- Referencias de mano: hielo y explosión existentes; tomar la concentración del brillo, sin copiar su identidad de hielo o fuego.
- Revisar los ocho cuadros sobre las texturas reales de pradera, nieve, volcán y desierto, a 192 y 34 px; repetir con multiplicación RGB de los cinco tintes del juego. No retocar el suelo.
- Montajes con Ametralladora y Mortero usando escalas y encastre documentados; reconstrucción explícita del anillo actual. No presentar estos montajes como capturas de partida.
- Conservar las decisiones pendientes de Lucas. Producir solo muestras dentro de `art/t362-muestras/`, sin integración ni cambios de lógica.
