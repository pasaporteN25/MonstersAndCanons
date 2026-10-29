# El cartel de entrada de un nivel (M52, RF-466): el nombre del nivel, su lugar y las líneas de la entrada,
# con un botón «Empezar» (solo en mobile; en PC lo reemplaza la indicación de clic o tecla, T429) y el suelo del
# tema del nivel de fondo, como en su tarjeta de selección. Mismo estilo que el menú de pausa, pero NO es el menú de pausa: no dice «PAUSA» ni se
# abre con `P`. Solo muestra y avisa (`closed`); quien lo abre (`Game`) decide qué pasa con la partida (P6).
#
# Se omite con un toque o clic en cualquier parte, el botón «Empezar» (mobile) o cualquier tecla. Todo se
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
@onready var _hint: Label = %Hint
@onready var _backdrop: TextureRect = %ThemeBackdrop
@onready var _tint: ColorRect = %ThemeTint

## Cuánto se deja ver el suelo del tema detrás del texto (que se siga leyendo bien).
const BACKDROP_ALPHA: float = 0.30
const TINT_ALPHA: float = 0.35


func _ready() -> void:
	visible = false
	Localization.apply(self, {"%StartButton": &"level_intro.start"})
	_start_button.pressed.connect(close)
	get_node("/root/Audio").call("add_click_sounds", self)


## Lo abre. `title` es el nombre del nivel; `place`, su lugar ("" = sin subtítulo); `text`, las líneas de la entrada;
## `theme_id`, el tema del mapa del nivel (decide el suelo y el color del fondo).
func open(title: String, place: String, text: String, theme_id: StringName = MapThemes.DEFAULT) -> void:
	_title.text = title
	_place.text = place
	_place.visible = place != ""
	_lines.text = text
	_apply_theme(theme_id)
	var mobile: bool = UiMode.is_mobile()
	_start_button.visible = mobile  # en PC la indicación de abajo reemplaza al botón redundante
	_hint.text = Localization.t(&"level_intro.hint_mobile" if mobile else &"level_intro.hint_desktop")
	visible = true
	if mobile:
		_start_button.grab_focus()


func is_open() -> bool:
	return visible


## Lo cierra y avisa. Si ya estaba cerrado no hace nada (así `closed` sale una sola vez).
func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## El suelo y el tinte del tema; uno desconocido usa la pradera (MapThemes).
func _apply_theme(theme_id: StringName) -> void:
	var edge: Color = MapThemes.palette(theme_id)["edge"]
	_backdrop.texture = MapThemes.ground_texture(theme_id)
	_backdrop.modulate = Color(1, 1, 1, BACKDROP_ALPHA)
	_tint.color = Color(edge.r, edge.g, edge.b, TINT_ALPHA)


## El texto de las líneas que se ve (para los tests).
func lines_text() -> String:
	return _lines.text


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if key != null and key.pressed:
		if not key.echo:
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
