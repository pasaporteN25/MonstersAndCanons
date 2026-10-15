# Hojas de comparación: rasterizador SVG de Godot, fondos de los biomas y tamaños reales.
extends SceneTree

func _initialize() -> void:
	var parser: JSON = JSON.new()
	assert(parser.parse(FileAccess.get_file_as_string("res://art/t260-decoration/manifest.json")) == OK)
	var entries: Array = parser.data
	var desert: Array[String] = ["cactus", "roca_roja", "huesos"]
	var snow: Array[String] = ["pino", "abeto", "roca_nieve"]
	var forest: Array[String] = ["tree", "bush", "helecho", "tronco"]
	var ruins: Array[String] = ["columna", "estatua", "bloque", "roca_marcada", "simbolo_ruina", "hito"]
	for phase: String in ["before", "after"]:
		for size: int in [34, 220]:
			var slot: int = size + 24
			var sheet: Image = Image.create(slot * 7, slot * ceili(entries.size() / 7.0), false, Image.FORMAT_RGBA8)
			sheet.fill(Color("#383b36"))
			for i: int in entries.size():
				var path: String = entries[i]["archivo"]
				var name: String = path.get_file().get_basename()
				var biome: String = "pradera"
				if name in desert:
					biome = "desierto"
				elif name in snow:
					biome = "nieve"
				elif name in forest:
					biome = "bosque"
				elif name in ruins:
					biome = "ruinas"
				elif name in ["roca_negra", "grieta"]:
					biome = "volcan"
				elif name in ["junco", "hongo"]:
					biome = "pantano"
				var ground: Image = Image.load_from_file("res://assets/tiles/rendered/ground_%s.png" % biome)
				ground.resize(slot, slot, Image.INTERPOLATE_LANCZOS)
				var origin: Vector2i = Vector2i(i % 7 * slot, i / 7 * slot)
				sheet.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), origin)
				if phase == "before":
					path = "art/t260-decoration/sources/before/" + path.get_file()
				var source: Image = Image.new()
				assert(source.load_svg_from_string(FileAccess.get_file_as_string("res://" + path), float(size) / 64.0) == OK)
				assert(source.get_size() == Vector2i(size, size))
				sheet.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), origin + Vector2i(12, 12))
				assert(source.save_png("res://art/t260-decoration/%s/%s_%d.png" % [phase, name, size]) == OK)
			assert(sheet.save_png("res://art/t260-decoration/%s/contact_%d.png" % [phase, size]) == OK)
	print("T260: 27 dibujos, antes/después a 34 y 220 px, sobre terrenos reales.")
	quit()
