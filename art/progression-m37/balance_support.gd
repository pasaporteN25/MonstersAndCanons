# Comparación reproducible con el bot existente; no toca progreso ni recursos oficiales.
extends "res://tools/balance_sim.gd"
var with_support: bool = false
var support_built: bool = false
var prepared: bool = false

func _initialize() -> void:
	seed(12345)
	with_support = OS.get_cmdline_user_args().has("support=1")
	super._initialize()
	print("Apoyo habilitado para laboratorio: ", with_support)

func _process(delta: float) -> bool:
	if not prepared:
		_prepare_support()
		prepared = true
	return super._process(delta)

func _prepare_support() -> void:
	if with_support:
		var standard: TowerData = load("res://data/towers/mechanical_standard.tres")
		if not game.available_towers.has(standard):
			game.available_towers.append(standard)
		game.build_controller.setup(game.level, game.session, game.balance, game.available_towers, game.tower_container)

func _buy_towers() -> void:
	if with_support and built >= 4 and not support_built:
		var standard: TowerData = load("res://data/towers/mechanical_standard.tres")
		if not game.session.can_afford(standard.levels[0].cost):
			return
		var best: Vector2i = Vector2i(-1,-1)
		var best_count: int = -1
		for cell: Vector2i in _free_cells():
			var center: Vector2 = game.level.cell_center(cell)
			var count: int = 0
			for tower: Node2D in game.tower_container.get_children():
				if center.distance_to(tower.global_position) <= Rules.tiles_to_px(standard.levels[0].range_tiles):
					count += 1
			if count > best_count:
				best_count = count
				best = cell
		if game.build_controller.try_build(standard,best):
			support_built = true
			print("Estandarte comprado · aliados en aura: ",best_count)
	super._buy_towers()
