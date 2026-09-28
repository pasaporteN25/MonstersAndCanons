# Muestra de 0 a 3 estrellas (RF-93). Se dibujan con código porque la fuente
# del juego podría no tener el símbolo ★. Las ganadas, doradas; las que faltan, huecas.
class_name StarsDisplay
extends Control

const GOLD := Color(1.0, 0.84, 0.3)
const EMPTY := Color(1, 1, 1, 0.25)
const MAX_STARS: int = 3

## Tamaño de cada estrella, en píxeles.
@export var star_size: float = 36.0:
	set(value):
		star_size = value
		_update_size()
@export var count: int = 0:
	set(value):
		count = clampi(value, 0, MAX_STARS)
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_size()


func _update_size() -> void:
	custom_minimum_size = Vector2(star_size * MAX_STARS + star_size * 0.25 * (MAX_STARS - 1), star_size)
	queue_redraw()


func _draw() -> void:
	# Centradas en el espacio que tenga el control.
	var total_width: float = custom_minimum_size.x
	var start_x: float = (size.x - total_width) / 2.0 + star_size / 2.0
	for i: int in MAX_STARS:
		var center := Vector2(start_x + i * star_size * 1.25, size.y / 2.0)
		var points: PackedVector2Array = _star_points(center, star_size / 2.0)
		if i < count:
			draw_colored_polygon(points, GOLD)
			points.append(points[0])
			draw_polyline(points, GOLD.darkened(0.45), 2.0)
		else:
			points.append(points[0])
			draw_polyline(points, EMPTY, 2.0)


## Estrella de 5 puntas: alterna un radio largo (puntas) y uno corto (entrantes).
func _star_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in 10:
		var r: float = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2.from_angle(-PI / 2.0 + TAU * i / 10.0) * r)
	return points
