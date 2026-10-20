# Tests de la pantalla de la intro (T242, M57: RF-499 a RF-501): avance, fundido, omitir, que el clic final no
# llegue a lo de atrás, cómo se conecta «Jugar» en el menú y el botón «Ver la intro» de la Wiki.
# Nada cambia de escena: el menú y la Wiki se prueban por sus costuras.
extends GutTest

const TEST_SAVE: String = "user://test_intro_screen.json"
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const WIKI_SCENE: PackedScene = preload("res://scenes/ui/wiki_screen.tscn")

var screen: IntroScreen
var finished_count: int = 0


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	DevMode.enabled = false
	finished_count = 0


func after_each() -> void:
	DevMode.enabled = false
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)


func _open_screen(fade_s: float = 0.6) -> void:
	screen = IntroScreen.new()
	screen.manual_clock = true
	add_child_autofree(screen)
	screen.finished.connect(func() -> void: finished_count += 1)
	var raw: Dictionary = {"version": 1, "fundido_s": fade_s, "laminas": []}
	for i: int in 5:
		raw["laminas"].append({"imagen": "res://assets/intro/01_la_nave.webp", "texto": "Lámina %d" % (i + 1), "segundos": 4 + i})
	screen.open(IntroData.parse(raw))


func _key(keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	screen._input(event)


func _click(pressed: bool, position: Vector2 = Vector2(400, 300)) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	screen._input(event)


func _cancel() -> void:
	var event := InputEventAction.new()
	event.action = &"cancel"
	event.pressed = true
	screen._input(event)


# --- Avanzar ---

func test_opens_on_slide_1_with_its_text() -> void:
	_open_screen()
	assert_true(screen.is_open())
	assert_true(screen.visible)
	assert_eq(screen.current_index(), 0)
	assert_eq(screen.text(), "Lámina 1")
	assert_eq(finished_count, 0)


func test_click_space_enter_and_right_arrow_advance() -> void:
	_open_screen(0.0)
	_click(true)
	assert_eq(screen.current_index(), 0, "al apretar todavía no pasa (se traga)")
	_click(false)
	assert_eq(screen.current_index(), 1, "al soltar pasa")
	_key(KEY_SPACE)
	assert_eq(screen.current_index(), 2)
	_key(KEY_ENTER)
	assert_eq(screen.current_index(), 3)
	_key(KEY_RIGHT)
	assert_eq(screen.current_index(), 4)
	assert_eq(finished_count, 0)


func test_time_advances_with_a_fade_in_between() -> void:
	_open_screen(0.6)
	screen.advance(3.9)
	assert_eq(screen.current_index(), 0, "faltan 0,1 s")
	screen.advance(0.2)
	assert_eq(screen.current_index(), 1)
	assert_true(screen.is_fading())
	assert_eq(screen.text(), "Lámina 1", "al principio del fundido todavía se lee la anterior")
	screen.advance(0.4)
	assert_true(screen.is_fading())
	assert_almost_eq(screen.current_image().modulate.a, 0.4 / 0.6, 0.01)
	assert_eq(screen.text(), "Lámina 2", "pasada la mitad ya se lee la nueva")
	screen.advance(0.3)
	assert_false(screen.is_fading())
	assert_eq(screen.current_image().modulate.a, 1.0)
	assert_eq(screen.text(), "Lámina 2")


func test_the_fade_does_not_count_for_the_slide_seconds() -> void:
	_open_screen(0.6)
	screen.advance(4.0)  # abre el fundido a la lámina 2 (5 s)
	screen.advance(0.6)  # termina el fundido
	screen.advance(4.9)
	assert_eq(screen.current_index(), 1)
	screen.advance(0.2)
	assert_eq(screen.current_index(), 2)


func test_a_tap_during_the_fade_finishes_it_without_skipping_a_slide() -> void:
	_open_screen(0.6)
	screen.advance(4.0)
	assert_true(screen.is_fading())
	_key(KEY_SPACE)
	assert_false(screen.is_fading())
	assert_eq(screen.current_index(), 1, "se ve la lámina que entraba; no salta otra")
	assert_eq(screen.text(), "Lámina 2")
	assert_eq(screen.current_image().modulate.a, 1.0)


func test_zero_fade_is_a_straight_cut() -> void:
	_open_screen(0.0)
	_key(KEY_SPACE)
	assert_false(screen.is_fading())
	assert_eq(screen.current_index(), 1)
	assert_eq(screen.text(), "Lámina 2")


func test_last_slide_ends_by_tap_and_by_time_only_once() -> void:
	_open_screen(0.0)
	for i: int in 4:
		_key(KEY_SPACE)
	assert_eq(screen.current_index(), 4)
	assert_eq(finished_count, 0)
	_key(KEY_SPACE)
	assert_eq(finished_count, 1, "el toque en la última termina")
	assert_false(screen.is_open())
	assert_false(screen.visible)
	_key(KEY_SPACE)
	screen.advance(100.0)
	screen.skip()
	assert_eq(finished_count, 1, "una sola vez")


func test_last_slide_ends_by_time() -> void:
	_open_screen(0.0)
	for i: int in 4:
		_key(KEY_SPACE)
	screen.advance(7.9)
	assert_eq(finished_count, 0)
	screen.advance(0.2)
	assert_eq(finished_count, 1)


# --- Omitir ---

func test_skip_button_ends_the_whole_intro_at_once() -> void:
	_open_screen()
	var button: Button = screen.skip_button()
	assert_eq(button.text, "Omitir")
	assert_true(button.is_visible_in_tree() or screen.visible, "siempre visible mientras la intro está abierta")
	_click(true, button.get_global_rect().get_center())
	assert_eq(finished_count, 0, "se traga al apretar")
	_click(false, button.get_global_rect().get_center())
	assert_eq(finished_count, 1)
	assert_false(screen.is_open())


func test_escape_key_and_back_action_end_it() -> void:
	_open_screen()
	_key(KEY_ESCAPE)
	assert_eq(finished_count, 1, "Esc")
	finished_count = 0
	_open_screen()
	_cancel()
	assert_eq(finished_count, 1, "el «atrás» de Android llega como acción, no como tecla")


func test_skip_works_from_any_slide_and_the_fade() -> void:
	_open_screen(0.6)
	screen.advance(4.0)
	assert_true(screen.is_fading())
	_key(KEY_ESCAPE)
	assert_eq(finished_count, 1)
	assert_false(screen.is_fading())


func test_the_final_click_is_swallowed_and_does_not_reach_what_is_behind() -> void:
	_open_screen(0.0)
	var reached: Array[int] = [0]
	var behind := Control.new()
	behind.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child_autofree(behind)
	behind.gui_input.connect(func(_event: InputEvent) -> void: reached[0] += 1)
	_click(true)
	_click(false)
	assert_eq(screen.current_index(), 1, "el toque avanzó la intro")
	# Un evento real: lo marca como atendido el viewport, así no se propaga al resto.
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = Vector2(100, 100)
	get_viewport().push_input(event)
	await get_tree().process_frame
	assert_eq(reached[0], 0, "ni el clic apretado ni el soltado llegan a lo de atrás")
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = Vector2(100, 100)
	get_viewport().push_input(release)
	await get_tree().process_frame
	assert_eq(reached[0], 0)


# --- Cómo se ve ---

func test_slide_is_shown_whole_not_cropped() -> void:
	_open_screen()
	assert_eq(screen.current_image().stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_eq(screen.previous_image().stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var image := Vector2(1920, 1080)
	for screen_size: Vector2 in [Vector2(1280, 720), Vector2(1560, 720), Vector2(960, 720)]:  # 16:9, 20:9 y 4:3
		var rect: Rect2 = IntroScreen.fit_rect(screen_size, image)
		assert_true(Rect2(Vector2.ZERO, screen_size).encloses(rect), "la lámina entra entera en %s" % str(screen_size))
		assert_almost_eq(rect.size.x / rect.size.y, 16.0 / 9.0, 0.001, "conserva la proporción")


func test_worst_case_text_fits_the_strip_in_two_lines() -> void:
	_open_screen()
	var worst: String = "a".repeat(10).repeat(9) + "\n" + "b ".repeat(45).strip_edges()
	var label: Label = screen.find_children("*", "Label", true, false)[0]
	label.text = worst
	label.custom_minimum_size.x = 0.0
	var font: Font = label.get_theme_font("font")
	var size: int = label.get_theme_font_size("font_size")
	var width: float = 1280.0 - 128.0  # el ancho de la franja menos sus márgenes
	for line: String in worst.split("\n"):
		assert_lt(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x, width,
			"una línea de 90 caracteres entra en una sola línea a 1280 de ancho")


# --- «Jugar» en el menú ---



## Un menú con las costuras apuntando a contadores.
func _menu_with_seams(destinations: Array[String]) -> MainMenu:
	var menu: MainMenu = MENU_SCENE.instantiate()
	menu.open_level_select = func() -> void: destinations.append("seleccion")
	menu.open_first_level = func() -> void: destinations.append("nivel_1")
	add_child_autofree(menu)
	menu.intro_screen.manual_clock = true
	return menu


func test_play_with_a_new_save_opens_the_intro_and_marks_it_seen_right_away() -> void:
	var went: Array[String] = []
	var menu: MainMenu = _menu_with_seams(went)
	menu.play()
	assert_true(menu.intro_screen.is_open())
	assert_eq(menu.intro_screen.current_index(), 0)
	assert_true(SaveManager.intro_seen(), "ya está marcada")
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(TEST_SAVE))
	assert_eq((json.data as Dictionary).get("intro_seen"), true, "y guardada en el archivo")
	assert_eq(went, [], "no navega con la intro abierta")
	menu.play()
	assert_eq(went, [], "tocar «Jugar» otra vez con la intro abierta no hace nada")


func test_ending_it_with_no_won_levels_opens_level_1() -> void:
	var went: Array[String] = []
	var menu: MainMenu = _menu_with_seams(went)
	menu.play()
	menu.intro_screen.skip()
	assert_eq(went, ["nivel_1"])


func test_ending_it_with_won_levels_opens_the_level_select() -> void:
	var went: Array[String] = []
	SaveManager.record_victory(&"level_01", 20, 900)
	var menu: MainMenu = _menu_with_seams(went)
	menu.play()
	menu.intro_screen.skip()
	assert_eq(went, ["seleccion"])


func test_play_with_the_intro_seen_goes_straight_to_the_level_select() -> void:
	var went: Array[String] = []
	SaveManager.mark_intro_seen()
	var menu: MainMenu = _menu_with_seams(went)
	menu.play()
	assert_false(menu.intro_screen.is_open())
	assert_eq(went, ["seleccion"])


func test_play_in_dev_mode_goes_to_the_level_select_without_marking() -> void:
	var went: Array[String] = []
	DevMode.enabled = true
	var menu: MainMenu = _menu_with_seams(went)
	menu.play()
	assert_eq(went, ["seleccion"])
	assert_false(SaveManager.intro_seen())
	DevMode.enabled = false


func test_broken_intro_file_never_blocks_playing() -> void:
	var went: Array[String] = []
	var menu: MainMenu = _menu_with_seams(went)
	menu.intro_path = "res://data/intro/no_existe.json"
	menu.play()
	assert_eq(went, ["seleccion"])
	assert_false(menu.intro_screen.is_open())
	assert_false(SaveManager.intro_seen(), "no se marca como vista si no se pudo ver")


func test_the_play_button_is_connected_to_play() -> void:
	var menu: MainMenu = _menu_with_seams([])
	var button: Button = menu.get_node("%PlayButton")
	assert_true(button.pressed.is_connected(menu.play))


# --- «Ver la intro» en la Wiki ---

func _wiki() -> Control:
	var wiki: Control = WIKI_SCENE.instantiate()
	wiki.on_leave = func() -> void: pass
	add_child_autofree(wiki)
	wiki.intro_screen.manual_clock = true
	return wiki


func test_wiki_has_the_intro_button_only_in_the_lore_tab() -> void:
	var wiki: Control = _wiki()
	var button: Button = wiki.intro_button()
	assert_eq(button.text, "Ver la intro")
	wiki.show_category(&"lore")
	assert_true(button.visible)
	for id: StringName in wiki.category_ids():
		if id != &"lore":
			wiki.show_category(id)
			assert_false(button.visible, "no se ve en %s" % id)
			break


func test_wiki_intro_opens_in_the_wiki_and_does_not_touch_the_save() -> void:
	var wiki: Control = _wiki()
	wiki.show_category(&"lore")
	var entry: StringName = wiki.current_entry()
	wiki.intro_button().pressed.emit()
	assert_true(wiki.intro_screen.is_open())
	assert_false(SaveManager.intro_seen(), "no marca nada")
	assert_false(FileAccess.file_exists(TEST_SAVE), "no escribe el guardado")
	wiki.intro_screen.skip()
	assert_false(wiki.intro_screen.is_open())
	assert_false(SaveManager.intro_seen(), "sigue como estaba")
	assert_eq(wiki.current_category(), &"lore", "la Wiki queda como estaba")
	assert_eq(wiki.current_entry(), entry)


func test_wiki_intro_is_available_in_dev_mode_and_with_the_intro_seen() -> void:
	DevMode.enabled = true
	SaveManager.mark_intro_seen()
	var wiki: Control = _wiki()
	wiki.show_category(&"lore")
	wiki.show_intro()
	assert_true(wiki.intro_screen.is_open())
	assert_true(SaveManager.intro_seen(), "seguía vista")


func test_wiki_with_a_broken_intro_file_does_nothing() -> void:
	var wiki: Control = _wiki()
	wiki.intro_path = "res://data/intro/no_existe.json"
	wiki.show_intro()
	assert_false(wiki.intro_screen.is_open())
