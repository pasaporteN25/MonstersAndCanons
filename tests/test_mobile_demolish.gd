extends GutTest
# T302 (M60, RF-542 y RF-543): el botón flotante «Demoler / Habilitar» y su estado en la barra de abajo.
# Partida real en un SubViewport, modo celular, guardado de prueba.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t302_demolish.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _start(level_index: int) -> void:
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func _spec_of(kind: ObstacleSpec.Kind) -> ObstacleSpec:
	for spec: ObstacleSpec in _game.level_data.obstacles:
		if spec.kind == kind:
			return spec
	return null


func _tap(cell: Vector2i) -> void:
	_game.build_controller._mobile_map_tap(_game.level.cell_center(cell), Time.get_ticks_msec())
	await get_tree().process_frame


func _empty_cell() -> Vector2i:
	for y: int in _game.level.map_size().y:
		for x: int in _game.level.map_size().x:
			var cell := Vector2i(x, y)
			if _game.infrastructure.obstacle_at(cell) == null:
				return cell
	return Vector2i(-1, -1)


func test_the_button_exists_only_in_levels_with_something_to_demolish() -> void:
	await _start(0)
	assert_false(_game.mobile_hud._demolish_button.visible, "el nivel 1 no tiene removibles")
	assert_eq(_game.mobile_hud._active_float_indices().size(), 2)
	_game.queue_free()
	await get_tree().process_frame
	await _start(6)
	assert_true(_game.mobile_hud._demolish_button.visible, "el nivel 7 sí")
	assert_eq(_game.mobile_hud._active_float_indices().size(), 3)


func test_the_catalog_has_no_infrastructure_cards() -> void:
	await _start(9)
	_game.mobile_hud.open_catalog()
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		var text: String = (child as Button).text
		assert_false(text.begins_with("Demoler") or text.begins_with("Habilitar"), text)


func test_pressing_the_button_chooses_the_tool_and_shows_the_bar_state() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	hud.demolish_pressed.emit()
	await get_tree().process_frame
	assert_true(_game.build_controller.mobile_action_active())
	assert_eq(hud._status_state, "tool")
	assert_true(hud._status_label.text.begins_with("Demoler o habilitar"))
	assert_true(hud._bottom_cancel.visible, "la cruz está a la vista")
	assert_false(hud._bottom_confirm.visible)
	assert_false(_game.hud._start_wave_button.visible, "con la herramienta no está «Empezar oleada»")
	assert_ne(hud._demolish_button.self_modulate, Color.WHITE, "el botón queda marcado")
	assert_eq(hud._cart_button.self_modulate, Color.WHITE, "el carrito no")


func test_pressing_the_button_again_or_the_cross_releases_the_tool() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	hud.demolish_pressed.emit()
	hud.demolish_pressed.emit()
	await get_tree().process_frame
	assert_false(_game.build_controller.mobile_action_active())
	assert_eq(hud._status_state, "empty")
	assert_true(_game.hud._start_wave_button.visible, "vuelve «Empezar oleada»")
	assert_eq(hud._demolish_button.self_modulate, Color.WHITE)
	hud.demolish_pressed.emit()
	await get_tree().process_frame
	hud._bottom_cancel.pressed.emit()
	await get_tree().process_frame
	assert_false(_game.build_controller.mobile_action_active(), "la cruz la suelta")
	assert_eq(hud._status_state, "empty")
	hud.demolish_pressed.emit()
	var back := InputEventAction.new()
	back.action = "cancel"
	back.pressed = true
	_game.build_controller._unhandled_input(back)
	assert_false(_game.build_controller.mobile_action_active(), "Esc o «atrás» también")


func test_choosing_a_tower_or_pausing_releases_the_tool() -> void:
	await _start(6)
	_game.mobile_hud.demolish_pressed.emit()
	_game.mobile_hud.tower_chosen.emit(0, false)
	assert_false(_game.build_controller.mobile_action_active())
	_game.build_controller.cancel()
	_game.mobile_hud.demolish_pressed.emit()
	_game.open_pause_menu()
	assert_false(_game.build_controller.mobile_action_active(), "el menú de pausa la suelta")


func test_tapping_an_extraction_point_enables_it_and_releases_the_tool() -> void:
	await _start(9)
	var extraction: ObstacleSpec = _spec_of(ObstacleSpec.Kind.EXTRACTION)
	assert_not_null(extraction)
	_game.session.earn(5000)
	var gold_before: int = _game.session.gold
	_game.mobile_hud.demolish_pressed.emit()
	await _tap(extraction.cell)
	assert_eq(_game.infrastructure.field.state_of(extraction.cell), ObstacleField.State.ACTIVE)
	assert_eq(_game.session.gold, gold_before - _game.infrastructure.field.cost_of(extraction.cell))
	assert_false(_game.build_controller.mobile_action_active(), "salió bien: se suelta sola")


func test_tapping_a_removable_orders_the_demolition_and_releases_the_tool() -> void:
	await _start(9)
	var removable: ObstacleSpec = _spec_of(ObstacleSpec.Kind.REMOVABLE)
	assert_not_null(removable)
	_game.session.earn(5000)
	_game.mobile_hud.demolish_pressed.emit()
	await _tap(removable.cell)
	assert_true(_game.infrastructure.field.has_job())
	assert_false(_game.build_controller.mobile_action_active())
	assert_false(_game.is_paused())


func test_a_useless_tap_keeps_the_tool_and_says_why() -> void:
	await _start(9)
	var removable: ObstacleSpec = _spec_of(ObstacleSpec.Kind.REMOVABLE)
	var hud: MobileHud = _game.mobile_hud
	hud.demolish_pressed.emit()
	var gold_before: int = _game.session.gold
	await _tap(_empty_cell())
	await get_tree().process_frame
	assert_true(_game.build_controller.mobile_action_active(), "la herramienta sigue")
	assert_true(hud._status_label.text.contains("nada para demoler"), hud._status_label.text)
	assert_eq(_game.session.gold, gold_before, "no se cobró nada")
	_game.session.spend(_game.session.gold)
	await _tap(removable.cell)
	await get_tree().process_frame
	assert_true(_game.build_controller.mobile_action_active())
	assert_true(hud._status_label.text.begins_with("Faltan"), hud._status_label.text)
	assert_false(_game.infrastructure.field.has_job())
	_game.session.earn(5000)
	await _tap(removable.cell)
	assert_true(_game.infrastructure.field.has_job())
	var other: ObstacleSpec = null
	for spec: ObstacleSpec in _game.level_data.obstacles:
		if spec.kind == ObstacleSpec.Kind.REMOVABLE and spec.cell != removable.cell and _game.infrastructure.obstacle_at(spec.cell) != null:
			other = spec
			break
	if other != null:
		hud.demolish_pressed.emit()
		await _tap(other.cell)
		await get_tree().process_frame
		assert_true(hud._status_label.text.contains("en curso"), "una sola demolición a la vez: %s" % hud._status_label.text)


func test_the_machine_is_the_last_card_of_the_catalog() -> void:
	await _start(6)  # el nivel 7 trae la Demoledora
	assert_false(_game._mobile_machine_option().is_empty())
	_game.mobile_hud.open_catalog()
	var cards: Array[Node] = _game.mobile_hud._tower_grid.get_children()
	assert_true((cards[cards.size() - 1] as Button).text.begins_with("Demoledora"))
	_game.session.earn(5000)
	_game.mobile_hud.infrastructure_tool_chosen.emit(&"machine", &"")
	assert_true(_game.infrastructure.field.has_machine)
	assert_true(_game._mobile_machine_option().is_empty(), "ya comprada, la tarjeta se va")


# --- Los tres botones flotantes (RF-509, D-111) ---

func test_the_three_buttons_do_not_overlap_and_stay_in_the_map_area() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	var rects: Array[Rect2] = [hud._cart_button.get_global_rect(), hud._exit_button.get_global_rect(), hud._demolish_button.get_global_rect()]
	for i: int in 3:
		for j: int in i:
			assert_false(rects[i].intersects(rects[j]), "los botones %d y %d no se pisan" % [i, j])
		assert_gte(rects[i].position.y, 64.0)
		assert_lte(rects[i].end.y, 624.0)


func test_dragging_the_demolish_button_saves_its_place() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	hud._drag_button = hud._demolish_button
	hud._finish_drag(Vector2(10.0, 344.0))
	assert_eq(hud._prefs.demolish_side, "left")
	assert_almost_eq(hud._prefs.demolish_y, 0.5, 0.05)
	assert_almost_eq(hud._demolish_button.position.x, 0.0, 0.1)
	assert_eq(SaveManager.get_ui_prefs().demolish_side, "left", "se guardó")
	assert_false(hud._demolish_button.get_global_rect().intersects(hud._exit_button.get_global_rect()))


func test_same_side_buttons_are_separated_with_three_buttons() -> void:
	var positions := FloatButtonLayout.avoid(Rect2(Vector2(-100.0, -100.0), Vector2.ZERO),
		[Rect2(Vector2(1216.0, 200.0), Vector2.ONE * 64.0), Rect2(Vector2(1216.0, 220.0), Vector2.ONE * 64.0),
		Rect2(Vector2(1216.0, 230.0), Vector2.ONE * 64.0)], ["right", "right", "right"],
		Vector2(1280.0, 720.0), 64.0, 96.0, Vector2.ONE * 64.0, 0.0)
	for i: int in 3:
		for j: int in i:
			assert_true(absf(positions[i].y - positions[j].y) >= 128.0 - 0.01, "%d y %d separados" % [i, j])
	var apart := FloatButtonLayout.avoid(Rect2(Vector2(-100.0, -100.0), Vector2.ZERO),
		[Rect2(Vector2(0.0, 200.0), Vector2.ONE * 64.0), Rect2(Vector2(1216.0, 210.0), Vector2.ONE * 64.0)],
		["left", "right"], Vector2(1280.0, 720.0), 64.0, 96.0, Vector2.ONE * 64.0, 0.0)
	assert_eq(apart[1].y, 210.0, "uno de cada lado no se mueve")


func test_prefs_without_the_demolish_keys_load_defaults_and_bad_ones_fall_back() -> void:
	var old: UiPrefs = UiPrefs.read({"cart_side": "left", "cart_y": 0.3, "exit_side": "right", "exit_y": 0.2})
	assert_eq(old.demolish_side, "right")
	assert_almost_eq(old.demolish_y, 0.8, 0.001)
	assert_eq(old.cart_side, "left")
	var broken: UiPrefs = UiPrefs.read({"cart_side": "left", "cart_y": 0.3, "exit_side": "right", "exit_y": 0.2,
		"demolish_side": "arriba", "demolish_y": 3})
	assert_eq(broken.demolish_side, "right")
	assert_almost_eq(broken.demolish_y, 0.8, 0.001)
	assert_eq(broken.cart_side, "left", "los campos sanos se conservan")
	var good: UiPrefs = UiPrefs.read({"demolish_side": "left", "demolish_y": 0.5})
	assert_eq(good.demolish_side, "left")
	assert_almost_eq(good.demolish_y, 0.5, 0.001)


func test_the_button_hides_with_a_modal_or_when_the_game_ends() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	hud.set_modal_open(true)
	assert_false(hud._demolish_button.visible)
	hud.set_modal_open(false)
	assert_true(hud._demolish_button.visible)
	hud.set_game_over(true)
	assert_false(hud._demolish_button.visible)


func test_the_button_goes_semitransparent_with_a_ghost() -> void:
	await _start(6)
	var hud: MobileHud = _game.mobile_hud
	hud.set_placement_visible(true)
	assert_almost_eq(hud._demolish_button.modulate.a, 0.45, 0.001)
	hud.set_placement_visible(false)
	assert_almost_eq(hud._demolish_button.modulate.a, 1.0, 0.001)
