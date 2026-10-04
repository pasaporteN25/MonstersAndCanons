extends SceneTree

const OUT := "res://art/prototypes/full-pass/"


func _initialize() -> void:
	var assets: Array[String] = [
		"assets/sprites/towers/base_1.svg", "assets/sprites/towers/base_2.svg",
		"assets/sprites/towers/base_3.svg", "assets/sprites/towers/turret_basic.svg",
		"assets/sprites/towers/turret_cannon.svg", "assets/sprites/towers/turret_frost.svg",
		"assets/sprites/towers/turret_sniper.svg", "assets/sprites/towers/turret_fire.svg",
		"assets/sprites/towers/turret_multi.svg", "assets/sprites/towers/turret_burst.svg",
		"assets/sprites/towers/turret_tesla.svg", "assets/sprites/towers/turret_mortar.svg",
		"assets/sprites/ui/stat_gold.svg", "assets/sprites/ui/stat_lives.svg",
		"assets/sprites/ui/stat_points.svg", "assets/sprites/ui/stat_wave.svg",
		"assets/sprites/effects/flame.svg",
	]
	for source: String in assets:
		var image := Image.new()
		var error: Error = image.load_svg_from_string(FileAccess.get_file_as_string("res://" + source), 4.0)
		if error != OK:
			push_error("SVG inválido: " + source)
			quit(1)
			return
		var name: String = source.get_file().get_basename()
		error = image.save_png(OUT + name + ".png")
		if error != OK:
			push_error("No se pudo guardar: " + name)
			quit(1)
			return
	print("%d SVG renderizados" % assets.size())
	quit()
