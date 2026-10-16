class_name GhostPlacement
extends RefCounted

var cell: Vector2i = Vector2i.ZERO
var tower_id: StringName = &""
var size: int = 1
var valid: bool = false
var reason: String = "Ahí no"
var gold_cost: int = 0
var resource_cost: int = 0
var _last_tap_cell: Vector2i = Vector2i(-1000, -1000)
var _last_tap_ms: int = -1000000


func select_tower(id: StringName, footprint: int, cost_gold: int, cost_resources: int = 0) -> void:
	tower_id = id
	size = clampi(footprint, 1, 2)
	gold_cost = cost_gold
	resource_cost = cost_resources
	valid = false
	reason = "Ahí no"


func move_to(next_cell: Vector2i, is_valid: bool, invalid_reason: String = "Ahí no") -> void:
	cell = next_cell
	valid = is_valid
	reason = "" if is_valid else invalid_reason


func move_by_cells(delta: Vector2i, map_size: Vector2i) -> void:
	cell += delta
	clamp_inside(map_size)


func clamp_inside(map_size: Vector2i) -> void:
	cell.x = clampi(cell.x, 0, maxi(map_size.x - size, 0))
	cell.y = clampi(cell.y, 0, maxi(map_size.y - size, 0))


func can_confirm(gold: int, resources: int) -> Dictionary:
	if not valid:
		return {"ok": false, "motivo": reason, "faltan": 0}
	if gold < gold_cost:
		return {"ok": false, "motivo": "Faltan %d de oro" % (gold_cost - gold), "faltan": gold_cost - gold}
	if resources < resource_cost:
		return {"ok": false, "motivo": "Faltan %d recursos" % (resource_cost - resources), "faltan": resource_cost - resources}
	return {"ok": true, "motivo": "", "faltan": 0}


func is_double_tap(next_cell: Vector2i, time_ms: int, window_ms: int) -> bool:
	var matched: bool = _last_tap_cell == next_cell and time_ms - _last_tap_ms < window_ms
	_last_tap_cell = Vector2i(-1000, -1000) if matched else next_cell
	_last_tap_ms = -1000000 if matched else time_ms
	return matched
