# T223: los niveles 6 (El lindero) y 7 (El aserradero) son de bosque y tienen removibles.
# Los removibles nunca tocan el camino ni las casillas de impacto del Embestidor (RF-379),
# y el mapa se puede jugar sin demoler nada (los que tapan casillas libres son pocos).
extends GutTest

# nivel → [removibles, largo de cada recorrido (no cambió respecto de antes de T223)]
const EXPECTED: Dictionary = {
	6: [3, [56, 47]],
	7: [6, [30, 29]],
}
## Casillas libres (".") que tapa un removible en cada nivel; el resto reemplaza casillas "X".
const FREE_CELLS_COVERED: Dictionary = {6: 2, 7: 0}


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_0%d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


func test_levels_6_and_7_are_forest_with_the_expected_removables() -> void:
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		assert_eq(level.theme, &"bosque", "nivel %d: tema bosque" % n)
		assert_eq(level.obstacles.size(), EXPECTED[n][0], "nivel %d: removibles" % n)
		for obstacle: ObstacleSpec in level.obstacles:
			assert_eq(obstacle.kind, ObstacleSpec.Kind.REMOVABLE, "nivel %d" % n)


func test_level_6_gives_no_resources_and_level_7_gives_one_at_random() -> void:
	var six: LevelData = _load(6)
	assert_false(six.uses_resources(), "Q-18: el 6 no da recursos")
	assert_false(six.machine_enabled)
	var seven: LevelData = _load(7)
	assert_true(seven.uses_resources(), "Q-18: el 7 es el primer drop")
	assert_true(seven.machine_enabled, "el 7 habilita la demoledora")
	for obstacle: ObstacleSpec in seven.obstacles:
		assert_eq(obstacle.reward_amount, 1)
		assert_between(obstacle.chance_percent, 1, 99, "al azar, ni seguro ni nunca")


func test_removables_do_not_change_the_routes() -> void:
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		assert_eq(grid.errors.size(), 0, "nivel %d" % n)
		var lengths: Array = []
		for route: Array in grid.routes:
			lengths.append(route.size())
		assert_eq(lengths, EXPECTED[n][1], "nivel %d: largo de los recorridos" % n)


func test_removables_keep_the_rammer_impact_cells_free() -> void:
	# RF-379: la casilla de impacto está a ≤ 1,25 casillas del extremo de una recta (una esquina del camino).
	for n: int in EXPECTED.keys():
		var level: LevelData = _load(n)
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		var corners: Array[Vector2i] = []
		for route: Array in grid.routes:
			for i: int in range(1, route.size() - 1):
				if route[i] - route[i - 1] != route[i + 1] - route[i]:
					corners.append(route[i])
		for obstacle: ObstacleSpec in level.obstacles:
			for corner: Vector2i in corners:
				assert_gt(Vector2(obstacle.cell).distance_to(Vector2(corner)), 1.25,
					"nivel %d: el removible de %s tapa un impacto del Embestidor" % [n, obstacle.cell])


func test_most_removables_replace_cells_that_were_already_blocked() -> void:
	# Antes de T223 esas casillas eran "X" (bloqueadas) salvo las pocas que se anotan acá.
	for n: int in FREE_CELLS_COVERED.keys():
		var before: Array = _rows_before(n)
		var level: LevelData = _load(n)
		var covered: int = 0
		for obstacle: ObstacleSpec in level.obstacles:
			var old: String = String(before[obstacle.cell.y])[obstacle.cell.x]
			assert_true(old in ".X", "nivel %d: nunca sobre el camino" % n)
			if old == ".":
				covered += 1
		assert_eq(covered, FREE_CELLS_COVERED[n], "nivel %d: casillas libres tapadas" % n)


## El mapa de cada nivel tal como era antes de T223.
func _rows_before(n: int) -> Array:
	if n == 6:
		return [
			"..........B.........", "A#####....#.......X.", ".....#....#.........",
			"...X.#############..", ".................#..", "..################..",
			"..#.........X.......", "..#################S", ".......X............"]
	return [
		"....................", "A#################..", "....X...X.....X..#..",
		".X....X......#####..", "........##S#.#......", "..#######..###...X..",
		"..#.......X....X....", "..#################B", ".....X......X......."]
