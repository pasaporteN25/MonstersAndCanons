# Captura el selector planetario con una partida temporal para revisar sus estados en desktop.
# Uso: godot --path . res://tools/capture_campaign_map.tscn -- <salida.png> <ancho>x<alto>
extends Node

const TEMP_SAVE: String = "user://test_capture_campaign_map.json"
const SELECT_SCENE: String = "res://scenes/ui/level_select.tscn"


func _ready() -> void:
	call_deferred("capture")


func capture() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var output: String = args[0] if args.size() > 0 else "user://campaign_map.png"
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
	var style: String = args[2] if args.size() > 2 else "map"
	var save: Node = get_node("/root/SaveManager")
	var original_save_path: String = String(save.get("save_path"))
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.set("save_path", TEMP_SAVE)
	save.call("load_save")
	save.call("set_setting", "ui_mode", 2)
	save.call("set_setting", "selector_style", CampaignMap.STYLE_CARDS if style == "cards" else CampaignMap.STYLE_MAP)
	var first: LevelData = GameFlow.level(0)
	var second: LevelData = GameFlow.level(1)
	var third: LevelData = GameFlow.level(2)
	save.call("record_victory", first.id, first.starting_lives, 100)
	save.call("unlock", second.id)
	save.call("record_victory", second.id, int(float(second.starting_lives) * 0.5), 80)
	save.call("unlock", third.id)
	GameFlow.select_page = &"campaign"
	var select: Control = (load(SELECT_SCENE) as PackedScene).instantiate() as Control
	get_tree().root.add_child(select)
	get_tree().current_scene = select
	for _frame: int in 12:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = select.get_viewport().get_texture().get_image()
	var absolute_output: String = ProjectSettings.globalize_path(output)
	DirAccess.make_dir_recursive_absolute(absolute_output.get_base_dir())
	var error: Error = image.save_png(absolute_output)
	print("Captura de campaña (%s): %s (%s, ventana %s), error=%d" % [style, absolute_output, image.get_size(), get_window().size, error])
	select.queue_free()
	await get_tree().process_frame
	save.set("save_path", original_save_path)
	save.call("load_save")
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	get_tree().quit(1 if error != OK else 0)
