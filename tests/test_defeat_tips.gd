# Tests del consejo de la pantalla de derrota en la partida y en la pantalla (T421, M70: RF-630, RF-631,
# RF-636, RF-637). La lógica de la elección está en test_defeat_advice.gd; acá, cómo se conecta y cómo se ve.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ui/end_screen.tscn")

var game: Game
var _old_save_path: String


func before_each() -> void:
	_old_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_defeat_tips.json"
	SaveManager.set_setting("defeat_advice", true)
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	SaveManager.save_path = _old_save_path
	if FileAccess.file_exists("user://test_defeat_tips.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_defeat_tips.json"))


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Hace llegar `count` enemigos del tipo a la salida, por el camino real de la partida.
func _leak(id: String, count: int) -> void:
	for i: int in count:
		game.dev_spawn(_enemy(id))
		var enemy: Enemy = game.enemies.get_child(game.enemies.get_child_count() - 1)
		game._on_enemy_reached_exit(enemy)
		enemy.queue_free()


func _label(unique_name: String) -> Label:
	return game.end_screen.get_node("%" + unique_name) as Label


func _button_order(screen: EndScreen) -> Array[String]:
	var names: Array[String] = []
	for child: Node in screen.get_node("%Rows").get_children():
		if child is Button:
			names.append(child.name)
	return names


# --- El registro (RF-631) ---

func test_leaks_are_recorded_when_enemies_reach_the_exit() -> void:
	_leak("flyer", 3)
	assert_eq(game.leak_log.leaks[_enemy("flyer")], 3)
	assert_eq(game.leak_log.total_lives(), 3)
	assert_eq(game.session.lives, 17)


func test_leaks_record_only_the_lives_really_taken() -> void:
	game.session.lose_lives(game.session.lives - 1)
	_leak("boss", 1)
	assert_eq(game.leak_log.lives[_enemy("boss")], 1, "quedaba 1 vida")


func test_infinite_lives_record_nothing() -> void:
	game.dev_set_infinite_lives(true)
	_leak("flyer", 3)
	assert_true(game.leak_log.is_empty())


func test_a_leak_after_the_game_is_over_records_nothing() -> void:
	game.session.lose_lives(20)
	_leak("flyer", 1)
	assert_true(game.leak_log.is_empty())


func test_defeat_with_flyer_leaks_shows_a_tower_tip_of_this_level() -> void:
	_leak("flyer", 6)
	game.session.lose_lives(20)
	var tip: String = game.end_screen.tower_tip_text()
	assert_string_contains(tip, "Ametralladora")
	assert_false(tip.contains("{"))
	for tower: TowerData in game.tower_types:
		if not game.available_towers.has(tower):
			assert_false(tip.contains(tower.display_name), "%s no está en el nivel" % tower.display_name)


func test_defeat_without_leaks_shows_no_tower_tip() -> void:
	game.session.lose_lives(20)
	assert_true(game.end_screen.visible)
	assert_eq(game.end_screen.tower_tip_text(), "", "sin datos no se inventa nada")
	assert_eq(_label("Title").text, "Derrota")


func test_turning_off_the_option_skips_the_defeat_tip() -> void:
	_leak("flyer", 6)
	SaveManager.set_setting("defeat_advice", false)
	game.session.lose_lives(20)
	assert_true(game.end_screen.visible)
	assert_eq(game.end_screen.tower_tip_text(), "")


func test_victory_shows_no_tips() -> void:
	_leak("flyer", 6)
	game.session.set_gold(2000)
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		game.session.complete_wave()
	assert_true(game.end_screen.visible)
	assert_eq(_label("Title").text, "¡Victoria!")
	assert_eq(game.end_screen.tower_tip_text(), "")


func test_a_later_victory_screen_hides_tips_left_by_a_defeat() -> void:
	var screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(screen)
	screen.show_defeat(3, 10, true, 0, "Un consejo.")
	assert_eq(screen.tower_tip_text(), "Un consejo.")
	screen.show_victory(10, 3, true, true)
	assert_eq(screen.tower_tip_text(), "")





func test_defeat_tips_never_change_the_session() -> void:
	_leak("flyer", 4)
	var gold: int = game.session.gold
	game.defeat_tips()
	assert_eq(game.session.gold, gold)
	assert_eq(game.session.lives, 16)


# --- La pantalla (RF-636) ---

func test_buttons_keep_their_order_and_size_with_and_without_tips() -> void:
	var screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(screen)
	screen.show_defeat(3, 10, true)
	await wait_process_frames(2)
	var order_before: Array[String] = _button_order(screen)
	var retry: Button = screen.get_node("%RetryButton")
	var size_before: Vector2 = retry.size
	screen.show_defeat(3, 10, true, 0, "Un consejo corto.")
	await wait_process_frames(2)
	assert_eq(_button_order(screen), order_before)
	assert_eq(retry.size, size_before)
	assert_true(retry.visible)


func test_the_tips_sit_between_the_detail_and_the_buttons() -> void:
	var screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(screen)
	screen.show_defeat(3, 10, true, 0, "Un consejo.")
	var rows: Node = screen.get_node("%Rows")
	var detail: int = screen.get_node("%Detail").get_index()
	assert_eq((rows.get_child(detail + 1) as Label).text, "Un consejo.")
	assert_lt(detail + 1, screen.get_node("%NextButton").get_index())


## Los textos más largos que permite el archivo, con los nombres más largos del juego.
func _longest_texts() -> Array[String]:
	var advice: AdviceData = AdviceData.load_file()
	var names: String = "Ametralladora y Francotirador"
	var texts: Array[String] = []
	for rule: Dictionary in advice.rules:
		texts.append(String(rule["text"]).replace(AdviceData.PLACEHOLDER_TOWERS, names))
	return texts


func test_every_official_text_fits_in_two_lines() -> void:
	var screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(screen)
	for text: String in _longest_texts():
		screen.show_defeat(3, 10, true, 0, text)
		await wait_process_frames(2)
		var tip: Label = screen.get_node("%Rows").get_child(screen.get_node("%Detail").get_index() + 1)
		assert_lte(tip.get_line_count(), 2, text)


func test_the_panel_fits_in_1280_by_720_with_the_tip_and_the_record_table() -> void:
	var screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(screen)
	var table: Array = []
	for i: int in 5:
		table.append({"name": "AAA", "points": 99999 - i})
	var worst: String = ""
	for text: String in _longest_texts():
		if text.length() > worst.length():
			worst = text
	screen.show_defeat(20, 20, true, 123456, worst)
	screen.show_scores("Récords del nivel", table, 0)
	await wait_process_frames(3)
	var panel: Control = screen.get_node("Dim/Center/Panel")
	gut.p("Panel de derrota con el consejo y 5 récords: %s" % panel.size)
	assert_lt(panel.size.y, 720.0, "el panel entra en 720 de alto: %s" % panel.size)
	assert_lt(panel.size.x, 1280.0)
	var retry: Button = screen.get_node("%RetryButton")
	assert_lte(retry.get_global_rect().end.y, 720.0, "el botón de reintentar se ve")
	assert_lte((screen.get_node("%LevelsButton") as Button).get_global_rect().end.y, 720.0, "y el de niveles")
