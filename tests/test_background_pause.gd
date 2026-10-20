extends GutTest
# T303 (M60, RF-544): la partida se pausa sola al pasar la app a segundo plano; en una PC perder el foco no pausa.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t303_background.json"
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


func _start(mode: int) -> void:
	SaveManager.set_setting("ui_mode", mode)
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(0)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func test_the_app_going_to_the_background_pauses_a_running_game() -> void:
	await _start(UiMode.MOBILE)
	assert_false(_game.is_paused())
	_game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_true(_game.is_paused(), "pausada al pasar a segundo plano")
	assert_eq(_game.hud._pause_button.text, "Seguir", "el botón Pausa dice «Seguir»")
	_game.toggle_pause()
	assert_false(_game.is_paused(), "se sigue con el botón de siempre")


func test_the_pause_also_works_in_the_pc_interface_on_a_phone() -> void:
	await _start(UiMode.PC)
	_game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_true(_game.is_paused())


func test_it_does_nothing_if_already_paused_or_the_game_is_over() -> void:
	await _start(UiMode.MOBILE)
	_game.open_pause_menu()
	assert_true(_game.is_paused())
	_game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_true(_game.pause_menu.is_open(), "el menú sigue abierto")
	_game.close_pause_menu()
	assert_false(_game.is_paused())
	_game.session.lose_lives(_game.session.lives)
	assert_true(_game.session.is_over())
	get_tree().paused = false
	_game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_false(get_tree().paused, "con la partida terminada no hay nada que pausar")


func test_losing_focus_on_a_computer_does_not_pause() -> void:
	await _start(UiMode.PC)
	assert_false(OS.has_feature("mobile"), "los tests corren en una computadora")
	_game.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_false(_game.is_paused(), "en PC perder el foco no pausa")
	_game.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	assert_false(_game.is_paused())
