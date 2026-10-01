# Tests del panel de pruebas (T87, spec RF-184).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DEV_PATH: String = "user://test_save_pruebas.json"
const DT: float = 1.0 / 60.0

var game: Game


func _new_game() -> Game:
	var g: Game = GAME_SCENE.instantiate()
	add_child_autofree(g)
	return g


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	game = _new_game()


func after_each() -> void:
	DevMode.clear_stats_file()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	if FileAccess.file_exists(DEV_PATH):
		DirAccess.remove_absolute(DEV_PATH)


func _active_enemies() -> int:
	var count: int = 0
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			count += 1
	return count


func test_without_dev_mode_there_is_no_panel() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	var normal: Game = _new_game()
	assert_null(normal.dev_panel, "RF-180: el juego normal no lo tiene")


func test_dev_mode_game_has_the_panel_closed() -> void:
	assert_not_null(game.dev_panel)
	assert_false(game.dev_panel.visible, "empieza cerrado")
	game.dev_panel.toggle()
	assert_true(game.dev_panel.visible, "F1 o el botón lo abren")


func test_add_gold() -> void:
	var before: int = game.session.gold
	game.dev_add_gold()
	assert_eq(game.session.gold, before + DevMode.config.gold_step)


func test_infinite_lives() -> void:
	game.dev_set_infinite_lives(true)
	game.session.lose_lives(10)
	assert_eq(game.session.lives, 20, "no se pierden vidas")
	game.dev_set_infinite_lives(false)
	game.session.lose_lives(10)
	assert_eq(game.session.lives, 10)


func test_kill_all_gives_no_gold() -> void:
	game.dev_spawn(load("res://data/enemies/normal.tres"))
	game.dev_spawn(load("res://data/enemies/spider.tres"))
	var gold: int = game.session.gold
	game.dev_kill_all()
	assert_eq(_active_enemies(), 0)
	assert_eq(game.session.gold, gold, "matar con el panel no da oro")
	await wait_process_frames(2)
	assert_eq(game.enemies.get_child_count(), 0, "la Araña no soltó crías")


func test_skip_wave_completes_it() -> void:
	game.start_next_wave()
	simulate(game.spawner, 30, DT)  # ya salieron algunos
	game.dev_skip_wave()
	await wait_process_frames(2)
	assert_eq(game.session.wave, 1)
	assert_ne(game.session.state, LevelSession.State.WAVE_RUNNING, "la oleada 1 terminó")
	game.dev_skip_wave()  # sin oleada en curso: empieza la 2 y la termina
	await wait_process_frames(2)
	assert_eq(game.session.wave, 2)
	assert_ne(game.session.state, LevelSession.State.WAVE_RUNNING)


func test_win_and_lose() -> void:
	game.dev_finish(true)
	assert_eq(game.session.state, LevelSession.State.WON)
	var other: Game = _new_game()
	other.dev_finish(false)
	assert_eq(other.session.state, LevelSession.State.LOST)


func test_spawn_any_enemy() -> void:
	game.dev_spawn(load("res://data/enemies/troll.tres"))
	assert_eq(_active_enemies(), 1)
	assert_eq((game.enemies.get_child(0) as Enemy).data.id, &"troll")
