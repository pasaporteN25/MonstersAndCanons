# Rasteriza las fuentes vectoriales y empaqueta las cuatro direcciones, sin tocar datos.
extends SceneTree
func _initialize() -> void:
	for id: String in ["ratero", "cargador"]:
		var atlas: Image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		for row: int in 4:
			for phase: int in 4:
				var image: Image = Image.new()
				var source: String = FileAccess.get_file_as_string("res://art/t257-cuadrilla/sources/%s_%d_%d.svg" % [id, row, phase])
				assert(image.load_svg_from_string(source, 4.0) == OK)
				image.convert(Image.FORMAT_RGBA8)
				atlas.blit_rect(image, Rect2i(0, 0, 256, 256), Vector2i(phase * 256, row * 256))
				if row == 0 and phase == 0:
					assert(image.save_png("res://assets/sprites/enemies/rendered/%s.png" % id) == OK)
		assert(atlas.save_png("res://assets/sprites/enemies/rendered/%s_walk.png" % id) == OK)
	quit()
