# La columna de pestañas de la barra de abajo (M53, RF-455): «Cañones», «Infraestructura»… Sale de una
# lista, así que una pestaña de otro tipo se suma sin rehacer la barra. No sabe nada de torres ni de
# infraestructura: solo muestra y avisa (P6).
class_name BarTabs
extends Control

## El usuario eligió una pestaña (con un clic, un toque o `Tab`). No se emite al elegirla por código.
signal tab_selected(id: StringName)

const FONT_SIZE: int = 15
## «Infraestructura» no entra en 96 px: a 13 pt mide 96 px y no deja margen (medido en la ventana real, T248);
## a 12 pt mide 89 y entra con 3 px de margen a cada lado.
const LONG_FONT_SIZE: int = 12
## Margen de texto de cada pestaña (el del tema, 16 px, no deja lugar).
const TAB_MARGIN: float = 3.0
const GAP: int = 4

var _buttons: Dictionary = {}  # id → Button
var _titles: Dictionary = {}  # id → texto base
var _order: Array[StringName] = []
var _current: StringName = &""


func _ready() -> void:
	theme = preload("res://assets/ui/menu_theme.tres")


## `tabs` = [{id: StringName, text: String}], de arriba hacia abajo. La primera arranca activa.
func setup(tabs: Array[Dictionary]) -> void:
	for old: Button in _buttons.values():
		old.queue_free()
	_buttons.clear()
	_titles.clear()
	_order.clear()
	for i: int in tabs.size():
		var id: StringName = tabs[i]["id"]
		var button := Button.new()
		button.name = "Tab_%s" % id
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = BarLayout.TAB_SIZE
		button.size = BarLayout.TAB_SIZE
		button.position = Vector2(0, i * (BarLayout.TAB_SIZE.y + GAP))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		button.add_theme_font_size_override("font_size", FONT_SIZE)
		button.pressed.connect(_on_pressed.bind(id))
		add_child(button)
		tighten(button, TAB_MARGIN)
		_buttons[id] = button
		_titles[id] = String(tabs[i]["text"])
		_order.append(id)
		_apply_text(id, _titles[id])
	custom_minimum_size = Vector2(BarLayout.TAB_SIZE.x, tabs.size() * (BarLayout.TAB_SIZE.y + GAP) - GAP)
	size = custom_minimum_size
	if not _order.is_empty():
		select(_order[0])


## El tema del juego deja 16 px de margen a cada lado del botón: en un botón angosto (la flecha de 80 px, las
## pestañas de 96) el texto no entra y el botón crece. Esto le deja `margin` px a cada lado, solo a este botón.
static func tighten(button: Button, margin: float = 6.0) -> void:
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var box := button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		if box == null:
			continue
		box.content_margin_left = margin
		box.content_margin_right = margin
		button.add_theme_stylebox_override(state, box)


func current() -> StringName:
	return _current


func ids() -> Array[StringName]:
	return _order


func has_tab(id: StringName) -> bool:
	return _buttons.has(id)


## Activa una pestaña por código (no emite `tab_selected`).
func select(id: StringName) -> void:
	if not _buttons.has(id):
		return
	_current = id
	for key: StringName in _buttons:
		(_buttons[key] as Button).set_pressed_no_signal(key == id)


## La pestaña que sigue a la activa (da la vuelta). Con una sola, la misma.
func next_id() -> StringName:
	if _order.is_empty():
		return &""
	return _order[(_order.find(_current) + 1) % _order.size()]


## Texto extra en el título («Infraestructura · 4 s», RF-458). Vacío lo quita.
func set_badge(id: StringName, badge: String) -> void:
	if not _buttons.has(id):
		return
	var base: String = _titles[id]
	_apply_text(id, base if badge == "" else "%s · %s" % [base, badge])


func title_of(id: StringName) -> String:
	return (_buttons[id] as Button).text if _buttons.has(id) else ""


func button_of(id: StringName) -> Button:
	return _buttons.get(id)


func _apply_text(id: StringName, text: String) -> void:
	var button: Button = _buttons[id]
	button.text = text
	button.add_theme_font_size_override("font_size", LONG_FONT_SIZE if text.length() > 9 else FONT_SIZE)


func _on_pressed(id: StringName) -> void:
	if id == _current:
		select(id)  # volver a pulsar la activa no la apaga
		return
	select(id)
	tab_selected.emit(id)
