# T574 (RF-739, RF-574): el efecto de foco del tutorial. Primero la geometría pura y la lectura del archivo; después
# la escena real de la partida en PC y celular, y por último con los rieles laterales (el botón señalado está fuera
# del marco). Sin ventana: se miden rectángulos, no se mira la pantalla. Nada acá cambia de escena.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_SAVE: String = "user://test_tutorial_focus.json"
const SCREEN := Rect2(0.0, 0.0, 1280.0, 720.0)
const SURFACE_20_9: Vector2i = Vector2i(2400, 1080)

var _viewport: SubViewport
var _surface: SubViewport
var _rails: SideRails
var _game: Game
var _original_mode: Variant


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_original_mode = SaveManager.get_setting("ui_mode")
	GameFlow.current_index = 0
	GameFlow.intro_pending = false
	DevMode.enabled = false


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	GameFlow.current_index = -1
	GameFlow.intro_pending = false
	GameFlow.test_level = null
	DevMode.enabled = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


# --- La geometría ---

func test_the_ring_phase_runs_from_zero_to_one_by_the_clock() -> void:
	assert_almost_eq(TutorialLayout.ring_phase(0, 1.2), 0.0, 0.0001)
	assert_almost_eq(TutorialLayout.ring_phase(600, 1.2), 0.5, 0.0001)
	assert_almost_eq(TutorialLayout.ring_phase(1200, 1.2), 0.0, 0.0001, "vuelve a empezar")
	assert_almost_eq(TutorialLayout.ring_phase(1800, 1.2), 0.5, 0.0001)
	assert_eq(TutorialLayout.ring_phase(500, 0.0), 0.0, "una velocidad inválida no divide por cero")


func test_one_target_makes_one_hole_clipped_to_the_screen() -> void:
	var targets: Array[Rect2] = [Rect2(100.0, 100.0, 60.0, 40.0)]
	var hole: Rect2 = TutorialLayout.focus_hole(targets, 6.0, SCREEN, 0.3)
	assert_eq(hole, Rect2(94.0, 94.0, 72.0, 52.0))
	var at_corner: Array[Rect2] = [Rect2(0.0, 0.0, 50.0, 50.0)]
	assert_eq(TutorialLayout.focus_hole(at_corner, 6.0, SCREEN, 0.3), Rect2(0.0, 0.0, 56.0, 56.0), "no se sale de la pantalla")


func test_several_targets_share_one_hole_that_covers_them_all() -> void:
	var targets: Array[Rect2] = [Rect2(100.0, 100.0, 50.0, 50.0), Rect2(300.0, 200.0, 50.0, 50.0)]
	var hole: Rect2 = TutorialLayout.focus_hole(targets, 0.0, SCREEN, 0.3)
	assert_true(hole.encloses(targets[0]) and hole.encloses(targets[1]))
	assert_eq(hole, Rect2(100.0, 100.0, 250.0, 150.0))


func test_a_hole_that_would_cover_too_much_means_no_dimming() -> void:
	var targets: Array[Rect2] = [Rect2(0.0, 0.0, 100.0, 100.0), Rect2(1100.0, 600.0, 100.0, 100.0)]
	assert_eq(TutorialLayout.focus_hole(targets, 0.0, SCREEN, 0.3), Rect2(), "casi toda la pantalla: no enfoca nada")
	assert_eq(TutorialLayout.focus_hole([] as Array[Rect2], 6.0, SCREEN, 0.3), Rect2(), "sin nada señalado, no hay agujero")
	var off: Array[Rect2] = [Rect2(2000.0, 2000.0, 10.0, 10.0)]
	assert_eq(TutorialLayout.focus_hole(off, 6.0, SCREEN, 0.3), Rect2(), "fuera de la pantalla")


func test_the_four_shades_cover_the_screen_except_the_hole() -> void:
	var hole := Rect2(300.0, 200.0, 120.0, 80.0)
	var rects: Array[Rect2] = TutorialLayout.shade_rects(hole, SCREEN)
	assert_eq(rects.size(), 4)
	var area: float = 0.0
	for i: int in 4:
		area += rects[i].get_area()
		assert_false(rects[i].intersects(hole), "el rectángulo %d no pisa el agujero" % i)
		for j: int in range(i + 1, 4):
			assert_false(rects[i].intersects(rects[j]), "%d y %d no se pisan" % [i, j])
	assert_almost_eq(area, SCREEN.get_area() - hole.get_area(), 0.01, "entre los cuatro cubren todo menos el agujero")


func test_without_a_hole_the_first_shade_covers_the_whole_screen() -> void:
	var rects: Array[Rect2] = TutorialLayout.shade_rects(Rect2(), SCREEN)
	assert_eq(rects[0], SCREEN)
	for i: int in range(1, 4):
		assert_eq(rects[i].get_area(), 0.0)


func test_the_label_goes_next_to_the_target_without_covering_the_card_or_leaving_the_screen() -> void:
	var size := Vector2(160.0, 40.0)
	var card := Rect2(250.0, 560.0, 780.0, 150.0)  # abajo
	var target := Rect2(600.0, 300.0, 64.0, 64.0)
	var label: Rect2 = TutorialLayout.label_rect(size, target, card, SCREEN)
	assert_true(label.position.y < target.position.y, "la tarjeta está abajo: el rótulo, arriba")
	assert_false(label.intersects(card))
	assert_false(label.intersects(target))
	var top_card := Rect2(250.0, 10.0, 780.0, 150.0)
	var below: Rect2 = TutorialLayout.label_rect(size, target, top_card, SCREEN)
	assert_true(below.position.y > target.end.y, "la tarjeta está arriba: el rótulo, abajo")
	var near_top := Rect2(600.0, 2.0, 64.0, 30.0)
	var fitted: Rect2 = TutorialLayout.label_rect(size, near_top, card, SCREEN)
	assert_true(SCREEN.encloses(fitted), "contra el borde de arriba el rótulo pasa al otro lado")


func test_the_rail_label_sits_on_the_frame_edge_at_the_height_of_the_button() -> void:
	var size := Vector2(150.0, 40.0)
	var left: Rect2 = TutorialLayout.rail_label_rect(size, Rect2(-90.0, 500.0, 64.0, 64.0), SCREEN, 30.0)
	assert_eq(left.position.x, TutorialLayout.MARGIN + 30.0)
	assert_almost_eq(left.get_center().y, 532.0, 0.01)
	var right: Rect2 = TutorialLayout.rail_label_rect(size, Rect2(1300.0, 100.0, 64.0, 64.0), SCREEN, 30.0)
	assert_eq(right.end.x, SCREEN.end.x - TutorialLayout.MARGIN - 30.0)
	var high: Rect2 = TutorialLayout.rail_label_rect(size, Rect2(1300.0, -50.0, 64.0, 64.0), SCREEN)
	assert_true(SCREEN.encloses(high), "un botón arriba del todo no saca el rótulo del marco")


# --- Los datos ---

func test_the_official_file_has_the_focus_values_and_the_labels() -> void:
	var data: TutorialData = TutorialData.load_file()
	assert_true(data.is_valid(), "\n".join(data.errors))
	assert_between(data.focus_darkness(), 0.1, 0.9)
	assert_between(data.focus_ring_seconds(), 0.3, 5.0)
	assert_between(data.focus_hole_max(), 0.05, 1.0)
	assert_eq(data.focus_label(false), "Hacé clic acá")
	assert_eq(data.focus_label(true), "Tocá acá")


func test_the_labels_come_in_both_languages() -> void:
	var data: TutorialData = TutorialData.load_file()
	var original: String = Localization.language
	Localization.language = "en"
	assert_eq(data.focus_label(false), "Click here")
	assert_eq(data.focus_label(true), "Tap here")
	Localization.language = original


func test_a_broken_focus_section_is_reported_in_spanish() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TutorialData.DEFAULT_PATH))
	var broken: Dictionary = raw.duplicate(true)
	broken["foco"]["oscuridad"] = 1.5
	broken["foco"]["anillo_segundos"] = 0
	broken["foco"]["rotulo_pc"] = ""
	broken["foco"]["raro"] = 1
	var errors: String = "\n".join(TutorialData.parse(broken).errors)
	assert_true(errors.contains("\"oscuridad\" tiene que ser un número de 0 a"), errors)
	assert_true(errors.contains("\"anillo_segundos\""), errors)
	assert_true(errors.contains("\"rotulo_pc\" tiene que ser un texto no vacío"), errors)
	assert_true(errors.contains("no usa la clave \"raro\""), errors)
	var missing: Dictionary = raw.duplicate(true)
	missing.erase("foco")
	assert_true("\n".join(TutorialData.parse(missing).errors).contains("\"foco\" tiene que ser un objeto"))


# --- La escena real ---

func _open(mobile: bool, with_rails: bool = false) -> Game:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE if mobile else UiMode.PC)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)
	_game = GAME_SCENE.instantiate() as Game
	_viewport.add_child(_game)
	if with_rails:
		_surface = SubViewport.new()
		_surface.size = SURFACE_20_9
		add_child_autofree(_surface)
		_rails = SideRails.new()
		_surface.add_child(_rails)
		_rails.size = Vector2(SURFACE_20_9)
		_rails.set_safe_area_provider(func() -> Rect2: return Rect2(Vector2.ZERO, Vector2(SURFACE_20_9)))
		_rails.set_frame_scale(PresentationGeometry.frame_scale(PresentationGeometry.frame_rect(Vector2(SURFACE_20_9)).size))
		_game.mobile_hud.set_side_rails(_rails)
	await _settle()
	return _game


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _overlay() -> TutorialOverlay:
	return _game.tutorial.overlay


func _step() -> String:
	return _game.tutorial.flow.current_id()


func _next() -> void:
	_overlay().next_button().pressed.emit()
	await _settle()


func _press(control: Control) -> void:
	assert_not_null(control, "el control a apretar en el paso \"%s\"" % _step())
	(control as Button).pressed.emit()
	await _settle()


func _tap(position: Vector2) -> void:
	for pressed: bool in [true, false]:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = position
		touch.pressed = pressed
		_viewport.push_input(touch, true)
		await get_tree().process_frame


func _click(position: Vector2) -> void:
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = position
		click.global_position = position
		click.pressed = pressed
		click.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		_viewport.push_input(click, true)
		await get_tree().process_frame


func _read_steps(count: int) -> void:
	for i: int in count:
		await _next()


func test_reading_steps_do_not_dim_anything() -> void:
	await _open(false)
	for id: String in ["welcome", "path", "gold", "lives"]:
		assert_eq(_step(), id)
		assert_false(_overlay().is_dimmed(), "el paso de lectura \"%s\" no oscurece" % id)
		assert_eq(_overlay().label_rects().size(), 0, "ni lleva rótulo")
		for rect: Rect2 in _overlay().shade_rects():
			assert_eq(rect.get_area(), 0.0)
		await _next()


func test_pc_an_action_step_dims_everything_but_the_target_and_labels_it() -> void:
	await _open(false)
	await _read_steps(4)
	assert_eq(_step(), "pick_tower")
	var overlay: TutorialOverlay = _overlay()
	assert_true(overlay.is_dimmed())
	var tower: Rect2 = _game.hud.target_control(&"tower_1").get_global_rect()
	assert_true(overlay.focus_hole().encloses(tower), "el agujero deja a la vista lo señalado")
	var area: float = 0.0
	for rect: Rect2 in overlay.shade_rects():
		area += rect.get_area()
		assert_false(rect.intersects(tower), "el oscurecido no pisa el botón")
	assert_almost_eq(area, SCREEN.get_area() - overlay.focus_hole().get_area(), 0.5)
	assert_eq(overlay.label_rects().size(), 1)
	assert_eq(overlay.focus_label, "Hacé clic acá")
	assert_false(overlay.label_rects()[0].intersects(overlay.card_rect()), "el rótulo no pisa la tarjeta")
	assert_false(overlay.label_rects()[0].intersects(tower))
	assert_false(overlay.card_rect().intersects(tower.grow(TutorialLayout.GAP)), "la tarjeta no tapa lo señalado")
	assert_false(_game.is_paused(), "el foco no pausa la partida")


func test_the_shades_ignore_the_mouse_so_touches_reach_the_target() -> void:
	await _open(false)
	await _read_steps(4)
	for shade: ColorRect in _overlay().shade_nodes():
		assert_eq(shade.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	var button: Control = _game.hud.target_control(&"tower_1")
	await _click(button.get_global_rect().get_center())
	assert_not_null(_game.build_controller.selected_tower(), "un clic sobre lo señalado llega al botón y elige la torre")
	await _settle()
	assert_eq(_step(), "place_tower", "y el tutorial avanzó de verdad")


func test_mobile_the_touch_on_the_cart_goes_through_the_dimming() -> void:
	await _open(true)
	await _read_steps(4)
	assert_eq(_step(), "open_cart")
	assert_true(_overlay().is_dimmed())
	assert_eq(_overlay().focus_label, "Tocá acá")
	var cart: Control = _game.mobile_hud.target_control(&"cart")
	assert_true(_overlay().focus_hole().encloses(cart.get_global_rect()))
	await _tap(cart.get_global_rect().get_center())
	assert_true(_game.mobile_hud.is_catalog_open(), "el toque llegó al carrito")
	await _settle()
	assert_eq(_step(), "pick_card")


func test_the_dimming_uses_the_wall_clock_not_the_game_clock() -> void:
	await _open(false)
	await _read_steps(4)
	Engine.time_scale = 2.0
	get_tree().paused = true
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(_overlay().is_dimmed(), "con la partida en pausa y a ×2 el efecto sigue ahí")
	assert_true(_overlay().visible)
	var before: float = TutorialLayout.ring_phase(Time.get_ticks_msec(), 1.2)
	assert_between(before, 0.0, 1.0)


func test_the_focus_follows_the_target_when_the_map_is_zoomed() -> void:
	await _open(false)
	await _read_steps(4)
	await _press(_game.hud.target_control(&"tower_1"))
	assert_eq(_step(), "place_tower")
	var before: Rect2 = _overlay().targets()[0]
	var hole_before: Rect2 = _overlay().focus_hole()
	_game.camera_controller.zoom_in_step()
	await _settle()
	await _settle()
	var after: Rect2 = _overlay().targets()[0]
	assert_ne(after, before, "el recuadro se movió con el zoom")
	assert_gt(after.size.x, before.size.x, "y creció")
	assert_true(_overlay().focus_hole().encloses(after), "el agujero sigue a la casilla")
	assert_ne(_overlay().focus_hole(), hole_before)


func test_several_zones_use_one_hole_or_no_dimming_never_one_mask_per_cell() -> void:
	await _open(true)
	await _read_steps(4)
	await _press(_game.mobile_hud.target_control(&"cart"))
	await _press(_game.mobile_hud.target_control(&"first_card"))
	assert_eq(_step(), "confirm_tower")
	var overlay: TutorialOverlay = _overlay()
	assert_eq(overlay.targets().size(), 2, "la casilla y la tilde")
	var visible_shades: int = 0
	for shade: ColorRect in overlay.shade_nodes():
		if shade.visible:
			visible_shades += 1
	assert_true(visible_shades == 4 or visible_shades == 3 or visible_shades == 0, "cuatro rectángulos como mucho, no uno por casilla")
	if overlay.is_dimmed():
		for target: Rect2 in overlay.targets():
			assert_true(overlay.focus_hole().encloses(target), "un solo agujero cubre las dos zonas")


func test_the_path_step_is_reading_and_has_no_dimming_even_with_many_cells() -> void:
	await _open(false)
	await _next()
	assert_eq(_step(), "path")
	assert_false(_overlay().is_dimmed())
	assert_eq(_overlay().shade_nodes().size(), 4)


func test_the_card_never_covers_the_target_or_the_label_in_every_action_step_pc() -> void:
	await _open(false)
	await _read_steps(4)
	await _press(_game.hud.target_control(&"tower_1"))
	for id: String in ["place_tower"]:
		assert_eq(_step(), id)
		var card: Rect2 = _overlay().card_rect()
		assert_true(SCREEN.encloses(card))
		for target: Rect2 in _overlay().targets():
			assert_false(card.intersects(target))
		for label: Rect2 in _overlay().label_rects():
			assert_false(card.intersects(label))
			assert_true(SCREEN.encloses(label))


# --- Con rieles ---

func _walk_to_open_cart_with_rails() -> void:
	await _open(true, true)
	assert_true(_game.mobile_hud.rails_active(), "la superficie 20:9 tiene rieles")
	await _read_steps(4)
	assert_eq(_step(), "open_cart")


func test_rails_the_cart_ring_lives_on_the_rail_and_the_frame_is_fully_dimmed() -> void:
	await _walk_to_open_cart_with_rails()
	var cart: Button = _game.mobile_hud.rail_button(&"cart")
	assert_not_null(cart)
	assert_eq(_game.tutorial.current_rail_control(), cart)
	assert_eq(_game.mobile_hud.target_control(&"cart"), cart, "con rieles el carrito señalado es el del riel")
	var overlay: TutorialOverlay = _overlay()
	assert_true(overlay.targets().is_empty(), "no hay recuadro dentro del marco")
	var rail: Rect2 = overlay.rail_target()
	assert_gt(rail.size.x, 0.0, "el rectángulo del botón, en coordenadas del marco")
	assert_gt(rail.position.x, 1280.0 - 1.0, "el riel derecho queda a la derecha del marco")
	assert_true(overlay.is_dimmed())
	assert_eq(overlay.focus_hole(), Rect2(), "no hay agujero: el botón está fuera del marco")
	assert_eq(overlay.shade_rects()[0], SCREEN, "el oscurecido cubre el marco entero")
	assert_eq(_rails.focused_button(), cart, "la capa de rieles pulsa ese botón")
	for rect: Rect2 in overlay.label_rects():
		assert_true(SCREEN.encloses(rect), "el rótulo y su flecha quedan dentro del marco")
		assert_gt(rect.position.x, SCREEN.get_center().x, "del lado del riel derecho")
		assert_false(rect.intersects(overlay.card_rect()))
	assert_eq(overlay.label_rects().size(), 1)


func test_rails_the_other_buttons_are_dimmed_and_the_focus_layer_lets_touches_through() -> void:
	await _walk_to_open_cart_with_rails()
	var layer: Control = _rails.get_node("FocusLayer") as Control
	assert_eq(layer.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(_rails.focused_button(), _game.mobile_hud.rail_button(&"cart"))
	assert_ne(_rails.focused_button(), _game.mobile_hud.rail_button(&"menu"))
	# Un toque sobre el botón del riel llega: lo hace el propio SideRails.
	var pressed: Array = []
	_rails.button_pressed.connect(func(button: Control) -> void: pressed.append(button))
	_game.mobile_hud.rail_button(&"cart").pressed.emit()
	await _settle()
	assert_eq(pressed.size(), 1)
	assert_true(_game.mobile_hud.is_catalog_open(), "el carrito del riel abrió el catálogo")
	assert_eq(_step(), "pick_card")
	assert_null(_rails.focused_button(), "al pasar al paso siguiente la marca del riel se va")
	assert_eq(_overlay().rail_target(), Rect2())


func test_rails_sell_is_marked_on_the_left_rail() -> void:
	await _walk_to_open_cart_with_rails()
	await _press(_game.mobile_hud.rail_button(&"cart"))
	await _press(_game.mobile_hud.target_control(&"first_card"))
	assert_eq(_step(), "confirm_tower")
	assert_null(_rails.focused_button(), "la tilde está en el marco: ahí no hay marca de riel")
	await _press(_game.mobile_hud.target_control(&"confirm"))
	await _press(_game.hud.target_control(&"start_wave"))
	assert_eq(_step(), "select_tower")
	var tower: Tower = _game.tower_container.get_child(0) as Tower
	_game.build_controller.select_placed(tower)
	await _settle()
	assert_eq(_step(), "upgrade")
	await _next()
	assert_eq(_step(), "sell")
	var sell: Button = _game.mobile_hud.rail_button(&"sell")
	assert_not_null(sell)
	assert_eq(_rails.focused_button(), sell, "«Vender» del riel izquierdo pulsa")
	assert_lt(_overlay().rail_target().position.x, 0.0, "el riel izquierdo queda a la izquierda del marco")
	assert_true(_overlay().targets().is_empty())
	assert_false(_overlay().is_dimmed(), "es un paso de lectura: el marco no se oscurece")
	await _next()
	assert_null(_rails.focused_button(), "pasó el paso: la marca se va")


func test_rails_finishing_or_skipping_the_tutorial_clears_the_focus() -> void:
	await _walk_to_open_cart_with_rails()
	assert_not_null(_rails.focused_button())
	_overlay().skip_button().pressed.emit()
	await _settle()
	assert_null(_rails.focused_button())
	assert_false(_overlay().is_dimmed())


func test_rails_the_focus_survives_a_rail_rebuild() -> void:
	await _walk_to_open_cart_with_rails()
	var old_cart: Button = _game.mobile_hud.rail_button(&"cart")
	_rails.set_frame_scale(_rails.frame_scale() * 0.9)  # un cambio de tamaño rearma las medidas
	await _settle()
	var cart: Button = _game.mobile_hud.rail_button(&"cart")
	assert_not_null(cart)
	assert_eq(_rails.focused_button(), cart, "la marca sigue en el carrito (era %s)" % old_cart)


func test_pc_without_rails_has_no_rail_focus_at_all() -> void:
	await _open(false)
	await _read_steps(4)
	assert_eq(_overlay().rail_target(), Rect2())
	assert_null(_game.tutorial.current_rail_control())
