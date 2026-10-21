# El contenido oficial de «Novedades de esta versión» (M67, RF-605, T374): la entrada de la 1.0.0 es válida y los
# números que escribe coinciden con el juego (la cantidad de niveles, los niveles de cada torre). Si el juego
# cambia y el texto no, este test avisa.
extends GutTest

var _data: NewsData = NewsData.load_file()


func _entry() -> Dictionary:
	return _data.entry_for("1.0.0")


func test_the_official_file_is_valid_and_has_the_1_0_0_presentation() -> void:
	assert_eq(_data.errors, PackedStringArray())
	assert_false(_entry().is_empty(), "hay una entrada 1.0.0")
	assert_eq(_entry()["tipo"], "presentacion")


func test_the_first_version_in_the_file_is_the_newest() -> void:
	assert_eq(_data.latest()["id"], "1.0.0", "la lista va de la más nueva a la más vieja")


func test_the_level_count_in_the_text_matches_the_campaign() -> void:
	var found: bool = false
	for item: Dictionary in _entry()["novedades"]:
		var title: String = String(item["titulo"])
		if title.contains("niveles"):
			var number: int = int(title.split(" ")[0])
			assert_eq(number, GameFlow.level_count(), "«%s» tiene que decir la cantidad de niveles de campaign.json" % title)
			found = true
	assert_true(found, "alguna novedad habla de los niveles de la campaña")


func test_every_tower_has_the_three_levels_the_text_promises() -> void:
	var mentions: bool = false
	for item: Dictionary in _entry()["novedades"]:
		if String(item["texto"]).contains("tres niveles"):
			mentions = true
	assert_true(mentions, "una novedad dice que las torres tienen tres niveles")
	var dir: DirAccess = DirAccess.open("res://data/towers")
	for file: String in dir.get_files():
		var name: String = file.trim_suffix(".remap")
		if name.ends_with(".tres"):
			var tower: TowerData = load("res://data/towers/" + name) as TowerData
			assert_eq(tower.levels.size(), 3, "%s tiene tres niveles" % name)


func test_the_text_does_not_repeat_other_numbers() -> void:
	# D-143: salvo la cantidad de niveles y «tres niveles» (comprobados arriba), no se escriben cifras que queden viejas.
	for item: Dictionary in _entry()["novedades"]:
		var text: String = "%s %s" % [item["titulo"], item["texto"]]
		var digits: RegEx = RegEx.new()
		digits.compile("\\d+")
		for found: RegExMatch in digits.search_all(text):
			assert_eq(found.get_string().to_int(), GameFlow.level_count(), "la única cifra permitida es la de niveles: «%s»" % text)


func test_official_art_maps_each_item_to_its_approved_medallion() -> void:
	var expected: PackedStringArray = ["map", "tower", "monster", "siege", "editor", "mobile", "book"]
	assert_eq(_entry()["cabecera"], "res://assets/ui/novedades/news_header_1_0.png")
	var items: Array = _entry()["novedades"]
	assert_eq(items.size(), expected.size())
	for i: int in mini(items.size(), expected.size()):
		assert_eq(items[i]["icono"], "res://assets/ui/novedades/news_icon_%s.png" % expected[i])


func test_all_ten_approved_images_are_imported_without_mipmaps() -> void:
	var names: PackedStringArray = ["news_header_1_0", "news_header_plain", "news_icon_map", "news_icon_tower",
		"news_icon_monster", "news_icon_siege", "news_icon_editor", "news_icon_mobile", "news_icon_book", "news_icon_upgrade"]
	for name: String in names:
		var path: String = "res://assets/ui/novedades/%s.png" % name
		var texture: Texture2D = load(path) as Texture2D
		assert_not_null(texture, path)
		var config := ConfigFile.new()
		assert_eq(config.load(path + ".import"), OK)
		assert_eq(config.get_value("params", "mipmaps/generate"), false, path)
		assert_eq(config.get_value("params", "compress/mode"), 0, "compresión sin pérdida")
		assert_false(texture.get_image().has_mipmaps())
