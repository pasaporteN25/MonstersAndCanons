# Tests de menús y campaña (T41, T42, RF-110 a RF-112).
# OJO: nunca se llaman funciones que cambian de pantalla (start_level, go_to_...):
# reemplazarían la escena de GUT y cortarían los tests.
extends GutTest

const TEST_PATH: String = "user://test_save.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1


func after_each() -> void:
	GameFlow.current_index = -1
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


# --- Campaña y desbloqueo (RF-112) ---

func test_campaign_starts_with_level_01() -> void:
	assert_gt(GameFlow.level_count(), 0)
	assert_eq(GameFlow.level(0).id, &"level_01")


func test_only_the_first_level_is_unlocked_at_start() -> void:
	assert_true(GameFlow.is_level_unlocked(0))
	for i: int in range(1, GameFlow.level_count()):
		assert_false(GameFlow.is_level_unlocked(i), "nivel %d bloqueado" % (i + 1))


func test_winning_unlocks_the_next_level_and_saves() -> void:
	GameFlow.current_index = 0
	GameFlow.level_won(15)
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_eq(SaveManager.best_lives(&"level_01"), 15)
	if GameFlow.level_count() > 1:
		assert_true(GameFlow.is_level_unlocked(1), "RF-112")
	assert_true(FileAccess.file_exists(TEST_PATH), "se guardó en disco")


func test_winning_outside_the_campaign_saves_nothing() -> void:
	GameFlow.current_index = -1
	GameFlow.level_won(15)
	assert_false(SaveManager.is_completed(&"level_01"))
	assert_false(FileAccess.file_exists(TEST_PATH))


# --- La partida usa el nivel de la campaña ---

func test_game_plays_the_campaign_level() -> void:
	GameFlow.current_index = 0
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_eq(game.level_data, GameFlow.level(0))


func test_victory_in_campaign_shows_levels_button_and_saves() -> void:
	GameFlow.current_index = 0
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()
	assert_true((game.end_screen.get_node("%LevelsButton") as Button).visible)
	assert_eq((game.end_screen.get_node("%NextButton") as Button).visible, GameFlow.level_count() > 1)
	assert_true(SaveManager.is_completed(&"level_01"))


func test_victory_outside_campaign_hides_menu_buttons() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.lose_lives(100)
	assert_false((game.end_screen.get_node("%LevelsButton") as Button).visible)
	assert_false((game.end_screen.get_node("%NextButton") as Button).visible)


# --- Pantallas (RF-110, RF-111) ---

func test_main_menu_has_its_buttons() -> void:
	var menu: Control = (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	add_child_autofree(menu)
	for button_name: String in ["PlayButton", "OptionsButton", "QuitButton"]:
		assert_not_null(menu.get_node_or_null("%" + button_name), button_name)


func test_level_select_shows_one_card_per_level() -> void:
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	var cards: HBoxContainer = select.get_node("%Cards")
	assert_eq(cards.get_child_count(), GameFlow.level_count())
	assert_false((cards.get_child(0) as Button).disabled, "el nivel 1 se puede elegir")
	assert_eq(select.status_text(0), "¡Jugar!")


func test_level_select_shows_best_result() -> void:
	SaveManager.record_victory(&"level_01", 17)
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	assert_eq(select.status_text(0), "Completado · mejor: 17 vidas", "RF-111")
