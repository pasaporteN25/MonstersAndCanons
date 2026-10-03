extends GutTest

const RAMMER: EnemyData = preload("res://data/enemies/rammer.tres")
const BASIC: TowerData = preload("res://data/towers/basic.tres")
const STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")

func _path(points: PackedVector2Array) -> Path2D:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	for point: Vector2 in points:
		path.curve.add_point(point)
	add_child_autofree(path)
	return path

func _tower(position_: Vector2, data: TowerData = BASIC) -> Tower:
	var tower := Tower.new()
	tower.setup(data)
	tower.position = position_
	add_child_autofree(tower)
	tower.set_physics_process(false)
	return tower

func _rammer(path: Path2D) -> Enemy:
	var enemy := Enemy.new()
	enemy.setup(RAMMER,path,100)
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	return enemy

func test_collinear_points_are_one_straight_and_turns_reset_geometry() -> void:
	var path: Path2D = _path(PackedVector2Array([Vector2(0,0),Vector2(64,0),Vector2(128,0),Vector2(256,0),Vector2(256,64),Vector2(256,128)]))
	var segments: Array[Dictionary] = ChargeRules.segments(path.curve)
	assert_eq(segments.size(),2)
	assert_eq(segments[0]["end"],256.0)
	assert_eq(segments[1]["start"],256.0)
	assert_eq(segments[1]["position"],Vector2(256,128))

func test_only_one_tower_near_end_gets_wear_and_no_repeat() -> void:
	var path: Path2D = _path(PackedVector2Array([Vector2.ZERO,Vector2(256,0),Vector2(256,256)]))
	var near: Tower = _tower(Vector2(256,-64))
	var mid: Tower = _tower(Vector2(64,-64))
	var far: Tower = _tower(Vector2(256,-128))
	var other: Tower = _tower(Vector2(320,0))
	var enemy: Enemy = _rammer(path)
	watch_signals(enemy)
	enemy._update_charge(0,255)
	assert_true(enemy.is_charging())
	assert_eq(near.wear_percent + other.wear_percent,0.0)
	enemy._update_charge(255,257)
	assert_eq(near.wear_percent + other.wear_percent,20.0)
	assert_eq(mid.wear_percent,0.0)
	assert_eq(far.wear_percent,0.0)
	assert_false(enemy.is_charging())
	enemy._update_charge(257,300)
	assert_signal_emit_count(enemy,"charged_impact",1)

func test_short_straight_never_impacts_even_when_tower_is_near() -> void:
	var path: Path2D = _path(PackedVector2Array([Vector2.ZERO,Vector2(128,0),Vector2(128,128)]))
	var tower: Tower = _tower(Vector2(128,-64))
	var enemy: Enemy = _rammer(path)
	enemy._update_charge(0,129)
	assert_eq(tower.wear_percent,0.0)

func test_slow_interrupts_charge_preparation_and_speed() -> void:
	var path: Path2D = _path(PackedVector2Array([Vector2.ZERO,Vector2(256,0)]))
	var tower: Tower = _tower(Vector2(256,-64))
	var enemy: Enemy = _rammer(path)
	enemy._update_charge(0,200)
	assert_almost_eq(enemy.current_speed_tiles(),1.98,0.001)
	enemy.take_hit(1,0.4,3.0)
	assert_false(enemy.is_charging())
	enemy._update_charge(200,257)
	assert_eq(tower.wear_percent,0.0)
	assert_almost_eq(enemy.current_speed_tiles(),0.66,0.001)

func test_translated_path_uses_world_endpoint() -> void:
	var path: Path2D = _path(PackedVector2Array([Vector2.ZERO,Vector2(256,0)]))
	path.position = Vector2(400,300)
	var tower: Tower = _tower(Vector2(656,364))
	_rammer(path)._update_charge(0,257)
	assert_eq(tower.wear_percent,20.0)

func test_wear_cap_upgrade_support_and_stun_are_independent() -> void:
	var tower: Tower = _tower(Vector2.ZERO)
	var support: Tower = _tower(Vector2(64,0),STANDARD)
	tower.apply_wear(20.0)
	assert_almost_eq(tower.effective_fire_rate(),BASIC.levels[0].fire_rate * 1.1 * 0.8,0.001)
	tower.apply_upgrade()
	assert_eq(tower.wear_percent,20.0)
	tower.apply_wear(1000.0)
	assert_eq(tower.wear_percent,50.0)
	tower.stun(2.0)
	assert_eq(tower.wear_percent,50.0)
	support.apply_wear(50.0)
	assert_eq(tower.support_bonus(),5)
	support.stun(1.0)
	assert_eq(tower.support_bonus(),0)
	assert_eq(tower.total_invested,BASIC.levels[0].cost + BASIC.levels[1].cost)

func test_no_wear_keeps_existing_cadence_and_invalid_impacts_are_safe() -> void:
	assert_eq(WearRules.ratio(0.0),1.0)
	assert_eq(WearRules.impact(20.0,-10.0,50.0),20.0)
	assert_eq(WearRules.impact(45.0,20.0,50.0),50.0)
	assert_eq(WearRules.ratio(1000.0),0.0)
	var tower: Tower = _tower(Vector2.ZERO)
	assert_eq(tower.effective_fire_rate(),BASIC.levels[0].fire_rate)

func test_first_five_unchanged_and_trial_counts_in_six_seven() -> void:
	for i: int in 7:
		var count: int = 0
		for wave: WaveData in GameFlow.level(i).waves:
			for group: SpawnGroup in wave.groups:
				if group.enemy.id == &"rammer":
					count += group.count
		assert_eq(count,0 if i < 5 else (1 if i == 5 else 3))
