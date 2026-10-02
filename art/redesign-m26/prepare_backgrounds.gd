# Preparación de suelos repetibles y decoración. No cambia los recursos de producción.
extends SceneTree

const ROOT: String = "res://art/redesign-m26/"
const THEMES: Array[String] = ["pradera", "desierto", "nieve", "volcan", "bosque", "pantano", "ruinas"]
const PROPS: Array[String] = ["rock_a", "rock_b", "tree", "bush", "gate"]

func _initialize() -> void:
	var manifest: Dictionary = {"tile_size": 64, "texture_size": 256, "prop_frame": [128, 128],
		"prop_anchor": [64, 116], "grounds": {}, "props": {}}
	var names: Array[String] = ["path"]
	for theme: String in THEMES:
		names.append("ground_" + theme)
	for name_: String in names:
		var source: Image = Image.load_from_file(ROOT + "sources/" + name_ + ".png")
		if source == null or source.is_empty():
			push_error("Falta " + name_)
			quit(1)
			return
		source.convert(Image.FORMAT_RGBA8)
		source.resize(256, 256, Image.INTERPOLATE_LANCZOS)
		# Asegurar continuidad de color en lados opuestos, sin alterar el centro.
		for distance: int in 16:
			var weight: float = 0.5 * (1.0 - float(distance) / 16.0)
			for along: int in 256:
				var left: Color = source.get_pixel(distance, along)
				var right: Color = source.get_pixel(255 - distance, along)
				source.set_pixel(distance, along, left.lerp(right, weight))
				source.set_pixel(255 - distance, along, right.lerp(left, weight))
		for distance: int in 16:
			var weight: float = 0.5 * (1.0 - float(distance) / 16.0)
			for along: int in 256:
				var top: Color = source.get_pixel(along, distance)
				var bottom: Color = source.get_pixel(along, 255 - distance)
				source.set_pixel(along, distance, top.lerp(bottom, weight))
				source.set_pixel(along, 255 - distance, bottom.lerp(top, weight))
		if source.save_png(ROOT + "textures/" + name_ + ".png") != OK:
			quit(1)
			return
		manifest["grounds"][name_] = "textures/" + name_ + ".png"
	for name_: String in PROPS:
		var source: Image = Image.load_from_file(ROOT + "sources/" + name_ + ".png")
		if source == null or source.is_empty():
			push_error("Falta " + name_)
			quit(1)
			return
		source.convert(Image.FORMAT_RGBA8)
		var bounds: Rect2i = _body_bounds(source)
		if bounds.size.x == 0 or bounds.size.y == 0:
			quit(1)
			return
		var body: Image = source.get_region(bounds.grow(2).intersection(Rect2i(Vector2i.ZERO, source.get_size())))
		var scale_: float = minf(116.0 / body.get_width(), 108.0 / body.get_height())
		_resize_with_alpha(body, maxi(1, roundi(body.get_width() * scale_)), maxi(1, roundi(body.get_height() * scale_)))
		var frame: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		frame.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), Vector2i((128 - body.get_width()) / 2, 116 - body.get_height()))
		if frame.save_png(ROOT + "props/" + name_ + ".png") != OK:
			quit(1)
			return
		manifest["props"][name_] = "props/" + name_ + ".png"
	var file: FileAccess = FileAccess.open(ROOT + "manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	print("Ocho texturas y cinco objetos preparados.")
	quit()

func _body_bounds(image: Image) -> Rect2i:
	var bytes: PackedByteArray = image.get_data()
	var low := Vector2i(image.get_width(), image.get_height())
	var high := Vector2i(-1, -1)
	for index: int in image.get_width() * image.get_height():
		if bytes[index * 4 + 3] <= 25:
			continue
		var x: int = index % image.get_width()
		var y: int = index / image.get_width()
		low = Vector2i(mini(low.x, x), mini(low.y, y))
		high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	return Rect2i(low, high - low + Vector2i.ONE) if high.x >= 0 else Rect2i()

func _resize_with_alpha(image: Image, width: int, height: int) -> void:
	var bytes: PackedByteArray = image.get_data()
	for index: int in range(0, bytes.size(), 4):
		for channel: int in 3:
			bytes[index + channel] = roundi(float(bytes[index + channel]) * bytes[index + 3] / 255.0)
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, bytes)
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	bytes = image.get_data()
	for index: int in range(0, bytes.size(), 4):
		if bytes[index + 3] > 0:
			for channel: int in 3:
				bytes[index + channel] = clampi(roundi(float(bytes[index + channel]) * 255.0 / bytes[index + 3]), 0, 255)
	image.set_data(width, height, false, Image.FORMAT_RGBA8, bytes)
