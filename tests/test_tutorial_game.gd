# Integración del tutorial del nivel 1 con la escena real de la partida (T331, M63: RF-570 a RF-577). Recorre el
# tutorial entero en modo PC y en modo celular haciendo las acciones de verdad (botones del HUD, el catálogo, el
# fantasma, toques sobre el mapa), y comprueba cuándo NO sale. Nada acá cambia de escena.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_SAVE: String = "user://test_tutorial_game.json"
const SCREEN := Rect2(0.0, 0.0, 1280.0, 720.0)

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _data: TutorialData


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_original_mode = SaveManager.get_setting("ui_mode")
	GameFlow.current_index = 0
	GameFlow.intro_pending = false
	DevMode.enabled = false
	_data = TutorialData.load_file()


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	GameFlow.current_index = -1
	GameFlow.intro_pending = false
	GameFlow.test_level = null
	DevMode.enabled = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


## Abre la partida del nivel `GameFlow.current_index` en el modo pedido, dentro de un SubViewport de 1280 × 720.
func _open(mobile: bool) -> Game:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE if mobile else UiMode.PC)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)
	_game = GAME_SCENE.instantiate() as Game
	_viewport.add_child(_game)
	await _settle()
	return _game


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _step() -> String:
	return _game.tutorial.flow.current_id()


func _overlay() -> TutorialOverlay:
	return _game.tutorial.overlay


## Aprieta el botón «Siguiente» (o «¡A jugar!») de la tarjeta.
func _next() -> void:
	assert_true(_overlay().is_next_visible(), "el paso \"%s\" es de lectura y tiene botón" % _step())
	_overlay().next_button().pressed.emit()
	await _settle()


func _press(control: Control) -> void:
	assert_not_null(control, "el control a apretar en el paso \"%s\"" % _step())
	(control as Button).pressed.emit()
	await _settle()


func _expect_step(id: String) -> void:
	assert_eq(_step(), id)
	_check_card_clear()


## La tarjeta nunca tapa lo señalado y queda dentro de la pantalla.
func _check_card_clear() -> void:
	var card: Rect2 = _overlay().card_rect()
	assert_true(SCREEN.encloses(card), "la tarjeta del paso \"%s\" entra en la pantalla (%s)" % [_step(), card])
	for target: Rect2 in _overlay().targets():
		assert_false(card.intersects(target), "la tarjeta del paso \"%s\" no tapa lo señalado" % _step())


func _tap(position: Vector2) -> void:
	for pressed: bool in [true, false]:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = position
		touch.pressed = pressed
		_viewport.push_input(touch, true)
		await get_tree().process_frame


func _walk_the_first_four_reading_steps(total: int) -> void:
	await _expect_step("welcome")
	assert_eq(_overlay().header_text(), "Tutorial · Paso 1 de %d" % total)
	assert_true(_overlay().card_text().contains("Bienvenido"))
	assert_true(_overlay().targets().is_empty(), "la bienvenida no señala nada")
	await _next()
	await _expect_step("path")
	assert_eq(_overlay().targets().size(), 2, "la entrada y la salida")
	assert_false(_game.is_paused(), "el tutorial no pausa la partida")
	await _next()
	await _expect_step("gold")
	assert_eq(_overlay().targets(), [_game.hud.target_control(&"gold").get_global_rect()] as Array[Rect2])
	await _next()
	await _expect_step("lives")
	assert_eq(_overlay().targets(), [_game.hud.target_control(&"lives").get_global_rect()] as Array[Rect2])
	await _next()


func _walk_from_start_wave_to_the_end(mobile: bool) -> void:
	await _expect_step("start_wave")
	assert_false(_overlay().is_next_visible(), "empezar la oleada es una acción, no una lectura")
	await _press(_game.hud.target_control(&"start_wave"))
	assert_eq(_game.session.wave, 1, "la oleada empezó de verdad")
	await _expect_step("select_tower")
	var tower: Tower = _game.tower_container.get_child(0) as Tower
	if mobile:
		await _tap(_game.get_viewport().get_canvas_transform() * _game.level.cell_center(tower.origin_cell))
	else:
		_game.build_controller.cancel()
		_game.build_controller.select_placed(tower)
		await _settle()
	assert_eq(_game.build_controller.selected_placed(), tower)
	await _expect_step("upgrade")
	assert_eq(_overlay().targets().size(), 1, "señala «Mejorar»")
	var upgrade: Control = _game.mobile_hud.target_control(&"upgrade") if mobile else _game.hud.target_control(&"upgrade")
	assert_eq(_overlay().targets()[0], upgrade.get_global_rect())
	await _next()
	await _expect_step("sell")
	var sell: Control = _game.mobile_hud.target_control(&"sell") if mobile else _game.hud.target_control(&"sell")
	assert_eq(_overlay().targets()[0], sell.get_global_rect())
	await _next()
	await _expect_step("speed")
	assert_true(is_equal_approx(Engine.time_scale, 1.0))
	await _press(_game.hud.target_control(&"speed"))
	assert_true(is_equal_approx(Engine.time_scale, 2.0), "la velocidad cambió de verdad")
	await _expect_step("pause")
	await _press(_game.hud.target_control(&"pause"))
	assert_true(_game.is_paused())
	await _expect_step("resume")
	assert_true(_overlay().visible, "en pausa el tutorial sigue a la vista")
	await _press(_game.hud.target_control(&"pause"))
	assert_false(_game.is_paused())
	await _expect_step("done")
	assert_eq(_overlay().next_button().text, "¡A jugar!")
	await _next()


# --- Modo PC ---

func test_pc_the_whole_tutorial_can_be_walked_on_the_real_scene() -> void:
	await _open(false)
	assert_not_null(_game.tutorial, "el nivel 1, desde el menú, con un guardado nuevo, tiene tutorial")
	assert_eq(_game.tutorial.flow.count(), 14)
	assert_true(_overlay().visible)
	await _walk_the_first_four_reading_steps(14)
	# Elegir la torre: el botón de la barra de abajo.
	await _expect_step("pick_tower")
	assert_false(_overlay().is_next_visible())
	assert_eq(_overlay().targets(), [_game.hud.target_control(&"tower_1").get_global_rect()] as Array[Rect2])
	var gold_before: int = _game.session.gold
	await _press(_game.hud.target_control(&"tower_1"))
	assert_not_null(_game.build_controller.selected_tower())
	# Colocarla: la casilla sugerida es válida y está junto al camino.
	await _expect_step("place_tower")
	var cell: Vector2i = _game.tutorial.suggested_cell()
	assert_true(_game.level.is_inside(cell))
	assert_true(_game.build_controller.cells_free(_game.available_towers[0], cell), "se puede construir ahí")
	assert_eq(_overlay().targets().size(), 1)
	assert_true(_game.build_controller.try_build(_game.available_towers[0], cell))
	assert_lt(_game.session.gold, gold_before, "construir cuesta oro, como siempre")
	await _walk_from_start_wave_to_the_end(false)
	assert_true(_game.tutorial.flow.is_finished())
	assert_false(_overlay().visible, "terminado: la tarjeta se va")
	assert_true(SaveManager.tutorial_done(), "completarlo lo marca (RF-575)")
	assert_eq(_game.tower_container.get_child_count(), 1, "el tutorial no construyó ni vendió nada por su cuenta")


func test_pc_it_does_not_show_the_phone_steps_or_texts() -> void:
	await _open(false)
	var ids: Array[String] = []
	for step: Dictionary in _game.tutorial.flow._steps:
		ids.append(step["paso"])
	assert_false(ids.has("open_cart"))
	assert_true(ids.has("pick_tower"))
	assert_null(_game.mobile_hud)


func test_pc_playing_ahead_skips_the_steps_already_done() -> void:
	await _open(false)
	await _next()  # welcome
	_game.build_controller.select(0)
	assert_true(_game.build_controller.try_build(_game.available_towers[0], _game.tutorial.suggested_cell()))
	await _next()  # path
	await _next()  # gold
	await _next()  # lives
	await _expect_step("start_wave")


func test_pc_deselecting_the_tower_goes_back_to_choosing_it() -> void:
	await _open(false)
	for i: int in 4:
		await _next()
	await _press(_game.hud.target_control(&"tower_1"))
	await _expect_step("place_tower")
	_game.build_controller.cancel()  # clic derecho o Esc
	await _settle()
	await _expect_step("pick_tower")


func test_pc_start_wave_with_the_keyboard_also_advances() -> void:
	await _open(false)
	for i: int in 4:
		await _next()
	await _press(_game.hud.target_control(&"tower_1"))
	_game.build_controller.try_build(_game.available_towers[0], _game.tutorial.suggested_cell())
	await _settle()
	await _expect_step("start_wave")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.keycode = KEY_SPACE
	key.pressed = true
	_game._unhandled_input(key)  # la acción «start_wave» es Espacio (RF-32)
	await _settle()
	assert_eq(_game.session.wave, 1)
	await _expect_step("select_tower")


# --- Modo celular ---

func test_mobile_the_whole_tutorial_can_be_walked_on_the_real_scene() -> void:
	await _open(true)
	assert_not_null(_game.mobile_hud, "es el modo celular")
	assert_eq(_game.tutorial.flow.count(), 15)
	await _walk_the_first_four_reading_steps(15)
	# El carrito.
	await _expect_step("open_cart")
	assert_eq(_overlay().targets(), [_game.mobile_hud.target_control(&"cart").get_global_rect()] as Array[Rect2])
	assert_true(_overlay().card_text().contains("carrito"))
	await _press(_game.mobile_hud.target_control(&"cart"))
	assert_true(_game.mobile_hud.is_catalog_open())
	# El catálogo: señala la primera torre elegible y la tarjeta no la tapa.
	await _expect_step("pick_card")
	var card: Control = _game.mobile_hud.target_control(&"first_card")
	assert_not_null(card)
	assert_eq(_overlay().targets(), [card.get_global_rect()] as Array[Rect2])
	var gold_before: int = _game.session.gold
	await _press(card)
	assert_false(_game.mobile_hud.is_catalog_open(), "elegir cierra el catálogo solo")
	assert_not_null(_game.build_controller.selected_tower(), "y aparece el fantasma")
	# El fantasma: un toque en la casilla sugerida lo mueve; la tilde lo confirma.
	await _expect_step("confirm_tower")
	assert_eq(_overlay().targets().size(), 2, "la casilla y la tilde")
	var cell: Vector2i = _game.tutorial.suggested_cell()
	await _tap(_game.get_viewport().get_canvas_transform() * _game.level.cell_center(cell))
	assert_eq(_game.build_controller.ghost_placement().cell, cell, "el toque movió el fantasma a la casilla sugerida")
	assert_eq(_game.session.gold, gold_before, "mover el fantasma no cobra")
	await _settle()
	await _press(_game.mobile_hud.target_control(&"confirm"))
	assert_eq(_game.tower_container.get_child_count(), 1, "la tilde construyó")
	assert_lt(_game.session.gold, gold_before)
	assert_null(_game.build_controller.selected_tower(), "después de colocar, la torre se deselecciona (RF-505)")
	await _walk_from_start_wave_to_the_end(true)
	assert_true(SaveManager.tutorial_done())
	assert_eq(_game.tower_container.get_child_count(), 1)


func test_mobile_the_double_tap_also_builds_and_advances() -> void:
	await _open(true)
	for i: int in 4:
		await _next()
	await _press(_game.mobile_hud.target_control(&"cart"))
	await _press(_game.mobile_hud.target_control(&"first_card"))
	await _expect_step("confirm_tower")
	var center: Vector2 = _game.get_viewport().get_canvas_transform() * _game.level.cell_center(_game.tutorial.suggested_cell())
	await _tap(center)
	await _tap(center)
	assert_eq(_game.tower_container.get_child_count(), 1, "doble toque = tilde (RF-505)")
	await _expect_step("start_wave")


func test_mobile_closing_the_catalog_without_choosing_goes_back_to_the_cart() -> void:
	await _open(true)
	for i: int in 4:
		await _next()
	await _press(_game.mobile_hud.target_control(&"cart"))
	await _expect_step("pick_card")
	_game.mobile_hud.close_catalog()
	await _settle()
	await _expect_step("open_cart")


func test_mobile_cancelling_the_ghost_goes_back_to_the_cart() -> void:
	await _open(true)
	for i: int in 4:
		await _next()
	await _press(_game.mobile_hud.target_control(&"cart"))
	await _press(_game.mobile_hud.target_control(&"first_card"))
	await _expect_step("confirm_tower")
	_game.build_controller.cancel()  # la cruz
	await _settle()
	await _expect_step("open_cart")
	assert_eq(_game.tower_container.get_child_count(), 0, "cancelar no construye")


func test_mobile_upgrade_and_sell_keep_the_tower_selected_so_the_buttons_stay_visible() -> void:
	await _open(true)
	for i: int in 4:
		await _next()
	await _press(_game.mobile_hud.target_control(&"cart"))
	await _press(_game.mobile_hud.target_control(&"first_card"))
	_game.build_controller.try_build(_game.available_towers[0], _game.tutorial.suggested_cell())
	_game.build_controller.cancel()
	await _settle()
	await _press(_game.hud.target_control(&"start_wave"))
	assert_eq(_step(), "select_tower")
	var tower: Tower = _game.tower_container.get_child(0) as Tower
	_game.build_controller.select_placed(tower)
	await _settle()
	assert_eq(_step(), "upgrade")
	_game.build_controller.deselect_placed()  # un toque suelto en el mapa
	await _settle()
	assert_eq(_game.build_controller.selected_placed(), tower, "la torre vuelve a quedar elegida")
	assert_eq(_overlay().targets().size(), 1, "y «Mejorar» sigue señalado")


# --- Saltar, no repetir, apagar ---

func test_skipping_it_at_any_step_marks_it_done_and_hides_the_card() -> void:
	await _open(false)
	await _next()
	await _next()
	var results: Array = []
	_game.tutorial.finished.connect(func(completed: bool) -> void: results.append(completed))
	_overlay().skip_button().pressed.emit()
	await _settle()
	assert_eq(results, [false])
	assert_false(_overlay().visible)
	assert_true(SaveManager.tutorial_done(), "saltarlo también lo marca: no se repite")
	assert_false(_game.is_paused())
	assert_eq(_game.tower_container.get_child_count(), 0)


func test_skipping_works_on_the_phone_too() -> void:
	await _open(true)
	_overlay().skip_button().pressed.emit()
	await _settle()
	assert_true(SaveManager.tutorial_done())
	assert_false(_overlay().visible)


func test_it_does_not_repeat_once_done() -> void:
	SaveManager.mark_tutorial_done()
	await _open(false)
	assert_null(_game.tutorial)


func test_retrying_a_level_that_was_not_finished_shows_it_again_from_the_start() -> void:
	await _open(false)
	await _next()
	await _next()
	assert_eq(_step(), "gold")
	_viewport.remove_child(_game)
	_game.free()
	_game = GAME_SCENE.instantiate() as Game
	_viewport.add_child(_game)
	await _settle()
	assert_eq(_step(), "welcome", "no se guardó el paso: cerrar o reintentar a la mitad lo repite")


func test_turned_off_in_options_it_does_not_show() -> void:
	SaveManager.set_setting("tutorial_enabled", false)
	await _open(false)
	assert_null(_game.tutorial)
	assert_false(_game.is_paused())


func test_replay_from_options_shows_it_again_after_it_was_done() -> void:
	SaveManager.mark_tutorial_done()
	SaveManager.reset_tutorial()
	await _open(false)
	assert_not_null(_game.tutorial)


func test_an_old_save_with_level_1_won_does_not_show_it() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":20},"level_02":{"unlocked":true,"completed":false,"best_lives":0}}}')
	file.close()
	SaveManager.load_save()
	await _open(false)
	assert_null(_game.tutorial)


func test_it_does_not_show_in_the_test_mode() -> void:
	DevMode.enabled = true
	await _open(false)
	assert_null(_game.tutorial)


func test_it_does_not_show_in_other_levels() -> void:
	GameFlow.current_index = 1
	await _open(false)
	assert_null(_game.tutorial, "el nivel 2 no lleva tutorial")


func test_it_does_not_show_when_the_game_is_opened_without_the_menu() -> void:
	GameFlow.current_index = -1  # F6 o los tests: el primer nivel de la campaña sin pasar por la selección
	await _open(false)
	assert_null(_game.tutorial)


func test_it_does_not_show_when_testing_a_map_from_the_editor() -> void:
	GameFlow.current_index = -1
	GameFlow.test_level = GameFlow.level(0)
	await _open(false)
	assert_null(_game.tutorial)


func test_it_waits_for_the_entry_card_and_starts_when_it_closes() -> void:
	GameFlow.intro_pending = true
	await _open(false)
	assert_true(_game.level_intro.is_open(), "el nivel 1 trae su cartel de entrada")
	assert_not_null(_game.tutorial)
	assert_false(_overlay().visible, "mientras se lee el cartel el tutorial espera")
	_game.level_intro.close()
	await _settle()
	assert_true(_overlay().visible)
	assert_eq(_step(), "welcome")
	assert_false(_game.is_paused(), "al cerrar el cartel la partida sigue como estaba")


func test_the_end_of_the_level_hides_the_tutorial_without_marking_it() -> void:
	await _open(false)
	_game.session.finish(false)
	await _settle()
	assert_false(_overlay().visible)
	assert_false(SaveManager.tutorial_done(), "perder a la mitad no lo da por completado")


func test_the_tutorial_leaves_the_level_untouched() -> void:
	var reference: LevelData = GameFlow.level(0)
	var gold: int = reference.starting_gold
	var lives: int = reference.starting_lives
	var waves: int = reference.waves.size()
	await _open(false)
	assert_eq(_game.session.gold, gold)
	assert_eq(_game.session.lives, lives)
	assert_eq(_game.session.total_waves, waves)
	assert_eq(_game.session.wave, 0, "no empieza ninguna oleada sola")
