# Arte de la presentación de los jefes, leído de `data/ui/boss_presentation.json` (T548, RF-666 a RF-673).
# Dice qué jefe tiene fondo propio y cómo se oscurece la franja de texto para que se lea (números fuera del código, P2).
# Todo es tolerante: si falta el dato, la ruta o el recurso, devuelve null y la presentación usa su fondo liso.
class_name BossPresentationArt
extends RefCounted

const CATALOG_PATH: String = "res://data/ui/boss_presentation.json"
const DEFAULT_SHADE_COLOR: Color = Color(0.03, 0.02, 0.04)
const DEFAULT_SHADE_HEIGHT: float = 0.55
const DEFAULT_SHADE_OPACITY: float = 0.82


## El fondo del jefe `enemy_id`, o null si no tiene (los demás jefes) o si el recurso no existe.
static func backdrop_for(enemy_id: String, catalog_path: String = CATALOG_PATH) -> Texture2D:
	var path: String = backdrop_path(read_catalog(catalog_path), enemy_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Texture2D


static func backdrop_path(catalog: Variant, enemy_id: String) -> String:
	if typeof(catalog) != TYPE_DICTIONARY:
		return ""
	var bosses: Variant = (catalog as Dictionary).get("jefes", {})
	if typeof(bosses) != TYPE_DICTIONARY:
		return ""
	var entry: Variant = (bosses as Dictionary).get(enemy_id, {})
	if typeof(entry) != TYPE_DICTIONARY:
		return ""
	var path: Variant = (entry as Dictionary).get("fondo", "")
	if typeof(path) != TYPE_STRING or not String(path).begins_with("res://"):
		return ""
	return String(path)


## Franja oscura detrás del texto: `color`, `alto` (fracción de la ventana, 0 a 1) y `opacidad` (0 a 1; 0 la apaga).
static func shade(catalog: Variant = null) -> Dictionary:
	var result: Dictionary = {"color": DEFAULT_SHADE_COLOR, "alto": DEFAULT_SHADE_HEIGHT, "opacidad": DEFAULT_SHADE_OPACITY}
	if catalog == null:
		catalog = read_catalog(CATALOG_PATH)
	if typeof(catalog) != TYPE_DICTIONARY:
		return result
	var raw: Variant = (catalog as Dictionary).get("degradado", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return result
	var data: Dictionary = raw
	var rgb: Variant = data.get("color", null)
	if typeof(rgb) == TYPE_ARRAY and (rgb as Array).size() == 3:
		result["color"] = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))
	if typeof(data.get("alto", null)) in [TYPE_FLOAT, TYPE_INT]:
		result["alto"] = clampf(float(data["alto"]), 0.0, 1.0)
	if typeof(data.get("opacidad", null)) in [TYPE_FLOAT, TYPE_INT]:
		result["opacidad"] = clampf(float(data["opacidad"]), 0.0, 1.0)
	return result


## La composición (RF-738): tamaños de letra, alto del retrato (fracción de 720), ancho de la columna de texto y
## separación, en `data/ui/boss_presentation.json` bajo «composicion» → «pc» / «celular». Lo que falte, o no sea un número
## positivo, cae al valor de siempre; en el celular la letra no baja de `LETRA_MINIMA` (16 px lógicos).
const LETRA_MINIMA: int = 16
const DEFAULT_LAYOUT: Dictionary = {
	"letra_titulo": 34, "letra_nombre": 52, "letra_texto": 22, "letra_pista": 18,
	"alto_retrato": 0.5, "ancho_texto": 900.0, "separacion": 14,
}


static func layout(mobile: bool, catalog: Variant = null) -> Dictionary:
	var result: Dictionary = DEFAULT_LAYOUT.duplicate()
	if catalog == null:
		catalog = read_catalog(CATALOG_PATH)
	if typeof(catalog) == TYPE_DICTIONARY:
		var all: Variant = (catalog as Dictionary).get("composicion", {})
		var mine: Variant = (all as Dictionary).get("celular" if mobile else "pc", {}) if typeof(all) == TYPE_DICTIONARY else {}
		if typeof(mine) == TYPE_DICTIONARY:
			for key: String in result:
				var value: Variant = (mine as Dictionary).get(key, null)
				if typeof(value) in [TYPE_FLOAT, TYPE_INT] and float(value) > 0.0:
					result[key] = float(value) if key in ["alto_retrato", "ancho_texto"] else int(value)
	if mobile:
		for key: String in ["letra_titulo", "letra_nombre", "letra_texto", "letra_pista"]:
			result[key] = maxi(int(result[key]), LETRA_MINIMA)
	return result


static func read_catalog(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return null
	return parser.data
