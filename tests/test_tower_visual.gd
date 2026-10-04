extends GutTest

func test_mount_keeps_base_fixed_and_recoil_follows_aim() -> void:
	var base := Rect2(-32, -32, 64, 64)
	var mounted: Rect2 = TowerVisual.mounted_rect(base, 1.0)
	assert_eq(mounted.position, base.position + TowerVisual.MOUNT_OFFSET)
	assert_eq(mounted.size, base.size)
	for angle: float in [0.0, PI / 2, PI, -PI / 2]:
		var recoil: Vector2 = Vector2.from_angle(angle) * 3.0
		assert_eq(TowerVisual.mounted_rect(base, 1.0, recoil).position, mounted.position - recoil)
	assert_eq(base, Rect2(-32, -32, 64, 64), "la base permanece fija")
	assert_eq(TowerVisual.mounted_rect(base, 2.0).position, base.position + TowerVisual.MOUNT_OFFSET * 2.0, "huella2×2")

func test_eight_directions_and_angle_wrap() -> void:
	for i: int in 8:
		assert_eq(TowerVisual.direction_index(i * TAU / 8.0), i)
		assert_eq(TowerVisual.direction_index(i * TAU / 8.0 + TAU), i)
		assert_eq(TowerVisual.direction_index(i * TAU / 8.0 - TAU), i)
	assert_eq(TowerVisual.direction_index(-0.01), 0, "cruzar cero no salta al lado contrario")
	assert_eq(TowerVisual.direction_index(TAU - 0.01), 0)
	assert_eq(TowerVisual.direction_index(PI / 8.0 - 0.001), 0)
	assert_eq(TowerVisual.direction_index(PI / 8.0 + 0.001), 1, "elige la vista más cercana")

func test_frame_regions_are_inside_atlas() -> void:
	var image := Image.create(512, 256, false, Image.FORMAT_RGBA8)
	var texture := ImageTexture.create_from_image(image)
	for i: int in 8:
		var rect: Rect2 = TowerVisual.frame_rect(texture, i * TAU / 8.0)
		assert_eq(rect.size, Vector2(128, 128))
		assert_eq(rect.position, Vector2(i % 4, i / 4) * 128)
	assert_eq(TowerVisual.frame_rect(null, 0), Rect2())
	assert_null(TowerVisual.frame_texture(null, 0))

func test_extracted_frame_contains_only_selected_direction() -> void:
	var image := Image.create(512, 256, false, Image.FORMAT_RGBA8)
	for i: int in 8:
		image.fill_rect(Rect2i(Vector2i(i % 4, i / 4) * 128, Vector2i(128, 128)), Color.from_hsv(float(i) / 8, 1, 1))
	var texture := ImageTexture.create_from_image(image)
	var up: Image = TowerVisual.frame_texture(texture, -PI / 2).get_image()
	assert_eq(up.get_size(), Vector2i(128, 128))
	assert_eq(up.get_pixel(64, 64), image.get_pixel(320, 192), "HUD usa arriba, no una vista lateral girada")
