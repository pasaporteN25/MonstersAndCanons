# Tabla de récords (RF-193, RF-195): puesto, nombre y puntos. Resalta una fila (la nueva).
class_name ScoreTable
extends VBoxContainer

const HIGHLIGHT_COLOR := Color(1.0, 0.84, 0.3)
const NORMAL_COLOR := Color(1, 1, 1, 0.9)

var _font_size: int = 20


func setup(font_size: int = 20) -> ScoreTable:
	_font_size = font_size
	add_theme_constant_override("separation", 2)
	return self


## `table`: entradas {"name", "points"} de mayor a menor. `highlight`: fila resaltada (-1 = ninguna).
func show_scores(table: Array, highlight: int = -1) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	if table.is_empty():
		add_child(_cell("Todavía no hay récords", 0, NORMAL_COLOR, HORIZONTAL_ALIGNMENT_CENTER))
		return
	for i: int in table.size():
		var color: Color = HIGHLIGHT_COLOR if i == highlight else NORMAL_COLOR
		var row := HBoxContainer.new()
		row.add_child(_cell("%d." % (i + 1), 36, color, HORIZONTAL_ALIGNMENT_RIGHT))
		row.add_child(_cell("  " + String(table[i]["name"]), 110, color, HORIZONTAL_ALIGNMENT_LEFT))
		row.add_child(_cell(str(table[i]["points"]), 110, color, HORIZONTAL_ALIGNMENT_RIGHT))
		add_child(row)


func row_count() -> int:
	return get_child_count()


func _cell(text: String, width: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(width, 0)
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", _font_size)
	label.add_theme_color_override("font_color", color)
	return label
