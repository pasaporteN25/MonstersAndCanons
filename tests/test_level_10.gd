# T225: el nivel 10 (La mina vieja) es un mapa grande del desierto con una mina de reserva finita,
# removibles que dan recursos, la pieza 3/3 de la Disruptora y el Mortero habilitado (RF-453).
# Las oleadas no estrenan enemigos y nada de lo que hay en el mapa es obligatorio.
extends GutTest

const PATH: String = "user://test_level_10.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const MINE: Vector2i = Vector2i(10, 2)
const PIECE: Vector2i = Vector2i(13, 7)
## Casillas libres de 2×2 pensadas para el Mortero (esquina de arriba a la izquierda).
const MORTAR_BLOCKS: Array[Vector2i] = [Vector2i(5, 2), Vector2i(13, 3), Vector2i(9, 6), Vector2i(17, 7)]

var old_path: String
var old_index: int
var old_campaign: CampaignData
var old_dev: bool
var old_community: LevelData
var game: Game


func before_each() -> void:
	old_path = SaveManager.save_path
	old_index = GameFlow.current_index
	old_campaign = GameFlow.campaign
	old_dev = DevMode.enabled
	old_community = GameFlow.current_community
	DevMode.enabled = false
	GameFlow.current_community = null
	SaveManager.save_path = PATH
	SaveManager.load_save()


func after_each() -> void:
	GameFlow.current_index = old_index
	GameFlow.campaign = old_campaign
	GameFlow.current_community = old_community
	GameFlow.forced_seed = -1
	DevMode.enabled = old_dev
	SaveManager.save_path = old_path
	SaveManager.load_save()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


func _all_towers() -> Array[TowerData]:
	var towers: Array[TowerData] = []
	for id: String in ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar", "mechanical_standard"]:
		towers.append(load("res://data/towers/%s.tres" % id))
	return towers


func _start(n: int = 10) -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_load(n)] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _enemies_of(level: LevelData) -> Array:
	var ids: Array = []
	for wave: WaveData in level.waves:
		for group: SpawnGroup in wave.groups:
			var id: String = String(group.enemy.id)
			if not ids.has(id):
				ids.append(id)
	return ids


## Las esquinas donde termina una recta de al menos 3 casillas (la carga del Embestidor, RF-379).
func _corners(grid: MapGrid) -> Array[Vector2i]:
	var corners: Array[Vector2i] = []
	for route: Array in grid.routes:
		for i: int in range(1, route.size() - 1):
			if route[i] - route[i - 1] == route[i + 1] - route[i]:
				continue
			var run: int = 1
			while i - run - 1 >= 0 and route[i - run] - route[i - run - 1] == route[i] - route[i - 1]:
				run += 1
			if run >= 3 and not corners.has(route[i]):
				corners.append(route[i])
	return corners


func test_level_10_is_in_the_campaign_in_a_big_desert_map() -> void:
	assert_eq(LevelFile.campaign_ids().slice(8, 10), PackedStringArray(["level_09", "level_10"]))
	var level: LevelData = _load(10)
	assert_eq(level.display_name, "La mina vieja")
	assert_eq(level.theme, &"desierto")
	assert_eq(level.waves.size(), 20)
	assert_eq(level.starting_gold, 360)
	assert_eq(level.starting_lives, 20)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(grid.errors.size(), 0)
	assert_eq(Vector2i(grid.width, grid.height), Vector2i(24, 11), "RF-250: mapa grande")
	var lengths: Array = []
	for route: Array in grid.routes:
		lengths.append(route.size())
	assert_eq(lengths, [68, 55], "largo de los dos recorridos")


func test_one_mine_seven_removables_and_a_single_piece() -> void:
	var level: LevelData = _load(10)
	assert_true(level.uses_resources(), "hay recursos")
	var mines: int = 0
	var pieces: int = 0
	var removables: int = 0
	for obstacle: ObstacleSpec in level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.EXTRACTION:
			mines += 1
			assert_eq(obstacle.cell, MINE)
			assert_eq(obstacle.class_id, &"mina")
			assert_eq(obstacle.cost, 100, "Q-19: 100 de oro")
			assert_eq(obstacle.production, 2, "Q-19: 2 por oleada")
			assert_eq(obstacle.reserve, 8, "Q-19: reserva de 8")
			continue
		removables += 1
		if obstacle.finding_collection == &"disruptor":
			pieces += 1
			assert_eq(obstacle.cell, PIECE, "dónde está la pieza")
		else:
			assert_eq(obstacle.reward_amount, 1)
			assert_between(obstacle.chance_percent, 1, 99, "al azar, con semilla")
	assert_eq(mines, 1)
	assert_eq(removables, 7)
	assert_eq(pieces, 1, "la pieza 3/3")
	assert_false(level.machine_enabled, "sin demoledora: no hace falta (Lucas no la pidió)")


func test_the_mortar_and_the_mechanic_are_available_and_the_sniper_keeps_both_prices() -> void:
	var level: LevelData = _load(10)
	var ids: Array = []
	for tower: TowerData in level.available_towers(_all_towers(), func(_c: StringName) -> bool: return true):
		ids.append(String(tower.id))
	assert_true(ids.has("mortar"), "el Mortero sigue habilitado")
	assert_true(ids.has("mechanical_standard"))
	assert_true(ids.has("sniper"))
	var sniper: TowerData = load("res://data/towers/sniper.tres")
	assert_eq(sniper.levels[0].cost, 150)
	assert_eq(sniper.alt_gold_cost, 120)
	assert_eq(sniper.alt_resource_cost, 1)


func test_the_waves_have_no_debuts_and_pair_guardian_with_healer() -> void:
	var level: LevelData = _load(10)
	var known: Array = []
	for n: int in [6, 7, 8, 9]:
		for id: Variant in _enemies_of(_load(n)):
			if not known.has(id):
				known.append(id)
	for id: Variant in _enemies_of(level):
		assert_true(known.has(id), "%s ya apareció en los niveles 6 a 9" % id)
	var together: int = 0
	for wave: WaveData in level.waves:
		var ids: Array = []
		for group: SpawnGroup in wave.groups:
			ids.append(String(group.enemy.id))
		if ids.has("guardian") and ids.has("healer"):
			together += 1
	assert_gte(together, 3, "Guardián y Curandero juntos en varias oleadas")


func test_rammer_has_something_to_hit_at_every_corner_and_removables_do_not_cover_it() -> void:
	var level: LevelData = _load(10)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(_corners(grid).size(), 4, "las 4 esquinas del serpenteo")
	for corner: Vector2i in _corners(grid):
		var free: int = 0
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var cell: Vector2i = corner + step
			if cell.y >= 0 and cell.y < level.map_rows.size() and cell.x >= 0 and cell.x < level.map_rows[cell.y].length() \
					and level.map_rows[cell.y][cell.x] == ".":
				free += 1
		assert_gt(free, 0, "esquina %s: una torre a distancia de impacto del Embestidor" % corner)
		for obstacle: ObstacleSpec in level.obstacles:
			assert_gt(Vector2(obstacle.cell).distance_to(Vector2(corner)), 1.25,
				"%s tapa un impacto del Embestidor" % obstacle.cell)


func test_there_are_free_2x2_blocks_for_the_mortar() -> void:
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	for origin: Vector2i in MORTAR_BLOCKS:
		assert_true(game.build_controller.cells_free(mortar, origin), "bloque libre en %s" % origin)


func test_the_mine_pays_for_a_mortar_in_two_waves_and_the_level_works_without_it() -> void:
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	assert_eq(game.session.resources, 0, "empieza sin recursos")
	assert_false(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "sin recursos no se compra")
	game.session.earn(1000)
	assert_true(game.infrastructure.enable(MINE), "se habilita por 100 de oro")
	assert_eq(game.session.gold, 360 + 1000 - 100)
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 2)
	assert_false(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "con 2 recursos todavía no (cuesta 3)")
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 4)
	assert_true(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "300 de oro y 3 recursos")
	assert_eq(game.session.resources, 1)


func test_the_third_piece_completes_the_disruptor_collection() -> void:
	SaveManager.collect_source(&"disruptor", &"level_08")
	SaveManager.collect_source(&"disruptor", &"level_09")
	assert_false(SaveManager.collection_complete(&"disruptor"), "con 2 piezas todavía no")
	_start()
	game.infrastructure.select(PIECE)
	assert_string_contains(game.hud.obstacle_panel._reward.text, "Pieza de la Disruptora: pendiente")
	assert_true(game.infrastructure.order(PIECE), "se puede ordenar la demolición")
	game.infrastructure.field.tick(60.0)
	assert_eq(game.findings.pending().size(), 1)
	game.session.begin_wave()
	game.session.complete_wave()
	assert_eq(game.findings.confirmed().size(), 1)
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").has("level_10"), "guardada en la campaña")
	assert_eq(SaveManager.collected_sources(&"disruptor").size(), 3)
	assert_true(SaveManager.collection_complete(&"disruptor"), "Disruptora lista para el nivel 11")


func test_the_piece_is_not_collected_outside_the_campaign() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = _load(10)
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_true(game.infrastructure.order(PIECE))
	game.infrastructure.field.tick(60.0)
	assert_true(game.findings.pending().is_empty())
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())
