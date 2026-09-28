# Interfaz de la partida (spec §9.1). Solo MUESTRA datos y AVISA cuando se pulsa algo:
# no cambia el oro ni empieza oleadas por su cuenta (plan §5.2).
class_name Hud
extends CanvasLayer

signal start_wave_pressed
## Se pulsó el botón de la torre número `index` (0 = la primera).
signal tower_button_pressed(index: int)

const TOWER_BUTTON_SIZE := Vector2(176, 60)

var _total_waves: int = 0
var _tower_types: Array[TowerData] = []
var _tower_buttons: Array[Button] = []

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _start_wave_button: Button = %StartWaveButton
@onready var _tower_button_row: HBoxContainer = %TowerButtons


func _ready() -> void:
	_start_wave_button.pressed.connect(start_wave_pressed.emit)


## Game le pasa la sesión para que el HUD se mantenga actualizado.
func bind(session: LevelSession) -> void:
	session.gold_changed.connect(_on_gold_changed)
	session.lives_changed.connect(_on_lives_changed)
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
		button.text = "%d · %s
%d de oro" % [i + 1, tower.display_name, tower.levels[0].cost]
		button.add_theme_font_size_override("font_size", 16)
		button.icon = _color_swatch(tower.color)
		button.pressed.connect(tower_button_pressed.emit.bind(i))
		_tower_button_row.add_child(button)
		_tower_buttons.append(button)


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


func _on_gold_changed(gold: int) -> void:
	_gold_label.text = "Oro: %d" % gold
	# RF-101: gris si no alcanza el oro.
	for i: int in _tower_buttons.size():
		_tower_buttons[i].disabled = gold < _tower_types[i].levels[0].cost


func _on_lives_changed(lives: int) -> void:
	_lives_label.text = "Vidas: %d" % lives


func _on_wave_changed(wave: int, total_waves: int) -> void:
	_total_waves = total_waves
	_wave_label.text = "Oleada %d/%d" % [wave, total_waves]


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
