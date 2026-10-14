# Construcción y manejo de torres (spec §5.1 y §5.5, plan §6.6):
# - construir: elegir torre, vista previa verde/roja, validar, cobrar y crear;
# - torres ya construidas: seleccionar, mejorar y vender.
# Lleva el registro de casillas ocupadas.
class_name BuildController
extends Node2D

## Se creó una torre. Game la conecta (por ejemplo, para recibir sus proyectiles).
signal tower_built(tower: Tower)
## Una torre subió de nivel (RF-71).
signal tower_upgraded(tower: Tower)
## Se vendió una torre; `refund` es el oro devuelto (RF-72) y `resource_refund` los recursos (RF-418).
signal tower_sold(tower: Tower, refund: int, resource_refund: int)
## RF-419: cambió la forma de pago elegida (false = solo oro).
signal payment_changed(alt: bool)
## Cambió la torre elegida para construir. -1 = ninguna.
signal selection_changed(index: int)
## Cambió la torre construida seleccionada. null = ninguna (RF-73).
signal placed_selection_changed(tower: Tower)

const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const VALID_TINT := Color(0.3, 1.0, 0.3, 0.3)
const INVALID_TINT := Color(1.0, 0.25, 0.25, 0.35)

var _level: Level
var _session: LevelSession
var _balance: BalanceConfig
var _tower_types: Array[TowerData] = []
var _container: Node
## Índice de la torre elegida para construir. -1 = ninguna.
var _selected: int = -1
## Torre ya construida que está seleccionada (con el panel abierto). null = ninguna.
var _selected_placed: Tower
## Casillas ocupadas: { Vector2i: Tower }.
var _occupied: Dictionary = {}
var _hover_cell: Vector2i = Vector2i.ZERO
## RF-419: la torre elegida se paga con la segunda forma (oro + recursos). Arranca en false.
var _pay_alt: bool = false
## RF-404: los removibles del mapa. Lo pone Game; null = este controlador no los conoce (sirve para los tests).
var obstacles: InfrastructureController
## RF-456: con el diálogo de la flecha abierto (RF-460) ninguna tecla ni clic llega a la construcción.
var input_blocked: bool = false


## `container` es el nodo donde se agregan las torres (Game/Towers).
func setup(level: Level, session: LevelSession, balance: BalanceConfig,
		tower_types: Array[TowerData], container: Node) -> void:
	_level = level
	_session = session
	_balance = balance
	_tower_types = tower_types
	_container = container
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023: torre fantasma


# --- Elegir torre para construir (RF-40, RF-43) ---

func selected_tower() -> TowerData:
	return null if _selected < 0 else _tower_types[_selected]


## Elegir la misma torre otra vez la deselecciona.
func select(index: int) -> void:
	if index < 0 or index >= _tower_types.size():
		return
	deselect_placed()  # RF-73: nunca las dos cosas a la vez
	if obstacles != null:
		obstacles.deselect()
	_selected = -1 if index == _selected else index
	set_pay_alt(false)  # RF-419: "solo oro" elegido de entrada
	selection_changed.emit(_selected)
	queue_redraw()


func cancel() -> void:
	if _selected == -1:
		return
	_selected = -1
	set_pay_alt(false)
	selection_changed.emit(_selected)
	queue_redraw()


## RF-419: elige la forma de pago de la torre elegida. Si no tiene dos formas, queda en solo oro.
func set_pay_alt(alt: bool) -> void:
	var tower: TowerData = selected_tower()
	alt = alt and tower != null and tower.has_alt_payment()
	if alt == _pay_alt:
		return
	_pay_alt = alt
	payment_changed.emit(_pay_alt)
	queue_redraw()


func pay_alt() -> bool:
	return _pay_alt


# --- Construir (RF-42) ---

func is_occupied(cell: Vector2i) -> bool:
	return _occupied.has(cell)


func tower_at(cell: Vector2i) -> Tower:
	return _occupied.get(cell)


## RF-290: las casillas de una torre de lado `footprint` cuya casilla de arriba a la izquierda es `origin`.
static func footprint_cells(origin: Vector2i, footprint: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in footprint:
		for x: int in footprint:
			cells.append(origin + Vector2i(x, y))
	return cells


## RF-292: la casilla de arriba a la izquierda de una torre de lado `footprint` para el mouse en `global_pos`.
## Con lado 1 es la casilla de siempre; con lado 2 el cuadrado queda centrado en el mouse.
func origin_for(global_pos: Vector2, footprint: int) -> Vector2i:
	return _level.cell_at(global_pos - Vector2.ONE * (footprint - 1) * Rules.TILE_SIZE / 2.0)


## RF-291: todas las casillas son construibles y están libres.
func cells_free(tower: TowerData, origin: Vector2i) -> bool:
	for cell: Vector2i in footprint_cells(origin, tower.footprint):
		if not _level.is_buildable(cell) or is_occupied(cell):
			return false
	return true


## `cell` es la casilla de arriba a la izquierda. Casillas libres, con oro suficiente, la partida no
## terminó y no está en pausa (RF-104).
func can_build(tower: TowerData, cell: Vector2i, alt: bool = false) -> bool:
	return not _session.is_over() \
		and (tower.required_collection == &"" or _tower_types.has(tower)) \
		and not get_tree().paused \
		and cells_free(tower, cell) \
		and _session.can_afford_both(tower.build_gold(alt), tower.build_resources(alt))


## Cobra (oro y recursos, los dos o ninguno: RF-418) y crea la torre. `alt` = segunda forma de pago (RF-419).
## Devuelve false (y no cambia nada) si no se puede construir ahí.
func try_build(tower_data: TowerData, cell: Vector2i, alt: bool = false) -> bool:
	if not can_build(tower_data, cell, alt):
		return false
	_session.spend_both(tower_data.build_gold(alt), tower_data.build_resources(alt))
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(tower_data, alt and tower_data.has_alt_payment())
	tower.origin_cell = cell
	# RF-293: en el centro del cuadrado (el contenedor está en el origen).
	tower.position = _level.cell_center(cell) + Vector2.ONE * (tower_data.footprint - 1) * Rules.TILE_SIZE / 2.0
	_container.add_child(tower)
	for occupied: Vector2i in tower.cells():
		_occupied[occupied] = tower
	tower_built.emit(tower)
	queue_redraw()
	return true


# --- Torres construidas: seleccionar, mejorar, vender (RF-70 a RF-76) ---

func selected_placed() -> Tower:
	return _selected_placed


func select_placed(tower: Tower) -> void:
	cancel()  # RF-73: nunca las dos cosas a la vez
	if obstacles != null and tower != null:
		obstacles.deselect()
	if tower == _selected_placed:
		return
	_selected_placed = tower
	placed_selection_changed.emit(tower)
	queue_redraw()


func deselect_placed() -> void:
	if _selected_placed == null:
		return
	_selected_placed = null
	placed_selection_changed.emit(null)
	queue_redraw()


func can_upgrade(tower: Tower) -> bool:
	return not _session.is_over() and tower.can_upgrade() \
		and _session.can_afford(tower.next_level_stats().cost)


## Cobra y sube un nivel. Devuelve false (y no cambia nada) si no se puede.
func try_upgrade(tower: Tower) -> bool:
	if tower == null or not can_upgrade(tower):
		return false
	_session.spend(tower.next_level_stats().cost)
	tower.apply_upgrade()
	tower_upgraded.emit(tower)
	queue_redraw()  # el círculo de alcance puede haber crecido
	return true


## Oro que devolvería vender esta torre ahora (RF-72).
func sell_value(tower: Tower) -> int:
	return Rules.sell_refund(tower.total_invested, _balance)


## RF-418 y RF-423: los recursos que devolvería vender esta torre; el mismo %, redondeado hacia abajo.
func sell_resource_value(tower: Tower) -> int:
	return Rules.sell_refund(tower.resources_invested, _balance)


## Vende la torre: devuelve el oro y los recursos, libera la casilla y la borra. Devuelve el oro devuelto.
func sell(tower: Tower) -> int:
	if tower == null or _session.is_over():
		return 0
	var refund: int = sell_value(tower)
	var resource_refund: int = sell_resource_value(tower)
	_session.earn(refund)
	_session.add_resources(resource_refund)
	for occupied: Vector2i in tower.cells():  # RF-294: se liberan todas sus casillas
		_occupied.erase(occupied)
	if tower == _selected_placed:
		deselect_placed()
	tower_sold.emit(tower, refund, resource_refund)
	tower.queue_free()
	return refund


# --- Entrada y dibujo ---

func _process(_delta: float) -> void:
	if _selected < 0:
		return
	_hover_cell = origin_for(get_global_mouse_position(), _tower_types[_selected].footprint)
	queue_redraw()  # se redibuja siempre: el color también cambia si cambia el oro


func _unhandled_input(event: InputEvent) -> void:
	if input_blocked:
		return
	for i: int in _tower_types.size():
		var action: StringName = BarLayout.action_for(i)  # RF-456: la torre 11 en adelante no tiene tecla
		if action != &"" and event.is_action_pressed(action):
			select(i)
			_accept()
			return
	if _selected >= 0:
		_handle_build_mode_input(event)
	else:
		_handle_selection_input(event)


## RF-404: el removible bajo el mouse, si lo hay (null si no hay o no se puede elegir).
func _obstacle_under_mouse() -> Vector2i:
	if obstacles == null:
		return InfrastructureController.NONE
	var cell: Vector2i = _level.cell_at(get_global_mouse_position())
	return cell if obstacles.obstacle_at(cell) != null else InfrastructureController.NONE


## RF-73 y RF-404: elegir un removible deselecciona la torre y el modo construcción.
func _select_obstacle(cell: Vector2i) -> void:
	cancel()
	deselect_placed()
	obstacles.select(cell)


func _handle_build_mode_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or _is_click(event, MOUSE_BUTTON_RIGHT):
		cancel()
		_accept()
	elif _is_click(event, MOUSE_BUTTON_LEFT):
		var obstacle: Vector2i = _obstacle_under_mouse()
		if obstacle != InfrastructureController.NONE:
			_select_obstacle(obstacle)  # RF-404: en el modo construcción, un removible se elige, no se construye
			_accept()
			return
		# RF-43: la vista previa sigue activa para construir otra igual.
		try_build(selected_tower(), origin_for(get_global_mouse_position(), selected_tower().footprint), _pay_alt)
		_accept()


func _handle_selection_input(event: InputEvent) -> void:
	if _is_click(event, MOUSE_BUTTON_LEFT):
		var cell: Vector2i = _level.cell_at(get_global_mouse_position())
		if not _level.is_inside(cell):
			return  # clic fuera del mapa (por ejemplo, en el HUD): no tocar la selección
		var tower: Tower = tower_at(cell)
		if obstacles != null and tower == null and obstacles.obstacle_at(cell) != null:
			_select_obstacle(cell)
		elif tower != null:
			select_placed(tower)
		else:
			deselect_placed()
			if obstacles != null:
				obstacles.deselect()  # un clic fuera deselecciona
		_accept()
	elif obstacles != null and obstacles.has_selection() \
			and (event.is_action_pressed("cancel") or _is_click(event, MOUSE_BUTTON_RIGHT)):
		obstacles.deselect()
		_accept()
	elif _selected_placed == null:
		return
	elif event.is_action_pressed("cancel") or _is_click(event, MOUSE_BUTTON_RIGHT):
		deselect_placed()
		_accept()
	elif event.is_action_pressed("upgrade"):
		try_upgrade(_selected_placed)
		_accept()
	elif event.is_action_pressed("sell"):
		sell(_selected_placed)
		_accept()


func _is_click(event: InputEvent, button: MouseButton) -> bool:
	var mouse := event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == button


func _accept() -> void:
	get_viewport().set_input_as_handled()


func _draw() -> void:
	if _selected_placed != null:
		_draw_range(_selected_placed.global_position, _selected_placed.range_px())
	var tower: TowerData = selected_tower()
	if tower == null:
		return
	var cells: Array[Vector2i] = footprint_cells(_hover_cell, tower.footprint)
	if not cells.any(_level.is_inside):
		return
	# RF-40, RF-41 y RF-292: casillas verdes/rojas (todas las de la torre), torre fantasma y círculo de alcance.
	var tile: float = Rules.TILE_SIZE
	var center: Vector2 = _level.cell_center(_hover_cell) + Vector2.ONE * (tower.footprint - 1) * tile / 2.0
	var tint: Color = VALID_TINT if can_build(tower, _hover_cell, _pay_alt) else INVALID_TINT
	for cell: Vector2i in cells:
		var cell_center: Vector2 = _level.cell_center(cell)
		draw_rect(Rect2(cell_center - Vector2(tile, tile) / 2.0, Vector2(tile, tile)), tint)
	var side: float = tile * tower.footprint
	var cell_rect := Rect2(center - Vector2(side, side) / 2.0, Vector2(side, side))
	var base: Texture2D = tower.levels[0].base_texture
	if base != null and tower.turret_texture != null:
		# RF-150: la torre de nivel 1 con su torreta mirando hacia arriba, semitransparente.
		var ghost := Color(1, 1, 1, 0.6)
		draw_texture_rect(base, cell_rect, false, ghost)
		draw_set_transform(center, -PI / 2.0)
		draw_texture_rect(tower.turret_texture, Rect2(-cell_rect.size / 2.0, cell_rect.size), false, ghost)
		draw_set_transform(Vector2.ZERO)
	else:  # RF-156: sin dibujos, el cuadrado de color.
		var half: float = Rules.tiles_to_px(Tower.BODY_SIZE_TILES) / 2.0 * tower.footprint
		draw_rect(Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0), Color(tower.color, 0.6))
	_draw_range(center, Rules.tiles_to_px(tower.levels[0].range_tiles))


func _draw_range(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, Color(1, 1, 1, 0.08))
	draw_arc(center, radius, 0.0, TAU, 64, Color(1, 1, 1, 0.7), 2.0)
