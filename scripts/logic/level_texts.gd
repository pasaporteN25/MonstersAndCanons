# Los textos de un nivel (M52, RF-464): el lugar, la entrada, la victoria y el epílogo. Valida el campo
# `"textos"` del archivo del nivel con mensajes claros (RF-204) y devuelve los textos ya listos.
# Es lógica pura, sin escena (P10): se prueba sin abrir ventanas. Los límites son de interfaz (no de
# balance), por eso viven acá y no en `data/`.
class_name LevelTexts
extends RefCounted

const KEY_PLACE: String = "lugar"
const KEY_INTRO: String = "entrada"
const KEY_WIN: String = "victoria"
const KEY_EPILOGUE: String = "epilogo"
const KEYS: PackedStringArray = ["lugar", "entrada", "victoria", "epilogo"]

const PLACE_MAX_CHARS: int = 32
const INTRO_MAX_LINES: int = 3
const INTRO_MAX_CHARS: int = 240
const WIN_MAX_LINES: int = 2
const WIN_MAX_CHARS: int = 160
const EPILOGUE_MIN_LINES: int = 3
const EPILOGUE_MAX_LINES: int = 5
const EPILOGUE_MAX_CHARS: int = 400
const LINE_MAX_CHARS: int = 90


## Lee el campo `"textos"` (el valor ya parseado del JSON, o null si el nivel no lo trae).
## Devuelve {lugar, entrada, victoria, epilogo} con cadenas vacías donde falta. Los problemas se agregan
## a `errors` (con "textos" por delante, como el resto de los mensajes del nivel).
static func parse(raw: Variant, errors: PackedStringArray) -> Dictionary:
	var result: Dictionary = empty()
	if raw == null:
		return result
	if not raw is Dictionary:
		errors.append("textos: tiene que ser un objeto con %s, como {\"lugar\": \"El paso del agua\"}." % ", ".join(KEYS))
		return result
	var data: Dictionary = raw
	for key: Variant in data.keys():
		if not KEYS.has(str(key)):
			errors.append("textos: clave desconocida \"%s\" (se usan: %s)." % [key, ", ".join(KEYS)])
	for key: String in KEYS:
		if not data.has(key):
			continue
		var value: Variant = data[key]
		if not value is String:
			errors.append("textos \"%s\": tiene que ser un texto entre comillas." % key)
			continue
		var text: String = value
		if text.strip_edges().is_empty():
			errors.append("textos \"%s\" está vacío: sacá la clave si no querés texto." % key)
			continue
		if _has_control_chars(text):
			errors.append("textos \"%s\": tiene caracteres de control (solo se permite el salto de línea \\n)." % key)
			continue
		var before: int = errors.size()
		_check_limits(key, text, errors)
		if errors.size() == before:
			result[key] = text
	return result


## Todos los textos vacíos (un nivel sin el campo).
static func empty() -> Dictionary:
	return {KEY_PLACE: "", KEY_INTRO: "", KEY_WIN: "", KEY_EPILOGUE: ""}


## Las líneas de un texto (separadas por `\n`), sin líneas en blanco al final.
static func lines_of(text: String) -> PackedStringArray:
	return PackedStringArray(text.split("\n"))


static func _check_limits(key: String, text: String, errors: PackedStringArray) -> void:
	var lines: PackedStringArray = lines_of(text)
	var max_chars: int = 0
	var min_lines: int = 1
	var max_lines: int = 1
	match key:
		KEY_PLACE:
			max_chars = PLACE_MAX_CHARS
		KEY_INTRO:
			max_chars = INTRO_MAX_CHARS
			max_lines = INTRO_MAX_LINES
		KEY_WIN:
			max_chars = WIN_MAX_CHARS
			max_lines = WIN_MAX_LINES
		_:
			max_chars = EPILOGUE_MAX_CHARS
			min_lines = EPILOGUE_MIN_LINES
			max_lines = EPILOGUE_MAX_LINES
	if lines.size() > max_lines:
		errors.append("textos \"%s\" tiene %d líneas y el máximo es %d." % [key, lines.size(), max_lines])
	elif lines.size() < min_lines:
		errors.append("textos \"%s\" tiene %d líneas y el mínimo es %d." % [key, lines.size(), min_lines])
	if text.length() > max_chars:
		errors.append("textos \"%s\" tiene %d caracteres y el máximo es %d." % [key, text.length(), max_chars])
	for i: int in lines.size():
		if lines[i].strip_edges().is_empty():
			errors.append("textos \"%s\": la línea %d está en blanco." % [key, i + 1])
		elif lines[i].length() > LINE_MAX_CHARS:
			errors.append("textos \"%s\": la línea %d tiene %d caracteres y el máximo por línea es %d." % [key, i + 1, lines[i].length(), LINE_MAX_CHARS])


static func _has_control_chars(text: String) -> bool:
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if code < 32 and code != 10:
			return true
		if code == 127:
			return true
	return false
