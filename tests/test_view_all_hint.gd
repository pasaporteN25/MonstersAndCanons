extends GutTest

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String
var _original_current_index: int
var _original_intro_pending: bool


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t464_view_all_hint.json"
	SaveManager.load_save()
	_original_mode = SaveManager.get_setting("ui_mode")
	_original_current_index = GameFlow.current_index
	_original_intro_pending = GameFlow.intro_pending
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	GameFlow.current_index = _original_current_index
	GameFlow.intro_pending = _original_intro_pending
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func _start(mode: int) -> void:
	SaveManager.set_setting("ui_mode", mode)
	GameFlow.current_index = 14
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(14)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame
	if _game.level_intro.is_open():
		_game.level_intro.close()


func test_first_eligible_camera_change_shows_one_line_and_saves_seen() -> void:
	await _start(UiMode.PC)
	_game.camera_controller._zoom_at(Vector2(640, 360), 1.2)
	assert_true(_game.hud._view_all_notice.visible)
	assert_eq(_game.hud._view_all_notice.text, "Acercaste el mapa. Apretá V para volver a verlo entero.")
	assert_true(SaveManager.get_ui_prefs().view_all_hint_seen)
	_game.hud._view_all_notice.hide()
	_game._on_view_zoomed_in()
	assert_false(_game.hud._view_all_notice.visible)


func test_mobile_text_and_custom_key_are_used() -> void:
	await _start(UiMode.MOBILE)
	_game.camera_controller._zoom_at(Vector2(640, 360), 1.2)
	assert_eq(_game.hud._view_all_notice.text, "Acercaste el mapa. Tocá la lupa para volver a verlo entero.")
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	prefs.view_all_hint_seen = false
	prefs.view_all_key = KEY_H
	SaveManager.set_ui_prefs(prefs)
	SaveManager.set_setting("ui_mode", UiMode.PC)
	_game._on_view_zoomed_in()
	assert_eq(_game.hud._view_all_notice.text, "Acercaste el mapa. Apretá H para volver a verlo entero.")


func test_camera_notice_is_not_restricted_to_campaign_mode() -> void:
	await _start(UiMode.PC)
	_game._on_view_zoomed_in()
	assert_true(_game.hud._view_all_notice.visible)
	assert_true(SaveManager.get_ui_prefs().view_all_hint_seen)


func test_pc_has_no_onscreen_view_all_control() -> void:
	await _start(UiMode.PC)
	assert_null(_game.camera_controller.get_node_or_null("ViewAllLayer"))


func test_panning_without_zoom_does_not_show_or_remember_the_notice() -> void:
	await _start(UiMode.MOBILE)
	_game.camera_controller._pan_by_screen_delta(Vector2(60, 0))
	assert_false(_game.hud._view_all_notice.visible)
	assert_false(SaveManager.get_ui_prefs().view_all_hint_seen)


func test_zooming_out_does_not_show_the_approach_notice() -> void:
	await _start(UiMode.PC)
	_game.camera.zoom *= 1.2
	_game.open_pause_menu()
	_game.camera_controller._zoom_at(Vector2(640, 360), 1.0 / 1.2)
	_game.close_pause_menu()
	assert_false(_game.hud._view_all_notice.visible)
	assert_false(SaveManager.get_ui_prefs().view_all_hint_seen)


func test_moving_a_mobile_button_preserves_the_seen_marker() -> void:
	await _start(UiMode.MOBILE)
	_game.camera_controller._zoom_at(Vector2(640, 360), 1.2)
	assert_true(SaveManager.get_ui_prefs().view_all_hint_seen)
	var mobile_hud: MobileHud = _game.mobile_hud
	mobile_hud._drag_button = mobile_hud._cart_button
	var moved_position: Vector2 = mobile_hud._cart_button.position + Vector2(24, 24)
	mobile_hud._finish_drag(moved_position)
	assert_true(SaveManager.get_ui_prefs().view_all_hint_seen, "guardar la ubicación del carrito no borra la marca del aviso")
