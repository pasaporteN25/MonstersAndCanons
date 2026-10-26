# Tests de la máscara gris G2 de las zonas ocultas del atlas (T488, RF-709, RF-710, D-209).
# Instancian `CampaignMapView` solos, con entradas armadas a mano: no tocan el guardado ni cambian de escena.
extends GutTest


func _view(open_count: int, extra_open: Array[int] = []) -> CampaignMapView:
	var entries: Array[Dictionary] = []
	for i: int in CampaignMap.REGION_COUNT:
		var open: bool = i < open_count or extra_open.has(i)
		var state: CampaignMap.State = CampaignMap.State.LOCKED
		if open:
			state = CampaignMap.State.AVAILABLE if i == open_count - 1 else CampaignMap.State.TAKEN
		entries.append({"name": "Nivel %d" % (i + 1), "place": "", "stars": 0, "state": state})
	var view := CampaignMapView.new()
	add_child_autofree(view)
	view.setup(entries)
	return view


func test_new_save_masks_b_and_c() -> void:
	assert_eq(_view(1).hidden_zones(), [CampaignMap.ZONE_B, CampaignMap.ZONE_C] as Array[int])


func test_level_6_open_masks_only_c() -> void:
	assert_eq(_view(6).hidden_zones(), [CampaignMap.ZONE_C] as Array[int])


func test_level_11_open_has_no_mask() -> void:
	assert_eq(_view(11).hidden_zones(), [] as Array[int])


func test_testing_mode_all_open_has_no_mask() -> void:
	assert_eq(_view(CampaignMap.REGION_COUNT).hidden_zones(), [] as Array[int])


func test_odd_save_with_8_open_and_6_closed_masks_only_c() -> void:
	# Mismo criterio que el descubrimiento (RF-709): el 8 abierto descubre B aunque el 6 figure cerrado.
	assert_eq(_view(0, [7]).hidden_zones(), [CampaignMap.ZONE_C] as Array[int])


func test_masks_cover_exactly_the_hidden_zones_of_every_progress() -> void:
	for open_count: int in range(1, CampaignMap.REGION_COUNT + 1):
		var view: CampaignMapView = _view(open_count)
		var hidden: Array[int] = view.hidden_zones()
		for zone: int in [CampaignMap.ZONE_B, CampaignMap.ZONE_C]:
			var first: int = CampaignMap.ZONE_B_FIRST_REGION if zone == CampaignMap.ZONE_B else CampaignMap.ZONE_C_FIRST_REGION
			assert_eq(hidden.has(zone), not view.is_region_discovered(first), "%d niveles abiertos, zona %d" % [open_count, zone])


func test_zone_to_asset_mapping() -> void:
	var masks: Dictionary = CampaignMapView.HIDDEN_ZONE_MASKS
	assert_eq(masks.keys(), [CampaignMap.ZONE_B, CampaignMap.ZONE_C], "la zona A siempre está descubierta: sin máscara")
	assert_eq((masks[CampaignMap.ZONE_B] as Texture2D).resource_path, "res://assets/ui/campaign_hidden_zones/hidden_zone_b.svg")
	assert_eq((masks[CampaignMap.ZONE_C] as Texture2D).resource_path, "res://assets/ui/campaign_hidden_zones/hidden_zone_c.svg")


func test_masks_have_atlas_size_so_scale_and_origin_are_the_atlas_ones() -> void:
	assert_eq(CampaignMapView.MAP_SCALE, 1.26, "T502: escala del atlas")
	for zone: int in CampaignMapView.HIDDEN_ZONE_MASKS:
		var texture: Texture2D = CampaignMapView.HIDDEN_ZONE_MASKS[zone]
		# Se importan con la misma escala de SVG que el fondo (`svg/scale`), así que se compara la proporción, no los píxeles.
		var background_size := Vector2(CampaignMapView.MAP_BACKGROUND.get_size())
		assert_eq(Vector2(texture.get_size()), background_size, "la máscara de la zona %d mide como el atlas" % zone)
		assert_almost_eq(texture.get_size().x / background_size.x * CampaignMap.SEA_SIZE.x * CampaignMapView.MAP_SCALE, CampaignMapView.CANVAS_SIZE.x, 0.01)
	var view: CampaignMapView = _view(1)
	# El mismo origen que el fondo: el punto del atlas (SEA_ORIGIN) cae en el desplazamiento del lienzo.
	assert_eq(view._map_point(CampaignMap.SEA_ORIGIN), view._offset)


func test_mask_pixels_cover_hidden_regions_and_not_discovered_ones() -> void:
	var b: Image = (CampaignMapView.HIDDEN_ZONE_MASKS[CampaignMap.ZONE_B] as Texture2D).get_image()
	var c: Image = (CampaignMapView.HIDDEN_ZONE_MASKS[CampaignMap.ZONE_C] as Texture2D).get_image()
	if b == null or c == null or b.is_empty() or c.is_empty():
		pending("el motor sin ventana no entrega la imagen del SVG importado")
		return
	var ratio: float = float(b.get_width()) / CampaignMap.SEA_SIZE.x
	for i: int in CampaignMap.REGION_COUNT:
		var pixel := Vector2i((CampaignMap.REGION_POINTS[i] - CampaignMap.SEA_ORIGIN) * ratio)
		var zone: int = CampaignMap.zone_of(i)
		assert_eq(b.get_pixelv(pixel).a > 0.5, zone == CampaignMap.ZONE_B, "máscara B sobre la región %d" % (i + 1))
		assert_eq(c.get_pixelv(pixel).a > 0.5, zone == CampaignMap.ZONE_C, "máscara C sobre la región %d" % (i + 1))
