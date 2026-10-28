# T248 (M53): la barra con pestañas, las tarjetas de «Infraestructura», las teclas y la flecha «← Menú» con la
# escena Game REAL (niveles oficiales). Nunca se llama a nada que cambie de pantalla: la flecha sale por las
# costuras `leave_to_menu` y `leave_to_editor` de Game (`.claude/rules/tests.md`).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SAVE_PATH: String = "user://test_bar_tabs.json"
const SCREEN: Rect2 = Rect2(0, 0, 1280, 720)

var old_index: int
var old_campaign: CampaignData
var old_dev: bool
var old_community: LevelData
var old_path: String
var game: Game
var left_to: Array[String] = []
## Los controles de GUT (su panel de salida cubre la mitad derecha de la ventana) y su filtro de mouse original.
var _gut_filters: Dictionary = {}


func before_each() -> void:
	old_path = SaveManager.save_path
	old_index = GameFlow.current_index
	old_campaign = GameFlow.campaign
	old_dev = DevMode.enabled
	old_community = GameFlow.current_community
	DevMode.enabled = false
	GameFlow.current_community = null
	GameFlow.test_level = null
	_delete_save()
	SaveManager.save_path = SAVE_PATH
	SaveManager.load_save()
	left_to.clear()
	_ignore_gut_panel()


func after_each() -> void:
	for control: Control in _gut_filters:
		if is_instance_valid(control):
			control.mouse_filter = _gut_filters[control]
	_gut_filters.clear()
	GameFlow.current_index = old_index
	GameFlow.campaign = old_campaign
	GameFlow.current_community = old_community
	GameFlow.forced_seed = -1
	GameFlow.test_level = null
	DevMode.enabled = old_dev
	Engine.time_scale = 1.0
	SaveManager.save_path = old_path
	SaveManager.load_save()
	_delete_save()


## El panel de salida de GUT se queda con los clics de la derecha de la ventana y el juego nunca los ve. No pasa en
## una partida real: se le saca el mouse mientras dura cada test (igual que en test_real_scene_clicks).
func _ignore_gut_panel() -> void:
	for control: Node in get_tree().root.find_children("*", "Control", true, false):
		var ui := control as Control
		if ui.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			_gut_filters[ui] = ui.mouse_filter
			ui.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


## Las colecciones completas cambian cuántas torres ofrece el nivel: con `technology` (5 piezas) llega el Mecánico
## (10 torres en el 10) y con `disruptor` (3 piezas), la Disruptora (11).
func _complete(collection: StringName) -> void:
	for source: String in CollectionDefinitions.sources(collection):
		SaveManager.collect_source(collection, StringName(source))


func _start(n: int, collections: Array[StringName] = []) -> void:
	for collection: StringName in collections:
		_complete(collection)
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_load(n)] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.leave_to_menu = func() -> void: left_to.append("menu")
	game.leave_to_editor = func() -> void: left_to.append("editor")
	await get_tree().process_frame


func _key_event(code: Key, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	return event


## La tecla llega a quien la recibiría en la partida: primero `_input` de Game, luego BuildController y Game.
func _press(code: Key) -> void:
	var event: InputEventKey = _key_event(code)
	game._input(event)
	if get_viewport().is_input_handled():
		get_viewport().set_input_as_handled()  # no hace falta limpiar: cada prueba usa su partida
	game.build_controller._unhandled_input(event)
	game._unhandled_input(event)


func _first_obstacle_cell(game_level: LevelData) -> Vector2i:
	for obstacle: ObstacleSpec in game_level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.REMOVABLE:
			return obstacle.cell
	return Vector2i(-1, -1)


# --- Los niveles 1 a 5: la barra idéntica (RF-454) ---

func test_levels_1_to_5_keep_the_exact_bar_of_before() -> void:
	for n: int in range(1, 6):
		await _start(n)
		var hud: Hud = game.hud
		assert_null(hud.bar_tabs, "nivel %d: no hay pestañas" % n)
		assert_null(hud.infrastructure_tab, "nivel %d: no hay pestaña de infraestructura" % n)
		assert_null(hud.find_child("BarTabs", true, false))
		var row: HBoxContainer = hud._tower_button_row
		assert_eq(row.offset_left, 20.0, "nivel %d: la fila arranca en x = 20" % n)
		assert_eq(row.offset_right, 980.0, "nivel %d: y termina donde siempre" % n)
		assert_eq(row.get_theme_constant("separation"), 10, "nivel %d: separación de siempre" % n)
		assert_true(row.visible)
		var buttons: Array[Button] = hud._tower_buttons
		assert_gt(buttons.size(), 0)
		await get_tree().process_frame
		for i: int in buttons.size():
			var rect: Rect2 = buttons[i].get_global_rect()
			assert_eq(rect.size, Vector2(76, 60), "nivel %d, botón %d: 76 × 60 como antes" % [n, i + 1])
			assert_eq(rect.position, Vector2(20 + i * 86, 642), "nivel %d, botón %d: en su lugar de siempre" % [n, i + 1])
		game.queue_free()
		await get_tree().process_frame


func test_tab_and_zero_do_nothing_in_a_level_without_tabs() -> void:
	await _start(1)
	game.build_controller.select(1)
	await _press(KEY_TAB)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[1], "Tab no cancela nada")
	await _press(KEY_0)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[1], "con 8 torres, `0` no elige nada")
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS)


func test_the_arrow_is_in_every_level_and_the_stats_do_not_overlap_it() -> void:
	for n: int in [1, 6]:
		await _start(n)
		var hud: Hud = game.hud
		var arrow: Rect2 = hud._exit_button.get_global_rect()
		assert_eq(arrow, Rect2(8, 8, 80, 32), "nivel %d: la flecha mide 80 × 32 en (8, 8)" % n)
		assert_eq(hud._exit_button.text, "← Menú")
		assert_eq(hud._exit_button.tooltip_text, "Volver al menú principal")
		assert_eq(hud._exit_button.focus_mode, Control.FOCUS_NONE, "no toma el foco del teclado")
		var stats: Control = hud.get_node("TopBar/Stats")
		assert_gte(stats.get_global_rect().position.x, arrow.end.x, "las estadísticas arrancan a la derecha de la flecha")
		assert_lte(stats.get_global_rect().end.x, 1000.0, "y siguen hasta x = 1000")
		for other: Control in [hud._pause_button, hud._speed_button]:
			assert_false(arrow.intersects(other.get_global_rect()), "no tapa %s" % other.name)
		game.queue_free()
		await get_tree().process_frame


# --- Los niveles con infraestructura: las dos pestañas ---

func test_levels_6_to_10_show_both_tabs_with_cannons_active() -> void:
	for n: int in range(6, 11):
		await _start(n)
		var hud: Hud = game.hud
		assert_not_null(hud.bar_tabs, "nivel %d: hay pestañas" % n)
		assert_eq(hud.bar_tabs.ids(), [Hud.TAB_CANNONS, Hud.TAB_INFRASTRUCTURE])
		assert_eq(hud.current_tab(), Hud.TAB_CANNONS, "arranca siempre en «Cañones»")
		assert_true(hud._tower_button_row.visible)
		assert_false(hud.infrastructure_tab.visible)
		assert_eq(hud.bar_tabs.title_of(Hud.TAB_CANNONS), "Cañones")
		assert_eq(hud.bar_tabs.title_of(Hud.TAB_INFRASTRUCTURE), "Infraestructura")
		var tabs: Array[Rect2] = [hud.bar_tabs.button_of(Hud.TAB_CANNONS).get_global_rect(), hud.bar_tabs.button_of(Hud.TAB_INFRASTRUCTURE).get_global_rect()]
		assert_eq(tabs[0].size, Vector2(96, 44), "RF-455: 96 × 44")
		assert_eq(tabs[1].size, Vector2(96, 44))
		assert_eq(tabs[0].position.x, 12.0)
		assert_lt(tabs[0].end.y, tabs[1].position.y + 0.5, "una encima de la otra")
		assert_true(SCREEN.encloses(tabs[0]) and SCREEN.encloses(tabs[1]))
		game.queue_free()
		await get_tree().process_frame


func test_the_map_area_and_the_map_do_not_change_with_tabs() -> void:
	await _start(7)
	assert_eq(game.level.position, Game.MAP_OFFSET, "el mapa sigue debajo de la barra de arriba")
	assert_null(game.camera, "el 7 (20 × 9) no usa cámara")
	var bar: Control = game.hud.get_node("BottomBar")
	assert_eq(bar.get_global_rect(), Rect2(0, 624, 1280, 96), "la barra de abajo mide lo mismo")
	for child: Node in game.hud.get_children():
		if child is Control and child.name != "BottomBar" and child.name != "TopBar":
			var control := child as Control
			assert_false(control.visible and control.get_global_rect().intersects(Rect2(0, 48, 1280, 576)) and control is InfrastructureTab, "ninguna pestaña invade el mapa")


func test_tab_switches_and_hides_the_tower_buttons() -> void:
	await _start(7)
	var hud: Hud = game.hud
	await _press(KEY_TAB)
	assert_eq(hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
	assert_false(hud._tower_button_row.visible)
	assert_true(hud.infrastructure_tab.visible)
	await _press(KEY_TAB)
	assert_eq(hud.current_tab(), Hud.TAB_CANNONS, "Tab da la vuelta")
	assert_true(hud._tower_button_row.visible)
	assert_false(hud.infrastructure_tab.visible)


func test_tab_with_a_tower_chosen_cancels_the_construction() -> void:
	await _start(7)
	game.build_controller.select(0)
	assert_not_null(game.build_controller.selected_tower())
	await _press(KEY_TAB)
	assert_null(game.build_controller.selected_tower(), "no queda vista previa sobre el mapa")
	assert_eq(game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
	assert_false(game.hud._build_info.visible, "ni la ayuda de construcción")


func test_a_tower_key_in_infrastructure_goes_back_to_cannons_and_chooses_it() -> void:
	await _start(7)
	await _press(KEY_TAB)
	assert_eq(game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
	await _press(KEY_3)
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS, "ninguna tecla queda muerta")
	assert_eq(game.build_controller.selected_tower(), game.available_towers[2], "y elige la tercera")
	assert_true(game.hud._tower_buttons[2].button_pressed)


func test_clicking_a_tower_button_never_changes_the_tab() -> void:
	await _start(7)
	game.hud._tower_buttons[1].pressed.emit()
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[1])


func test_tab_keeps_a_placed_tower_and_a_map_object_selected() -> void:
	await _start(7)
	game.session.earn(500)
	assert_true(game.build_controller.try_build(game.available_towers[0], Vector2i(2, 3)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(2, 3))
	game.build_controller.select_placed(tower)
	await _press(KEY_TAB)
	assert_eq(game.build_controller.selected_placed(), tower, "RF-456: una torre colocada sigue seleccionada")
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	game.infrastructure.select(cell)
	assert_eq(game.infrastructure.selected_cell(), cell)
	await _press(KEY_TAB)
	assert_eq(game.infrastructure.selected_cell(), cell, "y un objeto del mapa también")


func test_tab_wins_over_the_keyboard_focus_of_the_interface() -> void:
	# El riesgo de la ficha: un ícono de arriba acepta el foco (FOCUS_ALL) y Tab lo movería en vez de cambiar la pestaña.
	await _start(7)
	var icon: Control = game.hud.get_node("TopBar/Stats/GoldStat/GoldIcon")
	icon.grab_focus()
	await get_tree().process_frame
	assert_eq(get_viewport().gui_get_focus_owner(), icon, "el ícono tiene el foco")
	Input.parse_input_event(_key_event(KEY_TAB))
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE, "Tab cambió la pestaña")
	assert_eq(get_viewport().gui_get_focus_owner(), icon, "y no movió el foco")
	Input.parse_input_event(_key_event(KEY_TAB, false))
	icon.release_focus()


func test_tabs_by_click_and_by_touch() -> void:
	await _start(7)
	var hud: Hud = game.hud
	hud.bar_tabs.button_of(Hud.TAB_INFRASTRUCTURE).pressed.emit()
	assert_eq(hud.current_tab(), Hud.TAB_INFRASTRUCTURE, "un toque en la pestaña es lo mismo que el clic")
	hud.bar_tabs.button_of(Hud.TAB_CANNONS).pressed.emit()
	assert_eq(hud.current_tab(), Hud.TAB_CANNONS)
	hud.bar_tabs.button_of(Hud.TAB_CANNONS).pressed.emit()
	assert_eq(hud.current_tab(), Hud.TAB_CANNONS, "pulsar la activa no la apaga")


# --- Las diez torres y la tecla 0 (RF-456) ---

func test_ten_towers_fit_and_read_in_level_10() -> void:
	await _start(10, [&"technology"])
	var hud: Hud = game.hud
	await get_tree().process_frame
	var buttons: Array[Button] = hud._tower_buttons
	assert_eq(buttons.size(), 10)
	var next_wave: Rect2 = hud._next_wave.get_global_rect()
	var tabs_end: float = hud.bar_tabs.button_of(Hud.TAB_CANNONS).get_global_rect().end.x
	for i: int in buttons.size():
		var rect: Rect2 = buttons[i].get_global_rect()
		assert_eq(rect.size, Vector2(BarLayout.button_width(10, true), 60), "botón %d" % (i + 1))
		assert_gt(rect.position.x, tabs_end, "botón %d: no toca las pestañas" % (i + 1))
		assert_lte(rect.end.x, next_wave.position.x, "botón %d: no toca «Próxima oleada»" % (i + 1))
		if i > 0:
			assert_gte(rect.position.x, buttons[i - 1].get_global_rect().end.x, "no se pisan")
		# La etiqueta de costo cabe dentro del botón.
		var font: Font = buttons[i].get_theme_font("font")
		var text_width: float = font.get_string_size(buttons[i].text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		assert_lt(text_width, rect.size.x, "botón %d: «%s» entra" % [i + 1, buttons[i].text])
	var labels: Array[String] = []
	for button: Button in buttons:
		for child: Node in button.get_children():
			if child is Label:
				labels.append((child as Label).text)
	assert_eq(labels, ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], "RF-456: las etiquetas de tecla, con el 0 en la décima")


func test_resource_badges_stay_inside_narrow_buttons_and_off_the_key_label() -> void:
	await _start(10, [&"technology", &"disruptor"])
	await get_tree().process_frame
	for i: int in game.hud._tower_buttons.size():
		var button: Button = game.hud._tower_buttons[i]
		var badge: Control = button.get_node_or_null("ResourceBadge")
		if badge == null:
			continue
		var rect: Rect2 = button.get_global_rect()
		var badge_rect: Rect2 = badge.get_global_rect()
		assert_true(rect.encloses(badge_rect), "botón %d: la insignia %s está dentro de %s" % [i + 1, badge_rect, rect])
		var key: Control = button.get_child(0)
		if key is Label:
			assert_lte(key.get_global_rect().end.x, badge_rect.position.x, "botón %d: la insignia no pisa la tecla" % (i + 1))


func test_zero_chooses_the_tenth_and_one_the_first_without_engine_errors() -> void:
	await _start(10, [&"technology"])
	await _press(KEY_0)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[9], "RF-456: `0` elige la décima")
	await _press(KEY_1)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[0], "`1` elige la primera")
	# Cualquier otra tecla: el motor no imprime «The InputMap action "build_N" doesn't exist» (GUT lo contaría como fallo).
	for code: Key in [KEY_A, KEY_Z, KEY_5, KEY_9, KEY_ENTER]:
		await _press(code)
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS)


func test_an_eleventh_tower_has_no_key_and_no_key_tooltip() -> void:
	# En la campaña el nivel 10 ofrece hasta 10 torres; las 11 que existen salen con el modo de pruebas (RF-436).
	await _start(10, [&"technology"])
	assert_eq(game.hud._tower_buttons.size(), 10)
	DevMode.enabled = true
	game.dev_enable_collections(true)
	DevMode.enabled = false
	DevMode.collections_unlocked = false
	assert_eq(game.hud._tower_buttons.size(), 11)
	await get_tree().process_frame
	var last: Button = game.hud._tower_buttons[10]
	assert_false(last.tooltip_text.contains("tecla"), "la ayuda de la torre 11 no dice «tecla N»")
	for child: Node in last.get_children():
		assert_false(child is Label, "y no lleva etiqueta de tecla")
	assert_eq(last.size.x, float(BarLayout.button_width(11, true)), "los 11 botones se reparten el ancho")
	assert_eq(last.size.x, 57.0, "unos 57 px")
	assert_lte(last.get_global_rect().end.x, game.hud._next_wave.get_global_rect().position.x)
	await _press(KEY_0)
	assert_eq(game.build_controller.selected_tower(), game.available_towers[9], "`0` elige la décima, no la undécima")
	last.pressed.emit()
	assert_eq(game.build_controller.selected_tower(), game.available_towers[10], "la 11 se elige con el mouse o el dedo")


func test_the_testing_mode_can_add_the_collection_towers_and_the_bar_rearranges() -> void:
	await _start(10)
	assert_eq(game.hud._tower_buttons.size(), 9, "sin colecciones, 9 torres")
	DevMode.enabled = true  # `dev_enable_collections` solo actúa con el modo de pruebas (RF-436)
	game.dev_enable_collections(true)
	DevMode.enabled = false
	DevMode.collections_unlocked = false
	assert_eq(game.hud._tower_buttons.size(), 11, "RF-447: «todas las colecciones» suma las torres")
	await get_tree().process_frame
	var previous_end: float = 0.0
	for button: Button in game.hud._tower_buttons:
		assert_eq(button.size.x, 57.0, "se reparten el ancho de nuevo: ninguno crece por su texto")
		assert_gte(button.get_global_rect().position.x, previous_end, "no se pisan")
		previous_end = button.get_global_rect().end.x
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS)


# --- Tocar un objeto del mapa (RF-458) ---

func test_selecting_a_map_object_keeps_the_tab_and_opens_its_panel() -> void:
	await _start(7)
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	game.infrastructure.select(cell)
	assert_true(game.hud.obstacle_panel.visible, "se abre el panel del objeto")
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS, "y la pestaña no cambia sola")
	await _press(KEY_TAB)
	game.infrastructure.deselect()
	game.infrastructure.select(cell)
	assert_eq(game.hud.current_tab(), Hud.TAB_INFRASTRUCTURE, "tampoco vuelve sola desde «Infraestructura»")


func test_the_tab_title_shows_the_demolition_time_and_goes_back() -> void:
	await _start(7)
	game.session.earn(200)
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	var title: Callable = func() -> String: return game.hud.bar_tabs.title_of(Hud.TAB_INFRASTRUCTURE)
	assert_eq(title.call(), "Infraestructura")
	assert_true(game.infrastructure.order(cell))
	assert_true(String(title.call()).begins_with("Infraestructura · "), "con trabajo: «%s»" % title.call())
	assert_true(String(title.call()).ends_with(" s"))
	assert_true(game.hud.infrastructure_tab.has_job(), "la tarjeta de trabajo muestra el nombre y el avance")
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS, "sin abrir la pestaña")
	assert_true(game.infrastructure.cancel_job())
	assert_eq(title.call(), "Infraestructura", "al cancelar, el título vuelve")
	assert_false(game.hud.infrastructure_tab.has_job())


func test_cancel_from_the_tab_gives_back_all_the_gold_and_updates_the_object_panel() -> void:
	await _start(7)
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	var gold: int = game.session.gold
	game.infrastructure.select(cell)
	assert_true(game.infrastructure.order(cell))
	assert_lt(game.session.gold, gold)
	game.hud.infrastructure_tab._cancel_button.pressed.emit()
	assert_eq(game.session.gold, gold, "RF-407: vuelve todo el oro")
	assert_eq(game.hud.obstacle_panel._button.text.begins_with("Demoler"), true, "el panel del objeto vuelve a decir «Demoler»")


# --- Las cuatro tarjetas (RF-457) ---

func test_level_7_cards_are_job_machine_and_resources_without_extraction() -> void:
	await _start(7)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	assert_true(tab._job_card.visible, "trabajo en curso: siempre")
	assert_true(tab._machine_card.visible, "el 7 tiene demoledora")
	assert_false(tab._sites_card.visible, "el 7 no tiene extracción")
	assert_true(tab._resources_card.visible, "los removibles pueden dar recursos")
	assert_eq(tab._job_empty.text, "Sin demolición en curso. Tocá un objeto del mapa para demolerlo.")
	assert_true(tab._job_empty.visible)
	assert_eq(tab._machine_title.text, "Demoledora · 180 de oro")
	assert_eq(tab._resources_label.text, "Recursos: 0")


func test_level_10_cards_are_job_extraction_and_resources_without_machine() -> void:
	await _start(10)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	assert_true(tab._job_card.visible)
	assert_false(tab._machine_card.visible, "el 10 no tiene demoledora")
	assert_true(tab._sites_card.visible, "el 10 tiene una mina")
	assert_true(tab._resources_card.visible)
	var cards: Array[Control] = []
	for card: Node in tab._row.get_children():
		if (card as Control).visible:
			cards.append(card)
	assert_eq(cards.size(), 3, "las tres tarjetas se reparten el ancho")
	var total: float = 0.0
	for card: Control in cards:
		total += card.size.x
	await get_tree().process_frame
	assert_true(Rect2(118, 624, 674, 96).encloses(tab.get_global_rect()), "todo dentro de x = 118 a 792")


func test_level_6_has_no_machine_card_because_its_file_has_no_demoledora() -> void:
	await _start(6)
	assert_false(game.hud.infrastructure_tab._machine_card.visible)
	assert_not_null(game.hud.bar_tabs)


func test_buying_the_machine_from_the_card() -> void:
	await _start(7)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	game.session.set_gold(200)
	assert_false(tab._buy_button.disabled)
	tab._buy_button.pressed.emit()
	assert_eq(game.session.gold, 20, "RF-457: 200 menos 180")
	assert_eq(tab._machine_title.text, "Demoledora activa")
	assert_eq(tab._machine_effect.text, "Cada demolición cuesta el 10 % y tarda el 80 %")
	assert_false(tab._buy_button.visible)
	tab.buy_pressed.emit()
	assert_eq(game.session.gold, 20, "no cobra dos veces")


func test_the_buy_button_is_grey_with_what_is_missing() -> void:
	await _start(7)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	game.session.set_gold(100)
	assert_true(tab._buy_button.disabled)
	assert_eq(tab._buy_button.text, "Te faltan 80 de oro")
	game.session.set_gold(180)
	assert_false(tab._buy_button.disabled, "borde: justo alcanza")
	assert_eq(tab._buy_button.text, "Comprar")


func test_the_extraction_card_enables_a_mine_and_shows_its_reserve() -> void:
	await _start(10)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	var mine: Vector2i = game.infrastructure.field.extraction_cells()[0]
	game.session.set_gold(150)
	var row: Control = tab._sites_box.get_child(0)
	var enable_button: Button = row.get_child(1)
	assert_eq(enable_button.text, "Habilitar · 100 de oro")
	assert_false(enable_button.disabled)
	enable_button.pressed.emit()
	assert_eq(game.session.gold, 50, "cobra lo mismo que el panel del objeto")
	assert_eq(game.infrastructure.field.state_of(mine), ObstacleField.State.ACTIVE)
	await get_tree().process_frame
	var active_row: Control = tab._sites_box.get_child(0)
	var line: Label = active_row.get_child(1)
	assert_eq(line.text, "Activa · reserva 8/8 · +2 por oleada")
	assert_eq(tab._expected_label.text, "Al terminar la oleada: +2")
	assert_true(tab._expected_label.visible)


func test_a_site_with_not_enough_gold_is_grey() -> void:
	await _start(10)
	game.session.set_gold(40)
	await get_tree().process_frame  # la ficha vieja se borra al final del cuadro
	var enable_button: Button = game.hud.infrastructure_tab._sites_box.get_child(0).get_child(1)
	assert_true(enable_button.disabled)


func test_touching_a_site_name_selects_it_on_the_map() -> void:
	await _start(10)
	var mine: Vector2i = game.infrastructure.field.extraction_cells()[0]
	game.build_controller.select(0)
	var name_button: Button = game.hud.infrastructure_tab._sites_box.get_child(0).get_child(0)
	assert_eq(name_button.text, "Mina")
	name_button.pressed.emit()
	assert_eq(game.infrastructure.selected_cell(), mine, "se elige en el mapa")
	assert_true(game.hud.obstacle_panel.visible, "y abre su panel (RF-404)")
	assert_null(game.build_controller.selected_tower(), "una sola selección a la vez (RF-73)")


func test_four_sites_show_three_and_two_arrows_scroll_one_by_one() -> void:
	await _start(10)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	var sites: Array[Dictionary] = []
	for i: int in 5:
		sites.append({"cell": Vector2i(i, 0), "kind_name": "Mina", "state": ObstacleField.State.DISABLED, "price": 100, "reserve": 8, "max_reserve": 8, "production": 2})
	tab.show_sites(sites, 500)
	await get_tree().process_frame
	assert_eq(tab._sites_box.get_child_count(), 3, "RF-457: hasta 3 fichas a la vez")
	assert_true(tab._prev_button.get_parent().visible, "con más de 3 hay flechas")
	assert_true(tab._prev_button.disabled, "borde: al principio no se puede ir atrás")
	tab._next_button.pressed.emit()
	await get_tree().process_frame
	var first: Button = tab._sites_box.get_child(0).get_child(0)
	assert_eq(first.text, "Mina")
	var picked: Array = []
	tab.site_selected.connect(func(cell: Vector2i) -> void: picked.append(cell))
	first.pressed.emit()
	assert_eq(picked, [Vector2i(1, 0)], "avanzó de a una: la primera visible es la 2")
	tab._next_button.pressed.emit()
	tab._next_button.pressed.emit()
	await get_tree().process_frame
	assert_true(tab._next_button.disabled, "borde: al final no se puede avanzar")
	assert_eq(tab._sites_box.get_child_count(), 3)
	tab.show_sites([sites[0], sites[1]] as Array[Dictionary], 500)
	await get_tree().process_frame
	assert_false(tab._prev_button.get_parent().visible, "con 3 o menos no hay flechas")


func test_depleted_and_active_sites_have_no_button_to_enable() -> void:
	await _start(10)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	var sites: Array[Dictionary] = [
		{"cell": Vector2i(1, 0), "kind_name": "Mina", "state": ObstacleField.State.DEPLETED, "price": 100, "reserve": 0, "max_reserve": 8, "production": 2},
	]
	tab.show_sites(sites, 500)
	await get_tree().process_frame
	var row: Control = tab._sites_box.get_child(0)
	assert_eq(row.get_child_count(), 2)
	assert_false(row.get_child(1) is Button)
	assert_eq((row.get_child(1) as Label).text, "Agotada")


func test_the_job_card_follows_the_demolition_and_cancel_button_calls_the_controller() -> void:
	await _start(7)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	game.session.earn(200)
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	assert_true(game.infrastructure.order(cell))
	assert_true(tab._job_box.visible)
	assert_false(tab._job_empty.visible)
	assert_string_starts_with(tab._job_left.text, "Faltan ")
	game.infrastructure._process(1.0)
	assert_gt(tab._job_bar.value, 0.0, "la barra avanza con el tiempo de juego")
	var gold: int = game.session.gold
	tab._cancel_button.pressed.emit()
	assert_false(game.infrastructure.field.has_job())
	assert_gt(game.session.gold, gold)
	assert_true(tab._job_empty.visible)


func test_resources_card_follows_the_session_and_is_hidden_when_the_map_has_none() -> void:
	await _start(7)
	var tab: InfrastructureTab = game.hud.infrastructure_tab
	game.session.add_resources(3)
	assert_eq(tab._resources_label.text, "Recursos: 3")
	assert_false(tab._expected_label.visible, "sin puntos activos no hay predicción")
	tab.show_resources(false, 0, 0)
	assert_false(tab._resources_card.visible)


# --- La flecha «← Menú» y su diálogo (RF-459 a RF-461) ---

func test_the_arrow_asks_before_leaving_and_pauses_the_game() -> void:
	await _start(1)
	assert_false(game.exit_dialog.is_open())
	game.hud._exit_button.pressed.emit()
	assert_true(game.exit_dialog.is_open(), "siempre pregunta")
	assert_true(game.is_paused(), "mientras está abierto, la partida queda en pausa")
	assert_eq(left_to, [] as Array[String], "todavía no salió")
	assert_eq(game.exit_dialog._message.text, "No se guardará el progreso de esta partida.")
	assert_true(game.exit_dialog._keep_button.has_focus(), "el foco inicial va a «Seguir jugando»")
	assert_eq((game.exit_dialog.get_node("%LeaveButton") as Button).text, "Salir al menú")


func test_keep_playing_restores_a_running_game_at_the_same_speed() -> void:
	await _start(1)
	game.set_speed(2.0)
	game.hud._exit_button.pressed.emit()
	assert_true(game.is_paused())
	game.exit_dialog._keep_button.pressed.emit()
	assert_false(game.exit_dialog.is_open())
	assert_false(game.is_paused(), "RF-460: volvió a correr")
	assert_eq(Engine.time_scale, 2.0, "a la misma velocidad")
	assert_false(game.build_controller.input_blocked)
	assert_eq(left_to, [] as Array[String])


func test_keep_playing_keeps_a_game_that_was_paused_with_p() -> void:
	await _start(1)
	game.toggle_pause()
	assert_true(game.is_paused())
	game.hud._exit_button.pressed.emit()
	game.exit_dialog._keep_button.pressed.emit()
	assert_true(game.is_paused(), "si ya estaba en pausa con `P`, sigue en pausa")


func test_escape_closes_the_dialog_and_does_not_open_the_pause_menu() -> void:
	await _start(1)
	game.hud._exit_button.pressed.emit()
	var escape: InputEventKey = _key_event(KEY_ESCAPE)
	game.build_controller._unhandled_input(escape)
	game._unhandled_input(escape)
	assert_false(game.exit_dialog.is_open(), "Esc cierra el diálogo")
	assert_false(game.pause_menu.is_open(), "el menú de pausa no se abre debajo")
	assert_false(game.is_paused())


func test_confirming_leaves_to_the_menu_and_writes_nothing_to_the_save() -> void:
	await _start(10)
	assert_true(game.findings.pick(&"disruptor", &"level_10", 1), "una pieza pendiente")
	game.hud._exit_button.pressed.emit()
	assert_eq(game.exit_dialog._message.text, ExitText.WARNING, "RF-725: sin detalle de piezas")
	game.exit_dialog._leave_button.pressed.emit()
	assert_eq(left_to, ["menu"], "va al menú principal")
	assert_false(FileAccess.file_exists(SAVE_PATH), "no se escribió el guardado")
	assert_eq(SaveManager.collected_sources(&"disruptor").size(), 0, "la pieza no quedó guardada")


func test_a_confirmed_piece_without_a_result_is_also_lost_and_listed() -> void:
	await _start(10)
	game.findings.pick(&"disruptor", &"level_10", 1)
	game.findings.complete_wave(1)
	assert_eq(game.findings.confirmed().size(), 1, "confirmada, pero todavía sin resultado")
	assert_eq(game.lost_pieces(), ["disruptor"])
	game.hud._exit_button.pressed.emit()
	assert_eq(game.exit_dialog._message.text, ExitText.WARNING)
	game.exit_dialog._leave_button.pressed.emit()
	assert_eq(SaveManager.collected_sources(&"disruptor").size(), 0, "abandonar descarta también las confirmadas (RF-427)")
	assert_false(FileAccess.file_exists(SAVE_PATH))


func test_a_technology_piece_is_counted_with_its_name() -> void:
	await _start(1)
	assert_not_null(game.collectible, "el nivel 1 es fuente de avances tecnológicos")
	game.collectible.pick(1)
	assert_eq(game.lost_pieces(), ["technology"])
	game.hud._exit_button.pressed.emit()
	assert_eq(game.exit_dialog._message.text, ExitText.WARNING)
	game.exit_dialog._leave_button.pressed.emit()
	assert_eq(SaveManager.collected_sources(&"technology").size(), 0)
	assert_false(FileAccess.file_exists(SAVE_PATH))


func test_the_dialog_warns_about_a_demolition_in_progress() -> void:
	await _start(7)
	game.session.earn(200)
	var cell: Vector2i = _first_obstacle_cell(game.level_data)
	assert_true(game.infrastructure.order(cell))
	game.hud._exit_button.pressed.emit()
	assert_eq(game.exit_dialog._message.text, ExitText.WARNING, "RF-725: ni la demolición se enumera")
	assert_true(game.is_paused())
	game.exit_dialog._leave_button.pressed.emit()
	assert_eq(left_to, ["menu"])


func test_testing_a_map_goes_back_to_the_editor_without_asking() -> void:
	var draft: LevelData = LevelDraft.new_level().check()["level"]
	GameFlow.test_level = draft
	GameFlow.current_index = -1
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.leave_to_menu = func() -> void: left_to.append("menu")
	game.leave_to_editor = func() -> void: left_to.append("editor")
	await get_tree().process_frame
	assert_true(game.testing)
	assert_eq(game.hud._exit_button.text, "← Editor")
	game.hud._exit_button.pressed.emit()
	assert_false(game.exit_dialog.is_open(), "sin diálogo: no se pierde nada")
	assert_eq(left_to, ["editor"])
	assert_false(game.is_paused())


func test_the_arrow_hides_when_the_game_is_over_and_does_not_open() -> void:
	await _start(1)
	game.session.lose_lives(1000)
	assert_true(game.session.is_over())
	assert_false(game.hud._exit_button.visible, "RF-459: la pantalla de resultado ya trae sus botones")
	game.hud._exit_button.pressed.emit()
	assert_false(game.exit_dialog.is_open(), "borde: ni aunque se fuerce la señal")


func test_the_dialog_does_not_open_over_the_pause_menu() -> void:
	await _start(1)
	game.open_pause_menu()
	game.hud._exit_button.pressed.emit()
	assert_false(game.exit_dialog.is_open())
	assert_true(game.pause_menu.is_open(), "el menú de pausa sigue como estaba")


func test_with_the_dialog_open_keys_do_nothing() -> void:
	await _start(7)
	game.hud._exit_button.pressed.emit()
	await _press(KEY_1)
	assert_null(game.build_controller.selected_tower(), "las teclas de torre no hacen nada")
	await _press(KEY_TAB)
	assert_eq(game.hud.current_tab(), Hud.TAB_CANNONS, "ni Tab")
	await _press(KEY_SPACE)
	assert_eq(game.session.state, LevelSession.State.BUILDING, "ni Espacio")
	game.exit_dialog._keep_button.pressed.emit()
	await _press(KEY_1)
	assert_not_null(game.build_controller.selected_tower(), "al cerrar el diálogo, las teclas vuelven")


func test_opening_the_dialog_drops_the_construction_and_the_selection() -> void:
	await _start(7)
	game.build_controller.select(0)
	game.infrastructure.select(_first_obstacle_cell(game.level_data))
	game.hud._exit_button.pressed.emit()
	assert_null(game.build_controller.selected_tower())
	assert_false(game.infrastructure.has_selection(), "para que Esc cierre el diálogo y no una selección")
	game.exit_dialog.handle_cancel()
	assert_false(game.exit_dialog.is_open())


## Un toque real (no una señal): se convierte con la misma transformación que el motor, como en test_real_scene_clicks.
func _touch_at(pos: Vector2) -> void:
	var window_pos: Vector2 = get_viewport().get_final_transform() * pos
	for pressed: bool in [true, false]:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = window_pos
		touch.pressed = pressed
		Input.parse_input_event(touch)
		await get_tree().process_frame
		await get_tree().process_frame


func test_every_new_button_works_with_a_touch() -> void:
	# RF-143 y RF-462: tocar equivale al clic; todo lo nuevo se hace sin teclado.
	assert_true(ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", true), "RF-143: tocar equivale al clic")
	await _start(7)
	var hud: Hud = game.hud
	# La pestaña «Infraestructura» y «Cañones».
	await _touch_at(hud.bar_tabs.button_of(Hud.TAB_INFRASTRUCTURE).get_global_rect().get_center())
	assert_eq(hud.current_tab(), Hud.TAB_INFRASTRUCTURE, "un toque en la pestaña la abre")
	# Comprar la demoledora con un toque.
	var gold: int = game.session.gold
	await _touch_at(hud.infrastructure_tab._buy_button.get_global_rect().get_center())
	assert_true(game.infrastructure.field.has_machine, "un toque en «Comprar» compra")
	assert_lt(game.session.gold, gold)
	await _touch_at(hud.bar_tabs.button_of(Hud.TAB_CANNONS).get_global_rect().get_center())
	assert_eq(hud.current_tab(), Hud.TAB_CANNONS)
	# Elegir cualquier torre.
	await _touch_at(hud._tower_buttons[2].get_global_rect().get_center())
	assert_eq(game.build_controller.selected_tower(), game.available_towers[2], "un toque elige la torre")
	# La flecha, el diálogo y «Seguir jugando».
	await _touch_at(hud._exit_button.get_global_rect().get_center())
	assert_true(game.exit_dialog.is_open(), "un toque en la flecha abre el diálogo")
	await _touch_at(game.exit_dialog._keep_button.get_global_rect().get_center())
	assert_false(game.exit_dialog.is_open())
	assert_false(game.is_paused())
	await _touch_at(hud._exit_button.get_global_rect().get_center())
	assert_true(game.exit_dialog.is_open())
	await get_tree().process_frame  # un diálogo recién abierto acomoda su texto un cuadro después
	await get_tree().process_frame
	await _touch_at(game.exit_dialog._leave_button.get_global_rect().get_center())
	assert_eq(left_to, ["menu"], "un toque en «Salir al menú» sale")
