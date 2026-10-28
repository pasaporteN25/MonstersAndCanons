# El "director" de la partida (plan §5): carga el nivel y CONECTA las señales
# entre todas las piezas. No calcula daño ni lleva la cuenta del oro:
# eso lo hacen Rules, las torres, los proyectiles y LevelSession.
class_name Game
extends Node2D

## El mapa se dibuja debajo de la barra superior del HUD (plan §2).
const MAP_OFFSET := Vector2(0, 48)
## Sacudida de pantalla al perder vidas (RF-128).
const SHAKE_DURATION: float = 0.25
const SHAKE_STRENGTH_PX: float = 4.0
## RF-316: el sonido del combo suena como mucho una vez cada tantos segundos.
const COMBO_SOUND_GAP: float = 0.15
## RF-105: velocidad rápida.
const FAST_SPEED: float = 2.0
## RF-193: título de la tabla de récords en la pantalla final.
const LEVEL_RECORDS_TITLE: String = "Récords del nivel"
## RF-217: cómo se llama el botón que vuelve al editor cuando se está probando un nivel.
const BACK_TO_EDITOR: String = "Volver al editor"

signal pause_changed(paused: bool)
signal speed_changed(speed: float)
## T478: la capa física recibe el tema una vez resueltos campaña, Asedio, comunidad o editor.
signal level_theme_selected(theme: StringName)
## RF-323: las vidas infinitas cambiaron (con el botón o con el atajo); el panel marca su interruptor.
signal dev_infinite_lives_changed(on: bool)

@export var level_data: LevelData
@export var balance: BalanceConfig
## Torres disponibles, en el orden de los botones y de las teclas 1, 2, 3…
@export var tower_types: Array[TowerData] = []
## RF-300: las torres de la barra en ESTE nivel (las comunes y las reservadas que el nivel habilita).
var available_towers: Array[TowerData] = []
const MECHANICAL_STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")
var collectible: CollectibleRun
## RF-427: las piezas de las ruinas de esta partida (T211).
var findings: FindingRun = FindingRun.new()
var _carrier: Enemy

var level: Level
## RF-251: solo existe si el mapa es más grande que 20×9 (hay que achicar el mundo para que entre).
var camera: Camera2D
var mobile_hud: MobileHud
var camera_controller: CameraController
var minimum_map_zoom: float = 1.0
## RF-217: se está probando el nivel del editor (no hay campaña: no se guarda nada).
var testing: bool = false
## M66 (RF-666 a RF-673): la presentación del jefe, mientras está abierta (null si no), si ya se mostró en esta partida,
## si la partida ya estaba en pausa antes y si la app pasó a segundo plano durante ella (D-112).
var presentation: BossPresentation
var _presentation_shown: bool = false
var _presentation_was_paused: bool = false
var _presentation_interrupted: bool = false
## RF-184: el panel de pruebas. null si no es el modo de pruebas.
var dev_panel: DevPanel
## RF-194: el Salón de la fama, mientras está abierto. null si no.
var hall_of_fame: HallOfFame
## RF-471: el epílogo del último nivel de la campaña (se crea al tocar «Epílogo»).
var epilogue: EpilogueScreen
var _shake_left: float = 0.0
## RF-325: el informe de esta partida de pruebas. null en el juego normal.
var dev_stats: DevStats
var _stats_written: bool = false
## RF-318: alguna torre del mapa aprovecha a los ralentizados / a los quemados.
var _exploit_slowed: bool = false
var _exploit_burning: bool = false
## M70 (RF-631): qué enemigos llegaron a la salida y cuántas vidas quitaron. Se toca solo cuando uno llega.
var leak_log: LeakLog = LeakLog.new()

@onready var tower_container: Node2D = $Towers
@onready var enemies: Node2D = $Enemies
@onready var projectiles: Node2D = $Projectiles
@onready var effects: EffectsLayer = $Effects
@onready var build_controller: BuildController = $BuildController
## RF-404 a RF-409: la demolición directa. Se crea en `_ready`.
var infrastructure: InfrastructureController
var obstacle_layer: ObstacleLayer
@onready var spawner: WaveSpawner = $WaveSpawner
@onready var session: LevelSession = $Session
@onready var hud: Hud = $HUD
@onready var end_screen: EndScreen = $EndScreen
@onready var pause_menu: PauseMenu = $PauseMenu
## RF-460: el diálogo de la flecha «← Menú».
@onready var exit_dialog: ExitDialog = $ExitDialog
## M52 (RF-466): el cartel de entrada del nivel.
@onready var level_intro: LevelIntro = $LevelIntro
## M63 (RF-570): el tutorial del nivel 1. null si esta partida no lo muestra.
var tutorial: TutorialController
## RF-460: si la partida ya estaba en pausa (con `P`) cuando se abrió el diálogo.
var _exit_was_paused: bool = false
var _tool_message: String = ""  # RF-543: por qué no sirvió el último toque de la herramienta de demolición
## Costuras para los tests (`.claude/rules/tests.md`): a dónde sale la flecha. Por omisión, las pantallas de verdad.
var leave_to_menu: Callable = func() -> void: GameFlow.go_to_main_menu()
var leave_to_editor: Callable = func() -> void: GameFlow.go_to_editor()


func _ready() -> void:
	# Si se llegó desde el menú, se juega el nivel elegido; si no (F6, tests), el que ya tenga
	# (el bot lo elige antes) o el primero de la campaña.
	var campaign_level: LevelData = GameFlow.current_level()
	if campaign_level != null:
		level_data = campaign_level
	elif GameFlow.current_community != null:
		level_data = GameFlow.current_community  # RF-224: un mapa de la comunidad
	elif GameFlow.current_mode_level() != null:
		level_data = GameFlow.current_mode_level()  # RF-389: un mapa de un modo, con sus reglas
	elif GameFlow.test_level != null:
		level_data = GameFlow.test_level  # RF-217: el nivel del editor
		testing = true
	elif level_data == null:
		level_data = GameFlow.level(0)
	level_theme_selected.emit(level_data.theme)

	# RF-696, RF-697: el guardado se consulta solo acá y solo en la campaña normal; el resto (comunidad, modos, editor,
	# modo de pruebas, escena suelta) conserva el poste rebelde fijo y no hereda la conquista ni la receta.
	var post_conquered: bool = _is_normal_campaign() and CampaignPosts.is_player_variant(GameFlow.level_stars(GameFlow.current_index))
	var banner_recipe: BannerRecipe = BannerRecipeStore.load_recipe() if post_conquered else null
	# Los postes de 1–15 son del mapa de campaña (con o sin modo de pruebas); lo demás no los lleva.
	var post_cells: Array[Vector2i] = []
	var mark_cells: Dictionary = {}  # T507, RF-717: las marcas siguen la misma regla que los postes
	if campaign_level != null and GameFlow.current_mode.is_empty():
		post_cells = CampaignPosts.cells_for(campaign_level.id)
		mark_cells = CampaignMarks.marks_for(campaign_level.id)
	level = level_data.build_map(post_conquered, banner_recipe, post_cells, mark_cells)
	level.position = Vector2(0.0, float(MobileUiConfig.load_from().get_value("barra_alta_px"))) if UiMode.is_mobile() else MAP_OFFSET
	add_child(level)
	move_child(level, 0)  # primero en la lista = se dibuja debajo de todo
	_fit_map()

	_setup_infrastructure()

	# RF-104: la partida (y la interfaz, que hereda) sigue funcionando en pausa;
	# el "mundo" se congela.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for node: Node in _world_nodes():
		node.process_mode = Node.PROCESS_MODE_PAUSABLE

	spawner.setup(level, enemies, level_data.health_scale_percent(balance), level_data.enemy_health_percent)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	spawner.wave_finished.connect(session.complete_wave)

	_setup_collection()
	_update_collection_notice()
	for support: TowerData in support_catalog():
		if (level_data.extra_towers.has(String(support.id)) or level_data.towers.has(String(support.id)) or (DevMode.enabled and DevMode.support_unlocked)) and not tower_types.has(support):
			tower_types.append(support)
	available_towers = level_data.available_towers(tower_types, SaveManager.collection_complete)
	if DevMode.enabled and DevMode.support_unlocked:
		for support: TowerData in support_catalog():
			if not available_towers.has(support):
				available_towers.append(support)
	build_controller.setup(level, session, balance, available_towers, tower_container)
	if UiMode.is_mobile():
		mobile_hud = MobileHud.new()
		mobile_hud.name = "MobileHUD"
		add_child(mobile_hud)
		mobile_hud.confirm_placement_pressed.connect(build_controller.confirm_ghost)
		mobile_hud.cancel_placement_pressed.connect(build_controller.cancel)
		mobile_hud.exit_pressed.connect(_request_exit)
		mobile_hud.tower_chosen.connect(_on_mobile_tower_chosen)
		mobile_hud.infrastructure_tool_chosen.connect(_on_mobile_infrastructure_tool_chosen)
		mobile_hud.demolish_pressed.connect(_on_mobile_demolish_pressed)
		mobile_hud.catalog_opened.connect(_on_mobile_catalog_opened)
		pause_changed.connect(mobile_hud.set_paused)  # M68 (RF-610): el carrito se apaga en pausa
		hud.tower_panel.hide()
		mobile_hud.upgrade_pressed.connect(_on_mobile_upgrade_pressed)
		mobile_hud.sell_pressed.connect(_on_mobile_sell_pressed)
		mobile_hud.targeting_pressed.connect(_on_targeting_pressed)
		mobile_hud.clear_selection_pressed.connect(build_controller.deselect_placed)
		build_controller.mobile_infrastructure_targeted.connect(_on_mobile_infrastructure_targeted)
		build_controller.mobile_map_tapped.connect(mobile_hud.clear_sell_arm)
		build_controller.mobile_map_tapped.connect(mobile_hud.clear_upgrade_arm)  # M75 (RF-681): tocar el mapa desarma «Mejorar»
		mobile_hud.upgrade_armed_changed.connect(_sync_range_preview.unbind(1))
		_refresh_mobile_catalog()
		session.gold_changed.connect(_on_mobile_catalog_money_changed)
		session.resources_changed.connect(func(_resources: int) -> void: _refresh_mobile_catalog())
	camera_controller = CameraController.new()
	camera_controller.name = "CameraController"
	add_child(camera_controller)
	camera_controller.setup(level, camera, minimum_map_zoom, Callable(self, "_create_interactive_camera"), mobile_hud, UiMode.is_mobile())
	camera_controller.view_zoomed_in.connect(_on_view_zoomed_in)
	if mobile_hud != null:
		mobile_hud.view_all_pressed.connect(camera_controller.view_all)
	build_controller.tower_built.connect(_on_tower_built)
	build_controller.tower_upgraded.connect(_on_tower_upgraded)
	build_controller.tower_sold.connect(_on_tower_sold)
	build_controller.selection_changed.connect(hud.show_selected_tower)
	build_controller.placed_selection_changed.connect(_refresh_tower_panel.unbind(1))

	hud.setup_resources(level_data.uses_resources())  # RF-416: antes de setup_towers
	hud.setup_towers(available_towers)
	hud.setup_waves(level_data.waves)  # RF-133, RF-135: antes de bind()
	hud.tower_button_pressed.connect(build_controller.select)
	hud.payment_pressed.connect(build_controller.set_pay_alt)  # RF-419
	build_controller.payment_changed.connect(hud.show_payment)
	hud.start_wave_pressed.connect(start_next_wave)
	hud.bind(session)

	# RF-70: el panel avisa; BuildController cobra, mejora y vende.
	var panel: TowerPanel = hud.tower_panel
	panel.partner_towers = available_towers  # RF-317: el panel nombra solo las torres de este nivel
	panel.upgrade_pressed.connect(func() -> void: build_controller.try_upgrade(build_controller.selected_placed()))
	panel.sell_pressed.connect(func() -> void: build_controller.sell(build_controller.selected_placed()))
	panel.targeting_pressed.connect(_on_targeting_pressed)
	panel.close_pressed.connect(build_controller.deselect_placed)
	session.gold_changed.connect(panel.refresh)
	panel.upgrade_hover_changed.connect(_sync_range_preview.unbind(1))  # M75 (RF-680): el mouse sobre «Mejorar»
	session.gold_changed.connect(_sync_range_preview.unbind(1))  # sin oro, la ampliación se va
	session.resources_changed.connect(_refresh_tower_panel.unbind(1))  # RF-418: la venta muestra recursos

	session.wave_completed.connect(_collection_wave_completed)
	session.countdown_finished.connect(start_next_wave)
	session.state_changed.connect(_on_state_changed)
	end_screen.retry_pressed.connect(restart)
	end_screen.next_pressed.connect(GameFlow.next_level)
	end_screen.epilogue_pressed.connect(open_epilogue)
	if testing:
		# RF-217: al terminar o salir, se vuelve al editor con el borrador intacto.
		end_screen.levels_pressed.connect(GameFlow.go_to_editor)
		end_screen.set_levels_text(BACK_TO_EDITOR)
	else:
		end_screen.levels_pressed.connect(GameFlow.go_to_level_select)
	end_screen.name_entered.connect(_on_record_name_entered)

	hud.pause_pressed.connect(toggle_pause)
	hud.speed_pressed.connect(toggle_speed)
	pause_changed.connect(hud.show_paused)
	speed_changed.connect(hud.show_speed)

	# RF-114: menú de pausa.
	pause_menu.resume_pressed.connect(close_pause_menu)
	pause_menu.retry_pressed.connect(restart)
	if testing:
		pause_menu.quit_pressed.connect(GameFlow.go_to_editor)
		pause_menu.set_quit_text(BACK_TO_EDITOR)
	else:
		pause_menu.quit_pressed.connect(GameFlow.go_to_main_menu)

	# RF-459 a RF-461: la flecha «← Menú» pregunta antes de salir; probando un mapa del editor vuelve directo.
	hud.menu_pressed.connect(_request_exit)
	exit_dialog.confirmed.connect(_on_exit_confirmed)
	exit_dialog.cancelled.connect(_on_exit_cancelled)
	if testing:
		hud.set_exit_text("← Editor", "Volver al editor")

	# RF-116: sonidos de la partida (los disparos, al construir cada torre).
	session.wave_changed.connect(func(wave: int, _total: int) -> void:
		if wave > 0:
			Audio.play(&"wave_start"))
	Audio.add_click_sounds(hud)
	Audio.add_click_sounds(end_screen)

	session.start(level_data, balance)
	_apply_dev_start()
	_start_dev_stats()
	if DevMode.enabled:
		_add_dev_panel()
	_open_intro_if_pending()
	_start_tutorial_if_due()


## RF-404 a RF-409: el controlador de la demolición, su vista y el panel del HUD. El sorteo del drop
## usa un generador propio con semilla (RF-417): nueva en cada partida, o `GameFlow.forced_seed`.
func _setup_infrastructure() -> void:
	var rng := RandomNumberGenerator.new()
	if GameFlow.forced_seed >= 0:
		rng.seed = GameFlow.forced_seed
	else:
		rng.randomize()
	infrastructure = InfrastructureController.new()
	infrastructure.name = "Infrastructure"
	add_child(infrastructure)
	infrastructure.setup(level, session, level_data.obstacles, rng, effects, _recovered_collections(), level_data.id,
		level_data.machine_enabled, _collects_pieces())
	infrastructure.demolished.connect(_on_obstacle_demolished)
	hud.setup_bar(level_data.uses_infrastructure())  # RF-454: las pestañas, solo si el nivel usa infraestructura
	obstacle_layer = ObstacleLayer.new()
	obstacle_layer.name = "ObstacleLayer"
	add_child(obstacle_layer)
	obstacle_layer.setup(infrastructure, level)
	(level.get_node("Decor") as LevelDecor).bind_field(infrastructure.field)
	build_controller.obstacles = infrastructure
	var panel: ObstaclePanel = hud.obstacle_panel
	panel.demolish_pressed.connect(infrastructure.order)
	panel.cancel_pressed.connect(infrastructure.cancel_job)
	panel.enable_pressed.connect(infrastructure.enable)
	infrastructure.selection_changed.connect(_refresh_obstacle_panel.unbind(1))
	infrastructure.changed.connect(_refresh_obstacle_panel)
	if hud.infrastructure_tab != null:  # RF-457: las tarjetas llaman a lo mismo que el panel del objeto
		var tab: InfrastructureTab = hud.infrastructure_tab
		tab.buy_pressed.connect(infrastructure.buy_machine)
		tab.cancel_pressed.connect(infrastructure.cancel_job)
		tab.enable_pressed.connect(infrastructure.enable)
		tab.site_selected.connect(_on_site_selected)
		hud.tab_changed.connect(_on_tab_changed)
		infrastructure.changed.connect(_refresh_infrastructure_tab)
		session.resources_changed.connect(_refresh_infrastructure_tab.unbind(1))
		_refresh_infrastructure_tab()


func _on_mobile_catalog_opened(open: bool) -> void:
	build_controller.input_blocked = open
	if open:
		_refresh_mobile_catalog()


func _on_mobile_tower_chosen(index: int, use_alt_payment: bool) -> void:
	build_controller.select(index, use_alt_payment)


func _on_mobile_infrastructure_tool_chosen(tool: StringName, _class_id: StringName) -> void:
	if tool == &"machine":
		infrastructure.buy_machine()


## RF-542: el botón de demolición elige la herramienta; tocarlo de nuevo la suelta.
func _on_mobile_demolish_pressed() -> void:
	_tool_message = ""
	if build_controller.mobile_action_active():
		build_controller.cancel()
	else:
		build_controller.select_mobile_infrastructure_tool(&"obstacle")


## RF-542: la herramienta reconoce el objeto tocado. Si la acción sale bien, se suelta sola; si no, queda
## elegida y la barra dice el motivo (RF-543).
func _on_mobile_infrastructure_targeted(cell: Vector2i, _tool: StringName, _class_id: StringName) -> void:
	var spec: ObstacleSpec = infrastructure.obstacle_at(cell)
	if spec == null:
		_tool_message = "Ahí no hay nada para demoler ni habilitar"
		return
	var field: ObstacleField = infrastructure.field
	var removable: bool = spec.kind == ObstacleSpec.Kind.REMOVABLE
	var reason: StringName = field.can_order(cell) if removable else field.can_enable(cell)
	var cost: int = field.cost_of(cell)
	_tool_message = ""
	if reason == &"busy":
		_tool_message = "Ya hay una demolición en curso"
	elif reason == &"active":
		_tool_message = "El punto ya está activo"
	elif reason == &"depleted":
		_tool_message = "El punto está agotado"
	elif reason != &"":
		_tool_message = "No se puede usar ahí"
	elif session.gold < cost:
		_tool_message = "Faltan %d de oro" % (cost - session.gold)
	if _tool_message != "":
		return
	var completed: bool = infrastructure.order(cell) if removable else infrastructure.enable(cell)
	if completed:
		build_controller.cancel()
	else:
		_tool_message = "No se pudo"


func _on_mobile_catalog_money_changed(_gold: int) -> void:
	_refresh_mobile_catalog()


func _refresh_mobile_catalog() -> void:
	if mobile_hud == null:
		return
	# Cerrado y ya armado: no se reconstruye nada; al abrirlo, catalog_opened vuelve a llamar acá (T290, H-04).
	if mobile_hud.is_catalog_populated() and not mobile_hud.is_catalog_open():
		return
	mobile_hud.set_catalog_data(available_towers, session.gold, session.resources,
		level_data.uses_resources(), _mobile_machine_option())


## RF-542: ¿este nivel tiene algo para demoler o habilitar? (si no, no hay botón de demolición)
func _has_demolition_targets() -> bool:
	return level_data != null and not level_data.obstacles.is_empty()


## RF-540: la compra de la Demoledora es la última tarjeta del catálogo ({} si el nivel no la ofrece o ya la tiene).
func _mobile_machine_option() -> Dictionary:
	if level_data == null or infrastructure == null:
		return {}
	if not infrastructure.machine_enabled or infrastructure.field.has_machine:
		return {}
	var machine_price: int = infrastructure.field.machine_price()
	var machine_reason: String = "Faltan %d de oro" % (machine_price - session.gold) if session.gold < machine_price else ""
	return {"tool": &"machine", "name": "Demoledora", "cost_text": "%d de oro" % machine_price,
		"disabled_reason": machine_reason, "icon": null}


## Muestra en el panel el removible elegido (o lo oculta si no hay ninguno).
func _refresh_obstacle_panel() -> void:
	var cell: Vector2i = infrastructure.selected_cell()
	var spec: ObstacleSpec = infrastructure.obstacle_at(cell)
	if spec == null:
		hud.obstacle_panel.show_obstacle(null, ObstacleField.State.INTACT, false, session.gold, 0.0, false)
		return
	var field: ObstacleField = infrastructure.field
	var job: DemolitionJob = field.job()
	hud.obstacle_panel.show_obstacle(spec, field.state_of(cell), field.has_job() and job.cell != cell,
			session.gold, 0.0 if job == null else job.seconds_left(), field.finding_recovered(cell),
			job.paid if job != null and job.cell == cell else field.cost_of(cell),
			field.seconds_of(cell), field.cost_with_machine(cell) if infrastructure.machine_enabled and not field.has_machine else -1,
			field.reserve_left(cell), _collects_pieces())


## RF-457 y RF-458: alimenta las cuatro tarjetas de «Infraestructura» y el aviso del título, leyendo lo que ya
## expone el controlador. La pestaña no guarda nada propio.
func _refresh_infrastructure_tab() -> void:
	var tab: InfrastructureTab = hud.infrastructure_tab
	if tab == null:
		return
	var field: ObstacleField = infrastructure.field
	var job: DemolitionJob = field.job()
	if job != null:
		tab.show_job(ObstacleText.display_name(field.spec_at(job.cell)), job.progress(), job.seconds_left())
	else:
		tab.clear_job()
	hud.show_job_badge(0.0 if job == null else job.seconds_left(), job != null)
	tab.show_machine(infrastructure.machine_enabled, field.has_machine, field.machine_price(), session.gold,
			InfrastructureText.machine_effect())
	tab.show_sites(InfrastructureText.sites(field), session.gold)
	tab.show_resources(hud.shows_resources(), session.resources, InfrastructureText.expected_resources(field))


## RF-458: tocar el nombre de un punto lo elige en el mapa, igual que tocarlo allá (una sola selección, RF-73).
func _on_site_selected(cell: Vector2i) -> void:
	build_controller.cancel()
	build_controller.deselect_placed()
	infrastructure.select(cell)


## RF-456: pasar a «Infraestructura» con una torre elegida para construir cancela la construcción (la vista previa
## no puede quedar sobre el mapa con sus botones ocultos). Una torre ya colocada o un objeto elegido siguen igual.
func _on_tab_changed(id: StringName) -> void:
	if id != Hud.TAB_CANNONS:
		build_controller.cancel()


## RF-251: un mapa más grande que 20×9 se muestra con zoom, con una cámara. Una cámara no cambia
## las coordenadas del mundo (alcances, disparos y la casilla bajo el mouse valen lo mismo, D-037).
func _fit_map() -> void:
	var size: Vector2i = level.map_size()
	var zoom: float = Rules.map_zoom(size.x, size.y)
	_add_theme_backdrop()
	if UiMode.is_mobile():
		var mobile_config: MobileUiConfig = MobileUiConfig.load_from()
		var top_height: float = float(mobile_config.get_value("barra_alta_px"))
		var bottom_height: float = float(hud.get_node("BottomBar").size.y)
		zoom = minf(1.0, minf(Rules.SCREEN_SIZE.x / (size.x * Rules.TILE_SIZE), (Rules.SCREEN_SIZE.y - top_height - bottom_height) / (size.y * Rules.TILE_SIZE)))
	minimum_map_zoom = zoom
	if zoom >= 1.0:
		return
	camera = Camera2D.new()
	camera.zoom = Vector2(zoom, zoom)
	var top_height: float = float(MobileUiConfig.load_from().get_value("barra_alta_px")) if UiMode.is_mobile() else 48.0
	var area := Rect2(0.0, top_height, Rules.SCREEN_SIZE.x, Rules.SCREEN_SIZE.y - top_height - float(hud.get_node("BottomBar").size.y))
	var map_center: Vector2 = level.position + Vector2(size) * Rules.TILE_SIZE / 2.0
	camera.position = map_center + (Rules.SCREEN_SIZE / 2.0 - area.get_center()) / zoom
	add_child(camera)
	camera.make_current()


func _add_theme_backdrop() -> void:
	var backdrop_layer: CanvasLayer = CanvasLayer.new()
	backdrop_layer.name = "ThemeBackdrop"
	backdrop_layer.layer = -10
	add_child(backdrop_layer)
	var solid: ColorRect = ColorRect.new()
	solid.name = "SolidFallback"
	solid.color = PresentationBackgroundCatalog.FALLBACK_COLOR
	solid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	solid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop_layer.add_child(solid)
	var texture: Texture2D = PresentationBackgroundCatalog.load_for_theme(level.theme)
	if texture == null:
		return
	var backdrop: TextureRect = TextureRect.new()
	backdrop.name = "ThemeImage"
	backdrop.texture = texture
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop_layer.add_child(backdrop)


func _create_interactive_camera() -> Camera2D:
	if camera != null:
		return camera
	camera = Camera2D.new()
	camera.zoom = Vector2.ONE * minimum_map_zoom
	var size: Vector2i = level.map_size()
	var top_height: float = float(MobileUiConfig.load_from().get_value("barra_alta_px")) if UiMode.is_mobile() else 48.0
	var bottom_height: float = float(hud.get_node("BottomBar").size.y)
	var area := Rect2(0.0, top_height, Rules.SCREEN_SIZE.x, Rules.SCREEN_SIZE.y - top_height - bottom_height)
	var map_center: Vector2 = level.position + Vector2(size) * Rules.TILE_SIZE / 2.0
	camera.position = map_center + (Rules.SCREEN_SIZE / 2.0 - area.get_center()) / minimum_map_zoom
	add_child(camera)
	camera.make_current()
	return camera


func _process(delta: float) -> void:
	if mobile_hud != null:
		mobile_hud.set_game_over(session.is_over())
		mobile_hud.set_cart_active(build_controller.selected_tower() != null or build_controller.selected_placed() != null)
		mobile_hud.set_demolish_available(_has_demolition_targets())
		mobile_hud.set_demolish_active(build_controller.mobile_action_active())
		var selected_tower: TowerData = build_controller.selected_tower()
		var tool_active: bool = build_controller.mobile_action_active()
		if not tool_active:
			_tool_message = ""
		hud.set_mobile_wave_controls_visible(selected_tower == null and build_controller.selected_placed() == null and not tool_active)
		if selected_tower == null:
			mobile_hud.set_placement_visible(false)
			var placed: Tower = build_controller.selected_placed()
			var refund: int = build_controller.sell_value(placed) if placed != null else 0
			var resource_refund: int = build_controller.sell_resource_value(placed) if placed != null else 0
			var can_improve: bool = placed != null and build_controller.can_upgrade(placed)
			var unavailable_reason: String = ""
			if placed != null and placed.can_upgrade() and session.gold < placed.next_level_stats().cost:
				unavailable_reason = "Faltan %d de oro" % (placed.next_level_stats().cost - session.gold)
			if placed == null and tool_active:
				mobile_hud.show_tool_status(_tool_message)
			else:
				mobile_hud.show_selected_tower(placed, session.gold, refund, resource_refund,
					can_improve, unavailable_reason)
		else:
			mobile_hud.show_ghost_status(selected_tower.display_name, TowerText.cost_text(selected_tower, build_controller.pay_alt()))
			var ghost: GhostPlacement = build_controller.ghost_placement()
			var ghost_world_pos: Vector2 = level.cell_center(ghost.cell)
			var zoom: float = camera.zoom.x if camera != null else minimum_map_zoom
			var ghost_size: Vector2 = Vector2.ONE * Rules.TILE_SIZE * selected_tower.footprint * zoom
			mobile_hud.show_placement(ghost_world_pos, TowerText.cost_text(selected_tower, build_controller.pay_alt()), ghost.valid, ghost.reason, ghost_size)
	if dev_stats != null and not get_tree().paused and not session.is_over():
		dev_stats.seconds += delta  # RF-325: tiempo de juego, sin pausa
	# RF-128: se mueve todo el "mundo"; el HUD está en otra capa y no se sacude.
	if _shake_left <= 0.0:
		return
	_shake_left -= delta
	if _shake_left <= 0.0:
		position = Vector2.ZERO
	else:
		var strength: float = SHAKE_STRENGTH_PX * _shake_left / SHAKE_DURATION
		position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength


## RF-544: al pasar la app a segundo plano (una llamada, el botón de inicio, otra app) la partida se pausa sola.
## `APPLICATION_PAUSED` es el aviso de Android; `APPLICATION_FOCUS_OUT` solo cuenta en un dispositivo móvil:
## en una PC, perder el foco de la ventana no pausa (no cambia nada para quien juega en la computadora).
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		pause_for_background()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and OS.has_feature("mobile"):
		pause_for_background()


## Deja la partida en pausa (la misma de RF-104: se sigue con el botón Pausa). No hace nada si ya está en pausa
## (un menú, un diálogo o el cartel de entrada ya la pausaron) ni si la partida terminó.
func pause_for_background() -> void:
	if presentation != null:
		_presentation_interrupted = true  # M66, RF-673 (D-112): al cerrarse la presentación no se reanuda sola
	if session == null or session.is_over() or is_paused():
		return
	set_paused(true)


## Al salir de la partida (reintentar, cerrar, o un test que la borra) nunca debe
## quedar el juego en pausa ni acelerado (RF-105, plan §6.7).
func _exit_tree() -> void:
	_write_dev_stats(DevStats.RESULT_LEFT)  # si la partida ya terminó, no pisa su informe
	DevMode.collections_unlocked = false  # RF-436: la habilitación dura solo esta partida.
	_reset_time()


## RF-456: `Tab` cambia de pestaña. Va en `_input` y no en `_unhandled_input` para que el foco de la interfaz
## (los íconos de arriba lo aceptan) no se lo quede para moverse entre controles.
func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("switch_tab") or not hud.has_tabs():
		return
	if exit_dialog.is_open() or pause_menu.is_open() or level_intro.is_open() or session.is_over():
		return  # con un diálogo abierto o la partida terminada, no hace nada
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return  # escribiendo en un campo (el panel de pruebas): Tab es de ese campo
	hud.switch_tab()
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if dev_panel != null and key != null and key.pressed and not key.echo and key.physical_keycode == KEY_F1:
		dev_panel.toggle()  # RF-184
		get_viewport().set_input_as_handled()
		return
	# BuildController recibe Esc primero (cancelar construcción o selección);
	# si nadie lo usó, llega aquí y abre o cierra el menú de pausa (RF-114).
	if event.is_action_pressed("cancel"):
		if exit_dialog.is_open():
			exit_dialog.handle_cancel()  # RF-461: Esc cierra el diálogo; el menú de pausa no se abre debajo
		elif pause_menu.is_open():
			pause_menu.handle_cancel()
		else:
			open_pause_menu()
	elif pause_menu.is_open() or exit_dialog.is_open() or level_intro.is_open():
		return  # con el menú o el diálogo abiertos, las otras teclas no hacen nada
	elif dev_panel != null and _handle_dev_shortcut(event):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("start_wave"):
		start_next_wave()
	elif event.is_action_pressed("pause"):
		toggle_pause()
	elif event.is_action_pressed(ViewAllBinding.ACTION):
		camera_controller.view_all()  # M68 (RF-613): también en pausa, la cámara no cambia la partida
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_speed"):
		toggle_speed()


## RF-676: el aviso dice «Acercaste», así que solo responde a un zoom que aumenta el acercamiento.
func _on_view_zoomed_in() -> void:
	if SaveManager.get_ui_prefs().view_all_hint_seen or tutorial != null and tutorial.is_active():
		return
	if pause_menu.is_open() or exit_dialog.is_open() or level_intro.is_open() or session.is_over() or presentation != null:
		return
	if hud.is_notice_active():
		return
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	var message: String
	if UiMode.is_mobile():
		message = "Acercaste el mapa. Tocá la lupa para volver a verlo entero."
	else:
		message = "Acercaste el mapa. Apretá %s para volver a verlo entero." % ViewAllBinding.key_text(prefs.view_all_key)
	hud.show_view_all_notice(message)
	prefs.view_all_hint_seen = true
	SaveManager.set_ui_prefs(prefs)


# --- Menú de pausa (RF-114) ---

func open_pause_menu() -> void:
	if session.is_over():
		return
	build_controller.cancel()
	build_controller.deselect_placed()
	infrastructure.deselect()
	set_paused(true)
	hud.show_paused(true, false)  # el menú ya dice "Pausa"
	pause_menu.open()
	if mobile_hud != null:
		mobile_hud.set_modal_open(true)


func close_pause_menu() -> void:
	pause_menu.close()
	set_paused(false)
	if mobile_hud != null:
		mobile_hud.set_modal_open(false)


# --- El cartel de entrada (M52, RF-466 a RF-468) ---

## RF-468: ¿esta partida muestra los textos del nivel (cartel y victoria)? La campaña, siempre; un mapa de la
## comunidad o de un modo propio, solo si su archivo los trae (si no, los textos están vacíos y no hay nada que
## mostrar). No los muestran el modo de pruebas, probar desde el editor ni los modos oficiales (Asedio).
func shows_texts() -> bool:
	if DevMode.enabled or testing:
		return false
	return GameFlow.current_mode.is_empty() or not bool(GameFlow.current_mode.get("official", false))


## RF-466: si se llegó eligiendo el nivel (`GameFlow.intro_pending`) y trae `"entrada"`, abre el cartel y la partida
## espera. El aviso se consume siempre: «Reintentar» recarga la escena y no lo vuelve a encender.
func _open_intro_if_pending() -> void:
	var pending: bool = GameFlow.intro_pending
	GameFlow.intro_pending = false
	level_intro.closed.connect(_on_intro_closed)
	if not pending or not shows_texts() or level_data.intro_text == "":
		return
	build_controller.cancel()
	build_controller.input_blocked = true  # leer no cuesta tiempo ni deja construir
	set_paused(true)
	hud.show_paused(true, false)  # el cartel no es el menú de pausa: no dice «PAUSA»
	level_intro.open(level_data.display_name, level_data.place_text, level_data.intro_text, level_data.theme)
	if mobile_hud != null:
		mobile_hud.set_modal_open(true)


## Al cerrarlo la partida sigue exactamente como estaba: la misma cuenta atrás, a la misma velocidad.
func _on_intro_closed() -> void:
	build_controller.input_blocked = false
	set_paused(false)
	if mobile_hud != null:
		mobile_hud.set_modal_open(false)


# --- El tutorial del nivel 1 (M63, RF-570 a RF-577) ---

## RF-570: si esta partida es la del nivel 1 jugada desde el menú (no el modo de pruebas ni el editor) y el jugador
## no lo desactivó ni lo completó antes, arma el tutorial. Empieza al cerrarse el cartel de entrada (si lo hay).
## Un archivo con errores no se muestra: el nivel se juega como siempre y el error sale por la salida.
func _start_tutorial_if_due() -> void:
	if testing or DevMode.enabled or GameFlow.current_level() == null or SaveManager.tutorial_done() \
			or not SaveManager.tutorial_enabled():
		return  # lo barato primero: así el archivo solo se lee cuando hace falta
	var data: TutorialData = TutorialData.load_file()
	if not data.is_valid():
		push_warning("El tutorial no se muestra: %s" % "; ".join(data.errors))
		return
	if not TutorialFlow.should_auto_show(SaveManager.tutorial_enabled(), SaveManager.tutorial_done(), DevMode.enabled, testing,
			String(level_data.id) == data.level_id, data.is_valid()):
		return
	tutorial = TutorialController.new()
	tutorial.name = "Tutorial"
	add_child(tutorial)
	tutorial.setup(self, data)
	if level_intro.is_open():
		level_intro.closed.connect(tutorial.begin, CONNECT_ONE_SHOT)
	else:
		tutorial.begin()


# --- La flecha «← Menú» (RF-459 a RF-461) ---

## Las piezas de colección que se perderían: una entrada por pieza, con el id de su colección. Cuentan las
## pendientes y las ya confirmadas, porque las dos se guardan recién al mostrar el resultado (RF-359, RF-427).
func lost_pieces() -> Array[String]:
	var collections: Array[String] = []
	for piece: Dictionary in findings.pending() + findings.confirmed():
		collections.append(String(piece["collection"]))
	if collectible != null and collectible.picked_wave > 0:
		collections.append(String(collectible.collection))
	return collections


## El texto del diálogo para el estado actual de la partida.
func exit_message() -> String:
	return ExitText.message(lost_pieces(), infrastructure.field.has_job())


## RF-460: pregunta qué se pierde y pausa la partida. Probando desde el editor no se pierde nada: vuelve directo.
func _request_exit() -> void:
	if session.is_over() or exit_dialog.is_open() or pause_menu.is_open():
		return
	if testing:
		leave_to_editor.call()
		return
	build_controller.cancel()
	build_controller.deselect_placed()
	infrastructure.deselect()
	_exit_was_paused = is_paused()
	build_controller.input_blocked = true
	set_paused(true)
	hud.show_paused(true, false)  # el diálogo ya cubre la pantalla
	exit_dialog.open(exit_message())
	if mobile_hud != null:
		mobile_hud.set_modal_open(true)


## «Seguir jugando» o Esc: la partida vuelve al estado anterior (corriendo a la misma velocidad, o en pausa si ya lo estaba).
func _on_exit_cancelled() -> void:
	build_controller.input_blocked = false
	set_paused(_exit_was_paused)
	if mobile_hud != null:
		mobile_hud.set_modal_open(false)


## «Salir al menú»: no se guarda nada (ni piezas ni progreso ni récords), así que no se llama a `_commit_collection()`.
func _on_exit_confirmed() -> void:
	build_controller.input_blocked = false
	leave_to_menu.call()


# --- Pausa y velocidad (RF-104, RF-105) ---

func is_paused() -> bool:
	return get_tree().paused


func set_paused(paused: bool) -> void:
	if session.is_over() and paused:
		return  # con la partida terminada no hay nada que pausar
	get_tree().paused = paused
	if paused:
		build_controller.cancel()  # en pausa no se construye
	pause_changed.emit(paused)


func toggle_pause() -> void:
	if pause_menu.is_open():
		return  # desde el menú de pausa se sale con "Continuar" o Esc
	set_paused(not is_paused())


func set_speed(speed: float) -> void:
	Engine.time_scale = speed
	DevMode.show_speed(speed)  # RF-322: el cartel del modo de pruebas dice la velocidad
	speed_changed.emit(speed)


func toggle_speed() -> void:
	# RF-105 y RF-322: desde x1 pasa a x2; desde cualquier otra velocidad (las del modo de pruebas) vuelve a x1.
	set_speed(FAST_SPEED if is_equal_approx(Engine.time_scale, 1.0) else 1.0)


func _reset_time() -> void:
	Engine.time_scale = 1.0
	DevMode.show_speed(1.0)
	if is_inside_tree():
		get_tree().paused = false


## Las partes del mundo que se congelan en pausa y al terminar la partida.
func _world_nodes() -> Array[Node]:
	return [level, tower_container, enemies, projectiles, effects, spawner, session, infrastructure, obstacle_layer]


## RF-32 y RF-34: la oleada empieza con el botón, con Espacio o al terminar la cuenta atrás.
func start_next_wave() -> void:
	if not session.can_start_wave():
		return
	var wave_number: int = session.begin_wave()
	spawner.start_wave(level_data.waves[wave_number - 1], wave_number)


## RF-92: reinicia el nivel desde cero recargando la escena.
func restart() -> void:
	_reset_time()
	GameFlow.reload_current()  # RF-584: con pantalla de carga


# --- Modo de pruebas (RF-184): lo que hace cada botón del panel ---

## RF-319 y RF-320: en el modo de pruebas, la partida de la campaña o de la comunidad arranca en la
## oleada y con el oro que se eligieron en la selección de nivel. El nivel del editor, F6 y los
## tests quedan como siempre.
func _apply_dev_start() -> void:
	DevMode.applied_wave = 1
	var from_menu: bool = GameFlow.current_level() != null or GameFlow.current_community != null \
		or GameFlow.current_mode_level() != null
	if not DevMode.enabled or testing or not from_menu:
		return
	var wave: int = DevStart.clamp_wave(DevMode.start_wave, level_data.waves.size())
	session.jump_to_wave(wave)
	session.set_gold(DevStart.start_gold(level_data, balance, wave, DevMode.start_gold))
	DevMode.applied_wave = wave


## RF-325: empieza a juntar el informe de la partida (solo en el modo de pruebas).
func _start_dev_stats() -> void:
	if not DevMode.enabled:
		return
	dev_stats = DevStats.new()
	dev_stats.begin(String(level_data.id), DevMode.applied_wave)
	session.wave_completed.connect(func(wave: int, _bonus: int) -> void:
		dev_stats.record_wave(wave, session.lives, session.gold, _tower_count()))


## Torres en el mapa (sin contar las que se están vendiendo).
func _tower_count() -> int:
	var count: int = 0
	for node: Node in tower_container.get_children():
		if not node.is_queued_for_deletion():
			count += 1
	return count


## RF-325: escribe el informe una sola vez por partida (al terminar, o al salir si no terminó).
func _write_dev_stats(result: String) -> void:
	if dev_stats == null or _stats_written or not DevMode.enabled:  # sin modo de pruebas (ya apagado) no hay informe
		return
	_stats_written = true
	DevMode.write_stats(dev_stats.to_dict(result, session.wave, session.total_waves, session.lives,
			session.gold, _tower_count()))


func _add_dev_panel() -> void:
	dev_panel = DevPanel.new().setup(self)
	hud.add_child(dev_panel)
	dev_panel.metrics_toggled.connect(hud.show_metrics)
	var button := Button.new()
	button.text = "Pruebas [F1]"
	button.focus_mode = Control.FOCUS_NONE
	button.position = Vector2(880, 8)
	button.size = Vector2(126, 32)
	button.pressed.connect(dev_panel.toggle)
	hud.get_node("TopBar").add_child(button)


func dev_add_gold() -> void:
	session.earn(DevMode.config.gold_step)  # RF-324: el número vive en data/dev_config.tres


## RF-436: suma recursos solo a la sesión actual.
func dev_add_resources() -> void:
	if DevMode.enabled and not session.is_over():
		hud.setup_resources(true)
		session.add_resources(10)


## RF-436: avanza el trabajo por el mismo camino que una demolición normal.
func dev_finish_demolition() -> void:
	if not DevMode.enabled or session.is_over() or not infrastructure.field.has_job():
		return
	var job: DemolitionJob = infrastructure.field.job()
	infrastructure.field.tick(job.seconds_left())


func dev_set_infinite_lives(on: bool) -> void:
	session.infinite_lives = on
	dev_infinite_lives_changed.emit(on)


## Los enemigos desaparecen sin morir: no dan oro ni puntos ni sueltan crías.
func dev_kill_all() -> void:
	for node: Node in enemies.get_children():
		(node as Enemy).vanish()


## Termina la oleada en curso (o empieza la siguiente y la termina): no salen más enemigos
## y desaparecen los que hay. La oleada se completa como siempre (con su bono de oro).
func dev_skip_wave() -> void:
	if session.is_over():
		return
	if session.state != LevelSession.State.WAVE_RUNNING:
		start_next_wave()
	spawner.skip_rest_of_wave()
	dev_kill_all()


func dev_finish(won: bool) -> void:
	spawner.skip_rest_of_wave()
	dev_kill_all()
	session.finish(won)


## RF-323: los atajos del modo de pruebas hacen lo mismo que los botones del panel. Devuelve true si
## la tecla era uno de ellos.
func _handle_dev_shortcut(event: InputEvent) -> bool:
	if event.is_action_pressed(&"dev_kill_all"):
		dev_kill_all()
	elif event.is_action_pressed(&"dev_skip_wave"):
		dev_skip_wave()
	elif event.is_action_pressed(&"dev_infinite_lives"):
		dev_set_infinite_lives(not session.infinite_lives)
	elif event.is_action_pressed(&"dev_slower"):
		dev_set_speed(DevStart.step_speed(DevMode.config.speeds, Engine.time_scale, -1))
	elif event.is_action_pressed(&"dev_faster"):
		dev_set_speed(DevStart.step_speed(DevMode.config.speeds, Engine.time_scale, 1))
	else:
		return false
	return true


## RF-322: una de las cinco velocidades del panel (o de los atajos).
func dev_set_speed(speed: float) -> void:
	set_speed(speed)


func dev_spawn(data: EnemyData) -> void:
	spawner.spawn_now(data)


func _on_enemy_spawned(enemy: Enemy) -> void:
	if collectible != null and bool(enemy.get_meta("original_spawn", false)) and collectible.next_enemy_is_carrier():
		_carrier = enemy
	enemy.died.connect(_on_enemy_died)
	enemy.charged_impact.connect(func(_rammer: Enemy, tower: Tower) -> void:
		var text := FloatingText.new().setup("¡Desgaste!", Color(1,0.67,0.27), 18, 0.7, 30.0)
		text.position = tower.global_position + Vector2(0,-20)
		effects.add_child(text)
		Audio.play(&"impact", 0.2))
	enemy.gold_drain.connect(func(thief: Enemy, amount: int, floor_gold: int) -> void:
		var taken: int = session.steal(amount, floor_gold)
		if taken > 0:
			effects.gold_stolen(thief.global_position, taken))
	enemy.cast_stun.connect(func(shaman: Enemy, tower: Tower) -> void:
		effects.stun_bolt(shaman.global_position, tower.global_position)
		Audio.play(&"stun", 0.2))  # RF-282
	enemy.reflected.connect(func(mirror: Enemy, tower: Tower, first: bool) -> void:
		effects.reflect(mirror.global_position, tower.global_position, first)
		Audio.play(&"reflect", 0.15))  # RF-284
	enemy.reached_exit.connect(_on_enemy_reached_exit)
	enemy.hit.connect(_on_enemy_hit)
	enemy.set_exploitable(_exploit_slowed, _exploit_burning)  # RF-318
	enemy.healed.connect(func(e: Enemy, amount: int) -> void:
		effects.heal_number(e.global_position, amount)
		Audio.play(&"heal", 0.8))  # RF-165
	_maybe_boss_presentation(enemy)  # M66: antes de marcarlo visto, que decide si dura 5 s o 3 s
	# RF-134: la primera vez en todo el juego que aparece este tipo, se presenta. Un jefe (peligroso, RF-135) no lleva
	# la tarjeta: la presentación y la línea «¡Llega el Jefe!» ya lo presentan (Lucas, 2026-10-23); igual
	# queda como visto para la Wiki y el guardado, aunque la presentación se omita o se saltee.
	if not SaveManager.has_seen_enemy(enemy.data.id):
		SaveManager.mark_enemy_seen(enemy.data.id)
		if not Rules.is_dangerous(enemy.data):
			hud.show_enemy_intro(enemy.data)
		if GameFlow.played_level() != null:
			SaveManager.save()  # RF-117: solo jugando desde el menú (campaña o comunidad)


## M66, RF-666: ¿esta partida es de la campaña normal, jugada desde el menú? No lo son Asedio ni los modos, el modo
## de pruebas, probar desde el editor, los mapas de la comunidad ni la escena suelta (F6, tests, `balance_sim`).
func _is_normal_campaign() -> bool:
	if DevMode.enabled or testing or not GameFlow.current_mode.is_empty() or GameFlow.current_community != null:
		return false
	var campaign: LevelData = GameFlow.current_level()
	return campaign != null and level_data != null and campaign.id == level_data.id


## M66, RF-666 a RF-673: si nace un jefe y corresponde, la partida se pausa en este mismo cuadro (el enemigo no se
## demora ni cambia) y se abre la presentación a pantalla completa. Una vez por partida: la primera oleada con jefe.
## Va ANTES de marcar al enemigo como visto: la duración depende de si ya se había visto (RF-668).
func _maybe_boss_presentation(enemy: Enemy) -> void:
	if not Rules.is_dangerous(enemy.data):
		return  # lo barato primero: casi todos los enemigos salen acá
	if not BossPresentationRules.is_eligible(true, SaveManager.boss_entrance_enabled(), _is_normal_campaign(),
			_presentation_shown or presentation != null) or session.is_over():
		return
	_presentation_shown = true
	_presentation_was_paused = is_paused()
	_presentation_interrupted = false
	build_controller.cancel()
	build_controller.input_blocked = true
	set_paused(true)
	hud.show_paused(true, false)  # la presentación no es el menú de pausa: no dice «PAUSA»
	hud.set_presentation_active(true)  # RF-670, RF-673: el cartel de oleada y las tarjetas se congelan
	if mobile_hud != null:
		mobile_hud.set_modal_open(true)
	presentation = BossPresentation.new().setup(enemy.data,
			BossPresentationRules.seconds(SaveManager.has_seen_enemy(enemy.data.id)), mobile_hud != null,
			null, BossPresentationArt.backdrop_for(enemy.data.id))  # T548: solo el Coloso tiene fondo propio
	presentation.closed.connect(_on_presentation_closed)
	add_child(presentation)


## Al cerrarse, la partida vuelve a como estaba: corriendo, salvo que ya estuviera en pausa, que la app haya pasado a
## segundo plano (D-112) o que se haya cerrado con `P` o «Atrás» (RF-669, RF-673).
func _on_presentation_closed(keep_paused: bool) -> void:
	presentation = null
	build_controller.input_blocked = false
	if mobile_hud != null:
		mobile_hud.set_modal_open(false)
	hud.set_presentation_active(false)  # las tarjetas «Nuevo enemigo» que esperaban salen en su turno
	if BossPresentationRules.should_resume(_presentation_was_paused, _presentation_interrupted, keep_paused):
		set_paused(false)
	else:
		hud.show_paused(is_paused(), true)  # sigue pausada: el botón y el cartel lo dicen


## RF-132: el número de daño de cada golpe. Si el golpe hizo combo, su número es el aviso (RF-315) y suena (RF-316).
func _on_enemy_hit(enemy: Enemy, damage: int, blocked: bool, combo: Enemy.Combo) -> void:
	if combo == Enemy.Combo.NONE:
		effects.damage_number(enemy.global_position, damage, blocked)
		return
	effects.combo(enemy.global_position, damage, combo)
	Audio.play(&"combo", COMBO_SOUND_GAP)


func _on_enemy_died(enemy: Enemy) -> void:
	if collectible != null and enemy == _carrier and not session.is_over():
		collectible.pick(session.wave)
		_carrier = null
		var token := Sprite2D.new()
		token.texture = preload("res://assets/ui/technology_token.svg")
		token.scale = Vector2.ONE * 0.45
		token.position = enemy.global_position
		effects.add_child(token)
		var tween: Tween = token.create_tween()
		tween.tween_property(token, "position:y", token.position.y - 35.0, 0.6)
		tween.parallel().tween_property(token, "modulate:a", 0.0, 0.6)
		tween.tween_callback(token.queue_free)
		_update_collection_notice()
	session.earn(enemy.data.reward)  # RF-21
	session.add_score(Rules.kill_points(enemy.data.reward, balance))  # RF-190
	effects.enemy_died(enemy.global_position, enemy.data.color,
		Rules.tiles_to_px(enemy.data.size_tiles), enemy.data.reward, enemy)
	Audio.play(&"enemy_death")


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	if enemy == _carrier:
		_carrier = null
	# M70 (RF-631): las vidas que de verdad quita (no más de las que quedan; nada con vidas infinitas).
	var taken: int = 0 if session.is_over() or session.infinite_lives else mini(enemy.data.lives_damage, session.lives)
	leak_log.record(enemy.data, taken)
	session.lose_lives(enemy.data.lives_damage)  # RF-11
	_shake_left = SHAKE_DURATION
	Audio.play(&"life_lost")


func _on_tower_built(tower: Tower) -> void:
	tower.fired.connect(_on_tower_fired)
	# Cada torre suena distinto: el sonido se llama "shot_" + el id de la torre.
	var shot_sound := StringName("shot_%s" % tower.data.id)
	tower.fired.connect(func(_projectile: Projectile) -> void: Audio.play(shot_sound))
	# RF-449: el pulso de la Disruptora (señal hacia arriba, P6): anillo y su sonido.
	tower.pulsed.connect(func(radius_px: float) -> void:
		effects.pulse_ring(tower.global_position, radius_px)
		Audio.play(&"shot_disruptor"))
	effects.tower_built(tower.global_position, tower.data.color, tower.data.footprint)
	_refresh_exploitable()
	Audio.play(&"build")


func _on_tower_upgraded(tower: Tower) -> void:
	# M65 (RF-590, RF-593): el efecto y el texto de la mejora; con la opción apagada, el anillo de siempre (RF-75).
	if not effects.tower_upgraded(tower, get_viewport().get_canvas_transform(), _upgrade_fx_safe_rects(), _upgrade_fx_view_rect()):
		effects.tower_built(tower.global_position, tower.data.color, tower.data.footprint)
	_refresh_tower_panel()
	_refresh_exploitable()
	Audio.play(&"upgrade")


## M65, RF-592: lo que el texto de la mejora no puede pisar (barra de abajo, tilde, cruz, botones flotantes).
func _upgrade_fx_safe_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var bottom: Control = hud.get_node_or_null("BottomBar") as Control
	if bottom != null and bottom.is_visible_in_tree():
		rects.append(bottom.get_global_rect())
	if mobile_hud != null:
		rects.append_array(mobile_hud.forbidden_rects())
	return rects


## M65, RF-592: el área de mapa que se ve (entre la barra de arriba y la de abajo).
func _upgrade_fx_view_rect() -> Rect2:
	var mobile_config: MobileUiConfig = MobileUiConfig.load_from()
	var top_height: float = float(mobile_config.get_value("barra_alta_px")) if UiMode.is_mobile() else 48.0
	var bottom: Control = hud.get_node_or_null("BottomBar") as Control
	var bottom_height: float = float(mobile_config.get_value("barra_baja_px")) if UiMode.is_mobile() \
			else (bottom.size.y if bottom != null and bottom.is_visible_in_tree() else 0.0)
	return Rect2(0.0, top_height, Rules.SCREEN_SIZE.x, Rules.SCREEN_SIZE.y - top_height - bottom_height)


func _on_tower_sold(tower: Tower, refund: int, _resource_refund: int) -> void:
	effects.tower_sold(tower.global_position, refund, tower.data.footprint)
	_refresh_exploitable(tower)  # todavía está en el árbol: se borra al final del cuadro
	Audio.play(&"sell")


## RF-318: qué estados aprovecha alguna torre del mapa (sin contar `leaving`, la que se está vendiendo).
## Se lo avisa a todos los enemigos para su marca de "vulnerable".
func _refresh_exploitable(leaving: Tower = null) -> void:
	_exploit_slowed = false
	_exploit_burning = false
	for node: Node in tower_container.get_children():
		var tower := node as Tower
		if tower == null or tower == leaving or tower.is_queued_for_deletion():
			continue
		_exploit_slowed = _exploit_slowed or tower.stats().bonus_vs_slowed_percent > 0
		_exploit_burning = _exploit_burning or tower.stats().bonus_vs_burning_percent > 0
	for node: Node in enemies.get_children():
		if node is Enemy:
			(node as Enemy).set_exploitable(_exploit_slowed, _exploit_burning)


func _on_targeting_pressed() -> void:
	var tower: Tower = build_controller.selected_placed()
	if tower != null:
		tower.cycle_targeting()
		_refresh_tower_panel()


func _on_mobile_upgrade_pressed() -> void:
	if mobile_hud == null:
		return
	var tower: Tower = build_controller.selected_placed()
	if tower != null and build_controller.try_upgrade(tower):
		mobile_hud.begin_upgrade_lock(tower.level_number())
		_refresh_tower_panel()


func _on_mobile_sell_pressed() -> void:
	if mobile_hud == null:
		return
	var tower: Tower = build_controller.selected_placed()
	if tower != null:
		build_controller.sell(tower)
		mobile_hud.clear_sell_arm()
		_refresh_tower_panel()


## Muestra en el panel la torre seleccionada (o lo oculta si no hay ninguna).
func _refresh_tower_panel() -> void:
	var tower: Tower = build_controller.selected_placed()
	var value: int = build_controller.sell_value(tower) if tower != null else 0
	var resource_value: int = build_controller.sell_resource_value(tower) if tower != null else 0
	if mobile_hud != null:
		hud.tower_panel.hide()
		var reason: String = ""
		if tower != null and tower.can_upgrade() and session.gold < tower.next_level_stats().cost:
			reason = "Faltan %d de oro" % (tower.next_level_stats().cost - session.gold)
		mobile_hud.show_selected_tower(tower, session.gold, value, resource_value,
		tower != null and build_controller.can_upgrade(tower), reason)
		_sync_range_preview()
		return
	hud.tower_panel.show_tower(tower, value, session.gold, resource_value)
	_sync_range_preview()


## M75 (RF-680, RF-681): muestra o saca la ampliación del alcance. Se ve mientras el mouse está sobre «Mejorar» activo (PC)
## o «Mejorar» está armado (celular), y la torre elegida se puede mejorar ahora. No cobra ni cambia nada.
func _sync_range_preview() -> void:
	var tower: Tower = build_controller.selected_placed()
	var wanted: bool = tower != null and build_controller.can_upgrade(tower)
	if wanted and mobile_hud != null:
		wanted = mobile_hud.armed_tower() == tower
	elif wanted:
		wanted = hud.tower_panel.is_upgrade_hovered()
	if wanted:
		effects.show_range_preview(tower)
	else:
		effects.hide_range_preview()


func _on_tower_fired(projectile: Projectile) -> void:
	projectiles.add_child(projectile)
	projectile.impacted.connect(effects.projectile_impacted)
	projectile.impacted.connect(func(_position: Vector2, _stats: TowerLevelData) -> void:
		Audio.play(&"impact", 0.12))
	projectile.chained.connect(effects.lightning)  # RF-163


func _on_state_changed(state: LevelSession.State) -> void:
	if state != LevelSession.State.WON and state != LevelSession.State.LOST:
		return
	hud.hide_exit()  # RF-459: la pantalla de resultado ya trae sus botones
	_commit_collection()
	_write_dev_stats(DevStats.RESULT_WON if state == LevelSession.State.WON else DevStats.RESULT_LOST)
	# RF-91: el juego se detiene. Se congela el "mundo", pero no la interfaz.
	infrastructure.discard_job()  # RF-409: el trabajo se pierde
	for node: Node in [enemies, tower_container, projectiles, spawner, infrastructure]:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	build_controller.cancel()
	build_controller.deselect_placed()
	set_speed(1.0)
	# Desde el menú (campaña o mapa de la comunidad, RF-224) se guarda progreso y récords, y se vuelve
	# a la selección de nivel; probando (RF-217), no se guarda nada y se vuelve al editor.
	var saves_progress: bool = GameFlow.played_level() != null
	var can_leave: bool = saves_progress or testing or GameFlow.dev_partial_run()
	if state == LevelSession.State.WON:
		GameFlow.level_won(session.lives, session.score)  # RF-112, RF-115 y RF-194: desbloquea y guarda
		var stars: int = Rules.stars_for(session.lives, level_data.starting_lives, balance)  # RF-93
		end_screen.show_victory(session.lives, stars, GameFlow.has_next_level(), can_leave, session.score,
			level_data.win_text if shows_texts() else "", shows_texts() and GameFlow.has_epilogue())  # RF-467, RF-471
		Audio.play(&"victory")
	else:
		var tips: Dictionary = defeat_tips()
		end_screen.show_defeat(session.wave, session.total_waves, can_leave, session.score,
			String(tips["tower"]))  # RF-630
		Audio.play(&"defeat")
	if saves_progress:
		_show_level_records()  # RF-191: los récords cuentan desde el menú (RF-196, RF-224)


## M70 (RF-630 a RF-635): los consejos de la pantalla de derrota. `"tower"`: el de torre.
## El texto es "" si no corresponde. Un archivo inválido no bloquea la derrota: avisa y no hay consejo.
func defeat_tips() -> Dictionary:
	var tips: Dictionary = {"tower": "", "rule": "", "towers": PackedStringArray()}
	if not SaveManager.defeat_advice_enabled():
		return tips
	var advice: AdviceData = AdviceData.load_file()
	if not advice.is_valid():
		push_warning("Consejos de derrota: %s" % "; ".join(advice.errors))
		return tips
	var wave_counts: Dictionary = {}
	if session.wave >= 1 and session.wave <= level_data.waves.size():
		wave_counts = level_data.waves[session.wave - 1].enemy_counts()
	var tower_tip: Dictionary = DefeatAdvice.tower_tip(advice, leak_log, wave_counts, available_towers)
	if not tower_tip.is_empty():
		tips["tower"] = tower_tip["text"]
		tips["rule"] = tower_tip["id"]
		tips["towers"] = tower_tip["towers"]
	return tips


# --- Epílogo (RF-471) ---

## Abre el epílogo encima de la pantalla de victoria: «Niveles» va a la selección; `Esc` o un toque vuelven a la victoria.
func open_epilogue() -> void:
	if epilogue == null:
		epilogue = EpilogueScreen.new()
		add_child(epilogue)
		epilogue.levels_pressed.connect(GameFlow.go_to_level_select)
	epilogue.open(level_data.epilogue_text)


# --- Récords (RF-191 a RF-193) ---

## Si los puntos entran en el top 5 del nivel, pide las iniciales; si no, muestra la tabla.
func _show_level_records() -> void:
	if GameFlow.level_score_qualifies(session.score):
		end_screen.ask_name("¡Nuevo récord! Escribí tus iniciales", HighScores.LEVEL_NAME_LENGTH,
			SaveManager.last_initials(HighScores.LEVEL_NAME_LENGTH))
	else:
		end_screen.show_scores(LEVEL_RECORDS_TITLE, GameFlow.current_level_scores())
		_show_hall_of_fame_if_earned()


func _on_record_name_entered(name: String) -> void:
	var index: int = GameFlow.record_level_score(name, session.score)
	end_screen.show_scores(LEVEL_RECORDS_TITLE, GameFlow.current_level_scores(), index)
	_show_hall_of_fame_if_earned()


## RF-194: si con esta victoria el total de la campaña subió y entra en el Salón de la fama,
## se abre encima de la pantalla final y pide 5 letras.
func _show_hall_of_fame_if_earned() -> void:
	if session.state != LevelSession.State.WON or not GameFlow.hall_of_fame_pending():
		return
	hall_of_fame = HallOfFame.new()
	add_child(hall_of_fame)
	hall_of_fame.ask_name(GameFlow.campaign_total(), SaveManager.last_initials(HighScores.HALL_NAME_LENGTH))
	hall_of_fame.name_entered.connect(func(name: String) -> void:
		var index: int = GameFlow.record_hall_of_fame(name)
		hall_of_fame.show_table(GameFlow.hall_of_fame(), index))
	hall_of_fame.closed.connect(func() -> void:
		hall_of_fame.queue_free()
		hall_of_fame = null)

func _setup_collection() -> void:
	if DevMode.enabled or testing or GameFlow.current_index < 0 or GameFlow.current_community != null:
		return
	if not CollectibleRun.eligible(&"technology", level_data.id):
		return
	if not SaveManager.collected_sources(&"technology").has(String(level_data.id)):
		var count: int = 0
		for wave: WaveData in level_data.waves:
			for group: SpawnGroup in wave.groups:
				count += group.count
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		collectible = CollectibleRun.new()
		collectible.setup(&"technology", level_data.id, count, rng)
	_update_collection_notice()

## RF-362 y RF-431: la barra muestra la colección de la que este nivel es fuente (o `technology`).
func _update_collection_notice() -> void:
	var id: StringName = CollectionDefinitions.collection_of_level(level_data.id)
	var count: int = SaveManager.collected_sources(id).size()
	var state: String = "conseguido aquí" if SaveManager.collected_sources(id).has(String(level_data.id)) else "pendiente aquí"
	if id == &"technology":
		if collectible != null and collectible.picked_wave > 0:
			count += 1
			state = "oleada confirmada; pendiente del resultado" if collectible.confirmed else "completar oleada"
	elif findings.has_piece(id, level_data.id):
		count += 1
		state = "oleada confirmada; pendiente del resultado" if findings.is_confirmed(id, level_data.id) else "completar oleada"
	hud.show_collection(count, CollectionDefinitions.required(id), state, id)

func _collection_wave_completed(wave: int, _bonus: int) -> void:
	findings.complete_wave(wave)  # RF-427
	if collectible != null:
		collectible.complete_wave(wave)
	_update_collection_notice()

## RF-429: las piezas de colección solo se recogen en la campaña jugada desde el menú.
func _collects_pieces() -> bool:
	return not (DevMode.enabled or testing or GameFlow.current_index < 0 or GameFlow.current_community != null \
			or GameFlow.current_mode_level() != null)

## RF-428 y RF-429: qué colecciones de hallazgo ya no entregan pieza en esta partida: las que ya
## están recuperadas en el guardado y todas, si acá no se recogen piezas.
func _recovered_collections() -> Dictionary:
	var result: Dictionary = {}
	var collects: bool = _collects_pieces()
	for id: StringName in CollectionDefinitions.ids():
		if CollectionDefinitions.origin(id) == CollectionDefinitions.ORIGIN_FINDING:
			result[id] = not collects or SaveManager.collected_sources(id).has(String(level_data.id))
	return result

## RF-427: la pieza se recoge al terminar la demolición y se confirma con la oleada en curso, o con
## la siguiente si se demolió en preparación o en la cuenta atrás.
func _on_obstacle_demolished(_cell: Vector2i, reward: Dictionary) -> void:
	var finding: Dictionary = reward.get("finding", {})
	if finding.is_empty() or not _collects_pieces() or session.is_over():
		return
	var wave_to_confirm: int = session.wave if session.state == LevelSession.State.WAVE_RUNNING else session.wave + 1
	if findings.pick(finding["collection"], finding["source"], wave_to_confirm):
		_update_collection_notice()

## RF-427: al mostrarse el resultado se guardan las piezas confirmadas, aunque la partida se pierda.
func _commit_findings() -> void:
	if not _collects_pieces():
		return
	var saved: bool = false
	for piece: Dictionary in findings.confirmed():
		SaveManager.collect_source(piece["collection"], piece["source"])
		saved = true
	if saved:
		SaveManager.save()

func _commit_collection() -> void:
	_commit_findings()
	if collectible == null or DevMode.enabled or testing:
		return
	for source: String in collectible.result_sources(true):
		SaveManager.collect_source(collectible.collection, StringName(source))
	if collectible.confirmed:
		SaveManager.save()
		collectible = null
		_update_collection_notice()

func dev_enable_support(on: bool) -> void:
	if not DevMode.enabled:
		return
	DevMode.support_unlocked = on
	_refresh_dev_towers()


## RF-436: las torres de colección quedan disponibles en esta partida, aunque el nivel no las ofrezca.
func dev_enable_collections(on: bool) -> void:
	if not DevMode.enabled:
		return
	DevMode.collections_unlocked = on
	_refresh_dev_towers()


func _refresh_dev_towers() -> void:
	var catalog: Array[TowerData] = tower_types.duplicate()
	for support: TowerData in support_catalog():
		if not catalog.has(support):
			catalog.append(support)
	available_towers = level_data.available_towers(catalog, func(collection: StringName) -> bool:
		return DevMode.collections_unlocked or SaveManager.collection_complete(collection))
	if DevMode.enabled and DevMode.support_unlocked:
		for support: TowerData in support_catalog():
			if not available_towers.has(support):
				available_towers.append(support)
	if DevMode.enabled and DevMode.collections_unlocked:
		for tower: TowerData in catalog:
			if tower.required_collection != &"" and not available_towers.has(tower):
				available_towers.append(tower)
	build_controller.cancel()
	build_controller.setup(level, session, balance, available_towers, tower_container)
	hud.setup_towers(available_towers)
	hud._on_gold_changed(session.gold)
	hud.tower_panel.partner_towers = available_towers

static func support_catalog() -> Array[TowerData]:
	var result: Array[TowerData] = []
	for tower: TowerData in Wiki._all_towers():
		if tower.support_only:
			result.append(tower)
	return result
