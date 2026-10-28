# La presentación de un jefe a pantalla completa (M66, RF-666 a RF-673). Una capa que cubre toda la ventana y
# se anima por código sobre una ilustración quieta; no es el menú de pausa ni el cartel de entrada del nivel.
# Solo muestra y avisa (`closed`): quien la abre (`Game`) pausa la partida y decide si se reanuda (P6).
#
# COMPOSICIÓN PROVISIONAL: el arte de T367 (ilustración y fondo propios del Jefe, el Coloso y, más adelante, el
# jefe supremo del nivel 15 por T243/T463) todavía no está aprobado por Lucas. Mientras tanto la ilustración es el
# retrato que el enemigo ya tiene, sobre un fondo liso teñido con su color. Cuando haya arte se pasan `illustration`
# y `backdrop` a `setup()` sin tocar el movimiento, la pausa ni el salteo.
#
# Corre en tiempo real y con la partida pausada (`PROCESS_MODE_ALWAYS`): su reloj sale de `Time`, no de `delta`, así
# que ×2 no la acorta. Se saltea con cualquier tecla, clic o toque tras 0,3 s; `P` y «Atrás» la cierran sin reanudar.
# Todo se atiende en `_input`, antes que la partida: ninguna entrada le llega al juego mientras está abierta.
class_name BossPresentation
extends CanvasLayer

## Se cerró (por tiempo, por salteo o por `P`/«Atrás»). `keep_paused`: la partida debe quedar pausada (RF-669).
signal closed(keep_paused: bool)

const LAYER_ABOVE_DIALOGS: int = 30
const TITLE: String = "¡Llega el Jefe!"
const HINT_MOBILE: String = "Tocá para seguir"
const HINT_DESKTOP: String = "Clic o cualquier tecla para seguir  ·  P deja la pausa"
const FADE_IN_SECONDS: float = 0.25
## Cuánto de su alto ocupa la ilustración.
const ILLUSTRATION_HEIGHT_RATIO: float = 0.5

var _data: EnemyData
var _seconds: float = BossPresentationRules.REPEAT_SECONDS
var _mobile: bool = false
var _illustration_texture: Texture2D
var _backdrop_texture: Texture2D
var _started_ms: int = 0
var _closing: bool = false
var _close_keep_paused: bool = false
var _closing_ms: int = 0
var _done: bool = false
var _root: Control
var _illustration: TextureRect
var _hint: Label
var _tween: Tween


## `seconds`: RF-668. `illustration` y `backdrop`: el arte aprobado; null = la composición provisional.
func setup(data: EnemyData, seconds_: float, mobile: bool, illustration: Texture2D = null, backdrop: Texture2D = null) -> BossPresentation:
	_data = data
	_seconds = seconds_
	_mobile = mobile
	_illustration_texture = illustration if illustration != null else data.texture
	_backdrop_texture = backdrop
	return self


func _ready() -> void:
	layer = LAYER_ABOVE_DIALOGS
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_started_ms = Time.get_ticks_msec()
	_animate()


func _build() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP  # ni el clic ni el toque llegan a la partida
	add_child(_root)
	var base := ColorRect.new()
	base.name = "Backdrop"
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.color = Color(0.05, 0.04, 0.06).lerp(_data.color, 0.18)
	_root.add_child(base)
	if _backdrop_texture != null:
		var art := TextureRect.new()
		art.name = "BackdropArt"
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.texture = _backdrop_texture
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_root.add_child(art)
		_add_text_shade()
	var column := VBoxContainer.new()
	column.name = "Column"
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	_root.add_child(column)
	column.add_child(_label("Title", TITLE, 34, Color(0.95, 0.35, 0.28)))
	_illustration = TextureRect.new()
	_illustration.name = "Illustration"
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_illustration.texture = _illustration_texture
	_illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_illustration.custom_minimum_size = Vector2(0.0, 720.0 * ILLUSTRATION_HEIGHT_RATIO)
	column.add_child(_illustration)
	column.add_child(_label("Name", _data.display_name, 52, Color(0.96, 0.92, 0.82)))
	column.add_child(_label("Line", _data.description, 22, Color(0.85, 0.82, 0.76)))
	_hint = _label("Hint", HINT_MOBILE if _mobile else HINT_DESKTOP, 18, Color(0.7, 0.68, 0.64))
	_hint.modulate.a = 0.0
	column.add_child(_hint)


## T548: con un fondo pintado, una franja que se oscurece hacia abajo detrás del texto (color, alto y opacidad: `data/ui/boss_presentation.json`).
func _add_text_shade() -> void:
	var shade: Dictionary = BossPresentationArt.shade()
	var opacity: float = shade["opacidad"]
	var height: float = shade["alto"]
	if opacity <= 0.0 or height <= 0.0:
		return
	var color: Color = shade["color"]
	var gradient := Gradient.new()
	gradient.set_color(0, Color(color, 0.0))
	gradient.set_color(1, Color(color, opacity))
	gradient.add_point(0.55, Color(color, opacity * 0.6))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	texture.width = 4
	texture.height = 256
	var rect := TextureRect.new()
	rect.name = "TextShade"
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.anchor_left = 0.0
	rect.anchor_right = 1.0
	rect.anchor_top = 1.0 - height
	rect.anchor_bottom = 1.0
	rect.offset_left = 0.0
	rect.offset_right = 0.0
	rect.offset_top = 0.0
	rect.offset_bottom = 0.0
	_root.add_child(rect)


func _label(node_name: String, text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(900.0, 0.0)
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	return label


## Todo el movimiento sale de código: aparece, la ilustración crece despacio y se muestra la pista cuando ya se puede saltear.
func _animate() -> void:
	_root.modulate.a = 0.0
	_illustration.resized.connect(func() -> void: _illustration.pivot_offset = _illustration.size / 2.0)
	_illustration.scale = Vector2(0.9, 0.9)
	_tween = create_tween()  # sigue corriendo con la partida pausada: la capa es PROCESS_MODE_ALWAYS
	_tween.set_speed_scale(1.0 / maxf(Engine.time_scale, 0.01))  # tiempo real aunque la partida esté a ×2
	_tween.set_parallel(true)
	_tween.tween_property(_root, "modulate:a", 1.0, FADE_IN_SECONDS)
	_tween.tween_property(_illustration, "scale", Vector2(1.04, 1.04), _seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_hint, "modulate:a", 1.0, 0.2).set_delay(BossPresentationRules.SKIP_LOCK_SECONDS)
	_tween.tween_property(_root, "modulate:a", 0.0, BossPresentationRules.FADE_OUT_SECONDS) \
		.set_delay(maxf(_seconds - BossPresentationRules.FADE_OUT_SECONDS, FADE_IN_SECONDS))


func elapsed() -> float:
	return (Time.get_ticks_msec() - _started_ms) / 1000.0


## Para los tests: avanza el reloj sin esperar.
func advance_clock_for_test(seconds_: float) -> void:
	_started_ms -= int(seconds_ * 1000.0)
	if _closing:
		_closing_ms -= int(seconds_ * 1000.0)


func is_closing() -> bool:
	return _closing


func _process(_delta: float) -> void:
	if _done:
		return
	if _closing:
		if (Time.get_ticks_msec() - _closing_ms) / 1000.0 >= BossPresentationRules.FADE_OUT_SECONDS:
			_finish()
	elif elapsed() >= _seconds:
		_close_keep_paused = false
		_finish()


## Cierra con el fundido de 0,15 s (RF-669). `P` y «Atrás» piden dejar la partida en pausa.
func skip(keep_paused: bool) -> void:
	if _closing or _done:
		return
	_closing = true
	_close_keep_paused = keep_paused
	_closing_ms = Time.get_ticks_msec()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	create_tween().tween_property(_root, "modulate:a", 0.0, BossPresentationRules.FADE_OUT_SECONDS)


func _finish() -> void:
	if _done:
		return
	_done = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	closed.emit(_close_keep_paused)
	queue_free()


func _input(event: InputEvent) -> void:
	if _done:
		return
	var key := event as InputEventKey
	var click := event as InputEventMouseButton
	var pressed: bool = false
	if key != null:
		pressed = key.pressed and not key.echo
	elif click != null:
		pressed = click.pressed
	elif event is InputEventScreenTouch:
		pressed = (event as InputEventScreenTouch).pressed
	elif event.is_action_pressed("cancel"):  # el «atrás» de Android llega como acción
		pressed = true
	else:
		return
	get_viewport().set_input_as_handled()  # nada llega a la partida, ni dentro de los 0,3 s ni durante el fundido
	if not pressed or _closing or not BossPresentationRules.can_skip(elapsed()):
		return
	skip(event.is_action_pressed("pause") or event.is_action_pressed("cancel"))
