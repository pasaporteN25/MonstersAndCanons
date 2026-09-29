# Tests del archivo de texto de un nivel y del mapa armado al vuelo (T94, spec §7.8:
# RF-200, RF-203, RF-204).
extends GutTest

## El nivel 6 con dos oleadas (spec §7.8, ejemplo).
const NEST: String = """{
  "version": 1,
  "nombre": "Nido",
  "oro": 250,
  "vidas": 20,
  "aumento_vida": 30,
  "mapa": [
    "..........B.........",
    "A#####....#.......X.",
    ".....#....#.........",
    "...X.#############..",
    ".................#..",
    "..################..",
    "..#.........X.......",
    "..#################S",
    ".......X............"
  ],
  "oleadas": [
    [{"enemigo": "normal", "cantidad": 10, "cada": 0.8}],
    [{"enemigo": "fast", "cantidad": 12, "cada": 0.4, "entrada": "B"},
     {"enemigo": "normal", "cantidad": 8, "cada": 0.8, "desde": 2.0}]
  ]
}"""


func _parse(text: String) -> Dictionary:
	return LevelFile.parse(text, &"level_test")


## El ejemplo con un cambio: `edit` recibe el Dictionary del JSON y lo modifica.
func _nest_with(edit: Callable) -> String:
	var data: Dictionary = JSON.parse_string(NEST)
	edit.call(data)
	return JSON.stringify(data)


func _assert_error(text: String, expected: String) -> void:
	var result: Dictionary = _parse(text)
	assert_null(result["level"], "inválido: " + expected)
	assert_true(" | ".join(result["errors"]).contains(expected),
		"el error dice '%s': %s" % [expected, result["errors"]])


func _points(curve: Curve2D) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i: int in curve.point_count:
		points.append(curve.get_point_position(i))
	return points


# --- Leer un nivel (RF-200, RF-203) ---

func test_reads_the_level_fields() -> void:
	var result: Dictionary = _parse(NEST)
	assert_eq(result["errors"], PackedStringArray())
	var level: LevelData = result["level"]
	assert_eq(level.id, &"level_test", "el id es el nombre del archivo")
	assert_eq(level.display_name, "Nido")
	assert_eq(level.starting_gold, 250)
	assert_eq(level.starting_lives, 20)
	assert_eq(level.health_scale_percent_per_wave, 30)
	assert_eq(level.map_rows.size(), 9)


func test_reads_waves_and_defaults() -> void:
	var level: LevelData = _parse(NEST)["level"]
	assert_eq(level.waves.size(), 2)
	var first: SpawnGroup = level.waves[0].groups[0]
	assert_eq(first.enemy, load("res://data/enemies/normal.tres"))
	assert_eq(first.count, 10)
	assert_almost_eq(first.interval, 0.8, 0.0001)
	assert_eq(first.start_delay, 0.0, "desde: 0 si no se escribe")
	assert_eq(first.entrance_index, 0, "entrada: A si no se escribe")
	var fast: SpawnGroup = level.waves[1].groups[0]
	assert_eq(fast.entrance_index, 1, "B es la entrada 1")
	assert_eq(level.waves[1].groups[1].start_delay, 2.0)


func test_without_health_scale_uses_the_general_one() -> void:
	var level: LevelData = _parse(_nest_with(func(d: Dictionary) -> void: d.erase("aumento_vida")))["level"]
	assert_eq(level.health_scale_percent_per_wave, 0)
	var balance: BalanceConfig = load("res://data/balance.tres")
	assert_eq(level.health_scale_percent(balance), balance.health_scale_percent_per_wave)


# --- Errores (RF-204) ---

func test_broken_json_says_the_line() -> void:
	_assert_error(NEST.replace("\"oro\": 250,", "\"oro\": 250"), "no es un JSON válido (línea")


func test_misspelled_key() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["canitdad"] = 3),
		"oleada 1, grupo 1: clave desconocida \"canitdad\"")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["dinero"] = 3), "Clave desconocida \"dinero\"")


func test_enemy_that_does_not_exist() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][1][1]["enemigo"] = "trol"),
		"oleada 2, grupo 2: no existe el enemigo 'trol'")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["enemigo"] = "../towers/basic"),
		"no existe el enemigo")


func test_entrance_the_map_does_not_have() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["entrada"] = "C"),
		"oleada 1, grupo 1: la entrada C no está en el mapa")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["entrada"] = 2),
		"\"entrada\" tiene que ser una letra")


func test_numbers_out_of_range() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["vidas"] = 0), "\"vidas\" tiene que ser 1 o más")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oro"] = 12.5), "\"oro\" tiene que ser un número entero")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["cantidad"] = 0),
		"oleada 1, grupo 1: \"cantidad\" tiene que ser 1 o más")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["cada"] = 0),
		"\"cada\" tiene que ser mayor que 0")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0]["desde"] = -1),
		"\"desde\" tiene que ser un número de 0 para arriba")


func test_missing_parts() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d.erase("nombre")), "Falta \"nombre\"")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d.erase("version")), "Falta \"version\"")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["version"] = 2), "La versión 2 no se puede leer")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"] = []), "al menos una oleada")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0] = []), "oleada 1: tiene que ser una lista")
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["oleadas"][0][0].erase("enemigo")),
		"oleada 1, grupo 1: falta \"enemigo\"")


func test_map_errors_come_with_their_prefix() -> void:
	_assert_error(_nest_with(func(d: Dictionary) -> void: d["mapa"][7] = "..#################."),
		"mapa: Falta la salida")


# --- El mapa armado al vuelo (Level.build) ---

func test_built_map_has_the_cells_of_the_letters() -> void:
	var level: Level = (_parse(NEST)["level"] as LevelData).build_map()
	add_child_autofree(level)
	assert_eq(level.ground.get_used_rect(), Rect2i(0, 0, 20, 9), "RF-01")
	assert_true(level.is_buildable(Vector2i(0, 0)), "pasto")
	assert_false(level.is_buildable(Vector2i(3, 1)), "camino")
	assert_false(level.is_buildable(Vector2i(18, 1)), "bloqueada")
	assert_eq(level.entrance_count(), 2)


func test_built_paths_match_the_old_level_6() -> void:
	# Los puntos de level_06.tscn (hechos con make_levels.gd), sin los puntos que no son esquinas.
	var level: Level = (_parse(NEST)["level"] as LevelData).build_map()
	add_child_autofree(level)
	var tail: Array[Vector2] = [Vector2(1120, 224), Vector2(1120, 352), Vector2(160, 352), Vector2(160, 480), Vector2(1312, 480)]
	var a: Array[Vector2] = [Vector2(-32, 96), Vector2(352, 96), Vector2(352, 224)]
	a.append_array(tail)
	var b: Array[Vector2] = [Vector2(672, -32), Vector2(672, 224)]
	b.append_array(tail)
	assert_eq(_points(level.get_ground_path(0).curve), a, "entrada A: entra desde la izquierda")
	assert_eq(_points(level.get_ground_path(1).curve), b, "entrada B: entra desde arriba")
	assert_eq(_points(level.get_air_path(1).curve), [Vector2(672, -32), Vector2(1312, 480)] as Array[Vector2])


func test_an_inner_exit_ends_at_the_center_and_gets_a_gate() -> void:
	var text: String = _nest_with(func(d: Dictionary) -> void:
		d["mapa"][7] = "..#################."
		d["mapa"][6] = "..#.........X.....S.")
	var level: Level = (_parse(text)["level"] as LevelData).build_map()
	add_child_autofree(level)
	var curve: Curve2D = level.get_ground_path(0).curve
	assert_eq(curve.get_point_position(curve.point_count - 1), Vector2(18.5, 6.5) * 64.0)
	assert_eq(level.inner_exit_cells(), [Vector2i(18, 6)] as Array[Vector2i], "RF-06: puerta")



# --- La campaña (RF-205) ---

func test_campaign_reads_levels_in_order_and_skips_broken_ones() -> void:
	var path: String = "user://test_campaign.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{\"version\": 1, \"niveles\": [\"level_02\", \"no_existe\", \"level_01\"]}")
	file.close()
	var campaign: CampaignData = LevelFile.load_campaign(path)
	DirAccess.remove_absolute(path)
	assert_push_error("no se va a jugar")
	var ids: Array[StringName] = []
	for level: LevelData in campaign.levels:
		ids.append(level.id)
	assert_eq(ids, [&"level_02", &"level_01"] as Array[StringName], "RF-204: el roto se saltea, el resto sigue")
