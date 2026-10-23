# Tests de nuevo, abrir, guardar, probar y salir del editor de mapas (T104, spec §10.3: RF-216 a RF-218).
# El editor guarda en una carpeta de pruebas (nunca en el user://maps/ de verdad) y sus señales de
# cambio de pantalla se desconectan de GameFlow: reemplazarían la escena de GUT.
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const TEST_DIR: String = "user://test_editor_maps/"
const NORMAL_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"

var editor: MapEditor
var dialog: EditorDialog


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	GameFlow.editor_draft = null
	_clean_dir()
	editor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	editor.maps_dir = TEST_DIR
	editor.modes_dir = "user://test_editor_files_modes/"  # nunca los modos del jugador (RF-392)
	editor.left.disconnect(GameFlow.go_to_tools)
	editor.test_requested.disconnect(GameFlow.play_test)
	dialog = editor.dialog()
	watch_signals(editor)


func after_each() -> void:
	GameFlow.editor_draft = null
	_clean_dir()
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _clean_dir() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)


func _accept() -> void:
	dialog.ok_button().pressed.emit()


func _choose(text_start: String) -> void:
	var list: ItemList = dialog.list()
	for i: int in list.item_count:
		if list.get_item_text(i).begins_with(text_start):
			list.select(i)
			list.item_selected.emit(i)
			return
	fail_test("no hay un elemento que empiece con '%s'" % text_start)


func _type_name(text: String) -> void:
	dialog.field().text = text
	dialog.field().text_changed.emit(text)


func _make_dirty() -> void:
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	editor.paint_at(Vector2i(3, 1))


func _save_as(id: String) -> void:
	editor.save_level()
	_type_name(id)
	_accept()


# --- Guardar (RF-216) ---

func test_saving_a_new_level_asks_for_a_file_name() -> void:
	editor.save_level()
	assert_true(dialog.is_open())
	assert_eq(dialog.title_text(), "Guardar el mapa")
	assert_eq(dialog.field().text, "nivel_nuevo", "sugiere el nombre del nivel, limpio")
	assert_false(dialog.ok_button().disabled)


func test_accepting_saves_the_file_and_tells_where() -> void:
	_make_dirty()
	_save_as("mi_mapa")
	assert_false(dialog.is_open())
	assert_eq(editor.draft.file_id, "mi_mapa")
	assert_false(editor.draft.dirty, "ya no hay cambios sin guardar")
	assert_true(FileAccess.file_exists(TEST_DIR + "mi_mapa.json"))
	assert_true(editor.message_text().contains("Guardado en"), editor.message_text())
	assert_true(editor.message_text().contains("mi_mapa.json"))
	assert_false((editor.get_node("%Title") as Label).text.ends_with("*"))


func test_the_saved_file_reads_back_the_same() -> void:
	_make_dirty()
	_save_as("igual")
	var opened: LevelDraft = LevelDraft.open_saved("igual", TEST_DIR)
	assert_eq(opened.to_text(), editor.draft.to_text())


func test_saving_again_writes_without_asking() -> void:
	_save_as("dos_veces")
	_make_dirty()
	editor.save_level()
	assert_false(dialog.is_open(), "ya tiene nombre: no lo vuelve a pedir")
	assert_eq(LevelDraft.open_saved("dos_veces", TEST_DIR).letter_at(Vector2i(3, 1)), "X")


func test_cancelling_the_name_saves_nothing() -> void:
	editor.save_level()
	dialog.cancel()
	assert_eq(editor.draft.file_id, "")
	assert_eq(LevelDraft.saved_ids(TEST_DIR), PackedStringArray())


func test_the_name_is_checked_while_typing() -> void:
	editor.save_level()
	_type_name("")
	assert_true(dialog.ok_button().disabled)
	_type_name("Mi Mapa")
	assert_true(dialog.ok_button().disabled, "mayúsculas y espacios no valen")
	assert_true(dialog.note_text().contains("minúsculas"), dialog.note_text())
	_type_name("level_03")
	assert_true(dialog.ok_button().disabled, "RF-216: no se pisan los oficiales")
	assert_true(dialog.note_text().contains("nivel oficial"), dialog.note_text())
	_type_name("valido_1")
	assert_false(dialog.ok_button().disabled)
	assert_true(dialog.note_text().contains("Se guarda en"), dialog.note_text())


func test_an_existing_own_map_can_be_replaced_after_a_warning() -> void:
	_save_as("repetido")
	editor.new_level()  # limpio: no pregunta
	editor.save_level()
	_type_name("repetido")
	assert_false(dialog.ok_button().disabled)
	assert_true(dialog.note_text().contains("se va a reemplazar"), dialog.note_text())


func test_a_draft_with_errors_can_be_saved() -> void:
	editor.set_tool(LevelDraft.Tool.GRASS)
	editor.paint_at(Vector2i(19, 4))  # sin salida
	assert_eq(editor.message_kind(), &"error")
	_save_as("a_medias")
	assert_true(FileAccess.file_exists(TEST_DIR + "a_medias.json"), "RF-213")


func test_ctrl_s_saves() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_S
	event.ctrl_pressed = true
	event.pressed = true
	editor._unhandled_input(event)
	assert_true(dialog.is_open())


# --- Nuevo (RF-215, RF-218) ---

func test_new_replaces_a_clean_draft_at_once() -> void:
	var before: LevelDraft = editor.draft
	editor.new_level()
	assert_false(dialog.is_open(), "no hay nada que perder")
	assert_ne(editor.draft, before)
	assert_eq(GameFlow.editor_draft, editor.draft)


func test_new_asks_first_when_there_are_unsaved_changes() -> void:
	_make_dirty()
	var before: LevelDraft = editor.draft
	editor.new_level()
	assert_true(dialog.is_open())
	assert_eq(dialog.title_text(), "Nuevo nivel")
	dialog.cancel()
	assert_eq(editor.draft, before, "Cancelar: todo sigue igual")
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), "X")
	editor.new_level()
	_accept()
	assert_ne(editor.draft, before)
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), ".")
	assert_false(editor.draft.dirty)


func test_a_dialog_cancelled_does_not_leak_into_the_next_one() -> void:
	# Cancelar "Nuevo" y después aceptar otra cosa no debe volver a ejecutar el "Nuevo" cancelado.
	_make_dirty()
	var before: LevelDraft = editor.draft
	editor.new_level()
	dialog.cancel()
	editor.save_level()
	_type_name("otro")
	_accept()
	assert_eq(editor.draft, before)
	assert_eq(editor.draft.file_id, "otro")


# --- Abrir (RF-216) ---

func test_open_lists_own_maps_and_official_levels() -> void:
	_save_as("mio")
	editor.open_level()
	assert_true(dialog.is_open())
	var list: ItemList = dialog.list()
	var texts: PackedStringArray = []
	for i: int in list.item_count:
		texts.append(list.get_item_text(i))
	assert_true(texts.has("— Mis mapas —"))
	assert_true(texts.has("mio"))
	assert_true(texts.has("— Niveles oficiales (se abren como plantilla) —"))
	assert_eq(texts.size(), 2 + 1 + GameFlow.level_count(), "dos títulos, el mío y los oficiales")
	assert_false(list.is_item_selectable(0), "los títulos no se eligen")
	assert_true(dialog.ok_button().disabled, "hasta que se elija algo")


func test_open_without_saved_maps_says_so() -> void:
	editor.open_level()
	var list: ItemList = dialog.list()
	assert_eq(list.get_item_text(1), "(todavía no guardaste ninguno)")
	assert_false(list.is_item_selectable(1))


func test_opening_an_own_map() -> void:
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	editor.paint_at(Vector2i(8, 7))
	_save_as("para_abrir")
	editor.new_level()
	assert_eq(editor.draft.letter_at(Vector2i(8, 7)), ".")
	editor.open_level()
	_choose("para_abrir")
	_accept()
	assert_eq(editor.draft.file_id, "para_abrir")
	assert_eq(editor.draft.letter_at(Vector2i(8, 7)), "X")
	assert_false(editor.draft.dirty)
	assert_true(editor.message_text().contains("Abierto: para_abrir"), editor.message_text())


func test_opening_an_official_level_gives_a_template() -> void:
	editor.open_level()
	_choose("level_06")
	_accept()
	assert_eq(editor.draft.file_id, "", "no queda ligado al oficial")
	assert_eq(editor.draft.suggested_id, "level_06_copia")
	assert_eq(editor.draft.level_name(), "Nido")
	assert_true(editor.message_text().contains("plantilla"), editor.message_text())
	editor.save_level()
	assert_eq(dialog.field().text, "level_06_copia", "sugiere otro nombre")
	assert_false(dialog.ok_button().disabled)


func test_the_panels_follow_the_opened_level() -> void:
	editor.show_panel(editor.settings_panel(), true)
	editor.open_level()
	_choose("level_05")
	_accept()
	assert_eq(editor.settings_panel().gold_spin().value, 300.0)
	assert_eq(editor.settings_panel().name_edit().text, "Fortaleza")


func test_open_asks_first_when_there_are_unsaved_changes() -> void:
	_make_dirty()
	editor.open_level()
	assert_eq(dialog.title_text(), "Abrir otro nivel")
	assert_eq(dialog.list().item_count, 0, "es la confirmación, todavía no la lista")
	_accept()
	assert_eq(dialog.list().item_count > 0, true, "después de confirmar, la lista")


func test_double_click_opens() -> void:
	editor.open_level()
	var list: ItemList = dialog.list()
	for i: int in list.item_count:
		if list.get_item_text(i).begins_with("level_01"):
			list.select(i)
			list.item_activated.emit(i)
			break
	assert_eq(editor.draft.level_name(), "Pradera")


# --- Probar (RF-217) ---

func test_a_level_with_errors_cannot_be_tried() -> void:
	editor.set_tool(LevelDraft.Tool.GRASS)
	editor.paint_at(Vector2i(19, 4))
	editor.try_level()
	assert_signal_not_emitted(editor, "test_requested")
	assert_true(editor.message_text().begins_with("✗ No se puede probar todavía"), editor.message_text())


func test_a_valid_level_is_sent_to_be_played() -> void:
	editor.settings_panel().draft.set_gold(444)
	editor.try_level()
	assert_signal_emitted(editor, "test_requested")
	var level: LevelData = get_signal_parameters(editor, "test_requested")[0]
	assert_eq(level.starting_gold, 444)
	assert_eq(level.waves.size(), 1)
	assert_eq(level.id, &"borrador")


func test_a_level_with_warnings_can_still_be_tried() -> void:
	editor.set_tool(LevelDraft.Tool.PATH)
	editor.paint_at(Vector2i(9, 5))  # una casilla colgada: aviso, no error
	assert_eq(editor.message_kind(), &"warning")
	editor.try_level()
	assert_signal_emitted(editor, "test_requested")


func test_trying_does_not_save_anything() -> void:
	editor.try_level()
	assert_eq(LevelDraft.saved_ids(TEST_DIR), PackedStringArray())


# --- Salir (RF-218) ---

func test_leaving_with_nothing_to_lose_goes_at_once() -> void:
	editor.leave()
	assert_signal_emitted(editor, "left")
	assert_false(dialog.is_open())


func test_leaving_with_unsaved_changes_asks_first() -> void:
	_make_dirty()
	editor.leave()
	assert_signal_not_emitted(editor, "left")
	assert_true(dialog.is_open())
	dialog.cancel()
	assert_signal_not_emitted(editor, "left")
	editor.leave()
	_accept()
	assert_signal_emitted(editor, "left")


func test_saving_then_leaving_does_not_ask() -> void:
	_make_dirty()
	_save_as("guardado")
	editor.leave()
	assert_signal_emitted(editor, "left")


func test_escape_closes_the_dialog_and_does_not_leave() -> void:
	_make_dirty()
	editor.leave()
	var escape := InputEventAction.new()
	escape.action = &"cancel"
	escape.pressed = true
	dialog._input(escape)
	assert_false(dialog.is_open(), "Esc cierra el diálogo")
	editor._unhandled_input(escape)
	assert_signal_not_emitted(editor, "left")
	editor._unhandled_input(escape)  # sin diálogo abierto y con cambios: pregunta
	assert_true(dialog.is_open())


func test_keys_do_nothing_while_a_dialog_is_open() -> void:
	editor.save_level()
	var key := InputEventKey.new()
	key.keycode = KEY_3
	key.pressed = true
	editor._unhandled_input(key)
	assert_eq(editor.tool, LevelDraft.Tool.PATH, "la tecla 3 no cambió la herramienta")


# --- La pantalla ---

func test_the_top_bar_has_the_new_buttons() -> void:
	for button_name: String in ["NewButton", "OpenButton", "SaveButton", "TryButton", "SettingsButton", "WavesButton", "BackButton"]:
		assert_not_null(editor.get_node_or_null("%" + button_name), button_name)


func test_the_buttons_do_what_the_functions_do() -> void:
	(editor.get_node("%SaveButton") as Button).pressed.emit()
	assert_true(dialog.is_open())
	dialog.cancel()
	(editor.get_node("%TryButton") as Button).pressed.emit()
	assert_signal_emitted(editor, "test_requested")
	(editor.get_node("%OpenButton") as Button).pressed.emit()
	assert_eq(dialog.title_text(), "Abrir un nivel")
	dialog.cancel()
	(editor.get_node("%BackButton") as Button).pressed.emit()
	assert_signal_emitted(editor, "left")
