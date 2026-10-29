# Interfaz de la partida (spec §9.1). Solo MUESTRA datos y AVISA cuando se pulsa algo:
# no cambia el oro ni empieza oleadas por su cuenta (plan §5.2).
class_name Hud
extends CanvasLayer

signal start_wave_pressed
## Se pulsó el botón de la torre número `index` (0 = la primera).
signal tower_button_pressed(index: int)
## RF-103: botones de pausa y velocidad.
signal pause_pressed
signal speed_pressed
## RF-419: se pulsó un botón de pago de la ayuda de construcción (true = oro + recursos).
signal payment_pressed(alt: bool)
## RF-459: se pulsó la flecha «← Menú». Game pregunta antes de salir (RF-460).
signal menu_pressed
## RF-455: el jugador cambió de pestaña de la barra (clic, toque o `Tab`). Game decide qué más pasa.
signal tab_changed(id: StringName)

## RF-170: botones compactos, para que entren 9 torres (M19) sin tapar "Próxima oleada" (D-026).
## El ancho lo reparte `BarLayout.button_width` (RF-455): 76 mientras entren, hasta 56 con pestañas.
const TOWER_BUTTON_HEIGHT: int = 60
## La letra del costo en el botón de torre (RF-170).
const COST_FONT_SIZE: int = 15
## RF-455: los ids de las dos pestañas de la barra.
const TAB_CANNONS: StringName = &"cannons"
const TAB_INFRASTRUCTURE: StringName = &"infrastructure"
## Ancho máximo del dibujo de la torre en su botón (RF-155).
const TOWER_ICON_SIZE: int = 34
## RF-134: cuánto se ve la tarjeta de presentación de un enemigo.
const INTRO_SECONDS: float = 6.0

var _total_waves: int = 0
## RF-319: la última oleada que avisó la sesión; si el salto es de más de una, no fue "empezó la oleada".
var _last_wave: int = 0
## Las oleadas del nivel: para mostrar la próxima (RF-133) y avisar del Jefe (RF-135).
var _waves: Array[WaveData] = []
var _tower_types: Array[TowerData] = []
var _tower_buttons: Array[Button] = []
## RF-134: si llegan dos enemigos nuevos juntos, sus tarjetas salen una detrás de otra.
var _intro_queue: Array[EnemyData] = []
var _intro_busy: bool = false
## M66 (RF-670, RF-673): mientras la presentación de un jefe está arriba, las animaciones de la interfaz se congelan
## (el HUD sigue activo con la partida en pausa, así que sus `Tween` no se detienen solos) y las tarjetas
## «Nuevo enemigo» que esperan no salen hasta que se cierra.
var _presentation_active: bool = false
var _tweens: Array[Tween] = []
## -1 = todavía no se mostró ningún valor (para no animar el primero).
var _last_gold: int = -1
var _last_lives: int = -1
var _last_score: int = -1
## RF-416: el mapa tiene alguna fuente de recursos (el contador se ve solo entonces).
var _uses_resources: bool = false
var _resources: int = 0
var _last_resources: int = -1
var _gold: int = 0
## Índice de la torre elegida para construir (-1 = ninguna) y su forma de pago (RF-419).
var _selected_index: int = -1
var _resource_stat: HBoxContainer
var _resource_label: Label
var _pay_gold_button: Button
var _pay_alt_button: Button
var _mobile_mode: bool = false
var _mobile_config: MobileUiConfig

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _start_wave_button: Button = %StartWaveButton
@onready var _tower_button_row: HBoxContainer = %TowerButtons
@onready var _wave_banner: Label = %WaveBanner
@onready var _boss_line: Label = %BossLine
@onready var _next_wave: Control = %NextWave
@onready var _next_wave_icons: HFlowContainer = %NextWaveIcons
@onready var _intro: Control = %EnemyIntro
@onready var _intro_icon_slot: Control = %IntroIconSlot
@onready var _intro_name: Label = %IntroName
@onready var _intro_text: Label = %IntroText
## Panel de la torre seleccionada (RF-70). Game lo conecta con BuildController.
@onready var tower_panel: TowerPanel = %TowerPanel
## Panel del removible elegido (RF-404). Game lo conecta con InfrastructureController.
var obstacle_panel: ObstaclePanel
## RF-454: solo existen en los niveles que usan infraestructura (`setup_bar`); null en los demás.
var bar_tabs: BarTabs
var infrastructure_tab: InfrastructureTab
## Cuántas torres tiene la barra y si lleva pestañas: de ahí salen el ancho de los botones y sus teclas.
var _tabs_enabled: bool = false
var _mobile_wave_controls_visible: bool = true
var _has_next_wave: bool = false
@onready var _exit_button: Button = %ExitButton
@onready var _pause_button: Button = %PauseButton
@onready var _speed_button: Button = %SpeedButton
@onready var _pause_label: Label = %PauseLabel
@onready var _build_info: Control = %BuildInfo
@onready var _build_info_name: Label = %BuildInfoName
@onready var _build_info_text: Label = %BuildInfoText


var _metrics: Label
var _metrics_updated: int = 0
var _view_all_notice: Label
var _view_all_notice_tween: Tween

func _process(_delta: float) -> void:
	if _metrics == null or not _metrics.visible:
		return
	var now: int = Time.get_ticks_msec()
	if now - _metrics_updated < 500:
		return
	_metrics_updated = now
	var fps: float = Engine.get_frames_per_second()
	_metrics.text = "%d FPS · %.1f ms/cuadro" % [fps, 1000.0 / maxf(fps, 1.0)]

func show_metrics(enabled: bool) -> void:
	_metrics.visible = enabled
	_metrics_updated = 0

func _ready() -> void:
	Localization.apply(self, {"NextWaveTitle": &"hud.next_wave", "StartWaveButton": &"hud.start_wave", "PauseLabel": &"hud.paused_label",
			"ExitButton": &"hud.exit_menu", "BuildInfoName": &"hud.build_info_placeholder", "BuildInfoText": &"hud.build_info_text_placeholder",
			"IntroName": &"hud.new_enemy_title"})
	obstacle_panel = ObstaclePanel.new()
	obstacle_panel.name = "ObstaclePanel"
	add_child(obstacle_panel)
	_metrics = Label.new()
	_metrics.name = "PerformanceOverlay"
	_metrics.position = Vector2(990, 56)
	_metrics.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_metrics.add_theme_font_size_override("font_size", 14)
	_metrics.add_theme_color_override("font_outline_color", Color.BLACK)
	_metrics.add_theme_constant_override("outline_size", 4)
	_metrics.visible = false
	add_child(_metrics)
	_view_all_notice = Label.new()
	_view_all_notice.name = "ViewAllNotice"
	_view_all_notice.position = Vector2(160, 50)
	_view_all_notice.size = Vector2(960, 36)
	_view_all_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_all_notice.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_view_all_notice.add_theme_font_size_override("font_size", 18)
	_view_all_notice.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
	_view_all_notice.add_theme_color_override("font_outline_color", Color.BLACK)
	_view_all_notice.add_theme_constant_override("outline_size", 5)
	_view_all_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view_all_notice.visible = false
	add_child(_view_all_notice)
	var hint := Label.new()
	hint.position = Vector2(20, 52)
	hint.visible = false
	hint.add_theme_color_override("font_outline_color", Color.BLACK)
	hint.add_theme_constant_override("outline_size", 4)
	add_child(hint)
	var bar: Control = get_node("TopBar")
	bar.theme = preload("res://assets/ui/menu_theme.tres")
	_mobile_mode = UiMode.is_mobile()
	if _mobile_mode:
		_configure_mobile_top_bar(bar)
	BarTabs.tighten(_exit_button)  # RF-459: 80 px de ancho; con el margen del tema el botón crecía a 94
	_build_resource_stat(bar.get_node("Stats"))
	_build_payment_buttons()
	var edge := ColorRect.new()
	edge.color = Color(0.52, 0.36, 0.17)
	edge.position = Vector2(0, bar.size.y - 2.0)
	edge.size = Vector2(1280, 2)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(edge)
	if _mobile_mode:
		get_node("BottomBar").theme = preload("res://assets/ui/menu_theme.tres")
		get_node("BottomBar").color = Color(0.105, 0.11, 0.125, 1)
	for pair: Array in [["Gold", Localization.t(&"hud.gold")], ["Lives", Localization.t(&"hud.lives")], ["Score", Localization.t(&"hud.score")],
			["Wave", Localization.t(&"hud.wave")], ["Technology", Localization.t(&"hud.technology")]]:
		var icon: Control = bar.get_node("Stats/" + pair[0] + "Stat/" + pair[0] + "Icon")
		icon.tooltip_text = pair[1]
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.focus_mode = Control.FOCUS_ALL
		icon.focus_entered.connect(func() -> void:
			hint.text = icon.tooltip_text
			hint.show())
		icon.focus_exited.connect(hint.hide)

	var resource_icon: Control = _resource_stat.get_node("ResourceIcon")
	resource_icon.focus_entered.connect(func() -> void:
		hint.text = resource_icon.tooltip_text
		hint.show())
	resource_icon.focus_exited.connect(hint.hide)

	_start_wave_button.pressed.connect(start_wave_pressed.emit)
	_pause_button.pressed.connect(pause_pressed.emit)
	_speed_button.pressed.connect(speed_pressed.emit)
	_exit_button.pressed.connect(menu_pressed.emit)
	show_paused(false)
	show_speed(1.0)


func show_view_all_notice(message: String) -> void:
	_view_all_notice.text = message
	_view_all_notice.modulate.a = 1.0
	_view_all_notice.visible = true
	if _view_all_notice_tween != null and _view_all_notice_tween.is_running():
		_view_all_notice_tween.kill()
	_view_all_notice_tween = create_tween()
	_view_all_notice_tween.tween_interval(3.0)
	_view_all_notice_tween.tween_property(_view_all_notice, "modulate:a", 0.0, 0.25)
	_view_all_notice_tween.tween_callback(func() -> void:
		_view_all_notice.visible = false
		_view_all_notice.modulate.a = 1.0)


func is_notice_active() -> bool:
	return _intro_busy or _presentation_active or (not _wave_banner.text.is_empty() and _wave_banner.modulate.a > 0.05)


## RF-416: el contador de recursos de la barra superior, con el mismo formato que las otras estadísticas.
## Oculto hasta que `setup_resources(true)`. El ícono es provisional (una gema dibujada) hasta T221.
func _build_resource_stat(stats: Control) -> void:
	_resource_stat = HBoxContainer.new()
	_resource_stat.name = "ResourceStat"
	_resource_stat.add_theme_constant_override("separation", 6)
	_resource_stat.visible = false
	var icon := TextureRect.new()
	icon.name = "ResourceIcon"
	icon.custom_minimum_size = Vector2(30, 30)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _resource_texture(30)
	icon.tooltip_text = Localization.t(&"hud.resources_tip")
	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.focus_mode = Control.FOCUS_ALL
	_resource_stat.add_child(icon)
	_resource_label = Label.new()
	_resource_label.name = "ResourceLabel"
	_resource_label.text = "0"
	_resource_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_resource_label.add_theme_color_override("font_color", Color(0.62, 0.9, 0.55))
	_resource_label.add_theme_font_size_override("font_size", 22)
	_resource_stat.add_child(_resource_label)
	stats.add_child(_resource_stat)


## Ícono provisional del recurso: un rombo verde con borde claro (guía de arte: colores de la interfaz).
static func _resource_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center: float = (size - 1) / 2.0
	for y: int in size:
		for x: int in size:
			var distance: float = (absf(x - center) + absf(y - center)) / center
			if distance <= 0.78:
				image.set_pixel(x, y, Color(0.4, 0.78, 0.38))
			elif distance <= 0.95:
				image.set_pixel(x, y, Color(0.85, 1.0, 0.8))
	return ImageTexture.create_from_image(image)


## RF-419: los dos botones chicos de pago de la ayuda de construcción. Solo se ven con una torre de dos precios.
func _build_payment_buttons() -> void:
	_pay_gold_button = _payment_button(false)
	_pay_alt_button = _payment_button(true)
	_build_info.add_child(_pay_gold_button)
	_build_info.add_child(_pay_alt_button)
	_build_info.move_child(_pay_gold_button, 1)
	_build_info.move_child(_pay_alt_button, 2)


func _payment_button(alt: bool) -> Button:
	var button := Button.new()
	button.name = "PayAltButton" if alt else "PayGoldButton"
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.visible = false
	button.add_theme_font_size_override("font_size", 14)
	button.custom_minimum_size = Vector2(0, 28)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(payment_pressed.emit.bind(alt))
	return button


## RF-416: ¿el contador de recursos está a la vista? (La tarjeta «Recursos» de la barra sigue a este contador.)
func shows_resources() -> bool:
	return _uses_resources


## RF-416: muestra u oculta el contador. Game lo llama con `LevelData.uses_resources()` antes de `setup_towers`.
func setup_resources(enabled: bool) -> void:
	_uses_resources = enabled
	_resource_stat.visible = enabled
	_refresh_tower_buttons()


## RF-104: texto del botón y cartel "PAUSA".
## `show_label` = false cuando el menú de pausa ya lo dice (no mostrar dos veces).
func show_paused(paused: bool, show_label: bool = true) -> void:
	_pause_button.text = Localization.t(&"hud.resume" if paused else &"hud.pause") + ("" if _mobile_mode else "  [P]")
	_pause_label.visible = paused and show_label


## RF-105: el botón muestra la velocidad actual.
func show_speed(speed: float) -> void:
	_speed_button.text = "%s%s" % [Rules.speed_text(speed), "" if _mobile_mode else "  [F]"]  # RF-322


## Game le pasa las oleadas del nivel ANTES de bind() (RF-133, RF-135).
func setup_waves(waves: Array[WaveData]) -> void:
	_waves = waves


## RF-133: muestra los enemigos de la oleada `wave` (o nada, si es null).
func show_next_wave(wave: WaveData) -> void:
	for child: Node in _next_wave_icons.get_children():
		child.queue_free()
	_has_next_wave = wave != null
	_next_wave.visible = _has_next_wave and _mobile_wave_controls_visible
	if wave == null:
		return
	var counts: Dictionary = wave.enemy_counts()
	for enemy: EnemyData in counts:
		var icon: EnemyIcon = EnemyIcon.new().setup(enemy, counts[enemy])
		for group: SpawnGroup in wave.groups:
			if group.enemy == enemy and group.probability < 1.0:
				icon.uncertain = true
				icon.mouse_filter = Control.MOUSE_FILTER_PASS
				icon.tooltip_text += Localization.t_fmt(&"hud.optional_group", {"pct": "%.0f" % (group.probability * 100.0)})
		_next_wave_icons.add_child(icon)


func set_mobile_wave_controls_visible(enabled: bool) -> void:
	_mobile_wave_controls_visible = enabled
	if not _mobile_mode:
		return
	_start_wave_button.visible = enabled
	_next_wave.visible = enabled and _has_next_wave


## RF-134: tarjeta "Nuevo enemigo" con su forma, nombre y qué hace.
func show_enemy_intro(enemy: EnemyData) -> void:
	_intro_queue.append(enemy)
	if not _intro_busy:
		_show_next_intro()


## M66 (RF-670, RF-673): congela o reanuda los carteles y las tarjetas del HUD. Al reanudar, la tarjeta «Nuevo enemigo»
## que esperaba en la cola sale en su turno.
func set_presentation_active(active: bool) -> void:
	_presentation_active = active
	for tween: Tween in _tweens:
		if tween.is_valid():
			if active:
				tween.pause()
			else:
				tween.play()
	if not active and not _intro_busy and not _intro_queue.is_empty():
		_show_next_intro()


func is_presentation_active() -> bool:
	return _presentation_active


## Un `Tween` del HUD que se congela con la presentación de un jefe. Se crea ya en pausa si la presentación está arriba.
func _tween() -> Tween:
	for i: int in range(_tweens.size() - 1, -1, -1):
		if not _tweens[i].is_valid():
			_tweens.remove_at(i)
	var tween: Tween = create_tween()
	_tweens.append(tween)
	if _presentation_active:
		tween.pause()
	return tween


func _show_next_intro() -> void:
	if _presentation_active:
		return  # M66 (RF-670): espera a que se cierre la presentación; `set_presentation_active(false)` la retoma
	if _intro_queue.is_empty():
		_intro_busy = false
		_intro.visible = false
		return
	_intro_busy = true
	var enemy: EnemyData = _intro_queue.pop_front()
	for child: Node in _intro_icon_slot.get_children():
		child.queue_free()
	_intro_icon_slot.add_child(EnemyIcon.new().setup(enemy))
	_intro_name.text = Localization.t_fmt(&"hud.new_enemy", {"name": enemy.name_text()})
	_intro_text.text = enemy.description_text()
	_intro.visible = true
	_intro.modulate.a = 0.0
	var tween: Tween = _tween()
	tween.tween_property(_intro, "modulate:a", 1.0, 0.25)
	tween.tween_interval(INTRO_SECONDS)
	tween.tween_property(_intro, "modulate:a", 0.0, 0.4)
	tween.finished.connect(_show_next_intro)


## RF-135: el primer enemigo peligroso de la oleada, o null si no trae ninguno.
static func dangerous_enemy_in(wave: WaveData) -> EnemyData:
	for group: SpawnGroup in wave.groups:
		if Rules.is_dangerous(group.enemy):
			return group.enemy
	return null


## Game le pasa la sesión para que el HUD se mantenga actualizado.
func bind(session: LevelSession) -> void:
	session.gold_changed.connect(_on_gold_changed)
	session.resources_changed.connect(_on_resources_changed)
	session.lives_changed.connect(_on_lives_changed)
	session.score_changed.connect(_on_score_changed)
	session.wave_changed.connect(_on_wave_changed)
	session.wave_completed.connect(_on_wave_completed)
	session.state_changed.connect(_on_state_changed)
	session.countdown_changed.connect(_on_countdown_changed)
	_on_gold_changed(session.gold)


## RF-454 y RF-455: la columna de pestañas y la pestaña «Infraestructura», solo si el nivel usa infraestructura.
## Sin pestañas no se crea nada y la barra queda como siempre. Game lo llama antes de `setup_towers`.
func setup_bar(tabs: bool) -> void:
	_tabs_enabled = tabs
	if not tabs:
		return
	var bottom: Control = get_node("BottomBar")
	bar_tabs = BarTabs.new()
	bar_tabs.name = "BarTabs"
	bar_tabs.position = Vector2(12, 2)
	bottom.add_child(bar_tabs)
	var list: Array[Dictionary] = [
		{"id": TAB_CANNONS, "text": Localization.t(&"hud.tab_cannons")},
		{"id": TAB_INFRASTRUCTURE, "text": InfrastructureText.tab_title()},
	]
	bar_tabs.setup(list)
	bar_tabs.tab_selected.connect(_on_tab_selected)
	infrastructure_tab = InfrastructureTab.new()
	infrastructure_tab.name = "InfrastructureTab"
	bottom.add_child(infrastructure_tab)
	if _mobile_mode:
		infrastructure_tab.set_mobile_touch_targets(float(_mobile_config.get_value("boton_alto_px")))
		bar_tabs.hide()
		infrastructure_tab.hide()
	show_tab(TAB_CANNONS)


func has_tabs() -> bool:
	return bar_tabs != null


## La pestaña activa (`TAB_CANNONS` si la barra no tiene pestañas).
func current_tab() -> StringName:
	return bar_tabs.current() if bar_tabs != null else TAB_CANNONS


## Muestra una pestaña sin avisar (RF-456: elegir una torre con su tecla vuelve a «Cañones»).
func show_tab(id: StringName) -> void:
	if bar_tabs == null or not bar_tabs.has_tab(id):
		return
	bar_tabs.select(id)
	if _mobile_mode:
		_tower_button_row.hide()
		infrastructure_tab.hide()
		return
	_tower_button_row.visible = id == TAB_CANNONS
	infrastructure_tab.visible = id == TAB_INFRASTRUCTURE


## RF-456 (`Tab`): pasa a la pestaña que sigue y avisa. Sin pestañas no hace nada.
func switch_tab() -> void:
	if bar_tabs == null:
		return
	_on_tab_selected(bar_tabs.next_id())


func _on_tab_selected(id: StringName) -> void:
	show_tab(id)
	tab_changed.emit(id)


## RF-458: el título de «Infraestructura» muestra lo que falta de la demolición en curso.
func show_job_badge(seconds_left: float, job_active: bool) -> void:
	if bar_tabs == null:
		return
	var badge: String = "" if not job_active else InfrastructureText.seconds_text(seconds_left)
	bar_tabs.set_badge(TAB_INFRASTRUCTURE, badge)


## M63 (RF-574): el control de la barra que señala el tutorial (null si no existe o no se ve ahora).
## Nombres: `gold`, `lives`, `start_wave`, `pause`, `speed`, `tower_1` (la primera torre de la barra),
## `upgrade` y `sell` (los del panel de la torre elegida, en la PC).
func target_control(target: StringName) -> Control:
	var control: Control = null
	match target:
		&"gold":
			control = get_node("TopBar/Stats/GoldStat") as Control
		&"lives":
			control = get_node("TopBar/Stats/LivesStat") as Control
		&"start_wave":
			control = _start_wave_button
		&"pause":
			control = _pause_button
		&"speed":
			control = _speed_button
		&"tower_1":
			control = _tower_buttons[0] if not _tower_buttons.is_empty() else null
		&"upgrade":
			control = tower_panel.upgrade_button()
		&"sell":
			control = tower_panel.sell_button()
	return control if control != null and control.is_visible_in_tree() else null


## RF-459: «← Menú», o «← Editor» al probar un mapa del editor (RF-217).
func set_exit_text(text: String, tooltip: String = "") -> void:
	_exit_button.text = text
	if tooltip != "":
		_exit_button.tooltip_text = tooltip


## RF-459: con la partida terminada la flecha se oculta (la pantalla de resultado trae sus botones).
func hide_exit() -> void:
	_exit_button.visible = false


## RF-101: un botón por torre, con su color, nombre, tecla y costo.
func setup_towers(tower_types: Array[TowerData]) -> void:
	for old: Node in _tower_button_row.get_children():
		_tower_button_row.remove_child(old)
		old.queue_free()
	_tower_buttons.clear()
	_tower_types = tower_types
	if _mobile_mode:
		_tower_button_row.hide()  # RF-510: el celular elige las torres desde el carrito.
	# RF-455: el reparto sale de BarLayout. Sin pestañas y hasta 9 torres: lo de siempre (x = 20, 76 de ancho, 10 de separación).
	var width: int = BarLayout.button_width(tower_types.size(), _tabs_enabled)
	_tower_button_row.offset_left = BarLayout.left(_tabs_enabled)
	if _tabs_enabled:
		_tower_button_row.offset_right = BarLayout.RIGHT_EDGE
	_tower_button_row.add_theme_constant_override("separation", BarLayout.gap(tower_types.size(), _tabs_enabled))
	for i: int in tower_types.size():
		var tower: TowerData = tower_types[i]
		var button := Button.new()
		button.custom_minimum_size = Vector2(width, TOWER_BUTTON_HEIGHT)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		# RF-170: dibujo arriba, costo abajo y la tecla en una esquina. El nombre, al pasar el mouse.
		button.text = TowerText.bar_text(tower)  # RF-418: "300 + 3"
		var key: String = BarLayout.key_label(i)
		if key != "" and not _mobile_mode:
			button.tooltip_text = Localization.t_fmt(&"hud.tower_tip_key", {"name": tower.name_text(), "key": key, "cost": TowerText.cost_text(tower)})
			button.add_child(_key_label(key))
		elif key != "":
			button.tooltip_text = Localization.t_fmt(&"hud.tower_tip", {"name": tower.name_text(), "cost": TowerText.cost_text(tower)})
		else:  # RF-456: de la torre 11 en adelante no hay tecla
			button.tooltip_text = Localization.t_fmt(&"hud.tower_tip", {"name": tower.name_text(), "cost": TowerText.cost_text(tower)})
		button.add_theme_font_size_override("font_size", _cost_font_size(button, width))
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		var icon: Texture2D = Tower.make_icon(tower)
		if icon != null:
			# RF-155: base y torreta, como la torre recién construida, achicadas con suavidad (D-023).
			button.icon = icon
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", TOWER_ICON_SIZE)
			button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		else:  # RF-156: sin dibujo, un cuadradito de su color.
			button.icon = _color_swatch(tower.color)
		if TowerText.uses_resources(tower):
			button.add_child(_resource_badge(tower, width))
		if tower.has_alt_payment():
			button.tooltip_text += Localization.t_fmt(&"hud.or_cost", {"cost": TowerText.cost_text(tower, true)})
		button.pressed.connect(tower_button_pressed.emit.bind(i))
		_tower_button_row.add_child(button)
		_tower_buttons.append(button)
	_refresh_tower_buttons()


## RF-455: la letra del costo, la de siempre (15) mientras entre; en un botón angosto, la más grande que quepa
## (un «300 + 3» a 15 pt hacía crecer el botón de 57 a 59 px). No se saca información: solo se achica.
func _cost_font_size(button: Button, width: int) -> int:
	var font: Font = button.get_theme_font("font")
	var margins: float = button.get_theme_stylebox("normal").get_minimum_size().x
	for size: int in [COST_FONT_SIZE, 14, 13, 12]:
		if font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + margins <= width:
			return size
	return 12


## RF-418 y RF-419: el ícono del recurso, chiquito, en la esquina de arriba a la derecha del botón. Con dos
## formas de pago lleva además la otra ("o 120 + 1"), en chico. En un botón angosto (RF-455) va pegado al borde
## derecho, crece hacia la izquierda y se achica la letra y el ícono para no pisar la tecla de la esquina.
func _resource_badge(tower: TowerData, button_width: int) -> Control:
	var narrow: bool = button_width < BarLayout.MAX_BUTTON_WIDTH
	var row := HBoxContainer.new()
	row.name = "ResourceBadge"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 1)
	if narrow:
		row.anchor_left = 1.0
		row.anchor_right = 1.0
		row.offset_left = 0.0
		row.offset_right = -4.0
		row.offset_top = 2.0
		row.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	else:  # 76 px: el lugar de siempre, para que la barra de los niveles 1 a 5 no cambie ni un píxel
		row.position = Vector2(button_width - (46 if tower.has_alt_payment() else 18), 2)
	if tower.has_alt_payment():
		var other := Label.new()
		# Angosto: «120+1» sin el «o» ni los espacios (la otra forma de pago completa está en la ayuda al pasar el mouse).
		other.text = TowerText.bar_text(tower, true).replace(" ", "") if narrow else Localization.t_fmt(&"hud.or_short", {"cost": TowerText.bar_text(tower, true)})
		other.add_theme_font_size_override("font_size", 9 if narrow else 10)
		other.modulate = Color(1, 1, 1, 0.75)
		other.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(other)
	var icon := TextureRect.new()
	var icon_size: int = 10 if narrow and tower.has_alt_payment() else 14
	icon.texture = _resource_texture(icon_size)
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	return row


## RF-170: número de la tecla, chiquito, en la esquina de arriba a la izquierda del botón.
func _key_label(key: String) -> Label:
	var label := Label.new()
	label.text = key
	label.position = Vector2(6, 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 12)
	label.modulate = Color(1, 1, 1, 0.6)
	return label


## Cuadradito del color de la torre, con borde claro para que se vean también las oscuras.
func _color_swatch(color: Color) -> Texture2D:
	var image := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0.8))
	image.fill_rect(Rect2i(2, 2, 16, 16), color)
	return ImageTexture.create_from_image(image)


## Marca el botón de la torre elegida (-1 = ninguna).
func show_selected_tower(index: int) -> void:
	for i: int in _tower_buttons.size():
		_tower_buttons[i].set_pressed_no_signal(i == index)
	# RF-171: nombre, costo y para qué sirve la torre elegida.
	_selected_index = index
	if _mobile_mode:
		_build_info.hide()
		return
	if index >= 0:
		show_tab(TAB_CANNONS)  # RF-456: elegir una torre (también con su tecla) vuelve a «Cañones»
	_build_info.visible = index >= 0
	_pay_gold_button.visible = false
	_pay_alt_button.visible = false
	if index >= 0:
		var tower: TowerData = _tower_types[index]
		if tower.has_alt_payment():  # RF-419: dos botones chicos; el nombre queda sin precio
			_build_info_name.text = tower.name_text()
			_pay_gold_button.text = TowerText.cost_text(tower)
			_pay_alt_button.text = TowerText.cost_text(tower, true)
			_pay_gold_button.visible = true
			_pay_alt_button.visible = true
			show_payment(false)
			_refresh_payment_buttons()
		else:
			_build_info_name.text = "%s · %s" % [tower.name_text(), TowerText.cost_text(tower)]
		_build_info_text.text = tower.description_text()
		if tower.footprint > 1:  # RF-298
			_build_info_text.text += Localization.t_fmt(&"hud.needs_space", {"n": tower.footprint})
		if tower.levels[0].suppress_seconds > 0.0:  # RF-450
			_build_info_text.text += " " + TowerText.pulse_line(tower.levels[0], TowerText.emitter_names(Wiki._all_enemies()))
		var combo: String = TowerText.combo_hint(tower, _tower_types)  # RF-317
		if combo != "":
			_build_info_text.text += " " + combo


func _on_gold_changed(gold: int) -> void:
	_gold_label.text = "%d" % gold
	if _last_gold >= 0 and gold != _last_gold:
		_pop(_gold_label)  # RF-129
	_last_gold = gold
	_gold = gold
	_refresh_tower_buttons()


## RF-416: el contador de recursos, con el mismo "pop" que el oro.
func _on_resources_changed(resources: int) -> void:
	_resource_label.text = "%d" % resources
	if _last_resources >= 0 and resources != _last_resources:
		_pop(_resource_label)
	_last_resources = resources
	_resources = resources
	_refresh_tower_buttons()


## RF-101 y RF-418: gris si no alcanza el oro o los recursos; el motivo, en el tooltip. Una torre con dos
## formas de pago se puede elegir si alcanza cualquiera de las dos (RF-419).
func _refresh_tower_buttons() -> void:
	for i: int in _tower_buttons.size():
		var tower: TowerData = _tower_types[i]
		var reason: String = TowerText.missing_text(tower, false, _gold, _resources, _uses_resources)
		if reason != "" and tower.has_alt_payment():
			reason = reason if TowerText.missing_text(tower, true, _gold, _resources, _uses_resources) != "" else ""
		_tower_buttons[i].disabled = reason != ""
		var base: String = _tower_buttons[i].tooltip_text.split("\n")[0]
		_tower_buttons[i].tooltip_text = base + ("\n" + reason if reason != "" else "")
	_refresh_payment_buttons()


## RF-419: la segunda opción se apaga, con el motivo, si faltan recursos o el mapa no los tiene.
func _refresh_payment_buttons() -> void:
	if _selected_index < 0 or _selected_index >= _tower_types.size() or not _tower_types[_selected_index].has_alt_payment():
		return
	var tower: TowerData = _tower_types[_selected_index]
	var reason: String = TowerText.missing_text(tower, true, _gold, _resources, _uses_resources)
	_pay_alt_button.disabled = reason != ""
	_pay_alt_button.tooltip_text = reason
	var reason_gold: String = TowerText.missing_text(tower, false, _gold, _resources, _uses_resources)
	_pay_gold_button.disabled = reason_gold != ""
	_pay_gold_button.tooltip_text = reason_gold


## RF-419: marca el botón de pago elegido.
func show_payment(alt: bool) -> void:
	_pay_gold_button.set_pressed_no_signal(not alt)
	_pay_alt_button.set_pressed_no_signal(alt)


## RF-190: los puntos, con el mismo "pop" que el oro.
func _on_score_changed(score: int) -> void:
	_score_label.text = "%d" % score
	if _last_score >= 0 and score != _last_score:
		_pop(_score_label)
	_last_score = score


func _on_lives_changed(lives: int) -> void:
	_lives_label.text = "%d" % lives
	if _last_lives >= 0 and lives < _last_lives:
		_blink(_lives_label)  # RF-128
	_last_lives = lives


func _on_wave_changed(wave: int, total_waves: int) -> void:
	_wave_label.tooltip_text = Localization.t(&"hud.wave")
	_total_waves = total_waves
	if wave > 0 and wave != _last_wave + 1:
		# RF-319 (modo de pruebas): se saltó a una oleada; la que dice es la que viene, sin cartel de inicio.
		_wave_label.text = "→ %d/%d" % [wave + 1, total_waves]
	else:
		_wave_label.text = "%d/%d" % [wave, total_waves]
		if wave > 0:
			_show_wave_banner(wave)
	_last_wave = wave
	# RF-133: la próxima es la oleada número wave + 1, que en la lista está en el índice `wave`.
	show_next_wave(_waves[wave] if wave < _waves.size() else null)


func _on_wave_completed(wave: int, bonus: int) -> void:
	_wave_label.text = "%d/%d ✓" % [wave, _total_waves]
	_wave_label.tooltip_text = Localization.t_fmt(&"hud.wave_completed_tip", {"n": bonus})


func _on_state_changed(state: LevelSession.State) -> void:
	match state:
		LevelSession.State.BUILDING:
			_set_button(Localization.t(&"hud.start_wave"), true)
		LevelSession.State.WAVE_RUNNING:
			_set_button(Localization.t(&"hud.wave_running"), false)
		LevelSession.State.COUNTDOWN:
			_set_button(Localization.t(&"hud.start_wave"), true)
		LevelSession.State.WON:
			_set_button(Localization.t(&"end.victory"), false)
		LevelSession.State.LOST:
			_set_button(Localization.t(&"end.defeat"), false)


## RF-34 / RF-102: el botón muestra la cuenta atrás.
func _on_countdown_changed(seconds_left: float) -> void:
	_start_wave_button.text = Localization.t_fmt(&"hud.start_wave_countdown", {"n": ceili(seconds_left)})
	if _mobile_mode:
		_wave_label.text = "%s · %ds" % [_wave_label.text.get_slice(" · ", 0), ceili(seconds_left)]


func _configure_mobile_top_bar(bar: Control) -> void:
	_mobile_config = MobileUiConfig.load_from()
	var height: float = float(_mobile_config.get_value("barra_alta_px"))
	bar.size.y = height
	bar.custom_minimum_size.y = height
	bar.get_node("Stats").position.y = 0.0
	bar.get_node("Stats").position.x = 20.0
	bar.get_node("Stats").size.y = height
	_exit_button.hide()
	_pause_button.text = Localization.t(&"hud.pause")
	_speed_button.text = "x1"
	var button_height: float = float(_mobile_config.get_value("boton_alto_px"))
	_pause_button.custom_minimum_size.y = button_height
	_speed_button.custom_minimum_size.y = button_height
	_pause_button.custom_minimum_size.x = _pause_button.size.x
	_speed_button.custom_minimum_size.x = _speed_button.size.x
	_pause_button.position.y = 4.0
	_speed_button.position.y = 4.0
	_pause_button.size.y = button_height
	_speed_button.size.y = button_height
	var separation: float = float(_mobile_config.get_value("separacion_px"))
	_speed_button.position.x = _pause_button.position.x + _pause_button.size.x + separation


func _set_button(text: String, enabled: bool) -> void:
	_start_wave_button.text = text
	_start_wave_button.disabled = not enabled


# --- Animaciones de la interfaz (solo visual, spec §9.3) ---

## RF-127: cartel grande "Oleada N" en el centro, que aparece y se desvanece.
func _show_wave_banner(wave: int) -> void:
	_wave_banner.text = Localization.t_fmt(&"hud.wave_banner", {"n": wave})
	_wave_banner.pivot_offset = _wave_banner.size / 2.0
	_wave_banner.modulate.a = 0.0
	_wave_banner.scale = Vector2(0.8, 0.8)
	var tween: Tween = _tween()
	tween.tween_property(_wave_banner, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(_wave_banner, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.9)
	tween.tween_property(_wave_banner, "modulate:a", 0.0, 0.4)
	# RF-135: si la oleada trae un enemigo peligroso, una línea roja abajo, que dura más.
	var danger: EnemyData = null
	if wave - 1 < _waves.size():
		danger = dangerous_enemy_in(_waves[wave - 1])
	_boss_line.text = Localization.t_fmt(&"hud.boss_incoming", {"name": danger.name_text()}) if danger != null else ""
	_boss_line.modulate.a = 0.0
	if danger != null:
		var boss_tween: Tween = _tween()
		boss_tween.tween_property(_boss_line, "modulate:a", 1.0, 0.2)
		boss_tween.tween_interval(2.0)
		boss_tween.tween_property(_boss_line, "modulate:a", 0.0, 0.5)


## RF-129: crece un poco y vuelve.
func _pop(label: Label) -> void:
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(1.25, 1.25)
	_tween().tween_property(label, "scale", Vector2.ONE, 0.15)


## RF-128: parpadea dos veces.
func _blink(label: Label) -> void:
	var tween: Tween = _tween()
	for i: int in 2:
		tween.tween_property(label, "modulate", Color(1, 1, 1, 0.25), 0.06)
		tween.tween_property(label, "modulate", Color.WHITE, 0.06)

func show_collection(count: int, required: int, state: String, collection: StringName = &"technology") -> void:
	(%TechnologyLabel as Label).text = "%d/%d" % [count, required]
	var icon: TextureRect = get_node("TopBar/Stats/TechnologyStat/TechnologyIcon")
	var icon_path: String = CollectionDefinitions.icon_of(collection)
	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path) as Texture2D
	if collection == &"technology":
		icon.tooltip_text = Localization.t_fmt(&"hud.collect_technology", {"state": state})
	else:
		icon.tooltip_text = Localization.t_fmt(&"hud.collect_other", {"name": CollectionDefinitions.name_of(collection), "state": state})
