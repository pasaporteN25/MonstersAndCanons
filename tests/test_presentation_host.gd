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
