# T229: el nivel 11 (Puesto seco) abre el bloque 3: desierto de 24 × 11 con una entrada, dos pozos de agua,
# una mina, cinco removibles, la rotación de torres sin Ametralladora y el debut del Chamán, solo (RF-476).
# Lo que depende de las reglas comunes del bloque (torres, escalera de oro) está en test_block3_levels.gd.
extends GutTest

const PATH: String = "user://test_level_11.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const MINE: Vector2i = Vector2i(11, 2)
## Bloques libres de 2×2 pensados para el Mortero (esquina de arriba a la izquierda, (columna, fila)).
const MORTAR_BLOCKS: Array[Vector2i] = [Vector2i(3, 1), Vector2i(13, 2), Vector2i(6, 7), Vector2i(13, 7)]

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
	assert_eq(result["warnings"], PackedStringArray(), "nivel %d sin avisos" % n)
	return result["level"]


func _start(n: int = 11) -> void:
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


func _ids_of_wave(wave: WaveData) -> Array:
	var ids: Array = []
	for group: SpawnGroup in wave.groups:
		ids.append(String(group.enemy.id))
	return ids


## La primera oleada (número, desde 1) que trae algún enemigo de `wanted`; 0 si ninguna.
func _first_wave_with(level: LevelData, wanted: Array) -> int:
	for i: int in level.waves.size():
		for id: String in _ids_of_wave(level.waves[i]):
			if wanted.has(id):
				return i + 1
	return 0


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


func test_level_11_follows_the_tenth_in_a_big_desert_map_with_one_entrance() -> void:
	assert_eq(LevelFile.campaign_ids().slice(9, 11), PackedStringArray(["level_10", "level_11"]))
	var level: LevelData = _load(11)
	assert_eq(level.display_name, "Puesto seco")
	assert_eq(level.theme, &"desierto")
	assert_eq(level.waves.size(), 22)
	assert_eq(level.starting_gold, 420)
	assert_eq(level.starting_lives, 20)
	assert_gt(level.health_scale_percent_per_wave, 0, "el nivel trae su propio aumento de vida")
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(grid.errors.size(), 0)
	assert_eq(Vector2i(grid.width, grid.height), Vector2i(24, 11), "RF-250: mapa grande")
	assert_eq(grid.routes.size(), 1, "una sola entrada")
	assert_gte((grid.routes[0] as Array).size(), 75, "camino largo: el Francotirador alcanza al Chamán antes de su hechizo")


func test_two_wells_three_markers_one_mine_and_five_removables_without_findings() -> void:
	var level: LevelData = _load(11)
	var water: int = 0
	var markers: int = 0
	for row: String in level.map_rows:
		for letter: String in row:
			var legend: Dictionary = level.legend.get(letter, {})
			if legend.get("dibujo", "") == "agua":
				water += 1
			elif legend.get("dibujo", "") == "roca_marcada":
				markers += 1
	assert_eq(water, 2, "los dos pozos del camino seco")
	assert_between(markers, 2, 3, "dos o tres hitos (roca marcada mientras el dibujo del hito no llega)")
	var mines: int = 0
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
		assert_eq(obstacle.finding_collection, &"", "sin hallazgos: la colección se completó en el 10")
		assert_eq(obstacle.reward_amount, 1)
		assert_between(obstacle.chance_percent, 1, 99, "al azar, con semilla (RF-417)")
	assert_eq(mines, 1)
	assert_between(removables, 4, 6, "de 4 a 6 removibles")
	assert_true(level.uses_resources())


func test_there_are_about_fifty_free_cells_and_free_2x2_blocks_for_the_mortar() -> void:
	var level: LevelData = _load(11)
	var free: int = 0
	for row: String in level.map_rows:
		free += row.count(".")
	assert_between(free, 45, 56, "unas 50 casillas libres: mapa de espacio limitado")
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	for origin: Vector2i in MORTAR_BLOCKS:
		assert_true(game.build_controller.cells_free(mortar, origin), "bloque libre en %s" % origin)


func test_the_shaman_debuts_alone_in_wave_4_to_6_and_nothing_else_is_new() -> void:
	var level: LevelData = _load(11)
	var known: Array = []
	for n: int in [6, 7, 8, 9, 10]:
		for id: Variant in _enemies_of(_load(n)):
			if not known.has(id):
				known.append(id)
	for id: Variant in _enemies_of(level):
		assert_true(id == "shaman" or known.has(id), "%s ya apareció en los niveles 6 a 10" % id)
	assert_false(known.has("shaman"), "el Chamán nunca apareció en la campaña")
	assert_false(known.has("mirror"), "el Espejo tampoco")
	assert_false(_enemies_of(level).has("mirror"), "el Espejo es del nivel 12")
	var first: int = _first_wave_with(level, ["shaman"])
	assert_between(first, 4, 6, "RF-475 punto 1: debuta en la oleada 4 a 6")
	var ids: Array = _ids_of_wave(level.waves[first - 1])
	for banned: String in ["guardian", "healer", "mirror"]:
		assert_false(ids.has(banned), "la primera oleada del Chamán no trae %s" % banned)


func test_auras_arrive_together_from_wave_8_and_the_shaman_joins_them_from_wave_12() -> void:
	var level: LevelData = _load(11)
	assert_gte(_first_wave_with(level, ["guardian", "healer"]), 8, "el Guardián y el Curandero entran desde la 8")
	var first_pair: int = 0
	for i: int in level.waves.size():
		var ids: Array = _ids_of_wave(level.waves[i])
		if i + 1 < 8:
			assert_false(ids.has("guardian") or ids.has("healer"), "oleada %d: el Guardián y el Curandero entran recién en la 8" % (i + 1))
		if i + 1 == 8:
			assert_true(ids.has("guardian") and ids.has("healer"), "la 8 los trae juntos")
		if first_pair == 0 and ids.has("guardian"):
			first_pair = i + 1
	assert_eq(first_pair, 8)
	for i: int in level.waves.size():
		var ids: Array = _ids_of_wave(level.waves[i])
		if i + 1 < 12 and ids.has("shaman"):
			assert_false(ids.has("guardian") or ids.has("healer"), "oleada %d: el Chamán todavía no se junta con las auras" % (i + 1))
	var together: int = 0
	for i: int in range(11, level.waves.size()):
		var ids: Array = _ids_of_wave(level.waves[i])
		if ids.has("shaman") and ids.has("guardian") and ids.has("healer"):
			together += 1
	assert_gte(together, 3, "Chamán, Guardián y Curandero juntos en varias oleadas desde la 12")
	var boss: int = _first_wave_with(level, ["boss"])
	assert_between(boss, 9, 13, "el Soberano aparece a mitad del nivel")


func test_rammer_has_something_to_hit_at_every_corner_and_removables_do_not_cover_it() -> void:
	var level: LevelData = _load(11)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(_corners(grid).size(), 4, "las 4 esquinas de la serpentina")
	for corner: Vector2i in _corners(grid):
		var free: int = 0
		var support: int = 0
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var cell: Vector2i = corner + step
			if cell.y >= 0 and cell.y < level.map_rows.size() and cell.x >= 0 and cell.x < level.map_rows[cell.y].length() \
					and level.map_rows[cell.y][cell.x] == ".":
				free += 1
		assert_gt(free, 0, "esquina %s: una torre a distancia de impacto del Embestidor" % corner)
		for y: int in level.map_rows.size():
			for x: int in level.map_rows[y].length():
				var other: Vector2i = Vector2i(x, y)
				if level.map_rows[y][x] == "." and Vector2(other).distance_to(Vector2(corner)) > 1.25 \
						and Vector2(other).distance_to(Vector2(corner)) <= 3.0:
					support += 1
		assert_gt(support, 0, "esquina %s: otra casilla libre cerca para el apoyo (RF-379)" % corner)
		for obstacle: ObstacleSpec in level.obstacles:
			assert_gt(Vector2(obstacle.cell).distance_to(Vector2(corner)), 1.25,
				"%s tapa un impacto del Embestidor" % obstacle.cell)


func test_the_mine_pays_for_a_mortar_in_two_waves_and_the_level_works_without_it() -> void:
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	assert_eq(game.session.resources, 0, "empieza sin recursos")
	assert_false(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "sin recursos no se compra")
	game.session.earn(1000)
	assert_true(game.infrastructure.enable(MINE), "se habilita por 100 de oro")
	assert_eq(game.session.gold, 420 + 1000 - 100)
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 4)
	assert_true(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "300 de oro y 3 recursos")
	assert_eq(game.session.resources, 1)


func test_the_third_piece_is_not_here_because_the_collection_was_completed_in_the_ten() -> void:
	var level: LevelData = _load(11)
	for obstacle: ObstacleSpec in level.obstacles:
		assert_eq(obstacle.finding_collection, &"")
	assert_false(CollectionDefinitions.sources(&"disruptor").has("level_11"), "ninguna colección tiene al 11 como fuente")
	assert_false(CollectionDefinitions.sources(&"technology").has("level_11"))
