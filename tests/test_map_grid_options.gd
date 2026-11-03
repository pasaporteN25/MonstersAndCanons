# T565, RF-741: la preferencia de cuadrícula y las líneas del mapa.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const OVERLAY_SCRIPT: Script = preload("res://scenes/levels/map_grid_overlay.gd")

var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.load_save()


func after_each() -> void:
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func test_missing_setting_defaults_off_without_changing_save_version() -> void:
	SaveManager._read_settings({})
	assert_false(SaveManager.map_grid_enabled())
	SaveManager.set_setting("map_grid", true)
	assert_true(SaveManager.map_grid_enabled())
	assert_eq(SaveManager.SAVE_VERSION, 1, "la preferencia es aditiva y no sube la versión")


func test_invalid_setting_values_fall_back_to_off() -> void:
	for value: Variant in ["yes", 1, null]:
		SaveManager.set_setting("map_grid", value)
		assert_false(SaveManager.map_grid_enabled())


func test_option_is_in_game_help_group_and_applies_immediately() -> void:
	var options: OptionsMenu = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.open()
	var check: CheckBox = options.find_child("MapGridCheck", true, false) as CheckBox
	assert_not_null(check)
	assert_eq(check.get_parent().name, &"OptionsPage2")
	assert_false(check.button_pressed)
	check.button_pressed = true
	assert_true(SaveManager.map_grid_enabled())


func test_overlay_reacts_to_option_and_covers_both_supported_map_sizes() -> void:
	var overlay := Node2D.new()
	overlay.set_script(OVERLAY_SCRIPT)
	add_child_autofree(overlay)
	overlay.call("setup", null)
	SaveManager.set_setting("map_grid", true)
	assert_true(bool(overlay.get("_enabled")))
	assert_eq(overlay.call("line_count", Vector2i(20, 9)), 31)
	assert_eq(overlay.call("line_count", Vector2i(26, 12)), 40)
	SaveManager.set_setting("map_grid", false)
	assert_false(bool(overlay.get("_enabled")))
