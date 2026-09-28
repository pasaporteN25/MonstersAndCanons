# Menú de pausa (RF-114): Continuar, Reintentar, Opciones, Salir al menú.
# Solo muestra y avisa; quien lo usa (Game) decide qué hacer.
class_name PauseMenu
extends CanvasLayer

signal resume_pressed
signal retry_pressed
signal quit_pressed

@onready var _panel: Control = %MenuPanel
@onready var _options: OptionsMenu = %OptionsMenu


func _ready() -> void:
	visible = false
	(%ResumeButton as Button).pressed.connect(resume_pressed.emit)
	(%RetryButton as Button).pressed.connect(retry_pressed.emit)
	(%OptionsButton as Button).pressed.connect(_open_options)
	(%QuitButton as Button).pressed.connect(quit_pressed.emit)
	_options.closed.connect(_on_options_closed)
	Audio.add_click_sounds(self)


func open() -> void:
	visible = true
	_panel.visible = true
	_options.visible = false


func close() -> void:
	visible = false


func is_open() -> bool:
	return visible


## Esc con las opciones abiertas las cierra; si no, cierra el menú.
func handle_cancel() -> void:
	if _options.visible:
		_options.close()
	else:
		resume_pressed.emit()


func _open_options() -> void:
	_panel.visible = false
	_options.open()


func _on_options_closed() -> void:
	_panel.visible = true
