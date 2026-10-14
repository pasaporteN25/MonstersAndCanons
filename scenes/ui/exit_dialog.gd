# Diálogo de la flecha «← Menú» (M53, RF-460): avisa qué se pierde al abandonar la partida. Mismo
# estilo que el menú de pausa. Solo muestra y avisa; `Game` decide (P6).
class_name ExitDialog
extends CanvasLayer

## Se eligió «Salir al menú».
signal confirmed
## Se eligió «Seguir jugando» o se pulsó Esc.
signal cancelled

@onready var _panel: Control = %DialogPanel
@onready var _message: Label = %Message
@onready var _keep_button: Button = %KeepButton
@onready var _leave_button: Button = %LeaveButton


func _ready() -> void:
	visible = false
	_keep_button.pressed.connect(_on_keep_pressed)
	_leave_button.pressed.connect(_on_leave_pressed)
	Audio.add_click_sounds(self)


## Lo abre con el texto de `ExitText`. El foco va a «Seguir jugando»: un `Espacio` o un `Enter` de más no sale.
func open(text: String) -> void:
	_message.text = text
	visible = true
	_keep_button.grab_focus()


func close() -> void:
	visible = false


func is_open() -> bool:
	return visible


## Esc hace lo mismo que «Seguir jugando».
func handle_cancel() -> void:
	_on_keep_pressed()


func _on_keep_pressed() -> void:
	close()
	cancelled.emit()


func _on_leave_pressed() -> void:
	close()
	confirmed.emit()
