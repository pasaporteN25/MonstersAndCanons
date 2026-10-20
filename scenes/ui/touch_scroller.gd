class_name TouchScroller
extends Node
# RF-551 (M61, D-115): desplazamiento de un dedo, con inercia, para el `ScrollContainer` que es su padre.
# Se queda con el arrastre aunque el dedo empiece sobre un botón o una tarjeta (el `ScrollContainer` de Godot no
# lo hace: el botón se queda con el toque). Solo atiende toques; el mouse sigue con la rueda y la barra (RF-552).
#
# Orden de eventos de Godot con un toque: primero el clic emulado y después el toque (T289, A.4). El botón apoyado
# ya recibió el «apretar» emulado; al empezar el arrastre se le manda un movimiento emulado lejos (un botón de
# Godot solo se pulsa al soltar si el puntero sigue adentro) y se le saca el foco. El soltar emulado pasa tal cual:
# el `Viewport` tiene que enterarse de que se soltó (si no, queda un botón «capturando» el próximo toque).

const FAR_AWAY: Vector2 = Vector2(-100000.0, -100000.0)
## Si el dedo estuvo quieto más que esto antes de soltar, no hay inercia.
const REST_MS: int = 100

var _scroll: ScrollContainer
var _index: int = -1
var _start: Vector2 = Vector2.ZERO
var _scrolling: bool = false
var _position: Vector2 = Vector2.ZERO  # posición de desplazamiento con decimales
var _velocity: Vector2 = Vector2.ZERO  # px/s de desplazamiento
var _last_drag_us: int = 0
var _injecting: bool = false
var _inertia: bool = false

var _threshold: float = 12.0
var _friction: float = 4.0
var _min_velocity: float = 30.0


func _ready() -> void:
	_scroll = get_parent() as ScrollContainer
	process_mode = Node.PROCESS_MODE_ALWAYS  # los menús de la pausa corren con el árbol en pausa
	set_process(false)
	var config: MobileUiConfig = MobileUiConfig.load_from()
	_threshold = float(config.get_value("scroll_umbral_px"))
	_friction = float(config.get_value("scroll_friccion"))
	_min_velocity = float(config.get_value("scroll_velocidad_min_px"))


func is_scrolling() -> bool:
	return _scrolling


func has_inertia() -> bool:
	return _inertia


func _input(event: InputEvent) -> void:
	if _scroll == null or not _scroll.is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseMotion and _scrolling and not _injecting and (event as InputEventMouseMotion).device == InputEvent.DEVICE_ID_EMULATION:
		get_viewport().set_input_as_handled()  # el eco del dedo que arrastra no tiene que mover ningún «hover»


func _on_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		_inertia = false
		set_process(false)
		if _index != -1 or not _scroll.get_global_rect().has_point(touch.position):
			return
		if not _can_scroll() or _on_other_control(touch.position):
			return
		_index = touch.index
		_start = touch.position
		_scrolling = false
		_velocity = Vector2.ZERO
		_position = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
		_last_drag_us = Time.get_ticks_usec()
		return
	if touch.index != _index:
		return
	var was_scrolling: bool = _scrolling
	_index = -1
	_scrolling = false
	if was_scrolling:
		if (Time.get_ticks_usec() - _last_drag_us) / 1000 > REST_MS:
			_velocity = Vector2.ZERO
		_inertia = not KineticScroll.is_stopped(_velocity, _min_velocity)
		set_process(_inertia)
		get_viewport().set_input_as_handled()


func _on_drag(drag: InputEventScreenDrag) -> void:
	if drag.index != _index:
		return
	if not _scrolling:
		if not KineticScroll.is_drag(drag.position.distance_to(_start), _threshold):
			return
		_scrolling = true
		_cancel_press()
	var now_us: int = Time.get_ticks_usec()
	var dt: float = float(now_us - _last_drag_us) / 1000000.0
	_last_drag_us = now_us
	_velocity = _velocity.lerp(-KineticScroll.finger_velocity(drag.relative, dt), 0.5)
	_scroll_by(-drag.relative)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _inertia:
		set_process(false)
		return
	_velocity = Vector2(KineticScroll.decay(_velocity.x, _friction, delta), KineticScroll.decay(_velocity.y, _friction, delta))
	var before: Vector2 = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
	_scroll_by(_velocity * delta)
	var after: Vector2 = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
	if after.x == before.x:
		_velocity.x = 0.0
	if after.y == before.y:
		_velocity.y = 0.0
	if KineticScroll.is_stopped(_velocity, _min_velocity):
		_inertia = false
		set_process(false)


func _scroll_by(amount: Vector2) -> void:
	_position += amount
	if _scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		_scroll.scroll_horizontal = roundi(_position.x)
	if _scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		_scroll.scroll_vertical = roundi(_position.y)
	# Si tocó un borde, el contenedor lo recortó: se sigue desde donde quedó.
	_position = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)


## Hay algo que desplazar (si todo entra, no se le saca el toque a nadie).
func _can_scroll() -> bool:
	var vertical: ScrollBar = _scroll.get_v_scroll_bar()
	var horizontal: ScrollBar = _scroll.get_h_scroll_bar()
	var can_v: bool = _scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED and vertical.max_value > vertical.page + 0.5
	var can_h: bool = _scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED and horizontal.max_value > horizontal.page + 0.5
	return can_v or can_h


## Un deslizador, una barra u otro desplazamiento adentro: el dedo es de ellos.
func _on_other_control(pos: Vector2) -> bool:
	for bar: ScrollBar in [_scroll.get_v_scroll_bar(), _scroll.get_h_scroll_bar()]:
		if bar.visible and bar.get_global_rect().has_point(pos):
			return true
	for node: Node in _scroll.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if (control is Range or control is ScrollContainer) and control.is_visible_in_tree() and control.get_global_rect().has_point(pos):
			return true
	return false


## El botón apoyado deja de estar «apretado»: el puntero «se va» lejos y, al soltar, no se pulsa.
func _cancel_press() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and _scroll.is_ancestor_of(focused):
		focused.release_focus()
	var away := InputEventMouseMotion.new()
	away.position = FAR_AWAY
	away.global_position = FAR_AWAY
	away.device = InputEvent.DEVICE_ID_EMULATION
	_injecting = true
	get_viewport().push_input(away, true)
	_injecting = false
