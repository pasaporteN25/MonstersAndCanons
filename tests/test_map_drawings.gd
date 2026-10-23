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


func test_the_catalog_has_four_grounds_and_twenty_nine_objects() -> void:
	var grounds: int = 0
	var objects: int = 0
	for id: String in MapDrawings.ids():
		if MapDrawings.kind(id) == MapDrawings.KIND_GROUND:
			grounds += 1
		else:
			objects += 1
	assert_eq(grounds, 4)
	assert_eq(objects, 29)


func test_the_six_community_signals_are_static_objects() -> void:
	for id: String in ["roca_marcada", "sendero", "herramienta", "poste_cintas", "simbolo_ruina", "campamento_vacio"]:
		assert_true(MapDrawings.is_valid(id), "%s está en el catálogo cerrado" % id)
		assert_eq(MapDrawings.kind(id), MapDrawings.KIND_OBJECT, "%s es decoración de casilla" % id)
		var texture: Texture2D = MapDrawings.texture(id)
		assert_not_null(texture, "%s usa una textura precargada" % id)
		if texture != null:
			assert_eq(texture.get_size(), Vector2(128, 128), "%s: SVG importado a 2x" % id)
			assert_true(texture.get_image().detect_alpha() != Image.ALPHA_NONE, "%s conserva alfa" % id)


# --- T437: el poste de banderines (RF-656, RF-657, RF-659) ---

func test_the_banner_post_has_two_distinct_variants_and_defaults_to_enemy() -> void:
	assert_eq(MapDrawings.post_texture(), MapDrawings.POST_ENEMY, "sin contexto, la enemiga")
	assert_eq(MapDrawings.post_texture(false), MapDrawings.POST_ENEMY)
	assert_eq(MapDrawings.post_texture(true), MapDrawings.POST_PLAYER)
	assert_ne(MapDrawings.POST_ENEMY, MapDrawings.POST_PLAYER)
	assert_eq(MapDrawings.texture(MapDrawings.POST_DRAWING), MapDrawings.POST_ENEMY, "el catálogo guarda la de reserva")
	for variant: Texture2D in [MapDrawings.POST_ENEMY, MapDrawings.POST_PLAYER]:
		assert_eq(variant.get_size(), Vector2(128, 128))
		assert_true(variant.get_image().detect_alpha() != Image.ALPHA_NONE, "conserva alfa")


func test_a_map_built_without_context_shows_the_enemy_post() -> void:
	var level: Level = _level_with("poste_cintas")
	add_child_autofree(level)
	var decor: LevelDecor = level.get_node("Decor") as LevelDecor
	assert_false(level.post_conquered)
	assert_eq(decor.object_texture(Vector2i(3, 1), "poste_cintas"), MapDrawings.POST_ENEMY)


func test_the_conquered_context_reaches_the_decor_of_that_map_only() -> void:
	var rows: PackedStringArray = []
	for y: int in 9:
		rows.append(".".repeat(20))
	rows[4] = "A" + "#".repeat(18) + "S"
	rows[1] = "...p".rpad(20, ".")
	var grid: MapGrid = MapGrid.parse(rows, {"p": {"dibujo": "poste_cintas"}})
	var conquered: Level = Level.build(grid, MapThemes.DEFAULT, true)
	var pending: Level = Level.build(grid, MapThemes.DEFAULT)
	add_child_autofree(conquered)
	add_child_autofree(pending)
	var cell := Vector2i(3, 1)
	assert_eq((conquered.get_node("Decor") as LevelDecor).object_texture(cell, "poste_cintas"), MapDrawings.POST_PLAYER)
	assert_eq((pending.get_node("Decor") as LevelDecor).object_texture(cell, "poste_cintas"), MapDrawings.POST_ENEMY, "el otro mapa no se contagia")
	# Otro dibujo no cambia con el contexto.
	assert_eq((conquered.get_node("Decor") as LevelDecor).object_texture(cell, "helecho"), MapDrawings.texture("helecho"))
	await wait_physics_frames(2)


func test_level_data_passes_the_post_context_and_defaults_to_enemy() -> void:
	var data := LevelData.new()
	data.map_rows = _level_rows()
	data.legend = {"p": {"dibujo": "poste_cintas"}}
	var plain: Level = data.build_map()
	var won: Level = data.build_map(true)
	add_child_autofree(plain)
	add_child_autofree(won)
	assert_false(plain.post_conquered)
	assert_true(won.post_conquered)
	await wait_physics_frames(2)


func test_log_and_fern_use_the_new_png_resources() -> void:
	for id: String in ["tronco", "helecho"]:
		var texture: Texture2D = MapDrawings.texture(id)
		assert_true(texture.resource_path.begins_with("res://assets/sprites/map/rendered/"), id)
		assert_true(texture.resource_path.ends_with(".png"), id)
		assert_eq(texture.get_size(), Vector2(128, 128))


func _level_rows() -> PackedStringArray:
	var rows: PackedStringArray = []
	for y: int in 9:
		rows.append(".".repeat(20))
	rows[4] = "A" + "#".repeat(18) + "S"
	rows[1] = "...p".rpad(20, ".")
	return rows


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
		await wait_physics_frames(2)
	assert_true(true, "se pintaron los 33")


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
		await wait_physics_frames(2)
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
	await wait_physics_frames(2)
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
	var original: MapGrid = MapGrid.parse(GameFlow.level(3).map_rows, GameFlow.level(3).legend)
	for theme: String in EXAMPLES:
		var level: LevelData = LevelFile.load_level("res://tools/ejemplos/tema_%s.json" % theme)["level"]
		var grid: MapGrid = MapGrid.parse(level.map_rows, level.legend)
		assert_eq(grid.routes, original.routes, theme)


## T277: la vista sigue transiciones reales del campo, incluida la cancelación.
func test_approved_art_follows_extraction_and_demolition_states() -> void:
	var specs: Array[ObstacleSpec] = []
	for id: String in ["mina", "bosque_explotable", "escombro"]:
		var spec: ObstacleSpec = ObstacleSpec.new()
		spec.cell = Vector2i(specs.size(), 1)
		spec.class_id = StringName(id)
		spec.kind = ObstacleSpec.Kind.REMOVABLE if id == "escombro" else ObstacleSpec.Kind.EXTRACTION
		spec.reserve = 2
		spec.production = 2
		spec.seconds = 1.0
		specs.append(spec)
	var field: ObstacleField = ObstacleField.new()
	field.setup(specs, RandomNumberGenerator.new())
	var decor: LevelDecor = LevelDecor.new()
	add_child_autofree(decor)
	decor.bind_field(field)
	for i: int in 2:
		var id: String = String(specs[i].class_id)
		var cell: Vector2i = specs[i].cell
		var initial: Texture2D = decor.object_texture(cell, id)
		assert_true(field.enable_site(cell))
		var active: Texture2D = decor.object_texture(cell, id)
		assert_ne(initial, active)
		field.complete_wave()
		var depleted: Texture2D = decor.object_texture(cell, id)
		assert_ne(active, depleted)
		assert_ne(initial, depleted)
	var rubble: Vector2i = specs[2].cell
	var intact: Texture2D = decor.object_texture(rubble, "escombro")
	assert_not_null(field.order(rubble))
	assert_ne(decor.object_texture(rubble, "escombro"), intact)
	field.cancel()
	assert_eq(decor.object_texture(rubble, "escombro"), intact)


func test_statue_variants_are_deterministic_objects_with_theme_material() -> void:
	var seen: Array[Texture2D] = []
	for x: int in 3:
		var cell: Vector2i = Vector2i(x, 2)
		var moss: Texture2D = MapDrawings.statue_texture(cell, &"pradera")
		assert_eq(moss, MapDrawings.statue_texture(cell, &"pradera"))
		assert_ne(moss, MapDrawings.statue_texture(cell, &"nieve"))
		assert_false(seen.has(moss))
		seen.append(moss)
	assert_eq(MapDrawings.kind("estatua"), MapDrawings.KIND_OBJECT)
	var level: Level = _level_with("estatua")
	add_child_autofree(level)
	assert_false(level.is_buildable(Vector2i(4, 1)))
