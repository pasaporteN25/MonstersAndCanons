# Empaquetado de los nueve ciclos M31. Fuentes intactas y apoyo constante.
extends SceneTree

const ROOT: String = "res://art/redesign-m31/"
const CELL: int = 256
const NAMES: Array[String] = ["armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss"]
const STRIDES: Dictionary = {"armored": 0.65, "troll": 0.85, "spider": 0.55, "spiderling": 0.4, "guardian": 0.85, "healer": 0.65, "shaman": 0.7, "mirror": 0.55, "boss": 0.85}

func _initialize() -> void:
	var manifest: Dictionary = {"frame_size": [CELL, CELL], "columns": 4, "rows": 4,
		"directions": ["east", "south", "west", "north"], "anchor": [128, 191], "creatures": {}}
	var failed: bool = false
	for id: String in NAMES:
		var path: String = ROOT + "sources/" + id + "_walk.png"
		if not FileAccess.file_exists(path):
			print("Fuente pendiente: " + id)
			failed = true
			continue
		var image: Image = Image.load_from_file(path)
		image.convert(Image.FORMAT_RGBA8)
		var frames: Array[Image] = _separate_figures(image)
		if frames.size() != 16:
			failed = true
			continue
		var max_width: int = 0
		var max_height: int = 0
		for frame: Image in frames:
			max_width = maxi(max_width, frame.get_width())
			max_height = maxi(max_height, frame.get_height())
		var factor: float = minf(246.0 / max_width, 162.0 / max_height)
		var atlas: Image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
		var unique: Dictionary = {}
		for index: int in 16:
			var frame: Image = frames[index]
			frame.resize(maxi(1, roundi(frame.get_width() * factor)), maxi(1, roundi(frame.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
			frame = frame.get_region(frame.get_used_rect())
			unique[hash(frame.get_data())] = true
			var position_: Vector2i = Vector2i((index % 4) * CELL + (CELL - frame.get_width()) / 2,
				(index / 4) * CELL + 191 - frame.get_height())
			atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), position_)
		if unique.size() != 16:
			push_error(id + ": hay poses idénticas; revisar fuente")
			failed = true
			continue
		var static_image: Image = Image.load_from_file("res://assets/sprites/enemies/rendered/" + id + ".png")
		var original: Rect2i = body_(static_image)
		var animated: Rect2i = body_(atlas.get_region(Rect2i(0, 0, CELL, CELL)))
		var art_scale: float = float(maxi(original.size.x, original.size.y)) / maxi(animated.size.x, animated.size.y)
		atlas.save_png(ROOT + "atlases/" + id + "_walk.png")
		manifest.creatures[id] = {"atlas": "atlases/" + id + "_walk.png", "walk_stride_tiles": STRIDES[id],
			"walk_art_scale": art_scale, "unique_poses": unique.size(), "source_size": [image.get_width(), image.get_height()]}
		print(id + ":16poses; calibración " + str(art_scale))
	var file: FileAccess = FileAccess.open(ROOT + "manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	quit(1 if failed else 0)

func body_(image: Image) -> Rect2i:
	var low: Vector2i = image.get_size()
	var high := Vector2i(-1, -1)
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > 0.1:
				low = Vector2i(mini(low.x, x), mini(low.y, y))
				high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	return Rect2i(low, high - low + Vector2i.ONE)

# Las fuentes generadas no tienen celdas exactas: aislar cada figura por conectividad
# evita recortar cuernos o incluir fragmentos de la figura de la fila siguiente.
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
