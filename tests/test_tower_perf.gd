# Dos optimizaciones de rendimiento de la torre (T236, constitución P7). No cambian lo que se ve ni cómo apuntan:
#   1. la búsqueda de enemigos en alcance (`_enemies_in_reach`) elige lo mismo que `can_target`;
#   2. la torre quieta ya no pide redibujarse en cada tick (`_aim_changed_visibly`).
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")

var world: Node2D
var level: Level
var normal: EnemyData = load("res://data/enemies/normal.tres")
var basic: TowerData = load("res://data/towers/basic.tres")
var cannon: TowerData = load("res://data/towers/cannon.tres")


func before_each() -> void:
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _spawn_enemy(distance: float, flying: bool = false) -> Enemy:
	var data: EnemyData = normal.duplicate()
	data.is_flying = flying
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), 20)
	enemy.distance = distance
	world.add_child(enemy)
	return enemy


func _build_tower(data: TowerData, cell: Vector2i) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(data)
	tower.position = level.cell_center(cell)
	tower.fired.connect(world.add_child)
	world.add_child(tower)
	return tower


# --- La búsqueda en alcance elige lo mismo que can_target ---

func test_enemies_in_reach_match_can_target_for_every_enemy() -> void:
	var enemies: Array[Enemy] = []
	for i: int in 24:
		enemies.append(_spawn_enemy(60.0 + i * 40.0, i % 5 == 0))
	for data: TowerData in [basic, cannon]:
		for cell: Vector2i in [Vector2i(3, 3), Vector2i(8, 5), Vector2i(15, 7)]:
			var tower: Tower = _build_tower(data, cell)
			var expected: Array[Enemy] = []
			for enemy: Enemy in enemies:
				if tower.can_target(enemy):
					expected.append(enemy)
			var found: Array[Enemy] = tower._enemies_in_reach()
			found.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.get_instance_id() < b.get_instance_id())
			expected.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.get_instance_id() < b.get_instance_id())
			assert_eq(found, expected, "%s en %s: los mismos enemigos" % [data.id, cell])
			tower.queue_free()


func test_removed_enemies_are_not_found() -> void:
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	var near: Enemy = _spawn_enemy(200.0)
	assert_eq(tower._enemies_in_reach().size(), 1)
	near.queue_free()
	await wait_physics_frames(2)
	assert_eq(tower._enemies_in_reach().size(), 0, "uno que ya no existe no cuenta")
	assert_null(tower.find_target())


func test_out_of_range_enemy_is_not_found() -> void:
	var far: Enemy = _spawn_enemy(200.0)
	var tower: Tower = _build_tower(basic, Vector2i(15, 7))
	assert_false(tower.can_target(far))
	assert_true(tower._enemies_in_reach().is_empty())


func test_empty_field_finds_nothing() -> void:
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	assert_true(tower._enemies_in_reach().is_empty())
	assert_null(tower.find_target())
	assert_true(tower.find_targets(3).is_empty())


# --- La torre quieta no se redibuja ---

func test_aim_change_within_the_same_view_does_not_redraw() -> void:
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	assert_not_null(tower.current_turret_atlas(), "la torre tiene atlas de vistas")
	var index: int = TowerVisual.direction_index(0.0)
	var tiny: float = 0.001
	assert_eq(TowerVisual.direction_index(tiny), index, "un cambio mínimo sigue en la misma vista")
	tower.aim_angle = tiny
	assert_false(tower._aim_changed_visibly(0.0))
	tower.aim_angle = 0.0
	assert_false(tower._aim_changed_visibly(0.0), "sin cambio, tampoco")


func test_aim_change_to_another_view_redraws() -> void:
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	tower.aim_angle = PI
	assert_true(tower._aim_changed_visibly(0.0))
	tower.aim_angle = TAU / TowerVisual.DIRECTION_COUNT * 1.01
	assert_true(tower._aim_changed_visibly(0.0), "la vista de al lado")


func test_without_atlas_any_aim_change_redraws() -> void:
	var data: TowerData = basic.duplicate(true)
	data.turret_atlas = null
	for level_data: TowerLevelData in data.levels:
		level_data.turret_atlas = null
	var tower: Tower = _build_tower(data, Vector2i(3, 3))
	assert_null(tower.current_turret_atlas())
	tower.aim_angle = 0.001
	assert_true(tower._aim_changed_visibly(0.0), "la torreta gira de verdad: se ve")


func test_an_idle_tower_stays_still_and_a_firing_one_animates() -> void:
	var tower: Tower = _build_tower(basic, Vector2i(3, 3))
	await wait_physics_frames(3)
	assert_eq(tower._recoil, 0.0)
	assert_eq(tower._flash_left, 0.0)
	var enemy: Enemy = _spawn_enemy(200.0)
	assert_true(tower.can_target(enemy))
	await wait_physics_frames(3)
	assert_gt(tower._flash_left + tower._recoil, 0.0, "al disparar anima el retroceso y el destello")
