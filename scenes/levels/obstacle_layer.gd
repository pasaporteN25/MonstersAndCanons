# Vista provisional del trabajo de demolición (RF-406, RF-408): una barra de progreso sobre la casilla
# en trabajo y un velo que se desvanece al terminar. Solo dibuja: escucha al InfrastructureController.
# Hasta que llegue el arte final (T219 a T221) usa figuras simples.
class_name ObstacleLayer
extends Node2D

const BAR_SIZE := Vector2(44, 8)
const FADE_SECONDS: float = 0.5
const BAR_BACK := Color(0.11, 0.09, 0.07, 0.85)
const BAR_FILL := Color(0.94, 0.65, 0.16)
const DUST := Color(0.69, 0.54, 0.37)

var _infra: InfrastructureController
var _level: Level
var _working: Vector2i = InfrastructureController.NONE
var _progress: float = 0.0
## Casillas que se acaban de despejar: celda → segundos que faltan para que el velo desaparezca.
var _fading: Dictionary = {}


func setup(infra: InfrastructureController, level: Level) -> void:
	_infra = infra
	_level = level
	infra.field.job_started.connect(func(cell: Vector2i) -> void:
		_working = cell
		_progress = 0.0
		queue_redraw())
	infra.field.job_progress.connect(func(_cell: Vector2i, fraction: float) -> void:
		_progress = fraction
		queue_redraw())
	infra.field.job_cancelled.connect(func(_cell: Vector2i, _refund: int) -> void:
		_working = InfrastructureController.NONE
		queue_redraw())
	infra.demolished.connect(func(cell: Vector2i, _reward: Dictionary) -> void:
		_working = InfrastructureController.NONE
		_fading[cell] = FADE_SECONDS
		queue_redraw())


func is_working() -> bool:
	return _working != InfrastructureController.NONE


func _process(delta: float) -> void:
	if _fading.is_empty():
		return
	for cell: Vector2i in _fading.keys():
		_fading[cell] -= delta
		if _fading[cell] <= 0.0:
			_fading.erase(cell)
	queue_redraw()


func _draw() -> void:
	var tile: float = Rules.TILE_SIZE
	if is_working():
		var origin: Vector2 = _origin(_working)
		draw_rect(Rect2(origin, Vector2(tile, tile)), Color(0, 0, 0, 0.3))
		var bar_pos: Vector2 = origin + Vector2((tile - BAR_SIZE.x) / 2.0, tile - 14.0)
		draw_rect(Rect2(bar_pos - Vector2.ONE, BAR_SIZE + Vector2.ONE * 2.0), BAR_BACK)
		draw_rect(Rect2(bar_pos, Vector2(BAR_SIZE.x * _progress, BAR_SIZE.y)), BAR_FILL)
	for cell: Vector2i in _fading:
		var alpha: float = clampf(_fading[cell] / FADE_SECONDS, 0.0, 1.0)
		draw_rect(Rect2(_origin(cell), Vector2(tile, tile)), Color(DUST, 0.7 * alpha))


func _origin(cell: Vector2i) -> Vector2:
	return _level.cell_center(cell) - to_global(Vector2.ZERO) - Vector2.ONE * Rules.TILE_SIZE / 2.0
