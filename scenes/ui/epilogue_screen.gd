# El epílogo (M52, RF-471): al ganar el último nivel de la campaña, la imagen del final a pantalla completa
# (recortada a lo que entre), el texto `"epilogo"` del nivel sobre una franja de abajo y dos botones: «Créditos»
# y «Niveles». `Esc` o un toque sobre la imagen vuelven a la pantalla de victoria (esta pantalla se cierra).
# No guarda nada: la campaña está «terminada» cuando los 15 niveles figuran completados (GameFlow).
# Solo muestra y avisa: a dónde va «Niveles» lo decide quien la abre (constitución P6).
class_name EpilogueScreen
extends CanvasLayer

## Se cerró el epílogo (`Esc`, un toque o el «atrás» de Android): se vuelve a la pantalla de victoria.
signal closed
signal levels_pressed

const IMAGE: Texture2D = preload("res://assets/sprites/story/epilogue.png")
const CREDITS_TEXT: String = "Créditos"
const LEVELS_TEXT: String = "Niveles"
const TEXT_COLOR := Color(0.96, 0.94, 0.88)
const STRIP_COLOR := Color(0.04, 0.045, 0.06, 0.78)
const THEME: Theme = preload("res://assets/ui/menu_theme.tres")

var credits: CreditsScreen
var _text: Label
var _credits_button: Button
var _levels_button: Button
var _root: Control


func _init() -> void:
	layer = 15  # encima de la pantalla de victoria (10) y debajo del Salón de la fama (20)
	visible = false
	_root = Control.new()
	_root.theme = THEME
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_gui_input)
	add_child(_root)
	var image := TextureRect.new()
	image.texture = IMAGE
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED  # 16:9 recortada a lo que entre
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(image)
	var strip := PanelContainer.new()
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.anchor_top = 1.0
	strip.offset_top = -230.0
	strip.offset_bottom = 0.0
	var style := StyleBoxFlat.new()
	style.bg_color = STRIP_COLOR
	strip.add_theme_stylebox_override("panel", style)
	strip.mouse_filter = Control.MOUSE_FILTER_PASS
	_root.add_child(strip)
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 64)
	for side: String in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	strip.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 12)
	margin.add_child(rows)
	_text = Label.new()
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 22)
	_text.add_theme_color_override("font_color", TEXT_COLOR)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(_text)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 24)
	rows.add_child(buttons)
	_credits_button = _button(CREDITS_TEXT)
	_credits_button.pressed.connect(open_credits)
	buttons.add_child(_credits_button)
	_levels_button = _button(LEVELS_TEXT)
	_levels_button.pressed.connect(levels_pressed.emit)
	buttons.add_child(_levels_button)
	credits = CreditsScreen.new()
	add_child(credits)


func _ready() -> void:
	Audio.add_click_sounds(self)


## Abre el epílogo con el texto del nivel (las líneas del campo `"epilogo"`).
func open(text: String) -> void:
	_text.text = text
	visible = true
	_credits_button.grab_focus()


func is_open() -> bool:
	return visible


## Lo cierra y avisa (la pantalla de victoria queda a la vista). Si ya estaba cerrado no hace nada.
func close() -> void:
	if not visible:
		return
	credits.visible = false
	visible = false
	closed.emit()


func open_credits() -> void:
	credits.open()


## El texto que se ve (para los tests).
func text() -> String:
	return _text.text


## Los créditos son hijos de esta pantalla: con ellos abiertos reciben `Esc` primero y lo atienden ellos.
func _input(event: InputEvent) -> void:
	if visible and not credits.is_open() and event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


## Un toque o clic sobre la imagen (los botones lo reciben antes) vuelve a la pantalla de victoria.
func _on_root_gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT:
		if not click.pressed:
			close()
		_root.accept_event()


func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(220, 52)
	button.add_theme_font_size_override("font_size", 22)
	return button
