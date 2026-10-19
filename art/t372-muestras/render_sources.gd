# Ejecutar desde un proyecto aislado: no importa ni abre el juego.
extends SceneTree
func _init() -> void:
	var root: String = OS.get_cmdline_user_args()[0]
	for name: String in ["news_icon_map", "news_icon_tower", "news_header_plain"]:
		var image := Image.new()
		var error: Error = image.load_svg_from_string(FileAccess.get_file_as_string(root + "/sources/" + name + ".svg"))
		if error != OK:
			push_error("No se pudo rasterizar " + name)
			quit(1)
			return
		if name == "news_header_plain":
			image.convert(Image.FORMAT_RGB8)
		if image.save_png(root + "/" + name + ".png") != OK:
			quit(1)
			return
		print(name + ": " + str(image.get_size()))
	quit()
