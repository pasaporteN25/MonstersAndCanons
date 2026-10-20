# Tests de la lógica del tutorial (T330, M63: RF-570, RF-574, RF-575): cuándo sale solo, la máquina de pasos y cómo
# lo guarda el guardado. Nada acá abre escenas.
extends GutTest

const TEST_SAVE: String = "user://test_tutorial_save.json"


func after_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _flow(ids: Array) -> TutorialFlow:
	var steps: Array[Dictionary] = []
	for id: Variant in ids:
		steps.append({"paso": str(id), "texto": "Texto de %s." % id})
	return TutorialFlow.new(steps)


func _use_test_save(content: String = "") -> void:
	SaveManager.save_path = TEST_SAVE
	if content != "":
		var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
		file.store_string(content)
		file.close()
	SaveManager.load_save()


# --- Cuándo sale solo (RF-570) ---

func test_it_shows_only_when_every_condition_holds() -> void:
	assert_true(TutorialFlow.should_auto_show(true, false, false, false, true, true))
	assert_false(TutorialFlow.should_auto_show(false, false, false, false, true, true), "desactivado en Opciones")
	assert_false(TutorialFlow.should_auto_show(true, true, false, false, true, true), "ya completado o saltado")
	assert_false(TutorialFlow.should_auto_show(true, false, true, false, true, true), "modo de pruebas")
	assert_false(TutorialFlow.should_auto_show(true, false, false, true, true, true), "probando desde el editor")
	assert_false(TutorialFlow.should_auto_show(true, false, false, false, false, true), "otro nivel")
	assert_false(TutorialFlow.should_auto_show(true, false, false, false, true, false), "archivo con errores")


# --- La máquina de pasos (RF-574) ---

func test_reading_steps_advance_with_next_and_the_last_one_finishes() -> void:
	var flow: TutorialFlow = _flow(["welcome", "path"])
	var results: Array = []
	flow.finished.connect(func(completed: bool) -> void: results.append(completed))
	assert_eq(flow.current_id(), "welcome")
	assert_true(flow.is_reading())
	assert_false(flow.is_last())
	assert_true(flow.next())
	assert_eq(flow.current_id(), "path")
	assert_true(flow.is_last())
	assert_true(flow.next())
	assert_true(flow.is_finished())
	assert_eq(results, [true])
	assert_false(flow.next(), "ya terminó")


func test_an_action_step_waits_for_its_event_and_ignores_the_rest() -> void:
	var flow: TutorialFlow = _flow(["pick_tower", "place_tower", "gold"])
	assert_false(flow.is_reading())
	assert_false(flow.next(), "«Siguiente» no salta una acción")
	assert_false(flow.notify(TutorialData.EVENT_TOWER_BUILT), "un evento de otro paso no avanza")
	assert_eq(flow.current_id(), "pick_tower")
	assert_true(flow.notify(TutorialData.EVENT_TOWER_SELECTED))
	assert_eq(flow.current_id(), "place_tower")
	assert_false(flow.notify(TutorialData.EVENT_NONE))
	assert_true(flow.notify(TutorialData.EVENT_TOWER_BUILT))
	assert_eq(flow.current_id(), "gold")
	assert_false(flow.notify(TutorialData.EVENT_TOWER_BUILT), "en un paso de lectura los eventos no cuentan")


func test_skip_ends_it_as_not_completed_and_only_once() -> void:
	var flow: TutorialFlow = _flow(["welcome", "path"])
	var results: Array = []
	flow.finished.connect(func(completed: bool) -> void: results.append(completed))
	flow.skip()
	flow.skip()
	assert_true(flow.is_finished())
	assert_eq(results, [false])
	assert_eq(flow.current_id(), "")
	assert_eq(flow.current(), {})


func test_an_empty_tutorial_is_born_finished() -> void:
	var flow: TutorialFlow = TutorialFlow.new()
	assert_true(flow.is_finished())
	assert_false(flow.notify(TutorialData.EVENT_TOWER_BUILT))


func test_steps_already_done_are_skipped_on_arrival() -> void:
	var flow: TutorialFlow = _flow(["path", "pick_tower", "place_tower", "start_wave", "upgrade"])
	assert_true(flow.next())
	assert_eq(flow.current_id(), "pick_tower")
	flow.skip_satisfied(func(id: String) -> bool: return id in ["pick_tower", "place_tower"])
	assert_eq(flow.current_id(), "start_wave", "se adelantó: elegir y construir ya estaban hechos")
	flow.skip_satisfied(func(_id: String) -> bool: return false)
	assert_eq(flow.current_id(), "start_wave", "una acción que no se cumplió no se saltea")


func test_skip_satisfied_stops_at_reading_steps() -> void:
	var flow: TutorialFlow = _flow(["start_wave", "upgrade", "speed"])
	flow.skip_satisfied(func(_id: String) -> bool: return true)
	assert_eq(flow.current_id(), "upgrade", "un paso de lectura nunca se saltea solo")


func test_finishing_by_satisfied_steps_counts_as_completed() -> void:
	var flow: TutorialFlow = _flow(["start_wave"])
	var results: Array = []
	flow.finished.connect(func(completed: bool) -> void: results.append(completed))
	flow.skip_satisfied(func(_id: String) -> bool: return true)
	assert_eq(results, [true])


func test_rewind_goes_back_only_to_an_earlier_step_of_the_list() -> void:
	var flow: TutorialFlow = _flow(["pick_tower", "place_tower", "start_wave"])
	assert_false(flow.rewind_to("pick_tower"), "ya está en el primero")
	flow.notify(TutorialData.EVENT_TOWER_SELECTED)
	assert_true(flow.rewind_to("pick_tower"))
	assert_eq(flow.current_id(), "pick_tower")
	assert_false(flow.rewind_to("start_wave"), "no se puede adelantar")
	assert_false(flow.rewind_to("sell"), "un paso que no está en la lista")
	flow.skip()
	assert_false(flow.rewind_to("pick_tower"), "terminado")


func test_the_step_number_is_one_based_and_stays_in_range() -> void:
	var flow: TutorialFlow = _flow(["welcome", "path"])
	assert_eq(flow.number(), 1)
	assert_eq(flow.count(), 2)
	flow.next()
	assert_eq(flow.number(), 2)
	flow.next()
	assert_eq(flow.number(), 2, "terminado: no pasa del total")


# --- El guardado (RF-575) ---

func test_a_new_save_has_not_done_the_tutorial_and_has_it_enabled() -> void:
	_use_test_save()
	assert_false(SaveManager.tutorial_done())
	assert_true(SaveManager.tutorial_enabled())


func test_marking_it_done_is_saved_and_survives_a_reload() -> void:
	_use_test_save()
	SaveManager.mark_tutorial_done()
	SaveManager.load_save()
	assert_true(SaveManager.tutorial_done())


func test_reset_turns_it_back_on_and_forgets_that_it_was_done() -> void:
	_use_test_save()
	SaveManager.set_setting("tutorial_enabled", false)
	SaveManager.mark_tutorial_done()
	SaveManager.reset_tutorial()
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_done())
	assert_true(SaveManager.tutorial_enabled())


func test_the_enabled_option_is_saved() -> void:
	_use_test_save()
	SaveManager.set_setting("tutorial_enabled", false)
	SaveManager.save()
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_enabled())


func test_an_old_save_that_already_won_level_1_does_not_see_the_tutorial() -> void:
	_use_test_save('{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":18},"level_02":{"unlocked":true,"completed":false,"best_lives":0}},"settings":{"music_volume":0.5}}')
	assert_true(SaveManager.tutorial_done(), "quien ya ganó el nivel 1 no necesita el tutorial")
	assert_true(SaveManager.tutorial_enabled(), "y la opción sigue prendida por omisión")


func test_an_old_save_without_level_1_won_sees_it_once() -> void:
	_use_test_save('{"version":1,"levels":{"level_01":{"unlocked":true,"completed":false,"best_lives":0}},"settings":{"music_volume":0.5}}')
	assert_false(SaveManager.tutorial_done())


func test_a_save_with_a_broken_tutorial_key_falls_back_to_the_level_rule() -> void:
	_use_test_save('{"version":1,"tutorial_done":"si","levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":3}}}')
	assert_true(SaveManager.tutorial_done())
	_use_test_save('{"version":1,"tutorial_done":1,"levels":{}}')
	assert_false(SaveManager.tutorial_done())


func test_an_explicit_false_is_respected_even_with_level_1_won() -> void:
	_use_test_save('{"version":1,"tutorial_done":false,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":3}}}')
	assert_false(SaveManager.tutorial_done(), "quien pidió volver a verlo lo ve aunque haya ganado el nivel")


func test_a_broken_option_value_falls_back_to_enabled() -> void:
	_use_test_save('{"version":1,"settings":{"tutorial_enabled":"no"}}')
	assert_true(SaveManager.tutorial_enabled())


func test_the_new_keys_do_not_change_anything_else_in_the_save() -> void:
	_use_test_save('{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":18,"best_score":900}},"settings":{"music_volume":0.25,"sfx_volume":0.5,"fullscreen":true,"damage_numbers":false},"intro_seen":true}')
	SaveManager.save()
	SaveManager.load_save()
	assert_eq(SaveManager.best_lives(&"level_01"), 18)
	assert_eq(SaveManager.best_score(&"level_01"), 900)
	assert_eq(SaveManager.get_setting("music_volume"), 0.25)
	assert_eq(SaveManager.get_setting("damage_numbers"), false)
	assert_true(SaveManager.intro_seen())
	var file := FileAccess.open(TEST_SAVE, FileAccess.READ)
	var json := JSON.new()
	assert_eq(json.parse(file.get_as_text()), OK)
	assert_eq(int((json.data as Dictionary)["version"]), SaveManager.SAVE_VERSION, "SAVE_VERSION no cambia")
