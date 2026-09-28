# Tests con la partida completa: construir torres (T18), ganar oro matando (T19)
# y pantallas de victoria y derrota (T24).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var game: Game
var basic: TowerData
var cannon: TowerData


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	basic = game.tower_types[0]
	cannon = game.tower_types[1]


func _tower_button(index: int) -> Button:
	return (game.hud.get_node("%TowerButtons") as HBoxContainer).get_child(index)


func _end_screen_text(unique_name: String) -> String:
	return (game.end_screen.get_node("%" + unique_name) as Label).text


# --- Construir (RF-42, RF-43, RF-23, RF-101) ---

func test_build_on_free_cell() -> void:
	assert_true(game.build_controller.try_build(basic, Vector2i(0, 0)))
	assert_eq(game.session.gold, 100, "150 − 50")
	assert_eq(game.tower_container.get_child_count(), 1)
	var tower: Tower = game.build_controller.tower_at(Vector2i(0, 0))
	assert_eq(tower.global_position, game.level.cell_center(Vector2i(0, 0)), "en el centro de la casilla")


func test_cannot_build_on_the_path() -> void:
	game.session.spend(90)  # quedan 60, como en el criterio de aceptación de RF-42
	assert_false(game.build_controller.try_build(basic, Vector2i(0, 1)))
	assert_eq(game.session.gold, 60, "no se cobra nada")


func test_cannot_build_on_rocks_or_outside() -> void:
	assert_false(game.build_controller.try_build(basic, Vector2i(6, 2)), "roca")
	assert_false(game.build_controller.try_build(basic, Vector2i(25, 3)), "fuera del mapa")


func test_cannot_build_twice_on_the_same_cell() -> void:
	game.build_controller.try_build(basic, Vector2i(0, 0))
	assert_false(game.build_controller.try_build(basic, Vector2i(0, 0)))
	assert_eq(game.session.gold, 100)


func test_cannot_build_without_gold() -> void:
	game.build_controller.try_build(cannon, Vector2i(0, 0))
	assert_false(game.build_controller.try_build(cannon, Vector2i(1, 0)), "quedan 50, cuesta 100")


func test_tower_buttons_turn_grey_without_gold() -> void:
	assert_false(_tower_button(1).disabled, "150 alcanza para el Cañón")
	game.build_controller.try_build(basic, Vector2i(0, 0))
	game.build_controller.try_build(basic, Vector2i(1, 0))
	assert_true(_tower_button(1).disabled, "RF-101: 50 no alcanza para el Cañón (100)")
	assert_false(_tower_button(0).disabled, "50 alcanza para la Ametralladora")


func test_selecting_a_tower_marks_its_button() -> void:
	game.build_controller.select(2)
	assert_true(_tower_button(2).button_pressed)
	assert_eq(game.build_controller.selected_tower(), game.tower_types[2])
	game.build_controller.cancel()
	assert_false(_tower_button(2).button_pressed)
	assert_null(game.build_controller.selected_tower())


# --- Matar da oro (RF-21) ---

func test_killing_enemies_gives_gold() -> void:
	game.build_controller.try_build(basic, Vector2i(4, 2))
	game.build_controller.try_build(basic, Vector2i(8, 2))
	game.start_next_wave()
	simulate(game, 60 * 45, DT)
	await wait_process_frames(2)
	assert_eq(game.session.lives, 20, "dos Ametralladoras bastan para la oleada 1")
	# 150 − 100 de torres + 8 × 5 por matar + 25 de bono.
	assert_eq(game.session.gold, 115)


# --- Fin de partida (RF-90, RF-91) ---

func test_end_screen_hidden_at_start() -> void:
	assert_false(game.end_screen.visible)


func test_defeat_shows_end_screen_and_freezes_the_world() -> void:
	game.start_next_wave()
	game.session.lose_lives(20)
	assert_true(game.end_screen.visible)
	assert_eq(_end_screen_text("Title"), "Derrota")
	assert_eq(_end_screen_text("Detail"), "Llegaste a la oleada 1 de 10")
	assert_eq(game.enemies.process_mode, Node.PROCESS_MODE_DISABLED, "RF-91: el juego se detiene")
	assert_false(game.build_controller.try_build(basic, Vector2i(0, 0)), "no se construye tras perder")


func test_victory_shows_end_screen() -> void:
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()
	assert_true(game.end_screen.visible)
	assert_eq(_end_screen_text("Title"), "¡Victoria!")
	assert_eq(_end_screen_text("Detail"), "Vidas restantes: 20")
