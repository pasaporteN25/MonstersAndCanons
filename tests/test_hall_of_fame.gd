# Tests del Salón de la fama (T90, spec RF-194, D-029).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
var TEST_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)


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


## Gana todos los niveles menos el último, cada uno con `points` puntos.
func _win_all_but_last(points: int) -> void:
	for i: int in GameFlow.level_count() - 1:
		SaveManager.record_victory(GameFlow.level(i).id, 20, points)


func _last_index() -> int:
	return GameFlow.level_count() - 1


func test_best_victory_score_is_kept() -> void:
	SaveManager.record_victory(&"level_01", 20, 900)
	SaveManager.record_victory(&"level_01", 20, 500)
	assert_eq(SaveManager.best_score(&"level_01"), 900, "se queda el mejor")
	SaveManager.save()
	SaveManager.load_save()
	assert_eq(SaveManager.best_score(&"level_01"), 900, "y se guarda")


func test_the_hall_needs_every_level_won() -> void:
	GameFlow.current_index = _last_index()
	_win_all_but_last(1000)
	assert_false(GameFlow.campaign_complete())
	assert_false(GameFlow.hall_of_fame_pending(), "falta ganar el último")
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 1000)
	assert_true(GameFlow.campaign_complete())
	assert_true(GameFlow.hall_of_fame_pending())


func test_campaign_total_is_the_sum_of_the_best_scores() -> void:
	_win_all_but_last(1000)
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 2500)
	assert_eq(GameFlow.campaign_total(), 1000 * (GameFlow.level_count() - 1) + 2500)


func test_only_asked_again_when_the_total_goes_up() -> void:
	GameFlow.current_index = _last_index()
	_win_all_but_last(1000)
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 1000)
	assert_eq(GameFlow.record_hall_of_fame("LUCAS"), 0)
	assert_false(GameFlow.hall_of_fame_pending(), "el mismo total no se anota dos veces")
	SaveManager.record_victory(&"level_01", 20, 800)  # peor que su récord: el total no cambia
	assert_false(GameFlow.hall_of_fame_pending())
	SaveManager.record_victory(&"level_01", 20, 1500)  # mejoró un nivel: el total sube
	assert_true(GameFlow.hall_of_fame_pending())


func test_hall_entries_have_five_letters_and_are_saved() -> void:
	GameFlow.current_index = _last_index()
	_win_all_but_last(1000)
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 1000)
	GameFlow.record_hall_of_fame("LUCAS")
	SaveManager.load_save()
	assert_eq(GameFlow.hall_of_fame(), [{"name": "LUCAS", "points": GameFlow.campaign_total()}])
	assert_eq(SaveManager.last_initials(5), "LUCAS")


func test_outside_the_campaign_there_is_no_hall() -> void:
	_win_all_but_last(1000)
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 1000)
	assert_false(GameFlow.hall_of_fame_pending(), "RF-196")


# --- En la partida ---

func _win_last_level(points: int) -> Game:
	GameFlow.current_index = _last_index()
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.add_score(points)
	game.session.finish(true)
	return game


func test_winning_the_last_level_opens_the_hall_after_the_level_record() -> void:
	_win_all_but_last(1000)
	var game: Game = _win_last_level(500)
	assert_true(game.end_screen.is_asking_name(), "primero, el récord del nivel (3 letras)")
	assert_null(game.hall_of_fame)
	game.end_screen.name_entry().confirm()
	assert_not_null(game.hall_of_fame, "después, el Salón de la fama")
	assert_true(game.hall_of_fame.is_asking_name())
	var entry: NameEntry = game.hall_of_fame.name_entry()
	assert_eq(entry.get_name_text().length(), 5, "5 letras")
	entry.confirm()
	assert_eq(GameFlow.hall_of_fame().size(), 1)
	assert_eq(int(GameFlow.hall_of_fame()[0]["points"]), GameFlow.campaign_total())


func test_losing_never_opens_the_hall() -> void:
	_win_all_but_last(1000)
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 20, 1000)
	GameFlow.current_index = _last_index()
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.add_score(9999)
	game.session.finish(false)
	if game.end_screen.is_asking_name():
		game.end_screen.name_entry().confirm()
	assert_null(game.hall_of_fame, "el total solo cambia con victorias")
