# La casilla «Entrada de los jefes» en Opciones (T368, M66: RF-600). No toca el guardado real.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_boss_entrance_options.json"
const OLD_SAVE: String = '{"version":1,"levels":{},"settings":{"music_volume":0.7,"sfx_volume":0.8,"fullscreen":false,"damage_numbers":true}}'

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
	return options.find_child("BossEntranceCheck", true, false) as CheckBox


func test_the_check_is_there_on_by_default_with_its_text() -> void:
	assert_not_null(_check())
	assert_eq(_check().text, "Entrada de los jefes")
	assert_true(_check().button_pressed)


func test_it_sits_under_the_damage_numbers_and_the_tutorial_row() -> void:
	var damage: Node = options.find_child("DamageNumbersCheck", true, false)
	var tutorial: Node = options.find_child("TutorialRow", true, false)
	assert_eq(_check().get_parent(), damage.get_parent())
	assert_gt(_check().get_index(), damage.get_index())
	assert_eq(_check().get_index(), tutorial.get_index() + 1)


func test_turning_it_off_saves_and_turning_it_on_restores() -> void:
	_check().button_pressed = false
	assert_false(SaveManager.boss_entrance_enabled())
	options.close()
	SaveManager.load_save()
	assert_false(SaveManager.boss_entrance_enabled(), "queda guardado")
	options.open()
	assert_false(_check().button_pressed)
	_check().button_pressed = true
	assert_true(SaveManager.boss_entrance_enabled())


func test_an_old_save_shows_it_on() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(OLD_SAVE)
	file.close()
	SaveManager.load_save()
	options.open()
	assert_true(_check().button_pressed, "un guardado viejo sin la clave la lee prendida")


func test_a_non_boolean_value_reads_as_on() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{},"settings":{"boss_entrance":"no"}}')
	file.close()
	SaveManager.load_save()
	options.open()
	assert_true(_check().button_pressed)


func test_the_panel_still_fits_in_720_and_the_row_is_touch_sized_on_mobile() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	options.queue_free()
	await get_tree().process_frame
	options = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.admin_available = true
	options.open()
	for i: int in 3:
		await get_tree().process_frame
	var panel: Control = options.find_child("Panel", true, false) as Control
	assert_lte(panel.size.y, 720.0, "Opciones entra en 720 de alto en modo celular")
	assert_gte(_check().size.y, 44.0, "la casilla se toca con el dedo")
	assert_lte(_check().size.x, panel.size.x)


func test_the_panel_fits_in_a_720_pixel_window_in_pc_mode() -> void:
	for from_main_menu: bool in [false, true]:
		options.admin_available = from_main_menu
		options.open()
		for i: int in 3:
			await get_tree().process_frame
		var panel: Control = options.find_child("Panel", true, false) as Control
		assert_lte(panel.size.y, 720.0)
		assert_lte(panel.size.x, 520.0, "y no se ensancha de más")
