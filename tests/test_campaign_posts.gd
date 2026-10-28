# T475 (RF-696, RF-697, RF-698): los veinte postes de campaña. Son una capa visual: los quince mapas jugables no
# cambian, y la variante sale solo del contexto que arma Game (estrellas), sin que MapDrawings/LevelDecor lean el guardado.
# No toca el guardado real: usa `user://test_campaign_posts.json`.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_campaign_posts.json"

## Posiciones que Lucas aprobó el 2026-10-25 («Atlas + los 20 postes tal cual»), con los tres reemplazos del paquete.
const APPROVED: Dictionary = {
	"level_01": [Vector2i(13, 5)], "level_02": [Vector2i(1, 4)], "level_03": [Vector2i(15, 6)],
	"level_04": [Vector2i(19, 4)], "level_05": [Vector2i(17, 3)], "level_06": [Vector2i(18, 1)],
	"level_07": [Vector2i(17, 5)],
	"level_08": [Vector2i(18, 1)], "level_09": [Vector2i(18, 1)],
	"level_10": [Vector2i(22, 2)], "level_11": [Vector2i(2, 1), Vector2i(20, 8)],
	"level_12": [Vector2i(5, 2), Vector2i(24, 9)], "level_13": [Vector2i(23, 2), Vector2i(24, 9)],
	"level_14": [Vector2i(1, 1), Vector2i(24, 10)], "level_15": [Vector2i(5, 1), Vector2i(23, 10)],
}

## Niveles 8 y 9: Lucas (2026-10-28) eligió (18, 1), una casilla libre construible, porque la aprobada antes, (0, 4), es el
## símbolo de ruina canónico y el poste lo tapaba por completo. Es la única excepción a «casilla no construible».
const FREE_CELL_LEVELS: PackedStringArray = ["level_08", "level_09"]
const SIGNAL_DRAWINGS: PackedStringArray = ["roca_marcada", "simbolo_ruina", "campamento_vacio", "sendero", "herramienta"]

## SHA-256 de cada data/levels/level_NN.json «antes» de T475 (art/t475-paquete-postes/index.md, base 9ce9e18).
const BEFORE_HASH: Dictionary = {
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
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _json(level_id: String) -> Dictionary:
	var file := FileAccess.open("res://data/levels/%s.json" % level_id, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return data


func _lives_for(level_index: int, wanted_stars: int) -> int:
	var data: LevelData = GameFlow.level(level_index)
	for lives: int in range(data.starting_lives, 0, -1):
		if Rules.stars_for(lives, data.starting_lives, GameFlow.BALANCE) == wanted_stars:
			return lives
	return -1


func _play(level_index: int) -> Game:
	GameFlow.current_index = level_index
	_game = GAME_SCENE.instantiate()
	add_child_autofree(_game)
	return _game


# --- Datos ---

func test_the_data_has_the_twenty_posts_in_the_fifteen_levels() -> void:
	assert_eq(CampaignPosts.total_count(), 20, "los 20 postes aprobados")
	assert_eq(CampaignPosts.level_ids().size(), 15)
	for id: String in APPROVED:
		assert_eq(CampaignPosts.cells_for(StringName(id)), Array(APPROVED[id], TYPE_VECTOR2I, "", null), id)
		var expected: int = 2 if int(id.substr(6)) >= 11 else 1
		assert_eq(CampaignPosts.cells_for(StringName(id)).size(), expected, "%s: 1 poste en 1–10 y 2 en 11–15" % id)
	assert_eq(APPROVED.size(), 15)


func test_levels_eight_and_nine_put_the_post_on_a_free_cell_away_from_every_signal() -> void:
	for id: String in FREE_CELL_LEVELS:
		var level: Dictionary = _json(id)
		var rows: Array = level["mapa"]
		var cell := Vector2i(18, 1)
		assert_eq(CampaignPosts.cells_for(StringName(id)), [cell] as Array[Vector2i], id)
		assert_eq(String(rows[cell.y])[cell.x], ".", "%s: casilla libre sin dibujo" % id)
		assert_false(level["leyenda"].has("."), "%s: '.' no tiene entrada de leyenda" % id)
		# ni una señal, un removible ni una entrada/salida a menos de dos casillas
		for dy: int in range(-2, 3):
			for dx: int in range(-2, 3):
				var x: int = cell.x + dx
				var y: int = cell.y + dy
				if y < 0 or y >= rows.size() or x < 0 or x >= String(rows[y]).length():
					continue
				var letter: String = String(rows[y])[x]
				if letter == "." or letter == "X":
					continue
				var entry: Dictionary = level["leyenda"].get(letter, {})
				if entry.is_empty():
					continue  # camino, entrada o salida del mapa se comprueban abajo
				assert_false(SIGNAL_DRAWINGS.has(entry.get("dibujo", "")), "%s: señal %s a menos de 2 casillas" % [id, Vector2i(x, y)])
				assert_false(entry.has("removible"), "%s: removible %s a menos de 2 casillas" % [id, Vector2i(x, y)])
	for index: int in [7, 8]:
		var data: LevelData = GameFlow.level(index)
		var map: Level = data.build_map(false, null, CampaignPosts.cells_for(data.id))
		add_child_autofree(map)
		assert_eq(map.grid.cell_type(Vector2i(18, 1)), MapGrid.Cell.GRASS, "%s: el poste es visual, la casilla sigue construible" % data.id)
		assert_eq((map.get_node("Decor") as LevelDecor).overlay_post_cells(), [Vector2i(18, 1)] as Array[Vector2i])
	await wait_physics_frames(2)


func test_a_level_without_posts_or_a_broken_file_gives_none() -> void:
	assert_true(CampaignPosts.cells_for(&"level_99").is_empty())
	assert_true(CampaignPosts.cells_for(&"level_01", "user://no_such_posts.json").is_empty())
	var file := FileAccess.open("user://test_campaign_posts_bad.json", FileAccess.WRITE)
	file.store_string("{ no es json")
	file.close()
	assert_true(CampaignPosts.cells_for(&"level_01", "user://test_campaign_posts_bad.json").is_empty())
	file = FileAccess.open("user://test_campaign_posts_bad.json", FileAccess.WRITE)
	file.store_string('{"niveles": {"level_01": [[1], "x", [2, 3], [2, 3], [1.5, 2]]}}')
	file.close()
	assert_eq(CampaignPosts.cells_for(&"level_01", "user://test_campaign_posts_bad.json"), [Vector2i(2, 3)] as Array[Vector2i], "ignora lo mal formado y lo repetido")
	DirAccess.remove_absolute("user://test_campaign_posts_bad.json")


func test_only_three_stars_give_the_player_variant() -> void:
	assert_false(CampaignPosts.is_player_variant(0))
	assert_false(CampaignPosts.is_player_variant(1))
	assert_false(CampaignPosts.is_player_variant(2))
	assert_true(CampaignPosts.is_player_variant(3))


# --- Invariancia de los quince mapas ---

func test_the_level_files_are_the_same_as_before() -> void:
	for id: String in BEFORE_HASH:
		assert_eq(FileAccess.get_sha256("res://data/levels/%s.json" % id), BEFORE_HASH[id], "%s cambió" % id)


func test_every_post_sits_on_a_permanently_unbuildable_free_cell() -> void:
	for id: String in APPROVED:
		if FREE_CELL_LEVELS.has(id):
			continue  # 8 y 9: casilla libre elegida por Lucas el 2026-10-28, ver el test siguiente
		var level: Dictionary = _json(id)
		var rows: Array = level["mapa"]
		var legend: Dictionary = level.get("leyenda", {})
		for cell: Vector2i in APPROVED[id]:
			assert_true(cell.y < rows.size() and cell.x < String(rows[cell.y]).length(), "%s %s dentro del mapa" % [id, cell])
			var letter: String = String(rows[cell.y])[cell.x]
			if letter == "X":
				continue
			assert_true(legend.has(letter), "%s %s: letra «%s» sin leyenda" % [id, cell, letter])
			var entry: Dictionary = legend[letter]
			assert_true(entry.has("dibujo"), "%s %s: es un dibujo" % [id, cell])
			assert_false(entry.has("removible") or entry.has("extraccion") or entry.get("construible", false), "%s %s: no es removible, extracción ni construible" % [id, cell])
			assert_true(["columna", "flores", "poste_cintas"].has(entry["dibujo"]), "%s %s: dibujo previsto" % [id, cell])
			assert_false(SIGNAL_DRAWINGS.has(entry["dibujo"]), "%s %s: no tapa una señal canónica" % [id, cell])


func test_the_posts_change_nothing_playable_in_any_of_the_fifteen_maps() -> void:
	for index: int in GameFlow.level_count():
		var data: LevelData = GameFlow.level(index)
		var cells: Array[Vector2i] = CampaignPosts.cells_for(data.id)
		assert_false(cells.is_empty(), "%s: tiene poste" % data.id)
		var plain: Level = data.build_map()
		var with_posts: Level = data.build_map(true, BannerRecipe.make("marea", "estrella"), cells)
		add_child_autofree(plain)
		add_child_autofree(with_posts)
		assert_eq(with_posts.grid.width, plain.grid.width)
		assert_eq(with_posts.grid.height, plain.grid.height)
		assert_eq(with_posts.grid.entrances, plain.grid.entrances, "%s entradas" % data.id)
		assert_eq(with_posts.grid.exit_cell, plain.grid.exit_cell, "%s salida" % data.id)
		assert_eq(with_posts.legend_cells, plain.legend_cells, "%s leyenda" % data.id)
		assert_eq(with_posts.removable_cells, plain.removable_cells, "%s removibles" % data.id)
		for y: int in plain.grid.height:
			for x: int in plain.grid.width:
				var cell := Vector2i(x, y)
				assert_eq(with_posts.grid.cell_type(cell), plain.grid.cell_type(cell), "%s %s tipo" % [data.id, cell])
				assert_eq(with_posts.ground.get_cell_atlas_coords(cell), plain.ground.get_cell_atlas_coords(cell), "%s %s suelo" % [data.id, cell])
		for i: int in plain.entrance_count():
			assert_eq(with_posts.get_ground_path(i).curve.get_baked_points(), plain.get_ground_path(i).curve.get_baked_points(), "%s camino %d" % [data.id, i])
		assert_eq(data.map_rows, GameFlow.level(index).map_rows)
	await wait_physics_frames(2)


# --- Capa visual y contexto ---

func test_the_overlay_does_not_repeat_the_post_that_the_legend_already_draws() -> void:
	var data: LevelData = GameFlow.level(5)
	assert_eq(data.id, &"level_06")
	var level: Level = data.build_map(false, null, CampaignPosts.cells_for(data.id))
	add_child_autofree(level)
	var decor: LevelDecor = level.get_node("Decor") as LevelDecor
	assert_eq(level.legend_cells.get(Vector2i(18, 1)), "poste_cintas")
	assert_true(decor.overlay_post_cells().is_empty(), "el del 6 ya es el de la leyenda")
	var other: Level = GameFlow.level(0).build_map(false, null, CampaignPosts.cells_for(&"level_01"))
	add_child_autofree(other)
	assert_eq((other.get_node("Decor") as LevelDecor).overlay_post_cells(), [Vector2i(13, 5)] as Array[Vector2i])
	await wait_physics_frames(2)


func test_decor_variant_depends_only_on_the_context_it_receives() -> void:
	var rebel: Level = GameFlow.level(0).build_map(false, null, CampaignPosts.cells_for(&"level_01"))
	var player: Level = GameFlow.level(0).build_map(true, BannerRecipe.make("brasa", "estrella"), CampaignPosts.cells_for(&"level_01"))
	add_child_autofree(rebel)
	add_child_autofree(player)
	assert_eq((rebel.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.POST_ENEMY)
	assert_eq((player.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.post_texture(true, BannerRecipe.make("brasa", "estrella")))
	await wait_physics_frames(2)


func test_a_map_built_without_context_has_no_posts() -> void:
	var level: Level = GameFlow.level(0).build_map()
	add_child_autofree(level)
	assert_true(level.post_cells.is_empty())
	assert_true((level.get_node("Decor") as LevelDecor).overlay_post_cells().is_empty())
	await wait_physics_frames(2)


# --- Game: campaña normal ---

func test_campaign_posts_are_rebel_without_win_and_with_one_or_two_stars() -> void:
	for stars: int in [0, 1, 2]:
		SaveManager.save_path = TEST_PATH
		SaveManager.load_save()
		if stars > 0:
			SaveManager.record_victory(&"level_03", _lives_for(2, stars))
		var game: Game = _play(2)
		assert_eq(GameFlow.level_stars(2), stars)
		assert_false(game.level.post_conquered, "%d estrellas: rebelde" % stars)
		assert_eq(game.level.post_cells, [Vector2i(15, 6)] as Array[Vector2i])
		assert_eq((game.level.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.POST_ENEMY)
		game.queue_free()
		await wait_physics_frames(2)


func test_three_stars_give_the_player_post_with_the_recipe() -> void:
	SaveManager.record_victory(&"level_03", _lives_for(2, 3))
	var game: Game = _play(2)
	assert_true(game.level.post_conquered)
	var decor: LevelDecor = game.level.get_node("Decor") as LevelDecor
	assert_eq(decor.campaign_post_texture(), MapDrawings.post_texture(true, BannerRecipeStore.load_recipe()))
	assert_ne(decor.campaign_post_texture(), MapDrawings.POST_ENEMY)


func test_level_six_post_no_longer_changes_with_any_victory() -> void:
	SaveManager.record_victory(&"level_06", _lives_for(5, 1))
	var game: Game = _play(5)
	assert_true(SaveManager.is_completed(&"level_06"))
	assert_false(game.level.post_conquered, "una victoria con 1 estrella ya no cambia el poste del 6")
	game.queue_free()
	await wait_physics_frames(2)
	SaveManager.record_victory(&"level_06", _lives_for(5, 3))
	game = _play(5)
	assert_true(game.level.post_conquered)


func test_the_stars_of_another_level_do_not_leak() -> void:
	SaveManager.record_victory(&"level_01", _lives_for(0, 3))
	var game: Game = _play(1)
	assert_false(game.level.post_conquered)


# --- Aislamiento de contextos ---

func test_test_mode_shows_rebel_posts_and_ignores_normal_progress() -> void:
	SaveManager.record_victory(&"level_03", _lives_for(2, 3))
	SaveManager.save()
	DevMode.enabled = true
	var game: Game = _play(2)
	assert_false(game.level.post_conquered, "el modo de pruebas no toma la conquista")
	assert_eq((game.level.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.POST_ENEMY)


func test_a_loose_scene_and_the_editor_play_get_no_campaign_posts() -> void:
	SaveManager.record_victory(&"level_01", _lives_for(0, 3))
	var game: Game = _play(-1)
	assert_true(game.level.post_cells.is_empty(), "escena suelta")
	assert_false(game.level.post_conquered)
	game.queue_free()
	await wait_physics_frames(2)
	GameFlow.test_level = GameFlow.level(0)
	game = _play(-1)
	assert_true(game.level.post_cells.is_empty(), "probar desde el editor")
	assert_false(game.level.post_conquered)


func test_community_maps_keep_the_fixed_rebel_post() -> void:
	SaveManager.record_victory(&"level_01", _lives_for(0, 3))
	var community: LevelData = GameFlow.level(0)
	GameFlow.current_community = community
	var game: Game = _play(-1)
	assert_true(game.level.post_cells.is_empty())
	assert_false(game.level.post_conquered)


func test_modes_such_as_siege_keep_the_fixed_rebel_post() -> void:
	SaveManager.record_victory(&"level_01", _lives_for(0, 3))
	var mode: Dictionary = {}
	for candidate: Dictionary in ModePacks.all():
		if candidate["id"] == &"asedio":
			mode = candidate
	assert_false(mode.is_empty(), "el modo oficial Asedio existe")
	GameFlow.current_mode = mode
	GameFlow.current_mode_index = 0
	var game: Game = _play(-1)
	assert_not_null(ModePacks.map_level(mode, 0))
	assert_true(game.level.post_cells.is_empty())
	assert_false(game.level.post_conquered)
