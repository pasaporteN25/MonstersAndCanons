extends GutTest

var _hud: MobileHud
var _saved_prefs: UiPrefs
var _original_save_path: String
var _viewport: SubViewport
var _game: Game
var _original_mode: Variant


func before_each() -> void:
	_saved_prefs = SaveManager.get_ui_prefs()
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_mobile_hud_input.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_viewport.add_child(_game)
	_hud = _game.mobile_hud
	await get_tree().process_frame


func after_each() -> void:
	SaveManager.set_ui_prefs(_saved_prefs)
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _mouse(pos: Vector2, pressed: bool, device: int = 0) -> void:
	var event := InputEventMouseButton.new()
	event.position = pos
	event.global_position = pos
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.device = device
	_viewport.push_input(event, true)
	await get_tree().process_frame


func _touch(pos: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = pos
	event.pressed = pressed
	_viewport.push_input(event, true)
	await get_tree().process_frame


func test_cart_opens_once_with_mouse_and_touch_on_both_edges() -> void:
	var transitions: Array[bool] = []
	_hud.catalog_opened.connect(func(open: bool) -> void: transitions.append(open))
	for side: String in ["left", "right"]:
		_hud._prefs.cart_side = side
		_hud._apply_saved_positions()
		var center: Vector2 = _hud._cart_button.get_global_rect().get_center()
		transitions.clear()
		await _mouse(center, true)
		await _mouse(center, false)
		assert_eq(transitions, [true], "mouse en %s" % side)
		_hud.close_catalog()
		transitions.clear()
		await _touch(center, true)
		await _touch(center, false)
		assert_eq(transitions, [true], "toque en %s" % side)
		_hud.close_catalog()


func test_emulated_mouse_does_not_toggle_the_cart_twice() -> void:
	var center: Vector2 = _hud._cart_button.get_global_rect().get_center()
	await _touch(center, true)
	await _mouse(center, true, InputEvent.DEVICE_ID_EMULATION)
	await _touch(center, false)
	await _mouse(center, false, InputEvent.DEVICE_ID_EMULATION)
	assert_true(_hud.is_catalog_open())


func test_dragging_cart_to_other_edge_does_not_open_it() -> void:
	var center: Vector2 = _hud._cart_button.get_global_rect().get_center()
	await _touch(center, true)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(40.0, 330.0)
	drag.relative = drag.position - center
	_viewport.push_input(drag, true)
	await get_tree().process_frame
	await _touch(drag.position, false)
	assert_false(_hud.is_catalog_open())
	assert_eq(_hud._prefs.cart_side, "left")
	assert_almost_eq(_hud._cart_button.position.x, 0.0, 0.1)


func test_placement_reports_reason_without_enlarging_the_tick() -> void:
	_hud.show_ghost_status("Mortero", "300 + 3")
	_hud.show_placement(Vector2(640.0, 360.0), "300 + 3", true, "")
	await get_tree().process_frame
	assert_eq(_hud._confirm_button.text, "")
	assert_eq(_hud._bottom_confirm.text, "")
	assert_not_null(_hud._confirm_button.icon)
	assert_eq(_hud._confirm_button.size, Vector2(64.0, 64.0))
	_hud.show_placement(Vector2(640.0, 360.0), "300 + 3", false, "Faltan 3 recursos")
	assert_true(_hud._confirm_button.disabled)
	assert_true(_hud._bottom_confirm.disabled)
	assert_string_contains(_hud._status_label.text, "Faltan 3 recursos")
