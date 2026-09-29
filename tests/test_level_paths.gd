# Comprueba que cada Path2D (lo que siguen los enemigos) va por encima de casillas
# NO construibles (lo que se ve como camino). Plan §6.1, T13.
# Recorre TODOS los niveles de la campaña (desde M7, armados desde sus archivos de texto):
# así los niveles futuros quedan cubiertos.
extends GutTest

## Cada cuántos píxeles se revisa un punto del camino.
const SAMPLE_STEP_PX := 8.0


func _level_indexes() -> Array[int]:
	var result: Array[int] = []
	for i: int in GameFlow.level_count():
		result.append(i)
	return result


func _load_level(index: int) -> Level:
	var level: Level = GameFlow.level(index).build_map()
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
	assert_gt(_level_indexes().size(), 0)


func test_every_level_has_an_entrance() -> void:
	for index: int in _level_indexes():
		var level: Level = _load_level(index)
		assert_gt(level.entrance_count(), 0, "nivel %d tiene GroundPath0" % (index + 1))


func test_every_ground_path_stays_on_the_road() -> void:
	for index: int in _level_indexes():
		var level: Level = _load_level(index)
		for i: int in level.entrance_count():
			var bad: Vector2 = _first_point_on_buildable(level, level.get_ground_path(i))
			assert_eq(bad, Vector2.INF,
				"nivel %d, GroundPath%d pasa por una casilla construible en %s" % [index + 1, i, bad])


## Criterio de T13: si un punto del camino se mueve al pasto, el test lo detecta.
func test_detects_a_path_point_on_the_grass() -> void:
	var level: Level = _load_level(0)
	var path: Path2D = level.get_ground_path(0)
	path.curve = path.curve.duplicate()
	path.curve.set_point_position(1, Vector2(1056, 32))  # casilla (16, 0): pasto
	assert_ne(_first_point_on_buildable(level, path), Vector2.INF)


# --- Nivel 1: casillas concretas (RF-02) ---

func test_level_01_cell_types() -> void:
	var level: Level = _load_level(0)
	assert_true(level.is_buildable(Vector2i(0, 0)), "pasto")
	assert_false(level.is_buildable(Vector2i(0, 1)), "camino")
	assert_false(level.is_buildable(Vector2i(6, 2)), "roca")
	assert_false(level.is_buildable(Vector2i(-1, 0)), "fuera del mapa")
	assert_false(level.is_buildable(Vector2i(20, 0)), "fuera del mapa")


func test_level_01_is_20_by_9() -> void:
	var level: Level = _load_level(0)
	assert_eq(level.ground.get_used_rect(), Rect2i(0, 0, 20, 9), "RF-01")
