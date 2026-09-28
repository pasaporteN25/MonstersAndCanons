# Un enemigo: avanza por su camino, recibe golpes, se ralentiza, muere o escapa (plan §6.2).
# No suma oro ni resta vidas: avisa con señales y Game decide (constitución P6).
class_name Enemy
extends Node2D

## Murió por daño (RF-81). Quien escuche decide cuánto oro dar.
signal died(enemy: Enemy)
## Llegó a la salida (RF-11). Quien escuche decide cuántas vidas restar.
signal reached_exit(enemy: Enemy)

const GROUP: StringName = &"enemies"
## Color al que se tiñe un enemigo ralentizado (RF-62).
const SLOW_TINT := Color(0.45, 0.72, 1.0)
const HEALTH_BAR_HEIGHT: float = 5.0

var data: EnemyData
var max_health: int = 0
var health: int = 0
## Píxeles recorridos desde el inicio del camino.
var distance: float = 0.0

var _path: Path2D
var _slow_amount: float = 0.0
var _slow_left: float = 0.0
## Evita actuar dos veces: tras queue_free() el nodo sigue vivo hasta el final del frame.
var _is_done: bool = false


## Se llama ANTES de agregar el enemigo al árbol.
## `scaled_health` ya viene calculada según la oleada (RF-36).
func setup(enemy_data: EnemyData, path: Path2D, scaled_health: int) -> void:
	data = enemy_data
	_path = path
	max_health = scaled_health
	health = scaled_health


func _ready() -> void:
	add_to_group(GROUP)
	_update_position()


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	_update_slow(delta)
	distance += Rules.tiles_to_px(current_speed_tiles()) * delta
	_update_position()
	if distance >= _path.curve.get_baked_length():
		_is_done = true
		reached_exit.emit(self)
		queue_free()


## false si ya murió o escapó (aunque el nodo todavía no se haya borrado).
func is_active() -> bool:
	return not _is_done


func is_slowed() -> bool:
	return _slow_left > 0.0


## RF-60: velocidad × (1 − ralentización).
func current_speed_tiles() -> float:
	return data.speed_tiles * (1.0 - _slow_amount)


## Píxeles que le faltan para llegar a la salida. Sirve para apuntar al "Primero" (RF-51).
func remaining_distance() -> float:
	return _path.curve.get_baked_length() - distance


## RF-82: la barra de vida solo aparece después del primer golpe.
func is_health_bar_visible() -> bool:
	return health < max_health


## Recibe un golpe (RF-80) y, si lo trae, una ralentización (RF-60, RF-61).
func take_hit(damage: int, slow_amount: float = 0.0, slow_duration: float = 0.0) -> void:
	if _is_done:
		return
	health = maxi(0, health - Rules.damage_after_armor(damage, data.armor))
	if slow_amount > 0.0:
		_apply_slow(Rules.effective_slow(slow_amount, data.slow_resistance), slow_duration)
	queue_redraw()
	if health == 0:
		_is_done = true
		died.emit(self)
		queue_free()


## RF-61: las ralentizaciones no se suman; queda la más fuerte y la duración se reinicia.
func _apply_slow(amount: float, duration: float) -> void:
	_slow_amount = maxf(_slow_amount, amount)
	_slow_left = duration


func _update_slow(delta: float) -> void:
	if _slow_left <= 0.0:
		return
	_slow_left -= delta
	if _slow_left <= 0.0:
		_slow_left = 0.0
		_slow_amount = 0.0
		queue_redraw()


func _update_position() -> void:
	global_position = _path.to_global(_path.curve.sample_baked(distance))


# --- Dibujo provisional con formas (D-002) ---

func _draw() -> void:
	var r: float = Rules.tiles_to_px(data.size_tiles)
	var fill: Color = data.color.lerp(SLOW_TINT, 0.6) if is_slowed() else data.color
	var outline: Color = fill.darkened(0.45)
	match data.shape:
		EnemyData.Shape.CIRCLE:
			draw_circle(Vector2.ZERO, r, fill)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, outline, 2.0)
		EnemyData.Shape.SQUARE:
			var rect := Rect2(-r, -r, r * 2.0, r * 2.0)
			draw_rect(rect, fill)
			draw_rect(rect, outline, false, 2.0)
		EnemyData.Shape.TRIANGLE:
			_draw_regular_polygon(3, r, fill, outline)
		EnemyData.Shape.DIAMOND:
			_draw_regular_polygon(4, r, fill, outline)
		EnemyData.Shape.HEXAGON:
			_draw_regular_polygon(6, r, fill, outline)
	if is_health_bar_visible():
		_draw_health_bar(r)


func _draw_regular_polygon(sides: int, r: float, fill: Color, outline: Color) -> void:
	var points := PackedVector2Array()
	for i: int in sides:
		points.append(Vector2.from_angle(-PI / 2.0 + TAU * i / sides) * r)
	draw_colored_polygon(points, fill)
	points.append(points[0])
	draw_polyline(points, outline, 2.0)


## RF-82: barra verde sobre fondo rojo oscuro, encima del enemigo.
func _draw_health_bar(r: float) -> void:
	var width: float = maxf(r * 2.0, 24.0)
	var top_left := Vector2(-width / 2.0, -r - HEALTH_BAR_HEIGHT - 4.0)
	draw_rect(Rect2(top_left, Vector2(width, HEALTH_BAR_HEIGHT)), Color(0.35, 0.05, 0.05))
	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(top_left, Vector2(width * ratio, HEALTH_BAR_HEIGHT)), Color(0.3, 0.9, 0.3))
