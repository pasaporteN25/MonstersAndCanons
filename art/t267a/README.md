# T267a · Propuesta visual aislada

**Para elegir, sin producción final ni integración.** Informe principal: [T267a-propuesta-assets.md](../../specs/tareas/informes/T267a-propuesta-assets.md). Abrir [comparison.html](comparison.html) para alternar las capturas a tamaño nativo.

## Criterio, decisión y plan de esta propuesta

**Refs:** B-38/T267, guía de arte, inventario T267a y antecedentes T233/T260/T261. No se agrega comportamiento jugable ni se crean RF/D: esta es la etapa de revisión previa que B-38 exige. **Dado** el estado integrado → **Cuando** Lucas compara las cinco prioridades en sus mapas y a 34 px → **Entonces** puede aceptar, rechazar o combinar muestras antes de autorizar producción.

Se conservan los suelos que Lucas prefirió, las flores y las rutas/lienzos de los recursos existentes. Se descarta repetir masivamente T260/T261 o confundir archivos entregados con dibujos conectados. Mina, bosque explotable y escombros usan copias exactas de SVG existentes como prueba de conexión visual; Central y estatua tienen bocetos vectoriales nativos nuevos, con caras iluminadas y laterales oscuros, solo en esta carpeta. No hubo generación raster ni prompts de imagen: `build_samples.py` es la fuente reproducible. Los bocetos todavía no igualan el acabado renderizado de las torres y no representan aprobación artística.

Plan: inventario → capturas de mapas y combate → diagnóstico por pieza → cinco pruebas aisladas → comparación en casillas reales → importación, GUT y check-only → informe y commit. La selección y la integración de T267 siguen pendientes.

## Qué contiene

- `capture.gd` / `capture.tscn`: instancia la escena real de partida, datos reales y cámara real de diez niveles. Renderiza a **1280×720 exactos** en un `SubViewport`, presentado en la ventana OpenGL; evita que el gestor de ventanas agrande la captura a 1777×999. No es un mapa reconstruido con Pillow.
- `sample_decor.gd`: subclase local de `LevelDecor`, conectada **solo por la escena de revisión**. Alterna con la decoración actual, preservando terreno, semilla por casilla, cámara, marcas y velo/reserva de extracción. No modifica `LevelDecor`, datos, escenas exportadas ni `assets/`.
- `samples/`: tres SVG existentes copiados sin cambios; estatua y cuatro cuartos de Central de prueba. Todos de 64×64. Central ensamblada de 128×128 en `sources/central_master_sample.svg`.
- `sources/`: originales preservados para las cinco piezas; el manifiesto registra hashes y destinos futuros, **sin conectarlos**.
- `map_metadata.json`: tema, tamaño real de casilla y coordenadas de las piezas/actores usados para recortar comparaciones.
- `contact.gd`: rasteriza las fuentes de estatua/Central a 220 y 112 px para las hojas complementarias.
- `build_review.py`: compone hojas y recortes desde las capturas, sin retocar el contenido del juego.
- `validation/`: salidas completas. Los archivos `capture_before_import`, `capture_array_error` y `capture_scope_error` son intentos fallidos de preparación, conservados por transparencia; **no son validación verde**. El resultado válido es `capture.txt`.

## Reproducir

Desde la raíz del proyecto, con Godot 4.7.2, Python 3 y Pillow:

```bash
python3 art/t267a/build_samples.py
godot --headless --import
XDG_DATA_HOME=/tmp/t267a-user godot --path . --resolution 1280x720 --position 20,30 art/t267a/capture.tscn
godot --headless -s art/t267a/contact.gd
python3 art/t267a/build_review.py
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
for f in tools/*.gd; do godot --headless --check-only -s "$f"; done
```

La escena usa datos de usuario separados por `XDG_DATA_HOME` y `user://test_t267a_capture.json`. Se marcan enemigos como vistos para evitar carteles que tapen el mapa. `current`/`proposal` son el mismo mapa en preparación, sin construir ni alterar recursos, pausado para mantener igualdad. `combat` arranca realmente la primera oleada, compra hasta tres torres con 2000 de oro de ayuda y espera tres segundos; no verifica la dificultad ni una partida humana completa. `working` habilita la extracción y adelanta un trabajo al 40 % mediante las APIs reales, con el mundo detenido. En la propuesta se conserva el mismo SVG de extracción al activarse: los estados finales no se producen acá.

`diagnostic` inserta actores reales adicionales, distribuidos por distancia sobre el recorrido terrestre real y congelados en una fase de caminar. No es la oleada natural del Coloso ni de la Cuadrilla. No se validan así sus ataques, la división del Coloso, todas las direcciones ni una victoria. `infrastructure` muestra la pestaña y selección reales del juego.

Las hojas resumen reducen el mapa y lo indican. Los PNG de partida y los recortes comparativos mantienen los píxeles originales; la hoja de 34 px normaliza una casilla a 34 px y la Central a dos casillas de 34 px: es una prueba de lectura adicional, no otra resolución de partida. Los enemigos de la hoja se normalizan por su cuerpo a 34 px y no representan sus tamaños relativos de combate. Usar `diagnostic` para evaluar esos tamaños reales.
