extends Node

func _ready() -> void:
	DevMode.set_enabled(true, "user://test_m32_capture.json")
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.dev_panel.show()
	game.dev_panel.metrics_toggled.emit(true)
	await get_tree().create_timer(1.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m32/hud_admin.png")
	game.dev_panel.hide()
	game.open_pause_menu()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m32/pause.png")
	get_tree().paused = false
	get_tree().quit()
