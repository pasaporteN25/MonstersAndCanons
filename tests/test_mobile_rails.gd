# T570 (RF-733, RF-734, D-224): los controles del celular pasan a los rieles laterales y se suman «+» y «−».
# Partida real en modo celular; los rieles son un `SideRails` propio dentro de un SubViewport del tamaño de la
# superficie (como el host). Sin ventana: la geometría se mide, no se mira. No se prueba el pulgar ni los 6 mm físicos.
extends GutTest

const TEST_SAVE: String = "user://test_mobile_rails_save.json"
const SURFACE_20_9: Vector2i = Vector2i(2400, 1080)
const SURFACE_16_9: Vector2i = Vector2i(1920, 1080)
var _original_save_path: String
var _original_mode: Variant
var _surface: SubViewport
var _rails: SideRails


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	_original_mode = SaveManager.get_setting("ui_mode")
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func _make_rails(size: Vector2i) -> void:
	_surface = SubViewport.new()
	_surface.size = size
	add_child_autofree(_surface)
	_rails = SideRails.new()
	_surface.add_child(_rails)
	_rails.size = Vector2(size)
	_set_surface(size)


func _set_surface(size: Vector2i) -> void:
	_surface.size = size
	_rails.size = Vector2(size)
	_rails.set_safe_area_provider(func() -> Rect2: return Rect2(Vector2.ZERO, Vector2(size)))
	_rails.set_frame_scale(PresentationGeometry.frame_scale(PresentationGeometry.frame_rect(Vector2(size)).size))


func _new_game(rails_size: Vector2i = Vector2i.ZERO) -> Game:
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	if rails_size != Vector2i.ZERO:
		_make_rails(rails_size)
		game.mobile_hud.set_side_rails(_rails)
		await wait_process_frames(2)
	return game


func _select(game: Game, id: String) -> Tower:
	var data: TowerData = load("res://data/towers/%s.tres" % id) as TowerData
	game.session.earn(5000)
	if not game.build_controller._tower_types.has(data):
		game.build_controller._tower_types.append(data)
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and game.build_controller.cells_free(data, cell) \
					and game.build_controller.try_build(data, cell):
				var tower: Tower = game.build_controller.tower_at(cell)
				game.build_controller.select_placed(tower)
				game._refresh_tower_panel()
				return tower
	return null


func _floating(game: Game) -> Array[Button]:
	var buttons: Array[Button] = []
	for node_name: String in ["CartButton", "MenuButton", "DemolishButton", "ViewAll"]:
		buttons.append(game.mobile_hud.find_child(node_name, true, false) as Button)
	return buttons


func test_without_rails_nothing_changes_in_16_9() -> void:
	var game: Game = await _new_game()
	var hud: MobileHud = game.mobile_hud
	assert_false(hud.rails_active())
	assert_null(hud.rail_button(&"menu"))
	assert_null(hud.rail_button(&"zoom_in"))
	assert_true((hud.find_child("CartButton", true, false) as Button).visible, "el carrito flotante sigue")
	assert_true((hud.find_child("MenuButton", true, false) as Button).visible, "el botón Menú flotante sigue")
	_select(game, "basic")
	assert_true((hud.find_child("MobileSell", true, false) as Button).visible, "«Vender» sigue en la barra")
	assert_true((hud.find_child("SellSeparation", true, false) as Control).visible, "con su separación de RF-512")


func test_16_9_surface_has_no_rails_even_if_the_layer_exists() -> void:
	var game: Game = await _new_game(SURFACE_16_9)
	assert_false(_rails.has_room(), "1920 x 1080 es 16:9: las franjas miden 0")
	assert_false(game.mobile_hud.rails_active())
	assert_true((game.mobile_hud.find_child("CartButton", true, false) as Button).visible)
	assert_eq(_rails.get_node("LeftColumn").get_child_count(), 0)
	assert_eq(_rails.get_node("RightColumn").get_child_count(), 0)


func test_with_rails_buttons_leave_the_frame_and_floating_ones_hide() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	assert_true(hud.rails_active())
	for floating: Button in _floating(game):
		assert_false(floating.visible, "%s ya no existe en el marco" % floating.name)
	_select(game, "basic")
	game.camera_controller.zoom_in_step()
	await wait_process_frames(2)
	var frame: Rect2 = PresentationGeometry.frame_rect(Vector2(SURFACE_20_9))
	for id: StringName in [&"menu", &"zoom_in", &"zoom_out", &"view_all", &"sell", &"cart"]:
		var button: Button = hud.rail_button(id)
		assert_not_null(button, "existe %s" % id)
		assert_true(button.is_visible_in_tree(), "%s se ve" % id)
		assert_false(button.get_global_rect().intersects(frame), "%s queda afuera del marco" % id)
	assert_lte(hud.rail_button(&"menu").get_global_rect().end.x, frame.position.x, "Menú en el riel izquierdo")
	assert_gte(hud.rail_button(&"cart").get_global_rect().position.x, frame.end.x, "carrito en el riel derecho")
	assert_false((hud.find_child("MobileSell", true, false) as Button).visible, "«Vender» salió de la barra")
	assert_false((hud.find_child("SellSeparation", true, false) as Control).visible, "y su separación también")


func test_rail_buttons_keep_the_minimum_size() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var minimum: float = float(MobileUiConfig.load_from().get_value("flotante_min_px")) * _rails.frame_scale()
	for id: StringName in [&"menu", &"zoom_in", &"zoom_out", &"cart", &"sell"]:
		var size: Vector2 = game.mobile_hud.rail_button(id).size
		assert_gte(size.x, minimum - 0.5, "%s mide de ancho al menos el mínimo del riel" % id)
		assert_gte(size.y, minimum - 0.5, "%s mide de alto al menos el mínimo del riel" % id)


func test_left_rail_order_ends_with_sell_and_right_has_cart_then_demolish() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var left: Node = _rails.get_node("LeftColumn")
	var names: Array[String] = []
	for child: Node in left.get_children():
		names.append(String(child.name))
	assert_eq(names, ["RailMenu", "RailZoomIn", "RailZoomOut", "RailViewAll", "RailSpacer", "RailSell"])
	var right: Node = _rails.get_node("RightColumn")
	assert_eq(String(right.get_child(0).name), "RailCart")
	assert_eq(String(right.get_child(1).name), "RailDemolish")
	assert_eq(right.get_child_count(), 2)
	assert_not_null(game.mobile_hud.rail_button(&"demolish"))


func test_floating_button_is_not_interactive_and_rail_does_not_count_inside_the_frame() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var cart_floating: Button = hud.find_child("CartButton", true, false) as Button
	var point: Vector2 = cart_floating.global_position + cart_floating.size / 2.0
	assert_false(hud.is_interactive_at(point), "el carrito flotante, oculto, no cuenta")
	var cart_rail: Button = hud.rail_button(&"cart")
	assert_false(hud.is_interactive_at(cart_rail.get_global_rect().get_center()), "lo de afuera del marco no se cuenta")


func test_zoom_buttons_zoom_around_the_visible_center_and_stop_at_each_limit() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var camera: CameraController = game.camera_controller
	var zoom_in: Button = hud.rail_button(&"zoom_in")
	var zoom_out: Button = hud.rail_button(&"zoom_out")
	var cart_before: Vector2 = hud.rail_button(&"cart").global_position
	var hints: Array[int] = [0]
	camera.view_zoomed_in.connect(func() -> void: hints[0] += 1)
	assert_true(zoom_out.disabled, "en el zoom mínimo «−» está apagado")
	assert_false(zoom_in.disabled)
	var minimum: float = game.minimum_map_zoom
	var maximum: float = CameraController.maximum_zoom_from_cell_pixels(float(MobileUiConfig.load_from().get_value("zoom_casilla_max_px")))
	zoom_in.pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(game.camera.zoom.x, minf(minimum * 1.25, maximum), 0.001, "un toque en «+» acerca ×1,25")
	assert_eq(hints[0], 1, "acercar con el botón dispara el aviso de RF-676 igual que la pinza")
	assert_false(zoom_out.disabled, "ya se puede alejar")
	for i: int in 12:
		zoom_in.pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(game.camera.zoom.x, maximum, 0.001, "«+» no pasa del tope")
	assert_true(zoom_in.disabled, "en el tope «+» se apaga")
	zoom_in.pressed.emit()
	assert_almost_eq(game.camera.zoom.x, maximum, 0.001, "ya apagado, un toque no hace nada")
	for i: int in 24:
		zoom_out.pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(game.camera.zoom.x, minimum, 0.001, "«−» no baja del mínimo")
	assert_true(zoom_out.disabled)
	assert_false(zoom_in.disabled)
	assert_eq(hud.rail_button(&"cart").global_position, cart_before, "ningún control se mueve al hacer zoom")


func test_zoom_step_keeps_the_center_of_the_visible_area() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var camera: CameraController = game.camera_controller
	var center: Vector2 = camera.visible_area_center()
	var world_before: Vector2 = game.get_viewport().get_canvas_transform().affine_inverse() * center
	camera.zoom_step(1.25)
	var world_after: Vector2 = game.get_viewport().get_canvas_transform().affine_inverse() * center
	assert_almost_eq(world_before.x, world_after.x, 8.0, "el punto del centro sigue debajo del centro (x)")
	# La cámara no puede salirse del mapa (se recorta el centro), así que en el borde puede correrse unos píxeles;
	# acercar alrededor de otro punto lo correría cientos.
	assert_almost_eq(world_before.y, world_after.y, 8.0, "y también (y), salvo el recorte del borde del mapa")


func test_view_all_rail_button_appears_only_with_zoom_and_restores_the_frame() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	assert_false(hud.rail_button(&"view_all").visible, "sin zoom no hay lupa")
	game.camera_controller.zoom_in_step()
	assert_true(hud.rail_button(&"view_all").visible, "con zoom aparece")
	watch_signals(hud)
	hud.rail_button(&"view_all").pressed.emit()
	assert_signal_emitted(hud, "view_all_pressed")


func test_sell_keeps_its_two_taps_and_the_minimum_gap_in_the_rail() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var sell: Button = hud.rail_button(&"sell")
	assert_false(sell.visible, "sin torre elegida no hay «Vender»")
	assert_not_null(_select(game, "basic"))
	assert_true(sell.visible)
	watch_signals(hud)
	var normal_text: String = sell.text
	sell.pressed.emit()
	assert_signal_not_emitted(hud, "sell_pressed", "el primer toque solo arma")
	assert_ne(sell.text, normal_text, "el botón pasa a pedir confirmación")
	assert_true(sell.text.contains("+"), "y dice cuánto devuelve")
	sell.pressed.emit()
	assert_signal_not_emitted(hud, "sell_pressed", "un segundo toque antes de `vender_min_s` no vende")
	hud._sell_elapsed = float(MobileUiConfig.load_from().get_value("vender_min_s")) + 0.01
	sell.pressed.emit()
	assert_signal_emitted(hud, "sell_pressed", "el segundo toque, pasado el mínimo, vende")


func test_sell_rearms_after_the_time_runs_out() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	_select(game, "basic")
	var sell: Button = hud.rail_button(&"sell")
	var normal_text: String = sell.text
	sell.pressed.emit()
	hud._process(float(MobileUiConfig.load_from().get_value("vender_rearmar_s")) + 0.1)
	assert_eq(sell.text, normal_text, "pasados los 3 s, vuelve a «Vender»")


func test_sell_is_not_in_the_bar_and_the_bar_text_is_not_squeezed() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	_select(game, "basic")
	var hud: MobileHud = game.mobile_hud
	var label: Label = hud.find_child("StatusText", true, false) as Label
	await wait_process_frames(2)
	var with_rails_width: float = label.size.x
	var plain: Game = await _new_game()
	_select(plain, "basic")
	await wait_process_frames(2)
	var plain_label: Label = plain.mobile_hud.find_child("StatusText", true, false) as Label
	assert_gt(with_rails_width, plain_label.size.x, "el texto gana el ancho de «Vender» y de su separación")


func test_modals_game_over_and_boss_presentation_hide_the_rails() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	assert_true(_rails.visible)
	hud.set_modal_open(true)
	assert_false(_rails.visible, "un menú, un cartel o un jefe abierto oculta los rieles")
	hud.set_modal_open(false)
	assert_true(_rails.visible, "al cerrar vuelven")
	hud.set_game_over(true)
	assert_false(_rails.visible, "con la partida terminada no hay rieles")
	hud.set_modal_open(true)
	hud.set_modal_open(false)
	assert_false(_rails.visible, "cerrar un modal con la partida terminada no los devuelve")
	hud.set_game_over(false)
	assert_true(_rails.visible)


func test_real_pause_menu_hides_and_restores_the_rails() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	game.open_pause_menu()
	assert_false(_rails.visible, "el menú de pausa oculta los rieles")
	game.close_pause_menu()
	assert_true(_rails.visible, "al cerrarlo vuelven")


func test_menu_button_in_the_rail_opens_the_pause_menu() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	game.mobile_hud.rail_button(&"menu").pressed.emit()
	assert_true(game.pause_menu.is_open())
	game.close_pause_menu()


func test_cart_in_the_rail_opens_and_closes_the_catalog() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var cart: Button = hud.rail_button(&"cart")
	cart.pressed.emit()
	assert_true(hud.is_catalog_open(), "el carrito del riel abre el catálogo")
	cart.pressed.emit()
	assert_false(hud.is_catalog_open(), "y otro toque lo cierra")


func test_demolish_in_the_rail_only_shows_when_available() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var demolish: Button = hud.rail_button(&"demolish")
	hud.set_demolish_available(false)
	assert_false(demolish.visible)
	hud.set_demolish_available(true)
	assert_true(demolish.visible)
	watch_signals(hud)
	demolish.pressed.emit()
	assert_signal_emitted(hud, "demolish_pressed")
	hud.set_demolish_available(false)
	assert_false(demolish.visible, "sin removibles no hay «Demoler»")


func test_ghost_state_cart_active_and_no_shifting() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	var cart: Button = hud.rail_button(&"cart")
	hud.set_cart_active(true)
	assert_ne(cart.self_modulate, Color.WHITE, "el carrito del riel se marca como activo")
	hud.set_cart_active(false)
	assert_eq(cart.self_modulate, Color.WHITE)
	var before: Vector2 = cart.global_position
	hud.show_placement(Vector2(300.0, 300.0), "50", true, "", Vector2.ONE * 64.0)
	hud.set_placement_visible(true)
	await wait_process_frames(2)
	assert_eq(cart.global_position, before, "con un fantasma el riel no se corre")
	assert_eq(cart.modulate.a, 1.0, "ni se vuelve translúcido: no tapa el mapa")
	assert_false((hud.find_child("CartButton", true, false) as Button).visible)
	hud.set_placement_visible(false)


func test_pause_dims_the_rail_cart_but_keeps_the_hint() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	hud.set_paused(true)
	var cart: Button = hud.rail_button(&"cart")
	assert_lt(cart.modulate.r, 1.0, "en pausa el carrito se ve apagado")
	cart.pressed.emit()
	assert_false(hud.is_catalog_open(), "y no abre el catálogo")
	hud.set_paused(false)
	assert_eq(cart.modulate, Color.WHITE)


func test_resizing_does_not_duplicate_buttons_or_lose_state() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	var hud: MobileHud = game.mobile_hud
	_select(game, "basic")
	hud.set_cart_active(true)
	game.camera_controller.zoom_in_step()
	_set_surface(SURFACE_16_9)
	await wait_process_frames(2)
	assert_false(hud.rails_active(), "al pasar a 16:9 los rieles se van")
	assert_eq(_rails.get_node("LeftColumn").get_child_count(), 0)
	assert_eq(_rails.get_node("RightColumn").get_child_count(), 0)
	assert_true((hud.find_child("CartButton", true, false) as Button).visible, "los flotantes vuelven")
	assert_true((hud.find_child("ViewAll", true, false) as Button).visible, "la lupa también (hay zoom)")
	assert_true((hud.find_child("MobileSell", true, false) as Button).visible, "«Vender» vuelve a la barra")
	assert_eq((hud.find_child("CartButton", true, false) as Button).self_modulate, Color("#ffe0a0"), "el carrito sigue marcado")
	for i: int in 3:
		_set_surface(SURFACE_20_9)
		await wait_process_frames(2)
		_set_surface(SURFACE_16_9)
		await wait_process_frames(2)
	_set_surface(SURFACE_20_9)
	await wait_process_frames(2)
	assert_true(hud.rails_active())
	assert_eq(_rails.get_node("LeftColumn").get_child_count(), 6, "sin botones duplicados (izquierda)")
	assert_eq(_rails.get_node("RightColumn").get_child_count(), 2, "sin botones duplicados (derecha)")
	assert_true(hud.rail_button(&"sell").visible, "«Vender» sigue ahí: la torre sigue elegida")
	assert_ne(hud.rail_button(&"cart").self_modulate, Color.WHITE, "el carrito activo se conserva")
	assert_true(hud.rail_button(&"view_all").visible)


func test_saved_floating_positions_are_kept_but_not_applied_with_rails() -> void:
	var game: Game = await _new_game()
	var hud: MobileHud = game.mobile_hud
	var cart: Button = hud.find_child("CartButton", true, false) as Button
	var saved: Vector2 = cart.position
	_make_rails(SURFACE_20_9)
	hud.set_side_rails(_rails)
	await wait_process_frames(2)
	assert_eq(cart.position, saved, "la posición del flotante no se tocó")
	_set_surface(SURFACE_16_9)
	await wait_process_frames(2)
	assert_eq(cart.position, saved, "y al volver sin rieles sigue en su lugar")
	assert_true(cart.visible)


func test_leaving_the_game_empties_the_rails() -> void:
	var game: Game = await _new_game(SURFACE_20_9)
	game.mobile_hud.set_modal_open(true)
	game.free()
	assert_eq(_rails.get_node("LeftColumn").get_child_count(), 0, "no quedan botones sueltos en el host")
	assert_true(_rails.visible, "y los rieles quedan listos para la próxima pantalla")
