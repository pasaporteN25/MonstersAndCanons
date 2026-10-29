# Inglés del editor de mapas y de banderines, de los mensajes de validación para quienes hacen mapas, modos o datos
# y del panel del modo de pruebas (T534, tercera tanda, RF-727, D-222). El español no cambia: cada caso compara los dos.
# OJO: nunca se llama a leave() ni a nada que cambie de pantalla (reemplazaría la escena de GUT).
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const BANNER_SCENE: PackedScene = preload("res://scenes/editor/banner_editor.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const NORMAL_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"
const MODES_DIR: String = "user://test_loc_modes/"


func after_each() -> void:
	Localization.reset()
	GameFlow.editor_draft = null
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


## `DevMode.set_enabled` carga un guardado y con él el idioma: el idioma se fija después.
func _editor(lang: String = "es") -> MapEditor:
	DevMode.set_enabled(true, DEV_PATH)
	Localization.set_language(lang)
	GameFlow.editor_draft = null
	var editor: MapEditor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	return editor


func _texts(editor: Node, names: Array[String]) -> Array[String]:
	var found: Array[String] = []
	for node_name: String in names:
		found.append((editor.get_node("%" + node_name) as Button).text)
	return found


func test_editor_top_bar_and_messages_in_both_languages() -> void:
	var editor: MapEditor = _editor()
	var names: Array[String] = ["NewButton", "OpenButton", "SaveButton", "SaveModeButton", "TryButton", "SettingsButton", "WavesButton", "ObjectsButton", "BackButton"]
	assert_eq(_texts(editor, names), ["Nuevo", "Abrir", "Guardar", "En un modo…", "Probar", "Ajustes", "Oleadas", "Objetos", "Salir"] as Array[String])
	assert_eq(editor.message_text(), "✓ Nivel válido · Entrada A: 8 casillas".replace("8", str(editor.draft.grid().routes[0].size())))
	editor.queue_free()
	await get_tree().process_frame
	editor = _editor("en")
	assert_eq(_texts(editor, names), ["New", "Open", "Save", "In a mode…", "Test", "Settings", "Waves", "Objects", "Exit"] as Array[String])
	var tiles: int = editor.draft.grid().routes[0].size()
	assert_eq(editor.message_text(), "✓ Valid level · Entrance A: %d tiles" % tiles)
	assert_eq((editor.get_node("%Title") as Label).text, "Map editor · New level")
	assert_eq((editor.get_node("%SaveModeButton") as Button).tooltip_text, "Save the map inside one of your own modes (or create a new one)")


func test_editor_tool_buttons_and_error_message_in_english() -> void:
	var editor: MapEditor = _editor("en")
	var labels: Array[String] = []
	for button: Node in (editor.get_node("%Tools") as HBoxContainer).get_children():
		if button is Button and (button as Button).toggle_mode:
			labels.append((button as Button).text)
	assert_eq(labels.slice(0, 5), ["Grass (1)", "Path (2)", "Blocked (3)", "Entrance (4)", "Exit (5)"] as Array[String])
	assert_eq(labels[9], "Forest (0)")
	editor.paint_at(Vector2i(0, editor.draft.rows().size() / 2))  # el camino tapa la entrada A (es la herramienta elegida)
	assert_eq(editor.message_kind(), &"error")
	assert_true(editor.message_text().begins_with("✗ "), "el mensaje de error empieza con la cruz: %s" % editor.message_text())
	assert_false(editor.message_text().contains("Falta"), "sin español en el mensaje: %s" % editor.message_text())


func test_editor_panels_in_english() -> void:
	var editor: MapEditor = _editor("en")
	var settings: SettingsPanel = editor.settings_panel()
	assert_eq(settings.machine_check().text, "Demolisher available")
	assert_eq(settings.default_towers_button().text, "Use the usual ones")
	assert_eq(settings.gold_spin().suffix, " gold")
	assert_eq(settings.lives_spin().suffix, " lives")
	var waves: WavesPanel = editor.waves_panel()
	editor.show_panel(waves, true)
	assert_eq(waves.total_text(), "Enemies in this wave: 10")
	assert_eq((waves.find_child("AddGroup", true, false) as Button).text, "+ Add group")
	assert_eq((waves.find_child("RemoveWave", true, false) as Button).text, "Remove")
	var objects: ObjectsPanel = editor.objects_panel()
	editor.set_tool(LevelDraft.Tool.RUBBLE)
	editor.paint_at(Vector2i(1, 1))
	editor.show_panel(objects, true)
	assert_eq(objects.letter_option().get_item_text(0), "u · Rubble")
	assert_eq(objects.finding_note().text, "Collection pieces can only be obtained in the campaign")
	assert_eq(objects.field_label("costo").text.split(" (")[0], "Cost")


func test_editor_dialogs_in_english() -> void:
	var editor: MapEditor = _editor("en")
	editor.open_level()
	assert_true(editor.dialog().is_open())
	var dialog: EditorDialog = editor.dialog()
	var texts: Array[String] = []
	for item: Node in dialog.find_children("*", "ItemList", true, false):
		for i: int in (item as ItemList).item_count:
			texts.append((item as ItemList).get_item_text(i))
	assert_true(texts.has("— My maps —"), "sale el encabezado inglés: %s" % [texts])
	assert_true(texts.has("— Official levels (they open as a template) —"))
	var cancel: Array[Node] = dialog.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return (b as Button).text == "Cancel")
	assert_eq(cancel.size(), 1)


func test_banner_editor_texts_in_both_languages() -> void:
	var editor: BannerEditor = BANNER_SCENE.instantiate()
	editor.store_path = "user://test_loc_banner.json"
	editor.close_editor = func() -> void: pass
	add_child_autofree(editor)
	await get_tree().process_frame
	assert_eq((editor.get_node("%ApplyButton") as Button).text, "Aplicar")
	editor.restore_default()
	assert_eq((editor.get_node("%Message") as Label).text, "Predeterminado seleccionado. Aplicalo para guardarlo.")
	Localization.set_language("en")
	var english: BannerEditor = BANNER_SCENE.instantiate()
	english.store_path = "user://test_loc_banner.json"
	english.close_editor = func() -> void: pass
	add_child_autofree(english)
	await get_tree().process_frame
	assert_eq((english.get_node("%ApplyButton") as Button).text, "Apply")
	assert_eq((english.get_node("%CancelButton") as Button).text, "Cancel")
	assert_eq((english.get_node("%RestoreButton") as Button).text, "Restore")
	english.restore_default()
	assert_eq((english.get_node("%Message") as Label).text, "Default selected. Apply it to save it.")
	var choices: Array[String] = []
	for choice: Node in english.get_node("%PaletteRow").get_children():
		choices.append((choice as Button).text)
	assert_eq(choices, ["Meridiana", "Ember", "Moss", "Tide"] as Array[String])


func test_every_banner_choice_has_an_english_name() -> void:
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")["entradas"]
	for id: String in BannerCatalog.palette_ids():
		assert_true(en.has("banner_palette.%s.name" % id), "paleta %s sin inglés" % id)
	for id: String in BannerCatalog.emblem_ids():
		assert_true(en.has("banner_emblem.%s.name" % id), "emblema %s sin inglés" % id)


func test_level_file_messages_in_both_languages() -> void:
	var text: String = '{"version": 1, "nombre": "X", "oro": 100, "vidas": 10, "mapa": ["A..S"], "oleadas": [[{"enemigo": "normal", "cantidad": 0}]], "nope": 1}'
	var es: Array = LevelFile.parse(text, &"level_x")["errors"]
	assert_true(es.has("Clave desconocida \"nope\" (se usan: version, nombre, oro, vidas, aumento_vida, tema, leyenda, torres_extra, torres, demoledora, textos, mapa, oleadas)."), "es: %s" % [es])
	Localization.set_language("en")
	var en: Array = LevelFile.parse(text, &"level_x")["errors"]
	assert_eq(en.size(), es.size(), "los mismos errores en ambos idiomas")
	assert_true(en.has("Unknown key \"nope\" (the ones used are: version, nombre, oro, vidas, aumento_vida, tema, leyenda, torres_extra, torres, demoledora, textos, mapa, oleadas)."), "en: %s" % [en])
	for message: String in en:
		assert_false(message.contains("Falta") or message.contains("tiene que"), "queda español: %s" % message)


func test_wave_and_group_locations_follow_the_language() -> void:
	var text: String = '{"version": 1, "nombre": "X", "oro": 100, "vidas": 10, "mapa": ["A..S", "...."], "oleadas": [[{"enemigo": "normal", "cantidad": 5, "cada": 1.0}], [{"enemigo": "normal"}]]}'
	assert_true(LevelFile.parse(text, &"level_x")["errors"].has("oleada 2, grupo 1: falta \"cantidad\"."))
	Localization.set_language("en")
	assert_true(LevelFile.parse(text, &"level_x")["errors"].has("wave 2, group 1: \"cantidad\" is missing."))


func test_map_grid_messages_in_both_languages() -> void:
	var empty: PackedStringArray = ["...."]
	var bare: PackedStringArray = []
	for y: int in MapGrid.MIN_HEIGHT:
		bare.append(MapGrid.GRASS.repeat(MapGrid.MIN_WIDTH))  # sin entrada ni salida
	assert_eq(MapGrid.where(Vector2i(6, 3)), "fila 4, columna 7")
	assert_true(MapGrid.parse(bare).errors.has("Falta la entrada A."))
	assert_true(MapGrid.parse(bare).errors.has("Falta la salida (S)."))
	Localization.set_language("en")
	assert_eq(MapGrid.where(Vector2i(6, 3)), "row 4, column 7")
	assert_true(MapGrid.parse(empty).errors.has("The map has 1 rows and it has to have between %d and %d." % [MapGrid.MIN_HEIGHT, MapGrid.MAX_HEIGHT]))
	var errors: PackedStringArray = MapGrid.parse(bare).errors
	assert_true(errors.has("Entrance A is missing."), "en: %s" % [errors])
	assert_true(errors.has("The exit (S) is missing."), "en: %s" % [errors])


func test_mode_pack_name_problems_in_both_languages() -> void:
	assert_eq(ModePacks.name_problem(MODES_DIR, ""), "Escribí un nombre.")
	assert_eq(ModePacks.name_problem(MODES_DIR, "x".repeat(ModePacks.MAX_NAME_LENGTH + 1)),
		"El nombre tiene %d letras y el máximo es %d." % [ModePacks.MAX_NAME_LENGTH + 1, ModePacks.MAX_NAME_LENGTH])
	Localization.set_language("en")
	assert_eq(ModePacks.name_problem(MODES_DIR, ""), "Write a name.")
	assert_eq(ModePacks.name_problem(MODES_DIR, "x".repeat(ModePacks.MAX_NAME_LENGTH + 1)),
		"The name has %d letters and the maximum is %d." % [ModePacks.MAX_NAME_LENGTH + 1, ModePacks.MAX_NAME_LENGTH])
	assert_eq(ModePacks.name_problem(MODES_DIR, "!!!"), "The name needs at least one letter or number.")


func test_level_texts_and_draft_messages_in_both_languages() -> void:
	var errors: PackedStringArray = []
	LevelTexts.parse({"lugar": ""}, errors)
	assert_eq(errors[0], "textos \"lugar\" está vacío: sacá la clave si no querés texto.")
	Localization.set_language("en")
	errors = []
	LevelTexts.parse({"lugar": ""}, errors)
	assert_eq(errors[0], "textos \"lugar\" is empty: remove the key if you do not want text.")
	var draft: LevelDraft = LevelDraft.new_level()
	assert_eq(draft.level_name(), "New level")
	draft.file_id = "Mal Nombre"
	assert_eq(draft.save(MODES_DIR), "The file name can only have lowercase letters, numbers and _.")
	Localization.set_language("es")
	assert_eq(LevelDraft.new_level().level_name(), LevelDraft.NEW_NAME)


func test_dev_panel_in_english() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	Localization.set_language("en")
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	var texts: Array[String] = []
	for node: Node in game.dev_panel.find_children("*", "", true, false):
		if node is Button:
			texts.append((node as Button).text)
		elif node is Label:
			texts.append((node as Label).text)
	for expected: String in ["Testing", "Resources", "+1000 gold", "+10 resources", "Finish demolition", "Enable banners", "Enable all collections",
			"Infinite lives  [F4]", "Match", "Skip wave  [F3]", "Kill all  [F2]", "Win", "Lose", "Simulation", "Speed  [F6 / F7]", "Show FPS", "Spawn"]:
		assert_true(texts.has(expected), "falta «%s» en el panel: %s" % [expected, texts])
	assert_eq(DevMode.banner_text(), "TEST MODE · F1: panel")
	Localization.set_language("es")
	assert_eq(DevMode.banner_text(), "MODO PRUEBAS · F1: panel")
