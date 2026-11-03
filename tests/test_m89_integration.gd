extends GutTest
# T579 (M89): combinaciones que ninguna ficha prueba sola. Partida real en celular con rieles 20:9 (un `SideRails`
# propio en un SubViewport, como en test_mobile_rails.gd). Sin ventana: se mide, no se mira; las capturas van aparte.

const TEST_SAVE: String = "user://test_m89_integration_save.json"
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
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func _set_surface(size: Vector2i) -> void:
	_surface.size = size
	_rails.size = Vector2(size)
	_rails.set_safe_area_provider(func() -> Rect2: return Rect2(Vector2.ZERO, Vector2(size)))
	_rails.set_frame_scale(PresentationGeometry.frame_scale(PresentationGeometry.frame_rect(Vector2(size)).size))


func _new_game() -> Game:
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	_surface = SubViewport.new()
	add_child_autofree(_surface)
	_rails = SideRails.new()
	_surface.add_child(_rails)
	_set_surface(SURFACE_20_9)
	game.mobile_hud.set_side_rails(_rails)
	await wait_process_frames(2)
	return game


func _free_cell(game: Game, skip: int = 0) -> Vector2i:
	var seen: int = 0
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and not game.build_controller.is_occupied(cell) \
					and game.infrastructure.obstacle_at(cell) == null:
				if seen == skip:
					return cell
				seen += 1
	return Vector2i(-1, -1)


func _place_and_select(game: Game) -> Tower:
	game.session.earn(5000)
	var data: TowerData = game.available_towers[0]
	var cell: Vector2i = _free_cell(game)
	assert_true(game.build_controller.try_build(data, cell))
	var tower: Tower = game.build_controller.tower_at(cell)
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	return tower


func test_zoom_two_with_rails_and_a_ghost_keeps_the_ghost_in_what_is_seen() -> void:
	var game: Game = await _new_game()
	var hud: MobileHud = game.mobile_hud
	for _i: int in 8:
		game.camera_controller.zoom_in_step()
	assert_almost_eq(game.camera.zoom.x, 2.0, 0.001, "el zoom llega a 2,0 con los rieles")
	game.build_controller.select(0)
	await wait_process_frames(2)
	var ghost: GhostPlacement = game.build_controller.ghost_placement()
	var seen_center: Vector2i = game.build_controller.visible_center_cell()
	assert_lt(Vector2(ghost.cell).distance_to(Vector2(seen_center)), 3.0, "el fantasma nace en lo que se ve, no en el centro del mapa")
	assert_true(hud.rails_active(), "los rieles siguen con zoom y fantasma")
	assert_gt(hud.rail_button(&"menu").modulate.a, 0.99, "el riel no se vuelve translúcido")
	game.build_controller.cancel()


func test_pan_then_double_tap_on_the_same_cell_opens_the_catalog_and_other_cell_does_not() -> void:
	var game: Game = await _new_game()
	for _i: int in 8:
		game.camera_controller.zoom_in_step()
	game.camera_controller.pan_with_one_finger(Vector2(-200.0, -60.0))
	await wait_process_frames(2)
	var cell: Vector2i = _free_cell(game, 20)
	var other: Vector2i = _free_cell(game, 25)
	game.build_controller._mobile_map_tap(game.level.cell_center(cell), 50000)
	game.build_controller._mobile_map_tap(game.level.cell_center(other), 50100)
	assert_false(game.mobile_hud.is_catalog_open(), "dos casillas distintas no cuentan")
	game.build_controller._mobile_map_tap(game.level.cell_center(cell), 60000)
	game.camera_controller.pan_with_one_finger(Vector2(40.0, 10.0))
	game.build_controller._mobile_map_tap(game.level.cell_center(cell), 60100)
	assert_true(game.mobile_hud.is_catalog_open(), "mover el mapa entre los toques no los invalida si es la misma casilla")


func test_armed_sell_and_opening_the_menu_does_not_sell() -> void:
	var game: Game = await _new_game()
	var hud: MobileHud = game.mobile_hud
	_place_and_select(game)
	var towers_before: int = game.tower_container.get_child_count()
	var sell: Button = hud.rail_button(&"sell")
	sell.pressed.emit()
	var armed_text: String = sell.text
	hud.rail_button(&"menu").pressed.emit()
	assert_true(game.pause_menu.is_open())
	assert_false(_rails.visible, "con el menú abierto los rieles no se ven")
	hud._sell_elapsed = 99.0
	sell.pressed.emit()
	assert_eq(game.tower_container.get_child_count(), towers_before, "con el menú abierto «Vender» no vende")
	game.close_pause_menu()
	assert_true(_rails.visible)
	assert_eq(game.tower_container.get_child_count(), towers_before, "al cerrar el menú, la torre sigue ahí")
	assert_true(armed_text != "", "el botón había pasado a pedir confirmación")


func test_boss_presentation_hides_rails_and_resizing_during_it_does_not_break_them() -> void:
	SaveManager.mark_tutorial_done()
	var game: Game = await _new_game()
	var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate() as Enemy
	enemy.data = load("res://data/enemies/boss.tres") as EnemyData
	game.testing = true  # fuera de la campaña la presentación no sale: se arma a mano abajo
	game.presentation = BossPresentation.new().setup(enemy.data, 3.0, true, null, null)
	game.add_child(game.presentation)
	game.mobile_hud.set_modal_open(true)
	assert_false(_rails.visible, "la presentación oculta los rieles")
	_set_surface(SURFACE_16_9)
	await wait_process_frames(2)
	_set_surface(SURFACE_20_9)
	await wait_process_frames(2)
	assert_false(_rails.visible, "cambiar de tamaño no los revive mientras dura")
	game.mobile_hud.set_modal_open(false)
	assert_true(_rails.visible, "al cerrar, vuelven")
	assert_eq(_rails.get_node("LeftColumn").get_child_count(), 6, "sin botones duplicados")
	game.presentation.queue_free()
	game.presentation = null
	enemy.free()


func test_selection_marker_zoom_and_grid_coexist() -> void:
	SaveManager.set_setting("map_grid", true)
	var game: Game = await _new_game()
	var tower: Tower = _place_and_select(game)
	for _i: int in 8:
		game.camera_controller.zoom_in_step()
	await wait_process_frames(2)
	assert_eq(game.build_controller.selected_placed(), tower, "la torre sigue elegida con zoom y cuadrícula")
	assert_true(game.mobile_hud.rail_button(&"sell").visible, "«Vender» del riel sigue a la vista")
	game.camera_controller.view_all()
	await wait_process_frames(2)
	assert_eq(game.build_controller.selected_placed(), tower, "y al volver a ver todo")


func test_grid_overlay_draws_in_a_real_game_without_errors() -> void:
	SaveManager.set_setting("map_grid", true)
	var game: Game = await _new_game()
	var overlay: Node = game.level.find_child("MapGridOverlay", true, false)
	assert_not_null(overlay)
	overlay.queue_redraw()
	await wait_process_frames(3)
	assert_eq(overlay.call("line_count", game.level.map_size()), game.level.map_size().x + game.level.map_size().y + 2)
