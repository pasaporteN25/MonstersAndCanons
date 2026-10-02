# M24 · Tanda 1, propuestas para revisar

Seis monstruos nuevos: variantes A/B de Normal, Rápido y Tanque. Dos hojas de evoluciones de tres niveles para Cañón e Hielo y una corrección del logo a **Monsters & Canons**, con una sola N entre A y O.

- `monsters_comparison.png`: A arriba, B abajo; cuerpos ampliados y lectura pequeña sobre verde.
- `upgrades_comparison.png`: tres niveles de cada torre, ampliados y con las bases actuales a 64 px.
- `menu_preview.png`: captura real de Godot; logo puesto solo en una instancia de muestra del menú.
- `map_preview.png`: captura real de Godot; criaturas estáticas de comparación junto a tres torres. No es una captura de enemigos animados o combate.
- `sources/`: PNG originales con alfa, generados mediante la herramienta integrada image_gen; excluidos de importación por `.gdignore`.
- `prompts.json`: prompts y referencias usados. El logo necesitó una segunda corrección de texto: eliminar una de las dos N consecutivas, conservando composición, materiales y transparencia.

Recomendación artística inicial: Normal B para destacar sobre el verde, Rápido A por su postura baja y Tanque A por su carácter orgánico. Tanque B podría reservarse como identidad de un monstruo volcánico más adelante; sus grietas naranjas no deben confundirse con el estado quemado.

Todavía faltan selección de Lucas, vistas por dirección, animación y pruebas de estados. Las evoluciones son referencias de una sola dirección; el nivel 1 generado presenta pequeñas variaciones y en producción se conservará el original aprobado. No se modificaron datos, escena principal, stats ni recursos de producción. El logo todavía no se aplica al menú habitual.

Para reproducir: ejecutar `make_previews.py` con Pillow y abrir `capture_menu.tscn` con Godot y APPDATA aislado. Las muestras de `art/` ya están excluidas de las exportaciones del proyecto.
