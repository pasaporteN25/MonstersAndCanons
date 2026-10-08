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

var _specs: Dictionary = {}  # Vector2i → ObstacleSpec
var _states: Dictionary = {}  # Vector2i → State
## RF-417: el resultado del sorteo de cada removible, fijado al empezar.
var _drops: Dictionary = {}  # Vector2i → bool
var _recovered: Dictionary = {}
var _source: StringName = &""
var _job: DemolitionJob


## RF-417: sortea ahora el drop de cada removible, en orden de fila y columna. `recovered` dice qué
## colecciones ya no entregan pieza (ya recuperada, o no se recogen en este contexto, RF-428 y RF-429).
## `source` es el id del nivel: identifica la pieza (RF-426).
func setup(specs: Array[ObstacleSpec], rng: RandomNumberGenerator, recovered: Dictionary = {},
		source: StringName = &"") -> void:
	_specs.clear()
	_states.clear()
	_drops.clear()
	_job = null
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
	return 0 if spec == null else spec.cost


func seconds_of(cell: Vector2i) -> float:
	var spec: ObstacleSpec = _specs.get(cell)
	return 0.0 if spec == null else spec.seconds


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
