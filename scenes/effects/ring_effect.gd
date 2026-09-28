# Anillo o círculo que crece y se desvanece (spec §9.3).
# Se usa para la onda del Cañón, el destello del Hielo, las chispas y el anillo al construir.
# Es solo visual: se borra solo al terminar.
class_name RingEffect
extends Node2D

var _color: Color = Color.WHITE
var _from_radius: float = 0.0
var _to_radius: float = 0.0
var _duration: float = 0.2
## Grosor del borde. 0 = círculo relleno.
var _width: float = 0.0
var _time: float = 0.0


func setup(color: Color, from_radius: float, to_radius: float, duration: float, width: float = 0.0) -> RingEffect:
	_color = color
	_from_radius = from_radius
	_to_radius = to_radius
	_duration = duration
	_width = width
	return self


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = clampf(_time / _duration, 0.0, 1.0)
	# ease_out: crece rápido al principio y frena al final.
	var radius: float = lerpf(_from_radius, _to_radius, 1.0 - pow(1.0 - t, 3.0))
	var color := Color(_color, _color.a * (1.0 - t))
	if _width <= 0.0:
		draw_circle(Vector2.ZERO, radius, color)
	else:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, color, _width)
