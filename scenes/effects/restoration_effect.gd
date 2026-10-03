# Pulso de curación efectiva, independiente del aura y del número opcional.
class_name RestorationEffect
extends Node2D

const DURATION: float = 0.5
var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var t: float = clampf(_time / DURATION, 0, 1)
	for i: int in 4:
		var p := Vector2((i - 1.5) * 5, -8 - t * 18 + sin(i * 2.0) * 3)
		var leaf := PackedVector2Array([p + Vector2(0, -3), p + Vector2(2, 0), p + Vector2(0, 3), p + Vector2(-2, 0)])
		draw_colored_polygon(leaf, Color(0.72, 0.96, 0.4, sin(t * PI) * 0.8))
		draw_line(p + Vector2(0, -2), p + Vector2(0, 2), Color(0.95, 1, 0.68, 1 - t), 1.0)
