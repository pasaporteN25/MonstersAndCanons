# Normaliza el tamaño del epílogo y arma las hojas con el rasterizador de Godot.
extends SceneTree

const NAMES: Array[String] = ["central_1", "central_2", "central_3", "central_4", "supply_depot", "supply_line_pole", "supply_cart", "supply_conveyor", "hito"]

func _initialize() -> void:
	var finale: Image = Image.load_from_file("res://art/t233-final/sources/epilogue_generated.png")
	assert(not finale.is_empty())
	# Ajuste de formato sin repintado; la fuente original queda conservada.
	var ratio: float = 16.0 / 9.0
	var crop_width: int = mini(finale.get_width(), roundi(finale.get_height() * ratio))
	var crop_height: int = mini(finale.get_height(), roundi(finale.get_width() / ratio))
	finale = finale.get_region(Rect2i((finale.get_width() - crop_width) / 2, (finale.get_height() - crop_height) / 2, crop_width, crop_height))
	finale.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	assert(finale.save_png("res://assets/sprites/story/epilogue.png") == OK)
	var master: Image = Image.new()
	assert(master.load_svg_from_string(FileAccess.get_file_as_string("res://art/t233-final/sources/central_master.svg")) == OK)
	var assembly: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	assembly.fill(Color.TRANSPARENT)
	for i: int in 4:
		var quarter: Image = _read(NAMES[i])
		assembly.blit_rect(quarter, Rect2i(0, 0, 64, 64), Vector2i(i % 2 * 64, i / 2 * 64))
	assert(assembly.save_png("res://art/t233-final/captures/central_assembled.png") == OK)
	# La transformación altera el redondeo del degradé hasta 1/255; el alfa debe coincidir.
	var mismatch: int = 0
	var max_difference: float = 0.0
	for y: int in 128:
		for x: int in 128:
			if master.get_pixel(x, y) != assembly.get_pixel(x, y):
				mismatch += 1
				var a: Color = master.get_pixel(x, y)
				var b: Color = assembly.get_pixel(x, y)
				max_difference = maxf(max_difference, maxf(absf(a.r-b.r), maxf(absf(a.g-b.g), maxf(absf(a.b-b.b), absf(a.a-b.a)))))
				assert(a.a == b.a, "Cambió la silueta o el margen de la central")
	print("Diferencias raster fuente/cuatro cuartos: ", mismatch)
	print("Máxima diferencia de canal: ", max_difference)
	assert(max_difference <= 1.0 / 255.0 + 0.000001)
	for size: int in [34, 64, 112, 220]:
		var slot: int = size + 20
		var sheet: Image = Image.create(slot * 6, slot * 3, false, Image.FORMAT_RGBA8)
		var grounds: Array[Color] = [Color("#8baf60"), Color("#dcbc7c"), Color("#e9f0f8")]
		for row: int in 3:
			sheet.fill_rect(Rect2i(0, row * slot, slot * 6, slot), grounds[row])
			for i: int in 6:
				var source: Image = assembly.duplicate() if i == 0 else _read(NAMES[i + 3])
				source.resize(size, size, Image.INTERPOLATE_LANCZOS)
				sheet.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i(i * slot + 10, row * slot + 10))
		assert(sheet.save_png("res://art/t233-final/captures/contact_%d.png" % size) == OK)
	print("T233: epílogo 1920×1080, montaje 128×128 y hojas 34/64/112/220.")
	quit()

func _read(id: String) -> Image:
	var result: Image = Image.new()
	assert(result.load_svg_from_string(FileAccess.get_file_as_string("res://assets/sprites/map/%s.svg" % id)) == OK)
	assert(result.get_size() == Vector2i(64, 64))
	return result
