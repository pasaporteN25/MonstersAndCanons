# Capturas reales de «Novedades de esta versión» (M67, T373): abre la pantalla con 8 novedades y con 1, en modo PC y
# en modo celular, y guarda un PNG de cada una. Se corre con ventana (no `--headless`: sin dibujo no hay imagen) y con
# la carpeta de salida FUERA del repo:
#   godot --path . res://tools/capture_news.tscn -- /ruta/de/salida [1280x720]
# No cambia `config/version`: la entrada de prueba se arma acá. Usa un guardado temporal que borra al terminar.
extends Node

const TEMP_SAVE: String = "user://capture_news.json"

var _out: String = "user://capturas"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	if args.size() > 1:
		var parts: PackedStringArray = args[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		get_window().size = Vector2i(int(parts[0]), int(parts[1]))
		get_window().position = Vector2i.ZERO
		for _i: int in 10:
			await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	save.save_path = TEMP_SAVE
	save.load_save()
	var labels: Dictionary = NewsData.load_file().labels
	for mobile: bool in [false, true]:
		save.set_setting("ui_mode", 1 if mobile else 2)
		for count: int in [8, 1]:
			var screen := NewsScreen.new()
			add_child(screen)
			screen.open(_entry(count, count == 8), labels)
			for _i: int in 24:
				await get_tree().process_frame
			var image: Image = get_viewport().get_texture().get_image()
			var path: String = "%s/novedades_%s_%d.png" % [_out, "celular" if mobile else "pc", count]
			image.save_png(path)
			print("captura: %s" % path)
			screen.close()
			await get_tree().process_frame
			screen.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.set_setting("ui_mode", 0)
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	get_tree().quit()


func _entry(count: int, draft: bool) -> Dictionary:
	var items: Array = []
	var titles: PackedStringArray = ["15 niveles, una historia", "Torres que se mejoran", "Monstruos con carácter", "Asedio",
		"Tus propios mapas", "PC y celular", "Intro y tutorial", "Mejoras y jefes con entrada"]
	for i: int in count:
		items.append({"titulo": titles[i], "icono": "",
			"texto": "Texto de prueba con la longitud de una novedad real, para ver cuántas líneas ocupa en el panel (%d)." % (i + 1)})
	return {"id": "1.0.0", "tipo": "presentacion", "borrador": draft, "titulo": "Monsters & Canons 1.0",
		"subtitulo": "Esto es lo que trae el juego completo.", "cabecera": "", "novedades": items}
