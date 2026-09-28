# Pantalla de opciones (RF-113): volumen de música y efectos, pantalla completa.
# Los cambios se aplican al momento; se guardan al cerrar.
# Se usa desde el menú principal y desde el menú de pausa.
class_name OptionsMenu
extends Control

signal closed

@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _fullscreen_check: CheckBox = %FullscreenCheck
@onready var _damage_numbers_check: CheckBox = %DamageNumbersCheck
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	visible = false
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_damage_numbers_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("damage_numbers", on))  # RF-132
	_back_button.pressed.connect(close)
	Audio.add_click_sounds(self)


func open() -> void:
	# set_value_no_signal: mostrar lo guardado sin "cambiarlo" de nuevo.
	_music_slider.set_value_no_signal(float(SaveManager.get_setting("music_volume")))
	_sfx_slider.set_value_no_signal(float(SaveManager.get_setting("sfx_volume")))
	_fullscreen_check.set_pressed_no_signal(bool(SaveManager.get_setting("fullscreen")))
	_damage_numbers_check.set_pressed_no_signal(bool(SaveManager.get_setting("damage_numbers")))
	visible = true


func close() -> void:
	SaveManager.save()
	visible = false
	closed.emit()


func _on_music_changed(value: float) -> void:
	SaveManager.set_setting("music_volume", value)
	Audio.apply_volumes()


func _on_sfx_changed(value: float) -> void:
	SaveManager.set_setting("sfx_volume", value)
	Audio.apply_volumes()
	Audio.play(&"click")  # para escuchar el volumen nuevo


func _on_fullscreen_toggled(on: bool) -> void:
	SaveManager.set_setting("fullscreen", on)
	GameFlow.apply_display_settings()
