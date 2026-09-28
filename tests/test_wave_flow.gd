# Test de integración: carga la partida completa (game.tscn con el nivel 1)
# y simula el paso del tiempo. Cubre los criterios de T14, T15, T16 y T17.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


## Avanza el juego `seconds` segundos a 60 FPS.
## Después espera 2 frames reales para que Godot borre los enemigos que terminaron.
func _run_seconds(seconds: float) -> void:
	simulate(game, roundi(seconds / DT), DT)
	await wait_process_frames(2)


func _label(unique_name: String) -> String:
	return (game.hud.get_node("%" + unique_name) as Label).text


# --- T15: HUD al empezar ---

func test_hud_shows_starting_values() -> void:
	assert_eq(_label("GoldLabel"), "Oro: 150")
	assert_eq(_label("LivesLabel"), "Vidas: 20")
	assert_eq(_label("WaveLabel"), "Oleada 0/10")


# --- T16: nada sale hasta pulsar "Empezar oleada" (RF-32) ---

func test_no_enemies_before_starting() -> void:
	await _run_seconds(3.0)
	assert_eq(game.enemies.get_child_count(), 0)
	assert_eq(game.session.state, LevelSession.State.BUILDING)


func test_enemies_come_out_one_per_second() -> void:
	game.start_next_wave()
	await _run_seconds(0.1)
	assert_eq(game.enemies.get_child_count(), 1)
	await _run_seconds(1.0)
	assert_eq(game.enemies.get_child_count(), 2)
	assert_eq(_label("WaveLabel"), "Oleada 1/10")


# --- T14: el enemigo recorre el camino a 1.5 casillas/s ---

func test_enemy_walks_the_path_at_its_speed() -> void:
	game.start_next_wave()
	await _run_seconds(0.1)
	var enemy: Enemy = game.enemies.get_child(0)
	var start: float = enemy.distance
	# Sin esperar frames reales: esos frames también moverían al enemigo y ensuciarían la medida.
	simulate(game, 120, DT)
	assert_almost_eq(enemy.distance - start, 2.0 * 96.0, 0.5, "1.5 casillas/s = 96 px/s")


# --- T15 + T16: la oleada 1 completa, sin torres ---

func test_full_wave_without_towers() -> void:
	game.start_next_wave()
	# 8 enemigos (el último sale a los 7 s) + ~35 s de camino.
	await _run_seconds(45.0)
	assert_eq(game.enemies.get_child_count(), 0, "todos llegaron a la salida")
	assert_eq(game.session.lives, 12, "RF-11: 20 − 8")
	assert_eq(game.session.gold, 175, "RF-22: 150 + bono de 25")
	assert_eq(game.session.state, LevelSession.State.COUNTDOWN, "RF-34")
	assert_eq(_label("LivesLabel"), "Vidas: 12")
	assert_eq(_label("GoldLabel"), "Oro: 175")
	assert_eq(_label("WaveLabel"), "Oleada 1/10 completada (+25 de oro)")

	# RF-34: tras 15 s de cuenta atrás, la oleada 2 sale sola.
	await _run_seconds(15.5)
	assert_eq(game.session.wave, 2)
	assert_eq(game.session.state, LevelSession.State.WAVE_RUNNING)
	assert_gt(game.enemies.get_child_count(), 0)


# --- T17: vida creciente por oleada (RF-36) ---

func test_enemies_get_more_health_each_wave() -> void:
	var spawned: Array[Enemy] = []
	game.spawner.enemy_spawned.connect(func(e: Enemy) -> void: spawned.append(e))
	game.spawner.start_wave(game.level_data.waves[1], 2)
	await _run_seconds(0.1)
	assert_eq(spawned.size(), 1)
	assert_eq(spawned[0].max_health, 42, "Normal en oleada 2: 30 × 1.4 = 42")
	assert_eq(spawned[0].health, 42)
