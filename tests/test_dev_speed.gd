# Tests de las cinco velocidades del modo de pruebas (T151, spec RF-322, RF-324).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DEV_PATH: String = "user://test_save_pruebas.json"

var game: Game


func before_each() -> void:
	Engine.time_scale = 1.0
	DevMode.set_enabled(true, DEV_PATH)
	DevMode.show_speed(1.0)
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	Engine.time_scale = 1.0
	DevMode.show_speed(1.0)
	DevMode.clear_stats_file()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	if FileAccess.file_exists(DEV_PATH):
		DirAccess.remove_absolute(DEV_PATH)


func _banner_text() -> String:
	return DevMode._banner_label.text


# --- Cómo se escribe ---

func test_speed_text() -> void:
	assert_eq(Rules.speed_text(1.0), "x1")
	assert_eq(Rules.speed_text(2.0), "x2")
	assert_eq(Rules.speed_text(4.0), "x4")
	assert_eq(Rules.speed_text(0.5), "x0,5", "RF-322: con coma")
	assert_eq(Rules.speed_text(0.25), "x0,25")


func test_the_hud_button_does_not_round_to_x0() -> void:
	game.dev_set_speed(0.5)
	assert_eq(game.hud._speed_button.text, "x0,5  [F]", "RF-322: antes decía x0")
	game.dev_set_speed(0.25)
	assert_eq(game.hud._speed_button.text, "x0,25  [F]")
	game.dev_set_speed(2.0)
	assert_eq(game.hud._speed_button.text, "x2  [F]", "el juego normal se lee igual que siempre")


# --- Los botones del panel ---

func test_there_is_one_button_per_configured_speed() -> void:
	var buttons: Array[Button] = game.dev_panel.speed_buttons()
	assert_eq(buttons.size(), DevMode.config.speeds.size())
	assert_eq(buttons.size(), 5, "x0,25 · x0,5 · x1 · x2 · x4")
	for i: int in buttons.size():
		assert_eq(buttons[i].text, Rules.speed_text(DevMode.config.speeds[i]))


func test_each_button_sets_the_time_scale() -> void:
	var buttons: Array[Button] = game.dev_panel.speed_buttons()
	for i: int in buttons.size():
		buttons[i].pressed.emit()
		assert_eq(Engine.time_scale, DevMode.config.speeds[i], buttons[i].text)


func test_only_the_current_speed_is_marked() -> void:
	var buttons: Array[Button] = game.dev_panel.speed_buttons()
	assert_true(buttons[2].button_pressed, "empieza en x1")
	game.dev_set_speed(0.5)
	for i: int in buttons.size():
		assert_eq(buttons[i].button_pressed, i == 1, buttons[i].text)
	buttons[1].pressed.emit()  # un clic en el activo no lo apaga
	assert_true(buttons[1].button_pressed)


func test_the_mark_follows_the_f_key_too() -> void:
	game.toggle_speed()
	assert_true(game.dev_panel.speed_buttons()[3].button_pressed, "x2")
	assert_false(game.dev_panel.speed_buttons()[2].button_pressed)


# --- El cartel ---

func test_the_banner_says_the_speed() -> void:
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel", "con x1 queda como siempre")
	game.dev_set_speed(0.5)
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel · x0,5", "RF-322")
	game.dev_set_speed(4.0)
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel · x4")
	game.dev_set_speed(1.0)
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel")


func test_the_banner_fits_its_text() -> void:
	game.dev_set_speed(0.25)
	var label: Label = DevMode._banner_label
	var font: Font = label.get_theme_font("font")
	var width: float = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	assert_lt(width, label.size.x, "el texto más largo entra en el cartel")
	assert_almost_eq(label.position.x + label.size.x / 2.0, 640.0, 0.5, "y sigue centrado")


# --- Vuelta a x1 ---

func test_leaving_the_game_goes_back_to_x1() -> void:
	game.dev_set_speed(0.25)
	remove_child_and_free(game)
	assert_eq(Engine.time_scale, 1.0, "RF-105 y RF-322")
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel", "el cartel también")


func remove_child_and_free(node: Node) -> void:
	node.get_parent().remove_child(node)  # eso ya ejecuta _exit_tree, como al salir de la partida
	node.free()


func test_finishing_the_game_goes_back_to_x1() -> void:
	game.dev_set_speed(4.0)
	game.dev_finish(false)
	assert_eq(Engine.time_scale, 1.0)
	assert_eq(_banner_text(), "MODO PRUEBAS · F1: panel")
	assert_true(game.dev_panel.speed_buttons()[2].button_pressed)


# --- La tecla F ---

func test_f_alternates_x1_and_x2() -> void:
	game.toggle_speed()
	assert_eq(Engine.time_scale, 2.0, "RF-105")
	game.toggle_speed()
	assert_eq(Engine.time_scale, 1.0)


func test_f_from_another_speed_goes_back_to_x1() -> void:
	for speed: float in [0.25, 0.5, 4.0]:
		game.dev_set_speed(speed)
		game.toggle_speed()
		assert_eq(Engine.time_scale, 1.0, "desde %s" % Rules.speed_text(speed))


func test_f_in_the_normal_game_is_the_same_as_always() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	var normal: Game = GAME_SCENE.instantiate()
	add_child_autofree(normal)
	assert_null(normal.dev_panel)
	normal.toggle_speed()
	assert_eq(Engine.time_scale, 2.0)
	assert_eq(normal.hud._speed_button.text, "x2  [F]")
	normal.toggle_speed()
	assert_eq(Engine.time_scale, 1.0)
