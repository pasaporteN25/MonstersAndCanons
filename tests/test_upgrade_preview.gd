extends GutTest
# M68 (T403, T404, RF-616 a RF-618, D-163): «Mejorar» muestra antes → después con los mismos datos que las
# animaciones de mejora (UpgradeDeltas y data/ui/mejoras.json).

var _table: Array[Dictionary]


func before_each() -> void:
	_table = UpgradeFxConfig.load_from().stats


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id) as TowerData


func _level(damage: int, range_tiles: float, rate: float = 1.0) -> TowerLevelData:
	var level := TowerLevelData.new()
	level.damage = damage
	level.range_tiles = range_tiles
	level.fire_rate = rate
	return level


func test_values_are_formatted_without_sign_and_with_comma() -> void:
	assert_eq(UpgradeDeltas.format_value(5.0, "entero"), "5")
	assert_eq(UpgradeDeltas.format_value(3.5, "decimal"), "3,5")
	assert_eq(UpgradeDeltas.format_value(3.0, "decimal"), "3", "sin ceros de más")
	assert_eq(UpgradeDeltas.format_value(30.0, "porcentaje"), "30 %")
	assert_eq(UpgradeDeltas.format_value(-2.0, "entero"), "−2")
	assert_eq(UpgradeDeltas.format_value(0.0, "entero"), "0")


func test_before_after_text_and_values() -> void:
	var changes: Array[Dictionary] = UpgradeDeltas.before_after(_level(5, 3.0), _level(8, 3.5), _table)
	assert_eq(changes.size(), 2)
	assert_eq(String(changes[0]["texto"]), "daño 5 → 8")
	assert_eq(String(changes[1]["texto"]), "alcance 3 → 3,5")
	assert_eq(changes[0]["antes"], 5.0)
	assert_eq(changes[0]["despues"], 8.0)


func test_before_after_lists_the_same_stats_as_the_effect_in_the_same_order() -> void:
	for id: String in ["basic", "cannon", "tesla", "sniper", "fire", "frost", "mortar", "burst", "multi"]:
		var path: String = "res://data/towers/%s.tres" % id
		if not ResourceLoader.exists(path):
			continue
		var data: TowerData = _tower(id)
		for index: int in data.levels.size() - 1:
			var deltas: Array[Dictionary] = UpgradeDeltas.compute(data.levels[index], data.levels[index + 1], _table)
			var changes: Array[Dictionary] = UpgradeDeltas.before_after(data.levels[index], data.levels[index + 1], _table)
			assert_eq(changes.size(), deltas.size(), "%s nivel %d" % [id, index + 1])
			for i: int in deltas.size():
				assert_eq(changes[i]["campo"], deltas[i]["campo"])
				assert_almost_eq(float(changes[i]["despues"]) - float(changes[i]["antes"]), float(deltas[i]["delta"]), 0.0001)


func test_scale_is_applied_to_both_sides() -> void:
	var from := TowerLevelData.new()
	var to := TowerLevelData.new()
	from.slow_amount = 0.3
	to.slow_amount = 0.4
	var changes: Array[Dictionary] = UpgradeDeltas.before_after(from, to, _table)
	assert_eq(changes.size(), 1)
	assert_eq(String(changes[0]["texto"]), "frenado 30 % → 40 %")


func test_no_change_or_null_gives_nothing_and_the_cap_is_respected() -> void:
	assert_eq(UpgradeDeltas.before_after(_level(5, 3.0), _level(5, 3.0), _table).size(), 0, "sin cambios no hay nada")
	assert_eq(UpgradeDeltas.before_after(null, _level(5, 3.0), _table).size(), 0)
	assert_eq(UpgradeDeltas.before_after(_level(1, 1.0, 1.0), _level(2, 2.0, 2.0), _table, 2).size(), 2, "el tope")


func test_preview_is_empty_at_the_last_level_and_for_bad_indexes() -> void:
	var data: TowerData = load("res://data/towers/%s.tres" % _first_tower_id()) as TowerData
	var last: int = data.levels.size() - 1
	assert_eq(UpgradeDeltas.preview(data.levels, last, _table).size(), 0, "en el nivel máximo no hay nada que mostrar")
	assert_eq(UpgradeDeltas.preview(data.levels, -1, _table).size(), 0)
	assert_eq(UpgradeDeltas.preview(data.levels, 99, _table).size(), 0)
	assert_gt(UpgradeDeltas.preview(data.levels, 0, _table).size(), 0, "del 1 al 2 sí cambia algo")


func _first_tower_id() -> String:
	for file: String in DirAccess.get_files_at("res://data/towers"):
		if file.ends_with(".tres") or file.ends_with(".tres.remap"):
			return file.replace(".remap", "").trim_suffix(".tres")
	return ""


func test_every_tower_shows_at_least_one_change_per_upgrade() -> void:
	for file: String in DirAccess.get_files_at("res://data/towers"):
		if not file.ends_with(".tres"):
			continue
		var data: TowerData = load("res://data/towers/%s" % file) as TowerData
		if data == null or data.levels.size() < 2:
			continue
		for index: int in data.levels.size() - 1:
			assert_gt(UpgradeDeltas.preview(data.levels, index, _table, 99).size(), 0, "%s: del nivel %d al %d" % [file, index + 1, index + 2])


func _spawn_game(mode: int) -> Game:
	SaveManager.set_setting("ui_mode", mode)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child_autofree(viewport)
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	game.level_data = GameFlow.level(0)
	viewport.add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	return game


func _build_one(game: Game) -> Tower:
	var tower_data: TowerData = game.available_towers[0]
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and game.build_controller.cells_free(tower_data, cell):
				game.session.gold += 1000
				assert_true(game.build_controller.try_build(tower_data, cell))
				return game.build_controller.tower_at(cell)
	return null


func test_pc_panel_shows_the_preview_and_hides_it_at_max_level() -> void:
	var original: Variant = SaveManager.get_setting("ui_mode")
	var game: Game = await _spawn_game(UiMode.PC)
	var tower: Tower = _build_one(game)
	game.hud.tower_panel.show_tower(tower, 10, 9999)
	var preview: Label = game.hud.tower_panel.find_child("UpgradePreview", true, false) as Label
	assert_not_null(preview)
	assert_true(preview.visible)
	assert_true(preview.text.begins_with("Al nivel 2:"))
	assert_true(preview.text.contains("→"))
	assert_false(preview.text.contains("daño"), "el daño ya se integra con la estadística principal")
	assert_eq((game.hud.tower_panel.get_node("%Damage") as Label).text, "5 → 8")
	assert_eq((game.hud.tower_panel.get_node("%UpgradeButton") as Button).text, "Mejorar a nivel 2 (60)  [U]")
	assert_eq((game.hud.tower_panel.get_node("%LevelCard") as HBoxContainer).tooltip_text, "Nivel actual: 1 de 3")
	while tower.can_upgrade():
		tower.apply_upgrade()
	game.hud.tower_panel.refresh(9999)
	assert_false(preview.visible, "en el nivel máximo no hay preview")
	assert_eq((game.hud.tower_panel.find_child("UpgradeButton", true, false) as Button).text, "Nivel máximo")
	assert_eq((game.hud.tower_panel.get_node("%Damage") as Label).text, str(tower.stats().damage))
	SaveManager.set_setting("ui_mode", original)


func test_mobile_status_line_shows_the_preview() -> void:
	var original: Variant = SaveManager.get_setting("ui_mode")
	var game: Game = await _spawn_game(UiMode.MOBILE)
	var tower: Tower = _build_one(game)
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_true(status.text.contains("Al mejorar:"), status.text)
	assert_true(status.text.contains("→"))
	while tower.can_upgrade():
		tower.apply_upgrade()
	game._refresh_tower_panel()
	assert_false(status.text.contains("Al mejorar:"), "en el nivel máximo no se ofrece nada")
	SaveManager.set_setting("ui_mode", original)
