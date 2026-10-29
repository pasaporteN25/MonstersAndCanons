# T474 (RF-695, RF-697, RF-698): cierre de la auditoría de números sin cero inicial en las pantallas y de la receta
# estética del editor en los postes. No toca el guardado real ni `user://banner.json`: usa archivos `user://test_*.json`.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const RECORDS_SCENE: PackedScene = preload("res://scenes/ui/records_screen.tscn")
const WIKI_SCENE: PackedScene = preload("res://scenes/ui/wiki_screen.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ui/end_screen.tscn")
const TEST_SAVE: String = "user://test_number_audit.json"
const TEST_RECIPE: String = "user://test_number_audit_banner.json"


func before_each() -> void:
	_remove(TEST_SAVE)
	_remove(TEST_RECIPE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	BannerRecipeStore.current_path = TEST_RECIPE
	GameFlow.current_index = -1


func after_each() -> void:
	GameFlow.current_index = -1
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.current_community = null
	DevMode.enabled = false
	BannerRecipeStore.current_path = BannerRecipeStore.DEFAULT_PATH
	_remove(TEST_SAVE)
	_remove(TEST_RECIPE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


# --- El detector ---

func test_detector_flags_only_a_leading_zero() -> void:
	assert_eq(LeadingZeroAudit.in_text("Nivel 05"), PackedStringArray(["05"]))
	assert_eq(LeadingZeroAudit.in_text("01 · Pradera y 09"), PackedStringArray(["01", "09"]))
	assert_true(LeadingZeroAudit.in_text("Nivel 5 · Nivel 10 · Nivel 15").is_empty(), "10 y 15 no llevan cero inicial")
	assert_true(LeadingZeroAudit.in_text("+0,5 daño · 0.60/s · 0 oro · 1:05").is_empty(), "decimales, cero solo y horas")
	assert_true(LeadingZeroAudit.in_text("level_01 y level_15").is_empty(), "el id conserva su cero y no es un texto")
	assert_true(LeadingZeroAudit.in_text("").is_empty())


func test_scan_reports_the_path_of_the_offending_node() -> void:
	var root := Control.new()
	var label := Label.new()
	label.name = "Titulo"
	label.text = "Nivel 07"
	root.add_child(label)
	var button := Button.new()
	button.text = "Jugar"
	button.tooltip_text = "Ir al nivel 03"
	root.add_child(button)
	add_child_autofree(root)
	var problems: PackedStringArray = LeadingZeroAudit.scan(root)
	assert_eq(problems.size(), 2)
	assert_true(problems[0].begins_with("Titulo"), problems[0])
	assert_true(problems[1].contains("03"), "también mira los tooltips")


# --- Pantallas con números de nivel (los 15 niveles, con todo desbloqueado y victorias de 1 a 3 estrellas) ---

func _unlock_and_win_everything() -> void:
	for i: int in GameFlow.level_count():
		var id: StringName = GameFlow.level(i).id
		SaveManager.unlock(id)
		if i < 9:
			SaveManager.record_victory(id, [20, 10, 1][i % 3], 500 + i)


func _assert_clean(root: Node, what: String) -> void:
	assert_eq(LeadingZeroAudit.scan(root), PackedStringArray(), "%s: números con cero inicial" % what)


func test_level_select_has_no_leading_zero_in_map_and_cards() -> void:
	_unlock_and_win_everything()
	for style: int in [0, 1]:
		SaveManager.set_setting("selector_style", style)
		var select: Control = SELECT_SCENE.instantiate()
		add_child_autofree(select)
		await wait_process_frames(2)
		select.show_page(&"campaign")
		await wait_process_frames(2)
		_assert_clean(select, "selector (estilo %d)" % style)
	SaveManager.set_setting("selector_style", 1)


func test_level_select_card_texts_show_numbers_1_to_15() -> void:
	_unlock_and_win_everything()
	SaveManager.set_setting("selector_style", 0)
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	select.show_page(&"campaign")
	await wait_process_frames(2)
	var found: Dictionary = {}
	for node: Node in select.find_children("LevelNumber", "Label", true, false):
		found[(node as Label).text] = true
	assert_true(found.has("Nivel 1") and found.has("Nivel 9") and found.has("Nivel 10") and found.has("Nivel 15"), str(found.keys()))
	SaveManager.set_setting("selector_style", 1)


func test_records_screen_has_no_leading_zero_in_any_of_the_fifteen_levels() -> void:
	var records: Control = RECORDS_SCENE.instantiate()
	add_child_autofree(records)
	await wait_process_frames(2)
	for i: int in records.map_count():
		records.show_level(i)
		_assert_clean(records, "récords, nivel %d" % (i + 1))
	records.show_level(8)
	assert_true(records._level_name.text.begins_with("Nivel 9 · "), records._level_name.text)


func test_wiki_has_no_leading_zero_in_any_article() -> void:
	var wiki: Control = WIKI_SCENE.instantiate()
	add_child_autofree(wiki)
	await wait_process_frames(2)
	var seen: int = 0
	for category: StringName in wiki.category_ids():
		wiki.show_category(category)
		for entry: StringName in wiki.entry_ids():
			wiki.show_entry(entry)
			seen += 1
			_assert_clean(wiki, "Wiki %s/%s" % [category, entry])
	assert_gt(seen, 20, "recorrió los artículos de la Wiki")


func test_end_screen_has_no_leading_zero() -> void:
	var end: Node = END_SCENE.instantiate()
	add_child_autofree(end)
	await wait_process_frames(2)
	end.show_victory(7, 2, true, true, 1234, "")
	_assert_clean(end, "victoria")
	end.show_defeat(9, 10, true, 345, "")
	_assert_clean(end, "derrota")


func test_game_hud_has_no_leading_zero_in_levels_5_and_10() -> void:
	for index: int in [4, 9]:
		GameFlow.current_index = index
		var game: Game = GAME_SCENE.instantiate()
		add_child_autofree(game)
		await wait_physics_frames(3)
		_assert_clean(game, "juego, nivel %d" % (index + 1))
		game.queue_free()
		await wait_physics_frames(2)


# --- Formato de «Mejor: N vidas» ---

func test_best_lives_text_uses_the_singular_with_one() -> void:
	assert_eq(CampaignMap.best_lives_text(1), "Mejor: 1 vida", "el límite del singular")
	assert_eq(CampaignMap.best_lives_text(2), "Mejor: 2 vidas")
	assert_eq(CampaignMap.best_lives_text(20), "Mejor: 20 vidas")


func test_level_card_status_shows_one_life_in_the_singular() -> void:
	SaveManager.unlock(&"level_01")
	SaveManager.record_victory(&"level_01", 1)
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	assert_eq(select.status_text(0), "Mejor: 1 vida")


# --- RF-697: la receta del editor y los postes ---

func _use_recipe(palette: String, emblem: String) -> BannerRecipe:
	var recipe: BannerRecipe = BannerRecipe.make(palette, emblem)
	assert_true(BannerRecipeStore.save_recipe(recipe), "se guardó la receta de prueba")
	return recipe


func _play(index: int) -> Game:
	GameFlow.current_index = index
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _win_with_lives(level_id: StringName, stars: int) -> void:
	var lives: int = 20 if stars >= 3 else (10 if stars == 2 else 1)
	SaveManager.record_victory(level_id, lives)


func test_a_non_default_recipe_changes_the_player_post_with_three_stars() -> void:
	var recipe: BannerRecipe = _use_recipe("brasa", "rombo")
	_win_with_lives(&"level_03", 3)
	var game: Game = _play(2)
	assert_eq(GameFlow.level_stars(2), 3)
	var decor: LevelDecor = game.level.get_node("Decor") as LevelDecor
	assert_eq(decor.campaign_post_texture(), MapDrawings.post_texture(true, recipe), "usa la receta guardada")
	assert_ne(decor.campaign_post_texture(), MapDrawings.post_texture(true, BannerRecipe.default_recipe()), "y no la predeterminada")


func test_the_recipe_never_reaches_the_post_with_fewer_than_three_stars() -> void:
	_use_recipe("brasa", "rombo")
	for stars: int in [0, 1, 2]:
		if stars > 0:
			_win_with_lives(&"level_03", stars)
		var game: Game = _play(2)
		assert_null(game.level.banner_recipe, "%d estrellas: ni siquiera se carga la receta" % stars)
		assert_eq((game.level.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.POST_ENEMY)
		game.queue_free()
		await wait_physics_frames(2)


func test_the_recipe_is_not_inherited_by_test_mode_community_or_modes() -> void:
	_use_recipe("musgo", "franja")
	_win_with_lives(&"level_01", 3)
	DevMode.enabled = true
	var game: Game = _play(0)
	assert_null(game.level.banner_recipe, "modo de pruebas")
	game.queue_free()
	await wait_physics_frames(2)
	DevMode.enabled = false
	GameFlow.current_community = GameFlow.level(0)
	game = _play(-1)
	assert_null(game.level.banner_recipe, "comunidad")
	game.queue_free()
	await wait_physics_frames(2)
	GameFlow.current_community = null
	for candidate: Dictionary in ModePacks.all():
		if candidate["id"] == &"asedio":
			GameFlow.current_mode = candidate
	GameFlow.current_mode_index = 0
	game = _play(-1)
	assert_null(game.level.banner_recipe, "Asedio")
	assert_false(game.level.post_conquered)


func test_the_recipe_is_cosmetic_and_changes_no_rule_or_save_data() -> void:
	_win_with_lives(&"level_03", 3)
	var stars_before: int = GameFlow.level_stars(2)
	var lives_before: int = SaveManager.best_lives(&"level_03")
	var cells_before: Array[Vector2i] = CampaignPosts.cells_for(&"level_03")
	var plain: Game = _play(2)
	var rows_before: PackedStringArray = plain.level_data.map_rows.duplicate()
	plain.queue_free()
	await wait_physics_frames(2)
	_use_recipe("marea", "estrella")
	var styled: Game = _play(2)
	assert_eq(GameFlow.level_stars(2), stars_before)
	assert_eq(SaveManager.best_lives(&"level_03"), lives_before)
	assert_eq(CampaignPosts.cells_for(&"level_03"), cells_before, "mismas casillas de poste")
	assert_eq(styled.level_data.map_rows, rows_before, "el mapa jugable no cambia")
	assert_true(styled.level.post_conquered)
	assert_false(FileAccess.file_exists(TEST_SAVE) and FileAccess.get_file_as_string(TEST_SAVE).contains("marea"), "la receta no entra en el guardado de progreso")


func test_a_missing_or_corrupt_recipe_file_falls_back_to_the_default_post() -> void:
	_win_with_lives(&"level_03", 3)
	var game: Game = _play(2)
	assert_eq((game.level.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.post_texture(true, BannerRecipe.default_recipe()), "archivo ausente")
	game.queue_free()
	await wait_physics_frames(2)
	var file := FileAccess.open(TEST_RECIPE, FileAccess.WRITE)
	file.store_string("{ no es json")
	file.close()
	game = _play(2)
	assert_true(game.level.post_conquered)
	assert_eq((game.level.get_node("Decor") as LevelDecor).campaign_post_texture(), MapDrawings.post_texture(true, BannerRecipe.default_recipe()), "archivo dañado")
