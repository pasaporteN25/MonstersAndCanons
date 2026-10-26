# Tests de las solapas de la selección de nivel y de los mapas de la comunidad (T108, spec §10.4:
# RF-221, RF-222, RF-225, RF-226). Usan una carpeta de pruebas y un "abridor de carpeta" falso.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_DIR: String = "user://test_community_select/"
const TEST_SAVE: String = "user://test_save.json"
const SCREEN_WIDTH: float = 1280.0

var opened_folders: Array[String] = []


func before_each() -> void:
	_clean()
	opened_folders = []
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)  # estas pruebas inspeccionan las tarjetas de campaña
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	_clean()
	GameFlow.select_page = &"campaign"
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _clean() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)


func _write(file_name: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file := FileAccess.open(TEST_DIR + file_name, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _good_map(level_name: String) -> String:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.set_level_name(level_name)
	return draft.to_text()


## Abre la selección con los mapas de la carpeta de pruebas, en la solapa de la comunidad.
func _open(page: StringName = &"community") -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = TEST_DIR
	select.folder_opener = func(path: String) -> void: opened_folders.append(path)
	GameFlow.select_page = page
	add_child_autofree(select)
	return select


func _cards(select: Control) -> Array[Node]:
	return (select.get_node("%Cards") as HFlowContainer).get_children()


# --- Las solapas (RF-221) ---

func test_it_opens_on_the_campaign_by_default() -> void:
	_write("mio.json", _good_map("Mío"))
	var select: Control = _open(&"campaign")
	assert_eq(select.current_page(), &"campaign")
	assert_eq(_cards(select).size(), GameFlow.level_count())
	assert_true((select.get_node("%CampaignTab") as Button).button_pressed)
	assert_false((select.get_node("%CommunityTab") as Button).button_pressed)
	assert_false((select.get_node("%FolderButton") as Button).visible, "la carpeta es de la comunidad")


func test_the_community_tab_says_how_many_maps() -> void:
	_write("uno.json", _good_map("Uno"))
	_write("dos.json", _good_map("Dos"))
	var select: Control = _open()
	assert_eq((select.get_node("%CommunityTab") as Button).text, "Comunidad")
	assert_eq((select.get_node("%TotalStars") as Label).text, "2 mapas")


func test_switching_tabs_rebuilds_the_cards() -> void:
	_write("mio.json", _good_map("Mío"))
	var select: Control = _open(&"campaign")
	select.show_page(&"community")
	assert_eq(select.current_page(), &"community")
	assert_eq(_cards(select).size(), 1)
	assert_eq(GameFlow.select_page, &"community", "se recuerda la solapa")
	assert_true((select.get_node("%CommunityTab") as Button).button_pressed)
	assert_false((select.get_node("%CampaignTab") as Button).button_pressed)
	select.show_page(&"campaign")
	assert_eq(_cards(select).size(), GameFlow.level_count())
	assert_true((select.get_node("%TotalStars") as Label).text.begins_with("Estrellas: "), "vuelven las estrellas de la campaña")


func test_the_tab_buttons_switch_pages() -> void:
	_write("mio.json", _good_map("Mío"))
	var select: Control = _open(&"campaign")
	(select.get_node("%CommunityTab") as Button).pressed.emit()
	assert_eq(select.current_page(), &"community")
	(select.get_node("%CampaignTab") as Button).pressed.emit()
	assert_eq(select.current_page(), &"campaign")


func test_it_remembers_the_page_it_was_left_on() -> void:
	# RF-225: al terminar un mapa de la comunidad, "Niveles" vuelve a su solapa.
	_write("mio.json", _good_map("Mío"))
	var select: Control = _open(&"community")
	assert_eq(select.current_page(), &"community")
	assert_eq(_cards(select).size(), 1)


# --- Las tarjetas (RF-221) ---

func test_one_card_per_map_in_alphabetical_order() -> void:
	for id: String in ["zeta", "alfa", "beta"]:
		_write(id + ".json", _good_map("Mapa " + id))
	var texts: PackedStringArray = []
	for card: Node in _cards(_open()):
		texts.append((card as Button).text)
	assert_eq(texts.size(), 3)
	assert_true(texts[0].begins_with("Mapa alfa") and texts[1].begins_with("Mapa beta") and texts[2].begins_with("Mapa zeta"), str(texts))


func test_a_card_shows_name_waves_and_is_open() -> void:
	_write("mio.json", _good_map("Mi mapa"))
	var card: Button = _cards(_open())[0]
	assert_true(card.text.contains("Mi mapa"))
	assert_true(card.text.contains("1 oleadas"))
	assert_true(card.text.contains("¡Jugar!"))
	assert_false(card.disabled, "no hay desbloqueo")
	assert_false(card.text.contains("Nivel "), "no es un nivel de la campaña")


func test_a_played_map_shows_its_best_result_and_stars() -> void:
	_write("mio.json", _good_map("Mi mapa"))
	SaveManager.record_victory(&"comunidad_mio", 19, 800)
	var card: Button = _cards(_open())[0]
	assert_true(card.text.contains("Mejor: 19 vidas"), card.text)
	var stars: StarsDisplay
	for child: Node in card.get_children():
		if child is StarsDisplay:
			stars = child
	assert_eq(stars.count, 3, "19 de 20 vidas = 3 estrellas")
	assert_true(stars.visible)


func test_a_card_starts_its_own_map() -> void:
	_write("mio.json", _good_map("Mi mapa"))
	var card: Button = _cards(_open())[0]
	var methods: PackedStringArray = []
	for connection: Dictionary in card.pressed.get_connections():
		methods.append((connection["callable"] as Callable).get_method())
	assert_true(methods.has("start_community"), "abre su mapa: " + str(methods))


func test_a_long_name_wraps_inside_the_card() -> void:
	_write("largo.json", _good_map("Un nombre muy largo de mapa de treinta"))
	var card: Button = _cards(_open())[0]
	assert_ne(card.autowrap_mode, TextServer.AUTOWRAP_OFF)


# --- Mapas con errores (RF-222) ---

func test_a_broken_map_is_a_disabled_card_with_the_reason() -> void:
	_write("roto.json", _good_map("Roto").replace("\"normal\"", "\"trol\""))
	_write("sano.json", _good_map("Sano"))
	var cards: Array[Node] = _cards(_open())
	var broken: Button = cards[0]
	var healthy: Button = cards[1]
	assert_true(broken.disabled)
	assert_true(broken.text.begins_with("roto"), "muestra el nombre del archivo")
	assert_true(broken.text.contains("Con errores"))
	assert_true(broken.tooltip_text.contains("no existe el enemigo 'trol'"), broken.tooltip_text)
	assert_false(healthy.disabled, "el sano se juega igual")


func test_an_invalid_file_name_is_a_disabled_card_too() -> void:
	_write("Mi Mapa.json", _good_map("X"))
	var card: Button = _cards(_open())[0]
	assert_true(card.disabled)
	assert_true(card.tooltip_text.contains("Nombre de archivo no válido"), card.tooltip_text)


# --- Sin mapas (RF-221) ---

func test_with_no_maps_it_says_where_to_put_them() -> void:
	var select: Control = _open()
	var cards: Array[Node] = _cards(select)
	assert_eq(cards.size(), 1)
	assert_true(cards[0] is Label)
	assert_true((cards[0] as Label).text.contains("Todavía no hay mapas"))
	assert_true((cards[0] as Label).text.contains(".json"))
	assert_true((cards[0] as Label).text.contains("test_community_select"), "dice la carpeta")
	assert_eq((select.get_node("%CommunityTab") as Button).text, "Comunidad")
	assert_eq((select.get_node("%TotalStars") as Label).text, "0 mapas")


func test_one_map_is_singular() -> void:
	_write("uno.json", _good_map("Uno"))
	assert_eq((_open().get_node("%TotalStars") as Label).text, "1 mapa")


# --- La carpeta (RF-221) ---

func test_the_folder_button_opens_the_folder_and_creates_it() -> void:
	var select: Control = _open()
	assert_false(DirAccess.dir_exists_absolute(TEST_DIR))
	var button: Button = select.get_node("%FolderButton")
	assert_true(button.visible)
	button.pressed.emit()
	assert_true(DirAccess.dir_exists_absolute(TEST_DIR), "la crea si no existe")
	assert_eq(opened_folders.size(), 1)
	assert_true(opened_folders[0].replace("\\", "/").ends_with("test_community_select/"), opened_folders[0])
	assert_false(opened_folders[0].begins_with("user://"), "una ruta de verdad, para el explorador")


# --- Buscar de nuevo (RF-226) ---

func test_a_map_added_later_appears_when_the_screen_opens_again() -> void:
	var first: Control = _open()
	assert_eq(_cards(first).size(), 1, "el mensaje de vacío")
	_write("nuevo.json", _good_map("Nuevo"))
	var second: Control = _open()
	assert_eq((second.get_node("%CommunityTab") as Button).text, "Comunidad")
	assert_true((_cards(second)[0] as Button).text.begins_with("Nuevo"))


# --- Muchos mapas ---

func test_many_maps_fit_on_the_screen_and_scroll() -> void:
	for i: int in 13:
		_write("m_%02d.json" % i, _good_map("Mapa %d" % i))
	var select: Control = _open()
	var cards: Array[Node] = _cards(select)
	assert_eq(cards.size(), 13)
	await wait_process_frames(3)
	for card: Node in cards:
		var rect: Rect2 = (card as Control).get_global_rect()
		assert_gte(rect.position.x, 0.0)
		assert_lte(rect.end.x, SCREEN_WIDTH, "ninguna tarjeta se sale de la pantalla")
	var scroll: ScrollContainer = select.get_node("%Scroll")
	assert_gt(scroll.get_v_scroll_bar().max_value, scroll.size.y + 1.0, "3 filas: hay que desplazar")


func test_the_area_height_follows_the_rows() -> void:
	var select: Control = _open()  # vacío: una fila
	assert_eq((select.get_node("%Scroll") as ScrollContainer).custom_minimum_size.y, 214.0)
	for i: int in 7:
		_write("m_%02d.json" % i, _good_map("Mapa %d" % i))
	var seven: Control = _open()
	assert_eq((seven.get_node("%Scroll") as ScrollContainer).custom_minimum_size.y, 214.0 * 2 + 16.0, "7 mapas: dos filas")
