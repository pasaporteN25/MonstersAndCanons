extends GutTest
# M68 (T401, RF-610, RF-611, D-160): con la partida en pausa, el carrito y el botón de demolición del celular
# quedan apagados y no se construye. La PC no cambia.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_m68_pause_lock.json"
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


func _start(mode: int, level_index: int = 0) -> void:
	SaveManager.set_setting("ui_mode", mode)
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func _cart() -> Button:
	return _game.mobile_hud.find_child("CartButton", true, false) as Button


func test_pausing_closes_the_open_catalog_and_greys_the_cart() -> void:
	await _start(UiMode.MOBILE)
	_game.mobile_hud.open_catalog()
	assert_true(_game.mobile_hud.is_catalog_open())
	_game.set_paused(true)
	assert_false(_game.mobile_hud.is_catalog_open(), "el catálogo abierto se cierra")
	assert_true(_cart().disabled)
	assert_false(_game.build_controller.input_blocked, "y el mapa vuelve a recibir toques")


func test_the_cart_does_nothing_while_paused_and_says_why() -> void:
	await _start(UiMode.MOBILE)
	_game.set_paused(true)
	_game.mobile_hud._on_cart_pressed()
	assert_false(_game.mobile_hud.is_catalog_open())
	_game.mobile_hud.open_catalog()
	assert_false(_game.mobile_hud.is_catalog_open(), "ni siquiera por la puerta de atrás")
	var status: Label = _game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_true(status.text.contains("En pausa"))


func test_resuming_gives_the_cart_back() -> void:
	await _start(UiMode.MOBILE)
	_game.set_paused(true)
	_game.set_paused(false)
	assert_false(_cart().disabled)
	var status: Label = _game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_true(status.text.contains("carrito"), "la línea de abajo vuelve a la de siempre")
	_game.mobile_hud._on_cart_pressed()
	assert_true(_game.mobile_hud.is_catalog_open())


func test_the_pause_button_and_the_pause_menu_both_lock_the_cart() -> void:
	await _start(UiMode.MOBILE)
	_game.open_pause_menu()
	assert_true(_cart().disabled)
	_game.close_pause_menu()
	assert_false(_cart().disabled)
	_game.toggle_pause()
	assert_true(_cart().disabled)
	_game.toggle_pause()
	assert_false(_cart().disabled)


func test_demolish_button_is_locked_too_in_a_level_with_infrastructure() -> void:
	await _start(UiMode.MOBILE, 5)
	var demolish: Button = _game.mobile_hud.find_child("DemolishButton", true, false) as Button
	_game.set_paused(true)
	assert_true(demolish.disabled)
	var emitted: Array[int] = [0]
	_game.mobile_hud.demolish_pressed.connect(func() -> void: emitted[0] += 1)
	_game.mobile_hud._drag_button = demolish
	_game.mobile_hud._drag_index = 7
	_game.mobile_hud._handle_drag_touch(7, demolish.get_global_rect().get_center(), false)
	assert_eq(emitted[0], 0, "tocarlo en pausa no elige la herramienta")
	_game.set_paused(false)
	assert_false(demolish.disabled)


func test_a_ghost_is_dropped_when_pausing_and_nothing_is_built() -> void:
	await _start(UiMode.MOBILE)
	var controller: BuildController = _game.build_controller
	var gold: int = _game.session.gold
	controller.select(0)
	_game.set_paused(true)
	assert_null(controller.selected_tower(), "al pausar se suelta la torre elegida")
	controller.select(0)
	controller.confirm_ghost()
	assert_eq(_game.session.gold, gold, "no se cobra nada en pausa")
	assert_eq(_game.tower_container.get_child_count(), 0)


func test_pc_has_no_mobile_hud_and_pause_still_works() -> void:
	await _start(UiMode.PC)
	assert_null(_game.mobile_hud)
	_game.set_paused(true)
	assert_true(_game.is_paused())
	_game.set_paused(false)
