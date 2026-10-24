extends GutTest


func test_frame_is_centered_without_changing_its_aspect() -> void:
	var frame: Rect2 = PresentationGeometry.frame_rect(Vector2(2520.0, 1080.0))
	assert_eq(frame, Rect2(300.0, 0.0, 1920.0, 1080.0))

	frame = PresentationGeometry.frame_rect(Vector2(1600.0, 1000.0))
	assert_eq(frame, Rect2(0.0, 50.0, 1600.0, 900.0))

	frame = PresentationGeometry.frame_rect(Vector2(2100.0, 900.0))
	assert_eq(frame, Rect2(250.0, 0.0, 1600.0, 900.0))

	frame = PresentationGeometry.frame_rect(Vector2(1200.0, 900.0))
	assert_eq(frame, Rect2(0.0, 112.5, 1200.0, 675.0))

	frame = PresentationGeometry.frame_rect(Vector2(2000.0, 900.0))
	assert_eq(frame, Rect2(200.0, 0.0, 1600.0, 900.0))


func test_window_coordinates_map_once_and_reject_the_bars() -> void:
	var surface: Vector2 = Vector2(2520.0, 1080.0)
	assert_eq(PresentationGeometry.window_to_logical(Vector2(300.0, 0.0), surface), Vector2.ZERO)
	assert_eq(PresentationGeometry.window_to_logical(Vector2(1260.0, 540.0), surface), Vector2(640.0, 360.0))
	assert_eq(PresentationGeometry.window_to_logical(Vector2(299.0, 540.0), surface), Vector2(-1.0, -1.0))
	assert_eq(PresentationGeometry.logical_to_window(Vector2(640.0, 360.0), surface), Vector2(1260.0, 540.0))


func test_render_target_uses_physical_frame_size() -> void:
	assert_eq(PresentationGeometry.render_size(Vector2(1920.0, 1080.0)), Vector2i(1920, 1080))
	assert_eq(PresentationGeometry.render_size(Vector2(960.0, 540.0)), Vector2i(960, 540))
	assert_eq(PresentationGeometry.frame_scale(Vector2(1920.0, 1080.0)), 1.5)
	assert_eq(PresentationGeometry.frame_scale(Vector2(960.0, 540.0)), 0.75)
