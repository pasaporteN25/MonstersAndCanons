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
## Cambió el estado de algún obstáculo (para refrescar el panel).
signal changed

var field: ObstacleField = ObstacleField.new()
var _level: Level
var _session: LevelSession
var _effects: Node
var _selected: Vector2i = NONE
## RF-429: ¿en esta partida se recogen piezas? Si no, la ruina se comporta como "ya recuperada".
var _collects_pieces: bool = true


## `rng` es el generador con semilla de la partida (RF-417); `recovered` y `source`, de ObstacleField.
func setup(level: Level, session: LevelSession, specs: Array[ObstacleSpec], rng: RandomNumberGenerator,
		effects: Node, recovered: Dictionary = {}, source: StringName = &"", collects_pieces: bool = true) -> void:
	_collects_pieces = collects_pieces
	_level = level
	_session = session
	_effects = effects
	field.setup(specs, rng, recovered, source)
	field.job_finished.connect(_on_job_finished)
	field.job_cancelled.connect(func(_cell: Vector2i, _refund: int) -> void: changed.emit())
	field.job_started.connect(func(_cell: Vector2i) -> void: changed.emit())
	field.job_progress.connect(func(_cell: Vector2i, _fraction: float) -> void: changed.emit())
	session.gold_changed.connect(func(_gold: int) -> void: changed.emit())


func _process(delta: float) -> void:
	if field.has_job() and not _session.is_over():
		field.tick(delta)


# --- Elegir (RF-404) ---

## El removible de `cell` si se puede elegir: uno ya despejado es pasto y no se elige.
func obstacle_at(cell: Vector2i) -> ObstacleSpec:
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


func _float_text(cell: Vector2i, message: String) -> void:
	if _effects == null:
		return
	var text := FloatingText.new().setup(message, REWARD_COLOR, 18, 0.9, 34.0)
	text.position = _level.cell_center(cell) + Vector2(0, -20)
	_effects.add_child(text)


func _on_job_finished(cell: Vector2i, reward: Dictionary) -> void:
	_level.clear_removable(cell)  # RF-408: pasto construible
	# Los recursos los suma a la sesión T209; la pieza la recoge `Game` con la señal `demolished` (T211).
	var resources: int = reward.get("resources", 0)
	if resources > 0:
		_float_text(cell, "+%d %s" % [resources, "recurso" if resources == 1 else "recursos"])
	if not (reward.get("finding", {}) as Dictionary).is_empty() and _collects_pieces:
		_float_text(cell, "¡Pieza encontrada!")
	Audio.play(&"build")  # RF-408: un sonido que ya existe
	if cell == _selected:
		_selected = NONE
		selection_changed.emit(NONE)  # el panel se cierra
	demolished.emit(cell, reward)
	changed.emit()
