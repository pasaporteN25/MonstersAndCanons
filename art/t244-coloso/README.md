# T244 · Coloso y Pedazo

**PROVISIONAL: pendiente de aprobación artística de Lucas.** El despacho autoriza esta entrega para no frenar T234; no cierra la compuerta artística. Conserva `colossus` y `colossus_shard` de RF-481/D-092. [Vista animada](preview.html), [prompts](prompts.md), [fuentes intactas](sources/) y [manifiesto](manifest.json).

El cuerpo es basalto cálido facetado, sin cara, ojos, gesto, escudo ni marca de los Moradores. Comparte el material rocoso del Guardián con tonos más oscuros y vetas ámbar apagadas. El Pedazo es una lasca aguda con dos apoyos finos: baja y rápida, sin anatomía de bestia. La corona y las sombras que aparecen en las capturas las dibuja el juego; no están incrustadas en los PNG. No hay pose de ruptura.

## Entrega para T234

En esta rama todavía no existen los dos `.tres`: **no se crearon**. T234 conserva sus ids y estadísticas de RF-481; estos son únicamente parámetros visuales propuestos:

| ID | `texture` | `walk_atlas` | `walk_stride_tiles` | `walk_art_scale` | `visual_scale` |
|---|---|---|---:|---:|---:|
| `colossus` | `res://assets/sprites/enemies/rendered/colossus.png` | `res://assets/sprites/enemies/rendered/colossus_walk.png` | 1.1 | 1.0 | 1.8 |
| `colossus_shard` | `res://assets/sprites/enemies/rendered/colossus_shard.png` | `res://assets/sprites/enemies/rendered/colossus_shard_walk.png` | 0.55 | 1.0 | 1.2 |

Ambos: `flip_when_walking_left = false`. Estáticas RGBA 256×256; atlas RGBA 1024×1024, cuatro fases por fila: derecha/abajo/izquierda/arriba. 16 poses propias por atlas, sin reflejar. Misma escala de empaquetado dentro de cada especie; pies a y=191 y márgenes transparentes. La estática es la primera pose derecha, por eso `walk_art_scale = 1.0`. Importación con mipmaps.

La escala 1.8 del cuerpo sobre `size_tiles = 0.5` produce cerca de dos veces el alto del Guardián (`0.38 × 1.2`), comprobado en captura; no cambia radio lógico. El arte ocupa aproximadamente 90×102 px lógicos (según vista) sobre casillas de 64 px: sobresale de una casilla, pero no cubre dos casillas enteras. T234 debe revisar la barra de vida dañándolo en el combate real. El Pedazo usa radio 0.3 y escala 1.2. A sus velocidades RF-481, un ciclo tarda 2.2 s para el cuerpo y 0.55 s para el Pedazo; lo gobierna la distancia, no un temporizador de lógica.

## Revisión en contexto

Orden de las hojas: **Coloso / Pedazo / Guardián / Soberano / Tanque**. [34 px](captures/contact_34.png), [64 px](captures/contact_64.png), [112 px](captures/contact_112.png), [220 px](captures/contact_220.png): filas sobre suelo y camino de pradera. Son encuadres iguales para comparar material y silueta, no tamaños relativos de campaña.

[Cuatro direcciones, fase 0](captures/game_step_0.png), [fase 1](captures/game_step_1.png), [fase 2](captures/game_step_2.png), [fase 3](captures/game_step_3.png): escena de partida **real del nivel 1**, en Godot con ventana OpenGL sobre GTX 1660 SUPER, viewport 1777×1000. Instancias reales de `Enemy` en caminos de exposición, con las fases avanzadas por distancia y reposicionadas para comparar. **No es el nivel 15 ni una oleada jugada**; no demuestra spawn, división, escolta, balance ni victoria. El guardado usado es `user://test_t244_capture.json`. Las cuatro filas permiten revisar también luz, espalda y lectura del Pedazo; el render no usa espejo.

Se inspeccionaron las fuentes, la hoja grande y las capturas en contexto. Al reducir a 34 px, los detalles de vetas se subordinan a la silueta. No se declara modelado 3D real: las hojas generadas tienen variación sutil de facetas entre fases y el Pedazo frontal/posterior se diferencia menos que de lado. Lucas puede pedir correcciones antes de aprobar.

## Reproducir

```bash
godot --headless -s art/t244-coloso/pack.gd
godot --headless --import
godot --headless -s art/t244-coloso/contact.gd
godot --path . --resolution 1777x1000 --position 20,30 art/t244-coloso/capture.tscn
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

`pack.gd` aísla las 16 figuras por conectividad alfa y normaliza sin repintar; rechaza un conteo distinto. Las fuentes originales se conservan sin modificar. El manifiesto guarda dimensiones, escala y rutas. Los tests usan copias aisladas de `EnemyData` hasta que T234 cree los `.tres`, sin agregar tipos al catálogo de campaña ni modificar balance.

## Límites

Pendientes aprobación artística, integración de T234 y captura del combate final con barra de vida, división real y tres Pedazos. No se probaron Windows, Android físico, balance, partida humana, FPS ni exportaciones. No hubo lógica ni datos jugables modificados. Los resultados completos de importación, empaquetado, captura y GUT quedan en `validation/`.

## Resultado de validación

Línea de base: **1401/1401 tests**, 12577 asserts, 101 scripts. Final: **1401/1401 tests**, 12765 asserts, 101 scripts; **0 `SCRIPT ERROR` y 0 `Parse Error`**. Se ampliaron las listas de regiones, ciclos, transparencia y ralentización en `tests/test_enemy_visual.gd` para ambos ids; el Coloso queda exceptuado de la escala fija 1.2. En GUT aparecieron los dos `ERROR` conocidos de la línea de base permitida: `no_existe` y `resources still in use`; las herramientas de empaquetado y hojas de contacto mostraron el aviso conocido `resources still in use` al salir, sin afectar los PNG. No hubo SVG ajenos reescritos por la importación que restaurar. Empaquetado y captura terminaron sin `SCRIPT ERROR`/`Parse Error`. `Image.load_from_file` avisa que estas herramientas de preparación no son aptas para exportación; el juego consume texturas importadas con `preload`.
