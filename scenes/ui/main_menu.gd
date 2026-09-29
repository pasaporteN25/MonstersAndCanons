# Menú principal (RF-110): Jugar, Récords, Opciones, Salir. En el modo de pruebas, además, el
# Editor de mapas (RF-210).
extends Control

@onready var _play_button: Button = %PlayButton
@onready var _records_button: Button = %RecordsButton
@onready var _editor_button: Button = %EditorButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit_button: Button = %QuitButton
@onready var _options: OptionsMenu = %OptionsMenu


func _ready() -> void:
	_play_button.pressed.connect(GameFlow.go_to_level_select)
	_records_button.pressed.connect(GameFlow.go_to_records)  # RF-195
	_editor_button.visible = DevMode.enabled  # RF-210: el juego normal y el APK no lo tienen
	_editor_button.pressed.connect(GameFlow.go_to_editor)
	_options_button.pressed.connect(_options.open)
	_quit_button.pressed.connect(get_tree().quit)
	_options.closed.connect(_play_button.grab_focus)
	Audio.add_click_sounds(self)
	_play_button.grab_focus()  # se puede jugar con Enter sin tocar el mouse


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and _options.visible:
		_options.close()
		get_viewport().set_input_as_handled()
