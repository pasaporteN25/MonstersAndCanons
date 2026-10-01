# Proyectil teledirigido que siempre impacta (plan §6.4, D-008).
class_name Projectile
extends Node2D

## Llegó a destino. Solo para efectos visuales (RF-122): el daño ya se aplicó.
signal impacted(position: Vector2, stats: TowerLevelData)
## El golpe saltó de enemigo en enemigo (RF-163). `points`: dónde estaba cada golpeado. Solo visual.
signal chained(points: PackedVector2Array)

## RF-153: lado del dibujo del proyectil, en píxeles.
const SPRITE_SIZE_PX: float = 28.0
## RF-162: una púa toca a un enemigo si pasa a menos de (su radio + este margen).
const STRAIGHT_HIT_MARGIN_PX: float = 4.0
## Rendimiento (T85): una púa solo revisa a los enemigos que al salir estaban a menos de
## (su recorrido + este margen): lo que un enemigo rápido camina mientras la púa vuela.
const STRAIGHT_CANDIDATE_MARGIN_PX: float = 96.0

## RF-284: la torre que disparó (el Espejo la necesita para devolverle el tiro). null = ninguna.
var source: Tower
var _target: Enemy
var _target_pos: Vector2
var _start_pos: Vector2
var _stats: TowerLevelData
var _can_hit_air: bool = false
var _speed_px: float = 0.0
var _color: Color = Color.WHITE
var _texture: Texture2D
var _is_done: bool = false
## RF-162: si no es cero, el proyectil va en LÍNEA RECTA en esa dirección (no persigue a nadie)
## y golpea al primer enemigo que toca, o se pierde al recorrer `_max_distance`.
var _direction := Vector2.ZERO
var _max_distance: float = 0.0
var _traveled: float = 0.0
## Los enemigos que esta púa puede llegar a tocar (se anotan al salir).
var _candidates: Array[Enemy] = []
var _has_candidates: bool = false


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


## RF-162: en vez de perseguir a un objetivo, sale en línea recta hacia `direction`.
func setup_straight(start_pos: Vector2, direction: Vector2, stats: TowerLevelData, can_hit_air: bool,
		speed_tiles: float, max_distance: float, color: Color, texture: Texture2D = null,
		candidates: Variant = null) -> void:
	# `candidates`: los enemigos cercanos, si quien dispara ya los buscó (la Ráfaga los busca
	# una vez para todas sus púas). Si no, la púa los busca sola al salir.
	if candidates != null:
		_candidates = candidates
		_has_candidates = true
	_start_pos = start_pos
	_target_pos = start_pos + direction.normalized() * max_distance
	_direction = direction.normalized()
	_max_distance = max_distance
	_stats = stats
	_can_hit_air = can_hit_air
	_speed_px = Rules.tiles_to_px(speed_tiles)
	_color = color
	_texture = texture


func is_straight() -> bool:
	return _direction != Vector2.ZERO


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	global_position = _start_pos
	_face(_target_pos)
	if is_straight() and not _has_candidates:
		_candidates = enemies_near(get_tree(), _start_pos, _max_distance + STRAIGHT_CANDIDATE_MARGIN_PX, _can_hit_air)


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	if is_straight():
		_move_straight(delta)
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


## RF-162: avanza en línea recta; al tocar a un enemigo que puede golpear, impacta ahí.
func _move_straight(delta: float) -> void:
	var step: float = _speed_px * delta
	global_position += _direction * step
	_traveled += step
	var touched: Enemy = _first_enemy_touching()
	if touched != null:
		_target = touched
		_is_done = true
		_impact()  # si además tiene área, explota ahí (RF-164: se combina)
		impacted.emit(global_position, _stats)
		queue_free()
	elif _traveled >= _max_distance:
		_is_done = true  # no tocó a nadie: se pierde
		queue_free()


## Revisar a los 200 enemigos en cada cuadro, por cada púa, bajaba el juego a 58 FPS con
## muchas Ráfagas: por eso se anotan una sola vez los que están cerca de su recorrido.
static func enemies_near(tree: SceneTree, center: Vector2, reach: float, can_hit_air: bool) -> Array[Enemy]:
	var list: Array[Enemy] = []
	for node: Node in tree.get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if not enemy.is_active() or (enemy.data.is_flying and not can_hit_air):
			continue
		if enemy.global_position.distance_squared_to(center) <= reach * reach:
			list.append(enemy)
	return list


func _first_enemy_touching() -> Enemy:
	for enemy: Enemy in _candidates:
		if not is_instance_valid(enemy) or not enemy.is_active():
			continue
		var reach: float = Rules.tiles_to_px(enemy.data.size_tiles) + STRAIGHT_HIT_MARGIN_PX
		if enemy.global_position.distance_squared_to(global_position) <= reach * reach:
			return enemy
	return null


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
		if _stats.chain_extra_targets > 0:
			_chain_from(_target)
	# Sin área y sin objetivo: desaparece sin hacer daño (RF-52).


## RF-163: desde el primer golpeado, salta al enemigo más cercano que todavía no golpeó,
## si está a menos de `chain_range_tiles`. Cada salto hace el mismo golpe.
func _chain_from(first: Enemy) -> void:
	var reach: float = Rules.tiles_to_px(_stats.chain_range_tiles)
	var struck: Array[Enemy] = [first]
	var points := PackedVector2Array([first.global_position])
	for i: int in _stats.chain_extra_targets:
		var next: Enemy = _nearest_not_struck(points[points.size() - 1], struck, reach)
		if next == null:
			break
		struck.append(next)
		points.append(next.global_position)
		_hit(next)
	if points.size() > 1:
		chained.emit(points)


func _nearest_not_struck(from: Vector2, struck: Array[Enemy], reach: float) -> Enemy:
	var best: Enemy = null
	var best_dist: float = reach * reach
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if not enemy.is_active() or struck.has(enemy) or (enemy.data.is_flying and not _can_hit_air):
			continue
		var dist: float = from.distance_squared_to(enemy.global_position)
		if dist <= best_dist:
			best = enemy
			best_dist = dist
	return best


func _hit(enemy: Enemy) -> void:
	if is_instance_valid(source) and enemy.will_reflect(source):  # la torre pudo venderse mientras volaba
		enemy.reflect(source)  # RF-284: ni daño ni ralentización; la torre queda aturdida
	else:
		# RF-311: el estado se mira ANTES de aplicar lo que trae este golpe, y el bonus va antes de la armadura.
		var slowed_bonus: int = _stats.bonus_vs_slowed_percent if enemy.is_slowed() else 0
		var burning_bonus: int = _stats.bonus_vs_burning_percent if enemy.is_burning() else 0
		# RF-315: el aviso lleva el color del estado que dio más bonus (si empatan, el ralentizado).
		var combo: Enemy.Combo = Enemy.Combo.NONE
		if slowed_bonus + burning_bonus > 0:
			combo = Enemy.Combo.SLOWED if slowed_bonus >= burning_bonus else Enemy.Combo.BURNING
		var damage: int = Rules.damage_with_bonus(_stats.damage, slowed_bonus + burning_bonus)
		enemy.take_hit(damage, _stats.slow_amount, _stats.slow_duration, combo)
	if _stats.burn_damage_per_second > 0:
		enemy.apply_burn(_stats.burn_damage_per_second, _stats.burn_duration)  # RF-160 (la quemadura no rebota, RF-284)


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
