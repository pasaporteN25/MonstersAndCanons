# Acceso a los mapas de Asedio (M76, RF-692, RF-693, D-201). Lógica pura: no toca escenas ni el guardado.
# En el modo normal, el mapa N de Asedio se abre al completar el mismo mapa de la campaña, o por un derecho
# heredado de un guardado viejo que ya había jugado Asedio. Ganar un Asedio no abre el siguiente.
class_name SiegeAccess
extends RefCounted

## Id del único modo oficial al que aplica esta regla.
const MODE_ID: StringName = &"asedio"


## ¿Es este modo el Asedio oficial? Un modo propio con otro id (o roto) nunca usa esta regla.
static func applies_to(mode: Dictionary) -> bool:
	return mode.get("id", &"") == MODE_ID and mode.get("official", false) == true


## Los ids de nivel (`modo_asedio_*`) de los mapas jugables del modo, en orden.
static func valid_ids(mode: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	var maps: Array = mode.get("maps", [])
	for index: int in maps.size():
		var level: LevelData = ModePacks.map_level(mode, index)
		if level != null:
			ids.append(String(level.id))
	return ids


## RF-692: ¿se puede jugar el mapa `index`? `campaign_completed` recibe el id del nivel de la campaña que
## comparte archivo con ese mapa; `legacy` es la lista heredada del guardado. (El modo de pruebas lo resuelve GameFlow.)
static func is_open(mode: Dictionary, index: int, campaign_completed: Callable, legacy: Array) -> bool:
	var level: LevelData = ModePacks.map_level(mode, index)
	if level == null:
		return false
	if legacy.has(String(level.id)):
		return true
	return campaign_completed.call(StringName(mode["maps"][index]["file"]))


## RF-693: ¿hay evidencia de que este archivo jugó Asedio? Cuenta un registro persistido de un mapa válido con
## `unlocked`, `completed`, `best_lives`/`best_score` o una tabla de récords no vacía. Nada más: el acceso
## implícito al primer mapa sin registro no es evidencia.
static func has_evidence(valid: Array[String], levels: Dictionary, scores: Dictionary) -> bool:
	for id: String in valid:
		var entry: Variant = levels.get(id)
		if entry is Dictionary:
			var record: Dictionary = entry
			if bool(record.get("unlocked", false)) or bool(record.get("completed", false)) \
					or int(record.get("best_lives", 0)) > 0 or int(record.get("best_score", 0)) > 0:
				return true
		var table: Variant = scores.get(id)
		if table is Array and not (table as Array).is_empty():
			return true
	return false


## RF-693: los accesos que daba la regla vieja (RF-390) con el progreso de este archivo: el primer mapa jugable,
## cada mapa explícitamente habilitado o completado y el siguiente jugable a cada uno completado.
static func legacy_access(mode: Dictionary, levels: Dictionary) -> Array[String]:
	var open: Array[String] = []
	var maps: Array = mode.get("maps", [])
	var first: int = -1
	for index: int in maps.size():
		var level: LevelData = ModePacks.map_level(mode, index)
		if level == null:
			continue
		if first < 0:
			first = index
			open.append(String(level.id))
		var entry: Variant = levels.get(String(level.id))
		if not entry is Dictionary:
			continue
		var record: Dictionary = entry
		if bool(record.get("unlocked", false)) or bool(record.get("completed", false)):
			if not open.has(String(level.id)):
				open.append(String(level.id))
		if bool(record.get("completed", false)):
			var next: int = ModePacks.next_playable(mode, index)
			if next >= 0 and not open.has(String(ModePacks.map_level(mode, next).id)):
				open.append(String(ModePacks.map_level(mode, next).id))
	return sort_by_map(mode, open)


## Los ids de `raw` que son mapas jugables del modo, sin repetidos y en el orden del modo. Ignora lo demás.
static func sanitize(mode: Dictionary, raw: Variant) -> Array[String]:
	var wanted: Array[String] = []
	if raw is Array:
		for item: Variant in raw:
			if item is String:
				wanted.append(item)
	return sort_by_map(mode, wanted)


static func sort_by_map(mode: Dictionary, ids: Array[String]) -> Array[String]:
	var sorted: Array[String] = []
	for id: String in valid_ids(mode):
		if ids.has(id):
			sorted.append(id)
	return sorted
