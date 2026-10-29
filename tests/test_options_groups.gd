# Solapas de Opciones (RF-708, T481): categorías, filas, modo celular y preferencias intactas.
# Guardado de prueba: no se toca el verdadero.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_options_groups.json"
const WINDOW: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
const PC_TABS: Array[String] = ["Sonido", "Pantalla", "Partida\ny ayudas", "Controles", "Avanzado"]
const MOBILE_TABS: Array[String] = ["Sonido", "Pantalla", "Partida\ny ayudas", "Avanzado"]
const SETTING_KEYS: Array[String] = ["music_volume", "sfx_volume", "fullscreen", "damage_numbers", "upgrade_fx",
	"range_display", "ui_mode", "tutorial_enabled", "boss_entrance", "defeat_advice"]

var _viewport: SubViewport
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	_remove_save()
	DevMode.set_enabled(false, TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	DevMode.set_enabled(false, TEST_SAVE)
	_remove_save()
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func _remove_save() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)


func _open(mode: int, from_main_menu: bool = true) -> OptionsMenu:
	SaveManager.set_setting("ui_mode", mode)
	var options: OptionsMenu = OPTIONS_SCENE.instantiate() as OptionsMenu
	options.admin_available = from_main_menu
	_viewport.add_child(options)
	options.open()
	return options


func _wait_layout() -> void:
	for i: int in 3:
		await get_tree().process_frame


func _names(container: Node) -> Array[String]:
	var names: Array[String] = []
	for child: Node in container.get_children():
		names.append(String(child.name))
	return names


func _tab_texts(options: OptionsMenu) -> Array[String]:
	var result: Array[String] = []
	for button: Button in options._tab_buttons:
		result.append(button.text)
	return result


func test_every_option_row_is_declared_in_exactly_one_tab() -> void:
	var seen: Dictionary = {}
	for group: Array in OptionsMenu.OPTION_GROUP_ROWS:
		for node_name: StringName in group:
			assert_false(seen.has(node_name), "«%s» está en una sola solapa" % node_name)
			seen[node_name] = true
	assert_eq(seen.size(), 24, "22 filas de siempre + las 2 del selector de idioma (T534)")


func test_pc_shows_five_tabs_and_keeps_the_rows_in_their_pages() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	assert_eq(_tab_texts(options), PC_TABS)
	assert_eq(_names(options._group_pages[0]), ["MusicLabel", "MusicSlider", "SfxLabel", "SfxSlider"])
	assert_eq(_names(options._group_pages[1]), ["FullscreenCheck", "DamageNumbersCheck", "UpgradeFxCheck", "RangeDisplayLabel", "RangeDisplaySelector"])
	assert_eq(_names(options._group_pages[2]), ["TutorialRow", "BossEntranceCheck", "DefeatAdviceCheck"])
	assert_eq(_names(options._group_pages[3]), ["ViewAllRow"])
	assert_eq(_names(options._group_pages[4]), ["UiModeLabel", "UiModeSelector", "CreditsSection", "VersionLabel", "CreditsButton", "NewsButton", "AdminSection", "AdminButton", "AdminConfirm"])


func test_tabs_switch_pages_and_have_one_selected_tab() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	options._select_tab(2)
	assert_true(options._group_pages[2].visible)
	assert_false(options._group_pages[0].visible)
	assert_true(options._tab_buttons[2].button_pressed)
	assert_false(options._tab_buttons[0].button_pressed)


func test_mobile_shows_four_tabs_without_controls_or_keyboard_binding() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	assert_eq(_tab_texts(options), MOBILE_TABS)
	assert_eq(options._group_pages.size(), 4)
	assert_null(options.find_child("ViewAllRow", true, false))
	options._select_tab(3)
	assert_true(options._group_pages[3].visible)
	assert_eq(options._group_pages[3].name, "OptionsPage4")


func test_interface_is_in_advanced_and_defaults_to_automatic() -> void:
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.AUTOMATIC)
	var options: OptionsMenu = _open(UiMode.AUTOMATIC)
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	assert_eq(selector.get_selected_id(), UiMode.AUTOMATIC)
	assert_eq(selector.get_item_text(0), "Automática")
	assert_eq(selector.get_parent(), options._group_pages[4])
	assert_eq(selector.get_parent().get_child(selector.get_index() - 1).name, &"UiModeLabel")


func test_interface_choice_is_saved_and_shown_again_from_advanced() -> void:
	var options: OptionsMenu = _open(UiMode.AUTOMATIC)
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	selector.select(2)
	selector.item_selected.emit(2)
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.PC)
	options.open()
	assert_eq(selector.get_selected_id(), UiMode.PC)


func test_saved_options_keep_their_values_after_opening_and_closing() -> void:
	SaveManager.set_setting("music_volume", 0.35)
	SaveManager.set_setting("sfx_volume", 0.55)
	SaveManager.set_setting("fullscreen", false)
	SaveManager.set_setting("damage_numbers", false)
	SaveManager.set_setting("upgrade_fx", false)
	SaveManager.set_setting("range_display", 2)
	SaveManager.set_setting("tutorial_enabled", false)
	SaveManager.set_setting("boss_entrance", false)
	SaveManager.set_setting("defeat_advice", false)
	for mode: int in [UiMode.PC, UiMode.MOBILE]:
		SaveManager.set_setting("ui_mode", mode)
		SaveManager.save()
		var before: Dictionary = {}
		for key: String in SETTING_KEYS:
			before[key] = SaveManager.get_setting(key)
		var options: OptionsMenu = _open(mode)
		assert_almost_eq((options.get_node("%MusicSlider") as HSlider).value, 0.35, 0.001)
		assert_almost_eq((options.get_node("%SfxSlider") as HSlider).value, 0.55, 0.001)
		assert_false((options.get_node("%DamageNumbersCheck") as CheckBox).button_pressed)
		assert_false((options.get_node("%UpgradeFxCheck") as CheckBox).button_pressed)
		assert_eq((options.find_child("RangeDisplaySelector", true, false) as OptionButton).get_selected_id(), 2)
		assert_false((options.find_child("TutorialCheck", true, false) as CheckBox).button_pressed)
		assert_false((options.find_child("BossEntranceCheck", true, false) as CheckBox).button_pressed)
		assert_false((options.find_child("DefeatAdviceCheck", true, false) as CheckBox).button_pressed)
		assert_eq((options.find_child("UiModeSelector", true, false) as OptionButton).get_selected_id(), mode)
		options.close()
		SaveManager.load_save()
		for key: String in SETTING_KEYS:
			assert_eq(SaveManager.get_setting(key), before[key], "«%s» conserva su valor (%s)" % [key, mode])
		options.queue_free()


func test_pc_panel_fits_in_720_and_scrolls_if_the_content_is_taller() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	await _wait_layout()
	_assert_fits_or_scrolls(options, "PC")


func test_mobile_panel_fits_in_720_and_scrolls_if_the_content_is_taller() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	await _wait_layout()
	_assert_fits_or_scrolls(options, "celular simulado")
	assert_not_null((options.get_node("%Scroll") as ScrollContainer).find_child("TouchScroller", false, false))


func _assert_fits_or_scrolls(options: OptionsMenu, what: String) -> void:
	var panel: Control = options.get_node("%Panel")
	var scroll: ScrollContainer = options.get_node("%Scroll")
	assert_true(WINDOW.encloses(panel.get_global_rect()), "%s: el panel entra en la ventana" % what)
	assert_true(WINDOW.encloses((options.get_node("%BackButton") as Control).get_global_rect()), "%s: «Volver» queda a la vista" % what)
	var content: float = (scroll.get_child(0) as Control).get_combined_minimum_size().y
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	if content > scroll.size.y + 0.5:
		assert_gt(bar.max_value, bar.page, "%s: el contenido se desplaza" % what)
	else:
		assert_lte(content, scroll.size.y + 0.5, "%s: el contenido entra" % what)


func test_confirmation_hides_tabs_and_restores_the_active_page() -> void:
	for mode: int in [UiMode.PC, UiMode.MOBILE]:
		var options: OptionsMenu = _open(mode)
		options._select_tab(options._group_pages.size() - 1)
		options._set_confirming(true)
		assert_true(options.is_confirm_visible())
		assert_false(options._tabs.visible)
		for page: VBoxContainer in options._group_pages:
			assert_false(page.visible)
		options._set_confirming(false)
		assert_true(options._tabs.visible)
		assert_true(options._group_pages.back().visible)
		assert_false(options.is_confirm_visible())
		options.queue_free()
