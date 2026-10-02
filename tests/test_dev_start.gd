# Tests de la oleada inicial del modo de pruebas (T149, spec RF-319, RF-320, RF-324).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const BALANCE: BalanceConfig = preload("res://data/balance.tres")
const DEV_PATH: String = "user://test_save_pruebas.json"


func _enemy(reward: int, spawn: EnemyData = null, spawn_count: int = 0) -> EnemyData:
	var enemy := EnemyData.new()
	enemy.reward = reward
	enemy.death_spawn = spawn
	enemy.death_spawn_count = spawn_count
	return enemy


func _group(enemy: EnemyData, count: int) -> SpawnGroup:
	var group := SpawnGroup.new()
	group.enemy = enemy
	group.count = count
	return group


## Un nivel de prueba: oro 100 y tres oleadas con recompensas conocidas.
func _level() -> LevelData:
	var level := LevelData.new()
	level.starting_gold = 100
	var small: EnemyData = _enemy(5)
	var big: EnemyData = _enemy(20)
	var wave_1 := WaveData.new()
	wave_1.groups = [_group(small, 10)]  # 50
	var wave_2 := WaveData.new()
	wave_2.groups = [_group(small, 4), _group(big, 2)]  # 20 + 40
	var wave_3 := WaveData.new()
	wave_3.groups = [_group(big, 5)]
	level.waves = [wave_1, wave_2, wave_3]
	return level


# --- clamp_wave ---

func test_clamp_wave_keeps_a_valid_wave() -> void:
	assert_eq(DevStart.clamp_wave(6, 10), 6)


func test_clamp_wave_limits() -> void:
	assert_eq(DevStart.clamp_wave(99, 10), 10, "RF-319: más que el total, la última")
	assert_eq(DevStart.clamp_wave(0, 10), 1)
	assert_eq(DevStart.clamp_wave(-5, 10), 1)
	assert_eq(DevStart.clamp_wave(3, 0), 1, "un nivel sin oleadas no rompe")


# --- Oro ---

func test_wave_1_gold_is_the_level_gold() -> void:
	assert_eq(DevStart.start_gold(_level(), BALANCE, 1), 100, "RF-319: con la 1 todo es como hoy")


func test_gold_adds_rewards_and_bonuses_of_skipped_waves() -> void:
	var bonus_1: int = Rules.wave_bonus(1, BALANCE)
	var bonus_2: int = Rules.wave_bonus(2, BALANCE)
	assert_eq(DevStart.start_gold(_level(), BALANCE, 2), 100 + 50 + bonus_1)
	assert_eq(DevStart.start_gold(_level(), BALANCE, 3), 100 + 50 + bonus_1 + 60 + bonus_2)


func test_gold_for_a_wave_beyond_the_total_counts_all_waves_once() -> void:
	var level: LevelData = _level()
	var last: int = DevStart.clamp_wave(99, level.waves.size())
	assert_eq(DevStart.start_gold(level, BALANCE, last), DevStart.start_gold(level, BALANCE, 3))
	# Sin ajustar, pasarse del total no suma oleadas que no existen.
	assert_eq(DevStart.skipped_gold(level, BALANCE, 99), DevStart.skipped_gold(level, BALANCE, 4))


func test_manual_gold_wins_even_when_zero() -> void:
	assert_eq(DevStart.start_gold(_level(), BALANCE, 3, 250), 250)
	assert_eq(DevStart.start_gold(_level(), BALANCE, 3, 0), 0, "RF-320: se puede empezar con 0")


func test_spawned_young_add_to_the_reward() -> void:
	var young: EnemyData = _enemy(2)
	var mother: EnemyData = _enemy(10, young, 4)
	assert_eq(DevStart.enemy_reward(mother), 18, "10 de la madre + 4 crías de 2")
	var grandmother: EnemyData = _enemy(1, mother, 2)
	assert_eq(DevStart.enemy_reward(grandmother), 37, "las crías de las crías también")


func test_a_loop_of_young_does_not_hang() -> void:
	var enemy: EnemyData = _enemy(1)
	enemy.death_spawn = enemy
	enemy.death_spawn_count = 1
	assert_eq(DevStart.enemy_reward(enemy), DevStart.MAX_SPAWN_DEPTH + 1, "corta en el tope")
	var released: WeakRef = weakref(enemy)
	enemy.death_spawn = null
	enemy = null
	assert_null(released.get_ref(), "el dato circular de prueba se libera")


func test_real_level_1_gold_matches_its_data() -> void:
	var level: LevelData = GameFlow.level(0)
	assert_eq(DevStart.start_gold(level, BALANCE, 1), level.starting_gold)
	# Calculado por otro camino: sumando a mano lo que dan los enemigos y los bonos de las oleadas 1 a 5.
	var expected: int = level.starting_gold
	for index: int in 5:
		for group: SpawnGroup in level.waves[index].groups:
			expected += group.count * DevStart.enemy_reward(group.enemy)
		expected += BALANCE.wave_bonus_base + BALANCE.wave_bonus_per_wave * (index + 1)
	assert_eq(DevStart.start_gold(level, BALANCE, 6), expected, "RF-320, nivel 1, oleada 6")
	assert_gt(expected, level.starting_gold)


func test_the_spider_young_count_in_the_real_data() -> void:
	var spider: EnemyData = load("res://data/enemies/spider.tres")
	assert_gt(DevStart.enemy_reward(spider), spider.reward, "la Araña suelta crías que también dan oro")


# --- Datos (RF-324) ---

func test_dev_config_has_the_numbers() -> void:
	var config: DevConfig = load("res://data/dev_config.tres")
	assert_eq(config.gold_step, 1000)
	assert_eq(Array(config.speeds), [0.25, 0.5, 1.0, 2.0, 4.0], "RF-322")


# --- Saltar a la oleada N en la sesión ---

func _session(waves: int) -> LevelSession:
	var level := LevelData.new()
	level.starting_gold = 10
	level.starting_lives = 20
	for i: int in waves:
		level.waves.append(WaveData.new())
	var session := LevelSession.new()
	add_child_autofree(session)
	session.start(level, BALANCE)
	return session


func test_jump_to_wave_leaves_the_session_ready_for_that_wave() -> void:
	var session: LevelSession = _session(10)
	watch_signals(session)
	session.jump_to_wave(6)
	assert_eq(session.wave, 5, "la 5 ya 'pasó'; la próxima es la 6")
	assert_eq(session.state, LevelSession.State.BUILDING)
	assert_signal_emitted_with_parameters(session, "wave_changed", [5, 10])
	assert_eq(session.gold, 10, "no da oro: eso lo decide DevStart")
	assert_eq(session.begin_wave(), 6)


func test_jump_to_wave_clamps_and_ignores_wave_1() -> void:
	var session: LevelSession = _session(10)
	session.jump_to_wave(99)
	assert_eq(session.wave, 9, "RF-319: más que el total, la última")
	var first: LevelSession = _session(10)
	first.jump_to_wave(1)
	assert_eq(first.wave, 0)


func test_jump_to_wave_only_before_the_first_wave() -> void:
	var session: LevelSession = _session(10)
	session.begin_wave()
	session.jump_to_wave(6)
	assert_eq(session.wave, 1, "con una oleada en curso no salta")


# --- El HUD ---

func test_hud_shows_the_target_wave_as_next() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.jump_to_wave(6)
	await wait_process_frames(2)
	var counts: Dictionary = game.level_data.waves[5].enemy_counts()
	assert_eq(game.hud._next_wave_icons.get_child_count(), counts.size(), "RF-319: muestra la oleada 6 como próxima")
	assert_true(game.hud._wave_label.text.contains("Próxima: oleada 6"), game.hud._wave_label.text)
	DevMode.clear_stats_file()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	if FileAccess.file_exists(DEV_PATH):
		DirAccess.remove_absolute(DEV_PATH)
