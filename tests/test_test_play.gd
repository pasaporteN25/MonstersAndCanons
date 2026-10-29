# Tests de jugar el nivel del editor (T104, spec §10.3: RF-217).
# OJO: nunca se llama a play_test(), go_to_editor() ni a nada que cambie de pantalla:
# reemplazaría la escena de GUT.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
var TEST_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)

var level: LevelData


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1
	level = LevelDraft.new_level().check()["level"]
	GameFlow.test_level = level


func after_each() -> void:
	level = null
	GameFlow.test_level = null
	GameFlow.current_index = -1
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _play() -> Game:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _win(game: Game) -> void:
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()


func test_the_game_plays_the_editor_level() -> void:
	var game: Game = _play()
	assert_true(game.testing)
	assert_eq(game.level_data, level)
	assert_eq(game.session.gold, level.starting_gold)
	assert_eq(game.session.lives, level.starting_lives)
	assert_eq(game.session.total_waves, 1)


func test_a_normal_game_is_not_testing() -> void:
	GameFlow.test_level = null
	var game: Game = _play()
	assert_false(game.testing)
	assert_eq(game.level_data, GameFlow.level(0), "sin campaña ni prueba, el primer nivel")
	assert_eq((game.end_screen.get_node("%LevelsButton") as Button).text, "Niveles")
	assert_eq((game.pause_menu.get_node("%QuitButton") as Button).text, "Salir al menú")


func test_the_campaign_wins_over_a_test_level() -> void:
	GameFlow.current_index = 2
	var game: Game = _play()
	assert_false(game.testing)
	assert_eq(game.level_data, GameFlow.level(2))


func test_victory_offers_to_go_back_to_the_editor() -> void:
	var game: Game = _play()
	_win(game)
	var back: Button = game.end_screen.get_node("%LevelsButton")
	assert_true(back.visible)
	assert_eq(back.text, "Volver al editor")
	assert_false((game.end_screen.get_node("%NextButton") as Button).visible, "no hay nivel siguiente")


func test_defeat_offers_to_go_back_to_the_editor() -> void:
	var game: Game = _play()
	game.session.lose_lives(100)
	var back: Button = game.end_screen.get_node("%LevelsButton")
	assert_true(back.visible)
	assert_eq(back.text, "Volver al editor")


func test_the_pause_menu_goes_back_to_the_editor() -> void:
	var game: Game = _play()
	assert_eq((game.pause_menu.get_node("%QuitButton") as Button).text, "Volver al editor")


func test_a_test_game_saves_nothing() -> void:
	var game: Game = _play()
	_win(game)
	assert_false(SaveManager.is_completed(level.id), "no cuenta como nivel ganado")
	assert_eq(SaveManager.best_score(level.id), 0)
	assert_eq(SaveManager.scores(level.id), [], "sin récords")
	assert_false(FileAccess.file_exists(TEST_PATH), "no se escribió ningún guardado")


func test_a_test_victory_does_not_ask_for_initials() -> void:
	var game: Game = _play()
	_win(game)
	assert_false(game.end_screen.is_asking_name(), "los récords son solo de la campaña (RF-196)")


func test_a_test_game_does_not_unlock_or_touch_the_campaign() -> void:
	var game: Game = _play()
	_win(game)
	for i: int in range(1, GameFlow.level_count()):
		assert_false(SaveManager.is_unlocked(GameFlow.level(i).id), "nivel %d sigue bloqueado" % (i + 1))
