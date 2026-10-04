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
## RF-327: ocho vistas, cuatro columnas por dos filas. Vacío = textura giratoria anterior.
@export var turret_atlas: Texture2D
## Solo visual (RF-153): el proyectil, dibujado mirando a la derecha. Vacío = círculo del color.
@export var projectile_texture: Texture2D
## RF-290: lado de la torre en casillas. 1 = una casilla (todas las de hoy), 2 = cuadrado de 2×2 (el Mortero).
@export_range(1, 3) var footprint: int = 1
## RF-300: una torre **reservada** no está en la barra de todos los niveles: solo en los que la habilitan
## con `"torres_extra"` en su archivo (por ahora, el Mortero).
@export var reserved: bool = false
## Un elemento por nivel: índice 0 = nivel 1.
@export var levels: Array[TowerLevelData] = []
