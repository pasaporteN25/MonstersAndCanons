# Tests de los textos por nivel (M52, T228: RF-464, RF-468, RF-473): la validación de `"textos"`, cómo
# lo lee LevelFile, cómo lo conserva el editor, y que los niveles oficiales traen los textos aprobados de
# specs/11-textos-lore.md, sin pasarse de los límites.
extends GutTest

const DOC_PATH: String = "res://specs/11-textos-lore.md"


func _parse(raw: Variant) -> Dictionary:
	var errors: PackedStringArray = []
	var texts: Dictionary = LevelTexts.parse(raw, errors)
	return {"texts": texts, "errors": errors}


# --- LevelTexts ---

func test_no_field_gives_empty_texts_and_no_errors() -> void:
	var result: Dictionary = _parse(null)
	assert_eq(result["errors"].size(), 0)
	assert_eq(result["texts"], LevelTexts.empty())


func test_each_valid_key_alone_is_read() -> void:
	assert_eq(_parse({"lugar": "El paso del agua"})["texts"]["lugar"], "El paso del agua")
	assert_eq(_parse({"entrada": "Una.\nDos.\nTres."})["texts"]["entrada"], "Una.\nDos.\nTres.")
	assert_eq(_parse({"victoria": "Una.\nDos."})["texts"]["victoria"], "Una.\nDos.")
	assert_eq(_parse({"epilogo": "Una.\nDos.\nTres."})["texts"]["epilogo"], "Una.\nDos.\nTres.")
	for result: Dictionary in [_parse({"lugar": "x"}), _parse({"entrada": "x"}), _parse({"victoria": "x"})]:
		assert_eq(result["errors"].size(), 0, str(result["errors"]))


func test_the_limits_are_accepted_exactly() -> void:
	var line: String = "a".repeat(LevelTexts.LINE_MAX_CHARS)
	assert_eq(_parse({"lugar": "a".repeat(32)})["errors"].size(), 0, "32 caracteres de lugar")
	assert_eq(_parse({"entrada": "a\nb\nc"})["errors"].size(), 0, "3 líneas")
	assert_eq(_parse({"entrada": "a".repeat(80) + "\n" + "a".repeat(80) + "\n" + "a".repeat(78)})["errors"].size(), 0, "240 caracteres (cuentan los saltos de línea)")
	assert_eq(_parse({"victoria": line + "\n" + "a".repeat(69)})["errors"].size(), 0, "160 caracteres y una línea de 90")
	assert_eq(_parse({"epilogo": "a\nb\nc\nd\ne"})["errors"].size(), 0, "5 líneas de epílogo")


func test_an_unknown_key_lists_the_valid_ones() -> void:
	var errors: PackedStringArray = _parse({"titulo": "x"})["errors"]
	assert_eq(errors.size(), 1)
	assert_string_contains(errors[0], "titulo")
	assert_string_contains(errors[0], "lugar, entrada, victoria, epilogo")


func test_a_value_that_is_not_text_is_an_error() -> void:
	assert_eq(_parse({"lugar": 5})["errors"].size(), 1)
	assert_eq(_parse({"entrada": ["a", "b"]})["errors"].size(), 1)
	assert_eq(_parse("hola")["errors"].size(), 1, "el campo entero tiene que ser un objeto")
	assert_eq(_parse([])["errors"].size(), 1)


func test_an_empty_text_is_an_error_that_says_to_remove_the_key() -> void:
	var errors: PackedStringArray = _parse({"entrada": "   "})["errors"]
	assert_eq(errors.size(), 1)
	assert_string_contains(errors[0], "\"entrada\" está vacío")
	assert_string_contains(errors[0], "sacá la clave")
	assert_eq(_parse({"lugar": ""})["errors"].size(), 1)


func test_too_many_lines_or_characters_say_how_much_and_the_maximum() -> void:
	var errors: PackedStringArray = _parse({"entrada": "a\nb\nc\nd"})["errors"]
	assert_eq(errors.size(), 1)
	assert_string_contains(errors[0], "4 líneas")
	assert_string_contains(errors[0], "máximo es 3")
	errors = _parse({"victoria": "a\nb\nc"})["errors"]
	assert_string_contains(errors[0], "3 líneas")
	errors = _parse({"entrada": "a".repeat(80) + "\n" + "a".repeat(80) + "\n" + "a".repeat(79)})["errors"]  # con los 2 saltos de línea: 241
	assert_string_contains(errors[0], "241 caracteres")
	assert_string_contains(errors[0], "240")
	errors = _parse({"lugar": "a".repeat(33)})["errors"]
	assert_string_contains(errors[0], "33 caracteres")


func test_a_line_of_91_characters_is_an_error() -> void:
	var errors: PackedStringArray = _parse({"victoria": "a".repeat(91)})["errors"]
	assert_eq(errors.size(), 1)
	assert_string_contains(errors[0], "91 caracteres")
	assert_string_contains(errors[0], "90")


func test_a_control_character_is_an_error_but_a_line_break_is_not() -> void:
	assert_eq(_parse({"victoria": "uno\u0001dos"})["errors"].size(), 1)
	assert_eq(_parse({"victoria": "uno\tdos"})["errors"].size(), 1)
	assert_eq(_parse({"victoria": "uno\ndos"})["errors"].size(), 0)


func test_a_blank_line_between_lines_is_an_error() -> void:
	assert_eq(_parse({"entrada": "uno\n\ntres"})["errors"].size(), 1)


func test_the_epilogue_needs_3_to_5_lines() -> void:
	var short: PackedStringArray = _parse({"epilogo": "a\nb"})["errors"]
	assert_eq(short.size(), 1)
	assert_string_contains(short[0], "mínimo es 3")
	var long: PackedStringArray = _parse({"epilogo": "a\nb\nc\nd\ne\nf"})["errors"]
	assert_string_contains(long[0], "6 líneas")


func test_a_wrong_key_does_not_hide_the_good_ones() -> void:
	var result: Dictionary = _parse({"lugar": "El paso", "colorinche": "x"})
	assert_eq(result["errors"].size(), 1)
	assert_eq(result["texts"]["lugar"], "El paso")


# --- LevelFile y LevelData ---

func _level_text(extra: String) -> String:
	var draft: LevelDraft = LevelDraft.new_level()
	var text: String = draft.to_text()
	return text.replace("  \"mapa\": [", extra + "  \"mapa\": [")


func test_level_file_reads_the_texts_into_the_level() -> void:
	var text: String = _level_text("  \"textos\": {\"lugar\": \"El paso\", \"entrada\": \"Una.\\nDos.\", \"victoria\": \"Listo.\"},\n")
	var result: Dictionary = LevelFile.parse(text, &"prueba")
	assert_eq(result["errors"].size(), 0, str(result["errors"]))
	var level: LevelData = result["level"]
	assert_eq(level.place_text, "El paso")
	assert_eq(level.intro_text, "Una.\nDos.")
	assert_eq(level.win_text, "Listo.")
	assert_eq(level.epilogue_text, "")
	assert_true(level.has_texts())


func test_a_level_without_the_field_is_read_as_before() -> void:
	var result: Dictionary = LevelFile.parse(LevelDraft.new_level().to_text(), &"prueba")
	assert_eq(result["errors"].size(), 0)
	var level: LevelData = result["level"]
	assert_false(level.has_texts())
	assert_eq(level.intro_text, "")


func test_level_file_reports_a_bad_text_and_refuses_the_level() -> void:
	var text: String = _level_text("  \"textos\": {\"entrada\": \"a\\nb\\nc\\nd\"},\n")
	var result: Dictionary = LevelFile.parse(text, &"prueba")
	assert_null(result["level"])
	assert_string_contains("\n".join(result["errors"]), "4 líneas")


func test_the_editor_keeps_the_texts_when_it_opens_and_writes_a_level() -> void:
	var text: String = _level_text("  \"textos\": {\n    \"lugar\": \"El paso\",\n    \"entrada\": \"Una.\\nDos.\"\n  },\n")
	var draft: LevelDraft = LevelDraft.from_text(text, "prueba")
	assert_not_null(draft)
	assert_eq(draft.to_text(), text, "el editor escribe el campo tal cual lo leyó")
	var result: Dictionary = draft.check()
	assert_eq(result["errors"].size(), 0, str(result["errors"]))
	assert_eq((result["level"] as LevelData).intro_text, "Una.\nDos.")
	# Una plantilla de un nivel oficial también lo conserva (RF-216).
	var official: LevelDraft = LevelDraft.open_official("level_08")
	assert_true(official.to_text().contains("\"El bastión sobre ruinas\""))
	assert_eq(LevelFile.parse(official.to_text(), &"copia")["errors"].size(), 0)


func test_the_editor_does_not_invent_the_field() -> void:
	var draft: LevelDraft = LevelDraft.from_text(LevelDraft.new_level().to_text(), "prueba")
	assert_false(draft.to_text().contains("textos"))


# --- Los niveles oficiales (RF-473) ---

## Los textos aprobados, leídos de specs/11-textos-lore.md: {número de nivel → {lugar, entrada, victoria}}.
func _approved_texts() -> Dictionary:
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var section: String = doc.split("## 1. Los 15 niveles")[1].split("## 2. Epílogo")[0]
	var found: Dictionary = {}
	var current: int = 0
	var field: String = ""
	var level_header := RegEx.create_from_string("^### Nivel (\\d+) ·")
	var place_line := RegEx.create_from_string("^- \\*\\*Lugar\\*\\* \\(\\d+ caracteres\\): (.*)$")
	for raw: String in section.split("\n"):
		var header := level_header.search(raw)
		if header != null:
			current = int(header.get_string(1))
			found[current] = {"lugar": "", "entrada": [], "victoria": []}
			continue
		if current == 0:
			continue
		var place := place_line.search(raw)
		if place != null:
			found[current]["lugar"] = place.get_string(1).strip_edges()
		elif raw.begins_with("- **Entrada**"):
			field = "entrada"
		elif raw.begins_with("- **Victoria**"):
			field = "victoria"
		elif raw.begins_with("  - ") and field != "":
			(found[current][field] as Array).append(raw.substr(4).strip_edges())
	return found


func test_the_approved_document_has_the_15_levels() -> void:
	var approved: Dictionary = _approved_texts()
	assert_eq(approved.size(), 15)
	assert_eq((approved[8]["entrada"] as Array).size(), 3)


func test_official_levels_carry_exactly_the_approved_texts_within_the_limits() -> void:
	var approved: Dictionary = _approved_texts()
	var checked: int = 0
	for i: int in GameFlow.level_count():
		var level: LevelData = GameFlow.level(i)
		var number: int = i + 1
		assert_true(approved.has(number), "el documento no trae el nivel %d" % number)
		var want: Dictionary = approved[number]
		assert_eq(level.place_text, want["lugar"], "lugar del nivel %d" % number)
		assert_eq(level.intro_text, "\n".join(want["entrada"]), "entrada del nivel %d" % number)
		assert_eq(level.win_text, "\n".join(want["victoria"]), "victoria del nivel %d" % number)
		# Y cumplen los límites de RF-464 (volviéndolos a pasar por el validador).
		var errors: PackedStringArray = []
		LevelTexts.parse({"lugar": level.place_text, "entrada": level.intro_text, "victoria": level.win_text}, errors)
		assert_eq(errors.size(), 0, "nivel %d: %s" % [number, str(errors)])
		checked += 1
	assert_eq(checked, GameFlow.level_count())
	assert_gte(checked, 10)


func test_official_texts_avoid_the_banned_vocabulary() -> void:
	var banned: PackedStringArray = ["enemigo", "salvaje", "invasor", "nativo", "alien", "peligroso", "bestia"]
	for i: int in GameFlow.level_count():
		var level: LevelData = GameFlow.level(i)
		var all: String = (level.place_text + " " + level.intro_text + " " + level.win_text).to_lower()
		for word: String in banned:
			assert_false(all.contains(word), "nivel %d dice «%s»" % [i + 1, word])


func test_no_official_level_explains_the_signals_before_the_8() -> void:
	# Biblia §8: ningún texto de los niveles 1 a 5 explica las señales (la roca marcada, el sendero…).
	for i: int in 5:
		var all: String = (GameFlow.level(i).intro_text + " " + GameFlow.level(i).win_text).to_lower()
		assert_false(all.contains("marca"), "el nivel %d habla de la marca antes del 8" % (i + 1))
