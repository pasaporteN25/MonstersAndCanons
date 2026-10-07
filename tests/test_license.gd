# La licencia del juego (M48, RF-387, D-077): el texto oficial en LICENSE y el artículo de la Wiki.
extends GutTest


func test_license_file_is_the_gpl_version_3() -> void:
	var file := FileAccess.open("res://LICENSE", FileAccess.READ)
	assert_not_null(file, "RF-387: LICENSE en la raíz")
	if file == null:
		return
	var text: String = file.get_as_text()
	assert_true(text.contains("GNU GENERAL PUBLIC LICENSE"))
	assert_true(text.contains("Version 3, 29 June 2007"))
	assert_true(text.contains("END OF TERMS AND CONDITIONS"), "el texto está completo, no recortado")


func test_wiki_explains_the_game_and_engine_licenses() -> void:
	var article: WikiEntry = null
	for entry: WikiEntry in Wiki.articles(Wiki.ARTICLES_DIR)["entries"]:
		if entry.id == &"licencias":
			article = entry
	assert_not_null(article, "RF-387: artículo Licencias en la guía")
	if article == null:
		return
	var text: String = article.plain_text()
	assert_true(text.contains("GPL") and text.contains("versión 3"), "la licencia del juego")
	assert_true(text.contains("cualquier versión posterior"), "GPL-3.0-or-later")
	assert_true(text.contains("Godot") and text.contains("MIT"), "la licencia del motor")
	assert_true(text.contains("Godot Engine contributors"), "con su aviso de copyright")
	assert_true(text.contains("FreeType"), "el crédito que pide FreeType")
	assert_true(text.contains("GUT"), "aclara que la herramienta de tests no va en los ejecutables")
