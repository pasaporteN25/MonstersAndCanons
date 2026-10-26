# T494 · Cabezas del desierto

**Estado: cinco propuestas sin integrar, listas para que Lucas elija.** Ninguna queda aprobada por este informe. Fecha: 2026-10-25. Trabajo dentro de `art/m79-muestras/cabezas/`, en `feature/t494-muestras-cabezas-desierto`; sin commit ni push.

## Para revisar

- [Comparativa a 220 px](sheets/contact_220.png): material, volumen y diferencias de anatomía, junto al cactus y la roca roja vigentes.
- [Comparativa a 34 px](sheets/contact_34.png): lienzos de exactamente 34 × 34 px, sin ampliarlos para favorecer la lectura. Conviene abrirla al 100 %.
- Montajes del nivel 10: [01](compositions/level10_01_four_horns.png), [02](compositions/level10_02_open_jaw.png), [03](compositions/level10_03_single_socket.png), [04](compositions/level10_04_insect_mandibles.png), [05](compositions/level10_05_cattle_baseline.png).

Cada montaje usa una sola variante para las 26 cabezas del nivel: permite evaluar la repetición antes de decidir si conviene variedad. Son composiciones sobre la captura de T491, **no capturas del juego ejecutando las piezas nuevas**. El rótulo de propuesta se agregó en una franja de 46 px por encima de la imagen original.

## Elección sugerida, sin aprobación

| Pieza / función | Variante recomendada | Motivo y límite observado |
|---|---|---|
| Reemplazo principal de `huesos.svg` | **01 · Dos pares de cuernos** | La silueta abierta se separa del cactus vertical y de la roca compacta. Los cuatro cuernos proponen fauna extraña sin copiar un enemigo. A 34 px se distinguen mejor los pares que las grietas. |
| Alternativa si Lucas quiere una segunda forma | **03 · Una cuenca grande** | Más baja y compacta; la cavidad dominante y el hocico largo contrastan con 01. Puede sugerir una especie reconocible: requiere decisión expresa de Lucas. |
| Comparación con una forma más agresiva | **02 · Cuernos curvos y mandíbula abierta** | El hueco de la mandíbula se distingue en la hoja grande. A 34 px los dientes se juntan y puede parecer una cabeza activa; la dejaría detrás de 01 y 03. |
| Exploración de una anatomía distinta | **04 · Placas y mandíbulas** | Cabeza alargada, cavidades laterales erosionadas y dos mandíbulas curvas. Sin abdomen, patas, cuerno frontal ni caparazón azul del Escarabajo. El detalle compuesto de las cavidades no se sostiene a 34 px; los arcos de las mandíbulas sí. Riesgo de sugerir una especie nueva. |
| Línea de base conservadora | **05 · Cráneo de ganado mejorado** | Mantiene cuernos, cuenca y hocico de la idea actual, con cavidades y material dimensionales. Sirve para juzgar cuánto se quiere alejar la dirección de la cabeza vigente. No implica que exista ganado terrestre en el canon. |

Estas recomendaciones son juicio visual sobre imágenes estáticas. No se propone cambiar probabilidades, listas de decoración ni JSON. Si Lucas elige dos, su distribución corresponde a una decisión posterior.

## Producción y procedencia

Las cinco piezas son originales de esta tarea. Se modelaron con sólidos elipsoidales y cuernos sobre curvas de Bézier, y se rasterizaron mediante intersecciones analíticas de rayos: las cuencas y los orificios se excavan en el volumen. El generador calcula normales, iluminación superior izquierda, oclusión local, poros y desgaste; agrega grietas cortas, sombra de apoyo y una lengua de arena que cubre el borde inferior. No se usó otro modelo de arte, ImageGen, material descargado ni SVG plano como fuente de las cabezas.

La fuente editable canónica es [sources/generate.py](sources/generate.py): incluye geometría, paleta, iluminación, arena, hojas y montajes. Los JSON numerados documentan la geometría generada; se regeneran desde el script, así que las modificaciones persistentes se hacen en `model()` y en sus parámetros. También se conservan los cinco PNG de trabajo de 256 × 256, antes de reducirlos con Lanczos. Los PNG finales son **RGBA de 128 × 128**, pensados para una casilla de **64 × 64**. Ninguno toca los bordes del lienzo, incluida la sombra tenue.

Para reproducir desde la raíz del repositorio:

```bash
python3 art/m79-muestras/cabezas/sources/generate.py
```

Solo requiere Python 3, PIL/Pillow y la fuente DejaVu Sans instalada en la ruta indicada en el script. Se verificó que PIL está disponible; numpy y cairosvg no están instalados y no se necesitan. No se instaló nada.

Referencias locales leídas o inspeccionadas:

- `CLAUDE.md`, `.claude/rules/arte.md`, constitución, guía de arte §4, M79 (RF-712 a RF-714), D-210, universo §4, §6 y §8, ficha T494, tablero T491 e inventario.
- `assets/sprites/map/rendered/rubble_idle.png`, `statue_basic_moss.png` y `banner_post_enemy.png`: material dimensional, perspectiva, luz y apoyo.
- `Capturas/T475-nivel10-0est-1280x720.png`, `Capturas/T471-pc-1280x720-final.png` y el antes del nivel 10 de T491: contexto actual, poste, atlas y UI.
- `assets/sprites/enemies/rendered/armored.png` y `spider.png`: contraste visual de la muestra 04 con Escarabajo y Araña. El hocico de las demás propuestas no usa orejas, pelaje ni colmillos caninos del Lobo.

El suelo de las hojas se copia de `assets/tiles/rendered/ground_desierto.png`. Cactus y roca roja son recortes del mapa real de T491, con su propio suelo, reescalados al tamaño indicado: son referencias vigentes, no rediseños. Su ampliación a 220 px muestra la resolución de la captura y no debe confundirse con una fuente nueva de esos objetos.

La base de los cinco montajes es `art/m79-inventario/antes-nivel-10-1280x720.png`. Se ubicaron visualmente las 26 cabezas y se guardaron sus coordenadas en [sources/replacement_cells.json](sources/replacement_cells.json). Se tapó cada casilla con un parche de arena limpia de esa misma captura y se compuso el PNG nuevo con escala uniforme. La grilla visible mide aproximadamente 52 px por casilla en esa captura reducida; no se presentó como si fueran 64 píxeles físicos. El parche permite comparar el reemplazo, pero no reproduce exactamente la textura de suelo que había detrás del dibujo viejo.

La spec y la ficha todavía conservan la aprobación previa de T490 y la restricción de modelo anteriores. Se avanzó con estas propuestas por el pedido explícito de esta sesión, que autoriza T494 con Codex y deja la elección para Lucas. T491 figura hecha y sus archivos están presentes. No se da por aprobada la integración ni se responde por Lucas ninguna pregunta de M79.

## Peso de archivos

| Variante | PNG final, bytes | Montaje, bytes |
|---|---:|---:|
| 01 · Dos pares de cuernos | 15.140 | 766.724 |
| 02 · Mandíbula abierta | 15.541 | 768.622 |
| 03 · Cuenca grande | 11.876 | 762.008 |
| 04 · Mandíbulas | 13.675 | 764.991 |
| 05 · Ganado | 13.661 | 765.096 |
| **Total** | **69.893** | **3.827.441** |

Las hojas pesan 300.396 bytes (220 px) y 56.841 bytes (34 px). Fuentes, JSON y comprobación suman aproximadamente 280 KiB. El paquete completo ronda **4,34 MiB**; el inventario exacto por archivo está en `sources/file_sizes.json`. Estos son pesos en disco: no son memoria de texturas, costo de importación ni una medición de rendimiento.

## Verificación y límites

Se abrieron visualmente ambas hojas y los cinco montajes. Se comprobó con PIL que los cinco finales son PNG RGBA de 128 × 128, tienen margen transparente y caben en su casilla. Se verificaron 26 coordenadas distintas y que todas corresponden a `X` en el JSON del nivel 10. Una comparación píxel a píxel, descontando la franja añadida, confirmó que los montajes conservan la captura original **fuera de esas 26 casillas**: UI, caminos, poste, señales y removibles permanecen allí iguales. Resultado técnico en [sources/validation.json](sources/validation.json).

La iluminación y el volumen siguen la dirección dimensional requerida. Esta rasterización procedural tiene superficies más suaves y geometría más regular que el desgaste pintado de los removibles T277; es una diferencia para revisar, no una equivalencia artística aprobada. En especial, 02 puede parecer expresiva y 04 pierde detalles chicos. La arena integrada debe revisarse también con el filtrado real del mapa.

**No se ejecutó Godot**, ni `--import`, ni GUT. No se comprobó importación, filtrado, convivencia con enemigos en movimiento, oclusión durante una partida ni la versión de Godot instalada. No hay capturas nuevas del motor, celular simulado, teléfono real ni mediciones de rendimiento. No se montaron los niveles 11 y 12: esta ficha solicita el nivel 10. No se editaron el tablero, CHANGELOG, recursos de juego, datos, escenas ni código fuera de esta carpeta.

## Preguntas para la elección de Lucas

1. ¿Elegís 01 como principal, otra de las cinco o pedís una corrección? Mi preferencia es 01 por su silueta a 34 px.
2. ¿Querés una sola cabeza o dos formas? Si son dos, propongo considerar 01 y 03; no se aplicó esa mezcla ni se fijó una frecuencia.
3. ¿La cuenca única de 03 o las mandíbulas de 04 te sugieren una especie nueva demasiado reconocible? Quedan como anatomías sin nombre, sin historia ni vínculo con enemigos existentes; si sugieren canon nuevo, requieren tu decisión antes de integrar.
4. ¿La mandíbula de 02 se lee como despojo o parece una criatura activa? Aconsejo descartarla si la expresión compite con los enemigos.
5. ¿El material y la cantidad de arena alcanzan la cercanía buscada con T277, o preferís más fractura y menos superficie suave en la variante que elijas?

No hay ninguna respuesta asumida ni aprobación en nombre de Lucas.
