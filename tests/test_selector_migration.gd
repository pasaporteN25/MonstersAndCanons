# Tests de la migración del estilo del selector (M76, T470, RF-687, RF-689, D-198): `settings.selector_map_migrated`,
# una vez por archivo (normal y de pruebas), aditiva, sin subir SAVE_VERSION y sin copiar datos entre archivos.
# Solo usan archivos `user://test_*.json`; nunca tocan el guardado real.
extends GutTest

const FILE_A: String = "user://test_selector_migration_a.json"
const FILE_B: String = "user://test_selector_migration_b.json"
const BAD_DIR: String = "user://test_selector_migration_dir"

var _original_path: String


func before_each() -> void:
	_original_path = SaveManager.save_path
	_clean()


func after_each() -> void:
	_clean()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _clean() -> void:
	for path: String in [FILE_A, FILE_B]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if DirAccess.dir_exists_absolute(BAD_DIR):
		DirAccess.remove_absolute(BAD_DIR)


func _write(path: String, settings: Variant, extra: Dictionary = {}) -> void:
	var data: Dictionary = {"version": SaveManager.SAVE_VERSION, "levels": {"level_01": {"unlocked": true, "completed": true, "best_lives": 7}}}
	if settings != null:
		data["settings"] = settings
	data.merge(extra, true)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func _read(path: String) -> Dictionary:
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(path))
	return json.data


func _load(path: String) -> void:
	SaveManager.save_path = path
	SaveManager.load_save()


# --- Qué estilo queda al cargar ---

func test_new_save_without_file_starts_in_map_and_migration_is_pending() -> void:
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_false(SaveManager.selector_map_migrated())
	assert_false(FileAccess.file_exists(FILE_A), "cargar no escribe")


func test_old_save_with_cards_and_no_mark_passes_to_map() -> void:
	_write(FILE_A, {"selector_style": 0, "music_volume": 0.3})
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "aunque hubiera elegido tarjetas")
	assert_false(SaveManager.selector_map_migrated())
	assert_almost_eq(float(SaveManager.get_setting("music_volume")), 0.3, 0.001, "otras preferencias intactas")


func test_old_save_without_settings_section_passes_to_map() -> void:
	_write(FILE_A, null)
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)


func test_settings_that_is_not_a_dictionary_passes_to_map() -> void:
	_write(FILE_A, [1, 2, 3])
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_false(SaveManager.selector_map_migrated())


func test_corrupt_and_foreign_version_files_start_in_map() -> void:
	var file := FileAccess.open(FILE_A, FileAccess.WRITE)
	file.store_string("{ esto no es json")
	file.close()
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_false(SaveManager.selector_map_migrated())
	_write(FILE_B, {"selector_style": 0, "selector_map_migrated": true}, {"version": 99})
	_load(FILE_B)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "otra versión: se empieza de cero")


func test_false_or_invalid_mark_means_pending_migration() -> void:
	for mark: Variant in [false, 1, 0, "true", null, [true], 1.0]:
		_write(FILE_A, {"selector_style": 0, "selector_map_migrated": mark})
		_load(FILE_A)
		assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "marca %s" % [mark])
		assert_false(SaveManager.selector_map_migrated(), "marca %s" % [mark])


func test_true_mark_respects_a_valid_style() -> void:
	_write(FILE_A, {"selector_style": 0, "selector_map_migrated": true})
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS)
	assert_true(SaveManager.selector_map_migrated())
	_write(FILE_A, {"selector_style": 1.0, "selector_map_migrated": true})
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)


func test_true_mark_with_missing_or_damaged_style_uses_map() -> void:
	_write(FILE_A, {"selector_map_migrated": true})
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "ausente")
	for style: Variant in [7, -1, 0.5, "tarjetas", true, null, [0]]:
		_write(FILE_A, {"selector_style": style, "selector_map_migrated": true})
		_load(FILE_A)
		assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "estilo dañado %s" % [style])
		assert_true(SaveManager.selector_map_migrated())


# --- Qué queda escrito ---

func test_first_successful_save_records_the_mark_and_keeps_everything_else() -> void:
	_write(FILE_A, {"selector_style": 0, "music_volume": 0.3}, {"hall_total": 1234})
	_load(FILE_A)
	assert_true(SaveManager.save())
	var saved: Dictionary = _read(FILE_A)
	assert_eq(int(saved["version"]), 1, "no sube SAVE_VERSION")
	assert_eq(SaveManager.SAVE_VERSION, 1)
	assert_true(saved["settings"]["selector_map_migrated"] is bool and saved["settings"]["selector_map_migrated"])
	assert_eq(int(saved["settings"]["selector_style"]), CampaignMap.STYLE_MAP)
	assert_almost_eq(float(saved["settings"]["music_volume"]), 0.3, 0.001)
	assert_eq(int(saved["hall_total"]), 1234, "no borra progreso ajeno")
	assert_true(bool(saved["levels"]["level_01"]["completed"]))
	assert_eq(int(saved["levels"]["level_01"]["best_lives"]), 7)
	_load(FILE_A)
	assert_true(SaveManager.selector_map_migrated())
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)


func test_choosing_cards_after_migration_persists_across_restarts() -> void:
	_write(FILE_A, {"selector_style": 0})
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	SaveManager.set_setting("selector_style", CampaignMap.STYLE_CARDS)
	assert_true(SaveManager.save())
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS, "la elección posterior se respeta")
	assert_true(SaveManager.selector_map_migrated())
	assert_true(SaveManager.save())
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS, "guardar de nuevo no vuelve a migrar")


func test_loading_without_saving_does_not_mark_the_file() -> void:
	_write(FILE_A, {"selector_style": 0})
	_load(FILE_A)
	_load(FILE_A)
	assert_false(_read(FILE_A)["settings"].has("selector_map_migrated"))
	assert_eq(int(_read(FILE_A)["settings"]["selector_style"]), 0, "el archivo viejo no cambia hasta el próximo guardado")


# --- Un archivo por vez ---

func test_each_file_migrates_on_its_own_without_copying_values() -> void:
	_write(FILE_A, {"selector_style": 0, "music_volume": 0.1})  # sin migrar
	_write(FILE_B, {"selector_style": 0, "selector_map_migrated": true, "music_volume": 0.9})  # ya migrado y con tarjetas
	var b_before: String = FileAccess.get_file_as_string(FILE_B)
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	assert_true(SaveManager.save())
	assert_eq(FileAccess.get_file_as_string(FILE_B), b_before, "guardar A no toca B")
	_load(FILE_B)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS, "B conserva su elección")
	assert_almost_eq(float(SaveManager.get_setting("music_volume")), 0.9, 0.001)
	var a_before: String = FileAccess.get_file_as_string(FILE_A)
	assert_true(SaveManager.save())
	assert_eq(FileAccess.get_file_as_string(FILE_A), a_before, "guardar B no toca A")
	assert_almost_eq(float(_read(FILE_A)["settings"]["music_volume"]), 0.1, 0.001)


func test_switching_save_file_resets_the_pending_state() -> void:
	_write(FILE_A, {"selector_style": 0, "selector_map_migrated": true})
	_write(FILE_B, {"selector_style": 0})
	_load(FILE_A)
	assert_true(SaveManager.selector_map_migrated())
	_load(FILE_B)
	assert_false(SaveManager.selector_map_migrated(), "la marca no viaja de un archivo al otro")
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP)
	_load(FILE_A)
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_CARDS)


# --- Fallo de escritura ---

func test_failed_write_keeps_the_migration_pending_and_the_old_file_intact() -> void:
	_write(FILE_A, {"selector_style": 0, "music_volume": 0.3})
	var before: String = FileAccess.get_file_as_string(FILE_A)
	_load(FILE_A)
	DirAccess.make_dir_absolute(BAD_DIR)
	SaveManager.save_path = BAD_DIR  # abrir un directorio para escribir falla
	assert_false(SaveManager.save(), "no informa persistencia lograda")
	assert_false(SaveManager.selector_map_migrated(), "sin escritura no hay marca")
	assert_eq(SaveManager.selector_style(), CampaignMap.STYLE_MAP, "en memoria sigue en mapa")
	assert_eq(FileAccess.get_file_as_string(FILE_A), before, "el guardado anterior queda como estaba")
	SaveManager.save_path = FILE_A
	assert_true(SaveManager.save(), "el próximo guardado exitoso sí registra la migración")
	assert_true(SaveManager.selector_map_migrated())
	assert_true(bool(_read(FILE_A)["settings"]["selector_map_migrated"]))
