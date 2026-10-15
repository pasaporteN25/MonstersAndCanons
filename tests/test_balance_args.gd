# Tests de la lectura de argumentos del bot de balance (T204).
extends GutTest


func test_levels_single() -> void:
	assert_eq(BalanceArgs.parse_levels("6"), [6] as Array[int])


func test_levels_range() -> void:
	assert_eq(BalanceArgs.parse_levels("6-9"), [6, 7, 8, 9] as Array[int])


func test_levels_invalid_is_empty() -> void:
	assert_true(BalanceArgs.parse_levels("a-b").is_empty())
	assert_true(BalanceArgs.parse_levels("9-6").is_empty())
	assert_true(BalanceArgs.parse_levels("").is_empty())


func test_seeds_up_to() -> void:
	assert_eq(BalanceArgs.seeds_up_to(3), [1, 2, 3] as Array[int])
	assert_true(BalanceArgs.seeds_up_to(0).is_empty())


func test_strategies_list() -> void:
	assert_eq(BalanceArgs.parse_strategies("mix,smart"), ["mix", "smart"] as Array[String])
	assert_eq(BalanceArgs.parse_strategies("mix"), ["mix"] as Array[String])


# --- T214: regla de oro (RF-432) ---

func _row(level: int, won: bool, strategy: String = "sin_recursos") -> Dictionary:
	return {"level": level, "strategy": strategy, "won": won}


func _rows(level: int, wins: int, total: int, strategy: String = "sin_recursos") -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for i: int in total:
		rows.append(_row(level, i < wins, strategy))
	return rows


func test_infra_strategy_names() -> void:
	for name: String in ["sin_recursos", "demoler", "demoledora", "pieza", "extraer_temprano", "extraer_tarde"]:
		assert_true(BalanceArgs.is_infra_strategy(name), name)
	assert_false(BalanceArgs.is_infra_strategy("mix"))
	assert_false(BalanceArgs.is_infra_strategy(""))


func test_rule_holds_border() -> void:
	assert_true(BalanceArgs.rule_holds(5, 5))
	assert_true(BalanceArgs.rule_holds(4, 5), "4 de 5 alcanza (M = 4)")
	assert_false(BalanceArgs.rule_holds(3, 5), "3 de 5 no alcanza")
	assert_false(BalanceArgs.rule_holds(0, 5))


func test_rule_needs_all_the_seeds() -> void:
	assert_false(BalanceArgs.rule_holds(4, 4), "4 de 4 no prueba nada: faltan semillas")
	assert_false(BalanceArgs.rule_holds(0, 0))


func test_rule_summary_ignores_other_strategies() -> void:
	var rows: Array[Dictionary] = _rows(3, 5, 5)
	rows.append_array(_rows(3, 0, 5, "mix"))
	var summary: Dictionary = BalanceArgs.rule_summary(rows)
	assert_eq(summary[3], {"wins": 5, "total": 5})


func test_exit_code_zero_when_every_map_holds() -> void:
	var rows: Array[Dictionary] = _rows(1, 5, 5)
	rows.append_array(_rows(2, 4, 5))
	assert_eq(BalanceArgs.rule_exit_code(rows), 0)


func test_exit_code_one_when_one_map_fails() -> void:
	var rows: Array[Dictionary] = _rows(1, 5, 5)
	rows.append_array(_rows(2, 3, 5))
	assert_eq(BalanceArgs.rule_exit_code(rows), 1)


func test_exit_code_one_when_nothing_was_played() -> void:
	assert_eq(BalanceArgs.rule_exit_code([] as Array[Dictionary]), 1)
	assert_eq(BalanceArgs.rule_exit_code(_rows(1, 5, 5, "mix")), 1, "sin partidas de sin_recursos no se afirma nada")


# --- T258: mejoras del bot y perfil de Asedio (RF-495) ---

func _profile_rows(lives_by_level: Dictionary, seeds: int = 5) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for level: int in lives_by_level:
		for seed_n: int in range(1, seeds + 1):
			rows.append({"level": level, "seed": seed_n, "strategy": "sin_recursos",
				"won": lives_by_level[level] > 0, "lives": lives_by_level[level]})
	return rows


func test_upgrade_modes_are_known() -> void:
	assert_true(BalanceArgs.is_upgrade_mode(""))
	assert_true(BalanceArgs.is_upgrade_mode("llenar"))
	assert_true(BalanceArgs.is_upgrade_mode("temprana"))
	assert_false(BalanceArgs.is_upgrade_mode("siempre"))


func test_fill_upgrades_only_when_no_free_cell_is_left() -> void:
	assert_false(BalanceArgs.wants_upgrade("llenar", 9, 2))
	assert_true(BalanceArgs.wants_upgrade("llenar", 9, 0))
	assert_false(BalanceArgs.wants_upgrade("", 9, 0), "sin la opción nunca mejora")


func test_early_upgrades_start_with_three_towers() -> void:
	assert_false(BalanceArgs.wants_upgrade("temprana", 2, 10))
	assert_true(BalanceArgs.wants_upgrade("temprana", 3, 10))


func test_the_tower_to_upgrade_is_the_lowest_level_then_the_cheapest() -> void:
	var candidates: Array[Dictionary] = [
		{"level": 1, "cost": 40}, {"level": 0, "cost": 90}, {"level": 0, "cost": 60}, {"level": 0, "cost": 60}]
	assert_eq(BalanceArgs.pick_upgrade(candidates), 2, "nivel 0, el más barato; si empatan, el primero")
	assert_eq(BalanceArgs.pick_upgrade([] as Array[Dictionary]), -1)


func test_policies_are_read_with_a_default() -> void:
	var parsed: Dictionary = BalanceArgs.parse_policies(FileAccess.get_file_as_string("res://tools/asedio_politicas.json"))
	assert_eq(parsed["error"], "")
	var policies: Dictionary = parsed["policies"]
	assert_eq(BalanceArgs.policy_for(policies, "level_02"), {"estrategia": "smart", "mejoras": "llenar"})
	assert_eq(BalanceArgs.policy_for(policies, "level_04"), {"estrategia": "sin_recursos", "mejoras": "temprana"})
	assert_eq(BalanceArgs.policy_for(policies, "level_09"), {"estrategia": "sin_recursos", "mejoras": "llenar"})


func test_bad_policies_say_why() -> void:
	assert_ne(BalanceArgs.parse_policies("{ no")["error"], "")
	assert_true(BalanceArgs.parse_policies('{"level_01": {"estrategia": "mix"}}')["error"].contains("por_defecto"))
	assert_true(BalanceArgs.parse_policies('{"por_defecto": {"estrategia": "mix", "mejoras": "siempre"}}')["error"].contains("mejoras"))
	assert_true(BalanceArgs.parse_policies('{"por_defecto": 5}')["error"].contains("estrategia"))


func test_profile_passes_with_five_wins_and_three_lives_and_falling_blocks() -> void:
	var lives: Dictionary = {}
	for level: int in range(1, 16):
		lives[level] = 16 if level <= 5 else (11 if level <= 10 else 6)
	var verdict: Dictionary = BalanceArgs.asedio_verdict(_profile_rows(lives))
	assert_eq(verdict["exit_code"], 0)
	assert_false(verdict["blocks_rise"])
	assert_almost_eq(float(verdict["blocks"][0]), 16.0, 0.001)
	assert_almost_eq(float(verdict["blocks"][2]), 6.0, 0.001)


func test_profile_fails_with_a_defeat_or_too_few_lives() -> void:
	var lives: Dictionary = {1: 16, 2: 2}
	assert_eq(BalanceArgs.asedio_verdict(_profile_rows(lives))["exit_code"], 1, "2 vidas no alcanzan")
	var rows: Array[Dictionary] = _profile_rows({1: 16})
	rows[2]["won"] = false
	assert_eq(BalanceArgs.asedio_verdict(rows)["exit_code"], 1, "una derrota")
	assert_eq(BalanceArgs.asedio_verdict(_profile_rows({1: 16}, 4))["exit_code"], 1, "con menos de 5 semillas no se afirma nada")
	assert_eq(BalanceArgs.asedio_verdict([] as Array[Dictionary])["exit_code"], 1)


func test_profile_fails_when_a_block_average_rises() -> void:
	var lives: Dictionary = {}
	for level: int in range(1, 16):
		lives[level] = 8 if level <= 5 else (12 if level <= 10 else 5)
	var verdict: Dictionary = BalanceArgs.asedio_verdict(_profile_rows(lives))
	assert_true(verdict["blocks_rise"])
	assert_eq(verdict["exit_code"], 1)
