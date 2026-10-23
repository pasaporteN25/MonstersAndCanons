# Captura el cartel desktop de entrada a un nivel, encima de un selector de campaña de prueba.
extends Node

const TEMP_SAVE: String = "user://test_capture_level_intro.json"


func _ready() -> void:
	call_deferred("capture")


func capture() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var output: String = args[0] if args.size() > 0 else "user://level_intro.png"
	if args.size() > 1:
		var dimensions: PackedStringArray = args[1].split("x")
		if dimensions.size() == 2:
			if args.has("fullscreen"):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
				get_window().size = Vector2i(int(dimensions[0]), int(dimensions[1]))
				get_window().position = Vector2i.ZERO
	for _frame: int in 10:
		await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var original_save_path: String = String(save.get("save_path"))
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.set("save_path", TEMP_SAVE)
	save.call("load_save")
	save.call("set_setting", "ui_mode", 2)
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(select)
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(intro)
	intro.open("Nido", "El lindero", "Los árboles se cierran sobre el sendero. Prepará las torres antes de que lleguen los primeros invasores.", &"bosque")
	for _frame: int in 12:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute_output: String = ProjectSettings.globalize_path(output)
	DirAccess.make_dir_recursive_absolute(absolute_output.get_base_dir())
	var error: Error = image.save_png(absolute_output)
	print("Captura de entrada: %s (%s), error=%d" % [absolute_output, image.get_size(), error])
	intro.queue_free()
	select.queue_free()
	await get_tree().process_frame
	save.set("save_path", original_save_path)
	save.call("load_save")
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	get_tree().quit(1 if error != OK else 0)
