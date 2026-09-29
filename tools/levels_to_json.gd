# Conversión de una sola vez (T95, D-031): pasa los niveles de campaign.tres (escena del mapa +
# .tres) a archivos de texto data/levels/<id>.json, y escribe data/campaign.json.
#
# Uso: godot --headless --path . -s tools/levels_to_json.gd
extends SceneTree

const LETTER_OF: Dictionary = {
	Vector2i(0, 0): MapGrid.GRASS, Vector2i(1, 0): MapGrid.PATH, Vector2i(2, 0): MapGrid.BLOCKED,
}


func _init() -> void:
	var campaign: CampaignData = load("res://data/campaign.tres")
	var ids: PackedStringArray = []
	for level: LevelData in campaign.levels:
		var path: String = LevelFile.LEVELS_DIR + level.id + ".json"
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(_level_text(level))
		file.close()
		ids.append(level.id)
		print(path)
	var campaign_file := FileAccess.open(LevelFile.CAMPAIGN_PATH, FileAccess.WRITE)
	campaign_file.store_string("{\n  \"version\": 1,\n  \"niveles\": [%s]\n}\n" \
		% ", ".join(Array(ids).map(func(id: String) -> String: return "\"%s\"" % id)))
	campaign_file.close()
	print(LevelFile.CAMPAIGN_PATH)
	quit()


func _level_text(level: LevelData) -> String:
	var lines: PackedStringArray = ["{", "  \"version\": 1,"]
	lines.append("  \"nombre\": %s," % JSON.stringify(level.display_name))
	lines.append("  \"oro\": %d," % level.starting_gold)
	lines.append("  \"vidas\": %d," % level.starting_lives)
	if level.health_scale_percent_per_wave > 0:
		lines.append("  \"aumento_vida\": %d," % level.health_scale_percent_per_wave)
	lines.append("  \"mapa\": [")
	var rows: PackedStringArray = _map_rows(level)
	for y: int in rows.size():
		lines.append("    \"%s\"%s" % [rows[y], "," if y < rows.size() - 1 else ""])
	lines.append("  ],")
	lines.append("  \"oleadas\": [")
	for w: int in level.waves.size():
		var groups: PackedStringArray = []
		for group: SpawnGroup in level.waves[w].groups:
			groups.append(_group_text(group))
		var end: String = "," if w < level.waves.size() - 1 else ""
		lines.append("    [" + ",\n     ".join(groups) + "]" + end)
	lines.append("  ]")
	lines.append("}")
	return "\n".join(lines) + "\n"


func _group_text(group: SpawnGroup) -> String:
	var parts: PackedStringArray = [
		"\"enemigo\": \"%s\"" % group.enemy.resource_path.get_file().get_basename(),
		"\"cantidad\": %d" % group.count,
		"\"cada\": %s" % _seconds(group.interval),
	]
	if group.start_delay > 0.0:
		parts.append("\"desde\": %s" % _seconds(group.start_delay))
	if group.entrance_index > 0:
		parts.append("\"entrada\": \"%s\"" % MapGrid.ENTRANCE_LETTERS[group.entrance_index])
	return "{" + ", ".join(parts) + "}"


func _seconds(value: float) -> String:
	return "%.1f" % value if is_equal_approx(value * 10.0, roundf(value * 10.0)) else str(value)


## Las letras de cada casilla, con las entradas (A, B…) y la salida (S) donde empieza y
## termina cada camino.
func _map_rows(level: LevelData) -> PackedStringArray:
	var map: Level = level.map_scene.instantiate()
	var ground: TileMapLayer = map.get_node("Ground")
	var letters: Array = []
	for y: int in MapGrid.HEIGHT:
		var row: Array = []
		for x: int in MapGrid.WIDTH:
			row.append(LETTER_OF[ground.get_cell_atlas_coords(Vector2i(x, y))])
		letters.append(row)
	var entrances: Node = map.get_node("Entrances")
	var i: int = 0
	while entrances.has_node("GroundPath%d" % i):
		var curve: Curve2D = (entrances.get_node("GroundPath%d" % i) as Path2D).curve
		var start: Vector2i = _cell_inside(curve.get_point_position(0))
		var end: Vector2i = _cell_inside(curve.get_point_position(curve.point_count - 1))
		letters[start.y][start.x] = MapGrid.ENTRANCE_LETTERS[i]
		letters[end.y][end.x] = MapGrid.EXIT
		i += 1
	map.free()
	var rows: PackedStringArray = []
	for row: Array in letters:
		rows.append("".join(row))
	return rows


## La casilla de un punto; si el punto está fuera del mapa (entra o sale por el borde),
## la del borde más cercana.
func _cell_inside(point: Vector2) -> Vector2i:
	var cell := Vector2i((point / Rules.TILE_SIZE).floor())
	return Vector2i(clampi(cell.x, 0, MapGrid.WIDTH - 1), clampi(cell.y, 0, MapGrid.HEIGHT - 1))
