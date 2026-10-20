# Tests de los datos de la intro (T242, M57: RF-497): el lector `IntroData` y los datos oficiales
# (`data/intro/intro.json`), que tienen que ser, tal cual, los textos de `specs/intro/guion.md`.
extends GutTest

const DOC_PATH: String = "res://specs/intro/guion.md"
const IMAGE: String = "res://assets/intro/01_la_nave.webp"


## Una lámina válida; `overrides` pisa campos.
func _slide(overrides: Dictionary = {}) -> Dictionary:
	var slide: Dictionary = {"imagen": IMAGE, "texto": "Una línea.\nOtra línea.", "segundos": 6}
	slide.merge(overrides, true)
	return slide


func _raw(slide_count: int = 5, overrides: Dictionary = {}) -> Dictionary:
	var slides: Array = []
	for i: int in slide_count:
		slides.append(_slide())
	var raw: Dictionary = {"version": 1, "fundido_s": 0.6, "laminas": slides}
	raw.merge(overrides, true)
	return raw


func _has_error(data: IntroData, fragment: String) -> bool:
	for error: String in data.errors:
		if error.contains(fragment):
			return true
	return false


# --- El lector ---

func test_a_valid_file_has_no_errors() -> void:
	var data: IntroData = IntroData.parse(_raw())
	assert_eq(data.errors, PackedStringArray(), "sin errores")
	assert_true(data.is_valid())
	assert_eq(data.slides.size(), 5)
	assert_eq(data.fade_s, 0.6)


func test_from_5_to_8_slides_are_accepted() -> void:
	assert_true(IntroData.parse(_raw(5)).is_valid())
	assert_true(IntroData.parse(_raw(8)).is_valid())


func test_4_and_9_slides_are_errors() -> void:
	var few: IntroData = IntroData.parse(_raw(4))
	assert_false(few.is_valid())
	assert_true(_has_error(few, "hay 4 láminas y el mínimo es 5"))
	var many: IntroData = IntroData.parse(_raw(9))
	assert_false(many.is_valid())
	assert_true(_has_error(many, "hay 9 láminas y el máximo es 8"))


func test_line_of_91_characters_is_an_error_and_90_is_not() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][2] = _slide({"texto": "a".repeat(91)})
	var data: IntroData = IntroData.parse(raw)
	assert_true(_has_error(data, "la lámina 3: la línea 1 tiene 91 caracteres y el máximo por línea es 90"))
	raw["laminas"][2] = _slide({"texto": "a".repeat(90)})
	assert_true(IntroData.parse(raw).is_valid(), "90 caracteres entra justo")


func test_three_lines_are_an_error_naming_the_slide() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][2] = _slide({"texto": "Una.\nDos.\nTres."})
	var data: IntroData = IntroData.parse(raw)
	assert_true(_has_error(data, "la lámina 3 tiene 3 líneas y el máximo es 2"))


func test_161_characters_in_total_are_an_error_and_160_are_not() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][0] = _slide({"texto": "a".repeat(80) + "\n" + "b".repeat(80)})  # 161 con el salto
	assert_true(_has_error(IntroData.parse(raw), "la lámina 1 tiene 161 caracteres y el máximo es 160"))
	raw["laminas"][0] = _slide({"texto": "a".repeat(80) + "\n" + "b".repeat(79)})
	assert_true(IntroData.parse(raw).is_valid(), "160 entra justo")


func test_empty_and_blank_texts_are_errors() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][0] = _slide({"texto": ""})
	assert_true(_has_error(IntroData.parse(raw), "la lámina 1 tiene el texto vacío"))
	raw["laminas"][0] = _slide({"texto": "   "})
	assert_true(_has_error(IntroData.parse(raw), "la lámina 1 tiene el texto vacío"))
	raw["laminas"][0] = _slide({"texto": "Algo.\n"})
	assert_true(_has_error(IntroData.parse(raw), "la lámina 1: la línea 2 está en blanco"))


func test_seconds_from_4_to_12_only() -> void:
	var raw: Dictionary = _raw()
	for seconds: Variant in [3, 13, 5.5, "7", null]:
		raw["laminas"][4] = _slide({"segundos": seconds})
		var data: IntroData = IntroData.parse(raw)
		assert_true(_has_error(data, "la lámina 5: \"segundos\" tiene que ser un entero de 4 a 12"), "segundos = %s" % str(seconds))
	for seconds: int in [4, 12]:
		raw["laminas"][4] = _slide({"segundos": seconds})
		assert_true(IntroData.parse(raw).is_valid(), "%d es válido" % seconds)
	raw["laminas"][4] = _slide({"segundos": 7.0})
	assert_true(IntroData.parse(raw).is_valid(), "JSON entrega 7 como 7.0")


func test_fade_from_0_to_2_only() -> void:
	assert_true(_has_error(IntroData.parse(_raw(5, {"fundido_s": 3})), "\"fundido_s\" tiene que ser un número de 0 a 2"))
	assert_true(_has_error(IntroData.parse(_raw(5, {"fundido_s": -0.1})), "\"fundido_s\""))
	assert_true(_has_error(IntroData.parse(_raw(5, {"fundido_s": "mucho"})), "\"fundido_s\""))
	assert_true(IntroData.parse(_raw(5, {"fundido_s": 0})).is_valid(), "0 = corte seco")
	assert_true(IntroData.parse(_raw(5, {"fundido_s": 2})).is_valid())
	var raw: Dictionary = _raw()
	raw.erase("fundido_s")
	var data: IntroData = IntroData.parse(raw)
	assert_true(data.is_valid(), "el fundido es opcional")
	assert_eq(data.fade_s, 0.6, "por omisión 0,6")


func test_missing_image_names_the_slide() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][2] = _slide({"imagen": "res://assets/intro/no_existe.webp"})
	var data: IntroData = IntroData.parse(raw)
	assert_true(_has_error(data, "la lámina 3 no encuentra la imagen `res://assets/intro/no_existe.webp`"))
	raw["laminas"][2] = _slide({"imagen": "assets/intro/01_la_nave.webp"})
	assert_true(_has_error(IntroData.parse(raw), "la lámina 3: \"imagen\" tiene que ser una ruta que empiece con res://"))


func test_other_version_is_an_error() -> void:
	assert_true(_has_error(IntroData.parse(_raw(5, {"version": 2})), "\"version\" tiene que ser 1"))
	var raw: Dictionary = _raw()
	raw.erase("version")
	assert_true(_has_error(IntroData.parse(raw), "\"version\""))


func test_wrong_shapes_do_not_crash() -> void:
	assert_false(IntroData.parse(null).is_valid())
	assert_false(IntroData.parse([]).is_valid())
	assert_false(IntroData.parse({"version": 1}).is_valid())
	assert_false(IntroData.parse({"version": 1, "laminas": "x"}).is_valid())
	var raw: Dictionary = _raw()
	raw["laminas"][1] = "una lámina"
	assert_true(_has_error(IntroData.parse(raw), "la lámina 2 tiene que ser un objeto"))


func test_control_characters_are_an_error() -> void:
	var raw: Dictionary = _raw()
	raw["laminas"][0] = _slide({"texto": "Hola\tmundo"})
	assert_true(_has_error(IntroData.parse(raw), "la lámina 1: el texto tiene caracteres de control"))


func test_missing_file_is_an_error_not_a_crash() -> void:
	var data: IntroData = IntroData.load_file("res://data/intro/no_existe.json")
	assert_false(data.is_valid())
	assert_true(_has_error(data, "no existe el archivo"))


func test_broken_json_is_an_error_not_a_crash() -> void:
	var path: String = "user://test_intro_roto.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ esto no es json")
	file.close()
	var data: IntroData = IntroData.load_file(path)
	DirAccess.remove_absolute(path)
	assert_false(data.is_valid())
	assert_true(_has_error(data, "no es un JSON válido"))


func test_reading_seconds_rule() -> void:
	assert_eq(IntroData.reading_seconds("a".repeat(59)), 5, "nunca menos de 5")
	assert_eq(IntroData.reading_seconds("a".repeat(83)), 7)
	assert_eq(IntroData.reading_seconds("a".repeat(125)), 9)


# --- Los datos oficiales ---

## Los textos del guion (§4), en orden: [{"numero", "texto"}], leídos de `specs/intro/guion.md`.
func _approved_texts() -> Array[String]:
	var doc: String = FileAccess.get_file_as_string(DOC_PATH)
	var section: String = doc.split("## 4. Las siete láminas")[1].split("## 5. Resumen")[0]
	var found: Array[String] = []
	var current: Array[String] = []
	var in_text: bool = false
	for raw: String in section.split("\n"):
		if raw.begins_with("### Lámina "):
			in_text = false
		elif raw.begins_with("**Texto**"):
			in_text = true
			current = []
		elif in_text and raw.begins_with("> "):
			current.append(raw.substr(2).strip_edges())
		elif in_text and not current.is_empty() and not raw.begins_with(">"):
			found.append("\n".join(current))
			in_text = false
	return found


func test_the_approved_document_has_the_seven_texts() -> void:
	var approved: Array[String] = _approved_texts()
	assert_eq(approved.size(), 7)
	assert_eq(approved[4], "La bajada fue brusca. El casco crujió entero, pero aguantó.")


func test_official_file_is_valid() -> void:
	var data: IntroData = IntroData.load_file()
	assert_eq(data.errors, PackedStringArray(), "el archivo oficial no tiene errores")
	assert_true(data.is_valid())
	assert_between(data.slides.size(), IntroData.MIN_SLIDES, IntroData.MAX_SLIDES)


func test_official_texts_are_exactly_the_approved_ones() -> void:
	var approved: Array[String] = _approved_texts()
	var data: IntroData = IntroData.load_file()
	assert_eq(data.slides.size(), approved.size())
	for i: int in mini(data.slides.size(), approved.size()):
		assert_eq(data.slides[i]["texto"], approved[i], "lámina %d: el texto es el del guion" % (i + 1))


func test_official_images_exist_and_are_1920_by_1080() -> void:
	for slide: Dictionary in IntroData.load_file().slides:
		var texture := load(String(slide["imagen"])) as Texture2D
		assert_not_null(texture, "carga %s" % slide["imagen"])
		if texture != null:
			assert_eq(texture.get_size(), Vector2(1920, 1080), "%s mide 1920 × 1080" % slide["imagen"])


func test_official_texts_have_no_banned_words_and_do_not_name_the_planet() -> void:
	var banned: PackedStringArray = ["enemigo", "peligro", "bestia", "salvaje", "invasor", "nativo", "indio",
		"alien", "monstruo", "malvado", "héroe", "cántaro"]
	for slide: Dictionary in IntroData.load_file().slides:
		var text: String = String(slide["texto"]).to_lower()
		for word: String in banned:
			assert_false(text.contains(word), "«%s» no va en la intro (lámina: %s)" % [word, slide["imagen"]])


func test_official_durations_are_enough_to_read() -> void:
	for slide: Dictionary in IntroData.load_file().slides:
		var needed: int = IntroData.reading_seconds(String(slide["texto"]))
		assert_gte(int(slide["segundos"]), needed, "%s: alcanza para leer" % slide["imagen"])
