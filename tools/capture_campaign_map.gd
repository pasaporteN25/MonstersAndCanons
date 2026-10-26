# Captura el selector planetario con una partida temporal para revisar sus estados en desktop.
# Uso: godot --path . res://tools/capture_campaign_map.tscn -- <salida.png> <ancho>x<alto> [map|cards] [mobile] [all] [open=N] [select=N] [scroll=0..1]
# `mobile`: modo celular simulado; `all`: los 15 niveles abiertos con estrellas variadas; `open=N`: abre los niveles 1 a N (3 a 15; sin él, la partida temporal abre 1 a 3, solo la zona A), con victorias en los anteriores (T488); `select=`: región seleccionada y con foco (0 a 14); `scroll=`: fracción del desplazamiento horizontal (T471).
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
	var game_flow: Node = get_node("/root/GameFlow")
	var original_save_path: String = String(save.get("save_path"))
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.set("save_path", TEMP_SAVE)
	save.call("load_save")
	save.call("set_setting", "ui_mode", 1 if args.has("mobile") else 2)
	save.call("set_setting", "selector_style", CampaignMap.STYLE_CARDS if style == "cards" else CampaignMap.STYLE_MAP)
	var first: LevelData = game_flow.call("level", 0) as LevelData
	var second: LevelData = game_flow.call("level", 1) as LevelData
	var third: LevelData = game_flow.call("level", 2) as LevelData
	save.call("record_victory", first.id, first.starting_lives, 100)
	save.call("unlock", second.id)
	save.call("record_victory", second.id, int(float(second.starting_lives) * 0.5), 80)
	save.call("unlock", third.id)
	if args.has("all"):
		for i: int in range(3, 15):
			var level: LevelData = game_flow.call("level", i) as LevelData
			save.call("unlock", level.id)
			if i < 9:
				save.call("record_victory", level.id, level.starting_lives if i % 2 == 0 else maxi(level.starting_lives / 2, 1), 100)
	for arg: String in args:
		if arg.begins_with("open="):  # T488: abre los niveles hasta el N (N→N+1): `open=6` descubre la zona B, `open=11` la C
			var last_open: int = clampi(int(arg.trim_prefix("open=")), 3, 15)
			for i: int in range(3, last_open):
				var level: LevelData = game_flow.call("level", i) as LevelData
				save.call("record_victory", (game_flow.call("level", i - 1) as LevelData).id, (game_flow.call("level", i - 1) as LevelData).starting_lives, 100)
				save.call("unlock", level.id)
	game_flow.set("select_page", &"campaign")
	var select: Control = (load(SELECT_SCENE) as PackedScene).instantiate() as Control
	get_tree().root.add_child(select)
	get_tree().current_scene = select
	for _frame: int in 12:
		await get_tree().process_frame
	for arg: String in args:
		if arg.begins_with("select=") and (select.get("map_view") as CampaignMapView) != null:
			(select.get("map_view") as CampaignMapView).pointer_select(int(arg.trim_prefix("select=")))
			for _frame: int in 4:
				await get_tree().process_frame
	for arg: String in args:
		if arg.begins_with("scroll=") and (select.get("map_view") as CampaignMapView) != null:
			var scroll: ScrollContainer = (select.get("map_view") as CampaignMapView).map_scroll()
			var bar: ScrollBar = scroll.get_h_scroll_bar()
			scroll.scroll_horizontal = int((bar.max_value - bar.page) * float(arg.trim_prefix("scroll=")))
			for _frame: int in 3:
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
