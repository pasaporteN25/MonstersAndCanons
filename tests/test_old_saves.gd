# Regresión de guardados viejos (T236, RF-115, RF-112, RF-381, RF-430).
# Cada guardado de abajo imita el archivo que escribía una versión anterior del juego (el formato siempre fue
# `"version": 1`, pero los campos se fueron sumando). Se comprueba que:
#   - carga sin errores del motor,
#   - no se pierde ni cambia nada de lo que tenía,
#   - lo que no tenía arranca vacío o por omisión,
#   - volver a guardar y cargar da lo mismo, y
#   - el nivel que sigue a uno ganado queda abierto (también en niveles agregados después, RF-381).
extends GutTest

const PATH: String = "user://test_old_saves.json"
const PATH_DEV: String = "user://test_old_saves_pruebas.json"

## El primer formato (T40): solo niveles y tres opciones.
const SAVE_T40: String = '{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":18},"level_02":{"unlocked":true,"completed":false,"best_lives":0}},"settings":{"music_volume":0.5,"sfx_volume":0.25,"fullscreen":true}}'

## Antes de M50, con los niveles 1 a 9 ganados: `technology` completa y `seen_enemies`, récords, iniciales y Salón de la fama.
## Todavía sin `disruptor` (colección de M51) ni los niveles 10 a 15.
const SAVE_BEFORE_M50: String = '{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":20,"best_score":900},"level_02":{"unlocked":true,"completed":true,"best_lives":19,"best_score":800},"level_03":{"unlocked":true,"completed":true,"best_lives":15,"best_score":700},"level_04":{"unlocked":true,"completed":true,"best_lives":12,"best_score":650},"level_05":{"unlocked":true,"completed":true,"best_lives":10,"best_score":600},"level_06":{"unlocked":true,"completed":true,"best_lives":9,"best_score":500},"level_07":{"unlocked":true,"completed":true,"best_lives":8,"best_score":400},"level_08":{"unlocked":true,"completed":true,"best_lives":7,"best_score":300},"level_09":{"unlocked":true,"completed":true,"best_lives":5,"best_score":200}},"settings":{"music_volume":0.7,"sfx_volume":0.8,"fullscreen":false,"damage_numbers":false},"seen_enemies":["normal","fast","tank","flyer"],"scores":{"level_01":[{"name":"LUC","points":900},{"name":"AAA","points":100}],"hall_of_fame":[{"name":"LUCAS","points":4000}]},"initials":{"3":"LUC","5":"LUCAS"},"hall_total":4000,"collections":{"technology":["level_01","level_02","level_03","level_04","level_05"]}}'

## Con las dos colecciones completas.
const SAVE_FULL_COLLECTIONS: String = '{"version":1,"levels":{"level_01":{"unlocked":true,"completed":true,"best_lives":20,"best_score":900}},"collections":{"technology":["level_01","level_02","level_03","level_04","level_05"],"disruptor":["level_08","level_09","level_10"]}}'

## Del modo de pruebas: abre todo sin haber ganado nada (RF-181 / RF-183) y no tiene colecciones.
const SAVE_DEV: String = '{"version":1,"levels":{"level_05":{"unlocked":true,"completed":false,"best_lives":0,"best_score":0}},"settings":{"music_volume":0.1,"sfx_volume":0.2,"fullscreen":false,"damage_numbers":true}}'


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = PATH
	SaveManager.load_save()


func after_each() -> void:
	DevMode.set_enabled(false)
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	for path: String in [PATH, PATH_DEV, PATH_DEV.get_basename() + "_stats.json"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _write(text: String, path: String = PATH) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _index_of(level_id: StringName) -> int:
	for i: int in GameFlow.level_count():
		if GameFlow.level(i).id == level_id:
			return i
	return -1


## Un resumen comparable de todo lo que guarda el archivo, leído por la API pública.
func _snapshot() -> Dictionary:
	var levels: Dictionary = {}
	for i: int in 15:
		var id := StringName("level_%02d" % (i + 1))
		levels[String(id)] = [SaveManager.is_unlocked(id), SaveManager.is_completed(id), SaveManager.best_lives(id), SaveManager.best_score(id)]
	var scores: Dictionary = {}
	for table: String in ["level_01", "level_02", String(SaveManager.HALL_OF_FAME_ID)]:
		scores[table] = SaveManager.scores(StringName(table))
	return {"levels": levels, "scores": scores,
		"technology": SaveManager.collected_sources(&"technology"), "disruptor": SaveManager.collected_sources(&"disruptor"),
		"hall": SaveManager.hall_total(), "initials": [SaveManager.last_initials(3), SaveManager.last_initials(5)],
		"seen": [SaveManager.has_seen_enemy(&"normal"), SaveManager.has_seen_enemy(&"fast"), SaveManager.has_seen_enemy(&"boss")],
		"settings": [SaveManager.get_setting("music_volume"), SaveManager.get_setting("sfx_volume"),
			SaveManager.get_setting("fullscreen"), SaveManager.get_setting("damage_numbers"), SaveManager.range_display()],
		"tutorial": [SaveManager.tutorial_done(), SaveManager.tutorial_enabled()]}


func _assert_roundtrip_is_identical(label: String) -> void:
	var before: Dictionary = _snapshot()
	assert_true(SaveManager.save(), label)
	SaveManager.load_save()
	assert_eq(_snapshot(), before, "%s: guardar y volver a cargar no cambia nada" % label)


# --- El primer formato ---

func test_first_format_with_only_levels_and_three_settings_loads() -> void:
	_write(SAVE_T40)
	SaveManager.load_save()
	assert_eq(SaveManager.best_lives(&"level_01"), 18)
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_true(SaveManager.is_unlocked(&"level_02"))
	assert_false(SaveManager.is_completed(&"level_02"))
	assert_eq(SaveManager.best_score(&"level_01"), 0, "sin puntaje: arranca en 0")
	assert_eq(SaveManager.get_setting("music_volume"), 0.5)
	assert_eq(SaveManager.get_setting("fullscreen"), true)
	assert_eq(SaveManager.get_setting("damage_numbers"), true, "la opción que no existía toma su valor por omisión")
	assert_true(SaveManager.collected_sources(&"technology").is_empty())
	assert_eq(SaveManager.scores(&"level_01"), [])
	assert_eq(SaveManager.hall_total(), 0)
	assert_false(SaveManager.has_seen_enemy(&"normal"))
	_assert_roundtrip_is_identical("formato T40")


# --- El tutorial del nivel 1 (M63, RF-575): una clave nueva que los guardados viejos no tienen ---

func test_old_saves_that_won_level_1_do_not_get_the_tutorial_and_new_ones_do() -> void:
	for text: String in [SAVE_T40, SAVE_BEFORE_M50, SAVE_FULL_COLLECTIONS]:
		_write(text)
		SaveManager.load_save()
		assert_true(SaveManager.tutorial_done(), "quien ya ganó el nivel 1 no lo ve")
		assert_true(SaveManager.tutorial_enabled(), "la opción nueva arranca prendida")
		_assert_roundtrip_is_identical("con el tutorial")
		assert_true(bool(JSON.parse_string(FileAccess.get_file_as_string(PATH))["tutorial_done"]), "al guardar queda escrita")
	_write(SAVE_DEV)  # sin el nivel 1 ganado
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_done())
	_write('{"version":1}')
	SaveManager.load_save()
	assert_false(SaveManager.tutorial_done())
	SaveManager.save()
	assert_eq(int(JSON.parse_string(FileAccess.get_file_as_string(PATH))["version"]), 1, "la versión no cambia")


# --- Animaciones de mejora (M65, RF-593): clave aditiva dentro de `settings` ---

func test_old_saves_read_the_upgrade_animations_as_on_and_the_version_does_not_change() -> void:
	for text: String in [SAVE_T40, SAVE_BEFORE_M50, SAVE_FULL_COLLECTIONS, SAVE_DEV]:
		_write(text)
		SaveManager.load_save()
		assert_true(SaveManager.upgrade_fx_enabled(), "un guardado viejo sin la clave la lee prendida")
		assert_eq(SaveManager.get_setting("upgrade_fx"), true)
		_assert_roundtrip_is_identical("con las animaciones de mejora")
	SaveManager.set_setting("upgrade_fx", false)
	SaveManager.save()
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	assert_eq(int(saved["version"]), 1, "SAVE_VERSION no cambia")
	assert_eq(saved["settings"]["upgrade_fx"], false)
	SaveManager.load_save()
	assert_false(SaveManager.upgrade_fx_enabled(), "apagada se recuerda")


func test_a_non_boolean_upgrade_fx_value_reads_as_on() -> void:
	_write('{"version":1,"levels":{},"settings":{"upgrade_fx":0,"damage_numbers":false}}')
	SaveManager.load_save()
	assert_true(SaveManager.upgrade_fx_enabled(), "un 0 no es «apagada»")
	_write('{"version":1,"levels":{},"settings":{"upgrade_fx":"no"}}')
	SaveManager.load_save()
	assert_true(SaveManager.upgrade_fx_enabled())
# --- Novedades de esta versión (M67, RF-606): otra clave aditiva ---

func test_old_saves_have_no_news_version_and_the_key_survives_a_roundtrip() -> void:
	for text: String in [SAVE_T40, SAVE_BEFORE_M50, SAVE_FULL_COLLECTIONS, SAVE_DEV, '{"version":1}']:
		_write(text)
		SaveManager.load_save()
		assert_eq(SaveManager.news_version_seen(), "", "un guardado viejo nunca vio las novedades")
		_assert_roundtrip_is_identical("con las novedades")
		assert_eq(String(JSON.parse_string(FileAccess.get_file_as_string(PATH))["news_version"]), "", "al guardar queda escrita")
	SaveManager.mark_news_seen("1.0.0")
	SaveManager.load_save()
	assert_eq(SaveManager.news_version_seen(), "1.0.0", "marcar guarda enseguida")
	assert_eq(int(JSON.parse_string(FileAccess.get_file_as_string(PATH))["version"]), 1, "SAVE_VERSION no cambia")


func test_news_version_with_the_wrong_type_reads_as_empty() -> void:
	for bad: String in ["7", "true", "null", "[\"1.0.0\"]", "{}"]:
		_write('{"version":1,"news_version":%s}' % bad)
		SaveManager.load_save()
		assert_eq(SaveManager.news_version_seen(), "", "news_version = %s se lee como vacío" % bad)


# --- Antes de M50: niveles 1 a 9 y technology ---

func test_before_m50_save_keeps_everything() -> void:
	_write(SAVE_BEFORE_M50)
	SaveManager.load_save()
	for i: int in 9:
		var id := StringName("level_%02d" % (i + 1))
		assert_true(SaveManager.is_completed(id), "%s sigue ganado" % id)
	assert_eq(SaveManager.best_lives(&"level_05"), 10)
	assert_eq(SaveManager.best_score(&"level_09"), 200)
	assert_eq(SaveManager.collected_sources(&"technology").size(), 5)
	assert_true(SaveManager.collection_complete(&"technology"))
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty(), "la colección nueva arranca vacía")
	assert_false(SaveManager.collection_complete(&"disruptor"))
	assert_eq(SaveManager.get_setting("damage_numbers"), false)
	assert_true(SaveManager.has_seen_enemy(&"tank"))
	assert_false(SaveManager.has_seen_enemy(&"boss"))
	var table: Array = SaveManager.scores(&"level_01")
	assert_eq(table.size(), 2)
	assert_eq(table[0]["name"], "LUC")
	assert_eq(table[0]["points"], 900)
	assert_eq(SaveManager.scores(SaveManager.HALL_OF_FAME_ID)[0]["name"], "LUCAS")
	assert_eq(SaveManager.hall_total(), 4000)
	assert_eq(SaveManager.last_initials(3), "LUC")
	assert_eq(SaveManager.last_initials(5), "LUCAS")


func test_before_m50_save_opens_level_10_when_level_9_was_won() -> void:
	_write(SAVE_BEFORE_M50)
	SaveManager.load_save()
	var nine: int = _index_of(&"level_09")
	var ten: int = _index_of(&"level_10")
	assert_gt(nine, -1)
	assert_eq(ten, nine + 1)
	assert_false(SaveManager.is_unlocked(&"level_10"), "el guardado viejo no tiene el 10")
	assert_true(GameFlow.is_level_unlocked(ten), "RF-381: ganar el 9 abre el 10 aunque el guardado no lo diga")
	assert_false(GameFlow.is_level_unlocked(ten + 1), "el 11 sigue cerrado: el 10 no se ganó")
	assert_false(GameFlow.is_level_unlocked(14), "el 15 sigue cerrado")
	assert_eq(GameFlow.level_stars(nine), GameFlow.level_stars(nine), "las estrellas salen de las vidas guardadas")
	assert_false(GameFlow.is_campaign_complete())


func test_before_m50_save_survives_a_new_victory_without_losing_anything() -> void:
	_write(SAVE_BEFORE_M50)
	SaveManager.load_save()
	SaveManager.record_victory(&"level_10", 14, 1000)
	SaveManager.unlock(&"level_11")
	SaveManager.collect_source(&"disruptor", &"level_10")
	assert_true(SaveManager.save())
	SaveManager.load_save()
	assert_eq(SaveManager.best_lives(&"level_09"), 5)
	assert_true(SaveManager.is_completed(&"level_10"))
	assert_true(SaveManager.is_unlocked(&"level_11"))
	assert_eq(SaveManager.collected_sources(&"technology").size(), 5)
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_10"]))
	assert_eq(SaveManager.hall_total(), 4000)
	assert_eq(SaveManager.scores(SaveManager.HALL_OF_FAME_ID).size(), 1)
	assert_eq(int(JSON.parse_string(FileAccess.get_file_as_string(PATH))["version"]), 1, "la versión no cambia")


func test_before_m50_save_roundtrip_is_identical() -> void:
	_write(SAVE_BEFORE_M50)
	SaveManager.load_save()
	_assert_roundtrip_is_identical("antes de M50")


# --- Colecciones completas ---

func test_full_collections_save_loads_and_keeps_both_complete() -> void:
	_write(SAVE_FULL_COLLECTIONS)
	SaveManager.load_save()
	assert_true(SaveManager.collection_complete(&"technology"))
	assert_true(SaveManager.collection_complete(&"disruptor"))
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08", "level_09", "level_10"]))
	_assert_roundtrip_is_identical("colecciones completas")


func test_collection_with_a_source_that_no_longer_counts_drops_only_that_source() -> void:
	# Un guardado con una pieza de un nivel que ya no es fuente de esa colección: se ignora solo esa.
	_write('{"version":1,"collections":{"technology":["level_01","level_12","nivel_que_no_existe"],"disruptor":["level_08"]}}')
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"technology"), PackedStringArray(["level_01"]))
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08"]))


# --- Modo de pruebas ---

func test_dev_mode_save_loads_apart_and_does_not_touch_the_real_one() -> void:
	_write(SAVE_BEFORE_M50)
	_write(SAVE_DEV, PATH_DEV)
	DevMode.set_enabled(true, PATH_DEV)
	assert_eq(SaveManager.save_path, PATH_DEV)
	assert_true(SaveManager.is_unlocked(&"level_05"))
	assert_false(SaveManager.is_completed(&"level_01"), "el progreso real no se mezcla")
	assert_eq(SaveManager.get_setting("music_volume"), 0.1)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())
	assert_true(GameFlow.is_level_unlocked(14), "RF-183: en el modo de pruebas todos los niveles están abiertos")
	SaveManager.record_victory(&"level_12", 3)
	SaveManager.save()
	DevMode.set_enabled(false, PATH)
	assert_eq(SaveManager.save_path, PATH)
	assert_eq(SaveManager.best_lives(&"level_09"), 5, "al volver al guardado real, sigue intacto")
	assert_false(SaveManager.is_completed(&"level_12"))
	assert_false(GameFlow.is_level_unlocked(14))


# --- Archivos dañados: se empieza de cero, sin errores del motor ---

func test_unreadable_or_foreign_version_saves_start_from_zero() -> void:
	for text: String in ["", "{", "[1,2]", '{"version":2,"levels":{"level_01":{"completed":true}}}', '{"levels":{}}']:
		_write(text)
		SaveManager.load_save()
		assert_false(SaveManager.is_completed(&"level_01"), "«%s» empieza de cero" % text)
		assert_true(SaveManager.collected_sources(&"technology").is_empty())
		assert_eq(SaveManager.get_setting("sfx_volume"), 0.8)


func test_fields_with_the_wrong_type_are_ignored_one_by_one() -> void:
	_write('{"version":1,"levels":{"level_01":{"completed":true,"best_lives":"mucho"},"level_02":7},"settings":{"music_volume":"alto","sfx_volume":0.3},"seen_enemies":["normal",5,null],"scores":{"level_01":[{"name":"LUC","points":"x"},{"name":"AAA","points":50}]},"hall_total":"muchos","collections":["technology"]}')
	SaveManager.load_save()
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_false(SaveManager.is_unlocked(&"level_02"))
	assert_eq(SaveManager.get_setting("music_volume"), 0.7, "valor de tipo raro: queda el de omisión")
	assert_eq(SaveManager.get_setting("sfx_volume"), 0.3, "el resto de las opciones sí se conserva")
	assert_true(SaveManager.has_seen_enemy(&"normal"))
	assert_eq(SaveManager.scores(&"level_01").size(), 1)
	assert_eq(SaveManager.hall_total(), 0)
	assert_true(SaveManager.collected_sources(&"technology").is_empty())


func test_ui_prefs_are_additive_and_broken_fields_default_individually() -> void:
	_write('{"version":1,"ui_prefs":{"cart_side":"arriba","cart_y":"x","exit_side":"right","exit_y":2}}')
	SaveManager.load_save()
	var prefs: UiPrefs = SaveManager.get_ui_prefs()
	assert_eq(prefs.to_dict(), {"cart_side": "right", "cart_y": 0.45, "exit_side": "right", "exit_y": 0.1, "demolish_side": "right", "demolish_y": 0.8, "view_all_key": KEY_V})
	assert_true(SaveManager.save())
	var file := FileAccess.open(PATH, FileAccess.READ)
	var parsed := JSON.new()
	assert_eq(parsed.parse(file.get_as_text()), OK)
	assert_true(parsed.data.has("ui_prefs"), "la preferencia se agrega al guardado sin cambiar su versión")
	assert_eq(int(parsed.data["version"]), SaveManager.SAVE_VERSION)


func test_old_save_without_ui_prefs_uses_defaults() -> void:
	_write(SAVE_T40)
	SaveManager.load_save()
	assert_eq(SaveManager.get_ui_prefs().to_dict(), {"cart_side": "right", "cart_y": 0.45, "exit_side": "left", "exit_y": 0.1, "demolish_side": "right", "demolish_y": 0.8, "view_all_key": KEY_V})


func test_ui_prefs_with_wrong_top_level_type_use_defaults() -> void:
	for raw: String in ["3", "\"mal\"", "[]"]:
		_write('{"version":1,"ui_prefs":%s}' % raw)
		SaveManager.load_save()
		assert_eq(SaveManager.get_ui_prefs().to_dict(), {"cart_side": "right", "cart_y": 0.45, "exit_side": "left", "exit_y": 0.1, "demolish_side": "right", "demolish_y": 0.8, "view_all_key": KEY_V})


# --- La presentación de los jefes (M66, RF-672): una clave aditiva de los ajustes que los guardados viejos no tienen ---

func test_old_saves_read_the_boss_entrance_as_on_and_keep_their_version() -> void:
	for text: String in [SAVE_T40, SAVE_BEFORE_M50, SAVE_FULL_COLLECTIONS, SAVE_DEV]:
		_write(text)
		SaveManager.load_save()
		assert_eq(SaveManager.range_display(), 0, "un guardado viejo empieza con el alcance oculto")
		assert_true(SaveManager.boss_entrance_enabled(), "sin la clave, prendida")
		_assert_roundtrip_is_identical("con la presentación de los jefes")
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		assert_eq(int(saved["version"]), SaveManager.SAVE_VERSION, "SAVE_VERSION no cambia")
		assert_true(bool(saved["settings"]["boss_entrance"]), "al guardar queda escrita")


func test_a_saved_off_boss_entrance_survives_and_a_wrong_type_reads_as_on() -> void:
	_write('{"version":1,"settings":{"boss_entrance":false}}')
	SaveManager.load_save()
	assert_false(SaveManager.boss_entrance_enabled())
	for raw: String in ['"no"', "[]", "null", "0"]:
		_write('{"version":1,"settings":{"boss_entrance":%s}}' % raw)
		SaveManager.load_save()
		assert_true(SaveManager.boss_entrance_enabled(), "un valor %s se lee como prendida" % raw)
