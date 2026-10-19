extends GutTest


func test_ui_mode_reads_and_resolves_supported_values() -> void:
	assert_eq(UiMode.read_setting(0), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting(1), UiMode.MOBILE)
	assert_eq(UiMode.read_setting(2), UiMode.PC)
	assert_eq(UiMode.read_setting(7), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting("celular"), UiMode.AUTOMATIC)
	assert_eq(UiMode.read_setting(null), UiMode.AUTOMATIC)
	assert_true(UiMode.resolve(0, true))
	assert_false(UiMode.resolve(0, false))
	assert_true(UiMode.resolve(1, false))
	assert_false(UiMode.resolve(2, true))


func test_mobile_ui_config_uses_defaults_for_broken_file() -> void:
	var path: String = "user://test_mobile_ui.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ roto")
	file.close()
	var config: MobileUiConfig = MobileUiConfig.load_from(path)
	assert_eq(config.get_value("boton_alto_px"), 56)
	assert_eq(config.get_value("barra_alta_px"), 64)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_mobile_ui_config_loads_data_file() -> void:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	assert_eq(config.get_value("boton_alto_px"), 56)
	assert_eq(config.get_value("pinza_gracia_ms"), 150)


func test_options_selector_saves_without_changing_an_existing_hud() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var hud: Hud = (load("res://scenes/game/hud.tscn") as PackedScene).instantiate() as Hud
	add_child_autofree(hud)
	await get_tree().process_frame
	assert_true(hud.get_node("TopBar/ExitButton").visible)
	var options: OptionsMenu = (load("res://scenes/ui/options_menu.tscn") as PackedScene).instantiate() as OptionsMenu
	add_child_autofree(options)
	await get_tree().process_frame
	var selector: OptionButton = options.find_child("UiModeSelector", true, false) as OptionButton
	assert_not_null(selector)
	selector.select(UiMode.MOBILE)
	selector.item_selected.emit(UiMode.MOBILE)
	assert_eq(SaveManager.get_setting("ui_mode"), UiMode.MOBILE)
	assert_true(hud.get_node("TopBar/ExitButton").visible, "el cambio se aplica en la próxima partida")
	SaveManager.set_setting("ui_mode", original_setting)


func test_mobile_hud_has_requested_top_controls() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var hud: Hud = (load("res://scenes/game/hud.tscn") as PackedScene).instantiate() as Hud
	add_child_autofree(hud)
	await get_tree().process_frame
	var top_bar: Control = hud.get_node("TopBar")
	var pause_button: Button = hud.get_node("TopBar/PauseButton")
	var speed_button: Button = hud.get_node("TopBar/SpeedButton")
	assert_false(hud.get_node("TopBar/ExitButton").visible)
	assert_eq(top_bar.size.y, 64.0)
	assert_eq(pause_button.custom_minimum_size.y, 56.0)
	assert_eq(speed_button.custom_minimum_size.y, 56.0)
	assert_false(pause_button.text.contains("[P]"))
	assert_false(speed_button.text.contains("[F]"))
	SaveManager.set_setting("ui_mode", original_setting)


func test_touch_gesture_distinguishes_taps_drags_and_multi_touch() -> void:
	var gesture := TouchGesture.new()
	gesture.configure(21.0, 150)
	gesture.down(0, Vector2.ZERO, 0)
	assert_eq(gesture.up(0, Vector2(10.5, 0.0), 50), TouchGesture.Gesture.TAP)
	gesture.down(0, Vector2.ZERO, 100)
	assert_eq(gesture.move(0, Vector2(21.1, 0.0), 120), TouchGesture.Gesture.DRAG)
	assert_eq(gesture.up(0, Vector2(21.1, 0.0), 130), TouchGesture.Gesture.DRAG)
	gesture.down(0, Vector2.ZERO, 200)
	gesture.down(1, Vector2(100.0, 0.0), 210)
	assert_eq(gesture.move(1, Vector2(125.0, 0.0), 215), TouchGesture.Gesture.PINCH)
	gesture.up(0, Vector2.ZERO, 220)
	assert_eq(gesture.up(1, Vector2(100.0, 0.0), 230), TouchGesture.Gesture.PINCH)
	assert_true(gesture.ignores_single_touch(379))
	assert_false(gesture.ignores_single_touch(380))


func test_ghost_placement_clamps_large_towers_and_checks_costs() -> void:
	var ghost := GhostPlacement.new()
	ghost.select_tower(&"mortar", 2, 300, 3)
	ghost.cell = Vector2i(19, 8)
	ghost.clamp_inside(Vector2i(20, 9))
	assert_eq(ghost.cell, Vector2i(18, 7))
	ghost.move_to(Vector2i(4, 3), true)
	assert_false(ghost.can_confirm(299, 3)["ok"])
	assert_eq(ghost.can_confirm(300, 2)["motivo"], "Faltan 1 recursos")
	assert_true(ghost.can_confirm(300, 3)["ok"])
	assert_false(ghost.is_double_tap(Vector2i(4, 3), 1000, 350))
	assert_true(ghost.is_double_tap(Vector2i(4, 3), 1349, 350))
	assert_false(ghost.is_double_tap(Vector2i(4, 3), 2000, 350))


func test_touch_gesture_two_fingers_that_move_together_are_a_pan() -> void:
	var gesture := TouchGesture.new()
	gesture.configure(21.0, 150)
	gesture.down(0, Vector2.ZERO, 0)
	gesture.down(1, Vector2(100.0, 0.0), 0)
	assert_eq(gesture.move(0, Vector2(15.0, 0.0), 20), TouchGesture.Gesture.PAN)
	assert_eq(gesture.move(1, Vector2(115.0, 0.0), 20), TouchGesture.Gesture.PAN)


func test_mobile_placement_buttons_are_compact_and_disable_invalid_placement() -> void:
	var mobile_hud := MobileHud.new()
	add_child_autofree(mobile_hud)
	await get_tree().process_frame
	mobile_hud.show_placement(Vector2(500.0, 400.0), "300 + 3", true, "")
	var confirm: Button = mobile_hud.get_node("ConfirmPlacement") as Button
	var cancel: Button = mobile_hud.get_node("CancelPlacement") as Button
	assert_false(confirm.disabled)
	assert_eq(confirm.text, "")
	assert_not_null(confirm.icon)
	assert_eq(confirm.custom_minimum_size, Vector2(64.0, 64.0))
	assert_eq(cancel.custom_minimum_size, Vector2(64.0, 64.0))
	mobile_hud.show_placement(Vector2(500.0, 400.0), "300 + 3", false, "Ahí no")
	assert_true(confirm.disabled)
	assert_eq(confirm.tooltip_text, "Ahí no")
	assert_true((mobile_hud.find_child("BottomConfirmPlacement", true, false) as Button).visible)
	assert_eq((mobile_hud.find_child("MobileUpgrade", true, false) as Button).custom_minimum_size.y, 84.0)
	assert_eq((mobile_hud.find_child("MobileSell", true, false) as Button).custom_minimum_size.y, 82.0)


func test_mobile_selected_tower_upgrade_lock_and_protected_sale() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	game.session.earn(5000)
	var tower_data: TowerData = game.available_towers[0]
	var cell := Vector2i.ZERO
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var candidate := Vector2i(x, y)
			if game.level.is_buildable(candidate) and game.build_controller.cells_free(tower_data, candidate):
				cell = candidate
				break
		if game.level.is_buildable(cell) and game.build_controller.cells_free(tower_data, cell):
			break
	assert_true(game.build_controller.try_build(tower_data, cell))
	var tower: Tower = game.build_controller.tower_at(cell)
	game.build_controller.select_placed(tower)
	game.mobile_hud.show_ghost_status(tower_data.display_name, TowerText.cost_text(tower_data))
	assert_true((game.mobile_hud.find_child("BottomConfirmPlacement", true, false) as Button).visible)
	assert_false((game.mobile_hud.find_child("MobileUpgrade", true, false) as Button).visible)
	game._refresh_tower_panel()
	var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
	var improve: Button = game.mobile_hud.find_child("MobileUpgrade", true, false) as Button
	var target: Button = game.mobile_hud.find_child("MobileTargeting", true, false) as Button
	var sell: Button = game.mobile_hud.find_child("MobileSell", true, false) as Button
	assert_true(status.text.contains(tower.data.display_name))
	assert_true(status.text.contains("Nivel 1 de"))
	assert_true(status.text.contains("Daño") and status.text.contains("Cadencia") and status.text.contains("Alcance"))
	assert_true(improve.text.contains("Mejorar"))
	assert_false(improve.disabled)
	var clear_selection: Button = game.mobile_hud.find_child("BottomCancelPlacement", true, false) as Button
	assert_true(clear_selection.visible)
	clear_selection.pressed.emit()
	assert_null(game.build_controller.selected_placed(), "la cruz inferior suelta la torre elegida")
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	var level_before: int = tower.level_number()
	improve.pressed.emit()
	improve.pressed.emit()
	assert_eq(tower.level_number(), level_before + 1, "el doble toque mejora una sola vez")
	assert_true(improve.text.contains("¡Nivel 2!"))
	await get_tree().create_timer(0.36).timeout
	game.session.set_gold(0)
	game.mobile_hud.show_selected_tower(tower, game.session.gold,
		game.build_controller.sell_value(tower), 0, game.build_controller.can_upgrade(tower))
	assert_true(improve.disabled)
	assert_true(improve.text.contains("Faltan"))
	game.session.earn(5000)
	while tower.can_upgrade():
		assert_true(game.build_controller.try_upgrade(tower))
	game.mobile_hud.show_selected_tower(tower, game.session.gold,
		game.build_controller.sell_value(tower), 0, game.build_controller.can_upgrade(tower))
	assert_true(improve.disabled)
	assert_eq(improve.text, "Nivel máximo")
	game.mobile_hud._on_sell_pressed()
	game.open_pause_menu()
	assert_false(game.mobile_hud._sell_armed, "pausar desarma la venta")
	game.close_pause_menu()
	game.build_controller.select_placed(tower)
	game.mobile_hud._on_sell_pressed()
	game.build_controller._mobile_map_tap(game.level.cell_center(Vector2i.ZERO), Time.get_ticks_msec())
	assert_false(game.mobile_hud._sell_armed, "tocar el mapa desarma la venta")
	game.build_controller.select_placed(tower)
	game.mobile_hud._on_sell_pressed()
	game.mobile_hud.set_game_over(true)
	assert_false(game.mobile_hud._sell_armed, "terminar la partida desarma la venta")
	game.mobile_hud.set_game_over(false)
	game.build_controller.select_placed(tower)
	game.mobile_hud._on_sell_pressed()
	assert_true(sell.text.contains("Vender por"))
	game.mobile_hud._process(float(MobileUiConfig.load_from().get_value("vender_rearmar_s")) + 0.01)
	assert_false(game.mobile_hud._sell_armed, "la confirmación vence a los tres segundos")
	game.mobile_hud._on_sell_pressed()
	game.mobile_hud.open_catalog()
	assert_false(game.mobile_hud._sell_armed, "abrir el carrito desarma la venta")
	game.mobile_hud.close_catalog()
	game.mobile_hud._on_sell_pressed()
	game.mobile_hud._on_sell_pressed()
	assert_true(is_instance_valid(tower) and not tower.is_queued_for_deletion(), "antes de 0,4 s no vende")
	await get_tree().create_timer(0.41).timeout
	game.mobile_hud._on_sell_pressed()
	assert_true(tower.is_queued_for_deletion(), "el segundo toque válido vende")
	assert_false(game.mobile_hud._sell_armed)
	assert_false(target.disabled)
	var support_data: TowerData
	for candidate: TowerData in Wiki._all_towers():
		if candidate.support_only:
			support_data = candidate
			break
	assert_not_null(support_data)
	var support_tower := Tower.new()
	support_tower.setup(support_data)
	add_child_autofree(support_tower)
	await get_tree().process_frame
	game.mobile_hud.show_selected_tower(support_tower, game.session.gold, 0, 0, false)
	assert_true(target.disabled, "una torre de apoyo no admite prioridad de apuntado")
	SaveManager.set_setting("ui_mode", original_setting)


func test_camera_zoom_is_clamped_between_automatic_and_cell_limits() -> void:
	assert_eq(CameraController.clamp_zoom(0.25, 0.75, 1.5), 0.75)
	assert_eq(CameraController.clamp_zoom(1.1, 0.75, 1.5), 1.1)
	assert_eq(CameraController.clamp_zoom(2.0, 0.75, 1.5), 1.5)
	assert_eq(CameraController.clamp_center(Vector2(-10.0, 200.0), Rect2(0.0, 0.0, 100.0, 100.0)), Vector2(0.0, 100.0))


func test_mobile_double_tap_builds_once_and_deselects() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	var controller: BuildController = game.build_controller
	var tower: TowerData = game.available_towers[0]
	var cell := Vector2i.ZERO
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var candidate := Vector2i(x, y)
			if game.level.is_buildable(candidate) and controller.cells_free(tower, candidate):
				cell = candidate
				break
		if controller.cells_free(tower, cell):
			break
	var starting_gold: int = game.session.gold
	controller.select(0)
	controller._mobile_map_tap(game.level.cell_center(cell), 1000)
	assert_eq(game.session.gold, starting_gold, "el primer toque deja el fantasma sin cobrar")
	assert_eq(game.tower_container.get_child_count(), 0)
	controller._mobile_map_tap(game.level.cell_center(cell), 1349)
	assert_eq(game.session.gold, starting_gold - tower.build_gold(false))
	assert_eq(game.tower_container.get_child_count(), 1)
	assert_null(controller.selected_tower(), "después de construir se deselecciona")
	var camera: CameraController = game.camera_controller
	var current_ghost_cell: Vector2i = controller.ghost_placement().cell
	camera._zoom_at(Vector2(640.0, 344.0), 10.0)
	assert_eq(game.camera.zoom.x, 1.5)
	assert_true(game.mobile_hud.get_node("ViewAll").visible)
	camera.view_all()
	assert_true(is_equal_approx(game.camera.zoom.x, game.minimum_map_zoom))
	assert_false(game.mobile_hud.get_node("ViewAll").visible)
	assert_eq(controller.ghost_placement().cell, current_ghost_cell, "el zoom no mueve el fantasma")
	SaveManager.set_setting("ui_mode", original_setting)


func test_pc_camera_input_adds_zoom_without_mobile_controls() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	assert_null(game.mobile_hud, "la PC no agrega botones visibles")
	game.camera_controller._zoom_at(Vector2(640.0, 336.0), 1.1)
	assert_true(is_equal_approx(game.camera.zoom.x, 1.1))
	game.camera_controller._pan_by_screen_delta(Vector2(5000.0, 5000.0))
	var map_rect := Rect2(game.level.position, Vector2(game.level.map_size()) * Rules.TILE_SIZE)
	assert_eq(game.camera.position, CameraController.clamp_center(game.camera.position, map_rect))
	SaveManager.set_setting("ui_mode", original_setting)


func test_ui_prefs_fall_back_per_field_and_snap_to_nearest_edge() -> void:
	var prefs: UiPrefs = UiPrefs.read({"cart_side": "arriba", "cart_y": 2.0, "exit_side": "right", "exit_y": 0.5})
	assert_eq(prefs.to_dict(), {"cart_side": "right", "cart_y": 0.45, "exit_side": "right", "exit_y": 0.5})
	var snapped: Dictionary = FloatButtonLayout.snap(Vector2(1180.0, 320.0), Vector2(1280.0, 720.0),
		64.0, 96.0, Vector2.ONE * 82.0)
	assert_eq(snapped["side"], "right")
	assert_true(float(snapped["y"]) > 0.0 and float(snapped["y"]) < 1.0)
	var restored: Vector2 = FloatButtonLayout.position_for(String(snapped["side"]), float(snapped["y"]),
		Vector2(1280.0, 720.0), 64.0, 96.0, Vector2.ONE * 82.0)
	assert_almost_eq(restored.x, 1198.0, 0.1)
	assert_eq(FloatButtonLayout.minimum_button_size(0.0, 1.0, 7.6, 82.0), 82.0)
	assert_almost_eq(FloatButtonLayout.minimum_button_size(320.0, 2.0, 7.6, 82.0), 47.874, 0.01)
	assert_almost_eq(FloatButtonLayout.minimum_button_size(480.0, 1.0, 7.6, 82.0), 143.622, 0.01)
	var separated := FloatButtonLayout.avoid(Rect2(Vector2(-100.0, -100.0), Vector2.ZERO),
		[Rect2(Vector2(0.0, 200.0), Vector2.ONE * 82.0), Rect2(Vector2(0.0, 250.0), Vector2.ONE * 82.0)],
		["left", "left"], Vector2(1280.0, 720.0), 64.0, 96.0, Vector2.ONE * 82.0, 0.0)
	assert_true(absf(separated[0].y - separated[1].y) >= 164.0)


func test_mobile_hud_catalog_and_exit_keep_the_game_state() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	game.mobile_hud.open_catalog()
	assert_true(game.mobile_hud.is_catalog_open())
	assert_false(game.is_paused(), "el catálogo no pausa la partida")
	assert_true(game.build_controller.input_blocked)
	game.mobile_hud.close_catalog()
	assert_false(game.build_controller.input_blocked)
	game.mobile_hud.exit_pressed.emit()
	assert_true(game.exit_dialog.is_open())
	assert_true(game.is_paused())
	game.exit_dialog.handle_cancel()
	assert_false(game.is_paused(), "seguir jugando restaura el estado previo")
	SaveManager.set_setting("ui_mode", original_setting)


func test_mobile_exit_from_editor_returns_directly_without_confirmation() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	game.testing = true
	var editor_calls: Array[String] = []
	game.leave_to_editor = func() -> void: editor_calls.append("editor")
	add_child_autofree(game)
	await get_tree().process_frame
	game.mobile_hud.exit_pressed.emit()
	assert_eq(editor_calls, ["editor"])
	assert_false(game.exit_dialog.is_open())
	assert_false(game.is_paused())
	SaveManager.set_setting("ui_mode", original_setting)


func test_mobile_catalog_selects_a_tower_in_two_touches_without_spending() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	assert_false(game.hud.get_node("BottomBar/TowerButtons").visible)
	assert_eq(game.mobile_hud.find_child("TowerCards", true, false).get_child_count(), game.available_towers.size())
	var level_twelve: LevelData = GameFlow.level(11)
	assert_eq(level_twelve.towers.size(), 10)
	var twelve: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	twelve.level_data = level_twelve
	add_child_autofree(twelve)
	await get_tree().process_frame
	# Las torres de colección sin completar (RF-448) no son elegibles y no aparecen ni apagadas.
	var card_texts: Array[String] = []
	for tower_card: Button in twelve.mobile_hud.find_child("TowerCards", true, false).get_children():
		card_texts.append(tower_card.text)
	assert_gte(twelve.available_towers.size(), 8)
	for tower: TowerData in Wiki._all_towers():
		var shown: bool = false
		for card_text: String in card_texts:
			shown = shown or card_text.begins_with(tower.display_name + "\n")
		var offered: bool = twelve.available_towers.has(tower)
		assert_eq(shown, offered, "%s: aparece solo si el nivel 12 la ofrece" % tower.id)
	twelve.queue_free()
	await get_tree().process_frame
	var tower_index: int = -1
	var use_alt: bool = false
	for i: int in game.available_towers.size():
		var tower: TowerData = game.available_towers[i]
		if TowerText.missing_text(tower, false, game.session.gold, game.session.resources, game.level_data.uses_resources()) == "":
			tower_index = i
			break
		if tower.has_alt_payment() and TowerText.missing_text(tower, true, game.session.gold, game.session.resources, game.level_data.uses_resources()) == "":
			tower_index = i
			use_alt = true
			break
	assert_gte(tower_index, 0)
	var chosen: TowerData = game.available_towers[tower_index]
	var before_gold: int = game.session.gold
	game.mobile_hud.open_catalog()
	var back := InputEventAction.new()
	back.action = "cancel"
	back.pressed = true
	game.mobile_hud._input(back)
	assert_false(game.mobile_hud.is_catalog_open(), "atrás cierra el catálogo")
	game.mobile_hud.open_catalog()
	var card: Button = game.mobile_hud.find_child("CatalogCard_%s" % chosen.display_name.to_snake_case(), true, false) as Button
	assert_not_null(card)
	assert_false(card.disabled)
	var virtual_mm: float = game.mobile_hud._minimum_touch_size() / float(MobileUiConfig.load_from().get_value("flotante_min_mm"))
	assert_almost_eq(card.custom_minimum_size.x, virtual_mm * 18.0, 0.01)
	assert_almost_eq(card.custom_minimum_size.y, virtual_mm * 10.0, 0.01)
	card.pressed.emit()
	assert_false(game.mobile_hud.is_catalog_open())
	assert_eq(game.build_controller.selected_tower(), chosen)
	assert_eq(game.session.gold, before_gold, "elegir solo muestra el fantasma")
	var ghost_cell: Vector2i = game.build_controller.ghost_placement().cell
	game.mobile_hud.open_catalog()
	game.mobile_hud._handle_drag_touch(0, Vector2(20.0, 300.0), true)
	assert_false(game.mobile_hud.is_catalog_open())
	assert_eq(game.build_controller.ghost_placement().cell, ghost_cell, "el toque afuera no llega al mapa")
	game.build_controller._unhandled_input(back)
	assert_null(game.build_controller.selected_tower(), "atrás suelta el fantasma")
	game.session.set_gold(0)
	await get_tree().process_frame
	game.mobile_hud.open_catalog()
	await get_tree().process_frame
	var unaffordable_card: Button = game.mobile_hud.find_child("CatalogCard_%s" % chosen.display_name.to_snake_case(), true, false) as Button
	assert_true(unaffordable_card.disabled)
	assert_true(unaffordable_card.text.contains("Faltan"), "el motivo se lee en la tarjeta")
	game.mobile_hud.close_catalog()
	game._unhandled_input(back)
	assert_true(game.pause_menu.is_open(), "atrás sin selección abre Pausa")
	SaveManager.set_setting("ui_mode", original_setting)


func test_mobile_infrastructure_catalog_can_enable_extraction_and_demolish() -> void:
	var original_setting: Variant = SaveManager.get_setting("ui_mode")
	var original_test_level: LevelData = GameFlow.test_level
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	GameFlow.test_level = GameFlow.level(9)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	assert_true(game.level_data.uses_infrastructure())
	assert_false(game.hud.bar_tabs.visible)
	assert_false(game.hud.infrastructure_tab.visible)
	var extraction: ObstacleSpec
	var removable: ObstacleSpec
	for spec: ObstacleSpec in game.level_data.obstacles:
		if extraction == null and spec.kind == ObstacleSpec.Kind.EXTRACTION:
			extraction = spec
		if removable == null and spec.kind == ObstacleSpec.Kind.REMOVABLE:
			removable = spec
	assert_not_null(extraction)
	assert_not_null(removable)
	game.mobile_hud.open_catalog()
	assert_null(game.mobile_hud.find_child("InfrastructureCards", true, false), "RF-540: el catálogo ya no trae infraestructura")
	game.mobile_hud.close_catalog()
	var gold_before: int = game.session.gold
	game._on_mobile_infrastructure_tool_chosen(&"extract", extraction.class_id)
	assert_true(game.build_controller.mobile_action_active())
	game.build_controller._mobile_map_tap(game.level.cell_center(extraction.cell), Time.get_ticks_msec())
	assert_eq(game.infrastructure.field.state_of(extraction.cell), ObstacleField.State.ACTIVE)
	assert_eq(game.session.gold, gold_before - game.infrastructure.field.cost_of(extraction.cell))
	var obstacle_name: String = ObstacleText.display_name(removable)
	game._on_mobile_infrastructure_tool_chosen(&"demolish", removable.class_id)
	game.build_controller._mobile_map_tap(game.level.cell_center(removable.cell), Time.get_ticks_msec())
	assert_true(game.infrastructure.field.has_job())
	assert_false(game.is_paused())
	GameFlow.test_level = original_test_level
	SaveManager.set_setting("ui_mode", original_setting)
