# Tests de la vista del atlas con zonas sin descubrir (M78, T488 parcial, RF-709, RF-710, RF-688, D-209).
# Instancian `CampaignMapView` solos, con entradas armadas a mano: no tocan el guardado ni cambian de escena.
# La máscara gris es provisional (`HIDDEN_ZONE_TINT_PLACEHOLDER`); acá se prueba el comportamiento, no el arte.
extends GutTest

var requested: Array[int] = []


func before_each() -> void:
	requested = []


## `open_count`: cuántos niveles están abiertos desde el 1 (el acceso es N→N+1); `extra_open`: niveles sueltos abiertos de más.
func _view(open_count: int, extra_open: Array[int] = []) -> CampaignMapView:
	var entries: Array[Dictionary] = []
	for i: int in CampaignMap.REGION_COUNT:
		var open: bool = i < open_count or extra_open.has(i)
		var state: CampaignMap.State = CampaignMap.State.LOCKED
		if open:
			state = CampaignMap.State.AVAILABLE if i == open_count - 1 else CampaignMap.State.TAKEN
		entries.append({"name": "Nivel %d" % (i + 1), "place": "", "stars": 3 if state == CampaignMap.State.TAKEN else 0, "state": state})
	var view := CampaignMapView.new()
	add_child_autofree(view)
	view.level_requested.connect(func(index: int) -> void: requested.append(index))
	view.setup(entries)
	return view


func test_new_save_only_zone_a_is_focusable() -> void:
	var view: CampaignMapView = _view(1)
	assert_eq(view.focusable_indices(), [0, 1, 2, 3, 4] as Array[int])
	for i: int in 5:
		assert_eq(view.region(i).focus_mode, Control.FOCUS_ALL, "la región %d admite foco" % (i + 1))
	for i: int in range(5, 15):
		assert_false(view.is_region_discovered(i))
		assert_eq(view.region(i).focus_mode, Control.FOCUS_NONE, "la región %d no admite foco" % (i + 1))
		assert_eq(view.region(i).tooltip_text, "", "sin tooltip: no se inspecciona")


func test_level_6_open_discovers_b_but_not_c_and_does_not_open_7_to_10() -> void:
	var view: CampaignMapView = _view(6)
	assert_eq(view.focusable_indices().size(), 10)
	assert_true(view.is_region_discovered(9))
	assert_false(view.is_region_discovered(10))
	assert_eq(view.region(5).state, CampaignMap.State.AVAILABLE)
	for i: int in range(6, 10):  # RF-710: del 7 al 10 siguen con candado, visibles
		assert_eq(view.region(i).state, CampaignMap.State.LOCKED)
		assert_true(view.region(i).discovered)


func test_level_11_open_discovers_all() -> void:
	var view: CampaignMapView = _view(11)
	assert_eq(view.focusable_indices().size(), 15)


func test_odd_save_with_8_open_and_6_closed_discovers_b() -> void:
	var view: CampaignMapView = _view(0, [7])
	assert_true(view.is_region_discovered(5))
	assert_false(view.is_region_discovered(10))


func test_hidden_region_cannot_be_selected_nor_pointer_selected_nor_requested() -> void:
	var view: CampaignMapView = _view(1)
	view.select(7)
	assert_eq(view.selected_index(), 0, "select() ignora una región oculta")
	view.pointer_select(7)
	assert_eq(view.selected_index(), 0)
	view.pointer_select(-1)
	view.pointer_select(99)
	assert_eq(view.selected_index(), 0)
	view._request(7)
	assert_eq(requested.size(), 0, "una oculta nunca inicia")


func test_hidden_region_does_not_hit_test_at_its_point() -> void:
	var view: CampaignMapView = _view(1)
	var center: Vector2 = view.region(7).position + view.region(7).size / 2.0
	assert_null(view._region_at(center), "el toque sobre una oculta no encuentra región")
	var visible_center: Vector2 = view.region(2).position + view.region(2).size / 2.0
	assert_eq(view._region_at(visible_center), view.region(2))


func test_arrows_skip_hidden_zone() -> void:
	var view: CampaignMapView = _view(1)
	var last: CampaignRegion = view.region(4)
	assert_eq(last.focus_neighbor_right, NodePath(), "tras la 5 no hay vecino: la zona B está oculta")
	assert_eq(last.focus_neighbor_bottom, NodePath())
	assert_eq(view.region(1).focus_neighbor_right, NodePath("../Region_2"))
	assert_eq(view.region(1).focus_neighbor_left, NodePath("../Region_0"))


func test_arrows_run_through_a_and_b_when_b_discovered() -> void:
	var view: CampaignMapView = _view(6)
	assert_eq(view.region(4).focus_neighbor_right, NodePath("../Region_5"))
	assert_eq(view.region(9).focus_neighbor_right, NodePath(), "la C sigue oculta")


func test_keyboard_enter_on_hidden_region_does_nothing() -> void:
	var view: CampaignMapView = _view(1)
	assert_eq(view.region(7).focus_mode, Control.FOCUS_NONE, "una región oculta no toma el foco (ni con Tab ni con flechas)")
	view.region(7).pressed.emit()  # aun forzando la señal, la vista no inicia
	assert_eq(requested.size(), 0)


func test_enter_on_available_in_discovered_zone_starts_once() -> void:
	var view: CampaignMapView = _view(6)
	view.region(5).pressed.emit()
	assert_eq(requested, [5] as Array[int], "el 6 disponible se puede jugar")
	view.region(7).pressed.emit()
	assert_eq(requested, [5] as Array[int], "el 8 bloqueado, aun descubierto, no inicia")


func test_initial_selection_falls_back_when_requested_one_is_hidden() -> void:
	var view: CampaignMapView = _view(1)
	var entries: Array[Dictionary] = []
	for i: int in CampaignMap.REGION_COUNT:
		entries.append({"name": "N%d" % i, "place": "", "stars": 0, "state": CampaignMap.State.AVAILABLE if i == 0 else CampaignMap.State.LOCKED})
	view.setup(entries, 12)
	assert_eq(view.selected_index(), 0)
	await get_tree().process_frame  # las regiones reemplazadas se liberan al fin del cuadro


func test_discovering_does_not_change_states() -> void:
	var view: CampaignMapView = _view(6)
	for i: int in range(6, 15):
		assert_eq(view.region(i).state, CampaignMap.State.LOCKED, "descubrir no abre niveles")
