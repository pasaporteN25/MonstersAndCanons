class_name FloatButtonLayout
extends RefCounted


static func minimum_button_size(dpi: float, canvas_scale: float, minimum_mm: float,
		fallback_px: float) -> float:
	if dpi <= 0.0 or canvas_scale <= 0.0:
		return fallback_px
	return minimum_mm * dpi / 25.4 / canvas_scale


static func snap(pos: Vector2, view_size: Vector2, top: float, bottom: float,
		button_size: Vector2) -> Dictionary:
	var side: String = "left" if pos.x + button_size.x / 2.0 < view_size.x / 2.0 else "right"
	var available: float = maxf(view_size.y - top - bottom - button_size.y, 0.0)
	var y: float = clampf((pos.y - top - button_size.y / 2.0) / maxf(available, 1.0), 0.0, 1.0)
	return {"side": side, "y": y}


static func position_for(side: String, y: float, view_size: Vector2, top: float,
		bottom: float, button_size: Vector2) -> Vector2:
	var x: float = 0.0 if side == "left" else view_size.x - button_size.x
	var available: float = maxf(view_size.y - top - bottom - button_size.y, 0.0)
	return Vector2(x, top + clampf(y, 0.0, 1.0) * available)


static func avoid(ghost_rect: Rect2, button_rects: Array[Rect2], sides: Array[String],
		view_size: Vector2, top: float, bottom: float, button_size: Vector2,
		distance: float) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for i: int in button_rects.size():
		var rect: Rect2 = button_rects[i]
		var current: String = sides[i]
		var expanded: Rect2 = ghost_rect.grow(button_size.x * distance)
		var opposite: String = "left" if current == "right" else "right"
		var current_position: Vector2 = rect.position
		var alternate_position: Vector2 = Vector2(0.0 if opposite == "left" else view_size.x - button_size.x, rect.position.y)
		var current_rect := Rect2(current_position, button_size)
		var alternate_rect := Rect2(alternate_position, button_size)
		if expanded.intersects(current_rect) and not expanded.intersects(alternate_rect):
			current_position = alternate_position
		positions.append(current_position)
	for i: int in positions.size():
		for j: int in i:
			if absf(positions[i].y - positions[j].y) < button_size.y * 2.0:
				var low: float = top
				var high: float = maxf(view_size.y - bottom - button_size.y, top)
				var new_y: float = positions[j].y + button_size.y * 2.0
				if new_y > high:
					new_y = positions[j].y - button_size.y * 2.0
				positions[i].y = clampf(new_y, low, high)
	return positions


static func tick_side(ghost_rect: Rect2, button_rects: Array[Rect2], view_width: float,
		near_distance: float) -> String:
	if button_rects.is_empty():
		return "right" if ghost_rect.get_center().x < view_width / 2.0 else "left"
	var nearest: Rect2 = button_rects[0]
	var nearest_distance: float = INF
	for rect: Rect2 in button_rects:
		var distance: float = rect.get_center().distance_squared_to(ghost_rect.get_center())
		if distance < nearest_distance:
			nearest = rect
			nearest_distance = distance
	if nearest.get_center().distance_to(ghost_rect.get_center()) > near_distance:
		var free_left: float = ghost_rect.position.x
		var free_right: float = view_width - ghost_rect.end.x
		return "right" if free_right >= free_left else "left"
	return "left" if nearest.get_center().x > ghost_rect.get_center().x else "right"
