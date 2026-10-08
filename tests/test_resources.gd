# Recursos locales y torres que cuestan recursos (T209, RF-415 a RF-421).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0
const ROWS: Array[String] = [
	"....................", "....................", "....................", "...........r........",
	"A##################S", "....................", "....................", "....................", "....................",
]
const ROCK := Vector2i(11, 3)

var game: Game
var mortar: TowerData
var sniper: TowerData
var cfg: BalanceConfig = load("res://data/balance.tres")


func before_each() -> void:
	mortar = load("res://data/towers/mortar.tres")
	sniper = load("res://data/towers/sniper.tres")


func after_each() -> void:
	GameFlow.test_level = null
	GameFlow.forced_seed = -1


## Un mapa con una roca que entrega siempre (probabilidad 100) o sin ninguna fuente de recursos.
func _start_game(with_rock: bool = true, chance: int = 100, towers: Array = ["mortar", "sniper"]) -> void:
	var rows: Array = ROWS.duplicate()
	if not with_rock:
		rows[3] = "...................."
	var data := {"version": 1, "nombre": "Recursos", "oro": 1000, "vidas": 10, "torres": towers,
		"mapa": rows, "oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	if with_rock:
		data["leyenda"] = {"r": {"removible": {"clase": "roca", "probabilidad": chance, "costo": 10, "tiempo": 1.0}}}
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	GameFlow.test_level = result["level"]
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _demolish_rock() -> void:
	game.infrastructure.order(ROCK)
	for i: int in 120:
		game.infrastructure._process(DT)


func _free_block() -> Vector2i:
	for y: int in range(0, 8):
		for x: int in range(0, 19):
			if game.build_controller.cells_free(mortar, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _set_resources(amount: int) -> void:
	game.session.resources = 0
	game.session.add_resources(amount)


# --- Los datos (RF-418 a RF-420) ---

func test_the_data_of_the_two_towers() -> void:
	assert_eq(mortar.resource_cost, 3, "RF-420")
	assert_eq(mortar.levels[0].cost, 300)
	assert_eq(mortar.alt_resource_cost, 0)
	assert_eq(sniper.resource_cost, 0, "RF-419")
	assert_eq(sniper.levels[0].cost, 150, "la forma de oro cuesta lo de siempre")
	assert_eq(sniper.alt_gold_cost, 120)
	assert_eq(sniper.alt_resource_cost, 1)


func test_no_tower_mixes_resource_cost_with_a_second_payment() -> void:
	for tower: TowerData in Wiki._all_towers():
		if tower.has_alt_payment():
			assert_eq(tower.resource_cost, 0, "%s: RF-419, o una cosa o la otra" % tower.id)
			assert_lt(tower.alt_gold_cost, tower.levels[0].cost, "%s: la segunda forma es más barata en oro" % tower.id)
		else:
			assert_eq(tower.alt_gold_cost, 0, "%s: sin recurso no hay segundo precio" % tower.id)


func test_other_towers_do_not_cost_resources() -> void:
	for tower: TowerData in Wiki._all_towers():
		if tower.id == &"disruptor":
			assert_eq(tower.resource_cost, 2, "RF-446: la Disruptora cuesta 2 recursos")
		elif tower.id != &"mortar":
			assert_eq(tower.resource_cost, 0, "%s no cambia" % tower.id)


# --- LevelSession (RF-415) ---

func test_session_starts_at_zero_and_restarts_at_zero() -> void:
	var session := LevelSession.new()
	add_child_autofree(session)
	var level := LevelData.new()
	level.waves.append(WaveData.new())
	session.start(level, cfg)
	assert_eq(session.resources, 0)
	session.add_resources(4)
	assert_eq(session.resources, 4)
	session.start(level, cfg)
	assert_eq(session.resources, 0, "reiniciar vuelve a 0")


func test_add_resources_emits_and_ignores_zero() -> void:
	var session := LevelSession.new()
	add_child_autofree(session)
	watch_signals(session)
	session.add_resources(0)
	session.add_resources(-2)
	assert_signal_not_emitted(session, "resources_changed")
	assert_eq(session.resources, 0)
	session.add_resources(2)
	assert_signal_emitted_with_parameters(session, "resources_changed", [2])


func test_spend_both_is_atomic() -> void:
	var session := LevelSession.new()
	add_child_autofree(session)
	var level := LevelData.new()
	level.starting_gold = 300
	level.waves.append(WaveData.new())
	session.start(level, cfg)
	session.add_resources(2)
	assert_false(session.spend_both(300, 3), "faltan recursos")
	assert_eq(session.gold, 300, "no cobró el oro")
	assert_eq(session.resources, 2)
	assert_false(session.spend_both(301, 1), "falta oro")
	assert_eq(session.resources, 2, "no cobró los recursos")
	session.add_resources(1)
	assert_true(session.spend_both(300, 3))
	assert_eq(session.gold, 0)
	assert_eq(session.resources, 0)
	assert_true(session.spend_both(0, 0), "borde: costo 0 siempre se puede")


# --- Construir, mejorar y vender (RF-418) ---

func test_mortar_needs_both_gold_and_resources() -> void:
	_start_game()
	var origin: Vector2i = _free_block()
	_set_resources(2)
	assert_false(game.build_controller.try_build(mortar, origin), "300 de oro y 2 recursos: no")
	assert_eq(game.session.gold, 1000, "no cobró nada")
	assert_eq(game.session.resources, 2)
	_set_resources(3)
	game.session.spend(game.session.gold - 299)
	assert_false(game.build_controller.try_build(mortar, origin), "299 de oro y 3 recursos: no")
	assert_eq(game.session.resources, 3, "no cobró recursos")
	game.session.earn(1)
	assert_true(game.build_controller.try_build(mortar, origin), "300 y 3: sí")
	assert_eq(game.session.gold, 0)
	assert_eq(game.session.resources, 0)


func test_upgrading_does_not_cost_resources() -> void:
	_start_game()
	var origin: Vector2i = _free_block()
	_set_resources(3)
	game.build_controller.try_build(mortar, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	_set_resources(5)
	var gold: int = game.session.gold
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(game.session.gold, gold - mortar.levels[1].cost)
	assert_eq(game.session.resources, 5, "mejorar no cobra recursos (Q-22)")


func test_selling_returns_gold_and_resources_rounded_down() -> void:
	_start_game()
	var origin: Vector2i = _free_block()
	_set_resources(3)
	game.build_controller.try_build(mortar, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	assert_eq(tower.resources_invested, 3)
	assert_eq(game.build_controller.sell_resource_value(tower), 2, "floor(3 × 70 / 100)")
	game.session.spend(game.session.gold)
	assert_eq(game.build_controller.sell(tower), 210)
	assert_eq(game.session.gold, 210)
	assert_eq(game.session.resources, 2)


func test_a_tower_without_resources_returns_none() -> void:
	_start_game()
	var basic: TowerData = game.tower_types[0]
	assert_true(game.build_controller.try_build(basic, Vector2i(0, 0)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(0, 0))
	game.build_controller.sell(tower)
	assert_eq(game.session.resources, 0)


# --- Francotirador con dos formas de pago (RF-419) ---

func test_sniper_gold_payment_is_as_always() -> void:
	_start_game()
	assert_true(game.build_controller.try_build(sniper, Vector2i(0, 0)))
	assert_eq(game.session.gold, 850)
	assert_eq(game.session.resources, 0)


func test_sniper_alt_payment_charges_120_and_1_resource() -> void:
	_start_game()
	game.session.spend(game.session.gold - 120)
	_set_resources(1)
	assert_false(game.build_controller.can_build(sniper, Vector2i(0, 0)), "con 120 de oro la forma común no alcanza")
	assert_true(game.build_controller.try_build(sniper, Vector2i(0, 0), true))
	assert_eq(game.session.gold, 0)
	assert_eq(game.session.resources, 0)
	var tower: Tower = game.build_controller.tower_at(Vector2i(0, 0))
	assert_eq(tower.total_invested, 120)
	game.build_controller.sell(tower)
	assert_eq(game.session.gold, 84)
	assert_eq(game.session.resources, 0, "con 1 recurso la venta devuelve 0 (Q-23)")


func test_sniper_alt_payment_without_resources_fails_and_charges_nothing() -> void:
	_start_game()
	assert_false(game.build_controller.try_build(sniper, Vector2i(0, 0), true))
	assert_eq(game.session.gold, 1000)


func test_alt_payment_on_a_normal_tower_is_just_gold_only() -> void:
	_start_game()
	var basic: TowerData = game.tower_types[0]
	assert_true(game.build_controller.try_build(basic, Vector2i(0, 0), true))
	assert_eq(game.session.gold, 1000 - basic.levels[0].cost, "sin segunda forma de pago, `alt` no cambia nada")


func test_payment_choice_starts_gold_only_and_resets() -> void:
	_start_game()
	var index: int = game.available_towers.find(sniper)
	assert_ne(index, -1)
	game.build_controller.select(index)
	assert_false(game.build_controller.pay_alt(), "solo oro de entrada")
	game.build_controller.set_pay_alt(true)
	assert_true(game.build_controller.pay_alt())
	game.build_controller.cancel()
	assert_false(game.build_controller.pay_alt(), "al cancelar vuelve a solo oro")
	game.build_controller.select(game.available_towers.find(mortar))
	game.build_controller.set_pay_alt(true)
	assert_false(game.build_controller.pay_alt(), "el Mortero no tiene segunda forma")


# --- Recompensa de la demolición (RF-408 y RF-417) ---

func test_demolition_adds_the_resource_once() -> void:
	_start_game(true, 100)
	_demolish_rock()
	assert_eq(game.session.resources, 1)
	for i: int in 60:
		game.infrastructure._process(DT)
	assert_eq(game.session.resources, 1, "entra una sola vez")


func test_demolition_with_zero_chance_gives_nothing() -> void:
	_start_game(true, 0)
	_demolish_rock()
	assert_eq(game.session.resources, 0)


func test_example_play_demolish_then_build_the_mortar() -> void:
	_start_game(true, 100)
	game.session.resources = 0
	_demolish_rock()
	_set_resources(3)
	var origin: Vector2i = _free_block()
	assert_true(game.build_controller.try_build(mortar, origin), "con 3 recursos se construye el Mortero")


# --- HUD (RF-416) ---

func test_counter_is_hidden_on_a_map_without_resources() -> void:
	_start_game(false)
	assert_false(game.level_data.uses_resources())
	assert_false((game.hud.get_node("TopBar/Stats/ResourceStat") as Control).visible)


func test_counter_shows_on_a_map_with_resources_and_follows_the_session() -> void:
	_start_game(true, 100)
	var stat: Control = game.hud.get_node("TopBar/Stats/ResourceStat")
	assert_true(stat.visible)
	game.session.add_resources(2)
	assert_eq((stat.get_node("ResourceLabel") as Label).text, "2")


func test_towers_that_cost_resources_do_not_turn_the_counter_on() -> void:
	_start_game(false)  # ofrece Mortero y Francotirador, pero no tiene fuentes
	assert_true(game.available_towers.has(mortar))
	assert_false((game.hud.get_node("TopBar/Stats/ResourceStat") as Control).visible, "RF-416")


func _bar_button(tower: TowerData) -> Button:
	return game.hud._tower_buttons[game.available_towers.find(tower)]


func test_bar_shows_both_prices_and_disables_with_the_reason() -> void:
	_start_game(true, 100)
	var button: Button = _bar_button(mortar)
	assert_eq(button.text, "300 + 3")
	assert_true(button.disabled, "0 recursos")
	assert_string_contains(button.tooltip_text, "Faltan 3 recursos")
	game.session.add_resources(3)
	assert_false(button.disabled)
	assert_false(button.tooltip_text.contains("Faltan"))


func test_bar_disables_the_mortar_on_a_map_without_resources_and_says_why() -> void:
	_start_game(false)
	var button: Button = _bar_button(mortar)
	assert_true(button.disabled)
	assert_string_contains(button.tooltip_text, "no tiene cómo conseguirlos")


func test_sniper_button_stays_enabled_with_gold_only() -> void:
	_start_game(false)
	var button: Button = _bar_button(sniper)
	assert_eq(button.text, "150")
	assert_false(button.disabled)
	assert_string_contains(button.tooltip_text, "120 de oro + 1 recurso")


func test_sniper_help_shows_two_payment_buttons() -> void:
	_start_game(true, 100)
	game.build_controller.select(game.available_towers.find(sniper))
	var gold_button: Button = game.hud._pay_gold_button
	var alt_button: Button = game.hud._pay_alt_button
	assert_true(gold_button.visible and alt_button.visible)
	assert_eq(gold_button.text, "150 de oro")
	assert_eq(alt_button.text, "120 de oro + 1 recurso")
	assert_true(gold_button.button_pressed, "solo oro de entrada")
	assert_true(alt_button.disabled, "sin recursos")
	assert_string_contains(alt_button.tooltip_text, "Faltan 1 recurso")
	game.session.add_resources(1)
	assert_false(alt_button.disabled)
	alt_button.pressed.emit()
	assert_true(game.build_controller.pay_alt())
	assert_true(alt_button.button_pressed)
	assert_false(gold_button.button_pressed)


func test_second_payment_is_disabled_on_a_map_without_resources() -> void:
	_start_game(false)
	game.build_controller.select(game.available_towers.find(sniper))
	assert_true(game.hud._pay_alt_button.disabled)
	assert_string_contains(game.hud._pay_alt_button.tooltip_text, "no tiene cómo conseguirlos")


func test_help_of_a_normal_tower_hides_the_payment_buttons() -> void:
	_start_game(true, 100)
	game.build_controller.select(game.available_towers.find(mortar))
	assert_false(game.hud._pay_gold_button.visible)
	assert_string_contains((game.hud.get_node("%BuildInfoName") as Label).text, "300 de oro + 3 recursos")


# --- Panel y Wiki (RF-418, RF-437) ---

func test_panel_shows_what_the_sale_returns() -> void:
	_start_game(true, 100)
	var origin: Vector2i = _free_block()
	_set_resources(3)
	game.build_controller.try_build(mortar, origin)
	game.build_controller.select_placed(game.build_controller.tower_at(origin))
	var sell_button: Button = game.hud.tower_panel.get_node("%SellButton")
	assert_string_contains(sell_button.text, "210 y 2 recursos")


func test_text_helpers_read_the_data() -> void:
	assert_eq(TowerText.cost_text(mortar), "300 de oro + 3 recursos")
	assert_eq(TowerText.cost_text(sniper), "150 de oro")
	assert_eq(TowerText.cost_text(sniper, true), "120 de oro + 1 recurso")
	assert_eq(TowerText.refund_text(70, 0), "70")
	assert_eq(TowerText.refund_text(84, 0), "84")
	assert_eq(TowerText.missing_text(mortar, false, 300, 3, true), "", "alcanza")
	assert_eq(TowerText.missing_text(mortar, false, 250, 1, true), "Faltan 50 de oro y 2 recursos")
	assert_eq(TowerText.invested_line(load("res://data/towers/basic.tres"), 0), "")


func test_wiki_sheet_shows_the_resource_cost() -> void:
	var mortar_entry: WikiEntry = Wiki.tower_entry(mortar)
	var sniper_entry: WikiEntry = Wiki.tower_entry(sniper)
	assert_true(str(mortar_entry.blocks).contains("300 de oro + 3 recursos"))
	assert_true(str(sniper_entry.blocks).contains("120 de oro + 1 recurso"))
	var basic_entry: WikiEntry = Wiki.tower_entry(load("res://data/towers/basic.tres"))
	assert_false(str(basic_entry.blocks).contains("recurso"), "las torres de oro no cambian")


# --- Aviso de archivo (RF-421) ---

func _parse_warnings(with_rock: bool, towers: Array) -> PackedStringArray:
	var rows: Array = ROWS.duplicate()
	if not with_rock:
		rows[3] = "...................."
	var data := {"version": 1, "nombre": "Aviso", "oro": 500, "vidas": 10, "torres": towers,
		"mapa": rows, "oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	if with_rock:
		data["leyenda"] = {"r": {"removible": {"clase": "roca"}}}
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	return result["warnings"]


func test_warning_for_a_resource_tower_on_a_map_without_resources() -> void:
	var warnings: PackedStringArray = _parse_warnings(false, ["mortar"])
	assert_eq(warnings.size(), 1)
	assert_string_contains(warnings[0], "Mortero cuesta recursos")


func test_no_warning_with_resources_or_without_the_tower() -> void:
	assert_eq(_parse_warnings(true, ["mortar"]).size(), 0, "hay una roca que da recursos")
	assert_eq(_parse_warnings(false, ["basic", "sniper"]).size(), 0, "el Francotirador nunca es indispensable")
