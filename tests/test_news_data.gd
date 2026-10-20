# «Novedades de esta versión» (M67, RF-605, T371): el archivo se lee, se valida y los errores salen en castellano
# con la versión y la novedad. Lógica pura: no abre escenas.
extends GutTest

const REAL_ICON: String = "res://assets/icon.png"


func _item(title: String = "Algo nuevo", text: String = "Una línea.") -> Dictionary:
	return {"titulo": title, "texto": text}


func _entry(id: String = "1.0.0", items: Array = []) -> Dictionary:
	return {"id": id, "tipo": "presentacion", "borrador": false, "titulo": "Monsters & Canons 1.0",
		"novedades": items if not items.is_empty() else [_item()]}


func _file(entries: Array) -> Dictionary:
	return {"version": 1, "versiones": entries, "interfaz": {"entendido": "Entendido",
		"titulo_novedades": "Novedades de esta versión", "titulo_mejoras": "Mejoras de esta versión",
		"borrador": "Borrador", "sin_novedades": "No hay novedades"}}


func _errors_text(data: NewsData) -> String:
	return "\n".join(data.errors)


func test_official_file_is_valid() -> void:
	var data: NewsData = NewsData.load_file()
	assert_eq(data.errors, PackedStringArray(), "el archivo oficial no tiene errores")
	assert_true(data.is_valid())


func test_empty_list_is_valid_and_shows_nothing() -> void:
	var data: NewsData = NewsData.parse(_file([]))
	assert_true(data.is_valid())
	assert_eq(data.latest(), {})
	assert_eq(data.entry_for_options("1.0.0"), {})


func test_valid_entry_is_read() -> void:
	var data: NewsData = NewsData.parse(_file([_entry("1.0.0")]))
	assert_true(data.is_valid(), _errors_text(data))
	assert_eq(data.entries.size(), 1)
	assert_eq(data.entry_for("1.0.0")["titulo"], "Monsters & Canons 1.0")
	assert_eq(data.entry_for("1.0.1"), {}, "se compara por igualdad exacta")
	assert_eq(String(data.labels["entendido"]), "Entendido")


func test_missing_file_and_broken_json_give_one_error_and_no_entries() -> void:
	var missing: NewsData = NewsData.load_file("res://no/existe.json")
	assert_false(missing.is_valid())
	assert_true(missing.entries.is_empty())
	var path: String = "user://test_news_roto.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ esto no es json")
	file.close()
	var broken: NewsData = NewsData.load_file(path)
	assert_false(broken.is_valid())
	assert_true(_errors_text(broken).contains("no es un JSON válido"))
	DirAccess.remove_absolute(path)


func test_three_problems_give_three_errors_naming_version_and_item() -> void:
	var long_text: Dictionary = _item("Novedad larga", "uno\ndos\ntres")
	var bad_icon: Dictionary = _item("Con ícono roto")
	bad_icon["icono"] = "res://no/existe.png"
	var data: NewsData = NewsData.parse(_file([_entry("1.0.0", [long_text, bad_icon]), _entry("1.0.0")]))
	assert_eq(data.errors.size(), 3, _errors_text(data))
	assert_true(_errors_text(data).contains("la versión 1.0.0, novedad 1 («Novedad larga»): el texto tiene 3 líneas y el máximo es 2"))
	assert_true(_errors_text(data).contains("novedad 2 («Con ícono roto») no encuentra la imagen"))
	assert_true(_errors_text(data).contains("la versión 1.0.0 está repetida"))
	assert_true(data.entries.is_empty() or data.entries.size() == 1, "las entradas con errores no se cargan")


func test_existing_icon_is_accepted() -> void:
	var item: Dictionary = _item()
	item["icono"] = REAL_ICON
	var entry: Dictionary = _entry("1.0.0", [item])
	entry["cabecera"] = REAL_ICON
	var data: NewsData = NewsData.parse(_file([entry]))
	assert_true(data.is_valid(), _errors_text(data))
	assert_eq(data.entries[0]["novedades"][0]["icono"], REAL_ICON)


func test_limits_on_items_titles_and_text() -> void:
	var nine: Array = []
	for i: int in 9:
		nine.append(_item("Novedad %d" % i))
	assert_true(_errors_text(NewsData.parse(_file([_entry("1.0.0", nine)]))).contains("9 novedades y tiene que haber de 1 a 8"))
	var eight: Array = nine.slice(0, 8)
	assert_true(NewsData.parse(_file([_entry("1.0.0", eight)])).is_valid(), "ocho entran")
	var empty: Dictionary = _entry()
	empty["novedades"] = []
	assert_true(_errors_text(NewsData.parse(_file([empty]))).contains("0 novedades"))
	var title41: String = "x".repeat(41)
	assert_true(_errors_text(NewsData.parse(_file([_entry("1.0.0", [_item(title41)])]))).contains("41 caracteres y el máximo es 40"))
	assert_true(NewsData.parse(_file([_entry("1.0.0", [_item("x".repeat(40))])])).is_valid(), "40 caracteres entran")
	var text141: String = "y".repeat(141)
	assert_true(_errors_text(NewsData.parse(_file([_entry("1.0.0", [_item("T", text141)])]))).contains("141 caracteres y el máximo es 140"))
	assert_true(NewsData.parse(_file([_entry("1.0.0", [_item("T", "y".repeat(140))])])).is_valid())
	assert_true(NewsData.parse(_file([_entry("1.0.0", [_item("T", "uno\ndos")])])).is_valid(), "dos líneas entran")
	var blank: NewsData = NewsData.parse(_file([_entry("1.0.0", [_item("T", "uno\n")])]))
	assert_true(_errors_text(blank).contains("línea en blanco"))


func test_id_type_draft_and_subtitle_rules() -> void:
	var no_id: Dictionary = _entry()
	no_id.erase("id")
	assert_true(_errors_text(NewsData.parse(_file([no_id]))).contains("no tiene \"id\""))
	var bad_type: Dictionary = _entry()
	bad_type["tipo"] = "otra"
	assert_true(_errors_text(NewsData.parse(_file([bad_type]))).contains("\"tipo\" tiene que ser"))
	var bad_draft: Dictionary = _entry()
	bad_draft["borrador"] = "no"
	assert_true(_errors_text(NewsData.parse(_file([bad_draft]))).contains("\"borrador\" tiene que ser true o false"))
	var long_sub: Dictionary = _entry()
	long_sub["subtitulo"] = "s".repeat(81)
	assert_true(_errors_text(NewsData.parse(_file([long_sub]))).contains("\"subtitulo\" tiene 81 caracteres"))


func test_file_shape_errors() -> void:
	assert_false(NewsData.parse([]).is_valid())
	assert_false(NewsData.parse({"version": 2, "versiones": []}).is_valid())
	var no_labels: Dictionary = _file([])
	no_labels.erase("interfaz")
	assert_true(_errors_text(NewsData.parse(no_labels)).contains("\"interfaz\""))
	var no_list: Dictionary = _file([])
	no_list.erase("versiones")
	assert_true(_errors_text(NewsData.parse(no_list)).contains("\"versiones\""))


func test_options_entry_is_the_installed_one_or_the_newest() -> void:
	var newest: Dictionary = _entry("1.1.0")
	var data: NewsData = NewsData.parse(_file([newest, _entry("1.0.0")]))
	assert_eq(data.entry_for_options("1.0.0")["id"], "1.0.0")
	assert_eq(data.entry_for_options("beta")["id"], "1.1.0", "sin entrada para la versión, la más nueva")


func test_warnings_only_for_numeric_versions_without_an_approved_entry() -> void:
	var draft: Dictionary = _entry("1.0.0")
	draft["borrador"] = true
	var data: NewsData = NewsData.parse(_file([draft]))
	assert_true(data.warnings_for("beta").is_empty(), "beta no avisa")
	assert_true(data.warnings_for("").is_empty())
	assert_eq(data.warnings_for("1.0.0").size(), 1, "en borrador avisa")
	assert_eq(data.warnings_for("1.2.0").size(), 1, "sin entrada avisa")
	assert_true(NewsData.parse(_file([_entry("1.0.0")])).warnings_for("1.0.0").is_empty())
