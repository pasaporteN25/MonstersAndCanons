# El cartel de aparición de un jefe (M66, RF-597, RF-598, RF-599): arriba del mapa, con el retrato del enemigo,
# «¡Llega el Jefe!», su nombre y su frase. Dura 1,6 s en velocidad normal (entra, queda quieto, sale) y un toque
# o un clic lo retira al instante. NO pausa ni bloquea nada: solo el cartel recibe toques (STOP en él, IGNORE
# en todo lo de adentro); el mapa de alrededor sigue recibiendo los suyos.
#
# Lo crea `Hud.show_boss_entrance` en el momento y se borra al terminar o al saltearse (cero costo fuera de la
# entrada, P7). Sin `_process`: un `Tween` hace todo, así que se congela con la pausa y acompaña la velocidad.
# Estilo hierro y bronce (RF-627, D-165): un fondo oscuro liso y encima el marco aprobado en T367 (9-slice de 32 px,
# centro transparente, que NO recibe toques). Los números salen de `data/ui/entrada_jefes.json`.
class_name BossEntranceCard
extends PanelContainer

## El cartel ya no está: terminó solo o se salteó.
signal finished

const CARD_STYLE: StyleBox = preload("res://assets/ui/game_panel_style.tres")
const FRAME: Texture2D = preload("res://assets/sprites/effects/jefe/boss_card_frame.png")
## Márgenes del 9-slice del marco (son los de la imagen) y lo que mide su banda visible: el contenido va adentro.
const FRAME_SLICE_PX: int = 32
const FRAME_BAND_PX: int = 18
const TITLE_COLOR := Color(1.0, 0.36, 0.3)
const NAME_COLOR := Color(1.0, 0.86, 0.5)
const TEXT_COLOR := Color(0.92, 0.92, 0.94)
const HINT_COLOR := Color(0.72, 0.74, 0.8)
## Cuánto sube al entrar, en píxeles.
const SLIDE_PX: float = 24.0
## Lo que se deja libre adentro del marco: a los lados pasa los remaches de las esquinas; arriba y abajo se mete un
## poco en la banda para que entren los tres rótulos en 120 px.
const PADDING_X_PX: int = 32
const PADDING_Y_PX: int = 12
const SKIP_HINT_PC: String = "Clic para saltear"
const SKIP_HINT_MOBILE: String = "Tocá para saltear"
const TITLE_FORMAT: String = "¡Llega el %s!"

var _config: BossEntranceConfig
var _mobile: bool = false
var _dismissed: bool = false
var _tween: Tween
var _portrait: Control
var _title: Label
var _name_label: Label
var _line: Label
var _hint: Label
var _close_mark: Label
var _frame: NinePatchRect


## Arma los nodos del cartel (8 en el celular, 9 en PC con la «✕», contando el margen y el marco): panel, retrato, tres rótulos, pista.
func setup(enemy: EnemyData, config: BossEntranceConfig, mobile: bool) -> BossEntranceCard:
	_config = config
	_mobile = mobile
	name = "BossEntranceCard"
	# RF-598: la interfaz sigue funcionando en pausa (RF-104), pero este cartel se congela con el mundo.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mouse_filter = Control.MOUSE_FILTER_STOP
	var width: int = config.pixels("cartel_ancho_px")
	var height: int = config.pixels("cartel_alto_px")
	custom_minimum_size = Vector2(width, height)
	size = Vector2(width, height)
	# Fondo liso: el del panel de hierro y bronce de siempre pero sin su borde (el borde lo pone el marco).
	var style: StyleBoxFlat = CARD_STYLE.duplicate() as StyleBoxFlat
	style.set_border_width_all(0)
	# Sin márgenes de contenido: el marco ocupa todo el cartel; los márgenes los pone el `MarginContainer` de abajo.
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	add_theme_stylebox_override("panel", style)
	clip_contents = true
	var inset := MarginContainer.new()
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.add_theme_constant_override("margin_left", PADDING_X_PX)
	inset.add_theme_constant_override("margin_right", PADDING_X_PX)
	inset.add_theme_constant_override("margin_top", PADDING_Y_PX)
	inset.add_theme_constant_override("margin_bottom", PADDING_Y_PX)
	add_child(inset)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	inset.add_child(row)
	var portrait_px: float = float(config.pixels("retrato_px"))
	if enemy.texture != null:
		var picture := TextureRect.new()
		picture.texture = enemy.texture
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
		_portrait = picture
	else:
		_portrait = EnemyIcon.new().setup(enemy)  # sin dibujo: la forma del enemigo, como en la tarjeta RF-134
	_portrait.custom_minimum_size = Vector2(portrait_px, portrait_px)
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_portrait)
	var texts := VBoxContainer.new()
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)
	_title = _label(TITLE_FORMAT % enemy.display_name, config.pixels("titulo_fuente_px"), TITLE_COLOR)
	_name_label = _label(enemy.display_name, config.pixels("nombre_fuente_px"), NAME_COLOR)
	_line = _label(BossEntranceRules.line_for(enemy), config.pixels("frase_fuente_px"), TEXT_COLOR)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.max_lines_visible = 2
	# Ancho fijo para que el texto se corte en líneas (si no, pediría una columna de una palabra y crecería el cartel).
	_line.custom_minimum_size.x = float(width) - 2.0 * PADDING_X_PX - portrait_px - 96.0 - 28.0
	_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	texts.add_child(_title)
	texts.add_child(_name_label)
	texts.add_child(_line)
	# A la derecha: la «✕» arriba (solo en PC, RF-599) y la pista de saltear abajo. Todo el cartel lo cierra igual.
	var side := VBoxContainer.new()
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side.custom_minimum_size.x = 96.0
	row.add_child(side)
	if not mobile:
		_close_mark = _label("✕", 16, HINT_COLOR)
		_close_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		side.add_child(_close_mark)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	_hint = _label(SKIP_HINT_MOBILE if mobile else SKIP_HINT_PC, config.pixels("pista_fuente_px"), HINT_COLOR)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size.x = 96.0  # sin ancho, el autowrap pediría una letra por línea
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	side.add_child(_hint)
	_frame = NinePatchRect.new()
	_frame.name = "Frame"
	_frame.texture = FRAME
	_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # sin mipmaps (RF-628)
	for edge: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		_frame.set_patch_margin(edge, FRAME_SLICE_PX)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)  # el último hijo se dibuja arriba del contenido
	gui_input.connect(_on_gui_input)
	return self


func _label(text: String, font_px: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_px)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 3)
	return label


## Lo ubica centrado arriba del mapa (`top` = y donde queda quieto) y empieza la animación.
func start(viewport_width: float, top: float) -> void:
	position = Vector2((viewport_width - size.x) / 2.0, top - SLIDE_PX)
	modulate.a = 0.0
	var enter_s: float = _config.seconds("cartel_entra_s")
	var hold_s: float = _config.seconds("cartel_quieto_s")
	var exit_s: float = _config.seconds("cartel_sale_s")
	_portrait.pivot_offset = _portrait.custom_minimum_size / 2.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, enter_s)
	_tween.parallel().tween_property(self, "position:y", top, enter_s).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# P-66-5: el retrato quieto con un pulso mientras el cartel está quieto.
	_tween.tween_property(_portrait, "scale", Vector2(1.08, 1.08), hold_s * 0.5)
	_tween.tween_property(_portrait, "scale", Vector2.ONE, hold_s * 0.5)
	_tween.tween_property(self, "modulate:a", 0.0, exit_s)
	_tween.finished.connect(_finish)


## RF-599: lo retira al instante, con un fundido corto. No cambia nada de la partida.
func dismiss() -> void:
	if _dismissed:
		return
	_dismissed = true
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, _config.seconds("salteo_s"))
	_tween.finished.connect(_finish)


func is_dismissed() -> bool:
	return _dismissed


func skip_hint() -> String:
	return _hint.text


func title_text() -> String:
	return _title.text


func name_text() -> String:
	return _name_label.text


func line_text() -> String:
	return _line.text


func has_frame() -> bool:
	return _frame != null and _frame.texture == FRAME


func has_close_mark() -> bool:
	return _close_mark != null


func _on_gui_input(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		accept_event()
		dismiss()


func _finish() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit()
	queue_free()
