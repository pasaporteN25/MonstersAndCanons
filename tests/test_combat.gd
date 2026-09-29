# Tests de combate: apuntar, disparar, daño, área, ralentización y barra de vida (T19-T22).
# Usa el mapa del nivel 1 solo para tener un camino; no carga la partida entera.
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const DT: float = 1.0 / 60.0

var world: Node2D
var level: Level
var normal: EnemyData = load("res://data/enemies/normal.tres")
var basic: TowerData = load("res://data/towers/basic.tres")
var cannon: TowerData = load("res://data/towers/cannon.tres")
var frost: TowerData = load("res://data/towers/frost.tres")


func before_each() -> void:
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


## Crea un enemigo a `distance` píxeles del inicio del camino.
## El primer tramo va por la fila 1, de izquierda a derecha (y = 96).
func _spawn_enemy(distance: float, data: EnemyData = normal, health: int = 20) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), health)
	enemy.distance = distance
	world.add_child(enemy)
	return enemy


func _build_tower(data: TowerData, cell: Vector2i) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(data)
	tower.position = level.cell_center(cell)
	tower.fired.connect(world.add_child)  # en la partida lo hace Game
	world.add_child(tower)
	return tower


func _shoot_at(target: Enemy, tower: TowerData) -> Projectile:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	# Sale desde la posición del objetivo, así impacta en el primer frame.
	projectile.setup(target, target.global_position, tower.levels[0], tower.can_hit_air,
		tower.projectile_speed_tiles, tower.color)
	world.add_child(projectile)
	return projectile


func _enemy_data(armor: int, flying: bool) -> EnemyData:
	var data: EnemyData = normal.duplicate()
	data.armor = armor
	data.is_flying = flying
	return data


# --- Apuntar (RF-50, RF-51, RF-53) ---

func test_targets_the_enemy_closest_to_the_exit() -> void:
	var behind: Enemy = _spawn_enemy(200.0)
	var ahead: Enemy = _spawn_enemy(300.0)
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	assert_true(tower.can_target(behind), "está en alcance")
	assert_eq(tower.find_target(), ahead, "RF-51: el más adelantado")


func test_ignores_enemies_out_of_range() -> void:
	var enemy: Enemy = _spawn_enemy(200.0)
	var tower: Tower = _build_tower(basic, Vector2i(15, 7))
	assert_false(tower.can_target(enemy))
	assert_null(tower.find_target())


func test_cannon_ignores_flyers_but_basic_does_not() -> void:
	var flyer: Enemy = _spawn_enemy(200.0, _enemy_data(0, true))
	assert_false(_build_tower(cannon, Vector2i(3, 3)).can_target(flyer), "RF-53")
	assert_true(_build_tower(basic, Vector2i(3, 2)).can_target(flyer))


# --- Disparar y matar (T19) ---

func test_basic_tower_kills_a_normal_enemy() -> void:
	var enemy: Enemy = _spawn_enemy(0.0)
	watch_signals(enemy)
	_build_tower(basic, Vector2i(4, 2))
	simulate(world, 60 * 6, DT)
	assert_signal_emitted(enemy, "died")
	assert_signal_not_emitted(enemy, "reached_exit")


func test_fire_rate() -> void:
	_spawn_enemy(200.0, normal, 1000)
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	watch_signals(tower)
	simulate(world, 60, DT)  # 1 segundo
	assert_signal_emit_count(tower, "fired", 2, "cadencia 2.0: dos disparos por segundo")


func test_projectile_without_target_vanishes_without_error() -> void:
	var enemy: Enemy = _spawn_enemy(200.0)
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(enemy, level.cell_center(Vector2i(10, 6)), basic.levels[0], true, 10.0, Color.WHITE)
	world.add_child(projectile)
	enemy.take_hit(100)  # muere antes de que llegue el proyectil (RF-52)
	await wait_process_frames(1)
	simulate(world, 120, DT)
	await wait_process_frames(1)
	assert_false(is_instance_valid(projectile), "el proyectil desapareció")


# --- Daño y armadura (RF-80) ---

func test_armor_reduces_damage() -> void:
	var armored: Enemy = _spawn_enemy(200.0, _enemy_data(4, false), 45)
	armored.take_hit(5)
	assert_eq(armored.health, 44, "RF-80: 5 − 4 = 1, pero siempre al menos 1")
	armored.take_hit(40)
	assert_eq(armored.health, 8, "40 − 4 = 36")


# --- Área (T21) ---

func test_cannon_splash_hits_everyone_within_one_tile() -> void:
	var target: Enemy = _spawn_enemy(300.0, normal, 50)
	var near: Enemy = _spawn_enemy(340.0, normal, 50)  # a 40 px: dentro del radio de 64
	var far: Enemy = _spawn_enemy(420.0, normal, 50)   # a 120 px: fuera
	_shoot_at(target, cannon)
	simulate(world, 1, DT)
	assert_eq(target.health, 30, "50 − 20")
	assert_eq(near.health, 30, "50 − 20")
	assert_eq(far.health, 50, "fuera del radio")


func test_splash_does_not_hit_flyers_if_tower_cannot() -> void:
	var target: Enemy = _spawn_enemy(300.0)
	var flyer: Enemy = _spawn_enemy(310.0, _enemy_data(0, true))
	_shoot_at(target, cannon)
	simulate(world, 1, DT)
	assert_eq(flyer.health, 20, "RF-53")


# --- Ralentización (T22) ---

func test_frost_slows_to_60_percent_for_2_seconds() -> void:
	var enemy: Enemy = _spawn_enemy(200.0, normal, 1000)
	_shoot_at(enemy, frost)
	simulate(world, 1, DT)
	assert_true(enemy.is_slowed(), "RF-62")
	assert_almost_eq(enemy.current_speed_tiles(), 1.5 * 0.6, 0.001, "RF-60")
	simulate(enemy, roundi(2.1 / DT), DT)
	assert_false(enemy.is_slowed())
	assert_almost_eq(enemy.current_speed_tiles(), 1.5, 0.001)


func test_slows_do_not_stack() -> void:
	var enemy: Enemy = _spawn_enemy(200.0, normal, 1000)
	enemy.take_hit(2, 0.4, 2.0)
	enemy.take_hit(2, 0.4, 2.0)
	assert_almost_eq(enemy.current_speed_tiles(), 1.5 * 0.6, 0.001, "RF-61: no se suman")


func test_stronger_slow_wins() -> void:
	var enemy: Enemy = _spawn_enemy(200.0, normal, 1000)
	enemy.take_hit(2, 0.6, 2.0)
	enemy.take_hit(2, 0.4, 2.0)
	assert_almost_eq(enemy.current_speed_tiles(), 1.5 * 0.4, 0.001, "RF-61: la más fuerte")


# --- Barra de vida (T20, RF-82) ---

func test_health_bar_only_after_first_hit() -> void:
	var enemy: Enemy = _spawn_enemy(200.0)
	assert_false(enemy.is_health_bar_visible())
	enemy.take_hit(5)
	assert_true(enemy.is_health_bar_visible())
