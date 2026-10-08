# Textos del panel de un removible (RF-404, RF-405). Se arman leyendo los datos (RF-164).
class_name ObstacleText
extends RefCounted

const NAMES: Dictionary = {
	&"arbol": "Árbol", &"roca": "Roca", &"escombro": "Escombros",
	&"mina": "Mina", &"bosque_explotable": "Bosque explotable",
}
## Provisorio: T211 lleva los nombres de las colecciones a `data/progression.json` (RF-425).
const COLLECTION_NAMES: Dictionary = {&"disruptor": "la Disruptora"}


static func display_name(spec: ObstacleSpec) -> String:
	return NAMES.get(spec.class_id, String(spec.class_id).capitalize())


static func cost_line(cost: int) -> String:
	return "Costo: %d de oro" % cost


static func time_line(seconds: float) -> String:
	return "Tiempo: %s s" % _seconds(seconds)


## Lo que falta para pagar: "Te faltan 15 de oro".
static func missing_gold(cost: int, gold: int) -> String:
	return "Te faltan %d de oro" % maxi(cost - gold, 0)


## RF-404: la recompensa sin mostrar el sorteo.
static func reward_line(spec: ObstacleSpec, recovered: bool) -> String:
	if spec.finding_collection != &"":
		var name: String = COLLECTION_NAMES.get(spec.finding_collection, String(spec.finding_collection))
		return "Pieza de %s: %s" % [name, "ya recuperada" if recovered else "pendiente"]
	if spec.chance_percent > 0 and spec.reward_amount > 0:
		return "Puede dar %d %s (%d %%)" % [spec.reward_amount, "recurso" if spec.reward_amount == 1 else "recursos", spec.chance_percent]
	return "No da recursos"


static func seconds_left_line(seconds: float) -> String:
	return "Falta: %s s" % _seconds(ceilf(seconds))


static func _seconds(seconds: float) -> String:
	return str(int(seconds)) if is_equal_approx(seconds, roundf(seconds)) else "%.1f" % seconds
