class_name SideRails
extends Control

signal button_pressed(button: Control)
## T570: el riel cambió de medidas (tamaño de la superficie, área segura o escala del marco). Quien lo usa vuelve a
## preguntar `has_room()` y `button_size()`.
signal layout_changed

## T570: un control con este metadato es un separador flexible (no se toca, no mide nada, ocupa el espacio que sobra).
## Sirve para dejar un botón (por ejemplo «Vender») abajo de todo del riel.
const SPACER_META: StringName = &"rail_spacer"
## T570: un control con este metadato mide `button_size() * factor` de alto (por ejemplo, «Vender» con dos renglones).
const HEIGHT_FACTOR_META: StringName = &"rail_height_factor"

var _left_column: VBoxContainer
var _right_column: VBoxContainer
var _buttons_left: Array[Control] = []
var _buttons_right: Array[Control] = []
var _safe_area_provider: Callable
var _frame_scale: float = 1.0
var _modal_visible: bool = true
var _ignore_emulated_mouse: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_column = _make_column()
	_right_column = _make_column()
	add_child(_left_column)
	add_child(_right_column)
	_rebuild_columns()
	_update_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_layout()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_ignore_emulated_mouse = _button_at_position((event as InputEventScreenTouch).position)
	elif event is InputEventMouseButton and event.device == InputEvent.DEVICE_ID_EMULATION and _ignore_emulated_mouse:
		get_viewport().set_input_as_handled()
		if not (event as InputEventMouseButton).pressed:
			_ignore_emulated_mouse = false


func _button_at_position(position: Vector2) -> bool:
	for control: Control in _buttons_left + _buttons_right:
		if control != null and control.visible and control.get_global_rect().has_point(position):
			return true
	return false


func set_safe_area_provider(provider: Callable) -> void:
	_safe_area_provider = provider
	_update_layout()


func set_buttons(left: Array[Control], right: Array[Control]) -> void:
	_buttons_left = left.duplicate()
	_buttons_right = right.duplicate()
	_rebuild_columns()
	_update_layout()


func set_visible_for_modal(visible_for_modal: bool) -> void:
	_modal_visible = visible_for_modal
	visible = _modal_visible and not _rails_rects().is_empty()


## T570: ¿alcanza el ancho de las franjas para dibujar los rieles (RF-733)? Sin ancho, los controles quedan en el marco.
func has_room() -> bool:
	return not _rails_rects().is_empty()


## T570: el lado (en píxeles de la superficie) del botón mínimo del riel: 6 mm en un teléfono, `flotante_min_px` escalado
## por el marco en la PC.
func button_size() -> float:
	return _minimum_button_physical_px()


func frame_scale() -> float:
	return _frame_scale


func set_frame_scale(value: float) -> void:
	_frame_scale = maxf(value, 0.0)
	_update_layout()


func _make_column() -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = "LeftColumn" if _left_column == null else "RightColumn"
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_theme_constant_override("separation", 8)
	return column


func _rebuild_columns() -> void:
	if _left_column == null or _right_column == null:
		return
	for column: VBoxContainer in [_left_column, _right_column]:
		for child: Node in column.get_children():
			column.remove_child(child)
			child.queue_free()
	_add_buttons(_left_column, _buttons_left)
	_add_buttons(_right_column, _buttons_right)


func _add_buttons(column: VBoxContainer, buttons: Array[Control]) -> void:
	for control: Control in buttons:
		if control == null:
			continue
		_apply_control_size(control)
		if control.has_meta(SPACER_META):
			column.add_child(control)
			continue
		control.mouse_filter = Control.MOUSE_FILTER_STOP
		if control is BaseButton:
			var button: BaseButton = control as BaseButton
			button.pressed.connect(_on_button_pressed.bind(control))
		column.add_child(control)


func _apply_control_size(control: Control) -> void:
	if control.has_meta(SPACER_META):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		control.custom_minimum_size = Vector2.ZERO
		return
	var side: float = _minimum_button_physical_px()
	# Los botones con alto propio (como «Vender») llenan el ancho del riel; el resto queda cuadrado y centrado.
	control.size_flags_horizontal = Control.SIZE_FILL if control.has_meta(HEIGHT_FACTOR_META) else Control.SIZE_SHRINK_CENTER
	control.custom_minimum_size = Vector2(side, side * float(control.get_meta(HEIGHT_FACTOR_META, 1.0)))


func _on_button_pressed(button: Control) -> void:
	if GameFlow.is_changing() or not visible or not button.visible:
		return
	button_pressed.emit(button)


func _rails_rects() -> Array[Rect2]:
	var surface: Vector2 = get_viewport_rect().size
	var safe: Rect2 = _safe_area_provider.call() if _safe_area_provider.is_valid() else _get_display_safe_area(surface)
	var config: MobileUiConfig = MobileUiConfig.load_from()
	return PresentationGeometry.side_rail_rects(surface, safe, float(config.get_value("riel_min_px")))


func _get_display_safe_area(surface: Vector2) -> Rect2:
	if OS.get_name() != "Android":
		return Rect2(Vector2.ZERO, surface)
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	if safe.size == Vector2i.ZERO:
		return Rect2(Vector2.ZERO, surface)
	# Godot devuelve coordenadas de pantalla; el host ocupa la ventana principal.
	var window_position: Vector2i = DisplayServer.window_get_position()
	return Rect2(Vector2(safe.position - window_position), Vector2(safe.size))


func _update_layout() -> void:
	if _left_column == null:
		return
	var rects: Array[Rect2] = _rails_rects()
	visible = _modal_visible and not rects.is_empty()
	if rects.is_empty():
		layout_changed.emit()
		return
	_left_column.position = rects[0].position
	_left_column.size = rects[0].size
	_right_column.position = rects[1].position
	_right_column.size = rects[1].size
	for control: Control in _buttons_left + _buttons_right:
		if control != null and is_instance_valid(control):
			_apply_control_size(control)
	layout_changed.emit()


func _minimum_button_physical_px() -> float:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	var fallback: float = float(config.get_value("flotante_min_px")) * _frame_scale
	if not OS.has_feature("mobile"):
		return fallback
	var dpi: float = float(DisplayServer.screen_get_dpi())
	var canvas_scale: float = get_viewport().get_stretch_transform().x.length() * get_viewport().get_window().content_scale_factor
	return FloatButtonLayout.minimum_button_size(dpi, canvas_scale,
		float(config.get_value("flotante_min_mm")), fallback)
