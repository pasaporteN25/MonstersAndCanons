# El apoyo no guarda referencias a torres ni se apila (RF-361).
class_name SupportRules
extends RefCounted

static func strongest_at(position: Vector2, supports: Array[Dictionary]) -> int:
	var strongest: int = 0
	for support: Dictionary in supports:
		if bool(support.get("active", false)) and position.distance_squared_to(support["position"]) <= pow(float(support["radius"]), 2.0):
			strongest = maxi(strongest, int(support["percent"]))
	return strongest

static func fire_rate(base: float, bonus: int) -> float:
	return base * (1.0 + maxi(bonus, 0) / 100.0)
