extends GutTest
# T312 (RF-551, D-115): desplazamiento de un dedo con inercia en los menús del celular.
# Eventos reales por `push_input`, con el orden de Godot: primero el clic emulado y después el toque.

var _viewport: SubViewport
var _scroll: ScrollContainer
var _buttons: Array[Button] = []
var _pressed: Array[int] = []
var _original_mode: Variant


func before_each() -> void:
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)
	_buttons.clear()
	_pressed.clear()


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)


## Una pantalla de prueba: un `ScrollContainer` de 400 × 400 con 30 botones de 56 px y un deslizador al principio.
func _build(with_slider: bool = false) -> void:
	var screen := Control.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_viewport.add_child(screen)
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(100, 100)
	_scroll.size = Vector2(400, 400)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.add_child(_scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(rows)
	if with_slider:
		var slider := HSlider.new()
		slider.name = "Volume"
		rows.add_child(slider)
	for i: int in 30:
		var button := Button.new()
		button.text = "Fila %d" % i
		button.custom_minimum_size = Vector2(0, 56)
		button.pressed.connect(func() -> void: _pressed.append(i))
		rows.add_child(button)
		_buttons.append(button)
	MenuTouch.attach(screen)
	await get_tree().process_frame
	await get_tree().process_frame


func _emulated(pos: Vector2, pressed: bool) -> void:
	var mouse := InputEventMouseButton.new()
	mouse.position = pos
	mouse.global_position = pos
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = pressed
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	_viewport.push_input(mouse, true)


func _touch(pos: Vector2, pressed: bool) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = pos
	touch.pressed = pressed
	_viewport.push_input(touch, true)


func _drag(from: Vector2, to: Vector2) -> void:
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = to
	drag.relative = to - from
	_viewport.push_input(drag, true)


## Un dedo que apoya en `from`, se arrastra por pasos hasta `to` y suelta (con el orden de Android).
func _swipe(from: Vector2, to: Vector2, steps: int = 6, wait_s: float = 0.0) -> void:
	_emulated(from, true)
	_touch(from, true)
	await get_tree().process_frame
	var last: Vector2 = from
	for i: int in steps:
		var point: Vector2 = from.lerp(to, float(i + 1) / float(steps))
		_drag(last, point)
		last = point
		if wait_s > 0.0:
			await get_tree().create_timer(wait_s).timeout
		else:
			await get_tree().process_frame
	_emulated(to, false)
	_touch(to, false)
	await get_tree().process_frame


func _tap(pos: Vector2) -> void:
	_emulated(pos, true)
	_touch(pos, true)
	await get_tree().process_frame
	_emulated(pos, false)
	_touch(pos, false)
	await get_tree().process_frame


# --- Lógica pura ---

func test_kinetic_math() -> void:
	assert_false(KineticScroll.is_drag(12.0, 12.0), "justo en el umbral sigue siendo un toque")
	assert_true(KineticScroll.is_drag(12.5, 12.0))
	assert_almost_eq(KineticScroll.decay(100.0, 4.0, 0.0), 100.0, 0.001)
	assert_lt(KineticScroll.decay(100.0, 4.0, 0.5), 15.0, "frena fuerte en medio segundo")
	assert_gt(KineticScroll.decay(100.0, 4.0, 0.5), 0.0, "nunca cambia de signo")
	assert_true(KineticScroll.is_stopped(Vector2(10, 10), 30.0))
	assert_false(KineticScroll.is_stopped(Vector2(0, 100), 30.0))
	assert_almost_eq(KineticScroll.finger_velocity(Vector2(0, 8), 0.0).y, 1000.0, 0.01, "dt mínimo de 8 ms")


func test_numbers_come_from_the_data_file() -> void:
	var config: MobileUiConfig = MobileUiConfig.load_from()
	assert_eq(int(config.get_value("scroll_umbral_px")), 12)
	assert_gt(float(config.get_value("scroll_friccion")), 0.0)
	assert_gte(int(config.get_value("scroll_barra_px")), 20)


# --- La pantalla ---

func test_mobile_menu_touch_raises_buttons_bars_and_adds_the_scroller() -> void:
	await _build(true)
	for button: Button in _buttons:
		assert_gte(button.custom_minimum_size.y, 56.0)
	assert_gte((_scroll.find_child("Volume", true, false) as Control).custom_minimum_size.y, 44.0, "el deslizador también se agranda")
	assert_not_null(_scroll.find_child("TouchScroller", false, false))
	assert_gte(_scroll.get_v_scroll_bar().custom_minimum_size.x, 22.0, "la barra es más ancha")


func test_late_added_buttons_are_raised_too() -> void:
	await _build()
	var late := Button.new()
	late.custom_minimum_size = Vector2(0, 30)
	_scroll.get_child(0).add_child(late)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gte(late.custom_minimum_size.y, 56.0)


func test_pc_mode_changes_nothing() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var screen := Control.new()
	_viewport.add_child(screen)
	var scroll := ScrollContainer.new()
	screen.add_child(scroll)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 30)
	scroll.add_child(button)
	assert_null(MenuTouch.attach(screen))
	await get_tree().process_frame
	assert_eq(button.custom_minimum_size.y, 30.0)
	assert_null(scroll.find_child("TouchScroller", false, false))


func test_drag_over_a_button_scrolls_and_presses_nothing() -> void:
	await _build()
	await _swipe(Vector2(300, 400), Vector2(300, 200))
	assert_gt(_scroll.scroll_vertical, 150, "el contenido siguió al dedo (unos 200 px)")
	assert_eq(_pressed, [], "ningún botón se pulsó al soltar")


func test_buttons_without_focus_are_not_pressed_either() -> void:
	await _build()
	for button: Button in _buttons:
		button.focus_mode = Control.FOCUS_NONE  # el foco no los salva: tiene que bastar con correr el soltar emulado
	await _swipe(Vector2(300, 400), Vector2(300, 200))
	assert_gt(_scroll.scroll_vertical, 150)
	assert_eq(_pressed, [])
	await _tap(_buttons[0].get_global_rect().get_center() if _buttons[0].get_global_rect().position.y >= 100.0 else Vector2(300, 120))


func test_short_tap_still_presses_the_button_once() -> void:
	await _build()
	await _tap(_buttons[0].get_global_rect().get_center())
	assert_eq(_pressed, [0])
	assert_eq(_scroll.scroll_vertical, 0)


func test_a_wobble_under_the_threshold_is_still_a_tap() -> void:
	await _build()
	var center: Vector2 = _buttons[1].get_global_rect().get_center()
	await _swipe(center, center + Vector2(0, 8), 2)
	assert_eq(_pressed, [1])
	assert_eq(_scroll.scroll_vertical, 0)


func test_tap_after_a_scroll_reaches_the_right_button() -> void:
	await _build()
	await _swipe(Vector2(300, 400), Vector2(300, 250))
	assert_eq(_pressed, [])
	var target: Button = _buttons[5]
	var rect: Rect2 = target.get_global_rect()
	if rect.end.y > 500.0 or rect.position.y < 100.0:
		_scroll.scroll_vertical = int(target.position.y)
		await get_tree().process_frame
		rect = target.get_global_rect()
	await _tap(rect.get_center())
	assert_eq(_pressed, [5], "el toque siguiente va al botón que corresponde (no queda un botón capturado)")


func test_scrolled_button_is_not_left_pressed() -> void:
	await _build()
	await _swipe(Vector2(300, 150), Vector2(300, 300))
	for button: Button in _buttons:
		assert_ne(button.get_draw_mode(), BaseButton.DRAW_PRESSED, "%s no queda hundido" % button.text)


func test_inertia_keeps_moving_after_release_and_then_stops() -> void:
	await _build()
	await _swipe(Vector2(300, 450), Vector2(300, 150), 6, 0.016)
	var at_release: int = _scroll.scroll_vertical
	var scroller: TouchScroller = _scroll.find_child("TouchScroller", false, false) as TouchScroller
	assert_true(scroller.has_inertia(), "soltó con velocidad: sigue solo")
	await get_tree().create_timer(0.3).timeout
	assert_gt(_scroll.scroll_vertical, at_release, "siguió avanzando por inercia")
	await get_tree().create_timer(2.5).timeout
	assert_false(scroller.has_inertia(), "se frenó solo")


func test_a_new_touch_stops_the_inertia() -> void:
	await _build()
	await _swipe(Vector2(300, 450), Vector2(300, 150), 6, 0.016)
	var scroller: TouchScroller = _scroll.find_child("TouchScroller", false, false) as TouchScroller
	assert_true(scroller.has_inertia())
	_touch(Vector2(300, 300), true)
	await get_tree().process_frame
	assert_false(scroller.has_inertia())
	var held: int = _scroll.scroll_vertical
	await get_tree().create_timer(0.2).timeout
	assert_eq(_scroll.scroll_vertical, held, "con el dedo apoyado no se mueve")
	_touch(Vector2(300, 300), false)


func test_a_finger_on_a_slider_does_not_scroll() -> void:
	await _build(true)
	var slider: HSlider = _scroll.find_child("Volume", true, false) as HSlider
	var center: Vector2 = slider.get_global_rect().get_center()
	await _swipe(center, center + Vector2(0, 200))
	assert_eq(_scroll.scroll_vertical, 0, "el dedo es del deslizador")


func test_nothing_to_scroll_leaves_taps_alone() -> void:
	await _build()
	for index: int in range(5, 30):
		_buttons[index].queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	await _swipe(Vector2(300, 130), Vector2(300, 150), 2)
	assert_eq(_scroll.scroll_vertical, 0)
	assert_eq(_pressed, [0], "sin nada que desplazar, el gesto es un clic normal sobre el botón")
