# El tutorial del nivel 1 dentro de la partida (M63, RF-570 a RF-575). Es el "director" del tutorial: mira la
# partida (señales de `Game`, `BuildController`, `LevelSession` y de los HUD), le avisa a `TutorialFlow` qué pasó,
# y le dice a `TutorialOverlay` qué paso mostrar y qué señalar. No cambia la partida: no la pausa, no cobra, no
# construye (salvo elegir la torre construida para mostrar «Mejorar» y «Vender», RF-572). Los textos y el orden
# de los pasos vienen de `data/tutorial/tutorial.json` (`TutorialData`); acá solo vive qué control señala cada paso.
class_name TutorialController
extends Node

## Terminó el tutorial: `completed` es `false` si se saltó.
signal finished(completed: bool)

## Si el jugador suelta lo que había elegido, el paso vuelve a uno anterior (si el archivo lo trae): [paso] → [vuelve a].
const REWIND_ON_DESELECT: Dictionary = {
	"place_tower": "pick_tower",
	"pick_card": "open_cart",
	"confirm_tower": "open_cart",
}
## Lo que se deja libre sobre la barra de abajo: ahí aparece el texto de la torre que se va a construir.
const BOTTOM_KEEP_CLEAR_PX: float = 32.0
## Radio (en casillas) con el que se cuenta cuánto camino cubre una casilla al sugerir dónde construir.
const SUGGEST_RADIUS: int = 2

var flow: TutorialFlow
var overlay: TutorialOverlay

var _game: Game
var _data: TutorialData
var _mobile: bool = false
var _last_tower: Tower
var _towers_built: int = 0
var _suggested_cell: Vector2i = Vector2i(-1, -1)
var _path_cells: Array[Vector2i] = []
var _begun: bool = false
var _stopped: bool = false


## Arma el tutorial para esta partida. No muestra nada hasta `begin()`.
func setup(game: Game, data: TutorialData) -> void:
	_game = game
	_data = data
	_mobile = UiMode.is_mobile()
	flow = TutorialFlow.new(data.steps_for(_mobile))
	flow.step_changed.connect(_enter_step)
	flow.finished.connect(_on_flow_finished)
	overlay = TutorialOverlay.new()
	overlay.name = "TutorialOverlay"
	overlay.targets_provider = _targets
	overlay.fills_provider = _fills
	add_child(overlay)
	overlay.area = _map_area()
	overlay.next_pressed.connect(flow.next)
	overlay.skip_pressed.connect(flow.skip)
	var build: BuildController = game.build_controller
	build.selection_changed.connect(_on_selection_changed)
	build.tower_built.connect(_on_tower_built)
	build.placed_selection_changed.connect(_on_placed_selection_changed)
	game.session.wave_changed.connect(_on_wave_changed)
	game.session.state_changed.connect(_on_state_changed)
	game.pause_changed.connect(_on_pause_changed)
	game.speed_changed.connect(_on_speed_changed)
	if game.mobile_hud != null:
		game.mobile_hud.catalog_opened.connect(_on_catalog_opened)
	_collect_path_cells()


## Empieza por el primer paso (después del cartel de entrada, si lo hay).
func begin() -> void:
	if _begun or _stopped or flow == null or flow.is_finished():
		return
	_begun = true
	_enter_step()


func is_active() -> bool:
	return _begun and not _stopped and not flow.is_finished()


## Lo que se está señalando ahora (en pantalla), para los tests.
func current_targets() -> Array[Rect2]:
	return _targets()


## La casilla que el tutorial sugiere para construir (la que cubre más camino).
func suggested_cell() -> Vector2i:
	return _pick_build_cell()


# --- Pasos ---

func _enter_step() -> void:
	if _stopped:
		return
	flow.skip_satisfied(_is_satisfied)
	if flow.is_finished():
		return  # el aviso de `finished` ya ocultó la tarjeta
	var id: String = flow.current_id()
	if id == "upgrade" or id == "sell":
		_ensure_tower_selected()
	overlay.card_over_bottom_bar = id == "pick_card"  # el catálogo ya oscurece la barra de abajo
	var step: Dictionary = flow.current()
	var header: String = "%s · %s" % [_data.ui_text("titulo"), _data.ui_text("paso") % [flow.number(), flow.count()]]
	overlay.show_step(header, step["texto"], flow.is_reading(), flow.is_last(), _data.ui_text("siguiente"), _data.ui_text("terminar"), _data.ui_text("saltar"))


## ¿El paso de acción ya se cumplió antes de llegar a él? (el jugador se adelantó)
func _is_satisfied(id: String) -> bool:
	var build: BuildController = _game.build_controller
	match id:
		"pick_tower", "pick_card":
			return build.selected_tower() != null or _towers_built > 0
		"place_tower", "confirm_tower":
			return _towers_built > 0
		"open_cart":
			return _game.mobile_hud.is_catalog_open() or build.selected_tower() != null or _towers_built > 0
		"start_wave":
			return _game.session.wave >= 1
		"select_tower":
			return build.selected_placed() != null
	return false


## «Mejorar» y «Vender» solo se ven con una torre construida elegida: si el jugador la soltó, se vuelve a elegir.
func _ensure_tower_selected() -> void:
	if not is_active():
		return
	var build: BuildController = _game.build_controller
	if build.selected_placed() != null or not is_instance_valid(_last_tower) or _last_tower.is_queued_for_deletion():
		return
	build.cancel()
	build.select_placed(_last_tower)


# --- Lo que pasa en la partida ---

func _on_selection_changed(index: int) -> void:
	if not is_active():
		return
	if index >= 0:
		flow.notify(TutorialData.EVENT_TOWER_SELECTED)
		return
	var back: String = String(REWIND_ON_DESELECT.get(flow.current_id(), ""))
	if back != "" and flow.rewind_to(back):
		_enter_step()


func _on_tower_built(tower: Tower) -> void:
	_towers_built += 1
	_last_tower = tower
	if is_active():
		flow.notify(TutorialData.EVENT_TOWER_BUILT)


func _on_placed_selection_changed(tower: Tower) -> void:
	if not is_active():
		return
	if tower != null:
		flow.notify(TutorialData.EVENT_PLACED_SELECTED)
	elif flow.current_id() == "upgrade" or flow.current_id() == "sell":
		_ensure_tower_selected.call_deferred()  # un toque suelto no esconde los botones que se están explicando


func _on_wave_changed(wave: int, _total: int) -> void:
	if is_active() and wave >= 1:
		flow.notify(TutorialData.EVENT_WAVE_STARTED)


func _on_pause_changed(paused: bool) -> void:
	if is_active():
		flow.notify(TutorialData.EVENT_PAUSED if paused else TutorialData.EVENT_RESUMED)


func _on_speed_changed(_speed: float) -> void:
	if is_active():
		flow.notify(TutorialData.EVENT_SPEED_CHANGED)


func _on_catalog_opened(open: bool) -> void:
	if not is_active():
		return
	if open:
		flow.notify(TutorialData.EVENT_CATALOG_OPENED)
	elif flow.current_id() == "pick_card" and _game.build_controller.selected_tower() == null and flow.rewind_to("open_cart"):
		_enter_step()  # cerró el catálogo sin elegir: vuelve a mostrar el carrito


## La partida terminó (ganada o perdida): el tutorial se esconde, sin marcarse como completado.
func _on_state_changed(state: LevelSession.State) -> void:
	if state == LevelSession.State.WON or state == LevelSession.State.LOST:
		_stopped = true
		overlay.hide_step()


func _on_flow_finished(completed: bool) -> void:
	_stopped = true
	overlay.hide_step()
	SaveManager.mark_tutorial_done()  # RF-575: ni completado ni saltado se repite
	finished.emit(completed)


# --- Qué se señala ---

func _map_area() -> Rect2:
	var top: float = float(MobileUiConfig.load_from().get_value("barra_alta_px")) if _mobile else Game.MAP_OFFSET.y
	var bottom: float = Rules.SCREEN_SIZE.y - float(_game.hud.get_node("BottomBar").size.y) - BOTTOM_KEEP_CLEAR_PX
	return Rect2(0.0, top, Rules.SCREEN_SIZE.x, bottom - top)


## Los recuadros del paso actual, en coordenadas de pantalla. Se pide en cada cuadro.
func _targets() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if _stopped or flow == null or flow.is_finished():
		return rects
	match flow.current_id():
		"path":
			rects.append(_cell_rect(_game.level.grid.exit_cell))
			for entrance: Vector2i in _game.level.grid.entrances:
				rects.push_front(_cell_rect(entrance))
		"gold":
			_add_control(rects, _game.hud.target_control(&"gold"))
		"lives":
			_add_control(rects, _game.hud.target_control(&"lives"))
		"pick_tower":
			_add_control(rects, _game.hud.target_control(&"tower_1"))
		"place_tower":
			_add_cell(rects, _pick_build_cell())
		"open_cart":
			_add_control(rects, _game.mobile_hud.target_control(&"cart"))
		"pick_card":
			_add_control(rects, _game.mobile_hud.target_control(&"first_card"))
		"confirm_tower":
			_add_cell(rects, _pick_build_cell())
			_add_control(rects, _game.mobile_hud.target_control(&"confirm"))
		"start_wave":
			_add_control(rects, _game.hud.target_control(&"start_wave"))
		"select_tower":
			if is_instance_valid(_last_tower) and not _last_tower.is_queued_for_deletion():
				rects.append(_cell_rect(_last_tower.origin_cell, _last_tower.data.footprint))
		"upgrade":
			_add_control(rects, _mobile_or_pc_control(&"upgrade"))
		"sell":
			_add_control(rects, _mobile_or_pc_control(&"sell"))
		"speed":
			_add_control(rects, _game.hud.target_control(&"speed"))
		"pause", "resume":
			_add_control(rects, _game.hud.target_control(&"pause"))
	return rects


## Las casillas que se pintan suaves (no son recuadros): el camino, en el paso que lo explica.
func _fills() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if not _stopped and flow != null and flow.current_id() == "path":
		for cell: Vector2i in _path_cells:
			rects.append(_cell_rect(cell))
	return rects


func _mobile_or_pc_control(target: StringName) -> Control:
	return _game.mobile_hud.target_control(target) if _mobile else _game.hud.target_control(target)


func _add_cell(rects: Array[Rect2], cell: Vector2i) -> void:
	if _game.level.is_inside(cell):
		rects.append(_cell_rect(cell))


func _add_control(rects: Array[Rect2], control: Control) -> void:
	if control != null:
		rects.append(control.get_global_rect())


## El rectángulo en pantalla de una casilla (o de un cuadrado de `size` casillas desde `cell`).
func _cell_rect(cell: Vector2i, size: int = 1) -> Rect2:
	var transform: Transform2D = _game.get_viewport().get_canvas_transform()
	var top_left: Vector2 = _game.level.cell_center(cell) - Vector2.ONE * Rules.TILE_SIZE / 2.0
	return Rect2(transform * top_left, Vector2.ONE * Rules.TILE_SIZE * float(size) * transform.get_scale().x)


func _collect_path_cells() -> void:
	_path_cells = []
	var grid: MapGrid = _game.level.grid
	for y: int in grid.height:
		for x: int in grid.width:
			if grid.cell_type(Vector2i(x, y)) == MapGrid.Cell.PATH:
				_path_cells.append(Vector2i(x, y))


## RF-572: la casilla libre que más camino tiene a su alrededor (así la torre dispara bastante), y de esas la más
## cercana al centro del mapa. Siempre es una casilla en la que se puede construir la primera torre de la barra.
func _pick_build_cell() -> Vector2i:
	var build: BuildController = _game.build_controller
	if _suggested_cell != Vector2i(-1, -1) and not _game.available_towers.is_empty() \
			and build.cells_free(_game.available_towers[0], _suggested_cell):
		return _suggested_cell
	if _game.available_towers.is_empty():
		return Vector2i(-1, -1)
	var tower: TowerData = _game.available_towers[0]
	var grid: MapGrid = _game.level.grid
	var center := Vector2(float(grid.width), float(grid.height)) / 2.0
	var best: Vector2i = Vector2i(-1, -1)
	var best_cover: int = -1
	var best_distance: float = INF
	for y: int in grid.height:
		for x: int in grid.width:
			var cell := Vector2i(x, y)
			if not build.cells_free(tower, cell):
				continue
			var cover: int = _path_around(grid, cell)
			var distance: float = Vector2(cell).distance_to(center)
			if cover > best_cover or (cover == best_cover and distance < best_distance):
				best = cell
				best_cover = cover
				best_distance = distance
	_suggested_cell = best
	return best


func _path_around(grid: MapGrid, cell: Vector2i) -> int:
	var count: int = 0
	for dy: int in range(-SUGGEST_RADIUS, SUGGEST_RADIUS + 1):
		for dx: int in range(-SUGGEST_RADIUS, SUGGEST_RADIUS + 1):
			var other := cell + Vector2i(dx, dy)
			if grid.is_inside(other) and grid.cell_type(other) == MapGrid.Cell.PATH:
				count += 1
	return count
