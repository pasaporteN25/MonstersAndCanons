# M75, RF-678/679/683: ajuste de alcance, compatibilidad y valores visuales.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const SAVE_PATH: String = "user://test_range_display.json"

var options: OptionsMenu


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = SAVE_PATH
	SaveManager.load_save()
	options = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.open()


func after_each() -> void:
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _selector() -> OptionButton:
	return options.find_child("RangeDisplaySelector", true, false) as OptionButton


func test_range_option_sits_with_upgrade_animation_option() -> void:
	var upgrade: Node = options.find_child("UpgradeFxCheck", true, false)
	var label: Node = options.find_child("RangeDisplayLabel", true, false)
	assert_eq(label.get_parent(), upgrade.get_parent())
	assert_eq(label.get_index(), upgrade.get_index() + 1)
	assert_eq(_selector().get_index(), label.get_index() + 1)


func test_mobile_options_keep_the_range_row_touchable_and_inside_the_panel() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	options.queue_free()
	await get_tree().process_frame
	options = OPTIONS_SCENE.instantiate()
	add_child_autofree(options)
	options.open()
	for _frame: int in 3:
		await get_tree().process_frame
	var panel: Control = options.find_child("Panel", true, false) as Control
	var upgrade: Node = options.find_child("UpgradeFxCheck", true, false)
	var label: Node = options.find_child("RangeDisplayLabel", true, false)
	assert_eq(label.get_parent(), upgrade.get_parent(), "mismo contenedor en celular")
	assert_eq(label.get_index(), upgrade.get_index() + 1)
	assert_eq(_selector().get_index(), label.get_index() + 1)
	assert_lte(panel.size.y, 720.0)
	assert_gte(_selector().size.y, 44.0)
	assert_lte(_selector().size.x, panel.size.x)


func test_range_option_defaults_to_hidden_including_an_old_save() -> void:
	assert_eq(SaveManager.range_display(), 0)
	assert_eq(_selector().get_item_text(_selector().selected), "Oculto")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{},"settings":{"fullscreen":false}}')
	file.close()
	SaveManager.load_save()
	options.open()
	assert_eq(SaveManager.range_display(), 0)
	assert_eq(_selector().get_item_text(_selector().selected), "Oculto")


func test_each_option_is_saved_and_shown_again() -> void:
	for value: int in [0, 1, 2]:
		_selector().select(value)
		_selector().item_selected.emit(value)
		assert_eq(SaveManager.range_display(), value)
		options.close()
		assert_true(SaveManager.save())
		SaveManager.load_save()
		assert_eq(SaveManager.range_display(), value, "se conserva al releer JSON")
		options.open()
		assert_eq(_selector().selected, value)


func test_invalid_saved_values_warn_and_fall_back_to_hidden() -> void:
	for literal: String in ["1.5", "1.000001", "true", '"1"', "3", "-1"]:
		var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		file.store_string('{"version":1,"levels":{},"settings":{"range_display":%s}}' % literal)
		file.close()
		SaveManager.set_setting("range_display", 2)  # que el 0 sea un retroceso real, no el valor de antes
		SaveManager.load_save()
		assert_push_warning("range_display")
		assert_eq(SaveManager.range_display(), 0, "guardado %s" % literal)


func test_invalid_setter_values_fall_back_to_hidden() -> void:
	for value: Variant in [1.5, 1.000001, true, "1", 3, -1, INF, NAN, null]:
		SaveManager.set_setting("range_display", 2)
		SaveManager.set_setting("range_display", value)
		assert_eq(SaveManager.range_display(), 0, "setter %s" % str(value))
		assert_eq(SaveManager.get_setting("range_display"), 0, "no se guarda %s" % str(value))
	SaveManager.set_setting("range_display", 1.0)  # lo que da JSON: se acepta
	assert_eq(SaveManager.range_display(), 1)


func test_full_range_color_comes_from_the_data() -> void:
	var config := RangeDisplayConfig.new()
	config.values["color_completo"] = {"r": 0.25, "g": 0.5, "b": 0.75}
	assert_eq(BuildController.range_color(config), Color(0.25, 0.5, 0.75))
	assert_eq(BuildController.range_color(RangeDisplayConfig.runtime_config()), Color(1.0, 1.0, 1.0))


func test_range_drawing_data_matches_the_approved_styles() -> void:
	var config := RangeDisplayConfig.load_from()
	assert_true(config.is_valid(), "; ".join(config.errors))
	assert_almost_eq(config.get_value("sutil", "opacidad_borde"), 0.3, 0.001)
	assert_almost_eq(config.get_value("sutil", "grosor_borde_px"), 1.0, 0.001)
	assert_almost_eq(config.get_value("completo", "opacidad_relleno"), 0.08, 0.001)
	assert_almost_eq(config.get_value("completo", "opacidad_borde"), 0.7, 0.001)
	assert_almost_eq(config.get_value("completo", "grosor_borde_px"), 2.0, 0.001)
	assert_almost_eq(config.get_value("color_apoyo", "opacidad_sutil"), 0.22, 0.001)
	assert_almost_eq(float(config.values["color_completo"]["r"]), 1.0, 0.001)
	assert_almost_eq(float(config.values["color_completo"]["g"]), 1.0, 0.001)
	assert_almost_eq(float(config.values["color_completo"]["b"]), 1.0, 0.001)


func test_stunned_support_tower_is_not_drawn_as_active() -> void:
	assert_eq(Tower.support_range_style(2, false), 2)
	assert_eq(Tower.support_range_style(1, false), 1)
	assert_eq(Tower.support_range_style(0, false), 0)
	assert_eq(Tower.support_range_style(2, true), 0)


func test_ghost_is_always_complete_and_placed_tower_uses_the_setting() -> void:
	assert_eq(BuildController.ghost_range_style(), 2)
	for value: int in [0, 1, 2]:
		assert_eq(BuildController.placed_range_style(value), value)
	assert_eq(BuildController.placed_range_style(9), 0)
