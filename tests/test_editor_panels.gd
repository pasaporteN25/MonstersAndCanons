# Tests de los paneles del editor de mapas: ajustes y oleadas (T103, spec §10.3: RF-214, RF-215).
# OJO: nunca se llama a leave() ni a nada que cambie de pantalla (reemplazaría la escena de GUT).
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const NORMAL_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"

var editor: MapEditor
var settings: SettingsPanel
var waves: WavesPanel


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	GameFlow.editor_draft = null
	editor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	settings = editor.settings_panel()
	waves = editor.waves_panel()


func after_each() -> void:
	GameFlow.editor_draft = null
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _press(panel: Node, button_name: String) -> void:
	(panel.find_child(button_name, true, false) as Button).pressed.emit()


func _select_enemy(row: Dictionary, id: String) -> void:
	var option: OptionButton = row["enemy"]
	for i: int in option.item_count:
		if option.get_item_metadata(i) == id:
			option.select(i)
			option.item_selected.emit(i)
			return
	fail_test("no hay un enemigo '%s' en la lista" % id)


# --- Abrir y cerrar los paneles ---

func test_panels_start_closed_and_the_buttons_open_them() -> void:
	assert_false(settings.visible)
	assert_false(waves.visible)
	(editor.get_node("%SettingsButton") as Button).button_pressed = true
	assert_true(settings.visible)
	(editor.get_node("%SettingsButton") as Button).button_pressed = false
	assert_false(settings.visible)


func test_only_one_panel_is_open_at_a_time() -> void:
	(editor.get_node("%SettingsButton") as Button).button_pressed = true
	(editor.get_node("%WavesButton") as Button).button_pressed = true
	assert_true(waves.visible)
	assert_false(settings.visible)
	assert_false((editor.get_node("%SettingsButton") as Button).button_pressed, "y su botón se suelta")


# --- Ajustes (RF-214) ---

func test_settings_show_the_draft() -> void:
	editor.show_panel(settings, true)
	assert_eq(settings.name_edit().text, LevelDraft.NEW_NAME)
	assert_eq(settings.gold_spin().value, 200.0)
	assert_eq(settings.lives_spin().value, 20.0)
	assert_eq(settings.scale_spin().value, 0.0)


func test_changing_the_numbers_changes_the_draft() -> void:
	editor.show_panel(settings, true)
	settings.gold_spin().value = 350.0
	settings.lives_spin().value = 15.0
	settings.scale_spin().value = 22.0
	assert_eq([editor.draft.gold(), editor.draft.lives(), editor.draft.health_scale()], [350, 15, 22])
	assert_true((editor.get_node("%Title") as Label).text.ends_with("*"), "quedó sin guardar")


func test_the_name_is_saved_when_you_finish_typing() -> void:
	editor.show_panel(settings, true)
	settings.name_edit().text = "Mi mapa"
	assert_eq(editor.draft.level_name(), LevelDraft.NEW_NAME, "escribir todavía no cambia el borrador")
	settings.name_edit().text_submitted.emit("Mi mapa")
	assert_eq(editor.draft.level_name(), "Mi mapa")
	assert_true((editor.get_node("%Title") as Label).text.contains("Mi mapa"))
	settings.name_edit().text = "Otro"
	settings.name_edit().focus_exited.emit()
	assert_eq(editor.draft.level_name(), "Otro", "también al salir del campo")


func test_typing_a_name_is_one_undo_step() -> void:
	editor.show_panel(settings, true)
	settings.name_edit().text = "Mi mapa"
	settings.name_edit().text_submitted.emit("Mi mapa")
	settings.name_edit().focus_exited.emit()  # ya estaba guardado: no cuenta otra vez
	editor.undo()
	assert_eq(editor.draft.level_name(), LevelDraft.NEW_NAME)
	assert_false(editor.draft.can_undo())


func test_undo_refreshes_the_open_panel() -> void:
	editor.show_panel(settings, true)
	settings.gold_spin().value = 999.0
	editor.undo()
	assert_eq(settings.gold_spin().value, 200.0)


func test_invalid_numbers_show_in_the_editor_message() -> void:
	editor.show_panel(settings, true)
	settings.scale_spin().value = 0.0  # 0 = el general: válido
	assert_eq(editor.message_kind(), &"ok")
	settings.name_edit().text = " "
	settings.name_edit().text_submitted.emit(" ")
	assert_eq(editor.message_kind(), &"error", "un nombre vacío no es válido")
	assert_true(editor.message_text().contains("nombre"), editor.message_text())


# --- Oleadas: la lista (RF-215) ---

func test_the_panel_shows_the_first_wave() -> void:
	editor.show_panel(waves, true)
	assert_eq(waves.current_wave(), 0)
	assert_eq(waves.row_count(), 1)
	assert_eq(waves.total_text(), "Enemigos en esta oleada: 10")
	var row: Dictionary = waves.row(0)
	assert_eq((row["count"] as SpinBox).value, 10.0)
	assert_almost_eq((row["every"] as SpinBox).value, 0.8, 0.001)
	assert_eq((row["from"] as SpinBox).value, 0.0)
	assert_eq((row["entrance"] as OptionButton).get_item_text((row["entrance"] as OptionButton).selected), "A")
	var enemy: OptionButton = row["enemy"]
	assert_eq(enemy.get_item_metadata(enemy.selected), "normal")


func test_every_enemy_of_the_game_can_be_chosen() -> void:
	editor.show_panel(waves, true)
	var enemy: OptionButton = waves.row(0)["enemy"]
	var ids: PackedStringArray = []
	for i: int in enemy.item_count:
		ids.append(enemy.get_item_metadata(i))
	ids.sort()
	assert_eq(ids, LevelFile.enemy_ids())
	assert_true(ids.has("troll") and ids.has("spider") and ids.has("spiderling") and ids.has("boss"))


func test_an_unknown_enemy_is_shown_as_it_is() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.data["oleadas"][0][0]["enemigo"] = "trol"
	GameFlow.editor_draft = draft
	var other: MapEditor = EDITOR_SCENE.instantiate()
	add_child_autofree(other)
	other.show_panel(other.waves_panel(), true)
	var option: OptionButton = other.waves_panel().row(0)["enemy"]
	assert_eq(option.get_item_text(option.selected), "trol (no existe)")
	assert_true(other.message_text().contains("no existe el enemigo 'trol'"), other.message_text())


# --- Oleadas: editar los grupos ---

func test_editing_a_group_changes_the_draft() -> void:
	editor.show_panel(waves, true)
	var row: Dictionary = waves.row(0)
	_select_enemy(row, "troll")
	(row["count"] as SpinBox).value = 4.0
	(row["every"] as SpinBox).value = 1.5
	(row["from"] as SpinBox).value = 2.0
	assert_eq(editor.draft.group(0, 0), {"enemigo": "troll", "cantidad": 4, "cada": 1.5, "desde": 2.0, "entrada": "A"})
	assert_eq(waves.total_text(), "Enemigos en esta oleada: 4")


func test_editing_a_number_does_not_rebuild_the_row() -> void:
	# Si la fila se rehiciera, el campo perdería el foco y no se podría seguir con Tab.
	editor.show_panel(waves, true)
	var count: SpinBox = waves.row(0)["count"]
	count.value = 7.0
	assert_same(waves.row(0)["count"], count)


func test_entrance_choices_follow_the_map() -> void:
	editor.show_panel(waves, true)
	assert_eq((waves.row(0)["entrance"] as OptionButton).item_count, 1, "el mapa nuevo tiene una sola entrada")
	editor.set_tool(LevelDraft.Tool.ENTRANCE)
	editor.paint_at(Vector2i(5, 3))  # pegada al camino: la B
	assert_eq((waves.row(0)["entrance"] as OptionButton).item_count, 2, "el panel abierto se actualiza")
	var entrance: OptionButton = waves.row(0)["entrance"]
	entrance.select(1)
	entrance.item_selected.emit(1)
	assert_eq(editor.draft.group(0, 0)["entrada"], "B")


func test_add_and_remove_groups() -> void:
	editor.show_panel(waves, true)
	_press(waves, "AddGroup")
	assert_eq(waves.row_count(), 2)
	assert_eq(waves.total_text(), "Enemigos en esta oleada: 20")
	(waves.row(1)["remove"] as Button).pressed.emit()
	assert_eq(waves.row_count(), 1)
	assert_eq(editor.draft.group_count(0), 1)


func test_a_wave_without_groups_is_an_error() -> void:
	editor.show_panel(waves, true)
	(waves.row(0)["remove"] as Button).pressed.emit()
	assert_eq(editor.message_kind(), &"error")
	assert_true(editor.message_text().contains("oleada 1"), editor.message_text())


func test_a_zero_count_shows_the_error() -> void:
	editor.show_panel(waves, true)
	(waves.row(0)["count"] as SpinBox).value = 0.0
	assert_eq(editor.message_kind(), &"error")
	assert_true(editor.message_text().contains("cantidad"), editor.message_text())


# --- Oleadas: moverse y agregar ---

func test_add_copy_and_remove_waves() -> void:
	editor.show_panel(waves, true)
	_press(waves, "AddWave")
	assert_eq(editor.draft.wave_count(), 2)
	assert_eq(waves.current_wave(), 1, "se pasa a la oleada nueva")
	(waves.row(0)["count"] as SpinBox).value = 3.0
	_press(waves, "CopyWave")
	assert_eq(editor.draft.wave_count(), 3)
	assert_eq(waves.current_wave(), 2)
	assert_eq(editor.draft.group(2, 0)["cantidad"], 3, "la copia trae lo mismo")
	_press(waves, "RemoveWave")
	assert_eq(editor.draft.wave_count(), 2)
	assert_eq(waves.current_wave(), 1)


func test_prev_and_next_move_between_waves() -> void:
	editor.show_panel(waves, true)
	_press(waves, "AddWave")
	var prev: Button = waves.find_child("Prev", true, false)
	var next: Button = waves.find_child("Next", true, false)
	assert_false(prev.disabled)
	assert_true(next.disabled, "es la última")
	_press(waves, "Prev")
	assert_eq(waves.current_wave(), 0)
	assert_true(prev.disabled)
	assert_false(next.disabled)
	_press(waves, "Next")
	assert_eq(waves.current_wave(), 1)


func test_the_last_wave_cannot_be_removed() -> void:
	editor.show_panel(waves, true)
	assert_true((waves.find_child("RemoveWave", true, false) as Button).disabled)
	_press(waves, "RemoveWave")
	assert_eq(editor.draft.wave_count(), 1)


func test_undo_refreshes_the_waves_panel() -> void:
	editor.show_panel(waves, true)
	(waves.row(0)["count"] as SpinBox).value = 25.0
	editor.undo()
	assert_eq((waves.row(0)["count"] as SpinBox).value, 10.0)
	assert_eq(waves.total_text(), "Enemigos en esta oleada: 10")
	_press(waves, "AddWave")
	editor.undo()
	assert_eq(waves.current_wave(), 0, "la oleada que ya no existe se acomoda")
	assert_eq(waves.row_count(), 1)


func test_a_full_level_built_in_the_panels_is_valid() -> void:
	editor.show_panel(waves, true)
	_press(waves, "AddWave")
	_select_enemy(waves.row(0), "troll")
	(waves.row(0)["count"] as SpinBox).value = 6.0
	_press(waves, "AddGroup")
	_select_enemy(waves.row(1), "flyer")
	(waves.row(1)["from"] as SpinBox).value = 3.0
	assert_eq(editor.message_kind(), &"ok", editor.message_text())
	var level: LevelData = editor.draft.check()["level"]
	assert_eq(level.waves.size(), 2)
	assert_eq(level.waves[1].groups[1].enemy, LevelFile.find_enemy("flyer"))
	assert_almost_eq(level.waves[1].groups[1].start_delay, 3.0, 0.001)
