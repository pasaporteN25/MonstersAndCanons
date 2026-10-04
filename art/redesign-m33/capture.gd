extends Node

func _ready() -> void:
	SaveManager.save_path = "user://test_m33_capture.json"
	for id: String in ["options_menu", "level_select", "wiki_screen", "records_screen", "editor"]:
		var path: String = "res://scenes/ui/" + id + ".tscn" if id != "editor" else "res://scenes/editor/map_editor.tscn"
		var screen: Control = (load(path) as PackedScene).instantiate()
		add_child(screen)
		if screen is OptionsMenu:
			(screen as OptionsMenu).open()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://art/redesign-m33/" + id + ".png")
		screen.queue_free()
		await get_tree().process_frame
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.session.finish(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m33/end_screen.png")
	game.queue_free()
	await get_tree().process_frame
	var hall := HallOfFame.new()
	add_child(hall)
	hall.ask_name(2000, "AAAAA")
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m33/hall.png")
	get_tree().quit()

