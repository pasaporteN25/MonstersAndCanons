class_name CampaignMarks
extends RefCounted
## T507 / RF-717, RF-719: dónde van las marcas (señales) de campaña y de qué tipo. Copia el mecanismo de los postes
## (`CampaignPosts`): las posiciones son un dato visual (`data/ui/marcas_campana.json`), no parte del mapa jugable.
## Esta clase no consulta el guardado ni autoloads, y una marca no tiene efecto de juego.

const PATH: String = "res://data/ui/marcas_campana.json"

## Dónde puede ir cada tipo de marca. `SIGNAL`: sobre la casilla de leyenda de una señal (`roca_marcada` o
## `simbolo_ruina`), de la que forma parte (un solo ítem de dos capas). `FREE`: sobre una casilla `X` libre,
## de la que oculta el ítem de atrás (como el poste).
enum Support { SIGNAL, FREE }

const GRABADA: StringName = &"grabada"
const ESTELA: StringName = &"estela"
const PINTADA: StringName = &"pintada"

## Dibujos de leyenda que son una señal (la roca de la casilla).
const SIGNAL_DRAWINGS: PackedStringArray = ["roca_marcada", "simbolo_ruina"]

## Los tipos aprobados por Lucas (T506, 2026-10-26). `texture` es null mientras no exista el arte aprobado: un tipo
## sin arte se lee del dato pero no se dibuja. Estela y pintada están definidas, sin ninguna ubicación cargada.
static var _types: Dictionary = {
	GRABADA: {"support": Support.SIGNAL, "texture": preload("res://assets/sprites/map/rendered/mark_engraved_g2.png")},
	ESTELA: {"support": Support.FREE, "texture": null},
	PINTADA: {"support": Support.FREE, "texture": null},
}


## Los tipos definidos, en el orden de declaración.
static func type_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id: StringName in _types:
		ids.append(id)
	return ids


static func is_known_type(type_id: StringName) -> bool:
	return _types.has(type_id)


## Dónde va el tipo (`Support`); `FREE` si el tipo no existe (nadie lo pregunta sin antes mirar `is_known_type`).
static func support_of(type_id: StringName) -> Support:
	return (_types[type_id] as Dictionary)["support"] if _types.has(type_id) else Support.FREE


## El dibujo del tipo, o null si todavía no tiene arte aprobado.
static func texture_of(type_id: StringName) -> Texture2D:
	return (_types[type_id] as Dictionary)["texture"] if _types.has(type_id) else null


## Marcas de un nivel como casilla → tipo (vacío si el id no tiene marcas o el dato falta o está dañado). Una entrada mal
## formada, de tipo desconocido o repetida en la misma casilla se ignora: gana la primera.
static func marks_for(level_id: StringName, path: String = PATH) -> Dictionary:
	var marks: Dictionary = {}
	var entries: Variant = _levels(path).get(String(level_id), [])
	if not entries is Array:
		return marks
	for entry: Variant in entries:
		if not entry is Dictionary:
			continue
		var cell_value: Variant = (entry as Dictionary).get("casilla", null)
		var type_value: Variant = (entry as Dictionary).get("tipo", null)
		if not cell_value is Array or (cell_value as Array).size() != 2 or not type_value is String:
			continue
		var raw: Array = cell_value
		if not _is_int(raw[0]) or not _is_int(raw[1]) or not is_known_type(StringName(type_value as String)):
			continue
		var cell := Vector2i(int(raw[0]), int(raw[1]))
		if not marks.has(cell):
			marks[cell] = StringName(type_value as String)
	return marks


## Ids de nivel que tienen marcas, en el orden del archivo.
static func level_ids(path: String = PATH) -> PackedStringArray:
	return PackedStringArray(_levels(path).keys())


## Cantidad total de marcas válidas del dato (o de un tipo, si se pide).
static func total_count(path: String = PATH, type_id: StringName = &"") -> int:
	var total: int = 0
	for id: String in level_ids(path):
		var marks: Dictionary = marks_for(StringName(id), path)
		for cell: Vector2i in marks:
			if type_id == &"" or marks[cell] == type_id:
				total += 1
	return total


static func _levels(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	var text: String = file.get_as_text()
	file.close()
	if json.parse(text) != OK or not json.data is Dictionary:
		return {}
	var levels: Variant = (json.data as Dictionary).get("niveles", {})
	return levels if levels is Dictionary else {}


static func _is_int(value: Variant) -> bool:
	return (value is int) or (value is float and is_equal_approx(value, roundf(value)))
