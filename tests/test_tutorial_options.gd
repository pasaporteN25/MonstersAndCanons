# La casilla y el botón del tutorial en Opciones (T331, M63: RF-576). No toca el guardado real.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_tutorial_options.json"

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
	return options.find_child("TutorialCheck", true, false) as CheckBox


func _replay() -> Button:
	return options.find_child("TutorialReplay", true, false) as Button


func test_the_row_is_there_and_shows_the_saved_option() -> void:
	assert_not_null(_check())
	assert_not_null(_replay())
	assert_eq(_check().text, "Tutorial del nivel 1")
	assert_true(_check().button_pressed, "prendido por omisión")
	SaveManager.set_setting("tutorial_enabled", false)
	options.open()
	assert_false(_check().button_pressed)


func test_the_row_sits_under_the_damage_numbers_option() -> void:
	var rows: Node = options.find_child("Rows", true, false)
	var damage: Node = options.find_child("DamageNumbersCheck", true, false)
	var row: Node = rows.find_child("TutorialRow", true, false)
	assert_not_null(row, "la fila está en Opciones")
	assert_gt(row.get_index(), damage.get_index(), "va después de los números de daño (M61 puede intercalar «Interfaz»)")
	assert_lte(row.get_index() - damage.get_index(), 3, "y pegada a ellos")


func test_turning_it_off_saves_the_option_and_keeps_the_progress() -> void:
	SaveManager.mark_tutorial_done()
	_check().button_pressed = false
	assert_false(SaveManager.tutorial_enabled())
	assert_true(SaveManager.tutorial_done(), "apagarlo no borra que ya lo vio")
	options.close()
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_enabled(), "queda guardado")


func test_turning_it_on_again_makes_it_show_again() -> void:
	SaveManager.set_setting("tutorial_enabled", false)
	SaveManager.mark_tutorial_done()
	options.open()
	_check().button_pressed = true
	assert_true(SaveManager.tutorial_enabled())
	assert_false(SaveManager.tutorial_done(), "volver a prenderlo = querer verlo de nuevo")


func test_the_replay_button_rearms_it_and_says_where_it_will_be_seen() -> void:
	SaveManager.set_setting("tutorial_enabled", false)
	SaveManager.mark_tutorial_done()
	options.open()
	_replay().pressed.emit()
	assert_true(SaveManager.tutorial_enabled())
	assert_false(SaveManager.tutorial_done())
	assert_true(_check().button_pressed)
	assert_eq(_replay().text, OptionsMenu.TUTORIAL_REPLAYED_TEXT)
	assert_true(_replay().disabled, "ya está armado: no hay nada más que apretar")
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_done(), "se guardó enseguida")
	options.open()
	assert_eq(_replay().text, OptionsMenu.TUTORIAL_REPLAY_TEXT, "al volver a abrir Opciones el botón vuelve a estar")
	assert_false(_replay().disabled)


func test_the_panel_fits_in_a_720_pixel_window_from_the_pause_and_from_the_main_menu() -> void:
	for from_main_menu: bool in [false, true]:
		options.admin_available = from_main_menu
		options.open()
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var panel: Control = options.find_child("Panel", true, false) as Control
		assert_lte(panel.size.y, 720.0, "el panel de Opciones entra en 720 de alto (menú principal: %s)" % from_main_menu)
		assert_lte(panel.size.x, 520.0, "y no se ensancha de más")
		var row: Control = options.find_child("TutorialRow", true, false) as Control
		assert_lte(row.size.x, panel.size.x, "la fila entra en el ancho del panel")


func test_the_confirmation_of_the_test_mode_hides_the_row_too() -> void:
	options.admin_available = true
	options._set_confirming(true)
	assert_false((options.find_child("TutorialRow", true, false) as Control).visible, "la confirmación ocupa el panel entero")
	options._set_confirming(false)
	assert_true((options.find_child("TutorialRow", true, false) as Control).visible)
