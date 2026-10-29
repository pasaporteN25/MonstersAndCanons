# Salón de la fama (RF-194): "el ranking de los rankings", para quien ganó todos los niveles.
# Estética propia: fondo oscuro, marco dorado y trofeo. Se usa encima de la pantalla final
# (pidiendo 5 letras) y en la pantalla de récords (solo la tabla).
# Solo muestra y avisa: qué se anota lo decide quien la usa (constitución P6).
class_name HallOfFame
extends CanvasLayer

## Se confirmaron las 5 letras.
signal name_entered(name: String)
## Se tocó "Continuar".
signal closed

const GOLD := Color(1.0, 0.84, 0.3)
const DARK := Color(0.105, 0.11, 0.125)
const TROPHY: Texture2D = preload("res://assets/sprites/ui/trophy.svg")

var _subtitle: Label
var _entry_slot: VBoxContainer
var _table: ScoreTable
var _continue: Button


func _init() -> void:
	layer = 20  # encima de la pantalla final
	var dim := ColorRect.new()
	dim.theme = preload("res://assets/ui/menu_theme.tres")
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	panel.add_theme_stylebox_override("panel", _frame_style())
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 36)
	for side: String in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)
	var trophy := TextureRect.new()
	trophy.texture = TROPHY
	trophy.custom_minimum_size = Vector2(96, 96)
	trophy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trophy.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	trophy.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	trophy.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rows.add_child(trophy)
	rows.add_child(_label(Localization.t(&"hall.title"), 38, GOLD, 8))
	_subtitle = _label("", 20, Color(1, 1, 1, 0.9), 0)
	rows.add_child(_subtitle)
	_entry_slot = VBoxContainer.new()
	rows.add_child(_entry_slot)
	_table = ScoreTable.new().setup(26)
	_table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_table.visible = false
	rows.add_child(_table)
	_continue = Button.new()
	_continue.text = Localization.t(&"hall.continue")
	_continue.focus_mode = Control.FOCUS_NONE
	_continue.custom_minimum_size = Vector2(0, 50)
	_continue.add_theme_font_size_override("font_size", 22)
	_continue.visible = false
	for state: String in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.18, 0.24) if state == "normal" else Color(0.3, 0.26, 0.2)
		style.border_color = GOLD
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		_continue.add_theme_stylebox_override(state, style)
	_continue.add_theme_color_override("font_color", GOLD)
	_continue.pressed.connect(closed.emit)
	rows.add_child(_continue)
	MenuTouch.attach(self)  # RF-550: botones de 56 px en el celular


## Pide las 5 letras para anotar `total` (RF-194).
func ask_name(total: int, initial: String) -> void:
	_subtitle.text = Localization.t_fmt(&"hall.won_all", {"points": total})
	_table.visible = false
	_continue.visible = false
	var entry: NameEntry = NameEntry.new().setup(HighScores.HALL_NAME_LENGTH, initial)
	entry.confirmed.connect(func(name: String) -> void:
		entry.queue_free()
		name_entered.emit(name))
	_entry_slot.add_child(entry)


## Muestra la tabla, con la fila `highlight` resaltada (-1 = ninguna).
func show_table(table: Array, highlight: int = -1, subtitle: String = "") -> void:
	for child: Node in _entry_slot.get_children():
		child.queue_free()
	if subtitle != "":
		_subtitle.text = subtitle
	_table.show_scores(table, highlight)
	_table.visible = true
	_continue.visible = true


func is_asking_name() -> bool:
	for child: Node in _entry_slot.get_children():
		if not child.is_queued_for_deletion():
			return true
	return false


func name_entry() -> NameEntry:
	for child: Node in _entry_slot.get_children():
		if not child.is_queued_for_deletion():
			return child as NameEntry
	return null


func _frame_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = DARK
	style.border_color = GOLD
	style.set_border_width_all(5)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(1.0, 0.84, 0.3, 0.35)
	style.shadow_size = 18
	return style


func _label(text: String, font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if outline > 0:
		label.add_theme_color_override("font_outline_color", Color(0.35, 0.2, 0.05))
		label.add_theme_constant_override("outline_size", outline)
	return label
