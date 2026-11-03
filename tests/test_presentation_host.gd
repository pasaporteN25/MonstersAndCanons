extends GutTest

var _host: Control
var _test_viewport: SubViewport


func before_each() -> void:
	_test_viewport = SubViewport.new()
	_test_viewport.size = Vector2i(1280, 720)
	_test_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_test_viewport)
	_host = load("res://scenes/host/presentation_host.tscn").instantiate() as Control
	_test_viewport.add_child(_host)
	await get_tree().process_frame


func after_each() -> void:
	if _test_viewport != null and is_instance_valid(_test_viewport):
		_test_viewport.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame


func test_host_starts_with_the_menu_inside_a_logical_viewport() -> void:
	var screen: Node = _host.get_active_screen()
	var viewport: SubViewport = _host.get_content_viewport()
	assert_not_null(screen)
	assert_eq(screen.scene_file_path, "res://scenes/ui/main_menu.tscn")
	assert_eq(GameFlow.current_screen(), screen)
	assert_eq(viewport.size_2d_override, Vector2i(1280, 720))
	assert_true(viewport.size_2d_override_stretch)
	assert_eq(viewport.process_mode, Node.PROCESS_MODE_PAUSABLE)
	assert_true(GameFlow.transition.swapper.is_valid())


func test_host_replaces_only_the_inner_scene() -> void:
	var next_scene: PackedScene = load("res://scenes/ui/records_screen.tscn") as PackedScene
	_host.install_scene(next_scene)
	assert_eq(_host.get_active_screen().scene_file_path, "res://scenes/ui/records_screen.tscn")
	assert_eq(GameFlow.current_screen(), _host.get_active_screen())
	assert_eq(get_tree().current_scene, null)


func test_container_forwards_one_click_into_the_content_viewport() -> void:
	var viewport: SubViewport = _host.get_content_viewport()
	var frame: SubViewportContainer = _host.get_node("ContentFrame") as SubViewportContainer
	assert_eq(_test_viewport.get_visible_rect().size, Vector2(1280.0, 720.0))
	assert_eq(_host.size, Vector2(1280.0, 720.0))
	assert_eq(frame.size, Vector2(1280.0, 720.0))
	var button: Button = Button.new()
	button.position = Vector2(900.0, 100.0)
	button.size = Vector2(120.0, 60.0)
	viewport.add_child(button)
	var clicks: Array[int] = []
	button.pressed.connect(func() -> void: clicks.append(1))
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = Vector2(960.0, 130.0)
	motion.global_position = motion.position
	_test_viewport.push_input(motion)
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.position = Vector2(960.0, 130.0)
	press.global_position = press.position
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	_test_viewport.push_input(press)
	await wait_process_frames(1)
	var release: InputEventMouseButton = press.duplicate() as InputEventMouseButton
	release.pressed = false
	_test_viewport.push_input(release)
	await wait_process_frames(1)
	assert_eq(clicks.size(), 1, "el clic entra por el contenedor una sola vez")


func test_content_viewport_uses_the_project_texture_filter_and_keeps_logical_size() -> void:
	var viewport: SubViewport = _host.get_content_viewport()
	var setting: int = int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", 1))
	assert_eq(int(viewport.canvas_item_default_texture_filter), PresentationGeometry.content_texture_filter(setting))
	assert_eq(viewport.size_2d_override, Vector2i(1280, 720))
	assert_eq(viewport.oversampling_override, 0.0)


func test_side_rails_are_empty_until_buttons_are_supplied_and_forward_once() -> void:
	_test_viewport.size = Vector2i(2400, 1080)
	_host.size = Vector2(2400, 1080)
	_host.side_rails.set_safe_area_provider(func() -> Rect2: return Rect2(Vector2.ZERO, Vector2(2400, 1080)))
	_host._update_frame()
	await get_tree().process_frame
	var rails: SideRails = _host.side_rails
	assert_true(rails.visible)
	assert_eq(rails.get_node("LeftColumn").get_child_count(), 0)
	var button := Button.new()
	button.text = "Prueba"
	var left: Array[Control] = [button]
	var right: Array[Control] = []
	var actions: Array[Control] = []
	rails.button_pressed.connect(func(pressed: Control) -> void: actions.append(pressed))
	rails.set_buttons(left, right)
	await get_tree().process_frame
	var touch: InputEventScreenTouch = InputEventScreenTouch.new()
	touch.position = Vector2(60, 60)
	touch.index = 0
	touch.pressed = true
	_test_viewport.push_input(touch)
	await wait_process_frames(1)
	var emulated_click: InputEventMouseButton = InputEventMouseButton.new()
	emulated_click.position = touch.position
	emulated_click.global_position = touch.position
	emulated_click.device = InputEvent.DEVICE_ID_EMULATION
	emulated_click.button_index = MOUSE_BUTTON_LEFT
	emulated_click.pressed = true
	_test_viewport.push_input(emulated_click)
	await wait_process_frames(1)
	var release: InputEventScreenTouch = touch.duplicate() as InputEventScreenTouch
	release.pressed = false
	_test_viewport.push_input(release)
	var emulated_release: InputEventMouseButton = emulated_click.duplicate() as InputEventMouseButton
	emulated_release.pressed = false
	_test_viewport.push_input(emulated_release)
	await wait_process_frames(1)
	assert_eq(actions.size(), 1, "el botón del riel actúa una sola vez")


func test_empty_side_rail_does_not_emit_an_action() -> void:
	_test_viewport.size = Vector2i(2400, 1080)
	_host.size = Vector2(2400, 1080)
	_host.side_rails.set_safe_area_provider(func() -> Rect2: return Rect2(Vector2.ZERO, Vector2(2400, 1080)))
	_host._update_frame()
	await get_tree().process_frame
	var actions: Array[Control] = []
	_host.side_rails.button_pressed.connect(func(pressed: Control) -> void: actions.append(pressed))
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.position = Vector2(60, 60)
	click.global_position = click.position
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_test_viewport.push_input(click)
	await wait_process_frames(1)
	assert_true(actions.is_empty())
