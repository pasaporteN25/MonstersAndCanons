# Pantalla de victoria o derrota (RF-90, RF-91).
class_name EndScreen
extends CanvasLayer

signal retry_pressed
signal next_pressed
signal levels_pressed

@onready var _title: Label = %Title
@onready var _stars: StarsDisplay = %Stars
@onready var _detail: Label = %Detail
@onready var _retry_button: Button = %RetryButton
@onready var _next_button: Button = %NextButton
@onready var _levels_button: Button = %LevelsButton


func _ready() -> void:
	visible = false
	_retry_button.pressed.connect(retry_pressed.emit)
	_next_button.pressed.connect(next_pressed.emit)
	_levels_button.pressed.connect(levels_pressed.emit)


## `has_next`: hay un nivel siguiente (y se juega desde la campaña).
## `in_campaign`: se llegó desde el menú; si no (F6, tests), no hay a dónde volver.
func show_victory(lives_left: int, stars: int, has_next: bool, in_campaign: bool) -> void:
	_title.text = "¡Victoria!"
	_stars.count = stars  # RF-93
	_stars.visible = true
	_title.add_theme_color_override("font_color", Color(1, 0.84, 0.3))
	_detail.text = "Vidas restantes: %d" % lives_left
	_next_button.visible = has_next
	_levels_button.visible = in_campaign
	visible = true


func show_defeat(wave: int, total_waves: int, in_campaign: bool) -> void:
	_title.text = "Derrota"
	_stars.visible = false
	_title.add_theme_color_override("font_color", Color(1, 0.45, 0.45))
	_detail.text = "Llegaste a la oleada %d de %d" % [wave, total_waves]
	_next_button.visible = false
	_levels_button.visible = in_campaign
	visible = true
