# Los modos de juego (spec M49, RF-388 a RF-392, D-078): cada modo es una carpeta con un `modo.json` y
# sus mapas (los mismos JSON de §7.8). Los oficiales viven en data/modos/ y los propios en
# user://modos/. Solo se leen datos: un modo nunca puede traer código. Nunca corta el juego: un modo o
# un mapa roto queda con su motivo y los demás se ven igual (como CommunityMaps).
class_name ModePacks
extends RefCounted

const OFFICIAL_DIR: String = "res://data/modos/"
const USER_DIR: String = "user://modos/"
const FILE_NAME: String = "modo.json"
## Un mapa no puede llamarse como el archivo del modo.
const RESERVED_MAP_ID: String = "modo"
const VERSION: int = 1
## RF-390: el progreso de cada mapa de un modo va con el id `modo_<modo>_<mapa>`.
const ID_PREFIX: String = "modo_"
## Prefijo de la solapa de un modo en la selección de nivel (GameFlow.select_page).
const PAGE_PREFIX: String = "mode:"
const KEYS: PackedStringArray = ["version", "nombre", "descripcion", "mapas", "torres", "reglas"]
const RULE_GOLD: String = "oro_inicial_%"
const RULE_LIVES: String = "vidas"
const RULE_HEALTH: String = "vida_monstruos_%"
const RULE_KEYS: PackedStringArray = [RULE_GOLD, RULE_LIVES, RULE_HEALTH]
## Topes de formato (como RF-223), para que un modo ajeno no cuelgue el juego.
const MAX_MODES: int = 50
const MAX_MAPS: int = 50
const MAX_NAME_LENGTH: int = 30
const MAX_DESCRIPTION_LENGTH: int = 200
const MIN_PERCENT: int = 10
const MAX_PERCENT: int = 1000


## Todos los modos: primero los oficiales y después los propios (RF-389). Un modo propio con el
## mismo id que uno oficial queda con error, así sus récords no se mezclan (RF-388).
static func all(official_dir: String = OFFICIAL_DIR, user_dir: String = USER_DIR) -> Array[Dictionary]:
	var modes: Array[Dictionary] = scan(official_dir, true)
	var official_ids: Array[StringName] = []
	for mode: Dictionary in modes:
		official_ids.append(mode["id"])
	for mode: Dictionary in scan(user_dir, false):
		if official_ids.has(mode["id"]):
			# Los PackedStringArray se copian por valor: hay que volver a guardarlo en el diccionario.
			var errors: PackedStringArray = mode["errors"]
			errors.append("Ya hay un modo oficial llamado '%s': cambiale el nombre a la carpeta." % mode["id"])
			mode["errors"] = errors
		modes.append(mode)
	return modes


## Los modos de una carpeta, uno por subcarpeta, en orden alfabético. Una entrada:
## {"id": StringName, "official": bool, "dir": String, "name": String, "description": String,
##  "maps": Array[Dictionary] ({"file", "level": LevelData o null, "errors"}), "errors": PackedStringArray}.
## Si `errors` no está vacío, el modo.json está mal y no se juega ningún mapa.
static func scan(dir: String, official: bool) -> Array[Dictionary]:
	var modes: Array[Dictionary] = []
	if not DirAccess.dir_exists_absolute(dir):
		return modes
	var ids: PackedStringArray = DirAccess.get_directories_at(dir)
	ids.sort()
	for id: String in ids.slice(0, MAX_MODES):
		modes.append(read(dir, id, official))
	return modes


## Lee un modo: su modo.json y cada mapa de su lista, con las reglas ya aplicadas.
static func read(dir: String, id: String, official: bool) -> Dictionary:
	var mode: Dictionary = {
		"id": StringName(id), "official": official, "dir": dir_of(dir, id), "name": id, "description": "",
		"maps": [], "errors": PackedStringArray(),
	}
	var errors: PackedStringArray = []
	_read_into(mode, errors)
	mode["errors"] = errors  # se copia por valor: se guarda al final
	return mode


static func _read_into(mode: Dictionary, errors: PackedStringArray) -> void:
	if not LevelDraft.is_valid_file_id(String(mode["id"])):
		errors.append("Nombre de carpeta no válido: solo minúsculas, números y _ (hasta %d letras)." % LevelDraft.FILE_ID_MAX)
		return
	var path: String = mode["dir"] + FILE_NAME
	if not FileAccess.file_exists(path):
		errors.append("Falta el archivo %s en la carpeta del modo." % FILE_NAME)
		return
	if _size(path) > CommunityMaps.MAX_FILE_BYTES:
		errors.append("%s es demasiado grande." % FILE_NAME)
		return
	var data: Dictionary = _parse(FileAccess.get_file_as_string(path), errors)
	if not errors.is_empty():
		return
	var settings: Dictionary = _read_settings(data, errors)
	if not errors.is_empty():
		return
	mode["name"] = settings["name"]
	mode["description"] = settings["description"]
	var maps: Array = mode["maps"]
	for map_id: String in settings["maps"]:
		maps.append(_read_map(mode, map_id, settings))


static func dir_of(root: String, mode_id: String) -> String:
	return root + mode_id + "/"


static func level_id(mode_id: StringName, map_id: String) -> StringName:
	return StringName("%s%s_%s" % [ID_PREFIX, mode_id, map_id])


static func page_of(mode: Dictionary) -> StringName:
	return StringName(PAGE_PREFIX + String(mode["id"]))


## El nivel jugable del mapa `index` (null si el modo o ese mapa tienen errores).
static func map_level(mode: Dictionary, index: int) -> LevelData:
	if not (mode["errors"] as PackedStringArray).is_empty():
		return null
	var maps: Array = mode["maps"]
	if index < 0 or index >= maps.size():
		return null
	return maps[index]["level"]


## RF-390: ¿se puede jugar el mapa `index`? En un modo oficial, el primero jugable está abierto y cada
## uno se habilita al ganar el jugable anterior; en los propios, todos. (El modo de pruebas, RF-183, lo
## resuelve GameFlow.) `is_completed` e `is_unlocked` reciben un id de nivel.
static func is_open(mode: Dictionary, index: int, is_completed: Callable, is_unlocked: Callable) -> bool:
	var level: LevelData = map_level(mode, index)
	if level == null:
		return false
	if not mode["official"] or is_unlocked.call(level.id):
		return true
	var previous: int = previous_playable(mode, index)
	return previous < 0 or is_completed.call(map_level(mode, previous).id)


## El mapa jugable anterior a `index` (-1 si no hay).
static func previous_playable(mode: Dictionary, index: int) -> int:
	for i: int in range(index - 1, -1, -1):
		if map_level(mode, i) != null:
			return i
	return -1


## El mapa jugable siguiente a `index` (-1 si no hay).
static func next_playable(mode: Dictionary, index: int) -> int:
	for i: int in range(index + 1, (mode["maps"] as Array).size()):
		if map_level(mode, i) != null:
			return i
	return -1


## Los ids de los modos propios que hay en `user_dir` (para el editor, RF-392).
static func user_ids(user_dir: String = USER_DIR) -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(user_dir):
		return PackedStringArray()
	var ids: PackedStringArray = DirAccess.get_directories_at(user_dir)
	ids.sort()
	return ids


## RF-392: crea un modo propio vacío desde el editor. Devuelve {"id": String, "error": String}.
static func create(user_dir: String, display_name: String, official_dir: String = OFFICIAL_DIR) -> Dictionary:
	var problem: String = name_problem(user_dir, display_name, official_dir)
	if problem != "":
		return {"id": "", "error": problem}
	var id: String = LevelDraft.clean_file_id(display_name)
	DirAccess.make_dir_recursive_absolute(dir_of(user_dir, id))
	var data: Dictionary = {"version": VERSION, "nombre": display_name.strip_edges(), "descripcion": "", "mapas": []}
	var error: String = _write(dir_of(user_dir, id) + FILE_NAME, data)
	return {"id": id if error == "" else "", "error": error}


## Por qué no se puede crear un modo con ese nombre ("" si se puede). Lo usa el editor mientras se escribe.
static func name_problem(user_dir: String, display_name: String, official_dir: String = OFFICIAL_DIR) -> String:
	var clean_name: String = display_name.strip_edges()
	if clean_name == "":
		return "Escribí un nombre."
	if clean_name.length() > MAX_NAME_LENGTH:
		return "El nombre tiene %d letras y el máximo es %d." % [clean_name.length(), MAX_NAME_LENGTH]
	var id: String = LevelDraft.clean_file_id(clean_name)
	if id == "":
		return "El nombre necesita al menos una letra o un número."
	if DirAccess.dir_exists_absolute(dir_of(official_dir, id)):
		return "'%s' es un modo oficial: elegí otro nombre." % id
	if DirAccess.dir_exists_absolute(dir_of(user_dir, id)):
		return "Ya tenés un modo llamado '%s'." % id
	return ""


## RF-392: suma `map_id` al final de la lista de mapas del modo (si ya estaba, no lo repite).
## Devuelve "" si salió bien o el motivo si no.
static func add_map(mode_dir: String, map_id: String) -> String:
	var path: String = mode_dir + FILE_NAME
	var errors: PackedStringArray = []
	var data: Dictionary = _parse(FileAccess.get_file_as_string(path), errors) if FileAccess.file_exists(path) else {}
	if not errors.is_empty() or data.is_empty():
		return "No se pudo leer %s del modo." % FILE_NAME
	var maps: Array = data.get("mapas", []) if data.get("mapas") is Array else []
	if not maps.has(map_id):
		maps.append(map_id)
	data["mapas"] = maps
	data["version"] = VERSION
	return _write(path, data)


## El nombre que se muestra de un modo propio (o su id, si el modo.json está mal).
static func display_name(user_dir: String, mode_id: String) -> String:
	return str(read(user_dir, mode_id, false)["name"])


# --- Lectura y validación ---

static func _read_settings(data: Dictionary, errors: PackedStringArray) -> Dictionary:
	for key: Variant in data.keys():
		if not KEYS.has(str(key)):
			errors.append("Clave desconocida \"%s\" (se usan: %s)." % [key, ", ".join(KEYS)])
	if not data.get("version") is float or int(data["version"]) != VERSION:
		errors.append("\"version\" tiene que ser %d." % VERSION)
	var settings: Dictionary = {"name": "", "description": "", "maps": PackedStringArray(),
		"towers": PackedStringArray(), "rules": {}}
	var name_value: Variant = data.get("nombre")
	if not name_value is String or (name_value as String).strip_edges() == "":
		errors.append("\"nombre\" tiene que ser un texto, como \"Asedio\".")
	elif (name_value as String).length() > MAX_NAME_LENGTH:
		errors.append("El nombre tiene %d letras y el máximo es %d." % [(name_value as String).length(), MAX_NAME_LENGTH])
	else:
		settings["name"] = (name_value as String).strip_edges()
	if data.has("descripcion"):
		if not data["descripcion"] is String or (data["descripcion"] as String).length() > MAX_DESCRIPTION_LENGTH:
			errors.append("\"descripcion\" tiene que ser un texto de hasta %d letras." % MAX_DESCRIPTION_LENGTH)
		else:
			settings["description"] = data["descripcion"]
	settings["maps"] = _read_map_list(data.get("mapas"), errors)
	if data.has("torres"):
		settings["towers"] = _read_towers(data["torres"], errors)
	if data.has("reglas"):
		settings["rules"] = _read_rules(data["reglas"], errors)
	return settings


static func _read_map_list(value: Variant, errors: PackedStringArray) -> PackedStringArray:
	var maps := PackedStringArray()
	if not value is Array:
		errors.append("\"mapas\" tiene que ser una lista de nombres de mapa, como [\"level_01\"].")
		return maps
	var list: Array = value
	if list.size() > MAX_MAPS:
		errors.append("\"mapas\" tiene %d mapas y el máximo es %d." % [list.size(), MAX_MAPS])
		return maps
	for item: Variant in list:
		if not item is String or not LevelDraft.is_valid_file_id(item) or item == RESERVED_MAP_ID:
			errors.append("\"mapas\": '%s' no es un nombre de mapa válido (minúsculas, números y _)." % str(item))
		elif maps.has(item):
			errors.append("\"mapas\": '%s' está repetido." % item)
		else:
			maps.append(item)
	return maps


static func _read_towers(value: Variant, errors: PackedStringArray) -> PackedStringArray:
	var towers := PackedStringArray()
	var known: PackedStringArray = LevelFile.tower_ids()
	if not value is Array or (value as Array).is_empty():
		errors.append("\"torres\" tiene que ser una lista con al menos una torre, como [\"basic\", \"cannon\"].")
		return towers
	for item: Variant in value:
		if not item is String or not known.has(item):
			errors.append("\"torres\": la torre '%s' no existe. Las que hay: %s." % [str(item), ", ".join(known)])
		else:
			towers.append(item)
	return towers


static func _read_rules(value: Variant, errors: PackedStringArray) -> Dictionary:
	var rules: Dictionary = {}
	if not value is Dictionary:
		errors.append("\"reglas\" tiene que estar entre { }, como {\"vida_monstruos_%\": 150}.")
		return rules
	var data: Dictionary = value
	for key: Variant in data.keys():
		if not RULE_KEYS.has(str(key)):
			errors.append("\"reglas\": clave desconocida \"%s\" (se usan: %s)." % [key, ", ".join(RULE_KEYS)])
	for key: String in [RULE_GOLD, RULE_HEALTH]:
		if data.has(key):
			rules[key] = _whole(data[key], key, MIN_PERCENT, MAX_PERCENT, errors)
	if data.has(RULE_LIVES):
		rules[RULE_LIVES] = _whole(data[RULE_LIVES], RULE_LIVES, 1, LevelFile.MAX_LIVES, errors)
	return rules


static func _whole(value: Variant, key: String, minimum: int, maximum: int, errors: PackedStringArray) -> int:
	if not value is float or value != floorf(value) or value < minimum or value > maximum:
		errors.append("\"reglas\": \"%s\" tiene que ser un número entero entre %d y %d." % [key, minimum, maximum])
		return minimum
	return int(value)


## Un mapa del modo: primero en la carpeta del modo y, si no está, entre los niveles oficiales (RF-388).
static func _read_map(mode: Dictionary, map_id: String, settings: Dictionary) -> Dictionary:
	var entry: Dictionary = {"file": map_id, "level": null, "errors": PackedStringArray()}
	var path: String = mode["dir"] + map_id + ".json"
	if not FileAccess.file_exists(path):
		path = LevelFile.LEVELS_DIR + map_id + ".json"
	if not FileAccess.file_exists(path):
		entry["errors"] = PackedStringArray(["No existe el mapa '%s': ni en la carpeta del modo ni entre los niveles oficiales." % map_id])
		return entry
	if _size(path) > CommunityMaps.MAX_FILE_BYTES:
		entry["errors"] = PackedStringArray(["El mapa '%s' es demasiado grande." % map_id])
		return entry
	var result: Dictionary = LevelFile.parse(FileAccess.get_file_as_string(path), level_id(mode["id"], map_id))
	entry["errors"] = result["errors"]
	var level: LevelData = result["level"]
	if level != null:
		_apply(level, settings)
		var conflict: String = _towers_conflict(level, map_id)
		if conflict != "":  # RF-396: nivel y modo no comparten ninguna torre
			entry["errors"] = PackedStringArray(entry["errors"]) + PackedStringArray([conflict])
			level = null
	entry["level"] = level
	return entry


## RF-388: las reglas del modo sobre un mapa ya leído.
static func _apply(level: LevelData, settings: Dictionary) -> void:
	var rules: Dictionary = settings["rules"]
	if rules.has(RULE_GOLD):
		level.starting_gold = Rules.percent_of(level.starting_gold, rules[RULE_GOLD])
	if rules.has(RULE_LIVES):
		level.starting_lives = rules[RULE_LIVES]
	if rules.has(RULE_HEALTH):
		level.enemy_health_percent = rules[RULE_HEALTH]
	level.allowed_towers = settings["towers"]


## RF-396: si el modo y el mapa limitan las torres y no tienen ninguna en común, el mensaje del error; si no, "".
static func _towers_conflict(level: LevelData, map_id: String) -> String:
	if level.towers.is_empty() or level.allowed_towers.is_empty():
		return ""
	for id: String in level.towers:
		if level.allowed_towers.has(id):
			return ""
	return "El mapa '%s' ofrece las torres %s y este modo permite %s: no tienen ninguna en común, así que no habría con qué defenderse." \
		% [map_id, ", ".join(level.towers), ", ".join(level.allowed_towers)]


static func _parse(text: String, errors: PackedStringArray) -> Dictionary:
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("%s no es un JSON válido (línea %d: %s)." % [FILE_NAME, json.get_error_line(), json.get_error_message()])
		return {}
	if not json.data is Dictionary:
		errors.append("%s tiene que empezar con { y terminar con }." % FILE_NAME)
		return {}
	return json.data


static func _write(path: String, data: Dictionary) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "No se pudo escribir %s (%s)." % [path, error_string(FileAccess.get_open_error())]
	file.store_string(JSON.stringify(_whole_numbers(data), "\t", false) + "\n")
	return ""


## El JSON lee todo número como decimal (150 → 150.0): al reescribir, los enteros vuelven a ser enteros.
static func _whole_numbers(value: Variant) -> Variant:
	if value is float and value == floorf(value):
		return int(value)
	if value is Dictionary:
		var copy: Dictionary = {}
		for key: Variant in (value as Dictionary).keys():
			copy[key] = _whole_numbers(value[key])
		return copy
	if value is Array:
		var items: Array = []
		for item: Variant in value:
			items.append(_whole_numbers(item))
		return items
	return value


static func _size(path: String) -> int:
	var opened := FileAccess.open(path, FileAccess.READ)
	if opened == null:
		return 0
	var length: int = opened.get_length()
	opened.close()
	return length
