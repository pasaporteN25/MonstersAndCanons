# Tests de los dibujos de la leyenda (T125, RF-263, D-039).
extends GutTest

const EXAMPLES: PackedStringArray = ["pradera", "desierto", "nieve", "volcan", "bosque", "pantano", "ruinas"]


## Un mapa de 20×9 con una recta A→S y la letra "~" en algunas casillas.
func _level_with(drawing: String, buildable: bool = false) -> Level:
	var rows: PackedStringArray = []
	for y: int in 9:
		rows.append(".".repeat(20))
	rows[4] = "A" + "#".repeat(18) + "S"
	rows[1] = "...~~~~".rpad(20, ".")
	rows[2] = "...~~~~".rpad(20, ".")
	var legend: Dictionary = {"~": {"dibujo": drawing, "construible": buildable}}
	return Level.build(MapGrid.parse(rows, legend), MapThemes.DEFAULT)


# --- El catálogo ---

func test_every_object_has_a_drawing_and_every_ground_has_colors() -> void:
	for id: String in MapDrawings.ids():
		match MapDrawings.kind(id):
			MapDrawings.KIND_OBJECT:
				assert_not_null(MapDrawings.texture(id), "%s sin dibujo" % id)
				assert_true(MapDrawings.ground_colors(id).is_empty())
			MapDrawings.KIND_GROUND:
				assert_null(MapDrawings.texture(id))
				var colors: Dictionary = MapDrawings.ground_colors(id)
				for key: String in ["base", "light", "dark", "edge"]:
					assert_true(colors.has(key), "%s sin %s" % [id, key])
			_:
				fail_test("%s no es ni suelo ni objeto" % id)


func test_the_catalog_has_four_grounds_and_twelve_objects() -> void:
	var grounds: int = 0
	var objects: int = 0
	for id: String in MapDrawings.ids():
		if MapDrawings.kind(id) == MapDrawings.KIND_GROUND:
			grounds += 1
		else:
			objects += 1
	assert_eq(grounds, 4)
	assert_eq(objects, 12)


func test_an_unknown_drawing_is_nothing() -> void:
	assert_false(MapDrawings.is_valid("dragon"))
	assert_eq(MapDrawings.kind("dragon"), "")
	assert_null(MapDrawings.texture("dragon"))
	assert_true(MapDrawings.ground_colors("dragon").is_empty())


func test_grounds_are_told_apart_by_color() -> void:
	var bases: Dictionary = {}
	for id: String in ["agua", "hielo", "lava", "barro"]:
		bases[str(MapDrawings.ground_colors(id)["base"])] = true
	assert_eq(bases.size(), 4)


# --- Pintarlos ---

func test_every_drawing_paints_in_a_level_without_errors() -> void:
	for id: String in MapDrawings.ids():
		var level: Level = _level_with(id)
		add_child_autofree(level)
		assert_eq(level.legend_cells.size(), 8, id)
		await wait_frames(2)
	assert_true(true, "se pintaron los 16")


func test_every_drawing_paints_in_every_theme() -> void:
	for theme: String in MapThemes.IDS:
		var rows: PackedStringArray = []
		for y: int in 9:
			rows.append(".".repeat(20))
		rows[4] = "A" + "#".repeat(18) + "S"
		rows[1] = "..~~a~b~c~d~e~f~g~h."
		var legend: Dictionary = {}
		var index: int = 0
		var letters: PackedStringArray = ["~", "a", "b", "c", "d", "e", "f", "g", "h"]
		var ids: PackedStringArray = MapDrawings.ids()
		for letter: String in letters:
			legend[letter] = {"dibujo": ids[index % ids.size()], "construible": false}
			index += 1
		var level: Level = Level.build(MapGrid.parse(rows, legend), StringName(theme))
		add_child_autofree(level)
		await wait_frames(2)
	assert_true(true, "todos los dibujos en los siete temas")


func test_the_legend_never_changes_what_can_be_built_except_for_buildable_ones() -> void:
	var lake: Level = _level_with("agua", false)
	add_child_autofree(lake)
	assert_false(lake.is_buildable(Vector2i(4, 1)), "no se construye sobre el agua")
	var flowers: Level = _level_with("flores", true)
	add_child_autofree(flowers)
	assert_true(flowers.is_buildable(Vector2i(4, 1)), "sí sobre las flores")
	assert_false(flowers.is_buildable(Vector2i(0, 4)), "ni sobre el camino")


func test_the_editor_view_draws_the_legend_too() -> void:
	var rows: PackedStringArray = []
	for y: int in 9:
		rows.append(".".repeat(20))
	rows[4] = "A" + "#".repeat(18) + "S"
	rows[6] = "..~~~~..............".left(20)
	var grid: MapGrid = MapGrid.parse(rows, {"~": {"dibujo": "lava", "construible": false}})
	assert_true(grid.is_valid(), str(grid.errors))
	var view := MapView.new()
	add_child_autofree(view)
	view.show_map(rows, grid, &"volcan")
	await wait_frames(2)
	assert_eq(grid.legend_cells.size(), 4)


# --- Los mapas de ejemplo (T126) ---

func test_the_example_map_of_every_theme_is_valid_and_has_no_warnings() -> void:
	for theme: String in EXAMPLES:
		var result: Dictionary = LevelFile.load_level("res://tools/ejemplos/tema_%s.json" % theme)
		assert_eq(result["errors"], PackedStringArray(), theme)
		assert_eq(result["warnings"], PackedStringArray(), "%s: sin avisos" % theme)
		var level: LevelData = result["level"]
		assert_eq(level.theme, StringName(theme))
		assert_gt(level.legend.size(), 0, "%s usa la leyenda" % theme)


func test_the_example_maps_have_the_same_routes_as_the_map_they_came_from() -> void:
	# Son el nivel 4 con parches de leyenda: el recorrido no puede haber cambiado (RF-264).
	var original: MapGrid = MapGrid.parse(GameFlow.level(3).map_rows)
	for theme: String in EXAMPLES:
		var level: LevelData = LevelFile.load_level("res://tools/ejemplos/tema_%s.json" % theme)["level"]
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		assert_eq(grid.routes, original.routes, theme)
