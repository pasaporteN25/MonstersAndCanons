# El contenido de la pestaña «Infraestructura» (M53, RF-457): cuatro tarjetas (trabajo en curso,
# demoledora, extracción y recursos) en el espacio de la barra de abajo. Reemplaza al panel suelto
# de arriba a la derecha (`InfrastructurePanel`). No decide nada: no cobra ni habilita; avisa con
# señales y `Game` lo alimenta desde `InfrastructureController` (P6).
class_name InfrastructureTab
extends Control

signal buy_pressed
signal cancel_pressed
signal enable_pressed(cell: Vector2i)
## Se tocó el nombre de un punto de extracción: se elige en el mapa, como tocarlo allá (RF-458).
signal site_selected(cell: Vector2i)

## El espacio de la tarjeta, en el lienzo base: de x = 118 a 792 y casi el alto de la barra (RF-455).
const AREA := Rect2(118, 6, 674, 84)
## Cuántas fichas de extracción se ven a la vez (RF-457).
const VISIBLE_SITES: int = 3
const CARD_FONT: int = 13
const TITLE_COLOR := Color(1, 0.84, 0.45)
const MUTED_COLOR := Color(0.78, 0.76, 0.72)
const RESOURCE_COLOR := Color(0.62, 0.9, 0.55)
const GOLD_COLOR := Color(1, 0.84, 0.3)

var _row: HBoxContainer
var _job_card: PanelContainer
var _job_empty: Label
var _job_box: VBoxContainer
var _job_name: Label
var _job_bar: ProgressBar
var _job_left: Label
var _cancel_button: Button
var _machine_card: PanelContainer
var _machine_title: Label
var _machine_effect: Label
var _buy_button: Button
var _sites_card: PanelContainer
var _sites_box: VBoxContainer
var _prev_button: Button
var _next_button: Button
var _resources_card: PanelContainer
var _resources_label: Label
var _expected_label: Label

var _sites: Array[Dictionary] = []
var _gold: int = 0
var _first_site: int = 0
var _mobile_button_height: float = 0.0


func _ready() -> void:
	theme = preload("res://assets/ui/menu_theme.tres")
	position = AREA.position
	size = AREA.size
	_row = HBoxContainer.new()
	_row.name = "Cards"
	_row.size = AREA.size
	_row.add_theme_constant_override("separation", 6)
	add_child(_row)
	_build_job_card()
	_build_machine_card()
	_build_sites_card()
	_build_resources_card()
	_machine_card.visible = false
	_sites_card.visible = false
	_resources_card.visible = false
	clear_job()


# --- Armado de las tarjetas ---

func _card(card_name: String, ratio: float) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_stretch_ratio = ratio
	card.add_theme_stylebox_override("panel", _card_style())
	_row.add_child(card)
	return card


func _card_style() -> StyleBox:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.16, 0.19, 1)
	style.border_color = Color(0.52, 0.36, 0.17, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _label(parent: Control, color: Color = Color.WHITE, wrap: bool = false) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", CARD_FONT)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label


func _button(parent: Control, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, maxf(26.0, _mobile_button_height))
	button.add_theme_font_size_override("font_size", CARD_FONT)
	parent.add_child(button)
	return button


func set_mobile_touch_targets(height: float) -> void:
	_mobile_button_height = height
	custom_minimum_size.y = height
	_apply_mobile_touch_targets(self, height)


func _apply_mobile_touch_targets(node: Node, height: float) -> void:
	if node is Button:
		var button: Button = node as Button
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, height)
	if node is HBoxContainer or node is VBoxContainer:
		(node as BoxContainer).add_theme_constant_override("separation", 8)
	for child: Node in node.get_children():
		_apply_mobile_touch_targets(child, height)


func _build_job_card() -> void:
	_job_card = _card("JobCard", 1.3)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	_job_card.add_child(box)
	var title: Label = _label(box, TITLE_COLOR)
	title.text = "Trabajo en curso"
	_job_empty = _label(box, MUTED_COLOR, true)
	_job_empty.text = InfrastructureText.EMPTY_JOB
	_job_empty.add_theme_font_size_override("font_size", 12)
	_job_box = VBoxContainer.new()
	_job_box.add_theme_constant_override("separation", 1)
	box.add_child(_job_box)
	_job_name = _label(_job_box)
	_job_bar = ProgressBar.new()
	_job_bar.custom_minimum_size = Vector2(0, 10)
	_job_bar.max_value = 1.0
	_job_bar.show_percentage = false
	_job_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_job_box.add_child(_job_bar)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 6)
	_job_box.add_child(line)
	_job_left = _label(line)
	_job_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cancel_button = _button(line, "Cancelar")
	_cancel_button.custom_minimum_size = Vector2(70, 22)
	_cancel_button.tooltip_text = "Cancelar la demolición y recuperar todo el oro"
	_cancel_button.pressed.connect(cancel_pressed.emit)


func _build_machine_card() -> void:
	_machine_card = _card("MachineCard", 1.0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	_machine_card.add_child(box)
	_machine_title = _label(box, GOLD_COLOR)
	_machine_effect = _label(box, MUTED_COLOR, true)
	_machine_effect.add_theme_font_size_override("font_size", 12)
	_buy_button = _button(box, "Comprar")
	_buy_button.pressed.connect(buy_pressed.emit)


func _build_sites_card() -> void:
	_sites_card = _card("SitesCard", 1.5)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_sites_card.add_child(row)
	_sites_box = VBoxContainer.new()
	_sites_box.add_theme_constant_override("separation", 2)
	_sites_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_sites_box)
	var arrows := VBoxContainer.new()
	arrows.name = "Arrows"
	arrows.add_theme_constant_override("separation", 4)
	arrows.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(arrows)
	_prev_button = _button(arrows, "◀")
	_prev_button.custom_minimum_size = Vector2(30, 26)
	_prev_button.tooltip_text = "Puntos anteriores"
	_prev_button.pressed.connect(_scroll_sites.bind(-1))
	_next_button = _button(arrows, "▶")
	_next_button.custom_minimum_size = Vector2(30, 26)
	_next_button.tooltip_text = "Puntos siguientes"
	_next_button.pressed.connect(_scroll_sites.bind(1))


func _build_resources_card() -> void:
	_resources_card = _card("ResourcesCard", 0.7)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_resources_card.add_child(box)
	_resources_label = _label(box, RESOURCE_COLOR)
	_resources_label.add_theme_font_size_override("font_size", 16)
	_expected_label = _label(box, MUTED_COLOR, true)
	_expected_label.add_theme_font_size_override("font_size", 12)


# --- Lo que Game le da (RF-457) ---

## Tarjeta 1, con trabajo: el nombre, el avance (0 a 1) y lo que falta.
func show_job(job_name: String, fraction: float, seconds_left: float) -> void:
	_job_empty.visible = false
	_job_box.visible = true
	_job_name.text = job_name
	_job_bar.value = clampf(fraction, 0.0, 1.0)
	_job_left.text = InfrastructureText.job_left_line(seconds_left)


## Tarjeta 1, sin trabajo.
func clear_job() -> void:
	if _job_empty == null:
		return
	_job_empty.visible = true
	_job_box.visible = false


func has_job() -> bool:
	return _job_box != null and _job_box.visible


## Tarjeta 2: solo si el nivel habilita la demoledora (RF-411).
func show_machine(enabled: bool, owned: bool, price: int, gold: int, effect_text: String) -> void:
	_machine_card.visible = enabled
	if not enabled:
		return
	_machine_title.text = InfrastructureText.machine_title(price, owned)
	_machine_effect.text = effect_text if owned else ""
	_machine_effect.visible = owned
	_buy_button.visible = not owned
	_buy_button.text = InfrastructureText.buy_text(price, gold)
	_buy_button.disabled = gold < price
	_buy_button.tooltip_text = "Comprar la demoledora" if gold >= price else _buy_button.text


## Tarjeta 3: una ficha por punto (`InfrastructureText.sites`). Sin puntos, la tarjeta no se dibuja.
func show_sites(sites: Array[Dictionary], gold: int) -> void:
	_sites = sites
	_gold = gold
	_sites_card.visible = not sites.is_empty()
	_first_site = clampi(_first_site, 0, maxi(sites.size() - VISIBLE_SITES, 0))
	_rebuild_sites()


## Tarjeta 4: solo si el mapa usa recursos (RF-416).
func show_resources(enabled: bool, have: int, expected: int) -> void:
	_resources_card.visible = enabled
	if not enabled:
		return
	_resources_label.text = InfrastructureText.resources_line(have)
	var line: String = InfrastructureText.expected_line(expected)
	_expected_label.text = line
	_expected_label.visible = line != ""


func _scroll_sites(step: int) -> void:
	_first_site = clampi(_first_site + step, 0, maxi(_sites.size() - VISIBLE_SITES, 0))
	_rebuild_sites()


func _rebuild_sites() -> void:
	for old: Node in _sites_box.get_children():
		_sites_box.remove_child(old)
		old.queue_free()
	var arrows_needed: bool = _sites.size() > VISIBLE_SITES
	_prev_button.get_parent().visible = arrows_needed
	_prev_button.disabled = _first_site <= 0
	_next_button.disabled = _first_site >= _sites.size() - VISIBLE_SITES
	for i: int in range(_first_site, mini(_first_site + VISIBLE_SITES, _sites.size())):
		_sites_box.add_child(_site_row(_sites[i]))


func _site_row(site: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var cell: Vector2i = site["cell"]
	var state: ObstacleField.State = site["state"]
	var name_button := _button(row, String(site["kind_name"]))
	name_button.custom_minimum_size = Vector2(58, 24)
	name_button.tooltip_text = "Ver en el mapa"
	name_button.pressed.connect(site_selected.emit.bind(cell))
	var line: String = InfrastructureText.site_line(state, site["price"], site["reserve"], site["max_reserve"], site["production"])
	if state == ObstacleField.State.DISABLED:
		var enable := _button(row, line)
		enable.custom_minimum_size = Vector2(0, 24)
		enable.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		enable.disabled = _gold < int(site["price"])
		enable.tooltip_text = "Habilitar el punto" if not enable.disabled else InfrastructureText.buy_text(int(site["price"]), _gold)
		enable.pressed.connect(enable_pressed.emit.bind(cell))
	else:
		var label: Label = _label(row, Color.WHITE if state == ObstacleField.State.ACTIVE else MUTED_COLOR)
		label.text = line
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row
