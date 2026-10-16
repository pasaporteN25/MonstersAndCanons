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


func test_mobile_placement_buttons_show_cost_and_disable_invalid_placement() -> void:
	var mobile_hud := MobileHud.new()
	add_child_autofree(mobile_hud)
	await get_tree().process_frame
	mobile_hud.show_placement(Vector2(500.0, 400.0), "300 + 3", true, "")
	var confirm: Button = mobile_hud.get_node("ConfirmPlacement") as Button
	var cancel: Button = mobile_hud.get_node("CancelPlacement") as Button
	assert_false(confirm.disabled)
	assert_true(confirm.text.contains("300 + 3"))
	assert_eq(confirm.custom_minimum_size, Vector2(96.0, 88.0))
	assert_eq(cancel.custom_minimum_size, Vector2(84.0, 84.0))
	mobile_hud.show_placement(Vector2(500.0, 400.0), "300 + 3", false, "Ahí no")
	assert_true(confirm.disabled)
	assert_true(confirm.text.contains("Ahí no"))


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
