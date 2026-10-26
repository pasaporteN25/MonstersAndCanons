# Tests de las insignias de conquista del mapa planetario (T474, RF-695): el estado visual sale del progreso de cada
# nivel (sin victoria, 1–2 estrellas, 3 estrellas) y no depende de la zona ni se guarda.
extends GutTest


func test_badge_follows_victory_and_stars() -> void:
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(true, false, 0)), CampaignMap.Badge.REBEL, "sin victoria")
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(true, true, 1)), CampaignMap.Badge.SPLIT, "1 estrella")
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(true, true, 2)), CampaignMap.Badge.SPLIT, "2 estrellas, el límite superior de partido")
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(true, true, 3)), CampaignMap.Badge.PLAYER, "3 estrellas")


func test_locked_has_no_badge_even_with_stars_in_a_weird_save() -> void:
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(false, false, 0)), CampaignMap.Badge.NONE)
	assert_eq(CampaignMap.badge_of(CampaignMap.state_of(false, true, 3)), CampaignMap.Badge.NONE, "bloqueada manda sobre las estrellas")


func test_every_open_state_has_a_texture_and_locked_does_not() -> void:
	for state: int in [CampaignMap.State.AVAILABLE, CampaignMap.State.REBEL, CampaignMap.State.TAKEN]:
		var badge: CampaignMap.Badge = CampaignMap.badge_of(state as CampaignMap.State)
		assert_true(CampaignRegion.BADGES.has(badge), "estado %d" % state)
		assert_not_null(CampaignRegion.BADGES[badge])
	assert_false(CampaignRegion.BADGES.has(CampaignMap.Badge.NONE))


func test_three_badges_are_distinct_images() -> void:
	var seen: Dictionary = {}
	for badge: int in CampaignRegion.BADGES:
		var image: Image = (CampaignRegion.BADGES[badge] as Texture2D).get_image()
		seen[hash(image.get_data())] = true
	assert_eq(seen.size(), 3, "rebelde, partido y jugador se ven distintos")


func test_badge_fits_inside_the_touch_area() -> void:
	assert_lte(CampaignRegion.BADGE_RADIUS, 19.5)
	assert_gte(CampaignRegion.BADGE_RADIUS, 19.0)
	assert_lte(CampaignRegion.BADGE_EDGE * 2.0, CampaignRegion.TOUCH_MIN, "el borde de la insignia entra en el área de 56 px")


func test_region_keeps_stars_number_and_lock_data() -> void:
	var region := CampaignRegion.new()
	add_child_autofree(region)
	region.setup(9, {"state": CampaignMap.State.REBEL, "stars": 2, "name": "Diez"}, Vector2(100, 100), 56.0)
	assert_eq(region.stars, 2)
	assert_eq(CampaignMap.number_text(region.index), "10")
	assert_eq(region.size, Vector2(56, 56))
	var locked := CampaignRegion.new()
	add_child_autofree(locked)
	locked.setup(10, {"state": CampaignMap.State.LOCKED, "stars": 0, "name": "Once"}, Vector2(200, 100), 56.0)
	assert_true(locked.tooltip_text.contains("Bloqueada"), "el candado mantiene su razón de acceso en el texto")
