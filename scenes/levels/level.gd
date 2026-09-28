# Script común a todos los mapas (plan §6.1).
# Sabe qué casillas son construibles y dónde están los caminos.
# No sabe nada de torres ni de enemigos.
class_name Level
extends Node2D

@onready var ground: TileMapLayer = $Ground
@onready var entrances: Node2D = $Entrances


## RF-02: solo las casillas "libres" son construibles.
## Una casilla vacía o fuera del mapa no tiene datos, así que tampoco es construible.
func is_buildable(cell: Vector2i) -> bool:
	var tile: TileData = ground.get_cell_tile_data(cell)
	return tile != null and tile.get_custom_data("buildable")


## Casilla que hay debajo de una posición global (en píxeles).
func cell_at(global_pos: Vector2) -> Vector2i:
	return ground.local_to_map(ground.to_local(global_pos))


## Camino terrestre de la entrada `entrance_index` (RF-03, RF-04).
func get_ground_path(entrance_index: int) -> Path2D:
	return entrances.get_node_or_null("GroundPath%d" % entrance_index) as Path2D


## Cantidad de entradas del mapa (una por cada GroundPathN).
func entrance_count() -> int:
	var count: int = 0
	while get_ground_path(count) != null:
		count += 1
	return count
