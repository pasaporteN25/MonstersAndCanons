# Interfaz de la partida (spec §9.1). Solo MUESTRA datos y AVISA cuando se pulsa algo:
# no cambia el oro ni empieza oleadas por su cuenta (plan §5.2).
class_name Hud
extends CanvasLayer

signal start_wave_pressed

var _total_waves: int = 0

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _start_wave_button: Button = %StartWaveButton


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


func _on_gold_changed(gold: int) -> void:
	_gold_label.text = "Oro: %d" % gold


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
