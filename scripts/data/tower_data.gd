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
## RF-360/361: apoyo fijo y condición de colección, apagados para torres anteriores.
@export var support_only: bool = false
@export var required_collection: StringName = &""
## RF-418: recursos que cuesta construirla (además del oro). 0 = solo oro. Mejorar no cuesta recursos.
@export var resource_cost: int = 0
## RF-419: segunda forma de pago (oro + recursos). `alt_resource_cost` 0 = una sola forma de pago.
## No puede convivir con `resource_cost`, y `alt_gold_cost` tiene que ser menor que el oro del nivel 1.
@export var alt_gold_cost: int = 0
@export var alt_resource_cost: int = 0
## Un elemento por nivel: índice 0 = nivel 1.
@export var levels: Array[TowerLevelData] = []


## RF-419: true si se puede comprar de dos formas (oro, u oro más recursos).
func has_alt_payment() -> bool:
	return alt_resource_cost > 0


## RF-418 y RF-419: el oro que cuesta construirla; con `alt` y dos formas de pago, el de la segunda.
func build_gold(alt: bool = false) -> int:
	return alt_gold_cost if alt and has_alt_payment() else levels[0].cost


## RF-418 y RF-419: los recursos que cuesta construirla.
func build_resources(alt: bool = false) -> int:
	return alt_resource_cost if alt and has_alt_payment() else resource_cost
