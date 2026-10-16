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
	"ui_mode": 0,
}

## Los tests lo cambian para no tocar el guardado real del jugador.
var save_path: String = DEFAULT_PATH

var _levels: Dictionary = {}    # { "level_01": {"unlocked", "completed", "best_lives", "best_score"} }
var _settings: Dictionary = {}
## RF-134: enemigos ya presentados al jugador (sus id), para no repetir la tarjeta.
var _seen_enemies: Array[String] = []
## RF-191: récords de cada nivel: { "level_01": [{"name": "LUC", "points": 1234}, …] }.
var _scores: Dictionary = {}
## RF-192: últimas iniciales usadas, por largo: { "3": "LUC", "5": "LUCAS" }.
var _last_initials: Dictionary = {}
## RF-194: el total de la campaña que ya se anotó (o se ofreció) en el Salón de la fama.
var _hall_total: int = 0
## RF-359: fuentes únicas por colección; opcional para guardados anteriores.
var _collections: Dictionary = {}
## RF-498: ¿ya se mostró la intro? Clave aditiva (no sube SAVE_VERSION); sin ella, o si no es booleana, vale `false`.
var _intro_seen: bool = false
## RF-508: preferencias aditivas de posición y lado de los botones flotantes.
var _ui_prefs: UiPrefs


func _ready() -> void:
	load_save()


# --- Archivo ---

func load_save() -> void:
	_levels = {}
	_settings = DEFAULT_SETTINGS.duplicate()
	_seen_enemies = []
	_scores = {}
	_last_initials = {}
	_hall_total = 0
	_collections = {}
	_intro_seen = false
	_ui_prefs = UiPrefs.new()
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
	_read_collections((parsed as Dictionary).get("collections", {}))
	_read_levels((parsed as Dictionary).get("levels", {}))
	_read_settings((parsed as Dictionary).get("settings", {}))
	_read_seen_enemies((parsed as Dictionary).get("seen_enemies", []))
	_read_scores((parsed as Dictionary).get("scores", {}))
	_read_initials((parsed as Dictionary).get("initials", {}))
	var hall_total: Variant = (parsed as Dictionary).get("hall_total", 0)
	_hall_total = int(hall_total) if typeof(hall_total) in [TYPE_INT, TYPE_FLOAT] else 0
	var intro_seen: Variant = (parsed as Dictionary).get("intro_seen", false)
	_intro_seen = typeof(intro_seen) == TYPE_BOOL and intro_seen  # solo `true` booleano cuenta (RF-498)
	_ui_prefs = UiPrefs.read((parsed as Dictionary).get("ui_prefs", null))


func save() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar en %s" % save_path)
		return false
	var data := {"version": SAVE_VERSION, "levels": _levels, "settings": _settings,
		"seen_enemies": _seen_enemies, "scores": _scores, "initials": _last_initials, "hall_total": _hall_total, "collections": _collections,
		"intro_seen": _intro_seen, "ui_prefs": _ui_prefs.to_dict()}
	file.store_string(JSON.stringify(data, "  "))
	return true


# --- La intro (RF-498) ---

func intro_seen() -> bool:
	return _intro_seen


## Marca la intro como vista y guarda enseguida (al abrirse, no al terminarla).
func mark_intro_seen() -> void:
	_intro_seen = true
	save()


# --- Colecciones (RF-359/360) ---
func collected_sources(collection: StringName) -> PackedStringArray:
	return PackedStringArray(_collections.get(String(collection), []))

func collection_complete(collection: StringName) -> bool:
	var needed: int = CollectibleRun.required(collection)
	return needed > 0 and collected_sources(collection).size() >= needed

func collect_source(collection: StringName, source: StringName) -> void:
	if not CollectibleRun.eligible(collection, source):
		return
	var sources: Array = _collections.get(String(collection), [])
	if not sources.has(String(source)):
		sources.append(String(source))
	_collections[String(collection)] = sources

func _read_collections(raw: Variant) -> void:
	if not raw is Dictionary:
		return
	for collection: Variant in raw:
		if not collection is String or not raw[collection] is Array:
			continue
		for source: Variant in raw[collection]:
			if source is String:
				collect_source(StringName(collection), StringName(source))

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
## RF-194: `score` = puntos de esa victoria; se guarda el mejor (suma para el Salón de la fama).
func record_victory(level_id: StringName, lives: int, score: int = 0) -> void:
	var entry: Dictionary = _level(level_id)
	entry["unlocked"] = true
	entry["completed"] = true
	entry["best_lives"] = maxi(lives, entry.get("best_lives", 0))
	entry["best_score"] = maxi(score, entry.get("best_score", 0))
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


## RF-194: mejor puntaje en una victoria de ese nivel (0 si nunca se ganó).
func best_score(level_id: StringName) -> int:
	return _level(level_id).get("best_score", 0)


func hall_total() -> int:
	return _hall_total


func set_hall_total(total: int) -> void:
	_hall_total = total


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


func get_ui_prefs() -> UiPrefs:
	return UiPrefs.read(_ui_prefs.to_dict())


func set_ui_prefs(prefs: UiPrefs) -> void:
	_ui_prefs = UiPrefs.read(prefs.to_dict())
	save()


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
			"best_score": int(entry.get("best_score", 0)),
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
