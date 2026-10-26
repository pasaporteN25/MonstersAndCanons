# Tests del halo de «nivel disponible» del mapa planetario (T499, RF-695, RF-710): un nivel desbloqueado sin victoria lleva un
# halo dorado punteado, distinto de la selección (aro continuo) y del foco (aro blanco), y sin animación.
extends GutTest


func test_only_the_available_state_has_a_halo() -> void:
	assert_true(CampaignMap.has_halo(CampaignMap.state_of(true, false, 0)), "desbloqueado sin victoria")
	assert_false(CampaignMap.has_halo(CampaignMap.state_of(true, true, 1)), "1 estrella (partido)")
	assert_false(CampaignMap.has_halo(CampaignMap.state_of(true, true, 2)), "2 estrellas (partido)")
	assert_false(CampaignMap.has_halo(CampaignMap.state_of(true, true, 3)), "3 estrellas (jugador)")
	assert_false(CampaignMap.has_halo(CampaignMap.state_of(false, false, 0)), "bloqueado")
	assert_false(CampaignMap.has_halo(CampaignMap.state_of(false, true, 3)), "bloqueado manda aunque el guardado traiga estrellas")


func test_halo_is_a_dotted_ring_not_a_continuous_one() -> void:
	var dashes: Array[Vector2] = CampaignRegion.halo_dashes()
	assert_eq(dashes.size(), CampaignRegion.HALO_DASHES)
	var covered: float = 0.0
	for dash: Vector2 in dashes:
		assert_gt(dash.y, dash.x, "cada rayita tiene largo")
		covered += dash.y - dash.x
	assert_almost_eq(covered, TAU * CampaignRegion.HALO_DASH_FRACTION, 0.001, "cubre la fracción prevista del círculo")
	assert_lt(covered, TAU * 0.75, "deja huecos visibles: no se confunde con el aro continuo de selección")
	for i: int in dashes.size() - 1:
		assert_gt(dashes[i + 1].x, dashes[i].y, "entre una rayita y la siguiente hay un hueco")
	assert_lte(dashes[dashes.size() - 1].y, TAU, "no pasa de la vuelta completa")


func test_halo_sits_between_badge_edge_and_selection_ring_and_focus() -> void:
	var selection: float = CampaignRegion.BADGE_EDGE + 5.0
	var focus: float = CampaignRegion.BADGE_EDGE + 10.0
	assert_gt(CampaignRegion.HALO_RADIUS - CampaignRegion.HALO_WIDTH / 2.0, CampaignRegion.BADGE_EDGE, "no tapa el borde de la insignia")
	assert_lt(CampaignRegion.HALO_RADIUS + CampaignRegion.HALO_WIDTH / 2.0, selection - 1.0, "queda adentro del aro de selección, con aire")
	assert_lt(CampaignRegion.HALO_RADIUS, focus, "y adentro del foco")
	assert_ne(CampaignRegion.HALO_COLOR, CampaignRegion.FOCUS_COLOR, "no es del color del foco")


func test_halo_fits_in_the_gap_to_the_neighbour_badge() -> void:
	# El par más apretado del mapa es el 12–13 (T500): el halo de uno no toca la insignia del otro.
	var closest: float = INF
	for i: int in CampaignMap.REGION_COUNT - 1:
		closest = minf(closest, CampaignMap.REGION_POINTS[i].distance_to(CampaignMap.REGION_POINTS[i + 1]) * CampaignMapView.MAP_SCALE)
	assert_lt(CampaignRegion.HALO_RADIUS + CampaignRegion.HALO_WIDTH / 2.0 + CampaignRegion.BADGE_EDGE, closest, "el halo no pisa a la vecina")


func test_halo_has_no_animation_in_the_region_script() -> void:
	var source: String = FileAccess.get_file_as_string("res://scenes/ui/campaign_region.gd")
	assert_false(source.contains("_process"), "la región no tiene _process")
	assert_false(source.contains("Tween"), "ni tweens")
	assert_false(source.contains("Time.get_ticks"), "ni relojes: el halo es estático (RF-710)")


func test_available_region_keeps_its_data_and_can_draw_with_selection_and_focus() -> void:
	var region := CampaignRegion.new()
	add_child_autofree(region)
	region.setup(2, {"state": CampaignMap.State.AVAILABLE, "stars": 0, "name": "Tres"}, Vector2(100, 100), 56.0)
	region.set_selected(true)
	await get_tree().process_frame
	assert_true(CampaignMap.has_halo(region.state))
	assert_true(region.discovered)
	assert_eq(CampaignMap.badge_of(region.state), CampaignMap.Badge.REBEL, "la insignia sigue siendo la rebelde; el halo es lo que la marca disponible")
