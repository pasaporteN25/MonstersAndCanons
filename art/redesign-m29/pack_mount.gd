# Empaquetado reproducible del montaje C. No modifica las fuentes.
extends SceneTree

const ROOT: String = "res://art/redesign-m29/"
const OUT: String = "res://assets/sprites/towers/rendered/"

func _initialize() -> void:
	var source: Image = Image.load_from_file(ROOT + "sources/cannon_mount.png")
	var packer: SceneTree = load("res://tools/prepare_tower_sprites.gd").new()
	var regions: Array[Rect2i] = packer._objects(source, 24)
	if regions.size() != 24:
		packer.free()
		quit(1)
		return
	# El ordenado original contempla dos filas: ordenar aquí las seis filas explícitamente.
	regions.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.get_center().y < b.get_center().y)
	var ordered: Array[Rect2i] = []
	for row: int in 6:
		var group: Array[Rect2i] = regions.slice(row * 4, row * 4 + 4)
		group.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.get_center().x < b.get_center().x)
		ordered.append_array(group)
	var extent: int = 1
	for region: Rect2i in ordered:
		extent = maxi(extent, maxi(region.size.x, region.size.y))
	var factor: float = 110.0 / extent
	for level: int in 3:
		var atlas: Image = Image.create(512, 256, false, Image.FORMAT_RGBA8)
		for direction: int in 8:
			var frame: Image = source.get_region(ordered[level * 8 + direction])
			frame.resize(maxi(1, roundi(frame.get_width() * factor)), maxi(1, roundi(frame.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
			# La zapata del mecanismo cae a la misma altura para que apoye en el asiento.
			var position_: Vector2i = Vector2i((direction % 4) * 128 + (128 - frame.get_width()) / 2, (direction / 4) * 128 + 108 - frame.get_height())
			atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), position_)
		var name_: String = "cannon_atlas" if level == 0 else "cannon_level_" + str(level + 1)
		atlas.save_png(OUT + name_ + ".png")
		atlas.get_region(Rect2i(0, 0, 128, 128)).save_png(OUT + ("turret_cannon" if level == 0 else name_ + "_icon") + ".png")
	source = Image.load_from_file(ROOT + "sources/bases.png")
	regions = packer._objects(source, 3)
	if regions.size() != 3:
		packer.free()
		quit(1)
		return
	regions.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.get_center().x < b.get_center().x)
	for level: int in 3:
		var frame: Image = source.get_region(regions[level])
		var scale_: float = 122.0 / maxi(frame.get_width(), frame.get_height())
		frame.resize(roundi(frame.get_width() * scale_), roundi(frame.get_height() * scale_), Image.INTERPOLATE_LANCZOS)
		var image: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		image.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), (Vector2i.ONE * 128 - frame.get_size()) / 2)
		image.save_png(OUT + "base_" + str(level + 1) + ".png")
	packer.free()
	print("Montaje C: 24 vistas del cañón y tres bases")
	quit()
