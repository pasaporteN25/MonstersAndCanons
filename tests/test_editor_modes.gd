# Tests de "Guardar en un modo…" del editor de mapas (M49, RF-392). Usa carpetas de prueba para los mapas
# sueltos y los modos, nunca las del jugador, y desconecta las señales que cambiarían de pantalla.
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const MAPS: String = "user://test_editor_modes_maps/"
const MODES: String = "user://test_editor_modes_user/"
const OFFICIAL: String = "user://test_editor_modes_official/"

var editor: MapEditor
var dialog: EditorDialog


func before_each() -> void:
	for dir: String in [MAPS, MODES, OFFICIAL]:
		_remove(dir)
	GameFlow.editor_draft = null
	editor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	editor.maps_dir = MAPS
	editor.modes_dir = MODES
	editor.official_modes_dir = OFFICIAL
	editor.left.disconnect(GameFlow.go_to_tools)
	editor.test_requested.disconnect(GameFlow.play_test)
	dialog = editor.dialog()


func after_each() -> void:
	GameFlow.editor_draft = null
	for dir: String in [MAPS, MODES, OFFICIAL]:
		_remove(dir)


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	DirAccess.remove_absolute(dir)


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


func _type(text: String) -> void:
	dialog.field().text = text
	dialog.field().text_changed.emit(text)


func _mode_maps(mode_id: String) -> Array:
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(ModePacks.dir_of(MODES, mode_id) + ModePacks.FILE_NAME))
	return (json.data as Dictionary)["mapas"]


## Crea el modo `name` desde el editor y guarda el borrador ahí como `file`.
func _save_in_new_mode(name: String, file: String) -> void:
	editor.save_to_mode()
	_choose("+ Nuevo modo")
	_accept()
	_type(name)
	_accept()
	_type(file)
	_accept()


func test_the_top_bar_has_the_save_in_mode_button() -> void:
	var button: Button = editor.get_node("%SaveModeButton")
	button.pressed.emit()
	assert_true(dialog.is_open())
	assert_eq(dialog.title_text(), "Guardar en un modo")


func test_a_new_mode_is_created_and_the_map_goes_inside() -> void:
	_save_in_new_mode("Mi Modo", "mapa_a")
	assert_true(FileAccess.file_exists(ModePacks.dir_of(MODES, "mi_modo") + "mapa_a.json"))
	assert_eq(_mode_maps("mi_modo"), ["mapa_a"], "RF-392: el mapa entra en la lista del modo")
	assert_eq(editor.draft.mode_id, "mi_modo")
	assert_eq(editor.draft.file_id, "mapa_a")
	assert_false(FileAccess.file_exists(MAPS + "mapa_a.json"), "no queda como mapa suelto")
	assert_true(editor.message_text().contains("mi_modo"), editor.message_text())
	var mode: Dictionary = ModePacks.read(MODES, "mi_modo", false)
	assert_eq(mode["name"], "Mi Modo")
	assert_not_null(ModePacks.map_level(mode, 0), "el modo ya se puede jugar")


func test_saving_again_stays_in_the_mode_without_asking() -> void:
	_save_in_new_mode("Mi Modo", "mapa_a")
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	editor.paint_at(Vector2i(4, 4))
	editor.save_level()
	assert_false(dialog.is_open(), "ya tiene nombre y modo")
	var saved: LevelDraft = LevelDraft.open_saved("mapa_a", ModePacks.dir_of(MODES, "mi_modo"))
	assert_eq(saved.letter_at(Vector2i(4, 4)), "X")
	assert_eq(_mode_maps("mi_modo"), ["mapa_a"], "no se repite en la lista")


func test_saving_a_map_in_a_mode_with_the_health_table_keeps_the_table() -> void:
	# RF-496: el editor no edita la tabla de vida por mapa, pero tampoco la pierde.
	DirAccess.make_dir_recursive_absolute(ModePacks.dir_of(MODES, "con_tabla"))
	var file := FileAccess.open(ModePacks.dir_of(MODES, "con_tabla") + ModePacks.FILE_NAME, FileAccess.WRITE)
	file.store_string('{"version": 1, "nombre": "Con tabla", "mapas": ["level_01"], "reglas": {"vida_monstruos_%": 115, '
		+ '"vida_monstruos_por_mapa_%": {"level_01": 105}}}')
	file.close()
	editor.save_to_mode()
	_choose("Con tabla (con_tabla)")
	_accept()
	_type("mapa_c")
	_accept()
	assert_eq(_mode_maps("con_tabla"), ["level_01", "mapa_c"])
	var mode: Dictionary = ModePacks.read(MODES, "con_tabla", false)
	assert_eq(mode["errors"], PackedStringArray())
	assert_eq(ModePacks.map_level(mode, 0).enemy_health_percent, 105, "la tabla sigue mandando")
	assert_eq(ModePacks.map_level(mode, 1).enemy_health_percent, 115)


func test_a_second_map_goes_to_an_existing_mode() -> void:
	_save_in_new_mode("Mi Modo", "mapa_a")
	editor.new_level()
	editor.save_to_mode()
	_choose("Mi Modo (mi_modo)")
	_accept()
	_type("mapa_b")
	_accept()
	assert_eq(_mode_maps("mi_modo"), ["mapa_a", "mapa_b"])


func test_cancelling_the_file_name_leaves_the_draft_where_it_was() -> void:
	editor.save_level()
	_type("suelto")
	_accept()
	assert_eq(editor.draft.mode_id, "")
	editor.save_to_mode()
	_choose("+ Nuevo modo")
	_accept()
	_type("Otro")
	_accept()
	dialog.cancel()
	assert_eq(editor.draft.mode_id, "", "sigue siendo el mapa suelto")
	assert_eq(editor.draft.file_id, "suelto")
	assert_true(FileAccess.file_exists(ModePacks.dir_of(MODES, "otro") + ModePacks.FILE_NAME), "el modo sí se creó")


func test_mode_names_and_file_names_are_checked_while_typing() -> void:
	DirAccess.make_dir_recursive_absolute(ModePacks.dir_of(OFFICIAL, "asedio"))
	editor.save_to_mode()
	_choose("+ Nuevo modo")
	_accept()
	_type("Asedio")
	assert_true(dialog.ok_button().disabled, "no puede llamarse como un modo oficial")
	_type("Nuevo")
	assert_false(dialog.ok_button().disabled)
	_accept()
	_type("modo")
	assert_true(dialog.ok_button().disabled, "'modo' es el nombre del archivo del modo")
	assert_true(dialog.note_text().contains("reservado"), dialog.note_text())
	_type("level_01")
	assert_true(dialog.ok_button().disabled, "tampoco el de un nivel oficial")


func test_open_lists_the_maps_of_each_own_mode() -> void:
	_save_in_new_mode("Mi Modo", "mapa_a")
	editor.new_level()
	editor.open_level()
	var texts: PackedStringArray = []
	for i: int in dialog.list().item_count:
		texts.append(dialog.list().get_item_text(i))
	assert_true(texts.has("— Modo Mi Modo —"), str(texts))
	assert_true(texts.has("mapa_a"))
	assert_false(texts.has("modo"), "el archivo del modo no es un mapa")


func test_opening_a_mode_map_keeps_saving_into_that_mode() -> void:
	_save_in_new_mode("Mi Modo", "mapa_a")
	editor.new_level()
	editor.open_level()
	_choose("mapa_a")
	_accept()
	assert_eq(editor.draft.mode_id, "mi_modo")
	assert_eq(editor.draft.file_id, "mapa_a")
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	editor.paint_at(Vector2i(6, 6))
	editor.save_level()
	assert_false(FileAccess.file_exists(MAPS + "mapa_a.json"), "se guardó en el modo, no suelto")
