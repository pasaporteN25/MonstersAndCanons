# T261 · Suelo y terrenos

**Provisional, pendiente de aprobación artística de Lucas.** Pedido del 2026-10-11: pulir los terrenos con el lenguaje vectorial de la guía, más detalle, sombras suaves y variedad, conservando tono, colores base, rutas y tamaños. Referencias: RF-334, D-051 y `specs/05-guia-de-arte.md` §4–5. No cambia ninguna regla jugable.

## Criterio y decisión antes de dibujar

**Dado** cualquiera de los siete biomas y su camino, **cuando** se repiten las baldosas, **entonces** el material conserva su familia de color, no presenta líneas de cuadrícula ni costuras y el camino sigue siendo legible. **Dadas** las flores a 34 px, **cuando** se revisa el catálogo, **entonces** se distinguen pétalos, centros y follaje sin parecer un bloqueo.

Se conserva D-051: reemplazar únicamente los ocho PNG activos de `assets/tiles/rendered/` y el SVG existente de flores. Se descarta modificar el TileSet, inventar variantes conectadas, repintar la decoración asignada a otras tareas o cambiar paletas en código. Los PNG tendrán fuentes SVG nativas, rasterizadas a sus 256×256 originales. Las flores conservan lienzo 64×64 y transparencia. Los detalles del terreno tienen continuidad periódica; el sombreado será mediante rellenos y reflejos, sin filtros ni contornos gruesos.

## Plan y tarea

- [x] Guardar fuentes exactas del antes y hashes; hojas a 220 y 34 px.
- [x] Crear los siete materiales y el camino, rehacer flores y revisar mosaicos 3×3.
- [x] Comprobar dimensiones, alfa y continuidad en los bordes.
- [x] Importar con Godot y ejecutar toda la suite de GUT sin `SCRIPT ERROR` ni `Parse Error`.
- [x] Revisar `git status`, restaurar reescrituras ajenas del import y crear un único commit T261.

**Hecho cuando:** nueve recursos conservan contratos, hojas antes/después y mosaicos están disponibles, validación técnica pasa y se informa explícitamente que falta la aprobación visual de Lucas.

## Integración encontrada

`git grep` ubica las precargas en `scripts/logic/map_themes.gd` y `scripts/logic/map_drawings.gd`. `scenes/levels/level_decor.gd` pinta cada textura sobre la casilla lógica. Agua, hielo, lava y barro se pintan con primitivas desde ese archivo, igual que los bordes exteriores del camino y de las manchas de leyenda. **No existen tiles independientes de agua/bordes para retocar sin tocar código**: se mantienen como están. El atlas `assets/tiles/tiles.png` es la base lógica histórica, cubierta por estos suelos; se conserva.

## Resultado

Se refinaron **nueve recursos**: siete suelos, el camino y las flores. Pradera con brotes asimétricos; bosque con hojas secas; arena con ondulaciones; nieve con reflejos bajos; basalto con grietas angulosas; pantano con manchas húmedas; ruinas con dovelas alternadas; camino con guijarros discretos. Flores con cinco corolas de pétalos superpuestos, centros iluminados y follaje de tres tonos. Los suelos son deliberadamente tranquilos para que la decoración y las unidades sigan dominando.

**Verificación:** Godot 4.7.2 importó con salida 0; GUT dio **1569/1569 tests, 18645 asserts, 113 scripts, 0 `SCRIPT ERROR` y 0 `Parse Error`**, salida 0. Los nueve contratos pasan `validate_assets.py`; ocho texturas opacas 256×256 con muestras opuestas idénticas (diferencia 0); las flores siguen SVG 64×64 con alfa, cinco degradés de tres paradas, sin filtros, texto ni imágenes incrustadas. El cambio máximo de media RGB por canal es 1,11 sobre 255: se conservó la paleta media exacta de cada fuente histórica como base. `git diff --check` pasó. El import no reescribió ningún recurso ajeno: no hubo nada que restaurar.

Persisten los mensajes esperados de la suite: nivel `no_existe`, catálogo de removibles inválido y guardados ilegibles provocados por los tests, además de huérfanos GUT y el aviso de dos objetos/un recurso al cerrar. La importación avisa que no hay daemon ADB en tcp:5037; terminó correctamente. El rasterizador Rsvg avisa que `get_pixbuf` está deprecado; las imágenes se generaron correctamente. No se ocultaron esas salidas: están en `validation/*.txt`.

### Revisión visual

Abrir [comparison.html](comparison.html): antes/después a **220 y 34 px**, y mosaicos **3×3 a 64 px**. Se revisaron visualmente las tres escalas: no aparecen costuras ni marcos entre tiles. `manifest.json` conserva rutas, orden y hashes de ambas versiones; `sources/before/` guarda las fuentes exactas anteriores y `sources/after/` los nuevos SVG nativos.

Además, [after/context_sheet.png](after/context_sheet.png) resume capturas reales de los niveles **1, 6, 7, 8 y 10**, tomadas en ventana de **1777×1000** mediante OpenGL con la herramienta existente de T249 y guardado separado `user://test_t249_capture.json`. Se revisó el camino continuo y las flores en el nivel 1, y los terrenos de bosque (niveles 6 y 7), ruinas y desierto. Las tomas `working`, `cleared` y `disruptor_toolbar` son las muestras que esa herramienta ya produce: no implican cambios de arte en esos objetos ni pruebas de balance. Los PNG individuales son el viewport del juego; las hojas de contacto son bancos de muestras rotulados.

**Falta:** aprobación artística de Lucas, prueba humana de combate, captura contextual de nieve/volcán/pantano, comparativa de todos los enemigos sobre todos los biomas, revisión de los 15 mapas, exportación Windows/Android y medición de FPS. El agua y los bordes siguen sin modificaciones por el límite de no tocar código; se informa para coordinar una futura iteración si Lucas la pide. No se hizo push.

### Reproducir

Dependencias locales: Python 3, Pillow, PyGObject y librsvg (disponibles en esta máquina). Desde la raíz:

```bash
python3 art/t261-ground/refine_vectors.py
python3 art/t261-ground/validate_assets.py
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
godot --path . --resolution 1777x1000 --position 20,30 art/t249-mejoras/capture.tscn -- phase=../t261-ground/after
```

El generador conserva el antes la primera vez; posteriores ejecuciones reproducen el después sin sobrescribir esas fuentes. La hoja contextual se compuso desde las cinco capturas originales mediante Pillow, sin editar los dibujos del juego.
