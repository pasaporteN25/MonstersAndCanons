extends GutTest
# T290 a T292: regresiones de la auditoría T289 (catálogo, un dueño por toque, números de datos).
# Partida real en un SubViewport, modo celular, guardado de prueba.

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t290_touch_fixes.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _start(level_index: int) -> void:
	_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
	_game.level_data = GameFlow.level(level_index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame


## El orden de Godot en Android: primero el clic emulado, después el toque.
func _android_touch(pos: Vector2, pressed: bool) -> void:
	var mouse := InputEventMouseButton.new()
	mouse.position = pos
	mouse.global_position = pos
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = pressed
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	_viewport.push_input(mouse, true)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = pos
	touch.pressed = pressed
	_viewport.push_input(touch, true)
	await get_tree().process_frame


func _free_cell(tower: TowerData) -> Vector2i:
	for y: int in _game.level.map_size().y:
		for x: int in _game.level.map_size().x:
			if _game.build_controller.cells_free(tower, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _first_enabled_card() -> Button:
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		if not (child as Button).disabled:
			return child as Button
	return null


# --- T290 (H-03, H-04 de T289) ---

func test_catalog_card_tap_survives_a_gold_change() -> void:
	await _start(0)
	var chosen: Array[int] = [0]
	_game.mobile_hud.tower_chosen.connect(func(_i: int, _alt: bool) -> void: chosen[0] += 1)
	_game.mobile_hud.open_catalog()
	await get_tree().process_frame
	var card: Button = _first_enabled_card()
	assert_not_null(card)
	var center: Vector2 = card.get_global_rect().get_center()
	await _android_touch(center, true)
	_game.session.earn(1)  # muere un enemigo con el dedo apoyado
	await get_tree().process_frame
	await _android_touch(center, false)
	assert_eq(chosen[0], 1, "el toque se cuenta aunque el oro cambie en el medio")


func test_open_catalog_updates_cards_in_place_when_gold_changes() -> void:
	await _start(0)
	_game.mobile_hud.open_catalog()
	var before: Array[Node] = _game.mobile_hud._tower_grid.get_children()
	_game.session.earn(5)
	_game.session.spend(5)
	var after: Array[Node] = _game.mobile_hud._tower_grid.get_children()
	assert_eq(after.size(), before.size())
	for i: int in before.size():
		assert_same(after[i], before[i], "la tarjeta %d es el mismo nodo (no se destruyó)" % i)
		assert_false(before[i].is_queued_for_deletion())


func test_in_place_update_changes_the_state_of_a_card() -> void:
	await _start(0)
	_game.mobile_hud.open_catalog()
	var card: Button = _first_enabled_card()
	var node_before: Button = card
	_game.session.spend(_game.session.gold)  # sin oro: la tarjeta se apaga
	assert_true(node_before.disabled, "la misma tarjeta quedó apagada")
	assert_false(node_before.is_queued_for_deletion())
	_game.session.earn(10000)
	assert_false(node_before.disabled, "y vuelve a encenderse con oro")


func test_closed_catalog_is_not_rebuilt_on_gold_changes() -> void:
	await _start(0)
	var before: Array[Node] = _game.mobile_hud._tower_grid.get_children()
	var text_before: String = (before[0] as Button).text
	_game.session.earn(7)
	_game.session.spend(3)
	var after: Array[Node] = _game.mobile_hud._tower_grid.get_children()
	assert_eq(after.size(), before.size())
	for i: int in before.size():
		assert_same(after[i], before[i], "cerrado: no se toca ninguna tarjeta")
	assert_eq((before[0] as Button).text, text_before)
	# Al abrirlo se actualiza con el oro de ese momento.
	_game.session.spend(_game.session.gold)
	_game.mobile_hud.open_catalog()
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		var button: Button = child as Button
		if button.text.contains("No disponible"):
			continue
		assert_true(button.disabled, "sin oro, al abrir todas las disponibles están apagadas")


func test_closed_catalog_does_not_list_towers_on_gold_changes() -> void:
	await _start(0)
	var calls: Array[int] = [0]
	_game.mobile_hud.catalog_opened.connect(func(_open: bool) -> void: calls[0] += 1)
	# Si se reconstruyera cerrado, cambiaría el set de datos: lo marcamos y vemos que no se pisa.
	_game.mobile_hud._catalog_gold = -12345
	_game.session.earn(3)
	assert_eq(_game.mobile_hud._catalog_gold, -12345, "cerrado: set_catalog_data no se llama")
	_game.mobile_hud.open_catalog()
	assert_eq(_game.mobile_hud._catalog_gold, _game.session.gold, "abierto: sí, con el oro actual")


func test_tower_icons_are_cached_between_refreshes() -> void:
	await _start(0)
	_game.mobile_hud.open_catalog()
	var icons_before: Array[Texture2D] = []
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		icons_before.append((child as Button).icon)
	_game.session.earn(1)
	var index: int = 0
	for child: Node in _game.mobile_hud._tower_grid.get_children():
		assert_same((child as Button).icon, icons_before[index], "el ícono %d no se vuelve a generar" % index)
		index += 1


func test_tab_structure_change_rebuilds_without_leftovers() -> void:
	await _start(6)  # nivel 7, con infraestructura
	_game.mobile_hud.open_catalog()
	var grid: GridContainer = _game.mobile_hud._infrastructure_grid
	_game.mobile_hud.set_catalog_data(_game.mobile_hud._catalog_towers, _game.available_towers,
		_game.session.gold, _game.session.resources, true, [])
	assert_eq(grid.get_child_count(), 0, "sin opciones no quedan tarjetas viejas en la grilla")


# --- T291 (H-05, H-06 de T289): un solo dueño por toque ---

func _select_placed_tower() -> Tower:
	var tower_data: TowerData = _game.available_towers[0]
	_game.session.earn(5000)
	_game.build_controller.try_build(tower_data, _free_cell(tower_data))
	var tower: Tower = _game.tower_container.get_child(0)
	_game.build_controller.select_placed(tower)
	await get_tree().process_frame
	await get_tree().process_frame
	return tower


func test_targeting_advances_once_per_android_touch() -> void:
	await _start(0)
	var tower: Tower = await _select_placed_tower()
	var modes: int = Tower.TargetMode.size()
	for round: int in 3:
		var before: int = tower.targeting
		var center: Vector2 = _game.mobile_hud._target_button.get_global_rect().get_center()
		await _android_touch(center, true)
		await _android_touch(center, false)
		assert_eq(tower.targeting, (before + 1) % modes, "toque %d: avanza un solo modo" % round)


func test_upgrade_goes_up_one_level_per_android_touch() -> void:
	await _start(0)
	var tower: Tower = await _select_placed_tower()
	var before: int = tower.level_number()
	var center: Vector2 = _game.mobile_hud._upgrade_button.get_global_rect().get_center()
	await _android_touch(center, true)
	await _android_touch(center, false)
	assert_eq(tower.level_number(), before + 1)


func test_sell_needs_two_separate_touches_with_android_order() -> void:
	await _start(0)
	var tower: Tower = await _select_placed_tower()
	var center: Vector2 = _game.mobile_hud._sell_button.get_global_rect().get_center()
	await _android_touch(center, true)
	await _android_touch(center, false)
	assert_true(is_instance_valid(tower) and not tower.is_queued_for_deletion(), "un toque solo arma")
	assert_true(_game.mobile_hud._sell_armed)


func test_status_buttons_do_not_take_the_emulated_click() -> void:
	await _start(0)
	for button: Button in [_game.mobile_hud._target_button, _game.mobile_hud._upgrade_button, _game.mobile_hud._sell_button]:
		assert_eq(button.mouse_filter, Control.MOUSE_FILTER_IGNORE, "%s no recibe el clic emulado" % button.name)


func test_placement_buttons_stay_inside_the_map_area_in_every_corner() -> void:
	await _start(0)
	_game.build_controller.select(0)
	await get_tree().process_frame
	var size: Vector2i = _game.level.map_size()
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(size.x - 1, 0), Vector2i(0, size.y - 1), Vector2i(size.x - 1, size.y - 1), Vector2i(19, 0), Vector2i(16, 0)]:
		_game.build_controller._move_mobile_ghost(cell)
		await get_tree().process_frame
		await get_tree().process_frame
		for button: Button in [_game.mobile_hud._confirm_button, _game.mobile_hud._cancel_button]:
			var rect: Rect2 = button.get_global_rect()
			assert_gte(rect.position.y, 64.0, "%s en %s: debajo de la barra de arriba" % [button.name, cell])
			assert_lte(rect.end.y, 624.0, "%s en %s: arriba de la barra de abajo" % [button.name, cell])
			assert_gte(rect.position.x, 0.0, "%s en %s: dentro por la izquierda" % [button.name, cell])
			assert_lte(rect.end.x, 1280.0, "%s en %s: dentro por la derecha" % [button.name, cell])
		var tick: Rect2 = _game.mobile_hud._confirm_button.get_global_rect()
		var cross: Rect2 = _game.mobile_hud._cancel_button.get_global_rect()
		assert_false(tick.intersects(cross), "la tilde y la cruz no se pisan en %s" % cell)


func test_touch_on_top_bar_speed_button_does_not_also_build() -> void:
	await _start(0)
	var tower_data: TowerData = _game.available_towers[0]
	_game.build_controller.select(0)
	await get_tree().process_frame
	_game.build_controller._move_mobile_ghost(Vector2i(19, 0))
	await get_tree().process_frame
	await get_tree().process_frame
	var gold_before: int = _game.session.gold
	var speed_button: Button = _game.hud.find_child("SpeedButton", true, false) as Button
	var center: Vector2 = speed_button.get_global_rect().get_center() if speed_button != null else Vector2(1200.0, 30.0)
	await _android_touch(center, true)
	await _android_touch(center, false)
	assert_eq(_game.session.gold, gold_before, "tocar la velocidad no construye")
	assert_eq(_game.tower_container.get_child_count(), 0)
	assert_not_null(tower_data)
