extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")

func test_four_directions_wrap_and_choose_nearest_view() -> void:
	for row: int in 4:
		assert_eq(EnemyVisual.direction_row(row * PI / 2), row)
		assert_eq(EnemyVisual.direction_row(row * PI / 2 - TAU), row)
	assert_eq(EnemyVisual.direction_row(-0.001), 0)
	assert_eq(EnemyVisual.direction_row(PI / 4 - 0.001), 0)
	assert_eq(EnemyVisual.direction_row(PI / 4 + 0.001), 1)

func test_steps_follow_distance_and_stop_when_distance_stops() -> void:
	assert_eq(EnemyVisual.walk_frame(0, 48), 0)
	assert_eq(EnemyVisual.walk_frame(11.99, 48), 0)
	assert_eq(EnemyVisual.walk_frame(12, 48), 1)
	assert_eq(EnemyVisual.walk_frame(48, 48), 0, "cierra el ciclo")
	assert_eq(EnemyVisual.walk_frame(24, 48), 2)
	assert_eq(EnemyVisual.walk_frame(12, 48), 1, "a mitad de distancia, ralentizado, avanza la mitad de poses")
	assert_eq(EnemyVisual.walk_frame(24, 0), 0, "sin distancia de ciclo no divide por cero")

func test_scaled_sprite_keeps_feet_and_collision_radius() -> void:
	var original: Rect2 = EnemyShape.sprite_rect(16)
	var enlarged: Rect2 = EnemyShape.sprite_rect(16, 1.2)
	assert_almost_eq(enlarged.size.x, original.size.x * 1.2, 0.001)
	assert_almost_eq(original.position.y + original.size.y * 191.0 / 256.0,
		enlarged.position.y + enlarged.size.y * 191.0 / 256.0, 0.001, "los pies no flotan")
	assert_gt(EnemyShape.sprite_top(16, 1.2), EnemyShape.sprite_top(16), "barra sobre la cabeza ampliada")
	for id: String in ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss"]:
		var data: EnemyData = load("res://data/enemies/" + id + ".tres")
		assert_eq(data.visual_scale, 1.2, id)
		assert_true(data.texture.resource_path.contains("/rendered/"), id)
		assert_false(data.flip_when_walking_left, id)

func test_enemy_uses_regions_for_walk_flight_and_static_fallback() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	for id: String in ["normal", "fast", "tank", "flyer", "armored"]:
		var data: EnemyData = load("res://data/enemies/" + id + ".tres")
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data, path, data.max_health)
		add_child_autofree(enemy)
		enemy.set_physics_process(false)
		var region: Rect2 = enemy.visual_frame_region()
		assert_eq(region.has_area(), id != "armored", id)
		if data.walk_atlas != null:
			assert_same(enemy.visual_texture(), data.walk_atlas)
			assert_gt(enemy.visual_draw_scale(), data.visual_scale, "el enmarcado del ciclo no achica el monstruo")
			enemy.distance = Rules.tiles_to_px(data.walk_stride_tiles) / 4
			assert_eq(enemy.visual_frame_region().position, Vector2(256, 0))
		elif data.flight_atlas != null:
			assert_same(enemy.visual_texture(), data.flight_atlas)
		else:
			assert_same(enemy.visual_texture(), data.texture)
		var frozen: Rect2 = enemy.visual_frame_region()
		await wait_physics_frames(2)
		assert_eq(enemy.visual_frame_region(), frozen, "sin proceso físico no avanza la pose")

func test_slowed_walk_really_uses_less_distance_and_fewer_poses() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	var data: EnemyData = load("res://data/enemies/normal.tres")
	var walkers: Array[Enemy] = []
	for index: int in 2:
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data, path, data.max_health)
		add_child_autofree(enemy)
		enemy.set_physics_process(false)
		if index == 1:
			enemy.take_hit(1, 0.5, 2.0)
		enemy._physics_process(0.2)
		walkers.append(enemy)
	assert_almost_eq(walkers[1].distance, walkers[0].distance * 0.5, 0.001)
	assert_eq(walkers[0].visual_frame_region().position.x, 256.0)
	assert_eq(walkers[1].visual_frame_region().position.x, 0.0)

func test_flight_loops_and_all_frames_fit() -> void:
	for index: int in 4:
		var region: Rect2 = EnemyVisual.flight_region((index + 0.1) * 0.16, 0.16)
		assert_eq(region.position, Vector2(index % 2, index / 2) * 256)
		assert_true(Rect2(0, 0, 512, 512).encloses(region))
	assert_eq(EnemyVisual.flight_region(0.64, 0.16), EnemyVisual.flight_region(0, 0.16))

func test_desktop_size_fits_monitor_and_preserves_aspect_ratio() -> void:
	assert_eq(DesktopWindow.fitted_size(Vector2i(2560, 1440)), Vector2i(1920, 1080))
	for size_: Vector2i in [Vector2i(1920, 1040), Vector2i(1280, 720), Vector2i(800, 600), Vector2i(1, 1)]:
		var fitted: Vector2i = DesktopWindow.fitted_size(size_)
		assert_lte(fitted.x, size_.x)
		assert_lte(fitted.y, size_.y)
		assert_gt(fitted.x, 0)
		assert_gt(fitted.y, 0)
		if fitted.x > 2:
			assert_almost_eq(float(fitted.x) / fitted.y, 16.0 / 9.0, 0.01)
