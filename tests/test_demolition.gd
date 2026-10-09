# Demolición directa (T207, RF-404 a RF-410 y RF-417): la lógica pura, la conexión con la partida y la selección.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0
const ROWS: Array[String] = [
	"....................", "....t...............", "....................", "...........r........",
	"A##################S", "....................", "....................", "....................", "....................",
]
const TREE := Vector2i(4, 1)
const ROCK := Vector2i(11, 3)

var game: Game
var field: ObstacleField


func after_each() -> void:
	GameFlow.test_level = null
	GameFlow.forced_seed = -1
	Engine.time_scale = 1.0


func _specs(chance: int = 100) -> Array[ObstacleSpec]:
	var specs: Array[ObstacleSpec] = []
	for entry: Array in [[ROCK, &"roca", 60, 6.0], [TREE, &"arbol", 40, 4.0]]:
		var spec := ObstacleSpec.new()
		spec.cell = entry[0]
		spec.class_id = entry[1]
		spec.cost = entry[2]
		spec.seconds = entry[3]
		spec.reward_amount = 1
		spec.chance_percent = chance
		specs.append(spec)
	return specs


func _field(chance: int = 100, seed_value: int = 1) -> ObstacleField:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var result := ObstacleField.new()
	result.setup(_specs(chance), rng)
	return result


func _start_game(gold: int = 100, machine_enabled: bool = false) -> void:
	var rows: Array = ROWS.duplicate()
	rows[1] = "....t..............."
	rows[3] = "...........r........"
	var data := {"version": 1, "nombre": "Demolición", "oro": gold, "vidas": 10,
		"demoledora": machine_enabled,
		"leyenda": {"t": {"removible": {"clase": "arbol"}}, "r": {"removible": {"clase": "roca"}}},
		"mapa": rows, "oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}], [{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	GameFlow.test_level = result["level"]
	GameFlow.forced_seed = 7
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


# --- Lógica pura: ObstacleField y DemolitionJob ---

func test_job_progress_and_done() -> void:
	var job := DemolitionJob.new(TREE, 4.0, 40)
	job.tick(1.0)
	assert_almost_eq(job.progress(), 0.25, 0.001)
	assert_false(job.is_done())
	job.tick(10.0)
	assert_true(job.is_done(), "no se pasa de la duración")
	assert_eq(job.progress(), 1.0)
	assert_eq(DemolitionJob.new(TREE, 0.0, 0).progress(), 1.0, "borde: duración 0")


func test_order_starts_a_job_with_fixed_price_and_time() -> void:
	field = _field()
	var job: DemolitionJob = field.order(TREE)
	assert_not_null(job)
	assert_eq(job.paid, 40)
	assert_eq(job.seconds_total, 4.0)
	assert_eq(field.state_of(TREE), ObstacleField.State.WORKING)


func test_machine_applies_data_percentages_and_minimum() -> void:
	field = _field()
	assert_eq(field.machine_price(), 180, "RF-412: el precio sale de data/obstaculos.json")
	assert_eq(field.cost_of(TREE), 40)
	assert_true(field.buy_machine())
	assert_true(field.has_machine)
	assert_eq(field.cost_of(TREE), 5, "RF-413: 10 % de 40 redondeado, mínimo 5")
	assert_eq(field.cost_of(ROCK), 6, "RF-413: 10 % de 60")
	assert_almost_eq(field.seconds_of(TREE), 3.2, 0.001)
	assert_almost_eq(field.seconds_of(ROCK), 4.8, 0.001)
	assert_false(field.buy_machine(), "RF-412: no se compra dos veces")


func test_machine_discount_never_exceeds_original_cost() -> void:
	var cheap := ObstacleSpec.new()
	cheap.cell = TREE
	cheap.cost = 3
	cheap.seconds = 2.0
	field = ObstacleField.new()
	field.setup([cheap] as Array[ObstacleSpec], RandomNumberGenerator.new())
	field.buy_machine()
	assert_eq(field.cost_of(TREE), 3, "RF-413: el mínimo no puede subir el costo original")


func test_machine_amortization_examples_from_rf_414() -> void:
	field = _field()
	var cases: Array[Array] = [[60, 6, 4], [40, 5, 6], [90, 9, 3]]
	for entry: Array in cases:
		var original_total: int = int(entry[0]) * int(entry[2])
		var machine_total: int = field.machine_price() + int(entry[1]) * int(entry[2])
		assert_true(machine_total < original_total, "RF-414: la máquina se amortiza en el número de demoliciones indicado")


func test_only_one_job_at_a_time() -> void:
	field = _field()
	field.order(TREE)
	assert_eq(field.can_order(ROCK), &"busy", "RF-406: una sola a la vez")
	assert_null(field.order(ROCK))
	assert_eq(field.can_order(TREE), &"busy", "tampoco se ordena dos veces la misma")


func test_cannot_order_what_is_not_removable() -> void:
	field = _field()
	assert_eq(field.can_order(Vector2i(0, 0)), &"not_removable")
	assert_null(field.order(Vector2i(0, 0)))


func test_finishing_clears_and_emits_once() -> void:
	field = _field()
	watch_signals(field)
	field.order(TREE)
	field.tick(3.9)
	assert_signal_not_emitted(field, "job_finished")
	field.tick(0.2)
	assert_signal_emit_count(field, "job_finished", 1)
	assert_eq(field.state_of(TREE), ObstacleField.State.CLEARED)
	assert_false(field.has_job())
	field.tick(5.0)
	assert_signal_emit_count(field, "job_finished", 1, "RF-408: la recompensa llega una sola vez")
	assert_eq(field.can_order(TREE), &"cleared", "un despejado no vuelve a ordenarse")
	assert_null(field.order(TREE))


func test_cancel_refunds_everything_and_leaves_it_intact() -> void:
	field = _field()
	field.order(ROCK)
	field.tick(3.0)
	assert_eq(field.cancel(), 60, "RF-407: devuelve todo lo pagado")
	assert_eq(field.state_of(ROCK), ObstacleField.State.INTACT)
	assert_eq(field.cancel(), 0, "borde: sin trabajo no devuelve nada")
	var again: DemolitionJob = field.order(ROCK)
	assert_eq(again.seconds_done, 0.0, "el progreso se pierde")


func test_discard_job_gives_nothing_back() -> void:
	field = _field()
	watch_signals(field)
	field.order(ROCK)
	field.tick(1.0)
	field.discard_job()
	assert_false(field.has_job())
	assert_eq(field.state_of(ROCK), ObstacleField.State.INTACT)
	assert_signal_not_emitted(field, "job_finished")
	assert_signal_emitted_with_parameters(field, "job_cancelled", [ROCK, 0])


func test_drop_is_drawn_at_setup_in_row_column_order() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var expected := RandomNumberGenerator.new()
	expected.seed = 99
	var first: bool = expected.randi_range(1, 100) <= 50   # fila 1: el árbol
	var second: bool = expected.randi_range(1, 100) <= 50  # fila 3: la roca
	field = ObstacleField.new()
	field.setup(_specs(50), rng)  # las specs vienen en otro orden: la roca primero
	assert_eq(field.reward_of(TREE)["resources"], 1 if first else 0)
	assert_eq(field.reward_of(ROCK)["resources"], 1 if second else 0)


func test_drop_is_not_redrawn_by_cancelling_or_by_order() -> void:
	field = _field(50, 5)
	var before: int = field.reward_of(ROCK)["resources"]
	field.order(ROCK)
	field.cancel()
	field.order(TREE)
	field.cancel()
	assert_eq(field.reward_of(ROCK)["resources"], before, "RF-417: cancelar y volver a ordenar no sortea otra vez")


func test_same_seed_same_drops_and_extreme_chances() -> void:
	var a: ObstacleField = _field(50, 11)
	var b: ObstacleField = _field(50, 11)
	assert_eq(a.reward_of(TREE), b.reward_of(TREE))
	assert_eq(a.reward_of(ROCK), b.reward_of(ROCK))
	var never: ObstacleField = _field(0, 3)
	var always: ObstacleField = _field(100, 3)
	assert_eq(never.reward_of(TREE)["resources"], 0, "borde: 0 %")
	assert_eq(always.reward_of(TREE)["resources"], 1, "borde: 100 %")


func test_ruin_with_finding_gives_piece_or_repeat_resources() -> void:
	var ruin := ObstacleSpec.new()
	ruin.cell = TREE
	ruin.class_id = &"escombro"
	ruin.cost = 90
	ruin.seconds = 10.0
	ruin.finding_collection = &"disruptor"
	ruin.repeat_reward = 1
	var pending := ObstacleField.new()
	pending.setup([ruin] as Array[ObstacleSpec], RandomNumberGenerator.new(), {}, &"level_09")
	var reward: Dictionary = pending.reward_of(TREE)
	assert_eq(reward["resources"], 0, "RF-428: con la pieza pendiente, ningún recurso")
	assert_eq(reward["finding"], {"collection": &"disruptor", "source": &"level_09"})
	var done := ObstacleField.new()
	done.setup([ruin] as Array[ObstacleSpec], RandomNumberGenerator.new(), {&"disruptor": true}, &"level_09")
	assert_eq(done.reward_of(TREE)["resources"], 1)
	assert_true(done.reward_of(TREE)["finding"].is_empty())


func test_panel_texts_come_from_data() -> void:
	var spec: ObstacleSpec = _specs(50)[1]
	assert_eq(ObstacleText.reward_line(spec, false), "Puede dar 1 recurso (50 %)")
	spec.chance_percent = 0
	assert_eq(ObstacleText.reward_line(spec, false), "No da recursos")
	assert_eq(ObstacleText.missing_gold(40, 25), "Te faltan 15 de oro")


# --- La partida: cobro, trabajo, reloj, construir y fin ---

func test_order_charges_and_finishing_allows_building() -> void:
	_start_game(100)
	var basic: TowerData = game.tower_types[0]
	assert_false(game.build_controller.try_build(basic, TREE), "intacto: no se construye")
	assert_true(game.infrastructure.order(TREE))
	assert_eq(game.session.gold, 60, "RF-405: se cobra al ordenar (40)")
	game.infrastructure._process(4.1)
	assert_eq(game.infrastructure.field.state_of(TREE), ObstacleField.State.CLEARED)
	assert_true(game.level.is_buildable(TREE), "RF-408: queda pasto construible")
	assert_true(game.build_controller.try_build(basic, TREE))


func test_machine_purchase_is_level_gated_and_updates_prices_globally() -> void:
	_start_game(300, true)
	assert_true(game.hud.infrastructure_tab._machine_card.visible, "RF-411 y RF-457: la tarjeta de la demoledora aparece solo en el nivel habilitado")
	game.infrastructure.select(TREE)
	var text_before: Array[String] = []
	for label: Node in game.hud.obstacle_panel.find_children("*", "Label", true, false):
		text_before.append((label as Label).text)
	assert_true(text_before.any(func(text: String) -> bool: return text.contains("Con la demoledora: 5 de oro")),
		"RF-413: se informa el precio reducido antes de comprar")
	assert_true(game.infrastructure.buy_machine())
	assert_eq(game.session.gold, 120, "RF-412: cobra 180 de oro")
	assert_true(game.infrastructure.field.has_machine)
	assert_true(game.hud.infrastructure_tab._machine_title.text.contains("Demoledora activa"))
	assert_false(game.infrastructure.buy_machine(), "no vuelve a cobrar una segunda compra")
	assert_eq(game.session.gold, 120)
	assert_true(game.infrastructure.order(ROCK))
	assert_eq(game.session.gold, 114, "RF-413: el descuento rige en todo el mapa")
	assert_almost_eq(game.infrastructure.field.job().seconds_total, 4.8, 0.001)


func test_machine_cannot_be_bought_without_gold_or_when_level_disables_it() -> void:
	_start_game(100, true)
	assert_false(game.infrastructure.buy_machine(), "RF-412: no alcanza para los 180 de oro")
	assert_eq(game.session.gold, 100)
	assert_false(game.infrastructure.field.has_machine)
	game.free()
	_start_game(300, false)
	assert_false(game.hud.infrastructure_tab._machine_card.visible, "RF-411: sin habilitación no aparece la tarjeta de la demoledora")
	assert_false(game.infrastructure.buy_machine())
	assert_eq(game.session.gold, 300)


func test_machine_purchase_does_not_change_existing_job_and_retry_removes_it() -> void:
	_start_game(300, true)
	assert_true(game.infrastructure.order(TREE))
	var active_job: DemolitionJob = game.infrastructure.field.job()
	assert_eq(active_job.paid, 40)
	assert_eq(active_job.seconds_total, 4.0)
	assert_true(game.infrastructure.buy_machine())
	assert_eq(game.session.gold, 80)
	assert_eq(active_job.paid, 40, "RF-413: no se devuelve la diferencia")
	assert_eq(active_job.seconds_total, 4.0, "RF-406: la duración ordenada queda fija")
	game.free()
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_false(game.infrastructure.field.has_machine, "RF-412: el reinicio pierde la compra")
	assert_eq(game.session.gold, 300)


func test_cannot_order_without_gold() -> void:
	_start_game(30)
	assert_false(game.infrastructure.order(TREE), "RF-405: cuesta 40")
	assert_eq(game.session.gold, 30)
	assert_false(game.infrastructure.field.has_job())


func test_cancel_in_game_refunds_gold() -> void:
	_start_game(100)
	game.infrastructure.order(ROCK)
	game.infrastructure._process(3.0)
	assert_true(game.infrastructure.cancel_job())
	assert_eq(game.session.gold, 100, "RF-407: vuelve todo")
	assert_eq(game.infrastructure.field.state_of(ROCK), ObstacleField.State.INTACT)
	assert_false(game.infrastructure.cancel_job(), "borde: sin trabajo")


func test_second_obstacle_is_refused_while_busy() -> void:
	_start_game(200)
	game.infrastructure.order(TREE)
	assert_false(game.infrastructure.order(ROCK))
	assert_eq(game.session.gold, 160, "no se cobró la segunda")


func test_wave_end_keeps_the_job_and_game_over_discards_it() -> void:
	_start_game(100)
	game.infrastructure.order(ROCK)
	game.session.begin_wave()
	game.session.complete_wave()
	assert_true(game.infrastructure.field.has_job(), "RF-409: la oleada termina y el trabajo sigue")
	game.session.finish(false)
	assert_false(game.infrastructure.field.has_job(), "RF-409: el fin de la partida lo descarta")
	assert_eq(game.session.gold, 40 + Rules.wave_bonus(1, game.balance), "no devuelve el oro")
	game.infrastructure._process(10.0)
	assert_eq(game.infrastructure.field.state_of(ROCK), ObstacleField.State.INTACT, "no entrega nada")


func test_pause_stops_the_clock() -> void:
	_start_game(100)
	game.infrastructure.order(TREE)
	assert_true(game.infrastructure.can_process())
	game.set_paused(true)
	assert_false(game.infrastructure.can_process(), "RF-406: en pausa el reloj no avanza")
	game.set_paused(false)
	assert_true(game.infrastructure.can_process())


func test_double_speed_halves_real_time() -> void:
	_start_game(100)
	game.set_speed(2.0)
	var start: int = Time.get_ticks_msec()
	game.infrastructure.order(ROCK)
	await wait_seconds(0.6)
	var elapsed: float = (Time.get_ticks_msec() - start) / 1000.0
	var done: float = game.infrastructure.field.job().seconds_done
	assert_gt(done, 1.5 * (elapsed - 0.15), "a ×2 el trabajo avanza el doble de rápido que el reloj real")


func test_retry_restores_everything() -> void:
	_start_game(100)
	game.infrastructure.order(TREE)
	game.infrastructure._process(5.0)
	assert_eq(game.infrastructure.field.state_of(TREE), ObstacleField.State.CLEARED)
	game.free()
	game = GAME_SCENE.instantiate()  # reintentar recarga la escena: todo vuelve a empezar
	add_child_autofree(game)
	assert_eq(game.infrastructure.field.state_of(TREE), ObstacleField.State.INTACT, "RF-409: una partida nueva arranca intacta")
	assert_false(game.level.is_buildable(TREE))
	assert_eq(game.session.gold, 100)


func test_reward_is_not_duplicated_after_clearing() -> void:
	_start_game(200)
	watch_signals(game.infrastructure)
	game.infrastructure.order(TREE)
	game.infrastructure._process(4.1)
	assert_false(game.infrastructure.order(TREE), "despejado: no vuelve")
	game.infrastructure._process(10.0)
	assert_signal_emit_count(game.infrastructure, "demolished", 1)
	assert_eq(game.session.gold, 160)


# --- Selección (RF-404) ---

func test_obstacle_selection_rules() -> void:
	_start_game(100)
	var infra: InfrastructureController = game.infrastructure
	assert_not_null(infra.obstacle_at(TREE))
	assert_null(infra.obstacle_at(Vector2i(0, 0)), "pasto: no se elige")
	infra.select(TREE)
	assert_eq(infra.selected_cell(), TREE)
	assert_true(game.hud.obstacle_panel.visible)
	game.build_controller.select(0)
	assert_false(infra.has_selection(), "RF-73: elegir una torre para construir deselecciona el removible")
	assert_false(game.hud.obstacle_panel.visible)
	infra.select(TREE)
	infra.order(TREE)
	infra.field.tick(5.0)
	assert_false(infra.has_selection(), "al terminar, el panel se cierra")
	assert_null(infra.obstacle_at(TREE), "despejado: ya no se puede elegir")


func test_click_on_obstacle_selects_it_even_in_build_mode() -> void:
	_start_game(100)
	var build: BuildController = game.build_controller
	build.select(0)
	# El mouse real no se puede mover en headless: se prueba por la costura que usa el clic.
	build._select_obstacle(TREE)
	assert_eq(build.selected_tower(), null, "RF-404: en el modo construcción un removible se elige")
	assert_eq(game.infrastructure.selected_cell(), TREE)
	assert_eq(game.session.gold, 100, "no se construyó ni cobró nada")
	assert_eq(game.tower_container.get_child_count(), 0)


func test_panel_states() -> void:
	_start_game(30)
	var panel: ObstaclePanel = game.hud.obstacle_panel
	game.infrastructure.select(TREE)
	var button: Button = panel.find_children("*", "Button", true, false)[0]
	assert_true(button.disabled)
	assert_eq(button.text, "Te faltan 10 de oro", "RF-405")
	game.session.earn(100)
	assert_false(button.disabled)
	game.infrastructure.order(TREE)
	assert_eq(button.text.begins_with("Cancelar"), true)
	game.infrastructure.select(ROCK)
	assert_true(button.disabled)
	var texts: Array[String] = []
	for label: Node in panel.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	assert_true(texts.has("Hay una demolición en curso"), "RF-406")
