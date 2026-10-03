extends GutTest

const PATH: String = "user://test_progression_support.json"
const SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")
var old_path: String
var old_index: int
var old_dev: bool
var old_support: bool

func before_each() -> void:
	old_path = SaveManager.save_path
	old_index = GameFlow.current_index
	old_dev = DevMode.enabled
	old_support = DevMode.support_unlocked
	DevMode.enabled = false
	DevMode.support_unlocked = false
	GameFlow.current_index = -1
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
	SaveManager.save_path = PATH
	SaveManager.load_save()

func after_each() -> void:
	GameFlow.current_index = old_index
	DevMode.enabled = old_dev
	DevMode.support_unlocked = old_support
	SaveManager.save_path = old_path
	SaveManager.load_save()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
	Engine.time_scale = 1.0
	get_tree().paused = false

func _run(source: StringName = &"level_01") -> CollectibleRun:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var run := CollectibleRun.new()
	run.setup(&"technology", source, 10, rng)
	return run

func _collect_all() -> void:
	for source: String in (CollectibleRun.definitions()["technology"]["sources"] as Array):
		SaveManager.collect_source(&"technology", StringName(source))

func _game(index: int, campaign: bool = false) -> Game:
	GameFlow.current_index = index if campaign else -1
	var game: Game = SCENE.instantiate()
	game.level_data = GameFlow.level(index)
	add_child_autofree(game)
	return game

func test_one_random_carrier_per_run_and_escaping_gives_nothing() -> void:
	var run: CollectibleRun = _run()
	var carriers: int = 0
	for i: int in 10:
		if run.next_enemy_is_carrier():
			carriers += 1
	assert_eq(carriers, 1)
	assert_true(run.result_sources(true).is_empty())

func test_drop_is_not_kept_before_its_wave_finishes() -> void:
	var run: CollectibleRun = _run()
	run.pick(3)
	run.complete_wave(2)
	assert_true(run.result_sources(true).is_empty())
	run.complete_wave(3)
	assert_eq(run.result_sources(true), PackedStringArray(["level_01"]))

func test_abandon_discards_even_a_confirmed_drop() -> void:
	var run: CollectibleRun = _run()
	run.pick(1)
	run.complete_wave(1)
	assert_true(run.result_sources(false).is_empty())

func test_duplicates_unknown_collections_and_nonofficial_sources_do_not_unlock() -> void:
	SaveManager.collect_source(&"technology", &"level_01")
	SaveManager.collect_source(&"technology", &"level_01")
	SaveManager.collect_source(&"technology", &"comunidad_level_02")
	SaveManager.collect_source(&"unknown", &"level_02")
	assert_eq(SaveManager.collected_sources(&"technology").size(), 1)
	assert_false(SaveManager.collection_complete(&"technology"))
	assert_true(SaveManager.collected_sources(&"unknown").is_empty())
	assert_eq(_run(&"level_06").carrier_index, -1)

func test_collection_roundtrip_preserves_existing_progress() -> void:
	SaveManager.record_victory(&"level_01", 18, 100)
	_collect_all()
	assert_true(SaveManager.save())
	SaveManager.load_save()
	assert_true(SaveManager.collection_complete(&"technology"))
	assert_eq(SaveManager.best_lives(&"level_01"), 18)
	assert_eq(SaveManager.best_score(&"level_01"), 100)

func test_old_save_and_malformed_collection_are_safe() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{"level_01":{"completed":true,"best_lives":17}},"collections":{"technology":["level_01","level_01",2,"level_99"],"unknown":["level_01"]}}')
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"technology").size(), 1)
	assert_eq(SaveManager.best_lives(&"level_01"), 17)
	assert_false(SaveManager.collection_complete(&"technology"))

func test_level_permission_and_collection_are_both_required() -> void:
	var first: LevelData = GameFlow.level(0)
	var sixth: LevelData = GameFlow.level(5)
	assert_false(sixth.available_towers([STANDARD], SaveManager.collection_complete).has(STANDARD))
	_collect_all()
	assert_true(sixth.available_towers([STANDARD], SaveManager.collection_complete).has(STANDARD))
	assert_false(first.available_towers([STANDARD], SaveManager.collection_complete).has(STANDARD))

func test_admin_can_enable_and_disable_without_collecting_and_without_duplicate_buttons() -> void:
	DevMode.enabled = true
	var game: Game = _game(0)
	assert_null(game.collectible)
	game.dev_enable_support(true)
	assert_true(game.available_towers.has(STANDARD))
	assert_eq(game.hud._tower_buttons.size(), game.available_towers.size())
	game.dev_enable_support(true)
	assert_eq(game.hud._tower_buttons.size(), game.available_towers.size())
	assert_true(SaveManager.collected_sources(&"technology").is_empty())
	game.dev_enable_support(false)
	assert_false(game.available_towers.has(STANDARD))

func test_normal_mode_cannot_use_admin_enable() -> void:
	var game: Game = _game(0)
	game.dev_enable_support(true)
	assert_false(game.available_towers.has(STANDARD))
	game.session.earn(1000)
	assert_false(game.build_controller.can_build(STANDARD, Vector2i.ZERO))

func test_game_does_not_persist_collection_before_result_and_keeps_it_on_later_defeat() -> void:
	var game: Game = _game(0, true)
	assert_not_null(game.collectible)
	game.collectible.pick(1)
	game.session.begin_wave()
	game.session.complete_wave()
	assert_true(game.collectible.confirmed)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"technology").has("level_01"))
	SaveManager.load_save()
	assert_true(SaveManager.collected_sources(&"technology").has("level_01"))

func test_defeat_during_pickup_wave_does_not_keep_drop() -> void:
	var game: Game = _game(0, true)
	game.session.begin_wave()
	game.collectible.pick(1)
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())

func test_original_spawn_is_carrier_but_admin_spawn_is_not() -> void:
	var game: Game = _game(0, true)
	game.collectible.carrier_index = 0
	game.spawner.spawn_now(preload("res://data/enemies/normal.tres"))
	assert_eq(game.collectible.spawned, 0)
	game.spawner._spawn_enemy(preload("res://data/enemies/normal.tres"), game.level.get_ground_path(0), 0.0, true)
	assert_eq(game.collectible.spawned, 1)
	assert_not_null(game._carrier)
	game.session.begin_wave()
	game._carrier.take_hit(10000)
	assert_eq(game.collectible.picked_wave, 1)
	assert_null(game._carrier)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())

func test_second_play_of_collected_source_has_no_drop() -> void:
	SaveManager.collect_source(&"technology", &"level_01")
	assert_null(_game(0, true).collectible)

func test_abandoning_a_game_after_confirmation_does_not_write_collection() -> void:
	var game: Game = _game(0, true)
	game.collectible.pick(1)
	game.session.begin_wave()
	game.session.complete_wave()
	# Otro guardado (por ejemplo presentación de enemigos) no debe filtrar el pendiente.
	SaveManager.save()
	game.queue_free()
	SaveManager.load_save()
	assert_true(SaveManager.collected_sources(&"technology").is_empty())

func test_old_save_without_new_fields_keeps_progress_and_starts_collection_empty() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{"level_01":{"completed":true,"best_lives":19}}}')
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.best_lives(&"level_01"), 19)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())

func test_community_map_never_supplies_an_official_collection_source() -> void:
	var old: LevelData = GameFlow.current_community
	GameFlow.current_community = GameFlow.level(0)
	assert_null(_game(0, true).collectible)
	GameFlow.current_community = old

func test_wiki_support_explains_its_role_and_requirement() -> void:
	var entry: WikiEntry = Wiki.tower_entry(STANDARD)
	assert_string_contains(entry.subtitle, "no dispara")
	assert_string_contains(entry.plain_text(), "5 avances distintos")
	assert_string_contains(entry.plain_text(), "+10")

func test_aura_bounds_disabled_source_and_nonstacking() -> void:
	var supports: Array[Dictionary] = [
		{"active":true,"position":Vector2.ZERO,"radius":64.0,"percent":10},
		{"active":true,"position":Vector2.ZERO,"radius":64.0,"percent":20},
		{"active":false,"position":Vector2.ZERO,"radius":64.0,"percent":50}]
	assert_eq(SupportRules.strongest_at(Vector2(64,0), supports), 20)
	assert_eq(SupportRules.strongest_at(Vector2(64.01,0), supports), 0)
	assert_almost_eq(SupportRules.fire_rate(2.0,20), 2.4, 0.001)

func test_live_support_stun_upgrade_and_sale_change_bonus_without_shooting() -> void:
	var cannon := Tower.new()
	cannon.setup(preload("res://data/towers/basic.tres"))
	add_child_autofree(cannon)
	cannon.set_physics_process(false)
	var support := Tower.new()
	support.setup(STANDARD)
	support.position = Vector2(64,0)
	add_child_autofree(support)
	support.set_physics_process(false)
	assert_eq(cannon.support_bonus(), 10)
	assert_eq(support.support_bonus(), 0)
	watch_signals(support)
	support._physics_process(1.0)
	assert_signal_not_emitted(support, "fired")
	support.apply_upgrade()
	assert_eq(cannon.support_bonus(), 15)
	support.stun(2.0)
	assert_eq(cannon.support_bonus(), 0)
	support._physics_process(2.0)
	assert_eq(cannon.support_bonus(), 15)
	support.queue_free()
	assert_eq(cannon.support_bonus(), 0)

func test_first_five_levels_do_not_offer_new_support_even_when_unlocked() -> void:
	_collect_all()
	for i: int in 5:
		assert_false(GameFlow.level(i).available_towers([STANDARD], SaveManager.collection_complete).has(STANDARD))
	assert_true(GameFlow.level(6).available_towers([STANDARD], SaveManager.collection_complete).has(STANDARD))
