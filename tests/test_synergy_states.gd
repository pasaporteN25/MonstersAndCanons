# Tests de las sinergias por estado del enemigo (M20, T143, spec RF-310 a RF-312, D-046).
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const HEALTH: int = 1000

var world: Node2D
var level: Level
var cannon: TowerData = load("res://data/towers/cannon.tres")
var tesla: TowerData = load("res://data/towers/tesla.tres")
var combos: Array = []


func before_each() -> void:
	combos = []
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _enemy(id: String = "normal", distance: float = 250.0) -> Enemy:
	var data: EnemyData = (load("res://data/enemies/%s.tres" % id) as EnemyData).duplicate()
	data.speed_tiles = 0.0
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), HEALTH)
	enemy.distance = distance
	enemy.combo_hit.connect(func(e: Enemy) -> void: combos.append(e))
	world.add_child(enemy)
	return enemy


func _slow(enemy: Enemy) -> void:
	enemy.take_hit(0 + 1, 0.4, 5.0)  # 1 de daño, ralentizado
	enemy.health = HEALTH


func _burn(enemy: Enemy) -> void:
	enemy.apply_burn(8, 5.0)


## Dispara a `target` un golpe con los números de `stats` y lo hace impactar enseguida.
func _hit(stats: TowerLevelData, target: Enemy, can_hit_air: bool = true) -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(target, target.global_position, stats, can_hit_air, 10.0, Color.WHITE)
	world.add_child(projectile)
	projectile._physics_process(1.0 / 60.0)


func _lost(enemy: Enemy) -> int:
	return HEALTH - enemy.health


func _stats(damage: int, slowed: int = 0, burning: int = 0) -> TowerLevelData:
	var stats := TowerLevelData.new()
	stats.damage = damage
	stats.bonus_vs_slowed_percent = slowed
	stats.bonus_vs_burning_percent = burning
	return stats


# --- La cuenta (RF-311) ---

func test_damage_with_bonus_rounds_to_the_nearest() -> void:
	assert_eq(Rules.damage_with_bonus(20, 25), 25)
	assert_eq(Rules.damage_with_bonus(13, 30), 17, "16,9")
	assert_eq(Rules.damage_with_bonus(5, 25), 6, "6,25")
	assert_eq(Rules.damage_with_bonus(10, 25), 13, "12,5 sube")
	assert_eq(Rules.damage_with_bonus(20, 0), 20, "sin bonus no cambia nada")


# --- El criterio de aceptación (RF-312) ---

func test_the_cannon_hits_a_slowed_enemy_for_25_and_a_normal_one_for_20() -> void:
	var slowed: Enemy = _enemy()
	_slow(slowed)
	var plain: Enemy = _enemy("normal", 900.0)
	_hit(cannon.levels[0], slowed)
	_hit(cannon.levels[0], plain)
	assert_eq(_lost(slowed), 25, "ralentizado: 20 + 25 %")
	assert_eq(_lost(plain), 20, "normal")


func test_the_tesla_hits_a_burning_enemy_for_17() -> void:
	var burning: Enemy = _enemy()
	_burn(burning)
	var plain: Enemy = _enemy("normal", 900.0)
	_hit(tesla.levels[0], burning)
	_hit(tesla.levels[0], plain)
	assert_eq(_lost(burning), 17)
	assert_eq(_lost(plain), 13)


func test_a_slowed_enemy_does_not_help_the_tesla_and_a_burning_one_does_not_help_the_cannon() -> void:
	var slowed: Enemy = _enemy()
	_slow(slowed)
	var burning: Enemy = _enemy("normal", 900.0)
	_burn(burning)
	_hit(tesla.levels[0], slowed)
	_hit(cannon.levels[0], burning)
	assert_eq(_lost(slowed), 13, "la Eléctrica solo aprovecha lo quemado")
	assert_eq(_lost(burning), 20, "el Cañón solo aprovecha lo ralentizado")


func test_the_two_states_add_up() -> void:
	var enemy: Enemy = _enemy()
	_slow(enemy)
	_burn(enemy)
	_hit(_stats(20, 25, 30), enemy)
	assert_eq(_lost(enemy), 31, "20 × 1,55")


func test_the_bonus_goes_before_the_armor() -> void:
	var slowed: Enemy = _enemy("armored")
	_slow(slowed)
	var plain: Enemy = _enemy("armored", 900.0)
	_hit(cannon.levels[0], slowed)
	_hit(cannon.levels[0], plain)
	assert_eq(_lost(plain), 20 - 3, "armadura 3")
	assert_eq(_lost(slowed), 25 - 3, "primero 25 y después la armadura")


func test_a_hit_does_not_help_itself_with_the_state_it_applies() -> void:
	var enemy: Enemy = _enemy()
	var stats: TowerLevelData = _stats(10, 100)
	stats.slow_amount = 0.4
	stats.slow_duration = 2.0
	_hit(stats, enemy)
	assert_eq(_lost(enemy), 10, "el primer golpe lo ralentiza pero no se potencia")
	assert_true(enemy.is_slowed())
	assert_eq(combos.size(), 0)
	_hit(stats, enemy)
	assert_eq(_lost(enemy), 10 + 20, "el segundo ya lo encuentra ralentizado")
	assert_eq(combos.size(), 1)


func test_the_combo_signal_only_fires_with_a_bonus() -> void:
	var enemy: Enemy = _enemy()
	_hit(cannon.levels[0], enemy)
	assert_eq(combos.size(), 0, "sin estado, sin combo")
	_slow(enemy)
	_hit(cannon.levels[0], enemy)
	assert_eq(combos.size(), 1)
	assert_eq(combos[0], enemy)
	_hit(_stats(20), enemy)
	assert_eq(combos.size(), 1, "una torre sin bonus tampoco")


# --- Todos los tipos de golpe (RF-311) ---

func test_the_area_checks_each_enemy_separately() -> void:
	var slowed: Enemy = _enemy()
	_slow(slowed)
	var plain: Enemy = _enemy("normal", 250.0)
	plain.global_position = slowed.global_position + Vector2(20, 0)  # dentro del radio de 1 casilla
	_hit(cannon.levels[0], slowed)
	assert_eq(_lost(slowed), 25)
	assert_eq(_lost(plain), 20)


func test_the_chain_checks_each_jump() -> void:
	var first: Enemy = _enemy()
	var second: Enemy = _enemy("normal", 250.0)
	second.global_position = first.global_position + Vector2(40, 0)  # a menos de 1,5 casillas
	_burn(second)
	_hit(tesla.levels[1], first)  # nivel 2: salta a 3
	assert_eq(_lost(first), 19, "el primero no se quema")
	assert_eq(_lost(second), roundi(19 * 1.3), "el que salta sí")


func test_a_reflected_hit_has_no_bonus_and_no_combo() -> void:
	var mirror: Enemy = _enemy("mirror")
	_slow(mirror)
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(cannon)
	tower.position = mirror.global_position + Vector2(0, 100)  # a menos de 2,5 casillas
	world.add_child(tower)
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(mirror, mirror.global_position, cannon.levels[0], false, 10.0, Color.WHITE)
	projectile.source = tower
	world.add_child(projectile)
	projectile._physics_process(1.0 / 60.0)
	assert_eq(_lost(mirror), 0, "rebotó: ni daño ni bonus")
	assert_eq(combos.size(), 0)
	assert_true(tower.is_stunned())


# --- Los datos (RF-312) ---

func test_only_the_big_slow_hitters_and_the_tesla_have_a_bonus() -> void:
	var slowed_ids: Array[StringName] = [&"cannon", &"sniper", &"mortar"]
	var dir := "res://data/towers/"
	for file: String in LevelFile.tower_ids():
		var tower: TowerData = load(dir + file + ".tres")
		for i: int in tower.levels.size():
			var level: TowerLevelData = tower.levels[i]
			var expected_slowed: int = 25 if slowed_ids.has(tower.id) else 0
			var expected_burning: int = 30 if tower.id == &"tesla" else 0
			assert_eq(level.bonus_vs_slowed_percent, expected_slowed, "%s nivel %d: contra ralentizados" % [tower.id, i + 1])
			assert_eq(level.bonus_vs_burning_percent, expected_burning, "%s nivel %d: contra quemados" % [tower.id, i + 1])
