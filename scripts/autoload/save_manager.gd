# Guarda y carga el progreso y las opciones (RF-115, plan §7.1).
# Es un autoload: existe siempre y se usa como `SaveManager`.
#
# Si el archivo no existe, está corrupto o es de otra versión, se empieza con el
# progreso por defecto y el juego NO se cierra.
extends Node

const SAVE_VERSION: int = 1
const DEFAULT_PATH: String = "user://save.json"
## RF-194: la tabla del Salón de la fama se guarda junto a las de los niveles, con este nombre.
const HALL_OF_FAME_ID: StringName = &"hall_of_fame"
const DEFAULT_SETTINGS: Dictionary = {
	"music_volume": 0.7, "sfx_volume": 0.8, "fullscreen": false, "damage_numbers": true,
}

## Los tests lo cambian para no tocar el guardado real del jugador.
var save_path: String = DEFAULT_PATH

var _levels: Dictionary = {}    # { "level_01": {"unlocked": bool, "completed": bool, "best_lives": int} }
var _settings: Dictionary = {}
## RF-134: enemigos ya presentados al jugador (sus id), para no repetir la tarjeta.
var _seen_enemies: Array[String] = []
## RF-191: récords de cada nivel: { "level_01": [{"name": "LUC", "points": 1234}, …] }.
var _scores: Dictionary = {}
## RF-192: últimas iniciales usadas, por largo: { "3": "LUC", "5": "LUCAS" }.
var _last_initials: Dictionary = {}


func _ready() -> void:
	load_save()


# --- Archivo ---

func load_save() -> void:
	_levels = {}
	_settings = DEFAULT_SETTINGS.duplicate()
	_seen_enemies = []
	_scores = {}
	_last_initials = {}
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	# JSON.new().parse() en vez de JSON.parse_string(): un archivo roto es un caso
	# previsto (se empieza de cero), no un error del programa que haya que registrar.
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(file.get_as_text()) == OK else null
	if not parsed is Dictionary or int((parsed as Dictionary).get("version", 0)) != SAVE_VERSION:
		push_warning("Guardado ilegible o de otra versión: se empieza de cero (%s)" % save_path)
		return
	_read_levels((parsed as Dictionary).get("levels", {}))
	_read_settings((parsed as Dictionary).get("settings", {}))
	_read_seen_enemies((parsed as Dictionary).get("seen_enemies", []))
	_read_scores((parsed as Dictionary).get("scores", {}))
	_read_initials((parsed as Dictionary).get("initials", {}))


func save() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar en %s" % save_path)
		return false
	var data := {"version": SAVE_VERSION, "levels": _levels, "settings": _settings,
		"seen_enemies": _seen_enemies, "scores": _scores, "initials": _last_initials}
	file.store_string(JSON.stringify(data, "  "))
	return true


# --- Progreso de niveles (RF-111, RF-112) ---

func is_unlocked(level_id: StringName) -> bool:
	return _level(level_id).get("unlocked", false)


func is_completed(level_id: StringName) -> bool:
	return _level(level_id).get("completed", false)


## Mejor cantidad de vidas con la que se ganó el nivel (0 si nunca se ganó).
func best_lives(level_id: StringName) -> int:
	return _level(level_id).get("best_lives", 0)


func unlock(level_id: StringName) -> void:
	var entry: Dictionary = _level(level_id)
	entry["unlocked"] = true
	_levels[String(level_id)] = entry


## Se ganó el nivel: queda completado y se guarda la mejor cantidad de vidas.
func record_victory(level_id: StringName, lives: int) -> void:
	var entry: Dictionary = _level(level_id)
	entry["unlocked"] = true
	entry["completed"] = true
	entry["best_lives"] = maxi(lives, entry.get("best_lives", 0))
	_levels[String(level_id)] = entry


# --- Enemigos ya presentados (RF-134) ---

func has_seen_enemy(enemy_id: StringName) -> bool:
	return _seen_enemies.has(String(enemy_id))


func mark_enemy_seen(enemy_id: StringName) -> void:
	if not has_seen_enemy(enemy_id):
		_seen_enemies.append(String(enemy_id))


# --- Récords (RF-191, RF-192) ---

## Una copia de la tabla de récords de un nivel (o de otra tabla, como "hall_of_fame").
func scores(table_id: StringName) -> Array:
	return (_scores.get(String(table_id), []) as Array).duplicate(true)


## Anota un récord. Devuelve la posición en que quedó (0 = primero) o -1 si no entró.
func add_score(table_id: StringName, name: String, points: int) -> int:
	var table: Array = _scores.get(String(table_id), [])
	var index: int = HighScores.insert(table, name, points)
	_scores[String(table_id)] = table
	return index


## Las últimas iniciales usadas de ese largo (la primera vez, "AAA" o "AAAAA").
func last_initials(length: int) -> String:
	return HighScores.clean_name(String(_last_initials.get(str(length), "")), length)


func set_last_initials(name: String) -> void:
	_last_initials[str(name.length())] = name


# --- Opciones (RF-113) ---

func get_setting(key: String) -> Variant:
	return _settings.get(key, DEFAULT_SETTINGS.get(key))


func set_setting(key: String, value: Variant) -> void:
	_settings[key] = value


# --- Lectura defensiva: cualquier dato raro se ignora ---

func _level(level_id: StringName) -> Dictionary:
	return (_levels.get(String(level_id), {}) as Dictionary).duplicate()


func _read_levels(raw: Variant) -> void:
	if not raw is Dictionary:
		return
	for id: Variant in raw:
		var entry: Variant = raw[id]
		if not entry is Dictionary:
			continue
		# JSON guarda todos los números como decimales: se vuelven a entero.
		_levels[str(id)] = {
			"unlocked": bool(entry.get("unlocked", false)),
			"completed": bool(entry.get("completed", false)),
			"best_lives": int(entry.get("best_lives", 0)),
		}


func _read_seen_enemies(raw: Variant) -> void:
	if not raw is Array:
		return
	for id: Variant in raw:
		if id is String and not _seen_enemies.has(id):
			_seen_enemies.append(id)


func _read_scores(raw: Variant) -> void:
	if not raw is Dictionary:
		return
	for table_id: Variant in raw:
		var entries: Variant = raw[table_id]
		if not entries is Array:
			continue
		var is_hall: bool = str(table_id) == HALL_OF_FAME_ID
		var length: int = HighScores.HALL_NAME_LENGTH if is_hall else HighScores.LEVEL_NAME_LENGTH
		var table: Array = []
		for entry: Variant in entries:
			if entry is Dictionary and entry.get("name") is String and typeof(entry.get("points")) in [TYPE_INT, TYPE_FLOAT]:
				HighScores.insert(table, HighScores.clean_name(entry["name"], length), int(entry["points"]))
		_scores[str(table_id)] = table


func _read_initials(raw: Variant) -> void:
	if not raw is Dictionary:
		return
	for key: Variant in raw:
		if raw[key] is String:
			_last_initials[str(key)] = raw[key]


func _read_settings(raw: Variant) -> void:
	if not raw is Dictionary:
		return
	for key: String in DEFAULT_SETTINGS:
		if raw.has(key) and typeof(raw[key]) in [TYPE_FLOAT, TYPE_INT, TYPE_BOOL]:
			_settings[key] = raw[key]
