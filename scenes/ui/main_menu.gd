# Menú principal (RF-110): Jugar, Opciones, Salir.
extends Control

@onready var _play_button: Button = %PlayButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_play_button.pressed.connect(GameFlow.go_to_level_select)
	_options_button.pressed.connect(_on_options_pressed)
	_quit_button.pressed.connect(get_tree().quit)
	_play_button.grab_focus()  # se puede jugar con Enter sin tocar el mouse


func _on_options_pressed() -> void:
	pass  # T47: se abre la pantalla de opciones
