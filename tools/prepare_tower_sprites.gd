# Recorta las hojas originales y genera atlas e imágenes para HUD/Wiki.
# Ejecutar: godot --headless --path . -s tools/prepare_tower_sprites.gd
extends SceneTree

const SOURCE_DIR := "res://art/redesign-m23/sources/"
const OUT_DIR := "res://assets/sprites/towers/rendered/"
const NAMES: Array[String] = ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar"]
const FRAME_SIZE: int = 128
const COLUMNS: int = 4
const ROWS: int = 2
const CONTENT_SIZE: int = 110

## Las hojas generadas no siempre respetan los límites de las celdas.
## Buscar cuerpos completos por alfa evita amputar tubos o sumar piezas del vecino.
func _objects(image: Image, expected: int) -> Array[Rect2i]:
	image.convert(Image.FORMAT_RGBA8)
	var bytes: PackedByteArray = image.get_data()
	var width: int = image.get_width()
	var height: int = image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var found: Array[Rect2i] = []
	for start: int in width * height:
		if visited[start] != 0 or bytes[start * 4 + 3] < 64:
			continue
		var queue := PackedInt32Array([start])
		visited[start] = 1
		var cursor: int = 0
		var left: int = start % width
		var right: int = left
		var top: int = start / width
		var bottom: int = top
		while cursor < queue.size():
			var pixel: int = queue[cursor]
			cursor += 1
			var x: int = pixel % width
			var y: int = pixel / width
			left = mini(left, x)
			right = maxi(right, x)
			top = mini(top, y)
			bottom = maxi(bottom, y)
			for neighbor: int in [pixel - 1 if x > 0 else -1, pixel + 1 if x < width - 1 else -1,
				pixel - width if y > 0 else -1, pixel + width if y < height - 1 else -1]:
				if neighbor < 0 or visited[neighbor] != 0 or bytes[neighbor * 4 + 3] < 64:
					continue
				visited[neighbor] = 1
				queue.append(neighbor)
		if queue.size() > 2000:
			found.append(Rect2i(left, top, right - left + 1, bottom - top + 1).grow(3).intersection(Rect2i(0, 0, width, height)))
	if found.size() != expected:
		push_error("Se esperaban %d figuras completas y se encontraron %d" % [expected, found.size()])
		return []
	found.sort_custom(func(a: Rect2i, b: Rect2i) -> bool:
		if absf(a.get_center().y - b.get_center().y) > height * 0.25:
			return a.get_center().y < b.get_center().y
		return a.get_center().x < b.get_center().x)
	return found

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	for name_: String in NAMES:
		if not FileAccess.file_exists(SOURCE_DIR + name_ + ".png"):
			continue
		var source := Image.load_from_file(SOURCE_DIR + name_ + ".png")
		if source == null:
			quit(1)
			return
		var frames: Array[Image] = []
		var extent: int = 1
		var regions: Array[Rect2i] = _objects(source, 8)
		if regions.is_empty():
			quit(1)
			return
		for region: Rect2i in regions:
			var frame: Image = source.get_region(region)
			extent = maxi(extent, maxi(frame.get_width(), frame.get_height()))
			frames.append(frame)
		var atlas := Image.create(FRAME_SIZE * COLUMNS, FRAME_SIZE * ROWS, false, Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		var scale_: float = float(CONTENT_SIZE) / extent
		for i: int in frames.size():
			var frame: Image = frames[i]
			frame.resize(maxi(1, roundi(frame.get_width() * scale_)), maxi(1, roundi(frame.get_height() * scale_)), Image.INTERPOLATE_LANCZOS)
			var destination := Vector2i((FRAME_SIZE - frame.get_width()) / 2, (FRAME_SIZE - frame.get_height()) / 2)
			destination += Vector2i(i % COLUMNS, i / COLUMNS) * FRAME_SIZE
			atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)
		if atlas.save_png(OUT_DIR + name_ + "_atlas.png") != OK:
			quit(1)
			return
		atlas.get_region(Rect2i(0, 0, FRAME_SIZE, FRAME_SIZE)).save_png(OUT_DIR + "turret_" + name_ + ".png")
		print(name_, ": 8 vistas normalizadas")
	if FileAccess.file_exists(SOURCE_DIR + "bases.png"):
		var source := Image.load_from_file(SOURCE_DIR + "bases.png")
		var regions: Array[Rect2i] = _objects(source, 3)
		if regions.is_empty():
			quit(1)
			return
		for i: int in 3:
			var frame: Image = source.get_region(regions[i])
			var scale_: float = 122.0 / maxi(frame.get_width(), frame.get_height())
			frame.resize(roundi(frame.get_width() * scale_), roundi(frame.get_height() * scale_), Image.INTERPOLATE_LANCZOS)
			var output := Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
			output.fill(Color.TRANSPARENT)
			output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), (Vector2i.ONE * FRAME_SIZE - frame.get_size()) / 2)
			output.save_png(OUT_DIR + "base_" + str(i + 1) + ".png")
	if FileAccess.file_exists(SOURCE_DIR + "projectiles.png"):
		var source := Image.load_from_file(SOURCE_DIR + "projectiles.png")
		var regions: Array[Rect2i] = _objects(source, 9)
		if regions.is_empty():
			quit(1)
			return
		DirAccess.make_dir_recursive_absolute("res://assets/sprites/projectiles/rendered/")
		for i: int in regions.size():
			_save_icon(source.get_region(regions[i]), "res://assets/sprites/projectiles/rendered/" + NAMES[i] + ".png", 64, 54)
	if FileAccess.file_exists(SOURCE_DIR + "effects.png"):
		var source := Image.load_from_file(SOURCE_DIR + "effects.png")
		var names_: Array[String] = ["flame", "frost", "explosion", "spark"]
		DirAccess.make_dir_recursive_absolute("res://assets/sprites/effects/rendered/")
		for i: int in 4:
			var cell_size: int = source.get_width() / 4
			var icon: Image = source.get_region(Rect2i(i * cell_size, 0, cell_size, source.get_height()))
			_save_icon(icon.get_region(icon.get_used_rect()), "res://assets/sprites/effects/rendered/" + names_[i] + ".png", 128, 116)
	quit()

func _save_icon(icon: Image, destination: String, size_: int, content: int) -> void:
	var scale_: float = float(content) / maxi(icon.get_width(), icon.get_height())
	icon.resize(roundi(icon.get_width() * scale_), roundi(icon.get_height() * scale_), Image.INTERPOLATE_LANCZOS)
	var output := Image.create(size_, size_, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	output.blit_rect(icon, Rect2i(Vector2i.ZERO, icon.get_size()), (Vector2i.ONE * size_ - icon.get_size()) / 2)
	output.save_png(destination)
