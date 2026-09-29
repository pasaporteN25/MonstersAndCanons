# Definición de un tipo de torre. Spec §5.3.
class_name TowerData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## RF-171: frase que dice para qué sirve; se ve al elegir la torre para construir.
@export_multiline var description: String = ""
## Si puede apuntar y dañar a enemigos voladores (RF-53).
@export var can_hit_air: bool = false
## Velocidad de sus proyectiles, en casillas por segundo.
@export var projectile_speed_tiles: float = 0.0
## Color de la torre: se usa en los efectos y, si falta el dibujo, para pintar el cuadrado (D-002).
@export var color: Color = Color.WHITE
## Solo visual (RF-150): la parte que gira, dibujada mirando a la derecha y centrada.
## Vacío = cañón rectangular de antes (RF-156). La base depende del nivel (TowerLevelData).
@export var turret_texture: Texture2D
## Solo visual (RF-153): el proyectil, dibujado mirando a la derecha. Vacío = círculo del color.
@export var projectile_texture: Texture2D
## Un elemento por nivel: índice 0 = nivel 1.
@export var levels: Array[TowerLevelData] = []
