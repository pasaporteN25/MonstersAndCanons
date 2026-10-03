# B-23: ensayo aislado sobre Enemy y Rules reales, sin cambiar datos de campaña.
# godot --headless --path . res://art/redesign-m36/combo_lab.tscn
extends Node

const DT: float = 0.05
const SECONDS: float = 20.0

func _ready() -> void:
	var rows: Array[Dictionary] = []
	for tower_id: String in ["cannon", "multi", "tesla"]:
		for level: int in [2, 3]:
			for armor: int in [0, 4, 12]:
				for resistance: float in [0.0, 0.5]:
					var base: Dictionary = trial(tower_id, level, armor, resistance, false)
					var combo: Dictionary = trial(tower_id, level, armor, resistance, true)
					rows.append({"tower": tower_id, "level": level, "armor": armor, "slow_resistance": resistance,
						"base": base, "recipe": combo, "damage_change_percent": (float(combo.damage) / maxf(float(base.damage), 1) - 1) * 100})
	# Vecindad de ocho celdas, incluidos bordes2×2; comprobar también venta/aturdimiento/nivel mínimo.
	var cases: Dictionary = {
		"diagonal": eligible(Rect2i(0, 0, 1, 1), Rect2i(1, 1, 1, 1), 2, 2, false, false),
		"separadas": eligible(Rect2i(0, 0, 1, 1), Rect2i(2, 0, 1, 1), 2, 2, false, false),
		"borde2x2": eligible(Rect2i(0, 0, 2, 2), Rect2i(2, 1, 1, 1), 2, 2, false, false),
		"nivel1": eligible(Rect2i(0, 0, 1, 1), Rect2i(1, 0, 1, 1), 1, 2, false, false),
		"aturdida": eligible(Rect2i(0, 0, 1, 1), Rect2i(1, 0, 1, 1), 2, 2, true, false),
		"vendida": eligible(Rect2i(0, 0, 1, 1), Rect2i(1, 0, 1, 1), 2, 2, false, true),
	}
	var passed: bool = cases.diagonal and not cases.separadas and cases.borde2x2 and not cases.nivel1 and not cases.aturdida and not cases.vendida
	var start: int = Time.get_ticks_usec()
	for i: int in 100000:
		eligible(Rect2i(i % 20, 0, 1, 1), Rect2i(4, 0, 2, 2), 2, 2, false, false)
	var elapsed: int = Time.get_ticks_usec() - start
	var costs: Array[Dictionary] = []
	for pair: Array in [["frost", "cannon"], ["frost", "multi"], ["fire", "tesla"]]:
		for minimum: int in [2, 3]:
			var cost: int = 0
			for id: String in pair:
				var data: TowerData = load("res://data/towers/%s.tres" % id)
				for i: int in minimum:
					cost += data.levels[i].cost
			costs.append({"pair": pair, "minimum_level": minimum, "total_investment": cost})
	var file: FileAccess = FileAccess.open("res://art/redesign-m36/combo_results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"seconds_per_case": SECONDS, "cases": rows, "topology": cases,
		"topology_passed": passed, "100000_pair_checks_usec": elapsed, "activation_costs": costs,
		"scope": "Un objetivo inmóvil, sin distancia de proyectiles ni oleadas; prueba de mecánica, no balance final de campaña"}, "\t"))
	print("B-23: %d casos, topología %s,100000 pares en%d us" % [rows.size(), passed, elapsed])
	get_tree().quit(0 if passed else 1)

func eligible(a: Rect2i, b: Rect2i, level_a: int, level_b: int, stunned: bool, sold: bool) -> bool:
	return not stunned and not sold and level_a >= 2 and level_b >= 2 and not a.intersects(b) and a.grow(1).intersects(b)

func trial(id: String, level: int, armor: int, resistance: float, recipe: bool) -> Dictionary:
	var data: TowerData = load("res://data/towers/%s.tres" % id)
	var stats: TowerLevelData = data.levels[level - 1]
	var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
	var enemy_data: EnemyData = (load("res://data/enemies/normal.tres") as EnemyData).duplicate(true)
	enemy_data.armor = armor
	enemy_data.slow_resistance = resistance
	enemy_data.regen_percent_per_second = 0
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(10000, 0))
	enemy.setup(enemy_data, path, 1000000)
	var next_shot: float = 0
	var slowing: float = 0
	for frame: int in int(SECONDS / DT):
		var now: float = frame * DT
		if now + 0.00001 >= next_shot:
			var damage: int = stats.damage
			if enemy.is_slowed():
				damage = Rules.damage_with_bonus(damage, stats.bonus_vs_slowed_percent)
			if enemy.is_burning():
				damage = Rules.damage_with_bonus(damage, stats.bonus_vs_burning_percent)
			var slow: float = 0.15 if recipe and id != "tesla" else 0
			enemy.take_hit(damage, slow, 1.0)
			if recipe and id == "tesla":
				enemy.apply_burn(2, 1.0)
			next_shot += 1.0 / stats.fire_rate
		if enemy.is_slowed():
			slowing += enemy._slow_amount * DT
		enemy._update_slow(DT)
		enemy._update_burn(DT)
	var result: Dictionary = {"damage": 1000000 - enemy.health, "dps": (1000000 - enemy.health) / SECONDS,
		"equivalent_stop_seconds": slowing, "assumption": "Lado receptor solamente; sin daño ni estados del compañero"}
	enemy.free()
	path.free()
	return result
