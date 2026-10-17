class_name CameraController
extends Node

var _level: Level
var _camera: Camera2D
var _minimum_zoom: float = 1.0
var _maximum_zoom: float = 1.5
var _zoom_wheel_factor: float = 1.1
var _touch_max_distance: float = 21.0
var _top_height: float = 64.0
var _bottom_height: float = 96.0
var _camera_factory: Callable
var _mobile_hud: MobileHud
var _mobile_mode: bool = false
var _middle_dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO
var _touches: Dictionary = {}
var _pinch_distance: float = 0.0
var _pinch_start_distance: float = 0.0
var _pinch_midpoint: Vector2 = Vector2.ZERO


func setup(level: Level, camera: Camera2D, minimum_zoom: float, camera_factory: Callable,
		mobile_hud: MobileHud, mobile_mode: bool) -> void:
	_level = level
	_camera = camera
	_minimum_zoom = minimum_zoom
	_camera_factory = camera_factory
	_mobile_hud = mobile_hud
	_mobile_mode = mobile_mode
	var config: MobileUiConfig = MobileUiConfig.load_from()
	_maximum_zoom = float(config.get_value("zoom_casilla_max_px")) / Rules.TILE_SIZE
	_zoom_wheel_factor = float(config.get_value("zoom_rueda_factor"))
	_touch_max_distance = float(config.get_value("toque_max_px"))
	_top_height = float(config.get_value("barra_alta_px")) if _mobile_mode else 48.0
	_bottom_height = float(config.get_value("barra_baja_px"))
	_update_view_all()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed and _in_map_area(mouse.position):
			_zoom_at(mouse.position, _zoom_wheel_factor)
			get_viewport().set_input_as_handled()
		elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed and _in_map_area(mouse.position):
			_zoom_at(mouse.position, 1.0 / _zoom_wheel_factor)
			get_viewport().set_input_as_handled()
		elif mouse.button_index == MOUSE_BUTTON_MIDDLE:
			_middle_dragging = mouse.pressed and _in_map_area(mouse.position)
			_last_mouse_pos = mouse.position
			if _middle_dragging:
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _middle_dragging:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_pan_by_screen_delta(motion.position - _last_mouse_pos)
		_last_mouse_pos = motion.position
		get_viewport().set_input_as_handled()
	elif _mobile_mode and event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif _mobile_mode and event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)


func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		if not _in_map_area(touch.position) or (_mobile_hud != null and _mobile_hud.is_interactive_at(touch.position)):
			return
		_touches[touch.index] = touch.position
		if _touches.size() >= 2:
			_update_pinch_reference()
	else:
		_touches.erase(touch.index)
		if _touches.size() >= 2:
			_update_pinch_reference()


func _handle_screen_drag(drag: InputEventScreenDrag) -> void:
	if not _touches.has(drag.index):
		return
	var previous_midpoint: Vector2 = _pinch_midpoint
	_touches[drag.index] = drag.position
	if _touches.size() < 2:
		return
	var points: Array = _touches.values()
	var midpoint: Vector2 = (Vector2(points[0]) + Vector2(points[1])) / 2.0
	var distance: float = Vector2(points[0]).distance_to(Vector2(points[1]))
	if _pinch_distance > 0.0 and absf(distance - _pinch_start_distance) > _touch_max_distance:
		_zoom_at(midpoint, distance / _pinch_distance)
	else:
		_pan_by_screen_delta(midpoint - previous_midpoint)
	_pinch_distance = distance
	_pinch_midpoint = midpoint
	get_viewport().set_input_as_handled()


func _update_pinch_reference() -> void:
	var points: Array = _touches.values()
	_pinch_midpoint = (Vector2(points[0]) + Vector2(points[1])) / 2.0
	_pinch_distance = Vector2(points[0]).distance_to(Vector2(points[1]))
	_pinch_start_distance = _pinch_distance


func _zoom_at(screen_position: Vector2, factor: float) -> void:
	_ensure_camera()
	var old_zoom: float = _camera.zoom.x
	var next_zoom: float = clamp_zoom(old_zoom * factor, _minimum_zoom, _maximum_zoom)
	if is_equal_approx(old_zoom, next_zoom):
		return
	var world_before: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * screen_position
	_camera.zoom = Vector2.ONE * next_zoom
	var world_after: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * screen_position
	_camera.position += world_before - world_after
	_clamp_camera_center()
	_update_view_all()


func _pan_by_screen_delta(delta: Vector2) -> void:
	_ensure_camera()
	_camera.position -= delta / _camera.zoom.x
	_clamp_camera_center()


func _ensure_camera() -> void:
	if _camera == null:
		_camera = _camera_factory.call() as Camera2D
	if _camera.zoom.x <= 0.0:
		_camera.zoom = Vector2.ONE * _minimum_zoom


func _clamp_camera_center() -> void:
	var map_size: Vector2i = _level.map_size()
	var rect := Rect2(_level.position, Vector2(map_size) * Rules.TILE_SIZE)
	_camera.position = clamp_center(_camera.position, rect)


func _in_map_area(screen_position: Vector2) -> bool:
	return screen_position.y >= _top_height and screen_position.y < Rules.SCREEN_SIZE.y - _bottom_height


func _update_view_all() -> void:
	if _mobile_hud == null:
		return
	var zoom: float = _minimum_zoom if _camera == null else _camera.zoom.x
	_mobile_hud.show_view_all(zoom > _minimum_zoom and not is_equal_approx(zoom, _minimum_zoom))


static func clamp_zoom(value: float, minimum: float, maximum: float) -> float:
	return clampf(value, minimum, maximum)


static func clamp_center(center: Vector2, map_rect: Rect2) -> Vector2:
	return Vector2(clampf(center.x, map_rect.position.x, map_rect.end.x), clampf(center.y, map_rect.position.y, map_rect.end.y))


func view_all() -> void:
	_ensure_camera()
	_camera.zoom = Vector2.ONE * _minimum_zoom
	var map_size: Vector2i = _level.map_size()
	var area := Rect2(0.0, _top_height, Rules.SCREEN_SIZE.x, Rules.SCREEN_SIZE.y - _top_height - _bottom_height)
	var map_center: Vector2 = _level.position + Vector2(map_size) * Rules.TILE_SIZE / 2.0
	_camera.position = map_center + (Rules.SCREEN_SIZE / 2.0 - area.get_center()) / _minimum_zoom
	_clamp_camera_center()
	_update_view_all()
