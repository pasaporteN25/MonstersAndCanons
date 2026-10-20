class_name MobileUiConfig
extends RefCounted

const PATH: String = "res://data/ui/mobile_ui.json"
const DEFAULTS: Dictionary = {
	"boton_alto_px": 56,
	"icono_radio_px": 32,
	"icono_padding_px": 6,
	"barra_alta_px": 64,
	"barra_baja_px": 96,
	"separacion_px": 8,
	"flotante_min_px": 64,
	"flotante_min_mm": 6,
	"franja_px": 56,
	"toque_max_mm": 2.0,
	"toque_max_px": 21,
	"doble_toque_s": 0.35,
	"tilde_ancho_px": 64,
	"tilde_alto_px": 64,
	"cruz_lado_px": 64,
	"gestos_separacion_px": 12,
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
	"carrito_lado_default": "right",
	"carrito_y_default": 0.45,
	"salida_lado_default": "left",
	"salida_y_default": 0.1,
	"demoler_lado_default": "right",
	"demoler_y_default": 0.8,
	"catalogo_ancho_px": 800,
	"catalogo_alto_px": 480,
	"catalogo_tarjeta_ancho_mm": 18.0,
	"catalogo_tarjeta_alto_mm": 10.0,
	"catalogo_columnas": 3,
	"catalogo_separacion_px": 8,
	"catalogo_titulo_fuente_px": 24,
	"catalogo_tarjeta_fuente_px": 15,
	"catalogo_icono_ancho_px": 68,
	"barra_fuente_px": 16,
	"accion_fuente_px": 17,
	"apuntar_ancho_px": 172,
	"apuntar_alto_px": 88,
	"mejorar_ancho_px": 196,
	"mejorar_alto_px": 84,
	"vender_ancho_px": 150,
	"vender_alto_px": 82,
	"barra_margen_x_px": 8,
	"barra_margen_y_px": 2,
	"vender_borde_px": 3,
	"vender_radio_px": 8,
	"vender_padding_x_px": 8,
	"vender_padding_y_px": 4,
	"vender_separacion_mm": 35.0,
	"barra_texto_min_ancho_px": 200,
	"puntero_duplicado_ms": 500,
	"puntero_duplicado_px": 32,
	"scroll_umbral_px": 12,
	"scroll_friccion": 4.0,
	"scroll_velocidad_min_px": 30,
	"scroll_barra_px": 22,
	"menu_deslizador_alto_px": 44,
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
		var default_value: Variant = DEFAULTS[key]
		if typeof(value) == typeof(default_value):
			config.values[key] = value
		elif _is_number(value) and _is_number(default_value):
			# JSON entrega los enteros como float: se acepta y se pasa al tipo del valor por omisión (T292, H-13).
			config.values[key] = roundi(float(value)) if typeof(default_value) == TYPE_INT else float(value)
	return config


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func get_value(key: String) -> Variant:
	return values.get(key, DEFAULTS.get(key))
