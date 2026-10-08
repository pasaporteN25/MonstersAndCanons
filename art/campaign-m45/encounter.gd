# Oleada8 oficial con una defensa mínima expuesta. No fuerza carga, desgaste ni reparación.
extends Node

func _ready() -> void:
	DevMode.set_enabled(true,"user://test_m45_encounter.json")
	GameFlow.current_index = -1
	var results: Array[Dictionary] = []
	for index: int in [7,8]:
		seed(42)
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(index)
		add_child(game)
		game.spawner.rng.seed = 42
		game.dev_enable_support(true)
		var gun_cell: Vector2i = Vector2i(8,0) if index == 7 else Vector2i(10,4)
		var source_cell: Vector2i = Vector2i(6,0) if index == 7 else Vector2i(12,4)
		assert(game.build_controller.try_build(preload("res://data/towers/basic.tres"),gun_cell))
		assert(game.build_controller.try_build(preload("res://data/towers/mechanical_standard.tres"),source_cell))
		var gun: Tower = game.tower_container.get_child(0)
		var amounts: Dictionary = {"damage":0.0,"repair":0.0}
		gun.wear_changed.connect(func(_wear: float,change: float) -> void:
			if change > 0: amounts.damage += change
			else: amounts.repair -= change)
		game.session.wave = 7
		game.start_next_wave()
		var elapsed: float = 0
		while elapsed < 30:
			await get_tree().physics_frame
			elapsed += 1.0/Engine.physics_ticks_per_second
		assert(amounts.damage > 0 and amounts.repair > 0,"oleada produce impacto y reparación reales")
		assert(is_zero_approx(gun.wear_percent),"recupera la torre expuesta")
		results.append({"level":index+1,"wave":8,"seed":42,"seconds":30,"gun_cell":str(gun_cell),"support_cell":str(source_cell),"wear_received":amounts.damage,"repaired":snappedf(amounts.repair,0.01),"remaining_wear":gun.wear_percent,"lives_at_cutoff":game.session.lives})
		game.queue_free()
		await get_tree().process_frame
	var file: FileAccess = FileAccess.open("res://art/campaign-m45/encounters.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t")+"\n")
	if FileAccess.file_exists(SaveManager.save_path): DirAccess.remove_absolute(SaveManager.save_path)
	print("M45_ENCOUNTERS ",JSON.stringify(results))
	get_tree().quit()
