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
	for id: String in ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief", "ratero", "cargador", "colossus", "colossus_shard"]:
		var data: EnemyData = _visual_data(id)
		assert_eq(data.visual_scale, 1.8 if id == "colossus" else 1.2, id)  # Coloso: escala visual excepcional, sin ampliar colisión.
		assert_true(data.texture.resource_path.contains("/rendered/"), id)
		assert_false(data.flip_when_walking_left, id)

func test_enemy_uses_regions_for_walk_flight_and_static_fallback() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	for id: String in ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief", "ratero", "cargador", "colossus", "colossus_shard"]:
		var data: EnemyData = _visual_data(id)
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data, path, data.max_health)
		add_child_autofree(enemy)
		enemy.set_physics_process(false)
		var region: Rect2 = enemy.visual_frame_region()
		assert_true(region.has_area(), id + ": ciclo integrado")
		if data.walk_atlas != null:
			assert_same(enemy.visual_texture(), data.walk_atlas)
			assert_gt(enemy.visual_draw_scale(), 0.0, "enmarcado calibrado y válido")
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


func test_static_fallback_still_draws_without_a_cycle() -> void:
	var data: EnemyData = (load("res://data/enemies/armored.tres") as EnemyData).duplicate()
	data.walk_atlas = null
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, path, data.max_health)
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	assert_eq(enemy.visual_frame_region(), Rect2())
	assert_same(enemy.visual_texture(), data.texture)
	await wait_process_frames(2)

func test_remaining_cycles_are_complete_unique_and_inside_transparent_frames() -> void:
	for id: String in ["armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief", "ratero", "cargador", "colossus", "colossus_shard"]:
		var data: EnemyData = _visual_data(id)
		assert_not_null(data.walk_atlas, id)
		if data.walk_atlas == null:
			continue
		assert_eq(data.walk_atlas.get_size(), Vector2(1024, 1024), id)
		assert_gt(data.walk_stride_tiles, 0.0, id)
		var unique: Dictionary = {}
		var image: Image = data.walk_atlas.get_image()
		image.decompress()
		image.clear_mipmaps()
		for row: int in 4:
			for step: int in 4:
				var region: Rect2 = EnemyVisual.walk_region(step * Rules.tiles_to_px(data.walk_stride_tiles) / 4 + 0.001, Rules.tiles_to_px(data.walk_stride_tiles), row * PI / 2)
				assert_eq(region.position, Vector2(step, row) * 256)
				var frame: Image = image.get_region(Rect2i(region))
				unique[hash(frame.get_data())] = true
				var body: Rect2i = frame.get_used_rect()
				assert_gt(body.position.x, 0, id + ": margen izquierdo")
				assert_lt(body.end.x, 256, id + ": margen derecho")
				assert_gt(body.position.y, 0, id + ": margen de arriba")
				assert_eq(body.end.y, 191, id + ": apoyo constante")
		assert_eq(unique.size(), 16, id + ": poses propias")

func test_every_ground_cycle_slows_steps_and_keeps_boss_resistance() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	for id: String in ["armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief", "ratero", "cargador", "colossus", "colossus_shard"]:
		var data: EnemyData = _visual_data(id)
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data, path, data.max_health)
		add_child_autofree(enemy)
		enemy.set_physics_process(false)
		enemy.take_hit(1, 0.5, 5.0)
		var delta: float = data.walk_stride_tiles / data.speed_tiles * 0.3
		enemy._physics_process(delta)
		var expected: float = Rules.tiles_to_px(data.walk_stride_tiles) * 0.3 * (1.0 - 0.5 * (1.0 - data.slow_resistance))
		assert_almost_eq(enemy.distance, expected, 0.001, id)
		assert_eq(enemy.visual_frame_region().position.x, 0.0, id + ": no llega al paso siguiente mientras está lento")


# T234 crea los .tres: hasta entonces probamos assets con una copia aislada,
# sin registrar enemigos, tocar balance ni ampliar el catálogo de campaña.
func _visual_data(id: String) -> EnemyData:
	if id not in ["colossus", "colossus_shard"] or ResourceLoader.exists("res://data/enemies/" + id + ".tres"):
		return load("res://data/enemies/" + id + ".tres") as EnemyData
	var data: EnemyData = (preload("res://data/enemies/guardian.tres") as EnemyData).duplicate()
	data.id = StringName(id)
	data.texture = preload("res://assets/sprites/enemies/rendered/colossus.png") if id == "colossus" else preload("res://assets/sprites/enemies/rendered/colossus_shard.png")
	data.walk_atlas = preload("res://assets/sprites/enemies/rendered/colossus_walk.png") if id == "colossus" else preload("res://assets/sprites/enemies/rendered/colossus_shard_walk.png")
	data.walk_stride_tiles = 1.1 if id == "colossus" else 0.55
	data.walk_art_scale = 1.0
	data.visual_scale = 1.8 if id == "colossus" else 1.2
	data.flip_when_walking_left = false
	data.size_tiles = 0.5 if id == "colossus" else 0.3
	data.slow_resistance = 0.5 if id == "colossus" else 0.0
	return data

# T253: la Cuadrilla usa arte provisional (RF-156): sin `texture` ni `walk_atlas` se dibuja la forma geométrica,
# así que no entra en las listas de ciclos de caminata de arriba hasta que T257 los dibuje.
func test_the_band_without_art_falls_back_to_the_shape_until_it_has_an_atlas() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	add_child_autofree(path)
	for id: String in ["ratero", "cargador"]:
		var data: EnemyData = load("res://data/enemies/" + id + ".tres") as EnemyData
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data, path, data.max_health)
		add_child_autofree(enemy)
		enemy.set_physics_process(false)
		if data.walk_atlas != null:
			assert_true(enemy.visual_frame_region().has_area(), id + ": con atlas, ciclo integrado")
		else:
			assert_eq(enemy.visual_frame_region(), Rect2(), id + ": sin atlas, forma de reemplazo")
			assert_same(enemy.visual_texture(), data.texture)
