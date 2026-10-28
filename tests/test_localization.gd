# Catálogo de idiomas (T533, RF-727, D-217): validación de claves, duplicados y placeholders, y que el idioma
# se guarde como preferencia sin tocar el progreso. No toca el guardado real.
extends GutTest

const TEST_SAVE: String = "user://test_localization.json"


func after_each() -> void:
	Localization.reset()
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cat(lang: String, entries: Array) -> Dictionary:
	return LocalizationCatalog.parse(JSON.stringify({"version": 1, "idioma": lang, "entradas": entries}))


func _e(key: String, text: String) -> Dictionary:
	return {"clave": key, "texto": text}


func test_shipped_catalogs_are_consistent() -> void:
	var es: Dictionary = LocalizationCatalog.load_file("res://data/i18n/es.json")
	var en: Dictionary = LocalizationCatalog.load_file("res://data/i18n/en.json")
	assert_eq(LocalizationCatalog.validate(es, en, true), [] as Array[String])
	assert_eq(es["idioma"], "es")
	assert_eq(en["idioma"], "en")
	assert_gt((es["entradas"] as Dictionary).size(), 0)


func test_missing_key_is_reported_only_when_complete_is_required() -> void:
	var es := _cat("es", [_e("a.b", "Hola"), _e("a.c", "Chau")])
	var en := _cat("en", [_e("a.b", "Hello")])
	assert_eq(LocalizationCatalog.validate(es, en, false).size(), 0)
	var problems := LocalizationCatalog.validate(es, en, true)
	assert_eq(problems.size(), 1)
	assert_true(problems[0].contains("a.c"))


func test_duplicate_keys_are_detected() -> void:
	var es := _cat("es", [_e("a.b", "Hola"), _e("a.b", "Otra vez")])
	assert_eq(es["duplicadas"], ["a.b"])
	assert_eq(es["entradas"]["a.b"], "Hola")
	var problems := LocalizationCatalog.validate(es, _cat("en", []), false)
	assert_eq(problems.size(), 1)


func test_placeholder_mismatch_is_detected() -> void:
	var es := _cat("es", [_e("a.b", "Oro: {gold} de {max}")])
	assert_eq(LocalizationCatalog.validate(es, _cat("en", [_e("a.b", "Gold: {max} of {gold}")]), true).size(), 0)
	var bad := LocalizationCatalog.validate(es, _cat("en", [_e("a.b", "Gold: {gold}")]), true)
	assert_eq(bad.size(), 1)
	assert_true(bad[0].contains("placeholders"))


func test_orphan_and_invalid_keys_and_empty_text() -> void:
	var es := _cat("es", [_e("a.b", "x"), _e("SinPunto", "y")])
	var en := _cat("en", [_e("a.b", "  "), _e("z.z", "q")])
	var problems := LocalizationCatalog.validate(es, en, false)
	var joined: String = "\n".join(problems)
	assert_true(joined.contains("formato inválido: SinPunto"))
	assert_true(joined.contains("no existe en el catálogo base: z.z"))
	assert_true(joined.contains("traducción vacía: a.b"))


func test_broken_files_report_errors_instead_of_failing() -> void:
	assert_eq(LocalizationCatalog.parse("{no es json")["errores"].size(), 1)
	assert_eq(LocalizationCatalog.parse('{"entradas": 3}')["errores"].size(), 1)
	assert_eq(LocalizationCatalog.parse('{"entradas": [{"clave": "a.b"}]}')["errores"].size(), 1)
	assert_eq(LocalizationCatalog.load_file("res://data/i18n/nope.json")["errores"].size(), 1)


func test_placeholders_are_unique_and_sorted() -> void:
	assert_eq(LocalizationCatalog.placeholders("{b} y {a} y {b} y {}"), ["a", "b"] as Array[String])
	assert_eq(LocalizationCatalog.placeholders("sin marcadores"), [] as Array[String])


func test_lookup_falls_back_to_spanish_then_to_the_key() -> void:
	assert_eq(Localization.language, &"es")
	assert_eq(Localization.t(&"options.language.label"), "Idioma")
	Localization.set_language("en")
	assert_eq(Localization.t(&"options.language.label"), "Language")
	assert_eq(Localization.t(&"no.existe"), "no.existe")
	assert_eq(Localization.t_fmt(&"common.stars.other", {"n": 3}), "3 stars")
	assert_eq(Localization.t_plural(&"common.stars", 1), "1 star")
	assert_eq(Localization.t_plural(&"common.stars", 0), "0 stars")
	Localization.set_language("es")
	assert_eq(Localization.t_plural(&"common.stars", 2), "2 estrellas")


func test_invalid_language_values_mean_spanish() -> void:
	for bad: Variant in [null, "", "fr", 3, "EN", []]:
		assert_eq(Localization.normalize(bad), &"es", str(bad))
	assert_eq(Localization.normalize("en"), &"en")
	assert_eq(Localization.normalize(&"en"), &"en")


func test_selector_stays_hidden_until_the_english_is_complete() -> void:
	assert_false(Localization.SELECTOR_ENABLED)
	var options: Node = preload("res://scenes/ui/options_menu.tscn").instantiate()
	add_child_autofree(options)
	assert_null(options.find_child("LanguageOption", true, false))


func test_language_is_a_setting_that_does_not_change_the_save_version_or_progress() -> void:
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	assert_eq(SaveManager.language(), &"es")
	SaveManager.set_setting("language", "en")
	assert_eq(SaveManager.language(), &"en")
	assert_true(SaveManager.save())
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	assert_eq(int(data["version"]), 1)
	assert_eq(data["settings"]["language"], "en")
	SaveManager.load_save()
	assert_eq(SaveManager.language(), &"en")


func test_old_or_damaged_saves_keep_spanish() -> void:
	SaveManager.save_path = TEST_SAVE
	for raw: String in ['{"version":1,"levels":{},"settings":{"music_volume":0.7}}',
			'{"version":1,"levels":{},"settings":{"language":"fr"}}',
			'{"version":1,"levels":{},"settings":{"language":7}}']:
		var f := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
		f.store_string(raw)
		f.close()
		SaveManager.load_save()
		assert_eq(SaveManager.language(), &"es", raw)
