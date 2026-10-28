# El fondo propio de la presentación de jefes (T548): solo el Coloso lo tiene y todo falla hacia el fondo liso.
extends GutTest

const COLOSSUS_BACKDROP: String = "res://assets/backgrounds/boss/colossus.png"


func _data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


func _art_nodes(presentation: BossPresentation) -> Array:
	return [presentation.find_child("BackdropArt", true, false), presentation.find_child("TextShade", true, false)]


func test_colossus_gets_the_backdrop() -> void:
	var texture: Texture2D = BossPresentationArt.backdrop_for("colossus")
	assert_not_null(texture)
	assert_eq(texture.resource_path, COLOSSUS_BACKDROP)
	var presentation: BossPresentation = BossPresentation.new().setup(_data("colossus"), 5.0, false, null, texture)
	add_child_autofree(presentation)
	var nodes: Array = _art_nodes(presentation)
	assert_not_null(nodes[0], "con fondo hay BackdropArt")
	assert_not_null(nodes[1], "y la franja de contraste")
	assert_eq((nodes[0] as TextureRect).stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED, "cover: recorta, no deforma")


func test_other_enemies_get_no_backdrop() -> void:
	for id: String in ["boss", "grunt", "goblin"]:
		if ResourceLoader.exists("res://data/enemies/%s.tres" % id):
			assert_null(BossPresentationArt.backdrop_for(id), id)
	var boss: BossPresentation = BossPresentation.new().setup(_data("boss"), 5.0, false, null, BossPresentationArt.backdrop_for("boss"))
	add_child_autofree(boss)
	assert_null(_art_nodes(boss)[0], "el Jefe sigue con la composición provisional")
	assert_null(_art_nodes(boss)[1])


func test_missing_resource_falls_back_without_crashing() -> void:
	var catalog: Dictionary = {"jefes": {"colossus": {"fondo": "res://assets/backgrounds/boss/no_existe.png"}}}
	assert_eq(BossPresentationArt.backdrop_path(catalog, "colossus"), "res://assets/backgrounds/boss/no_existe.png")
	assert_null(BossPresentationArt.backdrop_for("colossus", "user://no_existe_boss_presentation.json"))
	var presentation: BossPresentation = BossPresentation.new().setup(_data("colossus"), 5.0, false, null, null)
	add_child_autofree(presentation)
	assert_not_null(presentation.find_child("Backdrop", true, false), "queda el fondo liso de código")
	assert_null(_art_nodes(presentation)[0])


func test_malformed_catalog_is_ignored() -> void:
	assert_eq(BossPresentationArt.backdrop_path(null, "colossus"), "")
	assert_eq(BossPresentationArt.backdrop_path({"jefes": 3}, "colossus"), "")
	assert_eq(BossPresentationArt.backdrop_path({"jefes": {"colossus": {"fondo": "http://x/y.png"}}}, "colossus"), "")
	assert_eq(BossPresentationArt.backdrop_path({"jefes": {"colossus": {"fondo": 7}}}, "colossus"), "")


func test_shade_comes_from_data_and_can_be_turned_off() -> void:
	var shade: Dictionary = BossPresentationArt.shade()
	assert_between(float(shade["opacidad"]), 0.5, 1.0)
	assert_between(float(shade["alto"]), 0.3, 0.8)
	var off: Dictionary = BossPresentationArt.shade({"degradado": {"opacidad": 0}})
	assert_eq(float(off["opacidad"]), 0.0)
	var clamped: Dictionary = BossPresentationArt.shade({"degradado": {"opacidad": 9, "alto": -1}})
	assert_eq(float(clamped["opacidad"]), 1.0)
	assert_eq(float(clamped["alto"]), 0.0)
	var presentation: BossPresentation = BossPresentation.new().setup(_data("colossus"), 5.0, false, null, BossPresentationArt.backdrop_for("colossus"))
	add_child_autofree(presentation)
	var rect: TextureRect = presentation.find_child("TextShade", true, false)
	assert_almost_eq(rect.anchor_top, 1.0 - float(shade["alto"]), 0.001)
	assert_eq(rect.mouse_filter, Control.MOUSE_FILTER_IGNORE)
