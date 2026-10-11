# Tests de cuándo se muestra la intro y a dónde se va (T242, M57: RF-498, RF-500) y de la clave `intro_seen`
# del guardado (aditiva: no sube SAVE_VERSION y un guardado de antes la ve una vez).
extends GutTest

const TEST_SAVE: String = "user://test_intro_flow.json"

## Un guardado de antes de M57 (formato real, sin la clave) con los niveles 1 a 5 ganados.
const SAVE_BEFORE_M57: String = '{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":20,"best_score":900},"level_02":{"unlocked":true,"completed":true,"best_lives":19,"best_score":800},"level_03":{"unlocked":true,"completed":true,"best_lives":15,"best_score":700},"level_04":{"unlocked":true,"completed":true,"best_lives":12,"best_score":650},"level_05":{"unlocked":true,"completed":true,"best_lives":10,"best_score":600}},"settings":{"music_volume":0.7,"sfx_volume":0.8,"fullscreen":false,"damage_numbers":false},"seen_enemies":["normal","fast"],"scores":{"level_01":[{"name":"LUC","points":900}]},"initials":{"3":"LUC"},"hall_total":0,"collections":{"technology":["level_01","level_02"]}}'


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()


func after_each() -> void:
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)


func _write(text: String) -> void:
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _saved() -> Dictionary:
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(TEST_SAVE))
	return json.data


# --- IntroFlow: la tabla de decisiones ---

func test_new_save_shows_the_intro() -> void:
	assert_true(IntroFlow.should_auto_show(false, false, true))


func test_seen_save_does_not_show_it() -> void:
	assert_false(IntroFlow.should_auto_show(true, false, true))


func test_dev_mode_does_not_show_it() -> void:
	assert_false(IntroFlow.should_auto_show(false, true, true))


func test_broken_file_does_not_show_it() -> void:
	assert_false(IntroFlow.should_auto_show(false, false, false))


func test_no_won_levels_goes_to_level_1_and_won_levels_to_the_select() -> void:
	assert_eq(IntroFlow.after_finish(false), IntroFlow.Destination.LEVEL_1)
	assert_eq(IntroFlow.after_finish(true), IntroFlow.Destination.LEVEL_SELECT)


func test_game_flow_knows_if_there_are_won_levels() -> void:
	assert_false(GameFlow.has_won_campaign_level(), "guardado nuevo")
	SaveManager.record_victory(&"level_03", 10, 100)
	assert_true(GameFlow.has_won_campaign_level())


# --- La clave del guardado ---

func test_new_save_has_not_seen_the_intro() -> void:
	assert_false(SaveManager.intro_seen())


func test_marking_it_saves_right_away_and_survives_a_reload() -> void:
	SaveManager.mark_intro_seen()
	assert_true(SaveManager.intro_seen())
	assert_true(FileAccess.file_exists(TEST_SAVE), "se guardó enseguida")
	assert_eq(_saved().get("intro_seen"), true)
	assert_eq(int(_saved().get("version")), SaveManager.SAVE_VERSION, "SAVE_VERSION no cambia")
	SaveManager.load_save()
	assert_true(SaveManager.intro_seen())


func test_only_boolean_true_counts() -> void:
	for raw: String in ['"si"', "1", "null", "[true]", "false", "0"]:
		_write('{"version":1,"intro_seen":%s}' % raw)
		SaveManager.load_save()
		assert_false(SaveManager.intro_seen(), "intro_seen = %s se lee como «no vista»" % raw)
	_write('{"version":1,"intro_seen":true}')
	SaveManager.load_save()
	assert_true(SaveManager.intro_seen())


func test_loading_another_save_resets_the_key() -> void:
	_write('{"version":1,"intro_seen":true}')
	SaveManager.load_save()
	assert_true(SaveManager.intro_seen())
	DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.load_save()
	assert_false(SaveManager.intro_seen(), "sin archivo vuelve a «no vista»")


func test_old_save_without_the_key_sees_the_intro_once_and_keeps_everything() -> void:
	_write(SAVE_BEFORE_M57)
	SaveManager.load_save()
	assert_false(SaveManager.intro_seen(), "un guardado de antes la ve una vez")
	assert_true(GameFlow.has_won_campaign_level())
	assert_eq(IntroFlow.after_finish(GameFlow.has_won_campaign_level()), IntroFlow.Destination.LEVEL_SELECT,
		"con niveles ganados termina en la selección, no en el nivel 1")
	SaveManager.mark_intro_seen()
	SaveManager.load_save()
	assert_true(SaveManager.intro_seen())
	for i: int in 5:
		assert_true(SaveManager.is_completed(StringName("level_%02d" % (i + 1))), "el nivel %d sigue ganado" % (i + 1))
	assert_eq(SaveManager.best_score(&"level_02"), 800)
	assert_eq(SaveManager.get_setting("music_volume"), 0.7)
	assert_eq(SaveManager.get_setting("damage_numbers"), false)
	assert_true(SaveManager.has_seen_enemy(&"fast"))
	assert_eq(SaveManager.scores(&"level_01")[0]["name"], "LUC")
	assert_eq(SaveManager.last_initials(3), "LUC")
	assert_eq(SaveManager.collected_sources(&"technology").size(), 2)


func test_the_new_key_does_not_change_the_rest_of_the_save() -> void:
	_write(SAVE_BEFORE_M57)
	SaveManager.load_save()
	SaveManager.save()
	var before: Dictionary = _saved()
	SaveManager.mark_intro_seen()
	var after: Dictionary = _saved()
	assert_eq(after.get("intro_seen"), true)
	after.erase("intro_seen")
	before.erase("intro_seen")
	assert_eq(after, before, "solo se sumó la clave")
