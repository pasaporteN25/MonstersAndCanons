# Tests del contenido nuevo de M5 (spec §5.6 y §6.1): cada comportamiento es un dato (RF-164).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const DT: float = 1.0 / 60.0


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id)


func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Un enemigo caminando por un camino recto y largo (no llega a la salida en los tests).
func _walker(data: EnemyData, health: int, from := Vector2(100, 300)) -> Enemy:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(from)
	path.curve.add_point(from + Vector2(4000, 0))
	add_child_autofree(path)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, path, health)
	add_child_autofree(enemy)
	return enemy


func _seconds(node: Node, seconds: float) -> void:
	simulate(node, roundi(seconds / DT), DT)


func _assert_levels(id: String, expected: Array) -> void:
	var tower: TowerData = _tower(id)
	assert_eq(tower.levels.size(), 3, "%s: 3 niveles" % id)
	for i: int in expected.size():
		for field: String in expected[i]:
			assert_almost_eq(float(tower.levels[i].get(field)), float(expected[i][field]), 0.001,
				"%s, nivel %d: %s" % [id, i + 1, field])


# --- Incendiaria y quemadura (RF-160) ---

func test_fire_tower_matches_spec() -> void:
	var fire: TowerData = _tower("fire")
	assert_eq(fire.display_name, "Incendiaria")
	assert_true(fire.can_hit_air)
	_assert_levels("fire", [
		{"cost": 90, "damage": 3, "fire_rate": 1.0, "range_tiles": 2.5, "burn_damage_per_second": 6, "burn_duration": 3.0},
		{"cost": 90, "damage": 4, "burn_damage_per_second": 10, "burn_duration": 3.0},
		{"cost": 140, "damage": 6, "range_tiles": 3.0, "burn_damage_per_second": 16, "burn_duration": 4.0},
	])


func test_burn_deals_its_damage_per_second() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "6 por segundo: dos golpecitos de 3")
	_seconds(enemy, 2.0)
	assert_eq(enemy.health, 982, "3 segundos: 18 en total")
	assert_false(enemy.is_burning(), "se apagó")
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 982, "apagado, ya no quema")


func test_burn_ignores_armor() -> void:
	var enemy: Enemy = _walker(_enemy_data("armored"), 1000)  # armadura 3
	enemy.apply_burn(6, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "cada golpecito de 3 entra entero")


func test_burns_do_not_stack() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 3.0)
	enemy.apply_burn(6, 3.0)
	enemy.apply_burn(4, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "queda la más fuerte (6), no la suma")


func test_a_new_burn_restarts_the_time() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 1.0)
	_seconds(enemy, 0.5)
	enemy.apply_burn(6, 1.0)  # ahora dura hasta el segundo 1,5
	_seconds(enemy, 1.5)
	assert_eq(enemy.health, 991, "tres golpecitos: 0,5 s, 1 s y 1,5 s")


func test_burning_to_death_counts_as_a_kill() -> void:
	var enemy: Enemy = _walker(_enemy_data("normal"), 5)
	watch_signals(enemy)
	enemy.apply_burn(10, 3.0)
	_seconds(enemy, 0.6)
	assert_signal_emitted(enemy, "died", "RF-81: da su oro como cualquier muerte")


func test_fire_projectile_sets_the_enemy_on_fire() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000, Vector2(200, 300))
	var fire: TowerData = _tower("fire")
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(enemy, Vector2(200, 200), fire.levels[0], true, fire.projectile_speed_tiles, fire.color,
		fire.projectile_texture)
	add_child_autofree(projectile)
	_seconds(projectile, 0.5)
	assert_true(enemy.is_burning(), "RF-160")
	assert_eq(enemy.health, 997, "el golpe hizo 3 (la quemadura todavía no)")
	await wait_process_frames(2)  # se dibujan las llamitas sin errores
