# Los datos de «Novedades de esta versión» (M67, RF-605): lee y valida `data/novedades/novedades.json`. Lógica pura,
# sin escena (P10): se prueba sin abrir ventanas. Los errores van en castellano y nombran la versión y la novedad
# («la versión 1.0.0, novedad 3: el texto tiene 3 líneas y el máximo es 2»). Un archivo con errores no muestra la
# pantalla y el menú abre como siempre (RF-603): nunca bloquea jugar.
class_name NewsData
extends RefCounted

const DEFAULT_PATH: String = "res://data/novedades/novedades.json"
const SUPPORTED_VERSION: int = 1
const MAX_ITEMS: int = 8
const MAX_TITLE_CHARS: int = 40
const MAX_SUBTITLE_CHARS: int = 80
const MAX_TEXT_CHARS: int = 140
const MAX_TEXT_LINES: int = 2
const TYPE_PRESENTATION: String = "presentacion"
const TYPE_IMPROVEMENTS: String = "mejoras"
const TYPES: PackedStringArray = ["presentacion", "mejoras"]
## Los rótulos fijos de la pantalla (RF-605): todos son obligatorios en `interfaz`.
const LABEL_KEYS: PackedStringArray = ["entendido", "titulo_novedades", "titulo_mejoras", "borrador", "sin_novedades"]

## Los rótulos de `interfaz`.
var labels: Dictionary = {}
## Las versiones válidas, de la más nueva a la más vieja: [{id, tipo, borrador, titulo, subtitulo, cabecera, novedades}].
var entries: Array[Dictionary] = []
var errors: PackedStringArray = []


## Lee el archivo. Si no existe, no se puede leer o no es JSON, el resultado trae el error y ninguna versión.
static func load_file(path: String = DEFAULT_PATH) -> NewsData:
	var data := NewsData.new()
	if not FileAccess.file_exists(path):
		data.errors.append("novedades: no existe el archivo %s." % path)
		return data
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		data.errors.append("novedades: no se pudo abrir %s." % path)
		return data
	# JSON.new().parse() en vez de JSON.parse_string(): un archivo roto es un caso previsto.
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		data.errors.append("novedades: %s no es un JSON válido (línea %d: %s)." % [path, json.get_error_line(), json.get_error_message()])
		return data
	return parse(json.data)


## Valida el contenido ya leído del JSON.
static func parse(raw: Variant) -> NewsData:
	var data := NewsData.new()
	if not raw is Dictionary:
		data.errors.append("novedades: el archivo tiene que ser un objeto con \"version\", \"interfaz\" y \"versiones\".")
		return data
	var dict: Dictionary = raw
	if not _is_number(dict.get("version")) or float(dict["version"]) != float(SUPPORTED_VERSION):
		data.errors.append("novedades: \"version\" tiene que ser %d." % SUPPORTED_VERSION)
	data._parse_labels(dict.get("interfaz"))
	var raw_list: Variant = dict.get("versiones")
	if not raw_list is Array:
		data.errors.append("novedades: \"versiones\" tiene que ser una lista (puede estar vacía).")
		return data
	var seen_ids: PackedStringArray = []
	var list: Array = raw_list
	for i: int in list.size():
		var entry: Dictionary = data._parse_entry(i + 1, list[i], seen_ids)
		if not entry.is_empty():
			data.entries.append(entry)
	return data


func is_valid() -> bool:
	return errors.is_empty()


## La entrada (aprobada o no) de la versión `version`, por igualdad exacta (RF-606); `{}` si no hay.
func entry_for(version: String) -> Dictionary:
	for entry: Dictionary in entries:
		if String(entry["id"]) == version:
			return entry
	return {}


## La entrada más nueva del archivo (la primera de la lista); `{}` si no hay ninguna.
func latest() -> Dictionary:
	return entries[0] if not entries.is_empty() else {}


## RF-607: lo que abre el botón de Opciones: la entrada de la versión instalada y, si no hay, la más nueva.
func entry_for_options(version: String) -> Dictionary:
	var entry: Dictionary = entry_for(version)
	return entry if not entry.is_empty() else latest()


## Avisos que no bloquean (RF-605): la versión instalada es un número y no hay una entrada aprobada para ella.
func warnings_for(config_version: String) -> PackedStringArray:
	var warnings: PackedStringArray = []
	if GameVersion.parse(config_version).is_empty():
		return warnings  # «beta» o texto libre: no se espera una entrada
	var entry: Dictionary = entry_for(config_version)
	if entry.is_empty():
		warnings.append("la versión %s de project.godot no tiene entrada en las novedades (no se mostrará nada)." % config_version)
	elif bool(entry["borrador"]):
		warnings.append("la entrada de la versión %s sigue en borrador (no se mostrará sola hasta pasar \"borrador\" a false)." % config_version)
	return warnings


func _parse_labels(raw: Variant) -> void:
	if not raw is Dictionary:
		errors.append("novedades: \"interfaz\" tiene que ser un objeto con los rótulos fijos (%s)." % ", ".join(LABEL_KEYS))
		return
	var dict: Dictionary = raw
	for key: String in LABEL_KEYS:
		var value: Variant = dict.get(key)
		if not value is String or (value as String).strip_edges().is_empty():
			errors.append("novedades: \"interfaz\" necesita \"%s\" con un texto." % key)
		else:
			labels[key] = value


func _parse_entry(number: int, raw: Variant, seen_ids: PackedStringArray) -> Dictionary:
	var before: int = errors.size()
	if not raw is Dictionary:
		errors.append("la versión número %d de la lista tiene que ser un objeto." % number)
		return {}
	var dict: Dictionary = raw
	var id: String = ""
	var id_raw: Variant = dict.get("id")
	if not id_raw is String or (id_raw as String).strip_edges().is_empty():
		errors.append("la versión número %d de la lista no tiene \"id\" (tiene que ser la versión, por ejemplo \"1.0.0\")." % number)
		id = "número %d" % number
	else:
		id = id_raw
		if seen_ids.has(id):
			errors.append("la versión %s está repetida." % id)
		seen_ids.append(id)
	var tag: String = "la versión %s" % id
	var type: String = ""
	if not dict.get("tipo") is String or not TYPES.has(dict["tipo"]):
		errors.append("%s: \"tipo\" tiene que ser \"%s\" o \"%s\"." % [tag, TYPE_PRESENTATION, TYPE_IMPROVEMENTS])
	else:
		type = dict["tipo"]
	var draft: bool = true
	if typeof(dict.get("borrador")) != TYPE_BOOL:
		errors.append("%s: \"borrador\" tiene que ser true o false." % tag)
	else:
		draft = dict["borrador"]
	var title: String = _text_field(tag, dict, "titulo", MAX_TITLE_CHARS, true)
	var subtitle: String = _text_field(tag, dict, "subtitulo", MAX_SUBTITLE_CHARS, false)
	var header: String = _image_field(tag, dict, "cabecera")
	var items: Array[Dictionary] = []
	var raw_items: Variant = dict.get("novedades")
	if not raw_items is Array:
		errors.append("%s: \"novedades\" tiene que ser una lista de 1 a %d." % [tag, MAX_ITEMS])
	else:
		var list: Array = raw_items
		if list.is_empty() or list.size() > MAX_ITEMS:
			errors.append("%s tiene %d novedades y tiene que haber de 1 a %d." % [tag, list.size(), MAX_ITEMS])
		for i: int in list.size():
			var item: Dictionary = _parse_item(tag, i + 1, list[i])
			if not item.is_empty():
				items.append(item)
	if errors.size() > before:
		return {}
	return {"id": id, "tipo": type, "borrador": draft, "titulo": title, "subtitulo": subtitle, "cabecera": header, "novedades": items}


func _parse_item(tag: String, number: int, raw: Variant) -> Dictionary:
	var before: int = errors.size()
	if not raw is Dictionary:
		errors.append("%s, novedad %d: tiene que ser un objeto con \"titulo\" y \"texto\"." % [tag, number])
		return {}
	var dict: Dictionary = raw
	var where: String = "%s, novedad %d" % [tag, number]
	var title: String = _text_field(where, dict, "titulo", MAX_TITLE_CHARS, true)
	if title != "":
		where = "%s, novedad %d («%s»)" % [tag, number, title]
	var text: String = _body_field(where, dict)
	var icon: String = _image_field(where, dict, "icono")
	if errors.size() > before:
		return {}
	return {"titulo": title, "texto": text, "icono": icon}


func _text_field(where: String, dict: Dictionary, key: String, max_chars: int, required: bool) -> String:
	if not dict.has(key) and not required:
		return ""
	var value: Variant = dict.get(key)
	if not value is String or (required and (value as String).strip_edges().is_empty()):
		errors.append("%s: \"%s\" tiene que ser un texto entre comillas%s." % [where, key, "" if required else " (o sacá la clave)"])
		return ""
	var text: String = value
	if _has_control(text):
		errors.append("%s: \"%s\" no puede tener saltos de línea ni caracteres de control." % [where, key])
	if text.length() > max_chars:
		errors.append("%s: \"%s\" tiene %d caracteres y el máximo es %d." % [where, key, text.length(), max_chars])
	return text


func _body_field(where: String, dict: Dictionary) -> String:
	var value: Variant = dict.get("texto")
	if not value is String or (value as String).strip_edges().is_empty():
		errors.append("%s: \"texto\" tiene que ser un texto entre comillas." % where)
		return ""
	var text: String = value
	if _has_control(text, true):
		errors.append("%s: el texto tiene caracteres de control (solo se permite el salto de línea \\n)." % where)
	var lines: PackedStringArray = text.split("\n")
	if lines.size() > MAX_TEXT_LINES:
		errors.append("%s: el texto tiene %d líneas y el máximo es %d." % [where, lines.size(), MAX_TEXT_LINES])
	if text.length() > MAX_TEXT_CHARS:
		errors.append("%s: el texto tiene %d caracteres y el máximo es %d." % [where, text.length(), MAX_TEXT_CHARS])
	for line: String in lines:
		if line.strip_edges().is_empty():
			errors.append("%s: el texto tiene una línea en blanco." % where)
			break
	return text


func _image_field(where: String, dict: Dictionary, key: String) -> String:
	if not dict.has(key):
		return ""
	var value: Variant = dict[key]
	if not value is String or not (value as String).begins_with("res://"):
		errors.append("%s: \"%s\" tiene que ser una ruta que empiece con res://." % [where, key])
		return ""
	if not ResourceLoader.exists(value):
		errors.append("%s no encuentra la imagen `%s` (\"%s\")." % [where, value, key])
		return ""
	return value


static func _has_control(text: String, allow_newline: bool = false) -> bool:
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if (code < 32 and not (allow_newline and code == 10)) or code == 127:
			return true
	return false


static func _is_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT]
