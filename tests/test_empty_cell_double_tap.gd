extends GutTest
# T573 (RF-740, D-227): doble toque o doble clic en una casilla vacía abre la compra.
# Parte 1: la función pura. Parte 2: partidas reales en un SubViewport, en modo celular y en modo PC.

const WINDOW_MS: int = 350

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String
var _fired: Array[Vector2i] = []


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t573_double_tap.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	_fired = []
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _start(level_index: int, mode: Variant) -> void:
	SaveManager.set_setting("ui_mode", mode)
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame
	_game.build_controller.empty_cell_double_tapped.connect(func(cell: Vector2i) -> void: _fired.append(cell))


func _is_free_grass(cell: Vector2i) -> bool:
	return _game.level.is_buildable(cell) and not _game.build_controller.is_occupied(cell) and _game.infrastructure.obstacle_at(cell) == null


func _grass_cell(not_cell: Vector2i = Vector2i(-1, -1)) -> Vector2i:
	for y: int in _game.level.map_size().y:
		for x: int in _game.level.map_size().x:
			var cell := Vector2i(x, y)
			if cell != not_cell and _is_free_grass(cell):
				return cell
	return Vector2i(-1, -1)


func _path_cell() -> Vector2i:
	for y: int in _game.level.map_size().y:
		for x: int in _game.level.map_size().x:
			var cell := Vector2i(x, y)
			if not _game.level.is_buildable(cell) and _game.infrastructure.obstacle_at(cell) == null:
				return cell
	return Vector2i(-1, -1)


## Un toque en el celular (el mismo camino que el dedo, ya reconocido como TAP) o un clic en la PC.
func _tap(cell: Vector2i, time_ms: int) -> void:
	if UiMode.is_mobile():
		_game.build_controller._mobile_map_tap(_game.level.cell_center(cell), time_ms)
	else:
		_game.build_controller._selection_click(cell, time_ms)


func _double_tap(cell: Vector2i, gap_ms: int = 100) -> void:
	_tap(cell, 10000)
	_tap(cell, 10000 + gap_ms)


# --- La función pura ---

func test_pure_same_cell_inside_the_window_matches() -> void:
	var tap := EmptyCellDoubleTap.new()
	assert_false(tap.register(Vector2i(3, 2), true, 1000, WINDOW_MS))
	assert_true(tap.register(Vector2i(3, 2), true, 1200, WINDOW_MS))


func test_pure_different_cell_does_not_match() -> void:
	var tap := EmptyCellDoubleTap.new()
	tap.register(Vector2i(3, 2), true, 1000, WINDOW_MS)
	assert_false(tap.register(Vector2i(4, 2), true, 1100, WINDOW_MS))


func test_pure_outside_the_window_does_not_match() -> void:
	var tap := EmptyCellDoubleTap.new()
	tap.register(Vector2i(3, 2), true, 1000, WINDOW_MS)
	assert_false(tap.register(Vector2i(3, 2), true, 1000 + WINDOW_MS, WINDOW_MS), "justo en el borde ya no cuenta")


func test_pure_ineligible_first_tap_forgets_it() -> void:
	var tap := EmptyCellDoubleTap.new()
	tap.register(Vector2i(3, 2), false, 1000, WINDOW_MS)
	assert_false(tap.register(Vector2i(3, 2), true, 1100, WINDOW_MS), "el primero no era válido")


func test_pure_a_third_tap_is_not_another_double() -> void:
	var tap := EmptyCellDoubleTap.new()
	tap.register(Vector2i(3, 2), true, 1000, WINDOW_MS)
	assert_true(tap.register(Vector2i(3, 2), true, 1100, WINDOW_MS))
	assert_false(tap.register(Vector2i(3, 2), true, 1200, WINDOW_MS))


# --- Celular ---

func test_mobile_double_tap_opens_the_catalog_and_charges_nothing() -> void:
	await _start(0, UiMode.MOBILE)
	var gold: int = _game.session.gold
	var cell: Vector2i = _grass_cell()
	assert_false(_game.mobile_hud.is_catalog_open())
	_double_tap(cell)
	assert_eq(_fired, [cell] as Array[Vector2i])
	assert_true(_game.mobile_hud.is_catalog_open(), "se abre el catálogo")
	assert_eq(_game.session.gold, gold, "no se cobra nada")
	assert_eq(_game.build_controller.selected_tower(), null, "y no elige ninguna torre")


func test_mobile_a_single_tap_only_releases_the_selection() -> void:
	await _start(0, UiMode.MOBILE)
	_tap(_grass_cell(), 10000)
	assert_true(_fired.is_empty())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_two_different_cells_do_not_count() -> void:
	await _start(0, UiMode.MOBILE)
	var cell: Vector2i = _grass_cell()
	_tap(cell, 10000)
	_tap(_grass_cell(cell), 10100)
	assert_true(_fired.is_empty())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_after_the_window_does_not_count() -> void:
	await _start(0, UiMode.MOBILE)
	_double_tap(_grass_cell(), WINDOW_MS + 50)
	assert_true(_fired.is_empty())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_the_path_does_not_count() -> void:
	await _start(0, UiMode.MOBILE)
	_double_tap(_path_cell())
	assert_true(_fired.is_empty())


func test_mobile_a_tower_does_not_count() -> void:
	await _start(0, UiMode.MOBILE)
	var cell: Vector2i = _grass_cell()
	_game.session.earn(5000)
	assert_true(_game.build_controller.try_build(_game.available_towers[0], cell))
	_double_tap(cell)
	assert_true(_fired.is_empty())
	assert_not_null(_game.build_controller.selected_placed(), "el toque simple elige la torre, como siempre")


func test_mobile_with_a_ghost_the_double_tap_still_confirms() -> void:
	await _start(0, UiMode.MOBILE)
	_game.session.earn(5000)
	var cell: Vector2i = _grass_cell()
	_game.build_controller.select(0)
	var gold: int = _game.session.gold
	_double_tap(cell)
	assert_true(_fired.is_empty(), "con fantasma no es la señal de compra")
	assert_true(_game.build_controller.is_occupied(cell), "confirma la torre (RF-505)")
	assert_lt(_game.session.gold, gold)
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_a_tap_with_a_ghost_does_not_arm_the_next_one() -> void:
	await _start(0, UiMode.MOBILE)
	var cell: Vector2i = _grass_cell()
	_game.build_controller.select(0)
	_tap(cell, 10000)  # mueve el fantasma
	_game.build_controller.cancel()
	_tap(cell, 10100)  # primer toque sin fantasma
	assert_true(_fired.is_empty())


func test_mobile_with_an_infrastructure_tool_does_not_count() -> void:
	await _start(6, UiMode.MOBILE)
	_game.mobile_hud.demolish_pressed.emit()
	_double_tap(_grass_cell())
	assert_true(_fired.is_empty())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_a_removable_object_does_not_count() -> void:
	await _start(6, UiMode.MOBILE)
	var cell := Vector2i(-1, -1)
	for spec: ObstacleSpec in _game.level_data.obstacles:
		cell = spec.cell
		break
	assert_ne(cell, Vector2i(-1, -1))
	_double_tap(cell)
	assert_true(_fired.is_empty())


func test_mobile_paused_does_not_open_the_catalog() -> void:
	await _start(0, UiMode.MOBILE)
	_game.set_paused(true)
	_double_tap(_grass_cell())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_a_finished_game_does_not_count() -> void:
	await _start(0, UiMode.MOBILE)
	_game.session.lose_lives(_game.session.lives)
	assert_true(_game.session.is_over())
	_double_tap(_grass_cell())
	assert_true(_fired.is_empty())
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_with_a_modal_open_the_catalog_stays_closed() -> void:
	await _start(0, UiMode.MOBILE)
	var cell: Vector2i = _grass_cell()
	_tap(cell, 10000)
	_game.open_pause_menu()
	_tap(cell, 10100)
	assert_false(_game.mobile_hud.is_catalog_open())


func test_mobile_a_drag_is_not_a_tap() -> void:
	# El gesto lo clasifica TouchGesture (T568): solo un TAP llega a `_mobile_map_tap`. Un arrastre no lo hace.
	var gesture := TouchGesture.new()
	gesture.configure(24.0, 120)
	gesture.down(0, Vector2(300, 300), 1000)
	gesture.move(0, Vector2(380, 300), 1040)
	assert_ne(gesture.up(0, Vector2(380, 300), 1080), TouchGesture.Gesture.TAP)


func test_mobile_opening_the_catalog_this_way_emits_the_tutorial_signal() -> void:
	await _start(0, UiMode.MOBILE)
	var opened: Array[bool] = []
	_game.mobile_hud.catalog_opened.connect(func(open: bool) -> void: opened.append(open))
	_double_tap(_grass_cell())
	assert_eq(opened, [true] as Array[bool], "es la misma señal que mueve el paso `open_cart`")


# --- PC ---

func test_pc_double_click_switches_to_the_tower_tab_and_pulses_the_bar() -> void:
	await _start(9, UiMode.PC)
	assert_true(_game.hud.has_tabs(), "el nivel 10 tiene pestañas")
	_game.hud.show_tab(Hud.TAB_INFRASTRUCTURE)
	var gold: int = _game.session.gold
	var cell: Vector2i = _grass_cell()
	_double_tap(cell)
	assert_eq(_fired, [cell] as Array[Vector2i])
	assert_eq(_game.hud.current_tab(), Hud.TAB_CANNONS)
	assert_eq(_game.session.gold, gold)
	assert_eq(_game.build_controller.selected_tower(), null)
	var bottom: Control = _game.hud.get_node("BottomBar")
	await get_tree().create_timer(0.1).timeout
	assert_ne(bottom.modulate, Color.WHITE, "la barra pulsa")


func test_pc_without_tabs_the_double_click_does_not_fail() -> void:
	await _start(0, UiMode.PC)
	_double_tap(_grass_cell())
	assert_eq(_fired.size(), 1)
	assert_eq(_game.hud.current_tab(), Hud.TAB_CANNONS)


func test_pc_single_click_or_other_cell_or_late_does_not_count() -> void:
	await _start(0, UiMode.PC)
	var cell: Vector2i = _grass_cell()
	_tap(cell, 10000)
	assert_true(_fired.is_empty())
	_tap(_grass_cell(cell), 10100)
	assert_true(_fired.is_empty())
	_tap(cell, 20000)
	_tap(cell, 20000 + WINDOW_MS + 10)
	assert_true(_fired.is_empty())


func test_pc_path_and_tower_do_not_count() -> void:
	await _start(0, UiMode.PC)
	_double_tap(_path_cell())
	assert_true(_fired.is_empty())
	var cell: Vector2i = _grass_cell()
	_game.session.earn(5000)
	assert_true(_game.build_controller.try_build(_game.available_towers[0], cell))
	_double_tap(cell)
	assert_true(_fired.is_empty())


func test_pc_with_a_tower_chosen_to_build_does_not_count() -> void:
	await _start(0, UiMode.PC)
	_game.build_controller.select(0)
	assert_false(_game.build_controller._is_empty_tap_cell(_grass_cell()), "con una torre elegida el clic construye (RF-43)")


func test_pc_paused_or_finished_does_not_switch_tab() -> void:
	await _start(9, UiMode.PC)
	_game.hud.show_tab(Hud.TAB_INFRASTRUCTURE)
	_game.set_paused(true)
	_double_tap(_grass_cell())
	assert_eq(_game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
	_game.set_paused(false)
	_game.session.lose_lives(_game.session.lives)
	_double_tap(_grass_cell())
	assert_eq(_game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
