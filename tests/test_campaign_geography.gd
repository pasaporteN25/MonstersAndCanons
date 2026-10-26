# Tests de la geografía integrada del selector planetario (T471, RF-691, RF-698, D-200): el aterrizaje, las 15 regiones y
# el recorrido en tierra, de oeste a este y sin cruces; el modelo (`CampaignMap`) y el fondo (SVG de runtime) comparten
# coordenadas; y la vista conserva selección y foco en ambos extremos con áreas táctiles de 56 px.
extends GutTest

const BACKGROUND_PATH: String = "res://assets/ui/campaign_map_background.svg"
const ROUTE_JSON: String = "res://art/t485-atlas-biomas/route_points.json"
## Margen mínimo a la costa (unidades del atlas, 1240×472) del aterrizaje, de los marcadores y del recorrido.
const LANDER_MARGIN: float = 40.0
const REGION_MARGIN: float = 25.0
const ROUTE_MARGIN: float = 20.0
const CURVE_STEPS: int = 4


func _distance_to_coast(point: Vector2, polygon: PackedVector2Array) -> float:
	var best: float = INF
	for i: int in polygon.size():
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()])
		best = minf(best, point.distance_to(closest))
	return best


func _route_all_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in CampaignMap.REGION_COUNT:
		var segment: PackedVector2Array = CampaignMap.route_polyline(i, 40)
		points.append_array(segment)
	return points


func _entries(states: Array[CampaignMap.State]) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for i: int in states.size():
		entries.append({"name": "Nivel %d" % (i + 1), "place": "Lugar", "stars": 0, "state": states[i]})
	return entries


func _view(width: float, states: Array[CampaignMap.State]) -> CampaignMapView:
	var view := CampaignMapView.new()
	add_child_autofree(view)
	view.custom_minimum_size.x = width
	view.size = Vector2(width, CampaignMapView.VIEW_SIZE.y)
	view.setup(_entries(states))
	return view


func _all(state: CampaignMap.State) -> Array[CampaignMap.State]:
	var result: Array[CampaignMap.State] = []
	for i: int in CampaignMap.REGION_COUNT:
		result.append(state)
	return result


# --- Modelo: tierra, margen y orden ---

func test_lander_is_on_land_with_margin() -> void:
	var land: PackedVector2Array = CampaignMap.land_polygon()
	assert_true(Geometry2D.is_point_in_polygon(CampaignMap.LANDER, land), "el aterrizaje está en tierra")
	assert_gt(_distance_to_coast(CampaignMap.LANDER, land), LANDER_MARGIN, "con aire hasta la costa")


func test_all_fifteen_regions_are_on_land_with_margin() -> void:
	var land: PackedVector2Array = CampaignMap.land_polygon()
	assert_eq(CampaignMap.REGION_POINTS.size(), 15)
	for i: int in CampaignMap.REGION_POINTS.size():
		var point: Vector2 = CampaignMap.REGION_POINTS[i]
		assert_true(Geometry2D.is_point_in_polygon(point, land), "región %d en tierra" % (i + 1))
		assert_gt(_distance_to_coast(point, land), REGION_MARGIN, "región %d con margen" % (i + 1))


func test_regions_do_not_overlap_and_run_west_to_east() -> void:
	var points: Array[Vector2] = CampaignMap.REGION_POINTS
	assert_lt(CampaignMap.LANDER.x, points[0].x, "el aterrizaje queda al oeste de la 1")
	for i: int in range(1, points.size()):
		assert_gt(points[i].x, points[i - 1].x, "la región %d está al este de la anterior" % (i + 1))
	var closest: float = INF
	for i: int in points.size():
		for j: int in range(i + 1, points.size()):
			closest = minf(closest, points[i].distance_to(points[j]))
	assert_gte(closest * CampaignMapView.MAP_SCALE, CampaignRegion.TOUCH_MIN, "a la escala del mapa, las áreas de 56 px no se pisan")


func test_route_stays_on_land_and_never_goes_back_west() -> void:
	var land: PackedVector2Array = CampaignMap.land_polygon()
	var previous_x: float = CampaignMap.LANDER.x
	for point: Vector2 in _route_all_points():
		assert_true(Geometry2D.is_point_in_polygon(point, land), "el recorrido no pisa el mar en %s" % point)
		assert_gt(_distance_to_coast(point, land), ROUTE_MARGIN, "con margen a la costa en %s" % point)
		assert_gte(point.x, previous_x - 0.001, "X no retrocede en %s" % point)
		previous_x = maxf(previous_x, point.x)


func test_route_segments_join_the_lander_and_the_regions() -> void:
	assert_eq(CampaignMap.route_polyline(0)[0], CampaignMap.LANDER)
	for i: int in CampaignMap.REGION_COUNT:
		var line: PackedVector2Array = CampaignMap.route_polyline(i)
		assert_eq(line.size(), 13)
		assert_true(line[line.size() - 1].is_equal_approx(CampaignMap.REGION_POINTS[i]), "el tramo %d termina en su región" % (i + 1))
		if i > 0:
			assert_true(line[0].is_equal_approx(CampaignMap.REGION_POINTS[i - 1]), "y arranca en la anterior")


func test_route_has_no_crossings() -> void:
	var lines: Array[PackedVector2Array] = []
	for i: int in CampaignMap.REGION_COUNT:
		lines.append(CampaignMap.route_polyline(i, 24))
	var segments: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		for k: int in range(line.size() - 1):
			segments.append(PackedVector2Array([line[k], line[k + 1]]))
	var crossings: int = 0
	for a: int in segments.size():
		for b: int in range(a + 2, segments.size()):  # los consecutivos comparten un extremo
			if Geometry2D.segment_intersects_segment(segments[a][0], segments[a][1], segments[b][0], segments[b][1]) != null:
				crossings += 1
	assert_eq(crossings, 0, "el recorrido no se cruza")


func test_model_matches_the_approved_source_points() -> void:
	var file := FileAccess.open(ROUTE_JSON, FileAccess.READ)
	assert_not_null(file, "la fuente aprobada existe")
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	assert_eq(CampaignMap.LANDER, Vector2(data["landing"][0], data["landing"][1]))
	assert_eq(data["nodes"].size(), CampaignMap.REGION_POINTS.size())
	for i: int in CampaignMap.REGION_POINTS.size():
		assert_eq(CampaignMap.REGION_POINTS[i], Vector2(data["nodes"][i][0], data["nodes"][i][1]), "punto %d" % (i + 1))


# --- Modelo y fondo comparten coordenadas ---

func _background_text() -> String:
	return FileAccess.get_file_as_string(BACKGROUND_PATH)


## La costa del fondo (la ruta de `land-clip`), aplanada igual que `art/t471-geografia/build_background.py`.
func _background_coast() -> PackedVector2Array:
	var text: String = _background_text()
	var start: int = text.find("<clipPath id=\"land-clip\"")
	var d_start: int = text.find(" d=\"", start) + 4
	var d: String = text.substr(d_start, text.find("\"", d_start) - d_start)
	var regex := RegEx.new()
	regex.compile("[MCLZ]|-?\\d+(?:\\.\\d+)?")
	var command: String = ""
	var numbers: Array[float] = []
	var points := PackedVector2Array()
	var tokens: Array[String] = []
	for found: RegExMatch in regex.search_all(d):
		tokens.append(found.get_string())
	var i: int = 0
	while i < tokens.size():
		if tokens[i] in ["M", "C", "L", "Z"]:
			command = tokens[i]
			i += 1
			continue
		var count: int = 6 if command == "C" else 2
		numbers = []
		for k: int in count:
			numbers.append(float(tokens[i + k]))
		i += count
		if command == "C":
			var from: Vector2 = points[points.size() - 1]
			for step: int in range(1, CURVE_STEPS + 1):
				points.append(from.bezier_interpolate(Vector2(numbers[0], numbers[1]), Vector2(numbers[2], numbers[3]),
					Vector2(numbers[4], numbers[5]), float(step) / CURVE_STEPS))
		else:
			points.append(Vector2(numbers[0], numbers[1]))
	if points[points.size() - 1].is_equal_approx(points[0]):
		points.remove_at(points.size() - 1)
	return points


func test_background_coast_equals_the_model_coast() -> void:
	var from_svg: PackedVector2Array = _background_coast()
	var model: PackedVector2Array = CampaignMap.land_polygon()
	assert_eq(from_svg.size(), model.size(), "misma cantidad de vértices")
	var worst: float = 0.0
	for i: int in mini(from_svg.size(), model.size()):
		worst = maxf(worst, from_svg[i].distance_to(model[i]))
	assert_lt(worst, 0.08, "el modelo es la costa del fondo, redondeada a 0,1")


func test_background_uses_the_model_frame() -> void:
	var text: String = _background_text()
	var o: Vector2 = CampaignMap.SEA_ORIGIN
	var s: Vector2 = CampaignMap.SEA_SIZE
	assert_true(text.contains("viewBox=\"%d %d %d %d\"" % [o.x, o.y, s.x, s.y]), "el marco del fondo es el del modelo")
	assert_true(text.contains("width=\"%d\" height=\"%d\"" % [s.x, s.y]))


func test_background_is_the_full_atlas_without_illustrative_marks() -> void:
	var text: String = _background_text()
	for forbidden: String in ["level-", "<use", "<mask", "zone-", "terrain-gray", "stroke-dasharray", "id=\"lock\"", "id=\"star\"", "id=\"lander\"", "<text"]:
		assert_false(text.contains(forbidden), "el fondo no trae `%s`" % forbidden)
	assert_true(text.contains("id=\"terrain\""), "el terreno completo está en color")


# --- Vista: selección, foco y táctil en ambos extremos ---

func test_view_places_regions_from_the_model_with_56px_targets() -> void:
	var view: CampaignMapView = _view(CampaignMapView.CANVAS_SIZE.x, _all(CampaignMap.State.AVAILABLE))
	assert_eq(view.region_count(), 15)
	var scale: float = CampaignMapView.MAP_SCALE
	var offset := Vector2(0.0, -(CampaignMapView.MAP_TOP - CampaignMap.SEA_ORIGIN.y) * scale)
	for i: int in 15:
		var region: CampaignRegion = view.region(i)
		var expected: Vector2 = offset + (CampaignMap.REGION_POINTS[i] - CampaignMap.SEA_ORIGIN) * scale
		assert_true((region.position + region.size / 2.0).is_equal_approx(expected), "región %d en su coordenada" % (i + 1))
		assert_gte(region.size.x, 56.0)
		assert_gte(region.size.y, 56.0)
		assert_true(Rect2(Vector2.ZERO, CampaignMapView.CANVAS_SIZE).encloses(Rect2(region.position, region.size)), "región %d dentro del lienzo" % (i + 1))
	assert_false(view.overflows(), "con el ancho del lienzo no hay desplazamiento")


func test_selection_and_focus_work_at_both_ends() -> void:
	var view: CampaignMapView = _view(CampaignMapView.CANVAS_SIZE.x, _all(CampaignMap.State.AVAILABLE))
	view.pointer_select(0)
	assert_eq(view.selected_index(), 0)
	assert_true(view.region(0).has_focus(), "el puntero da foco a la primera")
	view.pointer_select(14)
	assert_eq(view.selected_index(), 14)
	assert_true(view.region(14).has_focus(), "y a la última")
	assert_true(view.selection_name().begins_with("15"))
	view.region(0).grab_focus()
	assert_eq(view.selected_index(), 0, "el foco de teclado también selecciona la primera")
	assert_true(view.region(0).find_valid_focus_neighbor(SIDE_RIGHT) == view.region(1))
	assert_null(view.region(14).get_node_or_null(view.region(14).focus_neighbor_right), "sin vecino a la derecha de la última")


func test_narrow_view_scrolls_only_when_needed_and_shows_both_ends() -> void:
	var view: CampaignMapView = _view(600.0, _all(CampaignMap.State.AVAILABLE))
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(view.overflows(), "con 600 px el lienzo no entra")
	view.pointer_select(14)
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll: ScrollContainer = view.map_scroll()
	var last: Rect2 = Rect2(view.region(14).position, view.region(14).size)
	assert_gt(scroll.scroll_horizontal, 0, "se desplazó hacia la última")
	assert_gte(last.position.x, scroll.scroll_horizontal, "la última queda a la vista")
	assert_lte(last.end.x, scroll.scroll_horizontal + scroll.size.x + 0.5)
	view.pointer_select(0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(scroll.scroll_horizontal, 0, "y vuelve a la primera, con el aterrizaje")
