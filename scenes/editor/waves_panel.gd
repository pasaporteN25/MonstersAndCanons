# Oleadas del nivel (spec §10.3, RF-215): agregar, copiar y quitar oleadas y, en cada una, los grupos
# de enemigos (enemigo, cantidad, cada cuántos segundos, desde qué segundo y por qué entrada).
class_name WavesPanel
extends EditorPanel

const ENEMY_WIDTH: float = 170.0
const COUNT_WIDTH: float = 96.0
const SECONDS_WIDTH: float = 108.0
const ENTRANCE_WIDTH: float = 72.0
const REMOVE_WIDTH: float = 40.0
const GROUPS_HEIGHT: float = 300.0

var _wave: int = 0
## Los enemigos que se pueden elegir (todos los de data/enemies/), por nombre.
var _enemies: Array[EnemyData] = []

var _wave_label := Label.new()
var _total_label := Label.new()
var _groups_box := VBoxContainer.new()
var _rows: Array[Dictionary] = []
var _prev: Button
var _next: Button
var _remove: Button


func _init() -> void:
	super()  # arma el recuadro y el título (no se llama solo cuando la clase hija tiene su _init)
	set_title(Localization.t(&"editor.waves"))
	for id: String in LevelFile.enemy_ids():
		_enemies.append(LevelFile.find_enemy(id))
	_enemies.sort_custom(func(a: EnemyData, b: EnemyData) -> bool: return a.name_text() < b.name_text())

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	_prev = _button("◄", "Prev", func() -> void: show_wave(_wave - 1))
	_wave_label.custom_minimum_size = Vector2(150, 0)
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_next = _button("►", "Next", func() -> void: show_wave(_wave + 1))
	_remove = _button(Localization.t(&"editor.remove"), "RemoveWave", _remove_wave)
	for node: Control in [_prev, _wave_label, _next]:
		header.add_child(node)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	header.add_child(_button(Localization.t(&"editor.add"), "AddWave", _add_wave))
	header.add_child(_button(Localization.t(&"editor.copy"), "CopyWave", _copy_wave))
	header.add_child(_remove)
	_body.add_child(header)

	_total_label.add_theme_color_override("font_color", HEADER_COLOR)
	_body.add_child(_total_label)
	_body.add_child(_columns())
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, GROUPS_HEIGHT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_groups_box.add_theme_constant_override("separation", 6)
	_groups_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_groups_box)
	_body.add_child(scroll)
	_body.add_child(_button(Localization.t(&"editor.add_group"), "AddGroup", _add_group))


# --- Lo que se ve ---

## La oleada que se está editando (desde 0).
func current_wave() -> int:
	return _wave


func show_wave(index: int) -> void:
	_wave = clampi(index, 0, draft.wave_count() - 1)
	refresh()


func row_count() -> int:
	return _rows.size()


## Los controles de la fila `index`: enemy, count, every, from, entrance, remove.
func row(index: int) -> Dictionary:
	return _rows[index]


func total_text() -> String:
	return _total_label.text


func _fill() -> void:
	_wave = clampi(_wave, 0, draft.wave_count() - 1)
	_wave_label.text = Localization.t_fmt(&"editor.wave_of", {"n": _wave + 1, "total": draft.wave_count()})
	_prev.disabled = _wave == 0
	_next.disabled = _wave >= draft.wave_count() - 1
	_remove.disabled = draft.wave_count() <= 1  # RF-215: un nivel necesita al menos una oleada
	# RF-223: los topes. Con el máximo de oleadas o de grupos, agregar no hace nada.
	var full_waves: bool = draft.wave_count() >= LevelFile.MAX_WAVES
	(find_child("AddWave", true, false) as Button).disabled = full_waves
	(find_child("CopyWave", true, false) as Button).disabled = full_waves
	(find_child("AddGroup", true, false) as Button).disabled = draft.group_count(_wave) >= LevelFile.MAX_GROUPS
	for child: Node in _groups_box.get_children():
		_groups_box.remove_child(child)
		child.queue_free()
	_rows.clear()
	for g: int in draft.group_count(_wave):
		_add_row(g)
	_update_total()


func _update_total() -> void:
	_total_label.text = Localization.t_fmt(&"editor.wave_enemies", {"n": draft.enemy_total(_wave)})
	for i: int in draft.group_count(_wave):
		if float(draft.group(_wave,i)["probabilidad"]) < 1.0:
			_total_label.text += Localization.t(&"editor.wave_optional")
			break


## Los títulos de las columnas, del mismo ancho que los controles de abajo.
func _columns() -> Control:
	var row_box := HBoxContainer.new()
	row_box.add_theme_constant_override("separation", 8)
	for column: Array in [[Localization.t(&"editor.col_enemy"), ENEMY_WIDTH], [Localization.t(&"editor.col_count"), COUNT_WIDTH], [Localization.t(&"editor.col_every"), SECONDS_WIDTH],
			[Localization.t(&"editor.col_from"), SECONDS_WIDTH], [Localization.t(&"editor.tool.entrance"), ENTRANCE_WIDTH], [Localization.t(&"editor.col_chance"), COUNT_WIDTH], ["", REMOVE_WIDTH]]:
		var label := _header(column[0])
		label.custom_minimum_size = Vector2(column[1], 0)
		row_box.add_child(label)
	return row_box


func _add_row(g: int) -> void:
	var data: Dictionary = draft.group(_wave, g)
	var row_box := HBoxContainer.new()
	row_box.add_theme_constant_override("separation", 8)

	var enemy := OptionButton.new()
	enemy.custom_minimum_size = Vector2(ENEMY_WIDTH, 0)
	for e: EnemyData in _enemies:
		enemy.add_item(e.name_text())
		enemy.set_item_metadata(enemy.item_count - 1, String(e.id))
	var current: int = _enemy_index(enemy, data["enemigo"])
	if current < 0:
		# Un archivo con un enemigo que no existe: se muestra tal cual (el editor ya avisa el error).
		enemy.add_item(Localization.t_fmt(&"editor.enemy_missing", {"name": data["enemigo"]}))
		enemy.set_item_metadata(enemy.item_count - 1, data["enemigo"])
		current = enemy.item_count - 1
	enemy.select(current)
	enemy.item_selected.connect(func(index: int) -> void:
		if not _filling:
			draft.set_group(_wave, g, "enemigo", enemy.get_item_metadata(index))
			edited.emit())

	var count: SpinBox = _spin(0, 999, 1, "", func(value: float) -> void:
		draft.set_group(_wave, g, "cantidad", int(value))
		_update_total())
	count.custom_minimum_size = Vector2(COUNT_WIDTH, 0)
	count.set_value_no_signal(data["cantidad"])
	var every: SpinBox = _spin(0, 60, 0.05, " s", func(value: float) -> void:
		draft.set_group(_wave, g, "cada", value))
	every.custom_minimum_size = Vector2(SECONDS_WIDTH, 0)
	every.set_value_no_signal(data["cada"])
	var from: SpinBox = _spin(0, 600, 0.5, " s", func(value: float) -> void:
		draft.set_group(_wave, g, "desde", value))
	from.custom_minimum_size = Vector2(SECONDS_WIDTH, 0)
	from.set_value_no_signal(data["desde"])

	var entrance := OptionButton.new()
	entrance.custom_minimum_size = Vector2(ENTRANCE_WIDTH, 0)
	var used: int = MapGrid.ENTRANCE_LETTERS.find(data["entrada"])
	for i: int in maxi(maxi(draft.entrance_count(), 1), used + 1):
		entrance.add_item(MapGrid.ENTRANCE_LETTERS[i])
	entrance.select(maxi(used, 0))
	entrance.item_selected.connect(func(index: int) -> void:
		if not _filling:
			draft.set_group(_wave, g, "entrada", MapGrid.ENTRANCE_LETTERS[index])
			edited.emit())

	var chance: SpinBox = _spin(0, 100, 1, " %", func(value: float) -> void:
		draft.set_group(_wave, g, "probabilidad", value / 100.0))
	chance.custom_minimum_size = Vector2(COUNT_WIDTH, 0)
	chance.set_value_no_signal(float(data["probabilidad"]) * 100.0)
	chance.tooltip_text = Localization.t(&"editor.chance_tip")
	var remove: Button = _button("×", "", func() -> void:
		draft.remove_group(_wave, g)
		refresh()
		edited.emit())
	remove.custom_minimum_size = Vector2(REMOVE_WIDTH, 0)
	remove.tooltip_text = Localization.t(&"editor.remove_group_tip")

	for node: Control in [enemy, count, every, from, entrance, chance, remove]:
		row_box.add_child(node)
	_groups_box.add_child(row_box)
	_rows.append({"enemy": enemy, "count": count, "every": every, "from": from, "entrance": entrance, "chance": chance, "remove": remove})


func _enemy_index(option: OptionButton, id: String) -> int:
	for i: int in option.item_count:
		if option.get_item_metadata(i) == id:
			return i
	return -1


# --- Oleadas y grupos ---

func _add_wave() -> void:
	var index: int = draft.add_wave()
	if index < 0:
		return  # RF-223: ya hay el máximo de oleadas
	_wave = index
	refresh()
	edited.emit()


func _copy_wave() -> void:
	var index: int = draft.duplicate_wave(_wave)
	if index < 0:
		return
	_wave = index
	refresh()
	edited.emit()


func _remove_wave() -> void:
	if draft.remove_wave(_wave):
		refresh()
		edited.emit()


func _add_group() -> void:
	draft.add_group(_wave)
	refresh()
	edited.emit()


func _button(text: String, node_name: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.name = node_name if node_name != "" else "Button"
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	return button
