# Lee y valida los catálogos de idioma `data/i18n/<idioma>.json` (T533, RF-727, D-217).
# Lógica pura, sin escena (P10). Formato de cada archivo:
#   {"version": 1, "idioma": "es", "entradas": [{"clave": "options.language.label", "texto": "Idioma"}, …]}
# Es una lista (y no un diccionario) para que una clave repetida se pueda detectar.
# Los marcadores de valores son `{nombre}` (letras, números y guion bajo).
class_name LocalizationCatalog
extends RefCounted

## Forma de una clave: dominios en minúscula separados por puntos (`menu.main.play`, `common.stars.one`).
const KEY_PATTERN: String = "^[a-z][a-z0-9_]*(\\.[a-z0-9_]+)+$"
const PLACEHOLDER_PATTERN: String = "\\{([A-Za-z0-9_]+)\\}"


## Lee un catálogo. Devuelve `{"idioma": String, "entradas": Dictionary clave→texto, "duplicadas": Array[String],
## "errores": Array[String]}`. Nunca falla: un archivo ausente o roto devuelve `errores`.
static func load_file(path: String) -> Dictionary:
	var result: Dictionary = {"idioma": "", "entradas": {}, "duplicadas": [], "errores": []}
	if not FileAccess.file_exists(path):
		result["errores"].append("No existe el catálogo %s." % path)
		return result
	var text: String = FileAccess.get_file_as_string(path)
	return parse(text, path)


static func parse(text: String, source: String = "catálogo") -> Dictionary:
	var result: Dictionary = {"idioma": "", "entradas": {}, "duplicadas": [], "errores": []}
	var json := JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		result["errores"].append("%s no es un JSON válido (objeto)." % source)
		return result
	var data: Dictionary = json.data
	result["idioma"] = String(data.get("idioma", ""))
	var raw: Variant = data.get("entradas", [])
	if not raw is Array:
		result["errores"].append("%s: «entradas» debe ser una lista." % source)
		return result
	var entries: Dictionary = result["entradas"]
	var seen_dups: Array = result["duplicadas"]
	for item: Variant in raw as Array:
		if not item is Dictionary or typeof((item as Dictionary).get("clave")) != TYPE_STRING \
				or typeof((item as Dictionary).get("texto")) != TYPE_STRING:
			result["errores"].append("%s: una entrada no tiene «clave» y «texto» de tipo texto." % source)
			continue
		var key: String = (item as Dictionary)["clave"]
		if entries.has(key):
			if not seen_dups.has(key):
				seen_dups.append(key)
			continue
		entries[key] = (item as Dictionary)["texto"]
	return result


## Los marcadores `{nombre}` de un texto, sin repetir y en orden alfabético.
static func placeholders(text: String) -> Array[String]:
	var regex := RegEx.new()
	regex.compile(PLACEHOLDER_PATTERN)
	var found: Array[String] = []
	for m: RegExMatch in regex.search_all(text):
		var name: String = m.get_string(1)
		if not found.has(name):
			found.append(name)
	found.sort()
	return found


static func is_valid_key(key: String) -> bool:
	var regex := RegEx.new()
	regex.compile(KEY_PATTERN)
	return regex.search(key) != null


## Compara dos catálogos ya leídos con `load_file`/`parse` (el de base, español, y el de otro idioma) y devuelve la
## lista de problemas en texto. Vacía = coherentes. `require_complete`: ¿el otro idioma debe traer TODAS las claves
## del de base? Hoy es `false` (el inglés se completa en T534); T534 lo pone en `true`.
static func validate(base: Dictionary, other: Dictionary, require_complete: bool) -> Array[String]:
	var problems: Array[String] = []
	for cat: Dictionary in [base, other]:
		var lang: String = cat["idioma"]
		for e: String in cat["errores"]:
			problems.append(e)
		for k: String in cat["duplicadas"]:
			problems.append("[%s] clave duplicada: %s" % [lang, k])
		for k: String in cat["entradas"]:
			if not is_valid_key(k):
				problems.append("[%s] clave con formato inválido: %s" % [lang, k])
	var base_entries: Dictionary = base["entradas"]
	var other_entries: Dictionary = other["entradas"]
	for k: String in other_entries:
		if not base_entries.has(k):
			problems.append("[%s] clave que no existe en el catálogo base: %s" % [other["idioma"], k])
	for k: String in base_entries:
		if not other_entries.has(k):
			if require_complete:
				problems.append("[%s] clave sin traducción: %s" % [other["idioma"], k])
			continue
		if placeholders(base_entries[k]) != placeholders(other_entries[k]):
			problems.append("[%s] placeholders distintos en %s: %s contra %s" % [other["idioma"], k,
					placeholders(base_entries[k]), placeholders(other_entries[k])])
		if String(other_entries[k]).strip_edges().is_empty():
			problems.append("[%s] traducción vacía: %s" % [other["idioma"], k])
	return problems
