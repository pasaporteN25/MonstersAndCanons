# Proyectil teledirigido que siempre impacta (plan §6.4, D-008).
class_name Projectile
extends Node2D

## Llegó a destino. Solo para efectos visuales (RF-122): el daño ya se aplicó.
signal impacted(position: Vector2, stats: TowerLevelData)

var _target: Enemy
var _target_pos: Vector2
var _start_pos: Vector2
var _stats: TowerLevelData
var _can_hit_air: bool = false
var _speed_px: float = 0.0
var _color: Color = Color.WHITE
var _is_done: bool = false


## Se llama ANTES de agregar el proyectil al árbol.
## `stats` son los valores de la torre en el momento de disparar.
func setup(target: Enemy, start_pos: Vector2, stats: TowerLevelData, can_hit_air: bool,
		speed_tiles: float, color: Color) -> void:
	_target = target
	_target_pos = target.global_position
	_start_pos = start_pos
	_stats = stats
	_can_hit_air = can_hit_air
	_speed_px = Rules.tiles_to_px(speed_tiles)
	_color = color


func _ready() -> void:
	global_position = _start_pos


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


func _draw() -> void:
	var radius: float = 6.0 if _stats.splash_radius_tiles > 0.0 else 4.0
	draw_circle(Vector2.ZERO, radius, _color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 16, Color(1, 1, 1, 0.8), 1.5)
