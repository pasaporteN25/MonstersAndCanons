# T281 · Nuevas propuestas de La Cuadrilla

**Sólo revisión. Lucas elige antes de integrar.** Abrir [comparison.html](comparison.html).

- Ratero B: bípedo encorvado con pieza robada; Ratero C: corredor cuadrúpedo largo. El estudio A se conserva como descarte: demasiado realista, con halo.
- Cargador A: bolsa enorme a la espalda; Cargador B: carga abrazada delante del cuerpo.
- Ciclos exploratorios de **Ratero B y Cargador A**, 1024×1024, filas derecha/abajo/izquierda/arriba, cuatro fases de 256×256. Estáticas idénticas al primer cuadro derecho. Sin espejar ni modificar parámetros jugables.

Fuentes creadas con la herramienta integrada `imagegen`, sin CLI/API ni modelo local. Prompts en `prompts.json` y `ratero_c_prompt.txt`; fuentes originales en `sources/`. No son renders de un modelo 3D compartido. Los ciclos derivan algo en anatomía y detalle; el Ratero B del ciclo queda más compacto que su concepto. La bolsa y la pose cuentan la carga del Cargador, no una embestida.

`python3 art/t281-cuadrilla/prepare.py` reproduce recortes por alfa, normalización, atlas, hojas y GIF; no repinta arte. Conserva una escala uniforme para las 16 fases de cada especie; sólo centra horizontalmente y alinea el pie a y=191 inclusive. Las hojas de 220 y 34 px comparan **lienzos completos** a igual tamaño, no representan las diferencias de `size_tiles`; la hoja de siluetas usa 34 px de **alto visible**. Las capturas usan los tamaños reales del juego.

Después de `godot --headless --import`, correr:

```bash
godot --path . --rendering-method gl_compatibility --resolution 1280x720 res://art/t281-cuadrilla/capture.tscn
python3 art/t281-cuadrilla/build_review.py
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

La escena abre `game.tscn` en un SubViewport fijo de 1280×720 con el nivel 7 original y salta a su oleada 8 mediante la función existente de pruebas. Avanza con el reloj real, sin torres; a los 3, 6 y 9 segundos pausa y guarda un par antes/después, cambiando sólo textura/atlas en duplicados de datos **en memoria**. Puede variar ligeramente el instante exacto según el rendimiento de la máquina; cada par conserva los mismos actores y posiciones. Usa `user://test_t281_capture.json`, no el progreso personal. Ni el banco de captura ni los derivados están conectados al juego.

Ver el informe en `specs/tareas/informes/T281-propuesta-cuadrilla.md` para los resultados y límites. No hay integración, validación de balance, aprobación artística, exportación ni partida humana.
