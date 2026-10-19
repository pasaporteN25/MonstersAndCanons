# Los números del efecto de mejora de las torres y la tabla de estadísticas del texto (M65, RF-594, D-136).
# Lee `data/ui/mejoras.json`. Si falta, está dañado o un campo está mal, ese campo vuelve a su valor por
# omisión y el motivo queda en `errors` (en castellano) sin romper el juego. Lo revisa `tools/check_mejoras.gd`.
class_name UpgradeFxConfig
extends RefCounted

const PATH: String = "res://data/ui/mejoras.json"
const FORMATS: Array[String] = ["entero", "decimal", "porcentaje"]

## Valores por omisión (los mismos del archivo oficial).
const DEFAULT_VARIANTS: Dictionary = {
	"refuerzo": {"duracion_s": 0.5, "cuadros": 8, "escala": 1.0},
	"maestria": {"duracion_s": 0.7, "cuadros": 8, "escala": 1.5},
}
const DEFAULT_STATS: Array[Dictionary] = [
	{"campo": "damage", "etiqueta": "daño", "formato": "entero", "escala": 1.0},
	{"campo": "fire_rate", "etiqueta": "disp/s", "formato": "decimal", "escala": 1.0},
	{"campo": "chain_extra_targets", "etiqueta": "saltos", "formato": "entero", "escala": 1.0},
	{"campo": "range_tiles", "etiqueta": "alcance", "formato": "decimal", "escala": 1.0},
	{"campo": "splash_radius_tiles", "etiqueta": "área", "formato": "decimal", "escala": 1.0},
	{"campo": "burst_count", "etiqueta": "púas", "formato": "entero", "escala": 1.0},
	{"campo": "extra_targets", "etiqueta": "objetivos", "formato": "entero", "escala": 1.0},
	{"campo": "slow_amount", "etiqueta": "frenado", "formato": "porcentaje", "escala": 100.0},
	{"campo": "slow_duration", "etiqueta": "s de frenado", "formato": "decimal", "escala": 1.0},
	{"campo": "burn_damage_per_second", "etiqueta": "quemadura/s", "formato": "entero", "escala": 1.0},
	{"campo": "burn_duration", "etiqueta": "s de quemadura", "formato": "decimal", "escala": 1.0},
	{"campo": "suppress_seconds", "etiqueta": "s de pulso", "formato": "decimal", "escala": 1.0},
	{"campo": "support_rate_percent", "etiqueta": "apoyo", "formato": "porcentaje", "escala": 1.0},
	{"campo": "support_repair_per_second", "etiqueta": "reparación/s", "formato": "decimal", "escala": 1.0},
]
## Números sueltos: clave -> valor por omisión (el tipo del valor decide si se acepta un entero o un decimal).
const DEFAULT_NUMBERS: Dictionary = {
	"aclarado_blanco": 0.4,
	"fuente_base_px": 22,
	"fuente_min_px": 20,
	"fuente_max_px": 30,
	"texto_duracion_s": 1.1,
	"texto_sube_px": 24,
	"escalonado_s": 0.12,
	"max_estadisticas": 4,
	"max_por_renglon": 2,
	"tope_efectos": 8,
	"tope_textos": 4,
}

var variants: Dictionary = DEFAULT_VARIANTS.duplicate(true)
var stats: Array[Dictionary] = DEFAULT_STATS.duplicate(true)
var numbers: Dictionary = DEFAULT_NUMBERS.duplicate()
## Lo que está mal en el archivo, en castellano (vacío = todo bien).
var errors: Array[String] = []


static func load_from(path: String = PATH) -> UpgradeFxConfig:
	var config := UpgradeFxConfig.new()
	if not FileAccess.file_exists(path):
		config.errors.append("No se encontró %s; se usan los valores por omisión." % path)
		return config
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		config.errors.append("No se pudo leer %s; se usan los valores por omisión." % path)
		return config
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		config.errors.append("%s no es un JSON válido (un objeto); se usan los valores por omisión." % path)
		return config
	config._apply(parser.data)
	return config


func get_number(key: String) -> float:
	return float(numbers.get(key, DEFAULT_NUMBERS.get(key, 0.0)))


## La variante del nivel nuevo: el 2 es «refuerzo» y del 3 en adelante «maestría».
func variant_for(level_number: int) -> Dictionary:
	return variants["refuerzo" if level_number <= 2 else "maestria"]


func is_valid() -> bool:
	return errors.is_empty()


func _apply(raw: Dictionary) -> void:
	_apply_numbers(raw)
	_apply_variants(raw.get("variantes", null))
	_apply_stats(raw.get("estadisticas", null))


func _apply_numbers(raw: Dictionary) -> void:
	for key: String in DEFAULT_NUMBERS:
		if not raw.has(key):
			errors.append("Falta «%s»; se usa %s." % [key, str(DEFAULT_NUMBERS[key])])
			continue
		var value: Variant = raw[key]
		if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
			errors.append("«%s» tiene que ser un número." % key)
			continue
		var number: float = float(value)
		var minimum: float = 0.0 if key in ["aclarado_blanco", "escalonado_s"] else 1.0 if DEFAULT_NUMBERS[key] is int else 0.001
		if number < minimum or (key == "aclarado_blanco" and number > 1.0):
			errors.append("«%s» está fuera de rango (%s)." % [key, str(value)])
			continue
		numbers[key] = int(roundf(number)) if DEFAULT_NUMBERS[key] is int else number
	if int(numbers["fuente_min_px"]) > int(numbers["fuente_max_px"]):
		errors.append("«fuente_min_px» no puede ser mayor que «fuente_max_px»; se usan los de omisión.")
		numbers["fuente_min_px"] = DEFAULT_NUMBERS["fuente_min_px"]
		numbers["fuente_max_px"] = DEFAULT_NUMBERS["fuente_max_px"]


func _apply_variants(raw: Variant) -> void:
	if not raw is Dictionary:
		errors.append("Falta «variantes» (un objeto con «refuerzo» y «maestria»); se usan los valores por omisión.")
		return
	for name_: String in DEFAULT_VARIANTS:
		var entry: Variant = (raw as Dictionary).get(name_, null)
		if not entry is Dictionary:
			errors.append("Falta la variante «%s»; se usan los valores por omisión." % name_)
			continue
		var out: Dictionary = (DEFAULT_VARIANTS[name_] as Dictionary).duplicate()
		for key: String in out:
			var value: Variant = (entry as Dictionary).get(key, null)
			if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
				errors.append("En la variante «%s», «%s» tiene que ser un número." % [name_, key])
			elif float(value) <= 0.0:
				errors.append("En la variante «%s», «%s» tiene que ser mayor que 0 (es %s)." % [name_, key, str(value)])
			else:
				out[key] = int(roundf(float(value))) if key == "cuadros" else float(value)
		variants[name_] = out


func _apply_stats(raw: Variant) -> void:
	if not raw is Array:
		errors.append("Falta «estadisticas» (una lista); se usa la tabla por omisión.")
		return
	var known: Dictionary = {}
	for property: Dictionary in TowerLevelData.new().get_property_list():
		known[String(property["name"])] = true
	var table: Array[Dictionary] = []
	var seen: Dictionary = {}
	var index: int = 0
	for entry: Variant in raw:
		index += 1
		if not entry is Dictionary:
			errors.append("La estadística %d no es un objeto." % index)
			continue
		var row: Dictionary = entry
		var field: String = String(row.get("campo", ""))
		var label: String = String(row.get("etiqueta", ""))
		var format: String = String(row.get("formato", ""))
		var scale: Variant = row.get("escala", 1.0)
		var ok: bool = true
		if field.is_empty() or not known.has(field):
			errors.append("La estadística %d usa el campo «%s», que no existe en TowerLevelData." % [index, field])
			ok = false
		elif seen.has(field):
			errors.append("La estadística %d repite el campo «%s»." % [index, field])
			ok = false
		if label.is_empty():
			errors.append("La estadística %d (%s) no tiene «etiqueta»." % [index, field])
			ok = false
		if not format in FORMATS:
			errors.append("La estadística %d (%s) tiene el formato desconocido «%s» (valen: %s)." % [
				index, field, format, ", ".join(FORMATS)])
			ok = false
		if typeof(scale) != TYPE_FLOAT and typeof(scale) != TYPE_INT or float(scale) == 0.0:
			errors.append("La estadística %d (%s) tiene una «escala» que no sirve (tiene que ser un número distinto de 0)." % [index, field])
			ok = false
		if ok:
			seen[field] = true
			table.append({"campo": field, "etiqueta": label, "formato": format, "escala": float(scale)})
	if table.is_empty():
		errors.append("La tabla de estadísticas quedó vacía; se usa la de omisión.")
	else:
		stats = table
