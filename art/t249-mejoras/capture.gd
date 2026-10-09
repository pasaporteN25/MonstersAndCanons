# Capturas reproducibles del juego real en ventana; preparación visual, no balance humano.
extends Node

var phase: String = "before"

func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("phase="):
			phase = argument.trim_prefix("phase=")
	DevMode.set_enabled(true, "user://test_t249_capture.json")
	GameFlow.current_index = -1
	for number: int in [1, 6, 7, 8, 10]:
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(number - 1)
		add_child(game)
		await get_tree().process_frame
		await _save("level_%02d" % number)
		if number >= 6:
			game.session.earn(2000)
			var field: ObstacleField = game.infrastructure.field
			for site: Vector2i in field.extraction_cells():
				game.infrastructure.enable(site)
			for obstacle: ObstacleSpec in game.level_data.obstacles:
				if field.is_removable(obstacle.cell):
					game.infrastructure.order(obstacle.cell)
					field.tick(field.seconds_of(obstacle.cell) * 0.4)
					await _save("level_%02d_working" % number)
					field.tick(100.0)
					await get_tree().create_timer(0.7).timeout
					await _save("level_%02d_cleared" % number)
					break
		game.queue_free()
		await get_tree().process_frame
	# Sin modificar el nivel de campaña: modo de pruebas habilita la torre reservada.
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(0)
	add_child(game)
	await get_tree().process_frame
	game.session.earn(2000)
	game.session.add_resources(10)
	game.dev_enable_collections(true)
	game.build_controller.try_build(preload("res://data/towers/disruptor.tres"), Vector2i(3, 3))
	await _save("disruptor_toolbar")
	game.queue_free()
	await get_tree().process_frame
	get_tree().quit()

func _save(label: String) -> void:
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var folder: String = "res://art/t249-mejoras/" + phase
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var error: Error = get_viewport().get_texture().get_image().save_png(folder + "/" + label + ".png")
	assert(error == OK)
	print("T249 captura: ", phase, "/", label)
