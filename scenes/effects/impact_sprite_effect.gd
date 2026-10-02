# Impacto renderizado: se expande y desaparece. No interviene en el daño.
class_name ImpactSpriteEffect
extends Node2D

var _texture: Texture2D
var _size: float = 24.0
var _duration: float = 0.25
var _time: float = 0.0

func setup(texture: Texture2D, size_: float, duration: float) -> ImpactSpriteEffect:
	_texture = texture
	_size = size_
	_duration = maxf(duration, 0.01)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return self

func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if _texture == null:
		return
	var progress: float = _time / _duration
	var side: float = _size * (0.7 + progress * 0.5)
	var alpha: float = (1.0 - progress) * 0.85
	draw_texture_rect(_texture, Rect2(Vector2.ONE * -side / 2.0, Vector2.ONE * side), false, Color(1, 1, 1, alpha))
