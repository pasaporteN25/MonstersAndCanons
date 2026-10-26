class_name CampaignRegion
extends Button
## Una región del mapa planetario (M72, RF-647, RF-648): un botón real para tener foco de teclado y clic, que
## dibuja su estado con forma, pictograma y color (el bloqueo y la presencia rebelde no dependen del color).
## M76, RF-688/RF-690: la región no atiende al puntero (`MOUSE_FILTER_IGNORE`): el clic o el toque los resuelve el lienzo
## de la vista, que solo **selecciona** y distingue el arrastre del toque. Si fuera un botón con puntero, Godot le daría
## el foco al apretar y arrastrar desde ella seleccionaría. Aquí queda el teclado: Enter emite `confirmed`.

signal confirmed(index: int)

const CAPTION_WIDTH: float = 82.0
const CAPTION_SIZE: int = 11
const STAR_GOLD := Color("#f0d176")
const FOCUS_COLOR := Color("#ffffff")
## RF-550, RF-690: lado mínimo del área táctil en px lógicos.
const TOUCH_MIN: float = 56.0

var index: int = 0
var state: CampaignMap.State = CampaignMap.State.LOCKED
var stars: int = 0
var level_name: String = ""
## RF-709/RF-710: una región de una zona sin descubrir no se dibuja, no recibe foco y no se puede inspeccionar.
var discovered: bool = true
var _selected: bool = false
var _hovered: bool = false


func setup(region_index: int, entry: Dictionary, center: Vector2, button_size: float, is_discovered: bool = true) -> void:
	index = region_index
	discovered = is_discovered
	state = entry["state"]
	stars = int(entry["stars"])
	level_name = entry["name"]
	var side: float = maxf(button_size, TOUCH_MIN)
	size = Vector2(side, side)
	custom_minimum_size = size
	position = center - size / 2.0
	focus_mode = Control.FOCUS_ALL if discovered else Control.FOCUS_NONE
	if discovered:
		tooltip_text = "Nivel %d · %s · %s" % [index + 1, level_name, CampaignMap.state_text(state)]
		if state == CampaignMap.State.REBEL or state == CampaignMap.State.TAKEN:
			tooltip_text += " · %d de 3 estrellas" % stars
	# Todos los estados de dibujo propios son vacíos: el dibujo está en `_draw`; solo el foco usa un anillo.
	for style_name: String in ["normal", "hover", "pressed", "disabled", "hover_pressed", "focus"]:
		add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	# El anillo de foco se dibuja en `_draw`, ajustado al círculo (el área táctil es más grande que el dibujo).
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pressed.connect(func() -> void: confirmed.emit(index))  # Enter / ui_accept (sin repetición de tecla)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func set_selected(value: bool) -> void:
	_selected = value
	queue_redraw()


func set_hovered(value: bool) -> void:
	if _hovered != value:
		_hovered = value
		queue_redraw()


func _draw() -> void:
	if not discovered:
		return  # RF-710: ni número, ni candado, ni estrellas, ni rótulo
	var font: Font = get_theme_default_font()
	var center: Vector2 = size / 2.0
	var radius: float = 18.0 if state == CampaignMap.State.LOCKED else 19.0
	if _selected or _hovered:
		draw_arc(center, radius + 6.0, 0.0, TAU, 40, Color("#f0cb70"), 2.0)
	if has_focus():
		draw_arc(center, radius + 11.0, 0.0, TAU, 48, FOCUS_COLOR, 3.0)
	draw_mark(self, state, center, radius, font)
	if state == CampaignMap.State.AVAILABLE or state == CampaignMap.State.REBEL:
		var color: Color = Color("#25231f") if state == CampaignMap.State.AVAILABLE else Color("#fff1da")
		draw_string(font, center + Vector2(-radius, 5.0), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 15, color)
	if state == CampaignMap.State.REBEL or state == CampaignMap.State.TAKEN:
		_draw_stars(center + Vector2(0, -radius - 9.0))
	var caption: String = "%02d" % (index + 1) if state == CampaignMap.State.LOCKED else "%02d · %s" % [index + 1, level_name]
	var caption_color: Color = Color("#a8aeaa") if state == CampaignMap.State.LOCKED else Color("#ffe4a0")
	var fitted: String = _fit(font, caption)
	draw_string(font, center + Vector2(-CAPTION_WIDTH / 2.0, radius + 15.0), fitted, HORIZONTAL_ALIGNMENT_CENTER, CAPTION_WIDTH, CAPTION_SIZE, caption_color)


func _draw_stars(center: Vector2) -> void:
	var step: float = 11.0
	var first: float = -step * (stars - 1) / 2.0
	for i: int in stars:
		var at: Vector2 = center + Vector2(first + step * i, 0.0)
		var points := PackedVector2Array()
		for k: int in 10:
			var r: float = 6.0 if k % 2 == 0 else 2.6
			var angle: float = -PI / 2.0 + k * PI / 5.0
			points.append(at + Vector2(cos(angle), sin(angle)) * r)
		draw_colored_polygon(points, STAR_GOLD)


func _fit(font: Font, text: String) -> String:
	var result: String = text
	while result.length() > 1 and font.get_string_size(result, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_SIZE).x > CAPTION_WIDTH:
		result = result.left(result.length() - 1)
	return result + "…" if result != text else result


## El círculo y el pictograma de un estado. También lo usa la leyenda del mapa.
static func draw_mark(canvas: CanvasItem, mark_state: CampaignMap.State, center: Vector2, radius: float, _font: Font) -> void:
	match mark_state:
		CampaignMap.State.TAKEN:
			canvas.draw_circle(center, radius, Color("#26302a"))
			canvas.draw_arc(center, radius, 0.0, TAU, 40, Color("#efcf75"), 3.0)
			canvas.draw_circle(center, radius * 0.72, Color("#b99042"))
			canvas.draw_polyline(PackedVector2Array([center + Vector2(-0.35, 0.1) * radius, center + Vector2(-0.1, 0.4) * radius,
				center + Vector2(0.4, -0.25) * radius]), Color("#fff0bb"), maxf(radius * 0.16, 1.5))
		CampaignMap.State.REBEL:
			canvas.draw_circle(center, radius, Color("#302621"))
			for k: int in 12:
				var from_angle: float = k * TAU / 12.0
				canvas.draw_arc(center, radius, from_angle, from_angle + TAU / 20.0 * 1.6, 6, Color("#de805a"), 3.0)
			canvas.draw_circle(center, radius * 0.72, Color("#8e543c"))
			var pole: Vector2 = center + Vector2(0.62, -0.1) * radius
			canvas.draw_line(pole, pole + Vector2(0, -radius * 0.7), Color("#2b2233"), 2.0)
			canvas.draw_colored_polygon(PackedVector2Array([pole + Vector2(0, -radius * 0.7), pole + Vector2(radius * 0.5, -radius * 0.5),
				pole + Vector2(0, -radius * 0.3)]), Color("#df704d"))
		CampaignMap.State.AVAILABLE:
			canvas.draw_circle(center, radius, Color("#28323a"))
			canvas.draw_arc(center, radius, 0.0, TAU, 40, Color("#f0cb70"), 3.5)
			canvas.draw_circle(center, radius * 0.74, Color("#d39b43"))
		CampaignMap.State.LOCKED:
			canvas.draw_circle(center, radius, Color("#414b4b"))
			canvas.draw_arc(center, radius, 0.0, TAU, 40, Color("#222a2b"), 2.0)
			var body := Rect2(center + Vector2(-0.33, -0.05) * radius, Vector2(0.66, 0.5) * radius)
			canvas.draw_rect(body, Color("#555d5c"))
			canvas.draw_rect(body, Color("#b3b9b4"), false, 1.5)
			canvas.draw_arc(center + Vector2(0, -0.05) * radius, radius * 0.22, PI, TAU, 10, Color("#b3b9b4"), 1.7)
