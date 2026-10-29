# Idioma de la interfaz y búsqueda de textos por clave (T533, RF-727, D-217).
# Lógica pura, sin escena (P10). T533 dejó la base; T534 (D-222) migró menús, opciones, pausa, salida y récords.
# El selector de Opciones sigue oculto (`SELECTOR_ENABLED`) hasta que el resto de las pantallas y el Lore estén en inglés.
class_name Localization
extends RefCounted

const DEFAULT_LANGUAGE: StringName = &"es"
const SUPPORTED: Array[StringName] = [&"es", &"en"]
## T533/T534: el inglés todavía no cubre HUD, Wiki, tutorial, editor ni el Lore (queda en español por el respaldo), así que
## el selector NO se muestra. Se pasa a `true` cuando el inglés quede coherente.
const SELECTOR_ENABLED: bool = false
## Costura para pruebas: ¿se arma el selector? Vale `SELECTOR_ENABLED`; `reset()` lo restaura.
static var selector_visible: bool = SELECTOR_ENABLED
const CATALOG_DIR: String = "res://data/i18n/"

## Idioma activo. Se fija con `set_language` (lo hace quien lee la preferencia de `SaveManager`).
static var language: StringName = DEFAULT_LANGUAGE
static var _catalogs: Dictionary = {}  # { &"es": {clave: texto}, … }
## Costura para pruebas: carpeta de catálogos.
static var catalog_dir: String = CATALOG_DIR


## Un valor desconocido, vacío o de otro tipo vale español.
static func normalize(value: Variant) -> StringName:
	if typeof(value) in [TYPE_STRING, TYPE_STRING_NAME] and SUPPORTED.has(StringName(value)):
		return StringName(value)
	return DEFAULT_LANGUAGE


static func set_language(value: Variant) -> void:
	language = normalize(value)


## Descarta los catálogos leídos (para recargarlos o para las pruebas).
static func reset() -> void:
	_catalogs.clear()
	language = DEFAULT_LANGUAGE
	selector_visible = SELECTOR_ENABLED


static func _entries(lang: StringName) -> Dictionary:
	if not _catalogs.has(lang):
		var cat: Dictionary = LocalizationCatalog.load_file("%s%s.json" % [catalog_dir, String(lang)])
		_catalogs[lang] = cat["entradas"]
	return _catalogs[lang]


## ¿Existe la clave en el idioma activo (o en español)?
static func has_key(key: StringName) -> bool:
	return _entries(language).has(String(key)) or _entries(DEFAULT_LANGUAGE).has(String(key))


## El texto de `key` en el idioma activo; si falta, el español; si tampoco está, la propia clave (se nota en pantalla
## y la prueba de cobertura lo detecta).
static func t(key: StringName) -> String:
	var k: String = String(key)
	var own: Dictionary = _entries(language)
	if own.has(k):
		return own[k]
	var base: Dictionary = _entries(DEFAULT_LANGUAGE)
	return base[k] if base.has(k) else k


## Como `t`, reemplazando `{nombre}` por los valores de `values`. Un marcador sin valor queda tal cual.
static func t_fmt(key: StringName, values: Dictionary) -> String:
	var text: String = t(key)
	for name: Variant in values:
		text = text.replace("{%s}" % str(name), str(values[name]))
	return text


## Plural: usa `<clave>.one` si `n == 1` y `<clave>.other` en cualquier otro caso; `{n}` se reemplaza solo.
static func t_plural(key: StringName, n: int, values: Dictionary = {}) -> String:
	var suffix: String = "one" if n == 1 else "other"
	var merged: Dictionary = values.duplicate()
	merged["n"] = n
	return t_fmt(StringName("%s.%s" % [String(key), suffix]), merged)


## Pone el texto de cada nodo de `mapping` ({"%NombreUnico": &"clave"}, {"Ruta/Hija": &"clave"} o {"NombreSuelto": &"clave"},
## que se busca entre los descendientes) en el idioma activo. Sirve para los textos fijos de las escenas `.tscn`; los nodos
## que no existen se ignoran.
static func apply(root: Node, mapping: Dictionary) -> void:
	for path: Variant in mapping:
		var name: String = str(path)
		var node: Node = root.get_node_or_null(NodePath(name))
		if node == null and not name.contains("/") and not name.begins_with("%"):
			node = root.find_child(name, true, false)
		if node != null and (node is Label or node is BaseButton or node is RichTextLabel):
			node.set("text", t(StringName(mapping[path])))
