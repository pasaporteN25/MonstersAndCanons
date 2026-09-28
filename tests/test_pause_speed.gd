# Tests de pausa y velocidad x2 (T37, RF-103 a RF-105).
# Cuidado: GUT también corre dentro del árbol de Godot. Cada test quita la pausa
# ANTES de esperar frames, y after_each lo garantiza aunque un test falle.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


# --- Pausa (RF-104) ---

func test_pause_freezes_the_world_but_not_the_interface() -> void:
	game.set_paused(true)
	var world_frozen: bool = not game.enemies.can_process() and not game.session.can_process() \
		and not game.spawner.can_process() and not game.effects.can_process()
	var ui_alive: bool = game.hud.can_process() and game.build_controller.can_process()
	var label_visible: bool = (game.hud.get_node("%PauseLabel") as Label).visible
	game.set_paused(false)
	assert_true(world_frozen, "enemigos, cuenta atrás, oleadas y efectos quietos")
	assert_true(ui_alive, "el HUD y la selección siguen funcionando")
	assert_true(label_visible, "cartel PAUSA")


func test_cannot_build_while_paused_but_can_upgrade_and_sell() -> void:
	var basic: TowerData = game.tower_types[0]
	game.build_controller.try_build(basic, Vector2i(0, 0))
	var tower: Tower = game.build_controller.tower_at(Vector2i(0, 0))
	game.set_paused(true)
	var built: bool = game.build_controller.try_build(basic, Vector2i(1, 0))
	var upgraded: bool = game.build_controller.try_upgrade(tower)
	var refund: int = game.build_controller.sell(tower)
	game.set_paused(false)
	assert_false(built, "no se construye en pausa")
	assert_true(upgraded, "sí se mejora en pausa")
	assert_gt(refund, 0, "sí se vende en pausa")


func test_toggle_pause_twice_resumes() -> void:
	game.toggle_pause()
	var paused: bool = game.is_paused()
	game.toggle_pause()
	assert_true(paused)
	assert_false(game.is_paused())
	assert_eq((game.hud.get_node("%PauseButton") as Button).text, "Pausa  [P]")


func test_cannot_pause_after_game_over() -> void:
	game.session.lose_lives(100)
	game.set_paused(true)
	var paused: bool = game.is_paused()
	game.set_paused(false)
	assert_false(paused)


# --- Velocidad (RF-105) ---

func test_toggle_speed() -> void:
	game.toggle_speed()
	assert_eq(Engine.time_scale, 2.0)
	assert_eq((game.hud.get_node("%SpeedButton") as Button).text, "x2  [F]")
	game.toggle_speed()
	assert_eq(Engine.time_scale, 1.0)
	assert_eq((game.hud.get_node("%SpeedButton") as Button).text, "x1  [F]")


func test_game_over_returns_to_normal_speed() -> void:
	game.set_speed(2.0)
	game.session.lose_lives(100)
	assert_eq(Engine.time_scale, 1.0)


func test_leaving_the_game_resets_pause_and_speed() -> void:
	game.set_speed(2.0)
	game.set_paused(true)
	remove_child(game)  # dispara _exit_tree, como al reintentar o salir
	var speed: float = Engine.time_scale
	var paused: bool = get_tree().paused
	get_tree().paused = false
	add_child(game)  # lo devolvemos para que add_child_autofree lo borre
	assert_eq(speed, 1.0)
	assert_false(paused)
