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
## RF-424: la reserva se lee como segmentos que se vacían; el color dice el estado del punto.
const SEGMENT_FULL := Color(0.45, 0.9, 0.4)
const SEGMENT_EMPTY := Color(0.2, 0.17, 0.14, 0.9)
const SEGMENT_SIZE := Vector2(4, 6)
const SEGMENT_GAP: float = 1.0
const MAX_SEGMENTS: int = 8

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
	infra.field.site_changed.connect(func(_cell: Vector2i) -> void: queue_redraw())
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
	_draw_extraction_sites(tile)
	for cell: Vector2i in _fading:
		var alpha: float = clampf(_fading[cell] / FADE_SECONDS, 0.0, 1.0)
		draw_rect(Rect2(_origin(cell), Vector2(tile, tile)), Color(DUST, 0.7 * alpha))


func _origin(cell: Vector2i) -> Vector2:
	return _level.cell_center(cell) - to_global(Vector2.ZERO) - Vector2.ONE * Rules.TILE_SIZE / 2.0


## RF-424 (vista provisional, el arte final es T220): sin habilitar = velo gris y candado de color bronce;
## activa = marco verde y la reserva en segmentos; agotada = velo oscuro y segmentos vacíos.
func _draw_extraction_sites(tile: float) -> void:
	for cell: Vector2i in _infra.field.extraction_cells():
		var origin: Vector2 = _origin(cell)
		var rect := Rect2(origin, Vector2(tile, tile))
		var state: ObstacleField.State = _infra.field.state_of(cell)
		match state:
			ObstacleField.State.DISABLED:
				draw_rect(rect, Color(0.35, 0.35, 0.38, 0.45))
				draw_rect(rect.grow(-3.0), BAR_FILL, false, 1.5)
			ObstacleField.State.ACTIVE:
				draw_rect(rect.grow(-2.0), SEGMENT_FULL, false, 2.0)
			ObstacleField.State.DEPLETED:
				draw_rect(rect, Color(0.08, 0.07, 0.06, 0.6))
		var total: int = _infra.field.spec_at(cell).reserve
		if state != ObstacleField.State.DISABLED or total > 0:
			_draw_reserve(origin, tile, _infra.field.reserve_left(cell), total)


## Un segmento por unidad de reserva, hasta `MAX_SEGMENTS`; con más reserva, cada segmento vale varias.
func _draw_reserve(origin: Vector2, tile: float, left: int, total: int) -> void:
	if total <= 0:
		return
	var count: int = mini(total, MAX_SEGMENTS)
	var filled: int = ceili(float(left) * count / total)
	var width: float = count * (SEGMENT_SIZE.x + SEGMENT_GAP) - SEGMENT_GAP
	var start: Vector2 = origin + Vector2((tile - width) / 2.0, tile - 10.0)
	draw_rect(Rect2(start - Vector2(2, 2), Vector2(width + 4, SEGMENT_SIZE.y + 4)), BAR_BACK)
	for i: int in count:
		var pos: Vector2 = start + Vector2(i * (SEGMENT_SIZE.x + SEGMENT_GAP), 0)
		draw_rect(Rect2(pos, SEGMENT_SIZE), SEGMENT_FULL if i < filled else SEGMENT_EMPTY)
