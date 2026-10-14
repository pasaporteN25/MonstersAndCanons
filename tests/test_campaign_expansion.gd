extends GutTest

const PATH: String = "user://test_campaign_expansion.json"
const STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")
var old_path: String
var old_index: int
var old_dev: bool

func before_each() -> void:
	old_path = SaveManager.save_path
	old_index = GameFlow.current_index
	old_dev = DevMode.enabled
	GameFlow.current_index = -1
	DevMode.enabled = false
	SaveManager.save_path = PATH
	if FileAccess.file_exists(PATH): DirAccess.remove_absolute(PATH)
	SaveManager.load_save()

func after_each() -> void:
	GameFlow.current_index = old_index
	DevMode.enabled = old_dev
	SaveManager.save_path = old_path
	SaveManager.load_save()
	if FileAccess.file_exists(PATH): DirAccess.remove_absolute(PATH)

func test_old_last_level_victory_opens_only_the_next_without_writing() -> void:
	var file: FileAccess = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{"level_07":{"completed":true,"best_lives":16,"best_score":1234}}}')
	file.close()
	var previous: String = FileAccess.get_file_as_string(PATH)
	SaveManager.load_save()
	assert_false(SaveManager.is_unlocked(&"level_08"))
	assert_true(GameFlow.is_level_unlocked(7), "victoria previa habilita expansión")
	assert_false(GameFlow.is_level_unlocked(8), "no saltea8")
	assert_eq(SaveManager.best_score(&"level_07"),1234)
	assert_eq(FileAccess.get_file_as_string(PATH),previous,"consulta no migra ni escribe")

func test_winning_eight_unlocks_nine_and_each_next_one_until_the_last() -> void:
	GameFlow.current_index = 7
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(GameFlow.is_level_unlocked(8))
	assert_true(SaveManager.is_unlocked(&"level_09"))
	# T225 y T229 a T232: del 9 al 14 ya tienen siguiente; el último de la campaña (hoy el 15) no.
	GameFlow.current_index = 8
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(GameFlow.is_level_unlocked(9))
	assert_true(SaveManager.is_unlocked(&"level_10"))
	GameFlow.current_index = 9
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(SaveManager.is_unlocked(&"level_11"))
	GameFlow.current_index = 10
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(SaveManager.is_unlocked(&"level_12"))
	GameFlow.current_index = 11
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(SaveManager.is_unlocked(&"level_13"))
	GameFlow.current_index = 12
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(SaveManager.is_unlocked(&"level_14"))
	GameFlow.current_index = 13
	assert_true(GameFlow.has_next_level())
	GameFlow.level_won(15,1234)
	SaveManager.load_save()
	assert_true(SaveManager.is_unlocked(&"level_15"), "T234: ganar el 14 abre la central")
	GameFlow.current_index = LevelFile.campaign_ids().size() - 1
	assert_eq(GameFlow.level(GameFlow.current_index).id, &"level_15", "el último es el 15")
	assert_false(GameFlow.has_next_level(), "el último de la campaña no tiene siguiente")

func test_campaign_tail_and_collection_gate_for_the_new_levels() -> void:
	assert_eq(LevelFile.campaign_ids().slice(7, 10),PackedStringArray(["level_08","level_09","level_10"]))
	for index: int in [7,8,9]:
		assert_false(GameFlow.level(index).available_towers([STANDARD],SaveManager.collection_complete).has(STANDARD))
	for source: String in (CollectibleRun.definitions()["technology"]["sources"] as Array):
		SaveManager.collect_source(&"technology",StringName(source))
	for index: int in [7,8,9]:
		assert_true(GameFlow.level(index).available_towers([STANDARD],SaveManager.collection_complete).has(STANDARD))
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		var run: CollectibleRun = CollectibleRun.new()
		run.setup(&"technology",GameFlow.level(index).id,20,rng)
		assert_eq(run.carrier_index,-1,"no agrega fuentes después de5")

func _first(level: LevelData, id: StringName) -> int:
	for i: int in level.waves.size():
		for group: SpawnGroup in level.waves[i].groups:
			if group.enemy.id == id: return i+1
	return -1

func test_introductions_and_economic_encounters_have_preparation() -> void:
	assert_eq(_first(GameFlow.level(7),&"healer"),-1)
	assert_lt(_first(GameFlow.level(7),&"guardian"),_first(GameFlow.level(7),&"thief"))
	assert_lt(_first(GameFlow.level(8),&"guardian"),_first(GameFlow.level(8),&"healer"))
	for index: int in [7,8]:
		var level: LevelData = GameFlow.level(index)
		assert_gte(_first(level,&"thief"),6)
		assert_gte(_first(level,&"rammer"),8)
		assert_ne(_first(level,&"thief"),_first(level,&"rammer"))
		for wave: WaveData in level.waves:
			var thieves: int = 0
			for group: SpawnGroup in wave.groups:
				if group.enemy.id == &"thief":
					thieves += group.count
					assert_gt(group.probability,0.0)
					assert_lt(group.probability,1.0)
			assert_lte(thieves,1,"sin robos superpuestos")

func test_every_used_entrance_has_charge_endpoint_and_legal_support_position() -> void:
	for index: int in [7,8]:
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(index)
		add_child_autofree(game)
		var entries: Dictionary = {}
		for wave: WaveData in game.level_data.waves:
			for group: SpawnGroup in wave.groups:
				if group.enemy.id == &"rammer": entries[group.entrance_index] = true
		for entrance: int in entries:
			var found: bool = false
			var path: Path2D = game.level.get_ground_path(entrance)
			for segment: Dictionary in ChargeRules.segments(path.curve):
				if float(segment.end)-float(segment.start) < Rules.tiles_to_px(3): continue
				var endpoint: Vector2 = path.to_global(segment.position)
				for cell: Vector2i in game.level.ground.get_used_cells():
					if not game.level.is_buildable(cell) or endpoint.distance_to(game.level.cell_center(cell)) > Rules.tiles_to_px(1.25): continue
					for other: Vector2i in game.level.ground.get_used_cells():
						if cell != other and game.level.is_buildable(other) and cell.distance_to(other) <= 2:
							found = true
			assert_true(found,"entrada%d de nivel%d tiene exposición reparable" % [entrance,index+1])
