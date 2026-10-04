# Exposición controlada: camino oficial, celdas construibles y física real al cruzar un extremo.
extends Node
func _ready() -> void:
	DevMode.set_enabled(true,"user://test_m44_exposure.json")
	GameFlow.current_index = -1
	var results: Array[Dictionary] = []
	for index: int in [5,6]:
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(index)
		add_child(game)
		var path: Path2D = game.level.get_ground_path(0)
		var endpoints: int = 0
		var threatened: Dictionary = {}
		var sample: Vector2i = Vector2i(-1,-1)
		var endpoint_distance: float = 0
		for segment: Dictionary in ChargeRules.segments(path.curve):
			if float(segment.end)-float(segment.start) < Rules.tiles_to_px(3): continue
			var end: Vector2 = path.to_global(segment.position)
			endpoints += 1
			for cell: Vector2i in game.level.ground.get_used_cells():
				if game.level.is_buildable(cell) and end.distance_to(game.level.cell_center(cell)) <= Rules.tiles_to_px(1.25):
					threatened[str(cell)] = true
					if sample.x < 0:
						sample = cell
						endpoint_distance = segment.end
		var source_cell: Vector2i = Vector2i(-1,-1)
		for cell: Vector2i in game.level.ground.get_used_cells():
			if cell != sample and game.level.is_buildable(cell) and cell.distance_to(sample) <= 2:
				source_cell = cell
				break
		assert(sample.x >= 0 and source_cell.x >= 0,"exposición requiere celdas legales")
		var gun: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
		gun.setup(preload("res://data/towers/basic.tres"))
		gun.position = game.level.cell_center(sample)
		game.tower_container.add_child(gun)
		gun.set_physics_process(false)
		var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
		enemy.setup(preload("res://data/enemies/rammer.tres"),path,60)
		game.enemies.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.distance = endpoint_distance-1
		enemy._charge_progress = Rules.tiles_to_px(3)
		enemy._physics_process(0.03)
		assert(gun.wear_percent == 20)
		var support: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
		support.setup(preload("res://data/towers/mechanical_standard.tres"))
		support.position = game.level.cell_center(source_cell)
		game.tower_container.add_child(support)
		support.set_physics_process(false)
		var repair_times: Array[float] = []
		for level: int in 3:
			support.level_index = level
			gun.wear_percent = 20
			var elapsed: float = 0
			while gun.wear_percent > 0 and elapsed < 30:
				gun._update_repair(0.1)
				elapsed += 0.1
			repair_times.append(snappedf(elapsed,0.1))
		assert(repair_times[0] < 10.2 and repair_times[2] < 5.2)
		results.append({"level":index+1,"entrance":0,"long_straights":endpoints,"threatened_cells":threatened.keys(),"gun_cell":str(sample),"support_cell":str(source_cell),"impact_wear":20,"repair_seconds_levels_1_2_3":repair_times})
		game.queue_free()
		await get_tree().process_frame
	var file: FileAccess = FileAccess.open("res://art/balance-m44/exposure.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t")+"\n")
	if FileAccess.file_exists(SaveManager.save_path): DirAccess.remove_absolute(SaveManager.save_path)
	print("M44_EXPOSURE ",JSON.stringify(results))
	get_tree().quit()
