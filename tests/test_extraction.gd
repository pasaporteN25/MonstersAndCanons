# Extracción finita (T210, RF-422 a RF-424): la lógica pura, la conexión con las oleadas y el panel.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const ROWS: Array[String] = [
	"....................", "....................", "....................", "...........r........",
	"A##################S", "....................", "....................", "...m................", "....................",
]
const MINE := Vector2i(3, 7)
const ROCK := Vector2i(11, 3)

var game: Game


func after_each() -> void:
	GameFlow.test_level = null
	GameFlow.forced_seed = -1


func _site(cell: Vector2i, production: int = 2, reserve: int = 8, cost: int = 100) -> ObstacleSpec:
	var spec := ObstacleSpec.new()
	spec.cell = cell
	spec.kind = ObstacleSpec.Kind.EXTRACTION
	spec.class_id = &"mina"
	spec.cost = cost
	spec.production = production
	spec.reserve = reserve
	return spec


func _field(production: int = 2, reserve: int = 8) -> ObstacleField:
	var field := ObstacleField.new()
	var specs: Array[ObstacleSpec] = [_site(MINE, production, reserve)]
	field.setup(specs, RandomNumberGenerator.new())
	return field


func _start_game(gold: int = 100, waves: int = 5, production: int = 2, reserve: int = 8) -> void:
	var wave: Array = [{"enemigo": "normal", "cantidad": 1, "cada": 1.0}]
	var list: Array = []
	for i: int in waves:
		list.append(wave)
	var data := {"version": 1, "nombre": "Extracción", "oro": gold, "vidas": 10,
		"leyenda": {"r": {"removible": {"clase": "roca"}}, "m": {"extraccion": {"clase": "mina", "produccion": production, "reserva": reserve}}},
		"mapa": ROWS, "oleadas": list}
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(result["errors"], PackedStringArray())
	GameFlow.test_level = result["level"]
	GameFlow.forced_seed = 7
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


## Completa una oleada de verdad: empieza, y la sesión la da por terminada.
func _complete_wave() -> void:
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.session.complete_wave()


# --- Lógica pura ---

func test_site_starts_disabled_with_full_reserve() -> void:
	var field: ObstacleField = _field()
	assert_eq(field.state_of(MINE), ObstacleField.State.DISABLED)
	assert_eq(field.reserve_left(MINE), 8)
	assert_true(field.is_extraction(MINE))
	assert_false(field.is_removable(MINE))


func test_does_not_produce_when_not_enabled() -> void:
	var field: ObstacleField = _field()
	assert_eq(field.complete_wave(), {})
	assert_eq(field.reserve_left(MINE), 8)


func test_produces_two_four_times_then_depletes() -> void:
	var field: ObstacleField = _field()
	assert_true(field.enable_site(MINE))
	for i: int in 4:
		assert_eq(field.complete_wave(), {MINE: 2}, "oleada %d" % (i + 1))
	assert_eq(field.reserve_left(MINE), 0)
	assert_eq(field.state_of(MINE), ObstacleField.State.DEPLETED)
	assert_eq(field.complete_wave(), {}, "agotado no produce")


func test_never_produces_more_than_the_reserve() -> void:
	var field: ObstacleField = _field(2, 1)
	field.enable_site(MINE)
	assert_eq(field.complete_wave(), {MINE: 1})
	assert_eq(field.state_of(MINE), ObstacleField.State.DEPLETED)
	assert_eq(field.complete_wave(), {})


func test_odd_reserve_ends_with_the_remainder() -> void:
	var field: ObstacleField = _field(2, 5)
	field.enable_site(MINE)
	var total: int = 0
	for i: int in 5:
		total += field.complete_wave().get(MINE, 0)
	assert_eq(total, 5)


func test_cannot_enable_twice_or_when_depleted_or_a_removable() -> void:
	var field: ObstacleField = _field(2, 2)
	assert_eq(field.can_enable(MINE), &"")
	assert_true(field.enable_site(MINE))
	assert_eq(field.can_enable(MINE), &"active")
	assert_false(field.enable_site(MINE))
	field.complete_wave()
	assert_eq(field.can_enable(MINE), &"depleted")
	assert_eq(field.can_enable(ROCK), &"not_extraction")
	assert_false(field.enable_site(ROCK))


func test_reserve_zero_is_born_depleted() -> void:
	var field: ObstacleField = _field(2, 0)
	field.enable_site(MINE)
	assert_eq(field.state_of(MINE), ObstacleField.State.DEPLETED)
	assert_eq(field.complete_wave(), {})


func test_setup_restores_the_reserve() -> void:
	var field: ObstacleField = _field()
	field.enable_site(MINE)
	field.complete_wave()
	var specs: Array[ObstacleSpec] = [_site(MINE)]
	field.setup(specs, RandomNumberGenerator.new())
	assert_eq(field.state_of(MINE), ObstacleField.State.DISABLED)
	assert_eq(field.reserve_left(MINE), 8)


func test_many_sites_are_independent() -> void:
	var field := ObstacleField.new()
	var specs: Array[ObstacleSpec] = [_site(MINE, 2, 8), _site(Vector2i(5, 7), 1, 3)]
	field.setup(specs, RandomNumberGenerator.new())
	field.enable_site(MINE)
	field.enable_site(Vector2i(5, 7))
	assert_eq(field.complete_wave(), {Vector2i(5, 7): 1, MINE: 2})
	assert_eq(field.reserve_left(Vector2i(5, 7)), 2)


# --- En la partida ---

func test_site_can_be_selected_in_all_states() -> void:
	_start_game()
	assert_not_null(game.infrastructure.obstacle_at(MINE))
	game.infrastructure.select(MINE)
	assert_eq(game.infrastructure.selected_cell(), MINE)
	assert_true(game.infrastructure.enable(MINE))
	assert_not_null(game.infrastructure.obstacle_at(MINE), "activa también se elige")


func test_enable_charges_gold_immediately() -> void:
	_start_game(150)
	assert_true(game.infrastructure.enable(MINE))
	assert_eq(game.session.gold, 50)
	assert_eq(game.infrastructure.field.state_of(MINE), ObstacleField.State.ACTIVE)
	assert_false(game.infrastructure.enable(MINE), "no se cobra dos veces")
	assert_eq(game.session.gold, 50)


func test_enable_without_gold_changes_nothing() -> void:
	_start_game(99)
	assert_false(game.infrastructure.enable(MINE))
	assert_eq(game.session.gold, 99)
	assert_eq(game.infrastructure.field.state_of(MINE), ObstacleField.State.DISABLED)


func test_playable_example_gives_2_2_2_2_and_depletes() -> void:
	_start_game(100, 6)
	game.infrastructure.enable(MINE)
	var seen: Array[int] = []
	for i: int in 4:
		var before: int = game.session.resources
		_complete_wave()
		seen.append(game.session.resources - before)
	assert_eq(seen, [2, 2, 2, 2] as Array[int])
	assert_eq(game.infrastructure.field.state_of(MINE), ObstacleField.State.DEPLETED)
	var total: int = game.session.resources
	_complete_wave()
	assert_eq(game.session.resources, total, "agotada no entrega")


func test_no_production_when_not_enabled_or_by_waiting() -> void:
	_start_game()
	_complete_wave()
	assert_eq(game.session.resources, 0)
	game.infrastructure.enable(MINE)
	game.infrastructure._process(30.0)
	assert_eq(game.session.resources, 0, "esperar no produce")


func test_jumping_to_a_wave_does_not_produce() -> void:
	_start_game()
	game.infrastructure.enable(MINE)
	game.session.jump_to_wave(4)
	assert_eq(game.session.resources, 0)
	assert_eq(game.infrastructure.field.reserve_left(MINE), 8)


func test_enabled_during_the_wave_counts_that_wave() -> void:
	_start_game()
	game.session.state = LevelSession.State.WAVE_RUNNING
	game.infrastructure.enable(MINE)
	game.session.complete_wave()
	assert_eq(game.session.resources, 2)


func test_floating_text_is_shown_on_production() -> void:
	_start_game()
	game.infrastructure.enable(MINE)
	var before: int = game.effects.get_child_count()
	_complete_wave()
	assert_gt(game.effects.get_child_count(), before)


func test_panel_shows_each_state() -> void:
	_start_game(100)
	var panel: ObstaclePanel = game.hud.obstacle_panel
	game.infrastructure.select(MINE)
	assert_true(panel.visible)
	assert_eq(panel._button.text, "Habilitar extracción (100 de oro)")
	assert_false(panel._button.disabled)
	assert_eq(panel._cost.text, "Produce 2 recursos por oleada")
	assert_eq(panel._time.text, "Reserva 8/8")
	panel._button.pressed.emit()
	assert_eq(game.infrastructure.field.state_of(MINE), ObstacleField.State.ACTIVE)
	assert_false(panel._button.visible, "activa: no hay nada más que pagar")
	_complete_wave()
	assert_eq(panel._time.text, "Reserva 6/8")
	for i: int in 3:
		_complete_wave()
	assert_true(panel._title.text.contains("Agotada"))
	assert_eq(panel._time.text, "Reserva 0/8")


func test_panel_disables_the_button_without_gold() -> void:
	_start_game(40)
	game.infrastructure.select(MINE)
	var panel: ObstaclePanel = game.hud.obstacle_panel
	assert_true(panel._button.disabled)
	assert_eq(panel._button.text, "Te faltan 60 de oro")


func test_removable_panel_shows_the_button_again_after_a_site() -> void:
	_start_game()
	var panel: ObstaclePanel = game.hud.obstacle_panel
	game.infrastructure.select(MINE)
	game.infrastructure.enable(MINE)
	assert_false(panel._button.visible)
	panel.show_obstacle(null, ObstacleField.State.INTACT, false, 0, 0.0, false)
	assert_false(panel.visible)
