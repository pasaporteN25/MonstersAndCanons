# Selección de nivel (RF-111, RF-112, RF-116, RF-221, RF-389): solapas para la Campaña, los modos
# oficiales, los Mapas de la comunidad y los modos propios. En la campaña y en los modos oficiales,
# los bloqueados no se pueden elegir y los completados muestran sus estrellas (RF-93) y su mejor
# resultado. Los mapas de la comunidad (los .json de user://maps/) y los de los modos propios están
# todos abiertos, y los que tienen errores se ven deshabilitados con el motivo (RF-222, RF-388).
extends Control

const PAGE_CAMPAIGN: StringName = &"campaign"
const PAGE_COMMUNITY: StringName = &"community"

# Las tarjetas se acomodan en filas (RF-116): 5 de 200 px + 4 espacios de 16 px = 1064 px, que
# entran en el área de 1090 px. Se ven 2 filas; si hay más niveles, el área se desplaza.
const CARD_SIZE := Vector2(200, 214)
const CARD_SPACING: float = 16.0
const CARDS_PER_ROW: int = 5
const VISIBLE_ROWS: int = 2
const CARD_STAR_SIZE: float = 26.0
const TOWER_ICON_SIZE: float = 22.0
const NEW_COLOR := Color(1.0, 0.6, 0.15)
## RF-465: el lugar bajo el nombre, en letra chica y de color suave.
const PLACE_COLOR := Color(0.72, 0.76, 0.84)
const PLACE_FONT_SIZE: int = 14
const CARD_FONT_SIZE: int = 20
const CARD_FONT_SIZE_PLACE: int = 18
## Un renglón «en blanco» que Godot no descarta (RF-465).
const PLACE_SPACER: String = "\u200C"
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
@onready var _cards: HFlowContainer = %Cards
@onready var _back_button: Button = %BackButton
@onready var _total_stars: Label = %TotalStars
@onready var _campaign_tab: Button = %CampaignTab
@onready var _community_tab: Button = %CommunityTab
@onready var _folder_button: Button = %FolderButton


func _ready() -> void:
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	_folder_button.pressed.connect(open_folder)
	_campaign_tab.pressed.connect(show_page.bind(PAGE_CAMPAIGN))
	_community_tab.pressed.connect(show_page.bind(PAGE_COMMUNITY))
	_entries = CommunityMaps.scan(community_dir)  # RF-226: se vuelve a buscar cada vez que se abre
	_community_tab.text = "Mapas de la comunidad (%d)" % _entries.size()
	_modes = ModePacks.all(modes_official_dir, modes_user_dir)  # RF-389: también cada vez
	_add_mode_tabs()
	show_page(GameFlow.select_page)  # RF-225: la solapa en la que se estaba
	if DevMode.enabled:
		_add_dev_strip()
	Audio.add_click_sounds(self)


## Esc (o "atrás" en Android, RF-142) vuelve al menú principal.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		GameFlow.go_to_main_menu()


## Cambia de solapa y vuelve a armar las tarjetas (RF-221).
func show_page(page: StringName) -> void:
	var mode: Dictionary = _mode_for(page)
	if page != PAGE_CAMPAIGN and page != PAGE_COMMUNITY and mode.is_empty():
		page = PAGE_CAMPAIGN  # un modo que ya no está (se borró la carpeta): se vuelve a la campaña
	_page = page
	GameFlow.select_page = page
	_campaign_tab.set_pressed_no_signal(page == PAGE_CAMPAIGN)
	_community_tab.set_pressed_no_signal(page == PAGE_COMMUNITY)
	for tab_page: StringName in _mode_tabs:
		(_mode_tabs[tab_page] as Button).set_pressed_no_signal(tab_page == page)
	for card: Node in _cards.get_children():
		_cards.remove_child(card)
		card.queue_free()
	var count: int
	if page == PAGE_CAMPAIGN:
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
	var shown: int = mini(rows, VISIBLE_ROWS)
	_scroll.custom_minimum_size.y = shown * CARD_SIZE.y + (shown - 1) * CARD_SPACING


func current_page() -> StringName:
	return _page


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
		_campaign_tab.get_parent().add_child(tab)
		if mode["official"]:
			after_campaign += 1
			after_community += 1
			_campaign_tab.get_parent().move_child(tab, after_campaign)
		else:
			after_community += 1
			_campaign_tab.get_parent().move_child(tab, after_community)
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
	var card := _new_card()
	card.text = "Nivel %d\n%s\n%d oleadas\n%s\n\n" % [
		index + 1, level.display_name, level.waves.size(), status_text(index)]
	if level.extra_towers.has("mechanical_standard"):
		card.tooltip_text = "Estandarte mecánico: requiere cinco avances de niveles1–5 (%d/5)." % SaveManager.collected_sources(&"technology").size()
	elif CollectibleRun.eligible(&"technology", level.id):
		card.tooltip_text = "Avance de este nivel: %s. Una pieza distinta por nivel1–5." % ("conseguido" if SaveManager.collected_sources(&"technology").has(String(level.id)) else "pendiente")
	card.disabled = not GameFlow.is_level_unlocked(index)
	if not card.disabled and level.place_text != "":
		_add_place(card, index, level)
	_add_tower_icons(card, index)
	card.pressed.connect(GameFlow.start_level.bind(index))
	_add_stars(card, GameFlow.level_stars(index), GameFlow.is_level_unlocked(index))
	return card


## RF-465: el lugar del nivel en UNA línea debajo del nombre. La tarjeta es un Button con un solo texto, así
## que se le reserva un renglón bajo el nombre y el lugar se pone encima, con letra chica. Godot descarta los
## renglones que solo tienen espacios (los «\n\n» del final de la tarjeta tampoco ocupan lugar), por eso los
## renglones reservados llevan un carácter invisible (U+200C). Con el renglón de más el texto ya no entra
## entre el nombre y las torres, así que la tarjeta con lugar usa letra de 18 y dos renglones invisibles
## al final que suben el bloque (centrado). Si el lugar no entra en el ancho se corta con «…» y el cuadro de
## ayuda (tooltip) lo muestra completo. El tamaño de la tarjeta no cambia y la tarjeta sin lugar es idéntica a
## la de siempre. Se llama solo en niveles desbloqueados y con lugar.
func _add_place(card: Button, index: int, level: LevelData) -> void:
	card.text = "Nivel %d\n%s\n%s\n%d oleadas\n%s\n%s\n%s" % [index + 1, level.display_name, PLACE_SPACER, level.waves.size(),
		status_text(index), PLACE_SPACER, PLACE_SPACER]
	card.add_theme_font_size_override("font_size", CARD_FONT_SIZE_PLACE)
	var font: Font = card.get_theme_font("font")
	var margins: Vector2 = card.get_theme_stylebox("normal").get_minimum_size()
	var inner_width: float = CARD_SIZE.x - margins.x
	var flags: int = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	var above: Vector2 = font.get_multiline_string_size("Nivel %d\n%s\n" % [index + 1, level.display_name],
		HORIZONTAL_ALIGNMENT_CENTER, inner_width, CARD_FONT_SIZE_PLACE, -1, flags)
	var whole: Vector2 = font.get_multiline_string_size(card.text, HORIZONTAL_ALIGNMENT_CENTER, inner_width, CARD_FONT_SIZE_PLACE, -1, flags)
	var line_height: float = font.get_height(CARD_FONT_SIZE_PLACE)
	var label := Label.new()
	label.name = "Place"
	label.text = level.place_text
	label.add_theme_font_size_override("font_size", PLACE_FONT_SIZE)
	label.add_theme_color_override("font_color", PLACE_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = Vector2(CARD_SIZE.x - 12.0, line_height)
	# El bloque de texto va centrado en la tarjeta: el renglón reservado empieza donde termina el nombre.
	label.position = Vector2(6.0, (CARD_SIZE.y - whole.y) / 2.0 + above.y)
	card.add_child(label)
	card.tooltip_text = level.place_text + ("\n" + card.tooltip_text if card.tooltip_text != "" else "")


## RF-397: íconos chicos de las torres que ofrece el nivel (los de la barra) y, en las que debutan ahí,
## una marca naranja y "Nueva" al pasar el mouse. Se calcula en el momento, desde los datos.
func _add_tower_icons(card: Button, index: int) -> void:
	if _all_towers.is_empty():
		_all_towers = TowerOffer.canonical_towers()
	var levels: Array[LevelData] = []
	for i: int in GameFlow.level_count():
		levels.append(GameFlow.level(i))
	var fresh: PackedStringArray = TowerOffer.new_tower_ids(levels, index, _all_towers)
	var row := HBoxContainer.new()
	row.name = "TowerIcons"
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.position = Vector2(4, CARD_SIZE.y - CARD_STAR_SIZE - 18.0 - TOWER_ICON_SIZE - 4.0)
	for tower: TowerData in TowerOffer.offered(levels[index], _all_towers):
		var icon := TextureRect.new()
		icon.name = String(tower.id)
		icon.texture = Tower.make_icon(tower)
		icon.custom_minimum_size = Vector2(TOWER_ICON_SIZE, TOWER_ICON_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var is_new: bool = fresh.has(String(tower.id))
		card.tooltip_text += "%s%s%s" % ["\n" if card.tooltip_text != "" else "", tower.display_name, " · Nueva" if is_new else ""]
		if is_new:
			var mark := ColorRect.new()
			mark.name = "NewMark"
			mark.color = NEW_COLOR
			mark.size = Vector2(7, 7)
			mark.position = Vector2(TOWER_ICON_SIZE - 8.0, 1.0)
			mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.add_child(mark)
		row.add_child(icon)
	card.add_child(row)


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


func _new_card() -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
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
