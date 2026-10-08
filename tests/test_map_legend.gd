# Tests del tema y la leyenda en el archivo del nivel (T122, RF-260, RF-262 a RF-267, D-039).
extends GutTest

const LEVEL_MAP: Array = [
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


## El texto de un nivel con el mapa dado y los campos extra (tema, leyenda…).
func _text(extra: Dictionary = {}, rows: Array = LEVEL_MAP) -> String:
	var data: Dictionary = {
		"version": 1, "nombre": "Prueba", "oro": 100, "vidas": 10, "mapa": rows,
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]],
	}
	data.merge(extra, true)
	return JSON.stringify(data)


func _rows_with(cell: Vector2i, letter: String) -> Array:
	var rows: Array = LEVEL_MAP.duplicate()
	var row: String = rows[cell.y]
	rows[cell.y] = row.left(cell.x) + letter + row.substr(cell.x + 1)
	return rows


func _errors_of(extra: Dictionary, rows: Array = LEVEL_MAP) -> String:
	var result: Dictionary = LevelFile.parse(_text(extra, rows), &"prueba")
	assert_null(result["level"], "debería tener errores")
	return "\n".join(result["errors"])


# --- Sin los campos nuevos, todo igual (RF-267) ---

func test_a_level_without_theme_or_legend_is_the_usual_one() -> void:
	var result: Dictionary = LevelFile.parse(_text(), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	var level: LevelData = result["level"]
	assert_eq(level.theme, MapThemes.DEFAULT)
	assert_eq(level.theme, &"pradera")
	assert_true(level.legend.is_empty())


func test_the_official_levels_6_to_9_have_no_legend_and_levels_1_to_5_only_decoration() -> void:
	# T222 (Q-36): los niveles 1 a 5 tienen señales y oasis, siempre no construibles (reemplazan casillas X).
	for level: LevelData in GameFlow.campaign.levels:
		assert_eq(level.theme, &"pradera", str(level.id))
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		if level.legend.is_empty():
			assert_true(grid.legend_cells.is_empty(), str(level.id))
		for letter: String in level.legend.keys():
			assert_false(level.legend[letter].get("construible", false), "%s: '%s'" % [level.id, letter])


# --- Tema (RF-260) ---

func test_every_theme_is_accepted() -> void:
	assert_eq(MapThemes.IDS.size(), 7)
	for id: String in MapThemes.IDS:
		var result: Dictionary = LevelFile.parse(_text({"tema": id}), &"prueba")
		assert_eq(result["errors"], PackedStringArray(), id)
		assert_eq((result["level"] as LevelData).theme, StringName(id))


func test_an_unknown_theme_lists_the_valid_ones() -> void:
	var errors: String = _errors_of({"tema": "playa"})
	assert_string_contains(errors, "tema:")
	assert_string_contains(errors, "playa")
	assert_string_contains(errors, "desierto, nieve, volcan, bosque, pantano, ruinas")


func test_a_theme_that_is_not_text_is_an_error() -> void:
	assert_string_contains(_errors_of({"tema": 3}), "tema:")


# --- Leyenda (RF-262) ---

func test_a_legend_letter_reads_with_its_drawing_and_buildable_flag() -> void:
	var legend: Dictionary = {"~": {"dibujo": "agua"}, ",": {"dibujo": "flores", "construible": true}}
	var rows: Array = _rows_with(Vector2i(3, 1), "~")
	rows = _rows_with_on(rows, Vector2i(5, 1), ",")
	var result: Dictionary = LevelFile.parse(_text({"leyenda": legend}, rows), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	var level: LevelData = result["level"]
	assert_eq(level.legend["~"], {"dibujo": "agua", "construible": false}, "construible vale false si no se escribe")
	assert_eq(level.legend[","], {"dibujo": "flores", "construible": true})


func _rows_with_on(rows: Array, cell: Vector2i, letter: String) -> Array:
	var copy: Array = rows.duplicate()
	var row: String = copy[cell.y]
	copy[cell.y] = row.left(cell.x) + letter + row.substr(cell.x + 1)
	return copy


func test_legend_letters_are_grass_or_blocked_and_never_path() -> void:
	var legend: Dictionary = {"~": {"dibujo": "agua"}, ",": {"dibujo": "flores", "construible": true}}
	var rows: Array = _rows_with_on(_rows_with(Vector2i(3, 1), "~"), Vector2i(5, 1), ",")
	var level: LevelData = LevelFile.parse(_text({"leyenda": legend}, rows), &"prueba")["level"]
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	assert_true(grid.is_valid(), str(grid.errors))
	assert_eq(grid.cell_type(Vector2i(3, 1)), MapGrid.Cell.BLOCKED, "el agua no se construye")
	assert_eq(grid.cell_type(Vector2i(5, 1)), MapGrid.Cell.GRASS, "las flores sí")
	assert_eq(grid.legend_cells[Vector2i(3, 1)], "agua")
	assert_eq(grid.legend_cells[Vector2i(5, 1)], "flores")
	var built: Level = level.build_map()
	add_child_autofree(built)
	assert_false(built.is_buildable(Vector2i(3, 1)))
	assert_true(built.is_buildable(Vector2i(5, 1)))
	assert_eq(built.legend_cells.size(), 2)


func test_the_routes_are_identical_with_and_without_a_legend() -> void:
	var plain: MapGrid = MapGrid.parse(PackedStringArray(LEVEL_MAP))
	var rows: Array = LEVEL_MAP.duplicate()
	for cell: Vector2i in [Vector2i(3, 1), Vector2i(3, 2), Vector2i(10, 6), Vector2i(11, 6)]:
		rows = _rows_with_on(rows, cell, "~")
	var legend: Dictionary = {"~": {"dibujo": "agua"}}
	var with_legend: MapGrid = MapGrid.parse(PackedStringArray(rows), legend)
	assert_true(with_legend.is_valid(), str(with_legend.errors))
	assert_eq(with_legend.routes, plain.routes)
	assert_eq(with_legend.entrances, plain.entrances)
	assert_eq(with_legend.exit_cell, plain.exit_cell)
	assert_eq(with_legend.unused_cells, plain.unused_cells)


func test_a_legend_letter_never_becomes_an_entrance_or_exit_or_path() -> void:
	# Un enemigo no puede pasar por una casilla de la leyenda: la recta A→S no cambia.
	var rows: Array = _rows_with(Vector2i(5, 5), "~")
	var grid: MapGrid = MapGrid.parse(PackedStringArray(rows), {"~": {"dibujo": "lava", "construible": false}})
	assert_eq(grid.routes[0].size(), 20)
	assert_false(grid.routes[0].has(Vector2i(5, 5)))


# --- Errores (RF-265) ---

func test_an_undeclared_letter_mentions_the_legend() -> void:
	var errors: String = _errors_of({}, _rows_with(Vector2i(3, 1), "~"))
	assert_string_contains(errors, "Letra desconocida '~' en fila 2, columna 4")
	assert_string_contains(errors, "leyenda")


func test_a_declared_but_unused_letter_is_only_a_warning() -> void:
	var result: Dictionary = LevelFile.parse(_text({"leyenda": {"~": {"dibujo": "agua"}}}), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	assert_eq((result["warnings"] as PackedStringArray).size(), 1)
	assert_string_contains(result["warnings"][0], "'~' está en la leyenda pero no se usa")


func test_forbidden_letters_are_errors() -> void:
	for letter: String in [".", "#", "X", "S", "A", "H", " ", "\"", "\\"]:
		var errors: String = _errors_of({"leyenda": {letter: {"dibujo": "agua"}}})
		assert_string_contains(errors, "leyenda", "la letra '%s'" % letter)


func test_a_key_that_is_not_a_single_character_is_an_error() -> void:
	assert_string_contains(_errors_of({"leyenda": {"~~": {"dibujo": "agua"}}}), "una sola letra")
	assert_string_contains(_errors_of({"leyenda": {"": {"dibujo": "agua"}}}), "una sola letra")


func test_an_unknown_drawing_lists_the_catalog() -> void:
	var errors: String = _errors_of({"leyenda": {"~": {"dibujo": "dragon"}}})
	assert_string_contains(errors, "dragon")
	assert_string_contains(errors, "agua")
	assert_string_contains(errors, "cactus")


func test_a_missing_drawing_or_a_bad_flag_is_an_error() -> void:
	assert_string_contains(_errors_of({"leyenda": {"~": {}}}), "dibujo")
	assert_string_contains(_errors_of({"leyenda": {"~": {"dibujo": "agua", "construible": "si"}}}), "construible")


func test_a_legend_entry_with_a_misspelled_key_is_an_error() -> void:
	assert_string_contains(_errors_of({"leyenda": {"~": {"dibujo": "agua", "contruible": true}}}), "contruible")


func test_a_legend_that_is_not_an_object_is_an_error() -> void:
	assert_string_contains(_errors_of({"leyenda": ["~"]}), "leyenda:")
	assert_string_contains(_errors_of({"leyenda": {"~": "agua"}}), "tiene que ser un objeto")


func test_the_legend_limit_is_ten_letters() -> void:
	var ok: Dictionary = {}
	for letter: String in ["~", ",", "a", "b", "c", "d", "e", "f", "g", "h"]:
		ok[letter] = {"dibujo": "roca"}
	var result: Dictionary = LevelFile.parse(_text({"leyenda": ok}), &"prueba")
	assert_eq(LevelFile.MAX_LEGEND, 10)
	assert_eq((result["level"] as LevelData).legend.size(), 10, "diez sí")
	ok["i"] = {"dibujo": "roca"}
	assert_string_contains(_errors_of({"leyenda": ok}), "el máximo es 10")


func test_the_whole_catalog_is_accepted() -> void:
	var ids: PackedStringArray = MapDrawings.ids()
	assert_eq(ids.size(), 19)
	assert_eq(ids.size(), 22)
	for id: String in ids:
		var result: Dictionary = LevelFile.parse(_text({"leyenda": {"~": {"dibujo": id}}}, _rows_with(Vector2i(3, 1), "~")), &"prueba")
		assert_eq(result["errors"], PackedStringArray(), id)
	assert_eq(MapDrawings.kind("agua"), MapDrawings.KIND_GROUND)
	assert_eq(MapDrawings.kind("cactus"), MapDrawings.KIND_OBJECT)
	assert_eq(MapDrawings.kind("no_existe"), "")


# --- El editor conserva tema y leyenda (RF-266) ---

func test_the_editor_keeps_theme_and_legend_when_opening_and_saving() -> void:
	var legend: Dictionary = {"~": {"dibujo": "hielo"}, ",": {"dibujo": "flores", "construible": true}}
	var rows: Array = _rows_with_on(_rows_with(Vector2i(3, 1), "~"), Vector2i(5, 1), ",")
	var text: String = _text({"tema": "nieve", "leyenda": legend}, rows)
	var draft: LevelDraft = LevelDraft.from_text(text, "mapa_frio")
	assert_eq(draft.data["tema"], "nieve")
	assert_eq(draft.letter_at(Vector2i(3, 1)), "~", "las letras de la leyenda no se pierden")
	assert_true(draft.grid().is_valid(), str(draft.grid().errors))
	assert_eq(draft.check()["errors"], PackedStringArray())
	var saved: String = draft.to_text()
	var reread: Dictionary = LevelFile.parse(saved, &"mapa_frio")
	assert_eq(reread["errors"], PackedStringArray())
	var level: LevelData = reread["level"]
	assert_eq(level.theme, &"nieve")
	assert_eq(level.legend["~"], {"dibujo": "hielo", "construible": false})
	assert_eq(level.legend[","], {"dibujo": "flores", "construible": true})
	assert_eq(LevelDraft.from_text(saved, "x").to_text(), saved, "guardar dos veces da el mismo texto")


func test_a_draft_without_theme_or_legend_writes_neither() -> void:
	var text: String = LevelDraft.new_level().to_text()
	assert_false(text.contains("\"tema\""))
	assert_false(text.contains("\"leyenda\""))
