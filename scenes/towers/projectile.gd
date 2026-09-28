# Proyectil teledirigido que siempre impacta (plan §6.4, D-008).
class_name Projectile
extends Node2D

## Llegó a destino. Solo para efectos visuales (RF-122): el daño ya se aplicó.
signal impacted(position: Vector2, stats: TowerLevelData)

## RF-153: lado del dibujo del proyectil, en píxeles.
const SPRITE_SIZE_PX: float = 28.0

var _target: Enemy
var _target_pos: Vector2
var _start_pos: Vector2
var _stats: TowerLevelData
var _can_hit_air: bool = false
var _speed_px: float = 0.0
var _color: Color = Color.WHITE
var _texture: Texture2D
var _is_done: bool = false


## Se llama ANTES de agregar el proyectil al árbol.
## `stats` son los valores de la torre en el momento de disparar.
## `texture`: el dibujo del proyectil (RF-153); sin dibujo, un círculo de `color`.
func setup(target: Enemy, start_pos: Vector2, stats: TowerLevelData, can_hit_air: bool,
		speed_tiles: float, color: Color, texture: Texture2D = null) -> void:
	_target = target
	_target_pos = target.global_position
	_start_pos = start_pos
	_stats = stats
	_can_hit_air = can_hit_air
	_speed_px = Rules.tiles_to_px(speed_tiles)
	_color = color
	_texture = texture


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	global_position = _start_pos
	_face(_target_pos)


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	# RF-52: persigue al objetivo; si ya no existe, va al último lugar donde estaba.
	if is_instance_valid(_target) and _target.is_active():
		_target_pos = _target.global_position
	var step: float = _speed_px * delta
	if global_position.distance_to(_target_pos) <= step:
		global_position = _target_pos
		_is_done = true
		_impact()
		impacted.emit(global_position, _stats)
		queue_free()
	else:
		_face(_target_pos)
		global_position = global_position.move_toward(_target_pos, step)


func _impact() -> void:
	if _stats.splash_radius_tiles > 0.0:
		# Daño en área: todos los enemigos dentro del radio, aunque el objetivo ya no exista.
		var radius: float = Rules.tiles_to_px(_stats.splash_radius_tiles)
		for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
			var enemy := node as Enemy
			if not enemy.is_active():
				continue
			if enemy.data.is_flying and not _can_hit_air:
				continue  # RF-53
			if enemy.global_position.distance_to(global_position) <= radius:
				_hit(enemy)
	elif is_instance_valid(_target) and _target.is_active():
		_hit(_target)
	# Sin área y sin objetivo: desaparece sin hacer daño (RF-52).


func _hit(enemy: Enemy) -> void:
	enemy.take_hit(_stats.damage, _stats.slow_amount, _stats.slow_duration)


## RF-153: gira el proyectil (y su dibujo) hacia donde viaja. Solo visual.
func _face(point: Vector2) -> void:
	if not global_position.is_equal_approx(point):
		rotation = (point - global_position).angle()


func _draw() -> void:
	if _texture != null:
		var half: float = SPRITE_SIZE_PX / 2.0
		draw_texture_rect(_texture, Rect2(-half, -half, SPRITE_SIZE_PX, SPRITE_SIZE_PX), false)
		return
	var radius: float = 6.0 if _stats.splash_radius_tiles > 0.0 else 4.0
	draw_circle(Vector2.ZERO, radius, _color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 16, Color(1, 1, 1, 0.8), 1.5)
