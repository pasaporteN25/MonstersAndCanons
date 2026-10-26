class_name CampaignMapView
extends Control
## El mapa planetario 2D de la campaña (M72, RF-647, RF-648; M76, RF-688 a RF-690). Dibuja la carta de Cántaro,
## el aterrizaje y 15 regiones sobre el atlas aprobado en `art/t485-atlas-biomas/` (ruta B; T471, antes T427/T428); es un atlas, no un
## mapa jugable. El lienzo (`MapCanvas`) vive dentro de un `ScrollContainer` que solo se desplaza en horizontal y
## solo si el lienzo no entra; la ficha y «Jugar» (`InfoPanel`) quedan fijas abajo, fuera del lienzo.
## No lee el guardado ni cambia de escena: recibe los datos de cada región con `setup()` y avisa con
## `level_requested` cuando se confirma una habilitada (P6: señales hacia arriba). Tocar o hacer clic solo selecciona.

signal level_requested(index: int)
signal selection_changed(index: int)

const VIEW_SIZE := Vector2(1090, 458)
const MAP_HEIGHT: float = 380.0
## T471: con las coordenadas del atlas aprobado, los marcadores 12 y 13 quedan a 49,3 unidades; para que las áreas
## táctiles de 56 px no se pisen (RF-690) el atlas se dibuja a esta escala (la mínima es 56 / 49,3 = 1,137). El lienzo es
## más ancho que la vista y se desplaza en horizontal; en vertical se muestra la franja del atlas que arranca en `MAP_TOP`.
const MAP_SCALE: float = 1.14
const MAP_TOP: float = 160.0
const CANVAS_SIZE := Vector2(CampaignMap.SEA_SIZE.x * MAP_SCALE, MAP_HEIGHT)
const PANEL_TOP: float = 386.0
const PANEL_HEIGHT: float = 72.0
## RF-550, RF-690: el área táctil de cada región mide al menos 56 px lógicos (el dibujo sigue siendo el aprobado).
const REGION_SIZE: float = 56.0
## Aire que se deja entre la región seleccionada y el borde al traerla a la vista.
const SCROLL_MARGIN: float = 24.0
const WHEEL_STEP: float = 80.0
const MAP_BACKGROUND: Texture2D = preload("res://assets/ui/campaign_map_background.svg")
const LAND_EDGE := Color("#2b2233")
const ROUTE_COLOR := Color("#e0bc6a")
const GOLD := Color("#efcf75")
const REBEL_BORDER := Color("#de805a")
const LOCKED_FILL := Color("#414b4b")
const TEXT_COLOR := Color("#f5f0df")
const MUTED_COLOR := Color("#b8bfba")
const FONT_SIZE: int = 12
## PROVISIONAL (T488, RF-710): tinte neutro con que se tapa el terreno de una zona sin descubrir. La máscara gris
## definitiva todavía no la aprobó Lucas (muestra en preparación, `feature/t469-muestra-insignias`); cuando la apruebe,
## se reemplaza `_draw_hidden_zones` por la máscara del arte y se borra esta constante.
const HIDDEN_ZONE_TINT_PLACEHOLDER := Color(0.55, 0.57, 0.58, 1.0)

var _entries: Array[Dictionary] = []
var _states: Array[CampaignMap.State] = []
## RF-709: por región, si su zona está descubierta. Se deriva de los estados (abierta = `unlocked`) en cada `setup()`.
var _discovered: Array[bool] = []
var _selected: int = 0
var _regions: Array[CampaignRegion] = []
var _name_label: Label
var _status_label: Label
var _play_button: Button
var _map_scroll: ScrollContainer
var _canvas: Control
var _panel: Panel
## El umbral de arrastre de un dedo es el que ya usa `MenuTouch`/`TouchScroller` (RF-551, RF-690).
var _drag_threshold: float = 12.0
var _press_region: CampaignRegion
var _press_dragged: bool = false
var _press_at: Vector2 = Vector2.ZERO
var _scale: float = MAP_SCALE
var _offset: Vector2 = Vector2(0.0, -(MAP_TOP - CampaignMap.SEA_ORIGIN.y) * MAP_SCALE)


func _init() -> void:
	custom_minimum_size = VIEW_SIZE
	size = VIEW_SIZE
	_drag_threshold = float(MobileUiConfig.load_from().get_value("scroll_umbral_px"))
	_build_canvas()
	_build_panel()  # antes de `setup()`, que ya necesita las etiquetas
	resized.connect(_layout)
	_layout()


## `entries`: una por nivel, en orden, con `name`, `place`, `stars` y `state` (`CampaignMap.State`).
## `selected` es la región que arranca marcada; -1 elige la que corresponde por defecto.
func setup(entries: Array[Dictionary], selected: int = -1) -> void:
	_entries = entries
	_states = []
	for entry: Dictionary in entries:
		_states.append(entry["state"])
	var unlocked: Array = []
	for state: CampaignMap.State in _states:
		unlocked.append(CampaignMap.is_open(state))
	_discovered = CampaignMap.discovered_regions(unlocked)
	for region: CampaignRegion in _regions:
		_canvas.remove_child(region)
		region.queue_free()
	_regions = []
	for i: int in mini(entries.size(), CampaignMap.REGION_COUNT):
		var region := CampaignRegion.new()
		region.name = "Region_%d" % i
		region.setup(i, entries[i], _map_point(CampaignMap.REGION_POINTS[i]), REGION_SIZE, _discovered[i])
		region.confirmed.connect(_request)  # Enter sobre la región enfocada
		if _discovered[i]:
			region.focus_entered.connect(select.bind(i))
		_canvas.add_child(region)
		_regions.append(region)
	# RF-688/RF-710: las flechas siguen el orden y saltan las regiones de zonas sin descubrir (que no admiten foco).
	var focusable: Array[int] = []
	for i: int in _regions.size():
		if _discovered[i]:
			focusable.append(i)
	for position_in_list: int in focusable.size():
		var current: CampaignRegion = _regions[focusable[position_in_list]]
		if position_in_list > 0:
			var previous: NodePath = NodePath("../Region_%d" % focusable[position_in_list - 1])
			current.focus_neighbor_left = previous
			current.focus_neighbor_top = previous
		if position_in_list < focusable.size() - 1:
			var next: NodePath = NodePath("../Region_%d" % focusable[position_in_list + 1])
			current.focus_neighbor_right = next
			current.focus_neighbor_bottom = next
	var start: int = CampaignMap.default_selection(_states) if selected < 0 else selected
	select(start if is_region_discovered(start) else CampaignMap.default_selection(_states))
	_canvas.queue_redraw()


func region(index: int) -> CampaignRegion:
	return _regions[index]


## ¿La zona de la región `index` está descubierta? (RF-709). Fuera de rango, no.
func is_region_discovered(index: int) -> bool:
	return index >= 0 and index < _discovered.size() and _discovered[index]


## Las regiones que admiten foco y selección, en orden (RF-710).
func focusable_indices() -> Array[int]:
	var result: Array[int] = []
	for i: int in _discovered.size():
		if _discovered[i]:
			result.append(i)
	return result


func region_count() -> int:
	return _regions.size()


func selected_index() -> int:
	return _selected


func map_scroll() -> ScrollContainer:
	return _map_scroll


func canvas() -> Control:
	return _canvas


func info_panel() -> Panel:
	return _panel


## ¿El lienzo no entra en el ancho disponible? Solo entonces hay desplazamiento horizontal (RF-690).
func overflows() -> bool:
	return _canvas.custom_minimum_size.x > _map_scroll.size.x + 0.5


func play_button() -> Button:
	return _play_button


func selection_name() -> String:
	return _name_label.text


func selection_status() -> String:
	return _status_label.text


## Marca una región y muestra su ficha. No abre nada (RF-648: cambiar el foco no inicia una partida).
func select(index: int) -> void:
	if _entries.is_empty() or not is_region_discovered(clampi(index, 0, _entries.size() - 1)):
		return  # RF-710: una región de zona sin descubrir no se selecciona
	_selected = clampi(index, 0, _entries.size() - 1)
	var entry: Dictionary = _entries[_selected]
	var state: CampaignMap.State = entry["state"]
	_name_label.text = "%02d · %s" % [_selected + 1, entry["name"]]
	_status_label.text = _status_line(entry)
	_play_button.disabled = not CampaignMap.is_open(state)  # «Jugar» siempre visible; bloqueada, deshabilitado
	for region_node: CampaignRegion in _regions:
		region_node.set_selected(region_node.index == _selected)
	selection_changed.emit(_selected)
	_ensure_selected_visible.call_deferred()


## Clic o toque en una región (RF-688): la marca y le da el foco, sin iniciar nada.
func pointer_select(index: int) -> void:
	if not is_region_discovered(index) or index >= _regions.size():
		return
	select(index)
	_regions[index].grab_focus()


## Confirma la región marcada: una bloqueada no se abre (RF-111, RF-648).
func request_selected() -> void:
	_request(_selected)


## Da el foco del teclado a la región marcada.
func focus_selected() -> void:
	if _selected < _regions.size():
		_regions[_selected].grab_focus()


func _request(index: int) -> void:
	if index < 0 or index >= _states.size() or not is_region_discovered(index) or not CampaignMap.is_open(_states[index]):
		return
	level_requested.emit(index)


func _status_line(entry: Dictionary) -> String:
	var state: CampaignMap.State = entry["state"]
	var text: String = CampaignMap.state_text(state)
	match state:
		CampaignMap.State.LOCKED:
			return "Ganá el nivel anterior para abrirla"  # RF-688: el candado ya dice que está bloqueada
		CampaignMap.State.AVAILABLE:
			return "%s · sin victorias todavía" % text
	return "%s · %d de 3 estrellas" % [text, int(entry["stars"])]


func _map_point(point: Vector2) -> Vector2:
	return _offset + (point - CampaignMap.SEA_ORIGIN) * _scale


## Trae la región marcada a la vista cuando el lienzo se desplaza (RF-690): al abrir, al cambiar el foco y al medirse.
func _ensure_selected_visible() -> void:
	if _selected >= _regions.size() or not overflows():
		return
	var box: Rect2 = _regions[_selected].get_rect()
	var left: float = box.position.x - SCROLL_MARGIN if _selected > 0 else 0.0  # la primera trae también el aterrizaje
	var right: float = box.end.x + SCROLL_MARGIN
	var current: float = _map_scroll.scroll_horizontal
	if left < current:
		_map_scroll.scroll_horizontal = maxi(int(left), 0)
	elif right > current + _map_scroll.size.x:
		_map_scroll.scroll_horizontal = int(ceil(right - _map_scroll.size.x))


## Acomoda el desplazable y la ficha al ancho actual: la ficha va fija abajo y no se desplaza con el lienzo.
func _layout() -> void:
	var width: float = size.x
	_map_scroll.position = Vector2.ZERO
	_map_scroll.size = Vector2(width, PANEL_TOP - 2.0)
	_panel.position = Vector2(0, PANEL_TOP)
	_panel.size = Vector2(width, PANEL_HEIGHT)
	_play_button.position.x = width - _play_button.size.x - 18.0
	var text_width: float = maxf(width - _play_button.size.x - 18.0 * 3.0, 80.0)
	_name_label.size.x = minf(text_width, 700.0)
	_status_label.size.x = minf(text_width, 760.0)
	_ensure_selected_visible.call_deferred()


func _build_canvas() -> void:
	_map_scroll = ScrollContainer.new()
	_map_scroll.name = "MapScroll"
	_map_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_map_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_map_scroll.follow_focus = true
	_map_scroll.get_h_scroll_bar().changed.connect(_ensure_selected_visible)  # al cambiar el rango (se midió o se redimensionó)
	add_child(_map_scroll)
	_canvas = Control.new()
	_canvas.name = "MapCanvas"
	_canvas.custom_minimum_size = CANVAS_SIZE
	_canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	_canvas.clip_contents = true  # el atlas es más alto que el lienzo: se recorta la franja que no se muestra
	_canvas.draw.connect(_draw_canvas)
	_canvas.mouse_exited.connect(_set_hover.bind(null))
	_canvas.gui_input.connect(_on_canvas_input)
	_map_scroll.add_child(_canvas)


## Puntero sobre el lienzo (RF-688, RF-690). Las regiones no reciben el puntero: acá se decide cuál se tocó, con el
## círculo inscrito de su área táctil. Un toque (o clic) selecciona al soltar sobre la misma región que se apretó; si
## el puntero se movió más que el umbral de `MenuTouch` (o `TouchScroller` lo mandó lejos al empezar a desplazar), era un
## arrastre y no selecciona. La rueda desplaza en horizontal cuando hay desborde.
func _on_canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var at: Vector2 = (event as InputEventMouseMotion).position
		_set_hover(_region_at(at))
		if _press_region != null and KineticScroll.is_drag(at.distance_to(_press_at), _drag_threshold):
			_press_dragged = true
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			_canvas.accept_event()
			if button.pressed:
				_press_region = _region_at(button.position)
				_press_at = button.position
				_press_dragged = false
			else:
				var target: CampaignRegion = _region_at(button.position)
				var tapped: bool = _press_region != null and not _press_dragged and target == _press_region
				_press_region = null
				_press_dragged = false
				if tapped:
					pointer_select(target.index)
		elif button.pressed and overflows() and (button.button_index == MOUSE_BUTTON_WHEEL_UP or button.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var direction: float = -1.0 if button.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
			_map_scroll.scroll_horizontal = maxi(int(_map_scroll.scroll_horizontal + direction * WHEEL_STEP), 0)
			_canvas.accept_event()


## La región cuyo círculo de toque contiene `at` (en coordenadas del lienzo); la más cercana si hubiera dos.
func _region_at(at: Vector2) -> CampaignRegion:
	var best: CampaignRegion = null
	var best_distance: float = INF
	for region_node: CampaignRegion in _regions:
		if not region_node.discovered:
			continue
		var distance: float = at.distance_to(region_node.position + region_node.size / 2.0)
		if distance <= region_node.size.x / 2.0 and distance < best_distance:
			best = region_node
			best_distance = distance
	return best


func _set_hover(region_node: CampaignRegion) -> void:
	for other: CampaignRegion in _regions:
		other.set_hovered(other == region_node)
	_canvas.tooltip_text = region_node.tooltip_text if region_node != null else ""


func _build_panel() -> void:
	_panel = Panel.new()
	_panel.name = "InfoPanel"
	_panel.position = Vector2(0, PANEL_TOP)
	_panel.size = Vector2(VIEW_SIZE.x, PANEL_HEIGHT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1b1d21")
	style.border_color = Color("#8a6038")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_name_label = _panel_label("SelectedName", 24, TEXT_COLOR, Rect2(18, 6, 700, 34))
	_status_label = _panel_label("SelectedStatus", 16, MUTED_COLOR, Rect2(18, 40, 760, 26))
	_panel.add_child(_name_label)
	_panel.add_child(_status_label)
	_play_button = Button.new()
	_play_button.name = "PlayButton"
	_play_button.text = "Jugar"
	_play_button.custom_minimum_size = Vector2(170, 56)
	_play_button.position = Vector2(VIEW_SIZE.x - 188, 8)
	_play_button.size = Vector2(170, 56)
	_play_button.add_theme_font_size_override("font_size", 20)
	_play_button.pressed.connect(request_selected)
	_panel.add_child(_play_button)


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


func _draw_canvas() -> void:
	var font: Font = _canvas.get_theme_default_font()
	var sea := Rect2(_offset, CampaignMap.SEA_SIZE * _scale)
	_canvas.draw_texture_rect(MAP_BACKGROUND, sea, false)
	_draw_hidden_zones()
	_draw_route()
	_draw_lander(font)
	_draw_legend(font)
	_draw_compass(font)
	_canvas.draw_string(font, Vector2(14, 22), "ATLAS MERIDIANO · CÁNTARO", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color("#dfd7bf"))


## RF-710: el terreno de las zonas sin descubrir se tapa con un tinte neutro. PROVISIONAL (ver
## `HIDDEN_ZONE_TINT_PLACEHOLDER`): corta la costa por la línea vertical a mitad de camino entre la última región de una
## zona y la primera de la siguiente; la máscara aprobada la reemplazará.
func _draw_hidden_zones() -> void:
	var first_hidden: int = -1
	for i: int in _discovered.size():
		if not _discovered[i]:
			first_hidden = i
			break
	if first_hidden < 0:
		return
	var split_x: float = (CampaignMap.REGION_POINTS[first_hidden - 1].x + CampaignMap.REGION_POINTS[first_hidden].x) / 2.0
	var east: float = CampaignMap.SEA_ORIGIN.x + CampaignMap.SEA_SIZE.x
	var south: float = CampaignMap.SEA_ORIGIN.y + CampaignMap.SEA_SIZE.y
	var cut := PackedVector2Array([Vector2(split_x, CampaignMap.SEA_ORIGIN.y), Vector2(east, CampaignMap.SEA_ORIGIN.y),
		Vector2(east, south), Vector2(split_x, south)])
	for piece: PackedVector2Array in Geometry2D.intersect_polygons(CampaignMap.land_polygon(), cut):
		if Geometry2D.is_polygon_clockwise(piece):
			continue  # un hueco de la costa (lago): no se tapa
		var mapped := PackedVector2Array()
		for point: Vector2 in piece:
			mapped.append(_map_point(point))
		_canvas.draw_colored_polygon(mapped, HIDDEN_ZONE_TINT_PLACEHOLDER)


## El recorrido arranca en el aterrizaje y sigue las curvas del atlas (`CampaignMap.route_polyline`); el tramo ya abierto
## se dibuja entero y el resto, tenue.
func _draw_route() -> void:
	for i: int in _regions.size():
		if not _discovered[i]:
			continue  # RF-710: el tramo hacia una región oculta no se adelanta
		var open: bool = CampaignMap.is_open(_states[i])
		var color: Color = ROUTE_COLOR if open else Color(ROUTE_COLOR, 0.28)
		var points := PackedVector2Array()
		for point: Vector2 in CampaignMap.route_polyline(i):
			points.append(_map_point(point))
		_draw_dashed_polyline(points, color, 2.0, 7.0, 5.0)


## Una línea de trazos que sigue una poligonal: los trazos no se reinician en cada vértice.
func _draw_dashed_polyline(points: PackedVector2Array, color: Color, width: float, dash: float, gap: float) -> void:
	var pen_down: bool = true
	var left: float = dash
	var current: Vector2 = points[0]
	for i: int in range(1, points.size()):
		var target: Vector2 = points[i]
		var remaining: float = current.distance_to(target)
		while remaining > 0.0:
			var step: float = minf(left, remaining)
			var next: Vector2 = current.move_toward(target, step)
			if pen_down:
				_canvas.draw_line(current, next, color, width)
			current = next
			remaining -= step
			left -= step
			if left <= 0.0:
				pen_down = not pen_down
				left = dash if pen_down else gap


func _draw_lander(font: Font) -> void:
	var center: Vector2 = _map_point(CampaignMap.LANDER)
	_canvas.draw_circle(center, 21.0, Color("#202226"))
	_canvas.draw_arc(center, 21.0, 0.0, TAU, 32, Color("#e1b45b"), 2.0)
	var hull := PackedVector2Array([Vector2(-8, 3), Vector2(-6, -5), Vector2(0, -9), Vector2(6, -5), Vector2(8, 3), Vector2(4, 7), Vector2(-4, 7)])
	for i: int in hull.size():
		hull[i] += center
	_canvas.draw_colored_polygon(hull, Color("#bd9a60"))
	_canvas.draw_polyline(hull + PackedVector2Array([hull[0]]), LAND_EDGE, 1.5)
	_canvas.draw_line(center + Vector2(-5, 6), center + Vector2(-9, 12), Color("#d2ad6a"), 2.0)
	_canvas.draw_line(center + Vector2(5, 6), center + Vector2(9, 12), Color("#d2ad6a"), 2.0)
	var label_rect := Rect2(center + Vector2(-44, 26), Vector2(88, 18))
	_canvas.draw_rect(label_rect, Color("#1d2022"))
	_canvas.draw_rect(label_rect, Color("#86623a"), false, 1.0)
	_canvas.draw_string(font, label_rect.position + Vector2(0, 13), "ATERRIZAJE", HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, 11, Color("#f4d98f"))


func _draw_compass(font: Font) -> void:
	var center: Vector2 = Vector2(CANVAS_SIZE.x - 40.0, CANVAS_SIZE.y - 42.0)  # el rincón del lienzo, siempre a la vista
	var radius: float = 19.0 * _scale
	_canvas.draw_circle(center, radius, Color("#22282b"))
	_canvas.draw_arc(center, radius, 0.0, TAU, 32, Color("#98a69c"), 1.5)
	_canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -13), center + Vector2(4, 0),
		center + Vector2(0, 12), center + Vector2(-4, 0)]), Color("#f0d176"))
	_canvas.draw_string(font, center + Vector2(-4, -radius - 5), "N", HORIZONTAL_ALIGNMENT_CENTER, 8, 10, Color("#dfd7bf"))


## La leyenda repite los pictogramas de las regiones: el estado no depende solo del color.
func _draw_legend(font: Font) -> void:
	var box := Rect2(CANVAS_SIZE.x - 232.0, 8.0, 214.0, 78.0)
	_canvas.draw_rect(box, Color(0.11, 0.125, 0.13, 0.94))
	_canvas.draw_rect(box, Color("#8a6038"), false, 1.5)
	var rows: Array[Array] = [
		[CampaignMap.State.TAKEN, "Tomada · 3 estrellas"],
		[CampaignMap.State.REBEL, "Rebeldes · 1–2 estrellas"],
		[CampaignMap.State.LOCKED, "Bloqueada"],
	]
	for i: int in rows.size():
		var y: float = box.position.y + 20.0 + i * 22.0
		CampaignRegion.draw_mark(_canvas, rows[i][0], Vector2(box.position.x + 18.0, y), 9.0, font)
		_canvas.draw_string(font, Vector2(box.position.x + 36.0, y + 4.0), rows[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT_COLOR)
