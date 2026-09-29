# Pantalla de récords (RF-195): el top 5 de cada nivel (se cambia con ◄/► o las flechas) y
# el Salón de la fama. Solo muestra: los récords los anota la pantalla final.
extends Control

const HALL_SUBTITLE: String = "Para quien ganó todos los niveles"
const HALL_EMPTY: String = "Todavía nadie ganó todos los niveles"

var _index: int = 0
var _table: ScoreTable
var _hall: HallOfFame

@onready var _level_name: Label = %LevelName
@onready var _table_panel: PanelContainer = %TablePanel
@onready var _prev_button: Button = %PrevButton
@onready var _next_button: Button = %NextButton
@onready var _hall_button: Button = %HallButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	_table_panel.add_child(margin)
	_table = ScoreTable.new().setup(24)
	_table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	margin.add_child(_table)
	_prev_button.pressed.connect(func() -> void: show_level(_index - 1))
	_next_button.pressed.connect(func() -> void: show_level(_index + 1))
	_hall_button.pressed.connect(open_hall_of_fame)
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	show_level(0)
	Audio.add_click_sounds(self)
	_back_button.grab_focus()


## Muestra el top 5 del nivel `index` (da la vuelta: después del último viene el primero).
func show_level(index: int) -> void:
	_index = posmod(index, GameFlow.level_count())
	var level: LevelData = GameFlow.level(_index)
	_level_name.text = "Nivel %d · %s" % [_index + 1, level.display_name]
	_table.show_scores(SaveManager.scores(level.id))


func current_level_index() -> int:
	return _index


func table_rows() -> int:
	return _table.row_count()


## RF-194: el Salón de la fama, con su estética dorada, encima de esta pantalla.
func open_hall_of_fame() -> void:
	var entries: Array = GameFlow.hall_of_fame()
	_hall = HallOfFame.new()
	add_child(_hall)
	_hall.show_table(entries, -1, HALL_SUBTITLE if not entries.is_empty() else HALL_EMPTY)
	_hall.closed.connect(close_hall_of_fame)


func is_hall_open() -> bool:
	return _hall != null


func close_hall_of_fame() -> void:
	if _hall != null:
		_hall.queue_free()
		_hall = null


## Esc (o "atrás" en Android, RF-142): cierra el Salón o vuelve al menú. Flechas: otro nivel.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		if is_hall_open():
			close_hall_of_fame()
		else:
			GameFlow.go_to_main_menu()
	elif not is_hall_open() and event.is_action_pressed("ui_left"):
		show_level(_index - 1)
	elif not is_hall_open() and event.is_action_pressed("ui_right"):
		show_level(_index + 1)
