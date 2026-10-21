# T427 · Arte de muestra para el mapa planetario
- Ejecutor · Codex, arte visual
- Depende de · T425 · Compuerta · Lucas aprueba muestras antes de producir/integrar
- Tamaño · Mediano

## Leer
Guía de arte y regla de no cambiar la lógica del juego en tareas de arte.

## Objetivo
Proponer un mapa 2D de Cántaro que pueda mostrar el lugar de aterrizaje y 15 zonas a escala de pantalla desktop.

## Alcance
Presentar una maqueta con tres estados: zona no jugada/bloqueada, presencia rebelde (1–2 estrellas) y zona tomada (3 estrellas). Mantener marcadores distinguibles y espacio para navegación/selección. Incluir fuente, procedencia, capturas de pantalla y estimación de peso si hay assets raster.

## Hecho cuando
Lucas puede revisar la composición y los estados a 1280×720. Separar claramente mockup, assets propuestos y producto final. No tocar código, datos de campaña o assets de producción; esperar aprobación antes de integrar.

## Resultado
Se entregó `art/t427-mapa-propuesta/mapa.svg` y su captura `captura_1280x720.png`: vista de atlas 2D con el punto de aterrizaje y 15 zonas. El ejemplo muestra una zona tomada con 3 estrellas, una rebelde con 2 y una desbloqueada; las demás están bloqueadas. El `README.md` documenta fuente y peso. No se modificaron assets de producción, escenas, lógica ni progreso. La integración final espera la aprobación artística de Lucas.
