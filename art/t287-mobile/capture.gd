extends Node


func _ready() -> void:
	run.call_deferred()


func _frames(count: int = 3) -> void:
	for i: int in count:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await _frames()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/t287-mobile/%s.png" % name)


func run() -> void:
	var wide: bool = OS.get_cmdline_user_args().has("wide")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1600 if wide else 1280, 720))
	await _frames(6)
	var save_manager: Node = get_node("/root/SaveManager")
	var flow: Node = get_node("/root/GameFlow")
	save_manager.save_path = "user://test_t287_capture.json"
	save_manager.load_save()
	save_manager.set_setting("ui_mode", 1)
	flow.intro_pending = false
	flow.forced_seed = 3
	var tag: String = "20x9" if wide else "16x9"
	for index: int in [0, 14]:
		flow.current_index = index
		flow.current_community = null
		var game: Node = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
		add_child(game)
		await _frames(6)
		game.session.gold = 5000
		game._refresh_mobile_catalog()
		await _shot("level%d_empty_%s" % [index + 1, tag])
		game.mobile_hud.open_catalog()
		await _shot("level%d_catalog_%s" % [index + 1, tag])
		game.mobile_hud.close_catalog()
		game.build_controller.select(0)
		await _shot("level%d_ghost_%s" % [index + 1, tag])
		game.build_controller.confirm_ghost()
		if game.tower_container.get_child_count() > 0:
			game.build_controller.select_placed(game.tower_container.get_child(0))
		await _shot("level%d_selected_%s" % [index + 1, tag])
		game.queue_free()
		await _frames()
	if FileAccess.file_exists(save_manager.save_path):
		DirAccess.remove_absolute(save_manager.save_path)
	get_tree().quit()
