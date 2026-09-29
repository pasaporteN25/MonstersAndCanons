# La Wiki (RF-230 a RF-232, D-035): solapas de categoría, lista de entradas y detalle.
# La pantalla NO sabe qué es un enemigo ni una torre: dibuja lo que le da `Wiki` (categorías →
# entradas → bloques). Agregar contenido nuevo no obliga a tocar este archivo.
extends Control

const GOLD: Color = Color(1, 0.84, 0.3)
const MUTED: Color = Color(0.72, 0.76, 0.84)
const LIST_WIDTH: float = 320.0
const ICON_BIG: float = 112.0
const ICON_SMALL: float = 40.0

## Se llama al salir (Volver o Esc). Es una "costura": los tests la reemplazan para no cambiar de pantalla.
var on_leave: Callable = GameFlow.go_to_main_menu

var _categories: Array[WikiCategory] = []
var _category: WikiCategory
var _entry: WikiEntry
var _tab_group := ButtonGroup.new()
var _entry_group := ButtonGroup.new()
var _tabs: HBoxContainer
var _list: VBoxContainer
var _list_scroll: ScrollContainer
var _detail: VBoxContainer
var _detail_scroll: ScrollContainer
var _back_button: Button
var _tab_buttons: Dictionary = {}
var _entry_buttons: Dictionary = {}


func _ready() -> void:
	_categories = Wiki.categories(GameFlow.campaign.levels)
	_build_layout()
	for category: WikiCategory in _categories:
		_add_tab(category)
	if not _categories.is_empty():
		show_category(_categories[0].id)
	Audio.add_click_sounds(self)
	_focus_first_entry()


# --- Lo que se puede consultar (los tests, y después un buscador o un enlace desde la partida) ---

func category_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for category: WikiCategory in _categories:
		ids.append(category.id)
	return ids


func entry_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	if _category != null:
		for entry: WikiEntry in _category.entries:
			ids.append(entry.id)
	return ids


func current_category() -> StringName:
	return _category.id if _category != null else &""


func current_entry() -> StringName:
	return _entry.id if _entry != null else &""


## Todo el texto que se ve en el detalle (títulos, párrafos, datos y tablas).
func detail_text() -> String:
	var parts: PackedStringArray = []
	for label: Node in _detail.find_children("*", "Label", true, false):
		parts.append((label as Label).text)
	return "\n".join(parts)


func tab_text(category_id: StringName) -> String:
	return (_tab_buttons[category_id] as Button).text if _tab_buttons.has(category_id) else ""


# --- Cambiar de categoría y de entrada ---

## Muestra una categoría y su primera entrada. Un id que no existe no hace nada.
func show_category(category_id: StringName) -> void:
	for category: WikiCategory in _categories:
		if category.id == category_id:
			_category = category
	if _category == null or _category.id != category_id:
		return
	(_tab_buttons[category_id] as Button).set_pressed_no_signal(true)
	_fill_list()
	if not _category.entries.is_empty():
		show_entry(_category.entries[0].id)


## Muestra una entrada de la categoría actual. Un id que no existe no hace nada.
func show_entry(entry_id: StringName) -> void:
	var entry: WikiEntry = _category.find(entry_id) if _category != null else null
	if entry == null:
		return
	_entry = entry
	var button: Button = _entry_buttons[entry_id]
	button.set_pressed_no_signal(true)
	_reveal.call_deferred(button)  # que la elegida no quede fuera de la lista
	_fill_detail(entry)


## Desplaza la lista hasta el botón (si todavía existe: la lista se puede haber rearmado).
func _reveal(button: Button) -> void:
	if is_instance_valid(button) and _list_scroll.is_ancestor_of(button):
		_list_scroll.ensure_control_visible(button)


## Abre la categoría y la entrada que se pidan (para enlazar desde otro lado, B-15).
func show_target(category_id: StringName, entry_id: StringName) -> void:
	show_category(category_id)
	show_entry(entry_id)


func _switch_category(step: int) -> void:
	if _categories.is_empty():
		return
	var index: int = _categories.find(_category)
	show_category(_categories[posmod(index + step, _categories.size())].id)
	_focus_first_entry()


func _focus_first_entry() -> void:
	if _category != null and not _category.entries.is_empty():
		(_entry_buttons[_category.entries[0].id] as Button).grab_focus()
	else:
		_back_button.grab_focus()


# --- Armar la pantalla ---

func _build_layout() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28 if side != "top" else 18)
	add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)

	var title := Label.new()
	title.text = "Wiki"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12))
	title.add_theme_constant_override("outline_size", 10)
	rows.add_child(title)

	_tabs = HBoxContainer.new()
	_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	_tabs.add_theme_constant_override("separation", 10)
	rows.add_child(_tabs)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	rows.add_child(body)

	var list_panel := _panel()
	list_panel.custom_minimum_size = Vector2(LIST_WIDTH, 0)
	body.add_child(list_panel)
	_list_scroll = _scroll()
	list_panel.add_child(_list_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	_list_scroll.add_child(_list)

	var detail_panel := _panel()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_panel)
	_detail_scroll = _scroll()
	detail_panel.add_child(_detail_scroll)
	_detail = VBoxContainer.new()
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 10)
	_detail_scroll.add_child(_detail)

	_back_button = Button.new()
	_back_button.text = "Volver"
	_back_button.custom_minimum_size = Vector2(220, 48)
	_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_back_button.add_theme_font_size_override("font_size", 22)
	_back_button.pressed.connect(_leave)
	rows.add_child(_back_button)


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style: StyleBoxFlat = (load("res://assets/ui/panel_style.tres") as StyleBoxFlat).duplicate()
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return panel


func _scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return scroll


func _add_tab(category: WikiCategory) -> void:
	var button := Button.new()
	button.text = category.title
	button.toggle_mode = true
	button.button_group = _tab_group
	button.focus_mode = Control.FOCUS_NONE  # ◄/► cambian de solapa; ▲/▼ recorren la lista
	button.custom_minimum_size = Vector2(150, 46)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(func() -> void:
		show_category(category.id)
		_focus_first_entry())
	_tabs.add_child(button)
	_tab_buttons[category.id] = button


func _fill_list() -> void:
	_clear(_list)
	_entry_buttons.clear()
	_list_scroll.scroll_vertical = 0
	for entry: WikiEntry in _category.entries:
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = _entry_group
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, ICON_SMALL + 14)
		button.pressed.connect(show_entry.bind(entry.id))
		button.focus_entered.connect(show_entry.bind(entry.id))  # con el teclado se ve el detalle al pasar
		var row := HBoxContainer.new()
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row.offset_left = 8
		row.offset_right = -8
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 10)
		button.add_child(row)
		if not entry.icon.is_empty():
			row.add_child(WikiIcon.new().setup(entry.icon, ICON_SMALL))
		var label := Label.new()
		label.text = entry.title
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS  # un título largo no se sale del botón
		label.tooltip_text = entry.title
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 21)
		row.add_child(label)
		_list.add_child(button)
		_entry_buttons[entry.id] = button
		Audio.add_click_sounds(button)


func _fill_detail(entry: WikiEntry) -> void:
	_clear(_detail)
	_detail_scroll.scroll_vertical = 0
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	_detail.add_child(header)
	if not entry.icon.is_empty():
		header.add_child(WikiIcon.new().setup(entry.icon, ICON_BIG))
	var names := VBoxContainer.new()
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(names)
	names.add_child(_label(entry.title, 36, GOLD))
	if entry.subtitle != "":
		names.add_child(_label(entry.subtitle, 20, MUTED))
	for block: Dictionary in entry.blocks:
		_add_block(block)


func _add_block(block: Dictionary) -> void:
	match block["tipo"]:
		WikiEntry.KIND_HEADING:
			var heading: Label = _label(block["texto"], 24, GOLD)
			heading.add_theme_constant_override("line_spacing", 0)
			_detail.add_child(_spaced(heading, 8))
		WikiEntry.KIND_TEXT:
			_detail.add_child(_wrapped(block["texto"], 19))
		WikiEntry.KIND_FACTS:
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation", 24)
			grid.add_theme_constant_override("v_separation", 4)
			for row: Array in block["filas"]:
				grid.add_child(_label(row[0], 19, MUTED))
				grid.add_child(_label(row[1], 19))
			_detail.add_child(grid)
		WikiEntry.KIND_TABLE:
			var rows: Array = block["filas"]
			var grid := GridContainer.new()
			grid.columns = (rows[0] as Array).size()
			grid.add_theme_constant_override("h_separation", 26)
			grid.add_theme_constant_override("v_separation", 4)
			for r: int in rows.size():
				for cell: String in rows[r]:
					grid.add_child(_label(cell, 19, GOLD if r == 0 else Color.WHITE))
			_detail.add_child(grid)


func _label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _wrapped(text: String, font_size: int) -> Label:
	var label: Label = _label(text, font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _spaced(node: Control, top: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", top)
	margin.add_child(node)
	return margin


func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


# --- Salir y teclado ---

func _leave() -> void:
	on_leave.call()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):  # Esc, o "atrás" en Android (RF-142)
		get_viewport().set_input_as_handled()
		_leave()
	elif event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		_switch_category(-1)
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		_switch_category(1)
