# Tests de jugar un mapa de un modo (M49, RF-389 a RF-391): la partida usa las reglas del modo y guarda
# su progreso aparte. OJO: nunca se llama a start_mode_level() ni a nada que cambie de pantalla
# (reemplazaría la escena de GUT): se prepara `GameFlow.current_mode` a mano.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"

var siege: Dictionary


func before_each() -> void:
	for path: String in [TEST_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	DevMode.set_enabled(false, TEST_PATH)
	GameFlow.current_index = -1
	GameFlow.current_community = null
	siege = ModePacks.read(ModePacks.OFFICIAL_DIR, "asedio", true)
	GameFlow.current_mode = siege
	GameFlow.current_mode_index = 0


func after_each() -> void:
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.current_index = -1
	GameFlow.select_page = &"campaign"
	DevMode.set_enabled(false, TEST_PATH)
	for path: String in [TEST_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
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


# --- La partida (RF-389, RF-391) ---

func test_the_game_plays_the_mode_map_with_its_rules() -> void:
	var game: Game = _play()
	var level: LevelData = ModePacks.map_level(siege, 0)
	assert_eq(game.level_data, level)
	assert_eq(game.session.gold, level.starting_gold, "el oro del modo")
	assert_eq(game.spawner._health_percent, level.enemy_health_percent, "la vida del modo llega al generador")
	assert_false(game.testing)


func test_monsters_come_out_with_the_mode_health() -> void:
	var game: Game = _play()
	game.spawner.spawn_now(preload("res://data/enemies/normal.tres"))
	var enemy: Enemy = game.enemies.get_child(game.enemies.get_child_count() - 1)
	var normal: EnemyData = preload("res://data/enemies/normal.tres")
	assert_gt(game.level_data.enemy_health_percent, 100)
	assert_eq(enemy.max_health, Rules.percent_of(Rules.scaled_health_percent(normal.max_health, 0,
		game.level_data.health_scale_percent(game.balance)), game.level_data.enemy_health_percent),
		"RF-391: la vida del monstruo con el % del modo")


func test_the_per_map_health_of_the_mode_reaches_the_spawner() -> void:
	# RF-492: el mapa 4 toma el 115 % global y el 10 su 118 %: llegan al generador por el mismo camino.
	for case: Array in [[3, 115], [9, 118], [5, 101]]:
		GameFlow.current_mode_index = case[0]
		var game: Game = _play()
		assert_eq(game.spawner._health_percent, case[1], "mapa %d" % (case[0] + 1))
		game.queue_free()
		await get_tree().process_frame


func test_winning_map_9_of_asedio_does_not_open_map_10() -> void:
	# RF-692: ganar un Asedio registra la victoria pero no abre el siguiente; lo abre la campaña 10.
	GameFlow.current_mode_index = 8
	var game: Game = _play()
	_win(game)
	assert_true(SaveManager.is_completed(ModePacks.map_level(siege, 8).id))
	assert_false(GameFlow.is_mode_level_unlocked(siege, 9), "el 10 sigue cerrado")
	assert_false(GameFlow.has_next_level())
	SaveManager.record_victory(GameFlow.level(9).id, 5)
	assert_true(GameFlow.is_mode_level_unlocked(siege, 9), "se abre al ganar la campaña 10")
	assert_true(GameFlow.has_next_level())


func test_the_campaign_wins_over_the_mode_in_the_game() -> void:
	GameFlow.current_index = 1
	var game: Game = _play()
	assert_eq(game.level_data, GameFlow.level(1))


func test_a_mode_map_never_offers_a_collectible() -> void:
	var game: Game = _play()
	assert_null(game.collectible, "RF-390: la colección de avances es solo de la campaña")


# --- Progreso propio (RF-390) ---

func test_played_level_is_the_mode_map() -> void:
	assert_eq(GameFlow.played_level(), ModePacks.map_level(siege, 0))
	GameFlow.current_mode = {}
	assert_null(GameFlow.played_level())


func test_winning_saves_its_own_progress_without_opening_the_next_map() -> void:
	SaveManager.record_victory(GameFlow.level(0).id, 5)  # RF-692: sin campaña 1 ganada el mapa 1 está cerrado
	var game: Game = _play()
	game.session.lose_lives(2)
	_win(game)
	var id: StringName = ModePacks.map_level(siege, 0).id
	assert_true(SaveManager.is_completed(id))
	assert_eq(SaveManager.best_lives(id), game.level_data.starting_lives - 2)
	assert_false(GameFlow.is_mode_level_unlocked(siege, 1), "RF-692: el siguiente no se abre por ganar Asedio")
	assert_false(GameFlow.has_next_level(), "no se ofrece 'Siguiente nivel'")


func test_a_mode_victory_never_touches_the_campaign() -> void:
	var game: Game = _play()
	_win(game)
	assert_false(SaveManager.is_completed(GameFlow.level(0).id), "el nivel 1 de la campaña sigue sin ganar")
	assert_false(GameFlow.is_level_unlocked(1), "ni se abre el nivel 2 de la campaña")
	assert_eq(GameFlow.total_stars(), 0, "las estrellas de la campaña no cambian")
	assert_false(GameFlow.hall_of_fame_pending(), "el Salón es solo de la campaña")
	assert_eq(SaveManager.collected_sources(&"technology").size(), 0)


func test_asedio_is_locked_until_its_campaign_level_is_won() -> void:
	assert_false(GameFlow.is_mode_level_unlocked(siege, 0), "RF-693: sin campaña ni herencia, ni el mapa 1")
	assert_false(GameFlow.is_mode_level_unlocked(siege, 1))
	assert_false(GameFlow.has_next_level())


func test_dev_mode_opens_every_map() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	for i: int in (siege["maps"] as Array).size():
		assert_true(GameFlow.is_mode_level_unlocked(siege, i), "RF-183: mapa %d" % (i + 1))


func test_the_last_map_has_no_next() -> void:
	GameFlow.current_mode_index = (siege["maps"] as Array).size() - 1
	DevMode.set_enabled(true, DEV_PATH)
	assert_false(GameFlow.has_next_level())


func test_mode_records_are_its_own() -> void:
	var game: Game = _play()
	_win(game)
	assert_true(GameFlow.level_score_qualifies(100))
	var position: int = GameFlow.record_level_score("AAA", 100)
	assert_eq(position, 0)
	assert_eq(SaveManager.scores(ModePacks.map_level(siege, 0).id).size(), 1)
	assert_eq(SaveManager.scores(GameFlow.level(0).id).size(), 0, "no van al top 5 del nivel de la campaña")


# --- T235: Asedio sin piezas y sin textos de lore (Q-31 y RF-468) ---

func test_asedio_maps_are_campaign_maps_in_order() -> void:
	# T258: Asedio tiene los 15 mapas de la campaña, cada uno con su porcentaje de vida (M56).
	assert_eq(siege["errors"].size(), 0)
	var maps: Array = siege["maps"]
	assert_eq(maps.size(), 15)
	assert_eq(maps.size(), GameFlow.level_count())
	for i: int in maps.size():
		assert_not_null(maps[i]["level"], "el mapa %d se lee sin errores" % (i + 1))
		assert_eq(maps[i]["level"].display_name, GameFlow.level(i).display_name)


func test_no_asedio_map_offers_pieces_or_texts() -> void:
	for i: int in siege["maps"].size():
		GameFlow.current_mode_index = i
		GameFlow.intro_pending = true  # como si se llegara eligiendo el mapa
		var game: Game = _play()
		var tag: String = "mapa %d" % (i + 1)
		assert_null(game.collectible, tag + ": sin colección")
		assert_false(game._collects_pieces(), tag + ": no se recogen piezas de ruinas (Q-31)")
		assert_false(game.shows_texts(), tag + ": sin textos de lore (RF-468)")
		assert_false(game.level_intro.is_open(), tag + ": sin cartel de entrada")
		assert_false(game.is_paused(), tag + ": la partida no arranca pausada por un cartel")
		game.session.state_changed.emit(LevelSession.State.WON)
		assert_eq(game.end_screen.win_text(), "", tag + ": sin texto de victoria")
		game.queue_free()
		await get_tree().process_frame


func test_asedio_hides_the_texts_of_the_last_campaign_levels() -> void:
	# T258: los mapas 10 a 15 ya están en Asedio y sus textos de lore tampoco se ven.
	for index: int in range(9, GameFlow.level_count()):
		var game: Game = GAME_SCENE.instantiate()
		game.level_data = GameFlow.level(index).duplicate()
		add_child_autofree(game)
		assert_false(game.shows_texts(), "nivel %d" % (index + 1))
