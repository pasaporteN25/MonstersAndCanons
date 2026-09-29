# Tests de los artículos de la Guía de la wiki (T111, RF-235, RF-236).
extends GutTest

const TEST_DIR: String = "user://test_wiki_articles/"


func before_each() -> void:
	_clean()
	DirAccess.make_dir_recursive_absolute(TEST_DIR)


func after_each() -> void:
	_clean()


func _clean() -> void:
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)


func _write(file: String, text: String) -> void:
	var handle := FileAccess.open(TEST_DIR + file, FileAccess.WRITE)
	handle.store_string(text)
	handle.close()


func _ok_article(title: String, order: int) -> String:
	return '{"version": 1, "titulo": "%s", "orden": %d, "bloques": [{"tipo": "texto", "texto": "hola"}]}' % [title, order]


# --- Los artículos oficiales ---

func test_every_official_article_reads_without_errors() -> void:
	var result: Dictionary = Wiki.articles(Wiki.ARTICLES_DIR)
	assert_eq(result["errors"], PackedStringArray(), "los artículos oficiales no pueden tener errores")


func test_the_official_guide_has_its_articles_in_order() -> void:
	var entries: Array[WikiEntry] = Wiki.articles(Wiki.ARTICLES_DIR)["entries"]
	assert_gte(entries.size(), 7)
	assert_eq(entries[0].id, &"como_se_juega")
	var ids: Dictionary = {}
	for entry: WikiEntry in entries:
		assert_false(ids.has(entry.id), "id repetido: %s" % entry.id)
		ids[entry.id] = true
		assert_ne(entry.title, "")
		assert_false(entry.blocks.is_empty())


func test_the_guide_category_is_in_the_wiki() -> void:
	var found: bool = false
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == &"guia":
			found = true
			assert_not_null(category.find(&"armadura_y_dano"))
	assert_true(found)


func test_articles_do_not_repeat_numbers_that_live_in_the_data() -> void:
	# RF-235 y constitución P2: el 70 % de la venta y el 15 de la cuenta atrás viven en los datos.
	var entries: Array[WikiEntry] = Wiki.articles(Wiki.ARTICLES_DIR)["entries"]
	for entry: WikiEntry in entries:
		if entry.id == &"teclas":
			continue
		var text: String = entry.plain_text()
		assert_false(text.contains("70 %") or text.contains("70%"), "%s repite el reembolso" % entry.id)
		assert_false(text.contains("15 segundos"), "%s repite la cuenta atrás" % entry.id)


# --- Leer un artículo ---

func test_a_good_article_reads() -> void:
	var result: Dictionary = Wiki.parse_article(
		'{"version": 1, "titulo": "Uno", "subtitulo": "sub", "orden": 3, "bloques": [' +
		'{"tipo": "titulo", "texto": "T"}, {"tipo": "texto", "texto": "P"},' +
		'{"tipo": "datos", "filas": [["a", "b"]]}, {"tipo": "tabla", "filas": [["x", "y"], ["1", 2]]}]}', &"uno")
	assert_eq(result["errors"], PackedStringArray())
	var entry: WikiEntry = result["entry"]
	assert_eq(entry.title, "Uno")
	assert_eq(entry.subtitle, "sub")
	assert_eq(entry.id, &"uno")
	assert_eq(result["order"], 3)
	assert_eq(entry.blocks.size(), 4)
	assert_eq(entry.blocks[3]["filas"][1], ["1", "2"], "los valores se guardan como texto")


func test_a_broken_article_gives_its_reason_and_no_entry() -> void:
	var cases: Dictionary = {
		"{no es json": "JSON",
		"[1, 2]": "empezar con {",
		'{"version": 1, "bloques": [{"tipo": "texto", "texto": "x"}]}': "titulo",
		'{"version": 2, "titulo": "A", "bloques": [{"tipo": "texto", "texto": "x"}]}': "version",
		'{"version": 1, "titulo": "A"}': "bloques",
		'{"version": 1, "titulo": "A", "bloques": []}': "bloques",
		'{"version": 1, "titulo": "A", "bloques": [{"tipo": "video"}]}': "no existe",
		'{"version": 1, "titulo": "A", "bloques": [{"tipo": "texto"}]}': "texto",
		'{"version": 1, "titulo": "A", "bloques": [{"tipo": "datos", "filas": [["solo uno"]]}]}': "2 textos",
		'{"version": 1, "titulo": "A", "bloques": [{"tipo": "tabla", "filas": [["a", "b"], ["c"]]}]}': "columnas",
		'{"version": 1, "titulo": "A", "orden": "x", "bloques": [{"tipo": "texto", "texto": "x"}]}': "orden",
		'{"version": 1, "titulo": "A", "colores": 1, "bloques": [{"tipo": "texto", "texto": "x"}]}': "colores",
		'{"version": 1, "titulo": "A", "bloques": [5]}': "objeto",
	}
	for text: String in cases:
		var result: Dictionary = Wiki.parse_article(text, &"x")
		assert_null(result["entry"], text)
		assert_gt((result["errors"] as PackedStringArray).size(), 0, text)
		assert_string_contains("\n".join(result["errors"]), cases[text])


# --- Una carpeta de artículos ---

func test_a_folder_is_read_in_order_and_ignores_other_files() -> void:
	_write("b.json", _ok_article("Segundo", 2))
	_write("a.json", _ok_article("Primero", 1))
	_write("c.json", _ok_article("Empatado con b", 2))
	_write("notas.txt", "esto no es un artículo")
	var result: Dictionary = Wiki.articles(TEST_DIR)
	var ids: Array = []
	for entry: WikiEntry in result["entries"]:
		ids.append(entry.id)
	assert_eq(ids, [&"a", &"b", &"c"], "por orden y, si empatan, por nombre de archivo")
	assert_eq(result["errors"], PackedStringArray())


func test_a_broken_article_does_not_stop_the_others() -> void:
	_write("roto.json", "{no es json")
	_write("bueno.json", _ok_article("Bueno", 1))
	var result: Dictionary = Wiki.articles(TEST_DIR)
	assert_eq((result["entries"] as Array).size(), 1)
	assert_eq((result["errors"] as PackedStringArray).size(), 1)
	assert_string_contains(result["errors"][0], "roto.json")


func test_a_missing_folder_gives_no_articles_and_no_errors() -> void:
	var result: Dictionary = Wiki.articles("user://no_existe_esta_carpeta/")
	assert_eq((result["entries"] as Array).size(), 0)
	assert_eq((result["errors"] as PackedStringArray).size(), 0)
