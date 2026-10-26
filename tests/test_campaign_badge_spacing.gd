# Geometría de las insignias del mapa (T500, RF-690, RF-695): los bordes de 26 px de radio de dos regiones nunca se pisan, a la
# escala con la que se dibuja el atlas, y entre vecinas queda una holgura mínima.
extends GutTest

## Holgura mínima, en px lógicos, entre los bordes de dos insignias (la medida actual del par más apretado, 12–13, es 4,2).
const MIN_BADGE_GAP: float = 4.0


func _screen_distance(i: int, j: int) -> float:
	return CampaignMap.REGION_POINTS[i].distance_to(CampaignMap.REGION_POINTS[j]) * CampaignMapView.MAP_SCALE


func test_no_two_badges_overlap_at_the_map_scale() -> void:
	var diameter: float = CampaignRegion.BADGE_EDGE * 2.0
	for i: int in CampaignMap.REGION_COUNT:
		for j: int in range(i + 1, CampaignMap.REGION_COUNT):
			assert_gte(_screen_distance(i, j) - diameter, MIN_BADGE_GAP, "las insignias %d y %d no se pisan (holgura mínima %s px)" % [i + 1, j + 1, MIN_BADGE_GAP])


func test_overlap_check_would_catch_two_badges_too_close() -> void:
	# Control del propio test: con el radio exterior de la insignia en 28 px el par 12–13 ya no tendría la holgura.
	assert_lt(_screen_distance(11, 12) - 56.0, MIN_BADGE_GAP, "con un borde de 28 px el par 12–13 se pasaría de la holgura")


func test_neighbours_keep_their_gap_along_the_route() -> void:
	var tightest: int = -1
	var smallest: float = INF
	for i: int in CampaignMap.REGION_COUNT - 1:
		var gap: float = _screen_distance(i, i + 1) - CampaignRegion.BADGE_EDGE * 2.0
		if gap < smallest:
			smallest = gap
			tightest = i
	assert_eq(tightest, 11, "el par más apretado es el 12–13")
	assert_gte(smallest, MIN_BADGE_GAP)
	# Los tramos 1–3 que se sospechaban apretados tienen holgura de sobra.
	assert_gt(_screen_distance(0, 1) - CampaignRegion.BADGE_EDGE * 2.0, 20.0, "1–2")
	assert_gt(_screen_distance(1, 2) - CampaignRegion.BADGE_EDGE * 2.0, 20.0, "2–3")


func test_touch_areas_do_not_overlap_either() -> void:
	for i: int in CampaignMap.REGION_COUNT - 1:
		assert_gte(_screen_distance(i, i + 1), CampaignRegion.TOUCH_MIN, "áreas táctiles de %d y %d" % [i + 1, i + 2])


func test_badge_edges_stay_inside_the_canvas() -> void:
	var view := CampaignMapView.new()
	add_child_autofree(view)
	var entries: Array[Dictionary] = []
	for i: int in CampaignMap.REGION_COUNT:
		entries.append({"name": "N%d" % i, "place": "", "stars": 0, "state": CampaignMap.State.AVAILABLE})
	view.setup(entries)
	for i: int in CampaignMap.REGION_COUNT:
		var region: CampaignRegion = view.region(i)
		var center: Vector2 = region.position + region.size / 2.0
		var rect := Rect2(center - Vector2.ONE * CampaignRegion.BADGE_EDGE, Vector2.ONE * CampaignRegion.BADGE_EDGE * 2.0)
		assert_true(Rect2(Vector2.ZERO, CampaignMapView.CANVAS_SIZE).encloses(rect), "el borde de la insignia %d entra en el lienzo" % (i + 1))
