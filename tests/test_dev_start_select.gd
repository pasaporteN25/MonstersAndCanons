# Tests de elegir la oleada y el oro al elegir nivel (T150, spec RF-319, RF-320, RF-321).
# Nunca se llama a GameFlow.start_level ni a nada que cambie de pantalla: las "costuras" son
# GameFlow.current_index / current_community (qué nivel viene del menú) y DevMode.start_*.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const BALANCE: BalanceConfig = preload("res://data/balance.tres")
const DEV_PATH: String = "user://test_save_pruebas.json"
const TEST_SAVE: String = "user://test_save_start.json"
const TEST_DIR: String = "user://test_dev_select/"


func before_each() -> void:
	_remove(DEV_PATH)
	_remove(TEST_SAVE)
	DevMode.set_enabled(true, DEV_PATH)
	DevMode.reset_start()
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()


func after_each() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = null
	DevMode.reset_start()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	_remove(DEV_PATH)
	_remove(TEST_SAVE)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## Un Game como si se hubiera llegado desde la selección (nivel 1 de la campaña).
func _game_from_menu(index: int = 0) -> Game:
	GameFlow.current_index = index
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _select() -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = TEST_DIR  # una carpeta vacía: no mira los mapas del jugador
	add_child_autofree(select)
	return select


# --- La franja ---

func test_the_strip_exists_only_in_dev_mode() -> void:
	var with_dev: Control = _select()
	assert_not_null(with_dev.dev_strip, "RF-319")
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	var normal: Control = _select()
	assert_null(normal.dev_strip, "el juego normal no la tiene")
	SaveManager.save_path = TEST_SAVE  # set_enabled(false) devolvió el guardado real


func test_strip_changes_what_game_will_use() -> void:
	var select: Control = _select()
	select._dev_wave.value = 6
	assert_eq(DevMode.start_wave, 6)
	assert_eq(DevMode.start_gold, -1, "automático por defecto")
	select._dev_auto.button_pressed = false
	select._dev_gold.value = 250
	assert_eq(DevMode.start_gold, 250, "a mano")
	select._dev_gold.value = 0
	assert_eq(DevMode.start_gold, 0, "RF-320: 0 es un valor válido")
	select._dev_auto.button_pressed = true
	assert_eq(DevMode.start_gold, -1, "de nuevo automático")


func test_the_wave_spinner_goes_up_to_the_longest_level() -> void:
	var select: Control = _select()
	var most: int = 1
	for i: int in GameFlow.level_count():
		most = maxi(most, GameFlow.level(i).waves.size())
	assert_eq(int(select._dev_wave.max_value), most)
	assert_eq(int(select._dev_wave.min_value), 1)


func test_opening_the_select_screen_starts_from_wave_1_again() -> void:
	DevMode.start_wave = 9
	DevMode.start_gold = 5
	_select()
	assert_eq(DevMode.start_wave, 1, "RF-321")
	assert_eq(DevMode.start_gold, -1)


# --- La partida ---

func test_game_starts_in_the_chosen_wave_with_automatic_gold() -> void:
	DevMode.start_wave = 6
	var game: Game = _game_from_menu()
	assert_eq(game.session.wave, 5, "lista para empezar la 6")
	assert_eq(game.session.gold, DevStart.start_gold(game.level_data, BALANCE, 6), "RF-320")
	assert_gt(game.session.gold, game.level_data.starting_gold)
	assert_eq(game.session.lives, game.level_data.starting_lives, "las vidas son las del nivel")
	assert_eq(game.tower_container.get_child_count(), 0, "sin torres")
	game.start_next_wave()
	assert_eq(game.session.wave, 6)


func test_game_uses_the_manual_gold() -> void:
	DevMode.start_wave = 3
	DevMode.start_gold = 0
	assert_eq(_game_from_menu().session.gold, 0, "RF-320")
	DevMode.start_gold = 777
	assert_eq(_game_from_menu().session.gold, 777)


func test_wave_1_is_the_game_as_always() -> void:
	var game: Game = _game_from_menu()
	assert_eq(game.session.wave, 0)
	assert_eq(game.session.gold, game.level_data.starting_gold)
	assert_false(GameFlow.dev_partial_run())


func test_a_wave_past_the_total_uses_the_last_one() -> void:
	DevMode.start_wave = 99
	var game: Game = _game_from_menu()
	assert_eq(game.session.wave, game.level_data.waves.size() - 1, "RF-319")
	assert_eq(DevMode.applied_wave, game.level_data.waves.size())


func test_a_community_map_uses_it_too() -> void:
	DevMode.start_wave = 4
	GameFlow.current_community = GameFlow.level(1)
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_eq(game.session.wave, 3)


func test_without_a_menu_level_nothing_is_applied() -> void:
	DevMode.start_wave = 6
	var game: Game = GAME_SCENE.instantiate()  # como F6 o un test: current_index = -1
	add_child_autofree(game)
	assert_eq(game.session.wave, 0)
	assert_eq(game.session.gold, game.level_data.starting_gold)
	assert_false(GameFlow.dev_partial_run())


func test_retrying_repeats_the_same_game() -> void:
	DevMode.start_wave = 6
	DevMode.start_gold = 321
	_game_from_menu()
	# restart() recarga la escena (y no se puede llamar en un test): lo que hace es abrir otro Game
	# con lo mismo que había, así que alcanza con que Game no haya borrado lo elegido.
	var again: Game = _game_from_menu()
	assert_eq(DevMode.start_wave, 6, "RF-321")
	assert_eq(again.session.wave, 5)
	assert_eq(again.session.gold, 321)


func test_forget_dev_start_goes_back_to_wave_1() -> void:
	DevMode.start_wave = 6
	DevMode.start_gold = 321
	_game_from_menu()
	GameFlow.forget_dev_start()  # lo que hacen "Siguiente nivel" y volver a la selección
	assert_eq(DevMode.start_wave, 1)
	assert_eq(DevMode.start_gold, -1)
	assert_false(GameFlow.dev_partial_run())
	assert_eq(_game_from_menu().session.wave, 0)


# --- Sin progreso (RF-321) ---

func test_a_partial_game_does_not_save_a_victory() -> void:
	DevMode.start_wave = 6
	var game: Game = _game_from_menu()
	assert_true(GameFlow.dev_partial_run())
	assert_null(GameFlow.played_level())
	game.dev_finish(true)
	assert_false(SaveManager.is_completed(game.level_data.id), "RF-321: no guarda la victoria")
	assert_eq(SaveManager.best_score(game.level_data.id), 0, "ni puntos")
	assert_false(SaveManager.is_unlocked(GameFlow.level(1).id), "ni desbloquea el siguiente")
	assert_eq(GameFlow.record_level_score("AAA", 999), -1, "ni récords")
	assert_false(GameFlow.level_score_qualifies(999))
	assert_false(GameFlow.hall_of_fame_pending())
	assert_true(game.end_screen._levels_button.visible, "pero se puede salir")


func test_a_whole_game_still_saves_a_victory() -> void:
	var game: Game = _game_from_menu()
	game.dev_finish(true)
	assert_true(SaveManager.is_completed(game.level_data.id), "con la oleada 1 se guarda como siempre")


func test_a_partial_game_does_not_save_seen_enemies() -> void:
	DevMode.start_wave = 6
	var game: Game = _game_from_menu()
	game.dev_spawn(load("res://data/enemies/troll.tres"))
	assert_false(FileAccess.file_exists(TEST_SAVE), "RF-321: no escribe el guardado")
	DevMode.reset_start()
	var whole: Game = _game_from_menu()
	whole.dev_spawn(load("res://data/enemies/spider.tres"))  # otro tipo: el Trol ya quedó visto en memoria
	assert_true(FileAccess.file_exists(TEST_SAVE), "una partida entera sí")
