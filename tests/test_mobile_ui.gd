extends GutTest


func test_ui_mode_reads_and_resolves_supported_values() -> void:
	assert_eq(UiMode.read_setting(0), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting(1), UiMode.MOBILE)
	assert_eq(UiMode.read_setting(2), UiMode.PC)
	assert_eq(UiMode.read_setting(7), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting("celular"), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting(null), UiMode.AUTOMATIC)
	assert_true(UiMode.resolve(0, true))
	assert_false(UiMode.resolve(0, false))
	assert_true(UiMode.resolve(1, false))
	assert_false(UiMode.resolve(2, true))


func test_mobile_ui_config_uses_defaults_for_broken_file() -> void:
	var path: String = "user://test_mobile_ui.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ roto")
	file.close()
	var config: MobileUiConfig = MobileUiConfig.load_from(path)
	assert_eq(config.get_value("boton_alto_px"), 56)
	assert_eq(config.get_value("barra_alta_px"), 64)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_mobile_ui_config_loads_data_file() -> void:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	assert_eq(config.get_value("boton_alto_px"), 56)
	assert_eq(config.get_value("pinza_gracia_ms"), 150)


func test_options_selector_saves_without_changing_an_existing_hud() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var hud: Hud = (load("res://scenes/game/hud.tscn") as PackedScene).instantiate() as Hud
	add_child_autofree(hud)
	await get_tree().process_frame
	assert_true(hud.get_node("TopBar/ExitButton").visible)
	var options: OptionsMenu = (load("res://scenes/ui/options_menu.tscn") as PackedScene).instantiate() as OptionsMenu
	add_child_autofree(options)
	await get_tree().process_frame
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	assert_not_null(selector)
	selector.select(UiMode.MOBILE)
	selector.item_selected.emit(UiMode.MOBILE)
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.MOBILE)
	assert_true(hud.get_node("TopBar/ExitButton").visible, "el cambio se aplica en la próxima partida")
	SaveManager.set_setting("ui_mode", original_setting)


func test_mobile_hud_has_requested_top_controls() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var hud: Hud = (load("res://scenes/game/hud.tscn") as PackedScene).instantiate() as Hud
	add_child_autofree(hud)
	await get_tree().process_frame
	var top_bar: Control = hud.get_node("TopBar")
	var pause_button: Button = hud.get_node("TopBar/PauseButton")
	var speed_button: Button = hud.get_node("TopBar/SpeedButton")
	assert_false(hud.get_node("TopBar/ExitButton").visible)
	assert_eq(top_bar.size.y, 64.0)
	assert_eq(pause_button.custom_minimum_size.y, 56.0)
	assert_eq(speed_button.custom_minimum_size.y, 56.0)
	assert_false(pause_button.text.contains("[P]"))
	assert_false(speed_button.text.contains("[F]"))
	SaveManager.set_setting("ui_mode", original_setting)
