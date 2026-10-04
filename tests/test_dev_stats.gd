# Tests de las estadísticas de la partida de pruebas (T153, spec RF-325).
# El archivo se escribe en una ruta de prueba (user://test_*), nunca en el informe del jugador.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const BALANCE: BalanceConfig = preload("res://data/balance.tres")
const DEV_PATH: String = "user://test_save_pruebas.json"
const OUT_PATH: String = "user://test_dev_stats_out.json"
const KEYS: Array[String] = ["level", "start_wave", "wave", "total_waves", "lives", "gold", "towers",
	"result", "waves", "seconds", "started_at"]


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	DevMode.clear_stats_file()
	DevMode.reset_start()
	_remove(OUT_PATH)


func after_each() -> void:
	GameFlow.current_index = -1
	DevMode.reset_start()
	DevMode.clear_stats_file()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	_remove(DEV_PATH)
	_remove(OUT_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _new_game() -> Game:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


## Lee el informe como lo haría cualquier herramienta (JSON.new().parse, sin imprimir errores del motor).
func _read_stats() -> Dictionary:
	assert_true(FileAccess.file_exists(DevMode.stats_path), "el informe existe: %s" % DevMode.stats_path)
	var json := JSON.new()
	var text: String = FileAccess.get_file_as_string(DevMode.stats_path)
	assert_eq(json.parse(text), OK, "es JSON válido")
	return json.data


# --- DevStats, sin escenas ---

func test_the_report_has_the_documented_names() -> void:
	var stats := DevStats.new()
	stats.begin("level_01", 1)
	stats.record_wave(1, 20, 65, 3)
	var report: Dictionary = stats.to_dict(DevStats.RESULT_WON, 10, 10, 17, 40, 4)
	for key: String in KEYS:
		assert_true(report.has(key), "RF-325: %s" % key)
	assert_eq(report.size(), KEYS.size(), "y no hay otros")
	assert_eq(report["level"], "level_01")
	assert_eq(report["result"], "won")
	assert_eq(report["lives"], 17)
	assert_eq(report["gold"], 40)
	assert_eq(report["towers"], 4)
	assert_eq(report["waves"], [{"wave": 1, "lives": 20, "gold": 65, "towers": 3}], "las mismas cifras que la línea del bot")


func test_the_three_results() -> void:
	var stats := DevStats.new()
	assert_eq(stats.to_dict(DevStats.RESULT_WON, 1, 1, 1, 1, 1)["result"], "won")
	assert_eq(stats.to_dict(DevStats.RESULT_LOST, 1, 1, 1, 1, 1)["result"], "lost")
	assert_eq(stats.to_dict(DevStats.RESULT_LEFT, 1, 1, 1, 1, 1)["result"], "left")


func test_an_empty_report_has_no_wave_rows() -> void:
	var stats := DevStats.new()
	stats.begin("x", 1)
	assert_eq(stats.to_dict(DevStats.RESULT_LEFT, 0, 10, 20, 150, 0)["waves"], [], "salir antes de terminar la primera")


func test_seconds_are_rounded_to_a_tenth() -> void:
	var stats := DevStats.new()
	stats.seconds = 12.3456
	assert_eq(stats.to_dict("won", 1, 1, 1, 1, 1)["seconds"], 12.3)


func test_the_report_does_not_change_after_it_is_made() -> void:
	var stats := DevStats.new()
	stats.record_wave(1, 20, 1, 1)
	var report: Dictionary = stats.to_dict("left", 1, 2, 20, 1, 1)
	stats.record_wave(2, 19, 2, 2)
	assert_eq(report["waves"].size(), 1)


func test_write_replaces_the_file_and_reads_back() -> void:
	assert_true(DevStats.write({"a": 1, "b": [1, 2]}, OUT_PATH))
	assert_true(DevStats.write({"a": 2}, OUT_PATH))
	var json := JSON.new()
	assert_eq(json.parse(FileAccess.get_file_as_string(OUT_PATH)), OK)
	assert_eq(json.data, {"a": 2.0}, "reemplaza, no suma (los enteros de JSON vuelven como float)")


func test_write_to_an_impossible_path_returns_false() -> void:
	assert_false(DevStats.write({}, "user://no_existe_esta_carpeta/x.json"))


# --- Dónde se escribe ---

func test_a_test_save_has_its_own_stats_file() -> void:
	assert_eq(DevMode.stats_path, "user://test_save_pruebas_stats.json", "no pisa el informe del jugador")
	DevMode.set_enabled(true)  # el modo real
	assert_eq(DevMode.stats_path, "user://pruebas_stats.json", "RF-325")
	DevMode.set_enabled(true, DEV_PATH)


# --- La partida ---

func test_finishing_a_won_game_writes_the_report() -> void:
	var game: Game = _new_game()
	game.dev_finish(true)
	var report: Dictionary = _read_stats()
	assert_eq(report["result"], "won")
	assert_eq(report["level"], String(game.level_data.id))
	assert_eq(int(report["total_waves"]), game.level_data.waves.size())
	assert_eq(int(report["start_wave"]), 1)
	assert_eq(int(report["lives"]), game.session.lives)
	assert_eq(int(report["gold"]), game.session.gold)
	assert_eq(report["waves"], [], "no terminó ninguna oleada")


func test_a_lost_game() -> void:
	var game: Game = _new_game()
	game.dev_finish(false)
	assert_eq(_read_stats()["result"], "lost")


func test_leaving_before_the_end_says_left() -> void:
	var game: Game = _new_game()
	game.dev_skip_wave()
	await wait_process_frames(2)
	remove_child(game)  # lo que pasa al salir de la partida (_exit_tree)
	game.free()
	var report: Dictionary = _read_stats()
	assert_eq(report["result"], "left", "RF-325")
	assert_eq(int(report["wave"]), 1)
	assert_eq(report["waves"].size(), 1)


func test_leaving_after_the_end_does_not_overwrite_the_result() -> void:
	var game: Game = _new_game()
	game.dev_finish(true)
	remove_child(game)
	game.free()
	assert_eq(_read_stats()["result"], "won")


func test_one_row_per_finished_wave_with_the_numbers_of_that_moment() -> void:
	var game: Game = _new_game()
	var basic: TowerData = load("res://data/towers/basic.tres")
	assert_true(game.build_controller.try_build(basic, Vector2i(0, 0)))
	var expected_gold: int = game.session.gold + Rules.wave_bonus(1, BALANCE)  # saltar no da recompensas
	game.dev_skip_wave()
	await wait_process_frames(2)
	game.dev_finish(true)
	var rows: Array = _read_stats()["waves"]
	assert_eq(rows.size(), 1)
	assert_eq(int(rows[0]["wave"]), 1)
	assert_eq(int(rows[0]["lives"]), game.level_data.starting_lives)
	assert_eq(int(rows[0]["gold"]), expected_gold, "con el bono de la oleada, como el bot")
	assert_eq(int(rows[0]["towers"]), 1)
	assert_eq(int(_read_stats()["towers"]), 1)


func test_a_game_from_wave_6_records_it() -> void:
	DevMode.start_wave = 6
	GameFlow.current_index = 0
	var game: Game = _new_game()
	var gold: int = game.session.gold
	game.dev_skip_wave()
	await wait_process_frames(2)
	game.dev_finish(false)
	var report: Dictionary = _read_stats()
	assert_eq(int(report["start_wave"]), 6)
	assert_eq(report["waves"].size(), 1)
	assert_eq(int(report["waves"][0]["wave"]), 6)
	assert_eq(int(report["waves"][0]["gold"]), gold + Rules.wave_bonus(6, BALANCE))


func test_each_game_replaces_the_report() -> void:
	var first: Game = _new_game()
	first.dev_skip_wave()
	await wait_process_frames(2)
	first.dev_finish(true)
	var second: Game = _new_game()
	second.dev_finish(false)
	var report: Dictionary = _read_stats()
	assert_eq(report["result"], "lost", "RF-325: no se acumulan")
	assert_eq(report["waves"], [])


func test_seconds_count_game_time_and_not_the_pause() -> void:
	var game: Game = _new_game()
	for i: int in 60:
		game._process(1.0 / 60.0)
	assert_almost_eq(game.dev_stats.seconds, 1.0, 0.01)
	game.set_paused(true)
	for i: int in 60:
		game._process(1.0 / 60.0)
	assert_almost_eq(game.dev_stats.seconds, 1.0, 0.01, "en pausa no cuenta")
	game.set_paused(false)
	game.dev_finish(true)
	game._process(5.0)
	assert_almost_eq(game.dev_stats.seconds, 1.0, 0.01, "terminada tampoco")
	assert_almost_eq(float(_read_stats()["seconds"]), 1.0, 0.1)


func test_the_normal_game_writes_nothing() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	DevMode.stats_path = OUT_PATH  # si escribiera algo, caería acá y no en el informe del jugador
	var normal: Game = _new_game()
	assert_null(normal.dev_stats)
	normal.session.finish(true)
	remove_child(normal)
	normal.free()
	assert_false(FileAccess.file_exists(OUT_PATH), "RF-325: el juego normal no escribe el informe")
	DevMode.set_enabled(true, DEV_PATH)


func test_a_game_freed_after_the_mode_was_turned_off_writes_nothing() -> void:
	var game: Game = _new_game()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	DevMode.stats_path = OUT_PATH
	remove_child(game)
	game.free()
	assert_false(FileAccess.file_exists(OUT_PATH), "sin modo de pruebas no hay informe")
	DevMode.set_enabled(true, DEV_PATH)
