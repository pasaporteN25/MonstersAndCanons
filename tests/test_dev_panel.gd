# Tests del panel de pruebas (T87, spec RF-184).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DEV_PATH: String = "user://test_save_pruebas.json"
const REAL_PATH: String = "user://test_save_real.json"
const DT: float = 1.0 / 60.0

var game: Game


func _new_game() -> Game:
	var g: Game = GAME_SCENE.instantiate()
	add_child_autofree(g)
	return g


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	game = _new_game()


func after_each() -> void:
	GameFlow.test_level = null
	GameFlow.forced_seed = -1
	DevMode.clear_stats_file()
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	for path: String in [DEV_PATH, REAL_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _active_enemies() -> int:
	var count: int = 0
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			count += 1
	return count


func test_without_dev_mode_there_is_no_panel() -> void:
	DevMode.set_enabled(false, SaveManager.DEFAULT_PATH)
	var normal: Game = _new_game()
	assert_null(normal.dev_panel, "RF-180: el juego normal no lo tiene")


func test_dev_mode_game_has_the_panel_closed() -> void:
	assert_not_null(game.dev_panel)
	assert_false(game.dev_panel.visible, "empieza cerrado")
	var button_texts: Array[String] = []
	for node: Node in game.dev_panel.find_children("*", "Button", true, false):
		button_texts.append((node as Button).text)
	assert_true(button_texts.has("+10 recursos"), "RF-436: el panel ofrece recursos")
	assert_true(button_texts.has("Terminar demolición"), "RF-436: el panel termina la demolición")
	var toggles: Array[String] = []
	for node: Node in game.dev_panel.find_children("*", "CheckButton", true, false):
		toggles.append((node as CheckButton).text)
	assert_true(toggles.has("Habilitar todas las colecciones"), "RF-436: el panel habilita las colecciones")
	game.dev_panel.toggle()
	assert_true(game.dev_panel.visible, "F1 o el botón lo abren")


func test_add_gold() -> void:
	var before: int = game.session.gold
	game.dev_add_gold()
	assert_eq(game.session.gold, before + DevMode.config.gold_step)


func test_add_ten_resources_shows_the_counter_without_map_sources() -> void:
	assert_false(game.level_data.uses_resources())
	assert_false(game.hud.get_node("TopBar/Stats/ResourceStat").visible)
	game.dev_add_resources()
	assert_eq(game.session.resources, 10)
	assert_true(game.hud.get_node("TopBar/Stats/ResourceStat").visible, "RF-436: el contador aparece aunque el mapa no tenga fuentes")
	assert_eq(game.hud.get_node("TopBar/Stats/ResourceStat/ResourceLabel").text, "10")


func test_finish_demolition_finishes_the_current_job_and_grants_its_reward() -> void:
	game.free()
	var data := {"version": 1, "nombre": "Prueba", "oro": 100, "vidas": 10,
		"mapa": ["....................", "....................", "....................", "...........r........",
			"A##################S", "....................", "....................", "....................", "...................."],
		"leyenda": {"r": {"removible": {"clase": "roca", "probabilidad": 100, "costo": 10, "tiempo": 1.0}}},
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	var parsed: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(parsed["errors"], PackedStringArray())
	GameFlow.test_level = parsed["level"]
	game = _new_game()
	assert_true(game.infrastructure.order(Vector2i(11, 3)))
	game.dev_finish_demolition()
	assert_false(game.infrastructure.field.has_job())
	assert_eq(game.infrastructure.field.state_of(Vector2i(11, 3)), ObstacleField.State.CLEARED)
	assert_eq(game.session.resources, 1, "la recompensa normal entra al terminar al instante")


func test_all_collections_toggle_unlocks_collection_towers_without_collecting_pieces() -> void:
	var tower: TowerData = load("res://data/towers/cannon.tres").duplicate()
	tower.id = &"dev_collection_test"
	tower.required_collection = &"disruptor"
	tower.reserved = true
	game.tower_types.append(tower)
	game._refresh_dev_towers()
	assert_false(game.available_towers.has(tower))
	var collected_before: PackedStringArray = SaveManager.collected_sources(&"disruptor")
	game.dev_enable_collections(true)
	assert_true(game.available_towers.has(tower), "RF-436: la torre aparece aunque el nivel no la ofrezca")
	assert_eq(SaveManager.collected_sources(&"disruptor"), collected_before, "no guarda piezas ni progreso")
	game.dev_enable_collections(false)
	assert_false(game.available_towers.has(tower))
	await wait_process_frames(2)


func test_dev_actions_do_not_write_the_normal_save() -> void:
	SaveManager.save_path = REAL_PATH
	SaveManager.load_save()
	SaveManager.record_victory(&"level_01", 20)
	assert_true(SaveManager.save())
	var normal_save_before: String = FileAccess.get_file_as_string(REAL_PATH)
	DevMode.set_enabled(true, DEV_PATH)
	game.dev_add_resources()
	game.dev_enable_collections(true)
	assert_eq(FileAccess.get_file_as_string(REAL_PATH), normal_save_before, "RF-181 y RF-436: las acciones no escriben el guardado normal")
	await wait_process_frames(2)


func test_infinite_lives() -> void:
	game.dev_set_infinite_lives(true)
	game.session.lose_lives(10)
	assert_eq(game.session.lives, 20, "no se pierden vidas")
	game.dev_set_infinite_lives(false)
	game.session.lose_lives(10)
	assert_eq(game.session.lives, 10)


func test_kill_all_gives_no_gold() -> void:
	game.dev_spawn(load("res://data/enemies/normal.tres"))
	game.dev_spawn(load("res://data/enemies/spider.tres"))
	var gold: int = game.session.gold
	game.dev_kill_all()
	assert_eq(_active_enemies(), 0)
	assert_eq(game.session.gold, gold, "matar con el panel no da oro")
	await wait_process_frames(2)
	assert_eq(game.enemies.get_child_count(), 0, "la Araña no soltó crías")


func test_skip_wave_completes_it() -> void:
	game.start_next_wave()
	simulate(game.spawner, 30, DT)  # ya salieron algunos
	game.dev_skip_wave()
	await wait_process_frames(2)
	assert_eq(game.session.wave, 1)
	assert_ne(game.session.state, LevelSession.State.WAVE_RUNNING, "la oleada 1 terminó")
	game.dev_skip_wave()  # sin oleada en curso: empieza la 2 y la termina
	await wait_process_frames(2)
	assert_eq(game.session.wave, 2)
	assert_ne(game.session.state, LevelSession.State.WAVE_RUNNING)


func test_win_and_lose() -> void:
	game.dev_finish(true)
	assert_eq(game.session.state, LevelSession.State.WON)
	var other: Game = _new_game()
	other.dev_finish(false)
	assert_eq(other.session.state, LevelSession.State.LOST)


func test_spawn_any_enemy() -> void:
	game.dev_spawn(load("res://data/enemies/troll.tres"))
	assert_eq(_active_enemies(), 1)
	assert_eq((game.enemies.get_child(0) as Enemy).data.id, &"troll")

func test_metrics_stay_visible_when_panel_closes_and_can_be_disabled() -> void:
	game.dev_panel.show()
	game.dev_panel.metrics_toggled.emit(true)
	game.hud._process(0.0)
	var overlay: Label = game.hud.get_node("PerformanceOverlay")
	game.dev_panel.hide()
	assert_true(overlay.is_visible_in_tree())
	assert_true(overlay.text.contains("FPS"))
	assert_true(overlay.text.contains("ms/cuadro"))
	assert_eq(overlay.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	game.dev_panel.metrics_toggled.emit(false)
	assert_false(overlay.visible)

func _wheel(button: MouseButton, pressed: bool = true) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	return event

func test_enemy_wheel_selects_without_opening_or_spawning_and_clamps_ends() -> void:
	var panel: DevPanel = game.dev_panel
	var choice: OptionButton = panel._enemy_choice
	choice.select(0)
	panel._on_enemy_choice_input(_wheel(MOUSE_BUTTON_WHEEL_UP))
	assert_eq(choice.selected,0)
	panel._on_enemy_choice_input(_wheel(MOUSE_BUTTON_WHEEL_DOWN))
	assert_eq(choice.selected,1)
	assert_false(choice.get_popup().visible)
	assert_eq(_active_enemies(),0)
	choice.select(choice.item_count - 1)
	panel._on_enemy_choice_input(_wheel(MOUSE_BUTTON_WHEEL_DOWN))
	assert_eq(choice.selected,choice.item_count - 1)
	panel._on_enemy_choice_input(_wheel(MOUSE_BUTTON_WHEEL_UP))
	assert_eq(choice.selected,choice.item_count - 2)

func test_click_release_and_horizontal_wheel_are_not_selection_steps() -> void:
	var panel: DevPanel = game.dev_panel
	panel._enemy_choice.select(3)
	for event: InputEvent in [_wheel(MOUSE_BUTTON_LEFT),_wheel(MOUSE_BUTTON_WHEEL_DOWN,false),_wheel(MOUSE_BUTTON_WHEEL_LEFT),InputEventMouseMotion.new()]:
		panel._on_enemy_choice_input(event)
	assert_eq(panel._enemy_choice.selected,3)

func test_spawn_button_uses_enemy_chosen_with_wheel() -> void:
	var panel: DevPanel = game.dev_panel
	panel._enemy_choice.select(0)
	panel._on_enemy_choice_input(_wheel(MOUSE_BUTTON_WHEEL_DOWN))
	var spawn: Button = null
	for button: Node in panel.find_children("*","Button",true,false):
		if (button as Button).text == "Aparecer":
			spawn = button as Button
	assert_not_null(spawn)
	spawn.pressed.emit()
	assert_eq(_active_enemies(),1)
	assert_eq((game.enemies.get_child(0) as Enemy).data,panel._enemy_types[1])

func test_enemy_popup_is_bounded_opaque_and_hover_has_no_clipped_shadow() -> void:
	var popup: PopupMenu = game.dev_panel._enemy_choice.get_popup()
	assert_eq(popup.max_size.y,320)
	assert_eq((popup.get_theme_stylebox("panel") as StyleBoxFlat).bg_color.a,1.0)
	assert_eq((popup.get_theme_stylebox("hover") as StyleBoxFlat).shadow_size,0)

func test_enemy_popup_real_height_and_last_item_remain_accessible() -> void:
	game.dev_panel.show()
	await wait_process_frames(2)
	var choice: OptionButton = game.dev_panel._enemy_choice
	choice.show_popup()
	await wait_process_frames(2)
	var popup: PopupMenu = choice.get_popup()
	assert_true(popup.visible)
	assert_lte(popup.size.y,320,"limita altura real, no solo la propiedad")
	var last: int = choice.item_count - 1
	popup.set_focused_item(last)
	popup.scroll_to_item(last)
	assert_eq(popup.get_focused_item(),last)
	popup.index_pressed.emit(last)
	assert_eq(choice.selected,last,"el clic conserva selección del último enemigo")
	popup.hide()
	choice.gui_input.emit(_wheel(MOUSE_BUTTON_WHEEL_UP))
	assert_eq(choice.selected,last - 1,"la señal del control conecta la rueda")
