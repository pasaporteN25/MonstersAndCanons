# Prepara el logo de producción (M24, RF-331) desde art/redesign-m24/sources/logo_corrected.png:
# recorta el margen transparente (dejando 8 px) y lo achica a 1024 px de ancho, conservando el alfa.
# Uso: godot --headless --path . -s tools/prepare_logo.gd
extends SceneTree

const SOURCE := "res://art/redesign-m24/sources/logo_corrected.png"
const OUTPUT := "res://assets/ui/logo.png"
const WIDTH: int = 1024
const MARGIN: int = 8
const BODY_ALPHA: float = 0.05


func _init() -> void:
	var image: Image = Image.load_from_file(SOURCE)
	if image == null or image.is_empty():
		push_error("No se pudo leer %s" % SOURCE)
		quit(1)
		return
	image.convert(Image.FORMAT_RGBA8)
	var low := Vector2i(image.get_width(), image.get_height())
	var high := Vector2i(-1, -1)
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > BODY_ALPHA:
				low = Vector2i(mini(low.x, x), mini(low.y, y))
				high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	var rect := Rect2i(low, high - low + Vector2i.ONE).grow(MARGIN).intersection(
		Rect2i(0, 0, image.get_width(), image.get_height()))
	var logo: Image = image.get_region(rect)
	logo.premultiply_alpha()
	logo.resize(WIDTH, roundi(float(rect.size.y) * WIDTH / rect.size.x), Image.INTERPOLATE_LANCZOS)
	for y: int in logo.get_height():
		for x: int in logo.get_width():
			var pixel: Color = logo.get_pixel(x, y)
			if pixel.a > 0.0:
				logo.set_pixel(x, y, Color(minf(pixel.r / pixel.a, 1.0), minf(pixel.g / pixel.a, 1.0),
					minf(pixel.b / pixel.a, 1.0), pixel.a))
	print("logo: fuente %dx%d, cuerpo %s → %dx%d" % [image.get_width(), image.get_height(), rect, logo.get_width(), logo.get_height()])
	quit(0 if logo.save_png(OUTPUT) == OK else 1)
