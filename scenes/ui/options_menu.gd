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
## M63 (RF-576): el tutorial del nivel 1, en una sola fila para que el panel no crezca.
const TUTORIAL_CHECK_TEXT: String = "Tutorial del nivel 1"
const TUTORIAL_REPLAY_TEXT: String = "Volver a verlo"
const TUTORIAL_REPLAYED_TEXT: String = "Se verá en el nivel 1"
## M66 (RF-600): la entrada de los jefes.
const BOSS_ENTRANCE_TEXT: String = "Entrada de los jefes"

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
@onready var _upgrade_fx_check: CheckBox = %UpgradeFxCheck
@onready var _panel: PanelContainer = %Panel
@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = $Center/Panel/Margin/Frame/Scroll/Columns/Rows
@onready var _side: VBoxContainer = %Side
@onready var _admin_section: Label = %AdminSection
@onready var _admin_button: Button = %AdminButton
@onready var _admin_confirm: Control = %AdminConfirm
@onready var _admin_confirm_button: Button = %AdminConfirmButton
@onready var _admin_cancel_button: Button = %AdminCancelButton
@onready var _back_button: Button = %BackButton
@onready var _version_label: Label = %VersionLabel
@onready var _credits_button: Button = %CreditsButton
@onready var _title: Control = $Center/Panel/Margin/Frame/Title

## RF-550: en el modo celular, dos columnas (la de la derecha es `_side`); en PC, una sola (RF-555).
const MOBILE_PANEL_WIDTH: float = 880.0
## Aire arriba y abajo de la ventana (RF-555): el centro se desplaza antes de tocar los bordes.
const WINDOW_MARGIN: float = 24.0

var _ui_mode_selector: OptionButton
var _ui_mode_label: Label
var _two_columns: bool = false
## RF-553: los créditos de siempre (RF-472), hijos de Opciones; al cerrarlos se vuelve acá.
var credits: CreditsScreen
var _tutorial_check: CheckBox
var _tutorial_replay: Button
var _boss_entrance_check: CheckBox


func _ready() -> void:
	visible = false
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_damage_numbers_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("damage_numbers", on))  # RF-132
	_upgrade_fx_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("upgrade_fx", on))  # M65, RF-593
	_build_tutorial_row()
	_build_ui_mode_selector()
	# RF-593: justo debajo de «Mostrar números de daño» (las filas de arriba también se meten ahí).
	_rows.move_child(_upgrade_fx_check, _damage_numbers_check.get_index() + 1)
	_build_boss_entrance_check()  # M66
	_arrange_columns()
	_admin_button.pressed.connect(_on_admin_pressed)
	_admin_confirm_button.pressed.connect(set_dev_mode.bind(true))
	_admin_cancel_button.pressed.connect(_on_admin_cancel)
	_back_button.pressed.connect(close)
	_version_label.text = GameVersion.label(GameVersion.raw())  # RF-554
	credits = CreditsScreen.new()
	add_child(credits)
	credits.closed.connect(_credits_button.grab_focus)
	_credits_button.pressed.connect(credits.open)
	Audio.add_click_sounds(self)
	_refresh_admin()
	MenuTouch.attach(self)  # RF-550, RF-551: botones de 56 px y desplazamiento táctil en el celular
	resized.connect(_fit_scroll)


func open() -> void:
	# set_value_no_signal: mostrar lo guardado sin "cambiarlo" de nuevo.
	_music_slider.set_value_no_signal(float(SaveManager.get_setting("music_volume")))
	_sfx_slider.set_value_no_signal(float(SaveManager.get_setting("sfx_volume")))
	_fullscreen_check.set_pressed_no_signal(bool(SaveManager.get_setting("fullscreen")))
	_damage_numbers_check.set_pressed_no_signal(bool(SaveManager.get_setting("damage_numbers")))
	_upgrade_fx_check.set_pressed_no_signal(SaveManager.upgrade_fx_enabled())
	_ui_mode_selector.select(UiMode.read_setting(SaveManager.get_setting("ui_mode")))
	_boss_entrance_check.set_pressed_no_signal(SaveManager.boss_entrance_enabled())  # M66
	_tutorial_check.set_pressed_no_signal(SaveManager.tutorial_enabled())
	_tutorial_replay.text = TUTORIAL_REPLAY_TEXT
	_tutorial_replay.disabled = false
	_set_confirming(false)
	visible = true
	_fit_scroll()


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
	for column: Control in [_rows, _side]:
		if column == null:
			continue
		for child: Node in column.get_children():
			if child != _admin_confirm:
				(child as Control).visible = not on
	_rows.visible = not (on and _two_columns)  # en dos columnas, la confirmación queda sola y centrada
	_back_button.visible = not on
	_admin_confirm.visible = on
	if not on:
		_refresh_admin()
	_fit_scroll.call_deferred()


## RF-550 / RF-555: en el celular, dos columnas y un panel ancho; en PC, la columna única de siempre (lo de la
## columna derecha se agrega al final de la izquierda, en el mismo orden).
func _arrange_columns() -> void:
	_two_columns = UiMode.is_mobile()
	if _two_columns:
		_panel.custom_minimum_size.x = MOBILE_PANEL_WIDTH
		# «Interfaz» encabeza la columna derecha: así la izquierda (sonido y pantalla) entra sin desplazar.
		_ui_mode_label.reparent(_side, false)
		_ui_mode_selector.reparent(_side, false)
		_side.move_child(_ui_mode_label, 0)
		_side.move_child(_ui_mode_selector, 1)
		return
	for child: Node in _side.get_children():
		child.reparent(_rows, false)
	_side.queue_free()
	_side = null


## RF-555: el centro se desplaza si el panel no entra en la ventana; si entra, el panel mide lo que mide su
## contenido (el título y «Volver» quedan siempre a la vista).
func _fit_scroll() -> void:
	if not is_inside_tree():
		return
	var content: float = (_scroll.get_child(0) as Control).get_combined_minimum_size().y
	var chrome: float = _panel.get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y
	var available: float = size.y - WINDOW_MARGIN * 2.0 - chrome
	_scroll.custom_minimum_size.y = minf(content, maxf(available, 120.0))


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


## RF-576: la casilla prende o apaga el tutorial (al prenderla de nuevo, vuelve a salir); el botón lo vuelve a
## armar para la próxima vez que se entre al nivel 1. Va debajo de «Mostrar números de daño».
func _build_tutorial_row() -> void:
	var row := HBoxContainer.new()
	row.name = "TutorialRow"
	row.add_theme_constant_override("separation", 8)
	_tutorial_check = CheckBox.new()
	_tutorial_check.name = "TutorialCheck"
	_tutorial_check.text = TUTORIAL_CHECK_TEXT
	_tutorial_check.add_theme_font_size_override("font_size", 18)
	_tutorial_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tutorial_check.clip_text = true  # que la fila no ensanche el panel (M61 fija 460 px)
	row.add_child(_tutorial_check)
	_tutorial_replay = Button.new()
	_tutorial_replay.name = "TutorialReplay"
	_tutorial_replay.text = TUTORIAL_REPLAY_TEXT
	_tutorial_replay.add_theme_font_size_override("font_size", 15)
	_tutorial_replay.custom_minimum_size.y = 44
	row.add_child(_tutorial_replay)
	_rows.add_child(row)
	_rows.move_child(row, _damage_numbers_check.get_index() + 1)
	_tutorial_check.toggled.connect(_on_tutorial_toggled)
	_tutorial_replay.pressed.connect(_on_tutorial_replay)


func _on_tutorial_toggled(on: bool) -> void:
	if on:
		SaveManager.reset_tutorial()  # volver a prenderlo = querer verlo de nuevo
	else:
		SaveManager.set_setting("tutorial_enabled", false)


func _on_tutorial_replay() -> void:
	SaveManager.reset_tutorial()
	_tutorial_check.set_pressed_no_signal(true)
	_tutorial_replay.text = TUTORIAL_REPLAYED_TEXT
	_tutorial_replay.disabled = true


## M66, RF-600: «Entrada de los jefes». Va debajo de «Mostrar números de daño» y del tutorial (y de
## «Animaciones de mejora» si M65 está). Una casilla simple: la lee `Game` al aparecer un jefe.
func _build_boss_entrance_check() -> void:
	_boss_entrance_check = CheckBox.new()
	_boss_entrance_check.name = "BossEntranceCheck"
	_boss_entrance_check.text = BOSS_ENTRANCE_TEXT
	_boss_entrance_check.add_theme_font_size_override("font_size", 20)
	_boss_entrance_check.clip_text = true  # que la fila no ensanche el panel
	_rows.add_child(_boss_entrance_check)
	# Después de la fila del tutorial, que tiene que quedar pegada a «Mostrar números de daño» (RF-576).
	var anchor: Node = _rows.get_node_or_null("TutorialRow")
	if anchor == null:
		anchor = _damage_numbers_check
	_rows.move_child(_boss_entrance_check, anchor.get_index() + 1)
	_boss_entrance_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("boss_entrance", on))


func _build_ui_mode_selector() -> void:
	# RF-555: «Interfaz» va dentro de «Visualización», después de los números de daño (antes quedaba tras «Volver»).
	var label := Label.new()
	_ui_mode_label = label
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
	var after: int = _damage_numbers_check.get_index() + 1
	_rows.move_child(label, after)
	_rows.move_child(_ui_mode_selector, after + 1)
	_ui_mode_selector.item_selected.connect(func(index: int) -> void:
		SaveManager.set_setting("ui_mode", _ui_mode_selector.get_item_id(index)))
