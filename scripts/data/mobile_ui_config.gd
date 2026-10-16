class_name MobileUiConfig
extends RefCounted

const PATH: String = "res://data/ui/mobile_ui.json"
const DEFAULTS: Dictionary = {
	"boton_alto_px": 56,
	"barra_alta_px": 64,
	"barra_baja_px": 96,
	"separacion_px": 8,
	"flotante_min_px": 82,
	"flotante_min_mm": 7.6,
	"franja_px": 56,
	"toque_max_mm": 2.0,
	"toque_max_px": 21,
	"doble_toque_s": 0.35,
	"tilde_ancho_px": 96,
	"tilde_alto_px": 88,
	"cruz_lado_px": 84,
	"gestos_separacion_px": 48,
	"pinza_gracia_ms": 150,
	"opacidad_con_fantasma": 0.45,
	"corrimiento_s": 0.2,
	"vender_rearmar_s": 3.0,
	"vender_min_s": 0.4,
	"mejorar_bloqueo_s": 0.35,
	"zoom_casilla_max_px": 96,
	"zoom_rueda_factor": 1.1,
	"fantasma_distancia_botones": 1,
	"fantasma_botones_arriba_px": 8,
	"ver_todo_x_px": 1188,
	"ver_todo_y_px": 74,
}

var values: Dictionary = DEFAULTS.duplicate(true)


static func load_from(path: String = PATH) -> MobileUiConfig:
	var config := MobileUiConfig.new()
	if not FileAccess.file_exists(path):
		push_warning("No se encontró la configuración móvil; se usan los valores por omisión.")
		return config
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("No se pudo leer la configuración móvil; se usan los valores por omisión.")
		return config
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		push_warning("La configuración móvil está dañada; se usan los valores por omisión.")
		return config
	var raw: Dictionary = parser.data
	for key: String in DEFAULTS:
		var value: Variant = raw.get(key, DEFAULTS[key])
		if typeof(value) == typeof(DEFAULTS[key]):
			config.values[key] = value
	return config


func get_value(key: String) -> Variant:
	return values.get(key, DEFAULTS.get(key))
