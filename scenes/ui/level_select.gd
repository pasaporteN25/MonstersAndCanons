# Selección de nivel (RF-111, RF-112, RF-116, RF-221): dos solapas, la Campaña y los Mapas de la
# comunidad. En la campaña, los bloqueados no se pueden elegir y los completados muestran sus
# estrellas (RF-93) y su mejor resultado. Los mapas de la comunidad (los .json de user://maps/)
# están todos abiertos, y los que tienen errores se ven deshabilitados con el motivo (RF-222).
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
const ERROR_COLOR := Color(1.0, 0.55, 0.55)
## RF-319: tope del oro que se puede escribir a mano en la franja de pruebas.
const DEV_MAX_GOLD: int = 999999

## RF-226: dónde se buscan los mapas de la comunidad. Los tests usan otra carpeta (hay que
## cambiarlo ANTES de agregar la pantalla al árbol, que es cuando busca).
var community_dir: String = CommunityMaps.DIR
## Cómo se abre la carpeta en el explorador. Los tests lo reemplazan (si no, abrirían una ventana).
var folder_opener: Callable = OS.shell_open

var _page: StringName = PAGE_CAMPAIGN
var _entries: Array[Dictionary] = []
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
	_page = page
	GameFlow.select_page = page
	_campaign_tab.set_pressed_no_signal(page == PAGE_CAMPAIGN)
	_community_tab.set_pressed_no_signal(page == PAGE_COMMUNITY)
	for card: Node in _cards.get_children():
		_cards.remove_child(card)
		card.queue_free()
	var count: int
	if page == PAGE_CAMPAIGN:
		for i: int in GameFlow.level_count():
			_cards.add_child(_make_card(i))
		count = GameFlow.level_count()
		_total_stars.text = "Estrellas: %d de %d" % [GameFlow.total_stars(), GameFlow.max_stars()]
	else:
		for entry: Dictionary in _entries:
			_cards.add_child(_make_community_card(entry))
		count = _entries.size()
		if _entries.is_empty():
			_cards.add_child(_empty_message())
		_total_stars.text = "%d %s" % [_entries.size(), "mapa" if _entries.size() == 1 else "mapas"]
	_folder_button.visible = page == PAGE_COMMUNITY and can_add_maps()
	# Alto del área: las filas que hay, hasta VISIBLE_ROWS (con una sola fila no sobra espacio).
	var rows: int = maxi(ceili(float(count) / CARDS_PER_ROW), 1)
	var shown: int = mini(rows, VISIBLE_ROWS)
	_scroll.custom_minimum_size.y = shown * CARD_SIZE.y + (shown - 1) * CARD_SPACING


func current_page() -> StringName:
	return _page


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
	return most


func _on_dev_wave_changed(value: float) -> void:
	DevMode.start_wave = int(value)


func _on_dev_gold_changed() -> void:
	_dev_gold.editable = not _dev_auto.button_pressed
	DevMode.start_gold = -1 if _dev_auto.button_pressed else int(_dev_gold.value)


## En el celular la carpeta de mapas no se ve (D-034): no se ofrece agregar mapas.
func can_add_maps() -> bool:
	return not OS.has_feature("android")


## RF-221: abre la carpeta de mapas (y la crea si todavía no existe).
func open_folder() -> void:
	DirAccess.make_dir_recursive_absolute(community_dir)
	folder_opener.call(ProjectSettings.globalize_path(community_dir))


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
	card.pressed.connect(GameFlow.start_level.bind(index))
	_add_stars(card, GameFlow.level_stars(index), GameFlow.is_level_unlocked(index))
	return card


## Una tarjeta de un mapa de la comunidad (RF-221). Con errores: deshabilitada y con el motivo (RF-222).
func _make_community_card(entry: Dictionary) -> Button:
	var card := _new_card()
	var level: LevelData = entry["level"]
	if level == null:
		var errors: PackedStringArray = entry["errors"]
		card.text = "%s\nCon errores\n\n\n" % entry["file"]
		card.disabled = true
		card.tooltip_text = errors[0] if not errors.is_empty() else ""
		card.add_theme_color_override("font_disabled_color", ERROR_COLOR)
		return card
	card.text = "%s\n%d oleadas\n%s\n\n" % [level.display_name, level.waves.size(), community_status_text(entry)]
	card.pressed.connect(GameFlow.start_community.bind(level))
	_add_stars(card, GameFlow.community_stars(level), true)
	return card


func _new_card() -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.add_theme_font_size_override("font_size", 20)
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
	var label := Label.new()
	label.custom_minimum_size = Vector2(900, 180)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	if can_add_maps():
		label.text = "Todavía no hay mapas de la comunidad.\n\nCopiá archivos .json a esta carpeta y aparecen acá:\n%s\n\nLos mapas que hacés con el editor de mapas (versión de pruebas) también aparecen solos." \
			% CommunityMaps.folder_path(community_dir)
	else:
		label.text = "Todavía no hay mapas de la comunidad.\n\nEn el celular no se pueden agregar mapas: usá la versión de computadora."
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
