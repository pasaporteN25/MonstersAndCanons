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
