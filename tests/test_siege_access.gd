# Tests del acceso a Asedio (M76, RF-692, RF-693, D-201): se abre por la campaña del mismo número y los
# guardados que ya jugaron Asedio conservan lo que tenían. Nunca se cambia de escena: se usa el guardado de prueba.
extends GutTest

const TEST_PATH: String = "user://test_siege_access.json"
const DEV_PATH: String = "user://test_siege_access_pruebas.json"

var siege: Dictionary


func before_each() -> void:
	_clean()
	DevMode.set_enabled(false, TEST_PATH)
	siege = ModePacks.read(ModePacks.OFFICIAL_DIR, "asedio", true)
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	GameFlow.current_index = -1


func after_each() -> void:
	GameFlow.current_mode = {}
	GameFlow.current_mode_index = -1
	DevMode.set_enabled(false, TEST_PATH)
	_clean()
	SaveManager._siege_mode = {}
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _clean() -> void:
	for path: String in [TEST_PATH, DEV_PATH, TEST_PATH + ".tmp", DEV_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _id(number: int) -> String:
	return "modo_asedio_level_%02d" % number


func _entry(unlocked: bool = false, completed: bool = false, lives: int = 0, score: int = 0) -> Dictionary:
	return {"unlocked": unlocked, "completed": completed, "best_lives": lives, "best_score": score}


func _load_file(path: String, levels: Dictionary, scores: Dictionary = {}, settings: Dictionary = {}) -> void:
	var data: Dictionary = {"version": 1, "levels": levels, "scores": scores, "settings": settings}
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	SaveManager.save_path = path
	SaveManager.load_save()


func _legacy() -> Array:
	return SaveManager.siege_legacy_unlocked()


func _open(number: int) -> bool:
	return GameFlow.is_mode_level_unlocked(siege, number - 1)


func _win_campaign(number: int) -> void:
	SaveManager.record_victory(GameFlow.level(number - 1).id, 3)


func _won_siege(number: int) -> void:
	GameFlow.current_mode = siege
	GameFlow.current_mode_index = number - 1
	GameFlow.level_won(3, 100)


# --- Regla nueva (RF-692) ---

func test_campaign_and_siege_files_share_ids() -> void:
	for i: int in GameFlow.level_count():
		assert_eq(StringName(siege["maps"][i]["file"]), GameFlow.level(i).id, "mapa %d" % (i + 1))


func test_new_save_has_every_siege_closed_and_no_legacy() -> void:
	for i: int in 15:
		assert_false(_open(i + 1), "Asedio %d" % (i + 1))
	assert_eq(_legacy().size(), 0)
	assert_true(SaveManager.siege_access_migrated())


func test_winning_campaign_opens_the_same_siege_without_previous_siege() -> void:
	_win_campaign(3)
	assert_true(_open(3), "campaña 3 ganada abre Asedio 3 aunque el 2 no se haya jugado")
	assert_false(_open(2))
	assert_false(_open(4))


func test_campaign_opens_siege_with_any_stars() -> void:
	SaveManager.record_victory(GameFlow.level(4).id, 1)  # una sola vida: 1 estrella o menos
	assert_true(_open(5))


func test_unlocked_campaign_level_without_victory_does_not_open_siege() -> void:
	SaveManager.unlock(GameFlow.level(5).id)
	assert_false(_open(6))


func test_winning_siege_records_but_does_not_open_next() -> void:
	_win_campaign(4)
	_won_siege(4)
	assert_true(SaveManager.is_completed(StringName(_id(4))))
	assert_eq(SaveManager.best_score(StringName(_id(4))), 100)
	assert_false(_open(5), "Asedio 5 sigue cerrado")
	assert_false(SaveManager.is_unlocked(StringName(_id(5))), "ni queda un unlocked escrito")
	assert_false(GameFlow.has_next_level())


func test_siege_victory_of_a_closed_map_still_does_not_grant_next() -> void:
	_won_siege(7)  # p. ej. partida de otra manera: no abre nada
	assert_false(_open(7))
	assert_false(_open(8))


func test_own_modes_keep_their_access_and_record_result() -> void:
	var dir: String = "user://test_siege_modes/"
	DirAccess.make_dir_recursive_absolute(dir + "propio")
	var file := FileAccess.open(dir + "propio/modo.json", FileAccess.WRITE)
	file.store_string('{"version": 1, "nombre": "Propio", "mapas": ["level_01", "level_02"]}')
	file.close()
	var own: Dictionary = ModePacks.read(dir, "propio", false)
	assert_false(SiegeAccess.applies_to(own))
	assert_true(GameFlow.is_mode_level_unlocked(own, 1), "los modos propios siguen abiertos")
	GameFlow.current_mode = own
	GameFlow.current_mode_index = 0
	GameFlow.level_won(3, 10)
	assert_true(SaveManager.is_completed(ModePacks.map_level(own, 0).id))
	assert_true(SaveManager.is_unlocked(ModePacks.map_level(own, 1).id), "el flujo general sigue guardando el siguiente")
	DirAccess.remove_absolute(dir + "propio/modo.json")
	DirAccess.remove_absolute(dir + "propio")
	DirAccess.remove_absolute(dir)


func test_other_official_mode_unlocks_next_when_winning() -> void:
	var dir: String = "user://test_siege_serie/"
	DirAccess.make_dir_recursive_absolute(dir + "serie")
	var file := FileAccess.open(dir + "serie/modo.json", FileAccess.WRITE)
	file.store_string('{"version": 1, "nombre": "Serie", "mapas": ["level_01", "level_02"]}')
	file.close()
	var other: Dictionary = ModePacks.read(dir, "serie", true)
	assert_false(SiegeAccess.applies_to(other))
	assert_true(GameFlow.is_mode_level_unlocked(other, 0))
	assert_false(GameFlow.is_mode_level_unlocked(other, 1))
	GameFlow.current_mode = other
	GameFlow.current_mode_index = 0
	GameFlow.level_won(3, 10)
	assert_true(GameFlow.is_mode_level_unlocked(other, 1), "regla anterior de los demás modos")
	DirAccess.remove_absolute(dir + "serie/modo.json")
	DirAccess.remove_absolute(dir + "serie")
	DirAccess.remove_absolute(dir)


# --- Migración (RF-693) ---

func test_old_save_without_any_siege_data_gets_nothing() -> void:
	_load_file(TEST_PATH, {"level_01": _entry(true, true, 5, 100)})
	assert_eq(_legacy().size(), 0, "la migración no agrega accesos heredados")
	assert_true(_open(1), "la victoria de campaña abre Asedio 1 por la regla nueva")
	assert_false(_open(2))


func test_old_save_with_unlocked_flag_keeps_the_old_access() -> void:
	_load_file(TEST_PATH, {_id(3): _entry(true)})
	assert_eq(_legacy(), [_id(1), _id(3)], "mapa 1 y el habilitado")
	assert_true(_open(1))
	assert_true(_open(3))
	assert_false(_open(2))


func test_old_save_with_completed_map_keeps_it_and_its_next() -> void:
	_load_file(TEST_PATH, {_id(1): _entry(true, true, 4, 90), _id(5): _entry(false, true, 3, 50)})
	assert_eq(_legacy(), [_id(1), _id(2), _id(5), _id(6)])
	assert_true(_open(2))
	assert_true(_open(6))
	assert_false(_open(3))
	assert_eq(SaveManager.best_score(StringName(_id(5))), 50, "no se pierde nada")


func test_evidence_only_by_record_table_still_migrates() -> void:
	_load_file(TEST_PATH, {}, {_id(2): [{"name": "AAA", "points": 700}]})
	assert_eq(_legacy(), [_id(1)])
	assert_true(_open(1))
	assert_eq(SaveManager.scores(StringName(_id(2))).size(), 1, "el récord se conserva aunque falte el registro de nivel")


func test_evidence_by_best_lives_or_best_score_only() -> void:
	_load_file(TEST_PATH, {_id(4): _entry(false, false, 2, 0)})
	assert_eq(_legacy(), [_id(1)])
	_load_file(TEST_PATH, {_id(4): _entry(false, false, 0, 300)})
	assert_eq(_legacy(), [_id(1)])


func test_non_evidence_gives_no_access() -> void:
	# Registros vacíos, tablas vacías, ids de otro modo, ids inexistentes y la campaña no cuentan.
	_load_file(TEST_PATH, {
		_id(1): _entry(), "modo_asedio_level_99": _entry(true, true, 5, 5), "modo_otro_level_01": _entry(true, true, 5, 5),
		"level_01": _entry(true, true, 5, 5), "hall_of_fame": _entry(true)},
		{_id(2): [], "modo_asedio_level_99": [{"name": "AAA", "points": 5}], "level_03": [{"name": "AAA", "points": 5}]})
	assert_eq(_legacy().size(), 0)
	assert_true(_open(1), "la campaña 1 ganada abre Asedio 1 aunque no migre legado")
	assert_false(_open(2))


func test_unknown_records_are_not_lost_on_save() -> void:
	_load_file(TEST_PATH, {"modo_otro_level_01": _entry(true, true, 5, 5), _id(1): _entry(true)})
	assert_true(SaveManager.save())
	SaveManager.load_save()
	assert_true(SaveManager.is_completed(&"modo_otro_level_01"))
	assert_eq(SaveManager.best_score(&"modo_otro_level_01"), 5)


func test_migration_is_one_step_and_persists() -> void:
	_load_file(TEST_PATH, {_id(2): _entry(true, true, 3, 10)})
	assert_eq(_legacy(), [_id(1), _id(2), _id(3)])
	assert_true(SaveManager.save())
	var text: String = FileAccess.get_file_as_string(TEST_PATH)
	var json := JSON.new()
	assert_eq(json.parse(text), OK)
	var settings: Dictionary = json.data["settings"]
	assert_eq(settings["siege_access_migrated"], true)
	assert_eq(settings["siege_legacy_unlocked"], [_id(1), _id(2), _id(3)])
	# Recargar no la repite: si ahora hubiera más "evidencia" fuera de la lista, no se suma nada.
	SaveManager.load_save()
	assert_eq(_legacy(), [_id(1), _id(2), _id(3)])


func test_marked_save_does_not_remigrate_new_evidence() -> void:
	_load_file(TEST_PATH, {_id(5): _entry(true, true, 3, 10)}, {},
		{"siege_access_migrated": true, "siege_legacy_unlocked": [_id(1)]})
	assert_eq(_legacy(), [_id(1)], "con marca true solo manda la lista guardada")
	assert_false(_open(5) and _open(6) and _open(4))


func test_invalid_ids_and_types_in_the_list_are_dropped() -> void:
	_load_file(TEST_PATH, {}, {}, {"siege_access_migrated": true,
		"siege_legacy_unlocked": [_id(2), "modo_asedio_level_99", "modo_otro_level_01", "level_03", 7, null, _id(2), _id(1)]})
	assert_eq(_legacy(), [_id(1), _id(2)], "solo ids oficiales válidos, sin repetidos y en orden")


func test_non_boolean_marker_or_list_is_treated_as_unmigrated() -> void:
	_load_file(TEST_PATH, {_id(1): _entry(false, true, 3, 10)}, {},
		{"siege_access_migrated": "yes", "siege_legacy_unlocked": "no es lista"})
	assert_eq(_legacy(), [_id(1), _id(2)])
	_load_file(TEST_PATH, {}, {}, {"siege_access_migrated": 1, "siege_legacy_unlocked": 5})
	assert_eq(_legacy().size(), 0)


func test_unmarked_list_without_evidence_keeps_its_valid_ids() -> void:
	_load_file(TEST_PATH, {}, {}, {"siege_legacy_unlocked": [_id(4), "basura"]})
	assert_eq(_legacy(), [_id(4)], "aditivo: no se cierra lo que ya figuraba")


func test_broken_official_mode_defers_migration_without_losing_saved_ids() -> void:
	_load_file(TEST_PATH, {_id(4): _entry(true)}, {}, {"siege_legacy_unlocked": [_id(4)]})
	SaveManager._siege_mode = {"id": SiegeAccess.MODE_ID, "official": true, "errors": PackedStringArray(["modo roto"]), "maps": []}
	SaveManager.load_save()
	assert_eq(_legacy(), [_id(4)])
	assert_false(SaveManager.siege_access_migrated(), "se reintenta cuando se puedan validar los mapas")
	assert_true(SaveManager.save())
	var json := JSON.new()
	assert_eq(json.parse(FileAccess.get_file_as_string(TEST_PATH)), OK)
	var settings: Dictionary = json.data["settings"]
	assert_eq(settings["siege_legacy_unlocked"], [_id(4)])
	assert_false(settings["siege_access_migrated"])


func test_corrupt_file_starts_clean() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("{ esto no es json")
	file.close()
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	assert_eq(_legacy().size(), 0)
	assert_false(_open(1))


# --- Normal / pruebas (RF-693) ---

func test_dev_mode_opens_everything_and_normal_file_stays_untouched() -> void:
	_win_campaign(2)
	assert_true(SaveManager.save())
	DevMode.set_enabled(true, DEV_PATH)
	for i: int in 15:
		assert_true(_open(i + 1), "pruebas: Asedio %d" % (i + 1))
	GameFlow.current_mode = siege
	GameFlow.current_mode_index = 14
	GameFlow.level_won(3, 50)  # victoria en el guardado de pruebas
	DevMode.set_enabled(false, TEST_PATH)
	assert_true(_open(2), "campaña 2 normal sigue abriendo Asedio 2")
	assert_false(_open(1))
	assert_false(_open(15))
	assert_false(SaveManager.is_completed(StringName(_id(15))), "nada de pruebas pasa al normal")
	assert_eq(_legacy().size(), 0)
	assert_false(SaveManager.is_completed(GameFlow.level(14).id))


func test_each_file_migrates_independently() -> void:
	_load_file(TEST_PATH, {_id(3): _entry(true)})
	assert_eq(_legacy(), [_id(1), _id(3)])
	_load_file(DEV_PATH, {})
	assert_eq(_legacy().size(), 0, "el de pruebas sin evidencia no hereda la lista normal")
	assert_true(SaveManager.save())
	_load_file(TEST_PATH, {_id(3): _entry(true)})
	assert_eq(_legacy(), [_id(1), _id(3)], "volver al normal restaura su propia lista")
	DevMode.set_enabled(true, DEV_PATH)
	assert_eq(_legacy().size(), 0, "y el de pruebas sigue sin ella")
	DevMode.set_enabled(false, TEST_PATH)
	assert_eq(_legacy(), [_id(1), _id(3)])


func test_dev_file_with_own_evidence_migrates_without_touching_normal() -> void:
	_load_file(DEV_PATH, {_id(8): _entry(false, true, 2, 5)})
	assert_eq(_legacy(), [_id(1), _id(8), _id(9)])
	_load_file(TEST_PATH, {})
	assert_eq(_legacy().size(), 0)
