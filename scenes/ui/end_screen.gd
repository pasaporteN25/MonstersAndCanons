# Pantalla de victoria o derrota (RF-90, RF-91), con los puntos y los récords (RF-190 a RF-194).
# Solo muestra y avisa: qué récord se anota y dónde lo decide Game (constitución P6).
class_name EndScreen
extends CanvasLayer

signal retry_pressed
signal next_pressed
## RF-471: en el último nivel de la campaña el botón de «Siguiente nivel» pasa a ser «Epílogo».
signal epilogue_pressed
signal levels_pressed
## RF-192: se confirmaron las iniciales pedidas con ask_name().
signal name_entered(name: String)

const SCORE_COLOR := Color(0.55, 0.85, 1)
const RECORD_COLOR := Color(1, 0.84, 0.3)
## RF-467: el texto de victoria del nivel, más chico y de color suave. Mismo ancho que el panel (420 menos los márgenes).
const WIN_TEXT_COLOR := Color(0.78, 0.82, 0.9)
const WIN_TEXT_WIDTH: float = 356.0
## M70 (RF-636): los consejos de la derrota, más chicos que el detalle y de colores suaves; mismo ancho que el panel.
const TIP_COLOR := Color(1, 0.88, 0.6)
const TIP_FONT_SIZE: int = 16
## Un poco menos que el ancho útil del panel (352): así el texto con salto de línea no ensancha el panel.
const TIP_WIDTH: float = 340.0

@onready var _rows: VBoxContainer = %Rows
@onready var _title: Label = %Title
@onready var _stars: StarsDisplay = %Stars
@onready var _detail: Label = %Detail
@onready var _retry_button: Button = %RetryButton
@onready var _next_button: Button = %NextButton
@onready var _levels_button: Button = %LevelsButton

var _score_label: Label
var _tower_tip_label: Label
var _win_label: Label
var _record_title: Label
var _entry_slot: VBoxContainer
var _table: ScoreTable
## Qué botones corresponden a esta partida (se esconden mientras se piden las iniciales).
var _show_next: bool = false
var _show_levels: bool = false
## RF-471: el botón de arriba es «Epílogo» (la victoria del último nivel de la campaña).
var _epilogue_mode: bool = false


func _ready() -> void:
	visible = false
	Localization.apply(self, {"%RetryButton": &"end.retry", "%LevelsButton": &"end.levels"})
	_retry_button.pressed.connect(retry_pressed.emit)
	_next_button.pressed.connect(_on_next_button_pressed)
	_levels_button.pressed.connect(levels_pressed.emit)
	# Puntos, título de récords, entrada de iniciales y tabla: debajo del detalle.
	_tower_tip_label = _tip_label(TIP_COLOR)
	_win_label = _label(17, WIN_TEXT_COLOR)
	_win_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_win_label.custom_minimum_size = Vector2(WIN_TEXT_WIDTH, 0)
	_win_label.visible = false
	_score_label = _label(26, SCORE_COLOR)
	_record_title = _label(20, RECORD_COLOR)
	_entry_slot = VBoxContainer.new()
	_table = ScoreTable.new().setup(20)
	_table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var at: int = _detail.get_index() + 1
	for node: Control in [_tower_tip_label, _win_label, _score_label, _record_title, _entry_slot, _table]:
		_rows.add_child(node)
		_rows.move_child(node, at)
		at += 1
	_record_title.visible = false
	_table.visible = false


## Cómo se llama el botón que sale de la partida ("Niveles", o "Volver al editor" al probar, RF-217).
func set_levels_text(text: String) -> void:
	_levels_button.text = text


## `has_next`: hay un nivel siguiente (y se juega desde la campaña).
## `in_campaign`: se llegó desde el menú; si no (F6, tests), no hay a dónde volver.
## `win_text` (RF-467): el texto de victoria del nivel, bajo las estrellas y antes de los puntos. Vacío = no se ve nada.
## `has_epilogue` (RF-471): es el último nivel de la campaña; en lugar de «Siguiente nivel» (que no existe) está «Epílogo».
func show_victory(lives_left: int, stars: int, has_next: bool, in_campaign: bool, score: int = 0, win_text: String = "",
		has_epilogue: bool = false) -> void:
	_title.text = Localization.t(&"end.victory")
	_stars.count = stars  # RF-93
	_stars.visible = true
	_title.add_theme_color_override("font_color", Color(1, 0.84, 0.3))
	_detail.text = Localization.t_fmt(&"end.lives_left", {"n": lives_left})
	_win_label.text = win_text
	_win_label.visible = win_text != ""
	_show_tips("")  # M70: los consejos son solo de la derrota
	_score_label.text = Localization.t_fmt(&"end.score", {"n": score})  # RF-190
	_epilogue_mode = has_epilogue
	_next_button.text = Localization.t(&"end.epilogue" if has_epilogue else &"end.next")
	_show_next = has_next or has_epilogue
	_show_levels = in_campaign
	_set_buttons_visible(true)
	visible = true


## `tower_tip` (M70, RF-630): los consejos de la derrota; "" = no se ve esa línea.
func show_defeat(wave: int, total_waves: int, in_campaign: bool, score: int = 0, tower_tip: String = "") -> void:
	_title.text = Localization.t(&"end.defeat")
	_stars.visible = false
	_title.add_theme_color_override("font_color", Color(1, 0.45, 0.45))
	_detail.text = Localization.t_fmt(&"end.reached_wave", {"wave": wave, "total": total_waves})
	_win_label.visible = false  # RF-467: no hay texto en la derrota
	_show_tips(tower_tip)
	_score_label.text = Localization.t_fmt(&"end.score", {"n": score})  # RF-190
	_epilogue_mode = false
	_next_button.text = Localization.t(&"end.next")
	_show_next = false
	_show_levels = in_campaign
	_set_buttons_visible(true)
	visible = true


## RF-191 y RF-192: pide iniciales. Los botones esperan hasta que se confirmen.
func ask_name(title: String, length: int, initial: String) -> void:
	_record_title.text = title
	_record_title.visible = true
	_table.visible = false
	_set_buttons_visible(false)
	_clear_entry()
	var entry: NameEntry = NameEntry.new().setup(length, initial)
	entry.confirmed.connect(_on_name_confirmed)
	_entry_slot.add_child(entry)


## El consejo visible ("" si no hay).
func tower_tip_text() -> String:
	return _tower_tip_label.text if _tower_tip_label.visible else ""


func _show_tips(tower_tip: String) -> void:
	_tower_tip_label.text = tower_tip
	_tower_tip_label.visible = tower_tip != ""


func _tip_label(color: Color) -> Label:
	var label: Label = _label(TIP_FONT_SIZE, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(TIP_WIDTH, 0)
	label.visible = false
	return label


## El texto de victoria que se ve ("" si no hay).
func win_text() -> String:
	return _win_label.text if _win_label.visible else ""


func is_asking_name() -> bool:
	return _entry_slot.get_child_count() > 0


## La entrada de iniciales que se está mostrando (null si no se pide ninguna).
func name_entry() -> NameEntry:
	return _entry_slot.get_child(0) as NameEntry if is_asking_name() else null


## RF-193: muestra una tabla de récords, con la fila `highlight` resaltada (-1 = ninguna).
func show_scores(title: String, table: Array, highlight: int = -1) -> void:
	_clear_entry()
	_record_title.text = title
	_record_title.visible = title != ""
	_table.show_scores(table, highlight)
	_table.visible = true
	_set_buttons_visible(true)


func _on_next_button_pressed() -> void:
	if _epilogue_mode:
		epilogue_pressed.emit()
	else:
		next_pressed.emit()


func _on_name_confirmed(name: String) -> void:
	_clear_entry()
	name_entered.emit(name)


func _clear_entry() -> void:
	for child: Node in _entry_slot.get_children():
		_entry_slot.remove_child(child)
		child.queue_free()


func _set_buttons_visible(on: bool) -> void:
	_retry_button.visible = on
	_next_button.visible = on and _show_next
	_levels_button.visible = on and _show_levels


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
