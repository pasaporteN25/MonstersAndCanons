extends SceneTree

const PREVIEW := "res://art/prototypes/towers-3d/"
const ORIGINAL := "res://assets/sprites/towers/"


func _initialize() -> void:
	var rendered: int = 0
	for name: String in ["base_1", "base_2", "base_3", "turret_cannon", "turret_frost"]:
		var options: Array[String] = ["original", "a", "b"]
		if name == "base_2" or name == "turret_frost" or name == "turret_cannon":
			options.append("c")
		for option: String in options:
			var source: String = ORIGINAL + name + ".svg" if option == "original" else PREVIEW + option + "_" + name + ".svg"
			var image := Image.new()
			var error: Error = image.load_svg_from_string(FileAccess.get_file_as_string(source), 4.0)
			if error != OK:
				push_error("No se pudo renderizar: " + source)
				quit(1)
				return
			error = image.save_png(PREVIEW + option + "_" + name + ".png")
			if error != OK:
				push_error("No se pudo guardar: " + option + "_" + name)
				quit(1)
				return
			rendered += 1
	print("%d SVG renderizados con Godot." % rendered)
	quit()
