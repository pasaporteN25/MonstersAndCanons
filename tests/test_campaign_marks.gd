# T507 (RF-717, RF-719): el sistema de marcas por datos. Es una capa visual como los postes de T475: los quince mapas
# jugables no cambian y la marca no tiene efecto de juego ni de guardado. Hoy solo hay las 28 señales grabadas de M80;
# estela y pintada están definidas pero sin ninguna ubicación. No toca el guardado real: usa `user://test_campaign_marks.json`.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_campaign_marks.json"
const BAD_PATH: String = "user://test_campaign_marks_bad.json"

## Las 28 señales de la tabla de M80 (spec §M80; Lucas, T506, 2026-10-26), casillas `(x, y)` por nivel.
const SIGNALS: Dictionary = {
	"level_07": [Vector2i(1, 3)],
	"level_08": [Vector2i(12, 0), Vector2i(0, 4)],
	"level_09": [Vector2i(6, 0), Vector2i(0, 4)],
	"level_10": [Vector2i(1, 4), Vector2i(1, 6), Vector2i(20, 8)],
	"level_11": [Vector2i(1, 2), Vector2i(21, 2), Vector2i(2, 8)],
	"level_12": [Vector2i(4, 0), Vector2i(0, 3), Vector2i(1, 6)],
	"level_13": [Vector2i(7, 1), Vector2i(11, 4), Vector2i(20, 5), Vector2i(8, 7)],
	"level_14": [Vector2i(8, 1), Vector2i(24, 1), Vector2i(18, 2), Vector2i(3, 5), Vector2i(14, 5), Vector2i(7, 7), Vector2i(13, 8), Vector2i(25, 9)],
	"level_15": [Vector2i(2, 4), Vector2i(19, 10)],
}

## SHA-256 de cada data/levels/level_NN.json (los mismos que fija test_campaign_posts.gd; idénticos a `origin/main`).
const LEVEL_HASH: Dictionary = {
	"level_01": "a69feaf78d87b41f020177f1292482f8b03d6ff2decbd2b7928102de71d52d64",
	"level_02": "989d596338c37c3d62482ba7aadd863b72a2bf79a5bd6449838d31683acd01b8",
	"level_03": "c4fff3a35e2a1278bcc5792330cd887c7e5b6da5a36bf7e9fe7a0cba09b9d6a8",
	"level_04": "a2a1f6e6f65c10ec3ba87264c17dccecdab15a0e2a9ad0340c6948e65a892d56",
	"level_05": "abef553788fe90aea726f370047e6bb7743e14cf55b1bed93b80e6c027d26cef",
	"level_06": "091dc4aa81958fd7ccee54b24857d8a75885da1a49f73171d106635f8f6c0a01",
	"level_07": "d250d69eba3a1b47638892f291aa70c76a5332219c17f770f56fda01e763699a",
	"level_08": "e0f1c38361a8af20325025bd6cc0fb63915e96ff93acdacecf27a9c56d358b05",
	"level_09": "38019324f39caa34db22048031d06100c0505df16cd074b89c151a3741c1ad9a",
	"level_10": "21af960b29532957099e39c7b97c7c7ed101e3e5ef2646c003bfc091607e7fdf",
	"level_11": "cbec8c23f8998a67d321d95be9d2d65bf82e1664cd99f148aee715f9fda870e6",
	"level_12": "0a884be2b4cbfdfec6bc8daa40b7ab96e0ace79205d076baa384c3ebbba08a67",
	"level_13": "0577701868f5455858abd257393a3eb33cb740ce9754455510170986926cf3a1",
	"level_14": "150929389daa85941b826cbca70aaa9f25b73f97b95ea38149afa2e057112a20",
	"level_15": "79aa035ddc396bcb4e9e2549af031256ba1a5ff7542945ec8ac3c0de41e1f6a2",
}

var _game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.test_level = null


func after_each() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.test_level = null
	DevMode.enabled = false
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	if FileAccess.file_exists(BAD_PATH):
		DirAccess.remove_absolute(BAD_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _json(level_id: String) -> Dictionary:
	var file := FileAccess.open("res://data/levels/%s.json" % level_id, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return data


func _write_bad(text: String) -> void:
	var file := FileAccess.open(BAD_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _play(level_index: int) -> Game:
	GameFlow.current_index = level_index
	_game = GAME_SCENE.instantiate()
	add_child_autofree(_game)
	return _game


# --- Datos ---

func test_the_data_has_exactly_the_28_engraved_signals_of_the_m80_table() -> void:
	assert_eq(CampaignMarks.total_count(), 28)
	assert_eq(CampaignMarks.total_count(CampaignMarks.PATH, CampaignMarks.GRABADA), 28, "todas son grabadas")
	assert_eq(CampaignMarks.level_ids().size(), 9, "9 niveles: del 7 al 15")
	for id: String in SIGNALS:
		var marks: Dictionary = CampaignMarks.marks_for(StringName(id))
		assert_eq(marks.size(), SIGNALS[id].size(), id)
		for cell: Vector2i in SIGNALS[id]:
			assert_eq(marks.get(cell), CampaignMarks.GRABADA, "%s %s" % [id, cell])


func test_steles_and_painted_marks_are_defined_but_have_no_location() -> void:
	assert_eq(CampaignMarks.type_ids(), [&"grabada", &"estela", &"pintada"] as Array[StringName])
	assert_eq(CampaignMarks.total_count(CampaignMarks.PATH, CampaignMarks.ESTELA), 0, "sin ubicación aprobada")
	assert_eq(CampaignMarks.total_count(CampaignMarks.PATH, CampaignMarks.PINTADA), 0, "sin ubicación aprobada")
	assert_eq(CampaignMarks.support_of(CampaignMarks.GRABADA), CampaignMarks.Support.SIGNAL)
	assert_eq(CampaignMarks.support_of(CampaignMarks.ESTELA), CampaignMarks.Support.FREE)
	assert_eq(CampaignMarks.support_of(CampaignMarks.PINTADA), CampaignMarks.Support.FREE)
	assert_not_null(CampaignMarks.texture_of(CampaignMarks.GRABADA))
	assert_null(CampaignMarks.texture_of(CampaignMarks.ESTELA), "todavía sin arte aprobado")
	assert_null(CampaignMarks.texture_of(CampaignMarks.PINTADA), "todavía sin arte aprobado")


func test_the_engraved_art_is_a_square_rgba_image() -> void:
	var texture: Texture2D = CampaignMarks.texture_of(CampaignMarks.GRABADA)
	assert_eq(texture.get_width(), texture.get_height(), "cuadrada, la huella de una casilla")
	assert_eq(texture.get_width(), 128)


func test_a_level_without_marks_or_a_broken_file_gives_none() -> void:
	assert_true(CampaignMarks.marks_for(&"level_01").is_empty(), "los niveles 1 a 6 no llevan marcas")
	assert_true(CampaignMarks.marks_for(&"level_99").is_empty())
	assert_true(CampaignMarks.marks_for(&"level_07", "user://no_such_marks.json").is_empty(), "archivo ausente = sin marcas")
	assert_eq(CampaignMarks.total_count("user://no_such_marks.json"), 0)
	_write_bad("{ no es json")
	assert_true(CampaignMarks.marks_for(&"level_07", BAD_PATH).is_empty(), "archivo dañado = sin marcas")
	_write_bad("[1, 2, 3]")
	assert_true(CampaignMarks.marks_for(&"level_07", BAD_PATH).is_empty(), "raíz que no es un objeto")
	_write_bad('{"niveles": [1, 2]}')
	assert_true(CampaignMarks.marks_for(&"level_07", BAD_PATH).is_empty(), "niveles que no es un objeto")
	_write_bad('{"niveles": {"level_07": "x"}}')
	assert_true(CampaignMarks.marks_for(&"level_07", BAD_PATH).is_empty(), "las marcas de un nivel que no son una lista")


func test_malformed_unknown_and_repeated_entries_are_ignored() -> void:
	_write_bad('{"niveles": {"level_07": [{"casilla": [1]}, "x", {"tipo": "grabada"}, {"casilla": [1, 2]}, {"casilla": [1.5, 2], "tipo": "grabada"}, {"casilla": ["1", 2], "tipo": "grabada"}, {"casilla": [3, 3], "tipo": "inventada"}, {"casilla": [4, 4], "tipo": 7}, {"casilla": [2, 3], "tipo": "estela"}, {"casilla": [2, 3], "tipo": "grabada"}, {"casilla": [5.0, 6.0], "tipo": "pintada"}]}}')
	var marks: Dictionary = CampaignMarks.marks_for(&"level_07", BAD_PATH)
	assert_eq(marks.size(), 2, "solo las dos entradas buenas")
	assert_eq(marks[Vector2i(2, 3)], CampaignMarks.ESTELA, "la casilla repetida conserva la primera")
	assert_eq(marks[Vector2i(5, 6)], CampaignMarks.PINTADA, "un entero que llega como float vale")


# --- Invariancia y validación dura sobre los quince niveles ---

func test_the_level_files_and_the_posts_file_are_the_same_as_origin_main() -> void:
	for id: String in LEVEL_HASH:
		assert_eq(FileAccess.get_sha256("res://data/levels/%s.json" % id), LEVEL_HASH[id], "%s cambió" % id)
	assert_eq(FileAccess.get_sha256("res://data/ui/postes_campana.json"), "f0059799cd1c2c11d323cdf36d934a8a952c3d60eaec9add3cb6dba062b4d062", "postes_campana.json cambió")


func test_no_mark_sits_on_a_forbidden_cell_in_any_of_the_fifteen_levels() -> void:
	for index: int in GameFlow.level_count():
		var data: LevelData = GameFlow.level(index)
		var id: String = String(data.id)
		var level: Dictionary = _json(id)
		var rows: Array = level["mapa"]
		var legend: Dictionary = level.get("leyenda", {})
		var marks: Dictionary = CampaignMarks.marks_for(data.id)
		var posts: Array[Vector2i] = CampaignPosts.cells_for(data.id)
		for cell: Vector2i in marks:
			var where: String = "%s %s" % [id, cell]
			assert_true(cell.y >= 0 and cell.y < rows.size() and cell.x >= 0 and cell.x < String(rows[cell.y]).length(), "%s dentro del mapa" % where)
			assert_false(posts.has(cell), "%s: no coincide con un poste" % where)
			var letter: String = String(rows[cell.y])[cell.x]
			assert_false(letter in ".#S" or letter in MapGrid.ENTRANCE_LETTERS, "%s: ni camino, entrada, salida ni casilla construible" % where)
			if CampaignMarks.support_of(marks[cell]) == CampaignMarks.Support.FREE:
				assert_eq(letter, "X", "%s: una estela o pintada solo va en una X libre" % where)
				continue
			# La grabada acompaña a una señal: una casilla de leyenda con su dibujo, y nada más.
			assert_true(legend.has(letter), "%s: letra «%s» sin leyenda" % [where, letter])
			var entry: Dictionary = legend[letter]
			assert_true(CampaignMarks.SIGNAL_DRAWINGS.has(entry.get("dibujo", "")), "%s: es una señal" % where)
			assert_false(entry.has("removible") or entry.has("extraccion") or entry.has("hallazgo") or entry.get("construible", false), "%s: ni removible, ni extracción, ni pieza, ni construible" % where)
		assert_eq(marks.size(), SIGNALS[id].size() if SIGNALS.has(id) else 0, "%s: ninguna marca fuera de la tabla de M80" % id)


func test_the_overlay_marks_every_signal_cell_and_the_decor_hides_the_item_behind() -> void:
	for id: String in SIGNALS:
		var data: LevelData = GameFlow.level(int(id.substr(6)) - 1)
		assert_eq(data.id, StringName(id))
		var level: Level = data.build_map(false, null, CampaignPosts.cells_for(data.id), CampaignMarks.marks_for(data.id))
		add_child_autofree(level)
		var decor: LevelDecor = level.get_node("Decor") as LevelDecor
		var drawn: Array[Vector2i] = decor.overlay_mark_cells()
		assert_eq(drawn.size(), SIGNALS[id].size(), "%s: se dibujan todas" % id)
		for cell: Vector2i in SIGNALS[id]:
			assert_true(drawn.has(cell), "%s %s" % [id, cell])
		for post: Vector2i in decor.overlay_post_cells():
			assert_false(drawn.has(post), "%s: poste y marca nunca en la misma casilla" % id)
	await wait_physics_frames(2)


func test_the_decor_ignores_a_mark_that_does_not_belong_to_its_cell() -> void:
	# Nivel 12: (4, 0) es una señal; (5, 2) tiene un poste; (9, 1) es una X libre; (0, 0) es camino u otra cosa.
	var data: LevelData = GameFlow.level(11)
	var free_cell: Vector2i = Vector2i(-1, -1)
	var rows: Array = data.map_rows
	for y: int in rows.size():
		for x: int in String(rows[y]).length():
			if String(rows[y])[x] == "X" and not CampaignPosts.cells_for(data.id).has(Vector2i(x, y)) and not data.legend.has("X"):
				free_cell = Vector2i(x, y)
	assert_ne(free_cell, Vector2i(-1, -1), "el nivel 12 tiene alguna X libre")
	var post: Vector2i = CampaignPosts.cells_for(data.id)[0]
	var path_cell: Vector2i = Vector2i(-1, -1)
	for y: int in rows.size():
		var x: int = String(rows[y]).find("#")
		if x >= 0:
			path_cell = Vector2i(x, y)
			break
	var marks: Dictionary = {
		Vector2i(4, 0): CampaignMarks.GRABADA,           # señal: vale
		post: CampaignMarks.GRABADA,                      # poste: no
		free_cell: CampaignMarks.GRABADA,                 # una X sin señal: la grabada no va
		path_cell: CampaignMarks.GRABADA,                 # camino: no
		Vector2i(99, 99): CampaignMarks.GRABADA,          # fuera del mapa: no
		Vector2i(0, 3): CampaignMarks.ESTELA,             # sin arte aprobado: no se dibuja
		Vector2i(1, 6): &"inventada",                     # tipo desconocido: no
	}
	var level: Level = data.build_map(false, null, CampaignPosts.cells_for(data.id), marks)
	add_child_autofree(level)
	assert_eq((level.get_node("Decor") as LevelDecor).overlay_mark_cells(), [Vector2i(4, 0)] as Array[Vector2i])
	# Una estela con arte futuro tampoco iría sobre una señal ni sobre un poste.
	assert_eq(CampaignMarks.support_of(CampaignMarks.ESTELA), CampaignMarks.Support.FREE)
	await wait_physics_frames(2)


func test_marks_change_nothing_playable_in_any_of_the_fifteen_maps() -> void:
	for index: int in GameFlow.level_count():
		var data: LevelData = GameFlow.level(index)
		var plain: Level = data.build_map()
		var with_marks: Level = data.build_map(true, BannerRecipe.make("marea", "estrella"), CampaignPosts.cells_for(data.id), CampaignMarks.marks_for(data.id))
		add_child_autofree(plain)
		add_child_autofree(with_marks)
		assert_eq(with_marks.grid.width, plain.grid.width)
		assert_eq(with_marks.grid.height, plain.grid.height)
		assert_eq(with_marks.grid.entrances, plain.grid.entrances, "%s entradas" % data.id)
		assert_eq(with_marks.grid.exit_cell, plain.grid.exit_cell, "%s salida" % data.id)
		assert_eq(with_marks.legend_cells, plain.legend_cells, "%s leyenda" % data.id)
		assert_eq(with_marks.removable_cells, plain.removable_cells, "%s removibles" % data.id)
		for y: int in plain.grid.height:
			for x: int in plain.grid.width:
				var cell := Vector2i(x, y)
				assert_eq(with_marks.grid.cell_type(cell), plain.grid.cell_type(cell), "%s %s tipo" % [data.id, cell])
				assert_eq(with_marks.ground.get_cell_atlas_coords(cell), plain.ground.get_cell_atlas_coords(cell), "%s %s suelo" % [data.id, cell])
		for i: int in plain.entrance_count():
			assert_eq(with_marks.get_ground_path(i).curve.get_baked_points(), plain.get_ground_path(i).curve.get_baked_points(), "%s camino %d" % [data.id, i])
	await wait_physics_frames(2)


func test_a_map_built_without_context_has_no_marks() -> void:
	var level: Level = GameFlow.level(6).build_map()
	add_child_autofree(level)
	assert_true(level.mark_cells.is_empty())
	assert_true((level.get_node("Decor") as LevelDecor).overlay_mark_cells().is_empty())
	await wait_physics_frames(2)


# --- Contexto: solo la campaña ---

func test_campaign_levels_get_their_marks_and_do_not_depend_on_progress() -> void:
	var game: Game = _play(11)
	assert_eq(game.level.mark_cells, CampaignMarks.marks_for(&"level_12"))
	assert_eq((game.level.get_node("Decor") as LevelDecor).overlay_mark_cells().size(), 3)
	game.queue_free()
	await wait_physics_frames(2)
	SaveManager.record_victory(&"level_12", 1)
	game = _play(11)
	assert_eq(game.level.mark_cells, CampaignMarks.marks_for(&"level_12"), "sin variante «conquistada»")
	game.queue_free()
	await wait_physics_frames(2)
	game = _play(0)
	assert_true(game.level.mark_cells.is_empty(), "el nivel 1 no lleva marcas")


func test_test_mode_keeps_the_campaign_marks() -> void:
	DevMode.enabled = true
	var game: Game = _play(6)
	assert_eq(game.level.mark_cells, CampaignMarks.marks_for(&"level_07"))


func test_a_loose_scene_and_the_editor_play_get_no_marks() -> void:
	var game: Game = _play(-1)
	assert_true(game.level.mark_cells.is_empty(), "escena suelta")
	game.queue_free()
	await wait_physics_frames(2)
	GameFlow.test_level = GameFlow.level(11)
	game = _play(-1)
	assert_true(game.level.mark_cells.is_empty(), "probar desde el editor")


func test_community_maps_get_no_marks() -> void:
	GameFlow.current_community = GameFlow.level(11)
	var game: Game = _play(-1)
	assert_true(game.level.mark_cells.is_empty())


func test_modes_such_as_siege_get_no_marks() -> void:
	var mode: Dictionary = {}
	for candidate: Dictionary in ModePacks.all():
		if candidate["id"] == &"asedio":
			mode = candidate
	assert_false(mode.is_empty(), "el modo oficial Asedio existe")
	GameFlow.current_mode = mode
	GameFlow.current_mode_index = 0
	var game: Game = _play(11)
	assert_true(game.level.mark_cells.is_empty())
