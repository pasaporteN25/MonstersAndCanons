# Texto que sube y se desvanece, por ejemplo "+5" de oro (RF-124).
# Se borra solo al terminar.
class_name FloatingText
extends Node2D

const DURATION: float = 0.8
const RISE_PX: float = 36.0
const FONT_SIZE: int = 20

var _text: String = ""
var _color: Color = Color.WHITE
var _time: float = 0.0


func setup(text: String, color: Color) -> FloatingText:
	_text = text
	_color = color
	return self


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = _time / DURATION
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var pos := Vector2(-width / 2.0, -RISE_PX * (1.0 - pow(1.0 - t, 2.0)))
	# Se mantiene opaco la primera mitad y después se desvanece.
	var alpha: float = 1.0 if t < 0.5 else 1.0 - (t - 0.5) * 2.0
	draw_string_outline(font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, 4,
		Color(0, 0, 0, alpha * 0.8))
	draw_string(font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color(_color, alpha))
