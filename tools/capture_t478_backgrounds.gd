# Captura la integración real de los fondos en una partida, una imagen por tema.
# Uso: godot --path . res://tools/capture_t478_backgrounds.tscn -- <salida.png> <ancho>x<alto> <tema> [min|max]
extends Node

const HOST_SCENE: PackedScene = preload("res://scenes/host/presentation_host.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEMP_SAVE: String = "user://test_capture_t478.json"


func _ready() -> void:
	call_deferred("capture")


func capture() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("Uso: <salida.png> <ancho>x<alto> <tema> [min|max]")
		get_tree().quit(1)
		return
	var parts: PackedStringArray = args[1].split("x")
	if parts.size() != 2:
		push_error("El tamaño debe tener formato anchoxalto.")
		get_tree().quit(1)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = Vector2i(int(parts[0]), int(parts[1]))
	get_window().position = Vector2i.ZERO
	for _frame: int in 10:
		await get_tree().process_frame

	var save_manager: Node = get_node("/root/SaveManager")
	var game_flow: Node = get_node("/root/GameFlow")
	var original_save_path: String = String(save_manager.get("save_path"))
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save_manager.set("save_path", TEMP_SAVE)
	save_manager.call("load_save")
	save_manager.call("set_setting", "ui_mode", UiMode.PC)
	save_manager.call("mark_tutorial_done")
	var theme: StringName = StringName(args[2])
	var campaign_indices: Dictionary = {
		&"pradera": 0, &"bosque": 5, &"ruinas": 7, &"desierto": 9, &"nieve": 12,
	}
	if campaign_indices.has(theme):
		game_flow.set("current_index", int(campaign_indices[theme]))
		game_flow.set("test_level", null)
	else:
		var base_level: LevelData = game_flow.call("level", 12) as LevelData
		var editor_level: LevelData = base_level.duplicate(true) as LevelData
		editor_level.theme = theme
		game_flow.set("current_index", -1)
		game_flow.set("test_level", editor_level)

	var host: Control = HOST_SCENE.instantiate() as Control
	get_tree().root.add_child(host)
	host.call("install_scene", GAME_SCENE)
	for _frame: int in 30:
		await get_tree().process_frame
	var game: Game = host.get_active_screen() as Game
	if args.size() > 3 and args[3] == "max":
		game.camera_controller.call("_zoom_at", Vector2(640.0, 336.0), 100.0)
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_tree().root.get_texture().get_image()
	var output_path: String = ProjectSettings.globalize_path(args[0])
	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var error: Error = image.save_png(output_path)
	print("Captura T478: tema=%s, ventana=%s, zoom=%s, salida=%s, error=%d" % [
		String(theme), str(get_window().size), args[3] if args.size() > 3 else "min", output_path, error,
	])
	host.queue_free()
	await get_tree().process_frame
	save_manager.set("save_path", original_save_path)
	save_manager.call("load_save")
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	get_tree().quit(1 if error != OK else 0)
