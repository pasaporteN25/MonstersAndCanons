# Tests del modo de pruebas desde Opciones (M48, RF-383 a RF-385, D-077).
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
## Nunca el guardado real ni el save_pruebas.json de verdad.
const NORMAL_PATH: String = "user://test_options_normal.json"
const DEV_PATH: String = "user://test_options_pruebas.json"

var options: OptionsMenu


func _remove_files() -> void:
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func before_each() -> void:
	_remove_files()
	DevMode.set_enabled(false, NORMAL_PATH)
	options = OPTIONS_SCENE.instantiate()
	options.dev_save_path = DEV_PATH
	options.normal_save_path = NORMAL_PATH
	add_child_autofree(options)


func after_each() -> void:
	DevMode.set_enabled(false, NORMAL_PATH)
	_remove_files()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _press(unique_name: String) -> void:
	(options.get_node("%" + unique_name) as Button).pressed.emit()


func test_pause_options_never_offer_dev_mode() -> void:
	options.open()
	assert_false(options.is_admin_visible(), "RF-383: desde la pausa no se cambia de guardado")


func test_pause_options_hide_it_even_while_dev_mode_is_on() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	options.open()
	assert_false(options.is_admin_visible())


func test_main_menu_options_offer_dev_mode() -> void:
	options.admin_available = true
	options.open()
	assert_true(options.is_admin_visible(), "RF-383")
	assert_eq(options.admin_button_text(), Localization.t(&"options.admin.enable"))
	assert_false(options.is_confirm_visible(), "la confirmación aparece recién al tocar el botón")


func test_activating_asks_first() -> void:
	options.admin_available = true
	options.open()
	watch_signals(options)
	_press("AdminButton")
	assert_true(options.is_confirm_visible(), "RF-383: pide confirmación")
	assert_false((options.get_node("%BackButton") as Control).visible,
		"la confirmación ocupa el panel: así no crece más que la pantalla")
	assert_false(options.is_admin_visible())
	assert_false(DevMode.enabled, "todavía no cambió nada")
	assert_signal_not_emitted(options, "dev_mode_changed")


func test_cancel_changes_nothing() -> void:
	options.admin_available = true
	options.open()
	watch_signals(options)
	_press("AdminButton")
	_press("AdminCancelButton")
	assert_false(options.is_confirm_visible())
	assert_true((options.get_node("%BackButton") as Control).visible, "el panel vuelve a estar completo")
	assert_true((options.get_node("%MusicSlider") as Control).visible)
	assert_true(options.is_admin_visible())
	assert_false(DevMode.enabled)
	assert_eq(SaveManager.save_path, NORMAL_PATH)
	assert_signal_not_emitted(options, "dev_mode_changed")


func test_confirming_turns_on_dev_mode_with_its_own_save() -> void:
	options.admin_available = true
	options.open()
	watch_signals(options)
	_press("AdminButton")
	_press("AdminConfirmButton")
	assert_true(DevMode.enabled, "RF-383")
	assert_eq(SaveManager.save_path, DEV_PATH, "RF-181: guardado aparte")
	assert_true(DevMode.is_banner_visible(), "RF-182: el cartel avisa")
	assert_signal_emitted_with_parameters(options, "dev_mode_changed", [true])
	assert_eq(options.admin_button_text(), Localization.t(&"options.admin.disable"))
	assert_false(options.is_confirm_visible())


func test_back_to_normal_needs_no_confirmation() -> void:
	options.admin_available = true
	options.set_dev_mode(true)
	options.open()
	watch_signals(options)
	_press("AdminButton")
	assert_false(DevMode.enabled, "RF-384")
	assert_false(options.is_confirm_visible(), "sin confirmación")
	assert_eq(SaveManager.save_path, NORMAL_PATH)
	assert_signal_emitted_with_parameters(options, "dev_mode_changed", [false])
	assert_eq(options.admin_button_text(), Localization.t(&"options.admin.enable"))


func test_real_progress_is_untouched_by_dev_mode() -> void:
	SaveManager.record_victory(&"level_01", 20)
	SaveManager.save()
	options.set_dev_mode(true)
	assert_false(SaveManager.is_completed(&"level_01"), "RF-181: el de pruebas es otro guardado")
	SaveManager.record_victory(&"level_03", 5)
	SaveManager.save()
	options.set_dev_mode(false)
	assert_true(SaveManager.is_completed(&"level_01"), "RF-384: el progreso real sigue ahí")
	assert_false(SaveManager.is_completed(&"level_03"), "lo de pruebas no pasó al real")


func test_options_changed_before_switching_stay_in_their_save() -> void:
	SaveManager.set_setting("music_volume", 0.25)
	options.set_dev_mode(true)
	SaveManager.set_setting("music_volume", 0.9)
	options.set_dev_mode(false)
	assert_almost_eq(float(SaveManager.get_setting("music_volume")), 0.25, 0.001,
		"el volumen del guardado real se guardó antes de cambiar y el de pruebas no lo pisó")
