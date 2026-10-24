## M75, RF-678: parámetros visuales del círculo de alcance, editables como dato de interfaz.
class_name RangeDisplayConfig
extends RefCounted

const PATH: String = "res://data/ui/alcance.json"
const DEFAULTS: Dictionary = {
	"sutil": {"opacidad_borde": 0.3, "grosor_borde_px": 1.0},
	"completo": {"opacidad_relleno": 0.08, "opacidad_borde": 0.7, "grosor_borde_px": 2.0},
	"color_completo": {"r": 1.0, "g": 1.0, "b": 1.0},
	"color_apoyo": {"r": 0.68, "g": 0.83, "b": 0.9, "opacidad_sutil": 0.22},
}
var values: Dictionary = DEFAULTS.duplicate(true)
var errors: Array[String] = []
static var _runtime_config: RangeDisplayConfig


static func load_from(path: String = PATH) -> RangeDisplayConfig:
	var config := RangeDisplayConfig.new()
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


static func runtime_config() -> RangeDisplayConfig:
	if _runtime_config == null:
		_runtime_config = load_from()
	return _runtime_config


func is_valid() -> bool:
	return errors.is_empty()


func get_value(key: String, field: String) -> float:
	return float((values.get(key, DEFAULTS[key]) as Dictionary).get(field, (DEFAULTS[key] as Dictionary)[field]))


func _apply(raw: Dictionary) -> void:
	for group: String in DEFAULTS:
		var source: Variant = raw.get(group, null)
		if not source is Dictionary:
			errors.append("Falta «%s» (un objeto); se usan sus valores por omisión." % group)
			continue
		var out: Dictionary = (DEFAULTS[group] as Dictionary).duplicate()
		for field: String in out:
			var value: Variant = source.get(field, null)
			if typeof(value) not in [TYPE_FLOAT, TYPE_INT]:
				errors.append("«%s.%s» tiene que ser un número; se usa %s." % [group, field, str(out[field])])
				continue
			var number := float(value)
			var is_opacity: bool = field.begins_with("opacidad")
			if (is_opacity and (number < 0.0 or number > 1.0)) or (field == "grosor_borde_px" and number <= 0.0) or (not is_opacity and field != "grosor_borde_px" and (number < 0.0 or number > 1.0)):
				errors.append("«%s.%s» está fuera de rango (%s)." % [group, field, str(value)])
				continue
			out[field] = number
		values[group] = out
