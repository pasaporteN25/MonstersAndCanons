# Capturas reales de los grupos de Opciones (M75, T468), PC y celular simulado a 1280×720.
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
		var options: OptionsMenu = (load(OPTIONS_PATH) as PackedScene).instantiate() as OptionsMenu
		options.admin_available = true
		add_child(options)
		options.open()
		for i: int in 8:
			await get_tree().process_frame
		var tag: String = "pc" if mode == 2 else "celular-simulado"
		_shot("t468-%s-opciones-arriba.png" % tag)
		var scroll: ScrollContainer = options.get_node("%Scroll")
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
		for i: int in 3:
			await get_tree().process_frame
		_shot("t468-%s-opciones-abajo.png" % tag)
		options.queue_free()
		await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = old_save_path
	save.load_save()
	print("T468: capturas guardadas en %s" % _out)
	get_tree().quit()

func _shot(filename: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s" % [_out, filename])
	print("Captura %s: %dx%d" % [filename, image.get_width(), image.get_height()])
