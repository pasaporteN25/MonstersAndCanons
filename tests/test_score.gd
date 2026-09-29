# Tests de los puntos (T88, spec RF-190).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Hace salir un enemigo de ese tipo (con la vida de la oleada 1) y lo devuelve.
func _spawn(id: String) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = _enemy(id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.session.begin_wave()
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1) as Enemy


func test_points_come_from_balance() -> void:
	var balance: BalanceConfig = load("res://data/balance.tres")
	assert_eq(balance.points_per_gold, 10, "RF-190")
	assert_eq(balance.points_per_life, 100, "RF-190")
	assert_eq(Rules.kill_points(5, balance), 50)
	assert_eq(Rules.victory_points(17, balance), 1700)


func test_game_starts_with_zero_points() -> void:
	assert_eq(game.session.score, 0)
	assert_eq((game.hud.get_node("%ScoreLabel") as Label).text, "Puntos: 0")


func test_killing_gives_ten_points_per_gold() -> void:
	_spawn("normal").take_hit(100000)  # vale 5 de oro
	assert_eq(game.session.score, 50)
	assert_eq((game.hud.get_node("%ScoreLabel") as Label).text, "Puntos: 50", "se ve arriba")


func test_spiderlings_also_give_points() -> void:
	_spawn("spider").take_hit(100000)  # 6 de oro
	for node: Node in game.enemies.get_children():
		(node as Enemy).take_hit(100000)  # las 4 crías, 1 de oro cada una
	assert_eq(game.session.score, 60 + 4 * 10)


func test_winning_adds_a_hundred_per_life() -> void:
	game.session.lives = 17
	game.session.finish(true)
	assert_eq(game.session.score, 1700)


func test_losing_adds_nothing() -> void:
	_spawn("normal").take_hit(100000)
	game.session.finish(false)
	assert_eq(game.session.score, 50, "se conservan los de los enemigos, sin bonus")


func test_dev_panel_kills_give_no_points() -> void:
	_spawn("tank")
	game.dev_kill_all()
	assert_eq(game.session.score, 0, "RF-184")
