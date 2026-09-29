# Fórmulas del juego (spec 01). Son funciones puras: no tocan nodos ni escenas,
# así se pueden testear aisladas (constitución P10).
class_name Rules
extends RefCounted

## Tamaño de una casilla en píxeles (RF-01). No es un número de balance (plan §4.2).
const TILE_SIZE: float = 64.0
## RF-135/RF-136: un enemigo es "peligroso" si quita esta cantidad de vidas o más.
## Es un criterio de interfaz (cuándo avisar), no un número de balance.
const DANGEROUS_LIVES_DAMAGE: int = 5


static func is_dangerous(enemy: EnemyData) -> bool:
	return enemy.lives_damage >= DANGEROUS_LIVES_DAMAGE


static func tiles_to_px(tiles: float) -> float:
	return tiles * TILE_SIZE


## RF-80: la armadura resta, pero siempre se hace al menos 1 de daño.
static func damage_after_armor(damage: int, armor: int) -> int:
	return maxi(1, damage - armor)


## RF-36: vida del enemigo según la oleada, con el % general. Se redondea hacia abajo.
static func scaled_health(base_health: int, wave_number: int, cfg: BalanceConfig) -> int:
	return scaled_health_percent(base_health, wave_number, cfg.health_scale_percent_per_wave)


## RF-36 con un % concreto (cada nivel puede tener el suyo, D-019).
static func scaled_health_percent(base_health: int, wave_number: int, percent_per_wave: int) -> int:
	var percent: int = 100 + percent_per_wave * (wave_number - 1)
	# El numerador es entero, así que la división no arrastra errores de redondeo.
	return floori(base_health * percent / 100.0)


## RF-22: oro extra al terminar la oleada número `wave_number`.
static func wave_bonus(wave_number: int, cfg: BalanceConfig) -> int:
	return cfg.wave_bonus_base + cfg.wave_bonus_per_wave * wave_number


## RF-190: puntos por matar a un enemigo que vale `reward` de oro.
static func kill_points(reward: int, cfg: BalanceConfig) -> int:
	return reward * cfg.points_per_gold


## RF-190: puntos por ganar con `lives` vidas.
static func victory_points(lives: int, cfg: BalanceConfig) -> int:
	return lives * cfg.points_per_life


## RF-72: oro que se devuelve al vender una torre. Se redondea hacia abajo.
static func sell_refund(total_invested: int, cfg: BalanceConfig) -> int:
	return floori(total_invested * cfg.sell_refund_percent / 100.0)


## RF-93: estrellas (0 a 3) según las vidas que quedaron al ganar.
## 0 = no se ganó (sin vidas). Cuentas con enteros para no tener errores de redondeo (D-013).
static func stars_for(lives_left: int, starting_lives: int, cfg: BalanceConfig) -> int:
	if lives_left <= 0:
		return 0
	if lives_left * 100 >= cfg.star_3_lives_percent * starting_lives:
		return 3
	if lives_left * 100 >= cfg.star_2_lives_percent * starting_lives:
		return 2
	return 1


## RF-60 y Jefe: ralentización que realmente sufre un enemigo según su resistencia.
static func effective_slow(slow_amount: float, slow_resistance: float) -> float:
	return slow_amount * (1.0 - slow_resistance)
