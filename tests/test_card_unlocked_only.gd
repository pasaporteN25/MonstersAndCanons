# Tests de RF-724 (T531): la vista Tarjetas de la campaña ofrece solo niveles habilitados; el mapa y las estrellas no cambian.
# No cambian de escena y escriben solo `user://test_*.json`.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_SAVE: String = "user://test_card_unlocked_only.json"
const COMMUNITY: String = "user://test_card_unlocked_only_community/"


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


func _open(style: int) -> Control:
	SaveManager.set_setting("selector_style", style)
	var select: Control = SELECT_SCENE.instantiate()
	select.community_dir = COMMUNITY
	select.modes_official_dir = COMMUNITY + "official/"
	select.modes_user_dir = COMMUNITY + "user/"
	select.level_opener = func(_index: int) -> void: pass
	add_child_autofree(select)
	await get_tree().process_frame
	await get_tree().process_frame
	return select


func _buttons(select: Control) -> Array[Button]:
	var out: Array[Button] = []
	for child: Node in select.get_node("%Cards").get_children():
		if child is Button:
			out.append(child as Button)
	return out


func test_a_new_save_shows_only_level_one() -> void:
	var select: Control = await _open(CampaignMap.STYLE_CARDS)
	var cards: Array[Button] = _buttons(select)
	assert_eq(cards.size(), 1, "guardado nuevo: solo el nivel 1")
	assert_false(cards[0].disabled)


func test_a_partially_unlocked_campaign_shows_exactly_one_to_n() -> void:
	for i: int in range(1, 4):
		SaveManager.unlock(GameFlow.level(i).id)
	var select: Control = await _open(CampaignMap.STYLE_CARDS)
	var cards: Array[Button] = _buttons(select)
	assert_eq(cards.size(), 4, "niveles 1 a 4 y ninguno más")
	for card: Button in cards:
		assert_false(card.disabled, "toda tarjeta mostrada se puede iniciar")


func test_every_card_matches_is_level_unlocked() -> void:
	SaveManager.unlock(GameFlow.level(1).id)
	var expected: int = 0
	for i: int in GameFlow.level_count():
		if GameFlow.is_level_unlocked(i):
			expected += 1
	var select: Control = await _open(CampaignMap.STYLE_CARDS)
	assert_eq(_buttons(select).size(), expected)


func test_the_global_star_total_still_covers_the_whole_campaign() -> void:
	var select: Control = await _open(CampaignMap.STYLE_CARDS)
	var label: Label = select.get_node("%TotalStars")
	assert_eq(label.text, "Estrellas: %d de %d" % [GameFlow.total_stars(), GameFlow.max_stars()])
	assert_gt(GameFlow.max_stars(), 3, "el máximo es el de toda la campaña, no el de las tarjetas")


func test_the_map_style_still_has_the_map_and_no_cards() -> void:
	var select: Control = await _open(CampaignMap.STYLE_MAP)
	assert_not_null(select.map_view, "el mapa sigue ahí")
	assert_eq(_buttons(select).size(), 0)
	assert_false(GameFlow.is_level_unlocked(GameFlow.level_count() - 1), "el último sigue bloqueado")
	assert_true(select.map_view.is_inside_tree())
