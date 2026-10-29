# La preferencia «Consejos en la derrota» en Opciones (T433, M70: RF-644). No toca el guardado real.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_defeat_advice_options.json"
const OLD_SAVE: String = '{"version":1,"levels":{},"settings":{"music_volume":0.7,"sfx_volume":0.8}}'

var options: OptionsMenu


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	DevMode.set_enabled(false, TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	options = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.open()


func after_each() -> void:
	DevMode.set_enabled(false, TEST_SAVE)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _check() -> CheckBox:
	return options.find_child("DefeatAdviceCheck", true, false) as CheckBox


func test_the_option_is_on_by_default_with_its_label() -> void:
	assert_not_null(_check())
	assert_eq(_check().text, Localization.t(&"options.game.defeat_advice"))
	assert_true(_check().button_pressed)
	assert_true(SaveManager.defeat_advice_enabled())


func test_it_is_the_last_row_of_the_game_and_help_group() -> void:
	var rows: Node = _check().get_parent()
	assert_eq(rows.get_child(_check().get_index() - 1).name, &"BossEntranceCheck")
	assert_eq(rows.name, &"OptionsPage2", "pertenece a la solapa «Partida y ayudas»")
	assert_eq(rows.get_child_count(), 3)


func test_turning_it_off_persists_and_can_be_turned_on_again() -> void:
	_check().button_pressed = false
	assert_false(SaveManager.defeat_advice_enabled())
	options.close()
	SaveManager.load_save()
	assert_false(SaveManager.defeat_advice_enabled())
	options.open()
	assert_false(_check().button_pressed)
	_check().button_pressed = true
	assert_true(SaveManager.defeat_advice_enabled())


func test_an_old_save_without_the_option_keeps_it_on() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(OLD_SAVE)
	file.close()
	SaveManager.load_save()
	options.open()
	assert_true(_check().button_pressed)
	assert_true(SaveManager.defeat_advice_enabled())


func test_a_non_boolean_value_defaults_to_on() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{},"settings":{"defeat_advice":"no"}}')
	file.close()
	SaveManager.load_save()
	options.open()
	assert_true(_check().button_pressed)
	assert_true(SaveManager.defeat_advice_enabled())


func test_the_checkbox_is_touch_sized_in_mobile_options() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	options.queue_free()
	await get_tree().process_frame
	options = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.open()
	for i: int in 3:
		await get_tree().process_frame
	assert_gte(_check().size.y, 44.0)
	assert_lte(_check().size.x, (options.find_child("Panel", true, false) as Control).size.x)
