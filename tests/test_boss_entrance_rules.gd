# Tests de las reglas de la entrada de los jefes (T366, M66: RF-597 y RF-601): lógica pura, sin escena.
extends GutTest


func _enemy(levels: PackedStringArray = PackedStringArray(["level_01"]), with_entrance: bool = true) -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = &"boss"
	enemy.display_name = "Jefe"
	enemy.description = "Mucha vida."
	if with_entrance:
		enemy.entrance = BossEntranceData.new()
		enemy.entrance.levels = levels
	return enemy


func test_level_in_list_shows() -> void:
	assert_true(BossEntranceRules.should_show(_enemy(), "level_01", true, 100.0, BossEntranceRules.NEVER, []))


func test_level_outside_list_does_not_show() -> void:
	assert_false(BossEntranceRules.should_show(_enemy(), "level_02", true, 100.0, BossEntranceRules.NEVER, []))


func test_empty_list_means_every_level() -> void:
	var enemy: EnemyData = _enemy(PackedStringArray())
	assert_true(BossEntranceRules.should_show(enemy, "level_01", true, 100.0, BossEntranceRules.NEVER, []))
	assert_true(BossEntranceRules.should_show(enemy, "level_15", true, 100.0, BossEntranceRules.NEVER, []))


func test_option_off_does_not_show() -> void:
	assert_false(BossEntranceRules.should_show(_enemy(), "level_01", false, 100.0, BossEntranceRules.NEVER, []))


func test_enemy_without_entrance_does_not_show() -> void:
	assert_false(BossEntranceRules.should_show(_enemy(PackedStringArray(), false), "level_01", true, 100.0,
			BossEntranceRules.NEVER, []))
	assert_false(BossEntranceRules.should_show(null, "level_01", true, 100.0, BossEntranceRules.NEVER, []))


func test_less_than_eight_seconds_since_last_does_not_show() -> void:
	assert_false(BossEntranceRules.should_show(_enemy(), "level_01", true, 107.9, 100.0, []))
	assert_true(BossEntranceRules.should_show(_enemy(), "level_01", true, 108.0, 100.0, []), "justo 8 s sí")


func test_same_type_twice_in_wave_does_not_show() -> void:
	assert_false(BossEntranceRules.should_show(_enemy(), "level_01", true, 100.0, BossEntranceRules.NEVER, [&"boss"]))
	assert_false(BossEntranceRules.should_show(_enemy(), "level_01", true, 100.0, BossEntranceRules.NEVER, ["boss"]))
	assert_true(BossEntranceRules.should_show(_enemy(), "level_01", true, 100.0, BossEntranceRules.NEVER, [&"colossus"]))


func test_line_falls_back_to_description() -> void:
	var enemy: EnemyData = _enemy()
	assert_eq(BossEntranceRules.line_for(enemy), "Mucha vida.")
	enemy.entrance.line = "¡Viene por la salida!"
	assert_eq(BossEntranceRules.line_for(enemy), "¡Viene por la salida!")
	enemy.entrance.line = "   "
	assert_eq(BossEntranceRules.line_for(enemy), "Mucha vida.", "una frase en blanco no cuenta")


func test_validate_names_every_problem_in_spanish() -> void:
	var entrance := BossEntranceData.new()
	entrance.levels = PackedStringArray(["level_01", "level_99"])
	entrance.line = "x".repeat(81)
	entrance.sound = &"no_existe"
	var errors: PackedStringArray = BossEntranceRules.validate("boss", entrance, PackedStringArray(["level_01"]),
			PackedStringArray(["click"]))
	assert_eq(errors.size(), 3)
	assert_true("\n".join(errors).contains("level_99"))
	assert_true("\n".join(errors).contains("81 caracteres"))
	assert_true("\n".join(errors).contains("no_existe"))


func test_validate_accepts_a_good_entrance_and_exactly_80_chars() -> void:
	var entrance := BossEntranceData.new()
	entrance.levels = PackedStringArray(["level_01"])
	entrance.line = "x".repeat(80)
	entrance.sound = &"click"
	assert_eq(BossEntranceRules.validate("boss", entrance, PackedStringArray(["level_01"]), PackedStringArray(["click"])).size(), 0)
	assert_eq(BossEntranceRules.validate("boss", null, PackedStringArray(), PackedStringArray()).size(), 0)
