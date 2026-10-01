# Rayo en zigzag que une a los enemigos golpeados por un rayo en cadena (RF-163, RF-158).
# Es solo visual: se borra solo al terminar.
class_name LightningEffect
extends Node2D

const COLOR := Color(1.0, 0.92, 0.35)
const DURATION: float = 0.22
## Cada tramo se parte en esta cantidad de pedacitos, corridos un poco hacia los costados.
const KINKS_PER_SEGMENT: int = 4
const JITTER_PX: float = 7.0

var _points := PackedVector2Array()
var _branches: Array[PackedVector2Array] = []
var _endpoints := PackedVector2Array()
var _color: Color = COLOR
var _time: float = 0.0


## `points`: posiciones GLOBALES de los golpeados, en orden. La capa de efectos está en el
## origen, así que sirven tal cual como posiciones locales.
func setup(points: PackedVector2Array, color: Color = COLOR) -> LightningEffect:
	_color = color
	_endpoints = points
	for i: int in range(1, points.size()):
		var from: Vector2 = points[i - 1]
		var to: Vector2 = points[i]
		var side: Vector2 = (to - from).orthogonal().normalized()
		_points.append(from)
		for k: int in range(1, KINKS_PER_SEGMENT):
			var t: float = float(k) / KINKS_PER_SEGMENT
			var kink: Vector2 = from.lerp(to, t) + side * randf_range(-JITTER_PX, JITTER_PX)
			_points.append(kink)
			if k % 2 == 1:
				var branch_direction: float = -1.0 if k == 1 else 1.0
				_branches.append(PackedVector2Array([kink,
					kink + side * branch_direction * 6.0 + (to - from).normalized() * 4.0,
					kink + side * branch_direction * 12.0 + (to - from).normalized() * 7.0]))
	if points.size() > 0:
		_points.append(points[points.size() - 1])
	return self


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _points.size() < 2:
		return
	var alpha: float = 1.0 - _time / DURATION
	draw_polyline(_points, Color(_color, 0.16 * alpha), 15.0)
	draw_polyline(_points, Color(_color, 0.8 * alpha), 5.0)
	draw_polyline(_points, Color(1, 1, 1, alpha), 1.7)
	for branch: PackedVector2Array in _branches:
		draw_polyline(branch, Color(_color, 0.45 * alpha), 3.0)
		draw_polyline(branch, Color(1, 1, 1, 0.8 * alpha), 1.0)
	for point: Vector2 in _endpoints:
		draw_circle(point, 6.0, Color(_color, 0.25 * alpha))
		draw_circle(point, 2.3, Color(1, 1, 1, 0.9 * alpha))
