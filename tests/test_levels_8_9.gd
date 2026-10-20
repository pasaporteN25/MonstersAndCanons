# T224: los niveles 8 (El bastión sobre ruinas) y 9 (El taller) son de ruinas, guardan las piezas 1/3 y 2/3
# de la Disruptora y el 9 estrena el Mortero (RF-420). Las oleadas no cambian; los removibles
# nunca tocan el camino ni las casillas de impacto del Embestidor (RF-379).
extends GutTest

const PATH: String = "user://test_levels_8_9.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## nivel → [removibles, celda de la pieza, largo de cada recorrido (no cambió)]
const EXPECTED: Dictionary = {
	8: [4, Vector2i(7, 6), [58]],
	9: [4, Vector2i(11, 6), [56, 47]],
}

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
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_0%d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


func _all_towers() -> Array[TowerData]:
	var towers: Array[TowerData] = []
	for id: String in ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar", "mechanical_standard"]:
		towers.append(load("res://data/towers/%s.tres" % id))
	return towers


func _ids(level: LevelData) -> Array:
	var ids: Array = []
	for tower: TowerData in level.available_towers(_all_towers()):
		ids.append(String(tower.id))
	return ids


func _start(n: int) -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_load(n)] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func test_levels_8_and_9_are_ruins_with_removables_and_resources() -> void:
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		assert_eq(level.theme, &"ruinas", "nivel %d: tema" % n)
		assert_eq(level.obstacles.size(), EXPECTED[n][0], "nivel %d: removibles" % n)
		assert_true(level.uses_resources(), "nivel %d: hay recursos" % n)
		var pieces: int = 0
		for obstacle: ObstacleSpec in level.obstacles:
			assert_eq(obstacle.kind, ObstacleSpec.Kind.REMOVABLE)
			if obstacle.finding_collection == &"disruptor":
				pieces += 1
				assert_eq(obstacle.cell, EXPECTED[n][1], "nivel %d: dónde está la pieza" % n)
			else:
				assert_eq(obstacle.reward_amount, 1)
				if n == 9:
					assert_eq(obstacle.chance_percent, 100, "nivel 9: los escombros comunes siempre dan su recurso")
				else:
					assert_between(obstacle.chance_percent, 1, 99, "nivel 8: al azar")
		assert_eq(pieces, 1, "nivel %d: una sola pieza" % n)


func test_the_mortar_debuts_in_level_9_only() -> void:
	assert_false(_ids(_load(8)).has("mortar"), "el 8 queda sin Mortero")
	assert_true(_ids(_load(9)).has("mortar"), "el 9 lo estrena")
	assert_true(_load(8).extra_towers.has("mechanical_standard"), "el Mecánico se conserva")
	assert_true(_load(9).extra_towers.has("mechanical_standard"))
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	assert_eq(mortar.levels[0].cost, 300)
	assert_eq(mortar.resource_cost, 3)


func test_waves_and_routes_are_unchanged() -> void:
	assert_eq(_load(8).waves.size(), 18)
	assert_eq(_load(9).waves.size(), 20)
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		assert_eq(grid.errors.size(), 0)
		var lengths: Array = []
		for route: Array in grid.routes:
			lengths.append(route.size())
		assert_eq(lengths, EXPECTED[n][2], "nivel %d: largo de los recorridos" % n)


func test_removables_keep_the_rammer_impact_cells_free() -> void:
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		var corners: Array[Vector2i] = []
		for route: Array in grid.routes:
			for i: int in range(1, route.size() - 1):
				if route[i] - route[i - 1] != route[i + 1] - route[i]:
					corners.append(route[i])
		for obstacle: ObstacleSpec in level.obstacles:
			for corner: Vector2i in corners:
				assert_gt(Vector2(obstacle.cell).distance_to(Vector2(corner)), 1.25,
					"nivel %d: %s tapa un impacto del Embestidor" % [n, obstacle.cell])


func test_the_piece_is_picked_confirmed_and_saved_in_the_campaign() -> void:
	for n: int in EXPECTED.keys():
		_start(n)
		var cell: Vector2i = EXPECTED[n][1]
		game.infrastructure.select(cell)
		assert_string_contains(game.hud.obstacle_panel._reward.text, "Pieza de la Disruptora: pendiente")
		assert_true(game.infrastructure.order(cell), "nivel %d: se puede ordenar" % n)
		game.infrastructure.field.tick(60.0)
		assert_eq(game.findings.pending().size(), 1, "nivel %d: pendiente" % n)
		game.session.begin_wave()
		game.session.complete_wave()
		assert_eq(game.findings.confirmed().size(), 1)
		game.session.lose_lives(1000)
		assert_true(SaveManager.collected_sources(&"disruptor").has("level_0%d" % n), "nivel %d: guardada" % n)
		game.queue_free()
		await get_tree().process_frame
	assert_eq(SaveManager.collected_sources(&"disruptor").size(), 2, "2 de 3 piezas")


func test_the_piece_is_not_collected_outside_the_campaign() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = _load(8)
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	var cell: Vector2i = EXPECTED[8][1]
	assert_true(game.infrastructure.order(cell))
	game.infrastructure.field.tick(60.0)
	assert_true(game.findings.pending().is_empty())
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())
