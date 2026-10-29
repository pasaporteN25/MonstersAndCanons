class_name RecordSources
extends RefCounted
## RF-694: de dónde sale cada tabla de la pantalla de Récords. Una fuente por modo (oficial o propio), con
## los ids de tabla que el progreso ya guarda (`modo_<modo>_<mapa>`, RF-390). Nunca copia ni suma puntajes:
## solo dice qué id leer. Un modo con errores aparece con su diagnóstico y sin ningún id (no existe nada que
## leer), y un mapa que no cargó, con su motivo.

## Una fuente por modo, en el orden de `ModePacks.all` (oficiales y después propios, RF-389):
## {"id": StringName, "name": String, "errors": PackedStringArray,
##  "maps": Array[Dictionary] ({"label": String, "table_id": StringName, "error": String})}.
## `table_id` queda vacío cuando el modo o el mapa tienen errores.
static func from_modes(modes: Array[Dictionary]) -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	for mode: Dictionary in modes:
		var errors: PackedStringArray = mode["errors"]
		var maps: Array[Dictionary] = []
		if errors.is_empty():
			for i: int in (mode["maps"] as Array).size():
				var level: LevelData = ModePacks.map_level(mode, i)
				if level == null:
					var entry: Dictionary = mode["maps"][i]
					var reasons: PackedStringArray = entry["errors"]
					maps.append({"label": Localization.t_fmt(&"records.map_label", {"n": i + 1, "name": entry["file"]}), "table_id": &"",
						"error": reasons[0] if not reasons.is_empty() else Localization.t(&"records.map_failed")})
				else:
					maps.append({"label": Localization.t_fmt(&"records.map_label", {"n": i + 1, "name": level.display_name}), "table_id": level.id, "error": ""})
		sources.append({"id": mode["id"], "name": mode["name"] if errors.is_empty() else String(mode["id"]),
			"errors": errors, "maps": maps})
	return sources
