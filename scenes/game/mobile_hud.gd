class_name MobileHud
extends CanvasLayer

signal confirm_placement_pressed
signal cancel_placement_pressed
signal view_all_pressed

var _config: MobileUiConfig
var _confirm_button: Button
var _cancel_button: Button
var _view_all_button: Button
var _ghost_visible: bool = false
var _world_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_config = MobileUiConfig.load_from()
	layer = 3
	_confirm_button = Button.new()
	_confirm_button.name = "ConfirmPlacement"
	_confirm_button.text = "✓"
	_confirm_button.add_theme_font_size_override("font_size", 32)
	_confirm_button.custom_minimum_size = Vector2(
		float(_config.get_value("tilde_ancho_px")), float(_config.get_value("tilde_alto_px")))
	_confirm_button.pressed.connect(confirm_placement_pressed.emit)
	add_child(_confirm_button)
	_cancel_button = Button.new()
	_cancel_button.name = "CancelPlacement"
	_cancel_button.text = "×"
	_cancel_button.add_theme_font_size_override("font_size", 32)
	var cancel_size: float = float(_config.get_value("cruz_lado_px"))
	_cancel_button.custom_minimum_size = Vector2(cancel_size, cancel_size)
	_cancel_button.pressed.connect(cancel_placement_pressed.emit)
	add_child(_cancel_button)
	_view_all_button = Button.new()
	_view_all_button.name = "ViewAll"
	_view_all_button.text = "Ver todo"
	var floating_size: float = float(_config.get_value("flotante_min_px"))
	_view_all_button.custom_minimum_size = Vector2(floating_size, floating_size)
	_view_all_button.position = Vector2(
		float(_config.get_value("ver_todo_x_px")), float(_config.get_value("ver_todo_y_px")))
	_view_all_button.visible = false
	_view_all_button.pressed.connect(view_all_pressed.emit)
	add_child(_view_all_button)
	set_placement_visible(false)


func show_placement(world_position: Vector2, cost_text: String, valid: bool, reason: String) -> void:
	_world_position = world_position
	_ghost_visible = true
	_confirm_button.text = "✓\n%s" % cost_text if valid else "✕\n%s" % reason
	_confirm_button.disabled = not valid
	_confirm_button.tooltip_text = "Confirmar construcción" if valid else reason
	_cancel_button.tooltip_text = "Cancelar construcción"
	set_placement_visible(true)
	_update_placement_position()


func set_placement_visible(enabled: bool) -> void:
	_ghost_visible = enabled
	if _confirm_button != null:
		_confirm_button.visible = enabled
	if _cancel_button != null:
		_cancel_button.visible = enabled


func show_view_all(enabled: bool) -> void:
	if _view_all_button != null:
		_view_all_button.visible = enabled


func is_interactive_at(screen_pos: Vector2) -> bool:
	for button: Button in [_confirm_button, _cancel_button, _view_all_button]:
		if button != null and button.visible and button.get_global_rect().has_point(screen_pos):
			return true
	return false


func _process(_delta: float) -> void:
	if _ghost_visible:
		_update_placement_position()


func _update_placement_position() -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _world_position
	var separation: float = float(_config.get_value("gestos_separacion_px"))
	var confirm_size: Vector2 = _confirm_button.size
	var cancel_size: Vector2 = _cancel_button.size
	var above: float = float(_config.get_value("fantasma_botones_arriba_px"))
	_confirm_button.position = screen_pos + Vector2(-separation / 2.0 - confirm_size.x, -confirm_size.y - above)
	_cancel_button.position = screen_pos + Vector2(separation / 2.0, -cancel_size.y - above)
