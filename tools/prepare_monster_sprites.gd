# Prepara las copias de producción de los monstruos M24 a partir de las fuentes de art/redesign-m24/sources/.
# Recorta el cuerpo por su opacidad, lo escala y lo apoya en un lienzo cuadrado de 256×256 con la
# línea de los pies siempre a la misma altura (RF-329, D-050). Las fuentes no se tocan.
# Uso: godot --headless --path . -s tools/prepare_monster_sprites.gd
extends SceneTree

const SOURCE_DIR := "res://art/redesign-m24/sources/"
const OUTPUT_DIR := "res://assets/sprites/enemies/rendered/"
const CANVAS: int = 256
## Dónde apoyan los pies, como fracción del alto del lienzo: con EnemyShape.SPRITE_SCALE (2.8) cae
## justo sobre la sombra del suelo que dibuja el enemigo.
const FOOT_LINE: float = 0.7455
## Hasta dónde puede subir la cabeza (el alto máximo del cuerpo coincide con EnemyShape.sprite_top, donde
## van la barra de vida y la corona) y cuánto puede ocupar de ancho.
const MAX_BODY_HEIGHT: float = 0.634
const MAX_BODY_WIDTH: float = 0.98
## Un píxel cuenta como cuerpo con más de esta opacidad (ignora motas casi invisibles del generador).
const BODY_ALPHA: float = 0.1
## id del enemigo → archivo fuente aprobado por Lucas.
const CREATURES: Dictionary = {
	"normal": "normal_B.png",
	"fast": "fast_A.png",
	"tank": "tank_A.png",
}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for id: String in CREATURES:
		var path: String = SOURCE_DIR + String(CREATURES[id])
		var source: Image = Image.load_from_file(path)
		if source == null or source.is_empty():
			push_error("No se pudo leer %s" % path)
			quit(1)
			return
		var result: Image = frame(source)
		var out: String = OUTPUT_DIR + id + ".png"
		var error: int = result.save_png(out)
		if error != OK:
			push_error("No se pudo guardar %s" % out)
			quit(1)
			return
		print("%s: fuente %dx%d → %s" % [id, source.get_width(), source.get_height(), out])
	quit()


## El rectángulo de la imagen donde hay cuerpo (opacidad mayor que BODY_ALPHA).
static func body_rect(image: Image) -> Rect2i:
	var left: int = image.get_width()
	var top: int = image.get_height()
	var right: int = -1
	var bottom: int = -1
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > BODY_ALPHA:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
	if right < 0:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)


## Devuelve la imagen enmarcada: cuerpo recortado, escalado y con los pies en FOOT_LINE.
static func frame(source: Image) -> Image:
	var image: Image = source.duplicate()
	image.convert(Image.FORMAT_RGBA8)
	var rect: Rect2i = body_rect(image)
	var body: Image = image.get_region(rect)
	body.premultiply_alpha()  # así el color de los píxeles transparentes no mancha los bordes al achicar
	var scale: float = minf(CANVAS * MAX_BODY_WIDTH / rect.size.x, CANVAS * MAX_BODY_HEIGHT / rect.size.y)
	var width: int = maxi(1, roundi(rect.size.x * scale))
	var height: int = maxi(1, roundi(rect.size.y * scale))
	body.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_unpremultiply(body)
	var canvas: Image = Image.create_empty(CANVAS, CANVAS, false, Image.FORMAT_RGBA8)
	var foot_y: int = roundi(CANVAS * FOOT_LINE)
	canvas.blit_rect(body, Rect2i(0, 0, width, height), Vector2i((CANVAS - width) / 2, foot_y - height))
	return canvas


## Deshace premultiply_alpha() (el color vuelve a ser independiente de la opacidad).
static func _unpremultiply(image: Image) -> void:
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a > 0.0:
				image.set_pixel(x, y, Color(minf(pixel.r / pixel.a, 1.0), minf(pixel.g / pixel.a, 1.0),
					minf(pixel.b / pixel.a, 1.0), pixel.a))
