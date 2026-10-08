# Tests de las solapas de modos en la selección de nivel (M49, RF-389, RF-390). Usan carpetas de prueba
# para los modos oficiales y propios y un "abridor de carpeta" falso; nunca cambian de pantalla.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const OFFICIAL: String = "user://test_mode_select_official/"
const USER: String = "user://test_mode_select_user/"
const COMMUNITY: String = "user://test_mode_select_community/"
const TEST_SAVE: String = "user://test_save.json"

var opened_folders: Array[String] = []


func before_each() -> void:
	for dir: String in [OFFICIAL, USER, COMMUNITY]:
		_remove(dir)
	opened_folders = []
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	for dir: String in [OFFICIAL, USER, COMMUNITY]:
		_remove(dir)
	GameFlow.select_page = &"campaign"
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	DirAccess.remove_absolute(dir)


func _mode(root: String, id: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ModePacks.dir_of(root, id))
	var file := FileAccess.open(ModePacks.dir_of(root, id) + ModePacks.FILE_NAME, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _open(page: StringName = &"campaign") -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = OFFICIAL
	select.modes_user_dir = USER
	select.folder_opener = func(path: String) -> void: opened_folders.append(path)
	GameFlow.select_page = page
	add_child_autofree(select)
	return select


func _cards(select: Control) -> Array[Node]:
	return (select.get_node("%Cards") as HFlowContainer).get_children()


func _tab_names(select: Control) -> PackedStringArray:
	var names: PackedStringArray = []
	for child: Node in (select.get_node("%CampaignTab") as Control).get_parent().get_children():
		if child is Button:
			names.append((child as Button).text)
	return names


func _with_modes() -> void:
	_mode(OFFICIAL, "asedio", '{"version": 1, "nombre": "Asedio", "descripcion": "Más duro", "mapas": ["level_01", "level_02", "level_03"]}')
	_mode(USER, "mio", '{"version": 1, "nombre": "Mío", "mapas": ["level_02", "level_01"]}')


# --- Solapas (RF-389) ---

func test_official_modes_go_after_the_campaign_and_own_modes_after_the_community() -> void:
	_with_modes()
	var names: PackedStringArray = _tab_names(_open())
	assert_eq(names, PackedStringArray(["Campaña", "Asedio", "Mapas de la comunidad (0)", "Mío"]))


func test_without_modes_only_the_two_tabs_are_there() -> void:
	var names: PackedStringArray = _tab_names(_open())
	assert_eq(names, PackedStringArray(["Campaña", "Mapas de la comunidad (0)"]))


func test_choosing_a_mode_shows_its_maps_in_order() -> void:
	_with_modes()
	var select: Control = _open()
	var page: StringName = &"mode:asedio"
	(select.mode_tab(page) as Button).pressed.emit()
	assert_eq(select.current_page(), page)
	assert_eq(GameFlow.select_page, page, "RF-225: se recuerda la solapa")
	var cards: Array[Node] = _cards(select)
	assert_eq(cards.size(), 3)
	assert_true((cards[0] as Button).text.begins_with("Mapa 1\n" + GameFlow.level(0).display_name))
	assert_true((select.mode_tab(page) as Button).button_pressed)
	assert_false((select.get_node("%CampaignTab") as Button).button_pressed)
	assert_eq((select.get_node("%TotalStars") as Label).text, "Estrellas: 0 de 9")


func test_the_remembered_mode_page_opens_again() -> void:
	_with_modes()
	var select: Control = _open(&"mode:mio")
	assert_eq(select.current_page(), &"mode:mio")
	assert_eq(_cards(select).size(), 2)


func test_a_page_of_a_mode_that_is_gone_falls_back_to_the_campaign() -> void:
	var select: Control = _open(&"mode:borrado")
	assert_eq(select.current_page(), &"campaign")
	assert_eq(_cards(select).size(), GameFlow.level_count())


# --- Bloqueo y estado (RF-390) ---

func test_official_maps_open_one_after_the_other() -> void:
	_with_modes()
	var select: Control = _open(&"mode:asedio")
	var cards: Array[Node] = _cards(select)
	assert_false((cards[0] as Button).disabled)
	assert_true((cards[1] as Button).disabled, "cerrado hasta ganar el mapa 1 del modo")
	assert_true((cards[1] as Button).text.contains("Bloqueado"))


func test_winning_a_mode_map_opens_the_next_one_on_the_screen() -> void:
	_with_modes()
	var mode: Dictionary = ModePacks.read(OFFICIAL, "asedio", true)
	SaveManager.record_victory(ModePacks.map_level(mode, 0).id, 18, 500)
	var cards: Array[Node] = _cards(_open(&"mode:asedio"))
	assert_true((cards[0] as Button).text.contains("Mejor: 18 vidas"))
	assert_false((cards[1] as Button).disabled)
	assert_true((cards[1] as Button).text.contains("¡Jugar!"))


func test_winning_the_campaign_level_does_not_open_the_mode_map() -> void:
	_with_modes()
	SaveManager.record_victory(GameFlow.level(0).id, 20, 500)
	var cards: Array[Node] = _cards(_open(&"mode:asedio"))
	assert_true((cards[1] as Button).disabled, "RF-390: el progreso de cada modo es aparte")


func test_own_mode_maps_are_all_open() -> void:
	_with_modes()
	for card: Node in _cards(_open(&"mode:mio")):
		assert_false((card as Button).disabled)


# --- Errores (RF-388) ---

func test_a_broken_mode_shows_one_card_with_the_reason() -> void:
	_mode(USER, "roto", '{"version": 1}')
	var select: Control = _open(&"mode:roto")
	var cards: Array[Node] = _cards(select)
	assert_eq(cards.size(), 1)
	assert_true((cards[0] as Button).disabled)
	assert_true((cards[0] as Button).text.contains("Con errores"))
	assert_true((cards[0] as Button).tooltip_text.contains("nombre"), (cards[0] as Button).tooltip_text)
	assert_eq(_tab_names(select)[2], "roto (con errores)")


func test_a_broken_map_is_a_disabled_card_and_the_rest_still_play() -> void:
	_mode(USER, "mezcla", '{"version": 1, "nombre": "Mezcla", "mapas": ["no_existe", "level_01"]}')
	var cards: Array[Node] = _cards(_open(&"mode:mezcla"))
	assert_eq(cards.size(), 2)
	assert_true((cards[0] as Button).disabled)
	assert_true((cards[0] as Button).tooltip_text.contains("No existe el mapa"))
	assert_false((cards[1] as Button).disabled)


func test_an_empty_own_mode_says_how_to_add_maps() -> void:
	_mode(USER, "vacio", '{"version": 1, "nombre": "Vacío", "mapas": []}')
	var cards: Array[Node] = _cards(_open(&"mode:vacio"))
	assert_eq(cards.size(), 1)
	assert_true((cards[0] as Label).text.contains("Guardar en un modo"))


# --- La carpeta ---

func test_own_modes_open_their_own_folder_and_official_ones_none() -> void:
	_with_modes()
	var select: Control = _open(&"mode:asedio")
	var folder: Button = select.get_node("%FolderButton")
	assert_false(folder.visible, "un modo oficial no se edita desde la carpeta")
	select.show_page(&"mode:mio")
	if not select.can_add_maps():
		assert_false(folder.visible, "en el celular no se ofrece")
		return
	assert_true(folder.visible)
	assert_eq(folder.text, "Abrir carpeta del modo")
	folder.pressed.emit()
	assert_eq(opened_folders, [ProjectSettings.globalize_path(ModePacks.dir_of(USER, "mio"))])
	select.show_page(&"community")
	assert_eq(folder.text, "Abrir carpeta de mapas", "la de la comunidad vuelve a su texto")
