# M27 · Evoluciones y cinco especiales

Entrega artística para revisión; **no integrada en producción**. Generada con la herramienta integrada `image_gen`, con los atlas M23 y el Tanque M24 como referencias. Prompts finales en `prompts.json` y originales seleccionados en `sources/`.

- Nueve torres, niveles 2 y 3: 18 atlas RGBA512×256, ocho cuadros 128×128 por atlas; 144 cuadros distintos. Orden E, SE, S, SO, O, NO, N, NE. El nivel 1 conserva su archivo original.
- 18 iconos del mecanismo mirando hacia arriba (N), RGBA 128; no incluyen la base.
- Guardián, Curandero, Chamán, Espejo y Jefe: cinco conceptos estáticos RGBA 256, preparados con el mismo enmarcado que M24. No son animaciones.
- `validation.json`: tamaño, contenido, cuadros distintos y márgenes. `manifest.json`: contrato de formato.
- `previews/evolutions_godot.png`: niveles 1/2/3 ampliados. `preview.tscn`: visor que recorre las ocho vistas.
- `previews/evolutions_map.png`: escenas reales Tower sobre el mapa, filas nivel 1/2/3, columnas Cañón, Básica, Múltiple, Francotirador, Ráfaga, Fuego, Mortero, Hielo, Tesla.
- `previews/special_monsters.png`: conceptos ampliados y lectura a 34 px. `previews/special_monsters_map.png`: escenas reales Enemy, incluidas auras y corona.

Las capturas usan copias temporales de datos: no son una integración ni una partida de balance. No se cambiaron habilidades, estadísticas, proyectiles ni puntos de salida. Las evoluciones son discretas; en algunas familias la diferencia entre niveles 2/3 es pequeña. Los sprites generados pueden variar ligeramente entre vistas: no son renders de un modelo 3D único. Revisar apuntado/retroceso en combate al integrar. Pendientes de los cinco especiales: vistas de caminar, golpe y desaparición. No se exportó un nuevo ejecutable.

## Reproducir la preparación

Desde el proyecto, ejecutar Godot con `-s art/redesign-m27/pack_upgrades.gd`, luego `-s art/redesign-m27/prepare_specials.gd`. Para capturas, abrir `preview.tscn -- --capture`, `preview_specials.tscn` y `capture_game.tscn`.

Los subdirectorios tienen `.gdignore` para no importar fuentes y muestras como recursos de producción. Los visores cargan los PNG mediante ImageTexture.
