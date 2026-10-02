extends GutTest

const SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")

func tower_(id: String) -> Tower:
	var tower: Tower = SCENE.instantiate()
	tower.setup(load("res://data/towers/" + id + ".tres"))
	add_child_autofree(tower)
	tower.set_physics_process(false)
	return tower

func test_every_upgrade_uses_its_atlas_and_glow_is_hidden_at_level_one() -> void:
	for id: String in ["cannon", "basic", "multi", "sniper", "burst", "fire", "mortar", "frost", "tesla"]:
		var tower: Tower = tower_(id)
		assert_false(tower._upgrade_glow.visible, id + ": nivel1 sin reflejo extra")
		tower.apply_upgrade()
		assert_true(tower._upgrade_glow.visible, id + ": nivel2")
		assert_same(tower._upgrade_frame.atlas, tower.stats().turret_atlas)
		var level2: float = tower._upgrade_material.get_shader_parameter("strength")
		tower.apply_upgrade()
		assert_gt(float(tower._upgrade_material.get_shader_parameter("strength")), level2, id + ": nivel3 más intenso")
		assert_same(tower._upgrade_frame.atlas, tower.stats().turret_atlas)

func test_glow_tracks_pose_recoil_and_footprint_then_turns_off_when_stunned() -> void:
	var tower: Tower = tower_("mortar")
	tower.apply_upgrade()
	tower.aim_angle = PI / 2
	tower._recoil = 0.5
	tower._sync_upgrade_glow()
	assert_eq(tower._upgrade_frame.region, TowerVisual.frame_rect(tower.current_turret_atlas(), PI / 2))
	assert_almost_eq(tower._upgrade_glow.position, TowerVisual.MOUNT_OFFSET * 2 - Vector2(0, Tower.RECOIL_PX), Vector2.ONE * 0.001)
	assert_eq(tower._upgrade_glow.scale, Vector2.ONE)
	var phase: float = tower._upgrade_time
	await wait_physics_frames(2)
	assert_eq(tower._upgrade_time, phase, "sin física no avanza el pulso")
	tower.stun(1.0)
	assert_false(tower._upgrade_glow.visible, "aturdida queda apagada")
	tower._physics_process(1.1)
	assert_true(tower._upgrade_glow.visible, "al recuperarse vuelve el reflejo")

func test_missing_atlas_uses_legacy_fallback_without_glow() -> void:
	var tower: Tower = tower_("basic")
	tower.data = tower.data.duplicate(true)
	tower.data.turret_atlas = null
	for level: TowerLevelData in tower.data.levels:
		level.turret_atlas = null
	tower.apply_upgrade()
	assert_false(tower._upgrade_glow.visible)
