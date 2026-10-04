# Prepara los cinco diseños de M25 aprobados por Lucas, sin alterar la integración de Claude.
extends SceneTree

const FRAMER: Script = preload("res://tools/prepare_monster_sprites.gd")
const IDS: Array[String] = ["armored", "troll", "flyer", "spider", "spiderling"]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/redesign-m26/monsters/"))
	for id: String in IDS:
		var source: Image = Image.load_from_file("res://art/redesign-m25/sources/" + id + "_concept.png")
		if source == null or source.is_empty():
			quit(1)
			return
		var framed: Image = FRAMER.frame(source)
		if framed.save_png("res://art/redesign-m26/monsters/" + id + ".png") != OK:
			quit(1)
			return
	print("Cinco monstruos aprobados: marco y pivote compatibles con M24.")
	quit()
