# Genera el ícono del juego (assets/icon.png, 512×512): una torre con su cañón,
# sobre fondo oscuro con borde dorado, en el estilo geométrico del juego (D-002).
#
# Uso: godot --headless --path . -s tools/make_icon.gd
extends SceneTree

const SIZE: int = 512
const BG := Color(0.12, 0.13, 0.16)
const GOLD := Color(1.0, 0.84, 0.3)
const GRASS := Color("6fae4f")
const TOWER := Color("7a7a7a")
const TOWER_DARK := Color("3d3d3d")


func _init() -> void:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_rounded_rect(img, Rect2i(0, 0, SIZE, SIZE), 96, GOLD)            # borde dorado
	_rounded_rect(img, Rect2i(16, 16, SIZE - 32, SIZE - 32), 82, BG)  # fondo
	_rounded_rect(img, Rect2i(64, 300, SIZE - 128, 148), 40, GRASS)   # pasto
	img.fill_rect(Rect2i(136, 176, 240, 240), TOWER_DARK)             # torre: borde
	img.fill_rect(Rect2i(150, 190, 212, 212), TOWER)                  # torre
	_line(img, Vector2(256, 296), Vector2(400, 150), 46, TOWER_DARK)  # cañón apuntando
	_circle(img, Vector2(256, 296), 70, TOWER_DARK)                   # torreta
	_circle(img, Vector2(256, 296), 44, TOWER)
	_circle(img, Vector2(412, 138), 26, Color(1.0, 0.95, 0.6))        # destello del disparo
	print("icon: ", img.save_png("res://assets/icon.png"))
	quit()


func _rounded_rect(img: Image, rect: Rect2i, radius: int, color: Color) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			var cx: int = clampi(x, rect.position.x + radius, rect.end.x - 1 - radius)
			var cy: int = clampi(y, rect.position.y + radius, rect.end.y - 1 - radius)
			if Vector2(x - cx, y - cy).length() <= radius:
				img.set_pixel(x, y, color)


func _circle(img: Image, center: Vector2, radius: float, color: Color) -> void:
	for y: int in range(int(center.y - radius), int(center.y + radius) + 1):
		for x: int in range(int(center.x - radius), int(center.x + radius) + 1):
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, color)


## Línea gruesa: círculos seguidos a lo largo del segmento.
func _line(img: Image, from: Vector2, to: Vector2, width: float, color: Color) -> void:
	var steps: int = int(from.distance_to(to))
	for i: int in steps + 1:
		_circle(img, from.lerp(to, float(i) / steps), width / 2.0, color)
