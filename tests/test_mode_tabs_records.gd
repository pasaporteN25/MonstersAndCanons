# T473 (RF-694, D-202): solapas alcanzables con cinco modos propios y récords por modo, sin mezclarlos.
# Usa carpetas de prueba para los modos y un guardado de prueba; nunca cambia de pantalla.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const RECORDS_SCENE: PackedScene = preload("res://scenes/ui/records_screen.tscn")
const OFFICIAL: String = "user://test_t473_official/"
const USER: String = "user://test_t473_user/"
const COMMUNITY: String = "user://test_t473_community/"
const TEST_SAVE: String = "user://test_t473_save.json"
const OWN_IDS: Array[String] = ["propio1", "propio2", "propio3", "propio4", "propio5"]

var _viewport: SubViewport
var _original_mode: Variant


func before_each() -> void:
	for dir: String in [OFFICIAL, USER, COMMUNITY]:
		_remove(dir)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	GameFlow.select_page = &"campaign"
	GameFlow.select_map_index = -1
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	for dir: String in [OFFICIAL, USER, COMMUNITY]:
		_remove(dir)
	GameFlow.select_page = &"campaign"
	GameFlow.select_map_index = -1
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	DirAccess.remove_absolute(dir)


func _mode(root: String, id: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ModePacks.dir_of(root, id))
	var file := FileAccess.open(ModePacks.dir_of(root, id) + ModePacks.FILE_NAME, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _five_own_modes() -> void:
	_mode(OFFICIAL, "asedio", '{"version": 1, "nombre": "Asedio", "mapas": ["level_01", "level_02"]}')
	for id: String in OWN_IDS:
		_mode(USER, id, '{"version": 1, "nombre": "Modo %s", "mapas": ["level_01", "level_02", "level_03"]}' % id)


func _open_select(host: Node = null) -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = OFFICIAL
	select.modes_user_dir = USER
	select.folder_opener = func(_path: String) -> void: pass
	(host if host != null else self).add_child(select)
	autofree(select)
	return select


func _open_records() -> Control:
	var screen: Control = RECORDS_SCENE.instantiate()
	screen.modes_official_dir = OFFICIAL
	screen.modes_user_dir = USER
	add_child_autofree(screen)
	return screen


func _key(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	_viewport.push_input(event)


# --- Lógica pura: RecordSources ---

func test_sources_use_the_saved_ids_of_each_map() -> void:
	_five_own_modes()
	var sources: Array[Dictionary] = RecordSources.from_modes(ModePacks.all(OFFICIAL, USER))
	assert_eq(sources.size(), 6, "Asedio y cinco propios")
	assert_eq(sources[0]["id"], &"asedio")
	assert_eq((sources[0]["maps"] as Array).size(), 2)
	assert_eq(sources[0]["maps"][1]["table_id"], &"modo_asedio_level_02")
	assert_eq(sources[3]["maps"][2]["table_id"], &"modo_propio3_level_03")
	assert_ne(sources[0]["maps"][0]["table_id"], sources[1]["maps"][0]["table_id"], "dos modos no comparten tabla")


func test_a_mode_with_errors_has_a_diagnosis_and_no_table_to_read() -> void:
	_mode(USER, "roto", "{esto no es json")
	var sources: Array[Dictionary] = RecordSources.from_modes(ModePacks.all(OFFICIAL, USER))
	assert_eq(sources.size(), 1)
	assert_false((sources[0]["errors"] as PackedStringArray).is_empty())
	assert_eq((sources[0]["maps"] as Array).size(), 0, "no se intenta leer ningún registro")
	assert_eq(sources[0]["name"], "roto")


func test_a_map_that_does_not_load_has_a_reason_and_an_empty_id() -> void:
	_mode(USER, "mixto", '{"version": 1, "nombre": "Mixto", "mapas": ["level_01", "no_existe"]}')
	var sources: Array[Dictionary] = RecordSources.from_modes(ModePacks.all(OFFICIAL, USER))
	var maps: Array = sources[0]["maps"]
	if maps.is_empty():
		# El modo entero puede quedar con errores si el mapa no existe: tampoco hay nada que leer.
		assert_false((sources[0]["errors"] as PackedStringArray).is_empty())
	else:
		assert_eq(maps[1]["table_id"], &"")
		assert_ne(maps[1]["error"], "")


func test_no_modes_no_sources() -> void:
	assert_eq(RecordSources.from_modes(ModePacks.all(OFFICIAL, USER)).size(), 0)


# --- Solapas ---

func test_order_is_campaign_official_community_then_own() -> void:
	_five_own_modes()
	var select: Control = _open_select()
	await get_tree().process_frame
	var expected: Array[StringName] = [&"campaign", &"mode:asedio", &"community"]
	for id: String in OWN_IDS:
		expected.append(StringName("mode:" + id))
	assert_eq(select.page_order(), expected)
	var names: PackedStringArray = []
	for child: Node in (select.get_node("%TabRow") as Control).get_children():
		names.append((child as Button).text)
	assert_eq(names[0], "Campaña")
	assert_eq(names[1], "Asedio")
	assert_eq(names[3], "Modo propio1", "los propios van después de Comunidad")
	assert_eq(names.size(), 8)


func test_every_tab_is_reachable_by_scrolling_and_by_mouse() -> void:
	_five_own_modes()
	var select: Control = _open_select()
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll: ScrollContainer = select.get_node("%TabScroll")
	var content_width: float = (select.get_node("%TabRow") as Control).size.x
	assert_gt(content_width, scroll.size.x, "no entran todas: hace falta desplazar")
	for page: StringName in select.page_order():
		(select.tab_button(page) as Button).pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		assert_eq(select.current_page(), page)
		assert_eq(GameFlow.select_page, page, "RF-225")
		var tab: Button = select.tab_button(page)
		assert_true(tab.button_pressed)
		var left: float = tab.global_position.x - scroll.global_position.x
		assert_gte(left, -1.0, "la solapa activa se ve entera (borde izquierdo): %s" % page)
		assert_lte(left + tab.size.x, scroll.size.x + 1.0, "la solapa activa se ve entera (borde derecho): %s" % page)


func test_keyboard_steps_through_all_tabs_and_wraps() -> void:
	_five_own_modes()
	var select: Control = _open_select(_viewport)
	await get_tree().process_frame
	var order: Array[StringName] = select.page_order()
	for i: int in range(1, order.size()):
		_key(&"ui_page_down")
		await get_tree().process_frame
		assert_eq(select.current_page(), order[i])
	_key(&"ui_page_down")
	assert_eq(select.current_page(), order[0], "después de la última, la primera")
	_key(&"ui_page_up")
	assert_eq(select.current_page(), order[order.size() - 1], "antes de la primera, la última")


func test_touch_drag_scrolls_the_tab_row_on_the_phone() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_five_own_modes()
	var select: Control = _open_select(_viewport)
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll: ScrollContainer = select.get_node("%TabScroll")
	assert_not_null(scroll.find_child("TouchScroller", false, false), "MenuTouch le puso el desplazamiento táctil")
	assert_eq(scroll.scroll_horizontal, 0)
	var from: Vector2 = scroll.global_position + Vector2(scroll.size.x - 20.0, 20.0)
	var to: Vector2 = from - Vector2(300, 0)
	var press := InputEventMouseButton.new()
	press.position = from
	press.global_position = from
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.device = InputEvent.DEVICE_ID_EMULATION
	_viewport.push_input(press, true)
	var touch := InputEventScreenTouch.new()
	touch.position = from
	touch.pressed = true
	_viewport.push_input(touch, true)
	await get_tree().process_frame
	var last: Vector2 = from
	for i: int in 6:
		var point: Vector2 = from.lerp(to, float(i + 1) / 6.0)
		var drag := InputEventScreenDrag.new()
		drag.position = point
		drag.relative = point - last
		_viewport.push_input(drag, true)
		last = point
		await get_tree().process_frame
	var release := InputEventScreenTouch.new()
	release.position = to
	release.pressed = false
	_viewport.push_input(release, true)
	await get_tree().process_frame
	assert_gt(scroll.scroll_horizontal, 0, "un dedo desplazó las solapas")
	assert_eq(select.current_page(), &"campaign", "arrastrar no cambia de solapa")


func test_without_modes_the_two_tabs_still_fit_without_scrolling() -> void:
	var select: Control = _open_select()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(select.page_order(), [&"campaign", &"community"] as Array[StringName])
	var scroll: ScrollContainer = select.get_node("%TabScroll")
	assert_lte((select.get_node("%TabRow") as Control).size.x, scroll.size.x + 1.0)


func test_back_to_the_same_tab_and_map_after_playing_an_own_mode() -> void:
	_five_own_modes()
	GameFlow.select_page = &"mode:propio4"
	GameFlow.select_map_index = 2
	var select: Control = _open_select()
	await get_tree().process_frame
	assert_eq(select.current_page(), &"mode:propio4")
	var cards: Array[Node] = (select.get_node("%Cards") as Control).get_children()
	assert_eq(cards.size(), 3)
	assert_true((cards[2] as Button).has_focus(), "la tarjeta del mapa jugado recupera el foco")
	(select.tab_button(&"mode:propio5") as Button).pressed.emit()
	assert_eq(GameFlow.select_map_index, -1, "otra solapa: la selección anterior se olvida")


func test_a_stale_selection_does_not_break_anything() -> void:
	_five_own_modes()
	GameFlow.select_page = &"mode:propio2"
	GameFlow.select_map_index = 99  # el modo ahora tiene menos mapas
	var select: Control = _open_select()
	await get_tree().process_frame
	assert_eq(select.current_page(), &"mode:propio2")
	GameFlow.select_page = &"mode:borrado"  # la carpeta ya no existe
	var other: Control = _open_select()
	await get_tree().process_frame
	assert_eq(other.current_page(), &"campaign")


# --- Récords ---

func test_records_offers_the_campaign_and_every_installed_mode() -> void:
	_five_own_modes()
	var screen: Control = _open_records()
	assert_eq(screen.source_count(), 7, "Campaña, Asedio y cinco propios")
	assert_eq(screen.source_name(0), "Campaña")
	assert_eq(screen.source_name(1), "Asedio")
	assert_eq(screen.source_name(6), "Modo propio5")
	assert_eq(screen.current_source(), 0, "empieza en la Campaña")


func test_records_keep_campaign_and_modes_apart() -> void:
	_five_own_modes()
	SaveManager.add_score(&"level_01", "CAM", 900)
	SaveManager.add_score(&"modo_asedio_level_01", "ASE", 700)
	SaveManager.add_score(&"modo_asedio_level_01", "DOS", 600)
	SaveManager.add_score(&"modo_propio1_level_01", "UNO", 500)
	var screen: Control = _open_records()
	assert_eq(screen.table_rows(), 1, "la campaña solo tiene el suyo")
	screen.show_source(1)
	assert_eq(screen.current_table_id(), &"modo_asedio_level_01")
	assert_eq(screen.table_rows(), 2, "Asedio muestra sus dos, no los de la campaña")
	assert_eq((screen.get_node("%ModeName") as Label).text, "Asedio")
	screen.show_level(1)
	assert_eq(screen.table_rows(), 1, "el segundo mapa de Asedio no tiene récords")
	screen.show_source(2)
	assert_eq(screen.current_table_id(), &"modo_propio1_level_01")
	assert_eq(screen.table_rows(), 1)
	assert_eq(screen.current_level_index(), 0, "cambiar de modo vuelve al primer mapa")


func test_records_selector_wraps_and_buttons_work() -> void:
	_five_own_modes()
	var screen: Control = _open_records()
	(screen.get_node("%PrevModeButton") as Button).pressed.emit()
	assert_eq(screen.current_source(), 6, "antes de la Campaña, el último modo")
	(screen.get_node("%NextModeButton") as Button).pressed.emit()
	assert_eq(screen.current_source(), 0)
	screen.show_level(-1)
	assert_eq(screen.current_level_index(), 14)
	screen.show_source(1)
	screen.show_level(-1)
	assert_eq(screen.current_level_index(), 1, "Asedio de prueba tiene 2 mapas: da la vuelta en ese modo")


func test_records_without_modes_only_campaign_and_buttons_disabled() -> void:
	var screen: Control = _open_records()
	assert_eq(screen.source_count(), 1)
	assert_true((screen.get_node("%NextModeButton") as Button).disabled)
	screen.show_source(3)
	assert_eq(screen.current_source(), 0)


func test_records_show_the_diagnosis_of_an_invalid_mode_and_read_nothing() -> void:
	_mode(USER, "roto", "{esto no es json")
	SaveManager.add_score(&"modo_roto_level_01", "FAN", 999)  # un registro huérfano no se muestra
	var screen: Control = _open_records()
	assert_eq(screen.source_count(), 2)
	screen.show_source(1)
	assert_eq(screen.current_table_id(), &"")
	assert_ne(screen.diagnosis_text(), "")
	assert_false((screen.get_node("%TablePanel") as Control).visible)
	screen.show_source(0)
	assert_eq(screen.diagnosis_text(), "")
	assert_true((screen.get_node("%TablePanel") as Control).visible)


func test_records_do_not_touch_the_hall_of_fame_or_the_scores() -> void:
	_five_own_modes()
	SaveManager.add_score(&"modo_asedio_level_01", "ASE", 700)
	var before: Array = SaveManager.scores(&"modo_asedio_level_01")
	var hall_before: Array = GameFlow.hall_of_fame()
	var screen: Control = _open_records()
	for i: int in screen.source_count():
		screen.show_source(i)
	assert_eq(SaveManager.scores(&"modo_asedio_level_01"), before)
	assert_eq(GameFlow.hall_of_fame(), hall_before, "ver los modos no suma al Salón de la fama")


func test_records_page_keys_change_mode() -> void:
	_five_own_modes()
	var screen: Control = _open_records()
	var event := InputEventAction.new()
	event.action = &"ui_page_down"
	event.pressed = true
	screen._unhandled_input(event)
	assert_eq(screen.current_source(), 1)
	event.action = &"ui_page_up"
	screen._unhandled_input(event)
	assert_eq(screen.current_source(), 0)
