# Tests del borrador del editor de mapas (T101, spec §10.3: RF-212, RF-214, RF-215, RF-216).
extends GutTest

const TEST_DIR: String = "user://test_maps/"

var draft: LevelDraft


func before_each() -> void:
	draft = LevelDraft.new_level()


func after_each() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)


func _cell_letters(cells: Array) -> Array:
	var letters: Array = []
	for cell: Vector2i in cells:
		letters.append(draft.letter_at(cell))
	return letters


# --- El nivel nuevo ---

func test_new_level_is_valid_without_warnings() -> void:
	var result: Dictionary = draft.check()
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(result["warnings"], PackedStringArray())
	assert_not_null(result["level"])
	assert_false(draft.dirty, "todavía no se cambió nada")
	assert_eq(draft.file_id, "")


func test_new_level_has_a_straight_road_from_a_to_the_exit() -> void:
	assert_eq(draft.letter_at(Vector2i(0, 4)), "A")
	assert_eq(draft.letter_at(Vector2i(19, 4)), "S")
	assert_eq(draft.letter_at(Vector2i(10, 4)), "#")
	assert_eq(draft.letter_at(Vector2i(10, 3)), ".")
	assert_eq(draft.entrance_count(), 1)
	assert_eq(draft.wave_count(), 1)
	assert_eq(draft.enemy_total(0), 10)


# --- Pintar (RF-212) ---

func test_each_tool_paints_its_letter() -> void:
	var cell := Vector2i(5, 1)
	assert_true(draft.apply_tool(LevelDraft.Tool.PATH, cell))
	assert_eq(draft.letter_at(cell), "#")
	assert_true(draft.apply_tool(LevelDraft.Tool.BLOCKED, cell))
	assert_eq(draft.letter_at(cell), "X")
	assert_true(draft.apply_tool(LevelDraft.Tool.GRASS, cell))
	assert_eq(draft.letter_at(cell), ".")
	assert_true(draft.dirty)


func test_painting_the_same_thing_or_outside_changes_nothing() -> void:
	assert_false(draft.apply_tool(LevelDraft.Tool.GRASS, Vector2i(5, 1)), "ya era pasto")
	assert_false(draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(-1, 0)))
	assert_false(draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(20, 0)))
	assert_false(draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(0, 9)))
	assert_false(draft.dirty)
	assert_false(draft.can_undo(), "lo que no cambia nada no se puede deshacer")


func test_entrances_get_the_next_free_letter() -> void:
	assert_true(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 1)))
	assert_true(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 7)))
	assert_eq(_cell_letters([Vector2i(0, 4), Vector2i(0, 1), Vector2i(0, 7)]), ["A", "B", "C"])
	assert_eq(draft.entrance_count(), 3)
	assert_false(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 1)), "ya es una entrada")


func test_there_are_at_most_eight_entrances() -> void:
	for y: int in 7:
		assert_true(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, y if y < 4 else y + 1)), "entrada %d" % (y + 2))
	assert_eq(draft.entrance_count(), 8)
	assert_false(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(3, 0)), "la novena no entra")


func test_the_exit_moves() -> void:
	assert_true(draft.apply_tool(LevelDraft.Tool.EXIT, Vector2i(19, 8)))
	assert_eq(draft.letter_at(Vector2i(19, 8)), "S")
	assert_eq(draft.letter_at(Vector2i(19, 4)), ".", "la salida vieja pasa a pasto: hay una sola")
	assert_false(draft.apply_tool(LevelDraft.Tool.EXIT, Vector2i(19, 8)))


func test_erasing_the_exit_leaves_the_map_without_one() -> void:
	draft.apply_tool(LevelDraft.Tool.GRASS, Vector2i(19, 4))
	assert_true(" | ".join(draft.check()["errors"]).contains("Falta la salida"))


func test_painting_over_an_entrance_removes_it_and_renumbers() -> void:
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 1))  # B
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 7))  # C
	draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(0, 1))  # se quita la B
	assert_eq(_cell_letters([Vector2i(0, 4), Vector2i(0, 1), Vector2i(0, 7)]), ["A", "#", "B"], "la C pasó a ser B")
	assert_eq(draft.entrance_count(), 2)


func test_removing_the_first_entrance_shifts_all_the_others() -> void:
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 1))  # B
	draft.apply_tool(LevelDraft.Tool.GRASS, Vector2i(0, 4))  # se quita la A
	assert_eq(draft.letter_at(Vector2i(0, 1)), "A", "la B pasó a ser A")
	assert_eq(draft.letter_at(Vector2i(0, 4)), ".")


func test_removing_an_entrance_fixes_the_waves() -> void:
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 1))  # B
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 7))  # C
	draft.set_group(0, 0, "entrada", "B")
	draft.add_group(0)
	draft.set_group(0, 1, "entrada", "C")
	draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(0, 1))  # se quita la B
	assert_eq(draft.group(0, 0)["entrada"], "A", "las de la entrada quitada pasan a la A")
	assert_eq(draft.group(0, 1)["entrada"], "B", "las de la C pasan a la B")


func test_a_gap_in_the_letters_takes_the_free_one() -> void:
	# Un archivo con A y C (sin B): la próxima entrada es la B, no otra C.
	var rows: Array = draft.data["mapa"]
	rows[1] = "C" + (rows[1] as String).substr(1)
	assert_true(draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(0, 7)))
	assert_eq(draft.letter_at(Vector2i(0, 7)), "B")


# --- Deshacer y rehacer ---

func test_undo_and_redo_one_change() -> void:
	draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(5, 1))
	assert_true(draft.can_undo())
	assert_true(draft.undo())
	assert_eq(draft.letter_at(Vector2i(5, 1)), ".")
	assert_true(draft.can_redo())
	assert_true(draft.redo())
	assert_eq(draft.letter_at(Vector2i(5, 1)), "#")
	assert_false(draft.redo())


func test_a_stroke_is_one_undo_step() -> void:
	draft.begin_stroke()
	for x: int in range(2, 8):
		draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(x, 1))
	draft.end_stroke()
	assert_eq(draft.letter_at(Vector2i(7, 1)), "#")
	draft.undo()
	assert_eq(_cell_letters([Vector2i(2, 1), Vector2i(5, 1), Vector2i(7, 1)]), [".", ".", "."], "todo el trazo junto")
	assert_false(draft.can_undo())


func test_a_stroke_that_changes_nothing_records_nothing() -> void:
	draft.begin_stroke()
	draft.apply_tool(LevelDraft.Tool.GRASS, Vector2i(5, 1))
	draft.end_stroke()
	assert_false(draft.can_undo())


func test_a_new_change_clears_redo() -> void:
	draft.apply_tool(LevelDraft.Tool.PATH, Vector2i(5, 1))
	draft.undo()
	draft.apply_tool(LevelDraft.Tool.BLOCKED, Vector2i(6, 1))
	assert_false(draft.can_redo())


func test_undo_covers_settings_and_waves_too() -> void:
	draft.set_gold(500)
	draft.add_wave()
	draft.undo()
	assert_eq(draft.wave_count(), 1)
	draft.undo()
	assert_eq(draft.gold(), 200)


func test_undo_keeps_only_the_last_fifty_steps() -> void:
	for i: int in 60:
		draft.set_gold(1000 + i)
	var steps: int = 0
	while draft.undo():
		steps += 1
	assert_eq(steps, LevelDraft.UNDO_LIMIT)


# --- Ajustes (RF-214) ---

func test_settings() -> void:
	draft.set_level_name("Mi mapa")
	draft.set_gold(350)
	draft.set_lives(15)
	draft.set_health_scale(22)
	assert_eq([draft.level_name(), draft.gold(), draft.lives(), draft.health_scale()], ["Mi mapa", 350, 15, 22])
	draft.set_health_scale(0)
	assert_false(draft.data.has("aumento_vida"), "0 = el general: no se escribe")
	assert_eq(draft.health_scale(), 0)


func test_setting_the_same_value_records_nothing() -> void:
	draft.set_gold(200)
	draft.set_level_name(LevelDraft.NEW_NAME)
	assert_false(draft.can_undo())
	assert_false(draft.dirty)


# --- Oleadas (RF-215) ---

func test_add_duplicate_and_remove_waves() -> void:
	assert_eq(draft.add_wave(), 1)
	draft.set_group(1, 0, "cantidad", 3)
	assert_eq(draft.duplicate_wave(1), 2)
	assert_eq(draft.group(2, 0)["cantidad"], 3, "la copia trae lo mismo")
	draft.set_group(2, 0, "cantidad", 9)
	assert_eq(draft.group(1, 0)["cantidad"], 3, "y no comparte datos con el original")
	assert_true(draft.remove_wave(0))
	assert_eq(draft.wave_count(), 2)
	assert_false(draft.remove_wave(5))


func test_the_last_wave_cannot_be_removed() -> void:
	assert_false(draft.remove_wave(0))
	assert_eq(draft.wave_count(), 1)


func test_groups() -> void:
	draft.add_group(0)
	assert_eq(draft.group_count(0), 2)
	draft.set_group(0, 1, "enemigo", "troll")
	draft.set_group(0, 1, "cantidad", 4)
	draft.set_group(0, 1, "cada", 1.5)
	draft.set_group(0, 1, "desde", 2.0)
	assert_eq(draft.group(0, 1), {"enemigo": "troll", "cantidad": 4, "cada": 1.5, "desde": 2.0, "entrada": "A"})
	assert_eq(draft.enemy_total(0), 14)
	assert_true(draft.remove_group(0, 1))
	assert_eq(draft.enemy_total(0), 10)
	assert_false(draft.remove_group(0, 3))


func test_set_group_reports_whether_it_changed() -> void:
	assert_false(draft.set_group(0, 0, "cantidad", 10), "ya valía 10")
	assert_true(draft.set_group(0, 0, "cantidad", 11))
	assert_false(draft.set_group(0, 0, "desconocida", 1))
	assert_false(draft.set_group(9, 0, "cantidad", 1))


func test_default_values_are_not_written() -> void:
	draft.set_group(0, 0, "desde", 2.0)
	draft.set_group(0, 0, "desde", 0.0)
	draft.set_group(0, 0, "entrada", "B")
	draft.set_group(0, 0, "entrada", "A")
	assert_eq((draft.data["oleadas"][0][0] as Dictionary).keys(), ["enemigo", "cantidad", "cada"])


# --- El texto ---

func test_the_text_reads_back_the_same_with_level_file() -> void:
	draft.set_level_name("Prueba con ñandú")
	draft.set_gold(333)
	draft.set_health_scale(17)
	draft.apply_tool(LevelDraft.Tool.ENTRANCE, Vector2i(5, 3))  # pegada al camino: B
	draft.set_group(0, 0, "entrada", "B")
	var result: Dictionary = LevelFile.parse(draft.to_text(), &"x")
	var level: LevelData = result["level"]
	assert_not_null(level, str(result["errors"]))
	assert_eq(level.display_name, "Prueba con ñandú")
	assert_eq(level.starting_gold, 333)
	assert_eq(level.health_scale_percent_per_wave, 17)
	assert_eq(level.map_rows, draft.rows())
	assert_eq(level.waves[0].groups[0].entrance_index, 1)


func test_opening_and_writing_official_levels_gives_the_same_text() -> void:
	# El texto del editor tiene que ser IGUAL al de los niveles oficiales: así los mapas que
	# se guardan se leen bien y se ven ordenados en git.
	var checked: int = 0
	for file: String in DirAccess.get_files_at(LevelFile.LEVELS_DIR):
		if not file.ends_with(".json"):
			continue
		var original: String = FileAccess.get_file_as_string(LevelFile.LEVELS_DIR + file)
		var opened: LevelDraft = LevelDraft.from_text(original, file.get_basename())
		assert_not_null(opened, file)
		assert_eq(opened.to_text(), original, "%s: mismo texto" % file)
		checked += 1
	assert_gt(checked, 0)


func test_from_text_rejects_what_is_not_a_level() -> void:
	assert_null(LevelDraft.from_text("esto no es json"))
	assert_null(LevelDraft.from_text("[1, 2, 3]"))


func test_from_text_completes_what_is_missing() -> void:
	var partial: LevelDraft = LevelDraft.from_text("{\"nombre\": \"Roto\", \"mapa\": [\"A#S\"], \"dinero\": 5}")
	assert_not_null(partial)
	assert_eq(partial.rows().size(), MapGrid.MIN_HEIGHT, "nueve filas")
	assert_eq(partial.rows()[0].length(), MapGrid.MIN_WIDTH, "de veinte letras")
	assert_eq(partial.rows()[0], "A#S" + ".".repeat(17))
	assert_false(partial.data.has("dinero"), "las claves desconocidas se descartan")
	assert_eq(partial.wave_count(), 0)
	assert_false(partial.check()["errors"].is_empty(), "y se puede abrir para arreglarlo")


# --- Guardar y abrir (RF-216) ---

func test_save_and_open() -> void:
	draft.file_id = "mi_mapa"
	draft.set_level_name("Guardado")
	assert_eq(draft.save(TEST_DIR), "")
	assert_false(draft.dirty)
	assert_eq(LevelDraft.saved_ids(TEST_DIR), PackedStringArray(["mi_mapa"]))
	var opened: LevelDraft = LevelDraft.open_saved("mi_mapa", TEST_DIR)
	assert_eq(opened.to_text(), draft.to_text())
	assert_eq(opened.file_id, "mi_mapa")
	assert_false(opened.dirty)


func test_a_saved_file_checks_the_same_as_the_draft() -> void:
	draft.file_id = "igual"
	draft.save(TEST_DIR)
	var from_file: Dictionary = LevelFile.load_level(TEST_DIR + "igual.json")
	assert_eq(from_file["errors"], draft.check()["errors"])
	assert_not_null(from_file["level"])


func test_a_draft_with_errors_can_still_be_saved() -> void:
	draft.apply_tool(LevelDraft.Tool.GRASS, Vector2i(19, 4))
	draft.file_id = "a_medias"
	assert_eq(draft.save(TEST_DIR), "", "RF-213: un borrador con errores se guarda para seguir después")
	assert_false(LevelDraft.open_saved("a_medias", TEST_DIR).check()["errors"].is_empty())


func test_invalid_file_names_are_refused() -> void:
	for bad: String in ["", "Mi Mapa", "con.punto", "../afuera", "ñandú", "a".repeat(41)]:
		draft.file_id = bad
		assert_ne(draft.save(TEST_DIR), "", "'%s' no es un nombre válido" % bad)
	assert_eq(LevelDraft.saved_ids(TEST_DIR), PackedStringArray(), "no se escribió nada")


func test_an_official_name_is_refused() -> void:
	draft.file_id = "level_03"
	assert_true(draft.save(TEST_DIR).contains("nivel oficial"))
	assert_eq(LevelDraft.saved_ids(TEST_DIR), PackedStringArray())


func test_official_level_opens_as_a_template() -> void:
	var template: LevelDraft = LevelDraft.open_official("level_03")
	assert_not_null(template)
	assert_eq(template.file_id, "", "no queda ligado al oficial")
	assert_eq(template.suggested_id, "level_03_copia")
	assert_false(template.dirty)
	assert_eq(template.level_name(), LevelFile.load_level("res://data/levels/level_03.json")["level"].display_name)
	template.file_id = template.suggested_id
	assert_eq(template.save(TEST_DIR), "", "guardarlo con otro nombre anda")
	assert_null(LevelDraft.open_official("no_existe"))


func test_clean_file_id() -> void:
	assert_eq(LevelDraft.clean_file_id("Mi Mapa 2"), "mi_mapa_2")
	assert_eq(LevelDraft.clean_file_id("  ¡Ñandú! "), "and")
	assert_eq(LevelDraft.clean_file_id("../x"), "x")
	assert_true(LevelDraft.is_valid_file_id("mi_mapa_2"))
	assert_false(LevelDraft.is_valid_file_id(""))


# --- Límites (RF-223): el editor nunca genera un archivo que el juego rechace ---

func test_settings_are_capped_at_the_limits() -> void:
	draft.set_gold(10_000_000)
	draft.set_lives(5000)
	draft.set_health_scale(999)
	draft.set_level_name("x".repeat(100))
	assert_eq([draft.gold(), draft.lives(), draft.health_scale()], [LevelFile.MAX_GOLD, LevelFile.MAX_LIVES, LevelFile.MAX_HEALTH_SCALE])
	assert_eq(draft.level_name().length(), LevelFile.MAX_NAME_LENGTH)
	assert_true(draft.check()["errors"].is_empty(), str(draft.check()["errors"]))


func test_group_numbers_are_capped_at_the_limits() -> void:
	draft.set_group(0, 0, "cantidad", 5000)
	draft.set_group(0, 0, "cada", 999.0)
	draft.set_group(0, 0, "desde", 99999.0)
	var g: Dictionary = draft.group(0, 0)
	assert_eq([g["cantidad"], g["cada"], g["desde"]], [LevelFile.MAX_COUNT, LevelFile.MAX_EVERY, LevelFile.MAX_FROM])
	assert_true(draft.check()["errors"].is_empty(), str(draft.check()["errors"]))


func test_waves_and_groups_stop_at_the_maximum() -> void:
	while draft.wave_count() < LevelFile.MAX_WAVES:
		assert_gte(draft.add_wave(), 0)
	assert_eq(draft.add_wave(), -1, "no hay una oleada 101")
	assert_eq(draft.duplicate_wave(0), -1)
	assert_eq(draft.wave_count(), LevelFile.MAX_WAVES)
	assert_true(draft.check()["errors"].is_empty(), "el máximo es válido")
	while draft.group_count(0) < LevelFile.MAX_GROUPS:
		assert_true(draft.add_group(0))
	assert_false(draft.add_group(0), "no hay un grupo 21")
	assert_eq(draft.group_count(0), LevelFile.MAX_GROUPS)
	assert_true(draft.check()["errors"].is_empty())
