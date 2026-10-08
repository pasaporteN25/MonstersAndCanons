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
