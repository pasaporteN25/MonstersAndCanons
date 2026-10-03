extends GutTest

const THIEF: EnemyData = preload("res://data/enemies/thief.tres")
const SCENE: PackedScene = preload("res://scenes/game/game.tscn")

func _enemy() -> Enemy:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(2000,0))
	add_child_autofree(path)
	var enemy := Enemy.new()
	enemy.setup(THIEF, path, 100)
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	return enemy

func test_floor_income_and_finished_session() -> void:
	var session := LevelSession.new()
	add_child_autofree(session)
	session.gold = 12
	assert_eq(session.steal(3,10),2)
	assert_eq(session.steal(3,10),0)
	session.earn(6)
	assert_eq(session.steal(3,10),3)
	session.gold = 7
	assert_eq(session.steal(3,10),0)
	assert_eq(session.gold,7)
	assert_eq(session.steal(-3,10),0)
	session.state = LevelSession.State.LOST
	session.gold = 30
	assert_eq(session.steal(3,10),0)

func test_clock_stops_on_death_and_vanish() -> void:
	var enemy: Enemy = _enemy()
	watch_signals(enemy)
	enemy._physics_process(1.0)
	assert_signal_not_emitted(enemy,"gold_drain")
	enemy._physics_process(1.0)
	assert_signal_emitted_with_parameters(enemy,"gold_drain",[enemy,3,10])
	enemy.vanish()
	enemy._physics_process(8.0)
	assert_signal_emit_count(enemy,"gold_drain",1)
	var dead: Enemy = _enemy()
	watch_signals(dead)
	dead.take_hit(1000)
	dead._physics_process(8.0)
	assert_signal_not_emitted(dead,"gold_drain")

func test_large_delta_counts_only_time_on_path_and_escape_has_no_extra_theft() -> void:
	var enemy: Enemy = _enemy()
	enemy.distance = enemy.path().curve.get_baked_length() - Rules.tiles_to_px(THIEF.speed_tiles) * 1.9
	watch_signals(enemy)
	enemy._physics_process(10.0)
	assert_signal_not_emitted(enemy,"gold_drain")
	assert_signal_emit_count(enemy,"reached_exit",1)
	enemy._physics_process(10.0)
	assert_signal_not_emitted(enemy,"gold_drain")

func test_real_game_connections_and_floor_resume() -> void:
	var old_dev: bool = DevMode.enabled
	DevMode.enabled = true
	var game: Game = SCENE.instantiate()
	add_child_autofree(game)
	game.session.set_gold(11)
	game.spawner.spawn_now(THIEF)
	var enemy: Enemy = game.get_node("Enemies").get_child(0)
	enemy.set_physics_process(false)
	enemy._update_gold_drain(2.0)
	assert_eq(game.session.gold,10)
	game.session.earn(5)
	enemy._update_gold_drain(2.0)
	assert_eq(game.session.gold,12)
	DevMode.enabled = old_dev

func test_optional_groups_can_be_absent_and_caps_reset_per_wave() -> void:
	var spawner := WaveSpawner.new()
	add_child_autofree(spawner)
	var wave := WaveData.new()
	for probability: float in [0.0,0.999999,0.999999]:
		var group := SpawnGroup.new()
		group.enemy = THIEF
		group.count = 10
		group.probability = probability
		wave.groups.append(group)
	spawner.rng.seed = 12
	spawner.start_wave(wave,1)
	var total: int = 0
	for run: WaveSpawner.GroupRun in spawner._runs:
		total += run.group.count - run.spawned
	assert_eq(total,1)
	spawner.start_wave(wave,2)
	total = 0
	for run: WaveSpawner.GroupRun in spawner._runs:
		total += run.group.count - run.spawned
	assert_eq(total,1,"el cupo vuelve a estar disponible en la siguiente oleada")
	wave.groups.resize(1)
	watch_signals(spawner)
	spawner.start_wave(wave,2)
	spawner._process(0.1)
	assert_signal_emitted(spawner,"wave_finished")

func test_editor_probability_roundtrip_validation_and_undo() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	assert_true(draft.set_group(0,0,"probabilidad",0.35))
	var restored: LevelDraft = LevelDraft.from_text(draft.to_text())
	assert_eq(restored.group(0,0)["probabilidad"],0.35)
	assert_eq((LevelFile.parse(draft.to_text(),&"test")["level"] as LevelData).waves[0].groups[0].probability,0.35)
	draft.undo()
	assert_eq(draft.group(0,0)["probabilidad"],1.0)
	for invalid: String in ["-0.1","1.01","\"mucho\""]:
		var text: String = restored.to_text().replace("\"probabilidad\": 0.35","\"probabilidad\": " + invalid)
		assert_null(LevelFile.parse(text,&"test")["level"])

func test_campaign_introduces_threats_only_after_five_levels() -> void:
	for i: int in 7:
		var level: LevelData = GameFlow.level(i)
		var count: int = 0
		for wave: WaveData in level.waves:
			for group: SpawnGroup in wave.groups:
				if group.enemy.id == &"thief":
					count += 1
					assert_eq(group.count,1)
					assert_lt(group.probability,1.0)
		assert_eq(count,0 if i < 5 else (1 if i == 5 else 3))

func test_actual_pause_freezes_and_time_scale_accelerates_clock() -> void:
	var enemy: Enemy = _enemy()
	enemy.set_physics_process(true)
	get_tree().paused = true
	var distance_before: float = enemy.distance
	await get_tree().create_timer(0.1,true,false,true).timeout
	assert_eq(enemy._drain_clock,0.0)
	assert_eq(enemy.distance,distance_before)
	get_tree().paused = false
	Engine.time_scale = 2.0
	await get_tree().create_timer(0.2,true,false,true).timeout
	Engine.time_scale = 1.0
	enemy.set_physics_process(false)
	assert_gt(enemy._drain_clock,0.3)
