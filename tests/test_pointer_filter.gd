extends GutTest
# T311 (RF-552, D-116): la entrada del modo celular se decide por el dispositivo que genera el evento.
# Lógica pura de `PointerFilter` + la escena real de la partida con un clic de mouse real y con el orden de Android.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t311_pointer.json"
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


func _start() -> void:
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(0)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


func _mouse(pos: Vector2, pressed: bool, device: int = 0) -> void:
	var event := InputEventMouseButton.new()
	event.position = pos
	event.global_position = pos
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.device = device
	_viewport.push_input(event, true)
	await get_tree().process_frame


func _touch(pos: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = pos
	event.pressed = pressed
	_viewport.push_input(event, true)
	await get_tree().process_frame


## Una casilla del mapa, lejos de la del fantasma, y su posición en pantalla.
func _far_cell_screen_position() -> Vector2i:
	var ghost: Vector2i = _game.build_controller.ghost_placement().cell
	var size: Vector2i = _game.level.map_size()
	return Vector2i(0, 0) if ghost.x > size.x / 2 else Vector2i(size.x - 1, size.y - 1)


func _screen_of(cell: Vector2i) -> Vector2:
	return _game.get_viewport().get_canvas_transform() * _game.level.cell_center(cell)


# --- Lógica pura ---

func test_emulated_mouse_is_never_accepted() -> void:
	var filter := PointerFilter.new()
	assert_false(filter.accepts_mouse(InputEvent.DEVICE_ID_EMULATION, Vector2(500, 300), 1000))


func test_real_mouse_is_accepted_when_there_was_no_touch() -> void:
	var filter := PointerFilter.new()
	assert_true(filter.accepts_mouse(0, Vector2(500, 300), 1000))
	assert_true(filter.accepts_mouse(7, Vector2(500, 300), 1000), "cualquier dispositivo que no sea la emulación")


func test_unmarked_click_next_to_a_recent_touch_is_a_duplicate() -> void:
	var filter := PointerFilter.new()
	filter.configure(500, 32.0)
	filter.note_touch(Vector2(500, 300), 1000)
	assert_false(filter.accepts_mouse(0, Vector2(510, 305), 1400), "mismo lugar y 400 ms: duplicado")
	assert_true(filter.accepts_mouse(0, Vector2(510, 305), 1501), "pasó la ventana: es un clic de verdad")
	assert_true(filter.accepts_mouse(0, Vector2(600, 300), 1100), "lejos del toque: es otro dedo")
	assert_false(filter.accepts_mouse(0, Vector2(532, 300), 1000), "justo en el radio: duplicado")
	assert_true(filter.accepts_mouse(0, Vector2(533, 300), 1000), "un píxel más allá: no")


func test_mouse_finger_index_does_not_collide_with_touch_indices() -> void:
	assert_lt(PointerFilter.MOUSE_FINGER, 0)


func test_numbers_come_from_the_data_file() -> void:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	assert_eq(int(config.get_value("puntero_duplicado_ms")), 500)
	assert_eq(int(config.get_value("puntero_duplicado_px")), 32)


func test_input_paths_do_not_look_at_the_platform() -> void:
	# RF-552: el clic se acepta o se descarta por su dispositivo, no por `OS.has_feature("mobile")`.
	var build_source: String = FileAccess.get_file_as_string("res://scenes/game/build_controller.gd")
	assert_false(build_source.contains("has_feature(\"mobile\")"), "BuildController no mira la plataforma")
	var hud_source: String = FileAccess.get_file_as_string("res://scenes/game/mobile_hud.gd")
	var input_start: int = hud_source.find("func _input(")
	var input_end: int = hud_source.find("func _handle_status_touch(")
	assert_gt(input_start, 0)
	assert_false(hud_source.substr(input_start, input_end - input_start).contains("has_feature(\"mobile\")"), "MobileHud._input no mira la plataforma")


# --- Escena real ---

func test_real_mouse_click_moves_the_ghost_like_a_tap() -> void:
	await _start()
	_game.build_controller.select(0)
	await get_tree().process_frame
	var target: Vector2i = _far_cell_screen_position()
	var pos: Vector2 = _screen_of(target)
	await _mouse(pos, true)
	await _mouse(pos, false)
	assert_eq(_game.build_controller.ghost_placement().cell, target, "un clic real mueve el fantasma")


func test_touch_with_its_emulated_click_moves_the_ghost_once() -> void:
	await _start()
	_game.build_controller.select(0)
	await get_tree().process_frame
	var target: Vector2i = _far_cell_screen_position()
	var pos: Vector2 = _screen_of(target)
	var gold: int = _game.session.gold
	# El orden de Godot en cualquier plataforma: primero el clic emulado, después el toque.
	await _mouse(pos, true, InputEvent.DEVICE_ID_EMULATION)
	await _touch(pos, true)
	await _mouse(pos, false, InputEvent.DEVICE_ID_EMULATION)
	await _touch(pos, false)
	assert_eq(_game.build_controller.ghost_placement().cell, target)
	assert_eq(_game.session.gold, gold, "no se compró nada")
	assert_eq(_game.build_controller.selected_tower(), _game.available_towers[0], "la torre sigue elegida (no se interpretó como pinza ni doble toque)")


func test_unmarked_duplicate_after_a_touch_is_ignored_by_the_map() -> void:
	await _start()
	_game.build_controller.select(0)
	await get_tree().process_frame
	var target: Vector2i = _far_cell_screen_position()
	var pos: Vector2 = _screen_of(target)
	await _touch(pos, true)
	await _mouse(pos, true)  # un sistema que entrega el clic sin marcarlo
	await _touch(pos, false)
	await _mouse(pos, false)
	assert_eq(_game.build_controller.ghost_placement().cell, target, "se movió una vez, a donde se tocó")
	assert_eq(_game.build_controller.selected_tower(), _game.available_towers[0])
