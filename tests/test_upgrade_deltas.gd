# Tests de lo que suma una mejora de torre (M65, T361, RF-591, RF-592, RF-594). Sin escenas: lógica y datos.
extends GutTest

const TEST_FILE: String = "user://test_mejoras.json"

var _table: Array[Dictionary]


func before_each() -> void:
	_table = UpgradeFxConfig.load_from().stats


func after_each() -> void:
	if FileAccess.file_exists(TEST_FILE):
		DirAccess.remove_absolute(TEST_FILE)


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id) as TowerData


func _texts(id: String, from_index: int) -> Array[String]:
	var data: TowerData = _tower(id)
	var texts: Array[String] = []
	for delta: Dictionary in UpgradeDeltas.compute(data.levels[from_index], data.levels[from_index + 1], _table):
		texts.append(String(delta["texto"]))
	return texts


func _rows(id: String, from_index: int) -> Array[String]:
	var data: TowerData = _tower(id)
	return UpgradeDeltas.rows(UpgradeDeltas.compute(data.levels[from_index], data.levels[from_index + 1], _table))


# --- formato de los números ---

func test_numbers_have_sign_comma_and_no_extra_zeros() -> void:
	assert_eq(UpgradeDeltas.format_number(3.0, "entero"), "+3")
	assert_eq(UpgradeDeltas.format_number(3.0, "decimal"), "+3", "sin ceros de más")
	assert_eq(UpgradeDeltas.format_number(0.5, "decimal"), "+0,5")
	assert_eq(UpgradeDeltas.format_number(0.50000001, "decimal"), "+0,5")
	assert_eq(UpgradeDeltas.format_number(0.0999999, "decimal"), "+0,1", "el ruido de los decimales se limpia")
	assert_eq(UpgradeDeltas.format_number(1.25, "decimal"), "+1,25")
	assert_eq(UpgradeDeltas.format_number(10.000000000000002, "porcentaje"), "+10 %")
	assert_eq(UpgradeDeltas.format_number(-2.0, "entero"), "−2", "una baja lleva el menos tipográfico")


func test_header_for_each_level() -> void:
	assert_eq(UpgradeDeltas.header(2, false), "¡Nivel 2!")
	assert_eq(UpgradeDeltas.header(3, true), "¡Nivel máximo!")


func test_rows_are_two_per_line_separated_by_a_dot() -> void:
	var four: Array[Dictionary] = [{"texto": "a"}, {"texto": "b"}, {"texto": "c"}, {"texto": "d"}]
	assert_eq(UpgradeDeltas.rows(four), ["a · b", "c · d"] as Array[String])
	assert_eq(UpgradeDeltas.rows([{"texto": "a"}, {"texto": "b"}, {"texto": "c"}] as Array[Dictionary]), ["a · b", "c"] as Array[String])
	assert_eq(UpgradeDeltas.rows([] as Array[Dictionary]).size(), 0, "sin cambios no hay renglones")


# --- los ejemplos de la spec, leídos de los .tres reales ---

func test_machine_gun_level_2_matches_the_spec() -> void:
	assert_eq(_rows("basic", 0), ["+3 daño · +0,5 disp/s"] as Array[String])
	assert_false(" ".join(_texts("basic", 0)).contains("alcance"), "el alcance no cambió: no se menciona")


func test_disruptor_level_2_has_no_damage() -> void:
	assert_eq(_rows("disruptor", 0), ["+0,5 alcance · +0,5 s de pulso"] as Array[String])
	assert_false(" ".join(_texts("disruptor", 0)).contains("daño"))


func test_fire_level_2_and_tesla_level_3_match_the_spec() -> void:
	assert_eq(_rows("fire", 0), ["+2 daño · +4 quemadura/s"] as Array[String])
	assert_eq(_rows("tesla", 1), ["+8 daño · +0,1 disp/s", "+1 saltos · +0,5 alcance"] as Array[String])


func test_frost_shows_the_slow_in_percent() -> void:
	assert_true(_texts("frost", 0).has("+10 % frenado"))


# --- recorrido de las 11 torres ---

func test_every_real_upgrade_has_at_least_one_line_and_only_known_fields() -> void:
	var ids: PackedStringArray = LevelFile.tower_ids()
	assert_eq(ids.size(), 11, "si se suma una torre, este test la recorre sola")
	var known: Dictionary = {}
	for row: Dictionary in _table:
		known[row["campo"]] = true
	for id: String in ids:
		var data: TowerData = _tower(id)
		for from_index: int in range(data.levels.size() - 1):
			var deltas: Array[Dictionary] = UpgradeDeltas.compute(data.levels[from_index], data.levels[from_index + 1], _table)
			assert_gt(deltas.size(), 0, "%s %d→%d: la mejora tiene que mostrar algo" % [id, from_index + 1, from_index + 2])
			assert_lte(deltas.size(), 4, "%s: como mucho 4" % id)
			for delta: Dictionary in deltas:
				assert_true(known.has(delta["campo"]))
				assert_ne(float(delta["delta"]), 0.0, "%s: nunca un +0" % id)
				assert_true(String(delta["texto"]).begins_with("+"), "%s %s: las mejoras suben" % [id, delta["texto"]])


func test_no_tower_stat_that_changes_is_left_out_of_the_table() -> void:
	# Riesgo 1 del plan: un campo de TowerLevelData que cambia entre niveles y no está en la tabla ni en la lista de ignorados.
	var ignored: Array[String] = ["cost", "base_texture", "turret_atlas", "bonus_vs_slowed_percent",
			"bonus_vs_burning_percent", "chain_range_tiles"]
	var known: Dictionary = {}
	for row: Dictionary in _table:
		known[row["campo"]] = true
	assert_gt(known.size(), 10, "la tabla tiene que cubrir las estadísticas de combate")
	for id: String in LevelFile.tower_ids():
		var data: TowerData = _tower(id)
		for from_index: int in range(data.levels.size() - 1):
			for property: Dictionary in TowerLevelData.new().get_property_list():
				if not (int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE):
					continue
				var field: String = String(property["name"])
				if field in ignored or known.has(field):
					continue
				var a: Variant = data.levels[from_index].get(field)
				var b: Variant = data.levels[from_index + 1].get(field)
				if typeof(a) == TYPE_OBJECT or typeof(a) == TYPE_NIL:
					continue
				assert_eq(a, b, "%s: «%s» cambia entre niveles y no está en data/ui/mejoras.json" % [id, field])


func test_the_text_follows_the_data_without_touching_code() -> void:
	var data: TowerData = _tower("basic")
	var edited: TowerLevelData = data.levels[1].duplicate() as TowerLevelData
	edited.damage += 10
	var deltas: Array[Dictionary] = UpgradeDeltas.compute(data.levels[0], edited, _table)
	assert_eq(String(deltas[0]["texto"]), "+13 daño", "cambiar el daño del .tres cambia el texto")


func test_nothing_changed_gives_an_empty_list_and_a_null_level_too() -> void:
	var level: TowerLevelData = _tower("basic").levels[0]
	assert_eq(UpgradeDeltas.compute(level, level, _table).size(), 0)
	assert_eq(UpgradeDeltas.compute(null, level, _table).size(), 0)


func test_a_difference_below_the_tolerance_does_not_count() -> void:
	var a := TowerLevelData.new()
	var b := TowerLevelData.new()
	b.range_tiles = a.range_tiles + 0.004
	assert_eq(UpgradeDeltas.compute(a, b, _table).size(), 0)


func test_the_maximum_of_stats_is_respected() -> void:
	var a := TowerLevelData.new()
	var b := TowerLevelData.new()
	b.damage = 1
	b.fire_rate = 1.0
	b.range_tiles = 1.0
	b.splash_radius_tiles = 1.0
	b.burst_count = 1
	assert_eq(UpgradeDeltas.compute(a, b, _table, 4).size(), 4)
	assert_eq(UpgradeDeltas.compute(a, b, _table, 2).size(), 2)


# --- dónde se pone el bloque (RF-592) ---

const VIEW := Rect2(0, 64, 1280, 560)


func test_a_free_block_stays_where_it_was_asked() -> void:
	var anchor := Vector2(600, 300)
	assert_eq(UpgradeDeltas.place_block(anchor, Vector2(200, 80), [] as Array[Rect2], VIEW), anchor)


func test_a_block_near_the_right_edge_is_pulled_inside() -> void:
	var placed: Vector2 = UpgradeDeltas.place_block(Vector2(1270, 300), Vector2(200, 80), [] as Array[Rect2], VIEW)
	assert_lte(placed.x + 100.0, VIEW.end.x)
	var left: Vector2 = UpgradeDeltas.place_block(Vector2(5, 300), Vector2(200, 80), [] as Array[Rect2], VIEW)
	assert_gte(left.x - 100.0, VIEW.position.x)


func test_a_block_near_the_top_is_pulled_down_inside() -> void:
	var placed: Vector2 = UpgradeDeltas.place_block(Vector2(600, 70), Vector2(200, 80), [] as Array[Rect2], VIEW)
	assert_gte(placed.y - 80.0, VIEW.position.y)


func test_a_block_over_a_forbidden_zone_moves_up_until_free() -> void:
	var bar := Rect2(0, 624, 1280, 96)
	var placed: Vector2 = UpgradeDeltas.place_block(Vector2(600, 660), Vector2(200, 80), [bar] as Array[Rect2], VIEW)
	var block := Rect2(placed.x - 100.0, placed.y - 80.0, 200, 80)
	assert_false(block.intersects(bar))
	assert_lte(placed.y, bar.position.y)


func test_a_block_dodges_several_zones() -> void:
	var zones: Array[Rect2] = [Rect2(0, 624, 1280, 96), Rect2(500, 520, 200, 80)]
	var placed: Vector2 = UpgradeDeltas.place_block(Vector2(600, 660), Vector2(200, 80), zones, VIEW)
	var block := Rect2(placed.x - 100.0, placed.y - 80.0, 200, 80)
	for zone: Rect2 in zones:
		assert_false(block.intersects(zone))


# --- el archivo y su validador (RF-594) ---

func _write(text: String) -> void:
	var file := FileAccess.open(TEST_FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_the_official_file_has_no_errors() -> void:
	var config: UpgradeFxConfig = UpgradeFxConfig.load_from()
	assert_eq(config.errors, [] as Array[String])
	assert_eq(config.stats.size(), 14)
	assert_almost_eq(float(config.variant_for(2)["duracion_s"]), 0.5, 0.0001)
	assert_almost_eq(float(config.variant_for(3)["duracion_s"]), 0.7, 0.0001)
	assert_eq(int(config.get_number("tope_efectos")), 8)


func test_the_defaults_match_the_official_file() -> void:
	var raw := JSON.new()
	raw.parse(FileAccess.get_file_as_string(UpgradeFxConfig.PATH))
	var official: Dictionary = raw.data
	var config := UpgradeFxConfig.new()
	for key: String in UpgradeFxConfig.DEFAULT_NUMBERS:
		assert_almost_eq(float(official[key]), float(config.numbers[key]), 0.0001, key)
	var stats: Array = official["estadisticas"]
	assert_eq(stats.size(), config.stats.size())
	for index: int in range(stats.size()):
		assert_eq(String(stats[index]["campo"]), String(config.stats[index]["campo"]))
		assert_eq(String(stats[index]["etiqueta"]), String(config.stats[index]["etiqueta"]))
		assert_eq(String(stats[index]["formato"]), String(config.stats[index]["formato"]))


func test_a_missing_field_is_named_and_the_defaults_are_used() -> void:
	_write('{"estadisticas":[{"campo":"daño_x","etiqueta":"daño","formato":"entero"}]}')
	var config: UpgradeFxConfig = UpgradeFxConfig.load_from(TEST_FILE)
	assert_false(config.is_valid())
	assert_true("\n".join(config.errors).contains("daño_x"), "nombra el campo que no existe")
	assert_eq(config.stats.size(), 14, "la tabla de omisión sigue sirviendo")
	assert_eq(UpgradeDeltas.compute(_tower("basic").levels[0], _tower("basic").levels[1], config.stats).size(), 2)


func test_an_unknown_format_is_named() -> void:
	_write('{"estadisticas":[{"campo":"damage","etiqueta":"daño","formato":"hexa"}]}')
	var config: UpgradeFxConfig = UpgradeFxConfig.load_from(TEST_FILE)
	assert_true("\n".join(config.errors).contains("hexa"))


func test_a_duration_of_zero_or_less_is_an_error_and_keeps_the_default() -> void:
	_write('{"variantes":{"refuerzo":{"duracion_s":0,"cuadros":8,"escala":1},"maestria":{"duracion_s":-1,"cuadros":8,"escala":1.5}}}')
	var config: UpgradeFxConfig = UpgradeFxConfig.load_from(TEST_FILE)
	var text: String = "\n".join(config.errors)
	assert_true(text.contains("refuerzo") and text.contains("duracion_s"))
	assert_true(text.contains("maestria"))
	assert_almost_eq(float(config.variant_for(2)["duracion_s"]), 0.5, 0.0001)
	assert_almost_eq(float(config.variant_for(3)["duracion_s"]), 0.7, 0.0001)


func test_a_missing_or_broken_file_uses_the_defaults() -> void:
	var missing: UpgradeFxConfig = UpgradeFxConfig.load_from("user://no_existe_mejoras.json")
	assert_false(missing.is_valid())
	assert_eq(missing.stats.size(), 14)
	_write("esto no es json")
	var broken: UpgradeFxConfig = UpgradeFxConfig.load_from(TEST_FILE)
	assert_false(broken.is_valid())
	assert_eq(broken.stats.size(), 14)
