# M29 · Muestras aprobadas integradas

La partida usa los trece monstruos renderizados con+20% visual. Normal/Rápido/Tanque caminan con48 poses existentes (M25), por distancia y cuatro direcciones; Volador usa cuatro poses M28 con cabeza estabilizada. Nueve restantes: pose fija, sin bamboleo ni aplastamiento del cuerpo. Todos conservan sus reglas y radios.

## Montaje C
Fuentes generadas con la herramienta integrada `image_gen.imagegen`; prompts exactos y referencias en `prompts.json`. `sources/bases.png` contiene tres asientos fijos; `sources/cannon_mount.png`,24 mecanismos, cuatro columnas/seis filas, ocho direcciones por nivel. Luz fija arriba a la izquierda. `pack_mount.gd` recorta por conectividad de alfa, ordena por filas y normaliza128px sin modificar las fuentes. Produce bases y atlas en `assets/sprites/towers/rendered/`. Las otras ocho torres conservan los mecanismos M23/M27 sobre los nuevos asientos con contacto y offset compartido.

## Reproducir
- `godot --headless --path . -s art/redesign-m29/pack_mount.gd`
- `godot --headless --import`
- `godot --path . --resolution 1920x1080 art/redesign-m29/capture.tscn`
- Las capturas usan escenas y recursos de producción, sin aumentar la escala de los nodos ni reemplazar datos. `motion_00` a `motion_23` son cuadros originales; `motion.gif` es su codificación para revisión.

Ventana objetivo1920×1080 limitada al área útil; mapa/UI1280×720 escalados juntos. Pantalla completa usa la resolución del monitor. Respeta resolución explícita de herramientas, headless y móvil. Revisado visualmente en Windows; Linux/celular no ejecutados. La descripción del PR queda a cargo de Lucas.
