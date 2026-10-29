# Los datos del tutorial del nivel 1 (M63, RF-571): lee y valida `data/tutorial/tutorial.json` (los pasos y los
# textos, una lista para la PC y otra para el modo celular, más los rótulos de la tarjeta). Es lógica pura, sin
# escena (P10): se prueba sin abrir ventanas. Los errores van en castellano y nombran el paso («el paso 3 del
# celular tiene 3 líneas y el máximo es 2»). Un tutorial con errores no se muestra y el nivel 1 se juega como
# siempre (RF-570): el tutorial nunca bloquea jugar.
#
# Qué es cada paso (su `"paso"`) y qué hace falta para pasar al siguiente vive acá, en `STEPS`: el texto, el orden
# y cuáles pasos se usan es de Lucas (se cambia en el archivo); la acción que cada paso espera es del código.
class_name TutorialData
extends RefCounted

const DEFAULT_PATH: String = "res://data/tutorial/tutorial.json"
const SUPPORTED_VERSION: int = 1
const MODE_PC: String = "pc"
const MODE_MOBILE: String = "celular"
## Límites de los textos de los pasos (de interfaz, no de balance): textos cortos.
const MAX_LINES: int = 2
const MAX_LINE_CHARS: int = 80
const MAX_TOTAL_CHARS: int = 160
const MAX_UI_CHARS: int = 40

## Los rótulos de la tarjeta (`"interfaz"`). `paso` lleva dos `%d` (número y total).
const UI_KEYS: PackedStringArray = ["titulo", "paso", "siguiente", "saltar", "terminar"]

## Los eventos que hacen pasar de paso (los emite `TutorialController`). Vacío = paso de lectura: avanza con «Siguiente».
const EVENT_NONE: StringName = &""
const EVENT_TOWER_SELECTED: StringName = &"tower_selected"
const EVENT_TOWER_BUILT: StringName = &"tower_built"
const EVENT_CATALOG_OPENED: StringName = &"catalog_opened"
const EVENT_WAVE_STARTED: StringName = &"wave_started"
const EVENT_PLACED_SELECTED: StringName = &"placed_selected"
const EVENT_SPEED_CHANGED: StringName = &"speed_changed"
const EVENT_PAUSED: StringName = &"paused"
const EVENT_RESUMED: StringName = &"resumed"

## Todos los pasos que existen: qué evento espera cada uno y en qué modos se usa.
const STEPS: Dictionary = {
	"welcome": {"event": EVENT_NONE, "pc": true, "celular": true},
	"path": {"event": EVENT_NONE, "pc": true, "celular": true},
	"gold": {"event": EVENT_NONE, "pc": true, "celular": true},
	"lives": {"event": EVENT_NONE, "pc": true, "celular": true},
	"pick_tower": {"event": EVENT_TOWER_SELECTED, "pc": true, "celular": false},
	"place_tower": {"event": EVENT_TOWER_BUILT, "pc": true, "celular": false},
	"open_cart": {"event": EVENT_CATALOG_OPENED, "pc": false, "celular": true},
	"pick_card": {"event": EVENT_TOWER_SELECTED, "pc": false, "celular": true},
	"confirm_tower": {"event": EVENT_TOWER_BUILT, "pc": false, "celular": true},
	"start_wave": {"event": EVENT_WAVE_STARTED, "pc": true, "celular": true},
	"select_tower": {"event": EVENT_PLACED_SELECTED, "pc": true, "celular": true},
	"upgrade": {"event": EVENT_NONE, "pc": true, "celular": true},
	"sell": {"event": EVENT_NONE, "pc": true, "celular": true},
	"speed": {"event": EVENT_SPEED_CHANGED, "pc": true, "celular": true},
	"pause": {"event": EVENT_PAUSED, "pc": true, "celular": true},
	"resume": {"event": EVENT_RESUMED, "pc": true, "celular": true},
	"done": {"event": EVENT_NONE, "pc": true, "celular": true},
}

## Lo que el tutorial tiene que enseñar sí o sí (RF-572, RF-573): sin estos pasos el archivo no vale.
const REQUIRED_PC: PackedStringArray = ["path", "gold", "lives", "pick_tower", "place_tower", "start_wave",
		"upgrade", "sell", "speed", "pause"]
const REQUIRED_MOBILE: PackedStringArray = ["path", "gold", "lives", "open_cart", "pick_card", "confirm_tower",
		"start_wave", "upgrade", "sell", "speed", "pause"]
## Pares que tienen que ir en este orden si están los dos: [antes, después].
const ORDER_RULES: Array = [["pick_tower", "place_tower"], ["open_cart", "pick_card"], ["pick_card", "confirm_tower"],
		["pause", "resume"]]

var level_id: String = ""
## `true` mientras Lucas no aprobó los textos (RF-571). No cambia el comportamiento: solo avisa.
var draft: bool = true
var ui: Dictionary = {}
var pc_steps: Array[Dictionary] = []
var mobile_steps: Array[Dictionary] = []
var errors: PackedStringArray = []


## Lee el archivo. Si no existe, no se puede leer o no es JSON, el resultado trae el error y ningún paso.
static func load_file(path: String = DEFAULT_PATH) -> TutorialData:
	var data := TutorialData.new()
	if not FileAccess.file_exists(path):
		data.errors.append("tutorial: no existe el archivo %s." % path)
		return data
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		data.errors.append("tutorial: no se pudo abrir %s." % path)
		return data
	# JSON.new().parse() en vez de JSON.parse_string(): un archivo roto es un caso previsto.
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		data.errors.append("tutorial: %s no es un JSON válido (línea %d: %s)." % [path, json.get_error_line(), json.get_error_message()])
		return data
	return parse(json.data)


## Valida el contenido ya leído del JSON.
static func parse(raw: Variant) -> TutorialData:
	var data := TutorialData.new()
	if not raw is Dictionary:
		data.errors.append("tutorial: el archivo tiene que ser un objeto con \"version\", \"pc\" y \"celular\".")
		return data
	var dict: Dictionary = raw
	if not _is_number(dict.get("version")) or float(dict["version"]) != float(SUPPORTED_VERSION):
		data.errors.append("tutorial: \"version\" tiene que ser %d." % SUPPORTED_VERSION)
	if typeof(dict.get("borrador")) != TYPE_BOOL:
		data.errors.append("tutorial: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).")
	else:
		data.draft = dict["borrador"]
	var level_raw: Variant = dict.get("nivel")
	if not level_raw is String or (level_raw as String).strip_edges().is_empty():
		data.errors.append("tutorial: \"nivel\" tiene que ser el id del nivel donde se muestra, como \"level_01\".")
	else:
		data.level_id = level_raw
	_parse_ui(dict.get("interfaz"), data)
	data.pc_steps = _parse_steps(MODE_PC, dict.get(MODE_PC), data.errors)
	data.mobile_steps = _parse_steps(MODE_MOBILE, dict.get(MODE_MOBILE), data.errors)
	return data


func is_valid() -> bool:
	return errors.is_empty() and not pc_steps.is_empty() and not mobile_steps.is_empty()


## Los pasos del modo: `[{"paso": String, "texto": String}]`.
func steps_for(mobile: bool) -> Array[Dictionary]:
	var steps: Array[Dictionary] = mobile_steps if mobile else pc_steps
	if Localization.language == Localization.DEFAULT_LANGUAGE:
		return steps
	# T534: en otro idioma el texto sale del catálogo (`tutorial.<modo>_<paso>.text`); los pasos y eventos son los mismos.
	var translated: Array[Dictionary] = []
	for step: Dictionary in steps:
		var copy: Dictionary = step.duplicate()
		copy["texto"] = Localization.data_text("tutorial", StringName("%s_%s" % [MODE_MOBILE if mobile else MODE_PC, step["paso"]]), "text", String(step["texto"]))
		translated.append(copy)
	return translated


## T534: un rótulo de la tarjeta (`"titulo"`, `"paso"`, …) en el idioma activo.
func ui_text(key: String) -> String:
	return Localization.data_text("tutorial", &"ui", key, String(ui[key]))


## El evento que espera un paso (`EVENT_NONE` si se lee y se toca «Siguiente», o si el paso no existe).
static func event_of(step_id: String) -> StringName:
	return (STEPS.get(step_id, {}) as Dictionary).get("event", EVENT_NONE)


static func is_known(step_id: String) -> bool:
	return STEPS.has(step_id)


static func _parse_ui(raw: Variant, data: TutorialData) -> void:
	if not raw is Dictionary:
		data.errors.append("tutorial: \"interfaz\" tiene que ser un objeto con %s." % ", ".join(UI_KEYS))
		return
	var ui_raw: Dictionary = raw
	for key: String in UI_KEYS:
		var value: Variant = ui_raw.get(key)
		if not value is String or (value as String).strip_edges().is_empty():
			data.errors.append("tutorial: \"interfaz\" \"%s\" tiene que ser un texto no vacío." % key)
		elif (value as String).length() > MAX_UI_CHARS:
			data.errors.append("tutorial: \"interfaz\" \"%s\" tiene %d caracteres y el máximo es %d." % [key, (value as String).length(), MAX_UI_CHARS])
		else:
			data.ui[key] = value
	if data.ui.has("paso") and String(data.ui["paso"]).count("%d") != 2:
		data.errors.append("tutorial: \"interfaz\" \"paso\" tiene que llevar dos %d (el número del paso y el total), como \"Paso %d de %d\".")
		data.ui.erase("paso")
	for key: Variant in ui_raw.keys():
		if not UI_KEYS.has(str(key)):
			data.errors.append("tutorial: \"interfaz\" no usa la clave \"%s\" (se usan: %s)." % [key, ", ".join(UI_KEYS)])


static func _parse_steps(mode: String, raw: Variant, errors: PackedStringArray) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	var label: String = "la lista \"%s\"" % mode
	if not raw is Array:
		errors.append("tutorial: %s tiene que ser una lista de pasos." % label)
		return steps
	var seen: Array[String] = []
	var before: int = errors.size()
	for i: int in (raw as Array).size():
		var step: Variant = (raw as Array)[i]
		var number: int = i + 1
		var where: String = "el paso %d de %s" % [number, mode]
		if not step is Dictionary:
			errors.append("%s tiene que ser un objeto con \"paso\" y \"texto\"." % where)
			continue
		var id_raw: Variant = (step as Dictionary).get("paso")
		if not id_raw is String or not is_known(id_raw):
			errors.append("%s: \"paso\" `%s` no existe (se usan: %s)." % [where, str(id_raw), ", ".join(PackedStringArray(STEPS.keys()))])
			continue
		var id: String = id_raw
		if not bool((STEPS[id] as Dictionary)[mode]):
			errors.append("%s: el paso \"%s\" no se usa en %s." % [where, id, "la PC" if mode == MODE_PC else "el modo celular"])
			continue
		if seen.has(id):
			errors.append("%s: el paso \"%s\" está repetido." % [where, id])
			continue
		var text_raw: Variant = (step as Dictionary).get("texto")
		if not text_raw is String:
			errors.append("%s (\"%s\"): \"texto\" tiene que ser un texto entre comillas." % [where, id])
			continue
		var text_errors: PackedStringArray = _text_errors(text_raw)
		for message: String in text_errors:
			errors.append("%s (\"%s\") %s" % [where, id, message])
		if not text_errors.is_empty():
			continue
		seen.append(id)
		steps.append({"paso": id, "texto": text_raw})
	if errors.size() > before:
		return steps
	_check_coverage(mode, seen, errors)
	return steps


static func _check_coverage(mode: String, ids: Array[String], errors: PackedStringArray) -> void:
	var required: PackedStringArray = REQUIRED_PC if mode == MODE_PC else REQUIRED_MOBILE
	for id: String in required:
		if not ids.has(id):
			errors.append("la lista \"%s\" no tiene el paso \"%s\" y hace falta." % [mode, id])
	for rule: Array in ORDER_RULES:
		if ids.has(rule[0]) and ids.has(rule[1]) and ids.find(rule[0]) > ids.find(rule[1]):
			errors.append("la lista \"%s\": el paso \"%s\" tiene que ir antes que \"%s\"." % [mode, rule[0], rule[1]])
	if ids.has("pause") and not ids.has("resume"):
		errors.append("la lista \"%s\": después de \"pause\" tiene que ir \"resume\" (si no, la partida quedaría pausada)." % mode)
	if ids.has("done") and ids.find("done") != ids.size() - 1:
		errors.append("la lista \"%s\": el paso \"done\" tiene que ser el último." % mode)


## Los problemas de un texto (vacío si está bien). Mismas reglas de caracteres que los textos de los niveles.
static func _text_errors(text: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	if text.strip_edges().is_empty():
		problems.append("tiene el texto vacío.")
		return problems
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if (code < 32 and code != 10) or code == 127:
			problems.append("tiene caracteres de control (solo se permite el salto de línea \\n).")
			return problems
	var lines: PackedStringArray = LevelTexts.lines_of(text)
	if lines.size() > MAX_LINES:
		problems.append("tiene %d líneas y el máximo es %d." % [lines.size(), MAX_LINES])
	if text.length() > MAX_TOTAL_CHARS:
		problems.append("tiene %d caracteres y el máximo es %d." % [text.length(), MAX_TOTAL_CHARS])
	for i: int in lines.size():
		if lines[i].strip_edges().is_empty():
			problems.append("tiene la línea %d en blanco." % (i + 1))
		elif lines[i].length() > MAX_LINE_CHARS:
			problems.append("tiene la línea %d con %d caracteres y el máximo por línea es %d." % [i + 1, lines[i].length(), MAX_LINE_CHARS])
	return problems


static func _is_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT]
