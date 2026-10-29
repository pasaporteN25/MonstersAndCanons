# Lee el mapa de un nivel escrito con letras (spec §7.8, RF-201, RF-202) y calcula el recorrido
# de cada entrada hasta la salida. Es lógica pura: no crea nodos (eso lo hace Level.build).
#
#   .  pasto (se construye)   #  camino   X  bloqueada
#   A, B, C…  entradas (son camino)       S  salida (es camino)
#   Las letras de la LEYENDA del nivel (RF-262): pasto si es construible, bloqueada si no. Nunca camino.
#
# Los errores se juntan en `errors`, en castellano y con la fila y la columna contadas desde 1
# (como las muestra el Bloc de notas).
class_name MapGrid
extends RefCounted

enum Cell { GRASS, PATH, BLOCKED }

## RF-250: el tamaño de un mapa va de 20×9 (el de siempre) a 26×12.
const MIN_WIDTH: int = 20
const MIN_HEIGHT: int = 9
const MAX_WIDTH: int = 26
const MAX_HEIGHT: int = 12
const GRASS: String = "."
const PATH: String = "#"
const BLOCKED: String = "X"
const EXIT: String = "S"
## Las entradas posibles, en orden: la primera es la entrada 0 de las oleadas.
const ENTRANCE_LETTERS: String = "ABCDEFGH"
const NEIGHBORS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

## Tamaño del mapa, en casillas (sale de las filas).
var width: int = MIN_WIDTH
var height: int = MIN_HEIGHT
var errors: PackedStringArray = []
## RF-207: cosas dudosas que no impiden jugar (por ejemplo, un tramo que el enemigo se salta).
var warnings: PackedStringArray = []
## Casillas de camino que ningún recorrido usa.
var unused_cells: Array[Vector2i] = []
## RF-262: el dibujo que pidió la leyenda para cada casilla (casilla → nombre del dibujo).
var legend_cells: Dictionary = {}
## RF-401: casillas con removibles, para dibujar su marca provisional.
var removable_cells: Array[Vector2i] = []
## Casilla de cada entrada: índice 0 = A, 1 = B…
var entrances: Array[Vector2i] = []
var exit_cell: Vector2i = Vector2i(-1, -1)
## Recorrido de cada entrada: todas sus casillas, de la entrada a la salida.
var routes: Array[Array] = []

var _cells: Dictionary = {}  # Vector2i → Cell
var _legend: Dictionary = {}  # letra → {"dibujo": String, "construible": bool}


## Lee las filas del mapa. Si algo está mal, `errors` dice qué y dónde. `legend` son las letras
## extra que declaró el nivel (ya validadas por LevelFile).
static func parse(rows: PackedStringArray, legend: Dictionary = {}) -> MapGrid:
	var grid := MapGrid.new()
	grid._legend = legend
	grid._read(rows)
	if grid.errors.is_empty():
		grid._find_routes()
	if grid.errors.is_empty():
		grid._find_unused_cells()
	return grid


func is_valid() -> bool:
	return errors.is_empty()


func cell_type(cell: Vector2i) -> Cell:
	return _cells.get(cell, Cell.BLOCKED)


## RF-400: despeja un removible sin recalcular recorridos; nunca ocupaba una casilla de camino.
func clear_cell(cell: Vector2i) -> bool:
	if not is_inside(cell) or cell_type(cell) != Cell.BLOCKED or not removable_cells.has(cell):
		return false
	_cells[cell] = Cell.GRASS
	legend_cells.erase(cell)
	removable_cells.erase(cell)
	return true


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func is_on_border(cell: Vector2i) -> bool:
	return cell.x == 0 or cell.y == 0 or cell.x == width - 1 or cell.y == height - 1


## Las esquinas del recorrido de una entrada: la entrada, cada casilla donde dobla y la salida.
func corners(entrance_index: int) -> Array[Vector2i]:
	var route: Array = routes[entrance_index]
	var result: Array[Vector2i] = [route[0]]
	for i: int in range(1, route.size() - 1):
		if route[i] - route[i - 1] != route[i + 1] - route[i]:
			result.append(route[i])
	result.append(route[route.size() - 1])
	return result


## "fila 4, columna 7": para los mensajes (contadas desde 1).
static func where(cell: Vector2i) -> String:
	return Localization.t_fmt(&"grid.where", {"row": cell.y + 1, "col": cell.x + 1})


func _read(rows: PackedStringArray) -> void:
	if rows.size() < MIN_HEIGHT or rows.size() > MAX_HEIGHT:
		errors.append(Localization.t_fmt(&"grid.rows_range", {"n": rows.size(), "min": MIN_HEIGHT, "max": MAX_HEIGHT}))
		return
	height = rows.size()
	width = rows[0].length()
	if width < MIN_WIDTH or width > MAX_WIDTH:
		errors.append(Localization.t_fmt(&"grid.width_range", {"n": width, "min": MIN_WIDTH, "max": MAX_WIDTH}))
		return
	var found: Dictionary = {}  # letra de entrada → casilla
	var exits: Array[Vector2i] = []
	var grass: int = 0
	var used_legend: Dictionary = {}
	for y: int in height:
		var row: String = rows[y]
		if row.length() != width:
			errors.append(Localization.t_fmt(&"grid.row_length", {"row": y + 1, "n": row.length(), "width": width}))
			continue
		for x: int in width:
			var cell := Vector2i(x, y)
			var letter: String = row[x]
			if letter == GRASS:
				_cells[cell] = Cell.GRASS
				grass += 1
			elif letter == BLOCKED:
				_cells[cell] = Cell.BLOCKED
			elif letter == PATH:
				_cells[cell] = Cell.PATH
			elif letter == EXIT:
				_cells[cell] = Cell.PATH
				exits.append(cell)
			elif ENTRANCE_LETTERS.contains(letter):
				_cells[cell] = Cell.PATH
				if found.has(letter):
					errors.append(Localization.t_fmt(&"grid.entrance_twice", {"letter": letter, "first": where(found[letter]), "second": where(cell)}))
				found[letter] = cell
			elif _legend.has(letter):
				var entry: Dictionary = _legend[letter]
				var buildable: bool = entry.get("construible", false)
				_cells[cell] = Cell.GRASS if buildable else Cell.BLOCKED
				if buildable:
					grass += 1
				legend_cells[cell] = entry["dibujo"]
				if entry.has("removible"):
					removable_cells.append(cell)
				used_legend[letter] = true
			else:
				errors.append(Localization.t_fmt(&"grid.unknown_letter", {"letter": letter, "where": where(cell)}))
	if not errors.is_empty():
		return
	if exits.is_empty():
		errors.append(Localization.t(&"grid.no_exit"))
	elif exits.size() > 1:
		errors.append(Localization.t_fmt(&"grid.many_exits", {"n": exits.size()}))
	else:
		exit_cell = exits[0]
	if found.is_empty():
		errors.append(Localization.t(&"grid.no_entrance_a"))
	for i: int in ENTRANCE_LETTERS.length():
		var letter: String = ENTRANCE_LETTERS[i]
		if found.has(letter):
			if entrances.size() < i:
				errors.append(Localization.t_fmt(&"grid.entrance_gap", {"letter": letter, "missing": ENTRANCE_LETTERS[entrances.size()]}))
				break
			entrances.append(found[letter])
	if grass == 0:
		errors.append(Localization.t(&"grid.no_grass"))
	if errors.is_empty():
		for letter: String in _legend.keys():
			if not used_legend.has(letter):
				warnings.append(Localization.t_fmt(&"grid.unused_letter", {"letter": letter}))


## RF-202: el camino más corto de cada entrada a la salida. Primero se mide, desde la salida,
## cuántos pasos hay de cada casilla de camino a la salida; después, desde cada entrada, se
## avanza siempre a la vecina que está un paso más cerca. Si hay dos, es un empate: error.
func _find_routes() -> void:
	var steps: Dictionary = {exit_cell: 0}
	var queue: Array[Vector2i] = [exit_cell]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for dir: Vector2i in NEIGHBORS:
			var next: Vector2i = cell + dir
			if cell_type(next) == Cell.PATH and is_inside(next) and not steps.has(next):
				steps[next] = steps[cell] + 1
				queue.append(next)
	for i: int in entrances.size():
		var letter: String = ENTRANCE_LETTERS[i]
		var cell: Vector2i = entrances[i]
		if not steps.has(cell):
			errors.append(Localization.t_fmt(&"grid.no_path", {"letter": letter, "where": where(cell)}))
			continue
		var route: Array[Vector2i] = [cell]
		while cell != exit_cell:
			var closer: Array[Vector2i] = []
			for dir: Vector2i in NEIGHBORS:
				if steps.get(cell + dir, -1) == steps[cell] - 1:
					closer.append(cell + dir)
			if closer.size() > 1:
				errors.append(Localization.t_fmt(&"grid.tied_routes", {"letter": letter, "where": where(cell)}))
				break
			cell = closer[0]
			route.append(cell)
		routes.append(route)


## RF-207: las casillas de camino que ningún recorrido pisa. Si el enemigo se salta un tramo
## dibujado (porque dos partes del camino quedaron en casillas vecinas), ese tramo queda acá.
func _find_unused_cells() -> void:
	var used: Dictionary = {}
	for route: Array in routes:
		for cell: Vector2i in route:
			used[cell] = true
	for y: int in height:
		for x: int in width:
			var cell := Vector2i(x, y)
			if cell_type(cell) == Cell.PATH and not used.has(cell):
				unused_cells.append(cell)
	if unused_cells.is_empty():
		return
	var shown: PackedStringArray = []
	for cell: Vector2i in unused_cells.slice(0, 6):
		shown.append(where(cell))
	var more: String = "…" if unused_cells.size() > shown.size() else ""
	warnings.append(Localization.t_plural(&"grid.unused_path", unused_cells.size(), {"cells": "; ".join(shown), "more": more}))
