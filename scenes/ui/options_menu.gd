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
## M66 (RF-672): la presentación de los jefes. La clave de guardado sigue siendo `boss_entrance`.
const BOSS_ENTRANCE_TEXT: String = "Presentación de los jefes"
## M70 (RF-644): preferencia para ocultar los consejos de la pantalla de derrota.
const DEFEAT_ADVICE_TEXT: String = "Consejos en la derrota"
## M75, RF-678.
const RANGE_DISPLAY_TEXT: String = "Círculo de alcance"
## M68 (RF-614): la tecla de «Ver todo».
const VIEW_ALL_LABEL: String = "Tecla de «Ver todo»"
const VIEW_ALL_PROMPT: String = "Presioná una tecla…"
const VIEW_ALL_RESTORE: String = "Restaurar"
## M67 (RF-607): el botón de las novedades y su texto cuando no hay nada para abrir.
const NEWS_BUTTON_TEXT: String = "Novedades de esta versión"
const NEWS_EMPTY_TEXT: String = "No hay novedades"

## M75 (RF-684, D-197) y RF-708: filas por solapa en orden de lectura.
const OPTION_GROUP_NAMES: Array[String] = ["Sonido", "Pantalla", "Partida y ayudas", "Controles", "Avanzado"]
const OPTION_GROUP_ROWS: Array = [
	[&"MusicLabel", &"MusicSlider", &"SfxLabel", &"SfxSlider"],
	[&"FullscreenCheck", &"DamageNumbersCheck", &"UpgradeFxCheck", &"RangeDisplayLabel", &"RangeDisplaySelector"],
	[&"TutorialRow", &"BossEntranceCheck", &"DefeatAdviceCheck"],
	[&"ViewAllRow"],
	[&"UiModeLabel", &"UiModeSelector", &"CreditsSection", &"VersionLabel", &"CreditsButton", &"NewsButton",
		&"AdminSection", &"AdminButton", &"AdminConfirm"],
]
const OPTIONS_PANEL_WIDTH: float = 920.0
const MOBILE_PANEL_WIDTH: float = 880.0
const WINDOW_MARGIN: float = 24.0

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
@onready var _tabs: HBoxContainer = %Tabs
@onready var _admin_section: Label = %AdminSection
@onready var _admin_button: Button = %AdminButton
@onready var _admin_confirm: Control = %AdminConfirm
@onready var _admin_confirm_button: Button = %AdminConfirmButton
@onready var _admin_cancel_button: Button = %AdminCancelButton
@onready var _back_button: Button = %BackButton
@onready var _version_label: Label = %VersionLabel
@onready var _credits_button: Button = %CreditsButton
@onready var _title: Control = $Center/Panel/Margin/Frame/Title

var _ui_mode_selector: OptionButton
var _group_pages: Array[VBoxContainer] = []
var _tab_buttons: Array[Button] = []
var _active_tab: int = 0
## RF-553: los créditos de siempre (RF-472), hijos de Opciones; al cerrarlos se vuelve acá.
var credits: CreditsScreen
var _tutorial_check: CheckBox
## M67 (RF-607): «Novedades de esta versión», debajo de «Ver créditos». Costuras para los tests: de dónde se leen y qué
## versión está instalada.
var news: NewsScreen
var news_path: String = NewsData.DEFAULT_PATH
var news_version_source: Callable = GameVersion.raw
var _news_button: Button
var _news_data: NewsData
var _tutorial_replay: Button
var _boss_entrance_check: CheckBox
var _defeat_advice_check: CheckBox
var _range_display_selector: OptionButton
## M68 (RF-614): la fila de la tecla de «Ver todo» (solo con la interfaz de PC), el botón que la muestra y el aviso.
var _view_all_button: Button
var _view_all_restore: Button
var _view_all_note: Label
var _view_all_capturing: bool = false


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
	_build_boss_entrance_check()  # M66
	_build_defeat_advice_check()  # M70, RF-644
	if not UiMode.is_mobile():
		_build_view_all_row()  # M68: sin teclado no hace falta
	_build_range_display_selector()  # M75
	_build_news_button()  # M67
	_build_tabs_and_pages()  # RF-708: categorías en solapas superiores
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
	_range_display_selector.select(SaveManager.range_display())
	_ui_mode_selector.select(UiMode.read_setting(SaveManager.get_setting("ui_mode")))
	_boss_entrance_check.set_pressed_no_signal(SaveManager.boss_entrance_enabled())  # M66
	_defeat_advice_check.set_pressed_no_signal(SaveManager.defeat_advice_enabled())  # M70, RF-644
	_tutorial_check.set_pressed_no_signal(SaveManager.tutorial_enabled())
	_stop_view_all_capture()
	_refresh_view_all_row()
	_tutorial_replay.text = TUTORIAL_REPLAY_TEXT
	_tutorial_replay.disabled = false
	_refresh_news_button()
	_set_confirming(false)
	visible = true
	_fit_scroll()


func close() -> void:
	_stop_view_all_capture()
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
	return _admin_section.visible and _admin_button.visible and not _admin_confirm.visible


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
	_tabs.visible = not on
	for index: int in _group_pages.size():
		_group_pages[index].visible = not on and index == _active_tab
	if on and _admin_confirm.get_parent() != _rows:
		_admin_confirm.reparent(_rows, false)
	elif not on and _admin_confirm.get_parent() == _rows:
		_admin_confirm.reparent(_group_pages.back(), false)
	_back_button.visible = not on
	_admin_confirm.visible = on
	if not on:
		_refresh_admin()
	_fit_scroll.call_deferred()


## RF-708: cada categoría tiene una solapa y una página desplazable; «Controles» no se crea en celular.
func _build_tabs_and_pages() -> void:
	var by_name: Dictionary = {}
	for column: Control in [_rows, _side]:
		for child: Node in column.get_children():
			by_name[StringName(child.name)] = child
	_panel.custom_minimum_size.x = MOBILE_PANEL_WIDTH if UiMode.is_mobile() else OPTIONS_PANEL_WIDTH
	var button_group: ButtonGroup = ButtonGroup.new()
	for group_index: int in OPTION_GROUP_ROWS.size():
		if UiMode.is_mobile() and group_index == 3:
			continue
		var page: VBoxContainer = VBoxContainer.new()
		page.name = "OptionsPage%d" % group_index
		page.add_theme_constant_override("separation", 12)
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_rows.add_child(page)
		for node_name: StringName in OPTION_GROUP_ROWS[group_index]:
			var node: Node = by_name.get(node_name)
			if node == null:
				push_error("Opciones: no existe la fila «%s» de «%s»" % [node_name, OPTION_GROUP_NAMES[group_index]])
				continue
			node.reparent(page, false)
		_group_pages.append(page)
		var tab: Button = Button.new()
		tab.name = "Tab%d" % group_index
		tab.text = "Partida\ny ayudas" if group_index == 2 else OPTION_GROUP_NAMES[group_index]
		tab.toggle_mode = true
		tab.button_group = button_group
		tab.custom_minimum_size.y = 48.0
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_theme_font_size_override("font_size", 17)
		# Apariencia de solapa clásica: sin marco de botón, y una línea inferior
		# dorada marca la categoría activa.
		var normal: StyleBoxFlat = StyleBoxFlat.new()
		normal.bg_color = Color.TRANSPARENT
		normal.border_width_bottom = 2
		normal.border_color = Color("514839")
		var hover: StyleBoxFlat = StyleBoxFlat.new()
		hover.bg_color = Color("252728")
		hover.border_width_bottom = 2
		hover.border_color = Color("a7834a")
		var selected: StyleBoxFlat = StyleBoxFlat.new()
		selected.bg_color = Color("262522")
		selected.border_width_bottom = 3
		selected.border_color = Color("e4ad4c")
		tab.add_theme_stylebox_override("normal", normal)
		tab.add_theme_stylebox_override("hover", hover)
		tab.add_theme_stylebox_override("pressed", selected)
		tab.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		tab.pressed.connect(_select_tab.bind(_tab_buttons.size()))
		_tabs.add_child(tab)
		_tab_buttons.append(tab)
	for title_name: StringName in [&"SoundSection", &"DisplaySection", &"GameSection", &"ControlsSection", &"AdvancedSection"]:
		var title: Node = by_name.get(title_name)
		if title != null:
			title.free()
	for index: int in _group_pages.size():
		_rows.move_child(_group_pages[index], index)
	_side.free()
	_side = null
	_select_tab(0)


func _select_tab(index: int) -> void:
	if index < 0 or index >= _group_pages.size():
		return
	_active_tab = index
	for page_index: int in _group_pages.size():
		_group_pages[page_index].visible = page_index == index
	for button_index: int in _tab_buttons.size():
		_tab_buttons[button_index].button_pressed = button_index == index
	_fit_scroll.call_deferred()


## RF-555: el centro se desplaza si el panel no entra en la ventana; si entra, el panel mide lo que mide su
## contenido (el título y «Volver» quedan siempre a la vista).
func _fit_scroll() -> void:
	if not is_inside_tree():
		return
	var preferred_width: float = MOBILE_PANEL_WIDTH if UiMode.is_mobile() else OPTIONS_PANEL_WIDTH
	_panel.custom_minimum_size.x = minf(preferred_width, maxf(size.x - WINDOW_MARGIN * 2.0, 460.0))
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
## armar para la próxima vez que se entre al nivel 1. Va en «Partida y ayudas».
func _build_tutorial_row() -> void:
	var row: BoxContainer = VBoxContainer.new() if UiMode.is_mobile() else HBoxContainer.new()
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
	_tutorial_replay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_tutorial_replay)
	_rows.add_child(row)
	_tutorial_check.toggled.connect(_on_tutorial_toggled)
	_tutorial_replay.pressed.connect(_on_tutorial_replay)


## M75, RF-678: Oculto también es el valor para guardados viejos.
func _build_range_display_selector() -> void:
	var label := Label.new()
	label.name = "RangeDisplayLabel"
	label.text = RANGE_DISPLAY_TEXT
	label.add_theme_font_size_override("font_size", 20)
	_rows.add_child(label)
	_range_display_selector = OptionButton.new()
	_range_display_selector.name = "RangeDisplaySelector"
	_range_display_selector.add_item("Oculto", 0)
	_range_display_selector.add_item("Sutil", 1)
	_range_display_selector.add_item("Completo", 2)
	_range_display_selector.custom_minimum_size.y = 44
	_rows.add_child(_range_display_selector)
	_range_display_selector.item_selected.connect(func(selected: int) -> void:
		SaveManager.set_setting("range_display", _range_display_selector.get_item_id(selected)))


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


## M66, RF-672: «Presentación de los jefes», en «Partida y ayudas». Una casilla simple: la lee `Game` al aparecer un jefe.
func _build_boss_entrance_check() -> void:
	_boss_entrance_check = CheckBox.new()
	_boss_entrance_check.name = "BossEntranceCheck"
	_boss_entrance_check.text = BOSS_ENTRANCE_TEXT
	_boss_entrance_check.add_theme_font_size_override("font_size", 20)
	_boss_entrance_check.clip_text = true  # que la fila no ensanche el panel
	_rows.add_child(_boss_entrance_check)
	_boss_entrance_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("boss_entrance", on))


## M70, RF-644: «Consejos en la derrota». Comparte Opciones entre menú y pausa.
func _build_defeat_advice_check() -> void:
	_defeat_advice_check = CheckBox.new()
	_defeat_advice_check.name = "DefeatAdviceCheck"
	_defeat_advice_check.text = DEFEAT_ADVICE_TEXT
	_defeat_advice_check.add_theme_font_size_override("font_size", 20)
	_defeat_advice_check.clip_text = true
	_rows.add_child(_defeat_advice_check)
	_defeat_advice_check.toggled.connect(
		func(on: bool) -> void: SaveManager.set_setting("defeat_advice", on))


## M68 (RF-614): una fila con el nombre, un botón con la tecla de hoy (al pulsarlo espera la próxima tecla),
## «Restaurar» (vuelve a la V) y, debajo, el aviso cuando la tecla elegida ya la usa otra cosa.
func _build_view_all_row() -> void:
	var box := VBoxContainer.new()
	box.name = "ViewAllRow"
	box.add_theme_constant_override("separation", 4)
	var label := Label.new()
	label.text = VIEW_ALL_LABEL
	label.add_theme_font_size_override("font_size", 20)
	box.add_child(label)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	box.add_child(line)
	_view_all_button = Button.new()
	_view_all_button.name = "ViewAllKeyButton"
	_view_all_button.custom_minimum_size = Vector2(150, 40)
	_view_all_button.pressed.connect(_start_view_all_capture)
	line.add_child(_view_all_button)
	_view_all_restore = Button.new()
	_view_all_restore.name = "ViewAllRestoreButton"
	_view_all_restore.text = VIEW_ALL_RESTORE
	_view_all_restore.custom_minimum_size = Vector2(120, 40)
	_view_all_restore.pressed.connect(set_view_all_key.bind(ViewAllBinding.DEFAULT_KEY))
	line.add_child(_view_all_restore)
	_view_all_note = Label.new()
	_view_all_note.name = "ViewAllNote"
	_view_all_note.add_theme_font_size_override("font_size", 14)
	_view_all_note.add_theme_color_override("font_color", Color(1.0, 0.8, 0.25))
	_view_all_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_view_all_note.custom_minimum_size.x = 300
	_view_all_note.visible = false
	box.add_child(_view_all_note)
	_rows.add_child(box)


func _refresh_view_all_row() -> void:
	if _view_all_button == null:
		return
	var key: int = SaveManager.get_ui_prefs().view_all_key
	_view_all_button.text = VIEW_ALL_PROMPT if _view_all_capturing else ViewAllBinding.key_text(key)
	_view_all_restore.disabled = key == ViewAllBinding.DEFAULT_KEY


func _start_view_all_capture() -> void:
	_view_all_capturing = true
	_view_all_note.visible = false
	_refresh_view_all_row()


func _stop_view_all_capture() -> void:
	_view_all_capturing = false
	_refresh_view_all_row()


## Prueba la tecla y, si se puede, la guarda. Devuelve true si la cambió; si no, deja el aviso (RF-614).
func set_view_all_key(keycode: int) -> bool:
	_view_all_capturing = false
	var owner_name: String = "" if keycode == ViewAllBinding.DEFAULT_KEY else ViewAllBinding.conflict(keycode)
	if owner_name != "":
		_view_all_note.text = "Esa tecla ya la usa %s. Elegí otra." % owner_name
		_view_all_note.visible = true
		_refresh_view_all_row()
		return false
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	prefs.view_all_key = keycode
	SaveManager.set_ui_prefs(prefs)
	_view_all_note.visible = false
	_refresh_view_all_row()
	return true


## Mientras espera la tecla, se queda con la próxima que se aprieta (Esc cancela sin cerrar Opciones).
func _input(event: InputEvent) -> void:
	if not _view_all_capturing or not visible:
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	get_viewport().set_input_as_handled()
	if key.physical_keycode == KEY_ESCAPE:
		_stop_view_all_capture()
		return
	if key.physical_keycode in ViewAllBinding.RESERVED_KEYS:
		return  # un modificador solo no es una tecla: sigue esperando
	set_view_all_key(key.physical_keycode as int)


## RF-607: abre las novedades de la versión instalada (o la más nueva del archivo) sin tocar el guardado. Con el
## archivo roto o sin versiones queda deshabilitado y dice «No hay novedades».
func _build_news_button() -> void:
	news = NewsScreen.new()
	news.layer = 22  # sobre la pausa (20), por si Opciones se abrió desde ahí
	add_child(news)
	news.closed.connect(_news_button_focus)
	_news_button = Button.new()
	_news_button.name = "NewsButton"
	_news_button.custom_minimum_size.y = 44
	_news_button.add_theme_font_size_override("font_size", 20)
	_rows.add_child(_news_button)
	_news_button.pressed.connect(_on_news_pressed)
	_refresh_news_button()


func _refresh_news_button() -> void:
	_news_data = NewsData.load_file(news_path)
	var usable: bool = _news_data.is_valid() and not _news_data.entry_for_options(String(news_version_source.call())).is_empty()
	if not _news_data.is_valid():
		push_warning("Las novedades no se pueden abrir: %s" % "; ".join(_news_data.errors))
	_news_button.disabled = not usable
	_news_button.text = NEWS_BUTTON_TEXT if usable else String(_news_data.labels.get("sin_novedades", NEWS_EMPTY_TEXT))


func _on_news_pressed() -> void:
	var entry: Dictionary = _news_data.entry_for_options(String(news_version_source.call()))
	if not entry.is_empty():
		news.open(entry, _news_data.labels)


func _news_button_focus() -> void:
	_news_button.grab_focus()


func news_button() -> Button:
	return _news_button


func _build_ui_mode_selector() -> void:
	# RF-684: «Interfaz» va en «Avanzado», al principio.
	var label := Label.new()
	label.name = "UiModeLabel"
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
