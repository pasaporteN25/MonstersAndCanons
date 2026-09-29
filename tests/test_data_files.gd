# Comprueba que los archivos de data/ coinciden con las tablas de specs/01-spec.md (T11).
# Si cambias un número de balance, cámbialo en la spec, en el .tres y aquí (constitución P3).
extends GutTest


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id)


# --- Enemigos (spec §6) ---

func _assert_enemy(id: String, health: int, speed: float, armor: int, reward: int,
		lives: int, flying: bool, size: float) -> void:
	var e: EnemyData = _enemy(id)
	assert_not_null(e, "existe data/enemies/%s.tres" % id)
	if e == null:
		return
	assert_eq(e.id, StringName(id), "%s: id" % id)
	assert_eq(e.max_health, health, "%s: vida" % id)
	assert_almost_eq(e.speed_tiles, speed, 0.001, "%s: velocidad" % id)
	assert_eq(e.armor, armor, "%s: armadura" % id)
	assert_eq(e.reward, reward, "%s: oro" % id)
	assert_eq(e.lives_damage, lives, "%s: vidas que quita" % id)
	assert_eq(e.is_flying, flying, "%s: vuela" % id)
	assert_almost_eq(e.size_tiles, size, 0.001, "%s: tamaño" % id)


func test_normal() -> void:
	_assert_enemy("normal", 30, 1.5, 0, 5, 1, false, 0.25)


func test_fast() -> void:
	_assert_enemy("fast", 18, 3.0, 0, 4, 1, false, 0.2)


func test_tank() -> void:
	_assert_enemy("tank", 135, 0.8, 0, 15, 2, false, 0.35)


# --- Torres, nivel 1 (spec §5.3) ---

func _assert_tower_level_1(id: String, cost: int, damage: int, fire_rate: float,
		range_tiles: float, splash: float, slow: float, slow_time: float, hits_air: bool) -> void:
	var t: TowerData = _tower(id)
	assert_not_null(t, "existe data/towers/%s.tres" % id)
	if t == null:
		return
	assert_eq(t.id, StringName(id), "%s: id" % id)
	assert_eq(t.can_hit_air, hits_air, "%s: aire" % id)
	assert_almost_eq(t.projectile_speed_tiles, 10.0, 0.001, "%s: velocidad de proyectil (RF-55)" % id)
	assert_gt(t.levels.size(), 0, "%s: tiene al menos el nivel 1" % id)
	if t.levels.is_empty():
		return
	var l1: TowerLevelData = t.levels[0]
	assert_eq(l1.cost, cost, "%s: costo" % id)
	assert_eq(l1.damage, damage, "%s: daño" % id)
	assert_almost_eq(l1.fire_rate, fire_rate, 0.001, "%s: cadencia" % id)
	assert_almost_eq(l1.range_tiles, range_tiles, 0.001, "%s: alcance" % id)
	assert_almost_eq(l1.splash_radius_tiles, splash, 0.001, "%s: área" % id)
	assert_almost_eq(l1.slow_amount, slow, 0.001, "%s: ralentización" % id)
	assert_almost_eq(l1.slow_duration, slow_time, 0.001, "%s: duración de ralentización" % id)


func test_basic_tower() -> void:
	_assert_tower_level_1("basic", 50, 5, 2.0, 3.0, 0.0, 0.0, 0.0, true)


func test_cannon_tower() -> void:
	_assert_tower_level_1("cannon", 100, 20, 0.6, 3.0, 1.0, 0.0, 0.0, false)


func test_frost_tower() -> void:
	_assert_tower_level_1("frost", 75, 2, 1.0, 2.5, 0.0, 0.4, 2.0, true)


func test_sniper_tower() -> void:
	_assert_tower_level_1("sniper", 150, 40, 0.4, 6.0, 0.0, 0.0, 0.0, true)
	var sniper: TowerData = _tower("sniper")
	assert_eq(sniper.levels[1].cost, 150, "nivel 2: costo")
	assert_eq(sniper.levels[1].damage, 70, "nivel 2: daño")
	assert_eq(sniper.levels[2].cost, 225, "nivel 3: costo")
	assert_eq(sniper.levels[2].damage, 120, "nivel 3: daño")
	assert_almost_eq(sniper.levels[2].range_tiles, 7.0, 0.001, "nivel 3: alcance")


# --- Enemigos de M2 (spec §6, balanceados en T38) ---

func test_flyer() -> void:
	_assert_enemy("flyer", 18, 2.0, 0, 8, 1, true, 0.25)


func test_armored() -> void:
	_assert_enemy("armored", 30, 1.2, 3, 12, 1, false, 0.3)


func test_boss() -> void:
	_assert_enemy("boss", 300, 0.6, 3, 150, 10, false, 0.45)
	assert_almost_eq(_enemy("boss").slow_resistance, 0.5, 0.001, "solo le afecta la mitad")


# --- Oleadas del nivel 1 (spec §7) ---

## Cada grupo como [tipo, cantidad, intervalo, retraso].
const LEVEL_01_WAVES: Array = [
	[["normal", 8, 1.0, 0.0]],
	[["normal", 12, 0.8, 0.0]],
	[["fast", 10, 0.6, 0.0]],
	[["normal", 10, 0.8, 0.0], ["armored", 4, 1.5, 4.0]],
	[["tank", 3, 2.0, 0.0], ["flyer", 8, 0.8, 3.0]],
	[["fast", 15, 0.4, 0.0], ["armored", 6, 1.0, 5.0]],
	[["tank", 6, 1.5, 0.0], ["flyer", 10, 0.6, 4.0]],
	[["normal", 20, 0.5, 0.0], ["armored", 8, 1.0, 5.0], ["fast", 10, 0.5, 8.0]],
	[["tank", 8, 1.5, 0.0], ["flyer", 12, 0.5, 3.0], ["fast", 15, 0.4, 8.0]],
	[["boss", 1, 1.0, 0.0], ["tank", 10, 1.2, 3.0], ["normal", 20, 0.4, 6.0], ["flyer", 15, 0.4, 10.0]],
]


func test_level_01_basics() -> void:
	var level: LevelData = GameFlow.level(0)
	assert_eq(level.starting_gold, 150, "spec §7")
	assert_eq(level.starting_lives, 20, "RF-10")
	assert_eq(level.waves.size(), 10, "RF-30")


func test_level_01_waves_match_spec() -> void:
	var level: LevelData = GameFlow.level(0)
	for w: int in LEVEL_01_WAVES.size():
		var expected: Array = LEVEL_01_WAVES[w]
		var groups: Array[SpawnGroup] = level.waves[w].groups
		assert_eq(groups.size(), expected.size(), "oleada %d: cantidad de grupos" % (w + 1))
		for g: int in mini(groups.size(), expected.size()):
			var label: String = "oleada %d, grupo %d" % [w + 1, g + 1]
			assert_eq(groups[g].enemy.id, StringName(expected[g][0]), label + ": tipo")
			assert_eq(groups[g].count, expected[g][1], label + ": cantidad")
			assert_almost_eq(groups[g].interval, expected[g][2], 0.001, label + ": intervalo")
			assert_almost_eq(groups[g].start_delay, expected[g][3], 0.001, label + ": retraso")


# --- Avisos de enemigos (spec §9.5) ---

func test_every_enemy_has_a_description() -> void:
	for id: String in ["normal", "fast", "tank", "flyer", "armored", "boss"]:
		assert_gt(_enemy(id).description.length(), 10, "%s: RF-134" % id)


func test_only_the_boss_is_dangerous() -> void:
	for id: String in ["normal", "fast", "tank", "flyer", "armored"]:
		assert_false(Rules.is_dangerous(_enemy(id)), id)
	assert_true(Rules.is_dangerous(_enemy("boss")), "RF-136: quita 10 vidas")
