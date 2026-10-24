extends GutTest

const SOURCE_PATH: String = "user://test_save_backup_source.json"
const PREFIX: String = "user://test_save_backup_copy_"
const TEST_SAVE_PATH: String = "user://test_save_backup_other.json"
const TEST_DEV_SAVE_PATH: String = "user://test_save_backup_dev_mode.json"

var _original_version: Variant


func before_each() -> void:
	_original_version = ProjectSettings.get_setting("application/config/version", "")
	_save_manager_to_test_paths()
	_cleanup()


func after_each() -> void:
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.backup_save_path = SaveManager.DEFAULT_PATH
	SaveManager.backup_prefix = SaveManager.BACKUP_PREFIX
	SaveManager._backup_checked = false
	ProjectSettings.set_setting("application/config/version", _original_version)
	SaveManager.load_save()


func _save_manager_to_test_paths() -> void:
	SaveManager.save_path = SOURCE_PATH
	SaveManager.backup_save_path = SOURCE_PATH
	SaveManager.backup_prefix = PREFIX
	SaveManager._backup_checked = false
	SaveManager.load_save()


func _backup_path(version: String = "") -> String:
	# Sin argumento, la versión instalada del proyecto (hoy «beta»; el respaldo se nombra con ella).
	if version.is_empty():
		version = str(_original_version)
	return "%s%s.json" % [PREFIX, version]


func _write(path: String, bytes: PackedByteArray) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "se pudo crear %s" % path)
	if file == null:
		return
	file.store_buffer(bytes)
	file.close()


func _write_text(path: String, value: String) -> void:
	_write(path, value.to_utf8_buffer())


func _read(path: String) -> PackedByteArray:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return PackedByteArray()
	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	return bytes


func _cleanup() -> void:
	for path: String in [SOURCE_PATH, TEST_SAVE_PATH, TEST_DEV_SAVE_PATH, _backup_path(), _backup_path() + ".tmp", _backup_path("1.0___beta"), _backup_path("sin-version"), _backup_path("viejo"), _backup_path("temporal")]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var directory := DirAccess.open("user://")
	if directory != null:
		directory.list_dir_begin()
		var entry: String = directory.get_next()
		while not entry.is_empty():
			if entry.begins_with("test_save_backup_limit_"):
				DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + entry))
			entry = directory.get_next()
		directory.list_dir_end()
	var blocked_path: String = _backup_path("bloqueado")
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(blocked_path)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(blocked_path))


func test_first_save_copies_exact_bytes_then_writes_new_save() -> void:
	var original: PackedByteArray = '{"version":1,"levels":{"level_01":{"completed":true}}}'.to_utf8_buffer()
	_write(SOURCE_PATH, original)
	SaveManager.record_victory(&"level_02", 12)
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path()), original, "el respaldo conserva exactamente los bytes anteriores")
	assert_ne(_read(SOURCE_PATH), original, "save() escribe el contenido actualizado")


func test_existing_backup_is_never_changed_even_after_new_execution() -> void:
	var previous_backup: PackedByteArray = "respaldo original".to_utf8_buffer()
	_write(_backup_path(), previous_backup)
	_write_text(SOURCE_PATH, "archivo actual")
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path()), previous_backup)
	assert_ne(_read(SOURCE_PATH), "archivo actual".to_utf8_buffer())


func test_backup_is_checked_only_once_per_execution() -> void:
	_write_text(SOURCE_PATH, "primer original")
	assert_true(SaveManager.save())
	var first_backup: PackedByteArray = _read(_backup_path())
	_write_text(SOURCE_PATH, "segundo contenido")
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path()), first_backup)
	assert_ne(_read(SOURCE_PATH), "segundo contenido".to_utf8_buffer())


func test_missing_or_empty_save_does_not_create_backup() -> void:
	assert_true(SaveManager.save(), "sin save.json, la escritura sigue")
	assert_false(FileAccess.file_exists(_backup_path()))
	_save_manager_to_test_paths()
	_write(SOURCE_PATH, PackedByteArray())
	assert_true(SaveManager.save(), "un archivo vacío no bloquea la escritura")
	assert_false(FileAccess.file_exists(_backup_path()))


func test_damaged_save_is_copied_byte_for_byte() -> void:
	var damaged: PackedByteArray = '{"version":2, cortado'.to_utf8_buffer()
	_write(SOURCE_PATH, damaged)
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path()), damaged)
	assert_ne(_read(SOURCE_PATH), damaged)


func test_failed_copy_warns_and_save_still_writes() -> void:
	_write_text(SOURCE_PATH, "original")
	var blocked_path: String = _backup_path("bloqueado")
	ProjectSettings.set_setting("application/config/version", "bloqueado")
	assert_eq(DirAccess.make_dir_absolute(ProjectSettings.globalize_path(blocked_path)), OK)
	SaveManager._backup_checked = false
	assert_true(SaveManager.save())
	assert_push_warning("No se pudo completar el respaldo")
	assert_ne(_read(SOURCE_PATH), "original".to_utf8_buffer())
	assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(blocked_path)))


func test_old_temporary_file_is_replaced_with_complete_backup() -> void:
	var original: PackedByteArray = "bytes completos".to_utf8_buffer()
	_write(SOURCE_PATH, original)
	_write_text(_backup_path() + ".tmp", "temporal viejo")
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path()), original)
	assert_false(FileAccess.file_exists(_backup_path() + ".tmp"))


func test_rename_replaces_an_existing_destination_in_this_godot_version() -> void:
	var temporary_path: String = _backup_path("temporal") + ".tmp"
	var destination_path: String = _backup_path("temporal")
	_write_text(temporary_path, "temporal")
	_write_text(destination_path, "destino anterior")
	var result: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(destination_path))
	assert_eq(result, OK, "DirAccess.rename_absolute en Godot 4.7.2/Linux reemplaza el destino")
	assert_eq(_read(destination_path), "temporal".to_utf8_buffer(), "el respaldo debe comprobarse antes del renombrado")


func test_test_save_path_does_not_create_any_real_backups() -> void:
	SaveManager.backup_prefix = SaveManager.BACKUP_PREFIX
	var default_backup_count: int = SaveManager._backup_count()
	var real_save_before: PackedByteArray = _read(SaveManager.DEFAULT_PATH)
	SaveManager.save_path = TEST_SAVE_PATH
	SaveManager.backup_save_path = SaveManager.DEFAULT_PATH
	SaveManager._backup_checked = false
	assert_true(SaveManager.save())
	assert_true(FileAccess.file_exists(TEST_SAVE_PATH))
	assert_eq(SaveManager._backup_count(), default_backup_count, "no aparece un save_respaldo_*.json")
	assert_eq(_read(SaveManager.DEFAULT_PATH), real_save_before, "save.json real no se toca")


func test_test_prefix_limit_does_not_create_an_eleventh_backup() -> void:
	SaveManager.backup_prefix = "user://test_save_backup_limit_"
	for index: int in 10:
		_write_text("user://test_save_backup_limit_%02d.json" % index, "viejo %d" % index)
	_write_text(SOURCE_PATH, "original")
	assert_true(SaveManager.save())
	assert_push_warning("ya hay 10 respaldos")
	assert_false(FileAccess.file_exists("user://test_save_backup_limit_%s.json" % str(_original_version)))
	for index: int in 10:
		assert_eq(_read("user://test_save_backup_limit_%02d.json" % index), ("viejo %d" % index).to_utf8_buffer())


func test_version_characters_are_sanitized_and_empty_version_has_fallback() -> void:
	_write_text(SOURCE_PATH, "original")
	ProjectSettings.set_setting("application/config/version", "1.0 / beta")
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path("1.0___beta")), "original".to_utf8_buffer())
	_save_manager_to_test_paths()
	_write_text(SOURCE_PATH, "otro original")
	ProjectSettings.set_setting("application/config/version", "")
	assert_true(SaveManager.save())
	assert_eq(_read(_backup_path("sin-version")), "otro original".to_utf8_buffer())


func test_testing_mode_save_path_never_touches_real_or_testing_backup() -> void:
	_write_text(SOURCE_PATH, "real save")
	var real_before: PackedByteArray = _read(SOURCE_PATH)
	SaveManager.save_path = TEST_DEV_SAVE_PATH
	SaveManager._backup_checked = false
	assert_true(SaveManager.save())
	assert_eq(_read(SOURCE_PATH), real_before)
	assert_false(FileAccess.file_exists(_backup_path()))
	assert_false(FileAccess.file_exists(_backup_path() + ".tmp"))


func test_successful_backup_is_silent() -> void:
	_write_text(SOURCE_PATH, "original")
	assert_true(SaveManager.save())
	assert_push_warning_count(0)
