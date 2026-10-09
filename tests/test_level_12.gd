# T230: el nivel 12 (El cañadón) es un cañadón de 26 × 11 del desierto con una entrada, un bosque explotable en vez de
# la mina, cinco removibles y el debut del Espejo, solo (RF-477). Lo que tienen en común los niveles del bloque 3
# (torres, escalera de oro) está en test_block3_levels.gd.
extends GutTest

const PATH: String = "user://test_level_12.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const FOREST: Vector2i = Vector2i(6, 5)
## Bloques libres de 2×2 pensados para el Mortero (esquina de arriba a la izquierda, (columna, fila)).
const MORTAR_BLOCKS: Array[Vector2i] = [Vector2i(14, 3), Vector2i(4, 4), Vector2i(19, 5), Vector2i(9, 6)]

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


func _start(n: int = 12) -> void:
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


func test_level_12_follows_the_eleventh_in_a_canyon_of_26_by_11_with_one_entrance() -> void:
	assert_eq(LevelFile.campaign_ids().slice(10, 12), PackedStringArray(["level_11", "level_12"]))
	var level: LevelData = _load(12)
	assert_eq(level.display_name, "El cañadón")
	assert_eq(level.theme, &"desierto")
	assert_eq(level.waves.size(), 24)
	assert_eq(level.starting_gold, 440)
	assert_eq(level.starting_lives, 20)
	assert_gt(level.health_scale_percent_per_wave, 0, "el nivel trae su propio aumento de vida")
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(grid.errors.size(), 0)
	assert_eq(Vector2i(grid.width, grid.height), Vector2i(26, 11), "RF-250: mapa grande")
	assert_eq(grid.routes.size(), 1, "una sola entrada")
	assert_gte((grid.routes[0] as Array).size(), 75, "zigzag largo entre paredes")


func test_a_forest_instead_of_the_mine_five_removables_markers_and_no_findings() -> void:
	var level: LevelData = _load(12)
	var water: int = 0
	var markers: int = 0
	for row: String in level.map_rows:
		for letter: String in row:
			var legend: Dictionary = level.legend.get(letter, {})
			if legend.get("dibujo", "") == "agua":
				water += 1
			elif legend.get("dibujo", "") == "roca_marcada":
				markers += 1
	assert_eq(water, 0, "sin pozos: es un cañadón seco")
	assert_between(markers, 2, 3, "dos o tres hitos en la boca del cañadón (roca marcada mientras el dibujo del hito no llega)")
	var sources: int = 0
	var removables: int = 0
	for obstacle: ObstacleSpec in level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.EXTRACTION:
			sources += 1
			assert_eq(obstacle.cell, FOREST)
			assert_eq(obstacle.class_id, &"bosque_explotable", "un bosque en vez de la mina, para variar la fuente")
			assert_eq(obstacle.cost, 100, "Q-19: 100 de oro")
			assert_eq(obstacle.production, 2, "Q-19: 2 por oleada")
			assert_eq(obstacle.reserve, 8, "Q-19: reserva de 8")
			continue
		removables += 1
		assert_eq(obstacle.finding_collection, &"", "sin hallazgos")
		assert_eq(obstacle.reward_amount, 1)
		assert_between(obstacle.chance_percent, 1, 99, "al azar, con semilla (RF-417)")
	assert_eq(sources, 1)
	assert_between(removables, 4, 6, "de 4 a 6 removibles")
	assert_true(level.uses_resources())


func test_there_are_40_to_45_free_cells_and_free_2x2_blocks_for_the_mortar() -> void:
	var level: LevelData = _load(12)
	var free: int = 0
	for row: String in level.map_rows:
		free += row.count(".")
	assert_between(free, 40, 46, "espacio limitado a propósito, como el 10")
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	for origin: Vector2i in MORTAR_BLOCKS:
		assert_true(game.build_controller.cells_free(mortar, origin), "bloque libre en %s" % origin)


func test_the_mirror_debuts_alone_in_wave_4_to_6_and_nothing_else_is_new() -> void:
	var level: LevelData = _load(12)
	var known: Array = _enemies_of(_load(11))
	for n: int in [6, 7, 8, 9, 10]:
		for id: Variant in _enemies_of(_load(n)):
			if not known.has(id):
				known.append(id)
	assert_true(known.has("shaman"), "el Chamán ya debutó en el 11")
	assert_false(known.has("mirror"), "el Espejo nunca apareció en la campaña")
	for id: Variant in _enemies_of(level):
		assert_true(id == "mirror" or known.has(id), "%s ya apareció antes del 12" % id)
	var first: int = _first_wave_with(level, ["mirror"])
	assert_between(first, 4, 6, "RF-475 punto 1: debuta en la oleada 4 a 6")
	var ids: Array = _ids_of_wave(level.waves[first - 1])
	for banned: String in ["shaman", "guardian", "healer"]:
		assert_false(ids.has(banned), "la primera oleada del Espejo no trae %s" % banned)


func test_known_enemies_mix_from_wave_8_and_the_mirror_joins_them_from_wave_12() -> void:
	var level: LevelData = _load(12)
	var first_mix: int = 0
	for i: int in level.waves.size():
		var ids: Array = _ids_of_wave(level.waves[i])
		var auras: bool = ids.has("guardian") or ids.has("healer") or ids.has("shaman")
		if i + 1 < 8:
			assert_false(auras, "oleada %d: el Chamán, el Guardián y el Curandero se mezclan desde la 8" % (i + 1))
		if first_mix == 0 and auras:
			first_mix = i + 1
		if i + 1 < 12 and ids.has("mirror") and i + 1 != _first_wave_with(level, ["mirror"]):
			assert_false(auras, "oleada %d: el Espejo todavía no se junta con las auras" % (i + 1))
	assert_eq(first_mix, 8)
	var together: int = 0
	for i: int in range(11, level.waves.size()):
		var ids: Array = _ids_of_wave(level.waves[i])
		if ids.has("mirror") and (ids.has("guardian") or ids.has("healer") or ids.has("shaman")):
			together += 1
	assert_gte(together, 4, "desde la 12 el Espejo viaja con auras y aturdimiento")
	assert_between(_first_wave_with(level, ["boss"]), 9, 13, "el Soberano aparece a mitad del nivel")


func test_rammer_has_something_to_hit_at_every_corner_and_removables_do_not_cover_it() -> void:
	var level: LevelData = _load(12)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(_corners(grid).size(), 9, "las 9 esquinas del zigzag (la primera, de solo 3 casillas, no cuenta)")
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


func test_the_forest_pays_for_a_mortar_in_two_waves_and_the_level_works_without_it() -> void:
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	assert_eq(game.session.resources, 0, "empieza sin recursos")
	assert_false(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "sin recursos no se compra")
	game.session.earn(1000)
	assert_true(game.infrastructure.enable(FOREST), "se habilita por 100 de oro")
	assert_eq(game.session.gold, 440 + 1000 - 100)
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 4)
	assert_true(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "300 de oro y 3 recursos")
	assert_eq(game.session.resources, 1)


func test_free_cells_exist_inside_and_outside_the_mirror_reach_but_inside_the_sniper_reach() -> void:
	# RF-284 en el mapa real: una torre pegada al camino queda a menos de 2,5 casillas del Espejo (rebota); desde otra
	# casilla libre entre 3 y 5,5 casillas el Espejo no devuelve el tiro y el Francotirador (alcance 6) todavía llega.
	_start()
	var level: LevelData = game.level_data
	var path: Path2D = game.level.get_ground_path(0)
	var sniper_range: float = Rules.tiles_to_px((load("res://data/towers/sniper.tres") as TowerData).levels[0].range_tiles)
	var mirror_range: float = Rules.tiles_to_px((load("res://data/enemies/mirror.tres") as EnemyData).reflect_range_tiles)
	for tiles: int in [12, 25, 40, 55]:
		var point: Vector2 = path.to_global(path.curve.sample_baked(Rules.tiles_to_px(tiles)))
		var inside: int = 0
		var outside: int = 0
		for y: int in level.map_rows.size():
			for x: int in level.map_rows[y].length():
				if level.map_rows[y][x] != ".":
					continue
				var distance: float = point.distance_to(game.level.cell_center(Vector2i(x, y)))
				if distance < mirror_range:
					inside += 1
				elif distance < sniper_range:
					outside += 1
		assert_gt(inside, 0, "a %d casillas del inicio hay torres a menos de 2,5 del Espejo" % tiles)
		assert_gt(outside, 0, "a %d casillas del inicio hay lugares fuera del rebote que el Francotirador alcanza" % tiles)
