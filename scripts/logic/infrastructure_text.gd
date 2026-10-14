# Textos y cuentas de la pestaña «Infraestructura» de la barra (M53, RF-457 y RF-458). Se arman leyendo
# los datos (RF-164): ningún número del juego vive acá. Lógica pura, sin escena (P10).
class_name InfrastructureText
extends RefCounted

const EMPTY_JOB: String = "Sin demolición en curso. Tocá un objeto del mapa para demolerlo."
const TAB_TITLE: String = "Infraestructura"


## RF-458: los segundos del aviso del título («Infraestructura · 4 s»), hacia arriba: una demolición que falta 0,2 s
## todavía dice «1 s».
static func seconds_text(seconds_left: float) -> String:
	return "%d s" % maxi(ceili(seconds_left), 0)


## RF-457, tarjeta 1: «Faltan 4 s».
static func job_left_line(seconds_left: float) -> String:
	return "Faltan %s" % seconds_text(seconds_left)


## RF-457, tarjeta 2: sin comprar, «Demoledora · 180 de oro».
static func machine_title(price: int, owned: bool) -> String:
	return "Demoledora activa" if owned else "Demoledora · %d de oro" % price


## RF-413: la ventaja, leída de los datos: «Cada demolición cuesta el 10 % y tarda el 80 %».
static func machine_effect(machine: Dictionary = {}) -> String:
	var data: Dictionary = machine if not machine.is_empty() else ObstacleCatalog.machine()
	return "Cada demolición cuesta el %d %% y tarda el %d %%" % [
		int(data.get("costo_uso_porcentaje", 100)), int(data.get("tiempo_porcentaje", 100))]


## El botón de compra: «Comprar», o lo que falta si no alcanza el oro.
static func buy_text(price: int, gold: int) -> String:
	return "Comprar" if gold >= price else "Te faltan %d de oro" % (price - gold)


## RF-457, tarjeta 3: una ficha por punto, según el estado (`ObstacleField.State`).
## «Habilitar · 100 de oro» / «Activa · reserva 6/8 · +2 por oleada» / «Agotada».
static func site_line(state: ObstacleField.State, price: int, reserve: int, max_reserve: int, production: int) -> String:
	match state:
		ObstacleField.State.ACTIVE:
			return "Activa · reserva %d/%d · +%d por oleada" % [reserve, max_reserve, production]
		ObstacleField.State.DEPLETED:
			return "Agotada"
	return "Habilitar · %d de oro" % price


## RF-457, tarjeta 4: «Recursos: 3».
static func resources_line(have: int) -> String:
	return "Recursos: %d" % have


## «Al terminar la oleada: +2». Vacío si no hay nada que esperar.
static func expected_line(expected: int) -> String:
	return "Al terminar la oleada: +%d" % expected if expected > 0 else ""


## RF-457, tarjeta 4: la suma de `min(producción, reserva)` de los puntos activos: lo mismo que entrega
## `ObstacleField.complete_wave()` (RF-423), sin tocar el campo. No predice el drop al azar de los
## removibles (RF-417).
static func expected_resources(field: ObstacleField) -> int:
	var total: int = 0
	for cell: Vector2i in field.extraction_cells():
		if field.state_of(cell) == ObstacleField.State.ACTIVE:
			total += mini(field.spec_at(cell).production, field.reserve_left(cell))
	return total


## Las fichas de la tarjeta 3, listas para la vista: {cell, kind_name, state, price, reserve, max_reserve, production}.
static func sites(field: ObstacleField) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for cell: Vector2i in field.extraction_cells():
		var spec: ObstacleSpec = field.spec_at(cell)
		result.append({
			"cell": cell,
			"kind_name": ObstacleText.display_name(spec),
			"state": field.state_of(cell),
			"price": field.cost_of(cell),
			"reserve": field.reserve_left(cell),
			"max_reserve": spec.reserve,
			"production": spec.production,
		})
	return result
