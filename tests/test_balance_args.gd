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
	for name: String in ["sin_recursos", "demoler", "demoledora", "extraer_temprano", "extraer_tarde"]:
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
