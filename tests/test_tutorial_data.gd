# Tests de los datos del tutorial (T330, M63: RF-571 y RF-578): el lector `TutorialData` y los datos oficiales
# (`data/tutorial/tutorial.json`).
extends GutTest


func _step(id: String, text: String = "Un texto corto.") -> Dictionary:
	return {"paso": id, "texto": text}


func _pc_ids() -> Array:
	return ["welcome", "path", "gold", "lives", "pick_tower", "place_tower", "start_wave", "select_tower", "upgrade",
			"sell", "speed", "pause", "resume", "done"]


func _mobile_ids() -> Array:
	return ["welcome", "path", "gold", "lives", "open_cart", "pick_card", "confirm_tower", "start_wave", "select_tower",
			"upgrade", "sell", "speed", "pause", "resume", "done"]


func _steps(ids: Array) -> Array:
	var steps: Array = []
	for id: Variant in ids:
		steps.append(_step(str(id)))
	return steps


## Un archivo válido; `overrides` pisa claves.
func _raw(overrides: Dictionary = {}) -> Dictionary:
	var raw: Dictionary = {
		"version": 1, "borrador": true, "nivel": "level_01",
		"interfaz": {"titulo": "Tutorial", "paso": "Paso %d de %d", "siguiente": "Siguiente", "saltar": "Saltar tutorial", "terminar": "¡A jugar!"},
		"pc": _steps(_pc_ids()), "celular": _steps(_mobile_ids()),
	}
	raw.merge(overrides, true)
	return raw


func _has_error(data: TutorialData, fragment: String) -> bool:
	for error: String in data.errors:
		if error.contains(fragment):
			return true
	return false


# --- El lector ---

func test_a_valid_file_has_no_errors() -> void:
	var data: TutorialData = TutorialData.parse(_raw())
	assert_eq(data.errors, PackedStringArray(), "sin errores")
	assert_true(data.is_valid())
	assert_eq(data.level_id, "level_01")
	assert_true(data.draft)
	assert_eq(data.steps_for(false).size(), 14)
	assert_eq(data.steps_for(true).size(), 15)


func test_a_minimal_list_with_only_the_required_steps_is_valid() -> void:
	var pc: Array = _steps(["path", "gold", "lives", "pick_tower", "place_tower", "start_wave", "upgrade", "sell", "speed", "pause", "resume"])
	assert_true(TutorialData.parse(_raw({"pc": pc})).is_valid())


func test_a_missing_required_step_is_an_error_that_names_it() -> void:
	var ids: Array = _pc_ids()
	ids.erase("sell")
	var data: TutorialData = TutorialData.parse(_raw({"pc": _steps(ids)}))
	assert_false(data.is_valid())
	assert_true(_has_error(data, "la lista \"pc\" no tiene el paso \"sell\" y hace falta"))
	var mobile_ids: Array = _mobile_ids()
	mobile_ids.erase("confirm_tower")
	assert_true(_has_error(TutorialData.parse(_raw({"celular": _steps(mobile_ids)})), "la lista \"celular\" no tiene el paso \"confirm_tower\""))


func test_a_step_from_the_other_mode_is_an_error() -> void:
	var ids: Array = _pc_ids()
	ids.insert(4, "open_cart")
	var data: TutorialData = TutorialData.parse(_raw({"pc": _steps(ids)}))
	assert_true(_has_error(data, "el paso \"open_cart\" no se usa en la PC"))
	var mobile_ids: Array = _mobile_ids()
	mobile_ids.insert(4, "pick_tower")
	assert_true(_has_error(TutorialData.parse(_raw({"celular": _steps(mobile_ids)})), "el paso \"pick_tower\" no se usa en el modo celular"))


func test_an_unknown_or_repeated_step_is_an_error() -> void:
	var ids: Array = _pc_ids()
	ids.append("bailar")
	assert_true(_has_error(TutorialData.parse(_raw({"pc": _steps(ids)})), "`bailar` no existe"))
	var repeated: Array = _pc_ids()
	repeated.insert(2, "path")
	assert_true(_has_error(TutorialData.parse(_raw({"pc": _steps(repeated)})), "el paso \"path\" está repetido"))


func test_steps_out_of_order_are_errors() -> void:
	var ids: Array = _pc_ids()
	ids.erase("pick_tower")
	ids.insert(ids.find("place_tower") + 1, "pick_tower")
	assert_true(_has_error(TutorialData.parse(_raw({"pc": _steps(ids)})), "\"pick_tower\" tiene que ir antes que \"place_tower\""))
	var late: Array = _pc_ids()
	late.erase("done")
	late.insert(3, "done")
	assert_true(_has_error(TutorialData.parse(_raw({"pc": _steps(late)})), "\"done\" tiene que ser el último"))


func test_pause_without_resume_is_an_error() -> void:
	var ids: Array = _pc_ids()
	ids.erase("resume")
	assert_true(_has_error(TutorialData.parse(_raw({"pc": _steps(ids)})), "después de \"pause\" tiene que ir \"resume\""))


func test_text_limits_are_checked_with_the_step_named() -> void:
	var three_lines: Array = _steps(_pc_ids())
	three_lines[1]["texto"] = "Una.\nDos.\nTres."
	assert_true(_has_error(TutorialData.parse(_raw({"pc": three_lines})), "el paso 2 de pc (\"path\") tiene 3 líneas y el máximo es 2"))
	var long_line: Array = _steps(_pc_ids())
	long_line[2]["texto"] = "a".repeat(TutorialData.MAX_LINE_CHARS + 1)
	assert_true(_has_error(TutorialData.parse(_raw({"pc": long_line})), "la línea 1 con 81 caracteres y el máximo por línea es 80"))
	var too_long: Array = _steps(_pc_ids())
	too_long[2]["texto"] = "a".repeat(80) + "\n" + "b".repeat(81 - 1)
	assert_true(_has_error(TutorialData.parse(_raw({"pc": too_long})), "caracteres y el máximo es 160"))
	var empty: Array = _steps(_pc_ids())
	empty[0]["texto"] = "   "
	assert_true(_has_error(TutorialData.parse(_raw({"pc": empty})), "tiene el texto vacío"))
	var control: Array = _steps(_pc_ids())
	control[0]["texto"] = "hola\tchau"
	assert_true(_has_error(TutorialData.parse(_raw({"pc": control})), "caracteres de control"))
	var blank_line: Array = _steps(_pc_ids())
	blank_line[0]["texto"] = "Hola.\n"
	assert_true(_has_error(TutorialData.parse(_raw({"pc": blank_line})), "línea 2 en blanco"))
	var not_text: Array = _steps(_pc_ids())
	not_text[0]["texto"] = 7
	assert_true(_has_error(TutorialData.parse(_raw({"pc": not_text})), "\"texto\" tiene que ser un texto"))


func test_the_text_limits_are_accepted_exactly() -> void:
	var steps: Array = _steps(_pc_ids())
	steps[0]["texto"] = "a".repeat(TutorialData.MAX_LINE_CHARS) + "\n" + "b".repeat(TutorialData.MAX_TOTAL_CHARS - TutorialData.MAX_LINE_CHARS - 1)
	assert_eq(String(steps[0]["texto"]).length(), TutorialData.MAX_TOTAL_CHARS)
	assert_true(TutorialData.parse(_raw({"pc": steps})).is_valid(), "2 líneas, una de 80 y 160 en total: es el límite y pasa")
	steps[0]["texto"] = "a".repeat(TutorialData.MAX_LINE_CHARS) + "\n" + "b".repeat(TutorialData.MAX_LINE_CHARS)
	assert_false(TutorialData.parse(_raw({"pc": steps})).is_valid(), "161 con el salto de línea: uno de más")


func test_the_interface_labels_are_checked() -> void:
	var missing: Dictionary = _raw()["interfaz"]
	missing.erase("saltar")
	assert_true(_has_error(TutorialData.parse(_raw({"interfaz": missing})), "\"interfaz\" \"saltar\""))
	var bad: Dictionary = _raw()["interfaz"]
	bad["paso"] = "Paso %d"
	assert_true(_has_error(TutorialData.parse(_raw({"interfaz": bad})), "dos %d"))
	var extra: Dictionary = _raw()["interfaz"]
	extra["raro"] = "x"
	assert_true(_has_error(TutorialData.parse(_raw({"interfaz": extra})), "no usa la clave \"raro\""))
	assert_true(_has_error(TutorialData.parse(_raw({"interfaz": 5})), "\"interfaz\" tiene que ser un objeto"))


func test_header_fields_are_checked() -> void:
	assert_true(_has_error(TutorialData.parse(_raw({"version": 2})), "\"version\" tiene que ser 1"))
	assert_true(_has_error(TutorialData.parse(_raw({"borrador": "si"})), "\"borrador\" tiene que ser true o false"))
	assert_true(_has_error(TutorialData.parse(_raw({"nivel": ""})), "\"nivel\" tiene que ser el id del nivel"))
	assert_true(_has_error(TutorialData.parse(_raw({"pc": "nada"})), "la lista \"pc\" tiene que ser una lista de pasos"))
	assert_true(_has_error(TutorialData.parse([]), "tiene que ser un objeto"))
	assert_true(_has_error(TutorialData.parse(_raw({"pc": [5]})), "el paso 1 de pc tiene que ser un objeto"))


func test_a_missing_or_broken_file_is_an_error_not_a_crash() -> void:
	var missing: TutorialData = TutorialData.load_file("res://data/tutorial/no_existe.json")
	assert_false(missing.is_valid())
	assert_true(_has_error(missing, "no existe el archivo"))
	var path: String = "user://test_tutorial_roto.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ roto")
	file.close()
	var broken: TutorialData = TutorialData.load_file(path)
	assert_false(broken.is_valid())
	assert_true(_has_error(broken, "no es un JSON válido"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_every_step_has_a_known_event_and_reading_steps_have_none() -> void:
	for id: String in TutorialData.STEPS:
		assert_true(TutorialData.is_known(id))
	assert_eq(TutorialData.event_of("welcome"), TutorialData.EVENT_NONE)
	assert_eq(TutorialData.event_of("pick_tower"), TutorialData.EVENT_TOWER_SELECTED)
	assert_eq(TutorialData.event_of("confirm_tower"), TutorialData.EVENT_TOWER_BUILT)
	assert_eq(TutorialData.event_of("nada"), TutorialData.EVENT_NONE)
	for id: String in TutorialData.REQUIRED_PC + TutorialData.REQUIRED_MOBILE:
		assert_true(TutorialData.is_known(id), id)


# --- Los datos oficiales ---

func test_the_official_file_is_valid_and_marked_as_a_draft() -> void:
	var data: TutorialData = TutorialData.load_file()
	assert_eq(data.errors, PackedStringArray(), "el archivo oficial no tiene errores")
	assert_true(data.is_valid())
	assert_eq(data.level_id, "level_01")
	assert_true(data.draft, "los textos son borrador hasta el OK de Lucas (RF-571); al aprobarlos se pasa a false")


func test_the_official_tutorial_teaches_everything_lucas_asked_for_in_both_modes() -> void:
	var data: TutorialData = TutorialData.load_file()
	for mobile: bool in [false, true]:
		var ids: Array[String] = []
		for step: Dictionary in data.steps_for(mobile):
			ids.append(step["paso"])
		for topic: String in ["path", "gold", "lives", "start_wave", "upgrade", "sell", "speed", "pause"]:
			assert_true(ids.has(topic), "%s: falta %s" % ["celular" if mobile else "pc", topic])
	assert_true(data.steps_for(false).any(func(s: Dictionary) -> bool: return s["paso"] == "place_tower"))
	assert_true(data.steps_for(true).any(func(s: Dictionary) -> bool: return s["paso"] == "confirm_tower"))


func test_the_phone_texts_do_not_mention_the_keyboard_or_the_mouse() -> void:
	var data: TutorialData = TutorialData.load_file()
	for step: Dictionary in data.steps_for(true):
		var text: String = String(step["texto"]).to_lower()
		for word: String in ["clic", "mouse", "tecla", "espacio", "[p]", "[f]"]:
			assert_false(text.contains(word), "celular \"%s\" menciona «%s»" % [step["paso"], word])


func test_the_pc_texts_do_not_talk_about_touch() -> void:
	var data: TutorialData = TutorialData.load_file()
	for step: Dictionary in data.steps_for(false):
		var text: String = String(step["texto"]).to_lower()
		for word: String in ["carrito", "fantasma", "tilde", "toque", "tocá", "tocalo", "dedo"]:
			assert_false(text.contains(word), "pc \"%s\" menciona «%s»" % [step["paso"], word])


func test_the_official_texts_repeat_no_numbers_from_other_data() -> void:
	var data: TutorialData = TutorialData.load_file()
	for mobile: bool in [false, true]:
		for step: Dictionary in data.steps_for(mobile):
			var text: String = step["texto"]
			var digits: RegEx = RegEx.create_from_string("[0-9]")
			var matches: Array[RegExMatch] = digits.search_all(text)
			# Solo el «1» de «la tecla 1» (nombre de una tecla); nunca costos, porcentajes ni tiempos.
			assert_true(matches.size() <= 1, "%s: números en el texto" % step["paso"])
