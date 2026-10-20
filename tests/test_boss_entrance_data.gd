# Tests de los datos de la entrada de los jefes (T366, M66: RF-601): el lector de `data/ui/entrada_jefes.json`,
# el archivo oficial y la `entrance` de los enemigos.
extends GutTest


func test_official_config_has_no_errors() -> void:
	var config: BossEntranceConfig = BossEntranceConfig.load_from()
	assert_eq(config.errors, PackedStringArray(), "el archivo oficial no tiene errores")
	assert_almost_eq(config.seconds("destello_s"), 0.7, 0.001)
	assert_almost_eq(config.seconds("cartel_entra_s") + config.seconds("cartel_quieto_s") + config.seconds("cartel_sale_s"), 1.6, 0.001)
	assert_eq(config.pixels("cartel_ancho_px"), 720)
	assert_eq(config.pixels("cartel_alto_px"), 120)
	assert_almost_eq(config.seconds("intervalo_min_s"), 8.0, 0.001)


func test_official_file_has_every_default_key() -> void:
	var file := FileAccess.open(BossEntranceConfig.PATH, FileAccess.READ)
	var parser := JSON.new()
	assert_eq(parser.parse(file.get_as_text()), OK)
	var raw: Dictionary = parser.data
	for key: String in BossEntranceConfig.DEFAULTS:
		assert_true(raw.has(key), "falta «%s» en el archivo" % key)
	assert_eq(raw.size(), BossEntranceConfig.DEFAULTS.size(), "el archivo no trae campos de más")


func test_missing_file_uses_defaults_and_says_so() -> void:
	var config: BossEntranceConfig = BossEntranceConfig.load_from("res://data/ui/no_existe_entrada.json")
	assert_eq(config.errors.size(), 1)
	assert_true(config.errors[0].contains("no existe"))
	assert_eq(config.pixels("cartel_ancho_px"), 720)


func test_bad_fields_are_named_and_keep_the_default() -> void:
	var config: BossEntranceConfig = BossEntranceConfig.parse({
		"destello_s": -1, "cartel_quieto_s": "mucho", "cartel_ancho_px": 900, "cartel_alto_px": 40,
		"campo_raro": 1, "intervalo_min_s": -2})
	var text: String = "\n".join(config.errors)
	assert_eq(config.errors.size(), 6, text)
	assert_true(text.contains("destello_s"))
	assert_true(text.contains("cartel_quieto_s"))
	assert_true(text.contains("cartel_ancho_px"))
	assert_true(text.contains("cartel_alto_px"))
	assert_true(text.contains("campo_raro"))
	assert_true(text.contains("intervalo_min_s"))
	assert_almost_eq(config.seconds("destello_s"), 0.7, 0.001, "un campo malo no pisa el valor por omisión")
	assert_eq(config.pixels("cartel_ancho_px"), 720)


func test_integers_from_json_become_the_default_type() -> void:
	var config: BossEntranceConfig = BossEntranceConfig.parse({"destello_s": 1, "retrato_px": 90.0})
	assert_eq(config.errors.size(), 0)
	assert_eq(typeof(config.get_value("destello_s")), TYPE_FLOAT)
	assert_eq(typeof(config.get_value("retrato_px")), TYPE_INT)


func test_not_an_object_is_an_error() -> void:
	assert_eq(BossEntranceConfig.parse([1, 2]).errors.size(), 1)


func test_official_enemies_have_valid_entrances() -> void:
	assert_eq(BossEntranceConfig.validate_enemies(), PackedStringArray())


func test_only_the_boss_has_an_entrance_and_only_in_level_1() -> void:
	var with_entrance: Array[String] = []
	for enemy_id: String in LevelFile.enemy_ids():
		var enemy: EnemyData = LevelFile.find_enemy(enemy_id)
		if enemy.entrance != null:
			with_entrance.append(enemy_id)
	assert_eq(with_entrance, ["boss"], "el piloto es solo el Jefe (P-66-7: el Coloso no)")
	var boss: EnemyData = LevelFile.find_enemy("boss")
	assert_eq(boss.entrance.levels, PackedStringArray(["level_01"]))
	assert_eq(boss.entrance.line, "")
	assert_eq(boss.entrance.sound, &"")


func test_boss_stats_did_not_change() -> void:
	var boss: EnemyData = LevelFile.find_enemy("boss")
	assert_eq([boss.max_health, boss.armor, boss.lives_damage, boss.reward], [300, 3, 10, 150])
	assert_almost_eq(boss.speed_tiles, 0.6, 0.0001)


func test_colossus_can_get_an_entrance_without_code() -> void:
	# RF-601: darle una `entrance` al Coloso con `levels = []` alcanza; las reglas lo aceptan en cualquier nivel.
	var colossus: EnemyData = LevelFile.find_enemy("colossus").duplicate()
	colossus.entrance = BossEntranceData.new()
	assert_true(BossEntranceRules.should_show(colossus, "level_15", true, 10.0, BossEntranceRules.NEVER, []))


func test_real_level_and_sound_ids_are_found() -> void:
	assert_true(BossEntranceConfig.level_ids().has("level_01"))
	assert_eq(BossEntranceConfig.level_ids().size(), 15)
	assert_true(BossEntranceConfig.sound_ids().has("click"))
