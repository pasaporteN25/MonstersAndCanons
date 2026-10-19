extends GutTest
# T315 (RF-553, RF-554, D-117): la versión se lee de `project.godot` y se muestra como Beta hasta la 1.0.0;
# Opciones trae la sección «Créditos y versión» con el acceso a los créditos.

var _original_mode: Variant


func before_each() -> void:
	_original_mode = SaveManager.get_setting("ui_mode")


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)


func test_label_for_empty_and_beta() -> void:
	assert_eq(GameVersion.label(""), "Beta")
	assert_eq(GameVersion.label("beta"), "Beta")
	assert_eq(GameVersion.label("  Beta "), "Beta")


func test_label_for_numbers_under_one_is_beta_with_the_number() -> void:
	assert_eq(GameVersion.label("0.3.0"), "Beta 0.3.0")
	assert_eq(GameVersion.label("0.12.7"), "Beta 0.12.7")


func test_label_for_suffixes_keeps_beta_even_after_one() -> void:
	assert_eq(GameVersion.label("0.3.0-rc1"), "Beta 0.3.0-rc1")
	assert_eq(GameVersion.label("1.0.0-beta.2"), "Beta 1.0.0-beta.2")
	assert_eq(GameVersion.label("1.0.0+build5"), "Beta 1.0.0+build5")


func test_label_from_one_point_zero_is_plain_version() -> void:
	assert_eq(GameVersion.label("1.0.0"), "Versión 1.0.0")
	assert_eq(GameVersion.label("2.4.1"), "Versión 2.4.1")


func test_label_for_garbage_is_shown_as_is_after_beta() -> void:
	assert_eq(GameVersion.label("1.0"), "Beta 1.0")
	assert_eq(GameVersion.label("abc"), "Beta abc")
	assert_eq(GameVersion.label("1.x.0"), "Beta 1.x.0")


func test_parse() -> void:
	assert_eq(GameVersion.parse("1.2.3"), {"major": 1, "minor": 2, "patch": 3, "suffix": ""})
	assert_eq(GameVersion.parse("0.1.0-rc1")["suffix"], "rc1")
	assert_true(GameVersion.parse("1.2").is_empty())


func test_project_has_the_version_in_one_place() -> void:
	assert_true(ProjectSettings.has_setting(GameVersion.SETTING), "project.godot trae config/version")
	assert_eq(GameVersion.raw(), "beta", "hoy: beta")
	var presets: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_false(presets.contains("version/name=\"1.0.0\""), "Android no repite una versión inventada")
	assert_true(presets.contains("version/name=\"\""), "Android toma la del proyecto")
	assert_false(presets.contains("file_version=\"1.0.0\""), "Windows tampoco dice 1.0.0")


func _options() -> OptionsMenu:
	var options: OptionsMenu = (load("res://scenes/ui/options_menu.tscn") as PackedScene).instantiate() as OptionsMenu
	add_child_autofree(options)
	return options


func test_options_show_the_version_and_open_the_credits() -> void:
	var options: OptionsMenu = _options()
	options.open()
	await get_tree().process_frame
	var version: Label = options.get_node("%VersionLabel") as Label
	assert_eq(version.text, GameVersion.label(GameVersion.raw()))
	assert_true(version.text.begins_with("Beta"), "estamos en beta")
	var button: Button = options.get_node("%CreditsButton") as Button
	assert_eq(button.text, "Ver créditos")
	assert_true(button.is_visible_in_tree())
	button.pressed.emit()
	assert_true(options.credits.is_open(), "abre los créditos de siempre")
	assert_true(options.credits.lines().size() > 0, "con su texto")
	options.credits.close()
	assert_false(options.credits.is_open())
	assert_true(options.visible, "y vuelve a Opciones")


func test_credits_section_sits_after_display_and_before_admin() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var options: OptionsMenu = _options()
	var rows: Control = options.get_node("Center/Panel/Margin/Frame/Scroll/Columns/Rows")
	var names: Array[String] = []
	for child: Node in rows.get_children():
		names.append(child.name)
	assert_gt(names.find("CreditsSection"), names.find("UiModeSelector"), "después de «Visualización»")
	assert_lt(names.find("CreditsSection"), names.find("AdminSection"), "antes de «Administración»")


func test_credits_section_is_in_the_right_column_on_mobile() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var options: OptionsMenu = _options()
	var side: Control = options.get_node("%Side")
	assert_not_null(side.get_node_or_null("CreditsSection"))
	assert_not_null(side.get_node_or_null("CreditsButton"))
