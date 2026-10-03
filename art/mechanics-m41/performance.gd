## Variante de la carga P7: desgaste/reparación activos y nuevos comportamientos.
extends "res://tools/perf_test.gd"

func _populate() -> void:
	super._populate()
	if not OS.get_cmdline_user_args().has("sin_desgaste"):
		for tower: Node2D in game.tower_container.get_children():
			tower.apply_wear(50.0)
	if OS.get_cmdline_user_args().has("sin_especiales"):
		return
	var thief: EnemyData = load("res://data/enemies/thief.tres")
	var rammer: EnemyData = load("res://data/enemies/rammer.tres")
	var replaced: int = 0
	for enemy: Node2D in game.enemies.get_children():
		if replaced >= 20:
			break
		enemy.data = thief if replaced % 2 == 0 else rammer
		if enemy.data == rammer:
			enemy._charge_segments = ChargeRules.segments(enemy.path().curve)
		replaced += 1
