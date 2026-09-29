# Tests del mapa de letras (T93, spec §7.8: RF-201, RF-202, RF-204).
extends GutTest

## El nivel 6 (spec §7.7): dos entradas que se unen en la columna 11 (10 contando desde 0).
const NEST: PackedStringArray = [
	"..........B.........",
	"A#####....#.......X.",
	".....#....#.........",
	"...X.#############..",
	".................#..",
	"..################..",
	"..#.........X.......",
	"..#################S",
	".......X............",
]

## Mapa sencillo: una recta en la fila 5 (4 contando desde 0).
const LINE: PackedStringArray = [
	"....................",
	"....................",
	"....................",
	"....................",
	"A##################S",
	"....................",
	"....................",
	"....................",
	"....................",
]


func _with(rows: PackedStringArray, cell: Vector2i, letter: String) -> PackedStringArray:
	var copy: PackedStringArray = rows.duplicate()
	var row: String = copy[cell.y]
	copy[cell.y] = row.substr(0, cell.x) + letter + row.substr(cell.x + 1)
	return copy


func _cells(list: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(list)
	return result


func _assert_error(rows: PackedStringArray, text: String) -> void:
	var grid: MapGrid = MapGrid.parse(rows)
	assert_false(grid.is_valid(), "debería ser inválido: " + text)
	assert_true(" | ".join(grid.errors).contains(text), "el error dice '%s': %s" % [text, grid.errors])


# --- Letras (RF-201) ---

func test_letters_give_each_cell_its_type() -> void:
	var grid: MapGrid = MapGrid.parse(NEST)
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.cell_type(Vector2i(0, 0)), MapGrid.Cell.GRASS)
	assert_eq(grid.cell_type(Vector2i(3, 1)), MapGrid.Cell.PATH)
	assert_eq(grid.cell_type(Vector2i(18, 1)), MapGrid.Cell.BLOCKED)
	assert_eq(grid.cell_type(Vector2i(0, 1)), MapGrid.Cell.PATH, "la entrada es camino")
	assert_eq(grid.cell_type(Vector2i(19, 7)), MapGrid.Cell.PATH, "la salida es camino")


func test_entrances_in_letter_order_and_the_exit() -> void:
	var grid: MapGrid = MapGrid.parse(NEST)
	assert_eq(grid.entrances, [Vector2i(0, 1), Vector2i(10, 0)] as Array[Vector2i], "A y después B")
	assert_eq(grid.exit_cell, Vector2i(19, 7))


# --- Recorridos (RF-202) ---

func test_straight_route_has_two_corners() -> void:
	var grid: MapGrid = MapGrid.parse(LINE)
	assert_eq(grid.routes[0].size(), 20)
	assert_eq(grid.corners(0), [Vector2i(0, 4), Vector2i(19, 4)] as Array[Vector2i])


func test_routes_follow_the_road_and_join() -> void:
	var grid: MapGrid = MapGrid.parse(NEST)
	var tail: Array = [Vector2i(17, 3), Vector2i(17, 5), Vector2i(2, 5), Vector2i(2, 7), Vector2i(19, 7)]
	assert_eq(grid.corners(0), _cells([Vector2i(0, 1), Vector2i(5, 1), Vector2i(5, 3)] + tail))
	assert_eq(grid.corners(1), _cells([Vector2i(10, 0), Vector2i(10, 3)] + tail),
		"B baja y dobla a la derecha, hacia la salida (no hacia A)")


func test_route_is_the_shortest() -> void:
	# Un atajo por la fila 4 (3 contando desde 0): la columna 17 ya no hace falta.
	var rows: PackedStringArray = NEST.duplicate()
	rows[4] = "....#............#.."
	rows[3] = "...X##############.."
	var grid: MapGrid = MapGrid.parse(rows)
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.corners(0).slice(0, 4), [Vector2i(0, 1), Vector2i(5, 1), Vector2i(5, 3), Vector2i(4, 3)] as Array[Vector2i])


func test_every_route_cell_is_a_neighbor_of_the_next() -> void:
	var grid: MapGrid = MapGrid.parse(NEST)
	for route: Array in grid.routes:
		for i: int in route.size() - 1:
			var step: Vector2i = route[i + 1] - route[i]
			assert_eq(absi(step.x) + absi(step.y), 1)


# --- Errores (RF-204) ---

func test_a_tie_is_an_error() -> void:
	# Un anillo: desde la columna 4 se puede ir por la fila 4 o por la 6 (misma distancia).
	var rows: PackedStringArray = LINE.duplicate()
	rows[3] = "...#########........"
	rows[4] = "A###.......########S"
	rows[5] = "...#########........"
	_assert_error(rows, "dos recorridos igual de cortos")


func test_wrong_size() -> void:
	_assert_error(LINE.slice(0, 8), "tiene 8 filas")
	_assert_error(_with(LINE, Vector2i(0, 2), ".."), "La fila 3 tiene 21 letras")


func test_unknown_letter_says_where() -> void:
	_assert_error(_with(LINE, Vector2i(6, 1), "x"), "Letra desconocida 'x' en fila 2, columna 7")


func test_exit_missing_or_repeated() -> void:
	_assert_error(_with(LINE, Vector2i(19, 4), "#"), "Falta la salida")
	_assert_error(_with(LINE, Vector2i(10, 4), "S"), "Hay 2 salidas")


func test_entrance_problems() -> void:
	_assert_error(_with(LINE, Vector2i(0, 4), "#"), "Falta la entrada A")
	_assert_error(_with(LINE, Vector2i(0, 4), "B"), "Está la entrada B pero falta la A")
	_assert_error(_with(LINE, Vector2i(0, 3), "A"), "La entrada A está dos veces")
	_assert_error(_with(LINE, Vector2i(5, 0), "B"), "La entrada B (fila 1, columna 6) no tiene camino")


func test_a_map_without_grass_is_invalid() -> void:
	var rows: PackedStringArray = []
	for y: int in MapGrid.HEIGHT:
		rows.append("X".repeat(MapGrid.WIDTH))
	rows[4] = LINE[4]
	_assert_error(rows, "No hay pasto")
