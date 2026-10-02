# Normaliza los cinco conceptos sin integrarlos al bestiario.
extends SceneTree
const FRAMER: Script = preload("res://tools/prepare_monster_sprites.gd")
const ROOT: String = "res://art/redesign-m27/"
const NAMES: Array[String] = ["guardian", "healer", "shaman", "mirror", "boss"]
func _initialize() -> void:
	for id: String in NAMES:
		var image: Image = Image.load_from_file(ROOT + "sources/" + id + ".png")
		if image == null:
			quit(1)
			return
		var framed: Image = FRAMER.frame(image)
		if framed.save_png(ROOT + "monsters/" + id + ".png") != OK:
			quit(1)
			return
		print(id + ": RGBA256, pies alineados")
	quit()
