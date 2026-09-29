# T95 (spec §7.8, criterio de RF-200 a RF-205): los niveles pasados a JSON son IGUALES a los
# viejos (escena + .tres): mismas casillas, mismos recorridos, mismas oleadas y mismos números.
# Este test compara contra los archivos viejos; se retira en T96, cuando se borran.
extends GutTest

var old_campaign: CampaignData = load("res://data/campaign.tres")
var new_campaign: CampaignData = LevelFile.load_campaign()


## Los puntos de una curva sin los que no son esquinas (a la mitad de un tramo recto):
## la forma y el largo del recorrido no cambian por ellos.
func _corners(curve: Curve2D) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i: int in curve.point_count:
		points.append(curve.get_point_position(i))
	var result: Array[Vector2] = [points[0]]
	for i: int in range(1, points.size() - 1):
		var a: Vector2 = (points[i] - points[i - 1]).normalized()
		var b: Vector2 = (points[i + 1] - points[i]).normalized()
		if not a.is_equal_approx(b):
			result.append(points[i])
	result.append(points[points.size() - 1])
	return result


func _maps(i: int) -> Array[Level]:
	var old: Level = old_campaign.levels[i].map_scene.instantiate()
	var new: Level = new_campaign.levels[i].build_map()
	add_child_autofree(old)
	add_child_autofree(new)
	return [old, new]


func test_same_levels_in_the_same_order() -> void:
	assert_eq(new_campaign.levels.size(), old_campaign.levels.size())
	for i: int in old_campaign.levels.size():
		var old: LevelData = old_campaign.levels[i]
		var new: LevelData = new_campaign.levels[i]
		assert_eq(new.id, old.id)
		assert_eq(new.display_name, old.display_name)
		assert_eq(new.starting_gold, old.starting_gold, "%s: oro" % old.id)
		assert_eq(new.starting_lives, old.starting_lives, "%s: vidas" % old.id)
		assert_eq(new.health_scale_percent_per_wave, old.health_scale_percent_per_wave, "%s: aumento" % old.id)


func test_same_cells() -> void:
	for i: int in old_campaign.levels.size():
		var maps: Array[Level] = _maps(i)
		assert_eq(maps[1].ground.get_used_rect(), maps[0].ground.get_used_rect())
		var different: Array[Vector2i] = []
		for cell: Vector2i in maps[0].ground.get_used_cells():
			if maps[0].ground.get_cell_atlas_coords(cell) != maps[1].ground.get_cell_atlas_coords(cell):
				different.append(cell)
		assert_eq(different, [] as Array[Vector2i], "%s: casillas distintas" % old_campaign.levels[i].id)
		assert_eq(maps[1].inner_exit_cells(), maps[0].inner_exit_cells(), "RF-06: puerta")


func test_same_routes() -> void:
	for i: int in old_campaign.levels.size():
		var maps: Array[Level] = _maps(i)
		var id: StringName = old_campaign.levels[i].id
		assert_eq(maps[1].entrance_count(), maps[0].entrance_count(), "%s: entradas" % id)
		for e: int in maps[0].entrance_count():
			var old_ground: Curve2D = maps[0].get_ground_path(e).curve
			var new_ground: Curve2D = maps[1].get_ground_path(e).curve
			assert_eq(_corners(new_ground), _corners(old_ground), "%s, entrada %d: recorrido" % [id, e])
			assert_almost_eq(new_ground.get_baked_length(), old_ground.get_baked_length(), 0.5,
				"%s, entrada %d: largo" % [id, e])
			assert_eq(_corners(maps[1].get_air_path(e).curve), _corners(maps[0].get_air_path(e).curve),
				"%s, entrada %d: vuelo" % [id, e])


func test_same_waves() -> void:
	for i: int in old_campaign.levels.size():
		var old: LevelData = old_campaign.levels[i]
		var new: LevelData = new_campaign.levels[i]
		assert_eq(new.waves.size(), old.waves.size(), "%s: oleadas" % old.id)
		for w: int in old.waves.size():
			var old_groups: Array[SpawnGroup] = old.waves[w].groups
			var new_groups: Array[SpawnGroup] = new.waves[w].groups
			assert_eq(new_groups.size(), old_groups.size())
			for g: int in mini(old_groups.size(), new_groups.size()):
				var where: String = "%s, oleada %d, grupo %d" % [old.id, w + 1, g + 1]
				var a: SpawnGroup = old_groups[g]
				var b: SpawnGroup = new_groups[g]
				assert_eq(b.enemy, a.enemy, where)
				assert_eq(b.count, a.count, where)
				assert_almost_eq(b.interval, a.interval, 0.0001, where)
				assert_almost_eq(b.start_delay, a.start_delay, 0.0001, where)
				assert_eq(b.entrance_index, a.entrance_index, where)
