# Tests de los efectos visuales (M1.5, spec §9.3). No miran cómo se ven (eso se revisa
# con capturas), sino que aparezcan cuando deben, no aparezcan cuando no, y se borren solos.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _count_effects(type: Variant) -> int:
	var count: int = 0
	for child: Node in game.effects.get_children():
		if is_instance_of(child, type):
			count += 1
	return count


## Textos "+N" de oro (los números de daño, RF-132, no empiezan con "+").
func _count_gold_texts() -> int:
	var count: int = 0
	for child: Node in game.effects.get_children():
		if child is FloatingText and (child as FloatingText)._text.begins_with("+"):
			count += 1
	return count


func _first_enemy_of_wave() -> Enemy:
	game.start_next_wave()
	simulate(game, 1, DT)
	return game.enemies.get_child(0)


# --- T50 / RF-124: muerte ---

func test_death_shows_burst_and_gold_text() -> void:
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.take_hit(1000)
	assert_eq(_count_effects(BurstEffect), 1, "estallido")
	assert_eq(_count_gold_texts(), 1, "+N de oro")


func test_escaping_shows_no_death_effects() -> void:
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.distance = 1e6  # lo manda directo a la salida
	simulate(game, 1, DT)
	assert_eq(_count_effects(BurstEffect), 0)
	assert_eq(_count_gold_texts(), 0)


func test_effects_remove_themselves() -> void:
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.take_hit(1000)
	simulate(game.effects, 90, DT)  # 1.5 s: más que el efecto más largo
	await wait_process_frames(2)
	assert_eq(game.effects.get_child_count(), 0)


# --- T51 / RF-120: el cañón apunta ---

func test_tower_barrel_points_at_its_target() -> void:
	var tower_data: TowerData = game.tower_types[0]
	game.build_controller.try_build(tower_data, Vector2i(4, 2))
	var tower: Tower = game.build_controller.tower_at(Vector2i(4, 2))
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.distance = 280.0  # frente a la torre, en la fila 1
	simulate(game, 30, DT)
	var expected: float = (enemy.global_position - tower.global_position).angle()
	assert_almost_eq(angle_difference(tower.aim_angle, expected), 0.0, 0.15)


# --- T52 / RF-122: impactos ---

func test_projectile_impact_creates_effect() -> void:
	game.build_controller.try_build(game.tower_types[1], Vector2i(4, 2))  # Cañón
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.distance = 280.0
	var before: int = _count_effects(RingEffect)
	simulate(game, 20, DT)
	assert_gt(_count_effects(RingEffect), before, "la onda del Cañón")


# --- T55 / RF-128: la sacudida vuelve la pantalla a su lugar ---

func test_screen_shake_returns_to_origin() -> void:
	var enemy: Enemy = _first_enemy_of_wave()
	enemy.distance = 1e6
	simulate(game, 1, DT)
	assert_eq(game.session.lives, 19)
	simulate(game, 30, DT)  # 0.5 s, más que la sacudida
	assert_eq(game.position, Vector2.ZERO)
