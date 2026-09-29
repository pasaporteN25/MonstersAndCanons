# Tests de los mapas de tamaño variable (T116, RF-250, RF-253, D-037).
extends GutTest


## Un mapa de `w`×`h` con una recta de la entrada A a la salida S, en la fila del medio.
func _rows(w: int, h: int) -> PackedStringArray:
	var rows: PackedStringArray = []
	for y: int in h:
		rows.append(".".repeat(w))
	rows[h / 2] = "A" + "#".repeat(w - 2) + "S"
	return rows


func _error_of(rows: PackedStringArray) -> String:
	var grid: MapGrid = MapGrid.parse(rows)
	assert_false(grid.is_valid(), "debería ser inválido")
	return "\n".join(grid.errors)


# --- Tamaños permitidos ---

func test_the_usual_size_still_works() -> void:
	var grid: MapGrid = MapGrid.parse(_rows(20, 9))
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.width, 20)
	assert_eq(grid.height, 9)


func test_the_biggest_size_is_valid_and_measured() -> void:
	var grid: MapGrid = MapGrid.parse(_rows(26, 12))
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.width, 26)
	assert_eq(grid.height, 12)
	assert_eq(grid.routes[0].size(), 26, "una recta de punta a punta")


func test_every_size_in_between_is_valid() -> void:
	for w: int in [20, 21, 23, 26]:
		for h: int in [9, 10, 12]:
			var grid: MapGrid = MapGrid.parse(_rows(w, h))
			assert_true(grid.is_valid(), "%d×%d: %s" % [w, h, grid.errors])
			assert_eq(Vector2i(grid.width, grid.height), Vector2i(w, h))


func test_sizes_outside_the_limits_are_invalid_and_say_so() -> void:
	assert_string_contains(_error_of(_rows(27, 12)), "entre 20 y 26")
	assert_string_contains(_error_of(_rows(19, 9)), "entre 20 y 26")
	assert_string_contains(_error_of(_rows(26, 13)), "entre 9 y 12")
	assert_string_contains(_error_of(_rows(20, 8)), "tiene 8 filas")


func test_rows_of_different_length_are_invalid() -> void:
	var rows: PackedStringArray = _rows(24, 10)
	rows[3] = "." .repeat(23)
	assert_string_contains(_error_of(rows), "La fila 4 tiene 23 letras y la fila 1 tiene 24")


# --- El tamaño real se usa en todos lados ---

func test_the_border_is_the_border_of_the_real_size() -> void:
	var grid: MapGrid = MapGrid.parse(_rows(26, 12))
	assert_true(grid.is_on_border(Vector2i(25, 6)), "la última columna de 26")
	assert_false(grid.is_on_border(Vector2i(19, 6)), "la 20 ya no es borde")
	assert_true(grid.is_on_border(Vector2i(5, 11)), "la última fila de 12")
	assert_true(grid.is_inside(Vector2i(25, 11)))
	assert_false(grid.is_inside(Vector2i(26, 11)))
	assert_false(grid.is_inside(Vector2i(25, 12)))


func test_an_entrance_inside_the_map_is_still_a_valid_entrance() -> void:
	# La entrada en la columna 21 de un mapa de 26: no es borde, pero el mapa es válido.
	var rows: PackedStringArray = _rows(26, 10)
	rows[5] = "S" + "#".repeat(20) + "A" + "...."
	var grid: MapGrid = MapGrid.parse(rows)
	assert_true(grid.is_valid(), str(grid.errors))
	assert_false(grid.is_on_border(grid.entrances[0]))


func test_unused_path_cells_are_found_in_the_whole_map() -> void:
	var rows: PackedStringArray = _rows(26, 12)
	rows[11] = "#".repeat(2) + ".".repeat(24)  # 2 casillas de camino sueltas, en la última fila
	var grid: MapGrid = MapGrid.parse(rows)
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.unused_cells.size(), 2)
	assert_eq(grid.warnings.size(), 1)


func test_the_ground_has_the_size_of_the_map() -> void:
	var ground: TileMapLayer = Level.make_ground(MapGrid.parse(_rows(26, 12)))
	add_child_autofree(ground)
	assert_eq(ground.get_used_rect().size, Vector2i(26, 12))
	assert_eq(ground.get_used_rect().position, Vector2i.ZERO)


func test_the_route_enters_and_leaves_from_outside_the_real_border() -> void:
	var level: Level = Level.build(MapGrid.parse(_rows(26, 12)))
	add_child_autofree(level)
	var curve: Curve2D = level.get_ground_path(0).curve
	assert_lt(curve.get_point_position(0).x, 0.0, "entra desde afuera por la izquierda")
	assert_gt(curve.get_point_position(curve.point_count - 1).x, 26.0 * Rules.TILE_SIZE, "sale por la derecha del mapa de 26")
	assert_true(level.is_inside(Vector2i(25, 11)))
	assert_false(level.is_inside(Vector2i(26, 11)))


# --- Archivos de nivel ---

func _level_text(rows: PackedStringArray) -> String:
	return JSON.stringify({
		"version": 1, "nombre": "Grande", "oro": 100, "vidas": 10, "mapa": Array(rows),
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]],
	})


func test_a_level_file_with_a_big_map_reads() -> void:
	var result: Dictionary = LevelFile.parse(_level_text(_rows(26, 12)), &"grande")
	assert_eq(result["errors"], PackedStringArray())
	var level: LevelData = result["level"]
	assert_eq(level.map_rows.size(), 12)
	assert_eq(level.map_rows[0].length(), 26)
	var built: Level = level.build_map()
	add_child_autofree(built)
	assert_true(built.is_inside(Vector2i(25, 11)))


func test_a_level_file_with_a_map_too_big_says_why() -> void:
	var result: Dictionary = LevelFile.parse(_level_text(_rows(30, 12)), &"grande")
	assert_null(result["level"])
	assert_string_contains("\n".join(result["errors"]), "entre 20 y 26")


func test_the_official_levels_keep_their_size() -> void:
	for level: LevelData in GameFlow.campaign.levels:
		var grid: MapGrid = MapGrid.parse(level.map_rows)
		assert_true(grid.is_valid(), str(level.id))
		assert_eq(Vector2i(grid.width, grid.height), Vector2i(20, 9), "%s no cambia de tamaño" % level.id)
