# Tests de la pantalla de carga conectada con el juego (M64, RF-580 a RF-584, RF-588; T340).
# El defecto que se reportó en el celular: al elegir un nivel la carga tarda, y un toque de más sobre la selección
# lanzaba el nivel que quedaba debajo del dedo. Acá se tocan tarjetas de la selección REAL con eventos reales
# mientras `GameFlow.transition` está cambiando de pantalla. La costura es `GameFlow.transition.swapper`: cuenta
# los cambios en vez de reemplazar la escena de GUT.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const DEV_PATH: String = "user://test_save_pruebas_carga.json"
const TEST_SAVE: String = "user://test_save_carga.json"
const TEST_DIR: String = "user://test_loading_select/"

var _swaps: Array = []
var _old_min: float
var _old_release: float


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)  # en el modo de pruebas todos los niveles están abiertos: hay una tarjeta debajo del dedo
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)  # las pruebas tocan tarjetas durante la transición
	_swaps = []
	_old_min = GameFlow.transition.min_seconds
	_old_release = GameFlow.transition.release_seconds
	GameFlow.transition.min_seconds = 0.3
	GameFlow.transition.release_seconds = 0.05
	GameFlow.transition.swapper = func(scene: PackedScene) -> void: _swaps.append(scene)
	GameFlow.current_index = -1
	GameFlow.current_community = null


func after_each() -> void:
	await wait_until(func() -> bool: return not GameFlow.is_changing(), 8.0)
	get_tree().root.set_disable_input(false)
	GameFlow.transition.swapper = Callable()
	GameFlow.transition.min_seconds = _old_min
	GameFlow.transition.release_seconds = _old_release
	GameFlow.transition.blocks_input = true
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.test_level = null
	GameFlow.intro_pending = false
	DevMode.reset_start()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	for path: String in [DEV_PATH, TEST_SAVE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _select() -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = TEST_DIR
	add_child_autofree(select)
	return select


func _cards(select: Control) -> Array[Node]:
	return select.get_node("%Cards").get_children()


## En la corrida sin pantalla la ventana mide 64 × 64: los eventos van en coordenadas de ventana.
func _window_pos(game_pos: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * game_pos


func _tap(card: Control) -> void:
	var center: Vector2 = _window_pos(card.get_global_rect().get_center())
	var motion := InputEventMouseMotion.new()
	motion.position = center
	motion.global_position = center
	Input.parse_input_event(motion)
	Input.flush_buffered_events()
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = center
		event.global_position = center
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await wait_process_frames(1)


func _touch(card: Control) -> void:
	var center: Vector2 = _window_pos(card.get_global_rect().get_center())
	for pressed: bool in [true, false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = center
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_process_frames(1)


func _wait_done() -> void:
	await wait_until(func() -> bool: return not GameFlow.is_changing(), 8.0)


# --- El defecto reportado ---

func test_a_tap_starts_the_level_through_the_loading_screen() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	await _tap(_cards(select)[0])
	assert_true(GameFlow.is_changing(), "RF-580: se empezó a cambiar de pantalla")
	assert_true(GameFlow.transition.is_overlay_visible(), "con la pantalla de carga")
	assert_eq(GameFlow.current_index, 0)
	await _wait_done()
	assert_eq(_swaps.size(), 1, "y se cambió una sola vez")


func test_a_second_tap_on_another_card_during_the_load_does_not_launch_it() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	var cards: Array[Node] = _cards(select)
	assert_false((cards[1] as Button).disabled, "la segunda tarjeta está disponible: es la que quedaba bajo el dedo")
	await _tap(cards[0])
	await _tap(cards[1])
	await _tap(cards[2])
	await _tap(cards[1])
	assert_eq(GameFlow.current_index, 0, "RF-582: el nivel sigue siendo el primero")
	await _wait_done()
	assert_eq(_swaps.size(), 1, "RF-582: se cargó un solo nivel")


func test_real_touches_during_the_load_do_not_launch_another_level() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	var cards: Array[Node] = _cards(select)
	await _tap(cards[0])
	await _touch(cards[1])
	await _touch(cards[1])
	await _touch(cards[3])
	assert_eq(GameFlow.current_index, 0)
	await _wait_done()
	assert_eq(_swaps.size(), 1)


func test_the_tap_is_not_replayed_on_the_card_after_the_swap() -> void:
	# Los toques que llegan mientras el motor arma la escena nueva se descartan.
	var select: Control = _select()
	await wait_process_frames(2)
	var cards: Array[Node] = _cards(select)
	GameFlow.transition.swapper = func(scene: PackedScene) -> void:
		_swaps.append(scene)
		var center: Vector2 = _window_pos((cards[1] as Control).get_global_rect().get_center())
		for pressed: bool in [true, false]:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.position = center
			event.global_position = center
			event.pressed = pressed
			Input.parse_input_event(event)
	await _tap(cards[0])
	await _wait_done()
	await wait_process_frames(3)
	assert_eq(GameFlow.current_index, 0, "RF-583: lo que se juntó durante el cambio no lanza otro nivel")
	assert_eq(_swaps.size(), 1)


func test_back_during_the_load_does_nothing() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	await _tap(_cards(select)[0])
	var back := InputEventAction.new()
	back.action = &"cancel"
	back.pressed = true
	Input.parse_input_event(back)
	await wait_process_frames(2)
	assert_eq(GameFlow.current_index, 0, "RF-583: «atrás» no vuelve al menú a mitad de la carga (ahí current_index sería -1)")
	await _wait_done()
	assert_eq(_swaps.size(), 1)


func test_flow_functions_do_nothing_while_changing() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	await _tap(_cards(select)[0])
	GameFlow.go_to_main_menu()
	GameFlow.go_to_level_select()
	GameFlow.go_to_records()
	GameFlow.go_to_wiki()
	GameFlow.go_to_editor()
	GameFlow.start_level(1)
	GameFlow.next_level()
	GameFlow.reload_current()
	assert_eq(GameFlow.current_index, 0, "RF-582: ninguna función del flujo pisa el estado de la partida que se está cargando")
	await _wait_done()
	assert_eq(_swaps.size(), 1)


func test_after_the_load_the_next_tap_works_again() -> void:
	var select: Control = _select()
	await wait_process_frames(2)
	var cards: Array[Node] = _cards(select)
	await _tap(cards[0])
	await _wait_done()
	await wait_process_frames(2)
	await _tap(cards[1])
	assert_eq(GameFlow.current_index, 1, "RF-583: la entrada se libera")
	await _wait_done()
	assert_eq(_swaps.size(), 2)


# --- Los demás cambios ---

func test_every_screen_change_goes_through_the_transition() -> void:
	var paths: Array = []
	for call: Callable in [GameFlow.go_to_main_menu, GameFlow.go_to_level_select, GameFlow.go_to_records, GameFlow.go_to_wiki]:
		var starts: Array = []
		var on_start: Callable = func(path: String) -> void: starts.append(path)
		GameFlow.transition.started.connect(on_start)
		call.call()
		await _wait_done()
		GameFlow.transition.started.disconnect(on_start)
		assert_eq(starts.size(), 1, "RF-580: pasa por la pantalla de carga")
		paths.append(starts[0])
	assert_eq(paths, [GameFlow.MAIN_MENU_SCENE, GameFlow.LEVEL_SELECT_SCENE, GameFlow.RECORDS_SCENE, GameFlow.WIKI_SCENE])


func test_levels_modes_community_and_next_level_use_the_transition() -> void:
	var starts: Array = []
	GameFlow.transition.started.connect(func(path: String) -> void: starts.append(path))
	GameFlow.start_level(0)
	await _wait_done()
	GameFlow.next_level()
	await _wait_done()
	assert_eq(GameFlow.current_index, 1, "«Siguiente nivel»")
	assert_eq(starts, [GameFlow.GAME_SCENE, GameFlow.GAME_SCENE])
	GameFlow.start_community(GameFlow.level(0))
	await _wait_done()
	assert_eq(starts.size(), 3, "mapa de la comunidad")
	GameFlow.play_test(GameFlow.level(0))
	await _wait_done()
	assert_eq(starts.size(), 4, "probar desde el editor")
	assert_eq(_swaps.size(), 4)


func test_retry_reloads_the_current_scene_through_the_transition() -> void:
	# `Game.restart` termina en `GameFlow.reload_current`. GUT no tiene escena actual: se finge una con ruta.
	var fake := Node.new()
	fake.scene_file_path = GameFlow.GAME_SCENE
	get_tree().root.add_child(fake)
	get_tree().current_scene = fake
	var starts: Array = []
	GameFlow.transition.started.connect(func(path: String) -> void: starts.append(path))
	GameFlow.reload_current()
	await _wait_done()
	get_tree().current_scene = null
	fake.free()
	assert_eq(starts, [GameFlow.GAME_SCENE], "RF-584: recarga la escena actual con la pantalla de carga")
	assert_eq(_swaps.size(), 1)


func test_the_loading_screen_leaves_dev_mode_alone() -> void:
	GameFlow.start_level(0)
	assert_true(DevMode.enabled, "RF-588: el modo de pruebas sigue como estaba")
	await _wait_done()
	assert_true(DevMode.enabled)
	assert_eq(GameFlow.current_index, 0)


func test_the_wiring_uses_the_menu_theme_and_the_minimum_time() -> void:
	assert_eq(_old_min, GameFlow.LOADING_MIN_SECONDS, "RF-581: el mínimo viene de una constante de interfaz")
	assert_eq(GameFlow.transition.ui_theme, GameFlow.LOADING_THEME)
	assert_eq(GameFlow.transition.title, "Cargando…")
