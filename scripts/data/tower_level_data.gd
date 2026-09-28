# Valores de UN nivel de una torre (nivel 1, 2 o 3). Spec §5.3 y tabla de mejoras.
# Los valores por defecto son 0 a propósito: los números reales viven en los .tres (constitución P2).
class_name TowerLevelData
extends Resource

## Oro para construir (nivel 1) o para mejorar a este nivel (niveles 2 y 3).
@export var cost: int = 0
@export var damage: int = 0
## Disparos por segundo.
@export var fire_rate: float = 0.0
## Alcance, en casillas.
@export var range_tiles: float = 0.0
## Radio del daño en área, en casillas. 0 = daña a un solo enemigo.
@export var splash_radius_tiles: float = 0.0
## Fracción de ralentización: 0.4 = el enemigo va un 40 % más lento. 0 = no ralentiza.
@export_range(0.0, 1.0) var slow_amount: float = 0.0
## Duración de la ralentización, en segundos.
@export var slow_duration: float = 0.0
