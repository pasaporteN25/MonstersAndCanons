# Lee los archivos de texto de los niveles y de la campaña (spec §7.8, RF-200 a RF-205).
# Nunca corta el juego: devuelve el nivel o la lista de errores, en castellano y con su ubicación
# ("oleada 3, grupo 2: …"). Las claves del archivo van en castellano porque lo edita una persona
# (D-031).
class_name LevelFile
extends RefCounted

const VERSION: int = 1
const LEVELS_DIR: String = "res://data/levels/"
const ENEMIES_DIR: String = "res://data/enemies/"
const CAMPAIGN_PATH: String = "res://data/campaign.json"

const LEVEL_KEYS: PackedStringArray = ["version", "nombre", "oro", "vidas", "aumento_vida", "mapa", "oleadas"]
const GROUP_KEYS: PackedStringArray = ["enemigo", "cantidad", "cada", "desde", "entrada"]
const CAMPAIGN_KEYS: PackedStringArray = ["version", "niveles"]


## Lee el archivo de un nivel. El id del nivel es el nombre del archivo (RF-200).
## Devuelve {"level": LevelData o null, "errors": PackedStringArray, "warnings": PackedStringArray}
## (los avisos, RF-207, no impiden jugar).
static func load_level(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failed(["No existe el archivo %s." % path])
	return parse(FileAccess.get_file_as_string(path), StringName(path.get_file().get_basename()))


## Lee el texto de un nivel. Devuelve {"level": LevelData o null, "errors": PackedStringArray}.
static func parse(text: String, id: StringName) -> Dictionary:
	var errors: PackedStringArray = []
	var root: Variant = _parse_json(text, errors)
	if not errors.is_empty():
		return _failed(errors)
	if not root is Dictionary:
		return _failed(["El archivo tiene que empezar con { y terminar con }."])
	var data: Dictionary = root
	_check_keys(data, LEVEL_KEYS, "", errors)
	_check_version(data, errors)

	var level := LevelData.new()
	level.id = id
	level.display_name = _text(data, "nombre", "", errors)
	level.starting_gold = _whole(data, "oro", "", 0, errors)
	level.starting_lives = _whole(data, "vidas", "", 1, errors)
	if data.has("aumento_vida"):
		level.health_scale_percent_per_wave = _whole(data, "aumento_vida", "", 0, errors)

	var grid: MapGrid = null
	if not data.has("mapa"):
		errors.append("Falta \"mapa\".")
	elif not _is_list_of_text(data["mapa"]):
		errors.append("mapa: tiene que ser una lista de filas entre comillas, como [\"....\", \"A###\"].")
	else:
		level.map_rows = PackedStringArray(data["mapa"])
		grid = MapGrid.parse(level.map_rows)
		for problem: String in grid.errors:
			errors.append("mapa: " + problem)
		if not grid.is_valid():
			grid = null

	if not data.has("oleadas"):
		errors.append("Falta \"oleadas\".")
	elif not data["oleadas"] is Array or (data["oleadas"] as Array).is_empty():
		errors.append("oleadas: tiene que ser una lista con al menos una oleada.")
	else:
		var waves: Array = data["oleadas"]
		for w: int in waves.size():
			level.waves.append(_read_wave(waves[w], "oleada %d" % (w + 1), grid, errors))

	if not errors.is_empty():
		return _failed(errors)
	var warnings: PackedStringArray = []
	for problem: String in grid.warnings:
		warnings.append("mapa: " + problem)
	return {"level": level, "errors": errors, "warnings": warnings}


## La campaña (RF-205): los niveles de `campaign.json`, en orden. Un nivel inválido se saltea
## y su error queda en el registro (RF-204): el resto del juego sigue andando.
static func load_campaign(path: String = CAMPAIGN_PATH) -> CampaignData:
	var campaign := CampaignData.new()
	for level_id: String in campaign_ids(path):
		var result: Dictionary = load_level(LEVELS_DIR + level_id + ".json")
		if result["level"] == null:
			push_error("El nivel %s tiene errores y no se va a jugar:\n- %s" % [level_id, "\n- ".join(result["errors"])])
			continue
		for warning: String in result["warnings"]:
			push_warning("El nivel %s tiene un aviso: %s" % [level_id, warning])
		campaign.levels.append(result["level"])
	return campaign


## Los ids de la lista "niveles" de la campaña. Si el archivo está mal, lo anota y devuelve [].
static func campaign_ids(path: String = CAMPAIGN_PATH) -> PackedStringArray:
	var errors: PackedStringArray = []
	var root: Variant = _parse_json(FileAccess.get_file_as_string(path), errors) \
		if FileAccess.file_exists(path) else null
	if root == null and errors.is_empty():
		errors.append("No existe el archivo.")
	elif root is Dictionary:
		_check_keys(root, CAMPAIGN_KEYS, "", errors)
		_check_version(root, errors)
		if not _is_list_of_text(root.get("niveles")):
			errors.append("\"niveles\" tiene que ser una lista de nombres de nivel, como [\"level_01\"].")
	elif errors.is_empty():
		errors.append("El archivo tiene que empezar con { y terminar con }.")
	if not errors.is_empty():
		push_error("La campaña (%s) tiene errores:\n- %s" % [path, "\n- ".join(errors)])
		return PackedStringArray()
	return PackedStringArray(root["niveles"])


# --- Oleadas (RF-203) ---

static func _read_wave(value: Variant, where: String, grid: MapGrid, errors: PackedStringArray) -> WaveData:
	var wave := WaveData.new()
	if not value is Array or (value as Array).is_empty():
		_add(errors, where, "tiene que ser una lista con al menos un grupo, como [{\"enemigo\": \"normal\", \"cantidad\": 5, \"cada\": 1.0}].")
		return wave
	var groups: Array = value
	for g: int in groups.size():
		var group_where: String = "%s, grupo %d" % [where, g + 1]
		if not groups[g] is Dictionary:
			_add(errors, group_where, "tiene que estar entre { }.")
			continue
		wave.groups.append(_read_group(groups[g], group_where, grid, errors))
	return wave


static func _read_group(data: Dictionary, where: String, grid: MapGrid, errors: PackedStringArray) -> SpawnGroup:
	var group := SpawnGroup.new()
	_check_keys(data, GROUP_KEYS, where, errors)
	var enemy_name: String = _text(data, "enemigo", where, errors)
	if not enemy_name.is_empty():
		group.enemy = find_enemy(enemy_name)
		if group.enemy == null:
			_add(errors, where, "no existe el enemigo '%s' (tiene que ser un archivo de data/enemies/)." % enemy_name)
	group.count = _whole(data, "cantidad", where, 1, errors)
	if data.has("cada") or group.count > 1:
		group.interval = _number(data, "cada", where, errors)
		if group.count > 1 and group.interval <= 0.0 and data.has("cada") and _is_number(data["cada"]):
			_add(errors, where, "\"cada\" tiene que ser mayor que 0 (si no, salen todos juntos).")
	if data.has("desde"):
		group.start_delay = _number(data, "desde", where, errors)
	if data.has("entrada"):
		var letter: Variant = data["entrada"]
		var index: int = MapGrid.ENTRANCE_LETTERS.find(str(letter)) if letter is String and (letter as String).length() == 1 else -1
		if index < 0:
			_add(errors, where, "\"entrada\" tiene que ser una letra, como \"A\" o \"B\".")
		elif grid != null and index >= grid.entrances.size():
			_add(errors, where, "la entrada %s no está en el mapa." % letter)
		else:
			group.entrance_index = index
	return group


## Los nombres de los enemigos que existen (los archivos de data/enemies/), en orden. En un
## ejecutable exportado los recursos aparecen como "normal.tres.remap": también se aceptan.
static func enemy_ids() -> PackedStringArray:
	var found: Dictionary = {}
	for file: String in DirAccess.get_files_at(ENEMIES_DIR):
		var clean: String = file.trim_suffix(".remap")
		if clean.ends_with(".tres") or clean.ends_with(".res"):
			found[clean.get_basename()] = true
	var ids := PackedStringArray(found.keys())
	ids.sort()
	return ids


## El enemigo `name` (normal, troll…). Solo letras minúsculas, números y "_": así un nombre
## no puede apuntar a otra carpeta (importa para los mods, B-04).
static func find_enemy(enemy_name: String) -> EnemyData:
	var valid := RegEx.create_from_string("^[a-z0-9_]+$")
	if valid.search(enemy_name) == null:
		return null
	var path: String = ENEMIES_DIR + enemy_name + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as EnemyData


# --- Valores sueltos ---

static func _parse_json(text: String, errors: PackedStringArray) -> Variant:
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("El archivo no es un JSON válido (línea %d: %s). Revisá comas, comillas y llaves." \
			% [json.get_error_line(), json.get_error_message()])
		return null
	return json.data


## RF-204: una clave mal escrita ("canitdad") no se ignora en silencio.
static func _check_keys(data: Dictionary, known: PackedStringArray, where: String, errors: PackedStringArray) -> void:
	for key: Variant in data.keys():
		if not known.has(str(key)):
			_add(errors, where, "clave desconocida \"%s\" (se usan: %s)." % [key, ", ".join(known)])


static func _check_version(data: Dictionary, errors: PackedStringArray) -> void:
	if not data.has("version"):
		errors.append("Falta \"version\" (hoy es %d)." % VERSION)
	elif not _is_number(data["version"]) or int(data["version"]) != VERSION:
		errors.append("La versión %s no se puede leer: este juego lee la %d." % [_shown(data["version"]), VERSION])


static func _text(data: Dictionary, key: String, where: String, errors: PackedStringArray) -> String:
	if not data.has(key):
		_add(errors, where, "falta \"%s\"." % [key])
		return ""
	if not data[key] is String or (data[key] as String).strip_edges().is_empty():
		_add(errors, where, "\"%s\" tiene que ser un texto entre comillas." % [key])
		return ""
	return data[key]


## Un número entero (JSON no distingue 5 de 5.0) mayor o igual que `minimum`.
static func _whole(data: Dictionary, key: String, where: String, minimum: int, errors: PackedStringArray) -> int:
	if not data.has(key):
		_add(errors, where, "falta \"%s\"." % [key])
		return minimum
	var value: Variant = data[key]
	if not _is_number(value) or float(value) != floorf(float(value)):
		_add(errors, where, "\"%s\" tiene que ser un número entero." % [key])
		return minimum
	if int(value) < minimum:
		_add(errors, where, "\"%s\" tiene que ser %d o más." % [key, minimum])
		return minimum
	return int(value)


## Un número (con decimales o no) de 0 para arriba: segundos.
static func _number(data: Dictionary, key: String, where: String, errors: PackedStringArray) -> float:
	if not data.has(key):
		_add(errors, where, "falta \"%s\"." % [key])
		return 0.0
	var value: Variant = data[key]
	if not _is_number(value) or float(value) < 0.0:
		_add(errors, where, "\"%s\" tiene que ser un número de 0 para arriba (segundos)." % [key])
		return 0.0
	return float(value)


static func _is_number(value: Variant) -> bool:
	return value is float or value is int


static func _is_list_of_text(value: Variant) -> bool:
	if not value is Array:
		return false
	for item: Variant in value:
		if not item is String:
			return false
	return true


## Anota un error. Con ubicación: "oleada 2, grupo 1: falta …"; sin ella: "Falta …".
static func _add(errors: PackedStringArray, where: String, message: String) -> void:
	errors.append(message.left(1).to_upper() + message.substr(1) if where.is_empty() else where + ": " + message)


static func _failed(errors: PackedStringArray) -> Dictionary:
	return {"level": null, "errors": errors, "warnings": PackedStringArray()}


## Un valor como lo escribió la persona: JSON lee 2 como 2.0, y en un mensaje se ve raro.
static func _shown(value: Variant) -> String:
	if value is float and float(value) == floorf(float(value)):
		return str(int(value))
	return str(value)
