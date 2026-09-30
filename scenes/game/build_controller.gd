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
## Se vendió una torre; `refund` es el oro devuelto (RF-72).
signal tower_sold(tower: Tower, refund: int)
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
	_selected = -1 if index == _selected else index
	selection_changed.emit(_selected)
	queue_redraw()


func cancel() -> void:
	if _selected == -1:
		return
	_selected = -1
	selection_changed.emit(_selected)
	queue_redraw()


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
func can_build(tower: TowerData, cell: Vector2i) -> bool:
	return not _session.is_over() \
		and not get_tree().paused \
		and cells_free(tower, cell) \
		and _session.can_afford(tower.levels[0].cost)


## Cobra y crea la torre. Devuelve false (y no cambia nada) si no se puede construir ahí.
func try_build(tower_data: TowerData, cell: Vector2i) -> bool:
	if not can_build(tower_data, cell):
		return false
	_session.spend(tower_data.levels[0].cost)
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(tower_data)
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


## Vende la torre: devuelve el oro, libera la casilla y la borra. Devuelve el oro devuelto.
func sell(tower: Tower) -> int:
	if tower == null or _session.is_over():
		return 0
	var refund: int = sell_value(tower)
	_session.earn(refund)
	for occupied: Vector2i in tower.cells():  # RF-294: se liberan todas sus casillas
		_occupied.erase(occupied)
	if tower == _selected_placed:
		deselect_placed()
	tower_sold.emit(tower, refund)
	tower.queue_free()
	return refund


# --- Entrada y dibujo ---

func _process(_delta: float) -> void:
	if _selected < 0:
		return
	_hover_cell = _level.cell_at(get_global_mouse_position())
	queue_redraw()  # se redibuja siempre: el color también cambia si cambia el oro


func _unhandled_input(event: InputEvent) -> void:
	for i: int in _tower_types.size():
		if event.is_action_pressed("build_%d" % (i + 1)):
			select(i)
			_accept()
			return
	if _selected >= 0:
		_handle_build_mode_input(event)
	else:
		_handle_selection_input(event)


func _handle_build_mode_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or _is_click(event, MOUSE_BUTTON_RIGHT):
		cancel()
		_accept()
	elif _is_click(event, MOUSE_BUTTON_LEFT):
		# RF-43: la vista previa sigue activa para construir otra igual.
		try_build(selected_tower(), origin_for(get_global_mouse_position(), selected_tower().footprint))
		_accept()


func _handle_selection_input(event: InputEvent) -> void:
	if _is_click(event, MOUSE_BUTTON_LEFT):
		var cell: Vector2i = _level.cell_at(get_global_mouse_position())
		if not _level.is_inside(cell):
			return  # clic fuera del mapa (por ejemplo, en el HUD): no tocar la selección
		var tower: Tower = tower_at(cell)
		if tower != null:
			select_placed(tower)
		else:
			deselect_placed()
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
	if tower == null or not _level.is_inside(_hover_cell):
		return
	# RF-40 y RF-41: casilla verde/roja, torre fantasma y círculo de alcance.
	var center: Vector2 = _level.cell_center(_hover_cell)
	var tile: float = Rules.TILE_SIZE
	var cell_rect := Rect2(center - Vector2(tile, tile) / 2.0, Vector2(tile, tile))
	draw_rect(cell_rect, VALID_TINT if can_build(tower, _hover_cell) else INVALID_TINT)
	var base: Texture2D = tower.levels[0].base_texture
	if base != null and tower.turret_texture != null:
		# RF-150: la torre de nivel 1 con su torreta mirando hacia arriba, semitransparente.
		var ghost := Color(1, 1, 1, 0.6)
		draw_texture_rect(base, cell_rect, false, ghost)
		draw_set_transform(center, -PI / 2.0)
		draw_texture_rect(tower.turret_texture, Rect2(-cell_rect.size / 2.0, cell_rect.size), false, ghost)
		draw_set_transform(Vector2.ZERO)
	else:  # RF-156: sin dibujos, el cuadrado de color.
		var half: float = Rules.tiles_to_px(Tower.BODY_SIZE_TILES) / 2.0
		draw_rect(Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0), Color(tower.color, 0.6))
	_draw_range(center, Rules.tiles_to_px(tower.levels[0].range_tiles))


func _draw_range(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, Color(1, 1, 1, 0.08))
	draw_arc(center, radius, 0.0, TAU, 64, Color(1, 1, 1, 0.7), 2.0)
