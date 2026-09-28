# Test de prueba (T03): solo comprueba que GUT funciona.
extends GutTest


func test_one_plus_one_is_two() -> void:
	assert_eq(1 + 1, 2)
