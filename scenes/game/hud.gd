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

## RF-170: botones compactos, para que entren 9 torres (M19) sin tapar "Próxima oleada" (D-026).
const TOWER_BUTTON_SIZE := Vector2(76, 60)
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
## -1 = todavía no se mostró ningún valor (para no animar el primero).
var _last_gold: int = -1
var _last_lives: int = -1
var _last_score: int = -1

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
@onready var _pause_button: Button = %PauseButton
@onready var _speed_button: Button = %SpeedButton
@onready var _pause_label: Label = %PauseLabel
@onready var _build_info: Control = %BuildInfo
@onready var _build_info_name: Label = %BuildInfoName
@onready var _build_info_text: Label = %BuildInfoText


func _ready() -> void:
	_start_wave_button.pressed.connect(start_wave_pressed.emit)
	_pause_button.pressed.connect(pause_pressed.emit)
	_speed_button.pressed.connect(speed_pressed.emit)
	show_paused(false)
	show_speed(1.0)


## RF-104: texto del botón y cartel "PAUSA".
## `show_label` = false cuando el menú de pausa ya lo dice (no mostrar dos veces).
func show_paused(paused: bool, show_label: bool = true) -> void:
	_pause_button.text = "Seguir  [P]" if paused else "Pausa  [P]"
	_pause_label.visible = paused and show_label


## RF-105: el botón muestra la velocidad actual.
func show_speed(speed: float) -> void:
	_speed_button.text = "%s  [F]" % Rules.speed_text(speed)  # RF-322: x0,5 no se redondea a x0


## Game le pasa las oleadas del nivel ANTES de bind() (RF-133, RF-135).
func setup_waves(waves: Array[WaveData]) -> void:
	_waves = waves


## RF-133: muestra los enemigos de la oleada `wave` (o nada, si es null).
func show_next_wave(wave: WaveData) -> void:
	for child: Node in _next_wave_icons.get_children():
		child.queue_free()
	_next_wave.visible = wave != null
	if wave == null:
		return
	var counts: Dictionary = wave.enemy_counts()
	for enemy: EnemyData in counts:
		_next_wave_icons.add_child(EnemyIcon.new().setup(enemy, counts[enemy]))


## RF-134: tarjeta "Nuevo enemigo" con su forma, nombre y qué hace.
func show_enemy_intro(enemy: EnemyData) -> void:
	_intro_queue.append(enemy)
	if not _intro_busy:
		_show_next_intro()


func _show_next_intro() -> void:
	if _intro_queue.is_empty():
		_intro_busy = false
		_intro.visible = false
		return
	_intro_busy = true
	var enemy: EnemyData = _intro_queue.pop_front()
	for child: Node in _intro_icon_slot.get_children():
		child.queue_free()
	_intro_icon_slot.add_child(EnemyIcon.new().setup(enemy))
	_intro_name.text = "Nuevo enemigo: %s" % enemy.display_name
	_intro_text.text = enemy.description
	_intro.visible = true
	_intro.modulate.a = 0.0
	var tween: Tween = create_tween()
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
	session.lives_changed.connect(_on_lives_changed)
	session.score_changed.connect(_on_score_changed)
	session.wave_changed.connect(_on_wave_changed)
	session.wave_completed.connect(_on_wave_completed)
	session.state_changed.connect(_on_state_changed)
	session.countdown_changed.connect(_on_countdown_changed)


## RF-101: un botón por torre, con su color, nombre, tecla y costo.
func setup_towers(tower_types: Array[TowerData]) -> void:
	_tower_types = tower_types
	for i: int in tower_types.size():
		var tower: TowerData = tower_types[i]
		var button := Button.new()
		button.custom_minimum_size = TOWER_BUTTON_SIZE
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		# RF-170: dibujo arriba, costo abajo y la tecla en una esquina. El nombre, al pasar el mouse.
		button.text = str(tower.levels[0].cost)
		button.tooltip_text = "%s (tecla %d): %d de oro" % [tower.display_name, i + 1, tower.levels[0].cost]
		button.add_theme_font_size_override("font_size", 15)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.add_child(_key_label(i + 1))
		var icon: Texture2D = Tower.make_icon(tower)
		if icon != null:
			# RF-155: base y torreta, como la torre recién construida, achicadas con suavidad (D-023).
			button.icon = icon
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", TOWER_ICON_SIZE)
			button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		else:  # RF-156: sin dibujo, un cuadradito de su color.
			button.icon = _color_swatch(tower.color)
		button.pressed.connect(tower_button_pressed.emit.bind(i))
		_tower_button_row.add_child(button)
		_tower_buttons.append(button)


## RF-170: número de la tecla, chiquito, en la esquina de arriba a la izquierda del botón.
func _key_label(key: int) -> Label:
	var label := Label.new()
	label.text = str(key)
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
	_build_info.visible = index >= 0
	if index >= 0:
		var tower: TowerData = _tower_types[index]
		_build_info_name.text = "%s · %d de oro" % [tower.display_name, tower.levels[0].cost]
		_build_info_text.text = tower.description
		if tower.footprint > 1:  # RF-298
			_build_info_text.text += " Necesita %d×%d casillas libres." % [tower.footprint, tower.footprint]
		var combo: String = TowerText.combo_hint(tower, _tower_types)  # RF-317
		if combo != "":
			_build_info_text.text += " " + combo


func _on_gold_changed(gold: int) -> void:
	_gold_label.text = "Oro: %d" % gold
	if _last_gold >= 0 and gold != _last_gold:
		_pop(_gold_label)  # RF-129
	_last_gold = gold
	# RF-101: gris si no alcanza el oro.
	for i: int in _tower_buttons.size():
		_tower_buttons[i].disabled = gold < _tower_types[i].levels[0].cost


## RF-190: los puntos, con el mismo "pop" que el oro.
func _on_score_changed(score: int) -> void:
	_score_label.text = "Puntos: %d" % score
	if _last_score >= 0 and score != _last_score:
		_pop(_score_label)
	_last_score = score


func _on_lives_changed(lives: int) -> void:
	_lives_label.text = "Vidas: %d" % lives
	if _last_lives >= 0 and lives < _last_lives:
		_blink(_lives_label)  # RF-128
	_last_lives = lives


func _on_wave_changed(wave: int, total_waves: int) -> void:
	_total_waves = total_waves
	if wave > 0 and wave != _last_wave + 1:
		# RF-319 (modo de pruebas): se saltó a una oleada; la que dice es la que viene, sin cartel de inicio.
		_wave_label.text = "Próxima: oleada %d/%d" % [wave + 1, total_waves]
	else:
		_wave_label.text = "Oleada %d/%d" % [wave, total_waves]
		if wave > 0:
			_show_wave_banner(wave)
	_last_wave = wave
	# RF-133: la próxima es la oleada número wave + 1, que en la lista está en el índice `wave`.
	show_next_wave(_waves[wave] if wave < _waves.size() else null)


func _on_wave_completed(wave: int, bonus: int) -> void:
	_wave_label.text = "Oleada %d/%d completada (+%d de oro)" % [wave, _total_waves, bonus]


func _on_state_changed(state: LevelSession.State) -> void:
	match state:
		LevelSession.State.BUILDING:
			_set_button("Empezar oleada", true)
		LevelSession.State.WAVE_RUNNING:
			_set_button("Oleada en curso", false)
		LevelSession.State.COUNTDOWN:
			_set_button("Empezar oleada", true)
		LevelSession.State.WON:
			_set_button("¡Victoria!", false)
		LevelSession.State.LOST:
			_set_button("Derrota", false)


## RF-34 / RF-102: el botón muestra la cuenta atrás.
func _on_countdown_changed(seconds_left: float) -> void:
	_start_wave_button.text = "Empezar oleada (%d)" % ceili(seconds_left)


func _set_button(text: String, enabled: bool) -> void:
	_start_wave_button.text = text
	_start_wave_button.disabled = not enabled


# --- Animaciones de la interfaz (solo visual, spec §9.3) ---

## RF-127: cartel grande "Oleada N" en el centro, que aparece y se desvanece.
func _show_wave_banner(wave: int) -> void:
	_wave_banner.text = "Oleada %d" % wave
	_wave_banner.pivot_offset = _wave_banner.size / 2.0
	_wave_banner.modulate.a = 0.0
	_wave_banner.scale = Vector2(0.8, 0.8)
	var tween: Tween = create_tween()
	tween.tween_property(_wave_banner, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(_wave_banner, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.9)
	tween.tween_property(_wave_banner, "modulate:a", 0.0, 0.4)
	# RF-135: si la oleada trae un enemigo peligroso, una línea roja abajo, que dura más.
	var danger: EnemyData = null
	if wave - 1 < _waves.size():
		danger = dangerous_enemy_in(_waves[wave - 1])
	_boss_line.text = "¡Llega el %s!" % danger.display_name if danger != null else ""
	_boss_line.modulate.a = 0.0
	if danger != null:
		var boss_tween: Tween = create_tween()
		boss_tween.tween_property(_boss_line, "modulate:a", 1.0, 0.2)
		boss_tween.tween_interval(2.0)
		boss_tween.tween_property(_boss_line, "modulate:a", 0.0, 0.5)


## RF-129: crece un poco y vuelve.
func _pop(label: Label) -> void:
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(1.25, 1.25)
	create_tween().tween_property(label, "scale", Vector2.ONE, 0.15)


## RF-128: parpadea dos veces.
func _blink(label: Label) -> void:
	var tween: Tween = create_tween()
	for i: int in 2:
		tween.tween_property(label, "modulate", Color(1, 1, 1, 0.25), 0.06)
		tween.tween_property(label, "modulate", Color.WHITE, 0.06)
