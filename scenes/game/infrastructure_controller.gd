# Pegamento de la demolición directa con la partida (RF-404 a RF-409): es dueño del ObstacleField,
# cobra y reembolsa en LevelSession, despeja la casilla del mapa y avisa a la vista y al panel con
# señales. Hermano de BuildController. Va como nodo PAUSABLE: `Engine.time_scale` ya escala el
# `delta`, así que la pausa y la velocidad se respetan sin código extra (RF-406).
class_name InfrastructureController
extends Node

## No hay casilla elegida.
const NONE := Vector2i(-1, -1)
const REWARD_COLOR := Color(0.55, 0.95, 0.5)

## Cambió el removible elegido (`NONE` = ninguno). El HUD abre o cierra el panel.
signal selection_changed(cell: Vector2i)
## Terminó una demolición: la casilla ya es pasto. `reward` es la de `ObstacleField.reward_of`.
signal demolished(cell: Vector2i, reward: Dictionary)
## RF-423: al completarse una oleada, lo que entregó cada punto (celda → recursos).
signal produced_resources(produced: Dictionary)
## Cambió el estado de algún obstáculo (para refrescar el panel).
signal changed

var field: ObstacleField = ObstacleField.new()
var _level: Level
var _session: LevelSession
var _effects: Node
var _selected: Vector2i = NONE
var machine_enabled: bool = false


## `rng` es el generador con semilla de la partida (RF-417); `recovered` y `source`, de ObstacleField.
func setup(level: Level, session: LevelSession, specs: Array[ObstacleSpec], rng: RandomNumberGenerator,
		effects: Node, recovered: Dictionary = {}, source: StringName = &"", enable_machine: bool = false) -> void:
	_level = level
	_session = session
	_effects = effects
	machine_enabled = enable_machine
	field.setup(specs, rng, recovered, source)
	field.job_finished.connect(_on_job_finished)
	field.job_cancelled.connect(func(_cell: Vector2i, _refund: int) -> void: changed.emit())
	field.job_started.connect(func(_cell: Vector2i) -> void: changed.emit())
	field.job_progress.connect(func(_cell: Vector2i, _fraction: float) -> void: changed.emit())
	field.site_changed.connect(func(_cell: Vector2i) -> void: changed.emit())
	session.gold_changed.connect(func(_gold: int) -> void: changed.emit())
	session.wave_completed.connect(_on_wave_completed)


## RF-411 a RF-413: cobra la máquina una sola vez; el campo solo registra la compra.
func buy_machine() -> bool:
	if not machine_enabled or _session.is_over() or field.has_machine:
		return false
	if not _session.spend(field.machine_price()):
		return false
	if not field.buy_machine():
		_session.earn(field.machine_price())
		return false
	changed.emit()
	return true


func _process(delta: float) -> void:
	if field.has_job() and not _session.is_over():
		field.tick(delta)


# --- Elegir (RF-404) ---

## El removible o punto de extracción de `cell` si se puede elegir: un removible ya despejado es pasto
## y no se elige; un punto de extracción se elige siempre, también agotado (RF-422).
func obstacle_at(cell: Vector2i) -> ObstacleSpec:
	if field.is_extraction(cell):
		return field.spec_at(cell)
	if not field.is_removable(cell) or field.state_of(cell) == ObstacleField.State.CLEARED:
		return null
	return field.spec_at(cell)


func selected_cell() -> Vector2i:
	return _selected


func has_selection() -> bool:
	return _selected != NONE


func select(cell: Vector2i) -> void:
	if obstacle_at(cell) == null or cell == _selected:
		return
	_selected = cell
	selection_changed.emit(cell)


func deselect() -> void:
	if _selected == NONE:
		return
	_selected = NONE
	selection_changed.emit(NONE)


# --- Demoler y cancelar (RF-405, RF-407) ---

## Cobra al ordenar (RF-405). Devuelve false, sin cambiar nada, si no se puede ordenar o no alcanza el oro.
func order(cell: Vector2i) -> bool:
	if _session.is_over() or field.can_order(cell) != &"":
		return false
	if not _session.spend(field.cost_of(cell)):
		return false
	return field.order(cell) != null


## RF-422: cobra el oro y deja activo el punto de extracción. Es inmediato, no se cancela ni se devuelve.
## Devuelve false, sin cambiar nada, si no se puede habilitar o no alcanza el oro.
func enable(cell: Vector2i) -> bool:
	if _session.is_over() or field.can_enable(cell) != &"":
		return false
	if not _session.spend(field.cost_of(cell)):
		return false
	return field.enable_site(cell)


## RF-423: una oleada realmente completada (no un salto, RF-319) hace producir a cada punto activo.
func _on_wave_completed(_wave: int, _bonus: int) -> void:
	var produced: Dictionary = field.complete_wave()
	for cell: Vector2i in produced:
		var amount: int = produced[cell]
		_session.add_resources(amount)
		if _effects != null:
			var text := FloatingText.new().setup("+%d %s" % [amount, "recurso" if amount == 1 else "recursos"], REWARD_COLOR, 18, 0.9, 34.0)
			text.position = _level.cell_center(cell) + Vector2(0, -20)
			_effects.add_child(text)
	if not produced.is_empty():
		produced_resources.emit(produced)
	changed.emit()


## RF-407: devuelve todo el oro pagado. Devuelve false si no hay trabajo.
func cancel_job() -> bool:
	if not field.has_job() or _session.is_over():
		return false
	_session.earn(field.cancel())
	return true


## RF-409: al terminar la partida el trabajo se pierde sin entregar nada ni devolver el oro.
func discard_job() -> void:
	field.discard_job()
	deselect()


func _on_job_finished(cell: Vector2i, reward: Dictionary) -> void:
	_level.clear_removable(cell)  # RF-408: pasto construible
	# RF-408 y RF-415: los recursos entran a la sesión una sola vez (la casilla ya no se puede volver a demoler).
	# La pieza de colección la conecta T211.
	var resources: int = reward.get("resources", 0)
	_session.add_resources(resources)
	if resources > 0 and _effects != null:
		var text := FloatingText.new().setup("+%d %s" % [resources, "recurso" if resources == 1 else "recursos"], REWARD_COLOR, 18, 0.9, 34.0)
		text.position = _level.cell_center(cell) + Vector2(0, -20)
		_effects.add_child(text)
	Audio.play(&"build")  # RF-408: un sonido que ya existe
	if cell == _selected:
		_selected = NONE
		selection_changed.emit(NONE)  # el panel se cierra
	demolished.emit(cell, reward)
	changed.emit()
