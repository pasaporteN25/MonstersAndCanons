# Genera el ícono del juego (assets/icon.png, 512×512) con los dibujos del juego (RF-159):
# una torre de nivel 3 con el Cañón apuntando al Jefe, sobre pasto, con borde dorado.
# Se usa para la ventana, el .exe (export_presets.cfg) y el celular.
#
# Uso: godot --headless --path . -s tools/make_icon.gd
extends SceneTree

const SIZE: int = 512
const BG := Color(0.12, 0.13, 0.16)
const GOLD := Color(1.0, 0.84, 0.3)
const GRASS := Color("6fae4f")
const GRASS_DARK := Color("5d9a42")
const FLASH := Color(1.0, 0.95, 0.6)


func _init() -> void:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_rounded_rect(img, Rect2i(0, 0, SIZE, SIZE), 96, GOLD)            # borde dorado
	_rounded_rect(img, Rect2i(16, 16, SIZE - 32, SIZE - 32), 82, BG)  # fondo
	_rounded_rect(img, Rect2i(40, 250, SIZE - 80, 222), 60, GRASS)    # pasto
	_rounded_rect(img, Rect2i(40, 400, SIZE - 80, 72), 36, GRASS_DARK)
	# La torre (base de nivel 3 + Cañón), a la izquierda, apuntando a la derecha.
	_paste_svg(img, "res://assets/sprites/towers/base_3.svg", 3.6, Vector2i(28, 186), false)
	_paste_svg(img, "res://assets/sprites/towers/turret_cannon.svg", 3.6, Vector2i(28, 186), false)
	_circle(img, Vector2(258, 301), 19, FLASH)                         # destello del disparo
	# El Jefe, a la derecha, dado vuelta para mirar a la torre.
	_paste_svg(img, "res://assets/sprites/enemies/boss.svg", 3.8, Vector2i(250, 96), true)
	print("icon: ", img.save_png("res://assets/icon.png"))
	quit()


## Dibuja un SVG del juego sobre el ícono. `scale` 4 = cada unidad del SVG mide 4 píxeles.
func _paste_svg(img: Image, path: String, scale: float, at: Vector2i, mirror: bool) -> void:
	var sprite := Image.new()
	var error: Error = sprite.load_svg_from_string(FileAccess.get_file_as_string(path), scale)
	if error != OK:
		push_error("No se pudo leer %s" % path)
		return
	sprite.convert(Image.FORMAT_RGBA8)
	if mirror:
		sprite.flip_x()
	img.blend_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), at)


func _rounded_rect(img: Image, rect: Rect2i, radius: int, color: Color) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			var dx: int = maxi(maxi(rect.position.x + radius - x, x - (rect.end.x - 1 - radius)), 0)
			var dy: int = maxi(maxi(rect.position.y + radius - y, y - (rect.end.y - 1 - radius)), 0)
			if dx * dx + dy * dy <= radius * radius:
				img.set_pixel(x, y, color)


func _circle(img: Image, center: Vector2, radius: float, color: Color) -> void:
	for y: int in range(int(center.y - radius), int(center.y + radius) + 1):
		for x: int in range(int(center.x - radius), int(center.x + radius) + 1):
			if Vector2(x, y).distance_to(center) <= radius and x >= 0 and y >= 0 and x < SIZE and y < SIZE:
				img.set_pixel(x, y, color)
