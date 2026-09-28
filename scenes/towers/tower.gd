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

var data: TowerData
## Nivel actual: 0 = nivel 1, 1 = nivel 2, 2 = nivel 3 (RF-71).
var level_index: int = 0
## Oro gastado en esta torre (construcción + mejoras). Sirve para vender (RF-72).
var total_invested: int = 0
var targeting: TargetMode = TargetMode.FIRST
## Hacia dónde apunta el cañón, en radianes (0 = derecha). Empieza mirando hacia arriba.
var aim_angle: float = -PI / 2.0

## Segundos hasta poder volver a disparar. Si es <= 0, dispara apenas haya objetivo.
var _cooldown: float = 0.0
## Último objetivo al que se disparó; el cañón lo sigue entre disparos (RF-120).
var _target: Enemy
## 1 = recién disparó, 0 = cañón en reposo.
var _recoil: float = 0.0
var _flash_left: float = 0.0


## Se llama ANTES de agregar la torre al árbol.
func setup(tower_data: TowerData) -> void:
	data = tower_data
	total_invested = tower_data.levels[0].cost


func _ready() -> void:
	# RF-130: aparece creciendo desde el centro.
	scale = Vector2(0.2, 0.2)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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


## RF-54: pasa al siguiente modo de apuntado (y vuelve al primero después del último).
func cycle_targeting() -> void:
	targeting = ((targeting + 1) % TargetMode.size()) as TargetMode


func targeting_name() -> String:
	return TARGET_MODE_NAMES[targeting]


func _physics_process(delta: float) -> void:
	if _target != null and not (is_instance_valid(_target) and can_target(_target)):
		_target = null
	_cooldown -= delta
	if _cooldown <= 0.0:
		var target: Enemy = find_target()
		if target != null:
			_target = target
			_shoot(target)
			_cooldown = 1.0 / stats().fire_rate
	_animate(delta)


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
		data.projectile_speed_tiles, data.color)
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


func _barrel_length() -> float:
	return Rules.TILE_SIZE * 0.48


func _barrel_width() -> float:
	return Rules.TILE_SIZE * (0.22 if stats().splash_radius_tiles > 0.0 else 0.13)


func _barrel_tip_global() -> Vector2:
	return global_position + Vector2.from_angle(aim_angle) * _barrel_length()


func _outline_color() -> Color:
	# Las torres oscuras llevan borde claro, y las claras borde oscuro, para que siempre se vean.
	return data.color.lightened(0.45) if data.color.get_luminance() < 0.3 else data.color.darkened(0.5)


func _draw() -> void:
	var half: float = Rules.tiles_to_px(BODY_SIZE_TILES) / 2.0
	var outline: Color = _outline_color()
	# Sombra (RF-126): un poco desplazada hacia abajo a la derecha.
	draw_rect(Rect2(Vector2(-half, -half) + Vector2(4, 5), Vector2(half, half) * 2.0), Color(0, 0, 0, 0.22))
	# Base.
	var rect := Rect2(-half, -half, half * 2.0, half * 2.0)
	draw_rect(rect, data.color)
	draw_rect(rect, outline, false, 2.0)
	# Cañón, girado hacia `aim_angle` y retrocedido según `_recoil`.
	var length: float = _barrel_length()
	var width: float = _barrel_width()
	draw_set_transform(Vector2.ZERO, aim_angle)
	var back: float = RECOIL_PX * _recoil
	draw_rect(Rect2(-back, -width / 2.0, length, width), outline)
	if _flash_left > 0.0:
		var strength: float = _flash_left / FLASH_DURATION
		draw_circle(Vector2(length - back + 3.0, 0.0), width * 0.9, Color(1.0, 0.95, 0.6, strength))
	draw_set_transform(Vector2.ZERO)
	# Torreta encima del cañón.
	draw_circle(Vector2.ZERO, half * 0.42, outline)
	draw_circle(Vector2.ZERO, half * 0.26, data.color)
	# RF-75: un puntito por nivel, en la esquina inferior izquierda.
	for i: int in level_number():
		var dot := Vector2(-half + 7.0 + i * 8.0, half - 7.0)
		draw_circle(dot, 3.0, Color(1.0, 0.84, 0.3))
		draw_arc(dot, 3.0, 0.0, TAU, 12, Color(0, 0, 0, 0.6), 1.0)
