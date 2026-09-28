# Fórmulas del juego (spec 01). Son funciones puras: no tocan nodos ni escenas,
# así se pueden testear aisladas (constitución P10).
class_name Rules
extends RefCounted

## Tamaño de una casilla en píxeles (RF-01). No es un número de balance (plan §4.2).
const TILE_SIZE: float = 64.0


static func tiles_to_px(tiles: float) -> float:
	return tiles * TILE_SIZE


## RF-80: la armadura resta, pero siempre se hace al menos 1 de daño.
static func damage_after_armor(damage: int, armor: int) -> int:
	return maxi(1, damage - armor)


## RF-36: vida del enemigo según la oleada. Se redondea hacia abajo.
static func scaled_health(base_health: int, wave_number: int, cfg: BalanceConfig) -> int:
	var percent: int = 100 + cfg.health_scale_percent_per_wave * (wave_number - 1)
	# El numerador es entero, así que la división no arrastra errores de redondeo.
	return floori(base_health * percent / 100.0)


## RF-22: oro extra al terminar la oleada número `wave_number`.
static func wave_bonus(wave_number: int, cfg: BalanceConfig) -> int:
	return cfg.wave_bonus_base + cfg.wave_bonus_per_wave * wave_number


## RF-72: oro que se devuelve al vender una torre. Se redondea hacia abajo.
static func sell_refund(total_invested: int, cfg: BalanceConfig) -> int:
	return floori(total_invested * cfg.sell_refund_percent / 100.0)


## RF-60 y Jefe: ralentización que realmente sufre un enemigo según su resistencia.
static func effective_slow(slow_amount: float, slow_resistance: float) -> float:
	return slow_amount * (1.0 - slow_resistance)
