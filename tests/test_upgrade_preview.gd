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


func test_pc_panel_has_no_preview_block_and_shows_the_change_in_place() -> void:
	var original: Variant = SaveManager.get_setting("ui_mode")
	var game: Game = await _spawn_game(UiMode.PC)
	var tower: Tower = _build_one(game)
	var panel: TowerPanel = game.hud.tower_panel
	panel.show_tower(tower, 10, 9999)
	assert_null(panel.find_child("UpgradePreview", true, false), "T513: se retira el bloque UpgradePreview")
	assert_eq((panel.get_node("%Damage") as Label).text, "5 → 8")
	assert_eq((panel.get_node("%Rate") as Label).text, "2 → 2,5/s")
	assert_eq((panel.get_node("%UpgradeButton") as Button).text, "Mejorar a nivel 2")
	assert_eq((panel.get_node("%Cost") as Label).text, "60", "el costo va en el botón, con la moneda")
	assert_eq((panel.get_node("%LevelCard") as HBoxContainer).tooltip_text, "Nivel actual: 1 de 3")
	while tower.can_upgrade():
		tower.apply_upgrade()
	panel.refresh(9999)
	assert_eq((panel.find_child("UpgradeButton", true, false) as Button).text, "Nivel máximo")
	assert_eq((panel.get_node("%Damage") as Label).text, str(tower.stats().damage), "en el nivel máximo no hay flecha")
	SaveManager.set_setting("ui_mode", original)


func _panel_with(id: String, level_index: int) -> TowerPanel:
	var panel := (load("res://scenes/ui/tower_panel.tscn") as PackedScene).instantiate() as TowerPanel
	add_child_autofree(panel)
	var tower := (load("res://scenes/towers/tower.tscn") as PackedScene).instantiate() as Tower
	tower.setup(_tower(id))
	add_child_autofree(tower)
	tower.level_index = level_index
	panel.show_tower(tower, 0, 9999)
	return panel


func _count(text: String, part: String) -> int:
	return text.count(part)


## T513 (RF-721 punto 4): la frase de cada efecto lleva su «antes → después» adentro, y aparece UNA vez.
func test_effect_phrases_carry_the_change_inside_and_appear_once_for_every_tower_and_level() -> void:
	for file: String in DirAccess.get_files_at("res://data/towers"):
		if not file.ends_with(".tres"):
			continue
		var id: String = file.trim_suffix(".tres")
		var data: TowerData = _tower(id)
		for level_index: int in data.levels.size():
			var next: TowerLevelData = data.levels[level_index + 1] if level_index + 1 < data.levels.size() else null
			var panel: TowerPanel = _panel_with(id, level_index)
			var message: String = "%s nivel %d" % [id, level_index + 1]
			var stats: String = (panel.get_node("%Stats") as Label).text
			for phrase: String in TowerText.effect_phrases(data.levels[level_index], next):
				assert_eq(_count(stats, phrase), 1, "%s: «%s» una sola vez en %s" % [message, phrase, stats])
			var visible_text: String = stats
			for name: String in ["Damage", "Rate", "Range"]:
				visible_text += " " + (panel.get_node("%" + name) as Label).text
			assert_false(visible_text.contains("."), "%s: decimales con coma (%s)" % [message, visible_text])
			if next == null:
				assert_false(visible_text.contains(UpgradeDeltas.ARROW), "%s: último nivel sin flechas" % message)
			assert_null(panel.find_child("UpgradePreview", true, false))
			panel.queue_free()


func test_phrases_for_the_cases_of_rf_686() -> void:
	var tesla: TowerData = _tower("tesla")
	assert_eq(TowerText.effect_phrases(tesla.levels[0], tesla.levels[1])[0], "El rayo salta a 2 → 3 enemigos más")
	var frost: TowerData = _tower("frost")
	assert_eq(TowerText.effect_phrases(frost.levels[0], frost.levels[1])[0], "Ralentiza 40 → 50 % durante 2 s", "la duración no cambia: sin flecha")
	assert_eq(TowerText.effect_phrases(frost.levels[1], frost.levels[2])[0], "Ralentiza 50 → 60 % durante 2 → 3 s")
	var disruptor: TowerData = _tower("disruptor")
	assert_eq(TowerText.effect_phrases(disruptor.levels[0], disruptor.levels[1])[0], "Pulso: apaga las auras durante 2,5 → 3 s")
	var standard: TowerData = _tower("mechanical_standard")
	var support: Array[String] = TowerText.effect_phrases(standard.levels[0], standard.levels[1])
	assert_eq(support[0], "Apoyo: +10 → 15 % de cadencia; solo el mayor")
	assert_eq(support[1], "Repara 2 → 3 puntos de desgaste/s; solo la mayor tasa")
	var cannon: TowerData = _tower("cannon")
	assert_eq(TowerText.effect_phrases(cannon.levels[0], cannon.levels[1])[0], "Área: radio 1 → 1,2")


func test_effect_phrases_without_next_level_are_the_plain_effects() -> void:
	for file: String in DirAccess.get_files_at("res://data/towers"):
		if not file.ends_with(".tres"):
			continue
		var data: TowerData = _tower(file.trim_suffix(".tres"))
		for level: TowerLevelData in data.levels:
			var plain: Array[String] = TowerText.effects(level)
			var phrases: Array[String] = TowerText.effect_phrases(level, null, false)
			assert_eq(phrases, plain, "%s: sin nivel siguiente no hay flechas" % file)
			for line: String in phrases:
				assert_false(line.contains(UpgradeDeltas.ARROW))
	# Caso de borde: una mejora que agrega un efecto que el nivel actual no tiene no lo pierde.
	var from := TowerLevelData.new()
	var to := TowerLevelData.new()
	to.chain_extra_targets = 2
	assert_eq(TowerText.effect_phrases(from, to)[0], "El rayo salta a 0 → 2 enemigos más")


## RF-677 (caso de borde del cierre de M75): en el nivel 3 no hay flechas ni decimales con punto. El Cañón de
## nivel 3 mostraba «Área: radio 1.5» porque `TowerText.effects` usaba `%.1f`.
func test_panel_at_level_three_has_no_arrows_and_no_decimal_point() -> void:
	for id: String in ["cannon", "tesla", "frost", "disruptor"]:
		var panel: TowerPanel = _panel_with(id, 2)
		var full_text: String = "%s %s %s %s" % [panel.get_node("%Damage").text, panel.get_node("%Rate").text,
			panel.get_node("%Range").text, panel.get_node("%Stats").text]
		assert_false(full_text.contains("."), "%s nivel 3: decimales con coma (%s)" % [id, full_text])
		assert_false(full_text.contains(UpgradeDeltas.ARROW), "%s nivel 3: sin flechas" % id)
		assert_eq((panel.get_node("%UpgradeButton") as Button).text, "Nivel máximo")
	assert_eq(TowerText.effects(_tower("cannon").levels[2])[0], "Área: radio 1,5")


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
