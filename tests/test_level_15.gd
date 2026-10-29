# T234: el nivel 15 (La Central) cierra la campaña: un mapa de pradera de 26 × 12 con tres entradas, la central de
# energía en cuatro cuartos junto a la salida y la cadena de abastecimiento como decoración permanente (RF-480), una
# mina y dos bosques explotables, y el Coloso (RF-481 a RF-483) con su escolta en las últimas oleadas. Lo que tienen en
# común los niveles del bloque 3 está en test_block3_levels.gd; el Coloso, en test_colossus.gd; el epílogo, en
# test_epilogue.gd.
extends GutTest

const PATH: String = "user://test_level_15.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DOC_PATH: String = "res://specs/11-textos-lore.md"

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


func _start(n: int = 15) -> void:
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


## Las oleadas (número, desde 1) que nombran a `enemy`.
func _waves_with(level: LevelData, enemy: String) -> Array[int]:
	var found: Array[int] = []
	for i: int in level.waves.size():
		if _ids_of_wave(level.waves[i]).has(enemy):
			found.append(i + 1)
	return found


## Las entradas por las que sale un conjunto completo de escolta (Guardián, Curandero y Chamán con el mismo `desde` y la
## misma entrada) en una oleada.
func _full_escorts(wave: WaveData) -> Array[int]:
	var sets: Dictionary = {}
	for group: SpawnGroup in wave.groups:
		var key: String = "%d@%s" % [group.entrance_index, str(group.start_delay)]
		if not sets.has(key):
			sets[key] = {"entrance": group.entrance_index, "ids": []}
		(sets[key]["ids"] as Array).append(String(group.enemy.id))
	var full: Array[int] = []
	for key: String in sets:
		var ids: Array = sets[key]["ids"]
		if ids.has("guardian") and ids.has("healer") and ids.has("shaman"):
			full.append(sets[key]["entrance"])
	return full


## Las casillas de un dibujo de la leyenda: dibujo → [casillas].
func _drawn_cells(level: LevelData) -> Dictionary:
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	var found: Dictionary = {}
	for cell: Vector2i in grid.legend_cells:
		var drawing: String = grid.legend_cells[cell]
		if not found.has(drawing):
			found[drawing] = []
		(found[drawing] as Array).append(cell)
	return found


# --- La campaña y el mapa ---

func test_level_15_closes_the_campaign_in_the_valley_with_three_entrances() -> void:
	assert_eq(LevelFile.campaign_ids().slice(13, 15), PackedStringArray(["level_14", "level_15"]))
	assert_eq(LevelFile.campaign_ids().size(), 15, "la campaña tiene 15 niveles")
	var level: LevelData = _load(15)
	assert_eq(level.display_name, "Central")
	assert_eq(level.theme, &"pradera", "el valle, como el oasis: el círculo se cierra")
	assert_eq(level.waves.size(), 30)
	assert_eq(level.starting_gold, 520)
	assert_eq(level.starting_lives, 20)
	assert_gt(level.health_scale_percent_per_wave, 0, "el nivel trae su propio aumento de vida")
	assert_false(level.machine_enabled, "sin demoledora")
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_eq(grid.errors.size(), 0)
	assert_eq(Vector2i(grid.width, grid.height), Vector2i(26, 12), "el máximo de RF-250")
	assert_eq(grid.routes.size(), 3, "tres entradas: A, B y C")
	for route: Array in grid.routes:
		assert_gte(route.size(), 60, "caminos largos")
		assert_eq(route[route.size() - 1], grid.exit_cell, "las tres llegan a la misma salida")
	assert_eq(grid.unused_cells.size(), 0, "no sobra ninguna casilla de camino")


func test_the_legend_uses_the_twelve_letters_d093_allows() -> void:
	var level: LevelData = _load(15)
	assert_lte(level.legend.size(), LevelFile.MAX_LEGEND)
	assert_gt(level.legend.size(), 10, "D-093: es por este nivel que el tope subió de 10 a 12")


func test_the_central_is_four_quarters_next_to_the_exit_not_the_exit_itself() -> void:
	var level: LevelData = _load(15)
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	var drawn: Dictionary = _drawn_cells(level)
	var quarters: Array[Vector2i] = []
	for id: String in ["central_1", "central_2", "central_3", "central_4"]:
		assert_eq((drawn.get(id, []) as Array).size(), 1, "un solo %s" % id)
		quarters.append((drawn[id] as Array)[0])
	# NO, NE, SO, SE: una cuadrícula de 2 × 2, en ese orden.
	assert_eq(quarters[1], quarters[0] + Vector2i.RIGHT)
	assert_eq(quarters[2], quarters[0] + Vector2i.DOWN)
	assert_eq(quarters[3], quarters[0] + Vector2i(1, 1))
	var touches_exit: bool = false
	for cell: Vector2i in quarters:
		assert_ne(grid.cell_type(cell), MapGrid.Cell.PATH, "la central no es camino")
		assert_ne(cell, grid.exit_cell, "la salida sigue siendo la salida")
		assert_false(level.map_rows[cell.y][cell.x] == ".", "no se construye sobre la central")
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if cell + step == grid.exit_cell:
				touches_exit = true
	assert_true(touches_exit, "la central está al lado de la salida")
	for cell: Vector2i in quarters:
		assert_false(grid.removable_cells.has(cell))


func test_the_central_cannot_be_built_on_nor_crossed() -> void:
	_start()
	var grid: MapGrid = MapGrid.parse(game.level_data.map_rows, game.level_data.legend)
	var drawn: Dictionary = _drawn_cells(game.level_data)
	var cannon: TowerData = load("res://data/towers/cannon.tres")
	game.session.earn(1000)
	for id: String in ["central_1", "central_2", "central_3", "central_4"]:
		var cell: Vector2i = (drawn[id] as Array)[0]
		assert_false(game.level.is_buildable(cell), "%s no es construible" % id)
		assert_false(game.build_controller.try_build(cannon, cell), "%s no admite torres" % id)
	assert_eq(grid.routes.size(), 3)


func test_two_to_four_supply_pieces_along_the_border_and_two_or_three_empty_camps() -> void:
	var level: LevelData = _load(15)
	var drawn: Dictionary = _drawn_cells(level)
	var pieces: int = 0
	for id: String in ["supply_depot", "supply_line_pole", "supply_cart"]:
		for cell: Vector2i in drawn.get(id, []):
			pieces += 1
			assert_true(cell.x == 0 or cell.y == 0 or cell.x == 25 or cell.y == 11, "%s en %s: a lo largo del borde" % [id, cell])
	assert_between(pieces, 2, 4, "de 2 a 4 piezas de la cadena (RF-480 pide al menos dos)")
	assert_between((drawn.get("campamento_vacio", []) as Array).size(), 2, 3, "dos o tres campamentos vacíos")
	assert_gte((drawn.get("roca_marcada", []) as Array).size(), 1, "la roca marcada de nuevo, como en el 1")


func test_one_mine_two_forests_four_to_six_removables_and_no_findings() -> void:
	var level: LevelData = _load(15)
	var classes: Array = []
	var removables: int = 0
	for obstacle: ObstacleSpec in level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.EXTRACTION:
			classes.append(String(obstacle.class_id))
			assert_eq(obstacle.cost, 100, "Q-19: 100 de oro")
			assert_eq(obstacle.production, 2, "Q-19: 2 por oleada")
			assert_eq(obstacle.reserve, 8, "Q-19: reserva de 8 cada uno")
			continue
		removables += 1
		assert_eq(obstacle.finding_collection, &"", "sin hallazgos")
		assert_between(obstacle.chance_percent, 1, 99, "al azar, con semilla (RF-417)")
	classes.sort()
	assert_eq(classes, ["bosque_explotable", "bosque_explotable", "mina"])
	assert_between(removables, 4, 6, "de 4 a 6 removibles")
	assert_true(level.uses_resources())


func test_about_sixty_five_free_cells_and_four_free_2x2_blocks() -> void:
	var level: LevelData = _load(15)
	var free: int = 0
	for row: String in level.map_rows:
		free += row.count(".")
	assert_between(free, 58, 72, "unas 65 casillas libres")
	var taken: Dictionary = {}
	var blocks: int = 0
	for y: int in level.map_rows.size() - 1:
		for x: int in level.map_rows[y].length() - 1:
			var cells: Array[Vector2i] = [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]
			var all_free: bool = true
			for cell: Vector2i in cells:
				if level.map_rows[cell.y][cell.x] != "." or taken.has(cell):
					all_free = false
			if all_free:
				blocks += 1
				for cell: Vector2i in cells:
					taken[cell] = true
	assert_gte(blocks, 4, "al menos cuatro bloques de 2×2 (para el Mortero)")


# --- Las oleadas y el Coloso (RF-480, RF-483) ---

func test_the_sovereign_is_not_in_the_level_and_the_shard_is_never_named() -> void:
	var level: LevelData = _load(15)
	var present: Array = _enemies_of(level)
	assert_false(present.has("boss"), "el Soberano no está en el 15")
	assert_false(present.has("colossus_shard"), "el Pedazo no se nombra en ninguna oleada: solo lo suelta el Coloso")
	assert_true(present.has("colossus"))


func test_the_colossus_comes_in_waves_26_28_and_30_one_each_and_never_before() -> void:
	var level: LevelData = _load(15)
	assert_eq(_waves_with(level, "colossus"), [26, 28, 30] as Array[int])
	for number: int in [26, 28, 30]:
		var count: int = 0
		for group: SpawnGroup in level.waves[number - 1].groups:
			if group.enemy.id == &"colossus":
				count += group.count
		assert_gte(count, 1, "oleada %d: al menos un Coloso" % number)
	assert_true(_ids_of_wave(level.waves[29]).has("colossus"), "siempre sale en la 30, la última")


func test_the_full_escort_comes_with_the_colossus_only_in_wave_30_and_by_several_entrances() -> void:
	var level: LevelData = _load(15)
	for number: int in [26, 28]:
		assert_eq(_full_escorts(level.waves[number - 1]).size(), 0, "oleada %d: el Coloso sin la escolta completa" % number)
	var entrances: Array[int] = _full_escorts(level.waves[29])
	assert_gte(entrances.size(), 2, "en la 30, la escolta completa sale en formación por varias entradas (RF-203)")
	var distinct: Array[int] = []
	for entrance: int in entrances:
		if not distinct.has(entrance):
			distinct.append(entrance)
	assert_gte(distinct.size(), 2, "por entradas distintas")
	# Y cada miembro sale con el Coloso en la misma oleada.
	assert_true(_ids_of_wave(level.waves[29]).has("colossus"))


func test_the_colossus_debuts_with_only_known_enemies_and_after_a_lighter_wave() -> void:
	var level: LevelData = _load(15)
	var before: Array = []
	for i: int in 25:
		for id: String in _ids_of_wave(level.waves[i]):
			if not before.has(id):
				before.append(id)
	for id: String in _ids_of_wave(level.waves[25]):
		if id != "colossus":
			assert_true(before.has(id), "oleada 26: %s ya apareció (RF-475, punto 1)" % id)
	assert_false(before.has("colossus"))
	# «Con tiempo de preparación antes»: la oleada 25 es más liviana que la 24 (menos enemigos en total).
	var totals: Array[int] = []
	for i: int in [23, 24]:
		var total: int = 0
		for group: SpawnGroup in level.waves[i].groups:
			total += group.count
		totals.append(total)
	assert_lt(totals[1], totals[0], "la 25 es un respiro frente a la 24")


func test_all_the_other_threats_are_known_from_the_earlier_levels() -> void:
	var level: LevelData = _load(15)
	var known: Array = []
	for n: int in range(6, 15):
		for id: Variant in _enemies_of(_load(n)):
			if not known.has(id):
				known.append(id)
	for id: Variant in _enemies_of(level):
		if String(id) != "colossus":
			assert_true(known.has(id), "%s ya apareció antes del 15" % id)


func test_only_the_fifteenth_names_the_colossus_in_any_level_of_the_game() -> void:
	for dir_path: String in ["res://data/levels/", "res://data/modos/"]:
		for file_name: String in DirAccess.get_files_at(dir_path):
			if file_name.ends_with(".json") and file_name != "level_15.json":
				var text: String = FileAccess.get_file_as_string(dir_path + file_name)
				assert_false(text.contains("colossus"), "%s%s nombra al Coloso" % [dir_path, file_name])
	var own: String = FileAccess.get_file_as_string("res://data/levels/level_15.json")
	assert_true(own.contains("\"colossus\""))
	assert_false(own.contains("colossus_shard"))
	assert_false(own.contains("\"boss\""))


func test_entrances_exist_and_all_three_are_used() -> void:
	var level: LevelData = _load(15)
	var used: Array[int] = []
	for wave: WaveData in level.waves:
		for group: SpawnGroup in wave.groups:
			assert_lt(group.entrance_index, 3)
			if not used.has(group.entrance_index):
				used.append(group.entrance_index)
	used.sort()
	assert_eq(used, [0, 1, 2] as Array[int])


func test_the_mine_and_the_forests_pay_a_mortar() -> void:
	_start()
	var drawn: Dictionary = _drawn_cells(game.level_data)
	var mine: Vector2i = (drawn["mina"] as Array)[0] if drawn.has("mina") else Vector2i(-1, -1)
	var forests: Array = []
	for obstacle: ObstacleSpec in game.level_data.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.EXTRACTION:
			if obstacle.class_id == &"mina":
				mine = obstacle.cell
			else:
				forests.append(obstacle.cell)
	assert_eq(forests.size(), 2)
	game.session.earn(1000)
	assert_true(game.infrastructure.enable(mine), "la mina se habilita por 100 de oro")
	for forest: Vector2i in forests:
		assert_true(game.infrastructure.enable(forest), "los bosques también")
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()
	assert_eq(game.session.resources, 6, "2 de la mina y 2 de cada bosque en una sola oleada")


# --- Los textos y la Wiki Lore ---

func test_the_place_the_entry_and_the_victory_are_the_approved_ones() -> void:
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var section: String = doc.split("### Nivel 15 · Central")[1].split("## 2. Epílogo")[0]
	var place: String = ""
	var entry: PackedStringArray = []
	var victory: PackedStringArray = []
	var field: String = ""
	for raw: String in section.split("\n"):
		if raw.begins_with("- **Lugar**"):
			place = raw.split("): ")[1].strip_edges()
		elif raw.begins_with("- **Entrada**"):
			field = "entrada"
		elif raw.begins_with("- **Victoria**"):
			field = "victoria"
		elif raw.begins_with("  - "):
			(entry if field == "entrada" else victory).append(raw.substr(4).strip_edges())
	var level: LevelData = _load(15)
	assert_eq(level.place_text, place)
	assert_eq(level.intro_text, "\n".join(entry))
	assert_eq(level.win_text, "\n".join(victory))
	assert_ne(level.epilogue_text, "", "el 15 es el único con epílogo")
	for n: int in range(1, 15):
		assert_eq(_load(n).epilogue_text, "", "el nivel %d no tiene epílogo" % n)


func test_winning_the_fifteenth_opens_the_central_article_with_the_colossus_paragraph() -> void:
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var paragraph: String = ""
	for raw: String in doc.split("### 10. La Central")[1].split("## 5.")[0].split("\n"):
		if raw.contains("Los colonos lo llaman el Coloso"):
			paragraph = raw.strip_edges().trim_prefix("> ")
	assert_ne(paragraph, "", "el párrafo está en 11-textos-lore.md §4.10")
	var lore: WikiCategory = null
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, Callable(), SaveManager.is_completed):
		if category.id == &"lore":
			lore = category
	var closed: WikiEntry = lore.find(&"la_central")
	assert_true(closed.locked, "antes de ganar el 15 está cerrado")
	assert_string_contains(closed.plain_text(), "Se abre al ganar el nivel 15.")
	assert_false(closed.plain_text().contains("Coloso"), "y no adelanta nada")
	SaveManager.record_victory(&"level_15", 10, 100)
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, Callable(), SaveManager.is_completed):
		if category.id == &"lore":
			lore = category
	var open: WikiEntry = lore.find(&"la_central")
	assert_false(open.locked)
	assert_string_contains(open.plain_text(), paragraph)
	assert_string_contains(paragraph, "tres", "si el número de Pedazos cambia, se corrige también este texto")
	assert_eq(load("res://data/enemies/colossus.tres").death_spawn_count, 3)


func test_with_the_fifteen_levels_won_the_lore_has_eleven_open_articles() -> void:
	for id: String in LevelFile.campaign_ids():
		SaveManager.record_victory(StringName(id), 10, 100)
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, Callable(), SaveManager.is_completed):
		if category.id == &"lore":
			assert_eq(category.entries.size(), 11, "los 10 de 11-textos-lore.md y «La Cuadrilla» (T253)")
			assert_eq(category.unlocked_count(), 11)
			assert_false(category.has_locked())
