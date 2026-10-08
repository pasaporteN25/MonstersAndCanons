# El estado de cada removible de una partida y las reglas de la demolición directa (RF-404 a RF-409).
# Lógica pura, sin nodos: se prueba con GUT. El cobro y el reembolso los hace quien lo usa
# (InfrastructureController); acá solo se lleva el estado, el reloj del trabajo y el sorteo del drop.
class_name ObstacleField
extends RefCounted

enum State { INTACT, WORKING, CLEARED, DISABLED, ACTIVE, DEPLETED }

signal job_started(cell: Vector2i)
signal job_progress(cell: Vector2i, fraction: float)
## RF-408: el trabajo llegó a su duración. `reward` es lo que devuelve `reward_of`.
signal job_finished(cell: Vector2i, reward: Dictionary)
## RF-407: se canceló (con el oro pagado) o RF-409: se descartó (con 0).
signal job_cancelled(cell: Vector2i, refund: int)
## RF-422 y RF-423: un punto de extracción se habilitó, produjo o se agotó.
signal site_changed(cell: Vector2i)

var _specs: Dictionary = {}  # Vector2i → ObstacleSpec
var _states: Dictionary = {}  # Vector2i → State
## RF-417: el resultado del sorteo de cada removible, fijado al empezar.
var _drops: Dictionary = {}  # Vector2i → bool
var _recovered: Dictionary = {}
## RF-423: lo que le queda a cada punto de extracción.
var _reserves: Dictionary = {}  # Vector2i → int
var _source: StringName = &""
var _job: DemolitionJob
var has_machine: bool = false
var _machine: Dictionary = {}


## RF-417: sortea ahora el drop de cada removible, en orden de fila y columna. `recovered` dice qué
## colecciones ya no entregan pieza (ya recuperada, o no se recogen en este contexto, RF-428 y RF-429).
## `source` es el id del nivel: identifica la pieza (RF-426).
func setup(specs: Array[ObstacleSpec], rng: RandomNumberGenerator, recovered: Dictionary = {},
		source: StringName = &"") -> void:
	_specs.clear()
	_states.clear()
	_drops.clear()
	_reserves.clear()
	_job = null
	has_machine = false
	_machine = ObstacleCatalog.machine()
	_recovered = recovered
	_source = source
	var ordered: Array[ObstacleSpec] = specs.duplicate()
	ordered.sort_custom(func(a: ObstacleSpec, b: ObstacleSpec) -> bool:
		return a.cell.y < b.cell.y or (a.cell.y == b.cell.y and a.cell.x < b.cell.x))
	for spec: ObstacleSpec in ordered:
		_specs[spec.cell] = spec
		if spec.kind == ObstacleSpec.Kind.REMOVABLE:
			_states[spec.cell] = State.INTACT
			_drops[spec.cell] = rng.randi_range(1, 100) <= spec.chance_percent
		else:
			_states[spec.cell] = State.DISABLED
			_reserves[spec.cell] = spec.reserve


func spec_at(cell: Vector2i) -> ObstacleSpec:
	return _specs.get(cell)


## Estado de la celda; `INTACT` si no hay nada (no es un removible).
func state_of(cell: Vector2i) -> State:
	return _states.get(cell, State.CLEARED)


func is_removable(cell: Vector2i) -> bool:
	var spec: ObstacleSpec = _specs.get(cell)
	return spec != null and spec.kind == ObstacleSpec.Kind.REMOVABLE


func has_job() -> bool:
	return _job != null


func job() -> DemolitionJob:
	return _job


## `&""` si se puede ordenar, o el motivo: `&"busy"` (RF-406), `&"cleared"` o `&"not_removable"`.
func can_order(cell: Vector2i) -> StringName:
	if not is_removable(cell):
		return &"not_removable"
	if state_of(cell) == State.CLEARED:
		return &"cleared"
	if _job != null:
		return &"busy"
	return &""


func cost_of(cell: Vector2i) -> int:
	var spec: ObstacleSpec = _specs.get(cell)
	return 0 if spec == null else _cost(spec, has_machine)


func seconds_of(cell: Vector2i) -> float:
	var spec: ObstacleSpec = _specs.get(cell)
	return 0.0 if spec == null else _seconds(spec, has_machine)


## Precio que tendría la celda con la máquina, para mostrarlo antes de comprarla.
func cost_with_machine(cell: Vector2i) -> int:
	var spec: ObstacleSpec = _specs.get(cell)
	return 0 if spec == null else _cost(spec, true)


## Duración que tendría la celda con la máquina, para mostrarla antes de comprarla.
func seconds_with_machine(cell: Vector2i) -> float:
	var spec: ObstacleSpec = _specs.get(cell)
	return 0.0 if spec == null else _seconds(spec, true)


func machine_price() -> int:
	return int(_machine.get("precio", 0))


## La compra se cobra afuera. Devuelve false si ya se compró.
func buy_machine() -> bool:
	if has_machine or machine_price() <= 0:
		return false
	has_machine = true
	return true


func _cost(spec: ObstacleSpec, with_machine: bool) -> int:
	if not with_machine:
		return spec.cost
	var percentage: float = float(_machine.get("costo_uso_porcentaje", 100)) / 100.0
	var minimum: int = int(_machine.get("costo_uso_minimo", 0))
	return mini(spec.cost, maxi(minimum, roundi(spec.cost * percentage)))


func _seconds(spec: ObstacleSpec, with_machine: bool) -> float:
	if not with_machine:
		return spec.seconds
	var percentage: float = float(_machine.get("tiempo_porcentaje", 100)) / 100.0
	return spec.seconds * percentage


## Empieza el trabajo y guarda el precio y la duración (RF-406). El cobro lo hace el llamador.
## Devuelve null si no se puede.
func order(cell: Vector2i) -> DemolitionJob:
	if can_order(cell) != &"":
		return null
	_job = DemolitionJob.new(cell, seconds_of(cell), cost_of(cell))
	_states[cell] = State.WORKING
	job_started.emit(cell)
	return _job


func tick(delta: float) -> void:
	if _job == null:
		return
	_job.tick(delta)
	job_progress.emit(_job.cell, _job.progress())
	if not _job.is_done():
		return
	var cell: Vector2i = _job.cell
	_job = null
	_states[cell] = State.CLEARED
	job_finished.emit(cell, reward_of(cell))


## RF-407: devuelve el oro pagado y deja el objeto intacto. 0 si no hay trabajo.
func cancel() -> int:
	if _job == null:
		return 0
	var cell: Vector2i = _job.cell
	var refund: int = _job.paid
	_job = null
	_states[cell] = State.INTACT
	job_cancelled.emit(cell, refund)
	return refund


## RF-409: al terminar la partida el trabajo se pierde, sin entregar ni devolver nada.
func discard_job() -> void:
	if _job == null:
		return
	var cell: Vector2i = _job.cell
	_job = null
	_states[cell] = State.INTACT
	job_cancelled.emit(cell, 0)


## RF-408, RF-417 y RF-428: qué entrega demoler esta celda. `resources` sale del sorteo ya hecho; una
## ruina con pieza pendiente entrega la pieza y ningún recurso, y una ya recuperada entrega
## `repeat_reward`. Solo tiene sentido al terminar el trabajo: el panel no lo muestra (RF-404).
func reward_of(cell: Vector2i) -> Dictionary:
	var spec: ObstacleSpec = _specs.get(cell)
	var reward: Dictionary = {"resources": 0, "finding": {}}
	if spec == null:
		return reward
	if spec.finding_collection != &"":
		if _recovered.get(spec.finding_collection, false):
			reward["resources"] = spec.repeat_reward
		else:
			reward["finding"] = {"collection": spec.finding_collection, "source": _source}
		return reward
	if _drops.get(cell, false):
		reward["resources"] = spec.reward_amount
	return reward


## RF-428: la pieza de esta ruina ya está recuperada (o no se recoge acá).
func finding_recovered(cell: Vector2i) -> bool:
	var spec: ObstacleSpec = _specs.get(cell)
	return spec != null and spec.finding_collection != &"" and _recovered.get(spec.finding_collection, false)


# --- Extracción finita (RF-422 a RF-424) ---

func is_extraction(cell: Vector2i) -> bool:
	var spec: ObstacleSpec = _specs.get(cell)
	return spec != null and spec.kind == ObstacleSpec.Kind.EXTRACTION


## `&""` si se puede habilitar, o el motivo: `&"not_extraction"`, `&"active"` o `&"depleted"`.
func can_enable(cell: Vector2i) -> StringName:
	if not is_extraction(cell):
		return &"not_extraction"
	match state_of(cell):
		State.ACTIVE:
			return &"active"
		State.DEPLETED:
			return &"depleted"
	return &""


## RF-422: deja activo el punto. El cobro lo hace el llamador. Devuelve false si no se puede.
func enable_site(cell: Vector2i) -> bool:
	if can_enable(cell) != &"":
		return false
	# Una reserva de 0 desde el principio no tiene qué entregar: nace agotada.
	_states[cell] = State.ACTIVE if reserve_left(cell) > 0 else State.DEPLETED
	site_changed.emit(cell)
	return true


## RF-423: cada punto activo entrega `min(producción, reserva)` y baja su reserva. Devuelve lo producido
## por punto (celda → cantidad, solo los que entregaron algo). El que llega a 0 queda agotado.
## Se llama una vez por oleada realmente completada, nunca por esperar ni al saltar de oleada.
func complete_wave() -> Dictionary:
	var produced: Dictionary = {}
	var cells: Array = _reserves.keys()
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	for cell: Vector2i in cells:
		if _states[cell] != State.ACTIVE:
			continue
		var amount: int = mini(_specs[cell].production, _reserves[cell])
		_reserves[cell] -= amount
		if _reserves[cell] <= 0:
			_states[cell] = State.DEPLETED
		if amount > 0:
			produced[cell] = amount
		site_changed.emit(cell)
	return produced


## Las celdas de los puntos de extracción, en orden de fila y columna.
func extraction_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in _reserves:
		cells.append(cell)
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return cells


## Lo que le queda al punto (0 si no es de extracción).
func reserve_left(cell: Vector2i) -> int:
	return _reserves.get(cell, 0)
