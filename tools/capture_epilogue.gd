# Capturas reales de las dos variantes del epílogo (T546, RF-729): abre `EpilogueScreen` con el texto oficial del
# nivel 15 y guarda un PNG de la luminosa y otro de la oscura, con el tamaño de ventana que se pida.
# Se corre con ventana (no `--headless`) y con la carpeta de salida FUERA del repo:
#   godot --path . res://tools/capture_epilogue.tscn -- /ruta/de/salida 1280x720
extends Node


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://capturas"
	DirAccess.make_dir_recursive_absolute(out)
	var size: Vector2i = Vector2i(1280, 720)
	if args.size() > 1:
		var parts: PackedStringArray = args[1].split("x")
		size = Vector2i(int(parts[0]), int(parts[1]))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = size
	get_window().position = Vector2i.ZERO
	for _i: int in 10:
		await get_tree().process_frame
	var epilogue := EpilogueScreen.new()
	add_child(epilogue)
	var text: String = GameFlow.level(GameFlow.level_count() - 1).epilogue_text
	for variant: Array in [["luminosa", true], ["oscura", false]]:
		epilogue.open(text, variant[1])
		for _i: int in 6:
			await get_tree().process_frame
		var image: Image = get_viewport().get_texture().get_image()
		var path: String = "%s/epilogo_%s_%dx%d.png" % [out, variant[0], size.x, size.y]
		image.save_png(path)
		print("guardada ", path, " ", image.get_size())
		epilogue.close()
	get_tree().quit()
