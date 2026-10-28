# La presentación de los jefes con la escena real de la partida (T461, M66: RF-666 a RF-673). No cambia de escena
# y no toca el guardado real: usa `user://test_boss_presentation.json`.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_boss_presentation.json"

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1
	GameFlow.intro_pending = false


func after_each() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	DevMode.enabled = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _play(level_index: int = 0) -> Game:
	GameFlow.current_index = level_index
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _boss() -> EnemyData:
	return load("res://data/enemies/boss.tres")


func _spawn_boss() -> void:
	game.spawner.spawn_now(_boss())


func _key(code: Key, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	return event


func _click(pressed: bool = true) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


func _touch() -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	return event


## Pasa el tiempo real de la presentación y deja que `_process` la cierre.
func _elapse(seconds: float) -> void:
	if game.presentation != null:
		game.presentation.advance_clock_for_test(seconds)
	await get_tree().process_frame


func _open_and_skip(event: InputEvent) -> void:
	_spawn_boss()
	game.presentation.advance_clock_for_test(0.5)
	game.presentation._input(event)
	await _elapse(0.2)
	await get_tree().process_frame


# --- RF-666 y RF-667: cuándo sale, y la pausa desde el nacimiento ---

func test_the_boss_pauses_the_game_in_the_same_frame_it_is_born() -> void:
	_play()
	assert_false(game.is_paused())
	_spawn_boss()
	assert_true(game.is_paused(), "pausada en el mismo cuadro")
	assert_not_null(game.presentation)
	assert_eq(game.enemies.get_child_count(), 1, "el jefe nació igual, sin demora")
	assert_true(game.hud.is_presentation_active())
	assert_eq(game.presentation.process_mode, Node.PROCESS_MODE_ALWAYS)
	assert_eq(game.presentation.layer, BossPresentation.LAYER_ABOVE_DIALOGS)
	assert_eq(game.build_controller.input_blocked, true)


func test_a_normal_enemy_does_not_open_it() -> void:
	_play()
	game.spawner.spawn_now(load("res://data/enemies/normal.tres"))
	assert_null(game.presentation)
	assert_false(game.is_paused())


func test_it_shows_once_per_game_even_with_more_bosses() -> void:
	_play()
	_spawn_boss()
	game.presentation.advance_clock_for_test(10.0)
	await get_tree().process_frame
	assert_null(game.presentation)
	_spawn_boss()
	assert_null(game.presentation, "una sola por partida")
	assert_false(game.is_paused())
	game.free()
	_play()
	_spawn_boss()
	assert_not_null(game.presentation, "reintentar es otra partida")


func test_the_colossus_is_presented_too() -> void:
	_play()
	game.spawner.spawn_now(load("res://data/enemies/colossus.tres"))
	assert_not_null(game.presentation)


## T548: Game le pasa el fondo solo al Coloso; el Jefe sigue con la composición provisional.
func test_game_gives_the_backdrop_only_to_the_colossus() -> void:
	_play()
	game.spawner.spawn_now(load("res://data/enemies/colossus.tres"))
	assert_not_null(game.presentation.find_child("BackdropArt", true, false))
	game.free()
	_play()
	_spawn_boss()
	assert_null(game.presentation.find_child("BackdropArt", true, false))


# --- RF-666: dónde NO sale ---

func test_it_does_not_open_with_the_option_off() -> void:
	_play()
	SaveManager.set_setting("boss_entrance", false)
	_spawn_boss()
	assert_null(game.presentation)
	assert_false(game.is_paused())
	assert_true(SaveManager.has_seen_enemy(&"boss"), "igual queda como visto")


func test_it_does_not_open_in_a_loose_scene() -> void:
	game = GAME_SCENE.instantiate()  # sin campaña: F6, los tests y `balance_sim`
	add_child_autofree(game)
	_spawn_boss()
	assert_null(game.presentation)
	assert_false(game.is_paused())


func test_it_does_not_open_in_test_mode_or_the_editor_test() -> void:
	_play()
	DevMode.enabled = true
	_spawn_boss()
	assert_null(game.presentation, "modo de pruebas")
	DevMode.enabled = false
	game.testing = true
	_spawn_boss()
	assert_null(game.presentation, "probando desde el editor")


func test_it_does_not_open_in_a_siege_mode_or_a_community_map() -> void:
	_play()
	GameFlow.current_mode = {"official": true}
	_spawn_boss()
	assert_null(game.presentation, "Asedio u otro modo")
	GameFlow.current_mode = {}
	GameFlow.current_community = GameFlow.level(0)
	_spawn_boss()
	assert_null(game.presentation, "mapa de la comunidad")


func test_a_tutorial_level_one_still_counts_as_normal_campaign() -> void:
	_play(0)
	assert_true(game._is_normal_campaign())


# --- RF-668: 5 s la primera vez, 3 s después; el visto se conserva ---

func test_it_lasts_five_seconds_for_a_boss_never_seen_and_marks_it_seen() -> void:
	_play()
	_spawn_boss()
	assert_eq(game.presentation._seconds, 5.0)
	assert_true(SaveManager.has_seen_enemy(&"boss"), "queda registrado")
	game.presentation.advance_clock_for_test(4.9)
	await get_tree().process_frame
	assert_not_null(game.presentation, "a los 4,9 s sigue")
	game.presentation.advance_clock_for_test(0.2)
	await get_tree().process_frame
	assert_null(game.presentation, "a los 5 s se cierra")
	assert_false(game.is_paused(), "y la partida sigue")


func test_it_lasts_three_seconds_when_the_save_already_saw_it() -> void:
	SaveManager.mark_enemy_seen(&"boss")
	_play()
	_spawn_boss()
	assert_eq(game.presentation._seconds, 3.0)
	game.presentation.advance_clock_for_test(3.1)
	await get_tree().process_frame
	assert_null(game.presentation)


func test_skipping_keeps_the_boss_as_seen() -> void:
	_play()
	await _open_and_skip(_key(KEY_SPACE))
	assert_null(game.presentation)
	assert_true(SaveManager.has_seen_enemy(&"boss"))


func test_double_speed_does_not_shorten_it() -> void:
	_play()
	game.set_speed(2.0)
	_spawn_boss()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_not_null(game.presentation, "mide tiempo real, no el de la partida")
	assert_true(game.is_paused())


# --- RF-669: salteo ---

func test_input_in_the_first_0_3_seconds_is_swallowed_and_does_not_skip() -> void:
	_play()
	_spawn_boss()
	game.presentation._input(_key(KEY_SPACE))
	game.presentation._input(_click())
	game.presentation._input(_touch())
	await get_tree().process_frame
	assert_not_null(game.presentation)
	assert_false(game.presentation.is_closing())
	assert_true(game.is_paused())


func test_a_key_a_click_or_a_touch_skip_after_0_3_seconds_and_resume() -> void:
	for event: InputEvent in [_key(KEY_SPACE), _click(), _touch()]:
		_play()
		await _open_and_skip(event)
		assert_null(game.presentation, "%s cierra" % event.as_text())
		assert_false(game.is_paused(), "y reanuda")
		assert_false(game.hud.is_presentation_active())
		assert_false(game.build_controller.input_blocked)
		game.free()


func test_a_key_release_or_an_echo_do_not_skip() -> void:
	_play()
	_spawn_boss()
	game.presentation.advance_clock_for_test(1.0)
	game.presentation._input(_key(KEY_SPACE, false))
	game.presentation._input(_click(false))
	var echo: InputEventKey = _key(KEY_SPACE)
	echo.echo = true
	game.presentation._input(echo)
	assert_false(game.presentation.is_closing())


func test_p_skips_and_leaves_the_game_paused_without_opening_the_pause_menu() -> void:
	_play()
	await _open_and_skip(_key(KEY_P))
	assert_null(game.presentation)
	assert_true(game.is_paused(), "P deja la pausa")
	assert_false(game.pause_menu.is_open())
	game.toggle_pause()
	assert_false(game.is_paused(), "se sigue con el botón de siempre")


func test_escape_closes_without_resuming_and_without_the_pause_menu() -> void:
	_play()
	await _open_and_skip(_key(KEY_ESCAPE))
	assert_null(game.presentation)
	assert_true(game.is_paused(), "Atrás no reanuda por accidente")
	assert_false(game.pause_menu.is_open())


func test_it_closes_by_time_while_the_tree_is_paused() -> void:
	_play()
	_spawn_boss()
	assert_true(get_tree().paused)
	game.presentation.advance_clock_for_test(5.5)
	await get_tree().process_frame
	assert_null(game.presentation, "su `_process` corre con la partida pausada")


# --- RF-667 y RF-673: continuidad ---

func test_it_does_not_resume_a_game_that_was_paused_before() -> void:
	_play()
	game.set_paused(true)
	_spawn_boss()
	game.presentation.advance_clock_for_test(6.0)
	await get_tree().process_frame
	assert_null(game.presentation)
	assert_true(game.is_paused(), "estaba en pausa antes")


func test_going_to_the_background_during_it_keeps_the_pause_when_it_closes() -> void:
	_play()
	_spawn_boss()
	game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_true(game.is_paused())
	game.presentation.advance_clock_for_test(6.0)
	await get_tree().process_frame
	assert_null(game.presentation)
	assert_true(game.is_paused(), "sigue pausada hasta una acción explícita (D-112)")
	game.toggle_pause()
	assert_false(game.is_paused())


func test_the_game_world_does_not_advance_while_it_is_open() -> void:
	_play()
	_spawn_boss()
	var boss: Enemy = game.enemies.get_child(0) as Enemy
	var before: Vector2 = boss.global_position
	await get_tree().create_timer(0.3, true, false, true).timeout
	assert_eq(boss.global_position, before, "el jefe espera en la entrada")


# --- RF-670 y RF-134: el HUD ---

func test_the_boss_gets_no_new_enemy_card_and_other_cards_wait_for_the_close() -> void:
	_play()
	_spawn_boss()
	var card: Control = game.hud.get_node("%EnemyIntro")
	assert_false(card.visible, "el jefe no lleva «Nuevo enemigo»")
	game.spawner.spawn_now(load("res://data/enemies/normal.tres"))
	assert_false(card.visible, "la novedad espera")
	game.presentation.advance_clock_for_test(6.0)
	await get_tree().process_frame
	assert_true(card.visible, "al cerrarse, sale en su turno")


func test_the_wave_banner_tweens_freeze_during_it_and_continue_after() -> void:
	_play()
	game.hud._show_wave_banner(1)
	var banner: Tween = game.hud._tweens.back()
	assert_true(banner.is_running())
	_spawn_boss()
	assert_false(banner.is_running(), "congelado")
	game.presentation.advance_clock_for_test(6.0)
	await get_tree().process_frame
	assert_true(banner.is_running() or not banner.is_valid(), "continúa")


# --- Composición provisional ---

func test_the_provisional_composition_shows_the_title_name_and_line() -> void:
	_play()
	_spawn_boss()
	var root: Node = game.presentation
	assert_eq((root.find_child("Title", true, false) as Label).text, "¡Llega el Jefe!")
	assert_eq((root.find_child("Name", true, false) as Label).text, "Jefe")
	assert_eq((root.find_child("Line", true, false) as Label).text, _boss().description)
	assert_not_null((root.find_child("Illustration", true, false) as TextureRect).texture)
	assert_null(root.find_child("BackdropArt", true, false), "sin fondo propio hasta que haya arte aprobado")
