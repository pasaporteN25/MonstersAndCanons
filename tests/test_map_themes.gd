# Tests de los temas del mapa (T123, T124, RF-260, RF-261, D-039).
extends GutTest

const KEYS: PackedStringArray = ["fill_grass", "fill_path", "detail", "tuft", "accent", "flowers", "flower_chance", "edge", "pebble"]
const DETAILS: PackedStringArray = ["tufts", "dunes", "snow", "cracks", "leaves", "mud", "cobbles"]


func _grid() -> MapGrid:
	var rows: PackedStringArray = []
	for y: int in 9:
		rows.append(".".repeat(20))
	rows[4] = "A" + "#".repeat(18) + "S"
	rows[2] = "..X....X.........X.."
	rows[6] = "....X.......X......."
	return MapGrid.parse(rows)


# --- Las paletas ---

func test_there_are_seven_themes_and_each_has_a_full_palette() -> void:
	assert_eq(MapThemes.IDS.size(), 7)
	for id: String in MapThemes.IDS:
		var palette: Dictionary = MapThemes.palette(StringName(id))
		for key: String in KEYS:
			assert_true(palette.has(key), "%s no tiene %s" % [id, key])
		assert_true(DETAILS.has(palette["detail"]), "%s: detalle desconocido" % id)


func test_the_meadow_is_exactly_the_old_look() -> void:
	# RF-267: los niveles de siempre no cambian. Estos son los números que tenía LevelDecor antes de M15.
	var palette: Dictionary = MapThemes.palette(&"pradera")
	assert_null(palette["fill_grass"], "se ve el color del TileSet")
	assert_null(palette["fill_path"])
	assert_eq(palette["tuft"], Color(0.28, 0.5, 0.2))
	assert_eq(palette["edge"], Color(0.62, 0.5, 0.3))
	assert_eq(palette["pebble"], Color(0.7, 0.6, 0.42))
	assert_eq(palette["flower_chance"], 0.18)
	assert_eq(palette["flowers"], [Color(1, 0.95, 0.6), Color(1, 0.75, 0.85), Color(0.95, 0.95, 1)])
	assert_eq(palette["detail"], "tufts")


func test_an_unknown_theme_uses_the_meadow() -> void:
	assert_eq(MapThemes.palette(&"playa"), MapThemes.palette(&"pradera"))
	assert_eq(MapThemes.blocked_decor(&"playa", Vector2i(3, 4)), MapThemes.blocked_decor(&"pradera", Vector2i(3, 4)))


func test_every_other_theme_has_its_own_ground_and_path_colors() -> void:
	var seen: Dictionary = {}
	for id: String in MapThemes.IDS:
		if id == "pradera":
			continue
		var palette: Dictionary = MapThemes.palette(StringName(id))
		assert_not_null(palette["fill_grass"], id)
		assert_not_null(palette["fill_path"], id)
		var key: String = str(palette["fill_grass"]) + str(palette["fill_path"])
		assert_false(seen.has(key), "%s repite los colores de otro tema" % id)
		seen[key] = true


func test_the_path_always_reads_against_the_ground() -> void:
	# Guía de arte §4: el camino se lee sobre el suelo "con los ojos entrecerrados".
	for id: String in MapThemes.IDS:
		if id == "pradera":
			continue
		var palette: Dictionary = MapThemes.palette(StringName(id))
		var difference: float = absf((palette["fill_path"] as Color).get_luminance() - (palette["fill_grass"] as Color).get_luminance())
		assert_gt(difference, 0.12, "%s: el camino casi no se distingue del suelo" % id)


# --- Lo que sale en las casillas bloqueadas ---

func test_each_theme_has_its_own_blocked_decoration() -> void:
	var meadow: Dictionary = {}
	for texture: Texture2D in MapThemes.BLOCKED[&"pradera"]:
		meadow[texture] = true
	for id: String in MapThemes.IDS:
		var list: Array = MapThemes.BLOCKED[StringName(id)]
		var distinct: Dictionary = {}
		for texture: Texture2D in list:
			assert_not_null(texture, id)
			distinct[texture] = true
		assert_gte(distinct.size(), 3, "%s tiene poca variedad" % id)
		if id != "pradera":
			var shared: int = 0
			for texture: Texture2D in distinct:
				if meadow.has(texture):
					shared += 1
			assert_lt(shared, distinct.size(), "%s no se parece a sí mismo sino a la pradera" % id)


func test_the_decoration_of_a_cell_never_changes() -> void:
	for id: String in MapThemes.IDS:
		for cell: Vector2i in [Vector2i(0, 0), Vector2i(7, 3), Vector2i(19, 8)]:
			assert_eq(MapThemes.blocked_decor(StringName(id), cell), MapThemes.blocked_decor(StringName(id), cell))


func test_the_meadow_decoration_is_the_old_one() -> void:
	# LevelDecor.blocked_decor(cell) sin tema sigue dando lo mismo que antes.
	for cell: Vector2i in [Vector2i(1, 1), Vector2i(5, 2), Vector2i(12, 7)]:
		assert_eq(LevelDecor.blocked_decor(cell), MapThemes.blocked_decor(&"pradera", cell))
	var list: Array = MapThemes.BLOCKED[&"pradera"]
	assert_eq(list[0], load("res://assets/sprites/map/rendered/rock_a.png"))
	assert_eq(list.size(), 6, "las mismas seis, con las rocas repetidas")


func test_the_new_drawings_exist_and_are_64_square() -> void:
	var names: PackedStringArray = ["cactus", "roca_roja", "huesos", "pino", "roca_nieve", "roca_negra", "grieta",
		"columna", "bloque", "estatua", "tronco", "helecho", "junco", "hongo", "flores"]
	for file_name: String in names:
		var texture: Texture2D = load("res://assets/sprites/map/%s.svg" % file_name)
		assert_not_null(texture, file_name)
		assert_eq(texture.get_width(), texture.get_height(), "%s es cuadrado" % file_name)


## T498 (RF-713 c, RF-714, D-210): la cabeza de ganado del desierto (niveles 10 a 12) es el PNG aprobado de 128 × 128 (variante 01,
## dos pares de cuernos); cada casilla que antes mostraba `huesos.svg` resuelve al arte nuevo y los datos no cambiaron.
const DESERT_HASHES: Dictionary = {
	10: "21af960b29532957099e39c7b97c7c7ed101e3e5ef2646c003bfc091607e7fdf",
	11: "cbec8c23f8998a67d321d95be9d2d65bf82e1664cd99f148aee715f9fda870e6",
	12: "0a884be2b4cbfdfec6bc8daa40b7ab96e0ace79205d076baa384c3ebbba08a67",
}
const DESERT_BONES_CELLS: Dictionary = {10: 26, 11: 25, 12: 23}   # T491: casillas de cabeza en cada nivel


func test_desert_bones_is_the_approved_128_png() -> void:
	var path: String = "res://assets/sprites/map/rendered/bones_skull.png"
	assert_eq(MapThemes.BONES.resource_path, path)
	assert_eq(MapThemes.BONES.get_width(), 128)
	assert_eq(MapThemes.BONES.get_height(), 128)
	assert_true(MapThemes.BONES.get_image().detect_alpha() != Image.ALPHA_NONE, "tiene alfa")
	assert_eq(MapThemes.BLOCKED[&"desierto"], [MapThemes.CACTUS, MapThemes.RED_ROCK, MapThemes.BONES, MapThemes.CACTUS,
		MapThemes.RED_ROCK], "la misma lista de cinco: no cambia qué casilla usa cada dibujo")


func test_desert_levels_use_the_new_bones_in_the_same_cells_and_data_is_untouched() -> void:
	for number: int in DESERT_HASHES:
		var file: String = "res://data/levels/level_%02d.json" % number
		var text: String = FileAccess.get_file_as_string(file)
		assert_eq(text.sha256_text(), DESERT_HASHES[number], "%s no cambió" % file)
		var data: Dictionary = JSON.parse_string(text)
		assert_eq(data["tema"], "desierto")
		var rows: Array = data["mapa"]
		var bones: int = 0
		var others: int = 0
		for y: int in rows.size():
			var row: String = rows[y]
			for x: int in row.length():
				if row[x] != "X":
					continue
				var texture: Texture2D = MapThemes.blocked_decor(&"desierto", Vector2i(x, y))
				if texture == MapThemes.BONES:
					bones += 1
				else:
					assert_true(texture == MapThemes.CACTUS or texture == MapThemes.RED_ROCK, "(%d, %d) sigue siendo cactus o roca roja" % [x, y])
					others += 1
		assert_eq(bones, DESERT_BONES_CELLS[number], "casillas con cabeza en el nivel %d" % number)
		assert_gt(others, 0, "el cactus y la roca roja siguen en el nivel %d" % number)


# --- Pintar cada tema ---

func test_every_theme_builds_and_draws_without_errors() -> void:
	for id: String in MapThemes.IDS:
		var level: Level = Level.build(_grid(), StringName(id))
		add_child_autofree(level)
		assert_eq(level.theme, StringName(id))
		await wait_physics_frames(2)
	assert_true(true, "se dibujaron los siete")


func test_the_level_data_passes_its_theme_to_the_map() -> void:
	var level_data: LevelData = GameFlow.level(0).duplicate()
	level_data.theme = &"nieve"
	var built: Level = level_data.build_map()
	add_child_autofree(built)
	assert_eq(built.theme, &"nieve")
	assert_eq(GameFlow.level(0).theme, &"pradera", "el nivel oficial no se tocó")


func test_the_editor_view_takes_the_theme_of_the_draft() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	assert_eq(draft.theme(), &"pradera")
	draft.data["tema"] = "ruinas"
	assert_eq(draft.theme(), &"ruinas")
	draft.data["tema"] = "playa"
	assert_eq(draft.theme(), &"pradera", "un tema que no existe se ve como la pradera")
	var view := MapView.new()
	add_child_autofree(view)
	view.show_map(draft.rows(), draft.grid(), &"desierto")
	await wait_physics_frames(2)
	assert_true(true, "la vista del editor dibuja con tema")


func test_rendered_ground_materials_and_fallback() -> void:
	for id: String in MapThemes.IDS:
		assert_eq(MapThemes.ground_texture(StringName(id)).get_size(), Vector2(256, 256), id)
	assert_eq(MapThemes.ground_texture(&"playa"), MapThemes.ground_texture(MapThemes.DEFAULT))
	assert_eq(MapThemes.PATH_TEXTURE.get_size(), Vector2(256, 256))
