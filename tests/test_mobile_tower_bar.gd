# T511 y T514 (RF-722, CEL-B): la barra de la torre elegida en el celular. Dos renglones cortos con coma decimal y
# alcance con decimales, «Mejorar» de 320 × 84 con lo que se compra abajo, «Apuntar» como ícono con el modo (y ausente
# si la torre no apunta), la separación de seguridad entre «Mejorar» y «Vender» (35 mm, RF-512/RF-513), todo botón
# de 56 px o más y nada fuera de los 96 px de la barra ni de la pantalla.
extends GutTest

const TEST_SAVE: String = "user://test_mobile_tower_bar_save.json"
const ALL_TOWERS: Array[String] = ["basic", "burst", "cannon", "disruptor", "fire", "frost", "mechanical_standard", "mortar", "multi", "sniper", "tesla"]
const ACTION_NODES: Array[String] = ["MobileTargeting", "MobileUpgrade", "MobileSell", "BottomCancelPlacement"]
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


func _new_game() -> Game:
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	return game


func _node(game: Game, node_name: String) -> Control:
	return game.mobile_hud.find_child(node_name, true, false) as Control


func _status(game: Game) -> Label:
	return _node(game, "StatusText") as Label


func _upgrade(game: Game) -> Button:
	return _node(game, "MobileUpgrade") as Button


func _change(game: Game) -> Label:
	return _node(game, "MobileUpgradeChange") as Label


## Lo que RF-512 y RF-513 piden entre «Mejorar» y «Vender»: 35 mm en píxeles virtuales (T262, RF-722).
func _required_separation(game: Game) -> float:
	return game.mobile_hud._catalog_virtual_mm(float(MobileUiConfig.load_from().get_value("vender_separacion_mm")))


## ¿Hay un decimal con punto («2.5»)? «Alc.» lleva punto y no cuenta.
func _has_decimal_point(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[0-9]\\.[0-9]")
	return regex.search(text) != null


func _worn_or_stunned(text: String) -> bool:
	return text.contains("Desgaste") or text.contains("Aturdida")


## Todo lo que la barra tiene que cumplir para cualquier torre elegida (RF-722, RF-550).
func _assert_bar_ok(game: Game, label_text: String) -> void:
	var hud: Node = game.mobile_hud
	var bar: Control = _node(game, "MobileStatusBar")
	var bar_rect: Rect2 = bar.get_global_rect()
	var screen: Rect2 = Rect2(Vector2.ZERO, Vector2(Rules.SCREEN_SIZE))
	assert_eq(bar.size.y, 96.0, label_text + ": la barra mide 96 px")
	assert_true(screen.encloses(bar_rect), label_text + ": la barra está dentro de la pantalla")
	var status: Label = _status(game)
	var lines: int = status.text.count("\n") + 1
	assert_true(lines == 2 or (lines == 3 and _worn_or_stunned(status.text)), label_text + ": dos renglones cortos (tres solo con el estado aparte)")
	assert_false(status.text.contains("Al mejorar"), label_text + ": sin «Al mejorar»")
	assert_false(_has_decimal_point(status.text), label_text + ": coma decimal, ni un punto: " + status.text)
	assert_gte(status.get_theme_font_size("font_size"), 16, label_text + ": letra de 16 px o más")
	var widest: float = MobileHud.widest_line(status.get_theme_font("font"), status.text, status.get_theme_font_size("font_size"))
	assert_lte(widest, status.size.x + 0.5, "%s: el renglón más ancho (%.0f px) entra en el texto (%.0f px)" % [label_text, widest, status.size.x])
	assert_eq(status.get_line_count(), lines, label_text + ": no se parte")
	assert_lte(status.get_combined_minimum_size().y, bar.size.y, label_text + ": el texto entra en el alto de la barra")
	for node_name: String in ["StatusText", "SellSeparation"] + ACTION_NODES:
		var control: Control = _node(game, node_name)
		if node_name == "MobileTargeting" and not control.visible:
			continue
		assert_true(control.visible, label_text + ": " + node_name)
		var rect: Rect2 = control.get_global_rect()
		assert_true(screen.encloses(rect), "%s: %s dentro de la pantalla (%s)" % [label_text, node_name, rect])
		assert_gte(rect.position.y, bar_rect.position.y - 0.5, "%s: %s no pasa del borde de arriba de la barra" % [label_text, node_name])
		assert_lte(rect.end.y, bar_rect.end.y + 0.5, "%s: %s no pasa del borde de abajo de la barra" % [label_text, node_name])
	for node_name: String in ACTION_NODES:
		var control: Control = _node(game, node_name)
		if control.visible:
			assert_gte(control.size.x, 56.0, "%s: %s mide 56 px o más de ancho" % [label_text, node_name])
			assert_gte(control.size.y, 56.0, "%s: %s mide 56 px o más de alto" % [label_text, node_name])
	var upgrade: Button = _upgrade(game)
	assert_eq(upgrade.size, Vector2(320.0, 84.0), label_text + ": «Mejorar» mide 320 × 84")
	assert_eq(_node(game, "MobileSell").size, Vector2(150.0, 84.0), label_text + ": «Vender» mide 150 × 84")
	var gap: float = _node(game, "MobileSell").global_position.x - (upgrade.global_position.x + upgrade.size.x)
	assert_gte(gap, _required_separation(game), "%s: «Mejorar» y «Vender» separados al menos 35 mm (%.0f px)" % [label_text, gap])
	var change: Label = _change(game)
	if change.visible:
		var change_width: float = MobileHud.widest_line(change.get_theme_font("font"), change.text, change.get_theme_font_size("font_size"))
		assert_lte(change_width, upgrade.size.x - 12.0 + 0.5, "%s: lo que se compra entra en el botón (%.0f px)" % [label_text, change_width])
		assert_false(_has_decimal_point(change.text), label_text + ": coma decimal en el botón: " + change.text)
		assert_lte(change.text.count("→"), 2, label_text + ": hasta 2 estadísticas")
		assert_lte(change.get_rect().end.y, upgrade.size.y, label_text + ": la parte de abajo cabe en el botón")


func test_frost_level_one_has_the_cel_b_order_sizes_and_two_short_lines() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	assert_not_null(tower)
	await wait_process_frames(5)
	var lines: PackedStringArray = _status(game).text.split("\n")
	assert_eq(lines[0], "Hielo ●○○", "renglón 1: el nombre con los puntos de nivel")
	assert_eq(lines[1], "Daño 2 · 1/s · Alc. 2,5", "renglón 2: el estado actual abreviado, con el alcance real y con coma")
	assert_eq(_node(game, "MobileTargeting").size, Vector2(112.0, 84.0), "«Apuntar» es un ícono de 112 × 84")
	assert_eq(_node(game, "BottomCancelPlacement").size, Vector2(64.0, 64.0), "la × no cambia")
	# El orden de izquierda a derecha de la maqueta: texto, ×, Apuntar, Mejorar, separación, Vender.
	var xs: Array[float] = []
	for node_name: String in ["StatusText", "BottomCancelPlacement", "MobileTargeting", "MobileUpgrade", "SellSeparation", "MobileSell"]:
		xs.append(_node(game, node_name).global_position.x)
	for i: int in range(1, xs.size()):
		assert_gt(xs[i], xs[i - 1], "el hijo %d va a la derecha del anterior" % i)
	_assert_bar_ok(game, "Hielo 1")


func test_aim_button_is_an_icon_with_the_mode_underneath() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	await wait_process_frames(3)
	var aim: Button = _node(game, "MobileTargeting") as Button
	assert_not_null(aim.icon, "tiene el ícono de la mira")
	assert_eq(aim.text, "Primero", "dice el modo y nada más")
	assert_eq(aim.vertical_icon_alignment, VERTICAL_ALIGNMENT_TOP, "el ícono arriba y el modo debajo")
	assert_true(aim.tooltip_text.contains("Apuntar"))
	aim.pressed.emit()
	await wait_process_frames(2)
	assert_eq(tower.targeting, Tower.TargetMode.LAST, "tocarlo sigue cambiando el modo")
	assert_eq(aim.text, "Último")


func test_tesla_level_one_upgrade_button_has_two_parts_with_what_you_buy() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "tesla")
	await wait_process_frames(5)
	assert_eq(_status(game).text, "Eléctrica ●○○\nDaño 13 · 0,75/s · Alc. 2,5")
	var upgrade: Button = _upgrade(game)
	assert_eq(upgrade.text, "Mejorar → N2  %d" % tower.next_level_stats().cost, "arriba: a qué nivel pasa y cuánto cuesta")
	assert_true((_node(game, "MobileUpgradeCoin") as Control).visible, "con la moneda")
	assert_eq(_change(game).text, "daño 13 → 19 · disp/s 0,75 → 0,85", "abajo: hasta 2 estadísticas, con coma decimal")
	assert_eq(_change(game).get_theme_color("font_color"), MobileHud.UPGRADE_AFTER_COLOR, "en el verde del «después»")
	_assert_bar_ok(game, "Eléctrica 1")


func test_first_tap_arms_with_confirm_text_and_keeps_cost_and_changes() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "tesla")
	await wait_process_frames(3)
	var gold_before: int = game.session.gold
	game.mobile_hud._on_upgrade_pressed()
	await wait_process_frames(5)
	var upgrade: Button = _upgrade(game)
	assert_eq(upgrade.text, "Tocá para confirmar  %d" % tower.next_level_stats().cost, "arriba: confirmar y el costo")
	assert_eq(_change(game).text, "daño 13 → 19 · disp/s 0,75 → 0,85", "abajo: los mismos cambios")
	assert_true(game.mobile_hud.is_upgrade_armed())
	assert_eq(tower.level_number(), 1, "armar no mejora")
	assert_eq(game.session.gold, gold_before, "ni cobra")
	_assert_bar_ok(game, "Eléctrica 1 armada")


func test_without_gold_upgrade_says_how_much_is_missing_and_keeps_the_changes() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "basic")
	var cost: int = tower.next_level_stats().cost
	game.session.set_gold(cost - 25)
	game._refresh_tower_panel()
	await wait_process_frames(5)
	var upgrade: Button = _upgrade(game)
	assert_true(upgrade.disabled, "apagado")
	assert_eq(upgrade.text, "Faltan 25 de oro")
	assert_eq(_change(game).text, "daño 5 → 8 · disp/s 2 → 2,5", "y debajo, los mismos cambios")
	assert_false((_node(game, "MobileUpgradeCoin") as Control).visible, "sin moneda: no hay costo que pagar")
	game.mobile_hud._on_upgrade_pressed()
	assert_false(game.mobile_hud.is_upgrade_armed(), "tocarlo sin oro no arma nada")
	_assert_bar_ok(game, "Ametralladora 1 sin oro")


func test_max_level_says_so_alone() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	while tower.can_upgrade():
		tower.apply_upgrade()
	game._refresh_tower_panel()
	await wait_process_frames(5)
	assert_eq(_upgrade(game).text, "Nivel máximo")
	assert_true(_upgrade(game).disabled)
	assert_false(_change(game).visible, "«Nivel máximo» va solo")
	assert_eq(_status(game).text, "Hielo ●●●\nDaño 4 · 1/s · Alc. 3")
	_assert_bar_ok(game, "Hielo 3")


func test_support_tower_has_no_aim_button_and_no_damage() -> void:
	var game: Game = await _new_game()
	_select(game, "mechanical_standard")
	await wait_process_frames(5)
	assert_false(_node(game, "MobileTargeting").visible, "el Estandarte no apunta: no hay botón")
	var status: Label = _status(game)
	assert_false(status.text.contains("Daño"), status.text)
	assert_false(status.text.contains("/s"), "ni cadencia: " + status.text)
	assert_true(status.text.split("\n")[1].begins_with("Alc. "), status.text)
	assert_true(_node(game, "MobileUpgrade").global_position.x > _node(game, "BottomCancelPlacement").global_position.x)
	_assert_bar_ok(game, "Estandarte 1")


func test_pulse_tower_has_no_aim_button() -> void:
	var game: Game = await _new_game()
	_select(game, "disruptor")
	await wait_process_frames(5)
	assert_false(_node(game, "MobileTargeting").visible, "la Disruptora no apunta")
	_assert_bar_ok(game, "Disruptora 1")


func test_safety_gap_between_upgrade_and_sell_is_measured_against_35_mm() -> void:
	var game: Game = await _new_game()
	_select(game, "tesla")
	await wait_process_frames(5)
	var upgrade: Control = _upgrade(game)
	var sell: Control = _node(game, "MobileSell")
	var gap: float = sell.global_position.x - upgrade.get_global_rect().end.x
	var required: float = _required_separation(game)
	gut.p("T514 medido: «Mejorar» → «Vender» %.1f px lógicos (35 mm = %.1f px; la maqueta CEL-B deja ≈ 312 px)" % [gap, required])
	assert_gte(gap, required, "la separación real no baja de 35 mm")
	assert_gt(gap, 312.0, "y supera la de la maqueta, que no alcanzaba")
	assert_gte(_node(game, "SellSeparation").size.x, required, "el espaciador solo ya mide 35 mm")


func test_bar_font_returns_to_normal_when_selection_is_released() -> void:
	var game: Game = await _new_game()
	_select(game, "frost")
	await wait_process_frames(3)
	var status: Label = _status(game)
	assert_gte(status.get_theme_font_size("font_size"), 16)
	assert_eq(status.autowrap_mode, TextServer.AUTOWRAP_OFF, "en el estado «torre» los renglones no se parten")
	game.mobile_hud.show_selected_tower(null, 0, 0, 0, false)
	assert_eq(status.get_theme_font_size("font_size"), 16, "sin torre vuelve a la letra normal")
	assert_eq(status.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART, "y a partirse en renglones")


func test_stunned_and_worn_state_is_always_visible() -> void:
	var game: Game = await _new_game()
	var tower: Tower = _select(game, "frost")
	tower.wear_percent = 40
	game._refresh_tower_panel()
	await wait_process_frames(3)
	var status: Label = _status(game)
	assert_true(status.text.contains("Desgaste 40 %"), "el desgaste se ve en el texto: " + status.text)
	assert_true(status.text.begins_with("Hielo ●○○"))
	assert_true(status.text.contains("Alc. 2,5"), "y el estado actual sigue completo")
	game.build_controller.deselect_placed()
	var long_tower: Tower = _select(game, "basic")
	long_tower.wear_percent = 40
	game._refresh_tower_panel()
	await wait_process_frames(3)
	assert_true(_status(game).text.contains("Desgaste 40 %"), "también en un nombre largo, sin cortarse: " + _status(game).text)
	_assert_bar_ok(game, "Ametralladora 1 con desgaste")
	tower.stun(1.0)
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	await wait_process_frames(3)
	assert_true(_status(game).text.contains("Aturdida"), "y aturdida: " + _status(game).text)
	_assert_bar_ok(game, "Hielo 1 aturdida")
	game.build_controller.select_placed(tower)
	_assert_bar_ok(game, "Hielo 1 con desgaste")


func test_every_tower_at_every_level_fits_the_cel_b_bar() -> void:
	var game: Game = await _new_game()
	var checked: int = 0
	var min_font: int = 99
	var max_font: int = 0
	for id: String in ALL_TOWERS:
		var tower: Tower = _select(game, id)
		if tower == null:
			continue  # sin lugar libre en el mapa de prueba: no se mide
		var guard: int = 0
		while guard < 4:
			guard += 1
			game.session.earn(5000)
			game.build_controller.select_placed(tower)
			game._refresh_tower_panel()
			await wait_process_frames(2)
			_assert_bar_ok(game, "%s N%d" % [id, tower.level_number()])
			checked += 1
			min_font = mini(min_font, _status(game).get_theme_font_size("font_size"))
			max_font = maxi(max_font, _status(game).get_theme_font_size("font_size"))
			if not tower.can_upgrade():
				break
			game.build_controller.try_upgrade(tower)
	gut.p("T514 medido: letra del texto de %d casos entre %d y %d px" % [checked, min_font, max_font])
	assert_gte(checked, 30, "se midieron las 11 torres en sus 3 niveles (%d casos)" % checked)
