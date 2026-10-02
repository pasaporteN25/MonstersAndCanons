# Empaqueta las fuentes de M27 sin cambiar los atlas de producción.
extends SceneTree

const ROOT: String = "res://art/redesign-m27/"
const NAMES: Array[String] = ["cannon", "basic", "multi", "sniper", "burst", "fire", "mortar", "frost", "tesla"]

func _initialize() -> void:
	var failed: bool = false
	for id: String in NAMES:
		var path: String = ROOT + "sources/" + id + "_upgrades.png"
		if not FileAccess.file_exists(path):
			continue
		var source: Image = Image.load_from_file(path)
		source.convert(Image.FORMAT_RGBA8)
		var frames: Array[Image] = _separate_figures(source)
		if frames.size() != 16:
			print("Revisar fuente: " + id)
			failed = true
			continue
		var extent: int = 1
		for frame: Image in frames:
			extent = maxi(extent, maxi(frame.get_width(), frame.get_height()))
		var scale_: float = 110.0 / extent
		for level_index: int in 2:
			var atlas: Image = Image.create(512, 256, false, Image.FORMAT_RGBA8)
			for direction: int in 8:
				var frame: Image = frames[level_index * 8 + direction]
				frame.resize(maxi(1, roundi(frame.get_width() * scale_)), maxi(1, roundi(frame.get_height() * scale_)), Image.INTERPOLATE_LANCZOS)
				var position_: Vector2i = Vector2i((direction % 4) * 128 + (128 - frame.get_width()) / 2, (direction / 4) * 128 + (128 - frame.get_height()) / 2)
				atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), position_)
			var stem: String = id + "_level_" + str(level_index + 2)
			atlas.save_png(ROOT + "atlases/" + stem + ".png")
			atlas.get_region(Rect2i(256, 128, 128, 128)).save_png(ROOT + "icons/" + stem + ".png")
		print(id + ": niveles 2 y 3, ocho vistas cada uno")
	quit(1 if failed else 0)


func _separate_figures(source: Image) -> Array[Image]:
	var width: int = source.get_width()
	var height: int = source.get_height()
	var data_: PackedByteArray = source.get_data()
	var seen := PackedByteArray()
	seen.resize(width * height)
	var components: Array[Dictionary] = []
	for seed: int in width * height:
		if seen[seed] != 0 or data_[seed * 4 + 3] <= 32:
			continue
		var queue := PackedInt32Array([seed])
		seen[seed] = 1
		var cursor: int = 0
		var low := Vector2i(width, height)
		var high := Vector2i.ZERO
		while cursor < queue.size():
			var pixel: int = queue[cursor]
			cursor += 1
			var x: int = pixel % width
			var y: int = pixel / width
			low = Vector2i(mini(low.x, x), mini(low.y, y))
			high = Vector2i(maxi(high.x, x), maxi(high.y, y))
			for dy: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var nx: int = x + dx
					var ny: int = y + dy
					if nx < 0 or ny < 0 or nx >= width or ny >= height:
						continue
					var neighbor: int = ny * width + nx
					if seen[neighbor] == 0 and data_[neighbor * 4 + 3] > 32:
						seen[neighbor] = 1
						queue.append(neighbor)
		if queue.size() >= 1000:
			components.append({"pixels": queue, "bounds": Rect2i(low, high - low + Vector2i.ONE)})
	if components.size() != 16:
		push_error("Figuras detectadas: %d; revisar fuente antes de empaquetar." % components.size())
		return []
	components.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.bounds.get_center().y < b.bounds.get_center().y)
	var ordered: Array[Dictionary] = []
	for row: int in 4:
		var group: Array[Dictionary] = components.slice(row * 4, row * 4 + 4)
		group.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.bounds.get_center().x < b.bounds.get_center().x)
		ordered.append_array(group)
	var result: Array[Image] = []
	for component: Dictionary in ordered:
		var bounds: Rect2i = component.bounds.grow(2).intersection(Rect2i(0, 0, width, height))
		var bytes := PackedByteArray()
		bytes.resize(bounds.size.x * bounds.size.y * 4)
		for pixel: int in component.pixels:
			var x: int = pixel % width
			var y: int = pixel / width
			for dy: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var point := Vector2i(x + dx, y + dy)
					if not bounds.has_point(point):
						continue
					var index: int = (point.y * width + point.x) * 4
					if (dx != 0 or dy != 0) and data_[index + 3] > 32:
						continue
					var destination: int = ((point.y - bounds.position.y) * bounds.size.x + point.x - bounds.position.x) * 4
					for channel: int in 4:
						bytes[destination + channel] = data_[index + channel]
		result.append(Image.create_from_data(bounds.size.x, bounds.size.y, false, Image.FORMAT_RGBA8, bytes))
	return result


