# T523 · Revisión de cactus y campamento vacío · M79

**Muestras externas sin integrar.** Revisión del 2026-10-26: únicamente se sustituyen dos variantes de cactus y dos de campamento vacío. Siguen siendo 12 PNG RGBA 128×128 para una huella de 64×64. Las cuatro nuevas variantes esperan nueva aprobación de Lucas antes de T524.

## Revisión solicitada por Lucas · 2026-10-26 (diagnóstico previo a editar)

Lucas objetó las dos variantes iniciales de cactus y las dos de campamento vacío: «El campamento y el cactus lo podemos hacer mucho mejor, está bastante mal diseñado el cactus especialmente. Ya mergeé 122 y 123. Lo demás lo veo bien». Roca roja, columna, bloque y estatua recibieron su visto bueno en esa fecha; sus ocho PNG se conservan exactamente. Las cuatro propuestas nuevas quedan pendientes de nueva aprobación.

Antes de editar: el cactus inicial tiene grosor uniforme, tramos rectos y codos regulares; parece un ícono genérico aunque tenga sombreado. El campamento ocupa una banda demasiado baja del lienzo y el fogón se mezcla con la tela al reducir a 34 px. La corrección sigue T277: material pintado, volumen orgánico, luz superior izquierda, transparencia y sombra de apoyo discreta. Para cactus: silueta asimétrica de crecimiento vivo, costillas profundas y espinas subordinadas a la masa. Para campamento: refugio vencido de mayor altura útil, tela caída y varas expuestas; fogón apagado más grande y separado para conservar lectura. Todo permanece dentro de una casilla, sin objetos construibles.

## Qué mirar

- [Hoja a 220 px con fondos](contact_220_context.png) y [transparente](contact_220_transparent.png).
- [Hoja a 34 px con fondos](contact_034_context.png) y [transparente](contact_034_transparent.png). Cada miniatura mide realmente 34×34; no es una ampliación.
- [Hoja a 64 px con fondos](contact_064_context.png) y [transparente](contact_064_transparent.png).
- [Referencias dimensionales originales](reference_board.png) y [comparación de estatuas con torres activas/Estandarte](statue_comparison.png).
- Composiciones del desierto, nivel 10: [01](context_level_10_01.png), [02](context_level_10_02.png).
- Composiciones de ruinas, nivel 14: [01](context_level_14_01.png), [02](context_level_14_02.png).
- Composiciones del campamento en pradera, nivel 15: [01](context_level_15_01.png), [02](context_level_15_02.png).

En las hojas, cada variante aparece dos veces para comparar fondos. Hay solamente dos variantes por motivo, no cuatro. El fondo secundario liso de cactus y roca roja es una muestra neutra de contraste, no el camino real. Ruinas/volcán usan texturas del repositorio. Campamento se compara en pradera y ruinas.

## Resultado y lectura observada

| Motivo | Opción 01 | Opción 02 | Lectura a 34 px y límites |
|---|---|---|---|
| Cactus, nueva revisión | [cactus_01](variants/cactus_01.png): tronco alargado, brazo curvo izquierdo, brote corto derecho y base corchosa. | [cactus_02](variants/cactus_02.png): mata de tres tallos carnosos de alturas distintas, eje dominante inclinado. | Se distinguen la ramificación y las masas vegetales, con costillas claras/oscuras. Las espinas se funden en puntos de luz; las cicatrices no se leen individualmente. La 01 conserva una silueta más convencional, pero pierde los codos rectos y el grosor uniforme. La 02 es más compacta. El apoyo de la 01 tiene una sombra casi imperceptible. |
| Campamento vacío, nueva revisión | [empty_camp_01](variants/empty_camp_01.png): lona ocre vencida y rasgada, varas quebradas expuestas, entrada vacía oscura y fogón al frente derecho. | [empty_camp_02](variants/empty_camp_02.png): lona gris caqui caída hacia la izquierda, soporte cruzado roto a la derecha y fogón al frente izquierdo. | Se distinguen refugio y fogón apagado como dos masas separadas; el centro oscuro rodeado de piedras sobrevive. No se distinguen cada piedra, atadura, brasa apagada o desgarro. La 02 pierde contraste sobre ruinas y su lona se mezcla parcialmente con el suelo; la entrada oscura y las varas sostienen la identificación. La 01 es más visible sobre ambos fondos. |
| Roca roja | [01](variants/red_rock_01.png): peña alta. | [02](variants/red_rock_02.png): masa baja escalonada. | Sin cambios. Visto bueno de Lucas el 2026-10-26 para el motivo; no se infiere elección entre variantes. |
| Columna | [01](variants/column_01.png): fuste roto. | [02](variants/column_02.png): tambor caído. | Sin cambios. Visto bueno de Lucas el 2026-10-26. La 02 sigue leyendo primero como fragmento arquitectónico, con pérdida de acanaladuras a 34 px. |
| Bloque | [01](variants/block_01.png): mampuesto astillado. | [02](variants/block_02.png): dos bloques desplazados. | Sin cambios. Visto bueno de Lucas el 2026-10-26. Los faltantes pequeños siguen perdiéndose a escala chica. |
| Estatua | [01](variants/statue_01.png): cañón tallado. | [02](variants/statue_02.png): torre básica tallada. | Sin cambios. Visto bueno de Lucas el 2026-10-26. Conservan piedra mate y pedestal. La [comparación con torres activas](statue_comparison.png) permanece idéntica. |

La nueva tela ocupa más altura que la banda baja inicial, y el fogón deja de superponerse a ella. Los soportes aún sostienen una parte del refugio: se representa un campamento deteriorado y parcialmente vencido, no una lona completamente plana. Los agujeros y los extremos rotos comunican abandono en grande; a 34 px esa condición depende principalmente de la silueta vencida y la ausencia de fuego u ocupantes. No se agregaron cajas, botín, maquinaria ni útiles que sugieran construcción.

Se revisaron las seis hojas a 220/64/34 px y las seis composiciones a su tamaño nativo. No se identificó en esas imágenes una confusión efectiva de los cactus con torres o enemigos. Los campamentos no tienen plataforma, base industrial ni objetos de producción. Esta observación visual del agente **no es aprobación artística** ni prueba de interacción; Lucas decide si las opciones nuevas alcanzan el acabado pedido. Columna y bloque conservan el acabado más geométrico de la entrega aceptada, sin retoques.

## Referencias y composición

Antes de editar se leyeron RF-712–714/M79, D-210, la ficha T523, la constitución, la guía §4/§9, el inventario M79, el informe, los prompts, los scripts y los manifiestos existentes. Se observaron las hojas y las capturas base de niveles 10/14/15, los montajes previos y las referencias dimensionales preservadas del juego: rock_a, rock_b, rubble_idle y las estatuas. La dirección es T277, no SVG T260. No se ejecutaron generadores de assets integrados.

Las composiciones siguen rotuladas **COMPOSICIÓN DE MUESTRA / SIN INTEGRAR**. Son superposiciones externas de Pillow sobre capturas reales T491; **el motor no dibujó estos PNG nuevos**. En nivel 10 cambian los dos cactus de muestra; en 14 cambia el campamento de muestra; en 15 cambian los tres campamentos existentes. Las posiciones y rectángulos de [compositions.json](sources/compositions.json) permanecen idénticos. Las rocas, columnas, bloques y estatuas de los montajes conservan los mismos píxeles. Las otras decoraciones antiguas de las capturas permanecen visibles y no forman parte de la revisión.

Cada lienzo de 128 px se reduce a la casilla completa: no hay zoom especial del objeto. Nivel 10 usa casilla de 52,3636 px; 14/15, de 48 px. El rótulo agrega 60 px arriba sin escalar la captura. Se repone suelo solo en las casillas registradas, lo que puede dejar diferencias locales de textura. El verificador confirma que fuera de esos rectángulos la captura es idéntica. No se asignan ubicaciones nuevas ni se cambian mapas, temas, leyendas o grillas. La hoja de volcán sigue siendo solo compatibilidad de material; no se encontró un nivel actual con ese tema.

## Fuentes, prompts y reproducción

Autoría de la revisión: Codex `gpt-6.1-sol`, esfuerzo medio. Las cuatro imágenes nuevas se produjeron con la herramienta nativa **image_gen.imagegen**, una llamada por variante, transparencia solicitada y la hoja inicial `reference_board.png` como referencia de estilo (copia exacta del insumo en `sources/references/generation_reference_board.png`; la hoja activa solo actualiza su rótulo). El modelo interno de imagen no está expuesto por esa herramienta; no se lo atribuye al modelo de código. Los prompts completos, sin resumir, y los parámetros se registran en [prompts.md](prompts.md) y [generation.json](sources/generation.json).

Los originales generados quedan en `sources/generated/`. El script usa Pillow para reducir uniformemente cada original a una caja máxima de 112×112 y centrarlo en 128×128 RGBA, conservando alfa y proporción. No recorta, espeja, recolorea ni redibuja los rasters. Las ocho variantes aprobadas se cargan para componer, **sin regenerarlas ni guardarlas de nuevo**. No se declara una escena 3D o geometría editable inexistente: las fuentes nuevas son raster. El prompt permite repetir el pedido, pero **la IA no garantiza el mismo resultado**; la reproducción exacta parte de los cuatro originales preservados y no requiere red.

`sources/iterations/initial/` conserva los cuatro PNG objetados con sus nombres originales, el script y los prompts iniciales y el manifiesto anterior. `protected_hashes.json` fija los SHA-256 de las ocho variantes aprobadas contra ese manifiesto. `manifest.json` registra tamaños, alfa, hashes de todos los PNG, referencias, scripts, prompts y procedencia. Las referencias siguen siendo copias de arte propio del repositorio; no se inventa la procedencia generativa histórica de T277. Los rótulos usan DejaVu Sans del sistema.

Para generar y comprobar desde `/tmp`, sin Godot ni red:

```bash
cd /tmp
python3 /ruta/al/repo/art/m79-muestras/adornos/sources/generate_samples.py
python3 /ruta/al/repo/art/m79-muestras/adornos/sources/verify_samples.py --reproduce
```

Requiere Python 3, Pillow y `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf`. El segundo comando copia todo `adornos/` a un directorio temporal, ejecuta allí el generador con cwd `/tmp` y compara **todos los archivos byte a byte**, excepto `verification.json`, que registra la verificación. No depende del resto del checkout ni del directorio original de image_gen. El generador escribe solo bajo su copia de `adornos/`. El script histórico archivado es evidencia de la iteración inicial; no es el punto de entrada de reproducción actual.

## Verificación y alcance

- Verificador de adornos: **PASS**. Doce variantes RGBA 128×128, transparencia total y parcial, bordes transparentes, 51 PNG y 19 referencias con hashes, fuentes/documentos registrados, cuatro iniciales conservados y cuatro activos sustituidos. Ocho PNG aprobados idénticos al manifiesto inicial.
- Regeneración aislada desde `/tmp`: idéntica byte a byte; seis montajes conservan la captura fuera de las casillas documentadas. Resultado en [verification.json](verification.json).
- Verificadores existentes de nieve M79 y marcas M80 ejecutados en copias temporales para no escribir en esas carpetas del repositorio. Salida y alcance en [external_verification.json](sources/external_verification.json). No se regeneraron esas familias.
- `git diff --check` y control de alcance: solo archivos bajo `art/m79-muestras/adornos/`. No se actualiza tablero ni CHANGELOG por el límite explícito de esta revisión.

**Límites:** montajes externos, no capturas del motor con arte integrado. No se ejecutaron Godot/GUT, importación, teléfono real, simulación móvil ni mediciones de rendimiento. Lanczos no reproduce el filtro GPU de Godot. La pérdida de espinas y detalles de abandono a 34 px, el menor contraste de campamento 02 sobre ruinas y el apoyo muy tenue de cactus 01 permanecen como reservas visibles. La nueva aprobación de cactus/campamento queda exclusivamente pendiente de Lucas.
