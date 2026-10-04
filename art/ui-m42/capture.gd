extends Node
func _ready() -> void:
	DevMode.set_enabled(true,"user://test_t188_capture.json")
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.dev_panel.show()
	await get_tree().create_timer(0.3).timeout
	var choice: OptionButton = game.dev_panel._enemy_choice
	choice.select(4)
	choice.show_popup()
	choice.get_popup().set_focused_item(8)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/ui-m42/selector.png")
	print("POPUP ",choice.get_popup().position," ",choice.get_popup().size)
	choice.get_popup().scroll_to_item(choice.item_count - 1)
	choice.get_popup().set_focused_item(choice.item_count - 1)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/ui-m42/selector-final.png")
	choice.get_popup().hide()
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
