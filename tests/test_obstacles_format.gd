# Formato y lectura de removibles y puntos de extracción (T206, RF-398 a RF-403).
extends GutTest

const ROWS: Array[String] = [
	"....................", "....................", "....................", "....................",
	"A##################S", "....................", "....................", "....................", "....................",
]
const BAD_CATALOG_PATH: String = "user://test_obstacles_catalog.json"


func after_each() -> void:
	if FileAccess.file_exists(BAD_CATALOG_PATH):
		DirAccess.remove_absolute(BAD_CATALOG_PATH)


func _level(extra: Dictionary = {}, rows: Array = ROWS) -> Dictionary:
	var data: Dictionary = {"version": 1, "nombre": "Prueba", "oro": 100, "vidas": 10, "mapa": rows,
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	data.merge(extra, true)
	return LevelFile.parse(JSON.stringify(data), &"prueba")


func _rows_with(cell: Vector2i, letter: String) -> Array:
	var rows: Array = ROWS.duplicate()
	var row: String = rows[cell.y]
	rows[cell.y] = row.left(cell.x) + letter + row.substr(cell.x + 1)
	return rows


func test_catalog_has_the_initial_classes_and_values() -> void:
	var result: Dictionary = ObstacleCatalog.load_data()
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(ObstacleCatalog.class_ids(result["data"]), PackedStringArray(["arbol", "bosque_explotable", "escombro", "mina", "roca"]))
	assert_eq(ObstacleCatalog.removable("arbol", result["data"])["costo"], 40.0)
	assert_eq(ObstacleCatalog.extraction("mina", result["data"])["reserva"], 8.0)
	assert_eq(ObstacleCatalog.machine(result["data"])["precio"], 180.0)


func test_catalog_rejects_misspelled_keys_and_bad_value_types() -> void:
	var data: Dictionary = ObstacleCatalog.load_data()["data"].duplicate(true)
	data["removibles"]["arbol"]["costro"] = data["removibles"]["arbol"].get("costo")
	data["removibles"]["arbol"].erase("costo")
	data["removibles"]["roca"]["costo"] = "60"
	data["removibles"]["roca"]["probabilidad"] = 101
	var file := FileAccess.open(BAD_CATALOG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var result: Dictionary = ObstacleCatalog.load_data(BAD_CATALOG_PATH)
	assert_true(" ".join(result["errors"]).contains("costro"))
	assert_true(" ".join(result["errors"]).contains("costo"))
	assert_true(" ".join(result["errors"]).contains("no puede superar 100"))
	assert_true(result["data"].is_empty())


func test_removable_and_extraction_resolve_defaults_and_overrides() -> void:
	var rows: Array = _rows_with(Vector2i(3, 1), "t")
	rows = _rows_with_on(rows, Vector2i(5, 1), "m")
	var result: Dictionary = _level({"leyenda": {
		"t": {"removible": {"clase": "arbol", "costo": 30}},
		"m": {"extraccion": {"clase": "mina", "reserva": 6}},
	}}, rows)
	assert_eq(result["errors"], PackedStringArray())
	var level: LevelData = result["level"]
	assert_eq(level.obstacles.size(), 2)
	assert_eq(level.obstacles[0].cell, Vector2i(3, 1))
	assert_eq(level.obstacles[0].class_id, &"arbol")
	assert_eq(level.obstacles[0].cost, 30)
	assert_eq(level.obstacles[0].seconds, 4.0)
	assert_eq(level.obstacles[0].reward_amount, 1)
	assert_eq(level.obstacles[0].chance_percent, 50)
	assert_eq(level.obstacles[1].kind, ObstacleSpec.Kind.EXTRACTION)
	assert_eq(level.obstacles[1].reserve, 6)
	assert_true(level.uses_resources())
	assert_eq(level.legend["t"]["dibujo"], "arbol")


func _rows_with_on(rows: Array, cell: Vector2i, letter: String) -> Array:
	var copy: Array = rows.duplicate()
	var row: String = copy[cell.y]
	copy[cell.y] = row.left(cell.x) + letter + row.substr(cell.x + 1)
	return copy


func test_removable_is_blocked_and_clear_cell_leaves_routes_unchanged() -> void:
	var rows: Array = _rows_with(Vector2i(3, 1), "t")
	rows = _rows_with_on(rows, Vector2i(4, 1), "m")
	var level: LevelData = _level({"leyenda": {"t": {"removible": {"clase": "roca"}},
		"m": {"extraccion": {"clase": "mina"}}}}, rows)["level"]
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	var routes: Array = grid.routes.duplicate(true)
	assert_eq(grid.cell_type(Vector2i(3, 1)), MapGrid.Cell.BLOCKED)
	assert_true(grid.clear_cell(Vector2i(3, 1)))
	assert_eq(grid.cell_type(Vector2i(3, 1)), MapGrid.Cell.GRASS)
	assert_eq(grid.routes, routes)
	assert_false(grid.clear_cell(Vector2i(3, 1)))
	assert_false(grid.clear_cell(Vector2i(4, 1)), "una extracción no se puede despejar")


func test_invalid_obstacle_format_reports_specific_errors() -> void:
	var rows: Array = _rows_with(Vector2i(3, 1), "t")
	var result: Dictionary = _level({"leyenda": {"t": {"removible": {"clase": "dragon"}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "la clase \"dragon\" no existe")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol", "costro": 2}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "costro")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol"}, "extraccion": {"clase": "mina"}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "a la vez")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol"}, "construible": true}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "construible")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol", "costo": 0}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "mayor que 0")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol", "recursos": -1}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "número entero")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol", "probabilidad": 101}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "no puede superar 100")
	result = _level({"leyenda": {"t": {"dibujo": "roca", "removible": {"clase": "arbol"}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "dibujo tiene que ser")
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol", "hallazgo": "technology"}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "solo se puede usar en un escombro")
	result = _level({"leyenda": {"t": {"removible": {"clase": "escombro", "hallazgo": "missing"}}}}, rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "no existe en progression.json")
	result = _level({"demoledora": "sí"})
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "demoledora")
	var path_rows: Array = ROWS.duplicate()
	path_rows[4] = "A########t#########S"
	result = _level({"leyenda": {"t": {"removible": {"clase": "arbol"}}}}, path_rows)
	assert_null(result["level"], "un removible no puede interrumpir el camino")
	assert_string_contains(" ".join(result["errors"]), "no tiene camino hasta la salida")
	var duplicate_rows: Array = _rows_with(Vector2i(3, 1), "t")
	duplicate_rows = _rows_with_on(duplicate_rows, Vector2i(5, 1), "u")
	result = _level({"leyenda": {"t": {"removible": {"clase": "escombro", "hallazgo": "technology"}},
		"u": {"removible": {"clase": "escombro", "hallazgo": "technology"}}}}, duplicate_rows)
	assert_null(result["level"])
	assert_string_contains(" ".join(result["errors"]), "ya hay un hallazgo")


func test_editor_preserves_new_legend_fields_and_machine_flag() -> void:
	var rows: Array = _rows_with(Vector2i(3, 1), "t")
	var source: Dictionary = {"version": 1, "nombre": "Prueba", "oro": 100, "vidas": 10, "demoledora": true,
		"leyenda": {"t": {"removible": {"clase": "arbol", "probabilidad": 0}}}, "mapa": rows,
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	var draft: LevelDraft = LevelDraft.from_text(JSON.stringify(source), "prueba")
	var saved: String = draft.to_text()
	assert_eq(LevelFile.parse(saved, &"prueba")["errors"], PackedStringArray())
	assert_true(saved.contains("\"demoledora\": true"))
	assert_true(saved.contains("\"removible\""))
	var reread := JSON.new()
	assert_eq(reread.parse(saved), OK)
	assert_eq(reread.data["leyenda"]["t"]["removible"]["probabilidad"], 0.0)


func test_example_and_official_levels_remain_valid() -> void:
	var example: Dictionary = LevelFile.load_level("res://tools/ejemplos/mapa_removibles.json")
	assert_eq(example["errors"], PackedStringArray())
	assert_eq((example["level"] as LevelData).obstacles.size(), 4)
	for level: LevelData in GameFlow.campaign.levels:
		assert_true(level.obstacles.is_empty(), str(level.id))
		assert_eq(level.machine_enabled, false, str(level.id))


func test_catalog_drawings_cover_every_obstacle_class() -> void:
	var data: Dictionary = ObstacleCatalog.load_data()["data"]
	for class_id: String in ObstacleCatalog.class_ids(data):
		assert_true(MapDrawings.is_valid(class_id), class_id)
		assert_eq(MapDrawings.kind(class_id), MapDrawings.KIND_OBJECT, class_id)
