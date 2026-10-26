class_name CampaignPosts
extends RefCounted
## T475 / RF-696, RF-697: dónde van los postes de campaña (veinte en los quince niveles) y qué variante muestran.
## Las posiciones son un dato visual (`data/ui/postes_campana.json`); no son parte del mapa jugable.
## Esta clase no consulta el guardado ni autoloads: quien arma la partida (Game) le pasa las estrellas.

const PATH: String = "res://data/ui/postes_campana.json"
## Con esta cantidad de estrellas el poste pasa a ser del jugador (D-203); con menos, sigue siendo rebelde.
const PLAYER_STARS: int = 3


## Casillas de los postes de un nivel (vacío si el id no tiene postes o el dato falta o está dañado).
static func cells_for(level_id: StringName, path: String = PATH) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var levels: Dictionary = _levels(path)
	var entries: Variant = levels.get(String(level_id), [])
	if not entries is Array:
		return cells
	for entry: Variant in entries:
		if entry is Array and entry.size() == 2 and _is_int(entry[0]) and _is_int(entry[1]):
			var cell := Vector2i(int(entry[0]), int(entry[1]))
			if not cells.has(cell):
				cells.append(cell)
	return cells


## Ids de nivel que tienen postes, en el orden del archivo.
static func level_ids(path: String = PATH) -> PackedStringArray:
	return PackedStringArray(_levels(path).keys())


## Cantidad total de postes del dato.
static func total_count(path: String = PATH) -> int:
	var total: int = 0
	for id: String in level_ids(path):
		total += cells_for(StringName(id), path).size()
	return total


## D-203: solo 3 estrellas dan el poste del jugador; no hay estado intermedio.
static func is_player_variant(stars: int) -> bool:
	return stars >= PLAYER_STARS


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
