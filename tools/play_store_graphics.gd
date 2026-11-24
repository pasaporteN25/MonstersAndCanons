# Gráficos de la ficha de Google Play (T597, RF-757). Corre sin ventana: solo usa `Image`, no dibuja la escena.
#   godot --headless --path . -s tools/play_store_graphics.gd -- [lamina.webp] [salida/]
# - Gráfico destacado de 1024 × 500: la lámina de la intro sin bordes ni franja de texto, recortada para cubrir todo
#   el rectángulo, un poco más oscura, con el logo centrado encima. Por omisión usa `assets/intro/07_el_oasis.webp`.
# - Ícono de 512 × 512: copia de `assets/icon.png` (Play lo pide en PNG de 32 bits, hasta 1 MB).
# La salida por omisión es `res://art/play-store/`.
extends SceneTree

const FEATURE_SIZE: Vector2i = Vector2i(1024, 500)
const ICON_SIZE: Vector2i = Vector2i(512, 512)
const DEFAULT_BACKGROUND: String = "res://assets/intro/07_el_oasis.webp"
const LOGO_PATH: String = "res://assets/ui/logo.png"
const ICON_PATH: String = "res://assets/icon.png"
const DEFAULT_OUT: String = "res://art/play-store/"
## Ancho del logo sobre el gráfico destacado, en proporción al ancho total.
const LOGO_WIDTH_RATIO: float = 0.62
## Cuánto se oscurece la lámina para que el logo se lea (0 = igual, 1 = negro).
const BACKGROUND_DARKEN: float = 0.25
## Parte de la lámina que se usa, en fracciones del ancho y del alto: deja afuera los bordes de papel de los
## costados y la franja oscura de abajo, donde la intro pone el texto.
const SOURCE_CROP: Rect2 = Rect2(0.035, 0.03, 0.93, 0.68)


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var background_path: String = args[0] if args.size() > 0 else DEFAULT_BACKGROUND
	var out_dir: String = args[1] if args.size() > 1 else DEFAULT_OUT
	if not out_dir.ends_with("/"):
		out_dir += "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var ok: bool = _make_feature(background_path, out_dir + "feature_graphic_1024x500.png")
	ok = _make_icon(out_dir + "icon_512.png") and ok
	quit(0 if ok else 1)


func _load(path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		push_error("No se pudo leer la imagen: %s" % path)
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image


## Escala la imagen para cubrir `size` sin deformarla y recorta lo que sobra, centrado.
func _cover(image: Image, size: Vector2i) -> Image:
	var scale: float = maxf(float(size.x) / image.get_width(), float(size.y) / image.get_height())
	var scaled: Vector2i = Vector2i(ceili(image.get_width() * scale), ceili(image.get_height() * scale))
	image.resize(scaled.x, scaled.y, Image.INTERPOLATE_LANCZOS)
	var origin: Vector2i = (scaled - size) / 2
	return image.get_region(Rect2i(origin, size))


func _make_feature(background_path: String, out_path: String) -> bool:
	var background: Image = _load(background_path)
	var logo: Image = _load(LOGO_PATH)
	if background == null or logo == null:
		return false
	var full: Vector2 = Vector2(background.get_size())
	var crop: Rect2i = Rect2i(Vector2i(SOURCE_CROP.position * full), Vector2i(SOURCE_CROP.size * full))
	var canvas: Image = _cover(background.get_region(crop), FEATURE_SIZE)
	var shade: Image = Image.create(FEATURE_SIZE.x, FEATURE_SIZE.y, false, Image.FORMAT_RGBA8)
	shade.fill(Color(0, 0, 0, BACKGROUND_DARKEN))
	canvas.blend_rect(shade, Rect2i(Vector2i.ZERO, FEATURE_SIZE), Vector2i.ZERO)
	var logo_width: int = roundi(FEATURE_SIZE.x * LOGO_WIDTH_RATIO)
	var logo_height: int = roundi(float(logo.get_height()) * logo_width / logo.get_width())
	logo.resize(logo_width, logo_height, Image.INTERPOLATE_LANCZOS)
	var logo_pos: Vector2i = (FEATURE_SIZE - Vector2i(logo_width, logo_height)) / 2
	canvas.blend_rect(logo, Rect2i(Vector2i.ZERO, logo.get_size()), logo_pos)
	canvas.convert(Image.FORMAT_RGB8)  # Play no acepta transparencia en el gráfico destacado.
	var error: Error = canvas.save_png(ProjectSettings.globalize_path(out_path))
	print("Gráfico destacado: %s (%s)" % [out_path, error_string(error)])
	return error == OK


func _make_icon(out_path: String) -> bool:
	var icon: Image = _load(ICON_PATH)
	if icon == null:
		return false
	if icon.get_size() != ICON_SIZE:
		icon.resize(ICON_SIZE.x, ICON_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var error: Error = icon.save_png(ProjectSettings.globalize_path(out_path))
	print("Ícono: %s (%s)" % [out_path, error_string(error)])
	return error == OK
