# M26 · Fondos y segunda tanda aprobada

Lucas aprobó Blindado, Troll, Volador, Araña y Cría de M25 y pidió mejorar o rediseñar los fondos con libertad para proponer cambios después. Se prepararon recursos nuevos y escenas de revisión; no se alteró la integración de Claude.

## Recursos

- **Siete suelos**: pradera, desierto, nieve, volcán, bosque, pantano y ruinas.
- **Un camino** de tierra compactada para combinar con los paisajes.
- **Cinco objetos**: dos grupos de rocas, árbol, arbusto y puerta de piedra.
- **Cinco monstruos aprobados enmarcados**: copias estáticas compatibles con el formato de M24, desde fuentes de M25 intactas.

Fondos más tranquilos que las unidades, con volumen en los objetos y luz arriba a la izquierda. La grilla no está pintada en la textura: el selector de construcción puede superponerla cuando haga falta. Materiales de piedra, tierra, madera y vegetación coherentes con las torres y el logo.

## Archivos para revisar

- `terrain_sheet.png`: ocho materiales repetidos 4×4, a 64 px, con tres unidades sobre el camino.
- `props_sheet.png`: cinco objetos ampliados y sobre terreno a 64 px.
- `before.png` y `map_preview.png`: comparación sobre el mismo Game de Godot con las mismas torres y retratos estáticos de monstruos.
- `menu_preview.png`: MainMenu de Godot con la nueva pradera detrás del logo y controles existentes.
- `HANDOFF_CLAUDE.md`: integración en terreno, leyendas, salida, mapas, editor y menú.
- `sources/` y `prompts.json`: fuentes y prompts de la herramienta integrada image_gen.
- `manifest.json`: tamaños, pivotes y rutas de los fondos preparados.

## Reproducción

Usar datos de usuario aislados (APPDATA) antes de ejecutar Godot:

```powershell
godot --headless --path . -s art/redesign-m26/prepare_backgrounds.gd
godot --headless --path . -s art/redesign-m26/prepare_accepted_monsters.gd
python art/redesign-m26/make_previews.py
godot --path . art/redesign-m26/capture_backgrounds.tscn
```

Se guardan ocho texturas opacas de 256×256 con continuidad de color comprobada en los lados opuestos; objetos RGBA de 128×128 con suelo en (64,116); monstruos de 256×256 con el marco y pivote de la herramienta existente de M24. Los PNG de fondo se suavizan en una franja de 16 px en los bordes para evitar cortes al repetirlos. Los objetos se achican con alfa premultiplicado para evitar halos. Las fuentes originales no se reescriben.

## Validación y límites

Empaquetadores y escenas de muestra ejecutados con salida 0; revisados los siete suelos en mosaico, el mapa y el menú. Comprobados tamaños, opacidad de suelos, transparencia de objetos y continuidad horizontal/vertical. **872/872 tests, 6726 asserts, sin SCRIPT ERROR ni Parse Error.** Persisten avisos previos del motor sobre certificados y dos objetos/un recurso al cerrar.

Las muestras no son una integración de producción: usan instancias locales, sin cambios de lógica, rutas, colisiones o balance. Las unidades del mapa son retratos estáticos de contraste. No se exportó un nuevo ejecutable. Los siete suelos están preparados, pero el visor de mapa muestra la pradera; leyendas de agua/hielo/lava/barro y objetos específicos de los demás paisajes conservan su arte anterior hasta otra tanda. No se probaron todos los niveles ni zooms, Android o rendimiento con grandes oleadas.

Los cinco monstruos físicos quedan **aprobados**; sus nuevas copias están listas para la integración estática de Claude. Sus animaciones todavía no se produjeron. Los atlas de locomoción de los tres primeros elegidos siguen en `art/redesign-m25/atlases/`.

Actualización T167: los fondos y cinco objetos ya están integrados en producción (RF-334). Los monstruos preparados y las animaciones siguen pendientes de integración.
