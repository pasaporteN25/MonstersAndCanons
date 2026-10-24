class_name PresentationGeometry
extends RefCounted

const LOGICAL_SIZE: Vector2 = Vector2(1280.0, 720.0)


static func frame_rect(surface_size: Vector2) -> Rect2:
	if surface_size.x <= 0.0 or surface_size.y <= 0.0:
		return Rect2()
	var scale: float = minf(surface_size.x / LOGICAL_SIZE.x, surface_size.y / LOGICAL_SIZE.y)
	var size: Vector2 = LOGICAL_SIZE * scale
	return Rect2((surface_size - size) * 0.5, size)


static func render_size(frame_size: Vector2) -> Vector2i:
	return Vector2i(maxi(2, roundi(frame_size.x)), maxi(2, roundi(frame_size.y)))


static func frame_scale(frame_size: Vector2) -> float:
	if frame_size.x <= 0.0 or frame_size.y <= 0.0:
		return 0.0
	return minf(frame_size.x / LOGICAL_SIZE.x, frame_size.y / LOGICAL_SIZE.y)


static func window_to_logical(position: Vector2, surface_size: Vector2) -> Vector2:
	var frame: Rect2 = frame_rect(surface_size)
	if frame.size == Vector2.ZERO or not frame.has_point(position):
		return Vector2(-1.0, -1.0)
	return (position - frame.position) * (LOGICAL_SIZE / frame.size)


static func logical_to_window(position: Vector2, surface_size: Vector2) -> Vector2:
	var frame: Rect2 = frame_rect(surface_size)
	return frame.position + position * (frame.size / LOGICAL_SIZE)
