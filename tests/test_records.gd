# Tests de los récords de cada nivel (T89, spec RF-191 a RF-193, RF-196).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_save.json"


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


func _table(points: Array) -> Array:
	var table: Array = []
	for p: int in points:
		table.append({"name": "AAA", "points": p})
	return table


func _points(table: Array) -> Array:
	return table.map(func(entry: Dictionary) -> int: return entry["points"])


# --- Las cuentas (HighScores) ---

func test_higher_scores_go_first() -> void:
	var table: Array = _table([900, 500, 100])
	assert_eq(HighScores.insert(table, "BBB", 600), 1)
	assert_eq(_points(table), [900, 600, 500, 100])


func test_only_five_entries_are_kept() -> void:
	var table: Array = _table([900, 800, 700, 600, 500])
	assert_eq(HighScores.insert(table, "BBB", 650), 3)
	assert_eq(_points(table), [900, 800, 700, 650, 600], "el sexto (500) se descarta")


func test_a_tie_goes_below_the_older_entry() -> void:
	var table: Array = _table([900, 500])
	assert_eq(HighScores.insert(table, "NEW", 500), 2, "el que ya estaba queda arriba")


func test_what_does_not_qualify() -> void:
	assert_false(HighScores.qualifies([], 0), "con 0 puntos no se entra")
	var full: Array = _table([900, 800, 700, 600, 500])
	assert_false(HighScores.qualifies(full, 500), "empatar con el último no alcanza")
	assert_true(HighScores.qualifies(full, 501))
	assert_eq(HighScores.insert(full, "BBB", 100), -1)


func test_names_are_three_capital_letters() -> void:
	assert_eq(HighScores.clean_name("l.u-c9", 3), "LUC")
	assert_eq(HighScores.clean_name("ab", 3), "ABA", "se completa con A")
	assert_eq(HighScores.clean_name("lucas", 3), "LUC")


# --- Guardado ---

func test_scores_and_initials_survive_closing_the_game() -> void:
	SaveManager.add_score(&"level_02", "LUC", 1234)
	SaveManager.set_last_initials("LUC")
	SaveManager.save()
	SaveManager.load_save()
	assert_eq(SaveManager.scores(&"level_02"), [{"name": "LUC", "points": 1234}])
	assert_eq(SaveManager.last_initials(3), "LUC")
	assert_eq(SaveManager.last_initials(5), "AAAAA", "la primera vez")


func test_broken_scores_in_the_file_are_ignored() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "scores": {
		"level_01": [{"name": 5, "points": "x"}, {"name": "ok!", "points": 300}], "level_02": "roto"}}))
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.scores(&"level_01"), [{"name": "OKA", "points": 300}], "lo válido se conserva")
	assert_eq(SaveManager.scores(&"level_02"), [])


# --- En la partida ---

func _finished_game(won: bool, points: int) -> Game:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.add_score(points)
	game.session.lives = 0 if not won else game.session.lives
	game.session.finish(won)
	return game


func test_outside_the_campaign_nothing_is_recorded() -> void:
	var game: Game = _finished_game(false, 500)
	assert_false(game.end_screen.is_asking_name(), "RF-196: sin campaña no se piden letras")
	assert_false(FileAccess.file_exists(TEST_PATH), "ni se escribe nada")


func test_a_new_record_asks_for_initials_even_when_losing() -> void:
	GameFlow.current_index = 0
	var game: Game = _finished_game(false, 500)
	assert_true(game.end_screen.is_asking_name(), "RF-191: ganada o perdida")
	var entry: NameEntry = game.end_screen.name_entry()
	assert_eq(entry.get_name_text(), "AAA", "la primera vez")
	entry.change_letter(0, 11)  # A → L
	entry.confirm()
	assert_false(game.end_screen.is_asking_name())
	assert_eq(SaveManager.scores(&"level_01"), [{"name": "LAA", "points": 500}])
	SaveManager.load_save()
	assert_eq(SaveManager.scores(&"level_01").size(), 1, "quedó guardado en el archivo")


func test_no_record_shows_the_table_directly() -> void:
	GameFlow.current_index = 0
	for p: int in [900, 800, 700, 600, 500]:
		SaveManager.add_score(&"level_01", "AAA", p)
	var game: Game = _finished_game(false, 100)
	assert_false(game.end_screen.is_asking_name(), "100 no entra")


func test_name_entry_with_the_keyboard() -> void:
	var entry: NameEntry = NameEntry.new().setup(3, "AAA")
	add_child_autofree(entry)
	var names: Array[String] = []
	entry.confirmed.connect(func(n: String) -> void: names.append(n))
	for key: Key in [KEY_L, KEY_U, KEY_C]:
		entry._input(_key(key, 65 + key - KEY_A))
	entry._input(_key(KEY_UP))
	entry._input(_key(KEY_ENTER))
	assert_eq(names, ["LUD"] as Array[String], "L, U, C y ▲ en la última casilla: D")


func _key(keycode: Key, unicode: int = 0) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.unicode = unicode
	event.pressed = true
	return event
