extends GutTest
## T442 (RF-662, RF-664, D-186): catálogo, receta validada y persistencia aislada del banderín.

const TEST_PATH: String = "user://test_banner.json"


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _write(text: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func before_each() -> void:
	_remove(TEST_PATH)
	_remove(TEST_PATH + ".tmp")


func after_each() -> void:
	_remove(TEST_PATH)
	_remove(TEST_PATH + ".tmp")


func test_catalog_is_small_and_defaults_belong_to_it() -> void:
	assert_true(BannerCatalog.has_palette(BannerCatalog.DEFAULT_PALETTE))
	assert_true(BannerCatalog.has_emblem(BannerCatalog.DEFAULT_EMBLEM))
	assert_between(BannerCatalog.palette_ids().size(), 2, 8)
	assert_between(BannerCatalog.emblem_ids().size(), 2, 8)
	var all_ids: Array[String] = BannerCatalog.palette_ids() + BannerCatalog.emblem_ids()
	for id in all_ids:
		assert_eq(id, id.to_lower(), "id estable en minúsculas: %s" % id)
		assert_false(id.contains(" "), "id sin espacios: %s" % id)


func test_catalog_rejects_unknown_and_non_string_ids() -> void:
	assert_false(BannerCatalog.has_palette("nope"))
	assert_false(BannerCatalog.has_palette(""))
	assert_false(BannerCatalog.has_palette(null))
	assert_false(BannerCatalog.has_emblem(3))
	assert_false(BannerCatalog.has_emblem("Chevron"), "distingue mayúsculas")
	assert_eq(BannerCatalog.palette_label("nope"), "")
	assert_ne(BannerCatalog.emblem_label(BannerCatalog.DEFAULT_EMBLEM), "")


func test_default_recipe_is_valid_and_default() -> void:
	var recipe := BannerRecipe.default_recipe()
	assert_true(recipe.is_valid())
	assert_true(recipe.is_default())
	assert_eq(recipe.palette, BannerCatalog.DEFAULT_PALETTE)
	assert_eq(recipe.emblem, BannerCatalog.DEFAULT_EMBLEM)


func test_make_falls_back_on_unknown_ids() -> void:
	var ok := BannerRecipe.make("brasa", "rombo")
	assert_eq(ok.palette, "brasa")
	assert_eq(ok.emblem, "rombo")
	assert_false(ok.is_default())
	assert_true(BannerRecipe.make("brasa", "nope").is_default(), "un id malo descarta toda la receta")
	assert_true(BannerRecipe.make("nope", "rombo").is_default())


func test_every_catalog_combination_roundtrips_through_dict() -> void:
	for p in BannerCatalog.palette_ids():
		for e in BannerCatalog.emblem_ids():
			var recipe := BannerRecipe.make(p, e)
			assert_true(BannerRecipe.from_dict(recipe.to_dict()).equals(recipe), "%s/%s" % [p, e])


func test_from_dict_rejects_bad_shapes_version_and_ids() -> void:
	var good: Dictionary = {"version": 1, "palette": "brasa", "emblem": "rombo"}
	assert_eq(BannerRecipe.from_dict(good).palette, "brasa")
	assert_eq(BannerRecipe.from_dict({"version": 1.0, "palette": "brasa", "emblem": "rombo"}).emblem, "rombo", "1.0 de JSON vale 1")
	var bad_cases: Array = [
		null, "texto", [], 7,
		{},
		{"palette": "brasa", "emblem": "rombo"},
		{"version": 2, "palette": "brasa", "emblem": "rombo"},
		{"version": 0, "palette": "brasa", "emblem": "rombo"},
		{"version": 1.5, "palette": "brasa", "emblem": "rombo"},
		{"version": "1", "palette": "brasa", "emblem": "rombo"},
		{"version": 1, "palette": "nope", "emblem": "rombo"},
		{"version": 1, "palette": "brasa", "emblem": "nope"},
		{"version": 1, "palette": 5, "emblem": "rombo"},
		{"version": 1, "palette": "brasa"},
		{"version": 1, "emblem": "rombo"},
	]
	for raw in bad_cases:
		assert_true(BannerRecipe.from_dict(raw).is_default(), "debe dar el predeterminado: %s" % str(raw))


func test_load_missing_file_gives_default() -> void:
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default())
	assert_false(FileAccess.file_exists(TEST_PATH), "cargar no crea el archivo")


func test_save_and_load_roundtrip() -> void:
	var recipe := BannerRecipe.make("marea", "estrella")
	assert_true(BannerRecipeStore.save_recipe(recipe, TEST_PATH))
	assert_false(FileAccess.file_exists(TEST_PATH + ".tmp"), "no queda el temporal")
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).equals(recipe))
	var other := BannerRecipe.make("musgo", "franja")
	assert_true(BannerRecipeStore.save_recipe(other, TEST_PATH))
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).equals(other), "pisa la receta anterior")


func test_save_rejects_invalid_recipe_and_keeps_previous_file() -> void:
	var good := BannerRecipe.make("brasa", "rombo")
	assert_true(BannerRecipeStore.save_recipe(good, TEST_PATH))
	var broken := BannerRecipe.new()
	broken.palette = "nope"
	assert_false(BannerRecipeStore.save_recipe(broken, TEST_PATH))
	assert_false(BannerRecipeStore.save_recipe(null, TEST_PATH))
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).equals(good))


func test_save_to_unwritable_path_returns_false() -> void:
	assert_false(BannerRecipeStore.save_recipe(BannerRecipe.default_recipe(), "user://test_no_such_dir/banner.json"))


func test_corrupt_files_give_default() -> void:
	var corrupt: Array[String] = ["", "no es json", "{", "{\"version\": 1, \"palette\": ", "[1, 2]", "null", "\"brasa\""]
	for text in corrupt:
		_write(text)
		assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default(), "texto: %s" % text)


func test_unsupported_version_and_unknown_ids_in_file_give_default() -> void:
	_write(JSON.stringify({"version": 99, "palette": "brasa", "emblem": "rombo"}))
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default())
	_write(JSON.stringify({"version": 1, "palette": "brasa", "emblem": "dragon"}))
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default())


func test_default_path_is_dedicated_and_real_save_untouched() -> void:
	assert_eq(BannerRecipeStore.DEFAULT_PATH, "user://banner.json")
	assert_ne(BannerRecipeStore.DEFAULT_PATH, SaveManager.save_path)
	var before: bool = FileAccess.file_exists(SaveManager.save_path)
	BannerRecipeStore.save_recipe(BannerRecipe.make("brasa", "rombo"), TEST_PATH)
	assert_eq(FileAccess.file_exists(SaveManager.save_path), before, "el guardado real no se toca")
