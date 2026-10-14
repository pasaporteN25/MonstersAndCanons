# Los créditos (M52, RF-472): texto centrado sobre un fondo oscuro, con desplazamiento si no entra, y un botón
# «Volver». Su contenido sale de `data/creditos.json` (Credits). Sin música nueva ni animación.
# Solo muestra y avisa (`closed`): a dónde se vuelve lo decide quien lo abre (constitución P6).
class_name CreditsScreen
extends CanvasLayer

## Se cerró la pantalla (por «Volver», `Esc` o el «atrás» de Android).
signal closed

const TITLE: String = "Créditos"
const BACK_TEXT: String = "Volver"
const GOLD := Color(1.0, 0.84, 0.3)
const TEXT_COLOR := Color(0.92, 0.92, 0.96)
const THEME: Theme = preload("res://assets/ui/menu_theme.tres")

var _rows: VBoxContainer
var _scroll: ScrollContainer
var _back_button: Button


func _init() -> void:
	layer = 18  # encima del epílogo (15) y debajo del Salón de la fama (20)
	visible = false
	var dim := ColorRect.new()
	dim.theme = THEME
	dim.color = Color(0.03, 0.035, 0.05, 1.0)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 48.0
	column.offset_right = -48.0
	column.offset_top = 36.0
	column.offset_bottom = -36.0
	column.add_theme_constant_override("separation", 18)
	dim.add_child(column)
	column.add_child(_label(TITLE, 40, GOLD))
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 14)
	_scroll.add_child(_rows)
	_back_button = Button.new()
	_back_button.text = BACK_TEXT
	_back_button.custom_minimum_size = Vector2(220, 52)
	_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_back_button.add_theme_font_size_override("font_size", 22)
	_back_button.pressed.connect(close)
	column.add_child(_back_button)


func _ready() -> void:
	Audio.add_click_sounds(self)


## Abre los créditos con las líneas de `data/creditos.json`. Si el archivo está mal, no abre nada y avisa por consola.
func open(lines: PackedStringArray = PackedStringArray()) -> void:
	if lines.is_empty():
		var result: Dictionary = Credits.load_file()
		for problem: String in result["errors"]:
			push_error("Créditos: " + problem)
		lines = result["lines"]
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	for line: String in lines:
		var label: Label = _label(line, 24, TEXT_COLOR)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_rows.add_child(label)
	_scroll.scroll_vertical = 0
	visible = true
	_back_button.grab_focus()


func is_open() -> bool:
	return visible


## Cierra y avisa. Si ya estaba cerrada no hace nada (así `closed` sale una sola vez).
func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## Las líneas que se ven, en orden (para los tests).
func lines() -> PackedStringArray:
	var shown: PackedStringArray = []
	for child: Node in _rows.get_children():
		if not child.is_queued_for_deletion():
			shown.append((child as Label).text)
	return shown


## Con la pantalla abierta, `Esc` (o el «atrás» de Android) la cierra y no llega a nadie más.
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
