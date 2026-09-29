# Definición de un tipo de enemigo. Spec §6.
# Los valores por defecto son 0 a propósito: los números reales viven en los .tres (constitución P2).
class_name EnemyData
extends Resource

## Forma provisional con la que se dibuja (D-002).
enum Shape { CIRCLE, TRIANGLE, SQUARE, DIAMOND, HEXAGON }

@export var id: StringName = &""
@export var display_name: String = ""
## RF-134: frase que se muestra la primera vez que aparece este enemigo.
@export_multiline var description: String = ""
## Vida en la oleada 1; después crece según RF-36.
@export var max_health: int = 0
## Casillas por segundo.
@export var speed_tiles: float = 0.0
## Se resta a cada golpe recibido (RF-80).
@export var armor: int = 0
## Oro que da al morir (RF-21).
@export var reward: int = 0
## Vidas que quita al llegar a la salida (RF-11).
@export var lives_damage: int = 0
## Vuela en línea recta e ignora el camino (RF-05).
@export var is_flying: bool = false
## Qué parte de la ralentización ignora: 0.5 = solo le afecta la mitad (Jefe).
@export_range(0.0, 1.0) var slow_resistance: float = 0.0
@export var shape: Shape = Shape.CIRCLE
## Color del enemigo: se usa en los efectos (estallido al morir) y, sin dibujo, para la forma.
@export var color: Color = Color.WHITE
## Solo visual (RF-151): el dibujo, mirando a la derecha. Vacío = se usa `shape` (RF-156).
@export var texture: Texture2D
## Radio visual, en casillas.
@export var size_tiles: float = 0.0

# --- Comportamientos (M5, RF-164). Todos valen 0 = apagado, y se pueden combinar. ---

## RF-165: % de su vida máxima que recupera por segundo. No se regenera mientras se quema.
@export var regen_percent_per_second: float = 0.0
## RF-166: qué enemigo suelta al morir por daño (por ejemplo, las Crías de la Araña). Vacío = nada.
@export var death_spawn: EnemyData
## RF-166: cuántos suelta.
@export var death_spawn_count: int = 0
