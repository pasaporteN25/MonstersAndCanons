class_name UiPrefs
extends RefCounted

var cart_side: String = ""
var cart_y: float = 0.0
var exit_side: String = ""
var exit_y: float = 0.0
var demolish_side: String = ""
var demolish_y: float = 0.0


func _init() -> void:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	cart_side = str(config.get_value("carrito_lado_default"))
	cart_y = float(config.get_value("carrito_y_default"))
	exit_side = str(config.get_value("salida_lado_default"))
	exit_y = float(config.get_value("salida_y_default"))
	demolish_side = str(config.get_value("demoler_lado_default"))
	demolish_y = float(config.get_value("demoler_y_default"))


static func read(raw: Variant) -> UiPrefs:
	var prefs := UiPrefs.new()
	if not raw is Dictionary:
		if raw != null:
			push_warning("Las preferencias de interfaz tienen un formato inválido; se usan los valores por omisión.")
		return prefs
	var values: Dictionary = raw
	if values.get("cart_side") is String and values["cart_side"] in ["left", "right"]:
		prefs.cart_side = values["cart_side"]
	else:
		push_warning("Lado del carrito inválido; se usa el valor por omisión.")
	if typeof(values.get("cart_y")) in [TYPE_INT, TYPE_FLOAT] and float(values["cart_y"]) >= 0.0 and float(values["cart_y"]) <= 1.0:
		prefs.cart_y = float(values["cart_y"])
	else:
		push_warning("Altura del carrito inválida; se usa el valor por omisión.")
	if values.get("exit_side") is String and values["exit_side"] in ["left", "right"]:
		prefs.exit_side = values["exit_side"]
	else:
		push_warning("Lado de salida inválido; se usa el valor por omisión.")
	if typeof(values.get("exit_y")) in [TYPE_INT, TYPE_FLOAT] and float(values["exit_y"]) >= 0.0 and float(values["exit_y"]) <= 1.0:
		prefs.exit_y = float(values["exit_y"])
	else:
		push_warning("Altura de salida inválida; se usa el valor por omisión.")
	# RF-542: el botón de demolición. Un guardado de antes de M60 no lo trae: vale su valor por omisión, sin aviso.
	if values.has("demolish_side"):
		if values["demolish_side"] is String and values["demolish_side"] in ["left", "right"]:
			prefs.demolish_side = values["demolish_side"]
		else:
			push_warning("Lado del botón de demolición inválido; se usa el valor por omisión.")
	if values.has("demolish_y"):
		if typeof(values["demolish_y"]) in [TYPE_INT, TYPE_FLOAT] and float(values["demolish_y"]) >= 0.0 and float(values["demolish_y"]) <= 1.0:
			prefs.demolish_y = float(values["demolish_y"])
		else:
			push_warning("Altura del botón de demolición inválida; se usa el valor por omisión.")
	return prefs


func to_dict() -> Dictionary:
	return {"cart_side": cart_side, "cart_y": cart_y, "exit_side": exit_side, "exit_y": exit_y,
		"demolish_side": demolish_side, "demolish_y": demolish_y}
