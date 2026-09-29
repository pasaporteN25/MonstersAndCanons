# Ajustes del nivel (spec §10.3, RF-214): nombre, oro, vidas y aumento de vida por oleada.
class_name SettingsPanel
extends EditorPanel

var _name_edit := LineEdit.new()
var _gold_spin: SpinBox
var _lives_spin: SpinBox
var _scale_spin: SpinBox


func _init() -> void:
	super()  # arma el recuadro y el título (no se llama solo cuando la clase hija tiene su _init)
	set_title("Ajustes del nivel")
	_name_edit.max_length = 30
	_name_edit.custom_minimum_size = Vector2(260, 0)
	# El nombre se guarda al terminar de escribir, no letra por letra (cada letra sería un paso de deshacer).
	_name_edit.text_submitted.connect(func(_text: String) -> void: _commit_name())
	_name_edit.focus_exited.connect(_commit_name)
	_gold_spin = _spin(0, 9999, 10, " de oro", func(value: float) -> void: draft.set_gold(int(value)))
	_lives_spin = _spin(1, 999, 1, " vidas", func(value: float) -> void: draft.set_lives(int(value)))
	_scale_spin = _spin(0, 300, 1, " %", func(value: float) -> void: draft.set_health_scale(int(value)))
	_scale_spin.tooltip_text = "Vida extra de los enemigos en cada oleada. 0 = usar el general (spec §7.4)."
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 10)
	for row: Array in [
		["Nombre", _name_edit], ["Oro inicial", _gold_spin], ["Vidas", _lives_spin],
		["Vida extra por oleada", _scale_spin],
	]:
		var label := Label.new()
		label.text = row[0]
		grid.add_child(label)
		grid.add_child(row[1])
	_body.add_child(grid)
	var note := _header("0 en la vida extra = usar el general del juego. Los niveles oficiales van de 10 % a 35 %.")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(380, 0)
	_body.add_child(note)


func _fill() -> void:
	_name_edit.text = draft.level_name()
	_gold_spin.set_value_no_signal(draft.gold())
	_lives_spin.set_value_no_signal(draft.lives())
	_scale_spin.set_value_no_signal(draft.health_scale())


## Para los tests y para el editor: aplica el nombre que hay escrito.
func _commit_name() -> void:
	if _filling or draft == null:
		return
	if _name_edit.text != draft.level_name():
		draft.set_level_name(_name_edit.text)
		edited.emit()


func name_edit() -> LineEdit:
	return _name_edit


func gold_spin() -> SpinBox:
	return _gold_spin


func lives_spin() -> SpinBox:
	return _lives_spin


func scale_spin() -> SpinBox:
	return _scale_spin
