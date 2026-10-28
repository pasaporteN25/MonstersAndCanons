# Tests del epílogo y de los créditos (T234, M52: RF-471 y RF-472): el botón «Epílogo» en lugar de «Siguiente nivel»
# solo al ganar el último nivel desde la campaña, la pantalla del epílogo (imagen, texto, «Créditos» y «Niveles»),
# los créditos (`data/creditos.json`, «Volver»), y que ver todo eso no escribe nada en el guardado.
extends GutTest

const TEST_SAVE: String = "user://test_epilogue.json"
const DOC_PATH: String = "res://specs/11-textos-lore.md"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ui/end_screen.tscn")

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	GameFlow.intro_pending = false
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	GameFlow.intro_pending = false
	GameFlow.current_index = -1
	GameFlow.current_community = null
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.test_level = null
	GameFlow.select_page = &"campaign"
	DevMode.enabled = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH


func _last_index() -> int:
	return GameFlow.level_count() - 1


## Abre la partida del nivel `index` de la campaña y la gana (si pide iniciales, las confirma).
func _win_level(index: int) -> Game:
	GameFlow.current_index = index
	GameFlow.intro_pending = false
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.state_changed.emit(LevelSession.State.WON)
	if game.end_screen.is_asking_name():
		game.end_screen.name_entry().confirm()
	return game


func _next_button(end_screen: EndScreen) -> Button:
	return end_screen.get_node("%NextButton")


func _cancel() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = "cancel"
	event.pressed = true
	return event


func _click(pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


# --- La pantalla de victoria (RF-471) ---

func test_the_end_screen_swaps_next_level_for_epilogue_and_emits_its_own_signal() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	watch_signals(end_screen)
	end_screen.show_victory(18, 3, false, true, 100, "Texto.", true)
	var button: Button = _next_button(end_screen)
	assert_true(button.visible, "sin siguiente nivel, pero con epílogo")
	assert_eq(button.text, "Epílogo")
	button.pressed.emit()
	assert_signal_emitted(end_screen, "epilogue_pressed")
	assert_signal_not_emitted(end_screen, "next_pressed", "«Epílogo» no es «Siguiente nivel»")
	assert_true((end_screen.get_node("%RetryButton") as Button).visible, "conserva «Reintentar»")
	assert_true((end_screen.get_node("%LevelsButton") as Button).visible, "y «Niveles»")


func test_without_epilogue_the_button_is_next_level_as_before() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	watch_signals(end_screen)
	end_screen.show_victory(18, 3, true, true, 100)
	var button: Button = _next_button(end_screen)
	assert_true(button.visible)
	assert_eq(button.text, "Siguiente nivel")
	button.pressed.emit()
	assert_signal_emitted(end_screen, "next_pressed")
	assert_signal_not_emitted(end_screen, "epilogue_pressed")
	end_screen.show_victory(18, 3, false, true, 100)
	assert_false(_next_button(end_screen).visible, "borde: último nivel sin epílogo no muestra nada")


func test_the_epilogue_label_does_not_stick_after_a_defeat_or_another_victory() -> void:
	var end_screen: EndScreen = END_SCENE.instantiate()
	add_child_autofree(end_screen)
	end_screen.show_victory(18, 3, false, true, 100, "", true)
	end_screen.show_defeat(5, 30, true, 10)
	assert_false(_next_button(end_screen).visible, "la derrota no ofrece nada")
	assert_eq(_next_button(end_screen).text, "Siguiente nivel")
	end_screen.show_victory(18, 3, true, true, 100)
	assert_eq(_next_button(end_screen).text, "Siguiente nivel")


# --- Ganar el último nivel (RF-471) ---

func test_winning_the_last_level_of_the_campaign_offers_the_epilogue_and_no_next_level() -> void:
	assert_eq(GameFlow.level(_last_index()).id, &"level_15", "el último nivel es el 15")
	_win_level(_last_index())
	var button: Button = _next_button(game.end_screen)
	assert_true(button.visible)
	assert_eq(button.text, "Epílogo")
	assert_false(GameFlow.has_next_level(), "no hay siguiente")
	assert_true((game.end_screen.get_node("%LevelsButton") as Button).visible)
	assert_true((game.end_screen.get_node("%RetryButton") as Button).visible)
	assert_eq(game.end_screen.win_text(), GameFlow.level(_last_index()).win_text, "los textos de victoria siguen")


func test_winning_the_fourteenth_still_offers_the_next_level() -> void:
	_win_level(_last_index() - 1)
	assert_true(_next_button(game.end_screen).visible)
	assert_eq(_next_button(game.end_screen).text, "Siguiente nivel")


func test_losing_the_last_level_offers_no_epilogue() -> void:
	GameFlow.current_index = _last_index()
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.state_changed.emit(LevelSession.State.LOST)
	assert_false(_next_button(game.end_screen).visible)


func test_the_epilogue_is_only_in_the_campaign() -> void:
	# Un mapa de la comunidad, un modo oficial o «Probar» desde el editor: aunque tengan texto de epílogo, no hay botón.
	var last: LevelData = GameFlow.level(_last_index())
	assert_ne(last.epilogue_text, "")
	GameFlow.current_index = _last_index()
	assert_true(GameFlow.has_epilogue())
	GameFlow.current_index = -1
	GameFlow.current_community = last
	assert_false(GameFlow.has_epilogue(), "comunidad")
	GameFlow.current_community = null
	GameFlow.test_level = last
	assert_false(GameFlow.has_epilogue(), "editor")
	GameFlow.test_level = null
	GameFlow.current_mode = {"id": "asedio", "official": true}
	GameFlow.current_mode_index = 0
	assert_false(GameFlow.has_epilogue(), "modo")
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	assert_false(GameFlow.has_epilogue(), "sin nivel elegido")


func test_the_test_mode_shows_no_epilogue_button() -> void:
	DevMode.enabled = true
	_win_level(_last_index())
	assert_false(_next_button(game.end_screen).visible, "modo de pruebas (RF-471)")


func test_a_last_level_without_epilogue_text_has_no_button() -> void:
	GameFlow.current_index = _last_index()
	var level: LevelData = GameFlow.level(_last_index())
	var text: String = level.epilogue_text
	level.epilogue_text = ""
	assert_false(GameFlow.has_epilogue(), "borde: sin \"epilogo\" no aparece")
	level.epilogue_text = text


func test_the_campaign_is_complete_when_the_fifteen_levels_are_completed_without_a_new_field() -> void:
	assert_false(GameFlow.is_campaign_complete())
	for i: int in GameFlow.level_count() - 1:
		SaveManager.record_victory(GameFlow.level(i).id, 10, 100)
	assert_false(GameFlow.is_campaign_complete(), "borde: falta el último")
	SaveManager.record_victory(GameFlow.level(_last_index()).id, 10, 100)
	assert_true(GameFlow.is_campaign_complete())
	SaveManager.save()
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	assert_false(saved.has("campaign_complete") or saved.has("epilogue_seen"), "ningún campo nuevo en el guardado")


# --- El epílogo y los créditos (RF-471, RF-472) ---

func test_epilogue_button_opens_the_picture_with_the_three_lines_and_two_buttons() -> void:
	_win_level(_last_index())
	_next_button(game.end_screen).pressed.emit()
	assert_not_null(game.epilogue)
	assert_true(game.epilogue.is_open())
	assert_eq(game.epilogue.text(), GameFlow.level(_last_index()).epilogue_text)
	assert_eq(game.epilogue.text().split("\n").size(), 3, "tres líneas")
	assert_eq(EpilogueScreen.IMAGE.get_size(), Vector2(1920, 1080), "la imagen de T233")
	var texts: Array = []
	for button: Node in game.epilogue.find_children("*", "Button", true, false):
		texts.append((button as Button).text)
	assert_true(texts.has("Créditos") and texts.has("Niveles"), str(texts))


func test_the_epilogue_text_is_the_approved_one() -> void:
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var section: String = doc.split("## 2. Epílogo")[1].split("## 3. Créditos")[0]
	var lines: PackedStringArray = []
	for raw: String in section.split("\n"):
		if raw.begins_with("- "):
			lines.append(raw.substr(2).strip_edges())
	assert_eq(lines.size(), 3)
	assert_eq(GameFlow.level(_last_index()).epilogue_text, "\n".join(lines))
	var errors: PackedStringArray = []
	LevelTexts.parse({"epilogo": GameFlow.level(_last_index()).epilogue_text}, errors)
	assert_eq(errors.size(), 0, str(errors))


func test_escape_or_a_tap_on_the_picture_goes_back_to_the_victory_screen() -> void:
	_win_level(_last_index())
	_next_button(game.end_screen).pressed.emit()
	watch_signals(game.epilogue)
	game.epilogue._input(_cancel())
	assert_false(game.epilogue.is_open())
	assert_signal_emit_count(game.epilogue, "closed", 1)
	assert_true(game.end_screen.visible, "la pantalla de victoria sigue ahí")
	assert_true(_next_button(game.end_screen).visible)
	game.epilogue._input(_cancel())
	assert_signal_emit_count(game.epilogue, "closed", 1, "borde: cerrado, Esc no hace nada")
	_next_button(game.end_screen).pressed.emit()
	assert_true(game.epilogue.is_open(), "se puede volver a abrir")
	game.epilogue._on_root_gui_input(_click(true))
	assert_true(game.epilogue.is_open(), "al apretar todavía no se cierra")
	game.epilogue._on_root_gui_input(_click(false))
	assert_false(game.epilogue.is_open(), "un toque cierra")


func test_credits_open_from_the_epilogue_and_back_returns_to_the_epilogue() -> void:
	_win_level(_last_index())
	_next_button(game.end_screen).pressed.emit()
	var epilogue: EpilogueScreen = game.epilogue
	epilogue.open_credits()
	assert_true(epilogue.credits.is_open())
	assert_eq(epilogue.credits.lines(), Credits.load_file()["lines"])
	(epilogue.credits.find_children("*", "Button", true, false)[0] as Button).pressed.emit()
	assert_false(epilogue.credits.is_open(), "«Volver» cierra los créditos")
	assert_true(epilogue.is_open(), "y deja a la vista el epílogo")


func test_escape_in_the_credits_closes_only_the_credits() -> void:
	_win_level(_last_index())
	_next_button(game.end_screen).pressed.emit()
	var epilogue: EpilogueScreen = game.epilogue
	epilogue.open_credits()
	watch_signals(epilogue)
	epilogue.credits._input(_cancel())
	assert_false(epilogue.credits.is_open())
	assert_true(epilogue.is_open(), "el epílogo no se cierra con el mismo Esc")
	assert_signal_not_emitted(epilogue, "closed")


func test_levels_button_of_the_epilogue_asks_to_go_to_the_level_select() -> void:
	# No se pulsa «Niveles» dentro de la partida: GameFlow.go_to_level_select cambiaría la escena de GUT.
	_win_level(_last_index())
	_next_button(game.end_screen).pressed.emit()
	assert_true(game.epilogue.levels_pressed.is_connected(GameFlow.go_to_level_select), "la partida lo conecta")
	var epilogue := EpilogueScreen.new()
	add_child_autofree(epilogue)
	epilogue.open("Texto.")
	watch_signals(epilogue)
	for button: Node in epilogue.find_children("*", "Button", true, false):
		if (button as Button).text == "Niveles":
			(button as Button).pressed.emit()
			break
	assert_signal_emitted(epilogue, "levels_pressed")


func test_seeing_the_epilogue_and_the_credits_leaves_the_save_identical() -> void:
	for i: int in GameFlow.level_count() - 1:
		SaveManager.record_victory(GameFlow.level(i).id, 12, 100)
	SaveManager.save()
	_win_level(_last_index())
	var before: String = FileAccess.get_file_as_string(TEST_SAVE)
	assert_true(GameFlow.is_campaign_complete())
	_next_button(game.end_screen).pressed.emit()
	game.epilogue.open_credits()
	game.epilogue.credits.close()
	game.epilogue.close()
	_next_button(game.end_screen).pressed.emit()
	assert_eq(FileAccess.get_file_as_string(TEST_SAVE), before, "RF-471: el guardado no cambia")
	SaveManager.load_save()
	assert_true(GameFlow.is_campaign_complete(), "y la campaña sigue terminada")


# --- Los créditos (RF-472) ---

func test_the_credits_file_has_the_approved_lines_and_nothing_unverifiable() -> void:
	var result: Dictionary = Credits.load_file()
	assert_eq(result["errors"], PackedStringArray())
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var section: String = doc.split("## 3. Créditos")[1].split("## 4. Artículos")[0]
	var approved: PackedStringArray = []
	for raw: String in section.split("\n"):
		if raw.begins_with("- "):
			approved.append(raw.substr(2).strip_edges())
	assert_eq(approved.size(), 4)
	assert_eq(result["lines"], approved)
	var licenses: String = FileAccess.get_file_as_string("res://data/wiki/licencias.json")
	assert_true(licenses.contains("Monsters & Canons") and licenses.contains("versión 3 o, a tu elección, cualquier versión posterior"),
		"el copyright y la licencia salen de la Wiki")


func test_the_credits_parser_reports_each_problem() -> void:
	assert_gt((Credits.parse("{ no es json")["errors"] as PackedStringArray).size(), 0)
	assert_gt((Credits.parse("[1, 2]")["errors"] as PackedStringArray).size(), 0)
	assert_string_contains("\n".join(Credits.parse('{"version": 1}')["errors"]), "lineas")
	assert_string_contains("\n".join(Credits.parse('{"version": 2, "lineas": ["a"]}')["errors"]), "version")
	assert_string_contains("\n".join(Credits.parse('{"version": 1, "lineas": []}')["errors"]), "vacía")
	assert_string_contains("\n".join(Credits.parse('{"version": 1, "lineas": [3]}')["errors"]), "texto")
	assert_string_contains("\n".join(Credits.parse('{"version": 1, "lineas": ["a"], "extra": 1}')["errors"]), "extra")
	var long: String = "x".repeat(Credits.LINE_MAX + 1)
	assert_string_contains("\n".join(Credits.parse('{"version": 1, "lineas": ["%s"]}' % long)["errors"]), "máximo")
	var edge: String = "x".repeat(Credits.LINE_MAX)
	assert_eq((Credits.parse('{"version": 1, "lineas": ["%s"]}' % edge)["errors"] as PackedStringArray).size(), 0, "borde: justo el máximo")
	var many: PackedStringArray = []
	for i: int in Credits.MAX_LINES + 1:
		many.append('"l%d"' % i)
	assert_string_contains("\n".join(Credits.parse('{"version": 1, "lineas": [%s]}' % ",".join(many))["errors"]), "máximo")
	assert_gt((Credits.load_file("res://data/no_existe_creditos.json")["errors"] as PackedStringArray).size(), 0)


func test_the_credits_screen_scrolls_when_the_text_does_not_fit_and_shows_the_back_button() -> void:
	var credits := CreditsScreen.new()
	add_child_autofree(credits)
	var lines: PackedStringArray = []
	for i: int in 40:
		lines.append("Línea %d" % i)
	credits.open(lines)
	assert_eq(credits.lines().size(), 40)
	assert_eq(credits.find_children("*", "ScrollContainer", true, false).size(), 1)
	var texts: Array = []
	for button: Node in credits.find_children("*", "Button", true, false):
		texts.append((button as Button).text)
	assert_eq(texts, ["Volver"])
	watch_signals(credits)
	credits.close()
	credits.close()
	assert_signal_emit_count(credits, "closed", 1, "borde: cerrar dos veces avisa una sola")
