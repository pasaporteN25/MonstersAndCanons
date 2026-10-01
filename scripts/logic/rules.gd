# Fórmulas del juego (spec 01). Son funciones puras: no tocan nodos ni escenas,
# así se pueden testear aisladas (constitución P10).
class_name Rules
extends RefCounted

## Tamaño de una casilla en píxeles (RF-01). No es un número de balance (plan §4.2).
const TILE_SIZE: float = 64.0
## RF-135/RF-136: un enemigo es "peligroso" si quita esta cantidad de vidas o más.
## Es un criterio de interfaz (cuándo avisar), no un número de balance.
const DANGEROUS_LIVES_DAMAGE: int = 5
## La pantalla lógica (project.godot) y el área del mapa: entre la barra de arriba (48 px) y la de
## torres de abajo. Un mapa de 20×9 la llena justo (RF-251).
const SCREEN_SIZE := Vector2(1280.0, 720.0)
const MAP_AREA := Rect2(0.0, 48.0, 1280.0, 576.0)


static func is_dangerous(enemy: EnemyData) -> bool:
	return enemy.lives_damage >= DANGEROUS_LIVES_DAMAGE


## RF-251: cuánto se achica el mundo para que un mapa de `cols`×`rows` casillas entre entero en el
## área del mapa. 1.0 = sin zoom (20×9, el tamaño de siempre).
static func map_zoom(cols: int, rows: int) -> float:
	return minf(1.0, minf(MAP_AREA.size.x / (cols * TILE_SIZE), MAP_AREA.size.y / (rows * TILE_SIZE)))


## RF-251: el punto del mundo que mira la cámara para que el mapa quede centrado en el área del mapa
## (y no en el centro de la pantalla: la barra de arriba mide 48 px y la de abajo, 96). Con 20×9 y zoom 1 da el centro de la pantalla: la cámara no cambia nada.
static func map_camera_center(cols: int, rows: int) -> Vector2:
	var zoom: float = map_zoom(cols, rows)
	var map_center: Vector2 = MAP_AREA.position + Vector2(cols, rows) * TILE_SIZE / 2.0
	var area_center: Vector2 = MAP_AREA.get_center()
	return map_center + (SCREEN_SIZE / 2.0 - area_center) / zoom


static func tiles_to_px(tiles: float) -> float:
	return tiles * TILE_SIZE


## RF-311: el daño de un golpe con un bonus de `percent` %, redondeado al entero más cercano.
## Se calcula ANTES de restar la armadura.
static func damage_with_bonus(damage: int, percent: int) -> int:
	return roundi(damage * (100 + percent) / 100.0)


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
