# Una torre: busca un objetivo dentro de su alcance y le dispara según su cadencia (plan §6.3).
# UNA sola escena para todas las torres: lo que cambia son sus datos (D-006).
# No sabe dónde van los proyectiles: los crea y avisa con `fired` (constitución P6).
class_name Tower
extends Node2D

signal fired(projectile: Projectile)

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
## Lado del cuadrado que se dibuja, en casillas.
const BODY_SIZE_TILES: float = 0.8

var data: TowerData
## Nivel actual: 0 = nivel 1 (las mejoras llegan en M2).
var level_index: int = 0

## Segundos hasta poder volver a disparar. Si es <= 0, dispara apenas haya objetivo.
var _cooldown: float = 0.0


## Se llama ANTES de agregar la torre al árbol.
func setup(tower_data: TowerData) -> void:
	data = tower_data


func stats() -> TowerLevelData:
	return data.levels[level_index]


func range_px() -> float:
	return Rules.tiles_to_px(stats().range_tiles)


func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target: Enemy = find_target()
	if target == null:
		return
	_shoot(target)
	_cooldown = 1.0 / stats().fire_rate


## RF-51: apunta al "Primero", el enemigo al que menos le falta para llegar a la salida.
## Se mide la distancia a cada enemigo (D-014) en vez de usar áreas de colisión.
func find_target() -> Enemy:
	var best: Enemy = null
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if not can_target(enemy):
			continue
		if best == null or enemy.remaining_distance() < best.remaining_distance():
			best = enemy
	return best


## RF-50 y RF-53: el enemigo sigue activo, está en alcance y, si vuela, la torre puede golpearlo.
func can_target(enemy: Enemy) -> bool:
	if not enemy.is_active():
		return false
	if enemy.data.is_flying and not data.can_hit_air:
		return false
	return global_position.distance_to(enemy.global_position) <= range_px()


func _shoot(target: Enemy) -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(target, global_position, stats(), data.can_hit_air,
		data.projectile_speed_tiles, data.color)
	fired.emit(projectile)


# --- Dibujo provisional (D-002) ---

func _draw() -> void:
	var half: float = Rules.tiles_to_px(BODY_SIZE_TILES) / 2.0
	var rect := Rect2(-half, -half, half * 2.0, half * 2.0)
	# Las torres oscuras llevan borde claro, y las claras borde oscuro, para que siempre se vea.
	var outline: Color = data.color.lightened(0.45) if data.color.get_luminance() < 0.3 \
		else data.color.darkened(0.5)
	draw_rect(rect, data.color)
	draw_rect(rect, outline, false, 2.0)
	draw_circle(Vector2.ZERO, half * 0.45, outline)
