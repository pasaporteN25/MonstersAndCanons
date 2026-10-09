# T249 · Mejora de assets provisionales

**PROVISIONAL: pendiente de aprobación artística de Lucas.** Iteración sobre T216 y T218–T221, autorizada por su pedido de mejora del 2026-10-08. No cierra las compuertas de aprobación de aquellas tareas.

Abrir [comparison.html](comparison.html) para revisar ANTES y DESPUÉS en paralelo. Las imágenes completas se abren haciendo clic. [manifest.json](manifest.json) identifica cada archivo, su posición en las hojas y sus hashes antes/después.

## Qué mejoró

| Grupo | Cambios concretos | Qué conservó |
|---|---|---|
| Señales T218 | A más grande, oscura y con un bisel fino en roca y ruina; tres pasos separados del sendero; cabeza de hueso mayor y atadura en la herramienta; cintas asimétricas y gastadas; lona vencida con fogón apagado separado en el campamento. | Los seis ids, lienzos 64×64, materiales, transparencia y apoyo en el suelo. No se agregó ámbar a señales permanentes. |
| Removibles T219 | Copa ramificada menos parecida a una estrella; bandas ámbar mayores; ámbar también durante el trabajo; misma A en los escombros; despejados con suelo más tenue, sin contorno de isla que sugiera otro bloqueo. | Estados y rutas existentes. Árbol y roca intactos siguen distinguiéndose de los permanentes por la marca. Restos bajos. |
| Extracción T220 | Facetas claras/oscuras en la fachada, tablones más gruesos, entrada oscura y vagoneta; mineral azul grisáceo sobrio; bosque con bandas mayores y copas iluminadas, madera activa más gruesa y anillos de corte legibles al agotarse. | Tres estados por sitio, sombra suave y apoyos. Reserva 8×8 sin cambios. |
| Íconos T221 | Lingotes con menos rayas; colección como disco mecánico de hierro/plata/bronce y cristal; demoledora con ariete más robusto hacia la derecha. | SVG 64×64, alfa real, sin sombra, nombres originales. |
| Disruptora T216 | Anillos y abrazaderas más anchos, separación oscura más clara, disco superior blanco azulado legible. Tres fuentes nuevas; atlas básico ahora corresponde a la vista independiente básica. | PNG RGBA, alto del cuerpo 112 en cuadro 128, centro (64,64), atlas 512×256, bases y efectos originales. |

**25 SVG y 4 PNG finales modificados.** La marca de hallazgo, los dos segmentos de reserva, el anillo de pulso y las cuatro marcas de supresión se revisaron y se conservaron: cumplen su función y no requerían rediseño en esta iteración. No se alteraron cantidades de assets ni tamaños contractuales; no hubo motivo para ajustar tests de conteo o dimensiones.

## Qué muestran las capturas

Se ejecutó Godot 4.7.2 **con ventana gráfica**, a **1777×1000**, mediante OpenGL sobre la GTX 1660 SUPER; no se usó el renderizador headless para las capturas del juego. Los PNG son el viewport de esa ventana, sin marco del escritorio. Preparación reproducible en modo de pruebas, con guardado separado `user://test_t249_capture.json`.

- `before/level_01.png`, `level_06.png`, `level_07.png`, `level_08.png`, `level_10.png`, y sus pares en `after/`: escenas reales, mapas originales, HUD y barra. Se revisaron a ojo: camino/suelo, escala y señales visibles.
- `level_06_working/cleared`, `level_07_working/cleared`, `level_08_working/cleared` y `level_10_working/cleared`: estados producidos por `InfrastructureController.order()` y `ObstacleField.tick()`, con oro extra de pruebas; la extracción del 10 también se habilita. No prueban tiempos transcurridos a mano ni balance.
- `disruptor_toolbar.png`: torre construida en una casilla legal, colecciones habilitadas solo para la prueba y botón de la Disruptora en la barra. No modifica la disponibilidad de campaña.
- `gallery_level_01/06/08/10.png`: **banco de muestras rotulado** a 64 px sobre pradera, bosque, ruinas y desierto reales. Permite comparar los assets que todavía no consume la campaña; las muestras superpuestas no son objetos de esa partida y no se presentan como integración.
- `contact_34/64/112/220.png`: hojas de todos los recursos revisados, con margen y terrenos de referencia. El orden está en `asset_paths.json`/`manifest.json`. Los indicadores nativos de 8 y 32 px se amplían solo para inspección en estas hojas. La escala indicada es lógica: la ventana puede ampliar el lienzo del juego.
- `towers_34/64/112.png`: las diez torres con márgenes originales y escalado idéntico. Orden: Básica, Francotirador, Incendiaria, Múltiple, Ráfaga / Hielo, Eléctrica, Cañón, Mortero, Disruptora.

## Integración encontrada y límites

En la base de esta rama, `LevelDecor` usa figuras simples para escombros, mina y bosque; árbol/roca removibles reutilizan los dibujos permanentes con un rombo ámbar encima. `ObstacleLayer` agrega barras/velos y no carga los SVG de estados de T219/T220. Los íconos T221 tampoco están conectados: recursos usa un rombo verde y colección usa el avance genérico. En el nivel 1 todavía figura una estatua provisional; no usa `roca_marcada`. Se consultó a coordinación antes de ampliar el alcance a esa integración.

Por eso, una captura de campaña no demuestra por sí sola que todos los SVG nuevos estén integrados: para ellos se incluyen las galerías rotuladas. Las capturas del nivel 1, y varias de trabajo/despejado, pueden ser visualmente idénticas. Los cambios ya consumidos se ven en el poste del 6, la roca del 7, las ruinas del 8/10 y la Disruptora/barra.

La Disruptora continúa con ocho copias de una vista estática, no con ocho perspectivas modeladas. Los niveles 1 y 2 nuevos son muy similares; el disco elevado distingue mejor al 3. No se implementó el encendido/apagado del cristal: requiere integración de estados. No se rediseñaron las bases ni los efectos aprobados. El desierto del 10 sigue muy cargado de decoración permanente: varios objetos compiten por atención. No se modificó su densidad ni la leyenda de campaña. Sin captura de Wiki, combate con Guardián suprimido, exportación de Windows, aprobación artística, balance humano ni medición de FPS.

## Reproducir

Desde la raíz del proyecto:

```bash
python3 art/t249-mejoras/refine_vectors.py
godot --headless -s art/t249-mejoras/pack.gd
godot --headless --import
godot --headless -s art/t249-mejoras/render_contact.gd
godot --headless -s art/t249-mejoras/render_towers.gd
godot --path . --resolution 1777x1000 --position 20,30 art/t249-mejoras/capture.tscn -- phase=after
godot --path . --resolution 1777x1000 --position 20,30 art/t249-mejoras/context_gallery.tscn
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

`sources/before/` conserva exactamente los recursos anteriores sin modificar. Las tres fuentes PNG generadas quedan en `sources/`; `pack.gd` las recorta y normaliza sin repintar. [prompts.md](prompts.md) registra las instrucciones de edición y sus límites.

## Verificación

Línea de base: **1263/1263 tests**, 11410 asserts, 96 scripts, **0 `SCRIPT ERROR`/`Parse Error`**. **Resultado final: 1263/1263 tests, 11410 asserts, 96 scripts, 0 `SCRIPT ERROR`/`Parse Error`; solo el `ERROR` esperado de `no_existe`.** Salidas completas en `validation/`; verificación adicional de dimensiones, alfa, tres paradas, ausencia de filtros/texto y atlas consistente en `validation/assets.txt`. No hubo SVG ajenos que restaurar tras la importación. Se admite únicamente la línea de base de `no_existe` y `resources still in use`; cualquier otro error se trata como fallo. Los scripts de imágenes avisan que `Image.load_from_file` no es apto para exportación: son herramientas de arte ejecutadas desde el proyecto, no código consumido por el juego exportado.
