# Tests del cartel de entrada, del lugar en la tarjeta y del texto de victoria (M52, T228: RF-465 a RF-468).
# Nada acá cambia de escena: se instancian las pantallas sueltas y se mira cómo se conectan.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ui/end_screen.tscn")
const TEST_SAVE: String = "user://test_intro_save.json"

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	GameFlow.intro_pending = false
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	GameFlow.intro_pending = false
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.test_level = null
	GameFlow.select_page = &"campaign"
	DevMode.enabled = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


## Abre la partida del nivel `index` de la campaña como si se lo hubiera elegido en la selección.
func _open_game(index: int, pending: bool = true) -> Game:
	GameFlow.current_index = index
	GameFlow.intro_pending = pending
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	return game


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	return event


func _click(pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = Vector2(400, 300)
	return event


# --- El cartel suelto (LevelIntro) ---

func test_the_intro_shows_title_place_and_lines() -> void:
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child_autofree(intro)
	assert_false(intro.is_open())
	intro.open("Bastión", "El bastión sobre ruinas", "Una.\nDos.\nTres.")
	assert_true(intro.is_open())
	assert_eq((intro.get_node("%Title") as Label).text, "Bastión")
	assert_eq((intro.get_node("%Place") as Label).text, "El bastión sobre ruinas")
	assert_eq(intro.lines_text(), "Una.\nDos.\nTres.")
	assert_eq((intro.get_node("%StartButton") as Button).text, "Empezar")


func test_the_intro_without_a_place_hides_the_subtitle() -> void:
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child_autofree(intro)
	intro.open("Mapa", "", "Una línea.")
	assert_false((intro.get_node("%Place") as Label).visible)


func test_each_way_of_skipping_closes_it_once() -> void:
	var skips: Array = [
		func(intro: LevelIntro) -> void: intro._input(_key(KEY_SPACE)),
		func(intro: LevelIntro) -> void: intro._input(_key(KEY_ENTER)),
		func(intro: LevelIntro) -> void: intro._input(_key(KEY_ESCAPE)),
		func(intro: LevelIntro) -> void: intro._input(_click(false)),
		func(intro: LevelIntro) -> void: (intro.get_node("%StartButton") as Button).pressed.emit(),
	]
	for skip: Callable in skips:
		var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
		add_child_autofree(intro)
		var closed: Array[int] = [0]
		intro.closed.connect(func() -> void: closed[0] += 1)
		intro.open("N", "L", "Línea.")
		skip.call(intro)
		assert_false(intro.is_open())
		skip.call(intro)
		assert_eq(closed[0], 1, "avisa una sola vez")


func test_pressing_the_mouse_alone_does_not_close_it_but_release_does() -> void:
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child_autofree(intro)
	intro.open("N", "L", "Línea.")
	intro._input(_click(true))
	assert_true(intro.is_open(), "apretar solo traga el clic")
	intro._input(_click(false))
	assert_false(intro.is_open())


# --- En la partida (Game) ---

func test_entering_a_level_from_the_select_screen_opens_the_intro_and_pauses() -> void:
	_open_game(7)  # nivel 8
	assert_true(game.level_intro.is_open())
	assert_true(game.is_paused())
	assert_eq((game.level_intro.get_node("%Title") as Label).text, "Bastión")
	assert_eq(game.level_intro.lines_text(), GameFlow.level(7).intro_text)
	assert_false(GameFlow.intro_pending, "el aviso se consume")
	assert_true(game.build_controller.input_blocked, "no se puede construir mientras se lee")


func test_the_countdown_does_not_advance_while_the_intro_is_open_and_does_after() -> void:
	_open_game(7)
	game.session.state = LevelSession.State.COUNTDOWN  # una cuenta atrás en marcha
	game.session.countdown_left = 10.0
	await wait_process_frames(30)
	assert_eq(game.session.countdown_left, 10.0, "la cuenta atrás espera")
	game.level_intro.close()
	await wait_process_frames(30)
	assert_lt(game.session.countdown_left, 10.0, "al cerrar, sigue")


func test_closing_the_intro_resumes_exactly_where_it_was() -> void:
	_open_game(7)
	game.session.state = LevelSession.State.COUNTDOWN
	game.session.countdown_left = 10.0
	var countdown: float = game.session.countdown_left
	game.set_speed(2.0)
	game.level_intro._input(_click(false))
	assert_false(game.level_intro.is_open())
	assert_false(game.is_paused())
	assert_false(game.build_controller.input_blocked)
	assert_eq(game.session.countdown_left, countdown, "no suma ninguna espera")
	assert_eq(Engine.time_scale, 2.0, "la velocidad se conserva")


func test_escape_closes_the_intro_before_the_pause_menu_can_open() -> void:
	_open_game(7)
	Input.parse_input_event(_key(KEY_ESCAPE))
	await wait_process_frames(3)
	assert_false(game.level_intro.is_open(), "Esc cierra el cartel")
	assert_false(game.pause_menu.is_open(), "y no abre el menú de pausa")
	assert_false(game.is_paused())


func test_space_while_the_intro_is_open_does_not_start_a_wave() -> void:
	_open_game(7)
	var wave: int = game.session.wave
	Input.parse_input_event(_key(KEY_SPACE))
	await wait_process_frames(3)
	assert_false(game.level_intro.is_open())
	assert_eq(game.session.wave, wave, "Espacio cierra el cartel, no empieza la oleada")


func test_retry_does_not_show_the_intro_again() -> void:
	_open_game(7)
	game.level_intro.close()
	# «Reintentar» recarga la escena sin pasar por start_level: el aviso ya se consumió.
	assert_false(GameFlow.intro_pending)
	game.queue_free()
	await wait_process_frames(2)
	_open_game(7, GameFlow.intro_pending)
	assert_false(game.level_intro.is_open())
	assert_false(game.is_paused())


func test_a_level_without_entrada_starts_as_always() -> void:
	var plain: LevelData = GameFlow.level(0).duplicate()
	plain.intro_text = ""
	GameFlow.test_level = null
	GameFlow.current_community = plain  # un mapa de la comunidad sin "textos"
	GameFlow.intro_pending = true
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_false(game.level_intro.is_open())
	assert_false(game.is_paused())


func test_a_community_map_with_textos_shows_the_intro() -> void:
	var map: LevelData = GameFlow.level(0).duplicate()
	map.intro_text = "Un mapa con cartel."
	GameFlow.current_community = map
	GameFlow.intro_pending = true
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_true(game.level_intro.is_open())
	assert_eq(game.level_intro.lines_text(), "Un mapa con cartel.")


func test_testing_from_the_editor_never_shows_texts() -> void:
	GameFlow.test_level = GameFlow.level(7)
	GameFlow.intro_pending = true  # aunque se encienda por error
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_false(game.shows_texts())
	assert_false(game.level_intro.is_open())
	assert_false(game.is_paused())


func test_dev_mode_never_shows_texts() -> void:
	DevMode.enabled = true
	_open_game(7)
	assert_false(game.shows_texts())
	assert_false(game.level_intro.is_open())


func test_official_modes_never_show_texts_even_with_a_campaign_map() -> void:
	var map: LevelData = GameFlow.level(7).duplicate()
	var official: Dictionary = {"id": &"asedio", "official": true, "maps": [], "errors": PackedStringArray()}
	GameFlow.current_mode = official
	GameFlow.current_mode_index = 0
	# Se prueba la regla directamente: current_mode_level() necesita un modo real en disco.
	game = GAME_SCENE.instantiate()
	game.level_data = map
	add_child_autofree(game)
	assert_false(game.shows_texts(), "modo oficial: nada")
	GameFlow.current_mode = {"id": &"propio", "official": false, "maps": [], "errors": PackedStringArray()}
	assert_true(game.shows_texts(), "un modo propio muestra lo que el mapa traiga")


func test_the_victory_shows_the_win_text_only_when_texts_are_shown() -> void:
	_open_game(7)
	game.level_intro.close()
	assert_eq(game.level_data.win_text, GameFlow.level(7).win_text)
	game.session.state_changed.emit(LevelSession.State.WON)
	assert_eq(game.end_screen.win_text(), GameFlow.level(7).win_text)


# --- La pantalla de victoria (RF-467) ---

func test_victory_screen_shows_the_win_text_under_the_stars_and_before_the_score() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	end_screen.show_victory(18, 3, true, true, 1234, "Bastión asegurado.\nLos muros son de otros.")
	assert_eq(end_screen.win_text(), "Bastión asegurado.\nLos muros son de otros.")
	var rows: Node = end_screen.get_node("%Rows")
	var stars_at: int = end_screen.get_node("%Stars").get_index()
	var win_label: Node = null
	var score_label: Node = null
	for child: Node in rows.get_children():
		if child is Label and (child as Label).text.begins_with("Bastión"):
			win_label = child
		if child is Label and (child as Label).text.begins_with("Puntos"):
			score_label = child
	assert_not_null(win_label)
	assert_gt(win_label.get_index(), stars_at)
	assert_lt(win_label.get_index(), score_label.get_index())


func test_victory_screen_without_a_win_text_is_as_before() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	end_screen.show_victory(18, 3, true, true, 10)
	assert_eq(end_screen.win_text(), "")


func test_defeat_shows_no_text_and_the_text_does_not_stick() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	end_screen.show_victory(18, 3, true, true, 10, "Texto.")
	end_screen.show_defeat(5, 20, true, 10)
	assert_eq(end_screen.win_text(), "")


func test_the_win_text_does_not_break_the_initials_entry() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	end_screen.show_victory(18, 3, true, true, 10, "Texto.")
	end_screen.ask_name("¡Nuevo récord!", 3, "AAA")
	assert_true(end_screen.is_asking_name())
	assert_eq(end_screen.win_text(), "Texto.")


# --- La tarjeta (RF-465) ---

func _card(select: Control, index: int) -> Button:
	return select.get_node("%Cards").get_child(index)


func test_an_unlocked_card_shows_the_place_and_keeps_its_size() -> void:
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	var card: Button = _card(select, 0)
	var place: Label = card.get_node_or_null("Place")
	assert_not_null(place, "el nivel 1 está desbloqueado")
	assert_true(place.text.ends_with("…"), "el lugar largo se recorta con puntos suspensivos")
	assert_eq(card.size, select.CARD_SIZE, "el tamaño de la tarjeta no cambia")
	assert_true(card.tooltip_text.begins_with("Campamento de aterrizaje"), "el tooltip lleva el lugar completo")
	assert_gt(place.get_theme_font_size("font_size"), 0)
	assert_lt(place.get_theme_font_size("font_size"), card.get_theme_font_size("font_size"), "letra más chica")
	assert_string_contains(card.get_node("LevelNumber").text, "10 oleadas")


func test_a_locked_card_does_not_show_the_place() -> void:
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	var locked: Button = _card(select, 7)
	assert_true(locked.disabled)
	assert_null(locked.get_node_or_null("Place"), "no adelanta el nivel")
	assert_false(locked.tooltip_text.contains("El bastión sobre ruinas"), "el lugar tampoco se filtra por tooltip")


func test_the_place_follows_the_unlock_state() -> void:
	SaveManager.record_victory(&"level_07", 10, 100)
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	assert_not_null(_card(select, 7).get_node_or_null("Place"), "ganar el 7 abre el 8")


func test_a_card_without_a_place_is_the_same_as_before() -> void:
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	var level: LevelData = GameFlow.level(0)
	var saved: String = level.place_text
	level.place_text = ""
	var card: Button = select.call("_make_card", 0)
	level.place_text = saved
	autofree(card)
	assert_null(card.get_node_or_null("Place"))
	assert_eq(card.text, "", "las etiquetas están en controles independientes")
	assert_eq(card.get_node("LevelName").text, level.display_name)
	assert_string_contains(card.get_node("LevelNumber").text, "%d oleadas" % level.waves.size())


func test_the_place_label_sits_between_the_name_and_the_waves() -> void:
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	var card: Button = _card(select, 0)
	var place: Label = card.get_node("Place")
	var name: Label = card.get_node("LevelName")
	var plate: Control = card.get_node("TowerPlate")
	var icons: Control = plate.get_node("TowerIcons")
	assert_gte(place.position.y, name.position.y + name.size.y, "el lugar va directamente debajo del nombre")
	assert_gte(plate.position.y + icons.position.y, place.position.y + place.size.y, "los íconos van debajo del lugar")


func test_campaign_cards_keep_the_same_tower_offer_and_show_badges_for_all_levels() -> void:
	var select: Control = SELECT_SCENE.instantiate()
	add_child_autofree(select)
	await wait_process_frames(2)
	var towers: Array[TowerData] = TowerOffer.canonical_towers()
	var levels: Array[LevelData] = []
	for index: int in GameFlow.level_count():
		levels.append(GameFlow.level(index))
	for index: int in GameFlow.level_count():
		var card: Button = _card(select, index)
		var level: LevelData = levels[index]
		var expected: Array[TowerData] = TowerOffer.offered(level, towers)
		var icons: Control = card.get_node("TowerPlate/TowerIcons")
		var actual: Array[String] = []
		for badge: Node in icons.get_children():
			actual.append(String((badge as Control).get_child(0).name))
		assert_eq(actual, _tower_ids(expected), "nivel %d: conserva la lista y el orden" % (index + 1))
		assert_eq(card.get_node("TowerPlate/TowerTitle").text, "Torres  ·  %d" % expected.size())
		assert_true(card.tooltip_text.contains(expected[0].display_name), "nivel %d: conserva el tooltip" % (index + 1))
		for badge: Node in icons.get_children():
			assert_lte((badge as Control).position.x + (badge as Control).size.x, icons.size.x + 0.1)
		assert_lte(card.get_node("TowerPlate").position.y + card.get_node("TowerPlate").size.y,
			card.get_node("Stars").position.y, "nivel %d: la placa no pisa las estrellas" % (index + 1))
	assert_eq(select.get_node("%Cards").get_child(0).get_node("TowerPlate/TowerIcons").get_child_count(), 8,
		"el nivel 1 usa una fila de ocho insignias")
	assert_eq(select.get_node("%Cards").get_child(11).get_node("TowerPlate/TowerIcons").get_child_count(), 10,
		"el nivel 12 muestra las diez torres en dos filas")
	assert_true(select.get_node("%Cards").get_child(0).tooltip_text.contains("Nueva"),
		"se conserva el indicador de torre nueva en el tooltip")
	assert_not_null(select.get_node("%Cards").get_child(0).find_child("NewMark", true, false),
		"se conserva la marca naranja de torre nueva")


func _tower_ids(towers: Array[TowerData]) -> Array[String]:
	var result: Array[String] = []
	for tower: TowerData in towers:
		result.append(String(tower.id))
	return result


# --- Medidas (RF-466: que entre en 1280 × 720 y en el celular, sin tapar los botones de arriba) ---

func test_the_intro_panel_fits_between_the_top_and_bottom_bars_for_every_official_level() -> void:
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child_autofree(intro)
	var panel: Control = intro.get_node("IntroPanel/Center/Panel")
	for i: int in GameFlow.level_count():
		var level: LevelData = GameFlow.level(i)
		intro.open(level.display_name, level.place_text, level.intro_text)
		await wait_process_frames(2)
		var size: Vector2 = panel.get_combined_minimum_size()
		# La barra de arriba mide 48 y la de abajo empieza en 624 (hud.tscn): el cartel va entre las dos.
		assert_lt(size.y, 624.0 - 48.0 - 40.0, "nivel %d: el cartel mide %s" % [i + 1, size])
		assert_lt(size.x, 1280.0 - 2.0 * 40.0, "nivel %d" % (i + 1))
		intro.close()


func test_the_start_button_is_big_enough_to_touch() -> void:
	var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child_autofree(intro)
	assert_gte((intro.get_node("%StartButton") as Button).custom_minimum_size.y, 52.0, "como los demás botones de los diálogos")
