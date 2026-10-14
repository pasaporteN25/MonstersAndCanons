extends SceneTree

const ROOT: String = "res://art/m51-disruptora/"
const SOURCE: String = ROOT + "sources/concept_sheet.png"
const OUT: String = "res://assets/sprites/towers/rendered/"
const CELL: int = 128
const ATLAS_SIZE: Vector2i = Vector2i(512, 256)
const COLORS: Dictionary = {
	"energy": Color("#dcebff"),
	"energy_edge": Color("#7fa8ff"),
	"ink": Color("#202330"),
}

func _initialize() -> void:
	call_deferred("_generate")

func _generate() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var source: Image = Image.load_from_file(ProjectSettings.globalize_path(SOURCE))
	if source.is_empty() or source.get_width() != 1254 or source.get_height() != 1254:
		push_error("No se encontró la hoja original de concepto de 1254×1254.")
		call_deferred("quit", 1)
		return
	var variants: Array[Image] = []
	for column: int in 3:
		variants.append(_trim_column(source, column))
	if variants.size() != 3:
		call_deferred("quit", 1)
		return
	var names: Array[String] = ["turret_disruptor.png", "disruptor_level_2.png", "disruptor_level_3.png"]
	for index: int in 3:
		var sprite: Image = _fit_sprite(variants[index])
		if index == 0:
			sprite.save_png(OUT + names[index])
		_pack_static_atlas(sprite).save_png(OUT + "disruptor_atlas.png")
		if index > 0:
			_pack_static_atlas(sprite).save_png(OUT + names[index])
	_write_concept(source)
	_write_pulse_ring()
	_write_suppression_icons()
	_write_contact_sheet()
	_write_manifest(variants)
	variants.clear()
	source = Image.new()
	print("T216: tres variantes recortadas, atlas y texturas provisionales generados.")
	call_deferred("quit")

func _trim_column(source: Image, column: int) -> Image:
	var x_start: int = column * 418
	var bounds := Rect2i(x_start, 0, 418, source.get_height())
	var low := Vector2i(bounds.position.x + bounds.size.x, bounds.position.y + bounds.size.y)
	var high := Vector2i(bounds.position.x, bounds.position.y)
	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			if source.get_pixel(x, y).a > 0.5:
				low.x = mini(low.x, x)
				low.y = mini(low.y, y)
				high.x = maxi(high.x, x)
				high.y = maxi(high.y, y)
	if high.x < low.x or high.y < low.y:
		push_error("No se encontró la variante %d en la hoja." % (column + 1))
		return Image.new()
	return source.get_region(Rect2i(low, high - low + Vector2i.ONE))

func _fit_sprite(source: Image) -> Image:
	var sprite: Image = Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	var factor: float = minf(112.0 / source.get_width(), 112.0 / source.get_height())
	var size := Vector2i(maxi(1, roundi(source.get_width() * factor)), maxi(1, roundi(source.get_height() * factor)))
	source.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	sprite.blit_rect(source, Rect2i(Vector2i.ZERO, size), (Vector2i(CELL, CELL) - size) / 2)
	return sprite

func _pack_static_atlas(sprite: Image) -> Image:
	var atlas: Image = Image.create(ATLAS_SIZE.x, ATLAS_SIZE.y, false, Image.FORMAT_RGBA8)
	for index: int in 8:
		var origin := Vector2i(index % 4 * CELL, index / 4 * CELL)
		atlas.blit_rect(sprite, Rect2i(Vector2i.ZERO, Vector2i(CELL, CELL)), origin)
	return atlas

func _write_concept(source: Image) -> void:
	var concept: Image = source.duplicate()
	concept.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	concept.save_png(ROOT + "concept_provisional.png")

func _write_pulse_ring() -> void:
	var image: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(63.5, 63.5)
	for y: int in 128:
		for x: int in 128:
			var distance: float = Vector2(x, y).distance_to(center)
			var ring: float = clampf(1.0 - absf(distance - 48.0) / 1.8, 0.0, 1.0)
			var halo: float = clampf(1.0 - maxf(distance - 49.0, 0.0) / 10.0, 0.0, 1.0) * 0.12
			var alpha: float = maxf(ring, halo)
			if alpha > 0.005:
				var color: Color = COLORS.energy.lerp(COLORS.energy_edge, clampf(absf(distance - 48.0) / 2.0, 0.0, 1.0))
				color.a = alpha
				image.set_pixel(x, y, color)
	image.save_png(OUT + "disruptor_pulse_ring.png")

func _write_suppression_icons() -> void:
	var full: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for segment: int in 3:
		_draw_arc(full, segment)
	full.save_png(OUT + "disruptor_suppression_icon.png")
	for segment: int in 3:
		var single: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		_draw_arc(single, segment)
		single.save_png(OUT + "disruptor_suppression_arc_%d.png" % (segment + 1))

func _draw_arc(image: Image, segment: int) -> void:
	var center: Vector2 = Vector2(15.5, 15.5)
	var start: float = deg_to_rad(-150.0 + 120.0 * segment + 10.0)
	var finish: float = deg_to_rad(-150.0 + 120.0 * segment + 110.0)
	for y: int in 32:
		for x: int in 32:
			var offset: Vector2 = Vector2(x, y) - center
			var angle: float = atan2(offset.y, offset.x)
			var distance: float = offset.length()
			if distance < 8.7 or distance > 12.5 or not _angle_between(angle, start, finish):
				continue
			var edge: bool = distance < 9.7 or distance > 11.5
			image.set_pixel(x, y, COLORS.ink if edge else COLORS.energy)

func _angle_between(angle: float, start: float, finish: float) -> bool:
	while angle < start:
		angle += TAU
	while angle > start + TAU:
		angle -= TAU
	return angle >= start and angle <= finish

func _write_contact_sheet() -> void:
	var sources: Array[String] = [
		"turret_basic.png", "turret_sniper.png", "turret_fire.png", "turret_multi.png", "turret_burst.png",
		"turret_frost.png", "turret_tesla.png", "turret_cannon.png", "turret_mortar.png", "turret_disruptor.png",
	]
	for target: int in [112, 34]:
		var cell_size: int = target + 24
		var sheet: Image = Image.create(cell_size * 5, cell_size * 2, false, Image.FORMAT_RGBA8)
		sheet.fill(Color("#171923"))
		for index: int in sources.size():
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT + sources[index]))
			if image.is_empty():
				continue
			var bounds: Rect2i = _alpha_bounds(image)
			if bounds.size == Vector2i.ZERO:
				continue
			image = image.get_region(bounds)
			var factor: float = minf(float(target) / image.get_width(), float(target) / image.get_height())
			var size := Vector2i(maxi(1, roundi(image.get_width() * factor)), maxi(1, roundi(image.get_height() * factor)))
			image.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
			var slot := Vector2i(index % 5 * cell_size, index / 5 * cell_size)
			sheet.blend_rect(image, Rect2i(Vector2i.ZERO, size), slot + (Vector2i(cell_size, cell_size) - size) / 2)
		sheet.save_png(ROOT + "contact_%dpx.png" % target)

func _alpha_bounds(image: Image) -> Rect2i:
	var low := Vector2i(image.get_width(), image.get_height())
	var high := Vector2i(-1, -1)
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > 0.08:
				low.x = mini(low.x, x)
				low.y = mini(low.y, y)
				high.x = maxi(high.x, x)
				high.y = maxi(high.y, y)
	if high.x < low.x or high.y < low.y:
		return Rect2i()
	return Rect2i(low, high - low + Vector2i.ONE)

func _write_manifest(variants: Array[Image]) -> void:
	var manifest: Dictionary = {
		"estado": "provisional; pendiente de aprobación de Lucas",
		"fuente": "sources/concept_sheet.png",
		"fuente_original": {"ancho": 1254, "alto": 1254, "alfa": "RGBA"},
		"atlas": {"archivo": "disruptor_atlas.png", "ancho": 512, "alto": 256, "celda": 128, "direcciones": ["E", "SE", "S", "SO", "O", "NO", "N", "NE"], "variacion_direcciones": "ocho copias de la misma vista SE; torre casi simétrica"},
		"variantes": ["turret_disruptor.png", "disruptor_level_2.png", "disruptor_level_3.png"],
		"pulso": "disruptor_pulse_ring.png",
		"marca": ["disruptor_suppression_icon.png", "disruptor_suppression_arc_1.png", "disruptor_suppression_arc_2.png", "disruptor_suppression_arc_3.png"],
		"hojas": ["concept_provisional.png", "contact_112px.png", "contact_34px.png"],
		"orden_contacto": ["Básica", "Francotirador", "Incendiaria", "Múltiple", "Ráfaga", "Hielo", "Eléctrica", "Cañón", "Mortero", "Disruptora"],
		"limitaciones": ["No hay captura de partida ni de Wiki: T217 todavía no integró la torre."],
		"celdas_fuente": []
	}
	for index: int in variants.size():
		manifest["celdas_fuente"].append({"variante": index + 1, "ancho": variants[index].get_width(), "alto": variants[index].get_height()})
	var file: FileAccess = FileAccess.open(ROOT + "manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
