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


func test_content_texture_filter_mirrors_the_project_setting() -> void:
	assert_eq(PresentationGeometry.content_texture_filter(0), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	assert_eq(PresentationGeometry.content_texture_filter(1), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR)
	assert_eq(PresentationGeometry.content_texture_filter(2), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	assert_eq(PresentationGeometry.content_texture_filter(3), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST_WITH_MIPMAPS)


func test_content_texture_filter_falls_back_to_linear_out_of_range() -> void:
	assert_eq(PresentationGeometry.content_texture_filter(-1), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR)
	assert_eq(PresentationGeometry.content_texture_filter(9), Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR)


func test_side_rails_cover_supported_aspects_with_and_without_safe_area() -> void:
	var cases: Array[Vector2] = [Vector2(1920, 1080), Vector2(1600, 1000), Vector2(1440, 1080), Vector2(2340, 1080), Vector2(2400, 1080), Vector2(2520, 1080)]
	var expected_counts: Array[int] = [0, 0, 0, 2, 2, 2]
	for index: int in cases.size():
		var surface: Vector2 = cases[index]
		var rails: Array[Rect2] = PresentationGeometry.side_rail_rects(surface, Rect2(Vector2.ZERO, surface), 96.0)
		assert_eq(rails.size(), expected_counts[index], "relación %s" % surface)
		if not rails.is_empty():
			var frame: Rect2 = PresentationGeometry.frame_rect(surface)
			assert_eq(rails[0].end.x, frame.position.x)
			assert_eq(rails[1].position.x, frame.end.x)
			assert_almost_eq(rails[0].size.x / PresentationGeometry.frame_scale(frame.size), 140.0 if index == 3 else (160.0 if index == 4 else 200.0), 0.01)
		var inset_safe: Rect2 = Rect2(Vector2(12, 0), Vector2(surface.x - 24, surface.y))
		assert_eq(PresentationGeometry.side_rail_rects(surface, inset_safe, 96.0).size(), expected_counts[index],
			"relación %s con área segura" % surface)


func test_side_rails_apply_safe_area_per_side_and_require_both_minimums() -> void:
	var surface: Vector2 = Vector2(2400, 1080)
	var asymmetric_safe: Rect2 = Rect2(Vector2(60, 0), Vector2(2260, 1080))
	var rails: Array[Rect2] = PresentationGeometry.side_rail_rects(surface, asymmetric_safe, 96.0)
	assert_eq(rails.size(), 2)
	assert_eq(rails[0].position.x, 60.0)
	assert_eq(rails[1].end.x, 2320.0)

	var too_narrow: Rect2 = Rect2(Vector2(180, 0), Vector2(2220, 1080))
	assert_true(PresentationGeometry.side_rail_rects(surface, too_narrow, 96.0).is_empty())
