# Tests del zoom de los mapas grandes (T117, RF-251, RF-252, D-037).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")


func _big_level(w: int, h: int) -> LevelData:
	var rows: Array = []
	for y: int in h:
		rows.append(".".repeat(w))
	rows[h / 2] = "A" + "#".repeat(w - 2) + "S"
	var text: String = JSON.stringify({
		"version": 1, "nombre": "Grande", "oro": 500, "vidas": 10, "mapa": rows,
		"oleadas": [[{"enemigo": "normal", "cantidad": 3, "cada": 1.0}]],
	})
	return LevelFile.parse(text, &"grande")["level"]


func _game(level: LevelData = null) -> Game:
	var game: Game = GAME_SCENE.instantiate()
	if level != null:
		game.level_data = level
	add_child_autofree(game)
	return game


## Dónde cae en la pantalla un punto del mundo, según la cámara (la fórmula de Godot).
func _screen_of(world: Vector2, zoom: float, center: Vector2) -> Vector2:
	return (world - center) * zoom + Rules.SCREEN_SIZE / 2.0


# --- La fórmula ---

func test_zoom_is_one_for_the_usual_size() -> void:
	assert_eq(Rules.map_zoom(20, 9), 1.0)
	assert_eq(Rules.map_camera_center(20, 9), Rules.SCREEN_SIZE / 2.0, "la cámara no cambia nada")


func test_zoom_of_the_biggest_size_is_three_quarters() -> void:
	assert_almost_eq(Rules.map_zoom(26, 12), 0.75, 0.0001)


func test_zoom_is_limited_by_the_tighter_side() -> void:
	assert_almost_eq(Rules.map_zoom(26, 9), 1280.0 / (26.0 * 64.0), 0.0001, "manda el ancho")
	assert_almost_eq(Rules.map_zoom(20, 12), 0.75, 0.0001, "manda el alto")
	assert_almost_eq(Rules.map_zoom(21, 9), 1280.0 / (21.0 * 64.0), 0.0001)


func test_zoom_never_enlarges_and_always_fits() -> void:
	for w: int in range(MapGrid.MIN_WIDTH, MapGrid.MAX_WIDTH + 1):
		for h: int in range(MapGrid.MIN_HEIGHT, MapGrid.MAX_HEIGHT + 1):
			var zoom: float = Rules.map_zoom(w, h)
			assert_lte(zoom, 1.0)
			assert_lte(w * 64.0 * zoom, 1280.0 + 0.001, "%d×%d entra a lo ancho" % [w, h])
			assert_lte(h * 64.0 * zoom, 576.0 + 0.001, "%d×%d entra a lo alto" % [w, h])
			assert_gte(zoom, 0.75 - 0.0001, "nunca más chico que 0,75 (RF-250)")


func test_the_map_is_centered_in_the_map_area_for_every_size() -> void:
	for w: int in [20, 23, 26]:
		for h: int in [9, 11, 12]:
			var zoom: float = Rules.map_zoom(w, h)
			var center: Vector2 = Rules.map_camera_center(w, h)
			var top_left: Vector2 = _screen_of(Vector2(0, 48), zoom, center)
			var bottom_right: Vector2 = _screen_of(Vector2(w, h) * 64.0 + Vector2(0, 48), zoom, center)
			assert_true(Rules.MAP_AREA.grow(0.01).has_point(top_left), "%d×%d: esquina de arriba" % [w, h])
			assert_true(Rules.MAP_AREA.grow(0.01).has_point(bottom_right), "%d×%d: esquina de abajo" % [w, h])
			assert_almost_eq((top_left + bottom_right) / 2.0, Rules.MAP_AREA.get_center(), Vector2(0.01, 0.01), "%d×%d centrado" % [w, h])


# --- En la partida ---

func test_a_usual_map_has_no_camera() -> void:
	var game: Game = _game()
	assert_null(game.camera, "con 20×9 todo es igual que siempre")


func test_the_level_reports_its_size() -> void:
	assert_eq(_game().level.map_size(), Vector2i(20, 9))
	assert_eq(_game(_big_level(26, 12)).level.map_size(), Vector2i(26, 12))


func test_a_big_map_gets_a_camera_with_the_right_zoom_and_center() -> void:
	var game: Game = _game(_big_level(26, 12))
	assert_not_null(game.camera)
	assert_eq(game.camera.zoom, Vector2(0.75, 0.75))
	assert_eq(game.camera.position, Rules.map_camera_center(26, 12))


func test_the_camera_maps_the_world_where_the_formula_says() -> void:
	var game: Game = _game(_big_level(26, 12))
	await wait_frames(3)
	assert_eq(get_viewport().get_visible_rect().size, Rules.SCREEN_SIZE, "la pantalla de prueba mide 1280×720")
	var transform: Transform2D = game.get_canvas_transform()
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(25, 11), Vector2i(13, 6)]:
		var world: Vector2 = game.level.cell_center(cell)
		assert_almost_eq(transform * world, _screen_of(world, 0.75, game.camera.position), Vector2(0.01, 0.01), str(cell))
		assert_true(Rules.MAP_AREA.has_point(transform * world), "%s se ve dentro del área del mapa" % cell)


func test_the_cell_under_a_screen_point_is_the_right_one() -> void:
	# RF-252: es lo que hace get_global_mouse_position() con una cámara.
	var game: Game = _game(_big_level(26, 12))
	await wait_frames(3)
	var inverse: Transform2D = game.get_canvas_transform().affine_inverse()
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(25, 11), Vector2i(7, 3), Vector2i(20, 10)]:
		var screen: Vector2 = game.get_canvas_transform() * game.level.cell_center(cell)
		assert_eq(game.level.cell_at(inverse * screen), cell, "el centro de %s" % cell)
		assert_eq(game.level.cell_at(inverse * (screen + Vector2(15, -15))), cell, "cerca del borde de %s" % cell)


func test_towers_and_ranges_keep_their_world_coordinates() -> void:
	# Lo que justifica la cámara (D-037): nada del combate se entera del zoom.
	var big: Game = _game(_big_level(26, 12))
	var usual: Game = _game()
	var basic: TowerData = big.tower_types[0]
	assert_true(big.build_controller.try_build(basic, Vector2i(10, 2)))
	assert_true(usual.build_controller.try_build(usual.tower_types[0], Vector2i(10, 2)))
	var tower_big: Tower = big.build_controller.tower_at(Vector2i(10, 2))
	var tower_usual: Tower = usual.build_controller.tower_at(Vector2i(10, 2))
	assert_eq(tower_big.global_position, Vector2(10.5, 2.5) * 64.0 + Vector2(0, 48), "en el mundo, la casilla mide 64")
	assert_eq(tower_big.global_position, tower_usual.global_position)
	assert_eq(tower_big.range_px(), tower_usual.range_px(), "el alcance no cambia con el zoom")
	var enemy_position: Vector2 = tower_big.global_position + Vector2(tower_big.range_px() - 1.0, 0)
	assert_true(tower_big.global_position.distance_to(enemy_position) <= tower_big.range_px())
	assert_true(tower_usual.global_position.distance_to(enemy_position) <= tower_usual.range_px())


func test_the_bars_do_not_shrink() -> void:
	var game: Game = _game(_big_level(26, 12))
	assert_true(game.hud is CanvasLayer, "la barra de arriba y la de torres no las toca la cámara")
	assert_true(game.end_screen is CanvasLayer)
	assert_true(game.pause_menu is CanvasLayer)


func test_a_big_map_can_be_played_through_a_whole_wave() -> void:
	var game: Game = _game(_big_level(26, 12))
	game.start_next_wave()
	simulate(game, 60 * 20, 1.0 / 60.0)
	assert_gt(game.session.lives, 0)
	assert_lt(game.session.lives, 10, "los enemigos recorrieron el mapa grande hasta la salida")
