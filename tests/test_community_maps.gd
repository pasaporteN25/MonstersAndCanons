# Tests de los mapas de la comunidad y de los límites (T106, spec §10.4: RF-220, RF-222, RF-223).
# Usan una carpeta de pruebas: nunca la user://maps/ de verdad.
extends GutTest

const TEST_DIR: String = "user://test_community/"


func before_each() -> void:
	_clean()


func after_each() -> void:
	_clean()


func _clean() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		for folder: String in DirAccess.get_directories_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + folder)
		DirAccess.remove_absolute(TEST_DIR)


func _write(file_name: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file := FileAccess.open(TEST_DIR + file_name, FileAccess.WRITE)
	file.store_string(text)
	file.close()


## Un mapa válido, hecho con el borrador del editor.
func _good_map(level_name: String = "Un mapa") -> String:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.set_level_name(level_name)
	return draft.to_text()


func _entry(entries: Array[Dictionary], file_id: String) -> Dictionary:
	for entry: Dictionary in entries:
		if entry["file"] == file_id:
			return entry
	fail_test("no hay una entrada '%s'" % file_id)
	return {}


# --- Leer la carpeta (RF-220) ---

func test_a_missing_folder_has_no_maps_and_no_errors() -> void:
	assert_eq(CommunityMaps.scan(TEST_DIR), [] as Array[Dictionary])


func test_an_empty_folder_has_no_maps() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	assert_eq(CommunityMaps.scan(TEST_DIR).size(), 0)


func test_a_valid_map_is_listed_with_its_level() -> void:
	_write("mi_mapa.json", _good_map("Mi mapa"))
	var entries: Array[Dictionary] = CommunityMaps.scan(TEST_DIR)
	assert_eq(entries.size(), 1)
	var entry: Dictionary = entries[0]
	assert_eq(entry["file"], "mi_mapa")
	assert_eq(entry["id"], &"comunidad_mi_mapa", "RF-224: el id lleva el prefijo")
	assert_eq(entry["errors"], PackedStringArray())
	var level: LevelData = entry["level"]
	assert_eq(level.display_name, "Mi mapa")
	assert_eq(level.id, &"comunidad_mi_mapa", "el nivel también, así el progreso queda aparte")


func test_maps_come_in_alphabetical_order() -> void:
	for id: String in ["zeta", "alfa", "mitad_1", "beta"]:
		_write(id + ".json", _good_map(id))
	var order: PackedStringArray = []
	for entry: Dictionary in CommunityMaps.scan(TEST_DIR):
		order.append(entry["file"])
	assert_eq(order, PackedStringArray(["alfa", "beta", "mitad_1", "zeta"]))


func test_only_json_files_count() -> void:
	_write("mapa.json", _good_map())
	_write("notas.txt", "no soy un mapa")
	_write("mapa.json.bak", _good_map())
	DirAccess.make_dir_recursive_absolute(TEST_DIR + "una_carpeta.json")
	assert_eq(CommunityMaps.scan(TEST_DIR).size(), 1)


func test_the_id_never_clashes_with_official_levels_or_the_hall() -> void:
	assert_eq(CommunityMaps.id_for("level_03"), &"comunidad_level_03")
	assert_ne(CommunityMaps.id_for("level_03"), &"level_03")
	assert_ne(CommunityMaps.id_for("hall_of_fame"), SaveManager.HALL_OF_FAME_ID)
	_write("level_03.json", _good_map())
	assert_eq(CommunityMaps.scan(TEST_DIR)[0]["level"].id, &"comunidad_level_03")


# --- Archivos con problemas (RF-222) ---

func test_a_broken_map_is_an_entry_with_its_reason() -> void:
	_write("roto.json", _good_map().replace("\"normal\"", "\"trol\""))
	var entry: Dictionary = CommunityMaps.scan(TEST_DIR)[0]
	assert_null(entry["level"])
	assert_true(" | ".join(entry["errors"]).contains("no existe el enemigo 'trol'"), str(entry["errors"]))


func test_a_broken_map_does_not_hide_the_good_ones() -> void:
	_write("a_bien.json", _good_map("Bien"))
	_write("b_roto.json", "esto no es json")
	_write("c_bien.json", _good_map("Otro bien"))
	var entries: Array[Dictionary] = CommunityMaps.scan(TEST_DIR)
	assert_eq(entries.size(), 3)
	assert_eq(CommunityMaps.playable(entries).size(), 2, "los dos buenos se juegan")
	assert_null(_entry(entries, "b_roto")["level"])
	assert_true((_entry(entries, "b_roto")["errors"] as PackedStringArray)[0].contains("no es un JSON válido"))


func test_an_invalid_file_name_is_refused_with_the_reason() -> void:
	_write("Mi Mapa.json", _good_map())
	_write("un.punto.json", _good_map())
	for entry: Dictionary in CommunityMaps.scan(TEST_DIR):
		assert_null(entry["level"], entry["file"])
		assert_true((entry["errors"] as PackedStringArray)[0].contains("Nombre de archivo no válido"), entry["file"])


func test_a_file_that_is_too_big_is_refused_without_reading_it() -> void:
	_write("enorme.json", "x".repeat(CommunityMaps.MAX_FILE_BYTES + 1))
	var entry: Dictionary = CommunityMaps.scan(TEST_DIR)[0]
	assert_null(entry["level"])
	assert_true((entry["errors"] as PackedStringArray)[0].contains("demasiado grande"), str(entry["errors"]))
	_write("justo.json", _good_map())
	assert_not_null(_entry(CommunityMaps.scan(TEST_DIR), "justo")["level"], "un mapa normal pesa muy poco")


func test_warnings_come_with_the_entry() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(9, 5))  # una casilla colgada
	_write("con_aviso.json", draft.to_text())
	var entry: Dictionary = CommunityMaps.scan(TEST_DIR)[0]
	assert_not_null(entry["level"], "un aviso no impide jugar")
	assert_eq((entry["warnings"] as PackedStringArray).size(), 1)


func test_only_the_first_maps_are_read() -> void:
	for i: int in CommunityMaps.MAX_MAPS + 5:
		_write("m_%03d.json" % i, "{}")
	assert_eq(CommunityMaps.scan(TEST_DIR).size(), CommunityMaps.MAX_MAPS)


func test_folder_path_is_a_real_path_for_the_person() -> void:
	var path: String = CommunityMaps.folder_path()
	assert_false(path.begins_with("user://"), "la ruta de verdad, no la de Godot")
	assert_true(path.replace("\\", "/").ends_with("/maps/"), path)
	assert_eq(CommunityMaps.DIR, LevelDraft.MAPS_DIR, "es la misma carpeta que usa el editor")
