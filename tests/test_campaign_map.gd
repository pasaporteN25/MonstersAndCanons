# Tests del selector planetario 2D (M72, T428, RF-645, RF-647, RF-648, D-178, D-179): el modelo puro, la
# preferencia de estilo en `settings` y la vista con mouse y teclado. Nunca cambian de pantalla: el nivel
# se "abre" con un abridor falso (`level_opener`) y el guardado es un archivo de prueba.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_SAVE: String = "user://test_campaign_map.json"
const COMMUNITY: String = "user://test_campaign_map_community/"

var opened: Array[int] = []


func before_each() -> void:
	opened = []
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	await get_tree().process_frame
	GameFlow.select_page = &"campaign"
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _open() -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = COMMUNITY + "official/"
	select.modes_user_dir = COMMUNITY + "user/"
	select.level_opener = func(index: int) -> void: opened.append(index)
	add_child_autofree(select)
	return select


func _map_select() -> Control:
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_MAP)
	return _open()


func _progress_snapshot() -> String:
	var parts: Array[String] = []
	for i: int in GameFlow.level_count():
		var id: StringName = GameFlow.level(i).id
		parts.append("%s:%s:%s:%d:%d" % [id, SaveManager.is_unlocked(id), SaveManager.is_completed(id),
			SaveManager.best_lives(id), GameFlow.level_stars(i)])
	return ",".join(parts)


# --- Modelo puro ---

func test_state_of_covers_all_four_states() -> void:
	assert_eq(CampaignMap.state_of(false, false, 0), CampaignMap.State.LOCKED)
	assert_eq(CampaignMap.state_of(true, false, 0), CampaignMap.State.AVAILABLE)
	assert_eq(CampaignMap.state_of(true, true, 1), CampaignMap.State.REBEL)
	assert_eq(CampaignMap.state_of(true, true, 2), CampaignMap.State.REBEL)
	assert_eq(CampaignMap.state_of(true, true, 3), CampaignMap.State.TAKEN)


func test_state_of_edges() -> void:
	# Bloqueado manda aunque haya datos de victoria; una victoria sin estrellas sigue siendo presencia rebelde.
	assert_eq(CampaignMap.state_of(false, true, 3), CampaignMap.State.LOCKED)
	assert_eq(CampaignMap.state_of(true, true, 0), CampaignMap.State.REBEL)
	assert_eq(CampaignMap.state_of(true, false, 3), CampaignMap.State.AVAILABLE)


func test_states_is_deterministic_and_ordered() -> void:
	var unlocked: Array = [true, true, true, false]
	var completed: Array = [true, true, false, false]
	var stars: Array = [3, 1, 0, 0]
	var expected: Array = [CampaignMap.State.TAKEN, CampaignMap.State.REBEL, CampaignMap.State.AVAILABLE, CampaignMap.State.LOCKED]
	assert_eq(CampaignMap.states(unlocked, completed, stars), expected)
	assert_eq(CampaignMap.states(unlocked, completed, stars), expected, "misma entrada, mismo resultado")
	assert_eq(CampaignMap.states([], [], []).size(), 0)


func test_default_selection() -> void:
	var states: Array[CampaignMap.State] = [CampaignMap.State.TAKEN, CampaignMap.State.AVAILABLE, CampaignMap.State.LOCKED]
	assert_eq(CampaignMap.default_selection(states), 1)
	states = [CampaignMap.State.TAKEN, CampaignMap.State.REBEL, CampaignMap.State.LOCKED]
	assert_eq(CampaignMap.default_selection(states), 1, "sin disponibles: la última habilitada")
	assert_eq(CampaignMap.default_selection([] as Array[CampaignMap.State]), 0)


func test_geometry_has_one_point_per_region() -> void:
	assert_eq(CampaignMap.REGION_POINTS.size(), CampaignMap.REGION_COUNT)
	assert_eq(GameFlow.level_count(), CampaignMap.REGION_COUNT, "15 niveles, 15 regiones")
	assert_eq(CampaignMap.land_polygon().size(), CampaignMap.LAND_COORDS.size() / 2)
	var sea := Rect2(CampaignMap.SEA_ORIGIN, CampaignMap.SEA_SIZE)
	for point: Vector2 in CampaignMap.REGION_POINTS:
		assert_true(sea.has_point(point))


func test_state_text_is_distinct_per_state() -> void:
	var seen: Dictionary = {}
	for state: int in CampaignMap.State.values():
		seen[CampaignMap.state_text(state as CampaignMap.State)] = true
	assert_eq(seen.size(), 4)


# --- Preferencia de estilo (D-178) ---

func test_style_from_defaults_to_cards() -> void:
	assert_eq(CampaignMap.style_from(null), CampaignMap.STYLE_CARDS)
	assert_eq(CampaignMap.style_from("1"), CampaignMap.STYLE_CARDS)
	assert_eq(CampaignMap.style_from(7), CampaignMap.STYLE_CARDS)
	assert_eq(CampaignMap.style_from(1.5), CampaignMap.STYLE_CARDS)
	assert_eq(CampaignMap.style_from(true), CampaignMap.STYLE_CARDS)
	assert_eq(CampaignMap.style_from(1), CampaignMap.STYLE_MAP)
	assert_eq(CampaignMap.style_from(1.0), CampaignMap.STYLE_MAP, "JSON entrega enteros como float")


func test_old_save_without_the_key_uses_map() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": SaveManager.SAVE_VERSION, "levels": {"level_01": {"unlocked": true}},
		"settings": {"music_volume": 0.5}}))
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "RF-687/RF-689: el guardado anterior pasa al mapa")
	assert_eq(SaveManager.SAVE_VERSION, 1, "no se sube la versión del guardado")


func test_style_round_trips_through_the_file() -> void:
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_MAP)
	assert_true(SaveManager.save())
	SaveManager.load_save()
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	SaveManager.save()
	SaveManager.load_save()
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS)


func test_invalid_stored_style_reads_as_map_after_load() -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": SaveManager.SAVE_VERSION, "levels": {}, "settings": {"selector_style": "mapa"}}))
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)


# --- Escena: estados derivados del guardado ---

func test_map_shows_fifteen_regions_with_states_from_progress() -> void:
	SaveManager.record_victory(GameFlow.level(0).id, GameFlow.level(0).starting_lives, 100)  # 3 estrellas
	SaveManager.unlock(GameFlow.level(1).id)
	SaveManager.record_victory(GameFlow.level(1).id, 1, 100)  # pocas vidas: menos de 3 estrellas
	SaveManager.unlock(GameFlow.level(2).id)
	var select: Control = _map_select()
	var view: CampaignMapView = select.map_view
	assert_not_null(view)
	assert_eq(view.region_count(), 15)
	assert_eq(GameFlow.level_stars(0), 3)
	assert_true(GameFlow.level_stars(1) < 3)
	assert_eq(view.region(0).state, CampaignMap.State.TAKEN)
	assert_eq(view.region(1).state, CampaignMap.State.REBEL)
	assert_eq(view.region(2).state, CampaignMap.State.AVAILABLE)
	for i: int in range(3, 15):
		assert_eq(view.region(i).state, CampaignMap.State.LOCKED, "nivel %d" % (i + 1))
	assert_eq(view.selected_index(), 2, "arranca en el primer nivel habilitado sin victoria")
	assert_eq(select.get_node("%Cards").get_child_count(), 1, "solo el mapa, sin tarjetas")


func test_states_match_unlocks_of_cards() -> void:
	SaveManager.record_victory(GameFlow.level(0).id, GameFlow.level(0).starting_lives, 0)
	var select: Control = _map_select()
	var entries: Array[Dictionary] = select.map_entries()
	for i: int in entries.size():
		assert_eq(CampaignMap.is_open(entries[i]["state"]), GameFlow.is_level_unlocked(i), "nivel %d" % (i + 1))
		assert_eq(entries[i]["stars"], GameFlow.level_stars(i))


func test_new_save_has_only_first_region_available() -> void:
	var view: CampaignMapView = _map_select().map_view
	assert_eq(view.region(0).state, CampaignMap.State.AVAILABLE)
	assert_eq(view.region(1).state, CampaignMap.State.LOCKED)
	assert_eq(view.selected_index(), 0)


func test_locked_region_is_focusable_and_distinguishable() -> void:
	var view: CampaignMapView = _map_select().map_view
	var locked: CampaignRegion = view.region(3)  # bloqueada de la zona A (descubierta); las de zonas ocultas no admiten foco (T488)
	assert_eq(locked.focus_mode, Control.FOCUS_ALL)
	assert_true(locked.tooltip_text.contains("Bloqueada"), "el estado también está en texto")
	assert_true(view.region(0).tooltip_text.contains("Disponible"))


# --- Cambio de estilo ---

func test_map_is_the_default_and_switch_is_visible_on_desktop() -> void:
	var select: Control = _open()
	assert_not_null(select.map_view, "RF-687: guardado nuevo, mapa")
	assert_true(select.get_node("%StyleSwitch").visible)
	assert_true(select.get_node("%StyleMap").button_pressed)
	assert_false(select.get_node("%StyleCards").button_pressed)


func test_cards_can_be_chosen_and_switch_is_visible_on_desktop() -> void:
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	var select: Control = _open()
	assert_null(select.map_view)
	assert_eq(select.get_node("%Cards").get_child_count(), 15)
	assert_true(select.get_node("%StyleSwitch").visible)
	assert_true(select.get_node("%StyleCards").button_pressed)
	assert_false(select.get_node("%StyleMap").button_pressed)


func test_switch_persists_and_does_not_change_progress() -> void:
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	SaveManager.record_victory(GameFlow.level(0).id, GameFlow.level(0).starting_lives, 50)
	SaveManager.unlock(GameFlow.level(1).id)
	var before: String = _progress_snapshot()
	var select: Control = _open()
	select.get_node("%StyleMap").pressed.emit()
	assert_not_null(select.map_view)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_eq(_progress_snapshot(), before)
	select.get_node("%StyleCards").pressed.emit()
	await get_tree().process_frame
	assert_null(select.map_view)
	assert_eq(select.get_node("%Cards").get_child_count(), 15)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS)
	assert_eq(_progress_snapshot(), before)
	assert_eq(opened.size(), 0, "cambiar de estilo no abre niveles")
	# Lo elegido se conserva al volver a abrir el selector.
	select.get_node("%StyleMap").pressed.emit()
	await get_tree().process_frame
	SaveManager.load_save()
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_eq(_progress_snapshot(), before)
	assert_not_null(_open().map_view)


func test_switch_same_style_twice_is_harmless() -> void:
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	var select: Control = _open()
	select.set_style(CampaignMap.STYLE_CARDS)
	assert_null(select.map_view)
	select.set_style(CampaignMap.STYLE_MAP)
	await get_tree().process_frame
	select.set_style(CampaignMap.STYLE_MAP)
	assert_not_null(select.map_view)
	select.set_style(99)  # un valor inválido vuelve a tarjetas
	await get_tree().process_frame
	assert_null(select.map_view)


func test_other_pages_do_not_show_the_switch() -> void:
	var select: Control = _map_select()
	select.show_page(&"community")
	await get_tree().process_frame
	assert_false(select.get_node("%StyleSwitch").visible)
	assert_null(select.map_view)
	select.show_page(&"campaign")
	await get_tree().process_frame
	assert_true(select.get_node("%StyleSwitch").visible)
	assert_not_null(select.map_view)


# --- Mouse y teclado ---

func test_click_on_available_region_selects_and_play_opens_it_once() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _map_select().map_view
	view.pointer_select(1)
	assert_eq(opened.size(), 0, "RF-688: el clic solo selecciona")
	assert_eq(view.selected_index(), 1)
	view.play_button().pressed.emit()
	assert_eq(opened, [1] as Array[int])


func test_click_on_locked_region_selects_but_does_not_open() -> void:
	SaveManager.unlock(GameFlow.level(5).id)  # el 6 abierto descubre la zona B: el 8 queda visible, con candado (RF-710)
	var view: CampaignMapView = _map_select().map_view
	view.pointer_select(7)
	assert_eq(opened.size(), 0)
	assert_eq(view.selected_index(), 7)
	assert_true(view.selection_status().contains("Ganá el nivel anterior"))
	assert_false(view.selection_status().to_lower().contains("bloqueada"), "RF-688: sin repetir «bloqueada»")
	assert_eq(view.play_button().text, "Jugar", "«Jugar» siempre visible")
	assert_true(view.play_button().disabled)


func test_play_button_opens_selected_and_locked_confirm_is_ignored() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _map_select().map_view
	view.select(1)
	assert_false(view.play_button().disabled)
	view.play_button().pressed.emit()
	assert_eq(opened, [1] as Array[int])
	view.select(3)
	view.request_selected()  # confirmar con un nivel bloqueado enfocado
	assert_eq(opened.size(), 1)


func test_focus_selects_without_opening() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _map_select().map_view
	view.region(1).grab_focus()
	assert_eq(view.selected_index(), 1)
	assert_eq(opened.size(), 0)
	assert_true(view.selection_name().begins_with("2 · "), "número sin cero inicial (RF-695)")


func test_arrow_navigation_visits_all_fifteen_in_order() -> void:
	for level_index: int in range(1, 15):  # con los quince abiertos (como el modo de pruebas) las tres zonas están descubiertas
		SaveManager.unlock(GameFlow.level(level_index).id)
	var view: CampaignMapView = _map_select().map_view
	view.region(0).grab_focus()
	for i: int in 14:
		var next: Control = view.region(i).find_valid_focus_neighbor(SIDE_RIGHT)
		assert_eq(next, view.region(i + 1), "derecha desde %d" % (i + 1))
	assert_null(view.region(14).get_node_or_null(view.region(14).focus_neighbor_right))
	for i: int in range(14, 0, -1):
		assert_eq(view.region(i).find_valid_focus_neighbor(SIDE_LEFT), view.region(i - 1), "izquierda desde %d" % (i + 1))


func test_keyboard_accept_on_focused_region_opens_it() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var select: Control = _map_select()
	var view: CampaignMapView = select.map_view
	view.region(1).grab_focus()
	assert_true(view.region(1).has_focus())
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.physical_keycode = KEY_ENTER
	press.pressed = true
	get_viewport().push_input(press)
	var release := InputEventKey.new()
	release.keycode = KEY_ENTER
	release.physical_keycode = KEY_ENTER
	release.pressed = false
	get_viewport().push_input(release)
	assert_eq(opened, [1] as Array[int], "Enter abre una sola vez")


func test_keyboard_accept_on_locked_region_does_nothing() -> void:
	var select: Control = _map_select()
	var view: CampaignMapView = select.map_view
	view.region(4).grab_focus()
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.physical_keycode = KEY_ENTER
	press.pressed = true
	get_viewport().push_input(press)
	var release := InputEventKey.new()
	release.keycode = KEY_ENTER
	release.physical_keycode = KEY_ENTER
	release.pressed = false
	get_viewport().push_input(release)
	assert_eq(opened.size(), 0)
	assert_eq(view.selected_index(), 4)


func test_style_switch_buttons_are_keyboard_focusable() -> void:
	var select: Control = _open()
	assert_ne(select.get_node("%StyleCards").focus_mode, Control.FOCUS_NONE)
	assert_ne(select.get_node("%StyleMap").focus_mode, Control.FOCUS_NONE)
	assert_true(select.get_node("%StyleCards").toggle_mode)


# --- Descubrimiento por zonas (M78, T487, RF-709 a RF-711, D-209): modelo puro, sin escena ni guardado ---

func _unlocked_up_to(count: int) -> Array:
	var list: Array = []
	for i: int in CampaignMap.REGION_COUNT:
		list.append(i < count)
	return list


func test_zone_of_maps_regions_to_zones() -> void:
	assert_eq(CampaignMap.zone_of(0), CampaignMap.ZONE_A)
	assert_eq(CampaignMap.zone_of(4), CampaignMap.ZONE_A)
	assert_eq(CampaignMap.zone_of(5), CampaignMap.ZONE_B)
	assert_eq(CampaignMap.zone_of(9), CampaignMap.ZONE_B)
	assert_eq(CampaignMap.zone_of(10), CampaignMap.ZONE_C)
	assert_eq(CampaignMap.zone_of(14), CampaignMap.ZONE_C)
	assert_eq(CampaignMap.zone_of(-1), -1)
	assert_eq(CampaignMap.zone_of(15), -1)


func test_new_save_discovers_only_zone_a() -> void:
	var unlocked: Array = _unlocked_up_to(1)
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_A)
	assert_eq(CampaignMap.focusable_regions(unlocked), [0, 1, 2, 3, 4] as Array[int])
	var flags: Array[bool] = CampaignMap.discovered_regions(unlocked)
	assert_eq(flags.size(), 15)
	assert_eq(flags.count(true), 5)


func test_level_five_open_is_still_zone_a() -> void:
	assert_eq(CampaignMap.furthest_discovered_zone(_unlocked_up_to(5)), CampaignMap.ZONE_A)


func test_level_six_open_discovers_zone_b() -> void:
	var unlocked: Array = _unlocked_up_to(6)
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_B)
	assert_eq(CampaignMap.focusable_regions(unlocked).size(), 10)
	assert_true(CampaignMap.is_region_discovered(unlocked, 9))
	assert_false(CampaignMap.is_region_discovered(unlocked, 10))
	assert_eq(CampaignMap.discovered_regions(unlocked).count(true), 10)


func test_level_ten_open_keeps_zone_c_hidden() -> void:
	assert_eq(CampaignMap.furthest_discovered_zone(_unlocked_up_to(10)), CampaignMap.ZONE_B)


func test_level_eleven_open_discovers_zone_c() -> void:
	var unlocked: Array = _unlocked_up_to(11)
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_C)
	assert_eq(CampaignMap.focusable_regions(unlocked).size(), 15)
	assert_eq(CampaignMap.discovered_regions(unlocked).count(true), 15)


func test_odd_save_with_eleven_open_and_six_closed_discovers_everything_before() -> void:
	var unlocked: Array = _unlocked_up_to(0)
	unlocked[10] = true
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_C)
	assert_true(CampaignMap.is_region_discovered(unlocked, 5), "la zona B no queda oculta con la C abierta")
	assert_eq(CampaignMap.focusable_regions(unlocked).size(), 15)


func test_odd_save_with_eight_open_and_six_closed_discovers_zone_b() -> void:
	var unlocked: Array = _unlocked_up_to(0)
	unlocked[7] = true
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_B)


func test_damaged_unlocked_falls_back_to_zone_a() -> void:
	for bad: Variant in [null, "texto", 7, 3.5, {"a": true}, true]:
		assert_eq(CampaignMap.furthest_discovered_zone(bad), CampaignMap.ZONE_A, "valor: %s" % str(bad))
		assert_eq(CampaignMap.focusable_regions(bad), [0, 1, 2, 3, 4] as Array[int])
		assert_eq(CampaignMap.discovered_regions(bad).size(), 15)
		assert_false(CampaignMap.is_region_discovered(bad, 5))


func test_non_boolean_elements_count_as_locked() -> void:
	var unlocked: Array = [true, true, true, true, true, 1, "true", null, 1.0, [true], 1, "x", null, 0, 1]
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_A)
	unlocked[10] = true
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_C)


func test_array_with_other_length_than_fifteen() -> void:
	assert_eq(CampaignMap.furthest_discovered_zone([]), CampaignMap.ZONE_A)
	assert_eq(CampaignMap.discovered_regions([]).size(), 15)
	assert_eq(CampaignMap.furthest_discovered_zone([true, true, true]), CampaignMap.ZONE_A)
	var seven: Array = [false, false, false, false, false, true, true]
	assert_eq(CampaignMap.furthest_discovered_zone(seven), CampaignMap.ZONE_B)
	assert_eq(CampaignMap.focusable_regions(seven).size(), 10)
	var twelve: Array = [false, false, false, false, false, false, false, false, false, false, false, true]
	assert_eq(CampaignMap.furthest_discovered_zone(twelve), CampaignMap.ZONE_C, "un arreglo corto con el 12 abierto")
	var only_extra: Array = _unlocked_up_to(0)
	only_extra.append_array([true, true])
	assert_eq(CampaignMap.furthest_discovered_zone(only_extra), CampaignMap.ZONE_A, "más allá de 15 no cuenta")
	assert_eq(CampaignMap.discovered_regions(only_extra).size(), 15)


func test_test_mode_all_open_discovers_three_zones() -> void:
	var unlocked: Array = _unlocked_up_to(15)
	assert_eq(CampaignMap.furthest_discovered_zone(unlocked), CampaignMap.ZONE_C)
	var expected: Array[int] = []
	for i: int in 15:
		expected.append(i)
	assert_eq(CampaignMap.focusable_regions(unlocked), expected)


func test_hidden_regions_are_not_focusable() -> void:
	var unlocked: Array = _unlocked_up_to(3)
	var focusable: Array[int] = CampaignMap.focusable_regions(unlocked)
	for hidden: int in range(5, 15):
		assert_false(focusable.has(hidden))
		assert_false(CampaignMap.is_region_discovered(unlocked, hidden))
	assert_false(CampaignMap.is_region_discovered(unlocked, -1))
	assert_false(CampaignMap.is_region_discovered(unlocked, 15))


func test_discovery_never_modifies_unlocked() -> void:
	var unlocked: Array = _unlocked_up_to(6)
	var before: Array = unlocked.duplicate(true)
	CampaignMap.furthest_discovered_zone(unlocked)
	CampaignMap.discovered_regions(unlocked)
	CampaignMap.focusable_regions(unlocked)
	CampaignMap.is_region_discovered(unlocked, 8)
	assert_eq(unlocked, before)
	assert_false(unlocked[7], "descubrir la zona B no abre el nivel 8")
	assert_false(unlocked[10], "ni la zona C")
