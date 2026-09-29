# Tests de menús y campaña (T41, T42, RF-110 a RF-112).
# OJO: nunca se llaman funciones que cambian de pantalla (start_level, go_to_...):
# reemplazarían la escena de GUT y cortarían los tests.
extends GutTest

const TEST_PATH: String = "user://test_save.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SCREEN_WIDTH: float = 1280.0

var _saved_levels: Array[LevelData] = []


func before_each() -> void:
	_saved_levels = GameFlow.campaign.levels.duplicate()
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1


func after_each() -> void:
	GameFlow.campaign.levels = _saved_levels
	GameFlow.current_index = -1
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


# --- Campaña y desbloqueo (RF-112) ---

func test_campaign_starts_with_level_01() -> void:
	assert_gt(GameFlow.level_count(), 0)
	assert_eq(GameFlow.level(0).id, &"level_01")


func test_only_the_first_level_is_unlocked_at_start() -> void:
	assert_true(GameFlow.is_level_unlocked(0))
	for i: int in range(1, GameFlow.level_count()):
		assert_false(GameFlow.is_level_unlocked(i), "nivel %d bloqueado" % (i + 1))


func test_winning_unlocks_the_next_level_and_saves() -> void:
	GameFlow.current_index = 0
	GameFlow.level_won(15)
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_eq(SaveManager.best_lives(&"level_01"), 15)
	if GameFlow.level_count() > 1:
		assert_true(GameFlow.is_level_unlocked(1), "RF-112")
	assert_true(FileAccess.file_exists(TEST_PATH), "se guardó en disco")


func test_winning_outside_the_campaign_saves_nothing() -> void:
	GameFlow.current_index = -1
	GameFlow.level_won(15)
	assert_false(SaveManager.is_completed(&"level_01"))
	assert_false(FileAccess.file_exists(TEST_PATH))


# --- La partida usa el nivel de la campaña ---

func test_game_plays_the_campaign_level() -> void:
	GameFlow.current_index = 0
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	assert_eq(game.level_data, GameFlow.level(0))


func test_victory_in_campaign_shows_levels_button_and_saves() -> void:
	GameFlow.current_index = 0
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()
	# M6 (RF-191): con puntos, primero se piden las iniciales; los botones esperan.
	assert_true(game.end_screen.is_asking_name())
	assert_false((game.end_screen.get_node("%LevelsButton") as Button).visible)
	game.end_screen.name_entry().confirm()
	assert_true((game.end_screen.get_node("%LevelsButton") as Button).visible)
	assert_eq((game.end_screen.get_node("%NextButton") as Button).visible, GameFlow.level_count() > 1)
	assert_true(SaveManager.is_completed(&"level_01"))


func test_victory_outside_campaign_hides_menu_buttons() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.lose_lives(100)
	assert_false((game.end_screen.get_node("%LevelsButton") as Button).visible)
	assert_false((game.end_screen.get_node("%NextButton") as Button).visible)


# --- Pantallas (RF-110, RF-111) ---

func test_main_menu_has_its_buttons() -> void:
	var menu: Control = (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	add_child_autofree(menu)
	for button_name: String in ["PlayButton", "RecordsButton", "WikiButton", "OptionsButton", "QuitButton"]:
		assert_not_null(menu.get_node_or_null("%" + button_name), button_name)


func test_level_select_shows_one_card_per_level() -> void:
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	var cards: HFlowContainer = select.get_node("%Cards")
	assert_eq(cards.get_child_count(), GameFlow.level_count())
	assert_false((cards.get_child(0) as Button).disabled, "el nivel 1 se puede elegir")
	assert_eq(select.status_text(0), "¡Jugar!")


func test_level_select_shows_best_result() -> void:
	SaveManager.record_victory(&"level_01", 17)
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	assert_eq(select.status_text(0), "Mejor: 17 vidas", "RF-111 (las estrellas se ven abajo)")


# --- Estrellas (RF-93, RF-111) ---

func test_victory_screen_shows_stars() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.lose_lives(3)  # quedan 17 → 2 estrellas
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()
	var stars: StarsDisplay = game.end_screen.get_node("%Stars")
	assert_true(stars.visible)
	assert_eq(stars.count, 2)


func test_defeat_screen_hides_stars() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.lose_lives(100)
	assert_false((game.end_screen.get_node("%Stars") as StarsDisplay).visible)


func test_level_stars_come_from_best_lives() -> void:
	assert_eq(GameFlow.level_stars(0), 0, "sin ganar")
	SaveManager.record_victory(&"level_01", 12)
	assert_eq(GameFlow.level_stars(0), 2)
	SaveManager.record_victory(&"level_01", 19)
	assert_eq(GameFlow.level_stars(0), 3, "cuenta el mejor resultado")
	assert_eq(GameFlow.total_stars(), 3)
	assert_eq(GameFlow.max_stars(), GameFlow.level_count() * 3)


func test_level_select_shows_total_stars() -> void:
	SaveManager.record_victory(&"level_01", 20)
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	assert_eq((select.get_node("%TotalStars") as Label).text,
		"Estrellas: 3 de %d" % GameFlow.max_stars())


# --- Selección de nivel con muchos niveles (RF-116) ---

## Abre la selección como si la campaña tuviera `total` niveles (quita del final o repite el primero).
func _select_with(total: int) -> Control:
	while GameFlow.campaign.levels.size() > total:
		GameFlow.campaign.levels.pop_back()
	while GameFlow.campaign.levels.size() < total:
		GameFlow.campaign.levels.append(GameFlow.campaign.levels[0])
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child_autofree(select)
	await wait_process_frames(3)
	return select


func test_no_card_leaves_the_screen_however_many_levels() -> void:
	for total: int in [7, 13, 40]:
		var select: Control = await _select_with(total)
		var cards: HFlowContainer = select.get_node("%Cards")
		assert_eq(cards.get_child_count(), total)
		for card: Control in cards.get_children():
			var rect: Rect2 = card.get_global_rect()
			assert_gte(rect.position.x, 0.0, "%d niveles: no se sale por la izquierda" % total)
			assert_lte(rect.end.x, SCREEN_WIDTH, "%d niveles: no se sale por la derecha" % total)
		select.queue_free()
		await wait_process_frames(1)


func test_cards_wrap_into_rows_of_five() -> void:
	var select: Control = await _select_with(7)
	var cards: Array[Node] = (select.get_node("%Cards") as Control).get_children()
	assert_eq((cards[4] as Control).global_position.y, (cards[0] as Control).global_position.y, "5 en la primera fila")
	assert_gt((cards[5] as Control).global_position.y, (cards[0] as Control).global_position.y, "el sexto baja a otra fila")
	assert_eq((cards[6] as Control).global_position.y, (cards[5] as Control).global_position.y, "y el séptimo va con él")


func test_it_scrolls_only_when_there_are_more_than_two_rows() -> void:
	var scroll_of: Callable = func(select: Control) -> ScrollContainer: return select.get_node("%Scroll")
	var seven: ScrollContainer = scroll_of.call(await _select_with(7))
	assert_lte(seven.get_v_scroll_bar().max_value, seven.size.y + 1.0, "7 niveles = 2 filas: todo se ve, no hace falta desplazar")
	var thirteen: ScrollContainer = scroll_of.call(await _select_with(13))
	assert_gt(thirteen.get_v_scroll_bar().max_value, thirteen.size.y + 1.0, "13 niveles = 3 filas: hay que desplazar")


func test_one_row_when_there_are_five_levels_or_fewer() -> void:
	var select: Control = await _select_with(4)
	var scroll: ScrollContainer = select.get_node("%Scroll")
	assert_eq(scroll.custom_minimum_size.y, 214.0, "una sola fila de tarjetas")
