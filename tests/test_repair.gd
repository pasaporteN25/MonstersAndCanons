extends GutTest

const BASIC: TowerData = preload("res://data/towers/basic.tres")
const STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")

func _tower(position_: Vector2, data: TowerData = BASIC) -> Tower:
	var tower := Tower.new()
	tower.setup(data)
	tower.position = position_
	add_child_autofree(tower)
	tower.set_physics_process(false)
	return tower

func test_repair_clamps_and_rejects_negative_rate_time() -> void:
	assert_eq(WearRules.repair(3.0,2.0,2.0),0.0)
	assert_eq(WearRules.repair(3.0,-2.0,2.0),3.0)
	assert_eq(WearRules.repair(3.0,2.0,-2.0),3.0)

func test_rate_nonstacking_bounds_upgrade_and_sale() -> void:
	var cannon: Tower = _tower(Vector2.ZERO)
	var weak: Tower = _tower(Vector2(64,0),STANDARD)
	var strong: Tower = _tower(Vector2(64,0),STANDARD)
	strong.apply_upgrade()
	strong.apply_upgrade()
	cannon.apply_wear(20.0)
	cannon._physics_process(1.0)
	assert_eq(cannon.wear_percent,16.0)
	assert_eq(cannon.repair_rate_received,4.0)
	strong.stun(5.0)
	cannon._physics_process(1.0)
	assert_eq(cannon.wear_percent,14.0)
	weak.queue_free()
	cannon._physics_process(1.0)
	assert_eq(cannon.wear_percent,14.0)
	strong.position = Vector2(500,0)
	assert_eq(cannon.repair_rate(),0.0)

func test_source_wear_reduces_repair_and_can_be_repaired_only_by_another_source() -> void:
	var source: Tower = _tower(Vector2.ZERO,STANDARD)
	source.apply_wear(20.0)
	source._physics_process(1.0)
	assert_eq(source.wear_percent,20.0)
	var cannon: Tower = _tower(Vector2(64,0))
	cannon.apply_wear(20.0)
	assert_almost_eq(cannon.repair_rate(),1.6,0.001)
	var other: Tower = _tower(Vector2(64,0),STANDARD)
	source._physics_process(1.0)
	assert_eq(source.wear_percent,18.0)
	assert_eq(other.wear_percent,0.0)

func test_repair_does_not_remove_stun_upgrade_or_cost() -> void:
	var cannon: Tower = _tower(Vector2.ZERO)
	_tower(Vector2(64,0),STANDARD)
	cannon.apply_wear(20.0)
	cannon.stun(5.0)
	cannon._physics_process(1.0)
	assert_eq(cannon.wear_percent,18.0)
	assert_eq(cannon.stun_left(),4.0)
	cannon.apply_upgrade()
	assert_eq(cannon.wear_percent,18.0)
	assert_eq(cannon.total_invested,BASIC.levels[0].cost + BASIC.levels[1].cost)

func test_complete_repair_restores_cadence_and_stops_indicator() -> void:
	var cannon: Tower = _tower(Vector2.ZERO)
	_tower(Vector2(64,0),STANDARD)
	cannon.apply_wear(2.0)
	cannon._physics_process(1.0)
	assert_eq(cannon.wear_percent,0.0)
	assert_eq(cannon.repair_rate_received,0.0)
	assert_almost_eq(cannon.effective_fire_rate(),BASIC.levels[0].fire_rate * 1.1,0.001)

func test_wiki_and_panel_explain_repair_and_show_effective_state() -> void:
	assert_string_contains(Wiki.tower_entry(STANDARD).plain_text(),"Repara 2")
	var cannon: Tower = _tower(Vector2.ZERO)
	_tower(Vector2(64,0),STANDARD)
	cannon.apply_wear(20.0)
	cannon.stun(5.0)
	cannon._physics_process(1.0)
	var panel: TowerPanel = preload("res://scenes/ui/tower_panel.tscn").instantiate()
	add_child_autofree(panel)
	panel.show_tower(cannon,35,200)
	assert_string_contains((panel.get_node("%Status") as Label).text,"Desgaste 18")
	assert_string_contains((panel.get_node("%Status") as Label).text,"Aturdida")
	assert_string_contains((panel.get_node("%Stats") as Label).text,"Reparación recibida: 2 puntos/s")

func test_actual_pause_freezes_and_speed_scales_repair() -> void:
	var cannon: Tower = _tower(Vector2.ZERO)
	_tower(Vector2(64,0),STANDARD)
	cannon.apply_wear(20.0)
	cannon.set_physics_process(true)
	get_tree().paused = true
	await get_tree().create_timer(0.1,true,false,true).timeout
	assert_eq(cannon.wear_percent,20.0)
	get_tree().paused = false
	Engine.time_scale = 2.0
	await get_tree().create_timer(0.2,true,false,true).timeout
	Engine.time_scale = 1.0
	cannon.set_physics_process(false)
	assert_lt(cannon.wear_percent,19.4)

func test_real_paths_six_and_seven_charge_impact_and_mechanic_recovery() -> void:
	var old_dev: bool = DevMode.enabled
	DevMode.enabled = true
	for index: int in [5,6]:
		var game: Game = preload("res://scenes/game/game.tscn").instantiate()
		game.level_data = GameFlow.level(index)
		add_child_autofree(game)
		var path: Path2D = game.level.get_ground_path(0)
		var segments: Array[Dictionary] = ChargeRules.segments(path.curve)
		var tested: bool = false
		for segment: Dictionary in segments:
			if float(segment["end"]) - float(segment["start"]) < Rules.tiles_to_px(3):
				continue
			var endpoint: Vector2 = path.to_global(segment["position"])
			var chosen: Vector2i = Vector2i(-1,-1)
			for y: int in game.level.map_size().y:
				for x: int in game.level.map_size().x:
					var cell := Vector2i(x,y)
					if game.level.is_buildable(cell) and endpoint.distance_to(game.level.cell_center(cell)) <= Rules.tiles_to_px(1.25):
						chosen = cell
			if chosen.x < 0:
				continue
			var cannon: Tower = _tower(game.level.cell_center(chosen))
			var source: Tower = _tower(cannon.position + Vector2(64,0),STANDARD)
			var enemy := Enemy.new()
			enemy.setup(preload("res://data/enemies/rammer.tres"),path,100)
			add_child_autofree(enemy)
			enemy.set_physics_process(false)
			enemy.distance = float(segment["end"]) - 1.0
			enemy._charge_progress = Rules.tiles_to_px(3)
			enemy._physics_process(0.03)
			assert_eq(cannon.wear_percent,20.0,"impacto en nivel%d" % (index+1))
			cannon._update_repair(5.0)
			assert_eq(cannon.wear_percent,10.0,"reparación en nivel%d" % (index+1))
			cannon._update_repair(5.0)
			assert_eq(cannon.wear_percent,0.0)
			tested = true
			# No dejar fuentes/objetivos de un mapa en el siguiente escenario.
			remove_child(cannon)
			remove_child(source)
			remove_child(enemy)
			break
		assert_true(tested,"existe un extremo construible en nivel%d" % (index+1))
	DevMode.enabled = old_dev

func test_small_steps_finish_at_exact_zero_and_clear_repair_state() -> void:
	var cannon: Tower = _tower(Vector2.ZERO)
	var source: Tower = _tower(Vector2(64,0),STANDARD)
	for level: int in [0,2]:
		source.level_index = level
		cannon.wear_percent = 20.0
		for step: int in 101:
			cannon._update_repair(0.1)
		assert_eq(cannon.wear_percent,0.0,"no conserva residuo de coma flotante")
		assert_eq(cannon.repair_rate_received,0.0,"no queda herramienta de reparación encendida")
	cannon.wear_percent = 0.000001
	cannon._update_repair(0.1)
	assert_eq(cannon.wear_percent,0.0,"último fragmento termina aunque sean valores aproximadamente iguales")
