# Comprueba que cada Path2D (lo que siguen los enemigos) va por encima de casillas
# NO construibles (lo que se ve como camino). Plan §6.1, T13.
# Recorre TODOS los mapas scenes/levels/level_*.tscn, así los niveles futuros quedan cubiertos.
extends GutTest

const LEVELS_DIR := "res://scenes/levels/"
## Cada cuántos píxeles se revisa un punto del camino.
const SAMPLE_STEP_PX := 8.0


func _level_paths() -> Array[String]:
	var result: Array[String] = []
	for file: String in DirAccess.get_files_at(LEVELS_DIR):
		if file.begins_with("level_") and file.ends_with(".tscn"):
			result.append(LEVELS_DIR + file)
	return result


func _load_level(scene_path: String) -> Level:
	var level: Level = (load(scene_path) as PackedScene).instantiate()
	add_child_autofree(level)
	return level


## Devuelve el primer punto del camino que cae sobre una casilla construible,
## o Vector2.INF si todo el camino está bien.
func _first_point_on_buildable(level: Level, path: Path2D) -> Vector2:
	var curve: Curve2D = path.curve
	var distance: float = 0.0
	while distance <= curve.get_baked_length():
		var point: Vector2 = path.to_global(curve.sample_baked(distance))
		if level.is_buildable(level.cell_at(point)):
			return point
		distance += SAMPLE_STEP_PX
	return Vector2.INF


func test_there_is_at_least_one_level() -> void:
	assert_gt(_level_paths().size(), 0)


func test_every_level_has_an_entrance() -> void:
	for scene_path: String in _level_paths():
		var level: Level = _load_level(scene_path)
		assert_gt(level.entrance_count(), 0, "%s tiene GroundPath0" % scene_path)


func test_every_ground_path_stays_on_the_road() -> void:
	for scene_path: String in _level_paths():
		var level: Level = _load_level(scene_path)
		for i: int in level.entrance_count():
			var bad: Vector2 = _first_point_on_buildable(level, level.get_ground_path(i))
			assert_eq(bad, Vector2.INF,
				"%s GroundPath%d pasa por una casilla construible en %s" % [scene_path, i, bad])


## Criterio de T13: si un punto del camino se mueve al pasto, el test lo detecta.
func test_detects_a_path_point_on_the_grass() -> void:
	var level: Level = _load_level(LEVELS_DIR + "level_01.tscn")
	var path: Path2D = level.get_ground_path(0)
	path.curve = path.curve.duplicate()
	path.curve.set_point_position(1, Vector2(1056, 32))  # casilla (16, 0): pasto
	assert_ne(_first_point_on_buildable(level, path), Vector2.INF)


# --- Nivel 1: casillas concretas (RF-02) ---

func test_level_01_cell_types() -> void:
	var level: Level = _load_level(LEVELS_DIR + "level_01.tscn")
	assert_true(level.is_buildable(Vector2i(0, 0)), "pasto")
	assert_false(level.is_buildable(Vector2i(0, 1)), "camino")
	assert_false(level.is_buildable(Vector2i(6, 2)), "roca")
	assert_false(level.is_buildable(Vector2i(-1, 0)), "fuera del mapa")
	assert_false(level.is_buildable(Vector2i(20, 0)), "fuera del mapa")


func test_level_01_is_20_by_9() -> void:
	var level: Level = _load_level(LEVELS_DIR + "level_01.tscn")
	assert_eq(level.ground.get_used_rect(), Rect2i(0, 0, 20, 9), "RF-01")
