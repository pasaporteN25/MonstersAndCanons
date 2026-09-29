# El mapa que se ve en el editor (spec §10.3, RF-211, RF-213): el MISMO suelo y la MISMA
# decoración que en la partida (así se ve como va a quedar) y, encima, lo que ayuda a diseñar:
# el recorrido de cada entrada, las letras de entradas y salida y las casillas que nadie pisa.
# Solo dibuja: no sabe cómo se edita (eso lo hace MapEditor).
class_name MapView
extends Node2D

## Un color por entrada (A, B, C…): el mismo para su letra y para su recorrido.
const ROUTE_COLORS: Array[Color] = [
	Color(0.35, 0.75, 1.0), Color(1.0, 0.6, 0.25), Color(0.6, 1.0, 0.5), Color(1.0, 0.5, 0.8),
	Color(0.8, 0.7, 1.0), Color(1.0, 0.9, 0.4), Color(0.5, 1.0, 0.9), Color(1.0, 0.45, 0.4),
]
const EXIT_COLOR := Color(1.0, 0.84, 0.3)
const UNUSED_COLOR := Color(1.0, 0.25, 0.2, 0.4)
const HOVER_COLOR := Color(1, 1, 1, 0.9)
const LETTER_COLOR := Color(0.08, 0.08, 0.1)
## Los recorridos se dibujan como franjas anidadas: la primera entrada, la más ancha y abajo; las
## siguientes, más finas y encima. Así, donde varios recorridos comparten tramo se ven todos.
const ROUTE_WIDTH: float = 5.0
const ROUTE_WIDTH_STEP: float = 3.0
const BADGE_RADIUS: float = 21.0
const LETTER_SIZE: int = 26

## Casilla sobre la que está el mouse (fuera del mapa = sin resaltar).
var hover_cell := Vector2i(-1, -1):
	set(value):
		if value != hover_cell:
			hover_cell = value
			_overlay.queue_redraw()

var _rows: PackedStringArray = []
var _grid: MapGrid
var _ground: TileMapLayer
var _decor := LevelDecor.new()
var _overlay := Node2D.new()


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023, igual que la partida
	_overlay.draw.connect(_draw_overlay)


func _ready() -> void:
	add_child(_decor)
	add_child(_overlay)  # va último: se dibuja encima de todo


## Dibuja el mapa de letras `rows` (con `grid`, que es ese mismo mapa ya leído).
func show_map(rows: PackedStringArray, grid: MapGrid) -> void:
	_rows = rows
	_grid = grid
	if _ground != null:
		_ground.queue_free()
	_ground = Level.make_ground(grid)
	add_child(_ground)
	move_child(_ground, 0)  # el suelo debajo de la decoración
	# RF-06: la puerta de la salida, si está adentro del mapa.
	var gates: Array[Vector2i] = []
	if grid.exit_cell != Vector2i(-1, -1) and not grid.is_on_border(grid.exit_cell):
		gates.append(grid.exit_cell)
	_decor.paint(_ground, gates)
	_overlay.queue_redraw()


## La casilla que hay debajo de un punto de la pantalla (`local` es relativo a este nodo).
static func cell_at(local: Vector2) -> Vector2i:
	return Vector2i((local / Rules.TILE_SIZE).floor())


func _draw_overlay() -> void:
	if _grid == null:
		return
	var tile: float = Rules.TILE_SIZE
	# El recorrido de cada entrada (solo si el mapa es válido: si no, no hay recorridos).
	if _grid.is_valid():
		for i: int in _grid.routes.size():
			var points := PackedVector2Array()
			for cell: Vector2i in _grid.routes[i]:
				points.append(_center(cell))
			var width: float = ROUTE_WIDTH + ROUTE_WIDTH_STEP * (_grid.routes.size() - 1 - i)
			_overlay.draw_polyline(points, Color(_route_color(i), 0.9), width, true)
		# RF-207: las casillas de camino que nadie pisa.
		for cell: Vector2i in _grid.unused_cells:
			_overlay.draw_rect(Rect2(Vector2(cell) * tile, Vector2(tile, tile)), UNUSED_COLOR)
			_draw_letter(cell, "?", Color.WHITE)
	# Las letras de entradas y salida (se ven también si el mapa tiene errores).
	for y: int in _rows.size():
		var row: String = _rows[y]
		for x: int in row.length():
			var letter: String = row[x]
			var cell := Vector2i(x, y)
			if letter == MapGrid.EXIT:
				_draw_badge(cell, letter, EXIT_COLOR)
			elif MapGrid.ENTRANCE_LETTERS.contains(letter):
				_draw_badge(cell, letter, _route_color(MapGrid.ENTRANCE_LETTERS.find(letter)))
	if hover_cell.x >= 0 and hover_cell.y >= 0 and hover_cell.x < _grid.width and hover_cell.y < _grid.height:
		_overlay.draw_rect(Rect2(Vector2(hover_cell) * tile, Vector2(tile, tile)), HOVER_COLOR, false, 2.0)


func _route_color(index: int) -> Color:
	return ROUTE_COLORS[index % ROUTE_COLORS.size()]


func _center(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * Rules.TILE_SIZE


func _draw_badge(cell: Vector2i, letter: String, color: Color) -> void:
	_overlay.draw_circle(_center(cell), BADGE_RADIUS, color)
	_overlay.draw_arc(_center(cell), BADGE_RADIUS, 0.0, TAU, 24, Color(0.1, 0.1, 0.12), 2.5, true)
	_draw_letter(cell, letter, LETTER_COLOR)


func _draw_letter(cell: Vector2i, letter: String, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var origin: Vector2 = Vector2(cell) * Rules.TILE_SIZE
	var baseline: float = origin.y + Rules.TILE_SIZE / 2.0 + LETTER_SIZE * 0.35
	_overlay.draw_string(font, Vector2(origin.x, baseline), letter,
		HORIZONTAL_ALIGNMENT_CENTER, Rules.TILE_SIZE, LETTER_SIZE, color)
