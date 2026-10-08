# Capturas de integración, no partidas humanas: posiciones legales y enemigos congelados.
extends Node

func _ready() -> void:
	DevMode.set_enabled(true,"user://test_m45_capture.json")
	GameFlow.current_index = -1
	for index: int in [7,8]:
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(index)
		add_child(game)
		game.dev_enable_support(true)
		await get_tree().process_frame
		var gun_cell: Vector2i = Vector2i(8,0) if index == 7 else Vector2i(5,0)
		var source_cell: Vector2i = Vector2i(6,0) if index == 7 else Vector2i(3,0)
		assert(game.build_controller.try_build(preload("res://data/towers/basic.tres"),gun_cell))
		assert(game.build_controller.try_build(preload("res://data/towers/mechanical_standard.tres"),source_cell))
		var gun: Tower = game.tower_container.get_child(0)
		gun.wear_percent = 20
		gun.set_physics_process(false)
		gun.queue_redraw()
		var path: Path2D = game.level.get_ground_path(0)
		var distance: float = Rules.tiles_to_px(5)
		for id: String in (["guardian","rammer","thief"] if index == 7 else ["guardian","healer","rammer","thief"]):
			var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
			enemy.setup(load("res://data/enemies/"+id+".tres"),path,200)
			game.enemies.add_child(enemy)
			enemy.set_physics_process(false)
			enemy.distance = distance
			enemy.global_position = path.to_global(path.curve.sample_baked(distance))
			distance += Rules.tiles_to_px(1)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://art/campaign-m45/level_%02d.png" % (index+1))
		game.queue_free()
		await get_tree().process_frame
	if FileAccess.file_exists(SaveManager.save_path): DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
