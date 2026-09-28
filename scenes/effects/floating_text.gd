# Texto que sube y se desvanece: el "+5" de oro (RF-124) o un número de daño (RF-132).
# Se borra solo al terminar.
class_name FloatingText
extends Node2D

var _text: String = ""
var _color: Color = Color.WHITE
var _font_size: int = 20
var _duration: float = 0.8
var _rise_px: float = 36.0
var _time: float = 0.0


func setup(text: String, color: Color, font_size: int = 20, duration: float = 0.8,
		rise_px: float = 36.0) -> FloatingText:
	_text = text
	_color = color
	_font_size = font_size
	_duration = duration
	_rise_px = rise_px
	return self


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = _time / _duration
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size).x
	var pos := Vector2(-width / 2.0, -_rise_px * (1.0 - pow(1.0 - t, 2.0)))
	# Se mantiene opaco la primera mitad y después se desvanece.
	var alpha: float = 1.0 if t < 0.5 else 1.0 - (t - 0.5) * 2.0
	draw_string_outline(font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, 4,
		Color(0, 0, 0, alpha * 0.8))
	draw_string(font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, Color(_color, alpha))
