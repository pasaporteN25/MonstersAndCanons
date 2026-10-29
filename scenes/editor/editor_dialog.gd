# Cuadro de diálogo del editor de mapas (spec §10.3, RF-216, RF-218): confirmar algo, pedir un nombre
# o elegir de una lista. Tapa toda la pantalla (no se puede tocar el mapa mientras está abierto).
# Solo pregunta y avisa con `accepted` o `cancelled`; qué se hace después lo decide MapEditor.
class_name EditorDialog
extends Control

## La persona aceptó. `value`: el texto escrito, el elemento elegido, o null si era solo confirmar.
signal accepted(value: Variant)
signal cancelled

const NOTE_COLORS: Dictionary = {
	&"error": Color(1.0, 0.5, 0.5), &"warning": Color(1.0, 0.85, 0.4), &"info": Color(0.7, 0.72, 0.78),
}

var _title := Label.new()
var _message := Label.new()
var _field := LineEdit.new()
var _note := Label.new()
var _list := ItemList.new()
var _ok := Button.new()
var _cancel := Button.new()
## Revisa el texto mientras se escribe: devuelve {"ok": bool, "note": String, "kind": StringName}.
var _validator: Callable


func _init() -> void:
	theme = preload("res://assets/ui/menu_theme.tres")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)  # tapa todo: los clics no llegan al mapa
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EditorPanel.PANEL_STYLE)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(500, 0)
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	_title.add_theme_font_size_override("font_size", 24)
	_title.add_theme_color_override("font_color", EditorPanel.TITLE_COLOR)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.add_theme_font_size_override("font_size", 14)
	_list.custom_minimum_size = Vector2(0, 300)
	_field.text_changed.connect(func(_text: String) -> void: _revalidate())
	_field.text_submitted.connect(func(_text: String) -> void: accept())
	_list.item_activated.connect(func(index: int) -> void:  # doble clic: elige y acepta
		if _list.is_item_selectable(index):
			_list.select(index)
			_ok.disabled = false
			accept())
	_list.item_selected.connect(func(_index: int) -> void: _ok.disabled = false)
	_ok.pressed.connect(accept)
	_cancel.text = Localization.t(&"editor.cancel")
	_cancel.pressed.connect(cancel)
	for node: Control in [_title, _message, _field, _note, _list]:
		box.add_child(node)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.add_theme_constant_override("separation", 10)
	buttons.add_child(_cancel)
	buttons.add_child(_ok)
	box.add_child(buttons)


# --- Preguntar ---

## "¿Seguro?": Aceptar / Cancelar.
func ask_confirm(title: String, message: String, ok_text: String) -> void:
	_open(title, message, ok_text)


## Pide un texto. `validator(text)` dice si se puede aceptar y agrega una nota.
func ask_text(title: String, message: String, initial: String, ok_text: String, validator: Callable) -> void:
	_open(title, message, ok_text)
	_validator = validator
	_field.visible = true
	_field.text = initial
	_field.grab_focus()
	_field.select_all()
	_revalidate()


## Elige de una lista. Cada elemento: {"text": String, "value": Variant, "selectable": bool (opcional)}.
func ask_choice(title: String, message: String, items: Array[Dictionary], ok_text: String) -> void:
	_open(title, message, ok_text)
	_list.visible = true
	_list.clear()
	for item: Dictionary in items:
		var index: int = _list.add_item(item["text"])
		_list.set_item_metadata(index, item.get("value"))
		if not item.get("selectable", true):
			_list.set_item_selectable(index, false)
			_list.set_item_custom_fg_color(index, EditorPanel.HEADER_COLOR)
	_ok.disabled = true  # hasta que se elija algo


func is_open() -> bool:
	return visible


## Aceptar (botón, Enter o doble clic). No hace nada si no se puede (nombre inválido, nada elegido).
func accept() -> void:
	if not visible or _ok.disabled:
		return
	var value: Variant = null
	if _field.visible:
		value = _field.text
	elif _list.visible:
		var selected: PackedInt32Array = _list.get_selected_items()
		if selected.is_empty():
			return
		value = _list.get_item_metadata(selected[0])
	visible = false
	accepted.emit(value)


func cancel() -> void:
	if not visible:
		return
	visible = false
	cancelled.emit()


func ok_button() -> Button:
	return _ok


func field() -> LineEdit:
	return _field


func note_text() -> String:
	return _note.text


func list() -> ItemList:
	return _list


func title_text() -> String:
	return _title.text


func message_text() -> String:
	return _message.text


## Esc cierra el diálogo (y no llega al editor: si no, el mismo Esc lo haría salir).
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		cancel()


func _open(title: String, message: String, ok_text: String) -> void:
	_title.text = title
	_message.text = message
	_message.visible = message != ""
	_ok.text = ok_text
	_ok.disabled = false
	_field.visible = false
	_list.visible = false
	_note.visible = false
	_validator = Callable()
	visible = true


func _revalidate() -> void:
	if not _validator.is_valid():
		return
	var verdict: Dictionary = _validator.call(_field.text)
	_ok.disabled = not verdict["ok"]
	_note.visible = verdict["note"] != ""
	_note.text = verdict["note"]
	_note.add_theme_color_override("font_color", NOTE_COLORS.get(verdict["kind"], NOTE_COLORS[&"info"]))
