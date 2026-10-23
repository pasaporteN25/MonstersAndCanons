# Tests del fondo temático de las tarjetas de campaña desktop (T426).
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_SAVE: String = "user://test_campaign_card_background.json"
const COMMUNITY: String = "user://test_campaign_card_background_community/"


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	GameFlow.select_page = &"campaign"


func after_each() -> void:
	await get_tree().process_frame
	GameFlow.select_page = &"campaign"
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _open() -> Control:
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = COMMUNITY + "official/"
	select.modes_user_dir = COMMUNITY + "user/"
	add_child_autofree(select)
	return select


func _campaign_cards(select: Control) -> Array[Button]:
	var cards: Array[Button] = []
	for node: Node in (select.get_node("%Cards") as Node).get_children():
		if node is Button:
			cards.append(node)
	return cards

func test_each_desktop_card_background_comes_from_its_level_theme() -> void:
	if UiMode.is_mobile():
		pending("el fondo temático es solo de desktop")
		return
	var select: Control = _open()
	var cards: Array[Button] = _campaign_cards(select)
	assert_eq(cards.size(), GameFlow.level_count(), "una tarjeta por nivel")
	var themes_seen: Array[StringName] = []
	for i: int in cards.size():
		var theme_id: StringName = GameFlow.level(i).theme
		var backdrop: TextureRect = cards[i].get_node_or_null("ThemeBackdrop")
		assert_not_null(backdrop, "la tarjeta %d tiene fondo" % (i + 1))
		if backdrop == null:
			continue
		assert_eq(backdrop.texture, MapThemes.ground_texture(theme_id), "el fondo de la tarjeta %d es el suelo de %s" % [i + 1, theme_id])
		var edge: Color = MapThemes.palette(theme_id)["edge"]
		var scrim: ColorRect = cards[i].get_node("ThemeScrim")
		assert_eq(Color(scrim.color, 1.0), Color(edge.darkened(select.CAMPAIGN_SCRIM_DARKEN), 1.0), "el velo sale del borde de %s" % theme_id)
		if not themes_seen.has(theme_id):
			themes_seen.append(theme_id)
	assert_gt(themes_seen.size(), 1, "la campaña no usa un único tema")


func test_card_background_stays_low_contrast_and_behind_the_content() -> void:
	if UiMode.is_mobile():
		pending("el fondo temático es solo de desktop")
		return
	for card: Button in _campaign_cards(_open()):
		var backdrop: TextureRect = card.get_node("ThemeBackdrop")
		var scrim: ColorRect = card.get_node("ThemeScrim")
		assert_lt(backdrop.self_modulate.a, 0.4, "el suelo es tenue")
		assert_gt(scrim.color.a, 0.5, "el velo oscuro sostiene el contraste")
		assert_eq(backdrop.get_index(), 0, "el suelo va detrás de todo")
		assert_eq(scrim.get_index(), 1, "el velo va justo encima del suelo")
		for node: Control in [backdrop, scrim]:
			assert_eq(node.mouse_filter, Control.MOUSE_FILTER_IGNORE, "no traga clics")
		assert_true(card.clip_contents, "el fondo no se sale de la tarjeta")
		for child_name: String in ["LevelNumber", "LevelName", "Stars", "Status", "TowerIcons"]:
			var content: Node = card.get_node_or_null(child_name)
			assert_not_null(content, "%s sigue en la tarjeta" % child_name)
			if content != null:
				assert_gt(content.get_index(), scrim.get_index(), "%s se dibuja sobre el velo" % child_name)


func test_locked_card_dims_its_background_without_losing_the_alpha() -> void:
	if UiMode.is_mobile():
		pending("el fondo temático es solo de desktop")
		return
	var select: Control = _open()
	var cards: Array[Button] = _campaign_cards(select)
	var locked: Button = cards[cards.size() - 1]
	assert_true(locked.disabled, "el último nivel empieza bloqueado")
	var backdrop: TextureRect = locked.get_node("ThemeBackdrop")
	assert_lt(backdrop.modulate.r, 1.0, "el fondo se atenúa con la tarjeta")
	assert_almost_eq(backdrop.self_modulate.a, select.CAMPAIGN_BACKDROP_ALPHA, 0.001, "su alpha propio se conserva")


func test_community_cards_have_no_theme_background() -> void:
	var select: Control = _open()
	select.show_page(&"community")
	assert_false(select.get_node("%StyleSwitch").visible, "la vista alternativa solo aplica a la campaña")
	for card: Button in _campaign_cards(select):
		assert_null(card.get_node_or_null("ThemeBackdrop"), "la comunidad queda intacta")
