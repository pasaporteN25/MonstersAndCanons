# Los créditos del juego (M52, RF-472): un archivo de datos, `data/creditos.json`, con `{"version": 1, "lineas": ["…"]}`.
# Es lógica pura (constitución P10): lee y valida el texto, sin abrir ninguna ventana. La pantalla es CreditsScreen.
class_name Credits
extends RefCounted

const PATH: String = "res://data/creditos.json"
## Límites de forma (de interfaz, no de balance): una línea cabe en pantalla y la lista no crece sin fin.
const MAX_LINES: int = 40
const LINE_MAX: int = 90
const KEYS: PackedStringArray = ["version", "lineas"]


## Lee los créditos de `path`. Devuelve {"lines": PackedStringArray, "errors": PackedStringArray}.
static func load_file(path: String = PATH) -> Dictionary:
	var errors: PackedStringArray = []
	if not FileAccess.file_exists(path):
		errors.append("No se encuentra el archivo de créditos (%s)." % path)
		return {"lines": PackedStringArray(), "errors": errors}
	return parse(FileAccess.get_file_as_string(path), errors)


## Valida el texto de un archivo de créditos. `errors` ya puede traer problemas de la lectura.
static func parse(text: String, errors: PackedStringArray = []) -> Dictionary:
	var lines: PackedStringArray = []
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("Los créditos no son un JSON válido (línea %d: %s)." % [json.get_error_line(), json.get_error_message()])
		return {"lines": lines, "errors": errors}
	if not json.data is Dictionary:
		errors.append("Los créditos tienen que ser un objeto con \"version\" y \"lineas\".")
		return {"lines": lines, "errors": errors}
	var data: Dictionary = json.data
	for key: Variant in data.keys():
		if not KEYS.has(str(key)):
			errors.append("clave desconocida \"%s\" (se usan: %s)." % [key, ", ".join(KEYS)])
	if not data.has("version") or not (data["version"] is float or data["version"] is int) or int(data["version"]) != 1:
		errors.append("\"version\" tiene que ser 1.")
	if not data.has("lineas") or not data["lineas"] is Array:
		errors.append("\"lineas\" tiene que ser una lista de textos.")
		return {"lines": lines, "errors": errors}
	var source: Array = data["lineas"]
	if source.is_empty():
		errors.append("\"lineas\" no puede estar vacía.")
	if source.size() > MAX_LINES:
		errors.append("\"lineas\" tiene %d líneas y el máximo es %d." % [source.size(), MAX_LINES])
	for i: int in source.size():
		if not source[i] is String:
			errors.append("la línea %d tiene que ser un texto." % (i + 1))
			continue
		var line: String = source[i]
		if line.length() > LINE_MAX:
			errors.append("la línea %d tiene %d caracteres y el máximo es %d." % [i + 1, line.length(), LINE_MAX])
		lines.append(line)
	return {"lines": lines, "errors": errors}
