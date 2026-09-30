# Una torre: busca un objetivo dentro de su alcance y le dispara según su cadencia (plan §6.3).
# UNA sola escena para todas las torres: lo que cambia son sus datos (D-006).
# No sabe dónde van los proyectiles: los crea y avisa con `fired` (constitución P6).
class_name Tower
extends Node2D

signal fired(projectile: Projectile)

## RF-54: a qué enemigo apunta, entre los que están en su alcance.
enum TargetMode { FIRST, LAST, STRONGEST, CLOSEST }
const TARGET_MODE_NAMES: Array[String] = ["Primero", "Último", "Más fuerte", "Más cercano"]

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
## Lado del cuadrado que se dibuja, en casillas.
const BODY_SIZE_TILES: float = 0.8
## Qué tan rápido gira el cañón hacia su objetivo (más alto = más rápido).
const AIM_SPEED: float = 14.0
## Cuánto retrocede el cañón al disparar, en píxeles (RF-121).
const RECOIL_PX: float = 6.0
const FLASH_DURATION: float = 0.08
## Las torres están en este grupo: así un enemigo (el Chamán, RF-282) las encuentra.
const GROUP: StringName = &"towers"
## RF-280: aspecto de una torre aturdida (apagada, con chispas que giran encima).
const STUN_DIM := Color(0.06, 0.06, 0.1, 0.45)
const STUN_SPARK_COUNT: int = 3

var data: TowerData
## Nivel actual: 0 = nivel 1, 1 = nivel 2, 2 = nivel 3 (RF-71).
var level_index: int = 0
## Oro gastado en esta torre (construcción + mejoras). Sirve para vender (RF-72).
var total_invested: int = 0
var targeting: TargetMode = TargetMode.FIRST
## RF-293: casilla de arriba a la izquierda de la torre (la única, si ocupa una sola casilla).
var origin_cell: Vector2i = Vector2i.ZERO
## Hacia dónde apunta el cañón, en radianes (0 = derecha). Empieza mirando hacia arriba.
var aim_angle: float = -PI / 2.0

## Segundos hasta poder volver a disparar. Si es <= 0, dispara apenas haya objetivo.
var _cooldown: float = 0.0
## Último objetivo al que se disparó; el cañón lo sigue entre disparos (RF-120).
var _target: Enemy
## 1 = recién disparó, 0 = cañón en reposo.
var _recoil: float = 0.0
var _flash_left: float = 0.0
## RF-280: segundos que le quedan aturdida (no dispara mientras sea mayor que 0).
var _stun_left: float = 0.0
var _stun_anim: float = 0.0


## Se llama ANTES de agregar la torre al árbol.
func setup(tower_data: TowerData) -> void:
	data = tower_data
	total_invested = tower_data.levels[0].cost


func _ready() -> void:
	add_to_group(GROUP)
	# D-023: los dibujos se achican con suavidad (el mapa usa "Nearest" para no mostrar líneas).
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# RF-130: aparece creciendo desde el centro.
	scale = Vector2(0.2, 0.2)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## RF-155: ícono para la interfaz: la base de nivel 1 con la torreta mirando hacia arriba,
## como se ve la torre recién construida. null si a la torre le falta algún dibujo (RF-156).
static func make_icon(tower_data: TowerData) -> Texture2D:
	var base: Texture2D = tower_data.levels[0].base_texture if not tower_data.levels.is_empty() else null
	if base == null or tower_data.turret_texture == null:
		return null
	var image: Image = base.get_image()
	var turret: Image = tower_data.turret_texture.get_image()
	if image == null or turret == null:
		return null
	# Copias: get_image() puede devolver la misma imagen que guarda la textura, y cambiarla
	# cambiaría también la base que se ve en el mapa.
	image = image.duplicate()
	turret = turret.duplicate()
	# Se trabaja sin las copias achicadas (mipmaps) y se vuelven a generar al final.
	image.decompress()
	turret.decompress()
	image.clear_mipmaps()
	turret.clear_mipmaps()
	image.convert(Image.FORMAT_RGBA8)
	turret.convert(Image.FORMAT_RGBA8)
	turret.rotate_90(COUNTERCLOCKWISE)
	image.blend_rect(turret, Rect2i(Vector2i.ZERO, turret.get_size()), Vector2i.ZERO)
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


## RF-293: todas las casillas que ocupa, empezando por la de arriba a la izquierda.
func cells() -> Array[Vector2i]:
	return BuildController.footprint_cells(origin_cell, data.footprint)


func stats() -> TowerLevelData:
	return data.levels[level_index]


func range_px() -> float:
	return Rules.tiles_to_px(stats().range_tiles)


## Nivel que se ve (1, 2 o 3).
func level_number() -> int:
	return level_index + 1


func can_upgrade() -> bool:
	return level_index < data.levels.size() - 1


## Valores del próximo nivel, o null si ya está en el máximo.
func next_level_stats() -> TowerLevelData:
	return data.levels[level_index + 1] if can_upgrade() else null


## Sube un nivel. NO cobra: el oro lo maneja quien llama (BuildController).
func apply_upgrade() -> void:
	assert(can_upgrade(), "apply_upgrade() en una torre de nivel máximo")
	level_index += 1
	total_invested += stats().cost
	queue_redraw()


## RF-280: la aturde `seconds` segundos: no dispara hasta que pasen. No se suma: queda el que más dura.
func stun(seconds: float) -> void:
	if seconds <= 0.0:
		return
	_stun_left = maxf(_stun_left, seconds)
	queue_redraw()


func is_stunned() -> bool:
	return _stun_left > 0.0


## Segundos que le quedan aturdida (0 = no lo está).
func stun_left() -> float:
	return _stun_left


## RF-54: pasa al siguiente modo de apuntado (y vuelve al primero después del último).
func cycle_targeting() -> void:
	targeting = ((targeting + 1) % TargetMode.size()) as TargetMode


func targeting_name() -> String:
	return TARGET_MODE_NAMES[targeting]


func _physics_process(delta: float) -> void:
	if _target != null and not (is_instance_valid(_target) and can_target(_target)):
		_target = null
	_cooldown -= delta
	if _stun_left > 0.0:
		_stun_left = maxf(0.0, _stun_left - delta)
		_stun_anim += delta
		if _stun_left <= 0.0001:
			_stun_left = 0.0
			queue_redraw()
	if is_stunned():
		_animate(delta)  # RF-280: apagada, no dispara
		return
	if _cooldown <= 0.0 and stats().burst_count > 0:
		# RF-162: ráfaga en círculo, si hay alguien en alcance (no apunta a nadie en particular).
		if find_target() != null:
			_fire_burst()
			_cooldown = 1.0 / stats().fire_rate
	elif _cooldown <= 0.0:
		# RF-161: con `extra_targets`, además del mejor objetivo dispara a los siguientes.
		var targets: Array[Enemy] = find_targets(1 + stats().extra_targets)
		if not targets.is_empty():
			_target = targets[0]
			for target: Enemy in targets:
				_shoot(target)
			aim_angle = (_target.global_position - global_position).angle()  # mira al principal
			_cooldown = 1.0 / stats().fire_rate
	_animate(delta)


## RF-161: los `count` mejores objetivos en alcance, del mejor al peor según el modo de apuntado.
func find_targets(count: int) -> Array[Enemy]:
	var candidates: Array[Enemy] = []
	if count <= 1:  # lo común: alcanza con buscar el mejor, sin ordenar a todos
		var best: Enemy = find_target()
		if best != null:
			candidates.append(best)
		return candidates
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if can_target(enemy):
			candidates.append(enemy)
	candidates.sort_custom(_is_better_target)
	return candidates.slice(0, count)


## RF-51 y RF-54: el mejor objetivo en alcance según el modo de apuntado.
## Se mide la distancia a cada enemigo (D-014) en vez de usar áreas de colisión.
func find_target() -> Enemy:
	var best: Enemy = null
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if not can_target(enemy):
			continue
		if best == null or _is_better_target(enemy, best):
			best = enemy
	return best


## true si `a` es mejor objetivo que `b` según el modo actual.
func _is_better_target(a: Enemy, b: Enemy) -> bool:
	match targeting:
		TargetMode.LAST:
			return a.remaining_distance() > b.remaining_distance()
		TargetMode.STRONGEST:
			return a.health > b.health
		TargetMode.CLOSEST:
			var dist_a: float = global_position.distance_squared_to(a.global_position)
			return dist_a < global_position.distance_squared_to(b.global_position)
		_:  # FIRST: el que menos camino le falta
			return a.remaining_distance() < b.remaining_distance()


## RF-50 y RF-53: el enemigo sigue activo, está en alcance y, si vuela, la torre puede golpearlo.
func can_target(enemy: Enemy) -> bool:
	if not enemy.is_active():
		return false
	if enemy.data.is_flying and not data.can_hit_air:
		return false
	return global_position.distance_to(enemy.global_position) <= range_px()


func _shoot(target: Enemy) -> void:
	# El cañón apunta de golpe al disparar, así el proyectil nunca sale "de costado".
	aim_angle = (target.global_position - global_position).angle()
	_recoil = 1.0
	_flash_left = FLASH_DURATION
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(target, _barrel_tip_global(), stats(), data.can_hit_air,
		data.projectile_speed_tiles, data.color, data.projectile_texture)
	projectile.source = self  # RF-284
	fired.emit(projectile)


## RF-162: `burst_count` púas repartidas en círculo, en línea recta hasta el alcance.
## La torreta gira media separación en cada ráfaga, así las púas no salen siempre igual.
func _fire_burst() -> void:
	var count: int = stats().burst_count
	aim_angle += PI / count
	_recoil = 1.0
	_flash_left = FLASH_DURATION
	# Los enemigos que las púas pueden tocar se buscan una sola vez, para todas (rendimiento, T85).
	var nearby: Array[Enemy] = Projectile.enemies_near(get_tree(), global_position,
		range_px() + Projectile.STRAIGHT_CANDIDATE_MARGIN_PX, data.can_hit_air)
	for i: int in count:
		var direction := Vector2.from_angle(aim_angle + TAU * i / count)
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()
		projectile.setup_straight(global_position + direction * _barrel_length() * 0.6, direction, stats(),
			data.can_hit_air, data.projectile_speed_tiles, range_px() - _barrel_length() * 0.6, data.color,
			data.projectile_texture, nearby)
		projectile.source = self  # RF-284
		fired.emit(projectile)


# --- Animación y dibujo (solo visual, spec §9.3) ---

## RF-120 y RF-121: el cañón sigue al objetivo; el retroceso y el destello se apagan solos.
func _animate(delta: float) -> void:
	if _target != null:
		var desired: float = (_target.global_position - global_position).angle()
		aim_angle = lerp_angle(aim_angle, desired, minf(1.0, AIM_SPEED * delta))
	_recoil = move_toward(_recoil, 0.0, delta * 8.0)
	_flash_left = maxf(0.0, _flash_left - delta)
	queue_redraw()


## RF-295: lado de la torre en casillas (1 = la de siempre); lo que se dibuja se escala con él.
func _scale_factor() -> float:
	return float(data.footprint)


func _barrel_length() -> float:
	return Rules.TILE_SIZE * 0.48 * _scale_factor()


func _barrel_width() -> float:
	return Rules.TILE_SIZE * (0.22 if stats().splash_radius_tiles > 0.0 else 0.13) * _scale_factor()


func _barrel_tip_global() -> Vector2:
	return global_position + Vector2.from_angle(aim_angle) * _barrel_length()


func _outline_color() -> Color:
	# Las torres oscuras llevan borde claro, y las claras borde oscuro, para que siempre se vean.
	return data.color.lightened(0.45) if data.color.get_luminance() < 0.3 else data.color.darkened(0.5)


func _draw() -> void:
	var factor: float = _scale_factor()
	var half: float = Rules.tiles_to_px(BODY_SIZE_TILES) / 2.0 * factor
	var outline: Color = _outline_color()
	# RF-150: los dibujos ocupan una casilla entera (o el cuadrado entero, RF-295), centrados en la torre.
	var side: float = Rules.TILE_SIZE * factor
	var tile_rect := Rect2(-side / 2.0, -side / 2.0, side, side)
	var base: Texture2D = stats().base_texture
	# Base (y su sombra, RF-126, un poco desplazada hacia abajo a la derecha).
	if base != null:
		draw_circle(Vector2(4, 5) * factor, Rules.TILE_SIZE * 0.44 * factor, Color(0, 0, 0, 0.22))
		draw_texture_rect(base, tile_rect, false)
	else:  # RF-156: sin dibujo, el cuadrado de color de antes.
		draw_rect(Rect2(Vector2(-half, -half) + Vector2(4, 5) * factor, Vector2(half, half) * 2.0), Color(0, 0, 0, 0.22))
		var rect := Rect2(-half, -half, half * 2.0, half * 2.0)
		draw_rect(rect, data.color)
		draw_rect(rect, outline, false, 2.0)
	# Torreta (o cañón), girada hacia `aim_angle` y retrocedida según `_recoil`.
	var length: float = _barrel_length()
	var width: float = _barrel_width()
	draw_set_transform(Vector2.ZERO, aim_angle)
	var back: float = RECOIL_PX * _recoil * factor
	if data.turret_texture != null:
		draw_texture_rect(data.turret_texture, Rect2(tile_rect.position - Vector2(back, 0), tile_rect.size), false)
	else:
		draw_rect(Rect2(-back, -width / 2.0, length, width), outline)
	if _flash_left > 0.0:
		var strength: float = _flash_left / FLASH_DURATION
		draw_circle(Vector2(length - back + 3.0, 0.0), width * 0.9, Color(1.0, 0.95, 0.6, strength))
	draw_set_transform(Vector2.ZERO)
	if data.turret_texture == null:
		# Torreta redonda encima del cañón (solo sin dibujo: el dibujo ya la trae).
		draw_circle(Vector2.ZERO, half * 0.42, outline)
		draw_circle(Vector2.ZERO, half * 0.26, data.color)
	# RF-75: un puntito por nivel, abajo y al centro (encima de todo, para que siempre se vean).
	for i: int in level_number():
		var dot := Vector2((i - (level_number() - 1) / 2.0) * 8.0 * factor, half - 4.0 * factor)
		draw_circle(dot, 3.0 * factor, Color(1.0, 0.84, 0.3))
		draw_arc(dot, 3.0 * factor, 0.0, TAU, 12, Color(0, 0, 0, 0.6), 1.0)
	if is_stunned():
		_draw_stun(tile_rect)


## RF-280: la torre aturdida se ve apagada y con chispas que giran encima.
func _draw_stun(tile_rect: Rect2) -> void:
	draw_rect(tile_rect, STUN_DIM)
	for i: int in STUN_SPARK_COUNT:
		var angle: float = _stun_anim * 4.0 + TAU * i / STUN_SPARK_COUNT
		var p := Vector2(cos(angle) * 20.0, -20.0 + sin(angle) * 7.0) * _scale_factor()
		draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color(0.1, 0.08, 0.15), 4.4)
		draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color(0.1, 0.08, 0.15), 4.4)
		draw_line(p + Vector2(-3.4, 0), p + Vector2(3.4, 0), Color(1.0, 0.95, 0.5), 2.2)
		draw_line(p + Vector2(0, -3.4), p + Vector2(0, 3.4), Color(1.0, 0.95, 0.5), 2.2)
