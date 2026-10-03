# Valores de UN nivel de una torre (nivel 1, 2 o 3). Spec §5.3 y tabla de mejoras.
# Los valores por defecto son 0 a propósito: los números reales viven en los .tres (constitución P2).
class_name TowerLevelData
extends Resource

## Oro para construir (nivel 1) o para mejorar a este nivel (niveles 2 y 3).
@export var cost: int = 0
@export var damage: int = 0
## Disparos por segundo.
@export var fire_rate: float = 0.0
## RF-361: bonus de cadencia a otras torres dentro del alcance.
@export var support_rate_percent: int = 0
## Alcance, en casillas.
@export var range_tiles: float = 0.0
## Radio del daño en área, en casillas. 0 = daña a un solo enemigo.
@export var splash_radius_tiles: float = 0.0
## Fracción de ralentización: 0.4 = el enemigo va un 40 % más lento. 0 = no ralentiza.
@export_range(0.0, 1.0) var slow_amount: float = 0.0
## Duración de la ralentización, en segundos.
@export var slow_duration: float = 0.0
## Solo visual (RF-150): la base que se ve en este nivel. Vacío = cuadrado de color (RF-156).
@export var base_texture: Texture2D
## RF-337: mecanismo de este nivel. Vacío = atlas original del tipo de torre.
@export var turret_atlas: Texture2D

# --- Comportamientos (M5, RF-164). Todos valen 0 = apagado, y se pueden combinar. ---

## RF-160: daño de quemadura por segundo (ignora la armadura). 0 = no quema.
@export var burn_damage_per_second: int = 0
## RF-160: segundos que dura la quemadura.
@export var burn_duration: float = 0.0
## RF-161: a cuántos enemigos MÁS dispara a la vez (0 = a uno solo).
@export var extra_targets: int = 0
## RF-162: cuántas púas lanza en círculo, en línea recta (0 = dispara normal, a un objetivo).
@export var burst_count: int = 0
## RF-163: a cuántos enemigos MÁS salta el golpe, uno detrás de otro (0 = no salta).
@export var chain_extra_targets: int = 0
## RF-163: distancia máxima de cada salto, en casillas.
@export var chain_range_tiles: float = 0.0

# --- Sinergias por estado (M20, RF-310): cuánto más daño hace contra un enemigo en cierto estado. 0 = nada. ---

## RF-310: % de daño extra contra un enemigo ralentizado.
@export var bonus_vs_slowed_percent: int = 0
## RF-310: % de daño extra contra un enemigo que se está quemando.
@export var bonus_vs_burning_percent: int = 0

## RF-369: puntos porcentuales de desgaste que repara por segundo;0 apagado.
@export var support_repair_per_second: float = 0.0
