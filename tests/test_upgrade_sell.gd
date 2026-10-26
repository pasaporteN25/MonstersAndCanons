# Tests de M2, bloque A: seleccionar torres, panel, mejorar, vender y modos de apuntado
# (T30-T33, spec §5.5 y RF-54).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const DT: float = 1.0 / 60.0
const CELL := Vector2i(4, 2)

var game: Game
var basic: TowerData
var tower: Tower


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	basic = game.tower_types[0]
	game.build_controller.try_build(basic, CELL)
	tower = game.build_controller.tower_at(CELL)


func _panel_text(unique_name: String) -> String:
	var node: Node = game.hud.tower_panel.get_node("%" + unique_name)
	return node.text


# --- Datos de mejoras (tabla de mejoras de la spec §5.5) ---

func test_every_tower_has_three_levels() -> void:
	for data: TowerData in game.tower_types:
		assert_eq(data.levels.size(), 3, "%s: RF-71" % data.id)


func test_upgrade_table_matches_spec() -> void:
	var cannon: TowerData = game.tower_types[1]
	var frost: TowerData = game.tower_types[2]
	# [costo, daño, cadencia, alcance, área, ralentización, duración]
	var expected := {
		basic.levels[1]: [60, 8, 2.5, 3.0, 0.0, 0.0, 0.0],
		basic.levels[2]: [100, 12, 3.0, 3.5, 0.0, 0.0, 0.0],
		cannon.levels[1]: [110, 32, 0.6, 3.0, 1.2, 0.0, 0.0],
		cannon.levels[2]: [170, 50, 0.6, 3.5, 1.5, 0.0, 0.0],
		frost.levels[1]: [80, 2, 1.0, 3.0, 0.0, 0.5, 2.0],
		frost.levels[2]: [120, 4, 1.0, 3.0, 0.0, 0.6, 3.0],
	}
	for lvl: TowerLevelData in expected:
		var e: Array = expected[lvl]
		assert_eq(lvl.cost, e[0], "costo")
		assert_eq(lvl.damage, e[1], "daño")
		assert_almost_eq(lvl.fire_rate, e[2], 0.001, "cadencia")
		assert_almost_eq(lvl.range_tiles, e[3], 0.001, "alcance")
		assert_almost_eq(lvl.splash_radius_tiles, e[4], 0.001, "área")
		assert_almost_eq(lvl.slow_amount, e[5], 0.001, "ralentización")
		assert_almost_eq(lvl.slow_duration, e[6], 0.001, "duración")


# --- Mejorar (T31, RF-71, RF-76) ---

func test_upgrade_costs_gold_and_changes_stats() -> void:
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(game.session.gold, 150 - 50 - 60)
	assert_eq(tower.level_number(), 2)
	assert_eq(tower.stats().damage, 8)
	assert_eq(tower.total_invested, 110)


func test_cannot_upgrade_past_level_three() -> void:
	game.session.earn(1000)
	game.build_controller.try_upgrade(tower)
	game.build_controller.try_upgrade(tower)
	assert_eq(tower.level_number(), 3)
	assert_false(tower.can_upgrade())
	assert_false(game.build_controller.try_upgrade(tower))


func test_cannot_upgrade_without_gold() -> void:
	game.session.spend(game.session.gold - 59)  # quedan 59; mejorar cuesta 60
	assert_false(game.build_controller.try_upgrade(tower))
	assert_eq(tower.level_number(), 1)
	assert_eq(game.session.gold, 59)


# --- Vender (T32, RF-72) ---

func test_sell_spec_example() -> void:
	game.build_controller.try_upgrade(tower)  # 50 + 60 = 110 invertidos
	var gold_before: int = game.session.gold
	assert_eq(game.build_controller.sell(tower), 77, "criterio de aceptación RF-72")
	assert_eq(game.session.gold, gold_before + 77)
	assert_false(game.build_controller.is_occupied(CELL), "la casilla queda libre")
	await wait_process_frames(1)
	assert_eq(game.tower_container.get_child_count(), 0)
	assert_true(game.build_controller.try_build(basic, CELL), "se puede volver a construir")


# --- Seleccionar y panel (T30, RF-70, RF-73) ---

func test_panel_opens_on_selection_and_closes_on_deselection() -> void:
	assert_false(game.hud.tower_panel.visible)
	game.build_controller.select_placed(tower)
	assert_true(game.hud.tower_panel.visible)
	assert_eq(_panel_text("Title"), "Ametralladora")
	assert_eq(_panel_text("UpgradeButton"), "Mejorar a nivel 2")
	assert_eq(_panel_text("Cost"), "60", "el costo va junto a la moneda en el botón")
	assert_eq(_panel_text("SellButton"), "Vender +35 [S]")
	game.build_controller.deselect_placed()
	assert_false(game.hud.tower_panel.visible)


func test_panel_updates_after_upgrade() -> void:
	game.build_controller.select_placed(tower)
	game.build_controller.try_upgrade(tower)
	assert_eq(_panel_text("Title"), "Ametralladora")
	assert_eq(_panel_text("UpgradeButton"), "Mejorar a nivel 3")
	assert_eq(_panel_text("SellButton"), "Vender +77 [S]")
	assert_eq((game.hud.tower_panel.get_node("%LevelCard") as HBoxContainer).tooltip_text, "Nivel actual: 2 de 3")


func test_close_button_hides_panel_and_deselects_tower() -> void:
	game.build_controller.select_placed(tower)
	assert_true(game.hud.tower_panel.visible)
	(game.hud.tower_panel.get_node("%CloseButton") as Button).pressed.emit()
	assert_null(game.build_controller.selected_placed())
	assert_false(game.hud.tower_panel.visible)


func test_upgrade_button_greys_out_without_gold() -> void:
	game.build_controller.select_placed(tower)
	game.session.spend(game.session.gold)
	var button: Button = game.hud.tower_panel.get_node("%UpgradeButton")
	assert_true(button.disabled, "RF-76")


func test_panel_says_max_level() -> void:
	game.session.earn(1000)
	game.build_controller.select_placed(tower)
	game.build_controller.try_upgrade(tower)
	game.build_controller.try_upgrade(tower)
	assert_eq(_panel_text("UpgradeButton"), "Nivel máximo")


func test_selling_the_selected_tower_closes_the_panel() -> void:
	game.build_controller.select_placed(tower)
	game.build_controller.sell(tower)
	assert_false(game.hud.tower_panel.visible)


func test_build_mode_and_selection_are_exclusive() -> void:
	game.build_controller.select_placed(tower)
	game.build_controller.select(1)
	assert_null(game.build_controller.selected_placed(), "RF-73")
	game.build_controller.select_placed(tower)
	assert_null(game.build_controller.selected_tower(), "RF-73")


# --- Modos de apuntado (T33, RF-54) ---

func _enemy_at(distance: float, health: int) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(game.level_data.waves[0].groups[0].enemy, game.level.get_ground_path(0), health)
	enemy.distance = distance
	game.enemies.add_child(enemy)
	return enemy


func test_targeting_modes_pick_different_enemies() -> void:
	# La torre está en (4, 2); el camino pasa por la fila 1 (arriba de ella).
	var behind: Enemy = _enemy_at(200.0, 10)   # más lejos de la salida
	var strong: Enemy = _enemy_at(280.0, 500)  # más vida, justo encima de la torre
	var ahead: Enemy = _enemy_at(380.0, 10)    # más cerca de la salida
	assert_eq(tower.targeting_name(), "Primero")
	assert_eq(tower.find_target(), ahead, "Primero")
	tower.cycle_targeting()
	assert_eq(tower.find_target(), behind, "Último")
	tower.cycle_targeting()
	assert_eq(tower.find_target(), strong, "Más fuerte")
	tower.cycle_targeting()
	assert_eq(tower.targeting_name(), "Más cercano")
	assert_eq(tower.find_target(), strong, "Más cercano: el que está encima")
	tower.cycle_targeting()
	assert_eq(tower.targeting_name(), "Primero", "vuelve a empezar")
