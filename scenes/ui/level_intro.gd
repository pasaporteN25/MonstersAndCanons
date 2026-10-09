# El cartel de entrada de un nivel (M52, RF-466): el nombre del nivel, su lugar y las líneas de la entrada,
# con un botón «Empezar». Mismo estilo que el menú de pausa, pero NO es el menú de pausa: no dice «PAUSA» ni se
# abre con `P`. Solo muestra y avisa (`closed`); quien lo abre (`Game`) decide qué pasa con la partida (P6).
#
# Se omite con un toque o clic en cualquier parte, el botón «Empezar», `Espacio`, `Enter` o `Esc`. Todo se
# atiende en `_input`, antes que el resto del juego: así `Esc` no abre el menú de pausa y el clic que lo cierra
# no llega a la construcción (el clic se traga al apretar y el cartel se cierra al soltar; en el celular el
# toque llega como un clic emulado).
class_name LevelIntro
extends CanvasLayer

## Se cerró el cartel (por cualquier vía).
signal closed

@onready var _panel: Control = %IntroPanel
@onready var _title: Label = %Title
@onready var _place: Label = %Place
@onready var _lines: Label = %Lines
@onready var _start_button: Button = %StartButton


func _ready() -> void:
	visible = false
	_start_button.pressed.connect(close)
	Audio.add_click_sounds(self)


## Lo abre. `title` es el nombre del nivel; `place`, su lugar ("" = sin subtítulo); `text`, las líneas de la entrada.
func open(title: String, place: String, text: String) -> void:
	_title.text = title
	_place.text = place
	_place.visible = place != ""
	_lines.text = text
	visible = true
	_start_button.grab_focus()


func is_open() -> bool:
	return visible


## Lo cierra y avisa. Si ya estaba cerrado no hace nada (así `closed` sale una sola vez).
func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## El texto de las líneas que se ve (para los tests).
func lines_text() -> String:
	return _lines.text


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if key != null and key.pressed:
		if not key.echo and (key.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER] or event.is_action_pressed("cancel")):
			close()
		get_viewport().set_input_as_handled()  # con el cartel abierto las teclas no llegan a la partida
		return
	if event.is_action_pressed("cancel"):  # el «atrás» de Android llega como acción, no como tecla
		close()
		get_viewport().set_input_as_handled()
		return
	var click := event as InputEventMouseButton
	if click != null:
		if not click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			close()
		get_viewport().set_input_as_handled()  # el clic no pasa a la partida (ni al cerrar ni al apretar)
	elif event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
