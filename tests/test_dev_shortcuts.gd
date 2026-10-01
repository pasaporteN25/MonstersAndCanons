# Tests de los atajos de teclado del modo de pruebas (T152, spec RF-323).
# El test del choque de teclas recorre el InputMap de verdad: si mañana alguien agrega una acción
# del juego con F2 (o un atajo con una tecla que ya usa el juego), este test falla.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DEV_PATH: String = "user://test_save_pruebas.json"
const DT: float = 1.0 / 60.0
## F1 abre el panel (RF-184) y no es una acción del InputMap: se reserva a mano.
const RESERVED_KEYS: Array[Key] = [KEY_F1]

var game: Game


func before_each() -> void:
	Engine.time_scale = 1.0
	DevMode.set_enabled(true, DEV_PATH)
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	Engine.time_scale = 1.0
	DevMode.show_speed(1.0)
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	if FileAccess.file_exists(DEV_PATH):
		DirAccess.remove_absolute(DEV_PATH)


func _press(key: Key, target: Game = null) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	(target if target != null else game)._unhandled_input(event)


func _action_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for shortcut: Dictionary in DevMode.ACTIONS:
		names.append(shortcut["action"])
	return names


func _keys_of(action: StringName) -> Array[Key]:
	var keys: Array[Key] = []
	for event: InputEvent in InputMap.action_get_events(action):
		var key_event := event as InputEventKey
		if key_event != null:
			keys.append(key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode)
	return keys


func _active_enemies() -> int:
	var count: int = 0
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			count += 1
	return count


# --- Que no choquen ---

func test_every_shortcut_has_exactly_one_f_key() -> void:
	for action: StringName in _action_names():
		assert_true(InputMap.has_action(action), "existe %s" % action)
		var keys: Array[Key] = _keys_of(action)
		assert_eq(keys.size(), 1, "%s tiene una sola tecla" % action)
		assert_true(keys[0] >= KEY_F1 and keys[0] <= KEY_F12, "%s es una tecla de función" % action)


func test_no_shortcut_key_is_used_by_another_action() -> void:
	# Se comparan los atajos contra TODAS las demás acciones (las del juego y las ui_* de Godot). Las
	# ui_* se repiten entre sí a propósito (Enter, Tab…): eso no es asunto de este test.
	var checked: int = 0
	for shortcut: StringName in _action_names():
		for other: StringName in InputMap.get_actions():
			if other == shortcut:
				continue
			checked += 1
			for key: Key in _keys_of(shortcut):
				assert_false(_keys_of(other).has(key), "la tecla %s de %s la usa también %s" % [OS.get_keycode_string(key), shortcut, other])
	assert_gt(checked, 50, "el recorrido vio las acciones del juego y las de Godot (si no, el test no prueba nada)")
	assert_true(InputMap.has_action(&"build_1") and InputMap.has_action(&"start_wave"), "y las del juego están")


func test_no_shortcut_key_is_a_digit_or_reserved() -> void:
	var shortcut_keys: Array[Key] = []
	for action: StringName in _action_names():
		shortcut_keys.append_array(_keys_of(action))
	for digit: int in range(KEY_1, KEY_9 + 1):
		assert_false(shortcut_keys.has(digit), "1 a 9 construyen torres")
	for reserved: Key in RESERVED_KEYS:
		assert_false(shortcut_keys.has(reserved), "F1 abre el panel")
	var unique: Dictionary = {}
	for key: Key in shortcut_keys:
		unique[key] = true
	assert_eq(unique.size(), shortcut_keys.size(), "ningún atajo repite la tecla de otro")


func test_the_game_keys_are_still_where_they_were() -> void:
	# Si este test falla, cambiaron las teclas del juego y hay que revisar RF-323 y la tabla de la spec 9.2.
	var expected: Dictionary = {&"cancel": KEY_ESCAPE, &"start_wave": KEY_SPACE, &"pause": KEY_P,
		&"toggle_speed": KEY_F, &"upgrade": KEY_U, &"sell": KEY_S}
	for action: StringName in expected:
		assert_eq(_keys_of(action), [expected[action]], str(action))
	for i: int in 9:
		assert_eq(_keys_of(StringName("build_%d" % (i + 1))), [KEY_1 + i], "build_%d" % (i + 1))


func test_the_normal_game_does_not_have_the_actions() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	for action: StringName in _action_names():
		assert_false(InputMap.has_action(action), "RF-323: %s solo existe en el modo de pruebas" % action)
	DevMode.set_enabled(true, DEV_PATH)
	for action: StringName in _action_names():
		assert_true(InputMap.has_action(action))
	DevMode.register_actions()  # llamarlo dos veces no duplica la tecla
	for action: StringName in _action_names():
		assert_eq(_keys_of(action).size(), 1)


# --- Qué hace cada uno ---

func test_f2_kills_everyone_like_the_button() -> void:
	game.dev_spawn(load("res://data/enemies/normal.tres"))
	game.dev_spawn(load("res://data/enemies/spider.tres"))
	var gold: int = game.session.gold
	_press(KEY_F2)
	assert_eq(_active_enemies(), 0)
	assert_eq(game.session.gold, gold, "no da oro, igual que el botón")


func test_f3_skips_the_wave_like_the_button() -> void:
	game.start_next_wave()
	simulate(game.spawner, 30, DT)
	_press(KEY_F3)
	await wait_process_frames(2)
	assert_eq(game.session.wave, 1)
	assert_ne(game.session.state, LevelSession.State.WAVE_RUNNING)


func test_f4_toggles_infinite_lives_and_the_panel_follows() -> void:
	_press(KEY_F4)
	assert_true(game.session.infinite_lives)
	assert_true(game.dev_panel._lives_toggle.button_pressed, "el interruptor del panel lo muestra")
	game.session.lose_lives(5)
	assert_eq(game.session.lives, game.level_data.starting_lives)
	_press(KEY_F4)
	assert_false(game.session.infinite_lives)
	assert_false(game.dev_panel._lives_toggle.button_pressed)


func test_f6_and_f7_step_through_the_speeds() -> void:
	_press(KEY_F7)
	assert_eq(Engine.time_scale, 2.0)
	_press(KEY_F7)
	assert_eq(Engine.time_scale, 4.0)
	_press(KEY_F6)
	assert_eq(Engine.time_scale, 2.0)
	_press(KEY_F6)
	_press(KEY_F6)
	assert_eq(Engine.time_scale, 0.5)
	assert_true(DevMode.banner_text().ends_with("x0,5"), "y el cartel lo dice")


func test_the_speed_shortcuts_stop_at_the_ends() -> void:
	game.dev_set_speed(4.0)
	_press(KEY_F7)
	assert_eq(Engine.time_scale, 4.0, "en x4 no sube más")
	game.dev_set_speed(0.25)
	_press(KEY_F6)
	assert_eq(Engine.time_scale, 0.25, "en x0,25 no baja más")


func test_shortcuts_work_with_the_panel_closed() -> void:
	assert_false(game.dev_panel.visible)
	_press(KEY_F7)
	assert_eq(Engine.time_scale, 2.0)


func test_shortcuts_do_nothing_with_the_pause_menu_open() -> void:
	game.dev_spawn(load("res://data/enemies/normal.tres"))
	game.open_pause_menu()
	_press(KEY_F2)
	_press(KEY_F7)
	_press(KEY_F4)
	assert_eq(_active_enemies(), 1, "RF-323: con el menú de pausa abierto no actúan")
	assert_eq(Engine.time_scale, 1.0)
	assert_false(game.session.infinite_lives)


func test_a_shortcut_does_not_leak_to_the_normal_game() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	var normal: Game = GAME_SCENE.instantiate()
	add_child_autofree(normal)
	_press(KEY_F7, normal)
	assert_eq(Engine.time_scale, 1.0, "el juego normal ignora F7")


func test_the_panel_writes_each_key() -> void:
	var texts: Array[String] = []
	for node: Node in game.dev_panel.find_children("*", "Button", true, false):
		texts.append((node as Button).text)
	assert_true(texts.has("Matar a todos  [F2]"), str(texts))
	assert_true(texts.has("Saltar oleada  [F3]"))
	assert_true(texts.has("Vidas infinitas  [F4]"))
	var labels: Array[String] = []
	for node: Node in game.dev_panel.find_children("*", "Label", true, false):
		labels.append((node as Label).text)
	assert_true(labels.has("Velocidad  [F6 / F7]"), str(labels))


# --- La cuenta de pasos ---

func test_step_speed() -> void:
	var speeds := PackedFloat32Array([0.25, 0.5, 1.0, 2.0, 4.0])
	assert_eq(DevStart.step_speed(speeds, 1.0, 1), 2.0)
	assert_eq(DevStart.step_speed(speeds, 1.0, -1), 0.5)
	assert_eq(DevStart.step_speed(speeds, 4.0, 1), 4.0)
	assert_eq(DevStart.step_speed(speeds, 0.25, -1), 0.25)
	assert_eq(DevStart.step_speed(speeds, 3.0, 1), 4.0, "una velocidad que no está en la lista parte de la más cercana")
	assert_eq(DevStart.step_speed(PackedFloat32Array(), 1.0, 1), 1.0, "sin lista, no cambia")
