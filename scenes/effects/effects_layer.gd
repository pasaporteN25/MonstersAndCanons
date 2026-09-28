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
	elif stats.slow_amount > 0.0:
		_add(RingEffect.new().setup(Color(FROST_COLOR, 0.6), 4.0, 22.0, 0.25), position_)
	else:
		_add(RingEffect.new().setup(SPARK_COLOR, 2.0, 10.0, 0.12, 2.0), position_)


## RF-130: anillo que se expande al construir.
func tower_built(position_: Vector2, color: Color) -> void:
	var ring_color: Color = color.lightened(0.5)
	_add(RingEffect.new().setup(ring_color, 16.0, Rules.TILE_SIZE * 0.7, 0.3, 3.0), position_)


func _add(effect: Node2D, position_: Vector2) -> void:
	effect.position = position_  # la capa está en el origen: posición local = global
	add_child(effect)
