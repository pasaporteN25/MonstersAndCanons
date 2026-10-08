# T222: los niveles 1 a 5 ganaron tema y señales (RF-267, Q-36) sin cambiar nada jugable.
# Los números salen de los niveles tal como estaban antes (X totales y largo de cada recorrido).
extends GutTest

# nivel → [casillas bloqueadas (X + letras de leyenda), casillas de camino, largos de recorrido]
const BEFORE: Dictionary = {
	1: [5, 50, [52]],
	2: [3, 42, [44]],
	3: [4, 40, [32, 32]],
	4: [3, 70, [72]],
	5: [4, 35, [26, 26, 14]],
}


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_0%d.json" % n)
	return result["level"]


func test_levels_1_to_5_keep_blocked_cells_path_and_routes() -> void:
	for n: int in BEFORE.keys():
		var level: LevelData = _load(n)
		assert_not_null(level, "nivel %d carga sin errores" % n)
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		assert_eq(grid.errors.size(), 0, "nivel %d sin errores de mapa" % n)
		var blocked: int = 0
		var path: int = 0
		for row: String in level.map_rows:
			blocked += row.count("X")
			path += row.count("#")
		for letter: String in level.legend.keys():
			assert_false(level.legend[letter].get("construible", false), "nivel %d: '%s' no construible" % [n, letter])
			for row: String in level.map_rows:
				blocked += row.count(letter)
		assert_eq(blocked, BEFORE[n][0], "nivel %d: casillas bloqueadas" % n)
		assert_eq(path, BEFORE[n][1], "nivel %d: casillas de camino" % n)
		var lengths: Array = []
		for route in grid.routes:
			lengths.append(route.size())
		assert_eq(lengths, BEFORE[n][2], "nivel %d: largo de los recorridos" % n)
		assert_eq(level.theme, "pradera", "nivel %d: tema pradera" % n)
