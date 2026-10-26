# Tests de las insignias en la vista de tarjetas del selector (T501, RF-695): cada tarjeta de la campaña muestra la misma
# insignia V3 y el mismo estado (rebelde, partido, jugador, disponible con halo, bloqueado) que la región del mapa del mismo nivel.
# No cambian de escena (el abridor de niveles es falso) y escriben solo `user://test_*.json`.
extends GutTest

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const TEST_SAVE: String = "user://test_campaign_card_badges.json"
const COMMUNITY: String = "user://test_campaign_card_badges_community/"

var _original_mode: Variant


func before_each() -> void:
	_original_mode = SaveManager.get_setting("ui_mode")
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
	SaveManager.set_setting("ui_mode", _original_mode)


## Un progreso con todos los estados: 1 y 2 ganados (3 y 2 estrellas), 3 disponible y 4–15 bloqueados; `more` ganó
## además el 3 con una estrella y deja disponible el 4.
func _progress(more: bool = false) -> void:
	var first: LevelData = GameFlow.level(0)
	var second: LevelData = GameFlow.level(1)
	var third: LevelData = GameFlow.level(2)
	SaveManager.record_victory(first.id, first.starting_lives, 100)
	SaveManager.unlock(second.id)
	SaveManager.record_victory(second.id, int(float(second.starting_lives) * 0.5), 80)
	SaveManager.unlock(third.id)
	if more:
		SaveManager.record_victory(third.id, 1, 50)
		SaveManager.unlock(GameFlow.level(3).id)


func _open(style: int, mode: int) -> Control:
	SaveManager.set_setting("ui_mode", mode)
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


func _card_icons(select: Control) -> Array[CampaignBadgeIcon]:
	var result: Array[CampaignBadgeIcon] = []
	var cards: Node = select.find_child("Cards", true, false)
	for card: Node in cards.get_children():
		var icon: CampaignBadgeIcon = card.get_node_or_null("Badge") as CampaignBadgeIcon
		if icon != null:
			result.append(icon)
	return result


func test_every_campaign_card_has_a_badge_with_its_level_state() -> void:
	_progress(true)
	for mode: int in [2, 1]:
		var select: Control = await _open(CampaignMap.STYLE_CARDS, mode)
		var icons: Array[CampaignBadgeIcon] = _card_icons(select)
		assert_eq(icons.size(), GameFlow.level_count(), "una insignia por tarjeta (modo %d)" % mode)
		for i: int in icons.size():
			assert_eq(icons[i].level_index, i, "la insignia lleva el número de su nivel")
			assert_eq(icons[i].state, select.campaign_state(i), "estado de la tarjeta %d" % (i + 1))
		select.queue_free()
		await get_tree().process_frame


func test_cards_and_map_show_the_same_states() -> void:
	_progress(true)
	var cards_screen: Control = await _open(CampaignMap.STYLE_CARDS, 2)
	var from_cards: Array[int] = []
	for icon: CampaignBadgeIcon in _card_icons(cards_screen):
		from_cards.append(icon.state)
	cards_screen.queue_free()
	await get_tree().process_frame
	var map_screen: Control = await _open(CampaignMap.STYLE_MAP, 2)
	var view: CampaignMapView = map_screen.map_view
	assert_eq(view.region_count(), from_cards.size())
	for i: int in view.region_count():
		assert_eq(view.region(i).state, from_cards[i], "el mapa y las tarjetas coinciden en el nivel %d" % (i + 1))


func test_all_four_model_states_appear_on_cards() -> void:
	_progress(true)
	var select: Control = await _open(CampaignMap.STYLE_CARDS, 2)
	var seen: Dictionary = {}
	for icon: CampaignBadgeIcon in _card_icons(select):
		seen[icon.state] = true
		if icon.state == CampaignMap.State.AVAILABLE:
			assert_eq(CampaignMap.badge_of(icon.state), CampaignMap.Badge.REBEL, "disponible usa la insignia rebelde")
			assert_true(CampaignMap.has_halo(icon.state), "y lleva el halo")
		elif icon.state == CampaignMap.State.LOCKED:
			assert_eq(CampaignMap.badge_of(icon.state), CampaignMap.Badge.NONE, "bloqueado dibuja el candado")
			assert_false(CampaignMap.has_halo(icon.state))
	for expected: int in [CampaignMap.State.LOCKED, CampaignMap.State.AVAILABLE, CampaignMap.State.REBEL, CampaignMap.State.TAKEN]:
		assert_true(seen.has(expected), "aparece el estado %d" % expected)
	assert_eq(seen.size(), 4, "los cuatro estados del modelo; rebelde y partido comparten el estado REBEL con 1 y 2 estrellas")


func test_badge_follows_the_victory_when_the_save_changes() -> void:
	var select: Control = await _open(CampaignMap.STYLE_CARDS, 2)
	assert_eq(_card_icons(select)[0].state, CampaignMap.State.AVAILABLE, "sin victorias el primero está disponible")
	assert_eq(_card_icons(select)[1].state, CampaignMap.State.LOCKED)
	select.queue_free()
	await get_tree().process_frame
	_progress()
	select = await _open(CampaignMap.STYLE_CARDS, 2)
	assert_eq(_card_icons(select)[0].state, CampaignMap.State.TAKEN, "con 3 estrellas queda jugador")
	assert_eq(_card_icons(select)[1].state, CampaignMap.State.REBEL, "con menos queda presencia rebelde")


func test_badge_is_not_dimmed_and_does_not_take_clicks() -> void:
	_progress()
	var select: Control = await _open(CampaignMap.STYLE_CARDS, 2)
	for icon: CampaignBadgeIcon in _card_icons(select):
		assert_eq(icon.mouse_filter, Control.MOUSE_FILTER_IGNORE, "el clic sigue siendo de la tarjeta")
		assert_eq(icon.modulate, Color.WHITE, "la insignia no se atenúa ni en tarjetas bloqueadas")
	var cards: Node = select.find_child("Cards", true, false)
	var locked_card: Button = cards.get_child(5) as Button
	assert_true(locked_card.disabled, "una tarjeta bloqueada sigue deshabilitada")


func test_badge_fits_inside_the_card_corner_and_the_level_label_moves_aside_on_wide_cards() -> void:
	_progress()
	var select: Control = await _open(CampaignMap.STYLE_CARDS, 1)
	var cards: Node = select.find_child("Cards", true, false)
	var card: Control = cards.get_child(0) as Control
	var icon: CampaignBadgeIcon = card.get_node("Badge") as CampaignBadgeIcon
	var label: Label = card.get_node("LevelNumber") as Label
	assert_true(Rect2(Vector2.ZERO, card.custom_minimum_size).encloses(Rect2(icon.position, icon.size)), "la insignia entra en la tarjeta")
	assert_gte(label.position.x, icon.position.x + icon.size.x, "el rótulo «Nivel» no tapa la insignia en la tarjeta ancha")
