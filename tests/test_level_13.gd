# T231: el nivel 13 (Paso alto) es un paso de nieve de 26 × 12 con dos entradas que se unen, una laguna de hielo, una mina
# y un bosque explotable (uno por entrada), cinco removibles y las escoltas coordinadas (Guardián + Curandero + Chamán con el
# mismo `desde`), sin ningún debut (RF-478). Lo que tienen en común los niveles del bloque 3 está en test_block3_levels.gd.
extends GutTest

const PATH: String = "user://test_level_13.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const MINE: Vector2i = Vector2i(10, 1)
const FOREST: Vector2i = Vector2i(11, 10)
## Bloques libres de 2×2 pensados para el Mortero (esquina de arriba a la izquierda, (columna, fila)).
const MORTAR_BLOCKS: Array[Vector2i] = [Vector2i(4, 1), Vector2i(12, 1), Vector2i(5, 4), Vector2i(18, 7)]

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


func _start(n: int = 13) -> void:
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


## Los miembros de la escolta que salen juntos (misma entrada y mismo `desde`) en una oleada: una lista de {entrada, desde}
## por cada conjunto completo (Guardián, Curandero y Chamán).
func _escorts(wave: WaveData) -> Array:
	var sets: Dictionary = {}
	for group: SpawnGroup in wave.groups:
		var key: String = "%d@%s" % [group.entrance_index, str(group.start_delay)]
		if not sets.has(key):
			sets[key] = {"entrance": group.entrance_index, "ids": []}
		(sets[key]["ids"] as Array).append(String(group.enemy.id))
	var full: Array = []
	for key: String in sets:
		var ids: Array = sets[key]["ids"]
		if ids.has("guardian") and ids.has("healer") and ids.has("shaman"):
			full.append(sets[key]["entrance"])
	return full


func test_level_13_follows_the_twelfth_in_a_snowy_pass_of_26_by_12_with_two_entrances() -> void:
	assert_eq(LevelFile.campaign_ids().slice(11, 13), PackedStringArray(["level_12", "level_13"]))
	var level: LevelData = _load(13)
	assert_eq(level.display_name, "Paso alto")
	assert_eq(level.theme, &"nieve")
	assert_eq(level.waves.size(), 24)
	assert_eq(level.starting_gold, 460)
	assert_eq(level.starting_lives, 20)
	assert_gt(level.health_scale_percent_per_wave, 0, "el nivel trae su propio aumento de vida")
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(grid.errors.size(), 0)
	assert_eq(Vector2i(grid.width, grid.height), Vector2i(26, 12), "RF-250: el mapa más grande")
	assert_eq(grid.routes.size(), 2, "dos entradas")
	for route: Array in grid.routes:
		assert_gte(route.size(), 70, "caminos largos")
	var a: Array = grid.routes[0]
	var b: Array = grid.routes[1]
	assert_ne(a[0], b[0], "entran por lugares distintos")
	assert_eq(a[a.size() - 1], b[b.size() - 1], "y llegan a la misma salida")
	var shared: int = 0
	for i: int in range(1, mini(a.size(), b.size())):
		if a[a.size() - i] == b[b.size() - i]:
			shared += 1
		else:
			break
	assert_gte(shared, 20, "los dos recorridos se unen y comparten un tramo largo hasta la salida")


func test_an_ice_lagoon_markers_a_mine_and_a_forest_one_per_entrance_and_five_removables() -> void:
	var level: LevelData = _load(13)
	var ice: int = 0
	var markers: int = 0
	for row: String in level.map_rows:
		for letter: String in row:
			var legend: Dictionary = level.legend.get(letter, {})
			if legend.get("dibujo", "") == "hielo":
				ice += 1
				assert_false(legend.get("construible", false), "el hielo no se construye")
			elif legend.get("dibujo", "") == "roca_marcada":
				markers += 1
	assert_gte(ice, 4, "una laguna de hielo")
	assert_between(markers, 3, 4, "tres o cuatro hitos a lo largo de los dos caminos (roca marcada mientras el dibujo del hito no llega)")
	var classes: Array = []
	var removables: int = 0
	for obstacle: ObstacleSpec in level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.EXTRACTION:
			classes.append(String(obstacle.class_id))
			assert_eq(obstacle.cost, 100, "Q-19: 100 de oro")
			assert_eq(obstacle.production, 2, "Q-19: 2 por oleada")
			assert_eq(obstacle.reserve, 8, "Q-19: reserva de 8")
			continue
		removables += 1
		assert_eq(obstacle.finding_collection, &"", "sin hallazgos")
		assert_eq(obstacle.reward_amount, 1)
		assert_between(obstacle.chance_percent, 1, 99, "al azar, con semilla (RF-417)")
	classes.sort()
	assert_eq(classes, ["bosque_explotable", "mina"], "una mina y un bosque explotable (16 recursos en total si se habilitan los dos)")
	assert_between(removables, 4, 6, "de 4 a 6 removibles")
	assert_true(level.uses_resources())


func test_the_mine_and_the_forest_are_near_their_own_entrance() -> void:
	var level: LevelData = _load(13)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	var a_end: Vector2i = (grid.routes[0] as Array)[0]
	var b_end: Vector2i = (grid.routes[1] as Array)[0]
	assert_lt(Vector2(MINE).distance_to(Vector2(a_end)), Vector2(MINE).distance_to(Vector2(b_end)), "la mina, del lado de la entrada A")
	assert_lt(Vector2(FOREST).distance_to(Vector2(b_end)), Vector2(FOREST).distance_to(Vector2(a_end)), "el bosque, del lado de la entrada B")


func test_there_are_about_sixty_free_cells_and_free_2x2_blocks_for_the_mortar() -> void:
	var level: LevelData = _load(13)
	var free: int = 0
	for row: String in level.map_rows:
		free += row.count(".")
	assert_between(free, 55, 65, "unas 60 casillas libres repartidas entre los dos tramos")
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	for origin: Vector2i in MORTAR_BLOCKS:
		assert_true(game.build_controller.cells_free(mortar, origin), "bloque libre en %s" % origin)


func test_no_enemy_debuts_and_the_mirror_and_the_auras_are_known() -> void:
	var level: LevelData = _load(13)
	var known: Array = []
	for n: int in [6, 7, 8, 9, 10, 11, 12]:
		for id: Variant in _enemies_of(_load(n)):
			if not known.has(id):
				known.append(id)
	for id: Variant in _enemies_of(level):
		assert_true(known.has(id), "%s ya apareció antes del 13" % id)
	assert_between(_first_wave_with(level, ["boss"]), 9, 13, "el Soberano aparece a mitad del nivel")


func test_the_escort_comes_together_first_through_one_entrance_and_from_wave_14_through_both() -> void:
	var level: LevelData = _load(13)
	var with_escort: int = 0
	var first_escort: int = 0
	var both: int = 0
	for i: int in level.waves.size():
		var escorts: Array = _escorts(level.waves[i])
		if escorts.is_empty():
			continue
		with_escort += 1
		if first_escort == 0:
			first_escort = i + 1
			assert_eq(escorts.size(), 1, "la primera escolta completa entra por una sola entrada")
		if escorts.has(0) and escorts.has(1):
			both += 1
			assert_gte(i + 1, 14, "oleada %d: por las dos entradas recién desde la 14" % (i + 1))
	assert_gte(with_escort, 6, "la escolta completa viene en al menos 6 oleadas (RF-478)")
	assert_between(first_escort, 8, 10, "la primera escolta completa entra en la oleada 8 a 10")
	assert_gte(both, 2, "y desde la 14, por las dos entradas a la vez en al menos 2 oleadas")


func test_rammer_has_something_to_hit_at_every_corner_and_removables_do_not_cover_it() -> void:
	var level: LevelData = _load(13)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_gte(_corners(grid).size(), 4, "varias esquinas de rectas largas")
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


func test_the_mine_and_the_forest_together_pay_a_mortar_after_one_wave() -> void:
	_start()
	var mortar: TowerData = load("res://data/towers/mortar.tres")
	game.session.earn(1000)
	assert_true(game.infrastructure.enable(MINE), "la mina se habilita por 100 de oro")
	assert_true(game.infrastructure.enable(FOREST), "el bosque también")
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 4, "2 de la mina y 2 del bosque en una sola oleada")
	assert_true(game.build_controller.try_build(mortar, MORTAR_BLOCKS[0]), "300 de oro y 3 recursos")
	assert_eq(game.session.resources, 1)
