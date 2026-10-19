# Tests del documento editable de la intro (T321, M62: RF-561 y RF-562): la ida y la vuelta entre
# `data/intro/intro.json` y el Markdown, y los errores de un documento mal editado.
extends GutTest

const DIR: String = "user://test_intro_doc"
const IMAGE: String = "res://assets/intro/01_la_nave.png"


func after_each() -> void:
	if DirAccess.dir_exists_absolute(DIR):
		for file: String in DirAccess.get_files_at(DIR):
			DirAccess.remove_absolute(DIR + "/" + file)
		DirAccess.remove_absolute(DIR)


func _official_text() -> String:
	return FileAccess.get_file_as_string(IntroData.DEFAULT_PATH)


func _official_raw() -> Dictionary:
	var json := JSON.new()
	assert_eq(json.parse(_official_text()), OK)
	return json.data


## Un documento mínimo válido de `count` láminas; `slide_body` reemplaza el cuerpo de la lámina 1 si no está vacío.
func _doc(count: int = 5, slide_body: String = "", settings: String = "- Versión del formato: 1\n- Fundido entre láminas (segundos): 0.6\n") -> String:
	var out: String = "# Intro\n\n## Ajustes generales\n\n" + settings + "\n"
	for i: int in count:
		out += "## Lámina %d · Prueba\n\n" % (i + 1)
		if i == 0 and not slide_body.is_empty():
			out += slide_body + "\n"
		else:
			out += "- Imagen: %s\n- Segundos: 6\n- Voz o sonido: ninguno\n\nTexto:\n\n> Una línea.\n> Otra línea.\n\nNotas:\n\n" % IMAGE
	return out


func _has(list: PackedStringArray, fragment: String) -> bool:
	for item: String in list:
		if item.contains(fragment):
			return true
	return false


# --- Ida y vuelta con los datos oficiales ---

func test_official_data_round_trips_byte_for_byte() -> void:
	var markdown: String = IntroDoc.to_markdown(_official_raw())
	var result: Dictionary = IntroDoc.parse_markdown(markdown)
	assert_eq(result["errors"], PackedStringArray(), "el documento exportado se vuelve a leer sin errores")
	assert_eq(IntroDoc.to_json(result["raw"]), _official_text(), "export + import deja intro.json idéntico")


func test_to_json_matches_the_official_file_format() -> void:
	assert_eq(IntroDoc.to_json(_official_raw()), _official_text())


func test_exported_document_has_one_section_per_slide_with_the_same_content() -> void:
	var raw: Dictionary = _official_raw()
	var markdown: String = IntroDoc.to_markdown(raw)
	var result: Dictionary = IntroDoc.parse_markdown(markdown)
	var slides: Array = raw["laminas"]
	assert_eq(result["raw"]["laminas"].size(), slides.size())
	for i: int in slides.size():
		assert_true(markdown.contains("## Lámina %d · " % (i + 1)))
		assert_eq(result["raw"]["laminas"][i]["texto"], slides[i]["texto"])
		assert_eq(result["raw"]["laminas"][i]["imagen"], slides[i]["imagen"])
		assert_eq(int(result["raw"]["laminas"][i]["segundos"]), int(slides[i]["segundos"]))
	assert_eq(float(result["raw"]["fundido_s"]), float(raw["fundido_s"]))


func test_the_committed_document_matches_the_official_data() -> void:
	# `specs/intro/intro-editable.md` tiene que decir lo mismo que el JSON: si no, alguien editó uno y no el otro.
	var result: Dictionary = IntroDoc.parse_markdown(FileAccess.get_file_as_string(IntroDoc.DOC_PATH))
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(IntroDoc.to_json(result["raw"]), _official_text())


func test_the_written_file_is_read_by_the_game_loader() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var path: String = DIR + "/intro.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(IntroDoc.to_json(IntroDoc.parse_markdown(IntroDoc.to_markdown(_official_raw()))["raw"]))
	file.close()
	var data: IntroData = IntroData.load_file(path)
	assert_true(data.is_valid(), str(data.errors))
	assert_eq(data.slides.size(), 7)


func test_editing_one_text_changes_only_that_text() -> void:
	var raw: Dictionary = _official_raw()
	var markdown: String = IntroDoc.to_markdown(raw).replace("> La bajada fue brusca. El casco crujió entero, pero aguantó.", "> La bajada fue brusca.")
	var result: Dictionary = IntroDoc.parse_markdown(markdown)
	assert_eq(result["errors"], PackedStringArray())
	var changes: PackedStringArray = IntroDoc.describe_changes(raw, result["raw"])
	assert_eq(changes.size(), 1, str(changes))
	assert_true(changes[0].begins_with("lámina 5, texto:"))
	assert_eq(result["raw"]["laminas"][4]["texto"], "La bajada fue brusca.")


func test_no_edit_means_no_changes() -> void:
	var raw: Dictionary = _official_raw()
	assert_eq(IntroDoc.describe_changes(raw, IntroDoc.parse_markdown(IntroDoc.to_markdown(raw))["raw"]).size(), 0)


func test_titles_come_from_the_image_name() -> void:
	assert_eq(IntroDoc.title_of("res://assets/intro/01_la_nave.png"), "La nave")
	assert_eq(IntroDoc.title_of("res://assets/intro/06_los_motores_apagados.png"), "Los motores apagados")
	assert_eq(IntroDoc.title_of("res://assets/intro/x.png"), "X")
	assert_eq(IntroDoc.title_of(""), "sin título")


# --- Notas ---

func test_notes_are_read_and_kept_by_image_on_export() -> void:
	var raw: Dictionary = _official_raw()
	var markdown: String = IntroDoc.to_markdown(raw).replace("## Lámina 2 · La bodega\n", "## Lámina 2 · La bodega\n")
	var with_notes: String = markdown.replace("> Era un viaje de ida.\n\nNotas:\n", "> Era un viaje de ida.\n\nNotas:\n\nProbar con menos años.\nY una pausa.\n")
	var result: Dictionary = IntroDoc.parse_markdown(with_notes)
	assert_eq(result["errors"], PackedStringArray())
	var image: String = raw["laminas"][2]["imagen"]
	assert_eq(result["notes"][image], "Probar con menos años.\nY una pausa.")
	assert_eq(result["notes"].size(), 1)
	# Al volver a exportar con esas notas, siguen en el documento y el JSON no se entera.
	var again: String = IntroDoc.to_markdown(raw, result["notes"])
	assert_true(again.contains("Probar con menos años.\nY una pausa."))
	assert_eq(IntroDoc.to_json(IntroDoc.parse_markdown(again)["raw"]), _official_text())


# --- Formatos tolerados ---

func test_comma_decimals_seconds_suffix_and_backticks_are_accepted() -> void:
	var settings: String = "- Versión del formato: 1\n- Fundido entre láminas (segundos): 0,8 s\n"
	var body: String = "- Imagen: `%s`\n- Duración: 7 s\n\nTexto:\n\n> Hola.\n" % IMAGE
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5, body, settings))
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(float(result["raw"]["fundido_s"]), 0.8)
	assert_eq(int(result["raw"]["laminas"][0]["segundos"]), 7)
	assert_eq(result["raw"]["laminas"][0]["imagen"], IMAGE)


func test_text_keeps_asterisks_and_windows_line_endings_work() -> void:
	var body: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n> Una *cosa* rara.\n" % IMAGE
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5, body).replace("\n", "\r\n"))
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(result["raw"]["laminas"][0]["texto"], "Una *cosa* rara.")


func test_fade_is_optional() -> void:
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5, "", "- Versión del formato: 1\n"))
	assert_eq(result["errors"], PackedStringArray())
	assert_false(result["raw"].has("fundido_s"))
	assert_false(IntroDoc.to_json(result["raw"]).contains("fundido_s"))


# --- Errores: cada uno en castellano y con su línea o su lámina ---

func test_a_valid_minimal_document_has_no_errors() -> void:
	var result: Dictionary = IntroDoc.parse_markdown(_doc())
	assert_eq(result["errors"], PackedStringArray())
	assert_eq(result["raw"]["laminas"].size(), 5)


func test_three_lines_are_rejected_with_the_slide() -> void:
	var body: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n> Uno.\n> Dos.\n> Tres.\n" % IMAGE
	var errors: PackedStringArray = IntroDoc.parse_markdown(_doc(5, body))["errors"]
	assert_true(_has(errors, "la lámina 1 tiene 3 líneas y el máximo es 2"), str(errors))


func test_a_missing_image_is_rejected() -> void:
	var body: String = "- Imagen: res://assets/intro/no_existe.png\n- Segundos: 6\n\nTexto:\n\n> Uno.\n"
	var errors: PackedStringArray = IntroDoc.parse_markdown(_doc(5, body))["errors"]
	assert_true(_has(errors, "la lámina 1 no encuentra la imagen `res://assets/intro/no_existe.png`"), str(errors))


func test_required_fields_are_reported_with_their_line() -> void:
	var no_seconds: String = "- Imagen: %s\n\nTexto:\n\n> Uno.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, no_seconds))["errors"], "no tiene «Segundos»"))
	var no_image: String = "- Segundos: 6\n\nTexto:\n\n> Uno.\n"
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, no_image))["errors"], "no tiene «Imagen»"))
	var no_text: String = "- Imagen: %s\n- Segundos: 6\n" % IMAGE
	var errors: PackedStringArray = IntroDoc.parse_markdown(_doc(5, no_text))["errors"]
	assert_true(_has(errors, "no tiene «Texto:»"), str(errors))
	assert_true(_has(errors, "(línea "), "dice en qué línea empieza la lámina")


func test_bad_seconds_are_rejected() -> void:
	var words: String = "- Imagen: %s\n- Segundos: muchos\n\nTexto:\n\n> Uno.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, words))["errors"], "«Segundos» tiene que ser un número entero (dice «muchos»)"))
	var too_short: String = "- Imagen: %s\n- Segundos: 3\n\nTexto:\n\n> Uno.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, too_short))["errors"], "la lámina 1: \"segundos\" tiene que ser un entero de 4 a 12"))
	var half: String = "- Imagen: %s\n- Segundos: 6,5\n\nTexto:\n\n> Uno.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, half))["errors"], "\"segundos\" tiene que ser un entero"))


func test_a_blank_text_line_and_an_empty_text_are_rejected() -> void:
	var blank: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n> Uno.\n>\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, blank))["errors"], "la lámina 1: la línea 2 está en blanco"))
	var empty: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, empty))["errors"], "la lámina 1 tiene el texto vacío"))


func test_too_long_lines_are_rejected() -> void:
	var body: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n> %s\n" % [IMAGE, "a".repeat(91)]
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, body))["errors"], "la línea 1 tiene 91 caracteres y el máximo por línea es 90"))


func test_slide_count_limits_come_from_the_game_rules() -> void:
	assert_true(_has(IntroDoc.parse_markdown(_doc(4))["errors"], "hay 4 láminas y el mínimo es 5"))
	assert_true(_has(IntroDoc.parse_markdown(_doc(9))["errors"], "hay 9 láminas y el máximo es 8"))
	assert_eq(IntroDoc.parse_markdown(_doc(8))["errors"], PackedStringArray())


func test_settings_errors() -> void:
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, "", "- Versión del formato: 2\n"))["errors"], "\"version\" tiene que ser 1"))
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, "", "- Fundido entre láminas (segundos): 3\n- Versión del formato: 1\n"))["errors"], "\"fundido_s\" tiene que ser un número de 0 a 2"))
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, "", "- Fundido entre láminas (segundos): rápido\n- Versión del formato: 1\n"))["errors"], "«Fundido entre láminas» tiene que ser un número"))
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, "", "- Fundido entre láminas (segundos): 1\n"))["errors"], "falta «Versión del formato»"))
	var no_settings: String = _doc(5).replace("## Ajustes generales", "## Otra cosa")
	var errors: PackedStringArray = IntroDoc.parse_markdown(no_settings)["errors"]
	assert_true(_has(errors, "no entiendo la sección «Otra cosa»"), str(errors))
	assert_true(_has(errors, "falta la sección «Ajustes generales»"), str(errors))


func test_unknown_repeated_and_misplaced_lines_are_reported_with_their_line() -> void:
	var unknown: String = "- Imagen: %s\n- Color: rojo\n- Segundos: 6\n\nTexto:\n\n> Uno.\n" % IMAGE
	var errors: PackedStringArray = IntroDoc.parse_markdown(_doc(5, unknown))["errors"]
	assert_true(_has(errors, "no conozco el campo «Color»"), str(errors))
	assert_true(errors[0].begins_with("línea "), "el error empieza con el número de línea")
	var repeated: String = "- Imagen: %s\n- Segundos: 6\n- Segundos: 7\n\nTexto:\n\n> Uno.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, repeated))["errors"], "«Segundos» está repetido en la lámina 1"))
	var no_quote: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\nUna línea sin comillas.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, no_quote))["errors"], "tiene que empezar con «> »"))
	var twice: String = "- Imagen: %s\n- Segundos: 6\n\nTexto:\n\n> Uno.\n\nTexto:\n\n> Dos.\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, twice))["errors"], "tiene dos bloques «Texto:»"))
	var inline: String = "- Imagen: %s\n- Segundos: 6\n- Texto: hola\n" % IMAGE
	assert_true(_has(IntroDoc.parse_markdown(_doc(5, inline))["errors"], "«Texto:» y «Notas:» van solas en su línea"))


func test_a_document_with_no_content_does_not_crash() -> void:
	var errors: PackedStringArray = IntroDoc.parse_markdown("")["errors"]
	assert_true(_has(errors, "falta la sección «Ajustes generales»"), str(errors))
	assert_true(_has(IntroDoc.parse_markdown("## Ajustes generales\n- Versión del formato: 1\n")["errors"], "hay 0 láminas y el mínimo es 5"))
	assert_gt(IntroDoc.parse_markdown("## Lámina 1\n")["errors"].size(), 0)


# --- Avisos (no bloquean) ---

func test_a_slide_too_short_to_read_is_a_warning_not_an_error() -> void:
	var body: String = "- Imagen: %s\n- Segundos: 4\n\nTexto:\n\n> %s\n> %s\n" % [IMAGE, "a".repeat(79), "b".repeat(80)]  # 160 en total
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5, body))
	assert_eq(result["errors"], PackedStringArray())
	assert_true(_has(result["warnings"], "la lámina 1 dura 4 s y su texto pide al menos"), str(result["warnings"]))


func test_a_voice_or_sound_is_a_warning() -> void:
	var body: String = "- Imagen: %s\n- Segundos: 8\n- Voz o sonido: narrador grave\n\nTexto:\n\n> Uno.\n" % IMAGE
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5, body))
	assert_eq(result["errors"], PackedStringArray())
	assert_true(_has(result["warnings"], "la intro no tiene voces ni sonidos"), str(result["warnings"]))


func test_a_wrong_heading_number_is_a_warning() -> void:
	var result: Dictionary = IntroDoc.parse_markdown(_doc(5).replace("## Lámina 2 · Prueba", "## Lámina 7 · Prueba"))
	assert_eq(result["errors"], PackedStringArray())
	assert_true(_has(result["warnings"], "el título dice «Lámina 7» pero es la 2.ª"), str(result["warnings"]))
