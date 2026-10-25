# Tests de la interacción del mapa planetario (M76, T470, RF-687 a RF-690, D-199): clic y toque solo seleccionan,
# «Jugar» y Enter confirman una vez, las bloqueadas nunca inician, las tarjetas conservan el clic, el desborde
# horizontal solo existe si hace falta y las áreas táctiles miden 56 px sin solaparse. Usan punteros simulados
# (`push_input`), nunca cambian de escena (el abridor de niveles es falso) y escriben solo `user://test_*.json`.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_SAVE: String = "user://test_campaign_map_input.json"
const COMMUNITY: String = "user://test_campaign_map_input_community/"

var opened: Array[int] = []
var _original_mode: Variant
## Los eventos de puntero se mandan a un `SubViewport` propio (como `test_touch_scroll.gd`): el de GUT no los enruta a la interfaz.
var _vp: SubViewport


func before_each() -> void:
	opened = []
	_vp = SubViewport.new()
	_vp.size = Vector2i(1280, 720)
	add_child_autofree(_vp)
	_original_mode = SaveManager.get_setting("ui_mode")
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
	SaveManager.set_setting("ui_mode", _original_mode)


func _open(style: int = CampaignMap.STYLE_MAP) -> Control:
	SaveManager.set_setting("selector_style", style)
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = COMMUNITY + "official/"
	select.modes_user_dir = COMMUNITY + "user/"
	select.level_opener = func(index: int) -> void: opened.append(index)
	_vp.add_child(select)
	await get_tree().process_frame
	await get_tree().process_frame
	return select


func _view(select: Control) -> CampaignMapView:
	return select.map_view


func _mouse(position: Vector2, pressed: bool, double_click: bool = false, device: int = 0) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.double_click = double_click
	event.position = position
	event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.device = device
	_vp.push_input(event, true)


func _move(position: Vector2, device: int = 0) -> void:
	var event := InputEventMouseMotion.new()
	event.device = device
	event.position = position
	event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	_vp.push_input(event, true)


func _center(region: CampaignRegion) -> Vector2:
	return region.get_global_rect().get_center()


func _click(region: CampaignRegion, double_click: bool = false) -> void:
	_mouse(_center(region), true, double_click)
	_mouse(_center(region), false)


func _key(keycode: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	event.echo = echo
	_vp.push_input(event, true)


# --- Clic y toque: solo seleccionan (RF-688) ---

func test_single_click_selects_without_starting() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	_click(view.region(1))
	assert_eq(view.selected_index(), 1)
	assert_eq(opened.size(), 0)
	assert_true(view.selection_name().contains("02"), "la ficha se actualiza")


func test_repeated_and_double_click_never_start() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	_click(view.region(1))
	_click(view.region(1))
	_click(view.region(1), true)
	_mouse(_center(view.region(1)), true, true)
	_mouse(_center(view.region(1)), false)
	assert_eq(view.selected_index(), 1)
	assert_eq(opened.size(), 0, "ni el segundo clic ni el doble clic inician")


func test_click_on_a_locked_region_shows_detail_and_never_starts() -> void:
	SaveManager.unlock(GameFlow.level(5).id)  # el 6 abierto descubre la zona B: el 7 queda visible, con candado (RF-710)
	var view: CampaignMapView = _view(await _open())
	_click(view.region(6))
	_click(view.region(6), true)
	assert_eq(view.selected_index(), 6)
	assert_true(view.selection_status().contains("Ganá el nivel anterior"))
	assert_false(view.selection_status().to_lower().contains("bloqueada"))
	assert_true(view.play_button().disabled)
	assert_eq(view.play_button().text, "Jugar")
	assert_eq(opened.size(), 0)


# --- Jugar y Enter confirman una sola vez ---

func test_play_button_starts_selected_region_once() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	_click(view.region(1))
	var play: Button = view.play_button()
	_mouse(play.get_global_rect().get_center(), true)
	_mouse(play.get_global_rect().get_center(), false)
	assert_eq(opened, [1] as Array[int])


func test_level_select_rechecks_unlock_before_opening() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	view.pointer_select(1)
	SaveManager.load_save()  # el mapa quedó con el nivel abierto, pero el guardado cambió antes de confirmar
	view.request_selected()
	assert_eq(opened.size(), 0, "LevelSelect vuelve a comprobar el desbloqueo actual")


func test_play_button_on_locked_region_does_nothing() -> void:
	var view: CampaignMapView = _view(await _open())
	_click(view.region(3))
	var play: Button = view.play_button()
	_mouse(play.get_global_rect().get_center(), true)
	_mouse(play.get_global_rect().get_center(), false)
	view.request_selected()
	assert_eq(opened.size(), 0)


func test_enter_starts_focused_open_region_exactly_once_even_with_key_repeat() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	view.region(1).grab_focus()
	_key(KEY_ENTER, true)
	_key(KEY_ENTER, true, true)
	_key(KEY_ENTER, true, true)
	_key(KEY_ENTER, false)
	assert_eq(opened, [1] as Array[int])


func test_enter_on_locked_region_never_starts_even_after_a_click() -> void:
	var view: CampaignMapView = _view(await _open())
	_click(view.region(4))
	assert_true(view.region(4).has_focus(), "el clic también enfoca")
	_key(KEY_ENTER, true)
	_key(KEY_ENTER, false)
	assert_eq(opened.size(), 0)


func test_click_then_enter_starts_the_clicked_region() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	SaveManager.unlock(GameFlow.level(2).id)
	var view: CampaignMapView = _view(await _open())
	_click(view.region(1))
	_key(KEY_ENTER, true)
	_key(KEY_ENTER, false)
	assert_eq(opened, [1] as Array[int])


# --- Arrastre desde una región (RF-690) ---

func test_drag_from_a_region_does_not_select_on_release() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	var start: Vector2 = _center(view.region(1))
	view.select(0)
	_mouse(start, true)
	_move(start + Vector2(40, 0))  # más que el umbral
	_mouse(start + Vector2(40, 0), false)
	assert_eq(view.selected_index(), 0, "soltar tras arrastrar no selecciona")
	_mouse(start, true)
	_move(start + Vector2(40, 0))
	_move(start)  # vuelve al mismo lugar: igual era un arrastre
	_mouse(start, false)
	assert_eq(view.selected_index(), 0)
	assert_eq(opened.size(), 0)


func test_tiny_jitter_within_the_threshold_still_selects() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	view.select(0)
	var start: Vector2 = _center(view.region(1))
	_mouse(start, true)
	_move(start + Vector2(float(MobileUiConfig.load_from().get_value("scroll_umbral_px")), 0))  # justo en el umbral
	_mouse(start, false)
	assert_eq(view.selected_index(), 1, "el umbral es el de MenuTouch: hasta él, todavía es un toque")


func test_release_outside_the_region_does_not_select() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	view.select(0)
	var start: Vector2 = _center(view.region(1))
	_mouse(start, true)
	_mouse(start + Vector2(0, 200), false)
	assert_eq(view.selected_index(), 0)


# --- Tarjetas: un clic ---

func test_cards_keep_starting_with_one_click() -> void:
	var select: Control = await _open(CampaignMap.STYLE_CARDS)
	assert_null(select.map_view)
	var cards: Array[Node] = select.get_node("%Cards").get_children()
	assert_eq(cards.size(), 15)
	for i: int in [0, 7]:
		var found: bool = false
		for connection: Dictionary in (cards[i] as Button).pressed.get_connections():
			var callable: Callable = connection["callable"]
			if callable.get_method() == &"start_level":
				assert_eq(callable.get_bound_arguments(), [i], "la tarjeta %d inicia su nivel directo" % [i + 1])
				found = true
		assert_true(found, "tarjeta %d" % [i + 1])


# --- Geometría de los puntos táctiles (RF-550, RF-690) ---

func test_regions_are_at_least_56_px_and_do_not_overlap() -> void:
	var view: CampaignMapView = _view(await _open())
	assert_eq(view.region_count(), 15)
	var canvas := Rect2(Vector2.ZERO, view.canvas().custom_minimum_size)
	for i: int in 15:
		var box: Rect2 = view.region(i).get_rect()
		assert_gte(box.size.x, 56.0, "ancho de %d" % [i + 1])
		assert_gte(box.size.y, 56.0, "alto de %d" % [i + 1])
		assert_true(canvas.encloses(box), "la región %d cabe en el lienzo" % [i + 1])
		for j: int in range(i + 1, 15):
			# El área que responde es el círculo inscrito: dos no se superponen si sus centros distan lo que un diámetro.
			var gap: float = box.get_center().distance_to(view.region(j).get_rect().get_center())
			assert_gte(gap, (box.size.x + view.region(j).size.x) / 2.0, "%d y %d no se superponen" % [i + 1, j + 1])
	assert_gte(view.play_button().size.y, 56.0)
	assert_gte(view.play_button().size.x, 56.0)


func test_regions_stay_56_px_in_mobile_mode() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var select: Control = await _open()
	var view: CampaignMapView = _view(select)
	assert_not_null(view, "RF-687: el celular también abre en el mapa")
	assert_true(select.get_node("%StyleSwitch").visible, "y puede volver a tarjetas")
	for i: int in 15:
		assert_gte(view.region(i).size.x, 56.0)
		assert_gte(view.region(i).size.y, 56.0)
		assert_gte(view.region(i).custom_minimum_size.y, 56.0)
	assert_gte(view.play_button().custom_minimum_size.y, 56.0)


# --- Desborde y lienzo (RF-690) ---

func test_canvas_fits_and_no_scroll_is_forced_at_normal_width() -> void:
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, CampaignMapView.CANVAS_SIZE.x)  # T471: el atlas mide 1.414 px; el «ancho normal» ya no lo contiene
	assert_false(view.overflows())
	var bar: ScrollBar = view.map_scroll().get_h_scroll_bar()
	assert_false(bar.visible, "sin desborde no aparece barra")
	assert_eq(view.map_scroll().scroll_horizontal, 0)
	view.map_scroll().scroll_horizontal = 300
	assert_eq(view.map_scroll().scroll_horizontal, 0, "no hay a dónde desplazar")
	var before: Vector2 = view.region(0).global_position
	_mouse_wheel(_center(view.region(0)), MOUSE_BUTTON_WHEEL_DOWN)
	assert_eq(view.region(0).global_position, before, "la rueda no mueve nada sin desborde")


func _mouse_wheel(position: Vector2, button: MouseButton) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = pressed
		event.position = position
		event.global_position = position
		_vp.push_input(event, true)


func _narrow(view: CampaignMapView, width: float) -> void:
	view.custom_minimum_size.x = width
	view.size.x = width
	await get_tree().process_frame
	await get_tree().process_frame


func test_narrow_width_scrolls_only_horizontally_and_keeps_the_card_fixed() -> void:
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 700.0)
	var panel_before: Rect2 = view.info_panel().get_global_rect()
	assert_true(view.overflows())
	assert_true(view.map_scroll().get_h_scroll_bar().visible)
	assert_eq(view.map_scroll().vertical_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)
	assert_false(view.map_scroll().is_ancestor_of(view.info_panel()), "la ficha no está en el lienzo")
	assert_false(view.map_scroll().is_ancestor_of(view.play_button()), "«Jugar» tampoco")
	view.map_scroll().scroll_horizontal = 250
	await get_tree().process_frame
	assert_eq(view.map_scroll().scroll_horizontal, 250)
	assert_eq(view.info_panel().get_global_rect().position, panel_before.position, "la ficha no se desplaza")
	assert_eq(view.info_panel().size.x, 700.0)
	assert_true(Rect2(Vector2.ZERO, view.info_panel().size).encloses(view.play_button().get_rect()), "Jugar sigue dentro y visible")


func test_wheel_scrolls_horizontally_when_it_overflows() -> void:
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 700.0)
	view.map_scroll().scroll_horizontal = 0
	_mouse_wheel(_center(view.region(0)), MOUSE_BUTTON_WHEEL_DOWN)
	assert_gt(view.map_scroll().scroll_horizontal, 0)
	var after_down: int = view.map_scroll().scroll_horizontal
	_mouse_wheel(_center(view.region(0)), MOUSE_BUTTON_WHEEL_UP)
	assert_lt(view.map_scroll().scroll_horizontal, after_down)
	for _i: int in 30:
		_mouse_wheel(Vector2(400, 300), MOUSE_BUTTON_WHEEL_DOWN)
	var max_scroll: int = int(view.map_scroll().get_h_scroll_bar().max_value - view.map_scroll().get_h_scroll_bar().page)
	assert_lte(view.map_scroll().scroll_horizontal, max_scroll + 1, "no se pasa del borde")


func test_focus_and_selection_bring_the_region_into_view() -> void:
	for i: int in range(1, 14):
		SaveManager.unlock(GameFlow.level(i).id)
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 600.0)
	view.map_scroll().scroll_horizontal = 0
	view.region(13).grab_focus()
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll: ScrollContainer = view.map_scroll()
	var box: Rect2 = view.region(13).get_rect()
	assert_gte(box.position.x, float(scroll.scroll_horizontal), "el borde izquierdo está a la vista")
	assert_lte(box.end.x, scroll.scroll_horizontal + scroll.size.x, "el borde derecho está a la vista")
	view.select(0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(scroll.scroll_horizontal, 0, "volver al primero lo trae de vuelta")


func test_opening_with_the_selection_far_east_shows_it() -> void:
	for i: int in range(1, 14):
		SaveManager.unlock(GameFlow.level(i).id)
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 600.0)
	view.select(13)
	await get_tree().process_frame
	await get_tree().process_frame
	var box: Rect2 = view.region(13).get_rect()
	assert_lte(box.end.x, view.map_scroll().scroll_horizontal + view.map_scroll().size.x)


# --- Un dedo (RF-690) ---

func _touch(position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	_vp.push_input(event, true)


func _drag_finger(position: Vector2, relative: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	event.relative = relative
	_vp.push_input(event, true)


func test_one_finger_drag_scrolls_without_selecting_or_starting() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 700.0)
	assert_not_null(view.map_scroll().find_child("TouchScroller", false, false), "MenuTouch le pone el desplazamiento táctil")
	view.select(0)
	var start: Vector2 = _center(view.region(1))
	_mouse(start, true, false, InputEvent.DEVICE_ID_EMULATION)  # el clic emulado llega antes que el toque (TouchScroller, T289)
	_touch(start, true)
	var at: Vector2 = start
	for _i: int in 6:
		at += Vector2(-30, 0)
		_drag_finger(at, Vector2(-30, 0))
		_move(at, InputEvent.DEVICE_ID_EMULATION)
	_touch(at, false)
	_mouse(at, false, false, InputEvent.DEVICE_ID_EMULATION)
	assert_gt(view.map_scroll().scroll_horizontal, 0, "el dedo desplazó el lienzo")
	assert_eq(view.selected_index(), 0, "arrastrar desde una región no selecciona al soltar")
	assert_eq(opened.size(), 0)
	assert_true(view.play_button().is_visible_in_tree(), "«Jugar» sigue accesible")


func test_tap_below_the_threshold_selects_while_the_canvas_overflows() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, 700.0)
	view.select(0)
	var start: Vector2 = _center(view.region(1))
	_mouse(start, true, false, InputEvent.DEVICE_ID_EMULATION)
	_touch(start, true)
	_drag_finger(start + Vector2(3, 0), Vector2(3, 0))  # por debajo del umbral
	_touch(start + Vector2(3, 0), false)
	_mouse(start + Vector2(3, 0), false, false, InputEvent.DEVICE_ID_EMULATION)
	assert_eq(view.map_scroll().scroll_horizontal, 0)
	assert_eq(view.selected_index(), 1, "el toque corto selecciona")
	assert_eq(opened.size(), 0, "y no inicia")
	assert_false(view.play_button().disabled)


func test_no_touch_scroller_steals_the_finger_when_everything_fits() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	SaveManager.unlock(GameFlow.level(1).id)
	var view: CampaignMapView = _view(await _open())
	await _narrow(view, CampaignMapView.CANVAS_SIZE.x)
	assert_false(view.overflows())
	view.select(0)
	var start: Vector2 = _center(view.region(1))
	_mouse(start, true, false, InputEvent.DEVICE_ID_EMULATION)
	_touch(start, true)
	_touch(start, false)
	_mouse(start, false, false, InputEvent.DEVICE_ID_EMULATION)
	assert_eq(view.selected_index(), 1, "sin desborde el toque llega directo a la región")
	assert_eq(view.map_scroll().scroll_horizontal, 0)
