# Capa de efectos visuales de la partida (spec §9.3).
# Los efectos viven aquí y no dentro del enemigo o del proyectil, porque esos ya
# se borraron cuando el efecto todavía se está viendo.
# Todo es solo visual: nada de aquí cambia reglas del juego.
class_name EffectsLayer
extends Node2D

const FROST_IMPACT: Texture2D = preload("res://assets/sprites/effects/rendered/frost.png")
const EXPLOSION_IMPACT: Texture2D = preload("res://assets/sprites/effects/rendered/explosion.png")

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
## RF-315: el número de un golpe con combo, del color del estado que aprovechó.
## Nunca dorado: el dorado es el color del oro (RF-124).
const COMBO_SLOWED_COLOR := Color(0.45, 0.8, 1.0)
const COMBO_BURNING_COLOR := Color(1.0, 0.55, 0.15)
const COMBO_FONT_SIZE: int = 20
## RF-315: la primera vez en la partida que salta cada combo, un texto que lo nombra.
const COMBO_FIRST_TEXTS: Dictionary = {
	Enemy.Combo.SLOWED: "¡Combo de hielo!",
	Enemy.Combo.BURNING: "¡Combo de fuego!",
}
## RF-315: un combo a menos de esta distancia y este tiempo de otro solo muestra su anillo (golpes de área).
const COMBO_GROUP_PX: float = 40.0
const COMBO_GROUP_SECONDS: float = 0.15
const MAX_DAMAGE_NUMBERS: int = 40
## RF-315: los números de combo tienen su propio tope y no compiten con los blancos.
const MAX_COMBO_NUMBERS: int = 12
const MAX_DEATH_RESIDUES: int = 12
const MAX_HEAL_PULSES: int = 16
## RF-449: el pulso de la Disruptora (blanco azulado) y su tope de anillos a la vez.
const PULSE_COLOR := Color(0.86, 0.92, 1.0)
const PULSE_EDGE_COLOR := Color(0.50, 0.66, 1.0)
const MAX_PULSE_RINGS: int = 8
var _pulse_rings_alive: int = 0
var _death_residues_alive: int = 0
var _heal_pulses_alive: int = 0

var _damage_numbers_alive: int = 0
var _combo_numbers_alive: int = 0
## RF-315: los combos que ya se nombraron en esta partida (la capa vive lo que dura la partida).
var _combo_seen: Dictionary = {}
## RF-315: los últimos números de combo, como [posición, momento], para no amontonarlos.
var _recent_combos: Array[Array] = []
## Reloj propio de la capa (se congela con la pausa, como el resto del mundo).
var _clock: float = 0.0


func _process(delta: float) -> void:
	_clock += delta


## RF-132: número chico con el daño real. Gris si la armadura quitó la mitad o más.
## Devuelve false si no se mostró (opción apagada, o ya hay demasiados en pantalla).
func damage_number(position_: Vector2, damage: int, armor_blocked_most: bool) -> bool:
	return _small_number(position_, str(damage), DAMAGE_BLOCKED_COLOR if armor_blocked_most else DAMAGE_COLOR)


## RF-315: un golpe con combo. Su número de daño ES el aviso: "25!", más grande y del color del estado.
## El anillo y el texto de la primera vez salen siempre; el número sigue la opción de números de daño,
## tiene su propio tope y no se repite pegado a otro (un golpe de área sobre un grupo).
## Devuelve true si mostró el número.
func combo(position_: Vector2, damage: int, kind: Enemy.Combo) -> bool:
	var color: Color = combo_color(kind)
	_add(RingEffect.new().setup(Color(color, 0.95), 8.0, 28.0, 0.3, 3.0), position_)
	if not _combo_seen.has(kind):
		_combo_seen[kind] = true
		_add(FloatingText.new().setup(COMBO_FIRST_TEXTS[kind], color, 18, 0.9, 30.0), position_ + Vector2(0, -36))
	if _is_near_recent_combo(position_):
		return false
	_recent_combos.append([position_, _clock])
	if not bool(SaveManager.get_setting("damage_numbers")) or _combo_numbers_alive >= MAX_COMBO_NUMBERS:
		return false
	var text := FloatingText.new().setup("%d!" % damage, color, COMBO_FONT_SIZE, 0.7, 30.0)
	_combo_numbers_alive += 1
	text.tree_exited.connect(func() -> void: _combo_numbers_alive -= 1)
	_add(text, position_ + Vector2(randf_range(-6.0, 6.0), -16.0))
	return true


## RF-315: celeste si el golpe aprovechó un ralentizado, naranja si un quemado.
static func combo_color(kind: Enemy.Combo) -> Color:
	return COMBO_BURNING_COLOR if kind == Enemy.Combo.BURNING else COMBO_SLOWED_COLOR


func combo_numbers_alive() -> int:
	return _combo_numbers_alive


## true si hace muy poco salió otro número de combo muy cerca. De paso olvida los viejos.
func _is_near_recent_combo(position_: Vector2) -> bool:
	var still_recent: Array[Array] = []
	var near: bool = false
	for entry: Array in _recent_combos:
		if _clock - float(entry[1]) >= COMBO_GROUP_SECONDS:
			continue
		still_recent.append(entry)
		near = near or position_.distance_to(entry[0]) < COMBO_GROUP_PX
	_recent_combos = still_recent
	return near


## RF-449: el pulso de la Disruptora: un anillo que se expande hasta el radio, con otro más fino detrás.
## Dibuja como mucho MAX_PULSE_RINGS pulsos a la vez; el exceso no se dibuja.
func pulse_ring(position_: Vector2, radius: float) -> void:
	if _pulse_rings_alive >= MAX_PULSE_RINGS:
		return
	_pulse_rings_alive += 1
	var main := RingEffect.new().setup(PULSE_COLOR, radius * 0.2, radius, 0.3, 3.0)
	main.tree_exited.connect(func() -> void: _pulse_rings_alive -= 1)
	_add(main, position_)
	_add(RingEffect.new().setup(Color(PULSE_EDGE_COLOR, 0.6), radius * 0.15, radius, 0.35, 1.4), position_)


## RF-165: "+N" verde cuando un enemigo se cura. Mismas reglas que los números de daño.
func heal_number(position_: Vector2, amount: int) -> bool:
	if _heal_pulses_alive < MAX_HEAL_PULSES:
		var pulse := RestorationEffect.new()
		_heal_pulses_alive += 1
		pulse.tree_exited.connect(func() -> void: _heal_pulses_alive -= 1)
		_add(pulse, position_)
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
func enemy_died(position_: Vector2, color: Color, radius: float, reward: int, enemy: Enemy = null) -> void:
	# Destello blanco breve: se ve sobre cualquier fondo, aunque el enemigo sea del color del suelo.
	_add(RingEffect.new().setup(Color(1, 0.93, 0.8, 0.45), radius * 0.6, radius * 1.4, 0.16, 1.4), position_)
	_add(BurstEffect.new().setup(color, radius), position_)
	if enemy != null and enemy.visual_texture() != null and _death_residues_alive < MAX_DEATH_RESIDUES:
		var residue := DeathEffect.new().setup(enemy)
		_death_residues_alive += 1
		residue.tree_exited.connect(func() -> void: _death_residues_alive -= 1)
		_add(residue, position_)
	_add(FloatingText.new().setup("+%d" % reward, GOLD_COLOR), position_ + Vector2(0, -radius))


## RF-122: impacto distinto según la torre.
func projectile_impacted(position_: Vector2, stats: TowerLevelData) -> void:
	if stats.splash_radius_tiles > 0.0:
		# Cañón: la onda llega exactamente hasta el radio de área, así el jugador lo ve.
		var radius: float = Rules.tiles_to_px(stats.splash_radius_tiles)
		_add(RingEffect.new().setup(Color(SHOCKWAVE_COLOR, 0.25), 6.0, radius, 0.3), position_)
		_add(RingEffect.new().setup(SHOCKWAVE_COLOR, 6.0, radius, 0.3, 3.0), position_)
		_add(ImpactSpriteEffect.new().setup(EXPLOSION_IMPACT, clampf(radius * 0.75, 28.0, 64.0), 0.3), position_)
	elif stats.burn_damage_per_second > 0:
		_add(RingEffect.new().setup(Color(FIRE_COLOR, 0.8), 4.0, 18.0, 0.22, 3.0), position_)
		_add(FireImpactEffect.new(), position_)
	elif stats.slow_amount > 0.0:
		_add(RingEffect.new().setup(Color(FROST_COLOR, 0.6), 4.0, 22.0, 0.25), position_)
		_add(ImpactSpriteEffect.new().setup(FROST_IMPACT, 32.0, 0.28), position_)
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
	_add(ReflectionEffect.new().setup(tower_position - mirror_position), mirror_position)
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

## RF-365: aviso de robo efectivo, independiente de la opción de daño.
func gold_stolen(position_: Vector2, amount: int) -> void:
	_add(FloatingText.new().setup("−%d oro" % amount, GOLD_COLOR, 18, 0.7, 30.0), position_ + Vector2(0, -20))

