# Estabiliza el punto de apoyo de la cabeza entre cuatro poses generadas.
extends SceneTree
const ROOT: String = "res://art/redesign-m28/"
const EYES: Array[Vector2i] = [Vector2i(538, 426), Vector2i(534, 447), Vector2i(541, 375), Vector2i(535, 403)]
func _initialize() -> void:
	var source: Image = Image.load_from_file(ROOT + "sources/flyer_flap.png")
	source.convert(Image.FORMAT_RGBA8)
	var cell: Vector2i = source.get_size() / 2
	var atlas: Image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for index: int in 4:
		var frame: Image = source.get_region(Rect2i(Vector2i(index % 2, index / 2) * cell, cell))
		var factor: float = 0.32
		frame.resize(roundi(cell.x * factor), roundi(cell.y * factor), Image.INTERPOLATE_LANCZOS)
		var position_: Vector2i = Vector2i(205, 162) - Vector2i(Vector2(EYES[index]) * factor)
		position_ += Vector2i(index % 2, index / 2) * 256
		atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), position_)
	atlas.save_png(ROOT + "sources/flyer_flap_normalized.png")
	print("Cuatro poses, cabeza estabilizada, escala común y alfa conservado")
	quit()
