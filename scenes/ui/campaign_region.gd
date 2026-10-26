class_name CampaignRegion
extends Button
## Una región del mapa planetario (M72, RF-647, RF-648): un botón real para tener foco de teclado y clic, que
## dibuja su estado con forma, pictograma y color (el bloqueo y la presencia rebelde no dependen del color).
## M76, RF-688/RF-690: la región no atiende al puntero (`MOUSE_FILTER_IGNORE`): el clic o el toque los resuelve el lienzo
## de la vista, que solo **selecciona** y distingue el arrastre del toque. Si fuera un botón con puntero, Godot le daría
## el foco al apretar y arrastrar desde ella seleccionaría. Aquí queda el teclado: Enter emite `confirmed`.

signal confirmed(index: int)

## T515: el rótulo completo «N · Nombre» solo lo lleva la región elegida o con foco (una a la vez), así que puede ser más ancho
## que el de 82 px de antes sin pisarse con otro. El resto muestra solo el número dentro de la insignia (o bajo el candado).
const CAPTION_WIDTH: float = 150.0
const CAPTION_SIZE: int = 11
## Aire entre el rótulo y lo que lo rodea (aro de foco, insignias vecinas, bordes del lienzo).
const CAPTION_PAD: float = 2.0
const CAPTION_SHIFT_STEP: float = 6.0
## Radio con el que una insignia vecina (borde, halo) cuenta como obstáculo del rótulo.
const OBSTACLE_RADIUS: float = BADGE_EDGE + 3.0
const STAR_GOLD := Color("#f0d176")
const FOCUS_COLOR := Color("#ffffff")
## RF-550, RF-690: lado mínimo del área táctil en px lógicos.
const TOUCH_MIN: float = 56.0
## T474, RF-695: insignias de conquista V3 (aprobadas por Lucas). El disco del estado mide 19,5 px de radio; el borde exterior
## de la insignia llega a 26 px, dentro del área táctil de 56 px (el diámetro del borde es 52 px).
const BADGE_RADIUS: float = 19.5
const BADGE_EDGE: float = 26.0
## T502: distancia del aro de selección (31 px del centro) y del aro de foco (36 px) al borde de la insignia.
const SELECT_RING_GAP: float = 5.0
const FOCUS_RING_GAP: float = 10.0
## Lado lógico con el que se dibuja el SVG de 64×64 (1:1), sin depender de la escala con la que Godot lo rasterice.
const BADGE_TEXTURE_SIDE: float = 64.0
const LOCK_RADIUS: float = 18.0
const NUMBER_SIZE: int = 15
const NUMBER_SIZE_TWO_DIGITS: int = 14
const NUMBER_COLOR := Color("#fff7e6")
const NUMBER_OUTLINE := Color("#1c1620")
## T499: halo de «disponible». Radio entre el borde de la insignia (26) y el aro de selección (31); 24 rayitas de media
## separación, dorado claro. Es estático: sin animación (RF-710).
const HALO_RADIUS: float = BADGE_EDGE + 2.5
const HALO_WIDTH: float = 2.0
const HALO_DASHES: int = 24
const HALO_DASH_FRACTION: float = 0.5
const HALO_COLOR := Color("#ffdf8a")
const BADGES: Dictionary = {
	CampaignMap.Badge.REBEL: preload("res://assets/ui/campaign_badges/badge_rebel.svg"),
	CampaignMap.Badge.SPLIT: preload("res://assets/ui/campaign_badges/badge_split.svg"),
	CampaignMap.Badge.PLAYER: preload("res://assets/ui/campaign_badges/badge_player.svg"),
}

var index: int = 0
var state: CampaignMap.State = CampaignMap.State.LOCKED
var stars: int = 0
var level_name: String = ""
## RF-709/RF-710: una región de una zona sin descubrir no se dibuja, no recibe foco y no se puede inspeccionar.
var discovered: bool = true
var _selected: bool = false
var _hovered: bool = false
## T515: el lienzo donde vive (en su sistema de coordenadas) y lo que el rótulo no puede tapar (insignias y estrellas de las
## demás regiones). Lo informa la vista con `set_caption_context`; sin eso el rótulo va centrado debajo.
var _canvas_rect: Rect2 = Rect2()
var _obstacles: Array[Rect2] = []


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


## T515: dónde está el lienzo y qué ocupan las demás regiones, para poner el rótulo sin que se salga ni tape otra insignia.
func set_caption_context(canvas_rect: Rect2, obstacles: Array[Rect2]) -> void:
	_canvas_rect = canvas_rect
	_obstacles = obstacles
	queue_redraw()


## T515, RF-695: ¿lleva el rótulo completo «N · Nombre»? Solo la región elegida o con foco, y nunca una oculta (RF-710).
func shows_full_caption() -> bool:
	return discovered and (_selected or has_focus())


## T515: el texto bajo la insignia. Completo («N · Nombre») en la elegida o con foco; en las demás, vacío, salvo bajo el candado,
## que no tiene número adentro y lleva el número a secas.
func caption_text() -> String:
	if not discovered:
		return ""
	if shows_full_caption():
		return "%s · %s" % [CampaignMap.number_text(index), level_name]
	return CampaignMap.number_text(index) if state == CampaignMap.State.LOCKED else ""


## T515: el rectángulo del rótulo en el sistema del lienzo (vacío si no hay rótulo).
func caption_rect() -> Rect2:
	var text: String = caption_text()
	if text.is_empty():
		return Rect2()
	var font: Font = get_theme_default_font()
	var fitted: String = _fit(font, text)
	var box := Vector2(font.get_string_size(fitted, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_SIZE).x, font.get_height(CAPTION_SIZE))
	var locked: bool = state == CampaignMap.State.LOCKED
	return place_caption(box, position + size / 2.0, LOCK_RADIUS if locked else BADGE_EDGE, _canvas_rect, _obstacles)


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
	var locked: bool = state == CampaignMap.State.LOCKED
	# El aro de selección y el de foco rodean el borde de lo que se dibuja (la insignia llega a BADGE_EDGE).
	var edge: float = LOCK_RADIUS if locked else BADGE_EDGE
	if CampaignMap.has_halo(state):
		draw_halo(self, center)
	if _selected or _hovered:
		draw_arc(center, edge + SELECT_RING_GAP, 0.0, TAU, 40, Color("#f0cb70"), 2.0)
	if has_focus():
		draw_arc(center, edge + FOCUS_RING_GAP, 0.0, TAU, 48, FOCUS_COLOR, 3.0)
	draw_badge(self, state, index, center, font)
	if state == CampaignMap.State.REBEL or state == CampaignMap.State.TAKEN:
		_draw_stars(center + Vector2(0, -edge - 8.0))
	var text: String = caption_text()
	if not text.is_empty():
		var fitted: String = _fit(font, text)
		var rect: Rect2 = caption_rect()
		var caption_color: Color = Color("#a8aeaa") if locked and not shows_full_caption() else Color("#ffe4a0")
		var baseline: float = rect.position.y - position.y + font.get_ascent(CAPTION_SIZE)
		draw_string_outline(font, Vector2(rect.position.x - position.x, baseline), fitted, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_SIZE, 3, NUMBER_OUTLINE)
		draw_string(font, Vector2(rect.position.x - position.x, baseline), fitted, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_SIZE, caption_color)


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


## T515: lo que una región ocupa y un rótulo ajeno no puede tapar: su insignia (con el halo) y, si las lleva, sus estrellas.
static func obstacle_rects(center: Vector2, region_state: CampaignMap.State, region_stars: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var radius: float = LOCK_RADIUS if region_state == CampaignMap.State.LOCKED else OBSTACLE_RADIUS
	result.append(Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0))
	if region_state == CampaignMap.State.LOCKED:  # el número a secas que lleva bajo el candado
		result.append(Rect2(center + Vector2(-10.0, BADGE_EDGE + FOCUS_RING_GAP), Vector2(20.0, 16.0)))
	if region_state == CampaignMap.State.REBEL or region_state == CampaignMap.State.TAKEN:
		var width: float = 11.0 * maxi(region_stars - 1, 0) + 12.0
		result.append(Rect2(center + Vector2(-width / 2.0, -BADGE_EDGE - 14.0), Vector2(width, 12.0)))
	return result


## T515: dónde va un rótulo de tamaño `box` para la región de centro `center` (en el sistema del lienzo): centrado debajo del
## aro de foco; si ahí tapa a otra región o se sale de `bounds`, se corre de a pasos a los costados y, por último, se pone
## arriba de las estrellas. Si ningún sitio sirve, queda el menos malo (centrado debajo, adentro del lienzo).
static func place_caption(box: Vector2, center: Vector2, edge: float, bounds: Rect2, obstacles: Array[Rect2]) -> Rect2:
	var below_top: float = center.y + maxf(edge, BADGE_EDGE) + FOCUS_RING_GAP + CAPTION_PAD
	var above_top: float = center.y - BADGE_EDGE - 14.0 - CAPTION_PAD - box.y
	var reach: float = box.x / 2.0 + OBSTACLE_RADIUS
	for top: float in [below_top, above_top]:
		var shift: float = 0.0
		while shift <= reach:
			for sign_value: float in [1.0, -1.0]:
				var rect := Rect2(Vector2(center.x - box.x / 2.0 + sign_value * shift, top), box)
				if _caption_fits(rect, bounds, obstacles):
					return rect
			shift += CAPTION_SHIFT_STEP
	var fallback := Rect2(Vector2(center.x - box.x / 2.0, below_top), box)
	if bounds.size != Vector2.ZERO:
		fallback.position.x = clampf(fallback.position.x, bounds.position.x, bounds.end.x - box.x)
		fallback.position.y = clampf(fallback.position.y, bounds.position.y, bounds.end.y - box.y)
	return fallback


static func _caption_fits(rect: Rect2, bounds: Rect2, obstacles: Array[Rect2]) -> bool:
	if bounds.size != Vector2.ZERO and not bounds.encloses(rect):
		return false
	var padded: Rect2 = rect.grow(CAPTION_PAD)
	for obstacle: Rect2 in obstacles:
		if padded.intersects(obstacle):
			return false
	return true


## T474/T499/T501: lo que dibuja una región por dentro (el candado o la insignia V3 con su número), sin halo ni estrellas ni
## rótulo. Lo comparten el mapa y las tarjetas del selector para que los estados se vean igual; `unit` achica el dibujo
## completo (insignia, candado y número) para las tarjetas y vale 1 en el mapa.
static func draw_badge(canvas: CanvasItem, badge_state: CampaignMap.State, level_index: int, center: Vector2, font: Font, unit: float = 1.0) -> void:
	if badge_state == CampaignMap.State.LOCKED:
		draw_lock(canvas, center, LOCK_RADIUS * unit)
		return
	var badge: CampaignMap.Badge = CampaignMap.badge_of(badge_state)
	var side: Vector2 = Vector2(BADGE_TEXTURE_SIDE, BADGE_TEXTURE_SIDE) * unit
	canvas.draw_texture_rect(BADGES[badge], Rect2(center - side / 2.0, side), false)
	var number: String = CampaignMap.number_text(level_index)
	var number_size: int = roundi((NUMBER_SIZE_TWO_DIGITS if number.length() > 1 else NUMBER_SIZE) * unit)
	var origin: Vector2 = center + Vector2(-BADGE_RADIUS * unit, number_size * 0.36)
	canvas.draw_string_outline(font, origin, number, HORIZONTAL_ALIGNMENT_CENTER, BADGE_RADIUS * unit * 2.0, number_size, 3, NUMBER_OUTLINE)
	canvas.draw_string(font, origin, number, HORIZONTAL_ALIGNMENT_CENTER, BADGE_RADIUS * unit * 2.0, number_size, NUMBER_COLOR)


## T499, RF-695: los tramos del halo punteado de «disponible» como pares de ángulos (inicio, fin), en radianes. Son
## `HALO_DASHES` rayitas iguales con un hueco entre ellas: no es un círculo continuo (como la selección) ni gira (RF-710).
static func halo_dashes() -> Array[Vector2]:
	var result: Array[Vector2] = []
	var period: float = TAU / float(HALO_DASHES)
	for k: int in HALO_DASHES:
		result.append(Vector2(k * period, k * period + period * HALO_DASH_FRACTION))
	return result


## T499: dibuja el halo dorado punteado alrededor de una insignia de nivel disponible. Queda justo afuera del borde de la
## insignia (26 px) y adentro del aro de selección (r+5): ni lo tapa ni se confunde con él (continuo) ni con el foco (blanco).
static func draw_halo(canvas: CanvasItem, center: Vector2, unit: float = 1.0) -> void:
	for dash: Vector2 in halo_dashes():
		canvas.draw_arc(center, HALO_RADIUS * unit, dash.x, dash.y, 4, HALO_COLOR, HALO_WIDTH * maxf(unit, 0.75))


## El candado de una región bloqueada: no depende del color para distinguirse de las abiertas (RF-695).
static func draw_lock(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius, Color("#414b4b"))
	canvas.draw_arc(center, radius, 0.0, TAU, 40, Color("#222a2b"), 2.0)
	var body := Rect2(center + Vector2(-0.33, -0.05) * radius, Vector2(0.66, 0.5) * radius)
	canvas.draw_rect(body, Color("#555d5c"))
	canvas.draw_rect(body, Color("#b3b9b4"), false, 1.5)
	canvas.draw_arc(center + Vector2(0, -0.05) * radius, radius * 0.22, PI, TAU, 10, Color("#b3b9b4"), 1.7)
