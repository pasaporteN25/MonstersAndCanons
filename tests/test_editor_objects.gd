# Tests del editor con los sistemas de M50 (T212, RF-434 y RF-435): pinceles de removibles y extracción, valores
# por letra, hallazgo solo en la campaña, demoledora y torres del mapa. La mayor parte es LevelDraft (lógica pura);
# al final, lo que se conecta en la pantalla del editor.
# OJO: nunca se llama a leave() ni a nada que cambie de pantalla (reemplazaría la escena de GUT).
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const NORMAL_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"
const TEST_DIR: String = "user://test_editor_objects/"

var draft: LevelDraft
var editor: MapEditor
var _towers: Array[TowerData] = []


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	GameFlow.editor_draft = null
	draft = LevelDraft.new_level()


func after_each() -> void:
	GameFlow.editor_draft = null
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _paint(tool: LevelDraft.Tool, cell: Vector2i) -> bool:
	return draft.apply_tool(tool, cell)


## Una casilla de pasto con otra de pasto a la derecha (no se pisa el camino de un nivel oficial).
func _grass_cell(of: LevelDraft) -> Vector2i:
	for y: int in of.map_height():
		for x: int in of.map_width() - 1:
			if of.letter_at(Vector2i(x, y)) == "." and of.letter_at(Vector2i(x + 1, y)) == ".":
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _canonical_towers() -> Array[TowerData]:
	if _towers.is_empty():
		_towers = TowerOffer.canonical_towers()
	return _towers


## El texto de un archivo tal como lo lee el juego, para comparar sin depender de espacios ni del orden de las claves.
func _normalized(text: String) -> String:
	var json := JSON.new()
	assert_eq(json.parse(text), OK, "es un JSON")
	return JSON.stringify(json.data, "", true)


# --- Pinceles (RF-434) ---

func test_each_brush_creates_its_letter_and_the_level_reads_it() -> void:
	var cases: Array = [
		[LevelDraft.Tool.TREE, "t", "removible", "arbol"], [LevelDraft.Tool.ROCK, "r", "removible", "roca"],
		[LevelDraft.Tool.RUBBLE, "u", "removible", "escombro"], [LevelDraft.Tool.MINE, "m", "extraccion", "mina"],
		[LevelDraft.Tool.FOREST, "b", "extraccion", "bosque_explotable"],
	]
	for i: int in cases.size():
		var cell := Vector2i(1 + i, 1)
		assert_true(_paint(cases[i][0], cell), cases[i][3])
		assert_eq(draft.letter_at(cell), cases[i][1])
		assert_eq(draft.obstacle_category(cases[i][1]), cases[i][2])
		assert_eq(draft.obstacle_class(cases[i][1]), cases[i][3])
	var result: Dictionary = draft.check()
	assert_not_null(result["level"], str(result["errors"]))
	assert_eq((result["level"] as LevelData).obstacles.size(), 5)
	assert_eq(draft.obstacle_letters().size(), 5)
	assert_eq(JSON.stringify(draft.data["leyenda"]["t"]), '{"removible":{"clase":"arbol"}}', "sin sobrescrituras")


func test_painting_again_reuses_the_same_letter() -> void:
	_paint(LevelDraft.Tool.TREE, Vector2i(2, 1))
	_paint(LevelDraft.Tool.TREE, Vector2i(5, 2))
	_paint(LevelDraft.Tool.TREE, Vector2i(6, 6))
	assert_eq((draft.data["leyenda"] as Dictionary).size(), 1, "una sola letra para los tres árboles")
	assert_false(_paint(LevelDraft.Tool.TREE, Vector2i(6, 6)), "pintar lo mismo no cambia nada")
	assert_eq(draft.check()["level"].obstacles.size(), 3)


func test_a_letter_with_overrides_is_not_reused() -> void:
	_paint(LevelDraft.Tool.ROCK, Vector2i(2, 1))
	assert_true(draft.set_obstacle_value("r", "costo", 50.0))
	_paint(LevelDraft.Tool.ROCK, Vector2i(4, 1))
	assert_eq(draft.letter_at(Vector2i(4, 1)), "a", "la 'r' ya no es una roca común: se crea otra letra")
	assert_false(draft.obstacle_overrides("a", "costo"))
	assert_eq(draft.obstacle_letters().size(), 2)


func test_a_preferred_letter_taken_by_something_else_falls_back_to_a_free_one() -> void:
	draft.data["leyenda"] = {"t": {"dibujo": "helecho"}}
	_paint(LevelDraft.Tool.TREE, Vector2i(2, 1))
	assert_eq(draft.letter_at(Vector2i(2, 1)), "a")
	assert_eq(draft.data["leyenda"]["t"], {"dibujo": "helecho"}, "la letra ajena no se toca")


func test_erasing_the_last_cell_forgets_the_letter_but_not_while_others_remain() -> void:
	_paint(LevelDraft.Tool.TREE, Vector2i(2, 1))
	_paint(LevelDraft.Tool.TREE, Vector2i(3, 1))
	assert_true(_paint(LevelDraft.Tool.GRASS, Vector2i(2, 1)))
	assert_true(draft.obstacle_letters().has("t"), "queda otro árbol")
	assert_true(_paint(LevelDraft.Tool.GRASS, Vector2i(3, 1)))
	assert_false(draft.data.has("leyenda"), "sin objetos, la leyenda desaparece (no queda una letra sin usar)")
	assert_true(draft.check()["warnings"].is_empty())
	assert_true(draft.undo())
	assert_eq(draft.letter_at(Vector2i(3, 1)), "t", "deshacer devuelve el árbol y su letra")
	assert_true(draft.obstacle_letters().has("t"))


func test_erasing_never_touches_letters_the_file_already_had() -> void:
	draft.data["leyenda"] = {"p": {"dibujo": "helecho"}, "z": {"removible": {"clase": "arbol"}}}
	_paint(LevelDraft.Tool.PATH, Vector2i(3, 1))
	_paint(LevelDraft.Tool.GRASS, Vector2i(3, 1))
	assert_eq(draft.data["leyenda"].size(), 2, "una letra de la leyenda sin usar que ya estaba en el archivo se conserva")


func test_painting_an_object_over_the_entrance_removes_it_like_the_other_tools() -> void:
	var entrance: Vector2i = Vector2i(0, 4)
	assert_eq(draft.letter_at(entrance), "A")
	assert_true(_paint(LevelDraft.Tool.MINE, entrance))
	assert_eq(draft.entrance_count(), 0)
	assert_eq(draft.letter_at(entrance), "m")


func test_a_stroke_of_objects_is_one_undo_step() -> void:
	draft.begin_stroke()
	for x: int in range(2, 6):
		_paint(LevelDraft.Tool.ROCK, Vector2i(x, 1))
	draft.end_stroke()
	assert_true(draft.undo())
	assert_false(draft.data.has("leyenda"))
	assert_eq(draft.letter_at(Vector2i(2, 1)), ".")
	assert_false(draft.can_undo())


# --- El límite de letras (RF-262) ---

func _fill_legend_with_decor(count: int) -> void:
	var legend: Dictionary = {}
	for letter: String in "pfgwk~+-=*".left(count):
		legend[letter] = {"dibujo": "helecho"}
	draft.data["leyenda"] = legend


func test_the_tenth_letter_still_fits_and_the_eleventh_warns_without_painting() -> void:
	_fill_legend_with_decor(9)
	assert_true(_paint(LevelDraft.Tool.TREE, Vector2i(2, 1)), "la décima entra")
	assert_eq(draft.last_problem, "")
	assert_eq((draft.data["leyenda"] as Dictionary).size(), LevelFile.MAX_LEGEND)
	var rows_before: PackedStringArray = draft.rows()
	assert_false(_paint(LevelDraft.Tool.ROCK, Vector2i(3, 1)), "la undécima no")
	assert_true(draft.last_problem.contains("10"), draft.last_problem)
	assert_eq(draft.rows(), rows_before, "no pinta")
	assert_eq((draft.data["leyenda"] as Dictionary).size(), LevelFile.MAX_LEGEND)
	assert_true(_paint(LevelDraft.Tool.TREE, Vector2i(3, 1)), "reusar una letra existente no suma")
	assert_eq(draft.last_problem, "", "el aviso se limpia con la herramienta siguiente")
	assert_true(draft.check()["errors"].is_empty())


func test_a_refused_brush_does_not_leave_an_undo_step() -> void:
	_fill_legend_with_decor(10)
	draft.dirty = false
	assert_false(_paint(LevelDraft.Tool.MINE, Vector2i(3, 1)))
	assert_false(draft.can_undo())
	assert_false(draft.dirty)


func test_painting_over_the_last_cell_of_another_object_frees_its_slot() -> void:
	_fill_legend_with_decor(9)
	_paint(LevelDraft.Tool.TREE, Vector2i(2, 1))  # llena las 10
	assert_true(_paint(LevelDraft.Tool.ROCK, Vector2i(2, 1)), "la roca ocupa el lugar que deja el árbol")
	assert_eq((draft.data["leyenda"] as Dictionary).size(), LevelFile.MAX_LEGEND)
	assert_false(draft.obstacle_letters().has("t"))


# --- Valores por letra (RF-434) ---

func test_a_value_override_applies_to_every_cell_with_the_letter() -> void:
	_paint(LevelDraft.Tool.TREE, Vector2i(2, 1))
	_paint(LevelDraft.Tool.TREE, Vector2i(8, 6))
	assert_eq(draft.obstacle_value("t", "costo"), 40.0, "sin sobrescribir sale de la clase")
	assert_eq(draft.obstacle_default("t", "costo"), 40.0)
	assert_true(draft.set_obstacle_value("t", "costo", 75.0))
	assert_true(draft.set_obstacle_value("t", "tiempo", 2.5))
	assert_true(draft.set_obstacle_value("t", "probabilidad", 100.0))
	var level: LevelData = draft.check()["level"]
	for obstacle: ObstacleSpec in level.obstacles:
		assert_eq(obstacle.cost, 75)
		assert_eq(obstacle.seconds, 2.5)
		assert_eq(obstacle.chance_percent, 100)
		assert_eq(obstacle.reward_amount, 1, "lo que no se toca sale de la clase")


func test_setting_the_class_value_again_removes_the_override() -> void:
	_paint(LevelDraft.Tool.ROCK, Vector2i(2, 1))
	draft.set_obstacle_value("r", "costo", 99.0)
	assert_true(draft.obstacle_overrides("r", "costo"))
	assert_true(draft.set_obstacle_value("r", "costo", 60.0), "60 es el costo de la roca")
	assert_false(draft.obstacle_overrides("r", "costo"))
	assert_false(draft.set_obstacle_value("r", "costo", 60.0), "ya estaba así")
	assert_eq(JSON.stringify(draft.data["leyenda"]["r"]), '{"removible":{"clase":"roca"}}')


func test_override_values_are_kept_inside_what_the_level_file_accepts() -> void:
	_paint(LevelDraft.Tool.ROCK, Vector2i(2, 1))
	draft.set_obstacle_value("r", "costo", 0.0)
	assert_eq(draft.obstacle_value("r", "costo"), 1.0, "el costo no puede ser cero")
	draft.set_obstacle_value("r", "probabilidad", 250.0)
	assert_eq(draft.obstacle_value("r", "probabilidad"), 100.0)
	draft.set_obstacle_value("r", "tiempo", -3.0)
	assert_eq(draft.obstacle_value("r", "tiempo"), 0.1)
	draft.set_obstacle_value("r", "recursos", -5.0)
	assert_eq(draft.obstacle_value("r", "recursos"), 0.0)
	assert_not_null(draft.check()["level"], str(draft.check()["errors"]))


func test_extraction_has_its_own_fields_and_removibles_do_not_take_them() -> void:
	_paint(LevelDraft.Tool.MINE, Vector2i(2, 1))
	_paint(LevelDraft.Tool.TREE, Vector2i(5, 1))
	assert_eq(draft.obstacle_fields("m"), LevelDraft.EXTRACTION_FIELDS)
	assert_true(draft.set_obstacle_value("m", "reserva", 6.0))
	assert_true(draft.set_obstacle_value("m", "produccion", 3.0))
	assert_false(draft.set_obstacle_value("m", "probabilidad", 10.0), "una mina no tiene probabilidad")
	assert_false(draft.set_obstacle_value("t", "reserva", 10.0), "un árbol no tiene reserva")
	assert_false(draft.set_obstacle_value("q", "costo", 10.0), "una letra que no es un objeto")
	var mine: ObstacleSpec = (draft.check()["level"] as LevelData).obstacles.filter(
		func(o: ObstacleSpec) -> bool: return o.kind == ObstacleSpec.Kind.EXTRACTION)[0]
	assert_eq(mine.reserve, 6)
	assert_eq(mine.production, 3)


# --- El hallazgo solo en la campaña (RF-435, Q-31) ---

func test_the_finding_is_disabled_in_a_new_map() -> void:
	_paint(LevelDraft.Tool.RUBBLE, Vector2i(2, 1))
	assert_false(draft.is_campaign())
	assert_false(draft.can_edit_finding("u"))
	assert_false(draft.set_finding("u", "disruptor"))
	assert_eq(draft.finding("u"), "")


func test_the_finding_can_be_edited_while_the_draft_is_a_campaign_level() -> void:
	draft = LevelDraft.open_official("level_06")
	assert_true(draft.is_campaign())
	var spot: Vector2i = _grass_cell(draft)
	_paint(LevelDraft.Tool.RUBBLE, spot)
	_paint(LevelDraft.Tool.TREE, spot + Vector2i(1, 0))
	assert_true(draft.can_edit_finding("u"))
	assert_false(draft.can_edit_finding("t"), "solo las ruinas llevan hallazgo")
	assert_true(draft.set_finding("u", "disruptor"))
	assert_eq(draft.finding("u"), "disruptor")
	assert_not_null(draft.check()["level"], str(draft.check()["errors"]))
	assert_true(draft.set_finding("u", ""), "se puede quitar")
	assert_false(draft.data["leyenda"]["u"]["removible"].has("hallazgo"))


func test_a_finding_already_in_the_file_is_kept_even_when_it_cannot_be_edited() -> void:
	var text: String = '{"version": 1, "nombre": "Ruinas", "oro": 100, "vidas": 10, ' \
		+ '"leyenda": {"u": {"removible": {"clase": "escombro", "hallazgo": "disruptor"}}}, ' \
		+ '"mapa": ["....................", "....................", "....................", "....................", "A##################S", "..u.................", "....................", "....................", "...................."], ' \
		+ '"oleadas": [[{"enemigo": "normal", "cantidad": 1, "cada": 1.0}]]}'
	draft = LevelDraft.from_text(text, "mapa_ruinas")
	assert_false(draft.is_campaign(), "un mapa suelto no es de la campaña")
	assert_false(draft.can_edit_finding("u"))
	assert_eq(draft.finding("u"), "disruptor")
	assert_false(draft.set_finding("u", ""), "no se puede cambiar")
	assert_eq(_normalized(draft.to_text()), _normalized(text), "al guardar se conserva")


func test_saving_a_campaign_template_as_a_community_map_closes_the_finding() -> void:
	draft = LevelDraft.open_official("level_06")
	_paint(LevelDraft.Tool.RUBBLE, Vector2i(2, 1))
	draft.set_finding("u", "disruptor")
	draft.file_id = "mi_mapa_de_ruinas"  # lo que hace "Guardar" al aceptar el nombre
	assert_false(draft.is_campaign())
	assert_false(draft.can_edit_finding("u"))
	assert_eq(draft.finding("u"), "disruptor", "el hallazgo escrito se conserva")
	assert_true(draft.to_text().contains("disruptor"))


func test_the_editor_never_writes_into_data() -> void:
	draft = LevelDraft.open_official("level_06")
	assert_eq(draft.file_id, "", "el oficial no queda ligado: guardar pide otro nombre")
	assert_ne(draft.save(TEST_DIR), "", "sin nombre de archivo no guarda")
	assert_false(DirAccess.dir_exists_absolute(TEST_DIR), "y no crea carpetas")


# --- Demoledora (RF-411, RF-434) ---

func test_the_machine_flag_turns_on_and_off() -> void:
	assert_false(draft.machine_enabled())
	assert_true(draft.set_machine_enabled(true))
	assert_true(draft.machine_enabled())
	assert_false(draft.set_machine_enabled(true), "ya estaba")
	assert_true(draft.to_text().contains('"demoledora": true'))
	assert_true(draft.set_machine_enabled(false))
	assert_false(draft.data.has("demoledora"), "apagada vale lo mismo que no escribirla")
	assert_true(draft.undo())
	assert_true(draft.machine_enabled())


func test_an_explicit_false_or_odd_machine_value_is_kept_on_save() -> void:
	var text: String = draft.to_text().replace('"vidas": 20,', '"vidas": 20,\n  "demoledora": false,')
	var reopened: LevelDraft = LevelDraft.from_text(text)
	assert_false(reopened.machine_enabled())
	assert_true(reopened.to_text().contains('"demoledora": false'))


# --- Torres del mapa (RF-393, RF-394, RF-434) ---

func test_without_a_list_the_map_offers_the_usual_towers() -> void:
	var offered: PackedStringArray = draft.offered_tower_ids(_canonical_towers())
	assert_false(draft.has_tower_list())
	for tower: TowerData in _canonical_towers():
		assert_eq(offered.has(String(tower.id)), not tower.reserved, tower.display_name)
	draft.data["torres_extra"] = ["mortar"]
	assert_true(draft.offered_tower_ids(_canonical_towers()).has("mortar"), "torres_extra la habilita")


func test_unchecking_a_tower_writes_the_full_list_in_canonical_order() -> void:
	var before: PackedStringArray = draft.offered_tower_ids(_canonical_towers())
	assert_true(draft.set_tower_offered("frost", false, _canonical_towers()))
	assert_true(draft.has_tower_list())
	var after: PackedStringArray = draft.offered_tower_ids(_canonical_towers())
	assert_eq(after.size(), before.size() - 1)
	assert_false(after.has("frost"))
	assert_eq(Array(after), (draft.data["torres"] as Array), "se guarda en el orden canónico")
	assert_true(draft.set_tower_offered("mortar", true, _canonical_towers()))
	assert_true(draft.offered_tower_ids(_canonical_towers()).has("mortar"))
	assert_not_null(draft.check()["level"], str(draft.check()["errors"]))


func test_the_last_tower_cannot_be_unchecked() -> void:
	draft.data["torres"] = ["cannon"]
	assert_false(draft.set_tower_offered("cannon", false, _canonical_towers()), "RF-394: la lista no puede quedar vacía")
	assert_eq(draft.data["torres"], ["cannon"])
	assert_false(draft.set_tower_offered("cannon", true, _canonical_towers()), "ya estaba marcada")
	assert_false(draft.can_undo())


func test_back_to_the_usual_towers_erases_the_field() -> void:
	assert_false(draft.use_default_towers(), "no había lista")
	draft.set_tower_offered("frost", false, _canonical_towers())
	assert_true(draft.use_default_towers())
	assert_false(draft.data.has("torres"))
	assert_true(draft.undo())
	assert_true(draft.has_tower_list())


func test_a_tower_id_the_game_does_not_know_survives_editing_the_list() -> void:
	draft.data["torres"] = ["cannon", "hielo"]
	assert_true(draft.set_tower_offered("frost", true, _canonical_towers()))
	assert_true((draft.data["torres"] as Array).has("hielo"), "se conserva para que check() la marque")
	assert_false(draft.check()["errors"].is_empty())


# --- Ida y vuelta (RF-434) ---

func test_every_example_map_and_official_level_reads_back_the_same() -> void:
	var paths: Array[String] = []
	for dir: String in ["res://tools/ejemplos/", LevelFile.LEVELS_DIR]:
		for file: String in DirAccess.get_files_at(dir):
			if file.ends_with(".json"):
				paths.append(dir + file)
	assert_gt(paths.size(), 15)
	for path: String in paths:
		var original: String = FileAccess.get_file_as_string(path)
		var opened: LevelDraft = LevelDraft.from_text(original, path.get_file().get_basename())
		assert_not_null(opened, path)
		assert_eq(_normalized(opened.to_text()), _normalized(original), "%s: ida y vuelta" % path)
		var result: Dictionary = opened.check()
		var direct: Dictionary = LevelFile.parse(original, &"x")
		assert_eq(result["errors"], direct["errors"], path)
		assert_eq(result["warnings"], direct["warnings"], path)


func test_the_t206_t210_example_map_can_be_rebuilt_in_the_editor() -> void:
	# tools/ejemplos/mapa_removibles.json, armado solo con pinceles, valores y ajustes.
	var original: String = FileAccess.get_file_as_string("res://tools/ejemplos/mapa_removibles.json")
	draft.set_level_name("Mapa con removibles")
	draft.set_gold(200)
	draft.set_machine_enabled(true)
	_paint(LevelDraft.Tool.TREE, Vector2i(4, 1))
	_paint(LevelDraft.Tool.ROCK, Vector2i(11, 3))
	_paint(LevelDraft.Tool.RUBBLE, Vector2i(15, 6))
	_paint(LevelDraft.Tool.MINE, Vector2i(3, 7))
	draft.set_obstacle_value("r", "costo", 50.0)
	draft.set_obstacle_value("r", "probabilidad", 0.0)
	draft.set_obstacle_value("m", "reserva", 6.0)
	draft.set_group(0, 0, "cantidad", 2)
	draft.set_group(0, 0, "cada", 1.0)
	assert_eq(_normalized(draft.to_text()), _normalized(original), "queda igual al JSON del ejemplo")
	# Y el archivo que se guarda se vuelve a abrir igual.
	draft.file_id = "ejemplo_rearmado"
	assert_eq(draft.save(TEST_DIR), "")
	var reopened: LevelDraft = LevelDraft.open_saved("ejemplo_rearmado", TEST_DIR)
	assert_eq(reopened.to_text(), draft.to_text())


# --- En la pantalla del editor ---

func _open() -> MapEditor:
	editor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	editor.test_requested.disconnect(GameFlow.play_test)  # "Probar" cambiaría de escena y cortaría la corrida
	return editor


func _click(target: MapEditor, cell: Vector2i, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var area: Control = target.get_node("%MapArea")
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = pressed
		event.position = Vector2(cell) * 64.0 + Vector2(32, 32)
		area.gui_input.emit(event)


func test_the_object_brushes_have_buttons_and_keys() -> void:
	_open()
	var tools_row: HBoxContainer = editor.get_node("%Tools")
	var texts: PackedStringArray = []
	for child: Node in tools_row.get_children():
		if child is Button and (child as Button).toggle_mode:
			texts.append((child as Button).text)
	assert_eq(texts.size(), 10)
	assert_true("Árbol (6)" in texts and "Bosque (0)" in texts, str(texts))
	var key := InputEventKey.new()
	key.keycode = KEY_8
	key.pressed = true
	editor._unhandled_input(key)
	assert_eq(editor.tool, LevelDraft.Tool.RUBBLE)
	_click(editor, Vector2i(3, 2))
	assert_eq(editor.draft.letter_at(Vector2i(3, 2)), "u")
	assert_eq(editor.message_kind(), &"ok", editor.message_text())


func test_hitting_the_legend_limit_says_so_in_the_messages_line() -> void:
	_open()
	var legend: Dictionary = {}
	for letter: String in "pfgwk~+-=*":
		legend[letter] = {"dibujo": "helecho"}
	editor.draft.data["leyenda"] = legend
	editor.refresh()
	editor.set_tool(LevelDraft.Tool.MINE)
	_click(editor, Vector2i(3, 2))
	assert_eq(editor.draft.letter_at(Vector2i(3, 2)), ".", "no pinta")
	assert_true(editor.message_text().contains("⚠ La leyenda ya tiene 10 letras"), editor.message_text())
	editor.set_tool(LevelDraft.Tool.GRASS)  # el aviso es de cada intento: con otro pincel desaparece
	_click(editor, Vector2i(4, 2))
	assert_false(editor.message_text().contains("La leyenda ya tiene"), editor.message_text())


func test_try_play_a_map_with_objects_hands_the_level_with_them() -> void:
	_open()
	watch_signals(editor)
	editor.set_tool(LevelDraft.Tool.TREE)
	_click(editor, Vector2i(3, 2))
	editor.settings_panel().machine_check().button_pressed = true
	editor.try_level()
	assert_signal_emitted(editor, "test_requested", editor.message_text())
	var level: LevelData = get_signal_parameters(editor, "test_requested")[0]
	assert_eq(level.obstacles.size(), 1)
	assert_true(level.machine_enabled)


func test_objects_panel_edits_the_values_of_the_selected_letter() -> void:
	_open()
	var panel: ObjectsPanel = editor.objects_panel()
	editor.set_tool(LevelDraft.Tool.ROCK)
	_click(editor, Vector2i(3, 2))
	(editor.get_node("%ObjectsButton") as Button).button_pressed = true
	assert_true(panel.visible)
	assert_eq(panel.selected_letter(), "r")
	assert_eq(panel.spin_for("costo").value, 60.0, "muestra el de la clase")
	assert_true(panel.field_label("costo").text.contains("60"))
	assert_false(panel.spin_for("reserva").visible, "una roca no tiene reserva")
	panel.spin_for("costo").value = 80.0
	assert_eq(editor.draft.obstacle_value("r", "costo"), 80.0)
	assert_true(editor.draft.dirty)
	assert_eq(editor.message_kind(), &"ok", editor.message_text())
	editor.undo()
	assert_eq(panel.spin_for("costo").value, 60.0, "deshacer vuelve a llenar el panel")


func test_objects_panel_without_objects_explains_what_to_do() -> void:
	_open()
	(editor.get_node("%ObjectsButton") as Button).button_pressed = true
	assert_false(editor.objects_panel().letter_option().visible)
	assert_eq(editor.objects_panel().selected_letter(), "")


func test_finding_field_is_locked_with_its_explanation_outside_the_campaign() -> void:
	_open()
	var panel: ObjectsPanel = editor.objects_panel()
	editor.set_tool(LevelDraft.Tool.RUBBLE)
	_click(editor, Vector2i(3, 2))
	panel.refresh()
	assert_true(panel.finding_option().get_parent().visible)
	assert_true(panel.finding_option().disabled)
	assert_true(panel.finding_note().visible)
	assert_eq(panel.finding_note().text, "Las piezas de colección solo se consiguen en la campaña")


func test_finding_field_works_in_a_campaign_level_opened_as_template() -> void:
	_open()
	editor._use_draft(LevelDraft.open_official("level_06"), "Abierto")
	var panel: ObjectsPanel = editor.objects_panel()
	editor.set_tool(LevelDraft.Tool.RUBBLE)
	_click(editor, _grass_cell(editor.draft))
	panel.select_letter("u")
	assert_false(panel.finding_option().disabled)
	assert_false(panel.finding_note().visible)
	var option: OptionButton = panel.finding_option()
	option.select(option.item_count - 1)
	option.item_selected.emit(option.item_count - 1)
	assert_eq(editor.draft.finding("u"), str(option.get_item_metadata(option.item_count - 1)))
	assert_ne(editor.draft.finding("u"), "")


func test_settings_panel_demolisher_and_towers() -> void:
	_open()
	var settings: SettingsPanel = editor.settings_panel()
	settings.machine_check().button_pressed = true
	assert_true(editor.draft.machine_enabled())
	settings.tower_check("frost").button_pressed = false
	assert_true(editor.draft.has_tower_list())
	assert_false(editor.draft.offered_tower_ids(_canonical_towers()).has("frost"))
	assert_false(settings.default_towers_button().disabled)
	settings.default_towers_button().pressed.emit()
	assert_false(editor.draft.has_tower_list())
	assert_true(settings.tower_check("frost").button_pressed, "vuelve a estar marcada")
	assert_true(settings.default_towers_button().disabled)


func test_the_last_tower_checkbox_snaps_back() -> void:
	_open()
	var settings: SettingsPanel = editor.settings_panel()
	editor.draft.data["torres"] = ["cannon"]
	settings.refresh()
	settings.tower_check("cannon").button_pressed = false
	assert_eq(editor.draft.data["torres"], ["cannon"])
	assert_true(settings.tower_check("cannon").button_pressed, "la casilla vuelve a marcarse")
