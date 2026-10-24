# Tests del núcleo de la pantalla de carga (M64, RF-580 a RF-589, D-130 a D-134).
# Nunca se cambia la escena de GUT: `swapper` es una costura que cuenta las llamadas. La entrada se prueba con
# eventos reales (`Input.parse_input_event`), que pasan por la ventana principal igual que un toque del celular.
extends GutTest

const SMALL_SCENE: String = "res://scenes/ui/exit_dialog.tscn"

var _transition: SceneTransition
var _swaps: Array = []
var _pressed: Array = [0]
var _button: Button


func before_each() -> void:
	_swaps = []
	_pressed = [0]
	_transition = SceneTransition.new()
	_transition.min_seconds = 0.05
	_transition.release_seconds = 0.05
	_transition.swapper = func(scene: PackedScene) -> void: _swaps.append(scene)
	add_child_autofree(_transition)
	_button = Button.new()
	_button.position = Vector2(100, 100)
	_button.size = Vector2(200, 100)
	_button.pressed.connect(func() -> void: _pressed[0] += 1)
	add_child_autofree(_button)
	await wait_process_frames(2)


func after_each() -> void:
	get_tree().paused = false
	await wait_until(func() -> bool: return not _transition.is_busy(), 5.0)
	get_tree().root.set_disable_input(false)


func _wait_done() -> void:
	await wait_until(func() -> bool: return not _transition.is_busy(), 5.0)


## En la corrida sin pantalla la ventana mide 64 × 64 y el juego se estira a 1280 × 720: los eventos van en
## coordenadas de ventana, así que se pasa de las del juego a esas.
func _window_pos(game_pos: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * game_pos


## Para probar SOLO el bloqueo de la ventana: la capa deja pasar el mouse, así que si algo frena el clic es el bloqueo.
func _overlay_passes_mouse() -> void:
	(_transition.get_node("LoadingLayer/Root") as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _mouse(game_pos: Vector2, pressed: bool) -> void:
	var pos: Vector2 = _window_pos(game_pos)
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	Input.parse_input_event(motion)
	Input.flush_buffered_events()
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = pos
	event.global_position = pos
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _click_button() -> void:
	var center: Vector2 = _button.get_global_rect().get_center()
	_mouse(center, true)
	await wait_process_frames(1)
	_mouse(center, false)
	await wait_process_frames(1)


func _touch_button() -> void:
	var center: Vector2 = _button.get_global_rect().get_center()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.position = _window_pos(center)
	down.pressed = true
	Input.parse_input_event(down)
	await wait_process_frames(1)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.position = _window_pos(center)
	up.pressed = false
	Input.parse_input_event(up)
	await wait_process_frames(1)


# --- El cambio ---

func test_go_swaps_once_and_frees_everything() -> void:
	var finished: Array = [0]
	_transition.finished.connect(func(_p: String) -> void: finished[0] += 1)
	assert_true(_transition.go(SMALL_SCENE), "empieza")
	assert_true(_transition.is_busy())
	assert_true(_transition.is_overlay_visible(), "RF-580: la capa se ve")
	await _wait_done()
	assert_eq(_swaps.size(), 1, "se cambió una sola vez")
	assert_true(_swaps[0] is PackedScene, "con la escena cargada")
	assert_eq(finished[0], 1)
	assert_false(_transition.is_overlay_visible(), "la capa se oculta")
	assert_false(get_tree().root.is_input_disabled(), "RF-583: la entrada se libera")
	assert_eq(_transition.progress(), 1.0)


func test_second_go_while_busy_is_ignored() -> void:
	assert_true(_transition.go(SMALL_SCENE))
	assert_false(_transition.go(SMALL_SCENE), "RF-582: un segundo cambio no empieza")
	assert_false(_transition.go("res://scenes/ui/main_menu.tscn"), "ni uno a otra escena")
	await _wait_done()
	assert_eq(_swaps.size(), 1)
	assert_true(_transition.go(SMALL_SCENE), "terminado el cambio, se puede volver a pedir")
	await _wait_done()
	assert_eq(_swaps.size(), 2)


func test_minimum_time_is_respected_even_if_the_scene_is_instant() -> void:
	_transition.min_seconds = 0.4
	var t0: int = Time.get_ticks_msec()
	_transition.go(SMALL_SCENE)
	await _wait_done()
	assert_gte(Time.get_ticks_msec() - t0, 400, "RF-585: la capa no parpadea")


func test_threaded_and_synchronous_loading_both_work() -> void:
	_transition.use_threads = true
	_transition.go(SMALL_SCENE)
	await _wait_done()
	_transition.use_threads = false
	_transition.go(SMALL_SCENE)
	await _wait_done()
	assert_eq(_swaps.size(), 2)
	assert_true(_swaps[0] is PackedScene and _swaps[1] is PackedScene)


func test_a_missing_scene_fails_cleanly() -> void:
	var failed: Array = [0]
	_transition.failed.connect(func(_p: String) -> void: failed[0] += 1)
	_transition.go("res://no/existe.tscn")
	await _wait_done()
	assert_eq(failed[0], 1, "RF-587: avisa")
	assert_eq(_swaps.size(), 0, "no cambia nada")
	assert_false(get_tree().root.is_input_disabled(), "y no deja la entrada bloqueada")
	assert_false(_transition.is_overlay_visible())


func test_it_runs_while_the_tree_is_paused() -> void:
	get_tree().paused = true
	_transition.go(SMALL_SCENE)
	var timer: SceneTreeTimer = get_tree().create_timer(5.0, true)  # GUT también se pausa: se espera a mano
	while _transition.is_busy() and timer.time_left > 0.0:
		await get_tree().process_frame
	var still_paused: bool = get_tree().paused
	get_tree().paused = false
	assert_eq(_swaps.size(), 1, "RF-586: la pausa no la detiene")
	assert_true(still_paused, "y no cambia la pausa de nadie")


func test_time_scale_does_not_stretch_the_minimum() -> void:
	Engine.time_scale = 0.1
	var t0: int = Time.get_ticks_msec()
	_transition.min_seconds = 0.2
	_transition.go(SMALL_SCENE)
	await _wait_done()
	Engine.time_scale = 1.0
	assert_lt(Time.get_ticks_msec() - t0, 2500, "RF-585: reloj real, no delta")


# --- La entrada ---

func test_control_experiment_a_click_reaches_the_button_without_transition() -> void:
	await _click_button()
	assert_eq(_pressed[0], 1, "el helper de clics funciona (si no, los otros tests no probarían nada)")


func test_control_experiment_without_blocking_the_click_gets_through() -> void:
	_transition.blocks_input = false
	_overlay_passes_mouse()
	_transition.go(SMALL_SCENE)
	await _click_button()
	assert_eq(_pressed[0], 1, "sin el bloqueo ni la capa el clic atraviesa: este era el defecto")
	await _wait_done()


func test_the_overlay_alone_also_swallows_the_click() -> void:
	_transition.blocks_input = false
	_transition.go(SMALL_SCENE)
	await _click_button()
	assert_eq(_pressed[0], 0, "la capa de carga cubre y frena el clic aunque falte el bloqueo de la ventana")
	await _wait_done()


func test_mouse_clicks_are_blocked_during_the_transition() -> void:
	_overlay_passes_mouse()
	_transition.go(SMALL_SCENE)
	assert_true(get_tree().root.is_input_disabled(), "RF-583")
	await _click_button()
	await _click_button()
	assert_eq(_pressed[0], 0, "ningún clic llega")
	await _wait_done()


func test_touches_are_blocked_during_the_transition() -> void:
	_overlay_passes_mouse()
	_transition.go(SMALL_SCENE)
	await _touch_button()
	await _touch_button()
	assert_eq(_pressed[0], 0, "RF-583: ni el toque ni el clic que emula")
	await _wait_done()


func test_keys_and_back_are_blocked_during_the_transition() -> void:
	var seen: Array = [0]
	var listener := _Listener.new()
	listener.seen = seen
	add_child_autofree(listener)
	_transition.go(SMALL_SCENE)
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.physical_keycode = KEY_ESCAPE
	key.pressed = true
	Input.parse_input_event(key)
	var back := InputEventAction.new()
	back.action = &"cancel"
	back.pressed = true
	Input.parse_input_event(back)
	await wait_process_frames(2)
	assert_eq(seen[0], 0, "RF-583: ni teclas ni «atrás» (que es la acción cancel)")
	await _wait_done()


func test_control_experiment_keys_reach_a_listener_without_blocking() -> void:
	var seen: Array = [0]
	var listener := _Listener.new()
	listener.seen = seen
	add_child_autofree(listener)
	_transition.blocks_input = false
	_transition.go(SMALL_SCENE)
	var back := InputEventAction.new()
	back.action = &"cancel"
	back.pressed = true
	Input.parse_input_event(back)
	await wait_process_frames(2)
	assert_gt(seen[0], 0, "sin bloqueo «atrás» llega: el test de arriba no es vacío")
	await _wait_done()


func test_events_that_arrive_while_the_engine_is_busy_swapping_are_dropped() -> void:
	_overlay_passes_mouse()
	# Lo que pasa en el celular: la escena nueva tarda en armarse y los toques se juntan.
	_transition.swapper = func(scene: PackedScene) -> void:
		_swaps.append(scene)
		var center: Vector2 = _button.get_global_rect().get_center()
		_mouse(center, true)
		_mouse(center, false)
	_transition.go(SMALL_SCENE)
	await _wait_done()
	assert_eq(_pressed[0], 0, "RF-584: lo acumulado durante el cambio se descarta")


func test_input_works_again_after_the_transition() -> void:
	_transition.go(SMALL_SCENE)
	await _wait_done()
	await _click_button()
	assert_eq(_pressed[0], 1, "RF-583: se libera al terminar")


func test_input_is_restored_even_if_the_node_leaves_the_tree_mid_transition() -> void:
	_transition.go(SMALL_SCENE)
	assert_true(get_tree().root.is_input_disabled())
	remove_child(_transition)
	assert_false(get_tree().root.is_input_disabled(), "RF-587: no deja la entrada bloqueada para siempre")
	_transition.free()
	_transition = SceneTransition.new()
	add_child_autofree(_transition)


func test_an_input_that_was_already_disabled_stays_disabled() -> void:
	get_tree().root.set_disable_input(true)
	_transition.go(SMALL_SCENE)
	await _wait_done()
	assert_true(get_tree().root.is_input_disabled(), "se restaura lo que había, no se fuerza a false")


# --- Genérico ---

func test_the_core_does_not_mention_the_project() -> void:
	var text: String = FileAccess.get_file_as_string("res://scripts/logic/scene_transition.gd")
	for word: String in ["GameFlow", "SaveManager", "DevMode", "Audio.", "UiMode", "LevelData", "res://scenes", "res://data", "res://assets"]:
		assert_false(text.contains(word), "RF-581: el núcleo no depende del juego («%s»)" % word)


func test_the_overlay_has_title_and_a_bar_and_catches_the_mouse() -> void:
	var root: Control = _transition.get_node("LoadingLayer/Root")
	assert_eq(root.mouse_filter, Control.MOUSE_FILTER_STOP)
	assert_eq((_transition.get_node("LoadingLayer/Root/Center/Column/Title") as Label).text, "Cargando…")
	assert_not_null(_transition.find_child("Bar", true, false))


func test_overlay_content_scales_with_the_logical_frame_but_keeps_its_full_window_root() -> void:
	var root: Control = _transition.get_node("LoadingLayer/Root")
	var center: CenterContainer = _transition.get_node("LoadingLayer/Root/Center")
	var original_size: Vector2 = root.size
	_transition.set_overlay_scale(1.5)
	assert_eq(center.scale, Vector2(1.5, 1.5))
	assert_eq(center.pivot_offset, center.size * 0.5)
	assert_eq(root.size, original_size, "el fondo y el capturador siguen cubriendo la ventana")


class _Listener extends Node:
	var seen: Array

	func _input(event: InputEvent) -> void:
		if event is InputEventKey or event.is_action(&"cancel"):
			seen[0] += 1

	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey or event.is_action(&"cancel"):
			seen[0] += 1
