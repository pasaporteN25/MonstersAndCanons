# T268a (B-39, RF-115, RF-381): ¿la versión actual conserva el progreso de un tester que jugó con una build anterior?
# Cada guardado imita lo que escribía `save()` en un commit concreto de `save_manager.gd` (el formato siempre fue
# `"version": 1` y las claves se fueron sumando). Se comprueba que carga, que no se pierde nada de lo que el archivo
# decía, que cargar y consultar no reescribe el archivo y que el nivel que sigue al último ganado queda abierto.
# Informe y límites: specs/tareas/informes/T268a-verificacion-guardado.md.
extends GutTest

const PATH: String = "user://test_tester_eras.json"
const SETTINGS_3: Dictionary = {"music_volume": 0.5, "sfx_volume": 0.25, "fullscreen": true}
const SCORES: Dictionary = {"level_01": [{"name": "LUC", "points": 900}, {"name": "AAA", "points": 100}]}
const TECH_5: Array = ["level_01", "level_02", "level_03", "level_04", "level_05"]


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = PATH
	SaveManager.load_save()


func after_each() -> void:
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _write(text: String) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


## Niveles 1..won ganados y `won + 1` abierto sin ganar; con `score`, el formato de T90 en adelante.
func _levels(won: int, score: bool) -> Dictionary:
	var levels: Dictionary = {}
	for n: int in range(1, won + 2):
		var entry: Dictionary = {"unlocked": true, "completed": n <= won, "best_lives": (21 - n) if n <= won else 0}
		if score:
			entry["best_score"] = (1000 - 80 * n) if n <= won else 0
		levels["level_%02d" % n] = entry
	return levels


## Un guardado por época: [nombre, contenido]. Cada uno suma lo que trajo el commit indicado.
func _eras() -> Array:
	var settings_4: Dictionary = SETTINGS_3.duplicate()
	settings_4["damage_numbers"] = false
	var seen: Array = ["normal", "fast", "tank"]
	var hall: Dictionary = SCORES.duplicate(true)
	hall["hall_of_fame"] = [{"name": "LUCAS", "points": 4000}]
	var both: Dictionary = {"technology": TECH_5, "disruptor": ["level_08", "level_09", "level_10"]}
	return [
		["T40 (28/09): solo niveles y 3 opciones", {"version": 1, "levels": _levels(1, false), "settings": SETTINGS_3}],
		["T65 (28/09): + damage_numbers", {"version": 1, "levels": _levels(3, false), "settings": settings_4}],
		["T68 (28/09): + seen_enemies", {"version": 1, "levels": _levels(4, false), "settings": settings_4, "seen_enemies": seen}],
		["T89 (29/09): + scores e initials", {"version": 1, "levels": _levels(5, false), "settings": settings_4,
			"seen_enemies": seen, "scores": SCORES, "initials": {"3": "LUC"}}],
		["T90 (29/09): + best_score y hall_total", {"version": 1, "levels": _levels(6, true), "settings": settings_4,
			"seen_enemies": seen, "scores": hall, "initials": {"3": "LUC", "5": "LUCAS"}, "hall_total": 4000}],
		["T183 (03/10): + collections.technology", {"version": 1, "levels": _levels(8, true), "settings": settings_4,
			"seen_enemies": seen, "scores": hall, "initials": {"3": "LUC"}, "hall_total": 4000, "collections": {"technology": ["level_01", "level_02", "level_03"]}}],
		["T211 (08/10): + collections.disruptor", {"version": 1, "levels": _levels(9, true), "settings": settings_4,
			"seen_enemies": seen, "scores": hall, "initials": {"3": "LUC"}, "hall_total": 4000, "collections": {"technology": TECH_5, "disruptor": ["level_08"]}}],
		["T242 (11/10): + intro_seen", {"version": 1, "levels": _levels(10, true), "settings": settings_4,
			"seen_enemies": seen, "scores": hall, "initials": {"3": "LUC"}, "hall_total": 4000, "collections": both, "intro_seen": true}],
		["modos y mapas de la comunidad en el mismo archivo", {"version": 1, "levels": {"level_01": {"unlocked": true, "completed": true, "best_lives": 12, "best_score": 300},
			"comunidad_miMapa": {"unlocked": true, "completed": true, "best_lives": 9, "best_score": 120}}, "settings": settings_4}],
	]


func _assert_nothing_lost(label: String, data: Dictionary) -> void:
	for id: String in data["levels"]:
		var entry: Dictionary = data["levels"][id]
		var sid := StringName(id)
		assert_eq(SaveManager.is_unlocked(sid), entry["unlocked"], "%s: %s abierto" % [label, id])
		assert_eq(SaveManager.is_completed(sid), entry["completed"], "%s: %s ganado" % [label, id])
		assert_eq(SaveManager.best_lives(sid), int(entry["best_lives"]), "%s: %s vidas" % [label, id])
		assert_eq(SaveManager.best_score(sid), int(entry.get("best_score", 0)), "%s: %s puntaje" % [label, id])
	var settings: Dictionary = data["settings"]
	for key: String in settings:
		assert_eq(SaveManager.get_setting(key), settings[key], "%s: opción %s" % [label, key])
	for enemy: String in data.get("seen_enemies", []):
		assert_true(SaveManager.has_seen_enemy(StringName(enemy)), "%s: enemigo %s" % [label, enemy])
	var scores: Dictionary = data.get("scores", {})
	for table: String in scores:
		assert_eq(SaveManager.scores(StringName(table)).size(), (scores[table] as Array).size(), "%s: récords %s" % [label, table])
	var collections: Dictionary = data.get("collections", {})
	for collection: String in collections:
		assert_eq(Array(SaveManager.collected_sources(StringName(collection))), collections[collection], "%s: colección %s" % [label, collection])
	assert_eq(SaveManager.hall_total(), int(data.get("hall_total", 0)), "%s: hall_total" % label)
	assert_eq(SaveManager.intro_seen(), data.get("intro_seen", false), "%s: intro_seen" % label)


func test_every_build_era_loads_and_keeps_everything() -> void:
	for era: Array in _eras():
		_write(JSON.stringify(era[1], "  "))
		SaveManager.load_save()
		_assert_nothing_lost(era[0], era[1])


func test_loading_and_asking_does_not_rewrite_the_file_and_opens_the_next_level() -> void:
	for era: Array in _eras():
		var text: String = JSON.stringify(era[1], "  ")
		_write(text)
		SaveManager.load_save()
		var levels: Dictionary = era[1]["levels"]
		for i: int in GameFlow.level_count():
			GameFlow.is_level_unlocked(i)
			GameFlow.level_stars(i)
		assert_eq(FileAccess.get_file_as_string(PATH), text, "%s: consultar no reescribe el archivo (RF-381)" % era[0])
		var last_won: int = 0
		for n: int in range(1, 16):
			if levels.has("level_%02d" % n) and levels["level_%02d" % n]["completed"]:
				last_won = n
		if last_won > 0 and last_won < GameFlow.level_count():
			assert_true(GameFlow.is_level_unlocked(last_won), "%s: el nivel %d queda abierto" % [era[0], last_won + 1])
			assert_false(GameFlow.is_level_unlocked(last_won + 1), "%s: no se saltea un nivel sin victoria" % era[0])


func test_save_after_loading_each_era_keeps_everything_and_only_adds_new_keys() -> void:
	for era: Array in _eras():
		_write(JSON.stringify(era[1], "  "))
		SaveManager.load_save()
		assert_true(SaveManager.save(), era[0])
		SaveManager.load_save()
		_assert_nothing_lost(era[0], era[1])
		assert_eq(int(JSON.parse_string(FileAccess.get_file_as_string(PATH))["version"]), 1, "%s: la versión no cambia" % era[0])


## La primera vez que el tester abre la build nueva no tiene `intro_seen`: se muestra la intro y se reescribe el archivo
## enseguida (RF-498). Lo que había tiene que seguir intacto después de ese primer guardado automático.
func test_first_launch_intro_rewrite_keeps_the_old_progress() -> void:
	var era: Array = _eras()[6]
	_write(JSON.stringify(era[1], "  "))
	SaveManager.load_save()
	assert_false(SaveManager.intro_seen())
	SaveManager.mark_intro_seen()
	SaveManager.load_save()
	assert_true(SaveManager.intro_seen())
	var expected: Dictionary = (era[1] as Dictionary).duplicate()
	expected["intro_seen"] = true
	_assert_nothing_lost(era[0], expected)


# --- Archivos dañados: sin errores del motor, sin progreso, y el archivo no se toca hasta el próximo guardado ---

func test_damaged_files_start_from_zero_without_touching_the_file() -> void:
	var good: String = JSON.stringify(_eras()[7][1], "  ")
	var no_version: Dictionary = (_eras()[7][1] as Dictionary).duplicate()
	no_version.erase("version")
	var cases: Dictionary = {
		"vacío": "",
		"cortado a la mitad": good.substr(0, good.length() / 2),
		"basura": "\u0001\u0002no es jsonÿ",
		"dos documentos pegados": good + good,
		"otra versión": good.replace('"version": 1', '"version": 2'),
		"sin versión": JSON.stringify(no_version, "  "),
		"raíz que no es objeto": "[1,2,3]",
	}
	for label: String in cases:
		_write(cases[label])
		SaveManager.load_save()
		assert_false(SaveManager.is_completed(&"level_01"), "%s: empieza de cero" % label)
		assert_false(SaveManager.is_unlocked(&"level_02"), label)
		assert_eq(SaveManager.get_setting("sfx_volume"), 0.8, label)
		assert_eq(FileAccess.get_file_as_string(PATH), cases[label], "%s: cargar no modifica el archivo dañado" % label)


func test_levels_null_loads_as_empty_progress_and_keeps_the_rest() -> void:
	var data: Dictionary = _eras()[7][1].duplicate()
	data["levels"] = null
	_write(JSON.stringify(data))
	SaveManager.load_save()
	assert_false(SaveManager.is_completed(&"level_01"))
	assert_eq(SaveManager.hall_total(), 4000, "lo demás del archivo sí se conserva")
	assert_true(SaveManager.intro_seen())


func test_utf8_bom_at_the_start_still_loads() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_buffer(PackedByteArray([0xEF, 0xBB, 0xBF]))
	file.store_string(JSON.stringify(_eras()[7][1]))
	file.close()
	SaveManager.load_save()
	assert_true(SaveManager.is_completed(&"level_10"), "un editor de Windows que agrega BOM no rompe el guardado")
