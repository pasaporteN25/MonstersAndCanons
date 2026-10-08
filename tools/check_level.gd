# Revisa un nivel sin jugarlo (spec RF-206): muestra sus errores o, si está bien, el mapa con
# el recorrido de cada entrada y su largo en casillas.
#
# Uso: godot --headless --path . -s tools/check_level.gd -- data/levels/level_07.json
#      godot --headless --path . -s tools/check_level.gd            (todos los de la campaña)
#
# Termina con código 1 si algún nivel tiene errores.
extends SceneTree


func _init() -> void:
	var paths: PackedStringArray = OS.get_cmdline_user_args()
	if paths.is_empty():
		for level_id: String in LevelFile.campaign_ids():
			paths.append(LevelFile.LEVELS_DIR + level_id + ".json")
	var failed: int = 0
	for path: String in paths:
		if not path.begins_with("res://") and not path.is_absolute_path():
			path = "res://" + path
		if not _check(path):
			failed += 1
	print("\n%d de %d niveles con errores." % [failed, paths.size()] if failed > 0 \
		else "\nTodo bien (%d %s)." % [paths.size(), "nivel" if paths.size() == 1 else "niveles"])
	quit(1 if failed > 0 else 0)


func _check(path: String) -> bool:
	print("\n=== ", path)
	var result: Dictionary = LevelFile.load_level(path)
	if result["level"] == null:
		for problem: String in result["errors"]:
			print("  ✗ ", problem)
		return false
	var level: LevelData = result["level"]
	var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
	print("  %s · oro %d · vidas %d · %d oleadas" % [level.display_name, level.starting_gold,
		level.starting_lives, level.waves.size()])
	for i: int in grid.entrances.size():
		var letter: String = MapGrid.ENTRANCE_LETTERS[i]
		print("\n  Entrada %s: %d casillas hasta la salida (recorrido marcado con *)" % [letter, grid.routes[i].size()])
		for y: int in grid.height:
			var row: String = level.map_rows[y]
			for cell: Vector2i in grid.routes[i]:
				if cell.y == y and row[cell.x] == MapGrid.PATH:
					row = row.left(cell.x) + "*" + row.substr(cell.x + 1)
			print("    ", row)
	# RF-207: avisos (no impiden jugar). Las casillas que nadie pisa se marcan con "?".
	for warning: String in result["warnings"]:
		print("\n  ⚠ ", warning)
	if not grid.unused_cells.is_empty():
		print("  Casillas que ningún recorrido usa, marcadas con ?:")
		for y: int in grid.height:
			var row: String = level.map_rows[y]
			for cell: Vector2i in grid.unused_cells:
				if cell.y == y:
					row = row.left(cell.x) + "?" + row.substr(cell.x + 1)
			print("    ", row)
	return true
