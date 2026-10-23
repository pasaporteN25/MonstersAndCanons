# Los números de la entrada de los jefes (M66, RF-601, P2): duraciones, tamaño del cartel y fuentes, en
# `data/ui/entrada_jefes.json`. Si el archivo falta o un campo está mal, se usa el valor por omisión y el error
# queda en `errors` (en castellano, con el nombre del campo). Lo lee la interfaz; no hay lógica acá.
class_name BossEntranceConfig
extends RefCounted

const PATH: String = "res://data/ui/entrada_jefes.json"
const DEFAULTS: Dictionary = {
	"destello_s": 0.7,
	"cartel_entra_s": 0.25,
	"cartel_quieto_s": 1.1,
	"cartel_sale_s": 0.25,
	"salteo_s": 0.1,
	"cartel_ancho_px": 720,
	"cartel_alto_px": 120,
	"intervalo_min_s": 8.0,
	"retrato_px": 88,
	"titulo_fuente_px": 13,
	"nombre_fuente_px": 20,
	"frase_fuente_px": 14,
	"pista_fuente_px": 13,
	"arriba_pc_px": 56,
	"arriba_celular_px": 72,
}
## Límite del cartel (RF-598): como mucho 720 × 120 px virtuales.
const MAX_WIDTH_PX: int = 720
const MAX_HEIGHT_PX: int = 120
## Una duración fuera de (0, MAX_SECONDS] es un error de tipeo, no una decisión.
const MAX_SECONDS: float = 5.0

var values: Dictionary = DEFAULTS.duplicate(true)
var errors: PackedStringArray = []


static func load_from(path: String = PATH) -> BossEntranceConfig:
	var config := BossEntranceConfig.new()
	if not FileAccess.file_exists(path):
		config.errors.append("entrada de jefes: no existe el archivo %s; se usan los valores por omisión." % path)
		return config
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		config.errors.append("entrada de jefes: no se pudo abrir %s." % path)
		return config
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		config.errors.append("entrada de jefes: %s no es un JSON válido (línea %d: %s)." % [
			path, parser.get_error_line(), parser.get_error_message()])
		return config
	return parse(parser.data)


static func parse(raw: Variant) -> BossEntranceConfig:
	var config := BossEntranceConfig.new()
	if not raw is Dictionary:
		config.errors.append("entrada de jefes: el archivo tiene que ser un objeto con los campos.")
		return config
	var data: Dictionary = raw
	for key: Variant in data:
		if not DEFAULTS.has(key):
			config.errors.append("entrada de jefes: el campo «%s» no existe." % key)
	for key: String in DEFAULTS:
		if not data.has(key):
			continue
		var value: Variant = data[key]
		var default_value: Variant = DEFAULTS[key]
		if not (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT):
			config.errors.append("entrada de jefes: «%s» tiene que ser un número." % key)
			continue
		var number: float = float(value)
		var problem: String = _range_problem(key, number)
		if problem != "":
			config.errors.append("entrada de jefes: «%s» %s (vale %s)." % [key, problem, str(value)])
			continue
		config.values[key] = roundi(number) if typeof(default_value) == TYPE_INT else number
	return config


static func _range_problem(key: String, number: float) -> String:
	if key == "intervalo_min_s":
		return "no puede ser negativo" if number < 0.0 else ""
	if key.ends_with("_s"):
		if number <= 0.0 or number > MAX_SECONDS:
			return "tiene que estar entre 0 y %s segundos" % str(MAX_SECONDS)
		return ""
	if key == "cartel_ancho_px" and (number < 200.0 or number > MAX_WIDTH_PX):
		return "tiene que estar entre 200 y %d px" % MAX_WIDTH_PX
	if key == "cartel_alto_px" and (number < 56.0 or number > MAX_HEIGHT_PX):
		return "tiene que estar entre 56 y %d px (56 es el mínimo táctil)" % MAX_HEIGHT_PX
	if number < 0.0:
		return "no puede ser negativo"
	return ""


## Los ids de los niveles de la campaña (los archivos de `data/levels/`).
static func level_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for file: String in DirAccess.get_files_at(LevelFile.LEVELS_DIR):
		var clean: String = file.trim_suffix(".remap")
		if clean.ends_with(".json"):
			ids.append(clean.get_basename())
	ids.sort()
	return ids


## Los sonidos que existen en `Audio` (los .wav de `assets/audio/`; en un exportado aparecen como `.import`).
static func sound_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for file: String in DirAccess.get_files_at("res://assets/audio/"):
		var clean: String = file.trim_suffix(".import").trim_suffix(".remap")
		if clean.ends_with(".wav") and not ids.has(clean.get_basename()):
			ids.append(clean.get_basename())
	ids.sort()
	return ids


## Revisa la entrada de todos los enemigos de `data/enemies/`. Devuelve los errores en castellano.
static func validate_enemies() -> PackedStringArray:
	var errors := PackedStringArray()
	var levels: PackedStringArray = level_ids()
	var sounds: PackedStringArray = sound_ids()
	for enemy_id: String in LevelFile.enemy_ids():
		var enemy: EnemyData = LevelFile.find_enemy(enemy_id)
		if enemy != null and enemy.entrance != null:
			errors.append_array(BossEntranceRules.validate(enemy_id, enemy.entrance, levels, sounds))
	return errors


func get_value(key: String) -> Variant:
	return values.get(key, DEFAULTS.get(key))


func seconds(key: String) -> float:
	return float(get_value(key))


func pixels(key: String) -> int:
	return int(get_value(key))


func is_valid() -> bool:
	return errors.is_empty()
