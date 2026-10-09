# Recorta alfa y normaliza el mecanismo sin repintarlo; conserva formatos y centro de T216.
extends SceneTree

const OUT: String = "res://assets/sprites/towers/rendered/"
const SOURCES: Array[String] = ["disruptor_generated.png", "disruptor_level_2_generated.png", "disruptor_level_3_generated.png"]
const TARGETS: Array[String] = ["disruptor_atlas.png", "disruptor_level_2.png", "disruptor_level_3.png"]

func _initialize() -> void:
	for index: int in SOURCES.size():
		var source: Image = Image.load_from_file("res://art/t249-mejoras/sources/" + SOURCES[index])
		var low: Vector2i = Vector2i(source.get_width(), source.get_height())
		var high: Vector2i = Vector2i(-1, -1)
		for y: int in source.get_height():
			for x: int in source.get_width():
				if source.get_pixel(x, y).a > 0.08:
					low = Vector2i(mini(low.x, x), mini(low.y, y))
					high = Vector2i(maxi(high.x, x), maxi(high.y, y))
		source = source.get_region(Rect2i(low, high - low + Vector2i.ONE))
		var width: int = roundi(float(source.get_width()) * 112.0 / source.get_height())
		source.resize(width, 112, Image.INTERPOLATE_LANCZOS)
		var sprite: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		sprite.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i((128 - width) / 2, 8))
		if index == 0:
			assert(sprite.save_png(OUT + "turret_disruptor.png") == OK)
		var atlas: Image = Image.create(512, 256, false, Image.FORMAT_RGBA8)
		for frame: int in 8:
			atlas.blit_rect(sprite, Rect2i(0, 0, 128, 128), Vector2i(frame % 4 * 128, frame / 4 * 128))
		assert(atlas.save_png(OUT + TARGETS[index]) == OK)
		print("Disruptora nivel ", index + 1, ": cuerpo ", width, "×112, atlas 512×256")
	quit()
