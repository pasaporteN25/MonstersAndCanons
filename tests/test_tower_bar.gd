# Tests de la barra de torres para 9 torres (T77 y T140, spec RF-170, RF-171, RF-297, RF-40).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")

var game: Game


## Una partida con `count` torres (repite las que haya si hacen falta más).
func _game_with_towers(count: int) -> Game:
	var g: Game = GAME_SCENE.instantiate()
	var level: LevelData = GameFlow.level(0).duplicate()
	level.extra_towers = PackedStringArray(["mortar"])  # RF-300
	g.level_data = level
	var base: Array[TowerData] = g.tower_types.duplicate()
	var towers: Array[TowerData] = []
	for i: int in count:
		towers.append(base[i % base.size()])
	g.tower_types = towers
	add_child_autofree(g)
	return g


func _press_key(physical_key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = physical_key
	event.pressed = true
	game.build_controller._unhandled_input(event)


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func test_button_shows_cost_and_name_on_hover() -> void:
	var button: Button = game.hud._tower_buttons[1]
	assert_eq(button.text, "100", "RF-170: el costo del Cañón")
	assert_string_contains(button.tooltip_text, "Cañón")
	assert_string_contains(button.tooltip_text, "tecla 2")


func test_nine_towers_fit_without_covering_next_wave() -> void:
	game = _game_with_towers(9)
	await wait_process_frames(2)  # deja que la fila acomode los botones
	var next_wave: Control = game.hud.get_node("%NextWave")
	var buttons: Array[Button] = game.hud._tower_buttons
	assert_eq(buttons.size(), 9)
	for i: int in buttons.size():
		var rect: Rect2 = buttons[i].get_global_rect()
		assert_lte(rect.end.x, next_wave.get_global_rect().position.x, "botón %d: no tapa Próxima oleada" % (i + 1))
		if i > 0:
			assert_gt(rect.position.x, buttons[i - 1].get_global_rect().end.x - 0.5, "no se enciman")


func test_keys_1_to_9_choose_each_tower() -> void:
	game = _game_with_towers(9)
	var keys: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]
	for i: int in keys.size():
		game.build_controller.cancel()
		_press_key(keys[i])
		assert_eq(game.build_controller._selected, i, "tecla %d" % (i + 1))


func test_choosing_a_tower_shows_its_name_and_phrase() -> void:
	var info: Control = game.hud.get_node("%BuildInfo")
	assert_false(info.visible, "sin torre elegida no se ve")
	game.build_controller.select(1)
	assert_true(info.visible, "RF-171")
	assert_eq((game.hud.get_node("%BuildInfoName") as Label).text, "Cañón · 100 de oro")
	assert_eq((game.hud.get_node("%BuildInfoText") as Label).text, game.tower_types[1].description)
	game.build_controller.cancel()
	assert_false(info.visible, "al cancelar se esconde")


func test_every_tower_has_a_phrase() -> void:
	for tower: TowerData in game.tower_types:
		assert_ne(tower.description, "", "%s: RF-171" % tower.id)
