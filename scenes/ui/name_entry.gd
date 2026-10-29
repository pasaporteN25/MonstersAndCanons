# Entrada de iniciales estilo arcade (RF-192): una casilla por letra, con ▲/▼ para cambiarla.
# Con el teclado: flechas, letras (se escriben directo), Retroceso y Enter.
# Con el mouse o tocando la pantalla: los botones ▲, ▼ y "Listo".
class_name NameEntry
extends VBoxContainer

signal confirmed(name: String)

const LETTER_SIZE: int = 40
const SELECTED_COLOR := Color(1.0, 0.84, 0.3)
const NORMAL_COLOR := Color(1, 1, 1)

var _letters: Array[int] = []  # índice de cada letra en HighScores.LETTERS
var _slot: int = 0
var _labels: Array[Label] = []


## `initial`: las letras con las que empieza (por ejemplo, las últimas usadas).
func setup(length: int, initial: String) -> NameEntry:
	theme = preload("res://assets/ui/menu_theme.tres")
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 8)
	var clean: String = HighScores.clean_name(initial, length)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	add_child(row)
	for i: int in length:
		_letters.append(HighScores.LETTERS.find(clean[i]))
		row.add_child(_slot_column(i))
	var done := Button.new()
	done.text = Localization.t(&"name_entry.done")
	done.focus_mode = Control.FOCUS_NONE
	done.custom_minimum_size = Vector2(0, 44)
	done.pressed.connect(confirm)
	add_child(done)
	_refresh()
	return self


func get_name_text() -> String:
	var text: String = ""
	for letter: int in _letters:
		text += HighScores.LETTERS[letter]
	return text


func confirm() -> void:
	confirmed.emit(get_name_text())


## Cambia la letra de la casilla `slot` hacia adelante (+1) o atrás (-1), dando la vuelta.
func change_letter(slot: int, step: int) -> void:
	_slot = slot
	_letters[slot] = posmod(_letters[slot] + step, HighScores.LETTERS.length())
	_refresh()


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or not is_visible_in_tree():
		return
	var typed: String = String.chr(key.unicode).to_upper() if key.unicode > 0 else ""
	if typed != "" and HighScores.LETTERS.contains(typed):
		_letters[_slot] = HighScores.LETTERS.find(typed)
		_slot = mini(_slot + 1, _letters.size() - 1)
	elif key.keycode == KEY_UP:
		change_letter(_slot, 1)
	elif key.keycode == KEY_DOWN:
		change_letter(_slot, -1)
	elif key.keycode == KEY_RIGHT:
		_slot = mini(_slot + 1, _letters.size() - 1)
	elif key.keycode == KEY_LEFT or key.keycode == KEY_BACKSPACE:
		_slot = maxi(_slot - 1, 0)
	elif key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		confirm()
	else:
		return
	_refresh()
	get_viewport().set_input_as_handled()  # que las letras no lleguen a la partida (P, F, U…)


func _slot_column(index: int) -> Control:
	var column := VBoxContainer.new()
	column.add_child(_arrow_button("▲", index, 1))
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(48, 0)
	label.add_theme_font_size_override("font_size", LETTER_SIZE)
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_slot = index
			_refresh())
	_labels.append(label)
	column.add_child(label)
	column.add_child(_arrow_button("▼", index, -1))
	return column


func _arrow_button(text: String, slot: int, step: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(change_letter.bind(slot, step))
	return button


func _refresh() -> void:
	for i: int in _labels.size():
		_labels[i].text = HighScores.LETTERS[_letters[i]]
		_labels[i].add_theme_color_override("font_color", SELECTED_COLOR if i == _slot else NORMAL_COLOR)
