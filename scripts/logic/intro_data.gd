# Los datos de la intro (M57, RF-497): lee y valida `data/intro/intro.json` (de 5 a 8 láminas con imagen, texto
# y segundos, más el fundido entre láminas). Es lógica pura, sin escena (P10): se prueba sin abrir ventanas.
# Los errores van en castellano y nombran la lámina («la lámina 3 tiene 3 líneas y el máximo es 2»).
# Los límites del texto son los de la victoria de un nivel (`LevelTexts`, RF-464): se reusan, no se copian.
# Una intro con errores no se muestra y «Jugar» sigue yendo a la selección de niveles (RF-498).
class_name IntroData
extends RefCounted

const DEFAULT_PATH: String = "res://data/intro/intro.json"
const SUPPORTED_VERSION: int = 1
const MIN_SLIDES: int = 5
const MAX_SLIDES: int = 8
const MIN_SECONDS: int = 4
const MAX_SECONDS: int = 12
const MAX_FADE_S: float = 2.0
const DEFAULT_FADE_S: float = 0.6
## La regla de lectura del guion (§2): `2 s + caracteres / 20`, redondeado hacia arriba, nunca menos de 5 s.
const READING_BASE_S: float = 2.0
const READING_CHARS_PER_S: float = 20.0
const READING_MIN_S: int = 5

## Las láminas en orden: [{"imagen": String, "texto": String, "segundos": int}].
var slides: Array[Dictionary] = []
var fade_s: float = DEFAULT_FADE_S
var errors: PackedStringArray = []


## Lee el archivo. Si no existe, no se puede leer o no es JSON, el resultado trae el error y ninguna lámina.
static func load_file(path: String = DEFAULT_PATH) -> IntroData:
	var data := IntroData.new()
	if not FileAccess.file_exists(path):
		data.errors.append("intro: no existe el archivo %s." % path)
		return data
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		data.errors.append("intro: no se pudo abrir %s." % path)
		return data
	# JSON.new().parse() en vez de JSON.parse_string(): un archivo roto es un caso previsto.
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		data.errors.append("intro: %s no es un JSON válido (línea %d: %s)." % [path, json.get_error_line(), json.get_error_message()])
		return data
	return parse(json.data)


## Valida el contenido ya leído del JSON.
static func parse(raw: Variant) -> IntroData:
	var data := IntroData.new()
	if not raw is Dictionary:
		data.errors.append("intro: el archivo tiene que ser un objeto con \"version\" y \"laminas\".")
		return data
	var dict: Dictionary = raw
	if not _is_number(dict.get("version")) or float(dict["version"]) != float(SUPPORTED_VERSION):
		data.errors.append("intro: \"version\" tiene que ser %d." % SUPPORTED_VERSION)
	if dict.has("fundido_s"):
		var fade: Variant = dict["fundido_s"]
		if not _is_number(fade) or float(fade) < 0.0 or float(fade) > MAX_FADE_S:
			data.errors.append("intro: \"fundido_s\" tiene que ser un número de 0 a %s segundos." % MAX_FADE_S)
		else:
			data.fade_s = float(fade)
	var raw_slides: Variant = dict.get("laminas")
	if not raw_slides is Array:
		data.errors.append("intro: \"laminas\" tiene que ser una lista de láminas.")
		return data
	var list: Array = raw_slides
	if list.size() < MIN_SLIDES or list.size() > MAX_SLIDES:
		var which: String = "el mínimo es %d" % MIN_SLIDES if list.size() < MIN_SLIDES else "el máximo es %d" % MAX_SLIDES
		data.errors.append("hay %d láminas y %s." % [list.size(), which])
	for i: int in list.size():
		var slide: Dictionary = _parse_slide(i + 1, list[i], data.errors)
		if not slide.is_empty():
			data.slides.append(slide)
	return data


func is_valid() -> bool:
	return errors.is_empty() and not slides.is_empty()


## Cuántos segundos hacen falta como mínimo para leer `text` (la regla de lectura del guion, §2).
static func reading_seconds(text: String) -> int:
	return maxi(READING_MIN_S, ceili(READING_BASE_S + text.length() / READING_CHARS_PER_S))


static func _parse_slide(number: int, raw: Variant, errors: PackedStringArray) -> Dictionary:
	var before: int = errors.size()
	if not raw is Dictionary:
		errors.append("la lámina %d tiene que ser un objeto con \"imagen\", \"texto\" y \"segundos\"." % number)
		return {}
	var slide: Dictionary = raw
	var image: String = ""
	var text: String = ""
	var seconds: int = 0
	var image_raw: Variant = slide.get("imagen")
	if not image_raw is String or not (image_raw as String).begins_with("res://"):
		errors.append("la lámina %d: \"imagen\" tiene que ser una ruta que empiece con res://." % number)
	elif not ResourceLoader.exists(image_raw):
		errors.append("la lámina %d no encuentra la imagen `%s`." % [number, image_raw])
	else:
		image = image_raw
	var text_raw: Variant = slide.get("texto")
	if not text_raw is String:
		errors.append("la lámina %d: \"texto\" tiene que ser un texto entre comillas." % number)
	else:
		text = text_raw
		_check_text(number, text, errors)
	var seconds_raw: Variant = slide.get("segundos")
	if not _is_number(seconds_raw) or float(seconds_raw) != floorf(float(seconds_raw)) \
			or int(seconds_raw) < MIN_SECONDS or int(seconds_raw) > MAX_SECONDS:
		errors.append("la lámina %d: \"segundos\" tiene que ser un entero de %d a %d." % [number, MIN_SECONDS, MAX_SECONDS])
	else:
		seconds = int(seconds_raw)
	if errors.size() > before:
		return {}
	return {"imagen": image, "texto": text, "segundos": seconds}


static func _check_text(number: int, text: String, errors: PackedStringArray) -> void:
	if text.strip_edges().is_empty():
		errors.append("la lámina %d tiene el texto vacío." % number)
		return
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if (code < 32 and code != 10) or code == 127:
			errors.append("la lámina %d: el texto tiene caracteres de control (solo se permite el salto de línea \\n)." % number)
			return
	var lines: PackedStringArray = LevelTexts.lines_of(text)
	if lines.size() > LevelTexts.WIN_MAX_LINES:
		errors.append("la lámina %d tiene %d líneas y el máximo es %d." % [number, lines.size(), LevelTexts.WIN_MAX_LINES])
	if text.length() > LevelTexts.WIN_MAX_CHARS:
		errors.append("la lámina %d tiene %d caracteres y el máximo es %d." % [number, text.length(), LevelTexts.WIN_MAX_CHARS])
	for i: int in lines.size():
		if lines[i].strip_edges().is_empty():
			errors.append("la lámina %d: la línea %d está en blanco." % [number, i + 1])
		elif lines[i].length() > LevelTexts.LINE_MAX_CHARS:
			errors.append("la lámina %d: la línea %d tiene %d caracteres y el máximo por línea es %d." % [number, i + 1, lines[i].length(), LevelTexts.LINE_MAX_CHARS])


static func _is_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT]
