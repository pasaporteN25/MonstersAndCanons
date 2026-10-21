class_name CampaignMapView
extends Control
## El mapa planetario 2D de la campaña (M72, RF-647, RF-648). Dibuja la carta de Cántaro, el aterrizaje y 15
## regiones con el dibujo aprobado en `art/t427-mapa-propuesta/mapa.svg`; es un atlas, no un mapa jugable.
## No lee el guardado ni cambia de escena: recibe los datos de cada región con `setup()` y avisa con
## `level_requested` cuando se confirma una habilitada (P6: señales hacia arriba).

signal level_requested(index: int)
signal selection_changed(index: int)

const VIEW_SIZE := Vector2(1090, 458)
const MAP_HEIGHT: float = 380.0
const PANEL_TOP: float = 386.0
const PANEL_HEIGHT: float = 72.0
const REGION_SIZE: float = 44.0
const MAP_BACKGROUND: Texture2D = preload("res://assets/ui/campaign_map_background.svg")
const LAND_EDGE := Color("#2b2233")
const ROUTE_COLOR := Color("#e0bc6a")
const GOLD := Color("#efcf75")
const REBEL_BORDER := Color("#de805a")
const LOCKED_FILL := Color("#414b4b")
const TEXT_COLOR := Color("#f5f0df")
const MUTED_COLOR := Color("#b8bfba")
const FONT_SIZE: int = 12

var _entries: Array[Dictionary] = []
var _states: Array[CampaignMap.State] = []
var _selected: int = 0
var _regions: Array[CampaignRegion] = []
var _name_label: Label
var _status_label: Label
var _play_button: Button
var _scale: float = MAP_HEIGHT / CampaignMap.SEA_SIZE.y
var _offset: Vector2 = Vector2((VIEW_SIZE.x - CampaignMap.SEA_SIZE.x * (MAP_HEIGHT / CampaignMap.SEA_SIZE.y)) / 2.0, 0.0)


func _init() -> void:
	custom_minimum_size = VIEW_SIZE
	size = VIEW_SIZE
	_build_panel()  # antes de `setup()`, que ya necesita las etiquetas


## `entries`: una por nivel, en orden, con `name`, `place`, `stars` y `state` (`CampaignMap.State`).
## `selected` es la región que arranca marcada; -1 elige la que corresponde por defecto.
func setup(entries: Array[Dictionary], selected: int = -1) -> void:
	_entries = entries
	_states = []
	for entry: Dictionary in entries:
		_states.append(entry["state"])
	for region: CampaignRegion in _regions:
		remove_child(region)
		region.queue_free()
	_regions = []
	for i: int in mini(entries.size(), CampaignMap.REGION_COUNT):
		var region := CampaignRegion.new()
		region.name = "Region_%d" % i
		region.setup(i, entries[i], _map_point(CampaignMap.REGION_POINTS[i]), REGION_SIZE)
		region.pressed.connect(_on_region_pressed.bind(i))
		region.focus_entered.connect(select.bind(i))
		add_child(region)
		_regions.append(region)
	for i: int in _regions.size():
		if i > 0:
			_regions[i].focus_neighbor_left = NodePath("../Region_%d" % (i - 1))
		if i < _regions.size() - 1:
			_regions[i].focus_neighbor_right = NodePath("../Region_%d" % (i + 1))
	select(CampaignMap.default_selection(_states) if selected < 0 else selected)
	queue_redraw()


func region(index: int) -> CampaignRegion:
	return _regions[index]


func region_count() -> int:
	return _regions.size()


func selected_index() -> int:
	return _selected


func play_button() -> Button:
	return _play_button


func selection_name() -> String:
	return _name_label.text


func selection_status() -> String:
	return _status_label.text


## Marca una región y muestra su ficha. No abre nada (RF-648: cambiar el foco no inicia una partida).
func select(index: int) -> void:
	if _entries.is_empty():
		return
	_selected = clampi(index, 0, _entries.size() - 1)
	var entry: Dictionary = _entries[_selected]
	var state: CampaignMap.State = entry["state"]
	_name_label.text = "%02d · %s" % [_selected + 1, entry["name"]]
	_status_label.text = _status_line(entry)
	_play_button.disabled = not CampaignMap.is_open(state)
	_play_button.text = "Jugar" if CampaignMap.is_open(state) else "Bloqueada"
	for region_node: CampaignRegion in _regions:
		region_node.set_selected(region_node.index == _selected)
	selection_changed.emit(_selected)


## Confirma la región marcada: una bloqueada no se abre (RF-111, RF-648).
func request_selected() -> void:
	_request(_selected)


## Da el foco del teclado a la región marcada.
func focus_selected() -> void:
	if _selected < _regions.size():
		_regions[_selected].grab_focus()


func _on_region_pressed(index: int) -> void:
	select(index)
	_request(index)


func _request(index: int) -> void:
	if index < 0 or index >= _states.size() or not CampaignMap.is_open(_states[index]):
		return
	level_requested.emit(index)


func _status_line(entry: Dictionary) -> String:
	var state: CampaignMap.State = entry["state"]
	var text: String = CampaignMap.state_text(state)
	match state:
		CampaignMap.State.LOCKED:
			return "%s · ganá el nivel anterior para abrirla" % text
		CampaignMap.State.AVAILABLE:
			return "%s · sin victorias todavía" % text
	return "%s · %d de 3 estrellas" % [text, int(entry["stars"])]


func _map_point(point: Vector2) -> Vector2:
	return _offset + (point - CampaignMap.SEA_ORIGIN) * _scale


func _build_panel() -> void:
	var panel := Panel.new()
	panel.name = "InfoPanel"
	panel.position = Vector2(0, PANEL_TOP)
	panel.size = Vector2(VIEW_SIZE.x, PANEL_HEIGHT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1b1d21")
	style.border_color = Color("#8a6038")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_name_label = _panel_label("SelectedName", 24, TEXT_COLOR, Rect2(18, 6, 700, 34))
	_status_label = _panel_label("SelectedStatus", 16, MUTED_COLOR, Rect2(18, 40, 760, 26))
	panel.add_child(_name_label)
	panel.add_child(_status_label)
	_play_button = Button.new()
	_play_button.name = "PlayButton"
	_play_button.text = "Jugar"
	_play_button.custom_minimum_size = Vector2(170, 52)
	_play_button.position = Vector2(VIEW_SIZE.x - 188, 10)
	_play_button.size = Vector2(170, 52)
	_play_button.add_theme_font_size_override("font_size", 20)
	_play_button.pressed.connect(request_selected)
	panel.add_child(_play_button)


func _panel_label(label_name: String, font_size: int, color: Color, rect: Rect2) -> Label:
	var label := Label.new()
	label.name = label_name
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.position = rect.position
	label.size = rect.size
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _draw() -> void:
	var font: Font = get_theme_default_font()
	var sea := Rect2(_offset, CampaignMap.SEA_SIZE * _scale)
	draw_texture_rect(MAP_BACKGROUND, sea, false)
	_draw_route()
	_draw_lander(font)
	_draw_legend(font)
	_draw_compass(font)
	draw_string(font, _offset + Vector2(14, 22), "ATLAS MERIDIANO · CÁNTARO", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color("#dfd7bf"))


## El recorrido arranca en el aterrizaje; el tramo ya abierto se dibuja entero y el resto, tenue.
func _draw_route() -> void:
	var previous: Vector2 = _map_point(CampaignMap.LANDER)
	for i: int in _regions.size():
		var point: Vector2 = _map_point(CampaignMap.REGION_POINTS[i])
		var open: bool = CampaignMap.is_open(_states[i])
		var color: Color = ROUTE_COLOR if open else Color(ROUTE_COLOR, 0.28)
		draw_dashed_line(previous, point, color, 2.0, 7.0)
		previous = point


func _draw_lander(font: Font) -> void:
	var center: Vector2 = _map_point(CampaignMap.LANDER)
	draw_circle(center, 21.0, Color("#202226"))
	draw_arc(center, 21.0, 0.0, TAU, 32, Color("#e1b45b"), 2.0)
	var hull := PackedVector2Array([Vector2(-8, 3), Vector2(-6, -5), Vector2(0, -9), Vector2(6, -5), Vector2(8, 3), Vector2(4, 7), Vector2(-4, 7)])
	for i: int in hull.size():
		hull[i] += center
	draw_colored_polygon(hull, Color("#bd9a60"))
	draw_polyline(hull + PackedVector2Array([hull[0]]), LAND_EDGE, 1.5)
	draw_line(center + Vector2(-5, 6), center + Vector2(-9, 12), Color("#d2ad6a"), 2.0)
	draw_line(center + Vector2(5, 6), center + Vector2(9, 12), Color("#d2ad6a"), 2.0)
	var label_rect := Rect2(center + Vector2(-44, 26), Vector2(88, 18))
	draw_rect(label_rect, Color("#1d2022"))
	draw_rect(label_rect, Color("#86623a"), false, 1.0)
	draw_string(font, label_rect.position + Vector2(0, 13), "ATERRIZAJE", HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, 11, Color("#f4d98f"))


func _draw_compass(font: Font) -> void:
	var center: Vector2 = _map_point(Vector2(1207, 524))
	var radius: float = 19.0 * _scale
	draw_circle(center, radius, Color("#22282b"))
	draw_arc(center, radius, 0.0, TAU, 32, Color("#98a69c"), 1.5)
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -13), center + Vector2(4, 0),
		center + Vector2(0, 12), center + Vector2(-4, 0)]), Color("#f0d176"))
	draw_string(font, center + Vector2(-4, -radius - 5), "N", HORIZONTAL_ALIGNMENT_CENTER, 8, 10, Color("#dfd7bf"))


## La leyenda repite los pictogramas de las regiones: el estado no depende solo del color.
func _draw_legend(font: Font) -> void:
	var box := Rect2(VIEW_SIZE.x - 232.0, 8.0, 214.0, 78.0)
	draw_rect(box, Color(0.11, 0.125, 0.13, 0.94))
	draw_rect(box, Color("#8a6038"), false, 1.5)
	var rows: Array[Array] = [
		[CampaignMap.State.TAKEN, "Tomada · 3 estrellas"],
		[CampaignMap.State.REBEL, "Rebeldes · 1–2 estrellas"],
		[CampaignMap.State.LOCKED, "Bloqueada"],
	]
	for i: int in rows.size():
		var y: float = box.position.y + 20.0 + i * 22.0
		CampaignRegion.draw_mark(self, rows[i][0], Vector2(box.position.x + 18.0, y), 9.0, font)
		draw_string(font, Vector2(box.position.x + 36.0, y + 4.0), rows[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT_COLOR)
