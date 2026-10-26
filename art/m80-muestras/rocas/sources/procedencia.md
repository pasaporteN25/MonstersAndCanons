# Procedencia de T504 · revisión de las rocas

Fecha: 2026-10-26. Producción: Codex. Modelo y esfuerzo consignados en el encargo:
gpt-6.1-sol, medio. Herramientas: Python 3 y Pillow, sin NumPy, servicios de
imágenes, imágenes generativas ni material ajeno. Las nueve piezas son arte
procedural original. Los PNG de referencia nunca se modifican ni se copian
como material de las rocas nuevas.

## Referencias observadas

rock_a tiene bloques angulosos, caras superiores cálidas, frentes gris oscuro,
aristas claras, fisuras y musgo oliva. rock_b es bajo y ancho, con techo de
fractura escalonado y bloques menores. snow_rock conserva ese volumen bajo
una cubierta blanca; rubble_idle usa mampostería rota con juntas profundas;
tree muestra follaje agrupado, luz superior izquierda y sombra discreta.
snow_rock_01 se conserva exclusivamente como vecina de comparación.
Se consultó generate_samples.py: render a 384×384, normales, luz superior
izquierda y reducción Lanczos a 128×128. Los suelos y capturas son recursos
del propio repositorio. Los rótulos usan DejaVu Sans instalada.

## Cambios frente a la primera tanda

Se descartó el volumen por semiespacios con gran cara ovalada y biseles suaves.
También se descartó una prueba de facetas radiales que parecía piedra tallada.
La malla final es una proyección con profundidad por vértice: 17 caras en A/C
y 19 por cada bloque de B; cada cara calcula su normal y respuesta Lambert.
Se usan caras de tamaños desiguales, quiebres finos oscuros, brillo discontinuo,
lascas, muescas reales de silueta, inclusiones y grano mineral fino.
Solo la sombra de apoyo se desenfoca; no se desenfocan las caras de la roca.
La luz viene de arriba a la izquierda. No se usan reflejos horizontales porque
invertirían la iluminación. Tampoco se giran los PNG.

A es una peña ancha con frente inclinado; B agrupa tres bloques de tamaños
distintos; C es más alto, con techo visible y frente inclinado. A/C conservan
un rectángulo de 40×30 px dentro de la cara frontal, comprobado contra la
máscara de caras antes del material. Las pequeñas fisuras quedan en sus bordes.
No se agregan símbolos, letras ni grabados. Caliza lleva colonias de musgo oliva;
arenisca usa ocre rojizo apagado, estratos horizontales débiles y desgaste claro,
sin musgo; oscura tiene grietas con labio claro y líquen frío escaso.
Semillas: A 50417, B 50439 (+1 y +2 para sus vecinos), C 50483.
El manifiesto registra semillas, SHA-256, alfa, cuerpo opaco y caras por bloque.

## Reproducción y controles

Ejecutar desde cualquier carpeta:
`python3 /ruta/al/repositorio/art/m80-muestras/rocas/sources/generate_rocks.py`
El script regenera piezas, hojas, referencias, revisiones, composiciones,
calibración, manifiesto y este informe. Solo escribe dentro de la carpeta rocas.
No modifica prompts.md. Requiere Pillow y DejaVu Sans.

Se verifican las nueve piezas RGBA 128×128, esquinas transparentes, margen del
alfa mayor a 8 px y huella máxima de 104×92 px. El rectángulo frontal se valida
en ambas geometrías. La reproducibilidad se comprueba regenerando desde otra
carpeta y comparando SHA-256 de todas las salidas.
referencias.png muestra rock_a y rock_b al lado de las nueve nuevas a x3 exacto
con vecino más cercano. revision_piezas.png muestra las nueve variantes.
Se revisaron visualmente también las hojas a 220 y 34 px y los tres montajes.
La hoja de 34 px aproxima LINEAR_WITH_MIPMAPS mediante pirámide BOX, mezcla de
niveles y bilineal; su ampliación x4 usa vecino más cercano. No se afirma
identidad exacta con la GPU de Godot.

Los montajes parten de capturas reales del motor: niveles 15, 11 y 14.
Cada casilla se repinta con su suelo y recibe un solo sprite a escala de casilla.
Se validan señales, leyendas y postes contra los datos. En 15, las X (3,4) y
(4,4) sustituyen su decoración por B/C; los rock_a/rock_b vecinos se conservan.
No se detectaron discrepancias entre las señales indicadas y las capturas.
El cuerpo opaco de las nuevas queda en un rango comparable al alto de las
referencias (rock_a: 98 px; rock_b: 68 px a resolución nativa), sin escalado
extra sobre la casilla. Los tamaños exactos nuevos están en manifest.json.
La calibración mantiene origen (16,48), casilla 48 en 14/15 y origen
(11,6364;48), casilla 52,3636 en 11. El redondeo por borde evita huecos.

La revisión mejora claramente facetas, contraste y nitidez frente a la tanda
rechazada. A x3 se sigue percibiendo una construcción más geométrica y una
textura menos pictórica que rock_a/rock_b: no se certifica como cumplido el
criterio subjetivo de que no resulten peores. Queda expuesto en la comparación,
sin presentar la muestra como arte aprobado ni dar T504 por cerrada.
No se ejecutó ni importó el juego, no se probó en teléfono ni se midió
rendimiento. No se modificaron tablero, CHANGELOG ni archivos fuera del alcance.
No se hizo git add, commit ni push.
