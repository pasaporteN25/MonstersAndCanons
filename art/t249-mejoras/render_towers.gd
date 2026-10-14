# Comparación de las diez torres con márgenes originales, sin agrandar artificialmente la Disruptora.
extends SceneTree

func _initialize() -> void:
	var names: Array[String] = ["basic", "sniper", "fire", "multi", "burst", "frost", "tesla", "cannon", "mortar", "disruptor"]
	for phase: String in ["before", "after"]:
		for size: int in [34, 64, 112]:
			var slot: int = size + 20
			var sheet: Image = Image.create(slot * 5, slot * 2, false, Image.FORMAT_RGBA8)
			sheet.fill(Color("#171923"))
			for i: int in names.size():
				var path: String = "res://assets/sprites/towers/rendered/turret_" + names[i] + ".png"
				if phase == "before" and names[i] == "disruptor":
					path = "res://art/t249-mejoras/sources/before/assets/sprites/towers/rendered/turret_disruptor.png"
				var source: Image = Image.load_from_file(path)
				source.resize(size, size, Image.INTERPOLATE_LANCZOS)
				sheet.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i(i % 5 * slot + 10, i / 5 * slot + 10))
			assert(sheet.save_png("res://art/t249-mejoras/%s/towers_%d.png" % [phase, size]) == OK)
	quit()
