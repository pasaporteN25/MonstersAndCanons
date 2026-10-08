## Geometría pura de la carga: fusiona puntos colineales del camino de casillas.
class_name ChargeRules
extends RefCounted

static func segments(curve: Curve2D) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var offset: float = 0.0
	var direction: Vector2 = Vector2.ZERO
	for i: int in range(1,curve.point_count):
		var from: Vector2 = curve.get_point_position(i - 1)
		var to: Vector2 = curve.get_point_position(i)
		var step: Vector2 = to - from
		if step.is_zero_approx():
			continue
		var next: Vector2 = step.normalized()
		if result.is_empty() or not direction.is_equal_approx(next):
			result.append({"start":offset,"end":offset + step.length(),"position":to})
		else:
			result[-1]["end"] = offset + step.length()
			result[-1]["position"] = to
		offset += step.length()
		direction = next
	return result
