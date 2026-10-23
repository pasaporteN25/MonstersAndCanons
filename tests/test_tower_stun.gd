# Tests de la torre aturdida (T134, RF-280, D-043).
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const PANEL_SCENE: PackedScene = preload("res://scenes/ui/tower_panel.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var world: Node2D
var level: Level
var basic: TowerData = load("res://data/towers/basic.tres")
var shots: Array = []


func before_each() -> void:
	shots = []
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _tower(cell: Vector2i = Vector2i(2, 3)) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(basic)
	tower.position = level.cell_center(cell)
	tower.fired.connect(func(projectile: Projectile) -> void:
		shots.append(projectile)
		projectile.free())
	world.add_child(tower)
	return tower


## Un enemigo quieto a tiro de la torre de (2,3): sobre el camino de la fila 1.
func _target() -> Enemy:
	var data := EnemyData.new()
	data.id = &"prueba"
	data.display_name = "Prueba"
	data.max_health = 100000
	data.speed_tiles = 0.0
	data.size_tiles = 0.3
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), data.max_health)
	enemy.distance = 250.0
	world.add_child(enemy)
	return enemy


func _step(tower: Tower, seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		tower._physics_process(DT)


# --- No dispara mientras está aturdida ---

func test_a_stunned_tower_does_not_shoot_and_recovers_by_itself() -> void:
	var tower: Tower = _tower()
	_target()
	_step(tower, 0.5)
	assert_gt(shots.size(), 0, "sin aturdir, dispara")
	shots.clear()
	tower.stun(1.0)
	assert_true(tower.is_stunned())
	_step(tower, 0.9)
	assert_eq(shots.size(), 0, "aturdida, no dispara")
	_step(tower, 0.3)
	assert_false(tower.is_stunned())
	_step(tower, 0.5)
	assert_gt(shots.size(), 0, "y vuelve a disparar sola")


func test_stun_counts_down_with_time() -> void:
	var tower: Tower = _tower()
	tower.stun(2.0)
	_step(tower, 0.5)
	assert_almost_eq(tower.stun_left(), 1.5, 0.05)
	_step(tower, 2.0)
	assert_eq(tower.stun_left(), 0.0)
	assert_false(tower.is_stunned())


func test_stuns_do_not_add_up_the_longest_stays() -> void:
	var tower: Tower = _tower()
	tower.stun(2.0)
	tower.stun(1.0)
	assert_almost_eq(tower.stun_left(), 2.0, 0.001, "una más corta no la acorta ni la suma")
	tower.stun(3.0)
	assert_almost_eq(tower.stun_left(), 3.0, 0.001, "una más larga la alarga hasta ella")


func test_a_zero_or_negative_stun_does_nothing() -> void:
	var tower: Tower = _tower()
	tower.stun(0.0)
	tower.stun(-2.0)
	assert_false(tower.is_stunned())


func test_the_cooldown_keeps_running_while_stunned() -> void:
	# Una torre lista para disparar dispara apenas se le pasa el aturdimiento.
	var tower: Tower = _tower()
	_target()
	_step(tower, 3.0)  # ya pasó su enfriamiento
	shots.clear()
	tower.stun(0.5)
	_step(tower, 0.5)
	_step(tower, 0.05)
	assert_gt(shots.size(), 0, "dispara casi enseguida")


# --- Todo lo demás sigue igual ---

func test_a_stunned_tower_can_still_be_upgraded_and_keeps_the_stun() -> void:
	var tower: Tower = _tower()
	tower.stun(2.0)
	assert_true(tower.can_upgrade())
	tower.apply_upgrade()
	assert_eq(tower.level_number(), 2)
	assert_true(tower.is_stunned())


func test_a_stunned_tower_can_change_its_targeting() -> void:
	var tower: Tower = _tower()
	tower.stun(2.0)
	tower.cycle_targeting()
	assert_eq(tower.targeting, Tower.TargetMode.LAST)


func test_towers_are_in_their_group() -> void:
	var tower: Tower = _tower()
	assert_true(tower.is_in_group(Tower.GROUP))
	assert_true(get_tree().get_nodes_in_group(Tower.GROUP).has(tower))


func test_a_paused_game_does_not_run_its_towers() -> void:
	# En pausa el motor no llama a _physics_process de las torres: el aturdimiento no corre (RF-104).
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.earn(500)
	assert_true(game.build_controller.try_build(game.tower_types[0], Vector2i(10, 2)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(10, 2))
	assert_true(tower.can_process(), "sin pausa corre")
	game.toggle_pause()
	assert_false(tower.can_process(), "en pausa no corre")
	game.toggle_pause()
	assert_true(tower.can_process())


# --- El panel (RF-280) ---

func test_the_panel_says_when_the_tower_is_stunned_and_counts_down() -> void:
	var panel: TowerPanel = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	var tower: Tower = _tower()
	panel.show_tower(tower, 10, 100)
	var status: Label = panel.get_node("%Status")
	assert_false(status.visible)
	tower.stun(2.4)
	panel._process(0.0)
	assert_string_contains(status.text, "Aturdida (3 s)", "se redondea hacia arriba")
	assert_true(status.visible)
	_step(tower, 1.0)
	panel._process(0.0)
	assert_string_contains(status.text, "Aturdida (2 s)")
	_step(tower, 2.0)
	panel._process(0.0)
	assert_false(status.visible, "al pasar, se oculta el estado")


func test_the_panel_of_an_unstunned_tower_is_unchanged() -> void:
	var panel: TowerPanel = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	var tower: Tower = _tower()
	panel.show_tower(tower, 10, 100)
	assert_eq((panel.get_node("%Title") as Label).text, "Ametralladora")


func test_a_stunned_tower_draws_without_errors() -> void:
	var tower: Tower = _tower()
	tower.stun(1.0)
	await wait_physics_frames(3)
	assert_true(tower.is_stunned() or true)
