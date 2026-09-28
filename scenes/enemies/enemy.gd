# Un enemigo: avanza por su camino, muere o escapa (plan §6.2).
# No suma oro ni resta vidas: avisa con señales y Game decide (constitución P6).
class_name Enemy
extends Area2D

## Llegó a la salida (RF-11). Quien escuche decide cuántas vidas restar.
signal reached_exit(enemy: Enemy)

const GROUP: StringName = &"enemies"
## Capas de colisión (plan §6.3): las torres "ven" a los enemigos por estas capas.
const LAYER_GROUND: int = 2
const LAYER_AIR: int = 3

var data: EnemyData
var max_health: int = 0
var health: int = 0
## Píxeles recorridos desde el inicio del camino.
var distance: float = 0.0

var _path: Path2D
## Evita avisar dos veces: tras queue_free() el nodo sigue vivo hasta el final del frame.
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
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(LAYER_AIR if data.is_flying else LAYER_GROUND, true)
	var shape := CircleShape2D.new()
	shape.radius = Rules.tiles_to_px(data.size_tiles)
	$CollisionShape2D.shape = shape
	_update_position()


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	distance += Rules.tiles_to_px(data.speed_tiles) * delta
	_update_position()
	if distance >= _path.curve.get_baked_length():
		_is_done = true
		reached_exit.emit(self)
		queue_free()


func _update_position() -> void:
	global_position = _path.to_global(_path.curve.sample_baked(distance))


# --- Dibujo provisional con formas (D-002) ---

func _draw() -> void:
	var r: float = Rules.tiles_to_px(data.size_tiles)
	var outline: Color = data.color.darkened(0.45)
	match data.shape:
		EnemyData.Shape.CIRCLE:
			draw_circle(Vector2.ZERO, r, data.color)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, outline, 2.0)
		EnemyData.Shape.SQUARE:
			var rect := Rect2(-r, -r, r * 2.0, r * 2.0)
			draw_rect(rect, data.color)
			draw_rect(rect, outline, false, 2.0)
		EnemyData.Shape.TRIANGLE:
			_draw_regular_polygon(3, r, outline)
		EnemyData.Shape.DIAMOND:
			_draw_regular_polygon(4, r, outline)
		EnemyData.Shape.HEXAGON:
			_draw_regular_polygon(6, r, outline)


func _draw_regular_polygon(sides: int, r: float, outline: Color) -> void:
	var points := PackedVector2Array()
	for i: int in sides:
		points.append(Vector2.from_angle(-PI / 2.0 + TAU * i / sides) * r)
	draw_colored_polygon(points, data.color)
	points.append(points[0])
	draw_polyline(points, outline, 2.0)
