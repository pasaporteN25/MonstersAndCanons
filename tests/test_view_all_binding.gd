# M68 (T402, RF-612 a RF-615, D-161, D-162): la tecla de «Ver todo»: acción de input, guardado aditivo y fila de Opciones.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_m68_view_all_key.json"

var _options: OptionsMenu


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	DevMode.set_enabled(false, TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()


func after_each() -> void:
	DevMode.set_enabled(false, TEST_SAVE)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()
	ViewAllBinding.apply(ViewAllBinding.DEFAULT_KEY)


func _open_options() -> void:
	_options = OPTIONS_SCENE.instantiate()
	add_child_autofree(_options)
	_options.open()


func _key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event


# --- la acción y sus choques ---

func test_the_action_exists_with_v_by_default() -> void:
	assert_true(InputMap.has_action(ViewAllBinding.ACTION))
	assert_eq(ViewAllBinding.current_key(), KEY_V)
	assert_true(InputMap.event_is_action(_key_event(KEY_V), ViewAllBinding.ACTION))


func test_apply_leaves_exactly_one_key() -> void:
	ViewAllBinding.apply(KEY_H)
	assert_eq(ViewAllBinding.current_key(), KEY_H)
	assert_eq(InputMap.action_get_events(ViewAllBinding.ACTION).size(), 1)
	assert_false(InputMap.event_is_action(_key_event(KEY_V), ViewAllBinding.ACTION), "la V ya no activa «Ver todo»")


func test_apply_with_an_invalid_key_falls_back_to_v() -> void:
	ViewAllBinding.apply(0)
	assert_eq(ViewAllBinding.current_key(), KEY_V)
	ViewAllBinding.apply(KEY_ESCAPE)
	assert_eq(ViewAllBinding.current_key(), KEY_V)


func test_keys_used_by_other_actions_are_refused() -> void:
	assert_ne(ViewAllBinding.conflict(KEY_P), "", "P es la pausa")
	assert_ne(ViewAllBinding.conflict(KEY_SPACE), "", "Espacio empieza la oleada")
	assert_ne(ViewAllBinding.conflict(KEY_1), "", "1 elige una torre")
	assert_ne(ViewAllBinding.conflict(KEY_TAB), "")
	assert_ne(ViewAllBinding.conflict(KEY_F1), "", "F1 es el panel de pruebas")
	assert_ne(ViewAllBinding.conflict(KEY_ESCAPE), "")
	assert_eq(ViewAllBinding.conflict(KEY_H), "", "H está libre")
	assert_eq(ViewAllBinding.conflict(KEY_V), "", "la propia tecla de la acción no cuenta como choque")


# --- guardado aditivo ---

func test_ui_prefs_default_and_round_trip() -> void:
	var prefs := UiPrefs.new()
	assert_eq(prefs.view_all_key, KEY_V)
	prefs.view_all_key = KEY_H
	assert_eq(UiPrefs.read(prefs.to_dict()).view_all_key, KEY_H)


func test_old_prefs_without_the_key_read_without_warning() -> void:
	var raw: Dictionary = {"cart_side": "left", "cart_y": 0.3, "exit_side": "right", "exit_y": 0.2,
		"demolish_side": "left", "demolish_y": 0.5}
	assert_eq(UiPrefs.read(raw).view_all_key, KEY_V)


func test_invalid_keys_in_the_save_fall_back_to_v() -> void:
	for bad: Variant in ["H", -3, 0, KEY_ESCAPE, 72.5, null, [72]]:
		var raw: Dictionary = UiPrefs.new().to_dict()
		raw["view_all_key"] = bad
		assert_eq(UiPrefs.read(raw).view_all_key, KEY_V, "valor raro %s" % str(bad))


func test_the_key_survives_saving_and_loading_and_the_save_version_does_not_change() -> void:
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	prefs.view_all_key = KEY_H
	SaveManager.set_ui_prefs(prefs)
	assert_eq(ViewAllBinding.current_key(), KEY_H, "se aplica al guardar")
	ViewAllBinding.apply(KEY_V)
	SaveManager.load_save()
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_H)
	assert_eq(ViewAllBinding.current_key(), KEY_H, "se aplica al cargar")
	var text: String = FileAccess.get_file_as_string(TEST_SAVE)
	assert_eq(int((JSON.parse_string(text) as Dictionary)["version"]), SaveManager.SAVE_VERSION)


func test_loading_a_save_without_prefs_restores_v() -> void:
	ViewAllBinding.apply(KEY_H)
	SaveManager.load_save()
	assert_eq(ViewAllBinding.current_key(), KEY_V)


# --- la fila de Opciones ---

func test_options_has_the_row_with_the_current_key() -> void:
	_open_options()
	var button: Button = _options.find_child("ViewAllKeyButton", true, false) as Button
	assert_not_null(button)
	assert_eq(button.text, "V")
	assert_true((_options.find_child("ViewAllRestoreButton", true, false) as Button).disabled, "ya es la de siempre")


func test_the_row_is_in_the_controls_group_between_the_help_and_advanced_groups() -> void:
	_open_options()
	var row: Node = _options.find_child("ViewAllRow", true, false)
	var parent: Node = row.get_parent()
	var title: Node = parent.get_child(row.get_index() - 1)
	assert_eq(title.name, &"ControlsSection")
	assert_eq((title as Label).text, "Controles")
	assert_eq(parent.get_child(row.get_index() - 2).name, &"DefeatAdviceCheck", "antes, el final de «Partida y ayudas»")
	assert_eq(parent.get_child(row.get_index() + 1).name, &"AdvancedSection", "después, «Avanzado»")
	assert_eq((_options.find_child("ViewAllKeyButton", true, false) as Button).get_parent().get_parent(), row,
		"el botón, «Restaurar» y el aviso viajan con la fila")
	assert_eq(_options.find_child("ViewAllNote", true, false).get_parent(), row)


func test_choosing_a_free_key_saves_it_and_enables_restore() -> void:
	_open_options()
	assert_true(_options.set_view_all_key(KEY_H))
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_H)
	assert_eq((_options.find_child("ViewAllKeyButton", true, false) as Button).text, "H")
	assert_false((_options.find_child("ViewAllRestoreButton", true, false) as Button).disabled)
	(_options.find_child("ViewAllRestoreButton", true, false) as Button).pressed.emit()
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_V)
	assert_eq(ViewAllBinding.current_key(), KEY_V)


func test_choosing_a_taken_key_warns_and_changes_nothing() -> void:
	_open_options()
	assert_false(_options.set_view_all_key(KEY_P))
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_V)
	var note: Label = _options.find_child("ViewAllNote", true, false) as Label
	assert_true(note.visible)
	assert_true(note.text.contains("pausa"))
	assert_true(_options.set_view_all_key(KEY_H))
	assert_false(note.visible, "al elegir bien, el aviso se va")


func test_the_button_waits_for_the_next_key_and_escape_cancels_it() -> void:
	_open_options()
	var button: Button = _options.find_child("ViewAllKeyButton", true, false) as Button
	button.pressed.emit()
	assert_eq(button.text, "Presioná una tecla…")
	_options._input(_key_event(KEY_SHIFT))
	assert_eq(button.text, "Presioná una tecla…", "un modificador solo no cuenta")
	_options._input(_key_event(KEY_ESCAPE))
	assert_eq(button.text, "V")
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_V)
	button.pressed.emit()
	_options._input(_key_event(KEY_J))
	assert_eq(button.text, "J")
	assert_eq(ViewAllBinding.current_key(), KEY_J)
	_options._input(_key_event(KEY_K))
	assert_eq(ViewAllBinding.current_key(), KEY_J, "fuera de la espera, las teclas no hacen nada")


func test_a_phone_interface_has_no_key_row() -> void:
	var original: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_open_options()
	assert_null(_options.find_child("ViewAllKeyButton", true, false))
	assert_null(_options.find_child("ViewAllRow", true, false))
	assert_null(_options.find_child("ControlsSection", true, false), "tampoco queda un título «Controles» vacío")
	SaveManager.set_setting("ui_mode", original)
