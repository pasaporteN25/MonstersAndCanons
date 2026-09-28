# Definición de un tipo de torre. Spec §5.3.
class_name TowerData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## Si puede apuntar y dañar a enemigos voladores (RF-53).
@export var can_hit_air: bool = false
## Velocidad de sus proyectiles, en casillas por segundo.
@export var projectile_speed_tiles: float = 0.0
## Color provisional con el que se dibuja (D-002).
@export var color: Color = Color.WHITE
## Un elemento por nivel: índice 0 = nivel 1.
@export var levels: Array[TowerLevelData] = []
