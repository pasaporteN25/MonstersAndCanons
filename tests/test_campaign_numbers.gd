# Tests de los números de nivel sin cero inicial en el mapa planetario (T474 parcial, RF-695). Los ids y rutas
# (`level_01`) no se tocan: solo el número que se muestra.
extends GutTest


func test_number_text_has_no_leading_zero() -> void:
	assert_eq(CampaignMap.number_text(0), "1")
	assert_eq(CampaignMap.number_text(8), "9")
	assert_eq(CampaignMap.number_text(9), "10", "el límite entre una y dos cifras")
	assert_eq(CampaignMap.number_text(14), "15")


func test_all_fifteen_numbers_are_unique_and_never_start_with_zero() -> void:
	var seen: Dictionary = {}
	for i: int in CampaignMap.REGION_COUNT:
		var text: String = CampaignMap.number_text(i)
		assert_false(text.begins_with("0"), "nivel %d" % (i + 1))
		assert_false(seen.has(text))
		seen[text] = true
	assert_eq(seen.size(), 15)


func test_selection_label_uses_number_without_zero() -> void:
	var entries: Array[Dictionary] = []
	for i: int in CampaignMap.REGION_COUNT:
		entries.append({"name": "Nivel %d" % (i + 1), "place": "", "stars": 0, "state": CampaignMap.State.AVAILABLE})
	var view := CampaignMapView.new()
	add_child_autofree(view)
	view.setup(entries, 0)
	assert_eq(view.selection_name(), "1 · Nivel 1")
	view.select(9)
	assert_eq(view.selection_name(), "10 · Nivel 10")


func test_level_ids_keep_their_zero() -> void:
	assert_eq(GameFlow.level(0).id, &"level_01", "el id del nivel no se renombra")
