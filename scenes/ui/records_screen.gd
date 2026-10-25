# Pantalla de récords (RF-195, RF-694): el top 5 de cada nivel (se cambia con ◄/► o las flechas) y
# el Salón de la fama. Arriba, un selector de fuente: la Campaña y cada modo instalado (Asedio, los propios),
# con sus propias tablas `modo_<modo>_<mapa>`; nunca se mezclan ni suman al Salón. Solo muestra: los récords
# los anota la pantalla final.
extends Control

const HALL_SUBTITLE: String = "Para quien ganó todos los niveles"
const HALL_EMPTY: String = "Todavía nadie ganó todos los niveles"

## RF-388: dónde se buscan los modos (los tests usan otras carpetas; se cambian ANTES de agregar la pantalla).
var modes_official_dir: String = ModePacks.OFFICIAL_DIR
var modes_user_dir: String = ModePacks.USER_DIR

var _index: int = 0
## RF-694: la fuente que se ve. 0 = Campaña; las siguientes, `_sources` (los modos, en el orden de RF-389).
var _source: int = 0
var _sources: Array[Dictionary] = []
var _table: ScoreTable
var _hall: HallOfFame

@onready var _mode_name: Label = %ModeName
@onready var _prev_mode_button: Button = %PrevModeButton
@onready var _next_mode_button: Button = %NextModeButton
@onready var _diagnosis: Label = %Diagnosis
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
	_prev_mode_button.pressed.connect(func() -> void: show_source(_source - 1))
	_next_mode_button.pressed.connect(func() -> void: show_source(_source + 1))
	_sources = RecordSources.from_modes(ModePacks.all(modes_official_dir, modes_user_dir))
	_hall_button.pressed.connect(open_hall_of_fame)
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	show_source(0)
	Audio.add_click_sounds(self)
	MenuTouch.attach(self)  # RF-550: botones de 56 px en el celular
	_back_button.grab_focus()


## RF-694: cuántas fuentes hay (la Campaña y los modos instalados).
func source_count() -> int:
	return 1 + _sources.size()


func current_source() -> int:
	return _source


## Nombre de la fuente `index` (0 = Campaña).
func source_name(index: int) -> String:
	return "Campaña" if index == 0 else String(_sources[index - 1]["name"])


## Pasa a otra fuente (da la vuelta) y vuelve a su primer mapa.
func show_source(index: int) -> void:
	_source = posmod(index, source_count())
	_prev_mode_button.disabled = source_count() <= 1
	_next_mode_button.disabled = source_count() <= 1
	show_level(0)


## Cuántos mapas tiene la fuente que se ve. Un modo con errores no tiene ninguno que mostrar.
func map_count() -> int:
	if _source == 0:
		return GameFlow.level_count()
	return (_sources[_source - 1]["maps"] as Array).size()


## El id de la tabla del mapa que se ve (`level_xx` en la Campaña, `modo_<modo>_<mapa>` en un modo);
## vacío si el modo o el mapa tienen errores.
func current_table_id() -> StringName:
	if _source == 0:
		return GameFlow.level(_index).id
	var maps: Array = _sources[_source - 1]["maps"]
	if _index >= maps.size():
		return &""
	return maps[_index]["table_id"]


## Muestra el top 5 del mapa `index` de la fuente actual (da la vuelta: después del último viene el primero).
func show_level(index: int) -> void:
	_mode_name.text = source_name(_source)
	_diagnosis.visible = false
	_table_panel.visible = true
	var count: int = map_count()
	if _source == 0:
		_index = posmod(index, count)
		var level: LevelData = GameFlow.level(_index)
		_level_name.text = "Nivel %d · %s" % [_index + 1, level.display_name]
		_table.show_scores(SaveManager.scores(level.id))
		return
	var source: Dictionary = _sources[_source - 1]
	var errors: PackedStringArray = source["errors"]
	if not errors.is_empty():
		# El modo no se pudo leer: se dice por qué y no se busca ningún registro.
		_index = 0
		_level_name.text = "Modo con errores"
		_table_panel.visible = false
		_diagnosis.text = errors[0]
		_diagnosis.visible = true
		return
	if count == 0:
		_index = 0
		_level_name.text = "Sin mapas"
		_table.show_scores([])
		return
	_index = posmod(index, count)
	var entry: Dictionary = (source["maps"] as Array)[_index]
	_level_name.text = entry["label"]
	if entry["table_id"] == &"":
		_table_panel.visible = false
		_diagnosis.text = entry["error"]
		_diagnosis.visible = true
	else:
		_table.show_scores(SaveManager.scores(entry["table_id"]))


func current_level_index() -> int:
	return _index


func table_rows() -> int:
	return _table.row_count()


func diagnosis_text() -> String:
	return _diagnosis.text if _diagnosis.visible else ""


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


## Esc (o "atrás" en Android, RF-142): cierra el Salón o vuelve al menú. Flechas: otro mapa; AvPág / RePág: otro modo.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		if is_hall_open():
			close_hall_of_fame()
		else:
			GameFlow.go_to_main_menu()
	elif not is_hall_open() and event.is_action_pressed("ui_page_down"):
		show_source(_source + 1)
	elif not is_hall_open() and event.is_action_pressed("ui_page_up"):
		show_source(_source - 1)
	elif not is_hall_open() and event.is_action_pressed("ui_left"):
		show_level(_index - 1)
	elif not is_hall_open() and event.is_action_pressed("ui_right"):
		show_level(_index + 1)
