# Tests de M2, bloque B: Francotirador, Volador, Blindado y Jefe (T34-T36).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Hace salir un enemigo de ese tipo con el generador de oleadas (así elige su camino).
func _spawn_through_wave(id: String) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = _enemy_data(id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1)


# --- Francotirador (T34) ---

func test_sniper_is_the_fourth_tower() -> void:
	assert_eq(game.tower_types.size(), 4)
	assert_eq(game.tower_types[3].id, &"sniper", "tecla 4")


func test_sniper_reaches_six_tiles() -> void:
	game.session.earn(1000)
	game.build_controller.try_build(game.tower_types[3], Vector2i(4, 5))
	var sniper: Tower = game.build_controller.tower_at(Vector2i(4, 5))
	var enemy: Enemy = _spawn_through_wave("normal")
	enemy.distance = 250.0  # fila 1: ~4.3 casillas de distancia de la torre
	simulate(enemy, 1, DT)
	assert_true(sniper.can_target(enemy))
	var basic_range: float = Rules.tiles_to_px(game.tower_types[0].levels[0].range_tiles)
	assert_gt(sniper.global_position.distance_to(enemy.global_position), basic_range,
		"una Ametralladora no llegaría")


# --- Voladores (T35, RF-05, RF-53) ---

func test_flyers_use_the_straight_air_path() -> void:
	var flyer: Enemy = _spawn_through_wave("flyer")
	var start: Vector2 = flyer.global_position
	simulate(flyer, 120, DT)
	var moved: Vector2 = flyer.global_position - start
	var air: Path2D = game.level.get_air_path(0)
	var exit_point: Vector2 = air.to_global(air.curve.get_point_position(1))
	var straight: Vector2 = exit_point - start
	assert_almost_eq(moved.angle(), straight.angle(), 0.01, "va derecho hacia la salida")


func test_ground_enemies_keep_using_the_road() -> void:
	var enemy: Enemy = _spawn_through_wave("normal")
	simulate(enemy, 60, DT)
	assert_almost_eq(enemy.global_position.y, game.level.cell_center(Vector2i(0, 1)).y, 0.5,
		"sigue en la fila 1 del camino")


func test_cannon_ignores_flyers_in_a_real_game() -> void:
	game.build_controller.try_build(game.tower_types[1], Vector2i(1, 2))
	var cannon: Tower = game.build_controller.tower_at(Vector2i(1, 2))
	var flyer: Enemy = _spawn_through_wave("flyer")
	simulate(flyer, 30, DT)
	assert_false(cannon.can_target(flyer), "RF-53")


# --- Blindado y Jefe (T36) ---

func test_armored_takes_one_damage_from_basic() -> void:
	var armored: Enemy = _spawn_through_wave("armored")
	var before: int = armored.health
	armored.take_hit(game.tower_types[0].levels[0].damage)
	assert_eq(armored.health, before - 1, "criterio de aceptación RF-80")


func test_boss_resists_half_of_the_frost() -> void:
	var boss: Enemy = _spawn_through_wave("boss")
	var frost: TowerLevelData = game.tower_types[2].levels[0]
	boss.take_hit(frost.damage, frost.slow_amount, frost.slow_duration)
	assert_almost_eq(boss.current_speed_tiles(), 0.6 * 0.8, 0.001,
		"criterio de T36: Hielo 40 % × 0.5 = 20 % → va al 80 %")
