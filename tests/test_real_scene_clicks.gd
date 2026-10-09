# T246: lo que los tests de unidad no vieron. Se juega con la escena Game REAL y con eventos de mouse
# reales (movimiento + clic) sobre la casilla, en los niveles oficiales 6, 7, 8 y 9: el panel del
# removible tiene que aparecer. Con M53 (T248) «Infraestructura» es una pestaña de la barra de abajo: tiene que verse,
# no tapar nada y poder pulsarse con un clic real.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SCREEN: Rect2 = Rect2(0, 0, 1280, 720)

var old_index: int
var old_campaign: CampaignData
var old_dev: bool
var old_community: LevelData
var old_path: String
var game: Game
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
	SaveManager.save_path = "user://test_real_scene_clicks.json"
	SaveManager.load_save()
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
	DevMode.enabled = old_dev
	SaveManager.save_path = old_path
	SaveManager.load_save()
	if FileAccess.file_exists("user://test_real_scene_clicks.json"):
		DirAccess.remove_absolute("user://test_real_scene_clicks.json")


## El panel de salida de GUT (`TestOutput`) se queda con los clics de la derecha de la ventana y el juego
## nunca los ve. No pasa en una partida real: se le saca el mouse mientras dura cada test.
func _ignore_gut_panel() -> void:
	for control: Node in get_tree().root.find_children("*", "Control", true, false):
		var ui := control as Control
		if ui.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			_gut_filters[ui] = ui.mouse_filter
			ui.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


func _start(n: int) -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_load(n)] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame


## La posición en pantalla del centro de una casilla (con la cámara, si el mapa tiene zoom).
func _screen_pos(cell: Vector2i) -> Vector2:
	return game.get_viewport().get_canvas_transform() * game.level.cell_center(cell)


## Un movimiento y un clic reales del mouse. `pos` está en coordenadas del juego (1280×720); en la
## ventana de `--headless` (chica) el escalado de «canvas_items» las deforma, así que se convierten
## a coordenadas de ventana con la misma transformación que usa el motor (en una ventana de 1280×720 es la identidad).
func _click_at(pos: Vector2, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var window_pos: Vector2 = get_viewport().get_final_transform() * pos
	var motion := InputEventMouseMotion.new()
	motion.position = window_pos
	motion.global_position = window_pos
	Input.parse_input_event(motion)
	await get_tree().process_frame
	await get_tree().process_frame  # el botón se entera de que el mouse está encima un cuadro después
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = button
		click.pressed = pressed
		click.position = window_pos
		click.global_position = window_pos
		Input.parse_input_event(click)
		await get_tree().process_frame


## Un panel que se acaba de abrir acomoda sus hijos en el cuadro siguiente: hay que dejarlo pasar antes de medir o pulsar.
func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _first_removable(level: LevelData) -> ObstacleSpec:
	for obstacle: ObstacleSpec in level.obstacles:
		if obstacle.kind == ObstacleSpec.Kind.REMOVABLE:
			return obstacle
	return null


# --- (A) La demoledora sale del archivo del nivel ---

func test_official_levels_read_the_machine_flag_from_the_file() -> void:
	assert_false(_load(6).machine_enabled, "el 6 no la tiene")
	assert_true(_load(7).machine_enabled, "el 7 sí: «demoledora»: true en level_07.json")
	for n: int in [8, 9, 10]:
		assert_false(_load(n).machine_enabled, "nivel %d" % n)
	var in_campaign: Array = GameFlow.campaign.levels.filter(func(level: LevelData) -> bool: return level.machine_enabled)
	assert_eq(in_campaign.map(func(level: LevelData) -> String: return str(level.id)), ["level_07"], "la campaña carga solo el 7 con demoledora")


func test_level_7_has_the_infrastructure_tab_and_no_loose_button() -> void:
	# M53 (RF-458): el botón suelto de arriba a la derecha desaparece; la demoledora se compra en la pestaña de abajo.
	await _start(7)
	var hud: Hud = game.hud
	assert_true(game.infrastructure.machine_enabled)
	assert_not_null(hud.bar_tabs, "el nivel 7 usa infraestructura: hay pestañas")
	assert_null(hud.find_child("InfrastructurePanel", true, false), "ya no existe el panel suelto")
	var tab: Button = hud.bar_tabs.button_of(&"infrastructure")
	var rect: Rect2 = tab.get_global_rect()
	assert_true(SCREEN.encloses(rect), "la pestaña entra en la pantalla: %s" % rect)
	for other: Control in [hud._pause_button, hud._speed_button, hud._exit_button, hud._start_wave_button]:
		assert_false(rect.intersects(other.get_global_rect()), "no tapa %s" % other.name)
	# Un clic real en la pestaña la abre; la tarjeta de la demoledora se ve.
	await _click_at(rect.get_center())
	assert_eq(hud.current_tab(), Hud.TAB_INFRASTRUCTURE)
	assert_true(hud.infrastructure_tab.visible)
	assert_false(hud._tower_button_row.visible, "los botones de torre se ocultan")
	assert_true(hud.infrastructure_tab._machine_card.visible)
	var card_rect: Rect2 = hud.infrastructure_tab._machine_card.get_global_rect()
	assert_true(SCREEN.encloses(card_rect), "la tarjeta entra en la pantalla: %s" % card_rect)
	assert_false(card_rect.intersects(hud._start_wave_button.get_global_rect()), "no tapa «Empezar oleada»")
	assert_false(card_rect.intersects(hud._next_wave.get_global_rect()), "no tapa «Próxima oleada»")


func test_level_7_buy_button_buys_the_machine() -> void:
	await _start(7)
	var hud: Hud = game.hud
	var tab: InfrastructureTab = hud.infrastructure_tab
	var price: int = game.infrastructure.field.machine_price()
	assert_gt(game.session.gold, price - 1, "alcanza el oro")
	await _click_at(hud.bar_tabs.button_of(&"infrastructure").get_global_rect().get_center())
	await _settle()
	assert_false(tab._buy_button.disabled)
	var gold: int = game.session.gold
	await _click_at(tab._buy_button.get_global_rect().get_center())
	assert_true(game.infrastructure.field.has_machine, "el clic en «Comprar» compra la demoledora")
	assert_eq(game.session.gold, gold - price)
	assert_eq(tab._machine_title.text, "Demoledora activa")
	assert_false(tab._buy_button.visible, "ya comprada, no hay botón")


func test_the_bar_does_not_move_with_the_zoom_of_big_maps() -> void:
	# El nivel 10 (24×11) se ve con zoom y cámara; el HUD está en otra capa y no los sufre.
	await _start(10)
	assert_not_null(game.camera, "el mapa grande usa cámara con zoom")
	var hud: Hud = game.hud
	var tab: Button = hud.bar_tabs.button_of(&"infrastructure")
	assert_eq(tab.get_global_rect().position, Vector2(12, 674), "la pestaña no se mueve con la cámara")
	assert_eq(hud._exit_button.get_global_rect().position, Vector2(8, 8), "la flecha tampoco")
	await _click_at(tab.get_global_rect().get_center())
	await _settle()
	assert_true(hud.infrastructure_tab.visible, "con zoom, el clic en la pestaña también la abre")
	assert_true(SCREEN.encloses(hud.infrastructure_tab.get_global_rect()))


func test_levels_without_the_machine_have_tabs_but_no_machine_card() -> void:
	for n: int in [6, 8, 9]:
		await _start(n)
		assert_not_null(game.hud.bar_tabs, "nivel %d: usa infraestructura (tiene removibles)" % n)
		assert_false(game.hud.infrastructure_tab._machine_card.visible, "nivel %d: sin demoledora, sin su tarjeta" % n)
		game.queue_free()
		await get_tree().process_frame


# --- (B) Tocar un removible con el mouse muestra su panel ---

func test_clicking_every_removable_shows_its_panel() -> void:
	for n: int in [6, 7, 8, 9, 10]:  # el 10 es de 24×11: se ve con zoom y cámara
		await _start(n)
		var level: LevelData = game.level_data
		for obstacle: ObstacleSpec in level.obstacles:
			if obstacle.kind != ObstacleSpec.Kind.REMOVABLE:
				continue
			game.infrastructure.deselect()
			await _click_at(_screen_pos(obstacle.cell))
			var label: String = "nivel %d, casilla %s" % [n, obstacle.cell]
			assert_eq(game.infrastructure.selected_cell(), obstacle.cell, label + ": se eligió")
			var panel: ObstaclePanel = game.hud.obstacle_panel
			assert_true(panel.visible, label + ": el panel se ve")
			assert_true(SCREEN.encloses(panel.get_global_rect()), label + ": el panel entra en la pantalla %s" % panel.get_global_rect())
			assert_ne(panel._title.text, "", label + ": el panel dice qué es")
		game.queue_free()
		await get_tree().process_frame


func test_clicking_grass_clears_the_panel() -> void:
	await _start(8)
	var obstacle: ObstacleSpec = _first_removable(game.level_data)
	await _click_at(_screen_pos(obstacle.cell))
	assert_true(game.hud.obstacle_panel.visible)
	await _click_at(_screen_pos(Vector2i(0, 8)))
	assert_false(game.hud.obstacle_panel.visible, "un clic en el pasto la cierra")


func test_clicking_a_removable_in_build_mode_and_with_a_wave_running() -> void:
	await _start(8)
	var obstacle: ObstacleSpec = _first_removable(game.level_data)
	# Se elige una torre con el clic real en su botón y después se toca la ruina: se elige el removible, no se construye.
	await _click_at(game.hud._tower_buttons[0].get_global_rect().get_center())
	assert_not_null(game.build_controller.selected_tower(), "el clic en el botón elige la torre")
	await _click_at(_screen_pos(obstacle.cell))
	assert_eq(game.infrastructure.selected_cell(), obstacle.cell, "en modo construcción, la ruina se elige")
	assert_true(game.hud.obstacle_panel.visible)
	assert_eq(game.tower_container.get_child_count(), 0, "no se construyó nada encima")
	# Con una oleada en marcha, también.
	game.infrastructure.deselect()
	game.start_next_wave()
	for i: int in 30:
		await get_tree().process_frame
	await _click_at(_screen_pos(obstacle.cell))
	assert_eq(game.infrastructure.selected_cell(), obstacle.cell, "con una oleada en marcha se elige igual")
	assert_true(game.hud.obstacle_panel.visible)


## Un guardado real ya tiene piezas, avances y niveles ganados: la partida con esos estados también muestra el panel.
func test_clicking_a_removable_with_saved_progress() -> void:
	for sources: Array in [[], ["level_08"], ["level_08", "level_09", "level_10"]]:
		for source: String in sources:
			SaveManager.collect_source(&"disruptor", StringName(source))
		SaveManager.collect_source(&"technology", &"level_03")
		for n: int in [8, 9]:
			await _start(n)
			for obstacle: ObstacleSpec in game.level_data.obstacles:
				game.infrastructure.deselect()
				await _click_at(_screen_pos(obstacle.cell))
				var label: String = "nivel %d, casilla %s, piezas %s" % [n, obstacle.cell, sources]
				assert_eq(game.infrastructure.selected_cell(), obstacle.cell, label)
				assert_true(game.hud.obstacle_panel.visible, label + ": el panel se ve")
				assert_ne(game.hud.obstacle_panel._reward.text, "", label + ": dice qué da")
			game.queue_free()
			await get_tree().process_frame
		SaveManager.load_save()
