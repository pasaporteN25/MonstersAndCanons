# Rótulos del mapa de campaña (T515, RF-695): «N · Nombre» solo en la región elegida o con foco; el resto, el número en la
# insignia. El rótulo completo no se sale del lienzo ni tapa la insignia (ni las estrellas) de ninguna otra región, en los 15 niveles.
extends GutTest

var _view: CampaignMapView


func before_each() -> void:
	_view = CampaignMapView.new()
	add_child_autofree(_view)


## Los 15 niveles con sus nombres reales; `mix` alterna estados y estrellas para que haya de todo.
func _entries(mix: bool) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for i: int in GameFlow.level_count():
		var level: LevelData = GameFlow.level(i)
		var state: CampaignMap.State = CampaignMap.State.TAKEN
		var stars: int = 3
		if mix:
			var states: Array[CampaignMap.State] = [CampaignMap.State.TAKEN, CampaignMap.State.REBEL, CampaignMap.State.AVAILABLE, CampaignMap.State.LOCKED]
			state = states[i % 4]
			stars = 2 if state == CampaignMap.State.REBEL else (3 if state == CampaignMap.State.TAKEN else 0)
		entries.append({"name": level.display_name, "place": level.place_text, "stars": stars, "state": state})
	return entries


func _full_captions() -> Array[int]:
	var result: Array[int] = []
	for i: int in _view.region_count():
		if _view.region(i).caption_text().contains("·"):
			result.append(i)
	return result


func test_only_the_selected_region_shows_number_and_name() -> void:
	_view.setup(_entries(false), 11)
	await get_tree().process_frame
	assert_eq(_full_captions(), [11] as Array[int], "solo la elegida lleva «N · Nombre»")
	assert_eq(_view.region(11).caption_text(), "12 · %s" % GameFlow.level(11).display_name)
	for i: int in _view.region_count():
		if i != 11:
			assert_eq(_view.region(i).caption_text(), "", "la región %d no lleva rótulo (el número va en la insignia)" % (i + 1))


func test_focus_shows_the_caption_and_moving_it_moves_the_caption() -> void:
	_view.setup(_entries(false), 9)
	await get_tree().process_frame
	_view.region(10).grab_focus()
	await get_tree().process_frame
	assert_eq(_full_captions(), [10] as Array[int], "el foco lleva la selección y con ella el rótulo")
	assert_true(_view.region(10).has_focus())


func test_focus_alone_shows_the_caption() -> void:
	_view.setup(_entries(false), 9)
	await get_tree().process_frame
	var region: CampaignRegion = _view.region(3)
	assert_eq(region.caption_text(), "")
	region.grab_focus()  # sin pasar por la vista: solo el foco
	region._selected = false
	assert_true(region.shows_full_caption(), "con foco y sin selección también lleva el rótulo")


func test_locked_regions_keep_only_their_number_until_chosen() -> void:
	_view.setup(_entries(true), 0)
	await get_tree().process_frame
	var locked: CampaignRegion = _view.region(3)  # i % 4 == 3
	assert_eq(locked.state, CampaignMap.State.LOCKED)
	assert_eq(locked.caption_text(), "4", "el candado no tiene número adentro: lo lleva debajo, a secas")
	_view.select(3)
	assert_eq(locked.caption_text(), "4 · %s" % GameFlow.level(3).display_name)


func test_hidden_zone_regions_have_no_caption() -> void:
	var entries: Array[Dictionary] = _entries(false)
	for i: int in range(5, 15):
		entries[i]["state"] = CampaignMap.State.LOCKED
	_view.setup(entries, 0)
	await get_tree().process_frame
	assert_false(_view.region(8).discovered or _view.region(12).discovered, "zonas B y C sin descubrir")
	assert_eq(_view.region(8).caption_text(), "")


func test_selected_caption_stays_in_canvas_and_clear_of_every_other_badge_in_all_15() -> void:
	for mix: bool in [false, true]:
		_view.setup(_entries(mix), 0)
		await get_tree().process_frame
		var bounds := Rect2(Vector2.ZERO, CampaignMapView.CANVAS_SIZE)
		for i: int in _view.region_count():
			_view.select(i)
			var rect: Rect2 = _view.region(i).caption_rect()
			assert_gt(rect.size.x, 0.0, "la región %d tiene rótulo" % (i + 1))
			assert_true(bounds.encloses(rect), "el rótulo de %d (%s) cabe en el lienzo %s" % [i + 1, rect, bounds])
			for j: int in _view.region_count():
				if j == i:
					continue
				var other: CampaignRegion = _view.region(j)
				for obstacle: Rect2 in CampaignRegion.obstacle_rects(other.position + other.size / 2.0, other.state, other.stars):
					assert_false(rect.intersects(obstacle), "el rótulo de %d no tapa a %d (mix=%s)" % [i + 1, j + 1, mix])
				var other_caption: Rect2 = other.caption_rect()
				if other_caption.size.x > 0.0:
					assert_false(rect.intersects(other_caption), "el rótulo de %d no pisa al de %d" % [i + 1, j + 1])


func test_control_the_old_82px_caption_under_every_region_did_overlap_neighbours() -> void:
	# Control del propio test: con un rótulo fijo de 82 px debajo de cada insignia (como antes) varios pares se pisan.
	_view.setup(_entries(false), 0)
	var overlaps: int = 0
	for i: int in _view.region_count():
		var center: Vector2 = _view.region(i).position + _view.region(i).size / 2.0
		var old_rect := Rect2(center + Vector2(-41.0, CampaignRegion.BADGE_EDGE + 6.0), Vector2(82.0, 13.0))
		for j: int in _view.region_count():
			if j != i:
				var other: CampaignRegion = _view.region(j)
				for obstacle: Rect2 in CampaignRegion.obstacle_rects(other.position + other.size / 2.0, other.state, other.stars):
					if old_rect.intersects(obstacle):
						overlaps += 1
	assert_gt(overlaps, 0, "el rótulo fijo de antes sí tapaba insignias vecinas")
