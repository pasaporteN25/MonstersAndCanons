# Tests de los niveles de la campaña y de las entradas múltiples (T43-T45).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var campaign: CampaignData = GameFlow.campaign


func _game_with_level(index: int) -> Game:
	var game: Game = GAME_SCENE.instantiate()
	game.level_data = campaign.levels[index]
	add_child_autofree(game)
	return game


# --- Campaña (spec §7) ---

func test_campaign_has_fifteen_levels_in_order() -> void:
	var ids: Array[StringName] = []
	for level: LevelData in campaign.levels:
		ids.append(level.id)
	assert_eq(ids, [&"level_01", &"level_02", &"level_03", &"level_04", &"level_05", &"level_06", &"level_07", &"level_08", &"level_09", &"level_10", &"level_11", &"level_12", &"level_13", &"level_14", &"level_15"] as Array[StringName])


func test_levels_match_spec_table() -> void:
	# [oleadas, oro inicial, entradas]
	var expected: Array = [[10, 150, 1], [15, 200, 1], [20, 250, 2], [15, 200, 1], [20, 300, 3], [15, 250, 2], [20, 300, 2], [18, 300, 1], [20, 320, 2], [20, 360, 2], [22, 420, 1], [24, 440, 1], [24, 460, 2], [26, 480, 2], [30, 520, 3]]
	for i: int in expected.size():
		var game: Game = _game_with_level(i)
		assert_eq(game.level_data.waves.size(), expected[i][0], "nivel %d: oleadas" % (i + 1))
		assert_eq(game.session.gold, expected[i][1], "nivel %d: oro inicial" % (i + 1))
		assert_eq(game.level.entrance_count(), expected[i][2], "nivel %d: entradas" % (i + 1))
		assert_eq(game.session.lives, 20, "nivel %d: vidas" % (i + 1))


func test_every_level_is_20_by_9_but_the_tenth_to_the_fifteenth() -> void:
	for i: int in campaign.levels.size():
		var game: Game = _game_with_level(i)
		# T225, T229 a T232 y T234: los niveles 10 a 15 usan un mapa grande (RF-250): 24 × 11, 24 × 11, 26 × 11 y tres de 26 × 12.
		var size: Rect2i = Rect2i(0, 0, 20, 9)
		if i == 9 or i == 10:
			size = Rect2i(0, 0, 24, 11)
		elif i == 11:
			size = Rect2i(0, 0, 26, 11)
		elif i >= 12:
			size = Rect2i(0, 0, 26, 12)
		assert_eq(game.level.ground.get_used_rect(), size, "nivel %d: RF-01 / RF-250" % (i + 1))


func test_entrance_indexes_exist_in_their_map() -> void:
	for i: int in campaign.levels.size():
		var game: Game = _game_with_level(i)
		for w: int in game.level_data.waves.size():
			for group: SpawnGroup in game.level_data.waves[w].groups:
				assert_lt(group.entrance_index, game.level.entrance_count(),
					"nivel %d, oleada %d: la entrada existe" % [i + 1, w + 1])


# --- Varias entradas (T44) ---

func _spawn_from_entrance(game: Game, entrance: int) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = load("res://data/enemies/normal.tres")
	group.count = 1
	group.entrance_index = entrance
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1)


func test_each_group_comes_out_of_its_entrance() -> void:
	var game: Game = _game_with_level(2)
	var top: Enemy = _spawn_from_entrance(game, 0)
	var bottom: Enemy = _spawn_from_entrance(game, 1)
	assert_lt(top.global_position.y, bottom.global_position.y, "entrada 0 arriba, entrada 1 abajo")
	assert_almost_eq(top.global_position.y, game.level.cell_center(Vector2i(0, 1)).y, 1.0)
	assert_almost_eq(bottom.global_position.y, game.level.cell_center(Vector2i(0, 7)).y, 1.0)


func test_both_entrances_lead_to_the_same_exit() -> void:
	var game: Game = _game_with_level(2)
	var ends: Array[Vector2] = []
	for i: int in 2:
		var path: Path2D = game.level.get_ground_path(i)
		ends.append(path.to_global(path.curve.get_point_position(path.curve.point_count - 1)))
	assert_eq(ends[0], ends[1])


# --- Salidas dentro del mapa y entradas por arriba (RF-06, T60) ---

func test_only_the_spiral_and_the_cross_have_their_exit_inside_the_map() -> void:
	for i: int in campaign.levels.size():
		var game: Game = _game_with_level(i)
		var expected: Array[Vector2i] = []
		if i == 3:
			expected.append(Vector2i(5, 5))  # la puerta del centro de la Espiral
		elif i == 6:
			expected.append(Vector2i(10, 4))  # la puerta del centro del Cruce (spec §7.9)
		assert_eq(game.level.inner_exit_cells(), expected, "nivel %d" % (i + 1))


func test_fortress_entrance_c_comes_from_the_top() -> void:
	var game: Game = _game_with_level(4)
	var enemy: Enemy = _spawn_from_entrance(game, 2)
	var top_of_map: float = game.level.cell_center(Vector2i(13, 0)).y - Rules.TILE_SIZE / 2.0
	assert_lt(enemy.global_position.y, top_of_map, "empieza por encima del mapa")
	assert_almost_eq(enemy.global_position.x, game.level.cell_center(Vector2i(13, 0)).x, 1.0)


func test_all_fortress_entrances_share_the_exit() -> void:
	var game: Game = _game_with_level(4)
	var ends: Array[Vector2] = []
	for i: int in 3:
		var path: Path2D = game.level.get_ground_path(i)
		ends.append(path.to_global(path.curve.get_point_position(path.curve.point_count - 1)))
	assert_eq(ends[0], ends[1])
	assert_eq(ends[1], ends[2])


# --- Vida por oleada propia de cada nivel (D-019) ---

func test_levels_use_their_health_scale() -> void:
	var balance: BalanceConfig = load("res://data/balance.tres")
	assert_eq(campaign.levels[0].health_scale_percent(balance), 40, "spec §7.4: nivel 1, el general")
	assert_eq(campaign.levels[1].health_scale_percent(balance), 35, "spec §7.4: nivel 2")
	assert_eq(campaign.levels[2].health_scale_percent(balance), 20, "spec §7.4: nivel 3")
	assert_eq(campaign.levels[3].health_scale_percent(balance), 20, "spec §7.4: nivel 4")
	assert_eq(campaign.levels[4].health_scale_percent(balance), 10, "spec §7.4: nivel 5")


func test_level_can_override_health_scale() -> void:
	var balance: BalanceConfig = load("res://data/balance.tres")
	var level := LevelData.new()
	assert_eq(level.health_scale_percent(balance), balance.health_scale_percent_per_wave, "0 = el general")
	level.health_scale_percent_per_wave = 25
	assert_eq(level.health_scale_percent(balance), 25)


func test_scaled_health_percent() -> void:
	assert_eq(Rules.scaled_health_percent(30, 1, 25), 30)
	assert_eq(Rules.scaled_health_percent(30, 3, 25), 45, "30 × 1.5")
