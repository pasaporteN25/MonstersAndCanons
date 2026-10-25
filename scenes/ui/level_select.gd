# Selección de nivel (RF-111, RF-112, RF-116, RF-221, RF-389): solapas para la Campaña, los modos
# oficiales, los Mapas de la comunidad y los modos propios. En la campaña y en los modos oficiales,
# los bloqueados no se pueden elegir y los completados muestran sus estrellas (RF-93) y su mejor
# resultado. Los mapas de la comunidad (los .json de user://maps/) y los de los modos propios están
# todos abiertos, y los que tienen errores se ven deshabilitados con el motivo (RF-222, RF-388).
extends Control

const PAGE_CAMPAIGN: StringName = &"campaign"
const PAGE_COMMUNITY: StringName = &"community"

# Las tarjetas se acomodan en filas (RF-116): 5 columnas de 200 px entran en el área de 1090 px.
# Las páginas generales conservan el tamaño y scroll previos; la campaña desktop usa 3 filas compactas.
const CARD_SIZE := Vector2(200, 214)
const CAMPAIGN_CARD_SIZE := Vector2(200, 146)
const CARD_SPACING: float = 16.0
const CARDS_PER_ROW: int = 5
const VISIBLE_ROWS: int = 2
const CAMPAIGN_VISIBLE_ROWS: int = 3
const CAMPAIGN_CARD_SPACING: float = 10.0
const MOBILE_MAP_ROW_SEPARATION: int = 6
## T426: el fondo temático de la tarjeta desktop es el suelo del tema del nivel (MapThemes), muy tenue,
## con un velo oscuro del color de borde del tema encima para que texto, estrellas e iconos se lean.
const CAMPAIGN_BACKDROP_ALPHA: float = 0.30
const CAMPAIGN_SCRIM_ALPHA: float = 0.62
const CAMPAIGN_SCRIM_DARKEN: float = 0.55
const CARD_STAR_SIZE: float = 26.0
const CAMPAIGN_STAR_SIZE: float = 18.0
const TOWER_ICON_SIZE: float = 22.0
const CAMPAIGN_TOWER_ICON_SIZE: float = 20.0
const TOWER_ICON_COLUMNS: int = 8
const TOWER_BADGE_SIZE: float = 23.0
const CARD_CONTENT_LEFT: float = 6.0
const CARD_CONTENT_WIDTH: float = CARD_SIZE.x - CARD_CONTENT_LEFT * 2.0
const NEW_COLOR := Color(1.0, 0.6, 0.15)
## RF-465: el lugar bajo el nombre, en letra chica y de color suave.
const PLACE_COLOR := Color(0.72, 0.76, 0.84)
const PLACE_FONT_SIZE: int = 14
const CARD_FONT_SIZE: int = 20
const CAMPAIGN_TITLE_FONT_SIZE: int = 16
const ERROR_COLOR := Color(1.0, 0.55, 0.55)
## RF-319: tope del oro que se puede escribir a mano en la franja de pruebas.
const DEV_MAX_GOLD: int = 999999

## RF-226: dónde se buscan los mapas de la comunidad. Los tests usan otra carpeta (hay que
## cambiarlo ANTES de agregar la pantalla al árbol, que es cuando busca).
var community_dir: String = CommunityMaps.DIR
## RF-388: dónde se buscan los modos oficiales y los propios (los tests usan otras carpetas; igual que
## `community_dir`, se cambian ANTES de agregar la pantalla al árbol).
var modes_official_dir: String = ModePacks.OFFICIAL_DIR
var modes_user_dir: String = ModePacks.USER_DIR
## Cómo se abre la carpeta en el explorador. Los tests lo reemplazan (si no, abrirían una ventana).
var folder_opener: Callable = OS.shell_open
## M72: cómo se abre un nivel desde el mapa planetario. Los tests lo reemplazan (si no, cambiaría de escena).
var level_opener: Callable = GameFlow.start_level

var _all_towers: Array[TowerData] = []
var _page: StringName = PAGE_CAMPAIGN
var _entries: Array[Dictionary] = []
## RF-389: los modos (ModePacks.all) y la solapa de cada uno, por página (&"mode:<id>").
var _modes: Array[Dictionary] = []
var _mode_tabs: Dictionary = {}
## RF-319: la franja "Pruebas" (solo en el modo de pruebas). null en el juego normal.
var dev_strip: HBoxContainer
var _dev_wave: SpinBox
var _dev_auto: CheckBox
var _dev_gold: SpinBox

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = $Center/Rows
@onready var _cards: HFlowContainer = %Cards
@onready var _back_button: Button = %BackButton
@onready var _total_stars: Label = %TotalStars
@onready var _tab_scroll: ScrollContainer = %TabScroll
@onready var _tab_row: HBoxContainer = %TabRow
@onready var _campaign_tab: Button = %CampaignTab
@onready var _community_tab: Button = %CommunityTab
@onready var _folder_button: Button = %FolderButton
@onready var _style_switch: HBoxContainer = %StyleSwitch
@onready var _style_cards_button: Button = %StyleCards
@onready var _style_map_button: Button = %StyleMap
## M72: el mapa planetario cuando la campaña está en ese estilo; null con tarjetas.
var map_view: CampaignMapView


func _ready() -> void:
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	_folder_button.pressed.connect(open_folder)
	_campaign_tab.pressed.connect(show_page.bind(PAGE_CAMPAIGN))
	_community_tab.pressed.connect(show_page.bind(PAGE_COMMUNITY))
	_entries = CommunityMaps.scan(community_dir)  # RF-226: se vuelve a buscar cada vez que se abre
	_community_tab.text = "Mapas de la comunidad (%d)" % _entries.size()
	_modes = ModePacks.all(modes_official_dir, modes_user_dir)  # RF-389: también cada vez
	_add_mode_tabs()
	_style_cards_button.pressed.connect(set_style.bind(CampaignMap.STYLE_CARDS))
	_style_map_button.pressed.connect(set_style.bind(CampaignMap.STYLE_MAP))
	show_page(GameFlow.select_page)  # RF-225: la solapa en la que se estaba
	_focus_remembered_map()
	if map_view != null:
		map_view.focus_selected()  # RF-648: el mapa se puede recorrer con teclado desde que se abre
	if DevMode.enabled:
		_add_dev_strip()
	Audio.add_click_sounds(self)
	MenuTouch.attach(self)  # RF-550, RF-551: botones de 56 px y desplazamiento táctil en el celular


## Esc (o "atrás" en Android, RF-142) vuelve al menú principal.
## RF-694: AvPág / RePág pasan a la solapa siguiente / anterior (la fila de solapas se desplaza sola).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		GameFlow.go_to_main_menu()
	elif event.is_action_pressed("ui_page_down"):
		get_viewport().set_input_as_handled()
		step_page(1)
	elif event.is_action_pressed("ui_page_up"):
		get_viewport().set_input_as_handled()
		step_page(-1)


## Cambia de solapa y vuelve a armar las tarjetas (RF-221).
func show_page(page: StringName) -> void:
	var mode: Dictionary = _mode_for(page)
	if page != PAGE_CAMPAIGN and page != PAGE_COMMUNITY and mode.is_empty():
		page = PAGE_CAMPAIGN  # un modo que ya no está (se borró la carpeta): se vuelve a la campaña
	_page = page
	var is_campaign: bool = page == PAGE_CAMPAIGN and not UiMode.is_mobile()  # tarjetas compactas de PC
	var is_campaign_page: bool = page == PAGE_CAMPAIGN  # el mapa y su conmutador valen en PC y en celular (RF-687)
	_cards.add_theme_constant_override("v_separation", CAMPAIGN_CARD_SPACING if is_campaign else CARD_SPACING)
	if page != GameFlow.select_page:
		GameFlow.select_map_index = -1  # otra solapa: la selección recordada ya no vale
	GameFlow.select_page = page
	_campaign_tab.set_pressed_no_signal(page == PAGE_CAMPAIGN)
	_community_tab.set_pressed_no_signal(page == PAGE_COMMUNITY)
	for tab_page: StringName in _mode_tabs:
		(_mode_tabs[tab_page] as Button).set_pressed_no_signal(tab_page == page)
	for card: Node in _cards.get_children():
		_cards.remove_child(card)
		card.queue_free()
	map_view = null
	# RF-645, RF-687: el cambio de estilo es solo de la campaña, en PC y en celular.
	var show_map: bool = is_campaign_page and SaveManager.selector_style() == CampaignMap.STYLE_MAP
	_rows.add_theme_constant_override("separation", MOBILE_MAP_ROW_SEPARATION \
		if show_map and UiMode.is_mobile() else 8)
	_style_switch.visible = is_campaign_page
	_style_cards_button.set_pressed_no_signal(not show_map)
	_style_map_button.set_pressed_no_signal(show_map)
	var count: int
	if page == PAGE_CAMPAIGN:
		if show_map:
			map_view = _make_map_view()
			_cards.add_child(map_view)
		else:
			for i: int in GameFlow.level_count():
				_cards.add_child(_make_card(i))
		count = GameFlow.level_count()
		_total_stars.text = "Estrellas: %d de %d" % [GameFlow.total_stars(), GameFlow.max_stars()]
	elif page == PAGE_COMMUNITY:
		for entry: Dictionary in _entries:
			_cards.add_child(_make_community_card(entry))
		count = _entries.size()
		if _entries.is_empty():
			_cards.add_child(_empty_message())
		_total_stars.text = "%d %s" % [_entries.size(), "mapa" if _entries.size() == 1 else "mapas"]
	else:
		count = _show_mode(mode)
	_folder_button.visible = (page == PAGE_COMMUNITY or (not mode.is_empty() and not mode["official"])) \
		and can_add_maps()
	_folder_button.text = "Abrir carpeta del modo" if not mode.is_empty() else "Abrir carpeta de mapas"
	# Alto del área: las filas que hay, hasta VISIBLE_ROWS (con una sola fila no sobra espacio).
	var rows: int = maxi(ceili(float(count) / CARDS_PER_ROW), 1)
	var visible_rows: int = CAMPAIGN_VISIBLE_ROWS if is_campaign else VISIBLE_ROWS
	var card_height: float = CAMPAIGN_CARD_SIZE.y if is_campaign else CARD_SIZE.y
	var row_spacing: float = CAMPAIGN_CARD_SPACING if is_campaign else CARD_SPACING
	var shown: int = mini(rows, visible_rows)
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED \
		if is_campaign and rows <= CAMPAIGN_VISIBLE_ROWS else ScrollContainer.SCROLL_MODE_AUTO
	_scroll.custom_minimum_size.y = shown * card_height + (shown - 1) * row_spacing
	if show_map:
		_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_scroll.custom_minimum_size.y = CampaignMapView.VIEW_SIZE.y
	_reveal_active_tab.call_deferred()  # las medidas de las solapas se conocen después de este cuadro


func current_page() -> StringName:
	return _page


## RF-389, RF-694: el orden de las solapas: Campaña, modos oficiales, Comunidad y modos propios.
func page_order() -> Array[StringName]:
	var order: Array[StringName] = [PAGE_CAMPAIGN]
	for mode: Dictionary in _modes:
		if mode["official"]:
			order.append(ModePacks.page_of(mode))
	order.append(PAGE_COMMUNITY)
	for mode: Dictionary in _modes:
		if not mode["official"]:
			order.append(ModePacks.page_of(mode))
	return order


## RF-694: pasa a la solapa `delta` lugares más allá (da la vuelta) y la deja a la vista.
func step_page(delta: int) -> void:
	var order: Array[StringName] = page_order()
	show_page(order[posmod(order.find(_page) + delta, order.size())])


## La solapa de `page` (también Campaña y Comunidad), para poder desplazarla y probarla.
func tab_button(page: StringName) -> Button:
	if page == PAGE_CAMPAIGN:
		return _campaign_tab
	if page == PAGE_COMMUNITY:
		return _community_tab
	return mode_tab(page)


## Desplaza la fila de solapas hasta que la activa se vea entera (con cinco modos propios no entran todas).
func _reveal_active_tab() -> void:
	var tab: Button = tab_button(_page)
	if tab != null and is_inside_tree():
		_tab_scroll.ensure_control_visible(tab)


## RF-694: al volver de una partida de un modo, la tarjeta de ese mapa recupera el foco.
func _focus_remembered_map() -> void:
	var index: int = GameFlow.select_map_index
	if index < 0 or _page == PAGE_CAMPAIGN or _page == PAGE_COMMUNITY:
		return
	GameFlow.select_map_index = -1  # se usa una sola vez: el foco no vuelve a moverse en esta pantalla
	if index < _cards.get_child_count() and _cards.get_child(index) is Button:
		var card: Button = _cards.get_child(index) as Button
		if not card.disabled:
			card.grab_focus()


## M72, RF-645: cambia el estilo de la campaña y lo recuerda en `settings`. No toca el progreso.
func set_style(style: int) -> void:
	var wanted: int = CampaignMap.style_from(style)
	_style_cards_button.set_pressed_no_signal(wanted == CampaignMap.STYLE_CARDS)
	_style_map_button.set_pressed_no_signal(wanted == CampaignMap.STYLE_MAP)
	if wanted == SaveManager.selector_style():
		return
	SaveManager.set_setting("selector_style", wanted)
	SaveManager.save()
	show_page(_page)


## M72, RF-647: los estados salen del desbloqueo y de las estrellas actuales de cada nivel.
func map_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for i: int in GameFlow.level_count():
		var level: LevelData = GameFlow.level(i)
		var stars: int = GameFlow.level_stars(i)
		entries.append({"name": level.display_name, "place": level.place_text, "stars": stars,
			"state": CampaignMap.state_of(GameFlow.is_level_unlocked(i), SaveManager.is_completed(level.id), stars)})
	return entries


func _make_map_view() -> CampaignMapView:
	var view := CampaignMapView.new()
	view.name = "CampaignMapView"
	view.setup(map_entries())
	view.level_requested.connect(_request_campaign_level)
	return view


## Vuelve a comprobar el desbloqueo al confirmar: el estado visible del mapa puede haber quedado viejo (RF-688).
func _request_campaign_level(index: int) -> void:
	if index < 0 or index >= GameFlow.level_count() or not GameFlow.is_level_unlocked(index):
		return
	level_opener.call(index)


# --- Modos (RF-389) ---

## Una solapa por modo: los oficiales después de "Campaña" y los propios después de "Comunidad".
func _add_mode_tabs() -> void:
	var after_campaign: int = _campaign_tab.get_index()
	var after_community: int = _community_tab.get_index()
	for mode: Dictionary in _modes:
		var tab := Button.new()
		tab.toggle_mode = true
		tab.text = mode["name"] if (mode["errors"] as PackedStringArray).is_empty() else "%s (con errores)" % mode["id"]
		tab.tooltip_text = mode["description"]
		tab.custom_minimum_size = Vector2(130, 42)
		tab.add_theme_font_size_override("font_size", _campaign_tab.get_theme_font_size("font_size"))
		var page: StringName = ModePacks.page_of(mode)
		tab.pressed.connect(show_page.bind(page))
		_tab_row.add_child(tab)
		if mode["official"]:
			after_campaign += 1
			after_community += 1
			_tab_row.move_child(tab, after_campaign)
		else:
			after_community += 1
			_tab_row.move_child(tab, after_community)
		_mode_tabs[page] = tab


func mode_tab(page: StringName) -> Button:
	return _mode_tabs.get(page)


func _mode_for(page: StringName) -> Dictionary:
	for mode: Dictionary in _modes:
		if ModePacks.page_of(mode) == page:
			return mode
	return {}


## Arma las tarjetas de un modo y devuelve cuántas son.
func _show_mode(mode: Dictionary) -> int:
	var errors: PackedStringArray = mode["errors"]
	var maps: Array = mode["maps"]
	if not errors.is_empty():
		_cards.add_child(_error_card(String(mode["id"]), errors))
		_total_stars.text = "Modo con errores"
		return 1
	if maps.is_empty():
		_cards.add_child(_message_label("Este modo todavía no tiene mapas.\n\nEn el editor de mapas, \"Guardar en un modo\" los agrega."))
		_total_stars.text = "0 mapas"
		return 1
	var stars: int = 0
	var playable: int = 0
	for i: int in maps.size():
		_cards.add_child(_make_mode_card(mode, i))
		var level: LevelData = ModePacks.map_level(mode, i)
		if level != null:
			playable += 1
			stars += GameFlow.map_stars(level)
	_total_stars.text = "Estrellas: %d de %d" % [stars, playable * StarsDisplay.MAX_STARS]
	return maps.size()


## Una tarjeta de un mapa de un modo (RF-389). Con errores: deshabilitada y con el motivo (RF-388).
func _make_mode_card(mode: Dictionary, index: int) -> Button:
	var entry: Dictionary = mode["maps"][index]
	var level: LevelData = entry["level"]
	if level == null:
		return _error_card(entry["file"], entry["errors"])
	var unlocked: bool = GameFlow.is_mode_level_unlocked(mode, index)
	var card := _new_card()
	card.text = "Mapa %d\n%s\n%d oleadas\n%s\n\n" % [index + 1, level.display_name, level.waves.size(),
		mode_status_text(mode, index)]
	card.disabled = not unlocked
	card.pressed.connect(GameFlow.start_mode_level.bind(mode, index))
	_add_stars(card, GameFlow.map_stars(level), unlocked)
	return card


## Texto de estado de la tarjeta de un mapa de un modo (público para poder testearlo).
func mode_status_text(mode: Dictionary, index: int) -> String:
	if not GameFlow.is_mode_level_unlocked(mode, index):
		return "Bloqueado"
	var id: StringName = ModePacks.map_level(mode, index).id
	if SaveManager.is_completed(id):
		return "Mejor: %d vidas" % SaveManager.best_lives(id)
	return "¡Jugar!"


func _error_card(title: String, errors: PackedStringArray) -> Button:
	var card := _new_card()
	card.text = "%s\nCon errores\n\n\n" % title
	card.disabled = true
	card.tooltip_text = errors[0] if not errors.is_empty() else ""
	card.add_theme_color_override("font_disabled_color", ERROR_COLOR)
	return card


## RF-319: oleada inicial y oro inicial, para probar las oleadas finales sin jugar las anteriores.
## Los valores quedan en `DevMode` en cuanto se cambian; al elegir un nivel, `Game` los usa.
func _add_dev_strip() -> void:
	DevMode.reset_start()  # cada vez que se abre la selección se vuelve a elegir
	dev_strip = HBoxContainer.new()
	dev_strip.name = "DevStrip"
	dev_strip.custom_minimum_size = Vector2(1090, 36)
	dev_strip.add_theme_constant_override("separation", 10)
	var title: Label = _dev_label("Pruebas")
	title.add_theme_color_override("font_color", Color(1, 0.55, 0.3))
	dev_strip.add_child(title)
	dev_strip.add_child(_dev_label("Oleada inicial"))
	_dev_wave = _dev_spin(1, _max_waves(), 1)
	_dev_wave.value_changed.connect(_on_dev_wave_changed)
	dev_strip.add_child(_dev_wave)
	dev_strip.add_child(_dev_label("Oro inicial"))
	_dev_auto = CheckBox.new()
	_dev_auto.text = "Automático"
	_dev_auto.button_pressed = true
	_dev_auto.focus_mode = Control.FOCUS_NONE
	_dev_auto.toggled.connect(_on_dev_gold_changed.unbind(1))
	dev_strip.add_child(_dev_auto)
	_dev_gold = _dev_spin(0, DEV_MAX_GOLD, 0)
	_dev_gold.editable = false
	_dev_gold.value_changed.connect(_on_dev_gold_changed.unbind(1))
	dev_strip.add_child(_dev_gold)
	var hint: Label = _dev_label("Si pasa del total del nivel, se usa la última oleada.")
	hint.add_theme_font_size_override("font_size", 15)
	hint.modulate = Color(1, 1, 1, 0.7)
	dev_strip.add_child(hint)
	_scroll.get_parent().add_child(dev_strip)
	_scroll.get_parent().move_child(dev_strip, _scroll.get_index())
	Audio.add_click_sounds(dev_strip)


func _dev_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _dev_spin(min_value: int, max_value: int, start: int) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.value = start
	spin.custom_minimum_size = Vector2(110, 0)
	return spin


## El mayor número de oleadas entre los niveles de la campaña y los mapas de la comunidad.
func _max_waves() -> int:
	var most: int = 1
	for i: int in GameFlow.level_count():
		most = maxi(most, GameFlow.level(i).waves.size())
	for entry: Dictionary in _entries:
		var level: LevelData = entry["level"]
		if level != null:
			most = maxi(most, level.waves.size())
	for mode: Dictionary in _modes:
		for i: int in (mode["maps"] as Array).size():
			var level: LevelData = ModePacks.map_level(mode, i)
			if level != null:
				most = maxi(most, level.waves.size())
	return most


func _on_dev_wave_changed(value: float) -> void:
	DevMode.start_wave = int(value)


func _on_dev_gold_changed() -> void:
	_dev_gold.editable = not _dev_auto.button_pressed
	DevMode.start_gold = -1 if _dev_auto.button_pressed else int(_dev_gold.value)


## En el celular la carpeta de mapas no se ve (D-034): no se ofrece agregar mapas.
func can_add_maps() -> bool:
	return not OS.has_feature("android")


## RF-221: abre la carpeta de mapas (y la crea si todavía no existe). En la solapa de un modo propio,
## la carpeta de ese modo (RF-389).
func open_folder() -> void:
	var mode: Dictionary = _mode_for(_page)
	var folder: String = community_dir if mode.is_empty() else String(mode["dir"])
	DirAccess.make_dir_recursive_absolute(folder)
	folder_opener.call(ProjectSettings.globalize_path(folder))


func _make_card(index: int) -> Button:
	var level: LevelData = GameFlow.level(index)
	var compact: bool = not UiMode.is_mobile()
	var card := _new_card(CAMPAIGN_CARD_SIZE if compact else CARD_SIZE)
	card.text = ""
	if level.extra_towers.has("mechanical_standard"):
		card.tooltip_text = "Estandarte mecánico: requiere cinco avances de niveles1–5 (%d/5)." % SaveManager.collected_sources(&"technology").size()
	elif CollectibleRun.eligible(&"technology", level.id):
		card.tooltip_text = "Avance de este nivel: %s. Una pieza distinta por nivel1–5." % ("conseguido" if SaveManager.collected_sources(&"technology").has(String(level.id)) else "pendiente")
	var unlocked: bool = GameFlow.is_level_unlocked(index)
	card.disabled = not unlocked
	if compact:
		_add_theme_background(card, level.theme)
	_add_campaign_card_text(card, index, level, unlocked, compact)
	_add_tower_icons(card, index, level, unlocked, compact)
	card.pressed.connect(GameFlow.start_level.bind(index))
	_add_campaign_stars(card, GameFlow.level_stars(index), unlocked, index, compact)
	return card


## T426: suelo del tema del nivel (uno desconocido usa la pradera) y velo oscuro, detrás de todo lo demás.
## Con `self_modulate` el alpha no se pierde cuando una tarjeta bloqueada atenúa a sus hijos.
func _add_theme_background(card: Button, theme_id: StringName) -> void:
	card.clip_contents = true
	var backdrop := TextureRect.new()
	backdrop.name = "ThemeBackdrop"
	backdrop.texture = MapThemes.ground_texture(theme_id)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_TILE
	backdrop.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	backdrop.self_modulate = Color(1, 1, 1, CAMPAIGN_BACKDROP_ALPHA)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.position = Vector2.ZERO
	backdrop.size = CAMPAIGN_CARD_SIZE
	card.add_child(backdrop)
	var edge: Color = MapThemes.palette(theme_id)["edge"]
	var scrim := ColorRect.new()
	scrim.name = "ThemeScrim"
	scrim.color = Color(edge.darkened(CAMPAIGN_SCRIM_DARKEN), CAMPAIGN_SCRIM_ALPHA)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.position = Vector2.ZERO
	scrim.size = CAMPAIGN_CARD_SIZE
	card.add_child(scrim)


## RF-397 y RF-465: cada pieza tiene su propio rectángulo y no depende de renglones vacíos
## dentro del texto del botón, que Godot puede descartar al dibujarlo.
func _add_campaign_card_text(card: Button, index: int, level: LevelData, unlocked: bool, compact: bool = false) -> void:
	var card_size: Vector2 = CAMPAIGN_CARD_SIZE if compact else CARD_SIZE
	var number_text: String = "Nivel %d" % (index + 1) if compact else "Nivel %d · %d oleadas" % [index + 1, level.waves.size()]
	_card_label(card, "LevelNumber", number_text, 13 if compact else 14, Rect2(8, 3, card_size.x - 16, 19 if compact else 23))
	var title_y: float = 28.0
	var title_height: float = 24.0 if compact else 36.0
	var title: Label = _card_label(card, "LevelName", level.display_name, 16 if compact else CAMPAIGN_TITLE_FONT_SIZE, Rect2(8, title_y, card_size.x - 16, title_height))
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if unlocked and level.place_text != "":
		var place_font_size: int = 12 if compact else PLACE_FONT_SIZE
		var place_y: float = 54.0 if compact else 64.0
		var place_height: float = 18.0 if compact else 23.0
		var place_text: String = _fit_line(level.place_text, get_theme_font("font"), place_font_size, card_size.x - 40.0)
		var place: Label = _card_label(card, "Place", place_text, place_font_size, Rect2(8, place_y, card_size.x - 16, place_height))
		place.add_theme_color_override("font_color", PLACE_COLOR)
		place.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		place.size = Vector2(card_size.x - 16.0, place_height)
		card.tooltip_text = level.place_text + ("\n" + card.tooltip_text if card.tooltip_text != "" else "")
	if not unlocked:
		for child: Node in card.get_children():
			if child is Control:
				(child as Control).modulate = Color(0.58, 0.58, 0.58, 1.0)


func _card_label(card: Button, label_name: String, text: String, font_size: int, rect: Rect2) -> Label:
	var label := Label.new()
	label.name = label_name
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = rect.position
	label.size = rect.size
	card.add_child(label)
	return label


func _fit_line(text: String, font: Font, font_size: int, width: float) -> String:
	var result: String = text
	while not result.is_empty() and font.get_string_size(result, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
		result = result.left(result.length() - 1)
	return result + "…" if result != text else result


## RF-397: íconos chicos de las torres que ofrece el nivel (los de la barra) y, en las que debutan ahí,
## una marca naranja y "Nueva" al pasar el mouse. Se calcula en el momento, desde los datos.
func _add_tower_icons(card: Button, index: int, level: LevelData, unlocked: bool, compact: bool = false) -> void:
	if _all_towers.is_empty():
		_all_towers = TowerOffer.canonical_towers()
	var levels: Array[LevelData] = []
	for i: int in GameFlow.level_count():
		levels.append(GameFlow.level(i))
	var fresh: PackedStringArray = TowerOffer.new_tower_ids(levels, index, _all_towers)
	var offered: Array[TowerData] = TowerOffer.offered(level, _all_towers)
	var icon_size: float = CAMPAIGN_TOWER_ICON_SIZE if compact else TOWER_ICON_SIZE
	var columns: int = TOWER_ICON_COLUMNS
	var rows: int = maxi(ceili(float(offered.size()) / columns), 1)
	var row_parent: Control = card
	var row_y: float = 66.0
	var row_height: float = float(rows) * icon_size
	if not compact:
		var plate := Panel.new()
		plate.name = "TowerPlate"
		plate.position = Vector2(CARD_CONTENT_LEFT, 88.0)
		plate.size = Vector2(CARD_CONTENT_WIDTH, 64.0 if rows > 1 else 41.0)
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var plate_style := StyleBoxFlat.new()
		plate_style.bg_color = Color(0.12, 0.15, 0.19, 0.84)
		plate_style.border_color = Color(0.37, 0.29, 0.19, 0.9)
		plate_style.set_border_width_all(1)
		plate_style.set_corner_radius_all(7)
		plate.add_theme_stylebox_override("panel", plate_style)
		card.add_child(plate)
		var title := Label.new()
		title.name = "TowerTitle"
		title.text = "Torres  ·  %d" % offered.size()
		title.add_theme_font_size_override("font_size", 11)
		title.add_theme_color_override("font_color", Color(0.76, 0.59, 0.34))
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.position = Vector2(0, 0)
		title.size = Vector2(CARD_CONTENT_WIDTH, 14)
		plate.add_child(title)
		row_parent = plate
		row_y = 15.0
		row_height = float(rows) * TOWER_BADGE_SIZE
	var row := HFlowContainer.new()
	row.name = "TowerIcons"
	row.add_theme_constant_override("h_separation", 1 if compact else 0)
	row.add_theme_constant_override("v_separation", 0)
	row.alignment = FlowContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var compact_row_y: float = 80.0 + float(2 - rows) * 9.0
	row.position = Vector2(CARD_CONTENT_LEFT if compact else 0.0, compact_row_y if compact else row_y)
	row.size = Vector2(CARD_CONTENT_WIDTH, row_height)
	row_parent.add_child(row)
	for tower: TowerData in offered:
		var icon := TextureRect.new()
		icon.name = String(tower.id)
		icon.texture = Tower.make_icon(tower)
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.modulate = Color.WHITE if unlocked else Color(0.58, 0.58, 0.58, 1.0)
		icon.size = Vector2(icon_size, icon_size)
		var is_new: bool = fresh.has(String(tower.id))
		card.tooltip_text += "%s%s%s" % ["\n" if card.tooltip_text != "" else "", tower.display_name, " · Nueva" if is_new else ""]
		if is_new:
			var mark := ColorRect.new()
			mark.name = "NewMark"
			mark.color = NEW_COLOR
			mark.size = Vector2(6, 6)
			mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.add_child(mark)
		var new_mark: ColorRect = icon.get_node_or_null("NewMark") as ColorRect
		if new_mark != null:
			new_mark.position = Vector2(icon.size.x - new_mark.size.x - 1.0, 1.0)
		if compact:
			row.add_child(icon)
		else:
			var badge := Panel.new()
			badge.name = "Badge_%s" % tower.id
			badge.custom_minimum_size = Vector2(TOWER_BADGE_SIZE, TOWER_BADGE_SIZE)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var badge_style := StyleBoxFlat.new()
			badge_style.bg_color = Color(0.20, 0.21, 0.22, 0.98)
			badge_style.border_color = Color(0.63, 0.43, 0.22, 1.0)
			badge_style.set_border_width_all(1)
			badge_style.set_corner_radius_all(12)
			badge.add_theme_stylebox_override("panel", badge_style)
			icon.position = Vector2((TOWER_BADGE_SIZE - icon_size) / 2.0, (TOWER_BADGE_SIZE - icon_size) / 2.0)
			badge.add_child(icon)
			row.add_child(badge)


## Una tarjeta de un mapa de la comunidad (RF-221). Con errores: deshabilitada y con el motivo (RF-222).
func _make_community_card(entry: Dictionary) -> Button:
	var level: LevelData = entry["level"]
	if level == null:
		return _error_card(entry["file"], entry["errors"])
	var card := _new_card()
	card.text = "%s\n%d oleadas\n%s\n\n" % [level.display_name, level.waves.size(), community_status_text(entry)]
	card.pressed.connect(GameFlow.start_community.bind(level))
	_add_stars(card, GameFlow.community_stars(level), true)
	return card


func _new_card(size: Vector2 = CARD_SIZE) -> Button:
	var card := Button.new()
	card.custom_minimum_size = size
	card.add_theme_font_size_override("font_size", CARD_FONT_SIZE)
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # un nombre largo baja de renglón
	return card


## RF-93: estrellas abajo de la tarjeta (huecas si todavía no se ganó).
func _add_stars(card: Button, count: int, shown: bool) -> void:
	var stars := StarsDisplay.new()
	stars.star_size = CARD_STAR_SIZE
	stars.count = count
	stars.visible = shown
	# Posición a mano: la tarjeta todavía no tiene su tamaño final al crearla.
	stars.size = stars.custom_minimum_size
	stars.position = Vector2((CARD_SIZE.x - stars.size.x) / 2.0, CARD_SIZE.y - CARD_STAR_SIZE - 18.0)
	card.add_child(stars)


func _add_campaign_stars(card: Button, count: int, shown: bool, index: int, compact: bool = false) -> void:
	var stars := StarsDisplay.new()
	stars.name = "Stars"
	stars.star_size = CAMPAIGN_STAR_SIZE if compact else CARD_STAR_SIZE
	stars.count = count
	stars.visible = shown
	stars.size = stars.custom_minimum_size
	stars.position = Vector2(CAMPAIGN_CARD_SIZE.x - stars.size.x - 8.0, 122.0) if compact else Vector2((CARD_SIZE.x - stars.size.x) / 2.0, 158.0)
	card.add_child(stars)
	var status_rect: Rect2 = Rect2(8, 122, 106, 20) if compact else Rect2(8, 186, CARD_SIZE.x - 16, 23)
	var status: Label = _card_label(card, "Status", status_text(index), 12 if compact else 16, status_rect)
	if not shown:
		status.modulate = Color(0.58, 0.58, 0.58, 1.0)


## Lo que se ve cuando la solapa de la comunidad está vacía: dónde poner los mapas (RF-221).
func _empty_message() -> Label:
	if can_add_maps():
		return _message_label("Todavía no hay mapas de la comunidad.\n\nCopiá archivos .json a esta carpeta y aparecen acá:\n%s\n\nLos mapas que hacés con el editor de mapas también aparecen solos." \
			% CommunityMaps.folder_path(community_dir))
	return _message_label("Todavía no hay mapas de la comunidad.\n\nEn el celular no se pueden agregar mapas: usá la versión de computadora.")


func _message_label(text: String) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(900, 180)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.text = text
	return label


## Texto de estado de la tarjeta de la campaña (público para poder testearlo).
func status_text(index: int) -> String:
	var id: StringName = GameFlow.level(index).id
	if not GameFlow.is_level_unlocked(index):
		return "Bloqueado"
	if SaveManager.is_completed(id):
		return "Mejor: %d vidas" % SaveManager.best_lives(id)
	return "¡Jugar!"


## Texto de estado de la tarjeta de un mapa de la comunidad: no hay desbloqueo (RF-221).
func community_status_text(entry: Dictionary) -> String:
	var id: StringName = entry["id"]
	if SaveManager.is_completed(id):
		return "Mejor: %d vidas" % SaveManager.best_lives(id)
	return "¡Jugar!"
