# Lectura a tamaños contractuales; orden Coloso, Pedazo, Guardián, Soberano, Tanque.
extends SceneTree
const IDS: Array[String] = ["colossus", "colossus_shard", "guardian", "boss", "tank"]
func _initialize() -> void:
	for side: int in [34, 64, 112, 220]:
		var slot: int = side + 24
		var sheet: Image = Image.create(slot * 5, slot * 2, false, Image.FORMAT_RGBA8)
		sheet.fill(Color("#8baf60"))
		sheet.fill_rect(Rect2i(0, slot, slot * 5, slot), Color("#d2b383"))
		for index: int in IDS.size():
			var image: Image = Image.load_from_file("res://assets/sprites/enemies/rendered/" + IDS[index] + ".png")
			image.resize(side, side, Image.INTERPOLATE_LANCZOS)
			for row: int in 2:
				sheet.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(index * slot + 12, row * slot + 12))
		assert(sheet.save_png("res://art/t244-coloso/captures/contact_%d.png" % side) == OK)
	quit()
