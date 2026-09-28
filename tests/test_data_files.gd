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
	_assert_enemy("normal", 20, 1.5, 0, 5, 1, false, 0.25)


func test_fast() -> void:
	_assert_enemy("fast", 12, 3.0, 0, 4, 1, false, 0.2)


func test_tank() -> void:
	_assert_enemy("tank", 90, 0.8, 0, 15, 2, false, 0.35)


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
	_assert_tower_level_1("cannon", 100, 12, 0.6, 3.0, 1.0, 0.0, 0.0, false)


func test_frost_tower() -> void:
	_assert_tower_level_1("frost", 75, 2, 1.0, 2.5, 0.0, 0.4, 2.0, true)
