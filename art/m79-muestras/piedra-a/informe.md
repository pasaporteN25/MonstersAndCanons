# T492 · Muestras de la piedra con la A

**PROPUESTA, sin integrar.** La elección queda para Lucas en T495. Preparado el 2026-10-25 sobre `feature/t492-muestras-piedra-a`, referencia de trabajo `37de9a85e992f13b1094fbc849a756d8444c1748`. La instrucción de esta sesión autoriza las muestras con Codex; no se presume aprobada ninguna variante ni se cierran las preguntas pendientes de M79. T491 figura hecha y su inventario y capturas están presentes.

## Para revisar

Abrí [la galería local](index.html). Incluye las seis piezas, las diez hojas sobre suelo y las quince composiciones. También podés empezar por [la hoja de pradera a 220 px](sheets/pradera_220.png), [la de ruinas a 34 px](sheets/ruinas_34.png) y [la prueba del poste](sheets/post_overlap_220_34.png).

## Qué se hizo

Tres ejecuciones de `roca_marcada` y tres de `simbolo_ruina`, con nombres de archivo en inglés. Cada pieza tiene un PNG **RGBA de 128×128**, una fuente de trabajo de 512×512 y el generador editable [generate_samples.py](generate_samples.py). Está pensada para ocupar el lienzo de una casilla de 64×64, sin sobresalir. La piedra de ruina conserva su silueta quebrada, fisuras y material más cálido; la roca marcada conserva su cuerpo más bajo y redondeado.

La A **no se rediseñó**: el centro del trazo sigue `M23 42 32 24 41 42M27 35h10` en coordenadas de 64×64, igual en las seis piezas. Se conservan tamaño, posición, piernas y travesaño. El núcleo usa el ancho nominal de 3 unidades del SVG; el bisel añade relieve alrededor del mismo recorrido. El script comprueba que ese recorrido exista en ambos originales. El relieve y su labio iluminado cambian; no se agrega un significado, otra marca ni una inscripción.

| Ejecución | Qué compara |
|---|---|
| 01 · Tallado sobrio | Piedra gris cálida, surco menos profundo, superficie contenida. |
| 02 · Tallado profundo | Material algo más claro, surco más profundo y labio inferior/derecho más iluminado. |
| 03 · Superficie erosionada | Más poros, desgaste y variación mineral; conserva íntegra la A. |

Las piezas son un render procedural de relieve en 2,5D, con caras biseladas, normales, oclusión del surco, ruido mineral en varias escalas, fisuras y sombra mínima. La luz viene de arriba a la izquierda. No son SVG planos rasterizados ni un modelo 3D completo; el acabado es más facetado que algunas referencias pintadas de T277. Esa diferencia queda a revisión artística de Lucas.

## Recomendación, no aprobación

| Pieza vigente | Variante recomendada | Por qué |
|---|---|---|
| `roca_marcada` | `marked_rock_v02.png` | El surco y su reborde dan más profundidad sin cambiar el tamaño de la marca. A 34 px conserva la lectura sobre los cinco suelos. |
| `simbolo_ruina` | `ruin_symbol_v02.png` | Mantiene la misma A y una superficie antigua quebrada. El tallado se separa mejor de las fisuras que en 03. |

01 sirve si Lucas prefiere menos contraste. 03 muestra el límite de erosión: en la revisión a 34 px todavía reconozco la A, pero los poros suman ruido y reducen su limpieza. La recomendación es visual y subjetiva; no reemplaza la elección de Lucas ni una prueba de lectura con otras personas.

## Hojas y mapas

Hay una hoja a **220 px** y otra a **34 px** para cada suelo: pradera, bosque, desierto, nieve y ruinas. Se usan los PNG de suelo vigentes, no colores aproximados. A 34 px cada sprite mide exactamente 34×34 dentro de un panel de suelo mayor; a 220 px el lienzo del sprite mide 220×220. El visor puede reescalar la hoja: abrirla a 100 % para juzgar el tamaño.

Las composiciones miden **1280×720** y reemplazan todas las señales de cada mapa elegido:

| Nivel | Pieza | Casillas | Archivos |
|---|---|---|---|
| 11 · Puesto seco | Roca marcada | `(1,2)`, `(21,2)`, `(2,8)` | `composites/level_11_v01.png` a `level_11_v03.png` |
| 8 · Bastión | Piedra de ruina | `(12,0)`, `(0,4)` | `composites/level_08_v01.png` a `level_08_v03.png` |
| 9 · Taller asediado | Piedra de ruina | `(6,0)`, `(0,4)` | `composites/level_09_v01.png` a `level_09_v03.png` |

Las seis composiciones `level_08/09_v01/02/03_with_post.png` ensayan el poste hipotético en `(0,4)`. **Hoy esa entrada no está habilitada en los datos de postes.** Se usa `banner_post_enemy.png`, coherente con la referencia de T475. Son vistas de diseño, no capturas nuevas del motor.

**Hallazgo sobre el poste:** `scenes/levels/level_decor.gd` omite la decoración cuando `posted.has(cell)` y luego dibuja el poste. Por eso, en las composiciones de mapa «con poste», la señal se omite por completo. La hoja [post_overlap_220_34.png](sheets/post_overlap_220_34.png) distingue tres situaciones: sin poste; superposición literal solicitada como diagnóstico; y comportamiento vigente de T475, sin señal. En la superposición literal, el mástil y las telas impiden reconocer la A completa a 34 px. En el comportamiento vigente, la A directamente no se dibuja. **Ninguna variante resuelve esto por sí sola.** No se agrandó ni desplazó la A para forzar su visibilidad.

Los montajes parten de `art/m79-inventario/antes-nivel-08/09/11-1280x720.png`. El generador calcula el encuadre con el área útil 1280×576 desde y=48 y los tamaños reales de cada grilla. Repone el material de suelo solo en la casilla de la señal y compone la pieza encima. La reposición puede diferir mínimamente del muestreo del suelo del motor. Los rectángulos exactos están en [composition_manifest.json](sources/composition_manifest.json). Las leyendas «PROPUESTA» dentro de cada composición evitan confundirlas con una ejecución real.

## Procedencia y reproducción

Todo el dibujo nuevo fue generado por el script local de Codex, sin otro modelo ni servicio de imágenes. El script y los PNG de trabajo son las fuentes editables. Semillas fijas: el resultado es reproducible con las mismas dependencias. No hay un prompt de generación externa.

Referencias miradas: `rock_a.png`, `rock_b.png`, `rubble_idle.png`, `statue_basic_moss.png`, `banner_post_enemy.png`; las capturas T475 de 8 y la ampliación del poste que tapaba la señal; las capturas del inventario y la dirección de arte actual documentada en la guía §4. Los originales `roca_marcada.svg` y `simbolo_ruina.svg` aportan la silueta y las coordenadas canónicas del glifo. Los suelos, el poste y las capturas se reutilizan únicamente como contexto de revisión dentro de estas propuestas; no se modifican sus archivos originales. [input_manifest.json](sources/input_manifest.json) registra SHA-256 de las entradas que consume el generador.

Se comprobó con `python3 -c` que el Python predeterminado tiene Pillow, pero no NumPy ni CairoSVG. Se encontró un Python ya instalado con **Pillow 12.3.0 y NumPy 2.3.5**; no se instaló ningún paquete. CairoSVG no se usa. Comando utilizado desde la raíz del repositorio:

```bash
/home/newman/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 art/m79-muestras/piedra-a/generate_samples.py
```

En otra máquina alcanza un Python con Pillow y NumPy; el generador usa además la tipografía DejaVu Sans del sistema. Todos los destinos de escritura están anclados a esta carpeta. Regenerar sobrescribe las propuestas de esta carpeta, nunca los recursos del juego.

## Pesos

| PNG de entrega | Bytes | KiB |
|---|---:|---:|
| `marked_rock_v01.png` | 14.735 | 14.39 |
| `marked_rock_v02.png` | 15.044 | 14.69 |
| `marked_rock_v03.png` | 15.869 | 15.50 |
| `ruin_symbol_v01.png` | 15.695 | 15.33 |
| `ruin_symbol_v02.png` | 15.907 | 15.53 |
| `ruin_symbol_v03.png` | 17.051 | 16.65 |

Las seis piezas suman **94,301 bytes** (92.09 KiB). Son archivos comprimidos; no es una medición de memoria de GPU ni rendimiento. La recomendación de dos piezas pesa **30.951 bytes** en disco.

| Carpeta | Archivos | Bytes |
|---|---:|---:|
| `variants/` | 6 | 94.301 |
| `sources/` | 9 | 749.666 |
| `sheets/` | 11 | 2.152.307 |
| `composites/` | 15 | 4.863.681 |

El mayor peso del paquete corresponde a capturas de contexto. `sources/validation.json` incluye dimensiones, modo, caja alfa, peso y SHA-256 de cada PNG de entrega. Los tamaños de esta tabla se calcularon al preparar el informe; no incluyen este documento, la galería ni el generador.

## Qué se verificó y qué no

**Verificado:** ejecución del generador sin errores; seis PNG de 128×128 en RGBA con alfa de 0 a 255; márgenes transparentes; ninguna pieza excede el lienzo; mismo recorrido de A validado contra ambos SVG; hojas a los dos tamaños; enlaces locales de la galería; comprobación píxel a píxel de que los quince montajes solo cambian las casillas declaradas y el rótulo de propuesta; revisión visual de volumen, suelos, lectura de la A y oclusión; montajes en los niveles 8, 9 y 11; mapa con poste y sin poste. La A se reconoce en mi revisión de las hojas a 34 px, con 02 como opción más limpia. No se da por aprobado el ajuste de estilo con T277.

**No probado:** importación o ejecución de Godot; `godot --import` no se ejecutó; tests GUT; aplicación del filtrado exacto de Godot; capturas del motor con estas propuestas; celular simulado; teléfono real; rendimiento, FPS, memoria o carga. Tampoco se montaron los niveles 7, 10, 12, 13, 14 y 15: los suelos correspondientes sí están en las hojas. La integración y su validación completa pertenecen a T496, después de la elección de Lucas.

No se tocaron assets, scripts, escenas, datos, specs ni tablero. No se hicieron commit ni push. Todo queda en `art/m79-muestras/piedra-a/`.

## Preguntas para Lucas

1. ¿Elegís 02 para ambas piedras, o preferís otra combinación? Mantener la misma ejecución de tallado ayuda a relacionar las dos marcas.
2. ¿El acabado facetado y procedural alcanza la cercanía con T277 que buscás, o querés más irregularidad y pintura mineral antes de integrar? La aprobación estética sigue pendiente.
3. ¿Confirmás que se integren ambas piezas en todos sus usos actuales, incluidos 8 y 9, conservando tamaño y posición como estas muestras? Esta sesión prepara ambas, no modifica los datos.
4. ¿La señal tiene que permanecer visible en `(0,4)` cuando se habilite el poste? Con T475 se omite por completo. Resolverlo requiere una decisión de ubicación o comportamiento fuera de esta tarea; no alcanza con cambiar el dibujo.

Las demás preguntas de M79 siguen en su spec; no se contestaron en nombre de Lucas.
