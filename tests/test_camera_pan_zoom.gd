extends GutTest
# T568 (RF-731, RF-732, RF-505, H-07, D-223): zoom hasta 2,0 y un dedo que mueve el mapa.
# Partida real en un SubViewport, modo celular, eventos sintéticos. No prueba pinza ni rendimiento reales.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t568_zoom.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _start(level_index: int) -> void:
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func _zoom_to_max() -> Camera2D:
	var controller: CameraController = _game.camera_controller
	controller._zoom_at(Vector2(640.0, 344.0), 100.0)
	return controller._camera


func _touch(index: int, pos: Vector2, pressed: bool) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = index
	touch.position = pos
	touch.pressed = pressed
	_viewport.push_input(touch, true)
	await get_tree().process_frame


func _drag(index: int, pos: Vector2, relative: Vector2) -> void:
	var drag := InputEventScreenDrag.new()
	drag.index = index
	drag.position = pos
	drag.relative = relative
	_viewport.push_input(drag, true)
	await get_tree().process_frame


## Un dedo que apoya en `from` y se arrastra de a 10 px hasta `from + total` (sin soltar).
func _drag_finger(index: int, from: Vector2, total: Vector2) -> void:
	await _touch(index, from, true)
	var steps: int = int(ceil(total.length() / 10.0))
	var step: Vector2 = total / float(steps)
	for i: int in range(1, steps + 1):
		await _drag(index, from + step * i, step)


func _map_zoom_range(columns: int, rows: int) -> float:
	return minf(1.0, minf(1280.0 / (columns * Rules.TILE_SIZE), 560.0 / (rows * Rules.TILE_SIZE)))


# --- Rangos (RF-731) ---

func test_zoom_range_reaches_two_in_the_three_map_sizes() -> void:
	for size: Vector2i in [Vector2i(20, 9), Vector2i(24, 11), Vector2i(26, 12)]:
		var minimum: float = _map_zoom_range(size.x, size.y)
		var maximum: float = CameraController.maximum_zoom_from_cell_pixels(128.0)
		assert_lt(minimum, maximum, "%s: hay recorrido de zoom" % size)
		assert_eq(CameraController.clamp_zoom(9.0, minimum, maximum), 2.0, "%s: el tope es 2,0" % size)
		assert_eq(CameraController.clamp_zoom(0.1, minimum, maximum), minimum, "%s: el mínimo sigue siendo el encuadre" % size)


func test_pinch_and_wheel_zoom_reach_two_in_the_game() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	assert_not_null(camera)
	assert_almost_eq(camera.zoom.x, 2.0, 0.001)
	# Zoom con rueda en PC (RF-506): el mismo tope.
	_game.camera_controller.view_all()
	for i: int in 20:
		_game.camera_controller._zoom_at(Vector2(640.0, 344.0), 1.1)
	assert_almost_eq(camera.zoom.x, 2.0, 0.001)


func test_view_all_returns_to_the_automatic_framing() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	_game.camera_controller.pan_with_one_finger(Vector2(-300.0, 50.0))
	_game.camera_controller.view_all()
	assert_almost_eq(camera.zoom.x, _game.minimum_map_zoom, 0.001)
	assert_false(_game.camera_controller.is_view_displaced())


# --- Un dedo mueve el mapa (RF-732) ---

func test_one_finger_pans_the_zoomed_map_without_choosing_or_tapping() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	var taps: Array[int] = [0]
	_game.build_controller.mobile_map_tapped.connect(func() -> void: taps[0] += 1)
	var before: Vector2 = camera.position
	await _drag_finger(0, Vector2(700.0, 300.0), Vector2(-80.0, 0.0))
	await _touch(0, Vector2(620.0, 300.0), false)
	assert_gt(camera.position.x - before.x, 10.0, "arrastrar a la izquierda mueve la cámara hacia la derecha del mundo")
	assert_eq(taps[0], 0, "un arrastre no cuenta como toque")
	assert_eq(_game.build_controller.selected_tower(), null, "no se eligió nada")


func test_one_finger_does_not_pan_at_minimum_zoom() -> void:
	await _start(0)
	var controller: CameraController = _game.camera_controller
	var before: Vector2 = _game.camera.position if _game.camera != null else Vector2.ZERO
	await _drag_finger(0, Vector2(700.0, 300.0), Vector2(-120.0, 40.0))
	await _touch(0, Vector2(580.0, 340.0), false)
	var after: Vector2 = controller._camera.position if controller._camera != null else Vector2.ZERO
	assert_eq(after, before, "con el zoom mínimo un dedo no desplaza")
	assert_false(controller.is_zoomed_in())


func test_one_finger_with_a_ghost_moves_the_ghost_not_the_map() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	_game.build_controller.select(0)
	var before_camera: Vector2 = camera.position
	var before_cell: Vector2i = _game.build_controller._ghost_placement.cell
	await _drag_finger(0, Vector2(640.0, 300.0), Vector2(150.0, 0.0))
	await _touch(0, Vector2(790.0, 300.0), false)
	assert_eq(camera.position, before_camera, "con fantasma el mapa no se mueve")
	assert_ne(_game.build_controller._ghost_placement.cell, before_cell, "y el fantasma sí")


func test_pan_signal_is_not_emitted_while_a_ghost_exists() -> void:
	await _start(0)
	_zoom_to_max()
	_game.build_controller.select(0)
	var requested: Array[int] = [0]
	_game.build_controller.mobile_map_pan_requested.connect(func(_d: Vector2) -> void: requested[0] += 1)
	await _drag_finger(0, Vector2(640.0, 300.0), Vector2(100.0, 0.0))
	assert_eq(requested[0], 0)


func test_second_finger_hands_over_to_the_pinch_without_a_jump() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	_game.camera_controller._zoom_at(Vector2(640.0, 344.0), 0.7)  # margen para poder acercar de nuevo
	await _drag_finger(0, Vector2(600.0, 300.0), Vector2(-60.0, 0.0))
	var zoom_before: float = camera.zoom.x
	var position_before: Vector2 = camera.position
	await _touch(1, Vector2(800.0, 300.0), true)
	assert_eq(camera.position, position_before, "apoyar el segundo dedo no mueve nada")
	# Los dedos se separan: pinza.
	await _drag(0, Vector2(450.0, 300.0), Vector2(-90.0, 0.0))
	await _drag(1, Vector2(950.0, 300.0), Vector2(150.0, 0.0))
	assert_gt(camera.zoom.x, zoom_before - 0.0001, "la pinza abierta no aleja")
	await _touch(1, Vector2(950.0, 300.0), false)
	await _touch(0, Vector2(450.0, 300.0), false)
	assert_null(_game.build_controller.selected_tower(), "soltar los dedos no deja un toque que elija algo")


# --- Un toque acierta la casilla a cualquier zoom ---

func test_tap_hits_the_cell_under_the_finger_at_zoom_two_after_panning() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	_game.camera_controller.pan_with_one_finger(Vector2(-200.0, 30.0))
	await get_tree().process_frame  # la cámara aplica su transformación al final del cuadro
	_game.build_controller.select(0)
	var point := Vector2(500.0, 250.0)
	var expected: Vector2i = _game.level.cell_at(_viewport.get_canvas_transform().affine_inverse() * point)
	await _touch(0, point, true)
	await _touch(0, point, false)
	assert_eq(_game.build_controller._ghost_placement.cell, expected, "la casilla bajo el dedo, con zoom %s" % camera.zoom.x)


# --- Las cuatro esquinas ---

func test_all_four_corners_are_reachable_inside_the_map_area() -> void:
	await _start(0)
	var camera: Camera2D = _zoom_to_max()
	var size: Vector2 = Vector2(_game.level.map_size()) * Rules.TILE_SIZE
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(size.x, 0.0), Vector2(0.0, size.y), size]
	var pushes: Array[Vector2] = [Vector2(1e5, 1e5), Vector2(-1e5, 1e5), Vector2(1e5, -1e5), Vector2(-1e5, -1e5)]
	for i: int in 4:
		_game.camera_controller.pan_with_one_finger(pushes[i])
		await get_tree().process_frame
		var screen: Vector2 = _viewport.get_canvas_transform() * (_game.level.position + corners[i])
		assert_between(screen.y, 64.0, 624.0, "esquina %d dentro del área del mapa (entre las barras)" % i)
		assert_between(screen.x, 0.0, 1280.0, "esquina %d dentro de la pantalla" % i)
	assert_almost_eq(camera.zoom.x, 2.0, 0.001)


# --- H-07: el fantasma nace en lo que se ve ---

func test_ghost_is_born_near_the_center_of_what_is_visible() -> void:
	await _start(0)
	_zoom_to_max()
	_game.camera_controller.pan_with_one_finger(Vector2(1e5, 1e5))  # esquina superior izquierda a la vista
	await get_tree().process_frame
	_game.build_controller.select(0)
	var visible_center: Vector2i = _game.build_controller.visible_center_cell()
	var ghost: Vector2i = _game.build_controller._ghost_placement.cell
	assert_lt(Vector2(ghost).distance_to(Vector2(visible_center)), 4.0, "el fantasma nace cerca de %s, no en el centro del mapa" % visible_center)
	var map_size: Vector2i = _game.level.map_size()
	assert_lt(visible_center.x, map_size.x / 2, "con el mapa corrido a la izquierda, lo que se ve queda en la mitad izquierda")
