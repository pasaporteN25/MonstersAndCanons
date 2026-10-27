# T523 · Muestras de seis adornos de M79

**Propuestas sin integrar, pendientes de aprobación individual de Lucas antes de T524.** Fecha: 2026-10-26. Son 12 PNG RGBA de 128×128. La generación no modificó el juego, runtime ni assets integrados. La ficha se consultó en el worktree `t522-m79-m80`, rama `feature/t522-respuestas-m79-m80`; el pedido de esta sesión fija el alcance aunque T523 no esté todavía en las specs de esta rama.

## Qué mirar

- [Hoja a 220 px con fondos](contact_220_context.png) y [transparente](contact_220_transparent.png).
- [Hoja a 34 px con fondos](contact_034_context.png) y [transparente](contact_034_transparent.png). Cada miniatura mide realmente 34×34; no es una ampliación.
- [Hoja a 64 px con fondos](contact_064_context.png) y [transparente](contact_064_transparent.png).
- [Referencias dimensionales originales](reference_board.png) y [comparación de estatuas con torres activas/Estandarte](statue_comparison.png).
- Composiciones del desierto, nivel 10: [01](context_level_10_01.png), [02](context_level_10_02.png).
- Composiciones de ruinas, nivel 14: [01](context_level_14_01.png), [02](context_level_14_02.png).
- Composiciones del campamento en pradera, nivel 15: [01](context_level_15_01.png), [02](context_level_15_02.png).

En las hojas, cada variante aparece dos veces para comparar fondos. Hay solamente dos variantes por motivo, no cuatro. El fondo secundario liso de cactus y roca roja es una muestra neutra de contraste, no el camino real. Ruinas/volcán usan texturas del repositorio. Campamento se compara en pradera y ruinas.

## Opciones y lectura

| Motivo | Opción 01 | Opción 02 | Lectura a 34 px y recomendación para revisar |
|---|---|---|---|
| Cactus | [cactus_01](variants/cactus_01.png): tronco alto, brazos desiguales y costillas. | [cactus_02](variants/cactus_02.png): brazo izquierdo elevado, tronco menor y brazo derecho corto. | Ambos conservan la silueta ramificada vegetal. Se pierden las espinas finas; los brazos distinguen las opciones. Recomiendo 01 por su eje central claro; 02 ofrece asimetría. |
| Roca roja | [red_rock_01](variants/red_rock_01.png): grupo alto con peña dominante, derivado de rock_a. | [red_rock_02](variants/red_rock_02.png): masa baja ancha y escalonada, derivada de rock_b. | Se conserva la masa mineral rojiza y la fractura. La 01 comunica mejor obstáculo; la 02 deja más aire arriba. Recomiendo 01 para revisar primero. No son rocas con inscripción de M80. |
| Columna | [column_01](variants/column_01.png): fuste roto vertical, acanaladuras y base astillada. | [column_02](variants/column_02.png): tambor caído con fractura lateral. | La 01 se reconoce mejor como columna; en 02 la lectura primaria es fragmento de arquitectura y se pierden las acanaladuras. Recomiendo 01; 02 tiene menor claridad del motivo a escala chica. |
| Bloque | [block_01](variants/block_01.png): mampuesto macizo con esquinas faltantes y lascas. | [block_02](variants/block_02.png): dos bloques desplazados y erosionados. | Se distinguen bloque único y pila baja. Los faltantes chicos casi desaparecen; la 02 comunica ruina con más claridad que una plataforma intacta. Recomiendo 02. |
| Estatua | [statue_01](variants/statue_01.png): cañón del juego tallado en gris mate sobre pedestal erosionado. | [statue_02](variants/statue_02.png): torre básica del juego tallada en piedra, pedestal alto. | Ambos conservan pedestal pétreo escalonado y masa gris; la 01 tiene un tubo único reconocible, la 02 agrupa más detalles pequeños. Recomiendo 01 por la lectura del cañón. No son guerreros ni Estandarte. |
| Campamento vacío | [empty_camp_01](variants/empty_camp_01.png): lona ocre caída, madera rota y fogón apagado. | [empty_camp_02](variants/empty_camp_02.png): lona oliva grisácea más baja, extendida y plegada. | Se leen restos de lona junto a un pequeño círculo pétreo. El detalle de ceniza se pierde y la 02 se acerca al suelo de ruinas; 01 sostiene mejor la asociación de campamento. Recomiendo 01, con reserva por su huella baja. |

Estas recomendaciones no eligen ni aprueban por Lucas. Cada motivo admite aprobación, rechazo o pedido de ajuste por separado; no se propone alternar variantes en runtime.

## Riesgos y compatibilidad

Las nuevas piezas procedurales muestran volumen por caras, gradiente direccional, grano, oclusión y sombra de apoyo. Columnas y bloques siguen siendo más geométricos y menos pintados que rock_a/rock_b; el cactus tiene transiciones más regulares. Es una limitación artística visible a 220 px, no una equivalencia certificada con el acabado T277. Las rocas y estatuas conservan directamente la geometría pintada de sus fuentes del proyecto.

La estatua debe evocar una torre por §9. La separación decorativa se apoya en la piedra mate uniforme, el pedestal erosionado fijo, la ausencia de color industrial y la falta de base mecánica. Se revisó al lado de cañón/básica activos y Estandarte a 34/64 px: el pedestal y el material sostienen esa separación en estas hojas. Se redujeron los brillos de la primera tanda para evitar apariencia de arma metálica activa. No se valida selección ni interacción en motor. Si Lucas la ve como torre construida, corresponde rechazar o ajustar la pieza y mantener frenada su integración.

Los bloques carecen de patas, rostro, brazos, emblema y abertura de cañón. La columna caída tiene extremo macizo y acanalado longitudinal: no es un arma. No se identificó confusión efectiva con enemigo en la revisión aislada. No se alteran enemigos ni suelos para acomodar estas muestras.

La columna ya tiene uso en desierto (nivel 10), además de ruinas. Las hojas permiten revisar también piedra de ruinas sobre volcán. **No se encontró un nivel con tema `volcan` entre los JSON actuales**: la hoja sobre su textura es un estudio de compatibilidad, no una ubicación propuesta. No se inventó una captura volcánica ni se cambió ningún tema.

Campamento es deliberadamente bajo: en 34 px se reconoce mejor el conjunto de lona y fogón que cada herramienta. La 02 pierde contraste sobre ruinas. Ninguna pieza incorpora personas, bandera, señal, texto o H. Las señales antiguas que siguen visibles en las capturas base pertenecen al juego previo, no a estas muestras.

## Cómo se hicieron las composiciones

Son **composiciones externas de muestra**, no capturas del motor con estos assets integrados. Parten de las capturas reales T491 del inventario. Pillow repone el suelo dentro de unas pocas casillas y superpone el PNG a escala de casilla; no se reemplaza todo el mapa. La captura original queda conservada en `sources/references/`. La franja superior aclara la intervención.

En nivel 10 se muestran cactus/rocas sobre `X` existentes y columna sobre la leyenda de columna. En 14 se comparan columna/bloque/estatua sobre `X`, una columna de leyenda y un campamento de leyenda. En 15 se usan únicamente los tres campamentos existentes. Se verifican los caracteres del JSON antes de montar; no se editan esos datos. No se propone una asignación nueva de piezas a las `X`: son posiciones de comparación para Lucas. El resto conserva dibujos anteriores, incluyendo SVG planos todavía presentes.

La calibración usa origen y tamaño de celda de la captura: en 10, casilla 52,3636 px; en 14/15, 48 px. El lienzo fuente completo de 128 px se reduce a una casilla, sin zoom adicional del objeto. La franja de rótulo desplaza la captura 60 px hacia abajo, sin cambiar su escala. Coordenadas, rectángulos y archivos están en [compositions.json](sources/compositions.json). El repintado de suelo puede dejar una diferencia local de textura: no es evidencia de cómo mezclaría el motor los assets.

## Procedencia y reproducción

Autor: Codex `gpt-6.1-sol`, esfuerzo medio; renderizado con Python 3 + Pillow. Sin generador externo ni materiales de terceros. [manifest.json](manifest.json) consigna este límite, versiones reales, fecha, tamaños, alfa, SHA-256 y entradas de procedencia.

Fuentes de las rocas: `assets/sprites/map/rendered/rock_a.png` y `rock_b.png`. Fuentes de las estatuas: `statue_cannon_moss.png` y `statue_basic_moss.png`. Son derivados cromáticos y de material de arte del propio juego, no nuevos renders 3D. Se preservan sus alfas y sombras. Cactus, columnas, bloques y campamentos son geometría procedural original de esta tarea. Las fuentes históricas de las referencias siguen siendo las del repositorio; este trabajo no les inventa un modelo o prompt original.

Se leyeron la guía §4/§9, el inventario M79 y la ficha externa T523. Se observaron rock_a, rock_b, rubble_idle y estatuas integradas, más las hojas de nieve M79 y rocas M80; se consultó el enfoque de generación de ambas familias. Los generadores ajenos no se ejecutaron ni se modificaron. Los PNG y JSON necesarios para reproducir esta entrega quedan copiados en `sources/references/`, con rutas originales y hashes en el manifiesto. Los rótulos usan DejaVu Sans del sistema.

Desde cualquier carpeta, ejecutar:

```bash
python3 /ruta/al/repo/art/m79-muestras/adornos/sources/generate_samples.py
python3 /ruta/al/repo/art/m79-muestras/adornos/sources/verify_samples.py
```

Requiere Python 3, Pillow y `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf`. No instala dependencias. Todas las semillas, puntos, colores, luz, texturas, tamaños y reglas están en el script; `prompts.md` registra el pedido y las instrucciones adicionales utilizadas. El generador solo escribe bajo `adornos/` y utiliza primero sus referencias preservadas.

## Verificación y alcance

Se revisaron visualmente hojas a tamaño real de 34 y 64 px, detalle a 220 y las seis composiciones. La comparación con torres es de texturas al mismo tamaño de lienzo, no una simulación del juego. La reducción Lanczos es una herramienta de revisión y no reproduce exactamente el filtrado GPU de Godot.

El chequeo automático valida exactamente 12 variantes, PNG RGBA 128×128, alfa con transparencia total y opacidad, esquinas transparentes, píxeles parcialmente transparentes y hashes de todas las imágenes e insumos. `verification.json` conserva el resultado. Se comprueba además reproducibilidad regenerando desde otra carpeta y comparando hashes, y se ejecuta `git diff --check` junto con control de espacios en los archivos nuevos.

No se ejecutaron Godot ni GUT; no hubo importación, integración, prueba móvil ni medición de rendimiento. El tablero registra la finalización de T523 en el mismo commit de la entrega. No se modificaron otras specs ni CHANGELOG. La aprobación artística y T524 siguen pendientes de Lucas.
