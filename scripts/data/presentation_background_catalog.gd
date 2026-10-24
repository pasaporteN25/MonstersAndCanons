# Catálogo validado de fondos aprobados para las franjas y márgenes del mapa (M77, RF-700/RF-701).
class_name PresentationBackgroundCatalog
extends RefCounted

const CATALOG_PATH: String = "res://data/ui/presentation_backgrounds.json"
const FALLBACK_COLOR: Color = Color(0.07, 0.08, 0.1, 1.0)


static func load_for_theme(theme: StringName) -> Texture2D:
	var catalog: Variant = _read_catalog(CATALOG_PATH)
	var path: String = path_for_theme(catalog, theme)
	return load_texture(path)


static func load_texture(path: String) -> Texture2D:
	if not path.begins_with("res://") or not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Texture2D


static func path_for_theme(catalog: Variant, theme: StringName) -> String:
	if typeof(catalog) != TYPE_DICTIONARY:
		return ""
	var themes: Variant = (catalog as Dictionary).get("temas", {})
	if typeof(themes) != TYPE_DICTIONARY:
		return ""
	var path: Variant = (themes as Dictionary).get(String(theme), "")
	if typeof(path) != TYPE_STRING:
		return ""
	var resource_path: String = String(path)
	return resource_path if resource_path.begins_with("res://") else ""


static func _read_catalog(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return parse_catalog(file.get_as_text())


static func parse_catalog(source: String) -> Variant:
	var parser: JSON = JSON.new()
	if parser.parse(source) != OK:
		return null
	return parser.data
