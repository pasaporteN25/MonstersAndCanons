# Capturas reales de las solapas de Opciones (M75, T481), PC y celular simulado a 1280×720.
# Uso con ventana y carpeta de salida fuera del repositorio:
#   godot --path . res://tools/capture_options_groups.tscn -- /ruta/de/salida
extends Node

const OPTIONS_PATH: String = "res://scenes/ui/options_menu.tscn"
const TEMP_SAVE: String = "user://capture_options_groups.json"
var _out: String = "user://capturas"

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = Vector2i(1280, 720)
	get_window().position = Vector2i.ZERO
	for i: int in 10:
		await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var old_save_path: String = save.save_path
	save.save_path = TEMP_SAVE
	save.load_save()
	for mode: int in [2, 1]:  # UiMode.PC y UiMode.MOBILE; valores estables del enum.
		save.set_setting("ui_mode", mode)
		var options: Control = (load(OPTIONS_PATH) as PackedScene).instantiate()
		options.set("admin_available", true)
		add_child(options)
		options.call("open")
		for i: int in 8:
			await get_tree().process_frame
		var tabs: Array = [0, 1, 2, 3, 4] if mode == 2 else [0, 1, 2, 3]
		for tab_index: int in tabs:
			options.call("_select_tab", tab_index)
			for i: int in 4:
				await get_tree().process_frame
			var label: String = "pc" if mode == 2 else "celular"
			_shot("t481-%s-solapa-%d.png" % [label, tab_index + 1])
		options.queue_free()
		await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = old_save_path
	save.load_save()
	print("T481: capturas guardadas en %s" % _out)
	get_tree().quit()

func _shot(filename: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s" % [_out, filename])
	print("Captura %s: %dx%d" % [filename, image.get_width(), image.get_height()])
