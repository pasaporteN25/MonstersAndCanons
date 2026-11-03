# La capa visual del tutorial del nivel 1 (M63, RF-574): una tarjeta con el texto del paso y, sobre el control o la
# casilla que hay que usar, un recuadro que parpadea con una flecha. Solo muestra y avisa (`next_pressed`,
# `skip_pressed`): qué paso toca y cuándo cambia lo decide `TutorialController` (P6).
#
# No bloquea nada: el recuadro y la flecha ignoran el mouse y los toques (pasan al control de abajo) y solo la
# tarjeta los recibe, para que un toque en «Siguiente» no llegue al mapa. La partida sigue corriendo.
#
# T574 (RF-739): en los pasos que piden una acción, además, se oscurece todo menos lo señalado (cuatro rectángulos
# que ignoran el mouse), un anillo se expande desde allí y un rótulo dice «Tocá acá» o «Hacé clic acá». Si lo
# señalado es un botón de los rieles (fuera del marco), el oscurecido cubre el marco entero y el anillo lo dibuja
# `SideRails`; acá solo queda un rótulo en el borde del marco, del lado de ese riel.
class_name TutorialOverlay
extends CanvasLayer

## Se tocó «Siguiente» (o «¡A jugar!») en un paso de lectura.
signal next_pressed
## Se tocó «Saltar tutorial».
signal skip_pressed

const CARD_STYLE: StyleBox = preload("res://assets/ui/game_panel_style.tres")
const MENU_THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const HIGHLIGHT_COLOR := Color(1.0, 0.82, 0.30)
const SHADE_COLOR := Color(0.0, 0.0, 0.0, 0.35)
const ARROW_SIZE: float = 26.0
const FRAME_GROW: float = 6.0
const FRAME_WIDTH: float = 4.0
const PULSE_SPEED: float = 5.0
const CARD_WIDTH_PX: float = 780.0
const TEXT_FONT_PC: int = 21
const TEXT_FONT_MOBILE: int = 22
const SMALL_FONT: int = 16
const LABEL_FONT: int = 22
## Alto mínimo de los botones: en el celular, el de los botones de la barra de arriba (`boton_alto_px`).
const BUTTON_HEIGHT_PC: float = 44.0

## De dónde sale lo que se señala (un `Callable` que devuelve `Array[Rect2]`, en coordenadas de pantalla). Se
## consulta en cada cuadro: el control puede moverse, el mapa tener zoom o el catálogo abrirse recién.
var targets_provider: Callable = Callable()
## T574: el rectángulo (en coordenadas del marco) del botón del riel que se señala, o vacío si no hay.
var rail_provider: Callable = Callable()
## Casillas que se pintan suaves (sin recuadro), como el camino; mismo formato que `targets_provider`.
var fills_provider: Callable = Callable()
## El área libre entre las barras, para ubicar la tarjeta. Lo pone quien lo crea.
var area: Rect2 = Rect2(0.0, 48.0, 1280.0, 576.0)
## La tarjeta puede apoyarse sobre la barra de abajo (cuando una sombra de pantalla entera ya la tapa).
var card_over_bottom_bar: bool = false
## T574: cuánto oscurece lo que no se señala (0 a 1), cuánto tarda cada anillo, la parte de la pantalla que puede
## ocupar lo iluminado y el rótulo del anillo. Salen de `data/tutorial/tutorial.json` (`TutorialData`).
var focus_darkness: float = 0.55
var focus_ring_seconds: float = 1.2
var focus_hole_max: float = 0.3
var focus_label: String = ""

var _mobile: bool = false
var _targets: Array[Rect2] = []
var _fills: Array[Rect2] = []
var _rail_rect: Rect2 = Rect2()
var _action_step: bool = false
var _hole: Rect2 = Rect2()
var _dimmed: bool = false
var _label_rects: Array[Rect2] = []
var _shades: Array[ColorRect] = []
var _last_card_size: Vector2 = Vector2.ZERO
var _frame: Control
var _card: PanelContainer
var _header: Label
var _text: Label
var _next_button: Button
var _skip_button: Button


func _ready() -> void:
	layer = 12  # sobre el HUD y el HUD celular (3); debajo del cartel, de la pausa y de los diálogos (20 y 21)
	process_mode = Node.PROCESS_MODE_ALWAYS  # también en pausa: el paso «Pausa» se hace en pausa
	_mobile = UiMode.is_mobile()
	_build_shades()
	_frame = Control.new()
	_frame.name = "Highlight"
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_frame.draw.connect(_draw_highlight)
	add_child(_frame)
	_build_card()
	visible = false


## Muestra el paso. `header` es el rótulo de arriba («Tutorial · Paso 3 de 14»); `reading` y `last` deciden si
## hay botón de avance y qué dice (`next_text` o `last_text`).
func show_step(header: String, text: String, reading: bool, last: bool, next_text: String, last_text: String,
		skip_text: String) -> void:
	_header.text = header
	_text.text = text
	_next_button.text = last_text if last else next_text
	_next_button.visible = reading
	_action_step = not reading
	_skip_button.text = skip_text
	visible = true
	_card.reset_size()
	_refresh_targets(true)


func hide_step() -> void:
	visible = false
	_targets = []
	_fills = []
	_rail_rect = Rect2()
	_label_rects = []
	_dimmed = false
	_hole = Rect2()
	_apply_shades()


## La tarjeta (para los tests y para ubicar otros avisos).
func card_rect() -> Rect2:
	return Rect2(_card.position, _card.size)


func targets() -> Array[Rect2]:
	return _targets


## T574: ¿el paso actual oscurece lo que no se señala?
func is_dimmed() -> bool:
	return visible and _dimmed


## T574: el agujero sin oscurecer (vacío si se oscurece todo el marco o no se oscurece nada).
func focus_hole() -> Rect2:
	return _hole


## T574: los cuatro rectángulos del oscurecido (arriba, abajo, izquierda, derecha) con su posición y tamaño actuales;
## uno que no se ve queda vacío.
func shade_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for shade: ColorRect in _shades:
		rects.append(Rect2(shade.position, shade.size) if shade.visible else Rect2())
	return rects


## T574: el rectángulo del botón del riel señalado, en coordenadas del marco (vacío si no hay).
func rail_target() -> Rect2:
	return _rail_rect


## T574: dónde quedó el rótulo del anillo (vacío si el paso no lo lleva).
func label_rects() -> Array[Rect2]:
	return _label_rects


func shade_nodes() -> Array[ColorRect]:
	return _shades


func card_text() -> String:
	return _text.text


func header_text() -> String:
	return _header.text


func next_button() -> Button:
	return _next_button


func skip_button() -> Button:
	return _skip_button


func is_next_visible() -> bool:
	return visible and _next_button.visible


func _process(_delta: float) -> void:
	if not visible:
		return
	_refresh_targets(false)
	if not _targets.is_empty() or not _fills.is_empty() or _rail_rect.size != Vector2.ZERO:
		_frame.queue_redraw()  # el parpadeo y los anillos


func _build_card() -> void:
	_card = PanelContainer.new()
	_card.name = "Card"
	_card.theme = MENU_THEME
	_card.add_theme_stylebox_override("panel", CARD_STYLE)
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	_card.custom_minimum_size.x = CARD_WIDTH_PX
	add_child(_card)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	_card.add_child(rows)
	var top := HBoxContainer.new()
	rows.add_child(top)
	_header = Label.new()
	_header.name = "Header"
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.add_theme_font_size_override("font_size", SMALL_FONT)
	_header.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
	top.add_child(_header)
	_skip_button = _make_button("SkipButton", SMALL_FONT + 2)
	_skip_button.pressed.connect(skip_pressed.emit)
	top.add_child(_skip_button)
	_text = Label.new()
	_text.name = "Text"
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size.x = CARD_WIDTH_PX - 40.0
	_text.add_theme_font_size_override("font_size", TEXT_FONT_MOBILE if _mobile else TEXT_FONT_PC)
	rows.add_child(_text)
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_END
	rows.add_child(bottom)
	_next_button = _make_button("NextButton", TEXT_FONT_PC)
	_next_button.pressed.connect(next_pressed.emit)
	bottom.add_child(_next_button)
	Audio.add_click_sounds(_card)


func _make_button(button_name: String, font_size: int) -> Button:
	var button := Button.new()
	button.name = button_name
	button.focus_mode = Control.FOCUS_NONE  # que Espacio y Enter sigan siendo del juego («Empezar oleada»)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", font_size)
	var height: float = BUTTON_HEIGHT_PC
	if _mobile:
		height = float(MobileUiConfig.load_from().get_value("boton_alto_px"))
	button.custom_minimum_size = Vector2(0.0, height)
	return button


## Vuelve a pedir lo que se señala y acomoda la tarjeta. Solo redibuja si algo cambió.
func _refresh_targets(force: bool) -> void:
	var fresh: Array[Rect2] = _rects_from(targets_provider)
	var fresh_fills: Array[Rect2] = _rects_from(fills_provider)
	var fresh_rail: Rect2 = _rail_from_provider()
	var moved: bool = fresh != _targets or fresh_fills != _fills or fresh_rail != _rail_rect or _card.size != _last_card_size
	_targets = fresh
	_fills = fresh_fills
	_rail_rect = fresh_rail
	_last_card_size = _card.size
	if moved or force:
		_update_focus()
		var screen := Rect2(Vector2.ZERO, Rules.SCREEN_SIZE)
		var avoid: Array[Rect2] = _targets.duplicate()
		avoid.append_array(_fills)
		_label_rects = []
		var label_rail: Rect2 = _rail_label_rect()
		if label_rail.size != Vector2.ZERO:
			avoid.append(label_rail)
		_card.position = TutorialLayout.card_rect(_card.size, avoid, area, screen, card_over_bottom_bar).position
		_place_labels(label_rail)
		_frame.queue_redraw()


func _rail_from_provider() -> Rect2:
	if rail_provider.is_valid():
		var raw: Variant = rail_provider.call()
		if raw is Rect2:
			return raw
	return Rect2()


## T574: decide si se oscurece y por dónde queda el agujero. Un paso de lectura no oscurece nada; uno de acción
## oscurece todo menos el agujero que cubre lo señalado (un solo agujero, no una máscara por casilla) o, si lo
## señalado es un botón del riel, el marco entero. Con un agujero que ocuparía demasiada pantalla no se oscurece.
func _update_focus() -> void:
	var screen := Rect2(Vector2.ZERO, Rules.SCREEN_SIZE)
	_hole = Rect2()
	_dimmed = false
	if _action_step and focus_darkness > 0.0:
		if _rail_rect.size != Vector2.ZERO:
			_dimmed = true  # el botón está fuera del marco: no hay agujero que dejar
		elif not _targets.is_empty():
			_hole = TutorialLayout.focus_hole(_targets, FRAME_GROW, screen, focus_hole_max)
			_dimmed = _hole.size != Vector2.ZERO
	_apply_shades()


func _apply_shades() -> void:
	var rects: Array[Rect2] = TutorialLayout.shade_rects(_hole, Rect2(Vector2.ZERO, Rules.SCREEN_SIZE))
	for i: int in _shades.size():
		var rect: Rect2 = rects[i]
		_shades[i].visible = _dimmed and rect.size.x > 0.0 and rect.size.y > 0.0
		_shades[i].position = rect.position
		_shades[i].size = rect.size
		_shades[i].color = Color(0.0, 0.0, 0.0, focus_darkness)


## El rótulo del botón del riel (vacío si el paso no apunta a un riel o no lleva rótulo).
func _rail_label_rect() -> Rect2:
	if not _action_step or focus_label.is_empty() or _rail_rect.size == Vector2.ZERO:
		return Rect2()
	return TutorialLayout.rail_label_rect(_label_size(), _rail_rect, Rect2(Vector2.ZERO, Rules.SCREEN_SIZE), ARROW_SIZE + 6.0)


func _place_labels(rail_label: Rect2) -> void:
	if not _action_step or focus_label.is_empty():
		return
	if rail_label.size != Vector2.ZERO:
		_label_rects.append(rail_label)
		return
	if _targets.is_empty():
		return
	var screen := Rect2(Vector2.ZERO, Rules.SCREEN_SIZE)
	# La tarjeta se acomoda sin tapar lo señalado; el rótulo va del lado opuesto a ella.
	_label_rects.append(TutorialLayout.label_rect(_label_size(), _targets[0].grow(FRAME_GROW), card_rect(), screen))


func _label_size() -> Vector2:
	var font: Font = ThemeDB.fallback_font
	var text_size: Vector2 = font.get_string_size(focus_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LABEL_FONT)
	return text_size + TutorialLayout.LABEL_PAD * 2.0


func _build_shades() -> void:
	for shade_name: String in ["ShadeTop", "ShadeBottom", "ShadeLeft", "ShadeRight"]:
		var shade := ColorRect.new()
		shade.name = shade_name
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE  # los toques pasan al control de abajo (RF-574)
		shade.visible = false
		add_child(shade)
		_shades.append(shade)


func _rects_from(provider: Callable) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if provider.is_valid():
		var raw: Variant = provider.call()
		if raw is Array:
			for item: Variant in raw:
				if item is Rect2 and (item as Rect2).size != Vector2.ZERO:
					rects.append(item)
	return rects


func _draw_highlight() -> void:
	var has_rail: bool = _rail_rect.size != Vector2.ZERO
	if _targets.is_empty() and _fills.is_empty() and not has_rail:
		return
	var pulse: float = 0.65 + 0.35 * sin(float(Time.get_ticks_msec()) / 1000.0 * PULSE_SPEED)
	var color := Color(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, pulse)
	for fill: Rect2 in _fills:
		_frame.draw_rect(fill, Color(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 0.28 + 0.14 * pulse))
	if _action_step:
		_draw_action_focus()
		return
	if _targets.is_empty():
		return
	for target: Rect2 in _targets:
		var frame: Rect2 = target.grow(FRAME_GROW)
		_frame.draw_rect(frame, SHADE_COLOR, false, FRAME_WIDTH + 6.0)
		_frame.draw_rect(frame, color, false, FRAME_WIDTH)
	var screen := Rect2(Vector2.ZERO, Rules.SCREEN_SIZE)
	var arrow: PackedVector2Array = TutorialLayout.arrow_points(_targets[0].grow(FRAME_GROW), card_rect(), ARROW_SIZE, screen)
	if arrow.size() == 3:
		_frame.draw_colored_polygon(arrow, color)


## T574: el marco quieto, dos anillos que se expanden desde cada recuadro (desfasados, así siempre hay uno
## naciendo) y el rótulo. El reloj es `Time`: la partida puede estar en pausa o a ×2.
func _draw_action_focus() -> void:
	var now: int = Time.get_ticks_msec()
	for target: Rect2 in _targets:
		var frame: Rect2 = target.grow(FRAME_GROW)
		_frame.draw_rect(frame, SHADE_COLOR, false, FRAME_WIDTH + 6.0)
		_frame.draw_rect(frame, HIGHLIGHT_COLOR, false, FRAME_WIDTH)
		for offset: float in [0.0, 0.5]:
			var phase: float = TutorialLayout.ring_phase(now + int(offset * focus_ring_seconds * 1000.0), focus_ring_seconds)
			var ring: Rect2 = frame.grow(TutorialLayout.RING_REACH * phase)
			_frame.draw_rect(ring, Color(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 1.0 - phase), false, FRAME_WIDTH)
	for label: Rect2 in _label_rects:
		_draw_label(label)


func _draw_label(rect: Rect2) -> void:
	_frame.draw_rect(rect, Color(0.10, 0.07, 0.04, 0.92))
	_frame.draw_rect(rect, HIGHLIGHT_COLOR, false, 2.0)
	var font: Font = ThemeDB.fallback_font
	var baseline := Vector2(rect.position.x + TutorialLayout.LABEL_PAD.x, rect.position.y + TutorialLayout.LABEL_PAD.y + font.get_ascent(LABEL_FONT))
	_frame.draw_string(font, baseline, focus_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LABEL_FONT, HIGHLIGHT_COLOR)
	if _rail_rect.size != Vector2.ZERO:
		# Una flecha hacia el riel, que queda fuera del marco: ocupa el hueco entre el rótulo y el borde.
		var on_left: bool = _rail_rect.get_center().x < Rules.SCREEN_SIZE.x / 2.0
		var cy: float = rect.get_center().y
		var tip_x: float = rect.position.x - ARROW_SIZE - 4.0 if on_left else rect.end.x + ARROW_SIZE + 4.0
		var base_x: float = rect.position.x - 4.0 if on_left else rect.end.x + 4.0
		var points := PackedVector2Array([Vector2(tip_x, cy), Vector2(base_x, cy - ARROW_SIZE * 0.5), Vector2(base_x, cy + ARROW_SIZE * 0.5)])
		_frame.draw_colored_polygon(points, HIGHLIGHT_COLOR)
