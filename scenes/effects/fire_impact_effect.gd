# Breve llamarada en el punto de impacto. Reusa la textura de quemadura del enemigo.
class_name FireImpactEffect
extends Node2D

const FLAME: Texture2D = preload("res://assets/sprites/effects/flame.svg")
const DURATION: float = 0.25

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress: float = _time / DURATION
	var alpha: float = 1.0 - progress
	var radius: float = 5.0 + progress * 7.0
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.34, 0.08, 0.16 * alpha))
	for i: int in 3:
		var x: float = (float(i) - 1.0) * (6.0 + progress * 5.0)
		var y: float = -2.0 - progress * (6.0 + float(i % 2) * 3.0)
		var height: float = (12.0 if i == 1 else 9.0) * (1.0 - progress * 0.35)
		draw_texture_rect(FLAME, Rect2(x - height * 0.38, y - height, height * 0.76, height), false,
			Color(1, 1, 1, alpha))
