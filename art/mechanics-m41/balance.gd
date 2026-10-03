## Laboratorio6/7; bot de nivel1, una estrategia. No escribe progreso normal.
extends "res://art/progression-m37/balance_support.gd"

var scenario_seed: int = 12345
var thieves: int = 0
var rammers: int = 0
var stolen: int = 0
var impacts: int = 0
var repaired: float = 0.0
var reported: bool = false

func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("seed="):
			scenario_seed = int(arg.trim_prefix("seed="))
	super._initialize()

func _prepare_support() -> void:
	super._prepare_support()
	game.spawner.rng.seed = scenario_seed
	game.session.gold_stolen.connect(func(amount: int) -> void: stolen += amount)
	game.spawner.enemy_spawned.connect(func(enemy: Node2D) -> void:
		if enemy.data.id == &"thief":
			thieves += 1
		if enemy.data.id == &"rammer":
			rammers += 1
		enemy.charged_impact.connect(func(_enemy: Node2D, _tower: Node2D) -> void: impacts += 1))
	game.build_controller.tower_built.connect(func(tower: Node2D) -> void:
		tower.wear_changed.connect(func(_current: float, change: float) -> void:
			if change < 0.0:
				repaired -= change))

func _process(delta: float) -> bool:
	var finished: bool = super._process(delta)
	if finished and not reported:
		reported = true
		var result: Dictionary = {"level":level_number,"seed":scenario_seed,"support":with_support,
			"won":game.session.state == LevelSession.State.WON,"wave":game.session.wave,"lives":game.session.lives,
			"thieves":thieves,"rammers":rammers,"stolen_gold":stolen,"impacts":impacts,"repaired_points":snappedf(repaired,0.01)}
		print("M41_RESULT ",JSON.stringify(result))
	return finished
