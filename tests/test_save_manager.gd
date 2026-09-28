# Tests del guardado (T40, RF-115, plan §7.1).
# Usan un archivo aparte para no tocar el progreso real del jugador.
extends GutTest

const TEST_PATH: String = "user://test_save.json"


func before_each() -> void:
	_delete_test_file()
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()


func after_each() -> void:
	_delete_test_file()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()  # vuelve a dejar cargado el progreso real


func _delete_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)


func _write_test_file(text: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


# --- Sin archivo ---

func test_starts_empty_without_a_file() -> void:
	assert_false(SaveManager.is_completed(&"level_01"))
	assert_false(SaveManager.is_unlocked(&"level_02"))
	assert_eq(SaveManager.best_lives(&"level_01"), 0)
	assert_eq(SaveManager.get_setting("fullscreen"), false)


# --- Guardar y volver a cargar (criterio de aceptación RF-115) ---

func test_progress_survives_closing_the_game() -> void:
	SaveManager.record_victory(&"level_01", 17)
	SaveManager.unlock(&"level_02")
	assert_true(SaveManager.save())
	SaveManager.load_save()  # como si se cerrara y volviera a abrir
	assert_true(SaveManager.is_completed(&"level_01"))
	assert_eq(SaveManager.best_lives(&"level_01"), 17)
	assert_true(SaveManager.is_unlocked(&"level_02"), "criterio de aceptación RF-115")


func test_best_lives_keeps_the_best() -> void:
	SaveManager.record_victory(&"level_01", 17)
	SaveManager.record_victory(&"level_01", 9)
	assert_eq(SaveManager.best_lives(&"level_01"), 17)
	SaveManager.record_victory(&"level_01", 20)
	assert_eq(SaveManager.best_lives(&"level_01"), 20)


func test_settings_survive_closing_the_game() -> void:
	SaveManager.set_setting("music_volume", 0.25)
	SaveManager.set_setting("fullscreen", true)
	SaveManager.save()
	SaveManager.load_save()
	assert_almost_eq(float(SaveManager.get_setting("music_volume")), 0.25, 0.001)
	assert_eq(SaveManager.get_setting("fullscreen"), true)


func test_file_has_the_documented_format() -> void:
	SaveManager.record_victory(&"level_01", 17)
	SaveManager.save()
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	assert_eq(int(parsed["version"]), 1, "plan §7.1")
	assert_true(parsed["levels"]["level_01"]["completed"])
	assert_true(parsed.has("settings"))


# --- Archivos problemáticos: nunca rompen el juego ---

func test_corrupt_file_starts_from_zero() -> void:
	_write_test_file("{ esto no es json")
	SaveManager.load_save()
	assert_false(SaveManager.is_completed(&"level_01"))


func test_other_version_starts_from_zero() -> void:
	_write_test_file('{"version": 99, "levels": {"level_01": {"completed": true}}}')
	SaveManager.load_save()
	assert_false(SaveManager.is_completed(&"level_01"))


func test_weird_values_are_ignored() -> void:
	_write_test_file('{"version": 1, "levels": {"level_01": "hola"}, "settings": {"fullscreen": "sí"}}')
	SaveManager.load_save()
	assert_false(SaveManager.is_completed(&"level_01"))
	assert_eq(SaveManager.get_setting("fullscreen"), false, "se queda el valor por defecto")
