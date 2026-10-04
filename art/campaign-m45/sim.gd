# Laboratorio reproducible8/9; los recursos oficiales nunca se escriben.
# godot --headless --fixed-fps60 -s art/campaign-m45/sim.gd -- mix level=9 profile=adaptive_upgrade_late_value seed=42 pressure=normal
extends "res://tools/balance_sim.gd"
var profile: String = "baseline"
var pressure: String = "normal"
var scenario_seed: int = 42
var prepared: bool = false
var reported: bool = false
var support: Node2D
var upgrades: int = 0
var last_upgrade_wave: int = -1
var stolen: int = 0
var impacts: int = 0
var repaired: float = 0.0
var special_counts: Dictionary = {"thief":0,"rammer":0}
var purchases: Array[Dictionary] = []

func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("profile="): profile = arg.trim_prefix("profile=")
		if arg.begins_with("pressure="): pressure = arg.trim_prefix("pressure=")
		if arg.begins_with("seed="): scenario_seed = int(arg.trim_prefix("seed="))
	seed(scenario_seed)  # D047: también fijar el azar del temblor/efectos.
	super._initialize()

func _prepare() -> void:
	game.spawner.rng.seed = scenario_seed
	var standard: TowerData = load("res://data/towers/mechanical_standard.tres")
	if profile not in ["baseline","upgrades","adaptive_upgrades"]:
		if not game.available_towers.has(standard): game.available_towers.append(standard)
		game.build_controller.setup(game.level,game.session,game.balance,game.available_towers,game.tower_container)
	# Ablaciones solo en el Resource de esta corrida.
	for wave: WaveData in game.level_data.waves:
		for group: SpawnGroup in wave.groups:
			if group.enemy.id in [&"thief",&"rammer"]:
				if pressure == "none": group.count = 0
				if pressure == "double":
					if group.enemy.id == &"thief": group.probability = 0.7
					else: group.count *= 2
	game.session.gold_stolen.connect(func(amount: int) -> void: stolen += amount)
	game.spawner.enemy_spawned.connect(func(enemy: Node2D) -> void:
		if String(enemy.data.id) in special_counts: special_counts[String(enemy.data.id)] += 1
		enemy.charged_impact.connect(func(_enemy: Node2D,_tower: Node2D) -> void: impacts += 1))
	game.build_controller.tower_built.connect(func(tower: Node2D) -> void:
		tower.wear_changed.connect(func(_wear: float,change: float) -> void:
			if change < 0: repaired -= change))
	prepared = true

func _process(delta: float) -> bool:
	if not prepared: _prepare()
	var finished: bool = super._process(delta)
	if finished and not reported:
		reported = true
		var result: Dictionary = {"level":level_number,"seed":scenario_seed,"global_seed":scenario_seed,"profile":profile,"pressure":pressure,
			"won":game.session.state == LevelSession.State.WON,"wave":game.session.wave,"lives":game.session.lives,
			"gold":game.session.gold,"built":built,"upgrades":upgrades,"specials":special_counts,"stolen":stolen,
			"impacts":impacts,"repaired":snappedf(repaired,0.01),"purchases":purchases}
		print("M44_RESULT ",JSON.stringify(result))
	return finished

func _support_cell() -> Dictionary:
	var best: Dictionary = {"cell":Vector2i(-1,-1),"count":0,"dps":0.0,"score":-1.0}
	for cell: Vector2i in _free_cells():
		var center: Vector2 = game.level.cell_center(cell)
		var count: int = 0
		var dps: float = 0
		for tower: Node2D in game.tower_container.get_children():
			if tower.data.support_only: continue
			if center.distance_to(tower.global_position) <= Rules.tiles_to_px(2.0):
				count += 1
				dps += tower.stats().damage * tower.stats().fire_rate
		var score: float = dps if (profile.contains("value") or profile.contains("damage")) else float(count)
		if score > best.score: best = {"cell":cell,"count":count,"dps":dps,"score":score}
	return best

func _buy_support() -> void:
	if profile in ["baseline","upgrades","adaptive_upgrades"] or is_instance_valid(support): return
	var threshold: int = 4 if profile == "early" else 12
	if built < threshold: return
	var best: Dictionary = _support_cell()
	if profile.contains("value") and best.dps < 120.0: return
	var data: TowerData = load("res://data/towers/mechanical_standard.tres")
	if game.build_controller.try_build(data,best.cell):
		support = game.tower_container.get_child(game.tower_container.get_child_count()-1)
		purchases.append({"kind":"support","wave":game.session.wave,"allies":best.count,"nominal_dps":best.dps,"cell":str(best.cell)})

func _upgrade_one() -> void:
	if not profile.contains("upgrade") or built < 6 or last_upgrade_wave == game.session.wave: return
	if game.session.state == LevelSession.State.WAVE_RUNNING: return
	if profile == "upgrade_support" and is_instance_valid(support) and game.session.wave >= 10 and support.can_upgrade():
		if game.build_controller.try_upgrade(support):
			upgrades += 1
			last_upgrade_wave = game.session.wave
			purchases.append({"kind":"support_upgrade","wave":game.session.wave,"level":support.level_number()})
			return
	var candidate: Node2D
	var best_score: float = -1
	for tower: Node2D in game.tower_container.get_children():
		if tower.data.support_only or not tower.can_upgrade(): continue
		var next: TowerLevelData = tower.next_level_stats()
		if not game.session.can_afford(next.cost): continue
		var coverage: int = _points_in_range(path_points,tower.global_position,Rules.tiles_to_px(next.range_tiles))
		if profile.begins_with("adaptive") and tower.data.can_hit_air:
			coverage += _points_in_range(air_points,tower.global_position,Rules.tiles_to_px(next.range_tiles))
		var gain: float = next.damage * next.fire_rate - tower.stats().damage * tower.stats().fire_rate
		var score: float = coverage * gain / maxf(1,next.cost)
		if score > best_score:
			best_score = score
			candidate = tower
	if candidate != null and game.build_controller.try_upgrade(candidate):
		upgrades += 1
		last_upgrade_wave = game.session.wave
		purchases.append({"kind":"upgrade","wave":game.session.wave,"tower":String(candidate.data.id),"level":candidate.level_number()})

func _buy_towers() -> void:
	_buy_support()
	_upgrade_one()
	super._buy_towers()
