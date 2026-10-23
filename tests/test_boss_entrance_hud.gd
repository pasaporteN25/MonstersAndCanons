# Pruebas de integración de la entrada de los jefes (T368, M66: RF-597 a RF-600 y RF-602) con la escena real de la
# partida: el destello, el cartel de aparición, la cola con el cartel de oleada y la tarjeta «Nuevo enemigo»,
# el salteo, la opción y los niveles. No cambia de escena. No toca el guardado real.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_boss_entrance.json"

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1


func after_each() -> void:
	GameFlow.current_index = -1
	Engine.time_scale = 1.0
	get_tree().paused = false
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _play(level_index: int = 0) -> Game:
	GameFlow.current_index = level_index
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _boss() -> EnemyData:
	return load("res://data/enemies/boss.tres")


func _bursts() -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in game.get_children():
		if child is BossEntranceBurst:
			found.append(child)
	return found


func _intro_visible() -> bool:
	return (game.hud.get_node("%EnemyIntro") as Control).visible


func _spawn_boss() -> Enemy:
	game.spawner.spawn_now(_boss())
	return game.enemies.get_child(game.enemies.get_child_count() - 1) as Enemy


# --- RF-597: qué sale y cuándo ---

func test_the_level_1_boss_makes_its_entrance() -> void:
	_play()
	var boss: Enemy = _spawn_boss()
	assert_eq(_bursts().size(), 1, "el destello sale en el instante en que nace")
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_not_null(card, "sin cartel de oleada en pantalla, el cartel entra enseguida")
	assert_eq(card.title_text(), "¡Llega el Jefe!")
	assert_eq(card.name_text(), "Jefe")
	assert_eq(card.line_text(), _boss().description, "sin frase propia, la descripción del enemigo")
	assert_eq(boss.data, _boss())


func test_the_burst_sits_at_the_start_of_the_path_below_the_enemies() -> void:
	_play()
	_spawn_boss()
	var burst: Node2D = _bursts()[0]
	var path: Path2D = game.level.get_ground_path(0)
	assert_eq(burst.global_position, path.to_global(path.curve.get_point_position(0)))
	assert_lt(burst.get_index(), game.enemies.get_index(), "dibujado antes que los enemigos")


func test_the_burst_tints_with_the_enemy_color_and_goes_away() -> void:
	_play()
	_spawn_boss()
	var burst: BossEntranceBurst = _bursts()[0] as BossEntranceBurst
	await wait_seconds(0.9)
	assert_false(is_instance_valid(burst) and burst.is_inside_tree(), "dura 0,7 s y se borra solo")


func test_the_burst_uses_the_approved_art_tinted_over_an_untinted_crack() -> void:
	_play()
	_spawn_boss()
	var burst: BossEntranceBurst = _bursts()[0] as BossEntranceBurst
	assert_eq(burst.get_child_count(), 2, "la grieta y el destello: dos Sprite2D")
	var crack: Sprite2D = burst.get_child(0) as Sprite2D
	var flash: Sprite2D = burst.get_child(1) as Sprite2D
	assert_eq(crack.texture.get_size(), Vector2(192, 96))
	assert_eq(crack.modulate.r, 1.0, "la grieta no se tiñe")
	assert_eq(flash.texture.get_size(), Vector2(512, 256))
	assert_eq(flash.texture.get_size() * flash.scale / Vector2(4, 2), Vector2(256, 256), "conserva el tamaño visual original")
	assert_eq(flash.modulate, _boss().color, "el destello se tiñe con el color del jefe")
	assert_eq(flash.offset * flash.scale, -Vector2(128, 176), "el punto de los pies queda en el origen del nodo")
	assert_false(burst.is_processing(), "sin _process")


func test_the_burst_frame_and_crack_follow_the_progress() -> void:
	var burst := BossEntranceBurst.new().setup(Color.WHITE, 0.7)
	add_child_autofree(burst)
	var expected: Dictionary = {0.0: 0, 0.2: 1, 0.5: 4, 0.99: 7, 1.0: 7}
	for progress: float in expected:
		burst.progress = progress
		assert_eq(burst.frame(), expected[progress], "progreso %s" % progress)
	burst.progress = 0.0
	assert_almost_eq(burst.crack_alpha(), 1.0, 0.001)
	burst.progress = 1.0
	assert_almost_eq(burst.crack_alpha(), 0.0, 0.001, "la grieta se apaga al final")


func test_the_card_wears_the_approved_frame_without_taking_touches() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_true(card.has_frame())
	var frame: NinePatchRect = card.get_node("Frame") as NinePatchRect
	assert_eq(frame.mouse_filter, Control.MOUSE_FILTER_IGNORE, "el marco no recibe toques")
	assert_eq(frame.get_patch_margin(SIDE_LEFT), 32)
	assert_eq(frame.get_patch_margin(SIDE_BOTTOM), 32)
	assert_eq(frame.texture.get_size(), Vector2(192, 128))
	assert_eq(card.get_child(card.get_child_count() - 1), frame, "va arriba de todo el contenido")
	await wait_seconds(0.4)
	assert_almost_eq(card.size.x, 720.0, 0.05, "el contenido entra sin ensanchar el cartel")
	assert_almost_eq(card.size.y, 120.0, 0.05, "el contenido entra sin agrandar el cartel")


func test_the_card_waits_for_the_wave_banner_and_the_new_enemy_card_waits_for_the_card() -> void:
	_play()
	game.session.begin_wave()  # sale el cartel de «Oleada N» (1,5 s)
	_spawn_boss()
	assert_eq(_bursts().size(), 1, "el destello no espera a nadie")
	assert_null(game.hud.entrance_card(), "el cartel de aparición espera a que se retire el de oleada")
	assert_false(_intro_visible(), "la tarjeta «Nuevo enemigo» espera al cartel de aparición")
	await wait_seconds(1.7)
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_not_null(card, "al retirarse el cartel de oleada entra el de aparición")
	assert_false(_intro_visible(), "y la tarjeta sigue esperando")
	card.dismiss()
	await wait_seconds(0.3)
	assert_null(game.hud.entrance_card())
	assert_true(_intro_visible(), "retirado el cartel, la tarjeta sale con sus 6 s de siempre")


func test_the_card_lasts_one_point_six_seconds() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	await wait_seconds(1.4)
	assert_true(is_instance_valid(card) and card.is_inside_tree(), "a los 1,4 s sigue")
	await wait_seconds(0.4)
	assert_null(game.hud.entrance_card(), "a los 1,8 s ya se fue")


func test_a_second_boss_in_the_same_wave_does_not_repeat_it() -> void:
	_play()
	_spawn_boss()
	game.hud.entrance_card().dismiss()
	await wait_seconds(0.3)
	_spawn_boss()
	assert_eq(_bursts().size(), 1, "una vez por oleada y por tipo")
	assert_null(game.hud.entrance_card())


func test_the_8_second_limit_applies_between_waves() -> void:
	_play()
	_spawn_boss()
	game.hud.entrance_card().dismiss()
	await wait_seconds(0.3)
	game.session.begin_wave()
	_spawn_boss()
	assert_eq(_bursts().size(), 1, "otra oleada, pero hace menos de 8 s")


# --- RF-598: no bloquea ni cambia la partida ---

func test_the_game_is_not_paused_or_slowed_and_the_boss_is_untouched() -> void:
	_play()
	var boss: Enemy = _spawn_boss()
	assert_false(get_tree().paused)
	assert_eq(Engine.time_scale, 1.0)
	assert_eq(boss.data.armor, 3)
	assert_eq(boss.data.lives_damage, 10)
	assert_eq(boss.data.max_health, 300)
	assert_true(boss.is_active())
	var health_with: int = boss.max_health
	game.free()
	SaveManager.set_setting("boss_entrance", false)
	_play()
	assert_eq(_spawn_boss().max_health, health_with, "la misma vida con y sin la entrada")


func test_the_card_is_small_below_the_top_bar_and_only_it_takes_clicks() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_lte(card.size.x, 720.0)
	assert_lte(card.size.y, 120.0)
	assert_eq(card.mouse_filter, Control.MOUSE_FILTER_STOP)
	var inner: Array[Node] = card.find_children("*", "Control", true, false)
	assert_gt(inner.size(), 4)
	for node: Node in inner:
		assert_eq((node as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, "%s no recibe toques" % node.name)
	await wait_seconds(0.4)  # ya entró del todo
	assert_gte(card.get_global_rect().position.y, 48.0, "debajo de la barra de arriba")
	assert_almost_eq(card.get_global_rect().get_center().x, 640.0, 1.0, "centrado")


func test_the_effects_follow_pause_and_speed() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	var burst: BossEntranceBurst = _bursts()[0] as BossEntranceBurst
	assert_true(card.can_process() and burst.can_process())
	get_tree().paused = true
	assert_false(card.can_process(), "en pausa el cartel se congela")
	assert_false(burst.can_process(), "y el destello también")
	get_tree().paused = false


# --- RF-599: saltear ---

func test_a_click_on_the_card_skips_it_in_a_tenth_of_a_second() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	card.gui_input.emit(click)
	assert_true(card.is_dismissed())
	await wait_seconds(0.25)
	assert_null(game.hud.entrance_card())
	assert_gte(game.enemies.get_child_count(), 1, "el jefe sigue caminando")


func test_a_touch_also_skips_it_and_a_release_does_not() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	card.gui_input.emit(release)
	assert_false(card.is_dismissed(), "soltar no saltea")
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	card.gui_input.emit(touch)
	assert_true(card.is_dismissed())


func test_skipping_lets_the_waiting_new_enemy_card_out() -> void:
	_play()
	_spawn_boss()
	assert_false(_intro_visible())
	game.hud.entrance_card().dismiss()
	await wait_seconds(0.25)
	assert_true(_intro_visible())


func test_pc_shows_a_cross_and_click_hint_and_mobile_does_not() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_true(card.has_close_mark())
	assert_eq(card.skip_hint(), "Clic para saltear")


# --- RF-600: la opción ---

func test_option_off_leaves_the_boss_as_before() -> void:
	SaveManager.set_setting("boss_entrance", false)
	_play()
	_spawn_boss()
	assert_eq(_bursts().size(), 0)
	assert_null(game.hud.entrance_card())
	assert_true(_intro_visible(), "la tarjeta «Nuevo enemigo» sale sin esperar a nadie")


func test_an_old_save_reads_the_option_as_on() -> void:
	assert_true(SaveManager.boss_entrance_enabled(), "sin la clave, prendida")
	SaveManager.set_setting("boss_entrance", 0.0)
	assert_true(SaveManager.boss_entrance_enabled(), "un valor que no es booleano, prendida")
	SaveManager.set_setting("boss_entrance", false)
	assert_false(SaveManager.boss_entrance_enabled())


# --- RF-602: dónde sale y dónde no ---

func test_level_2_boss_does_not_make_an_entrance() -> void:
	_play(1)
	_spawn_boss()
	assert_eq(_bursts().size(), 0)
	assert_null(game.hud.entrance_card())


func test_the_loose_scene_does_not_make_an_entrance() -> void:
	_play(-1)
	_spawn_boss()
	assert_eq(_bursts().size(), 0, "F6 y tests: sin partida desde el menú")
	assert_null(game.hud.entrance_card())


func test_an_enemy_without_entrance_makes_none() -> void:
	_play()
	game.spawner.spawn_now(load("res://data/enemies/tank.tres"))
	assert_eq(_bursts().size(), 0)
	assert_null(game.hud.entrance_card())


func test_giving_the_colossus_an_entrance_needs_no_code() -> void:
	_play()
	var colossus: EnemyData = load("res://data/enemies/colossus.tres").duplicate()
	colossus.entrance = BossEntranceData.new()
	game.spawner.spawn_now(colossus)
	assert_eq(_bursts().size(), 1)
	assert_eq(game.hud.entrance_card().name_text(), colossus.display_name)


func test_dev_mode_can_see_it_with_the_panel() -> void:
	DevMode.set_enabled(true, TEST_PATH)
	_play()
	_spawn_boss()  # lo mismo que hace el panel (F1) al hacer aparecer un jefe
	assert_eq(_bursts().size(), 1)
	DevMode.set_enabled(false, TEST_PATH)


# --- Limpieza ---

func test_leaving_mid_entrance_leaves_no_nodes_behind() -> void:
	_play()
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	var burst: Node = _bursts()[0]
	game.free()
	await get_tree().process_frame
	assert_false(is_instance_valid(card))
	assert_false(is_instance_valid(burst))


# --- Móvil ---

func test_mobile_card_is_below_the_bar_and_away_from_the_floating_buttons() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_play()
	await wait_frames(3)
	_spawn_boss()
	var card: BossEntranceCard = game.hud.entrance_card()
	assert_not_null(card)
	assert_false(card.has_close_mark(), "sin «✕» en el celular")
	assert_eq(card.skip_hint(), "Tocá para saltear")
	assert_gte(card.size.y, 56.0, "supera el mínimo táctil")
	await wait_seconds(0.4)
	var rect: Rect2 = card.get_global_rect()
	assert_gte(rect.position.y, 64.0, "debajo de la barra de arriba del celular")
	for button_name: String in ["CartButton", "ExitButton", "DemolishButton", "ViewAllButton"]:
		var button: Control = game.mobile_hud.find_child(button_name, true, false) as Control
		if button != null and button.is_visible_in_tree():
			assert_false(rect.intersects(button.get_global_rect()), "%s no queda tapado" % button_name)
