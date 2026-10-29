# Inglés de la interfaz (T534, RF-727, D-217, D-222): cobertura de claves usadas en el código, ningún texto normal
# quedó en español en el catálogo inglés, y las pantallas migradas se arman en inglés. No toca el guardado real.
extends GutTest

const TEST_SAVE: String = "user://test_localization_en.json"
const SOURCE_DIRS: Array[String] = ["res://scenes", "res://scripts"]
## Textos que son iguales en ambos idiomas por decisión (D-222): nombre del juego, siglas, formatos.
const SAME_IN_BOTH: Array[String] = ["menu.main.wiki", "options.advanced.interface_pc", "version.beta", "enemy.normal.name", "enemy.troll.name",
		"towertext.combo_group", "towertext.combo_line", "common.no", "hud.tower_tip", "hud.exit_editor", "game.resources_float",
		"select.community_card", "tutorial.ui.titulo", "wiki.efectos.b9", "wiki.cat_lore", "wiki.title", "wiki.combos", "news.v1_0_0.title",
		"editor.suffix_seconds", "editor.suffix_percent", "lvlfile.where_legend", "banner_palette.meridiana.name", "banner_emblem.chevron.name"]
## Nombres propios que se conservan en español en el inglés (D-222).
const KEPT_NAMES: Array[String] = ["cántaro", "compañía meridiana"]
const SPANISH_MARKS: Array[String] = ["á", "é", "í", "ó", "ú", "ñ", "¿", "¡", "ción"]


func after_each() -> void:
	Localization.reset()
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _source_files(dir_path: String) -> Array[String]:
	var found: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return found
	for sub: String in dir.get_directories():
		found.append_array(_source_files("%s/%s" % [dir_path, sub]))
	for file: String in dir.get_files():
		if file.ends_with(".gd"):
			found.append("%s/%s" % [dir_path, file])
	return found


## Las claves del catálogo escritas como `&"dominio.clave"` en el código.
func _keys_used_in_code() -> Dictionary:
	var domains: Dictionary = {}
	var catalog: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")["entradas"]
	for key: String in catalog:
		domains[key.get_slice(".", 0)] = true
	var regex := RegEx.new()
	regex.compile("&\"([a-z][a-z0-9_]*(?:\\.[a-z0-9_]+)+)\"")
	var used: Dictionary = {}  # clave → archivo
	for dir_path: String in SOURCE_DIRS:
		for path: String in _source_files(dir_path):
			if path.ends_with("localization.gd") or path.ends_with("localization_catalog.gd"):
				continue
			for m: RegExMatch in regex.search_all(FileAccess.get_file_as_string(path)):
				var key: String = m.get_string(1)
				if domains.has(key.get_slice(".", 0)):
					used[key] = path
	return used


func test_every_key_used_in_code_exists_in_both_languages() -> void:
	var es: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")["entradas"]
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")["entradas"]
	var used: Dictionary = _keys_used_in_code()
	assert_gt(used.size(), 40, "el escaneo tiene que encontrar las claves de las pantallas migradas")
	for key: String in used:
		var present_es: bool = es.has(key) or es.has(key + ".one")
		var present_en: bool = en.has(key) or en.has(key + ".one")
		assert_true(present_es, "falta en es.json: %s (%s)" % [key, used[key]])
		assert_true(present_en, "falta en en.json: %s (%s)" % [key, used[key]])


func test_shipped_catalogs_are_complete_and_placeholders_match() -> void:
	var es: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")
	assert_eq(LocalizationCatalog.validate(es, en, true), [] as Array[String])
	assert_eq((en["entradas"] as Dictionary).size(), (es["entradas"] as Dictionary).size())


func test_english_catalog_has_no_normal_text_left_in_spanish() -> void:
	var es: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")["entradas"]
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")["entradas"]
	for key: String in en:
		if SAME_IN_BOTH.has(key):
			assert_eq(en[key], es[key], "%s es igual en ambos idiomas" % key)
			continue
		assert_ne(en[key], es[key], "%s quedó igual que el español" % key)
		var text: String = String(en[key]).to_lower()
		for kept: String in KEPT_NAMES:
			text = text.replace(kept, "")
		for mark: String in SPANISH_MARKS:
			assert_false(text.contains(mark), "%s parece español: %s" % [key, en[key]])


func test_main_menu_and_tools_in_english() -> void:
	Localization.set_language("en")
	var menu: MainMenu = preload("res://scenes/ui/main_menu.tscn").instantiate()
	menu.news_version_source = func() -> String: return ""
	add_child_autofree(menu)
	assert_eq((menu.get_node("%PlayButton") as Button).text, "Play")
	assert_eq((menu.get_node("%RecordsButton") as Button).text, "Records")
	assert_eq((menu.get_node("%EditorButton") as Button).text, "Tools")
	assert_eq((menu.get_node("%QuitButton") as Button).text, "Quit")
	var tools: ToolsHub = preload("res://scenes/ui/tools_hub.tscn").instantiate()
	add_child_autofree(tools)
	assert_eq((tools.get_node("%MapEditorButton") as Button).text, "Map editor")
	assert_eq((tools.get_node("%BackButton") as Button).text, "Back")


func test_pause_menu_in_english_and_quit_text_override() -> void:
	Localization.set_language("en")
	var pause: PauseMenu = preload("res://scenes/ui/pause_menu.tscn").instantiate()
	add_child_autofree(pause)
	assert_eq((pause.get_node("%ResumeButton") as Button).text, "Resume")
	assert_eq((pause.get_node("%QuitButton") as Button).text, "Exit to menu")
	pause.set_quit_text(Localization.t(&"pause.back_to_editor"))
	assert_eq((pause.get_node("%QuitButton") as Button).text, "Back to the editor")


func test_exit_text_in_both_languages() -> void:
	assert_eq(ExitText.title(), "¿Volver al menú principal?")
	Localization.set_language("en")
	assert_eq(ExitText.title(), "Return to the main menu?")
	assert_eq(ExitText.message(), "This match's progress will not be saved.")


func test_game_version_label_in_english() -> void:
	Localization.set_language("en")
	assert_eq(GameVersion.label("1.0.0"), "Version 1.0.0")
	assert_eq(GameVersion.label("0.3.0"), "Beta 0.3.0")
	assert_eq(GameVersion.label(""), "Beta")


func test_view_all_conflict_names_follow_the_language() -> void:
	assert_eq(ViewAllBinding.label_for_action(&"pause"), "pausa")
	assert_eq(ViewAllBinding.label_for_action(&"build_basic"), "elegir una torre")
	Localization.set_language("en")
	assert_eq(ViewAllBinding.label_for_action(&"pause"), "pause")
	assert_eq(ViewAllBinding.label_for_action(&"build_basic"), "choosing a tower")
	assert_eq(ViewAllBinding.conflict(KEY_F1), "the test panel")


func test_options_in_english_and_live_language_switch() -> void:
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	Localization.selector_visible = true  # el selector está oculto en el juego; acá se arma para probarlo
	var options: OptionsMenu = preload("res://scenes/ui/options_menu.tscn").instantiate()
	add_child_autofree(options)
	options.open()
	assert_eq((options.get_node("%BackButton") as Button).text, "Volver")
	var selector: OptionButton = options.language_selector()
	assert_eq(selector.item_count, 2)
	selector.select(1)
	selector.item_selected.emit(1)  # el jugador elige «Inglés»
	assert_eq(SaveManager.language(), &"en")
	assert_eq(Localization.language, &"en")
	assert_eq((options.get_node("%BackButton") as Button).text, "Back")
	assert_eq((options.get_node("%FullscreenCheck") as CheckBox).text, "Fullscreen")
	assert_eq(selector.get_item_text(0), "Spanish")
	assert_eq(selector.get_item_text(1), "English")
	assert_eq((options.find_child("RangeDisplaySelector", true, false) as OptionButton).get_item_text(2), "Full")
	assert_eq((options.find_child("UiModeSelector", true, false) as OptionButton).get_item_text(0), "Automatic")
	assert_eq((options.find_child("Tab2", true, false) as Button).text, "Game\nand help")
	assert_eq(options.admin_button_text(), "Enable test mode")


func test_language_survives_restart_without_touching_progress() -> void:
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	SaveManager.set_setting("language", "en")
	assert_true(SaveManager.save())
	var before: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	Localization.reset()  # "reiniciar": se pierde el idioma en memoria
	assert_eq(Localization.language, &"es")
	SaveManager.load_save()
	assert_eq(Localization.language, &"en", "el idioma guardado rige desde el arranque")
	assert_true(SaveManager.save())
	var after: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	assert_eq(after["version"], before["version"])
	assert_eq(after["levels"], before["levels"])


func test_language_is_kept_when_entering_and_leaving_test_mode() -> void:
	var normal_path: String = "user://test_localization_en_normal.json"
	var dev_path: String = "user://test_localization_en_dev.json"
	DevMode.set_enabled(false, normal_path)
	SaveManager.set_setting("language", "en")
	DevMode.set_enabled(true, dev_path)
	assert_eq(Localization.language, &"en", "el guardado de pruebas es nuevo y no trae idioma")
	DevMode.set_enabled(false, normal_path)
	assert_eq(Localization.language, &"en")
	for path: String in [normal_path, dev_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


# --- T534, segunda tanda: partida, torres, enemigos, consejos, tutorial, Wiki, selector ---

func _resource_ids(dir_path: String) -> Array[String]:
	var ids: Array[String] = []
	for file: String in DirAccess.get_files_at(dir_path):
		var name: String = file.trim_suffix(".remap")
		if name.ends_with(".tres"):
			ids.append(name.get_basename())
	return ids


func test_every_tower_and_enemy_has_english_name_and_description() -> void:
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")["entradas"]
	var es: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")["entradas"]
	var towers: Array[String] = _resource_ids("res://data/towers")
	var enemies: Array[String] = _resource_ids("res://data/enemies")
	assert_gt(towers.size(), 9)
	assert_gt(enemies.size(), 17)
	for id: String in towers:
		for field: String in ["name", "description"]:
			assert_true(en.has("tower.%s.%s" % [id, field]), "falta en inglés: tower.%s.%s" % [id, field])
			assert_true(es.has("tower.%s.%s" % [id, field]), "falta en español: tower.%s.%s" % [id, field])
	for id: String in enemies:
		for field: String in ["name", "description"]:
			assert_true(en.has("enemy.%s.%s" % [id, field]), "falta en inglés: enemy.%s.%s" % [id, field])
			assert_true(es.has("enemy.%s.%s" % [id, field]), "falta en español: enemy.%s.%s" % [id, field])


func test_tower_and_enemy_data_keep_their_spanish_and_ids_in_english() -> void:
	var tower: TowerData = load("res://data/towers/basic.tres") as TowerData
	var enemy: EnemyData = load("res://data/enemies/armored.tres") as EnemyData
	assert_eq(tower.name_text(), "Ametralladora")
	assert_eq(tower.name_text(), tower.display_name)
	assert_eq(enemy.description_text(), enemy.description)
	Localization.set_language("en")
	assert_eq(tower.name_text(), "Machine Gun")
	assert_eq(enemy.name_text(), "Armored")
	assert_eq(tower.display_name, "Ametralladora", "el .tres no cambia")
	assert_eq(tower.id, &"basic", "el id no cambia")
	assert_eq(enemy.description_text().left(14), "Its armor take")


func test_tower_texts_in_english_keep_numbers_and_decimal_comma() -> void:
	var cannon: TowerData = load("res://data/towers/cannon.tres") as TowerData
	var es_effects: Array[String] = TowerText.effects(cannon.levels[0])
	var es_cost: String = TowerText.cost_text(cannon)
	Localization.set_language("en")
	var en_effects: Array[String] = TowerText.effects(cannon.levels[0])
	assert_eq(en_effects.size(), es_effects.size())
	assert_true(en_effects[0].begins_with("Area: radius "), en_effects[0])
	assert_true(es_effects[0].begins_with("Área: radio "), es_effects[0])
	assert_true(TowerText.cost_text(cannon).ends_with(" gold"))
	assert_true(es_cost.ends_with(" de oro"))
	assert_eq(TowerText.resources_word(1), "resource")
	assert_eq(TowerText.resources_word(3), "resources")
	assert_eq(TowerText.join_names(["A", "B", "C"] as Array[String]), "A, B and C")
	assert_eq(TowerText.plural("Guardian"), "Guardians")
	assert_eq(UpgradeDeltas.header(2, false), "Level 2!")
	assert_eq(UpgradeDeltas.header(3, true), "Max level!")
	assert_eq(UpgradeDeltas.stat_label("damage", "daño"), "damage")


func test_defeat_advice_rules_exist_in_english_with_the_towers_placeholder() -> void:
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")["entradas"]
	var advice: AdviceData = AdviceData.load_file()
	assert_true(advice.is_valid())
	for rule: Dictionary in advice.rules:
		var key: String = "advice.%s.text" % rule["id"]
		assert_true(en.has(key), "falta el consejo en inglés: %s" % key)
		assert_true(String(en.get(key, "")).contains(AdviceData.PLACEHOLDER_TOWERS), "%s perdió {torres}" % key)
		assert_lt(String(en.get(key, "")).length(), advice.max_chars + 20, "%s es largo" % key)


func test_tutorial_texts_in_english_have_the_same_steps() -> void:
	var data: TutorialData = TutorialData.load_file()
	assert_true(data.is_valid())
	var es_pc: Array[Dictionary] = data.steps_for(false)
	var es_text: String = es_pc[0]["texto"]
	Localization.set_language("en")
	var en_pc: Array[Dictionary] = data.steps_for(false)
	var en_mobile: Array[Dictionary] = data.steps_for(true)
	assert_eq(en_pc.size(), es_pc.size())
	assert_eq(en_mobile.size(), data.mobile_steps.size())
	for i: int in en_pc.size():
		assert_eq(en_pc[i]["paso"], es_pc[i]["paso"], "el paso y su evento no cambian")
		assert_ne(en_pc[i]["texto"], data.pc_steps[i]["texto"], "sin traducir: %s" % en_pc[i]["paso"])
	assert_ne(en_pc[0]["texto"], es_text)
	assert_eq(data.ui_text("terminar"), "Let's play!")
	assert_eq(data.ui_text("paso") % [1, 14], "Step 1 of 14")


func test_wiki_guide_and_cards_in_english() -> void:
	var es_titles: Array[String] = []
	for entry: WikiEntry in Wiki.articles(Wiki.ARTICLES_DIR)["entries"]:
		es_titles.append(entry.title)
	assert_true(es_titles.has("Armadura y daño"))
	Localization.set_language("en")
	var en_titles: Array[String] = []
	for entry: WikiEntry in Wiki.articles(Wiki.ARTICLES_DIR)["entries"]:
		en_titles.append(entry.title)
	assert_eq(en_titles.size(), es_titles.size())
	assert_true(en_titles.has("Armor and damage"))
	assert_true(en_titles.has("Keys and controls"))
	var categories: Array[WikiCategory] = Wiki.categories()
	assert_eq(categories[0].title, "Enemies")
	assert_eq(categories[1].title, "Towers")
	var entry: WikiEntry = Wiki.enemy_entry(load("res://data/enemies/armored.tres") as EnemyData, [] as Array[EnemyData], [] as Array[LevelData])
	assert_eq(entry.title, "Armored")
	assert_eq(entry.subtitle, "Ground")


func test_lore_articles_stay_in_spanish_as_documented() -> void:
	Localization.set_language("en")
	var loaded: Dictionary = Wiki.articles(Wiki.LORE_DIR, true, Array(LevelFile.campaign_ids()))
	assert_eq((loaded["errors"] as PackedStringArray).size(), 0)
	assert_gt((loaded["entries"] as Array).size(), 0)
	var es_loaded: Dictionary
	Localization.set_language("es")
	es_loaded = Wiki.articles(Wiki.LORE_DIR, true, Array(LevelFile.campaign_ids()))
	for i: int in (loaded["entries"] as Array).size():
		assert_eq((loaded["entries"][i] as WikiEntry).title, (es_loaded["entries"][i] as WikiEntry).title)


func test_end_screen_and_official_mode_in_english() -> void:
	Localization.set_language("en")
	var end: EndScreen = preload("res://scenes/ui/end_screen.tscn").instantiate()
	add_child_autofree(end)
	end.show_defeat(3, 10, true, 50)
	assert_eq((end.get_node("%Title") as Label).text, "Defeat")
	assert_eq((end.get_node("%Detail") as Label).text, "You reached wave 3 of 10")
	assert_eq((end.get_node("%RetryButton") as Button).text, "Retry")
	end.show_victory(5, 3, true, true, 120)
	assert_eq((end.get_node("%Title") as Label).text, "Victory!")
	assert_eq((end.get_node("%NextButton") as Button).text, "Next level")
	assert_eq((end.get_node("%Detail") as Label).text, "Lives left: 5")


func test_infrastructure_and_obstacle_texts_in_english() -> void:
	assert_eq(InfrastructureText.job_left_line(4.0), "Faltan 4 s")
	assert_eq(InfrastructureText.buy_text(100, 100), "Comprar")
	Localization.set_language("en")
	assert_eq(InfrastructureText.job_left_line(4.0), "4 s left")
	assert_eq(InfrastructureText.buy_text(100, 100), "Buy")
	assert_eq(InfrastructureText.buy_text(100, 40), "You are 60 gold short")
	assert_eq(InfrastructureText.tab_title(), "Infrastructure")
	assert_eq(ObstacleText.cost_line(15), "Cost: 15 gold")
	assert_eq(ObstacleText.reserve_line(6, 8), "Reserve 6/8")


func test_news_entry_and_labels_in_english() -> void:
	var data: NewsData = NewsData.load_file()
	assert_gt(data.entries.size(), 0)
	var entry: Dictionary = data.entries[0]
	var es_title: String = String(entry["titulo"])
	assert_eq(NewsData.localized_entry(entry)["titulo"], es_title, "en español queda tal cual")
	Localization.set_language("en")
	var en_entry: Dictionary = NewsData.localized_entry(entry)
	assert_eq(String(entry["titulo"]), es_title, "el original no se modifica")
	assert_eq((en_entry["novedades"] as Array).size(), (entry["novedades"] as Array).size())
	assert_eq(String((en_entry["novedades"] as Array)[0]["titulo"]), "15 levels, one story")
	assert_eq(NewsData.localized_labels(data.labels)["entendido"], "Got it")


func test_campaign_texts_in_english() -> void:
	assert_eq(CampaignMap.best_lives_text(1), "Mejor: 1 vida")
	Localization.set_language("en")
	assert_eq(CampaignMap.best_lives_text(1), "Best: 1 life")
	assert_eq(CampaignMap.best_lives_text(20), "Best: 20 lives")
	assert_eq(CampaignMap.state_text(CampaignMap.State.LOCKED), "Locked")
