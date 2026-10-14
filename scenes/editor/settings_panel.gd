# Ajustes del nivel (spec §10.3, RF-214, RF-434): nombre, oro, vidas, aumento de vida por oleada,
# demoledora disponible y torres que ofrece el mapa.
class_name SettingsPanel
extends EditorPanel

var _name_edit := LineEdit.new()
var _gold_spin: SpinBox
var _lives_spin: SpinBox
var _scale_spin: SpinBox
var _machine_check := CheckBox.new()
var _tower_box := GridContainer.new()
var _tower_checks: Dictionary = {}  # id de torre → CheckBox
var _default_towers_button := Button.new()
var _towers_note: Label
var _all_towers: Array[TowerData] = []


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
	_machine_check.text = "Demoledora disponible"
	_machine_check.tooltip_text = "El nivel habilita comprar la demoledora para despejar removibles (RF-411)."
	_machine_check.toggled.connect(func(on: bool) -> void:
		if not _filling and draft != null and draft.set_machine_enabled(on):
			edited.emit())
	_body.add_child(_machine_check)
	var towers_title := Label.new()
	towers_title.text = "Torres del mapa"
	towers_title.add_theme_color_override("font_color", TITLE_COLOR)
	_body.add_child(towers_title)
	_tower_box.columns = 2
	_tower_box.add_theme_constant_override("h_separation", 24)
	_body.add_child(_tower_box)
	_towers_note = _header("")
	_towers_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_towers_note.custom_minimum_size = Vector2(380, 0)
	_body.add_child(_towers_note)
	_default_towers_button.text = "Usar las de siempre"
	_default_towers_button.name = "DefaultTowersButton"
	_default_towers_button.pressed.connect(func() -> void:
		if draft != null and draft.use_default_towers():
			edited.emit()
			refresh())
	_body.add_child(_default_towers_button)


func _fill() -> void:
	_name_edit.text = draft.level_name()
	_gold_spin.set_value_no_signal(draft.gold())
	_lives_spin.set_value_no_signal(draft.lives())
	_scale_spin.set_value_no_signal(draft.health_scale())
	_machine_check.set_pressed_no_signal(draft.machine_enabled())
	_fill_towers()


## Las casillas de las torres se arman la primera vez que se llena el panel (cargar la lista de torres es lo más pesado).
func _fill_towers() -> void:
	if _tower_checks.is_empty():
		_all_towers = TowerOffer.canonical_towers()
		for tower: TowerData in _all_towers:
			var check := CheckBox.new()
			check.text = tower.display_name
			check.name = "Tower_" + String(tower.id)
			var id: String = String(tower.id)
			check.toggled.connect(func(on: bool) -> void:
				if _filling or draft == null:
					return
				if draft.set_tower_offered(id, on, _all_towers):
					edited.emit()
				refresh())  # si no se pudo (era la última), la casilla vuelve a como estaba
			_tower_box.add_child(check)
			_tower_checks[id] = check
	var offered: PackedStringArray = draft.offered_tower_ids(_all_towers)
	for id: String in _tower_checks:
		(_tower_checks[id] as CheckBox).set_pressed_no_signal(offered.has(id))
	_default_towers_button.disabled = not draft.has_tower_list()
	_towers_note.text = "El mapa ofrece solo las marcadas (RF-393). Tiene que quedar al menos una." if draft.has_tower_list() \
		else "Sin lista propia: se ofrecen las de siempre (las comunes más las de torres_extra). Marcar o desmarcar una arma la lista."


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


func machine_check() -> CheckBox:
	return _machine_check


func tower_check(id: String) -> CheckBox:
	return _tower_checks.get(id)


func default_towers_button() -> Button:
	return _default_towers_button
