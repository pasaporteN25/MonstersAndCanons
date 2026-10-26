# T511: la barra de la torre elegida en el celular usa la coma decimal (RF-677.4), dice el alcance real y entra
# en sus 96 px sin cortar ninguna línea ni salirse de la pantalla.
extends GutTest

const TEST_SAVE: String = "user://test_mobile_tower_bar_save.json"
var _original_save_path: String
var _original_mode: Variant


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	_original_mode = SaveManager.get_setting("ui_mode")
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = _original_save_path
	SaveManager.load_save()


func _select(game: Game, id: String) -> Tower:
	var data: TowerData = load("res://data/towers/%s.tres" % id) as TowerData
	game.session.earn(5000)
	game.session.add_resources(1000)
	if not game.build_controller._tower_types.has(data):
		game.build_controller._tower_types.append(data)
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and game.build_controller.cells_free(data, cell) \
					and game.build_controller.try_build(data, cell):
				var tower: Tower = game.build_controller.tower_at(cell)
				game.build_controller.select_placed(tower)
				game._refresh_tower_panel()
				return tower
	return null


func _assert_bar_fits(game: Game, label_text: String) -> void:
	var hud: Node = game.mobile_hud
	var status: Label = hud.find_child("StatusText", true, false) as Label
	var bar: Control = hud.find_child("MobileStatusBar", true, false) as Control
	var limit: Rect2 = Rect2(Vector2.ZERO, Vector2(Rules.SCREEN_SIZE))
	assert_lte(bar.size.y, 96.0, label_text + ": la barra mide 96 px")
	assert_lte(status.size.y, 96.0, label_text + ": el texto no pasa del alto de la barra")
	assert_lte(status.get_combined_minimum_size().y, status.size.y + 0.5, label_text + ": ninguna línea queda cortada")
	assert_eq(status.get_line_count(), status.get_visible_line_count(), label_text + ": se ven todos los renglones")
	for node_name: String in ["StatusText", "MobileTargeting", "MobileUpgrade", "MobileSell", "BottomCancelPlacement"]:
		var control: Control = hud.find_child(node_name, true, false) as Control
		assert_true(control.visible, node_name)
		var rect: Rect2 = control.get_global_rect()
		assert_true(limit.encloses(rect), "%s: %s dentro de la pantalla (%s)" % [label_text, node_name, rect])
		assert_lte(rect.end.y, bar.get_global_rect().end.y + 0.5, "%s: %s no pasa del borde de la barra" % [label_text, node_name])
	assert_true(status.text.contains("Al mejorar:"), label_text + ": «Al mejorar» sigue en el texto")


func _new_game() -> Game:
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	return game


func test_frost_level_one_bar_uses_decimal_comma_real_range_and_fits() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	assert_not_null(tower)
	await wait_process_frames(5)
	var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_true(status.text.contains("Alcance 2,5"), status.text)
	assert_true(status.text.contains("Cadencia 1 "), "1.00 se escribe 1: " + status.text)
	assert_false(status.text.contains("Alcance 2 "), status.text)
	assert_false(status.text.contains("."), "ni un punto decimal: " + status.text)
	_assert_bar_fits(game, "Hielo 1")


func test_tesla_level_one_bar_uses_decimal_comma_real_range_and_fits() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "tesla")
	assert_not_null(tower)
	await wait_process_frames(5)
	var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_true(status.text.contains("Alcance 2,5"), status.text)
	assert_true(status.text.contains("Cadencia 0,75"), status.text)
	assert_false(status.text.contains("."), "ni un punto decimal: " + status.text)
	_assert_bar_fits(game, "Eléctrica 1")


func test_armed_upgrade_keeps_the_bar_inside_the_screen() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	await wait_process_frames(3)
	game.mobile_hud._on_upgrade_pressed()
	await wait_process_frames(5)
	assert_true((game.mobile_hud.find_child("MobileUpgrade", true, false) as Button).text.contains("Confirmar"))
	_assert_bar_fits(game, "Hielo 1 armado")
	assert_eq(tower.level_number(), 1, "armar no mejora")


func test_bar_font_returns_to_normal_when_selection_is_released() -> void:
	var game: Game = await _new_game()
	_select(game, "frost")
	await wait_process_frames(3)
	var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
	assert_lt(status.get_theme_font_size("font_size"), 16, "con tanto texto la letra baja")
	game.mobile_hud.show_selected_tower(null, 0, 0, 0, false)
	assert_eq(status.get_theme_font_size("font_size"), 16, "sin torre vuelve a la letra normal")


func test_every_tower_at_every_level_fits_in_the_bar() -> void:
	var game: Game = await _new_game()
	for id: String in ["basic", "burst", "cannon", "disruptor", "fire", "frost", "mechanical_standard", "mortar", "multi", "sniper", "tesla"]:
		var tower: Tower = _select(game, id)
		if tower == null:
			continue  # sin lugar libre en el mapa de prueba: no se mide
		var guard: int = 0
		while guard < 4:
			guard += 1
			game.build_controller.select_placed(tower)
			game._refresh_tower_panel()
			await wait_process_frames(2)
			var status: Label = game.mobile_hud.find_child("StatusText", true, false) as Label
			assert_false(status.text.contains("."), "%s N%d: sin punto decimal: %s" % [id, tower.level_number(), status.text])
			assert_lte(status.get_combined_minimum_size().y, 96.0, "%s N%d entra en la barra" % [id, tower.level_number()])
			assert_eq(status.get_line_count(), status.get_visible_line_count(), "%s N%d: sin líneas cortadas" % [id, tower.level_number()])
			if not tower.can_upgrade():
				break
			game.session.earn(5000)
			game.build_controller.try_upgrade(tower)
