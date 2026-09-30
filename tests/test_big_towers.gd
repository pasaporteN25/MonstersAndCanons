# Tests de las torres de más de una casilla (M19, T138): tamaño como dato, ocupación, seleccionar y vender
# (spec RF-290, RF-291, RF-293, RF-294, D-044).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")

var game: Game
var big: TowerData
var basic: TowerData


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	basic = game.tower_types[0]
	# Una torre de prueba de 2×2, con los números de la Ametralladora (no depende del Mortero).
	big = basic.duplicate()
	big.footprint = 2
	game.session.earn(1000)


## Casilla de arriba a la izquierda de un bloque de 2×2 donde todo es construible y está libre.
func _free_block() -> Vector2i:
	for y: int in range(0, 8):
		for x: int in range(0, 19):
			var origin := Vector2i(x, y)
			if game.build_controller.cells_free(big, origin):
				return origin
	return Vector2i(-1, -1)


## Un bloque de 2×2 con tres casillas libres y una que no (camino o roca), en cualquier parte del mapa.
func _block_with_one_blocked() -> Vector2i:
	for y: int in range(0, 8):
		for x: int in range(0, 19):
			var origin := Vector2i(x, y)
			var free: int = 0
			for cell: Vector2i in BuildController.footprint_cells(origin, 2):
				if game.level.is_buildable(cell):
					free += 1
			if free == 3:
				return origin
	return Vector2i(-1, -1)


# --- Datos (RF-290) ---

func test_footprint_is_one_by_default_for_the_current_towers() -> void:
	for tower: TowerData in game.tower_types:
		if tower.id != &"mortar":
			assert_eq(tower.footprint, 1, "%s ocupa una casilla" % tower.id)


func test_footprint_cells_are_a_square() -> void:
	assert_eq(BuildController.footprint_cells(Vector2i(3, 4), 1), [Vector2i(3, 4)] as Array[Vector2i])
	var cells: Array[Vector2i] = BuildController.footprint_cells(Vector2i(3, 4), 2)
	assert_eq(cells.size(), 4)
	for expected: Vector2i in [Vector2i(3, 4), Vector2i(4, 4), Vector2i(3, 5), Vector2i(4, 5)]:
		assert_true(cells.has(expected), "incluye %s" % expected)


# --- Construir (RF-291) ---

func test_builds_on_four_free_cells_and_occupies_them_all() -> void:
	var origin: Vector2i = _free_block()
	assert_ne(origin, Vector2i(-1, -1), "el mapa tiene un 2×2 libre")
	var gold: int = game.session.gold
	assert_true(game.build_controller.try_build(big, origin))
	assert_eq(game.session.gold, gold - big.levels[0].cost)
	var tower: Tower = game.build_controller.tower_at(origin)
	assert_not_null(tower)
	for cell: Vector2i in BuildController.footprint_cells(origin, 2):
		assert_true(game.build_controller.is_occupied(cell), "%s ocupada" % cell)
		assert_eq(game.build_controller.tower_at(cell), tower, "%s es de la misma torre" % cell)
	assert_eq(tower.cells().size(), 4)


func test_the_tower_sits_in_the_center_of_the_square() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(big, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	var expected: Vector2 = (game.level.cell_center(origin) + game.level.cell_center(origin + Vector2i(1, 1))) / 2.0
	assert_eq(tower.global_position, expected, "en la esquina común de las cuatro casillas")


func test_three_free_cells_are_not_enough() -> void:
	var origin: Vector2i = _block_with_one_blocked()
	assert_ne(origin, Vector2i(-1, -1), "el mapa tiene un 2×2 con una casilla tapada")
	var gold: int = game.session.gold
	assert_false(game.build_controller.try_build(big, origin), "RF-291")
	assert_eq(game.session.gold, gold, "no se cobra nada")
	for cell: Vector2i in BuildController.footprint_cells(origin, 2):
		assert_false(game.build_controller.is_occupied(cell), "no ocupa nada")


func test_cannot_overlap_another_tower() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(big, origin)
	var gold: int = game.session.gold
	assert_false(game.build_controller.try_build(big, origin), "encima de sí misma")
	assert_false(game.build_controller.try_build(big, origin + Vector2i(1, 1)), "pisando una sola casilla")
	assert_false(game.build_controller.try_build(basic, origin + Vector2i(1, 1)), "una chica en una de sus casillas")
	assert_eq(game.session.gold, gold)


func test_a_small_tower_blocks_a_big_one() -> void:
	var origin: Vector2i = _free_block()
	assert_true(game.build_controller.try_build(basic, origin + Vector2i(1, 1)))
	assert_false(game.build_controller.try_build(big, origin), "una de las cuatro casillas ya está ocupada")


func test_cannot_build_off_the_map_edge() -> void:
	var size: Vector2i = game.level.map_size()
	assert_false(game.build_controller.try_build(big, Vector2i(size.x - 1, 0)), "se sale por la derecha")
	assert_false(game.build_controller.try_build(big, Vector2i(0, size.y - 1)), "se sale por abajo")
	assert_false(game.build_controller.try_build(big, Vector2i(-1, 0)), "se sale por la izquierda")


func test_cannot_build_without_gold() -> void:
	var origin: Vector2i = _free_block()
	game.session.spend(game.session.gold - big.levels[0].cost + 1)
	assert_false(game.build_controller.try_build(big, origin), "falta 1 de oro")


# --- Seleccionar, mejorar y vender (RF-293, RF-294) ---

func test_a_click_on_any_cell_selects_the_tower() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(big, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	for cell: Vector2i in BuildController.footprint_cells(origin, 2):
		game.build_controller.deselect_placed()
		game.build_controller.select_placed(game.build_controller.tower_at(cell))
		assert_eq(game.build_controller.selected_placed(), tower, "desde %s" % cell)


func test_selling_frees_the_four_cells_and_gives_70_percent() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(big, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	var before: int = game.session.gold
	var refund: int = game.build_controller.sell(tower)
	assert_eq(refund, int(big.levels[0].cost * 0.7), "RF-72")
	assert_eq(game.session.gold, before + refund)
	for cell: Vector2i in BuildController.footprint_cells(origin, 2):
		assert_false(game.build_controller.is_occupied(cell), "%s libre otra vez" % cell)
	assert_true(game.build_controller.try_build(big, origin), "se puede volver a construir ahí")


func test_upgrade_works_like_any_other_tower() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(big, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(tower.level_number(), 2)
	assert_eq(tower.cells().size(), 4, "sigue ocupando el mismo lugar")


func test_small_towers_keep_working_as_before() -> void:
	assert_true(game.build_controller.try_build(basic, Vector2i(0, 0)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(0, 0))
	assert_eq(tower.cells(), [Vector2i(0, 0)] as Array[Vector2i])
	assert_eq(tower.global_position, game.level.cell_center(Vector2i(0, 0)))
	game.build_controller.sell(tower)
	assert_false(game.build_controller.is_occupied(Vector2i(0, 0)))
