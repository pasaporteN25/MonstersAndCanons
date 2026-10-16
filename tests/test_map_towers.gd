# Tests de las torres por mapa (T203, spec RF-393 a RF-397, D-079): el campo "torres" del nivel, su validación,
# la intersección con un modo y los íconos y la marca "Nueva" de la tarjeta. Todo es lógica pura.
extends GutTest

const MODES: String = "user://test_map_towers_modes/"

var all_towers: Array[TowerData] = []


func before_each() -> void:
	all_towers = TowerOffer.canonical_towers()
	_remove(MODES)


func after_each() -> void:
	_remove(MODES)


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	DirAccess.remove_absolute(dir)


func _text(towers: Variant, extra: Variant = null) -> String:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/levels/level_01.json"))
	if towers != null:
		data["torres"] = towers
	if extra != null:
		data["torres_extra"] = extra
	return JSON.stringify(data)


func _level(towers: Variant, extra: Variant = null) -> LevelData:
	var result: Dictionary = LevelFile.parse(_text(towers, extra), &"prueba")
	assert_eq(result["errors"].size(), 0, "sin errores: %s" % str(result["errors"]))
	return result["level"]


func _ids(towers: Array[TowerData]) -> Array[String]:
	var ids: Array[String] = []
	for tower: TowerData in towers:
		ids.append(String(tower.id))
	return ids


func test_the_canonical_order_is_the_bar_order() -> void:
	assert_eq(_ids(all_towers).slice(0, 9), ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar"])


# --- RF-393: el campo ---

func test_without_the_field_the_level_offers_what_it_always_did() -> void:
	var level: LevelData = _level(null)
	assert_eq(level.towers.size(), 0)
	assert_eq(_ids(TowerOffer.offered(level, all_towers)), ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla"])
	var with_extra: LevelData = _level(null, ["mortar"])
	assert_eq(_ids(TowerOffer.offered(with_extra, all_towers)).size(), 9)


func test_with_the_field_only_those_show_in_canonical_order() -> void:
	var level: LevelData = _level(["tesla", "frost", "basic"])
	assert_eq(_ids(level.available_towers(all_towers)), ["basic", "frost", "tesla"], "el orden es el canónico, no el del archivo")


func test_a_reserved_tower_in_the_list_is_enabled() -> void:
	var level: LevelData = _level(["cannon", "mortar"])
	assert_eq(_ids(level.available_towers(all_towers)), ["cannon", "mortar"])


func test_the_list_wins_over_torres_extra() -> void:
	var level: LevelData = _level(["cannon"], ["mortar"])
	assert_eq(_ids(level.available_towers(all_towers)), ["cannon"])


# --- RF-394: validación ---

func test_an_unknown_id_is_an_error_that_lists_the_valid_ones() -> void:
	var result: Dictionary = LevelFile.parse(_text(["hielo"]), &"prueba")
	assert_eq(result["errors"].size(), 1)
	assert_string_contains(result["errors"][0], "hielo")
	assert_string_contains(result["errors"][0], "frost", "lista las que hay")


func test_a_wrong_shape_or_an_empty_list_is_an_error() -> void:
	assert_string_contains(LevelFile.parse(_text("frost"), &"prueba")["errors"][0], "torres")
	assert_string_contains(LevelFile.parse(_text([]), &"prueba")["errors"][0], "al menos una")


func test_a_repeated_id_counts_once() -> void:
	assert_eq(_level(["frost", "frost"]).towers, PackedStringArray(["frost"]))


func test_the_editor_keeps_the_field() -> void:
	var saved: String = LevelDraft.from_text(_text(["frost", "cannon"]), "prueba").to_text()
	assert_string_contains(saved, "\"torres\": [\"frost\",\"cannon\"]")
	assert_eq(LevelDraft.from_text(saved, "x").to_text(), saved, "guardar dos veces da el mismo texto")
	assert_false(LevelDraft.from_text(_text(null), "x").to_text().contains("\"torres\""), "sin la clave, no la escribe")


func test_the_example_level_is_valid() -> void:
	var result: Dictionary = LevelFile.load_level("res://tools/ejemplos/mapa_torres_por_mapa.json")
	assert_eq(result["errors"].size(), 0, str(result["errors"]))
	assert_eq(_ids((result["level"] as LevelData).available_towers(all_towers)), ["cannon", "frost", "tesla", "mortar"])


# --- RF-395: la colección sigue mandando ---

func test_the_collection_still_applies() -> void:
	var level: LevelData = _level(["basic", "mechanical_standard"])
	assert_eq(_ids(level.available_towers(all_towers, func(_c: StringName) -> bool: return false)), ["basic"])
	assert_eq(_ids(level.available_towers(all_towers, func(_c: StringName) -> bool: return true)), ["basic", "mechanical_standard"])


# --- RF-396: modo y nivel juntos ---

func _mode_with_map(mode_towers: Array, map_towers: Array) -> Dictionary:
	var dir: String = ModePacks.dir_of(MODES, "prueba")
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(dir + "mapa_a.json", FileAccess.WRITE)
	file.store_string(_text(map_towers))
	file.close()
	file = FileAccess.open(dir + ModePacks.FILE_NAME, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "nombre": "Prueba", "mapas": ["mapa_a"], "torres": mode_towers}))
	file.close()
	return ModePacks.read(MODES, "prueba", false)


func test_mode_and_level_use_the_intersection() -> void:
	var mode: Dictionary = _mode_with_map(["basic", "frost", "cannon"], ["frost", "tesla", "cannon"])
	var level: LevelData = ModePacks.map_level(mode, 0)
	assert_not_null(level)
	assert_eq(_ids(level.available_towers(all_towers)), ["cannon", "frost"])


func test_an_empty_intersection_is_an_error_of_the_mode() -> void:
	var mode: Dictionary = _mode_with_map(["basic"], ["frost"])
	assert_null(ModePacks.map_level(mode, 0))
	var errors: PackedStringArray = mode["maps"][0]["errors"]
	assert_eq(errors.size(), 1)
	assert_string_contains(errors[0], "ninguna en común")


# --- RF-397: la tarjeta ---

func _campaign() -> Array[LevelData]:
	var levels: Array[LevelData] = []
	for i: int in GameFlow.level_count():
		levels.append(GameFlow.level(i))
	return levels


func test_new_towers_are_those_no_earlier_level_offered() -> void:
	var first: LevelData = LevelData.new()
	first.towers = PackedStringArray(["basic", "frost"])
	var second: LevelData = LevelData.new()
	second.towers = PackedStringArray(["basic", "frost", "tesla"])
	var third: LevelData = LevelData.new()
	third.towers = PackedStringArray(["cannon", "tesla"])
	var levels: Array[LevelData] = [first, second, third]
	assert_eq(TowerOffer.new_tower_ids(levels, 0, all_towers), PackedStringArray(["basic", "frost"]))
	assert_eq(TowerOffer.new_tower_ids(levels, 1, all_towers), PackedStringArray(["tesla"]))
	assert_eq(TowerOffer.new_tower_ids(levels, 2, all_towers), PackedStringArray(["cannon"]), "la Tesla ya había debutado")


func test_the_real_campaign_marks_each_tower_once() -> void:
	var levels: Array[LevelData] = _campaign()
	var seen: Dictionary = {}
	for i: int in levels.size():
		for id: String in TowerOffer.new_tower_ids(levels, i, all_towers):
			assert_false(seen.has(id), "%s debuta una sola vez" % id)
			seen[id] = true
	for tower: TowerData in TowerOffer.offered(levels[0], all_towers):
		assert_true(seen.has(String(tower.id)))


func test_the_card_shows_one_icon_per_offered_tower() -> void:
	var select: Control = load("res://scenes/ui/level_select.tscn").instantiate()
	add_child_autofree(select)
	var card: Button = select._make_card(0)
	autofree(card)
	var row: Node = card.get_node("TowerPlate/TowerIcons")
	assert_eq(row.get_child_count(), TowerOffer.offered(GameFlow.level(0), all_towers).size())
	assert_not_null(row.get_child(0).get_node("%s/NewMark" % row.get_child(0).get_child(0).name), "en el nivel 1 todas debutan")
	assert_string_contains(card.tooltip_text, "Nueva")


func test_the_largest_campaign_card_keeps_all_parts_separate() -> void:
	var select: Control = load("res://scenes/ui/level_select.tscn").instantiate()
	add_child_autofree(select)
	await get_tree().process_frame
	var levels: Array[LevelData] = _campaign()
	var max_index: int = 0
	for i: int in levels.size():
		if TowerOffer.offered(levels[i], all_towers).size() > TowerOffer.offered(levels[max_index], all_towers).size():
			max_index = i
	var card: Button = select._make_card(max_index)
	card.size = Vector2(200, 214)
	add_child_autofree(card)
	await get_tree().process_frame
	await _assert_card_parts_do_not_overlap(card, levels[max_index], all_towers)


func test_a_map_offering_many_towers_wraps_without_clipping() -> void:
	var select: Control = load("res://scenes/ui/level_select.tscn").instantiate()
	add_child_autofree(select)
	await get_tree().process_frame
	var many: LevelData = _level(null)
	many.towers = PackedStringArray(_ids(all_towers))
	var card := Button.new()
	card.custom_minimum_size = Vector2(200, 214)
	card.size = card.custom_minimum_size
	select._add_campaign_card_text(card, 0, many, true)
	select._add_tower_icons(card, 0, many, true)
	select._add_campaign_stars(card, 0, true, 0)
	add_child_autofree(card)
	await get_tree().process_frame
	await get_tree().process_frame
	var row: HFlowContainer = card.get_node("TowerPlate/TowerIcons")
	assert_eq(row.get_child_count(), all_towers.size(), "el mapa muestra todas las torres que ofrece")
	assert_gt(all_towers.size(), 8, "el caso de mapa cubre nueve o más íconos")
	var icon_rows: Dictionary = {}
	for badge: Control in row.get_children():
		icon_rows[snappedf(badge.position.y, 1.0)] = true
	assert_gt(icon_rows.size(), 1, "los íconos pasan a un segundo renglón")
	await _assert_card_parts_do_not_overlap(card, many, all_towers)


func _assert_card_parts_do_not_overlap(card: Button, level: LevelData, towers: Array[TowerData]) -> void:
	var elements: Array[Control] = []
	for child: Node in card.get_children():
		if child is Control and (child as Control).visible:
			elements.append(child as Control)
		var rect: Rect2 = (child as Control).get_global_rect() if child is Control else Rect2()
		if child is Control and (child as Control).visible:
			assert_true(card.get_global_rect().encloses(rect), "%s entra en la tarjeta: %s" % [child.name, rect])
	for first_index: int in elements.size():
		for second_index: int in range(first_index + 1, elements.size()):
			assert_false(elements[first_index].get_global_rect().intersects(elements[second_index].get_global_rect()),
				"%s no se pisa con %s" % [elements[first_index].name, elements[second_index].name])
	var icon_row: HFlowContainer = card.get_node("TowerPlate/TowerIcons")
	assert_eq(icon_row.get_child_count(), TowerOffer.offered(level, towers).size())
	for badge: Control in icon_row.get_children():
		assert_true(icon_row.get_global_rect().encloses(badge.get_global_rect()), "%s queda dentro de la fila" % badge.name)
