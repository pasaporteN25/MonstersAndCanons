# Script común a todos los mapas (plan §6.1).
# Sabe qué casillas son construibles y dónde están los caminos.
# No sabe nada de torres ni de enemigos.
class_name Level
extends Node2D

## Casillas del TileSet (assets/tiles/tileset.tres). Qué es construible lo dice su dato
## "buildable"; estas constantes solo sirven para decorar (LevelDecor).
const ATLAS_GRASS := Vector2i(0, 0)
const ATLAS_PATH := Vector2i(1, 0)
const ATLAS_BLOCKED := Vector2i(2, 0)
const TILESET: TileSet = preload("res://assets/tiles/tileset.tres")
const ATLAS_OF: Dictionary = {
	MapGrid.Cell.GRASS: ATLAS_GRASS, MapGrid.Cell.PATH: ATLAS_PATH, MapGrid.Cell.BLOCKED: ATLAS_BLOCKED,
}

## M15: el paisaje (RF-260) y los dibujos que pidió la leyenda (RF-262, casilla → dibujo).
var theme: StringName = MapThemes.DEFAULT
var legend_cells: Dictionary = {}

@onready var ground: TileMapLayer = $Ground
@onready var entrances: Node2D = $Entrances


## M7 (spec §7.8): arma el mapa a partir del mapa de letras (que tiene que ser válido):
## el suelo, un camino terrestre y uno aéreo por entrada, y la decoración.
static func build(grid: MapGrid, map_theme: StringName = MapThemes.DEFAULT) -> Level:
	assert(grid.is_valid(), "Level.build necesita un mapa válido")
	var level := Level.new()
	level.name = "Level"
	level.theme = map_theme
	level.legend_cells = grid.legend_cells
	level.add_child(make_ground(grid))
	var entrances_node := Node2D.new()
	entrances_node.name = "Entrances"
	level.add_child(entrances_node)
	for i: int in grid.entrances.size():
		var ground_path := Path2D.new()
		ground_path.name = "GroundPath%d" % i
		ground_path.curve = route_curve(grid, i)
		entrances_node.add_child(ground_path)
		# RF-05: los voladores van en línea recta del primer punto al último.
		var air := Path2D.new()
		air.name = "AirPath%d" % i
		air.curve = Curve2D.new()
		air.curve.add_point(ground_path.curve.get_point_position(0))
		air.curve.add_point(ground_path.curve.get_point_position(ground_path.curve.point_count - 1))
		entrances_node.add_child(air)
	var decor := LevelDecor.new()
	decor.name = "Decor"
	level.add_child(decor)
	return level


## El suelo del mapa: una casilla del TileSet por cada casilla de letras (las entradas y la salida
## son camino). Lo usan el juego (Level.build) y el editor de mapas (spec §10.3): se ven igual.
static func make_ground(grid: MapGrid) -> TileMapLayer:
	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = TILESET
	for y: int in grid.height:
		for x: int in grid.width:
			var cell := Vector2i(x, y)
			ground.set_cell(cell, 0, ATLAS_OF[grid.cell_type(cell)])
	return ground


## Curva que siguen los enemigos terrestres de una entrada: los centros de las esquinas del
## recorrido. Si la entrada (o la salida) está en el borde, ese punto se corre una casilla
## hacia afuera: el enemigo entra (o sale) desde fuera del mapa. Si la salida está adentro,
## termina justo en el centro de esa casilla, donde se dibuja la puerta (RF-06).
static func route_curve(grid: MapGrid, entrance_index: int) -> Curve2D:
	var corners: Array[Vector2i] = grid.corners(entrance_index)
	var first: Vector2i = corners[0]
	var last: Vector2i = corners[corners.size() - 1]
	var curve := Curve2D.new()
	for i: int in corners.size():
		var point: Vector2 = _center(corners[i])
		if i == 0 and grid.is_on_border(first):
			point += Vector2(_outward(grid, first, first - corners[1])) * Rules.TILE_SIZE
		elif i == corners.size() - 1 and grid.is_on_border(last):
			point += Vector2(_outward(grid, last, last - corners[i - 1])) * Rules.TILE_SIZE
		curve.add_point(point)
	return curve


## Hacia dónde queda "afuera" de una casilla del borde. Primero se prueba seguir derecho
## (`along`: la dirección del recorrido en ese extremo); si eso no sale del mapa (por ejemplo,
## un camino que corre pegado al borde), se usa el lado del borde.
static func _outward(grid: MapGrid, cell: Vector2i, along: Vector2i) -> Vector2i:
	var dir := Vector2i(signi(along.x), signi(along.y))
	if not grid.is_inside(cell + dir):
		return dir
	for side: Vector2i in MapGrid.NEIGHBORS:
		if not grid.is_inside(cell + side):
			return side
	return dir


static func _center(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * Rules.TILE_SIZE


func _ready() -> void:
	var decor := get_node_or_null("Decor") as LevelDecor
	if decor != null:
		decor.paint(ground, inner_exit_cells())


## RF-06: casillas donde termina algún camino DENTRO del mapa (ahí se dibuja una puerta).
## Si el camino sale por un borde, la salida es el borde y no se marca nada.
func inner_exit_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i: int in entrance_count():
		var path: Path2D = get_ground_path(i)
		var end: Vector2 = path.to_global(path.curve.get_point_position(path.curve.point_count - 1))
		var cell: Vector2i = cell_at(end)
		if is_inside(cell) and not cells.has(cell):
			cells.append(cell)
	return cells


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


## Camino aéreo de la entrada `entrance_index` (RF-05): línea recta hasta la salida.
## Si el mapa no tiene uno, los voladores usan el terrestre.
func get_air_path(entrance_index: int) -> Path2D:
	var air := entrances.get_node_or_null("AirPath%d" % entrance_index) as Path2D
	return air if air != null else get_ground_path(entrance_index)


## Cantidad de entradas del mapa (una por cada GroundPathN).
func entrance_count() -> int:
	var count: int = 0
	while get_ground_path(count) != null:
		count += 1
	return count


## Centro de una casilla, en coordenadas globales (donde se coloca una torre).
func cell_center(cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(cell))


## Tamaño del mapa, en casillas.
func map_size() -> Vector2i:
	return ground.get_used_rect().size


## true si la casilla es parte del mapa (aunque no sea construible).
func is_inside(cell: Vector2i) -> bool:
	return ground.get_used_rect().has_point(cell)
