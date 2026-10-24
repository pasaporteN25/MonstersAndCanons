# Opciones en cinco grupos (M75: RF-684, D-197, T468): el orden por grupo en PC y en celular, «Interfaz» en «Avanzado»
# con Automática por omisión, que las opciones guardadas conserven su valor y que el panel entre en 720 px de alto.
# Guardado de prueba: no se toca el verdadero.
extends GutTest

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_options_groups.json"
const WINDOW: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

## Lo que dice la tabla de RF-684, escrito a mano (no sale de las constantes de `OptionsMenu`).
const PC_ORDER: Array[String] = [
	"SoundSection", "MusicLabel", "MusicSlider", "SfxLabel", "SfxSlider",
	"DisplaySection", "FullscreenCheck", "DamageNumbersCheck", "UpgradeFxCheck", "RangeDisplayLabel", "RangeDisplaySelector",
	"GameSection", "TutorialRow", "BossEntranceCheck", "DefeatAdviceCheck",
	"ControlsSection", "ViewAllRow",
	"AdvancedSection", "UiModeLabel", "UiModeSelector",
	"CreditsSection", "VersionLabel", "CreditsButton", "NewsButton",
	"AdminSection", "AdminButton", "AdminConfirm",
]
const MOBILE_LEFT: Array[String] = [
	"SoundSection", "MusicLabel", "MusicSlider", "SfxLabel", "SfxSlider",
	"DisplaySection", "FullscreenCheck", "DamageNumbersCheck", "UpgradeFxCheck", "RangeDisplayLabel", "RangeDisplaySelector",
]
const MOBILE_RIGHT: Array[String] = [
	"GameSection", "TutorialRow", "BossEntranceCheck", "DefeatAdviceCheck",
	"AdvancedSection", "UiModeLabel", "UiModeSelector",
	"CreditsSection", "VersionLabel", "CreditsButton", "NewsButton",
	"AdminSection", "AdminButton", "AdminConfirm",
]
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


func _names(column: Node) -> Array[String]:
	var names: Array[String] = []
	for child: Node in column.get_children():
		names.append(String(child.name))
	return names


func _rows(options: OptionsMenu) -> Node:
	return options.get_node("Center/Panel/Margin/Frame/Scroll/Columns/Rows")


func _text_of(options: OptionsMenu, node_name: String) -> String:
	return (options.find_child(node_name, true, false) as Label).text


# --- declaración ---

func test_every_row_is_declared_in_exactly_one_group() -> void:
	var seen: Dictionary = {}
	for group: Array in OptionsMenu.PC_COLUMN:
		for node_name: StringName in group:
			assert_false(seen.has(node_name), "«%s» está en un solo grupo" % node_name)
			seen[node_name] = true
	assert_eq(seen.size(), PC_ORDER.size())
	var mobile: Array[String] = []
	for group: Array in OptionsMenu.MOBILE_LEFT_COLUMN + OptionsMenu.MOBILE_RIGHT_COLUMN:
		for node_name: StringName in group:
			mobile.append(String(node_name))
	assert_eq(mobile.size(), PC_ORDER.size() - 2, "el celular declara lo mismo menos el título y la fila de «Controles»")
	assert_false(mobile.has("ControlsSection") or mobile.has("ViewAllRow"))


# --- PC ---

func test_pc_shows_the_five_groups_in_order_with_their_rows() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	await get_tree().process_frame
	assert_null(options._side, "una sola columna")
	assert_null(options.find_child("Side", true, false), "la columna vacía se elimina")
	assert_eq(_names(_rows(options)), PC_ORDER)


func test_pc_group_titles_use_the_new_names_and_the_old_one_is_gone() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	assert_eq(_text_of(options, "SoundSection"), "Sonido")
	assert_eq(_text_of(options, "DisplaySection"), "Pantalla")
	assert_eq(_text_of(options, "GameSection"), "Partida y ayudas")
	assert_eq(_text_of(options, "ControlsSection"), "Controles")
	assert_eq(_text_of(options, "AdvancedSection"), "Avanzado")
	assert_eq(_text_of(options, "CreditsSection"), "Créditos y versión")
	assert_eq(_text_of(options, "AdminSection"), "Administración")
	for node: Node in options.find_children("*", "Label", true, false):
		assert_ne((node as Label).text, "Visualización")


func test_new_titles_look_like_the_current_ones() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	var reference: Label = options.find_child("SoundSection", true, false) as Label
	for node_name: String in ["DisplaySection", "GameSection", "ControlsSection", "AdvancedSection"]:
		var title: Label = options.find_child(node_name, true, false) as Label
		assert_eq(title.get_theme_font_size("font_size"), reference.get_theme_font_size("font_size"), node_name)
		assert_eq(title.get_theme_color("font_color"), reference.get_theme_color("font_color"), node_name)


func test_pc_admin_stays_out_of_the_pause_menu_and_the_order_does_not_change() -> void:
	var options: OptionsMenu = _open(UiMode.PC, false)
	assert_false(options.is_admin_visible())
	assert_eq(_names(_rows(options)), PC_ORDER, "las filas de administración están, ocultas")
	assert_true((options.find_child("AdvancedSection", true, false) as Control).is_visible_in_tree(), "«Avanzado» sigue por «Interfaz»")


# --- celular ---

func test_mobile_has_two_columns_and_no_controls_group() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	assert_eq(_names(_rows(options)), MOBILE_LEFT, "izquierda: Sonido y Pantalla")
	assert_eq(_names(options.get_node("%Side")), MOBILE_RIGHT, "derecha: Partida y ayudas y Avanzado")
	assert_null(options.find_child("ControlsSection", true, false), "no hay título de «Controles»")
	assert_null(options.find_child("ViewAllRow", true, false))


func test_mobile_columns_are_side_by_side_in_that_order() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	await _wait_layout()
	var left: Control = options.find_child("DisplaySection", true, false) as Control
	var right: Control = options.find_child("GameSection", true, false) as Control
	assert_gt(right.get_global_rect().position.x, left.get_global_rect().end.x - 1.0, "«Partida y ayudas» queda a la derecha")
	assert_almost_eq(right.get_global_rect().position.y, (options.find_child("SoundSection", true, false) as Control).get_global_rect().position.y, 1.0,
		"y las dos columnas empiezan arriba")


# --- Interfaz ---

func test_interface_is_in_advanced_with_automatic_by_default() -> void:
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.AUTOMATIC, "un guardado nuevo no fuerza ninguna interfaz")
	var options: OptionsMenu = _open(UiMode.AUTOMATIC)
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	assert_eq(selector.get_selected_id(), UiMode.AUTOMATIC, "Automática por omisión")
	assert_eq(selector.get_item_text(0), "Automática")
	assert_eq(selector.get_parent().get_child(selector.get_index() - 2).name, &"AdvancedSection", "debajo del título «Avanzado»")
	assert_eq(selector.get_parent().get_child(selector.get_index() - 1).name, &"UiModeLabel")


func test_interface_is_in_the_right_column_of_the_phone_under_advanced() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	assert_eq(selector.get_selected_id(), UiMode.MOBILE, "muestra lo guardado")
	assert_eq(selector.get_parent(), options.get_node("%Side"))
	assert_eq(selector.get_parent().get_child(selector.get_index() - 2).name, &"AdvancedSection")


func test_interface_choice_is_saved_and_shown_again_from_advanced() -> void:
	var options: OptionsMenu = _open(UiMode.AUTOMATIC)
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	selector.select(2)
	selector.item_selected.emit(2)
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.PC)
	options.open()
	assert_eq(selector.get_selected_id(), UiMode.PC)


# --- opciones guardadas ---

func test_saved_options_keep_their_value_after_opening_and_closing() -> void:
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


func test_a_save_without_the_newer_options_shows_their_defaults() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{},"settings":{"music_volume":0.7,"sfx_volume":0.8,"fullscreen":false,"damage_numbers":true}}')
	file.close()
	SaveManager.load_save()
	var options: OptionsMenu = _open(UiMode.PC)
	assert_true((options.find_child("TutorialCheck", true, false) as CheckBox).button_pressed)
	assert_true((options.find_child("BossEntranceCheck", true, false) as CheckBox).button_pressed)
	assert_true((options.find_child("DefeatAdviceCheck", true, false) as CheckBox).button_pressed)
	assert_true((options.get_node("%UpgradeFxCheck") as CheckBox).button_pressed)
	assert_eq((options.find_child("RangeDisplaySelector", true, false) as OptionButton).get_selected_id(), 0, "Oculto")
	assert_eq((options.find_child("UiModeSelector", true, false) as OptionButton).get_selected_id(), UiMode.PC, "se pidió PC al abrir")


func test_the_view_all_key_is_kept_in_pc() -> void:
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	prefs.view_all_key = KEY_H
	SaveManager.set_ui_prefs(prefs)
	var options: OptionsMenu = _open(UiMode.PC)
	assert_eq((options.find_child("ViewAllKeyButton", true, false) as Button).text, "H")
	options.close()
	assert_eq(SaveManager.get_ui_prefs().view_all_key, KEY_H)
	ViewAllBinding.apply(ViewAllBinding.DEFAULT_KEY)


# --- 720 px ---

func test_pc_panel_fits_in_720_and_scrolls_if_the_content_is_taller() -> void:
	var options: OptionsMenu = _open(UiMode.PC)
	await _wait_layout()
	_assert_fits_or_scrolls(options, "PC")


func test_mobile_panel_fits_in_720_and_scrolls_if_the_content_is_taller() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE)
	await _wait_layout()
	_assert_fits_or_scrolls(options, "celular")
	assert_not_null((options.get_node("%Scroll") as ScrollContainer).find_child("TouchScroller", false, false), "con el dedo se desplaza")


func test_mobile_panel_without_admin_also_fits() -> void:
	var options: OptionsMenu = _open(UiMode.MOBILE, false)
	await _wait_layout()
	_assert_fits_or_scrolls(options, "celular desde la pausa")


func _assert_fits_or_scrolls(options: OptionsMenu, what: String) -> void:
	var panel: Control = options.get_node("%Panel")
	var scroll: ScrollContainer = options.get_node("%Scroll")
	assert_true(WINDOW.encloses(panel.get_global_rect()), "%s: el panel entra en la ventana %s" % [what, panel.get_global_rect()])
	assert_true(WINDOW.encloses((options.get_node("%BackButton") as Control).get_global_rect()), "%s: «Volver» a la vista" % what)
	var content: float = (scroll.get_child(0) as Control).get_combined_minimum_size().y
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	if content > scroll.size.y + 0.5:
		assert_gt(bar.max_value, bar.page, "%s: el contenido (%.0f) no entra en %.0f y se desplaza" % [what, content, scroll.size.y])
	else:
		assert_lte(content, scroll.size.y + 0.5, "%s: entra sin desplazar" % what)
	gut.p("%s: contenido %.0f px, centro %.0f px, panel %.0f px" % [what, content, scroll.size.y, panel.size.y])


# --- confirmación del modo de pruebas ---

func test_the_confirmation_hides_every_group_and_restores_them() -> void:
	for mode: int in [UiMode.PC, UiMode.MOBILE]:
		var options: OptionsMenu = _open(mode)
		options._set_confirming(true)
		assert_true(options.is_confirm_visible())
		assert_false((options.find_child("GameSection", true, false) as Control).is_visible_in_tree(), "los títulos también se ocultan")
		assert_false((options.find_child("AdvancedSection", true, false) as Control).is_visible_in_tree())
		options._set_confirming(false)
		assert_true((options.find_child("GameSection", true, false) as Control).is_visible_in_tree())
		assert_false(options.is_confirm_visible())
		options.queue_free()
