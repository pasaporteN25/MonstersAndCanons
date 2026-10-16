# Pantalla de opciones (RF-113): volumen de música y efectos, pantalla completa.
# Los cambios se aplican al momento; se guardan al cerrar.
# Se usa desde el menú principal y desde el menú de pausa. Desde el menú principal también ofrece
# entrar y salir del modo de pruebas (RF-383, RF-384).
class_name OptionsMenu
extends Control

signal closed
## RF-383, RF-384: el modo de pruebas cambió desde acá. Quien abrió Opciones decide qué hacer
## (el menú principal se vuelve a armar).
signal dev_mode_changed(on: bool)

const ADMIN_ON_TEXT: String = "Activar modo de pruebas"
const ADMIN_OFF_TEXT: String = "Volver al juego normal"

## RF-383: la sección de administración solo se ofrece desde el menú principal, nunca desde la
## pausa (no se cambia de guardado en medio de una partida). La prende `MainMenu`.
var admin_available: bool = false
## Guardados al entrar y al salir del modo de pruebas. Vacío = los de siempre (`DevMode.SAVE_PATH`
## y `SaveManager.DEFAULT_PATH`); los tests pasan archivos propios.
var dev_save_path: String = ""
var normal_save_path: String = ""

@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _fullscreen_check: CheckBox = %FullscreenCheck
@onready var _damage_numbers_check: CheckBox = %DamageNumbersCheck
@onready var _rows: Control = $Center/Panel/Margin/Rows
@onready var _admin_section: Label = %AdminSection
@onready var _admin_button: Button = %AdminButton
@onready var _admin_confirm: Control = %AdminConfirm
@onready var _admin_confirm_button: Button = %AdminConfirmButton
@onready var _admin_cancel_button: Button = %AdminCancelButton
@onready var _back_button: Button = %BackButton
@onready var _title: Control = $Center/Panel/Margin/Rows/Title

var _ui_mode_selector: OptionButton


func _ready() -> void:
	visible = false
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_damage_numbers_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("damage_numbers", on))  # RF-132
	_build_ui_mode_selector()
	_admin_button.pressed.connect(_on_admin_pressed)
	_admin_confirm_button.pressed.connect(set_dev_mode.bind(true))
	_admin_cancel_button.pressed.connect(_on_admin_cancel)
	_back_button.pressed.connect(close)
	Audio.add_click_sounds(self)
	_refresh_admin()


func open() -> void:
	# set_value_no_signal: mostrar lo guardado sin "cambiarlo" de nuevo.
	_music_slider.set_value_no_signal(float(SaveManager.get_setting("music_volume")))
	_sfx_slider.set_value_no_signal(float(SaveManager.get_setting("sfx_volume")))
	_fullscreen_check.set_pressed_no_signal(bool(SaveManager.get_setting("fullscreen")))
	_damage_numbers_check.set_pressed_no_signal(bool(SaveManager.get_setting("damage_numbers")))
	_ui_mode_selector.select(UiMode.read_setting(SaveManager.get_setting("ui_mode")))
	_set_confirming(false)
	visible = true


func close() -> void:
	SaveManager.save()
	visible = false
	closed.emit()


## RF-383, RF-384: entra o sale del modo de pruebas. Primero guarda lo que se cambió en Opciones en el
## guardado que se deja; después cambia de guardado y aplica sus volúmenes y su pantalla.
func set_dev_mode(on: bool) -> void:
	SaveManager.save()
	DevMode.set_enabled(on, dev_save_path if on else normal_save_path)
	Audio.apply_volumes()
	GameFlow.apply_display_settings()
	_set_confirming(false)
	dev_mode_changed.emit(on)


func is_admin_visible() -> bool:
	return _admin_section.visible and _admin_button.visible


func is_confirm_visible() -> bool:
	return _admin_confirm.visible


func admin_button_text() -> String:
	return _admin_button.text


func _refresh_admin() -> void:
	_admin_section.visible = admin_available
	_admin_button.visible = admin_available
	_admin_button.text = ADMIN_OFF_TEXT if DevMode.enabled else ADMIN_ON_TEXT


## RF-383: la confirmación ocupa el panel entero (solo queda el título), así el panel no crece y
## entra en una pantalla de 720 de alto. Al salir, vuelve todo como estaba.
func _set_confirming(on: bool) -> void:
	for child: Node in _rows.get_children():
		if child != _title:
			(child as Control).visible = not on
	_admin_confirm.visible = on
	if not on:
		_refresh_admin()


## RF-383: activar pide confirmación; RF-384: volver al juego normal no.
func _on_admin_pressed() -> void:
	if DevMode.enabled:
		set_dev_mode(false)
		return
	_set_confirming(true)
	_admin_confirm_button.grab_focus()


func _on_admin_cancel() -> void:
	_set_confirming(false)
	_admin_button.grab_focus()


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


func _build_ui_mode_selector() -> void:
	var label := Label.new()
	label.text = "Interfaz"
	label.add_theme_font_size_override("font_size", 20)
	_rows.add_child(label)
	_ui_mode_selector = OptionButton.new()
	_ui_mode_selector.name = "UiModeSelector"
	_ui_mode_selector.add_item("Automática", UiMode.AUTOMATIC)
	_ui_mode_selector.add_item("Celular", UiMode.MOBILE)
	_ui_mode_selector.add_item("PC", UiMode.PC)
	_ui_mode_selector.custom_minimum_size.y = 44
	_rows.add_child(_ui_mode_selector)
	_ui_mode_selector.item_selected.connect(func(index: int) -> void:
		SaveManager.set_setting("ui_mode", _ui_mode_selector.get_item_id(index)))
