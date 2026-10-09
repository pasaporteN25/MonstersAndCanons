# T229 a T232: lo que tienen en común los niveles 11 a 14 del bloque 3 (RF-474 y RF-475): la rotación de torres
# sin Ametralladora, la apertura viable con Hielo y una torre de 90 a 110, la escalera de oro y de aumento de vida,
# sin demoledora y con recursos. Cada nivel tiene además su propio archivo (test_level_11.gd, etc.).
extends GutTest

const PATH: String = "user://test_block3_levels.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## RF-474: las torres de la campaña menos la Ametralladora.
const ROTATION: Array[String] = ["frost", "cannon", "sniper", "fire", "multi", "burst", "tesla", "mortar", "disruptor", "mechanical_standard"]
## Los niveles del bloque 3 que ya existen (T229 a T232) y su oro inicial según la ficha (§7.13 a §7.16).
const GOLD: Dictionary = {11: 420, 12: 440, 13: 460, 14: 480}

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


## Los números de los niveles del bloque 3 que están en la campaña.
func _block() -> Array[int]:
	var result: Array[int] = []
	for n: int in GOLD:
		if LevelFile.campaign_ids().has("level_%02d" % n):
			result.append(n)
	return result


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	assert_eq(result["warnings"], PackedStringArray(), "nivel %d sin avisos" % n)
	return result["level"]


func _start(n: int) -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_load(n)] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _ids(towers: Array[TowerData]) -> Array:
	return towers.map(func(tower: TowerData) -> String: return String(tower.id))


func test_the_block_is_in_the_campaign_in_order_after_the_tenth() -> void:
	assert_gte(_block().size(), 1, "al menos el 11")
	var ids: PackedStringArray = LevelFile.campaign_ids()
	for n: int in _block():
		assert_eq(ids.find("level_%02d" % n), n - 1, "el nivel %d está en su lugar de la campaña" % n)


func test_every_level_offers_the_rotation_without_the_machine_gun_and_without_the_machine() -> void:
	for n: int in _block():
		var level: LevelData = _load(n)
		var listed: Array = []
		for id: String in level.towers:
			listed.append(id)
		var expected: Array = ROTATION.duplicate()
		listed.sort()
		expected.sort()
		assert_eq(listed, expected, "nivel %d: `torres` de RF-474" % n)
		assert_false(listed.has("basic"), "nivel %d: sin Ametralladora" % n)
		assert_false(listed.has("launcher"), "nivel %d: sin Lanzamisiles (Q-28)" % n)
		assert_false(level.machine_enabled, "nivel %d: sin demoledora" % n)
		assert_true(level.uses_resources(), "nivel %d: tiene recursos (regla de oro)" % n)
		assert_eq(level.starting_lives, 20, "nivel %d: 20 vidas" % n)
		assert_eq(level.starting_gold, GOLD[n], "nivel %d: oro de la ficha" % n)


func test_without_collections_a_level_has_eight_towers_and_with_them_ten() -> void:
	var all: Array[TowerData] = TowerOffer.canonical_towers()
	for n: int in _block():
		var level: LevelData = _load(n)
		var without: Array = _ids(level.available_towers(all, func(_c: StringName) -> bool: return false))
		assert_eq(without.size(), 8, "nivel %d: sin colecciones, 8 torres" % n)
		assert_false(without.has("disruptor") or without.has("mechanical_standard"))
		assert_true(without.has("mortar"), "nivel %d: el Mortero no pide colección" % n)
		var with_all: Array = _ids(level.available_towers(all, func(_c: StringName) -> bool: return true))
		assert_eq(with_all.size(), 10, "nivel %d: con las colecciones, 10 torres" % n)
		assert_false(with_all.has("basic"))


func test_the_eleventh_marks_the_disruptor_as_new() -> void:
	var levels: Array[LevelData] = []
	for id: String in LevelFile.campaign_ids():
		levels.append(_load(int(id.trim_prefix("level_"))))
	assert_eq(TowerOffer.new_tower_ids(levels, 10, TowerOffer.canonical_towers()), PackedStringArray(["disruptor"]),
		"el 11 es el primero que ofrece la Disruptora; la Ametralladora no debuta: se retira")


func test_the_bar_shows_eight_towers_without_the_machine_gun_and_the_opening_is_viable() -> void:
	for n: int in _block():
		_start(n)
		assert_eq(_ids(game.available_towers).size(), 8)
		assert_false(_ids(game.available_towers).has("basic"), "nivel %d: la barra no tiene la Ametralladora" % n)
		assert_eq(game.hud._tower_buttons.size(), 8, "nivel %d: ocho botones" % n)
		# RF-474: el oro alcanza para Hielo (75) y una torre de 90 a 110 en la primera oleada.
		var frost: TowerData = load("res://data/towers/frost.tres")
		var middle: Array[TowerData] = []
		for id: String in ["fire", "cannon", "multi", "burst"]:
			middle.append(load("res://data/towers/%s.tres" % id))
		var cells: Array[Vector2i] = []
		for y: int in game.level_data.map_rows.size():
			for x: int in game.level_data.map_rows[y].length():
				if game.level_data.map_rows[y][x] == ".":
					cells.append(Vector2i(x, y))
		assert_true(game.build_controller.try_build(frost, cells[0]), "nivel %d: el Hielo se construye" % n)
		for tower: TowerData in middle:
			assert_gte(game.session.gold, tower.levels[0].cost, "nivel %d: queda oro para %s" % [n, tower.id])
		assert_between(middle[1].levels[0].cost, 90, 110)
		game.queue_free()
		await get_tree().process_frame


func test_the_gold_climbs_and_each_level_has_its_own_health_scale() -> void:
	# La ficha trae el aumento de vida como valor inicial (28, 26, 25, 24) y el bot lo ajusta nivel por nivel (T229 a T232):
	# lo que no puede faltar es que cada nivel traiga el suyo y que el oro inicial suba.
	var previous_gold: int = _load(10).starting_gold
	for n: int in _block():
		var level: LevelData = _load(n)
		assert_gt(level.starting_gold, previous_gold, "nivel %d: más oro que el anterior" % n)
		assert_between(level.health_scale_percent_per_wave, 20, 60, "nivel %d: trae su aumento de vida" % n)
		previous_gold = level.starting_gold


func test_waves_stay_inside_the_limits_and_use_known_entrances() -> void:
	for n: int in _block():
		var level: LevelData = _load(n)
		var entrances: int = MapGrid.parse(level.map_rows, level.legend).routes.size()
		assert_between(level.waves.size(), 22, 26, "nivel %d: 22 a 26 oleadas" % n)
		for i: int in level.waves.size():
			assert_lte(level.waves[i].groups.size(), LevelFile.MAX_GROUPS)
			for group: SpawnGroup in level.waves[i].groups:
				assert_lt(group.entrance_index, entrances, "nivel %d, oleada %d: la entrada existe" % [n, i + 1])
