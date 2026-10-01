# Capa de efectos visuales de la partida (spec §9.3).
# Los efectos viven aquí y no dentro del enemigo o del proyectil, porque esos ya
# se borraron cuando el efecto todavía se está viendo.
# Todo es solo visual: nada de aquí cambia reglas del juego.
class_name EffectsLayer
extends Node2D

const GOLD_COLOR := Color(1.0, 0.84, 0.3)
const SPARK_COLOR := Color(1.0, 0.95, 0.6)
const FROST_COLOR := Color(0.7, 0.92, 1.0)
const SHOCKWAVE_COLOR := Color(1.0, 0.75, 0.4)
const FIRE_COLOR := Color(1.0, 0.5, 0.15)
## RF-132: números de daño.
const DAMAGE_COLOR := Color(1, 1, 1)
const DAMAGE_BLOCKED_COLOR := Color(0.62, 0.62, 0.66)  # la armadura se comió el golpe
## RF-165: lo que se cura un enemigo que se regenera.
const HEAL_COLOR := Color(0.45, 0.95, 0.4)
## RF-282: el rayo del Chamán y la marca en la torre que apaga.
const STUN_COLOR := Color(0.95, 0.35, 0.8)
## RF-284: el rebote del Espejo.
const REFLECT_COLOR := Color(0.6, 0.92, 1.0)
## RF-313: el "¡Combo!" de un golpe con bonus por el estado del enemigo.
const COMBO_COLOR := Color(1.0, 0.82, 0.3)
const MAX_DAMAGE_NUMBERS: int = 40

var _damage_numbers_alive: int = 0


## RF-132: número chico con el daño real. Gris si la armadura quitó la mitad o más.
## Devuelve false si no se mostró (opción apagada, o ya hay demasiados en pantalla).
func damage_number(position_: Vector2, damage: int, armor_blocked_most: bool) -> bool:
	return _small_number(position_, str(damage), DAMAGE_BLOCKED_COLOR if armor_blocked_most else DAMAGE_COLOR)


## RF-313: "¡Combo!" dorado sobre el enemigo. Mismas reglas que los números de daño (opción y tope).
func combo(position_: Vector2) -> bool:
	if not _small_number(position_ + Vector2(0, -12), "¡Combo!", COMBO_COLOR):
		return false
	_add(RingEffect.new().setup(Color(COMBO_COLOR, 0.8), 6.0, 20.0, 0.2, 2.0), position_)
	return true


## RF-165: "+N" verde cuando un enemigo se cura. Mismas reglas que los números de daño.
func heal_number(position_: Vector2, amount: int) -> bool:
	return _small_number(position_, "+%d" % amount, HEAL_COLOR)


func _small_number(position_: Vector2, label: String, color: Color) -> bool:
	if not bool(SaveManager.get_setting("damage_numbers")):
		return false
	if _damage_numbers_alive >= MAX_DAMAGE_NUMBERS:
		return false
	var text := FloatingText.new().setup(label, color, 15, 0.6, 26.0)
	_damage_numbers_alive += 1
	text.tree_exited.connect(func() -> void: _damage_numbers_alive -= 1)
	# Un poco corrido al azar, así los golpes seguidos no se tapan entre sí.
	_add(text, position_ + Vector2(randf_range(-10.0, 10.0), -14.0))
	return true


func damage_numbers_alive() -> int:
	return _damage_numbers_alive


## RF-124: estallido del color del enemigo y "+N" con el oro ganado.
func enemy_died(position_: Vector2, color: Color, radius: float, reward: int) -> void:
	# Destello blanco breve: se ve sobre cualquier fondo, aunque el enemigo sea del color del suelo.
	_add(RingEffect.new().setup(Color(1, 1, 1, 0.7), radius, radius * 2.2, 0.18), position_)
	_add(BurstEffect.new().setup(color, radius), position_)
	_add(FloatingText.new().setup("+%d" % reward, GOLD_COLOR), position_ + Vector2(0, -radius))


## RF-122: impacto distinto según la torre.
func projectile_impacted(position_: Vector2, stats: TowerLevelData) -> void:
	if stats.splash_radius_tiles > 0.0:
		# Cañón: la onda llega exactamente hasta el radio de área, así el jugador lo ve.
		var radius: float = Rules.tiles_to_px(stats.splash_radius_tiles)
		_add(RingEffect.new().setup(Color(SHOCKWAVE_COLOR, 0.25), 6.0, radius, 0.3), position_)
		_add(RingEffect.new().setup(SHOCKWAVE_COLOR, 6.0, radius, 0.3, 3.0), position_)
	elif stats.burn_damage_per_second > 0:
		_add(RingEffect.new().setup(Color(FIRE_COLOR, 0.8), 4.0, 18.0, 0.22, 3.0), position_)
	elif stats.slow_amount > 0.0:
		_add(RingEffect.new().setup(Color(FROST_COLOR, 0.6), 4.0, 22.0, 0.25), position_)
	else:
		_add(RingEffect.new().setup(SPARK_COLOR, 2.0, 10.0, 0.12, 2.0), position_)


## RF-163: zigzag entre los enemigos que golpeó un rayo en cadena.
func lightning(points: PackedVector2Array) -> void:
	_add(LightningEffect.new().setup(points), Vector2.ZERO)


## RF-282: rayo magenta en zigzag del Chamán a la torre que apagó, y un anillo en la torre.
func stun_bolt(from: Vector2, to: Vector2) -> void:
	_add(LightningEffect.new().setup(PackedVector2Array([from, to]), STUN_COLOR), Vector2.ZERO)
	_add(RingEffect.new().setup(Color(STUN_COLOR, 0.8), 8.0, Rules.TILE_SIZE * 0.6, 0.35, 3.0), to)


## RF-284: destello cian en el Espejo y, la primera vez, el texto "¡Rebote!" y un anillo en la torre.
func reflect(mirror_position: Vector2, tower_position: Vector2, first: bool) -> void:
	_add(RingEffect.new().setup(Color(REFLECT_COLOR, 0.9), 6.0, 24.0, 0.2, 3.0), mirror_position)
	if first:
		_add(FloatingText.new().setup("¡Rebote!", REFLECT_COLOR, 18, 0.9, 30.0), mirror_position + Vector2(0, -22))
		_add(RingEffect.new().setup(Color(REFLECT_COLOR, 0.8), 8.0, Rules.TILE_SIZE * 0.6, 0.35, 3.0), tower_position)


## RF-130: anillo que se expande al construir.
## `footprint` = lado de la torre en casillas (RF-295): el anillo crece con ella.
func tower_built(position_: Vector2, color: Color, footprint: int = 1) -> void:
	var ring_color: Color = color.lightened(0.5)
	_add(RingEffect.new().setup(ring_color, 16.0 * footprint, Rules.TILE_SIZE * 0.7 * footprint, 0.3, 3.0), position_)


## Al vender: anillo gris que se cierra y "+N" con el oro devuelto.
func tower_sold(position_: Vector2, refund: int, footprint: int = 1) -> void:
	_add(RingEffect.new().setup(Color(1, 1, 1, 0.6), Rules.TILE_SIZE * 0.6 * footprint, 4.0, 0.25, 3.0), position_)
	_add(FloatingText.new().setup("+%d" % refund, GOLD_COLOR), position_ + Vector2(0, -16))


func _add(effect: Node2D, position_: Vector2) -> void:
	effect.position = position_  # la capa está en el origen: posición local = global
	add_child(effect)
