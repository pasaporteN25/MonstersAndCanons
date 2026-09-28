# Pantalla de victoria o derrota (RF-90, RF-91).
class_name EndScreen
extends CanvasLayer

signal retry_pressed

@onready var _title: Label = %Title
@onready var _detail: Label = %Detail
@onready var _retry_button: Button = %RetryButton


func _ready() -> void:
	visible = false
	_retry_button.pressed.connect(retry_pressed.emit)


func show_victory(lives_left: int) -> void:
	_title.text = "¡Victoria!"
	_title.add_theme_color_override("font_color", Color(1, 0.84, 0.3))
	_detail.text = "Vidas restantes: %d" % lives_left
	visible = true


func show_defeat(wave: int, total_waves: int) -> void:
	_title.text = "Derrota"
	_title.add_theme_color_override("font_color", Color(1, 0.45, 0.45))
	_detail.text = "Llegaste a la oleada %d de %d" % [wave, total_waves]
	visible = true
