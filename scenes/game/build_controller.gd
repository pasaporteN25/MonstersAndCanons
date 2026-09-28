# Construcción de torres (spec §5.1, plan §6.6): elegir torre, vista previa verde/roja,
# validar la casilla, cobrar y crear la torre. Lleva el registro de casillas ocupadas.
class_name BuildController
extends Node2D

## Se creó una torre. Game la conecta (por ejemplo, para recibir sus proyectiles).
signal tower_built(tower: Tower)
## Cambió la torre elegida para construir. -1 = ninguna.
signal selection_changed(index: int)

const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const VALID_TINT := Color(0.3, 1.0, 0.3, 0.3)
const INVALID_TINT := Color(1.0, 0.25, 0.25, 0.35)

var _level: Level
var _session: LevelSession
var _tower_types: Array[TowerData] = []
var _container: Node
var _selected: int = -1
## Casillas ocupadas: { Vector2i: Tower }.
var _occupied: Dictionary = {}
var _hover_cell: Vector2i = Vector2i.ZERO


## `container` es el nodo donde se agregan las torres (Game/Towers).
func setup(level: Level, session: LevelSession, tower_types: Array[TowerData], container: Node) -> void:
	_level = level
	_session = session
	_tower_types = tower_types
	_container = container


func selected_tower() -> TowerData:
	return null if _selected < 0 else _tower_types[_selected]


## RF-40: elegir torre. Elegir la misma otra vez la deselecciona.
func select(index: int) -> void:
	if index < 0 or index >= _tower_types.size():
		return
	_selected = -1 if index == _selected else index
	selection_changed.emit(_selected)
	queue_redraw()


## RF-43: clic derecho o Esc.
func cancel() -> void:
	if _selected == -1:
		return
	_selected = -1
	selection_changed.emit(_selected)
	queue_redraw()


func is_occupied(cell: Vector2i) -> bool:
	return _occupied.has(cell)


func tower_at(cell: Vector2i) -> Tower:
	return _occupied.get(cell)


## RF-42: casilla libre, sin torre, con oro suficiente, y la partida no terminó.
func can_build(tower: TowerData, cell: Vector2i) -> bool:
	return not _session.is_over() \
		and _level.is_buildable(cell) \
		and not is_occupied(cell) \
		and _session.can_afford(tower.levels[0].cost)


## Cobra y crea la torre. Devuelve false (y no cambia nada) si no se puede construir ahí.
func try_build(tower_data: TowerData, cell: Vector2i) -> bool:
	if not can_build(tower_data, cell):
		return false
	_session.spend(tower_data.levels[0].cost)
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(tower_data)
	tower.position = _level.cell_center(cell)  # el contenedor está en el origen
	_container.add_child(tower)
	_occupied[cell] = tower
	tower_built.emit(tower)
	queue_redraw()
	return true


func _process(_delta: float) -> void:
	if _selected < 0:
		return
	_hover_cell = _level.cell_at(get_global_mouse_position())
	queue_redraw()  # se redibuja siempre: el color también cambia si cambia el oro


func _unhandled_input(event: InputEvent) -> void:
	for i: int in _tower_types.size():
		if event.is_action_pressed("build_%d" % (i + 1)):
			select(i)
			get_viewport().set_input_as_handled()
			return
	if _selected < 0:
		return
	if event.is_action_pressed("cancel"):
		cancel()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		var button: MouseButton = (event as InputEventMouseButton).button_index
		if button == MOUSE_BUTTON_RIGHT:
			cancel()
			get_viewport().set_input_as_handled()
		elif button == MOUSE_BUTTON_LEFT:
			# RF-43: la vista previa sigue activa para construir otra igual.
			try_build(selected_tower(), _level.cell_at(get_global_mouse_position()))
			get_viewport().set_input_as_handled()


## RF-40 y RF-41: torre fantasma, casilla verde/roja y círculo de alcance.
func _draw() -> void:
	var tower: TowerData = selected_tower()
	if tower == null or not _level.is_inside(_hover_cell):
		return
	var center: Vector2 = _level.cell_center(_hover_cell)
	var tile: float = Rules.TILE_SIZE
	var cell_rect := Rect2(center - Vector2(tile, tile) / 2.0, Vector2(tile, tile))
	draw_rect(cell_rect, VALID_TINT if can_build(tower, _hover_cell) else INVALID_TINT)
	var half: float = Rules.tiles_to_px(Tower.BODY_SIZE_TILES) / 2.0
	var ghost := Color(tower.color, 0.6)
	draw_rect(Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0), ghost)
	var range_px: float = Rules.tiles_to_px(tower.levels[0].range_tiles)
	draw_circle(center, range_px, Color(1, 1, 1, 0.08))
	draw_arc(center, range_px, 0.0, TAU, 64, Color(1, 1, 1, 0.7), 2.0)
