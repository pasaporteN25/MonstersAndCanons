# Textos del panel de un removible (RF-404, RF-405). Se arman leyendo los datos (RF-164).
class_name ObstacleText
extends RefCounted

const NAMES: Dictionary = {
	&"arbol": "Árbol", &"roca": "Roca", &"escombro": "Escombros",
	&"mina": "Mina", &"bosque_explotable": "Bosque explotable",
}


static func display_name(spec: ObstacleSpec) -> String:
	return Localization.data_text("obstacle", spec.class_id, "name", NAMES.get(spec.class_id, String(spec.class_id).capitalize()))


static func cost_line(cost: int) -> String:
	return Localization.t_fmt(&"obstacle.cost", {"n": cost})


static func time_line(seconds: float) -> String:
	return Localization.t_fmt(&"obstacle.time", {"x": _seconds(seconds)})


## Lo que falta para pagar: "Te faltan 15 de oro".
static func missing_gold(cost: int, gold: int) -> String:
	return Localization.t_fmt(&"obstacle.short_gold", {"n": maxi(cost - gold, 0)})


## RF-404: la recompensa sin mostrar el sorteo.
## RF-428 y RF-429: `collects` = false cuando la partida no recoge piezas (modos, comunidad, editor, pruebas).
static func reward_line(spec: ObstacleSpec, recovered: bool, collects: bool = true) -> String:
	if spec.finding_collection != &"":
		if not collects:
			return Localization.t(&"obstacle.no_pieces")
		var name: String = CollectionDefinitions.name_of(spec.finding_collection)
		return Localization.t_fmt(&"obstacle.piece", {"name": name, "state": Localization.t(&"obstacle.piece_recovered" if recovered else &"obstacle.piece_pending")})
	if spec.chance_percent > 0 and spec.reward_amount > 0:
		return Localization.t_fmt(&"obstacle.may_give", {"n": spec.reward_amount, "word": TowerText.resources_word(spec.reward_amount), "pct": spec.chance_percent})
	return Localization.t(&"obstacle.gives_nothing")


static func seconds_left_line(seconds: float) -> String:
	return Localization.t_fmt(&"obstacle.time_left", {"x": _seconds(ceilf(seconds))})


static func _seconds(seconds: float) -> String:
	return str(int(seconds)) if is_equal_approx(seconds, roundf(seconds)) else "%.1f" % seconds


## RF-422: el botón de un punto sin habilitar.
static func enable_line(cost: int) -> String:
	return Localization.t_fmt(&"obstacle.enable", {"n": cost})


static func production_line(production: int) -> String:
	return Localization.t_fmt(&"obstacle.production", {"n": production, "word": TowerText.resources_word(production)})


## RF-424: "Reserva 6/8".
static func reserve_line(left: int, total: int) -> String:
	return Localization.t_fmt(&"obstacle.reserve", {"left": left, "total": total})


static func state_line(state: ObstacleField.State) -> String:
	match state:
		ObstacleField.State.ACTIVE:
			return Localization.t(&"obstacle.state_active")
		ObstacleField.State.DEPLETED:
			return Localization.t(&"obstacle.state_depleted")
	return Localization.t(&"obstacle.state_disabled")
