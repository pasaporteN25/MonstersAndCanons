# Tests de jugar un mapa de la comunidad (T107, spec §10.4: RF-224, RF-225).
# OJO: nunca se llama a start_community() ni a ninguna función que cambie de pantalla: reemplazaría
# la escena de GUT. Se prepara `GameFlow.current_community` a mano.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
var TEST_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)

var level: LevelData
var id: StringName


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1
	level = LevelFile.parse(LevelDraft.new_level().to_text(), &"comunidad_mi_mapa")["level"]
	id = level.id
	GameFlow.current_community = level


func after_each() -> void:
	level = null
	GameFlow.current_community = null
	GameFlow.test_level = null
	GameFlow.current_index = -1
	GameFlow.select_page = &"campaign"
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


# --- Jugarlo ---

func test_the_game_plays_the_community_map() -> void:
	var game: Game = _play()
	assert_eq(game.level_data, level)
	assert_false(game.testing, "no es una prueba del editor")
	assert_eq(game.session.gold, level.starting_gold)


func test_played_level_is_the_campaign_or_the_community_map() -> void:
	assert_eq(GameFlow.played_level(), level)
	GameFlow.current_index = 3
	assert_eq(GameFlow.played_level(), GameFlow.level(3), "la campaña tiene prioridad")
	GameFlow.current_index = -1
	GameFlow.current_community = null
	assert_null(GameFlow.played_level(), "F6, tests o probando: no se guarda nada")


func test_the_campaign_wins_over_the_community_map_in_the_game() -> void:
	GameFlow.current_index = 1
	var game: Game = _play()
	assert_eq(game.level_data, GameFlow.level(1))


# --- Progreso propio (RF-224) ---

func test_winning_saves_its_own_progress() -> void:
	var game: Game = _play()
	game.session.lose_lives(3)  # quedan 17: 2 estrellas
	_win(game)
	assert_true(SaveManager.is_completed(id))
	assert_eq(SaveManager.best_lives(id), 17)
	assert_gt(SaveManager.best_score(id), 0)
	assert_eq(GameFlow.community_stars(level), 2)
	assert_true(FileAccess.file_exists(TEST_PATH), "se guardó a disco")
	assert_true(FileAccess.get_file_as_string(TEST_PATH).contains("comunidad_mi_mapa"))


func test_a_community_win_does_not_touch_the_campaign() -> void:
	var game: Game = _play()
	_win(game)
	for i: int in GameFlow.level_count():
		var campaign_id: StringName = GameFlow.level(i).id
		assert_false(SaveManager.is_completed(campaign_id), campaign_id)
		assert_eq(SaveManager.best_score(campaign_id), 0)
		if i > 0:
			assert_false(SaveManager.is_unlocked(campaign_id), "no desbloquea nada")
	assert_eq(GameFlow.total_stars(), 0, "no suma a las estrellas de la campaña")


func test_a_community_win_never_counts_for_the_hall_of_fame() -> void:
	# Con toda la campaña ganada, un mapa de la comunidad con un puntaje enorme no abre el Salón.
	for i: int in GameFlow.level_count():
		SaveManager.record_victory(GameFlow.level(i).id, 20, 100)
	var before: int = GameFlow.campaign_total()
	var game: Game = _play()
	_win(game)
	assert_false(GameFlow.hall_of_fame_pending(), "solo la campaña abre el Salón")
	assert_eq(GameFlow.campaign_total(), before, "el total de la campaña no cambia")
	assert_eq(GameFlow.hall_of_fame(), [])


func test_a_defeat_saves_no_victory() -> void:
	var game: Game = _play()
	game.session.lose_lives(100)
	assert_false(SaveManager.is_completed(id))
	assert_eq(GameFlow.community_stars(level), 0)


func test_two_community_maps_have_separate_progress() -> void:
	var other: LevelData = LevelFile.parse(LevelDraft.new_level().to_text(), &"comunidad_otro")["level"]
	SaveManager.record_victory(other.id, 20, 500)
	var game: Game = _play()
	game.session.lose_lives(10)
	_win(game)
	assert_eq(SaveManager.best_lives(id), 10)
	assert_eq(SaveManager.best_lives(other.id), 20, "el otro sigue como estaba")
	assert_eq(SaveManager.best_score(other.id), 500)


# --- Récords (RF-224) ---

func test_a_community_win_asks_for_initials_and_keeps_its_own_top_5() -> void:
	var game: Game = _play()
	_win(game)
	assert_true(game.end_screen.is_asking_name(), "entra en el top 5 de ese mapa")
	game.end_screen.name_entry().confirm()
	var scores: Array = SaveManager.scores(id)
	assert_eq(scores.size(), 1)
	assert_gt(scores[0]["points"], 0)
	assert_eq(SaveManager.scores(&"level_01"), [], "la tabla de la campaña sigue vacía")
	assert_eq(SaveManager.scores(SaveManager.HALL_OF_FAME_ID), [])


func test_the_records_of_two_maps_do_not_mix() -> void:
	SaveManager.add_score(&"comunidad_otro", "AAA", 99999)
	var game: Game = _play()
	_win(game)
	assert_true(game.end_screen.is_asking_name(), "el 99999 es de otro mapa: acá entra igual")


# --- Salir (RF-225) ---

func test_the_end_screen_goes_back_to_levels_and_has_no_next() -> void:
	var game: Game = _play()
	_win(game)
	game.end_screen.name_entry().confirm()
	var levels: Button = game.end_screen.get_node("%LevelsButton")
	assert_true(levels.visible)
	assert_eq(levels.text, "Niveles", "no es 'Volver al editor'")
	assert_false((game.end_screen.get_node("%NextButton") as Button).visible, "no hay siguiente")


func test_the_pause_menu_goes_to_the_main_menu() -> void:
	var game: Game = _play()
	assert_eq((game.pause_menu.get_node("%QuitButton") as Button).text, "Salir al menú")


func test_the_select_page_defaults_to_the_campaign() -> void:
	assert_eq(GameFlow.select_page, &"campaign")


# --- La campaña sigue igual ---

func test_the_campaign_still_saves_and_unlocks() -> void:
	GameFlow.current_community = null
	GameFlow.current_index = 0
	var game: Game = _play()
	_win(game)
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_true(SaveManager.is_unlocked(&"level_02"), "la campaña sí desbloquea")
