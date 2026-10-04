# Trayectoria de rebote: lectura del origen y de la torre receptora.
class_name ReflectionEffect
extends Node2D

const DURATION: float = 0.32
var _to: Vector2 = Vector2.ZERO
var _time: float = 0.0

func setup(offset: Vector2) -> ReflectionEffect:
	_to = offset
	return self

func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var t: float = clampf(_time / DURATION, 0, 1)
	var path := PackedVector2Array()
	for i: int in 17:
		var s: float = i / 16.0
		path.append(_to * s + Vector2(0, -sin(s * PI) * 12))
	draw_polyline(path, Color(0.16, 0.38, 0.48, (1 - t) * 0.7), 4.0, true)
	draw_polyline(path, Color(0.71, 0.97, 1, 1 - t), 1.2, true)
	var head: Vector2 = _to * t + Vector2(0, -sin(t * PI) * 12)
	var shard := PackedVector2Array([head + Vector2(0, -5), head + Vector2(3, 0), head + Vector2(0, 5), head + Vector2(-3, 0)])
	draw_colored_polygon(shard, Color(0.91, 1, 1, 1 - t * 0.4))
