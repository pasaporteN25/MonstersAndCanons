extends GutTest
# T304 (M60, RF-545): «Ver todo» también cuando el encuadre se corrió con el zoom mínimo.
# Celular: dos dedos. PC: botón central y tecla configurable; no hay botón en pantalla.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t304_view_all.json"
	_original_mode = SaveManager.get_setting("ui_mode")
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


func _start(mode: int, level_index: int) -> void:
	SaveManager.set_setting("ui_mode", mode)
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func _touch(index: int, pos: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = pos
	event.pressed = pressed
	_game.camera_controller._input(event)


func _drag(index: int, pos: Vector2, relative: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = pos
	event.relative = relative
	_game.camera_controller._input(event)


## Corre el mapa 50 px con dos dedos, en pasos chicos para que no cuente como pinza.
func _two_finger_pan() -> void:
	var a := Vector2(300.0, 300.0)
	var b := Vector2(400.0, 300.0)
	_touch(0, a, true)
	_touch(1, b, true)
	for step: int in 5:
		a += Vector2(10.0, 0.0)
		_drag(0, a, Vector2(10.0, 0.0))
		b += Vector2(10.0, 0.0)
		_drag(1, b, Vector2(10.0, 0.0))
	_touch(0, a, false)
	_touch(1, b, false)


func test_view_all_is_hidden_at_the_start() -> void:
	await _start(UiMode.MOBILE, 14)  # 26×12: zoom mínimo 0,75
	assert_false(_game.mobile_hud._view_all_button.visible)
	assert_false(_game.camera_controller.is_view_displaced())


func test_panning_at_minimum_zoom_keeps_button_hidden_until_zoom_and_then_returns_to_fit() -> void:
	await _start(UiMode.MOBILE, 14)
	var controller: CameraController = _game.camera_controller
	_two_finger_pan()
	assert_almost_eq(_game.camera.zoom.x, _game.minimum_map_zoom, 0.0001, "el zoom sigue siendo el mínimo")
	assert_true(controller.is_view_displaced(), "el encuadre se corrió")
	assert_false(_game.mobile_hud._view_all_button.visible, "desplazar sin acercar no muestra la lupa")
	controller._zoom_at(Vector2(640.0, 340.0), 1.3)
	assert_true(_game.mobile_hud._view_all_button.visible, "la lupa aparece al acercar")
	var fit: Vector2 = controller._fit_position()
	_game.mobile_hud._view_all_button.pressed.emit()
	assert_false(_game.mobile_hud._view_all_button.visible, "desaparece")
	assert_false(controller.is_view_displaced())
	assert_eq(_game.camera.position, fit, "el encuadre de RF-251")


func test_panning_a_map_that_needs_no_zoom_keeps_view_all_hidden() -> void:
	await _start(UiMode.MOBILE, 0)  # 20×9: el zoom mínimo es 1 y al principio no hay cámara
	assert_false(_game.mobile_hud._view_all_button.visible)
	_two_finger_pan()
	assert_false(_game.mobile_hud._view_all_button.visible)


func test_zoomed_view_all_still_works_as_before() -> void:
	await _start(UiMode.MOBILE, 14)
	_game.camera_controller._zoom_at(Vector2(640.0, 340.0), 1.3)
	assert_true(_game.mobile_hud._view_all_button.visible)
	_game.camera_controller.view_all()
	assert_false(_game.mobile_hud._view_all_button.visible)
	assert_almost_eq(_game.camera.zoom.x, _game.minimum_map_zoom, 0.0001)


func test_pc_has_no_button_after_pan_or_zoom() -> void:
	await _start(UiMode.PC, 14)
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))
	_game.camera_controller._pan_by_screen_delta(Vector2(60.0, 0.0))
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))
	_game.camera_controller._zoom_at(Vector2(640.0, 340.0), 1.3)
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))


func test_mobile_has_a_single_view_all_button() -> void:
	await _start(UiMode.MOBILE, 14)
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"), "el celular usa el de su HUD")


# --- M68/M75 (T402/T464, RF-613/RF-674): la tecla de «Ver todo»; en PC no hay botón ---

func test_pc_view_all_key_goes_back_to_the_fit_even_while_paused() -> void:
	await _start(UiMode.PC, 14)
	_game.camera_controller._zoom_at(Vector2(640.0, 340.0), 1.3)
	assert_gt(_game.camera.zoom.x, _game.minimum_map_zoom)
	_game.set_paused(true)
	var event := InputEventKey.new()
	event.physical_keycode = KEY_V
	event.pressed = true
	_game._unhandled_input(event)
	assert_almost_eq(_game.camera.zoom.x, _game.minimum_map_zoom, 0.0001, "la V vuelve al encuadre")
	assert_false(_game.camera_controller.is_view_displaced())
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))


func test_pc_view_all_key_does_nothing_with_the_pause_menu_open() -> void:
	await _start(UiMode.PC, 14)
	_game.camera_controller._zoom_at(Vector2(640.0, 340.0), 1.3)
	_game.open_pause_menu()
	var zoom_before: float = _game.camera.zoom.x
	var event := InputEventKey.new()
	event.physical_keycode = KEY_V
	event.pressed = true
	_game._unhandled_input(event)
	assert_eq(_game.camera.zoom.x, zoom_before, "con el menú abierto, las teclas no hacen nada")
	_game.close_pause_menu()


func test_pc_has_no_button_tooltip() -> void:
	await _start(UiMode.PC, 14)
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))
	ViewAllBinding.apply(ViewAllBinding.DEFAULT_KEY)
