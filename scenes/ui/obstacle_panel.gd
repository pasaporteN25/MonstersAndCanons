# Panel de un removible (RF-404, RF-405, RF-406, RF-407). Estilo hierro y bronce, igual que TowerPanel.
# Solo MUESTRA y AVISA: no cobra ni demuele (eso lo hace InfrastructureController).
class_name ObstaclePanel
extends PanelContainer

signal demolish_pressed(cell: Vector2i)
signal cancel_pressed

var _cell: Vector2i = InfrastructureController.NONE
var _title: Label
var _cost: Label
var _time: Label
var _reward: Label
var _note: Label
var _button: Button
var _cancel_mode: bool = false


func _ready() -> void:
	theme = preload("res://assets/ui/menu_theme.tres")
	add_theme_stylebox_override("panel", preload("res://assets/ui/game_panel_style.tres"))
	offset_left = 1000.0
	offset_top = 260.0
	offset_right = 1270.0
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	for side: String in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	margin.add_child(rows)
	_title = _label(rows, 18, Color(1, 0.84, 0.45))
	_cost = _label(rows, 14)
	_time = _label(rows, 14)
	_reward = _label(rows, 14)
	_note = _label(rows, 14, Color(1, 0.68, 0.35))
	_button = Button.new()
	_button.custom_minimum_size = Vector2(0, 36)
	_button.pressed.connect(_on_button_pressed)
	rows.add_child(_button)
	visible = false


func _label(parent: Control, size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label


## Muestra el removible `spec` (o se oculta si es null). `state` es el de `ObstacleField`; `busy`, si hay
## otro trabajo en curso; `seconds_left`, lo que falta si este es el que se está demoliendo.
func show_obstacle(spec: ObstacleSpec, state: ObstacleField.State, busy: bool, gold: int,
		seconds_left: float, recovered: bool, current_cost: int = -1, current_seconds: float = -1.0,
		machine_cost: int = -1) -> void:
	visible = spec != null
	if spec == null:
		_cell = InfrastructureController.NONE
		return
	_cell = spec.cell
	_title.text = ObstacleText.display_name(spec)
	var cost: int = spec.cost if current_cost < 0 else current_cost
	var seconds: float = spec.seconds if current_seconds < 0.0 else current_seconds
	_cost.text = ObstacleText.cost_line(cost)
	if machine_cost >= 0:
		_cost.text += "\nCon la demoledora: %d de oro" % machine_cost
	_time.text = ObstacleText.time_line(seconds)
	_reward.text = ObstacleText.reward_line(spec, recovered)
	_note.visible = false
	_cancel_mode = state == ObstacleField.State.WORKING
	if state == ObstacleField.State.WORKING:
		_cost.text = "Pagado: %d de oro" % cost
		_time.text = ObstacleText.seconds_left_line(seconds_left)
		_button.text = "Cancelar (devuelve %d)" % cost
		_button.disabled = false
		_button.tooltip_text = "Cancelar la demolición y recuperar todo el oro"
	elif busy:
		_note.visible = true
		_note.text = "Hay una demolición en curso"
		_button.text = "Demoler (%d)" % cost
		_button.disabled = true
		_button.tooltip_text = _note.text
	elif gold < cost:
		_button.text = ObstacleText.missing_gold(cost, gold)
		_button.disabled = true
		_button.tooltip_text = _button.text
	else:
		_button.text = "Demoler (%d)" % cost
		_button.disabled = false
		_button.tooltip_text = "Demoler"


func _on_button_pressed() -> void:
	if _cancel_mode:
		cancel_pressed.emit()
	else:
		demolish_pressed.emit(_cell)
