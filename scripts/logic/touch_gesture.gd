class_name TouchGesture
extends RefCounted

enum Gesture { NONE, TAP, DRAG, PINCH, PAN }

var max_tap_distance: float = 21.0
var pinch_grace_ms: int = 150
var _fingers: Dictionary = {}
var _start_positions: Dictionary = {}
var _had_multiple_fingers: bool = false
var _last_multi_end_ms: int = -1000000
var _pair_distance: float = 0.0


func configure(max_distance_px: float, grace_ms: int) -> void:
	max_tap_distance = max_distance_px
	pinch_grace_ms = grace_ms


func down(index: int, pos: Vector2, _time_ms: int) -> Gesture:
	_fingers[index] = pos
	_start_positions[index] = pos
	if _fingers.size() > 1:
		_had_multiple_fingers = true
		var indices: Array = _fingers.keys()
		_pair_distance = Vector2(_fingers[indices[0]]).distance_to(Vector2(_fingers[indices[1]]))
		return Gesture.PINCH
	return Gesture.NONE


func move(index: int, pos: Vector2, _time_ms: int) -> Gesture:
	if not _fingers.has(index):
		return Gesture.NONE
	_fingers[index] = pos
	if _had_multiple_fingers:
		var indices: Array = _fingers.keys()
		if indices.size() < 2:
			return Gesture.PAN
		var distance: float = Vector2(_fingers[indices[0]]).distance_to(Vector2(_fingers[indices[1]]))
		return Gesture.PINCH if absf(distance - _pair_distance) > max_tap_distance else Gesture.PAN
	return Gesture.DRAG if pos.distance_to(_start_positions[index]) > max_tap_distance else Gesture.NONE


func up(index: int, pos: Vector2, time_ms: int) -> Gesture:
	if not _fingers.has(index):
		return Gesture.NONE
	_fingers[index] = pos
	var gesture: Gesture = Gesture.PINCH if _had_multiple_fingers else Gesture.NONE
	if not _had_multiple_fingers:
		gesture = Gesture.DRAG if pos.distance_to(_start_positions[index]) > max_tap_distance else Gesture.TAP
	_fingers.erase(index)
	_start_positions.erase(index)
	if _had_multiple_fingers and _fingers.is_empty():
		_last_multi_end_ms = time_ms
		_had_multiple_fingers = false
	return gesture


func ignores_single_touch(time_ms: int) -> bool:
	return time_ms - _last_multi_end_ms < pinch_grace_ms


func active_fingers() -> int:
	return _fingers.size()
