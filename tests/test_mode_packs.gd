# Tests de los paquetes de modo (M49, RF-388, RF-390 a RF-392, D-078): formato, errores, reglas, mapas
# que se buscan en la carpeta del modo o entre los oficiales, desbloqueo y creación desde el editor.
# Usa carpetas de prueba, nunca los modos del jugador.
extends GutTest

const OFFICIAL: String = "user://test_mode_packs_official/"
const USER: String = "user://test_mode_packs_user/"


func before_each() -> void:
	_remove(OFFICIAL)
	_remove(USER)


func after_each() -> void:
	_remove(OFFICIAL)
	_remove(USER)


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	DirAccess.remove_absolute(dir)


func _write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _mode(root: String, id: String, data: Dictionary) -> void:
	_write(ModePacks.dir_of(root, id) + ModePacks.FILE_NAME, JSON.stringify(data))


func _own_map(level_name: String) -> String:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.set_level_name(level_name)
	return draft.to_text()


# --- El modo oficial Asedio (RF-391) ---

## Las reglas tal como están en data/modos/asedio/modo.json (los números viven en los datos, P2).
static func siege_rules() -> Dictionary:
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(ModePacks.OFFICIAL_DIR + "asedio/" + ModePacks.FILE_NAME))
	return (json.data as Dictionary)["reglas"]


func test_siege_is_harder_than_the_campaign() -> void:
	var rules: Dictionary = siege_rules()
	assert_gt(int(rules[ModePacks.RULE_HEALTH]), 100, "RF-391: monstruos con más vida")
	assert_lte(int(rules.get(ModePacks.RULE_GOLD, 100)), 100, "nunca más oro que en la campaña")


func test_siege_reads_with_its_rules() -> void:
	var rules: Dictionary = siege_rules()
	var mode: Dictionary = ModePacks.read(ModePacks.OFFICIAL_DIR, "asedio", true)
	assert_eq(mode["errors"], PackedStringArray(), "Asedio no tiene errores")
	assert_eq(mode["name"], "Asedio")
	var maps: Array = mode["maps"]
	assert_eq(maps.size(), GameFlow.level_count(), "los mapas 1 a 9 de la campaña")
	for i: int in maps.size():
		var level: LevelData = ModePacks.map_level(mode, i)
		var campaign: LevelData = GameFlow.level(i)
		assert_not_null(level, "mapa %d" % (i + 1))
		assert_eq(level.id, StringName("modo_asedio_" + String(campaign.id)), "RF-390: id propio")
		assert_eq(level.waves.size(), campaign.waves.size(), "las mismas oleadas")
		assert_eq(level.starting_gold, Rules.percent_of(campaign.starting_gold, int(rules.get(ModePacks.RULE_GOLD, 100))))
		assert_eq(level.enemy_health_percent, int(rules[ModePacks.RULE_HEALTH]), "más vida")
		assert_eq(level.starting_lives, campaign.starting_lives, "las vidas no cambian")
		assert_eq(level.extra_towers, campaign.extra_towers, "las torres reservadas del nivel siguen igual")


func test_the_campaign_is_not_touched_by_the_mode() -> void:
	ModePacks.read(ModePacks.OFFICIAL_DIR, "asedio", true)
	assert_eq(GameFlow.level(0).enemy_health_percent, 100)
	assert_eq(GameFlow.level(0).id, &"level_01")


# --- Dónde se buscan los mapas (RF-388) ---

func test_maps_come_from_the_mode_folder_or_the_official_levels() -> void:
	_write(ModePacks.dir_of(USER, "mio") + "mi_mapa.json", _own_map("Mi mapa"))
	_mode(USER, "mio", {"version": 1, "nombre": "Mío", "mapas": ["mi_mapa", "level_02"]})
	var mode: Dictionary = ModePacks.read(USER, "mio", false)
	assert_eq(mode["errors"], PackedStringArray())
	assert_eq(ModePacks.map_level(mode, 0).display_name, "Mi mapa", "el de la carpeta del modo")
	assert_eq(ModePacks.map_level(mode, 1).display_name, GameFlow.level(1).display_name, "el oficial reusado")
	assert_eq(ModePacks.map_level(mode, 1).id, &"modo_mio_level_02")


func test_a_missing_map_has_its_reason_and_the_others_still_play() -> void:
	_mode(USER, "mio", {"version": 1, "nombre": "Mío", "mapas": ["no_existe", "level_01"]})
	var mode: Dictionary = ModePacks.read(USER, "mio", false)
	assert_null(ModePacks.map_level(mode, 0))
	assert_true(((mode["maps"] as Array)[0]["errors"] as PackedStringArray)[0].contains("No existe el mapa"))
	assert_not_null(ModePacks.map_level(mode, 1))


func test_a_broken_map_file_has_its_reason() -> void:
	_write(ModePacks.dir_of(USER, "mio") + "roto.json", "{ esto no es json")
	_mode(USER, "mio", {"version": 1, "nombre": "Mío", "mapas": ["roto"]})
	var mode: Dictionary = ModePacks.read(USER, "mio", false)
	assert_null(ModePacks.map_level(mode, 0))
	assert_false(((mode["maps"] as Array)[0]["errors"] as PackedStringArray).is_empty())


# --- Errores del modo.json (RF-388) ---

func test_broken_mode_files_say_why() -> void:
	var cases: Dictionary = {
		"{ esto no": "no es un JSON válido",
		"[1, 2]": "tiene que empezar con {",
		'{"version": 2, "nombre": "A", "mapas": []}': "version",
		'{"version": 1, "mapas": []}': "nombre",
		'{"version": 1, "nombre": "A", "mapas": "level_01"}': "mapas",
		'{"version": 1, "nombre": "A", "mapas": ["Nivel Uno"]}': "no es un nombre de mapa válido",
		'{"version": 1, "nombre": "A", "mapas": ["modo"]}': "no es un nombre de mapa válido",
		'{"version": 1, "nombre": "A", "mapas": ["level_01", "level_01"]}': "repetido",
		'{"version": 1, "nombre": "A", "mapas": [], "torres": ["laser"]}': "no existe",
		'{"version": 1, "nombre": "A", "mapas": [], "torres": []}': "al menos una torre",
		'{"version": 1, "nombre": "A", "mapas": [], "reglas": {"vida_monstruos_%": 5}}': "entre 10 y 1000",
		'{"version": 1, "nombre": "A", "mapas": [], "reglas": {"oro_inicial_%": 80.5}}': "entero",
		'{"version": 1, "nombre": "A", "mapas": [], "reglas": {"oro": 80}}': "clave desconocida",
		'{"version": 1, "nombre": "A", "mapas": [], "extra": true}': "Clave desconocida",
	}
	for text: String in cases:
		_remove(USER)
		_write(ModePacks.dir_of(USER, "malo") + ModePacks.FILE_NAME, text)
		var errors: PackedStringArray = ModePacks.read(USER, "malo", false)["errors"]
		assert_false(errors.is_empty(), text)
		assert_true(" ".join(errors).contains(cases[text]), "%s → %s" % [text, errors])


func test_a_folder_without_its_file_or_with_a_bad_name_is_an_error() -> void:
	DirAccess.make_dir_recursive_absolute(USER + "vacio")
	DirAccess.make_dir_recursive_absolute(USER + "Con Espacios")
	var modes: Array[Dictionary] = ModePacks.scan(USER, false)
	assert_eq(modes.size(), 2, "los dos se listan, con su motivo")
	for mode: Dictionary in modes:
		assert_false((mode["errors"] as PackedStringArray).is_empty(), String(mode["id"]))


func test_an_own_mode_named_like_an_official_one_is_an_error() -> void:
	_mode(OFFICIAL, "asedio", {"version": 1, "nombre": "Asedio", "mapas": ["level_01"]})
	_mode(USER, "asedio", {"version": 1, "nombre": "Mi asedio", "mapas": ["level_01"]})
	_mode(USER, "otro", {"version": 1, "nombre": "Otro", "mapas": ["level_01"]})
	var modes: Array[Dictionary] = ModePacks.all(OFFICIAL, USER)
	assert_eq(modes.size(), 3)
	assert_true(modes[0]["official"], "primero los oficiales")
	assert_true((modes[0]["errors"] as PackedStringArray).is_empty())
	assert_false((modes[1]["errors"] as PackedStringArray).is_empty(), "RF-388: el propio con el mismo nombre")
	assert_null(ModePacks.map_level(modes[1], 0), "y no se juega")
	assert_true((modes[2]["errors"] as PackedStringArray).is_empty())


func test_no_folder_means_no_modes() -> void:
	assert_eq(ModePacks.all(OFFICIAL, USER).size(), 0)


# --- Reglas (RF-388) ---

func test_rules_change_gold_lives_and_health() -> void:
	_mode(USER, "duro", {"version": 1, "nombre": "Duro", "mapas": ["level_01"],
		"reglas": {"oro_inicial_%": 50, "vidas": 5, "vida_monstruos_%": 200}})
	var level: LevelData = ModePacks.map_level(ModePacks.read(USER, "duro", false), 0)
	assert_eq(level.starting_gold, Rules.percent_of(GameFlow.level(0).starting_gold, 50))
	assert_eq(level.starting_lives, 5)
	assert_eq(level.enemy_health_percent, 200)


func test_without_rules_the_map_stays_as_it_is() -> void:
	_mode(USER, "igual", {"version": 1, "nombre": "Igual", "mapas": ["level_01"]})
	var level: LevelData = ModePacks.map_level(ModePacks.read(USER, "igual", false), 0)
	assert_eq(level.starting_gold, GameFlow.level(0).starting_gold)
	assert_eq(level.enemy_health_percent, 100)
	assert_eq(level.allowed_towers, PackedStringArray())


func test_the_tower_list_limits_the_bar() -> void:
	_mode(USER, "pocas", {"version": 1, "nombre": "Pocas", "mapas": ["level_01"], "torres": ["basic", "cannon"]})
	var level: LevelData = ModePacks.map_level(ModePacks.read(USER, "pocas", false), 0)
	var all_towers: Array[TowerData] = []
	for tower_id: String in LevelFile.tower_ids():
		all_towers.append(load(LevelFile.TOWERS_DIR + tower_id + ".tres"))
	var ids: Array[String] = []
	for tower: TowerData in level.available_towers(all_towers):
		ids.append(String(tower.id))
	ids.sort()
	assert_eq(ids, ["basic", "cannon"])


func test_percent_of_rounds_to_the_nearest_whole_number() -> void:
	assert_eq(Rules.percent_of(150, 80), 120)
	assert_eq(Rules.percent_of(7, 150), 11, "10,5 se redondea a 11")
	assert_eq(Rules.percent_of(40, 100), 40)


# --- Desbloqueo (RF-390) ---

func test_official_modes_open_one_map_after_the_other() -> void:
	_mode(OFFICIAL, "serie", {"version": 1, "nombre": "Serie", "mapas": ["level_01", "no_existe", "level_02"]})
	var mode: Dictionary = ModePacks.read(OFFICIAL, "serie", true)
	var completed: Dictionary = {}
	var unlocked: Dictionary = {}
	var is_completed := func(id: StringName) -> bool: return completed.has(id)
	var is_unlocked := func(id: StringName) -> bool: return unlocked.has(id)
	assert_true(ModePacks.is_open(mode, 0, is_completed, is_unlocked), "el primero está abierto")
	assert_false(ModePacks.is_open(mode, 1, is_completed, is_unlocked), "un mapa roto nunca")
	assert_false(ModePacks.is_open(mode, 2, is_completed, is_unlocked), "cerrado hasta ganar el anterior")
	assert_eq(ModePacks.previous_playable(mode, 2), 0, "se saltea el roto")
	assert_eq(ModePacks.next_playable(mode, 0), 2)
	assert_eq(ModePacks.next_playable(mode, 2), -1, "no hay siguiente")
	completed[ModePacks.level_id(&"serie", "level_01")] = true
	assert_true(ModePacks.is_open(mode, 2, is_completed, is_unlocked), "ganar el anterior lo abre")
	completed.clear()
	unlocked[ModePacks.level_id(&"serie", "level_02")] = true
	assert_true(ModePacks.is_open(mode, 2, is_completed, is_unlocked), "o una marca de desbloqueo")


func test_own_modes_are_all_open() -> void:
	_mode(USER, "libre", {"version": 1, "nombre": "Libre", "mapas": ["level_01", "level_02", "level_03"]})
	var mode: Dictionary = ModePacks.read(USER, "libre", false)
	var never := func(_id: StringName) -> bool: return false
	for i: int in 3:
		assert_true(ModePacks.is_open(mode, i, never, never), "mapa %d" % (i + 1))


# --- Crear un modo y sumarle mapas desde el editor (RF-392) ---

func test_creating_a_mode_makes_its_folder_and_file() -> void:
	var result: Dictionary = ModePacks.create(USER, "Mi Modo 2", OFFICIAL)
	assert_eq(result["error"], "")
	assert_eq(result["id"], "mi_modo_2")
	var mode: Dictionary = ModePacks.read(USER, "mi_modo_2", false)
	assert_eq(mode["errors"], PackedStringArray(), "un modo recién creado es válido, aunque no tenga mapas")
	assert_eq(mode["name"], "Mi Modo 2")
	assert_eq((mode["maps"] as Array).size(), 0)
	assert_eq(ModePacks.user_ids(USER), PackedStringArray(["mi_modo_2"]))


func test_mode_names_are_checked() -> void:
	_mode(OFFICIAL, "asedio", {"version": 1, "nombre": "Asedio", "mapas": []})
	ModePacks.create(USER, "Ya existe", OFFICIAL)
	assert_true(ModePacks.name_problem(USER, "", OFFICIAL).contains("Escribí"))
	assert_true(ModePacks.name_problem(USER, "¿?¡!", OFFICIAL).contains("al menos una letra"))
	assert_true(ModePacks.name_problem(USER, "x".repeat(31), OFFICIAL).contains("máximo"))
	assert_true(ModePacks.name_problem(USER, "Asedio", OFFICIAL).contains("modo oficial"))
	assert_true(ModePacks.name_problem(USER, "Ya existe", OFFICIAL).contains("Ya tenés"))
	assert_eq(ModePacks.name_problem(USER, "Otro nuevo", OFFICIAL), "")
	assert_ne(ModePacks.create(USER, "Ya existe", OFFICIAL)["error"], "", "no pisa uno que ya existe")


func test_adding_maps_keeps_the_order_and_never_repeats() -> void:
	_mode(USER, "mio", {"version": 1, "nombre": "Mío", "descripcion": "Hola", "mapas": ["level_01"],
		"reglas": {"vida_monstruos_%": 150}})
	var dir: String = ModePacks.dir_of(USER, "mio")
	assert_eq(ModePacks.add_map(dir, "mapa_b"), "")
	assert_eq(ModePacks.add_map(dir, "mapa_b"), "", "el mismo mapa otra vez no se repite")
	var text: String = FileAccess.get_file_as_string(dir + ModePacks.FILE_NAME)
	var json := JSON.new()
	assert_eq(json.parse(text), OK, text)
	var data: Dictionary = json.data
	assert_eq(data["mapas"], ["level_01", "mapa_b"])
	assert_eq(data["descripcion"], "Hola", "lo demás queda igual")
	assert_true(text.contains("\"vida_monstruos_%\": 150"), "los enteros siguen siendo enteros: " + text)
	assert_true(text.contains("\"version\": 1"), text)


func test_adding_a_map_to_a_mode_without_file_says_why() -> void:
	assert_ne(ModePacks.add_map(ModePacks.dir_of(USER, "fantasma"), "mapa"), "")
