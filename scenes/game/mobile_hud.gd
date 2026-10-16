class_name MobileHud
extends CanvasLayer

signal confirm_placement_pressed
signal cancel_placement_pressed
signal view_all_pressed
signal exit_pressed
signal catalog_opened(open: bool)
signal tower_chosen(index: int, use_alt_payment: bool)
signal infrastructure_tool_chosen(tool: StringName, class_id: StringName)

var _config: MobileUiConfig
var _prefs: UiPrefs
var _confirm_button: Button
var _cancel_button: Button
var _view_all_button: Button
var _cart_button: Button
var _exit_button: Button
var _catalog_panel: PanelContainer
var _catalog_dim: ColorRect
var _catalog_tabs: TabContainer
var _tower_grid: GridContainer
var _infrastructure_grid: GridContainer
var _catalog_towers: Array[TowerData] = []
var _available_towers: Array[TowerData] = []
var _infrastructure_options: Array[Dictionary] = []
var _catalog_gold: int = 0
var _catalog_resources: int = 0
var _catalog_uses_resources: bool = false
var _catalog_open: bool = false
var _game_over: bool = false
var _modal_open: bool = false
var _ghost_visible: bool = false
var _world_position: Vector2 = Vector2.ZERO
var _ghost_size: Vector2 = Vector2.ONE * Rules.TILE_SIZE
var _float_button_size: Vector2
var _base_cart_position: Vector2
var _base_exit_position: Vector2
var _drag_button: Button
var _drag_index: int = -1
var _drag_start: Vector2 = Vector2.ZERO
var _drag_start_position: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _layout_tween: Tween
var _target_cart_position: Vector2 = Vector2(-1000.0, -1000.0)
var _target_exit_position: Vector2 = Vector2(-1000.0, -1000.0)


func _ready() -> void:
	_config = MobileUiConfig.load_from()
	_prefs = SaveManager.get_ui_prefs()
	layer = 3
	_build_placement_buttons()
	_build_view_all_button()
	_build_floating_buttons()
	_build_empty_catalog()
	set_placement_visible(false)
	_apply_saved_positions()


func _build_placement_buttons() -> void:
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


func _build_view_all_button() -> void:
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


func _build_floating_buttons() -> void:
	var minimum_size: float = _minimum_touch_size()
	_float_button_size = Vector2.ONE * minimum_size
	_cart_button = _floating_button("CartButton", "🛒")
	_exit_button = _floating_button("ExitButton", "×")
	_cart_button.pressed.connect(_on_cart_pressed)
	_exit_button.pressed.connect(exit_pressed.emit)
	if _confirm_button != null:
		_confirm_button.custom_minimum_size.x = maxf(_confirm_button.custom_minimum_size.x, minimum_size)
		_confirm_button.custom_minimum_size.y = maxf(_confirm_button.custom_minimum_size.y, minimum_size)
		_cancel_button.custom_minimum_size = Vector2.ONE * maxf(_cancel_button.custom_minimum_size.x, minimum_size)
		_confirm_button.size = _confirm_button.custom_minimum_size
		_cancel_button.size = _cancel_button.custom_minimum_size


func _minimum_touch_size() -> float:
	var fallback: float = float(_config.get_value("flotante_min_px"))
	if not OS.has_feature("mobile"):
		return fallback
	var dpi: float = float(DisplayServer.screen_get_dpi())
	var stretch: Transform2D = get_viewport().get_stretch_transform()
	var canvas_scale: float = stretch.x.length() * get_viewport().get_window().content_scale_factor
	return FloatButtonLayout.minimum_button_size(dpi, canvas_scale,
		float(_config.get_value("flotante_min_mm")), fallback)


func _floating_button(button_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = _float_button_size
	button.add_theme_font_size_override("font_size", 32)
	add_child(button)
	return button


func _build_empty_catalog() -> void:
	_catalog_dim = ColorRect.new()
	_catalog_dim.name = "CatalogDim"
	_catalog_dim.color = Color(0.0, 0.0, 0.0, 0.55)
	_catalog_dim.size = Rules.SCREEN_SIZE
	_catalog_dim.visible = false
	_catalog_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_catalog_dim)
	var width: float = float(_config.get_value("catalogo_ancho_px"))
	var height: float = float(_config.get_value("catalogo_alto_px"))
	_catalog_panel = PanelContainer.new()
	_catalog_panel.name = "CatalogPanel"
	_catalog_panel.position = (Rules.SCREEN_SIZE - Vector2(width, height)) / 2.0
	_catalog_panel.custom_minimum_size = Vector2(width, height)
	_catalog_panel.visible = false
	_catalog_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_catalog_panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", int(_config.get_value("catalogo_separacion_px")))
	_catalog_panel.add_child(rows)
	var heading := HBoxContainer.new()
	rows.add_child(heading)
	var title := Label.new()
	title.text = "Elegí una opción"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", int(_config.get_value("catalogo_titulo_fuente_px")))
	heading.add_child(title)
	var close_button := Button.new()
	close_button.name = "CloseCatalog"
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2.ONE * _minimum_touch_size()
	close_button.pressed.connect(close_catalog)
	heading.add_child(close_button)
	_catalog_tabs = TabContainer.new()
	_catalog_tabs.name = "CatalogTabs"
	_catalog_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(_catalog_tabs)
	var tower_scroll := ScrollContainer.new()
	tower_scroll.name = "Torres"
	tower_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_tabs.add_child(tower_scroll)
	_tower_grid = GridContainer.new()
	_tower_grid.name = "TowerCards"
	_tower_grid.columns = int(_config.get_value("catalogo_columnas"))
	tower_scroll.add_child(_tower_grid)
	var infrastructure_scroll := ScrollContainer.new()
	infrastructure_scroll.name = "Infraestructura"
	infrastructure_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	infrastructure_scroll.visible = false
	_catalog_tabs.add_child(infrastructure_scroll)
	_infrastructure_grid = GridContainer.new()
	_infrastructure_grid.name = "InfrastructureCards"
	_infrastructure_grid.columns = int(_config.get_value("catalogo_columnas"))
	infrastructure_scroll.add_child(_infrastructure_grid)
	_refresh_catalog()


func set_catalog_data(towers: Array[TowerData], available: Array[TowerData], gold: int,
		resources: int, uses_resources: bool, infrastructure_options: Array[Dictionary]) -> void:
	_catalog_towers = towers.duplicate()
	_available_towers = available.duplicate()
	_catalog_gold = gold
	_catalog_resources = resources
	_catalog_uses_resources = uses_resources
	_infrastructure_options = infrastructure_options.duplicate(true)
	_refresh_catalog()


func _refresh_catalog() -> void:
	if _tower_grid == null:
		return
	var card_width: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_ancho_mm")))
	var separation: float = float(_config.get_value("catalogo_separacion_px"))
	var content_width: float = float(_config.get_value("catalogo_ancho_px")) - separation * 2.0
	var fit_columns: int = maxi(1, floori((content_width + separation) / (card_width + separation)))
	var columns: int = mini(int(_config.get_value("catalogo_columnas")), fit_columns)
	_tower_grid.columns = columns
	_infrastructure_grid.columns = columns
	_clear_children(_tower_grid)
	_clear_children(_infrastructure_grid)
	for tower: TowerData in _catalog_towers:
		var available_index: int = -1
		for i: int in _available_towers.size():
			if _available_towers[i].id == tower.id:
				available_index = i
				break
		var primary_reason: String = TowerText.missing_text(tower, false,
			_catalog_gold, _catalog_resources, _catalog_uses_resources)
		var use_alt: bool = false
		var reason: String = ""
		if available_index < 0:
			reason = "No disponible en este nivel"
			if tower.required_collection != &"" and not SaveManager.collection_complete(tower.required_collection):
				reason = "Falta completar la colección"
		elif primary_reason != "":
			var alternate_reason: String = TowerText.missing_text(tower, true,
				_catalog_gold, _catalog_resources, _catalog_uses_resources)
			if tower.has_alt_payment() and alternate_reason == "":
				use_alt = true
			else:
				reason = primary_reason
				if tower.has_alt_payment() and alternate_reason != "":
					reason = alternate_reason if alternate_reason.length() < primary_reason.length() else primary_reason
		var cost_text: String = TowerText.cost_text(tower, use_alt)
		if tower.has_alt_payment():
			cost_text = "%s / %s" % [TowerText.cost_text(tower), TowerText.cost_text(tower, true)]
		_add_catalog_card(_tower_grid, tower.display_name, cost_text, reason,
			Tower.make_icon(tower), available_index, use_alt)
	for option: Dictionary in _infrastructure_options:
		_add_catalog_card(_infrastructure_grid, String(option.get("name", "Infraestructura")),
			String(option.get("cost_text", "")), String(option.get("disabled_reason", "")),
			option.get("icon"), -1, false, StringName(option.get("tool", "")),
			StringName(option.get("class_id", "")))
	var infrastructure_tab: Control = _catalog_tabs.get_child(1)
	infrastructure_tab.visible = not _infrastructure_options.is_empty()
	if not infrastructure_tab.visible and _catalog_tabs.current_tab == 1:
		_catalog_tabs.current_tab = 0


func _add_catalog_card(parent: GridContainer, title: String, cost: String, reason: String,
		icon: Variant, tower_index: int, use_alt: bool, tool: StringName = &"",
		class_id: StringName = &"") -> void:
	var minimum_width: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_ancho_mm")))
	var minimum_height: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_alto_mm")))
	var card := Button.new()
	var safe_title: String = title.to_snake_case().replace("·", "").replace("__", "_").trim_prefix("_").trim_suffix("_")
	card.name = "CatalogCard_%s" % safe_title
	card.custom_minimum_size = Vector2(minimum_width, minimum_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_NONE
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	card.expand_icon = true
	card.add_theme_constant_override("icon_max_width", int(_config.get_value("catalogo_icono_ancho_px")))
	card.add_theme_font_size_override("font_size", int(_config.get_value("catalogo_tarjeta_fuente_px")))
	var text: String = "%s\n%s" % [title, cost]
	if reason != "":
		text += "\n%s" % reason
	card.text = text
	card.tooltip_text = reason if reason != "" else "%s · %s" % [title, cost]
	if icon is Texture2D:
		card.icon = icon
	card.disabled = reason != ""
	if tower_index >= 0:
		card.pressed.connect(_on_tower_card_pressed.bind(tower_index, use_alt))
	else:
		card.pressed.connect(_on_infrastructure_card_pressed.bind(tool, class_id))
	parent.add_child(card)


func _on_tower_card_pressed(index: int, use_alt_payment: bool) -> void:
	tower_chosen.emit(index, use_alt_payment)
	close_catalog()


func _on_infrastructure_card_pressed(tool: StringName, class_id: StringName) -> void:
	infrastructure_tool_chosen.emit(tool, class_id)
	close_catalog()


func _catalog_virtual_mm(millimeters: float) -> float:
	var minimum_mm: float = float(_config.get_value("flotante_min_mm"))
	var fallback: float = float(_config.get_value("flotante_min_px")) * millimeters / minimum_mm
	if not OS.has_feature("mobile"):
		return fallback
	var dpi: float = float(DisplayServer.screen_get_dpi())
	var canvas_scale: float = get_viewport().get_stretch_transform().x.length() * get_viewport().get_window().content_scale_factor
	return millimeters * dpi / 25.4 / canvas_scale if dpi > 0.0 and canvas_scale > 0.0 else fallback


func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.queue_free()


func show_placement(world_position: Vector2, cost_text: String, valid: bool, reason: String,
		ghost_size: Vector2 = Vector2.ONE * Rules.TILE_SIZE) -> void:
	_world_position = world_position
	_ghost_size = ghost_size
	_ghost_visible = true
	_confirm_button.text = "✓\n%s" % cost_text if valid else "✕\n%s" % reason
	_confirm_button.disabled = not valid
	_confirm_button.tooltip_text = "Confirmar construcción" if valid else reason
	_cancel_button.tooltip_text = "Cancelar construcción"
	set_placement_visible(true)
	_update_placement_position()
	_update_floating_layout()


func set_placement_visible(enabled: bool) -> void:
	_ghost_visible = enabled
	if _confirm_button != null:
		_confirm_button.visible = enabled
	if _cancel_button != null:
		_cancel_button.visible = enabled
	if _cart_button != null:
		_cart_button.modulate.a = float(_config.get_value("opacidad_con_fantasma")) if enabled else 1.0
		_exit_button.modulate.a = float(_config.get_value("opacidad_con_fantasma")) if enabled else 1.0
	if not enabled:
		_update_floating_layout()


func show_view_all(enabled: bool) -> void:
	if _view_all_button != null:
		_view_all_button.visible = enabled


func set_cart_active(active: bool) -> void:
	if _cart_button != null:
		_cart_button.text = "🛒 •" if active else "🛒"


func set_game_over(over: bool) -> void:
	_game_over = over
	if over:
		close_catalog()
	_update_floating_visibility()


func set_modal_open(open: bool) -> void:
	_modal_open = open
	_update_floating_visibility()


func _update_floating_visibility() -> void:
	_cart_button.visible = not _game_over and not _modal_open
	_exit_button.visible = not _game_over and not _modal_open


func is_catalog_open() -> bool:
	return _catalog_open


func open_catalog() -> void:
	_catalog_open = true
	_catalog_dim.show()
	_catalog_panel.show()
	catalog_opened.emit(true)


func close_catalog() -> void:
	if not _catalog_open:
		return
	_catalog_open = false
	_catalog_dim.hide()
	_catalog_panel.hide()
	catalog_opened.emit(false)


func is_interactive_at(screen_pos: Vector2) -> bool:
	if _catalog_open and (_catalog_panel.get_global_rect().has_point(screen_pos) or _catalog_dim.get_global_rect().has_point(screen_pos)):
		return true
	for button: Button in [_confirm_button, _cancel_button, _view_all_button, _cart_button, _exit_button]:
		if button != null and button.visible and button.get_global_rect().has_point(screen_pos):
			return true
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and _catalog_open:
		close_catalog()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		_handle_drag_touch(touch.index, touch.position, touch.pressed)
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if _drag_button != null and drag.index == _drag_index:
			_update_drag(drag.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not OS.has_feature("mobile"):
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			_handle_drag_touch(-1, mouse.position, mouse.pressed)
	elif event is InputEventMouseMotion and not OS.has_feature("mobile") and _drag_button != null:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_update_drag(motion.position)
		get_viewport().set_input_as_handled()


func _handle_drag_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		if _catalog_open and not _catalog_panel.get_global_rect().has_point(pos):
			close_catalog()
			get_viewport().set_input_as_handled()
			return
		var button: Button = _float_button_at(pos)
		if button == null:
			return
		_drag_button = button
		_drag_index = index
		_drag_start = pos
		_drag_start_position = button.position
		_dragging = false
		get_viewport().set_input_as_handled()
		return
	if _drag_button == null or _drag_index != index:
		return
	if _dragging:
		_finish_drag(pos)
	else:
		if _drag_button == _cart_button:
			_on_cart_pressed()
		else:
			exit_pressed.emit()
	_drag_button = null
	_drag_index = -1
	_dragging = false
	get_viewport().set_input_as_handled()


func _float_button_at(pos: Vector2) -> Button:
	if _cart_button.visible and _cart_button.get_global_rect().has_point(pos):
		return _cart_button
	if _exit_button.visible and _exit_button.get_global_rect().has_point(pos):
		return _exit_button
	return null


func _update_drag(pos: Vector2) -> void:
	var threshold: float = float(_config.get_value("toque_max_px"))
	if not _dragging and pos.distance_to(_drag_start) <= threshold:
		return
	_dragging = true
	var bounds := Rect2(0.0, float(_config.get_value("barra_alta_px")), Rules.SCREEN_SIZE.x,
		Rules.SCREEN_SIZE.y - float(_config.get_value("barra_alta_px")) - float(_config.get_value("barra_baja_px")))
	var next: Vector2 = pos - _float_button_size / 2.0
	_drag_button.position = Vector2(clampf(next.x, bounds.position.x, bounds.end.x - _float_button_size.x),
		clampf(next.y, bounds.position.y, bounds.end.y - _float_button_size.y))
	get_viewport().set_input_as_handled()


func _finish_drag(pos: Vector2) -> void:
	var snap: Dictionary = FloatButtonLayout.snap(pos, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")), _float_button_size)
	var side: String = String(snap["side"])
	var y: float = float(snap["y"])
	var snapped_position: Vector2 = FloatButtonLayout.position_for(side, y, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")), _float_button_size)
	if _drag_button == _cart_button:
		_prefs.cart_side = side
		_prefs.cart_y = y
		_base_cart_position = snapped_position
	else:
		_prefs.exit_side = side
		_prefs.exit_y = y
		_base_exit_position = snapped_position
	SaveManager.set_ui_prefs(_prefs)
	_resolve_button_collision()
	_apply_float_positions([_base_cart_position, _base_exit_position], false)


func _resolve_button_collision() -> void:
	var rects: Array[Rect2] = [Rect2(_base_cart_position, _float_button_size), Rect2(_base_exit_position, _float_button_size)]
	var sides: Array[String] = [_prefs.cart_side, _prefs.exit_side]
	var results: Array[Vector2] = FloatButtonLayout.avoid(Rect2(Vector2(-1000.0, -1000.0), Vector2.ZERO),
		rects, sides, Rules.SCREEN_SIZE, float(_config.get_value("barra_alta_px")),
		float(_config.get_value("barra_baja_px")), _float_button_size, 0.0)
	_base_cart_position = results[0]
	_base_exit_position = results[1]


func _apply_saved_positions() -> void:
	var top: float = float(_config.get_value("barra_alta_px"))
	var bottom: float = float(_config.get_value("barra_baja_px"))
	_base_cart_position = FloatButtonLayout.position_for(_prefs.cart_side, _prefs.cart_y,
		Rules.SCREEN_SIZE, top, bottom, _float_button_size)
	_base_exit_position = FloatButtonLayout.position_for(_prefs.exit_side, _prefs.exit_y,
		Rules.SCREEN_SIZE, top, bottom, _float_button_size)
	_resolve_button_collision()
	_apply_float_positions([_base_cart_position, _base_exit_position], false)


func _apply_float_positions(targets: Array[Vector2], animate: bool) -> void:
	if targets[0].is_equal_approx(_target_cart_position) and targets[1].is_equal_approx(_target_exit_position):
		return
	_target_cart_position = targets[0]
	_target_exit_position = targets[1]
	if _layout_tween != null and _layout_tween.is_running():
		_layout_tween.kill()
	var duration: float = float(_config.get_value("corrimiento_s")) if animate else 0.0
	if animate and (not _cart_button.position.is_equal_approx(targets[0]) or not _exit_button.position.is_equal_approx(targets[1])):
		_layout_tween = create_tween()
		_layout_tween.set_parallel(true)
		_layout_tween.tween_property(_cart_button, "position", targets[0], duration)
		_layout_tween.tween_property(_exit_button, "position", targets[1], duration)
	else:
		_cart_button.position = targets[0]
		_exit_button.position = targets[1]


func _update_floating_layout() -> void:
	if _cart_button == null:
		return
	if not _ghost_visible:
		_apply_float_positions([_base_cart_position, _base_exit_position], true)
		return
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _world_position
	var ghost_rect := Rect2(screen_pos - _ghost_size / 2.0, _ghost_size)
	var rects: Array[Rect2] = [Rect2(_base_cart_position, _float_button_size), Rect2(_base_exit_position, _float_button_size)]
	var sides: Array[String] = [_prefs.cart_side, _prefs.exit_side]
	var targets: Array[Vector2] = FloatButtonLayout.avoid(ghost_rect, rects, sides, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")),
		_float_button_size, float(_config.get_value("fantasma_distancia_botones")))
	_apply_float_positions(targets, true)


func _on_cart_pressed() -> void:
	if _catalog_open:
		close_catalog()
	else:
		open_catalog()


func _process(_delta: float) -> void:
	if _ghost_visible:
		_update_placement_position()
		_update_floating_layout()


func _update_placement_position() -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _world_position
	var separation: float = float(_config.get_value("gestos_separacion_px"))
	var confirm_size: Vector2 = _confirm_button.size
	var cancel_size: Vector2 = _cancel_button.size
	var above: float = float(_config.get_value("fantasma_botones_arriba_px"))
	var float_rects: Array[Rect2] = [Rect2(_cart_button.position, _float_button_size), Rect2(_exit_button.position, _float_button_size)]
	var side: String = FloatButtonLayout.tick_side(Rect2(screen_pos - _ghost_size / 2.0, _ghost_size),
		float_rects, Rules.SCREEN_SIZE.x, float(_config.get_value("flotante_min_px")))
	if side == "right":
		_confirm_button.position = screen_pos + Vector2(separation / 2.0, -confirm_size.y - above)
		_cancel_button.position = screen_pos + Vector2(separation / 2.0 + confirm_size.x + separation, -cancel_size.y - above)
	else:
		_confirm_button.position = screen_pos + Vector2(-separation / 2.0 - confirm_size.x, -confirm_size.y - above)
		_cancel_button.position = screen_pos + Vector2(-separation / 2.0 - confirm_size.x - separation - cancel_size.x, -cancel_size.y - above)
