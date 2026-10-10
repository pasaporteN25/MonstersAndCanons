# Tests de la categoría Lore de la Wiki (M52, T228: RF-469, RF-470): el formato de los artículos, el
# desbloqueo al ganar un nivel (con un guardado de prueba), el artículo cerrado y que la Guía no cambia.
extends GutTest

const TEST_SAVE: String = "user://test_lore_save.json"
const TEST_DIR: String = "user://test_lore_articles/"
const WIKI_SCENE: PackedScene = preload("res://scenes/ui/wiki_screen.tscn")
## La campaña terminada tiene 15 niveles (T234 sumó el último): los artículos de los niveles 11, 14 y 15 ya se ven
## cuando se gana su nivel. Este test valida los artículos contra esa lista fija, aunque la campaña cambie.
const PLANNED_CAMPAIGN: Array = ["level_01", "level_02", "level_03", "level_04", "level_05", "level_06", "level_07", "level_08",
	"level_09", "level_10", "level_11", "level_12", "level_13", "level_14", "level_15"]

var _levels_won: Array[StringName] = []


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_levels_won = []
	_clean_dir()


func after_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()
	_clean_dir()


func _clean_dir() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)


func _win(level_id: StringName) -> void:
	SaveManager.record_victory(level_id, 10, 100)


func _lore() -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, Callable(), SaveManager.is_completed):
		if category.id == &"lore":
			return category
	return null


func _article(unlock: String = "\"level_08\"", extra: String = "") -> String:
	var unlock_line: String = "" if unlock == "" else "\"desbloqueo\": %s," % unlock
	return "{\"version\": 1, \"titulo\": \"Prueba\", %s %s \"bloques\": [{\"tipo\": \"texto\", \"texto\": \"Hola.\"}]}" % [unlock_line, extra]


func _write(file_name: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file := FileAccess.open(TEST_DIR + file_name, FileAccess.WRITE)
	file.store_string(text)
	file.close()


# --- Los artículos oficiales ---

func test_the_official_lore_articles_have_no_errors() -> void:
	var result: Dictionary = Wiki.articles(Wiki.LORE_DIR, true, PLANNED_CAMPAIGN)
	assert_eq(result["errors"].size(), 0, str(result["errors"]))
	assert_eq((result["entries"] as Array).size(), 11, "los 10 artículos de 11-textos-lore.md §4 y «La Cuadrilla» (T253)")


func test_the_official_lore_articles_are_the_approved_ones_in_order() -> void:
	var result: Dictionary = Wiki.articles(Wiki.LORE_DIR, true, PLANNED_CAMPAIGN)
	var titles: PackedStringArray = []
	for entry: WikiEntry in result["entries"]:
		titles.append(entry.title)
	assert_eq(titles, PackedStringArray(["El oasis", "Cántaro", "La Compañía Meridiana", "El Soberano",
		"Las criaturas que van solas", "La Cuadrilla", "Las ruinas", "Los Moradores", "Los pozos", "Los poblados vacíos", "La Central"]))
	var unlocks: Dictionary = result["unlocks"]
	assert_eq(unlocks[&"el_oasis"], &"level_01")
	assert_eq(unlocks[&"la_cuadrilla"], &"level_07")
	assert_eq(unlocks[&"las_ruinas"], &"level_08")
	assert_eq(unlocks[&"la_central"], &"level_15")


func test_lore_articles_do_not_repeat_game_numbers_in_a_table() -> void:
	# P2: un artículo explica, no repite números de los datos; los de Lore son solo párrafos.
	for entry: WikiEntry in Wiki.articles(Wiki.LORE_DIR, true, PLANNED_CAMPAIGN)["entries"]:
		for block: Dictionary in entry.blocks:
			assert_eq(block["tipo"], WikiEntry.KIND_TEXT, "%s trae un bloque que no es texto" % entry.id)


func test_the_guide_does_not_see_the_lore_subfolder() -> void:
	var guide_ids: Array[StringName] = []
	for entry: WikiEntry in Wiki.articles(Wiki.ARTICLES_DIR)["entries"]:
		guide_ids.append(entry.id)
	assert_false(guide_ids.has(&"el_oasis"))
	assert_false(guide_ids.has(&"la_central"))
	assert_true(guide_ids.has(&"licencias"), "la Guía conserva sus artículos")
	assert_eq(guide_ids.size(), DirAccess.get_files_at(Wiki.ARTICLES_DIR).size() - 0, "uno por cada .json de data/wiki/")


func test_the_categories_keep_their_order_with_lore_after_the_guide() -> void:
	var ids: Array[StringName] = []
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		ids.append(category.id)
	assert_eq(ids, [&"enemigos", &"torres", &"colecciones", &"guia", &"lore"])


# --- Validación (RF-469) ---

func test_a_lore_article_needs_a_desbloqueo() -> void:
	var parsed: Dictionary = Wiki.parse_article(_article(""), &"x", true, PLANNED_CAMPAIGN)
	assert_null(parsed["entry"])
	assert_string_contains(parsed["errors"][0], "desbloqueo")


func test_desbloqueo_must_be_a_level_id_of_the_campaign() -> void:
	assert_null(Wiki.parse_article(_article("5"), &"x", true, PLANNED_CAMPAIGN)["entry"], "no es un texto")
	assert_null(Wiki.parse_article(_article("\"el_oasis\""), &"x", true, PLANNED_CAMPAIGN)["entry"], "no es un id de nivel")
	var unknown: Dictionary = Wiki.parse_article(_article("\"level_99\""), &"x", true, PLANNED_CAMPAIGN)
	assert_null(unknown["entry"], "no figura en la campaña")
	assert_string_contains(unknown["errors"][0], "level_99")
	assert_not_null(Wiki.parse_article(_article("\"level_08\""), &"x", true, PLANNED_CAMPAIGN)["entry"])


func test_a_broken_lore_article_is_skipped_and_the_rest_still_show() -> void:
	_write("buena.json", _article("\"level_08\""))
	_write("rota.json", _article(""))
	var result: Dictionary = Wiki.articles(TEST_DIR, true, PLANNED_CAMPAIGN)
	assert_eq((result["entries"] as Array).size(), 1)
	assert_eq(result["errors"].size(), 1)


func test_the_guide_rejects_the_desbloqueo_key() -> void:
	var parsed: Dictionary = Wiki.parse_article(_article("\"level_08\""), &"x")
	assert_null(parsed["entry"])
	assert_string_contains(parsed["errors"][0], "desbloqueo")


# --- Desbloqueo (RF-470) ---

func test_a_new_save_has_all_lore_closed() -> void:
	var lore: WikiCategory = _lore()
	assert_not_null(lore)
	assert_eq(lore.unlocked_count(), 0)
	assert_true(lore.has_locked())
	for entry: WikiEntry in lore.entries:
		assert_true(entry.locked, entry.id)
		assert_eq(entry.title, "???")
		assert_true(entry.icon.is_empty(), "cerrado y sin dibujo")


func test_winning_level_1_opens_the_oasis_only() -> void:
	_win(&"level_01")
	var lore: WikiCategory = _lore()
	assert_eq(lore.unlocked_count(), 1)
	assert_false(lore.find(&"el_oasis").locked)
	assert_eq(lore.find(&"el_oasis").title, "El oasis")
	assert_true(lore.find(&"planeta_cantaro").locked)


func test_a_closed_article_says_the_level_number_and_nothing_else() -> void:
	var entry: WikiEntry = _lore().find(&"las_ruinas")
	assert_true(entry.locked)
	var text: String = entry.plain_text()
	assert_string_contains(text, "Se abre al ganar el nivel 8.")
	assert_false(text.contains("Las ruinas"), "no muestra el título")
	assert_false(text.contains("Bastión"), "no nombra el nivel")
	assert_false(text.contains("muros"), "no muestra el texto")
	assert_eq(entry.blocks.size(), 1)


func test_a_save_that_won_1_to_9_has_eight_open() -> void:
	for i: int in range(1, 10):
		_win(StringName("level_%02d" % i))
	var lore: WikiCategory = _lore()
	var open: PackedStringArray = []
	for entry: WikiEntry in lore.entries:
		if not entry.locked:
			open.append(entry.id)
	assert_eq(open, PackedStringArray(["el_oasis", "planeta_cantaro", "la_compania", "el_soberano", "criaturas_solas", "la_cuadrilla", "las_ruinas", "los_moradores"]))


func test_the_order_does_not_change_when_one_opens() -> void:
	var before: Array[StringName] = []
	for entry: WikiEntry in _lore().entries:
		before.append(entry.id)
	_win(&"level_04")
	var after: Array[StringName] = []
	for entry: WikiEntry in _lore().entries:
		after.append(entry.id)
	assert_eq(after, before)


func test_without_a_completion_function_everything_is_open() -> void:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		assert_false(category.has_locked() and category.id == &"lore")


func test_lore_unlock_text_uses_the_campaign_position_or_the_id() -> void:
	assert_eq(LoreUnlock.locked_text(&"level_08", ["level_01", "level_08"]), "Se abre al ganar el nivel 2.", "manda la posición en la campaña")
	assert_eq(LoreUnlock.locked_text(&"level_11", ["level_01"]), "Se abre al ganar el nivel 11.", "si no está, el número del id")
	assert_true(LoreUnlock.locked_text(&"cualquiera", []).begins_with("Se abre al ganar"))
	assert_true(LoreUnlock.is_open(&"level_01", func(_id: StringName) -> bool: return true))
	assert_false(LoreUnlock.is_open(&"level_01", func(_id: StringName) -> bool: return false))
	assert_true(LoreUnlock.is_open(&"level_01", Callable()), "sin función, abierto")


# --- La pantalla ---

func _screen(completed: Callable) -> Control:
	var screen: Control = WIKI_SCENE.instantiate()
	screen.on_leave = func() -> void: pass
	screen.is_completed = completed
	add_child_autofree(screen)
	return screen


func test_the_screen_tab_counts_lore_and_a_closed_entry_does_not_break_the_icon() -> void:
	var screen: Control = _screen(SaveManager.is_completed)
	assert_true(screen.category_ids().has(&"lore"))
	assert_eq(screen.tab_text(&"lore"), "Lore 0/%d" % _lore().entries.size())
	screen.show_target(&"lore", &"las_ruinas")
	assert_string_contains(screen.detail_text(), "Se abre al ganar el nivel 8.")
	assert_false(screen.detail_text().contains("muros"))


func test_the_screen_shows_an_open_article_after_winning() -> void:
	_win(&"level_01")
	var screen: Control = _screen(SaveManager.is_completed)
	screen.show_target(&"lore", &"el_oasis")
	assert_string_contains(screen.detail_text(), "El oasis es un valle chico")
	assert_eq(screen.tab_text(&"lore"), "Lore 1/%d" % _lore().entries.size())


func test_dev_mode_opens_all_the_lore() -> void:
	var screen: Control = _screen(func(_id: StringName) -> bool: return true)
	assert_eq(screen.tab_text(&"lore"), "Lore", "sin cerrados no se cuenta")
	screen.show_target(&"lore", &"las_ruinas")
	assert_string_contains(screen.detail_text(), "Sobre la loma del bastión")
