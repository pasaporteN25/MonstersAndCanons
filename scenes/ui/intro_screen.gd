# La intro (M57, RF-499): las láminas de `data/intro/intro.json` a pantalla completa, una tras otra, con el
# texto en una franja de abajo (mismo estilo de hierro y bronce que el epílogo) y un fundido entre una y otra.
# Avanza con un toque o clic, `Espacio`, `Enter` o `→`, y sola cuando pasan los segundos de la lámina.
# «Omitir», `Esc` y el «atrás» de Android la terminan entera. No pide confirmación.
#
# Solo muestra y avisa (P6): emite `finished` UNA sola vez y no sabe a dónde se va después (eso lo decide quien
# la abre: el menú desde «Jugar», la Wiki desde «Ver la intro»). Todo se atiende en `_input`, antes que el resto
# (como `LevelIntro`): `Esc` no llega a la pantalla de atrás y el clic que termina o omite se traga al apretar y
# actúa al soltar, así no construye ni elige nada en la pantalla siguiente.
#
# El tiempo corre con `advance(delta)`: `_process` lo llama con el delta real; los tests ponen `manual_clock`
# y lo llaman a mano (un reloj inyectado, sin esperar).
class_name IntroScreen
extends CanvasLayer

## La intro terminó (última lámina, «Omitir», `Esc` o «atrás»). Sale una sola vez por cada apertura.
signal finished

const SKIP_TEXT: String = "Omitir"
const TEXT_COLOR := Color(0.96, 0.94, 0.88)
const STRIP_COLOR := Color(0.04, 0.045, 0.06, 0.78)
const BACKDROP_COLOR := Color(0.02, 0.02, 0.03, 0.94)
const THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const TEXT_FONT_SIZE: int = 22
const SKIP_SIZE := Vector2(220, 52)
const SCREEN_MARGIN: float = 24.0

## Los tests lo prenden y llaman a `advance()` a mano.
var manual_clock: bool = false

var _slides: Array[Dictionary] = []
var _fade_s: float = 0.0
var _index: int = 0
var _elapsed: float = 0.0     # segundos que lleva la lámina (sin contar el fundido que la trajo)
var _fade_t: float = 0.0
var _fading: bool = false
var _open: bool = false
var _textures: Dictionary = {}  # {índice → Texture2D}: solo la actual y la anterior
var _root: Control
var _previous_image: TextureRect
var _current_image: TextureRect
var _text: Label
var _skip_button: Button


func _init() -> void:
	layer = 25  # encima del menú, la Wiki y las opciones
	visible = false
	_root = Control.new()
	_root.theme = THEME
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var backdrop := ColorRect.new()
	backdrop.color = BACKDROP_COLOR
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(backdrop)
	_previous_image = _make_image()
	_current_image = _make_image()
	var strip := PanelContainer.new()
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.grow_vertical = Control.GROW_DIRECTION_BEGIN  # crece hacia arriba con las líneas del texto
	var style := StyleBoxFlat.new()
	style.bg_color = STRIP_COLOR
	style.content_margin_left = 64
	style.content_margin_right = 64
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	strip.add_theme_stylebox_override("panel", style)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(strip)
	_text = Label.new()
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", TEXT_FONT_SIZE)
	_text.add_theme_color_override("font_color", TEXT_COLOR)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(_text)
	_skip_button = Button.new()
	_skip_button.text = SKIP_TEXT
	_skip_button.custom_minimum_size = SKIP_SIZE
	_skip_button.add_theme_font_size_override("font_size", 22)
	_skip_button.focus_mode = Control.FOCUS_NONE  # las teclas las atiende `_input`, no el foco
	_skip_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_skip_button.offset_left = -SKIP_SIZE.x - SCREEN_MARGIN
	_skip_button.offset_right = -SCREEN_MARGIN
	_skip_button.offset_top = SCREEN_MARGIN
	_skip_button.offset_bottom = SCREEN_MARGIN + SKIP_SIZE.y
	_root.add_child(_skip_button)


func _ready() -> void:
	Audio.add_click_sounds(self)


func _process(delta: float) -> void:
	if _open and not manual_clock:
		advance(delta)


## Abre la intro en la lámina 1 con los datos ya validados (`IntroData`). Sin láminas termina enseguida.
func open(data: IntroData) -> void:
	_slides = data.slides
	_fade_s = data.fade_s
	_index = 0
	_elapsed = 0.0
	_fade_t = 0.0
	_fading = false
	_textures.clear()
	_open = true
	visible = true
	if _slides.is_empty():
		finish()
		return
	_current_image.texture = _texture(0)
	_previous_image.texture = null
	_current_image.modulate.a = 1.0
	_text.modulate.a = 1.0
	_text.text = String(_slides[0]["texto"])


func is_open() -> bool:
	return _open


## El reloj de la intro: el fundido en marcha o los segundos de la lámina.
func advance(delta: float) -> void:
	if not _open:
		return
	if _fading:
		_fade_t += delta
		if _fade_t >= _fade_s:
			_end_fade()
		else:
			_apply_fade(_fade_t / _fade_s)
		return
	_elapsed += delta
	if _elapsed >= float(_slides[_index]["segundos"]):
		next()


## Pasa a la lámina siguiente (con fundido) o, en la última, termina. Durante un fundido lo completa enseguida
## (se ve la lámina que entraba) sin saltar ninguna.
func next() -> void:
	if not _open:
		return
	if _fading:
		_end_fade()
		return
	if _index >= _slides.size() - 1:
		finish()
		return
	_index += 1
	_elapsed = 0.0
	_previous_image.texture = _current_image.texture
	_current_image.texture = _texture(_index)
	if _fade_s <= 0.0:
		_end_fade()
		return
	_fading = true
	_fade_t = 0.0
	_apply_fade(0.0)


## Termina la intro entera («Omitir», `Esc` y «atrás»).
func skip() -> void:
	finish()


## Cierra y avisa. Si ya estaba cerrada no hace nada: `finished` sale una sola vez.
func finish() -> void:
	if not _open:
		return
	_open = false
	_fading = false
	visible = false
	_textures.clear()
	_current_image.texture = null
	_previous_image.texture = null
	finished.emit()


# --- Lo que se puede consultar (los tests) ---

func current_index() -> int:
	return _index


func slide_count() -> int:
	return _slides.size()


func is_fading() -> bool:
	return _fading


## El texto que se ve en la franja.
func text() -> String:
	return _text.text


func skip_button() -> Button:
	return _skip_button


## Las dos imágenes apiladas: la lámina de atrás (durante el fundido) y la de adelante.
func current_image() -> TextureRect:
	return _current_image


func previous_image() -> TextureRect:
	return _previous_image


## El rectángulo que ocupa una imagen que se ve entera (`KEEP_ASPECT`) dentro de una pantalla.
static func fit_rect(screen: Vector2, image: Vector2) -> Rect2:
	var scale: float = minf(screen.x / image.x, screen.y / image.y)
	var size: Vector2 = image * scale
	return Rect2((screen - size) / 2.0, size)


# --- Entrada ---

func _input(event: InputEvent) -> void:
	if not _open:
		return
	var key := event as InputEventKey
	if key != null and key.pressed:
		if not key.echo:
			if event.is_action_pressed("cancel") or key.keycode == KEY_ESCAPE:
				skip()
			elif key.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_RIGHT]:
				next()
		get_viewport().set_input_as_handled()  # con la intro abierta ninguna tecla llega a lo de atrás
		return
	if event.is_action_pressed("cancel"):  # el «atrás» de Android llega como acción, no como tecla
		skip()
		get_viewport().set_input_as_handled()
		return
	var click := event as InputEventMouseButton
	if click != null:
		if not click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _skip_button.get_global_rect().has_point(click.position):
				skip()
			else:
				next()
		get_viewport().set_input_as_handled()  # el clic no pasa a lo de atrás (ni al apretar ni al soltar)
	elif event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()  # en el celular el toque llega también como clic emulado


# --- Armado ---

func _make_image() -> TextureRect:
	var image := TextureRect.new()
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # la lámina entera; sobran barras si no es 16:9
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(image)
	return image


## Carga la imagen de la lámina `index` (de a una: la actual y la anterior, no las siete). Una que no carga
## se avisa y deja la lámina sin imagen: la intro sigue con el texto.
func _texture(index: int) -> Texture2D:
	if not _textures.has(index):
		var texture := load(String(_slides[index]["imagen"])) as Texture2D
		if texture == null:
			push_warning("Intro: no se pudo cargar la imagen de la lámina %d (%s)." % [index + 1, _slides[index]["imagen"]])
		_textures[index] = texture
	return _textures[index]


## `t` de 0 a 1: la lámina que entra se funde sobre la que sale y el texto cambia en la mitad.
func _apply_fade(t: float) -> void:
	_current_image.modulate.a = t
	_text.modulate.a = absf(t * 2.0 - 1.0)
	_text.text = String(_slides[_index if t >= 0.5 else _index - 1]["texto"])


func _end_fade() -> void:
	_fading = false
	_fade_t = 0.0
	_current_image.modulate.a = 1.0
	_text.modulate.a = 1.0
	_text.text = String(_slides[_index]["texto"])
	_previous_image.texture = null
	for key: Variant in _textures.keys():
		if int(key) != _index:
			_textures.erase(key)
