# Tests del modo de pruebas (T86, spec §10.2, D-028).
extends GutTest

const NORMAL_PATH: String = "user://test_save.json"
## Los tests usan su propio archivo de pruebas, nunca el save_pruebas.json de verdad.
const DEV_PATH: String = "user://test_save_pruebas.json"


func _remove_files() -> void:
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func before_each() -> void:
	_remove_files()
	DevMode.set_enabled(false, NORMAL_PATH)


func after_each() -> void:
	DevMode.set_enabled(false, NORMAL_PATH)
	_remove_files()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func test_tests_and_normal_builds_run_without_dev_mode() -> void:
	assert_false(DevMode.detect(), "RF-385: sin el argumento --pruebas, el juego arranca normal")
	assert_false(DevMode.enabled)
	assert_false(DevMode.is_banner_visible())


func test_without_dev_mode_levels_stay_locked() -> void:
	assert_true(GameFlow.is_level_unlocked(0))
	assert_false(GameFlow.is_level_unlocked(GameFlow.level_count() - 1), "RF-112")


func test_dev_mode_opens_every_level() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	for i: int in GameFlow.level_count():
		assert_true(GameFlow.is_level_unlocked(i), "RF-183: nivel %d" % (i + 1))


func test_dev_mode_shows_its_banner() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	assert_true(DevMode.is_banner_visible(), "RF-182")
	DevMode.set_enabled(false, NORMAL_PATH)
	assert_false(DevMode.is_banner_visible())


func test_dev_mode_uses_its_own_save() -> void:
	# Progreso "real": el nivel 1 ganado.
	SaveManager.record_victory(&"level_01", 20)
	SaveManager.save()
	DevMode.set_enabled(true, DEV_PATH)
	assert_eq(SaveManager.save_path, DEV_PATH)
	assert_false(SaveManager.is_completed(&"level_01"), "RF-181: el guardado de pruebas es otro")
	SaveManager.record_victory(&"level_03", 5)
	SaveManager.save()
	DevMode.set_enabled(false, NORMAL_PATH)
	assert_true(SaveManager.is_completed(&"level_01"), "el progreso real sigue ahí")
	assert_false(SaveManager.is_completed(&"level_03"), "lo que se hizo en pruebas no pasó al real")


func test_one_export_per_platform_and_none_is_a_test_build() -> void:
	# RF-386 (D-077): el modo de pruebas se activa desde Opciones; no hay ejecutables ni APK aparte.
	var presets := ConfigFile.new()
	assert_eq(presets.load("res://export_presets.cfg"), OK)
	var names: PackedStringArray = []
	var i: int = 0
	while presets.has_section("preset.%d" % i):
		var section: String = "preset.%d" % i
		var preset_name: String = presets.get_value(section, "name")
		names.append(preset_name)
		assert_eq(presets.get_value(section, "custom_features", ""), "", "%s no trae ninguna característica especial" % preset_name)
		i += 1
	assert_eq(names, PackedStringArray(["Windows Desktop", "Android", "Linux"]))
