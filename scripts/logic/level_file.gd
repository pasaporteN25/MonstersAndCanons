# Lee los archivos de texto de los niveles y de la campaña (spec §7.8, RF-200 a RF-205).
# Nunca corta el juego: devuelve el nivel o la lista de errores, en castellano y con su ubicación
# ("oleada 3, grupo 2: …"). Las claves del archivo van en castellano porque lo edita una persona
# (D-031).
class_name LevelFile
extends RefCounted

const VERSION: int = 1
const LEVELS_DIR: String = "res://data/levels/"
const ENEMIES_DIR: String = "res://data/enemies/"
const TOWERS_DIR: String = "res://data/towers/"
const CAMPAIGN_PATH: String = "res://data/campaign.json"

const LEVEL_KEYS: PackedStringArray = ["version", "nombre", "oro", "vidas", "aumento_vida", "tema", "leyenda", "torres_extra", "torres", "demoledora", "textos", "mapa", "oleadas"]
const LEGEND_KEYS: PackedStringArray = ["dibujo", "construible", "removible", "extraccion"]
const GROUP_KEYS: PackedStringArray = ["enemigo", "cantidad", "cada", "desde", "entrada", "probabilidad"]
const CAMPAIGN_KEYS: PackedStringArray = ["version", "niveles"]

## RF-223: topes para que un archivo ajeno no cuelgue el juego. Valen para todos los niveles y el
## editor de mapas no deja pasarse de estos números.
const MAX_WAVES: int = 100
const MAX_GROUPS: int = 20
const MAX_COUNT: int = 999
const MAX_EVERY: float = 60.0
const MAX_FROM: float = 600.0
const MAX_GOLD: int = 99999
const MAX_LIVES: int = 999
const MAX_HEALTH_SCALE: int = 300
const MAX_NAME_LENGTH: int = 30
## RF-262, RF-265: letras que puede declarar la leyenda de un nivel.
const MAX_LEGEND: int = 10


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
	if level.display_name.length() > MAX_NAME_LENGTH:
		errors.append("El nombre tiene %d letras y el máximo es %d." % [level.display_name.length(), MAX_NAME_LENGTH])
	level.starting_gold = _whole(data, "oro", "", 0, MAX_GOLD, errors)
	level.starting_lives = _whole(data, "vidas", "", 1, MAX_LIVES, errors)
	if data.has("aumento_vida"):
		level.health_scale_percent_per_wave = _whole(data, "aumento_vida", "", 0, MAX_HEALTH_SCALE, errors)

	level.theme = _read_theme(data, errors)
	level.legend = _read_legend(data, errors)
	if data.has("demoledora"):
		if not data["demoledora"] is bool:
			errors.append("demoledora: tiene que ser true o false.")
		else:
			level.machine_enabled = data["demoledora"]
	var texts: Dictionary = LevelTexts.parse(data.get("textos"), errors)  # RF-464
	level.place_text = texts[LevelTexts.KEY_PLACE]
	level.intro_text = texts[LevelTexts.KEY_INTRO]
	level.win_text = texts[LevelTexts.KEY_WIN]
	level.epilogue_text = texts[LevelTexts.KEY_EPILOGUE]
	level.extra_towers = _read_extra_towers(data, errors)
	level.towers = _read_towers(data, errors)

	var grid: MapGrid = null
	if not data.has("mapa"):
		errors.append("Falta \"mapa\".")
	elif not _is_list_of_text(data["mapa"]):
		errors.append("mapa: tiene que ser una lista de filas entre comillas, como [\"....\", \"A###\"].")
	else:
		level.map_rows = PackedStringArray(data["mapa"])
		grid = MapGrid.parse(level.map_rows, level.legend)
		for problem: String in grid.errors:
			errors.append("mapa: " + problem)
		if not grid.is_valid():
			grid = null
	if grid != null:
		level.obstacles = _read_obstacles(level.map_rows, level.legend, errors)

	if not data.has("oleadas"):
		errors.append("Falta \"oleadas\".")
	elif not data["oleadas"] is Array or (data["oleadas"] as Array).is_empty():
		errors.append("oleadas: tiene que ser una lista con al menos una oleada.")
	elif (data["oleadas"] as Array).size() > MAX_WAVES:
		errors.append("oleadas: hay %d y el máximo es %d." % [(data["oleadas"] as Array).size(), MAX_WAVES])
	else:
		var waves: Array = data["oleadas"]
		for w: int in waves.size():
			level.waves.append(_read_wave(waves[w], "oleada %d" % (w + 1), grid, errors))

	if not errors.is_empty():
		return _failed(errors)
	var warnings: PackedStringArray = []
	for problem: String in grid.warnings:
		warnings.append("mapa: " + problem)
	if level.machine_enabled and level.obstacles.filter(func(obstacle: ObstacleSpec) -> bool: return obstacle.kind == ObstacleSpec.Kind.REMOVABLE).is_empty():
		warnings.append("demoledora: el nivel la habilita pero no tiene removibles.")
	if not level.uses_resources():  # RF-421: ofrece una torre que cuesta recursos y no hay cómo conseguirlos
		for tower: TowerData in level.available_towers(Wiki._all_towers()):
			if tower.resource_cost > 0:
				warnings.append("torres: el %s cuesta recursos y este mapa no tiene cómo conseguirlos." % tower.display_name)
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
	if groups.size() > MAX_GROUPS:
		_add(errors, where, "tiene %d grupos y el máximo es %d." % [groups.size(), MAX_GROUPS])
		return wave
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
	group.count = _whole(data, "cantidad", where, 1, MAX_COUNT, errors)
	if data.has("probabilidad"):
		group.probability = _number(data, "probabilidad", where, 1.0, errors)
	if data.has("cada") or group.count > 1:
		group.interval = _number(data, "cada", where, MAX_EVERY, errors)
		if group.count > 1 and group.interval <= 0.0 and data.has("cada") and _is_number(data["cada"]):
			_add(errors, where, "\"cada\" tiene que ser mayor que 0 (si no, salen todos juntos).")
	if data.has("desde"):
		group.start_delay = _number(data, "desde", where, MAX_FROM, errors)
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


# --- Torres extra (RF-300) ---

## Los ids de las torres que existen (los archivos de `data/towers/`).
static func tower_ids() -> PackedStringArray:
	var found: Dictionary = {}
	for file: String in DirAccess.get_files_at(TOWERS_DIR):
		var clean: String = file.trim_suffix(".remap")
		if clean.ends_with(".tres") or clean.ends_with(".res"):
			found[clean.get_basename()] = true
	var ids := PackedStringArray(found.keys())
	ids.sort()
	return ids


## `"torres_extra"`: lista de ids de torres reservadas que el nivel habilita. Un id que no existe es un error.
static func _read_extra_towers(data: Dictionary, errors: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	if not data.has("torres_extra"):
		return result
	if not _is_list_of_text(data["torres_extra"]):
		errors.append("torres_extra: tiene que ser una lista de nombres de torre entre comillas, como [\"mortar\"].")
		return result
	var known: PackedStringArray = tower_ids()
	for id: String in data["torres_extra"]:
		if not known.has(id):
			errors.append("torres_extra: la torre \"%s\" no existe. Las que hay: %s." % [id, ", ".join(known)])
		elif not result.has(id):
			result.append(id)
	return result


## RF-393/RF-394: `"torres"`, la lista de torres que el nivel ofrece. No puede estar vacía; un id que no
## existe es un error; uno repetido cuenta una vez.
static func _read_towers(data: Dictionary, errors: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	if not data.has("torres"):
		return result
	if not _is_list_of_text(data["torres"]) or (data["torres"] as Array).is_empty():
		errors.append("torres: tiene que ser una lista con al menos una torre entre comillas, como [\"frost\", \"cannon\"].")
		return result
	var known: PackedStringArray = tower_ids()
	for id: String in data["torres"]:
		if not known.has(id):
			errors.append("torres: la torre \"%s\" no existe. Las que hay: %s." % [id, ", ".join(known)])
		elif not result.has(id):
			result.append(id)
	return result


# --- Tema y leyenda (RF-260, RF-262, RF-265) ---

## El tema del nivel. Sin el campo, `pradera` (el de siempre).
static func _read_theme(data: Dictionary, errors: PackedStringArray) -> StringName:
	if not data.has("tema"):
		return MapThemes.DEFAULT
	var value: Variant = data["tema"]
	if not value is String or not MapThemes.is_valid(value):
		errors.append("tema: %s no existe. Los que hay: %s." % [JSON.stringify(value), ", ".join(MapThemes.IDS)])
		return MapThemes.DEFAULT
	return StringName(value)


## La leyenda de un nivel ya leído, sin los errores (para el editor, que la conserva; los errores los da parse).
static func parse_legend(data: Dictionary) -> Dictionary:
	return _read_legend(data, PackedStringArray())


## La leyenda: letra → {"dibujo": String, "construible": bool}. Devuelve la leyenda ya normalizada
## (con `construible` siempre escrito); lo que está mal se agrega a `errors` y se saltea.
static func _read_legend(data: Dictionary, errors: PackedStringArray) -> Dictionary:
	var legend: Dictionary = {}
	if not data.has("leyenda"):
		return legend
	if not data["leyenda"] is Dictionary:
		errors.append("leyenda: tiene que ser un objeto con una letra por entrada, como {\"~\": {\"dibujo\": \"agua\"}}.")
		return legend
	var source: Dictionary = data["leyenda"]
	var catalog_result: Dictionary = ObstacleCatalog.load_data()
	var catalog: Dictionary = catalog_result["data"]
	if source.size() > MAX_LEGEND:
		errors.append("leyenda: hay %d letras y el máximo es %d." % [source.size(), MAX_LEGEND])
	for key: Variant in source.keys():
		var letter: String = str(key)
		var where: String = "leyenda \"%s\"" % letter
		var problem: String = _legend_letter_problem(letter)
		if problem != "":
			errors.append("%s: %s" % [where, problem])
			continue
		if not source[key] is Dictionary:
			errors.append("%s: tiene que ser un objeto, como {\"dibujo\": \"agua\"}." % where)
			continue
		var entry: Dictionary = source[key]
		_check_keys(entry, LEGEND_KEYS, where, errors)
		var has_removable: bool = entry.has("removible")
		var has_extraction: bool = entry.has("extraccion")
		if has_removable and has_extraction:
			errors.append("%s: no puede tener \"removible\" y \"extraccion\" a la vez." % where)
			continue
		var category: String = "removibles" if has_removable else "extraccion" if has_extraction else ""
		var obstacle_data: Dictionary = {}
		var expected_drawing: String = ""
		if category != "":
			var obstacle_key: String = "removible" if has_removable else "extraccion"
			if catalog_result["errors"].is_empty():
				var resolved: Dictionary = _read_obstacle_entry(entry[obstacle_key], category, where, catalog, errors)
				if resolved.is_empty():
					continue
				obstacle_data = resolved
				expected_drawing = str(resolved["drawing"])
			else:
				var raw_obstacle: Variant = entry[obstacle_key]
				if not raw_obstacle is Dictionary or not raw_obstacle.get("clase") is String:
					_add(errors, where, "%s: falta \"clase\" (tiene que ser un texto)." % category)
					continue
				expected_drawing = raw_obstacle["clase"]
		var drawing: Variant = entry.get("dibujo", expected_drawing)
		if entry.has("dibujo") or category == "":
			if not drawing is String or not MapDrawings.is_valid(drawing):
				errors.append("%s: el dibujo %s no existe. Los que hay: %s." % [where, JSON.stringify(drawing), ", ".join(MapDrawings.ids())])
				continue
		elif category != "" and not MapDrawings.is_valid(drawing):
			errors.append("%s: el dibujo de la clase \"%s\" no existe." % [where, expected_drawing])
			continue
		if category != "" and drawing != expected_drawing:
			errors.append("%s: el dibujo tiene que ser \"%s\", como la clase." % [where, expected_drawing])
			continue
		var buildable: Variant = entry.get("construible", false)
		if not buildable is bool:
			errors.append("%s: \"construible\" tiene que ser true o false." % where)
			continue
		if category != "" and buildable:
			errors.append("%s: \"construible\" no puede ser true en un removible ni en una extracción." % where)
			continue
		var normalized: Dictionary = {"dibujo": drawing, "construible": buildable}
		if has_removable and not obstacle_data.is_empty():
			normalized["removible"] = obstacle_data
		elif has_extraction and not obstacle_data.is_empty():
			normalized["extraccion"] = obstacle_data
		legend[letter] = normalized
	return legend


static func _read_obstacle_entry(value: Variant, category: String, where: String, catalog: Dictionary, errors: PackedStringArray) -> Dictionary:
	if not value is Dictionary:
		_add(errors, where, "\"%s\" tiene que ser un objeto." % category)
		return {}
	var source: Dictionary = value
	var allowed: PackedStringArray = ["clase", "costo", "tiempo", "recursos", "probabilidad", "hallazgo"] if category == "removibles" \
		else ["clase", "costo", "produccion", "reserva"]
	_check_keys(source, allowed, where + " → " + category, errors)
	if not source.has("clase") or not source["clase"] is String:
		_add(errors, where, "%s: falta \"clase\" (tiene que ser un texto)." % category)
		return {}
	var class_id: String = source["clase"]
	var defaults: Dictionary = ObstacleCatalog.removable(class_id, catalog) if category == "removibles" else ObstacleCatalog.extraction(class_id, catalog)
	if defaults.is_empty():
		_add(errors, where, "%s: la clase \"%s\" no existe. Las que hay: %s." % [category, class_id, ", ".join(ObstacleCatalog.class_ids(catalog))])
		return {}
	var result: Dictionary = defaults.duplicate(true)
	for key: Variant in source.keys():
		if key != "clase" and key != "hallazgo":
			result[key] = source[key]
	if category == "removibles":
		for key: String in ["costo", "recursos"]:
			if not _nonnegative_whole(result.get(key), where + " → removible → " + key, errors, key == "costo"):
				return {}
		if not _positive_number(result.get("tiempo"), where + " → removible → tiempo", errors):
			return {}
		if not _probability(result.get("probabilidad"), where, errors):
			return {}
		result["drawing"] = class_id
		result["class"] = class_id
		result["finding"] = StringName(source.get("hallazgo", ""))
		result["repeat_reward"] = int(defaults.get("recursos_si_recuperado", 0))
		if source.has("hallazgo"):
			if class_id != "escombro":
				_add(errors, where, "\"hallazgo\" solo se puede usar en un escombro.")
				return {}
			var collections: Dictionary = _collection_definitions()
			if not collections.has(source["hallazgo"]):
				_add(errors, where, "la colección \"%s\" no existe en progression.json." % source["hallazgo"])
				return {}
	else:
		for key: String in ["costo", "produccion", "reserva"]:
			if not _nonnegative_whole(result.get(key), where + " → extraccion → " + key, errors, key == "costo"):
				return {}
		result["drawing"] = class_id
		result["class"] = class_id
	return result


static func _read_obstacles(rows: PackedStringArray, legend: Dictionary, errors: PackedStringArray) -> Array[ObstacleSpec]:
	var result: Array[ObstacleSpec] = []
	var findings: Dictionary = {}
	var finding_letters: Dictionary = {}
	for y: int in rows.size():
		for x: int in rows[y].length():
			var letter: String = rows[y][x]
			if not legend.has(letter):
				continue
			var entry: Dictionary = legend[letter]
			var is_removable: bool = entry.has("removible")
			if not is_removable and not entry.has("extraccion"):
				continue
			var values: Dictionary = entry["removible"] if is_removable else entry["extraccion"]
			var obstacle := ObstacleSpec.new()
			obstacle.cell = Vector2i(x, y)
			obstacle.letter = StringName(letter)
			obstacle.kind = ObstacleSpec.Kind.REMOVABLE if is_removable else ObstacleSpec.Kind.EXTRACTION
			obstacle.class_id = StringName(values["class"])
			obstacle.cost = int(values["costo"])
			if is_removable:
				obstacle.seconds = float(values["tiempo"])
				obstacle.reward_amount = int(values["recursos"])
				obstacle.chance_percent = int(values["probabilidad"])
				obstacle.finding_collection = values["finding"]
				obstacle.repeat_reward = int(values["repeat_reward"])
				if obstacle.finding_collection != &"":
					if finding_letters.has(letter):
						pass  # La misma letra puede ocupar varias casillas: sigue siendo una sola pieza del nivel.
					else:
						finding_letters[letter] = true
						if findings.has(obstacle.finding_collection):
							_add(errors, "leyenda \"%s\" en %s" % [letter, MapGrid.where(obstacle.cell)], "ya hay un hallazgo de la colección \"%s\" en este nivel (letra \"%s\")." % [obstacle.finding_collection, findings[obstacle.finding_collection]])
						else:
							findings[obstacle.finding_collection] = letter
			else:
				obstacle.production = int(values["produccion"])
				obstacle.reserve = int(values["reserva"])
			result.append(obstacle)
	return result


static func _collection_definitions() -> Dictionary:
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string("res://data/progression.json")) != OK or not parser.data is Dictionary:
		return {}
	return parser.data


static func _nonnegative_whole(value: Variant, where: String, errors: PackedStringArray, must_be_positive: bool) -> bool:
	if not _is_number(value) or float(value) != floorf(float(value)) or float(value) < 0.0 or (must_be_positive and float(value) <= 0.0):
		_add(errors, where, "tiene que ser %s." % ("un número entero mayor que 0" if must_be_positive else "un número entero de 0 para arriba"))
		return false
	return true


static func _positive_number(value: Variant, where: String, errors: PackedStringArray) -> bool:
	if not _is_number(value) or float(value) <= 0.0:
		_add(errors, where, "tiene que ser mayor que 0.")
		return false
	return true


static func _probability(value: Variant, where: String, errors: PackedStringArray) -> bool:
	if not _nonnegative_whole(value, where + " → probabilidad", errors, false) or float(value) > 100.0:
		if _is_number(value) and float(value) > 100.0:
			_add(errors, where, "\"probabilidad\" no puede superar 100.")
		return false
	return true


## Por qué una letra no sirve para la leyenda ("" si sirve): una sola, y que no sea una que ya significa algo.
static func _legend_letter_problem(letter: String) -> String:
	if letter.length() != 1:
		return "tiene que ser una sola letra o símbolo."
	if ". # X S".contains(letter) or MapGrid.ENTRANCE_LETTERS.contains(letter):
		return "esa letra ya significa algo (. # X S y las entradas A a H)."
	if letter == " " or letter == "\"" or letter == "\\":
		return "no puede ser un espacio, una comilla ni una barra."
	return ""


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


## Un número entero (JSON no distingue 5 de 5.0) de `minimum` a `maximum` (RF-223).
## Se compara como decimal ANTES de convertir a entero: un número gigante no desborda.
static func _whole(data: Dictionary, key: String, where: String, minimum: int, maximum: int, errors: PackedStringArray) -> int:
	if not data.has(key):
		_add(errors, where, "falta \"%s\"." % [key])
		return minimum
	var value: Variant = data[key]
	if not _is_number(value) or float(value) != floorf(float(value)):
		_add(errors, where, "\"%s\" tiene que ser un número entero." % [key])
		return minimum
	if float(value) < minimum:
		_add(errors, where, "\"%s\" tiene que ser %d o más." % [key, minimum])
		return minimum
	if float(value) > maximum:
		_add(errors, where, "\"%s\" tiene que ser %d o menos (es demasiado grande)." % [key, maximum])
		return minimum
	return int(value)


## Un número (con decimales o no) de 0 a `maximum`: segundos (RF-223).
static func _number(data: Dictionary, key: String, where: String, maximum: float, errors: PackedStringArray) -> float:
	if not data.has(key):
		_add(errors, where, "falta \"%s\"." % [key])
		return 0.0
	var value: Variant = data[key]
	if not _is_number(value) or float(value) < 0.0:
		_add(errors, where, "\"%s\" tiene que ser un número de 0 para arriba (segundos)." % [key])
		return 0.0
	if float(value) > maximum:
		_add(errors, where, "\"%s\" tiene que ser %s segundos o menos." % [key, _shown(maximum)])
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
