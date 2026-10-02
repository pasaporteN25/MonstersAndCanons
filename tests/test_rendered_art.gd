extends GutTest

const NAMES: Array[String] = ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar"]

func test_all_production_towers_have_complete_transparent_atlases() -> void:
	for name_: String in NAMES:
		var data: TowerData = load("res://data/towers/" + name_ + ".tres")
		assert_not_null(data.turret_atlas, name_)
		assert_eq(data.turret_atlas.get_size(), Vector2(512, 256), name_ + ": ocho cuadros de 128 px")
		for i: int in 8:
			var frame: Image = TowerVisual.frame_texture(data.turret_atlas, i * TAU / 8.0).get_image()
			assert_false(frame.is_invisible(), "%s: vista %d tiene cuerpo" % [name_, i])
			var used: Rect2i = frame.get_used_rect()
			assert_gt(used.position.x, 0, "sin corte a la izquierda")
			assert_gt(used.position.y, 0, "sin corte arriba")
			assert_lt(used.end.x, 128, "sin corte a la derecha")
			assert_lt(used.end.y, 128, "sin corte abajo")

func test_atlas_only_tower_has_an_icon_and_does_not_modify_source() -> void:
	var data: TowerData = load("res://data/towers/cannon.tres").duplicate(true)
	data.turret_texture = null
	var before: PackedByteArray = data.turret_atlas.get_image().get_data()
	var icon: Texture2D = Tower.make_icon(data)
	assert_not_null(icon)
	assert_eq(icon.get_size(), Vector2(128, 128))
	assert_eq(data.turret_atlas.get_image().get_data(), before)

func test_rendered_impacts_appear_and_free_themselves() -> void:
	var layer := EffectsLayer.new()
	add_child_autofree(layer)
	var frost := TowerLevelData.new()
	frost.slow_amount = 0.5
	layer.projectile_impacted(Vector2.ZERO, frost)
	var blast := TowerLevelData.new()
	blast.splash_radius_tiles = 1.0
	layer.projectile_impacted(Vector2(50, 0), blast)
	var impacts: int = 0
	for child: Node in layer.get_children():
		if child is ImpactSpriteEffect:
			impacts += 1
	assert_eq(impacts, 2, "frío y explosión usan impactos renderizados")
	simulate(layer, 40, 1.0 / 60.0)
	await wait_process_frames(2)
	assert_eq(layer.get_child_count(), 0, "ni sprites ni anillos quedan acumulados")
