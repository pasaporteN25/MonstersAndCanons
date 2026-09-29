# Editor de mapas (spec §10.3, RF-210 a RF-213): una pantalla para dibujar el mapa de un nivel,
# solo en el modo de pruebas. Cambia el borrador (LevelDraft), lo muestra (MapView) y explica
# los errores; no sabe nada de las reglas de los mapas: esas las revisa LevelFile (spec §7.8).
class_name MapEditor
extends Control

const OK_COLOR := Color(0.6, 1.0, 0.65)
const WARNING_COLOR := Color(1.0, 0.85, 0.4)
const ERROR_COLOR := Color(1.0, 0.5, 0.5)
const SELECTED_COLOR := Color(1.0, 0.84, 0.3)
## RF-212: nombre y tecla de cada herramienta, en el orden de LevelDraft.Tool.
const TOOL_NAMES: Array[String] = ["Pasto", "Camino", "Bloqueada", "Entrada", "Salida"]
const TOOL_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]

var draft: LevelDraft
var tool: LevelDraft.Tool = LevelDraft.Tool.PATH

var _stroking: bool = false
var _stroke_tool: LevelDraft.Tool = LevelDraft.Tool.PATH
var _last_cell := Vector2i(-1, -1)
var _tool_buttons: Array[Button] = []
var _undo_button: Button
var _redo_button: Button
var _message_kind: StringName = &"ok"

@onready var _view: MapView = %MapView
@onready var _area: Control = %MapArea
@onready var _title: Label = %Title
@onready var _back_button: Button = %BackButton
@onready var _tools_row: HBoxContainer = %Tools
@onready var _messages: Label = %Messages


func _ready() -> void:
	# Si se vuelve de probar el nivel, se retoma el mismo borrador (RF-217).
	if GameFlow.editor_draft == null:
		GameFlow.editor_draft = LevelDraft.new_level()
	draft = GameFlow.editor_draft
	_build_tools()
	_area.gui_input.connect(_on_map_input)
	_area.mouse_exited.connect(func() -> void: _view.hover_cell = Vector2i(-1, -1))
	_back_button.pressed.connect(leave)
	Audio.add_click_sounds(self)
	set_tool(LevelDraft.Tool.PATH)
	refresh()


# --- Herramientas (RF-212) ---

func set_tool(new_tool: LevelDraft.Tool) -> void:
	tool = new_tool
	for i: int in _tool_buttons.size():
		_tool_buttons[i].set_pressed_no_signal(i == new_tool)


## Pinta una casilla con la herramienta elegida, como un solo paso de deshacer.
func paint_at(cell: Vector2i) -> void:
	begin_stroke(cell, tool)
	end_stroke()


## Empieza un trazo (mouse apretado): pinta la casilla y deja seguir arrastrando.
func begin_stroke(cell: Vector2i, stroke_tool: LevelDraft.Tool) -> void:
	_stroking = true
	_stroke_tool = stroke_tool
	draft.begin_stroke()
	_last_cell = cell
	if draft.apply_tool(stroke_tool, cell):
		refresh()


## Sigue el trazo hasta `cell`, pintando también las casillas del medio (si el mouse va rápido
## se saltea casillas). La entrada y la salida se ponen de a una: no se arrastran.
func stroke_to(cell: Vector2i) -> void:
	if not _stroking or cell == _last_cell:
		return
	if _stroke_tool == LevelDraft.Tool.ENTRANCE or _stroke_tool == LevelDraft.Tool.EXIT:
		_last_cell = cell
		return
	var changed: bool = false
	for step: Vector2i in _cells_between(_last_cell, cell):
		changed = draft.apply_tool(_stroke_tool, step) or changed
	_last_cell = cell
	if changed:
		refresh()


func end_stroke() -> void:
	if not _stroking:
		return
	_stroking = false
	draft.end_stroke()
	refresh()


func undo() -> void:
	if draft.undo():
		refresh()


func redo() -> void:
	if draft.redo():
		refresh()


## RF-210: vuelve al menú. El borrador queda guardado en GameFlow: al volver se retoma.
func leave() -> void:
	GameFlow.go_to_main_menu()


# --- Lo que se ve ---

## Vuelve a dibujar el mapa y los mensajes después de un cambio.
func refresh() -> void:
	_view.show_map(draft.rows(), draft.grid())
	_update_messages()
	_title.text = "Editor de mapas · %s%s" % [draft.level_name(), " *" if draft.dirty else ""]
	_undo_button.disabled = not draft.can_undo()
	_redo_button.disabled = not draft.can_redo()


## RF-213: el mensaje de abajo. `message_kind()`: &"error", &"warning" o &"ok".
func message_text() -> String:
	return _messages.text


func message_kind() -> StringName:
	return _message_kind


func _update_messages() -> void:
	var result: Dictionary = draft.check()
	var errors: PackedStringArray = result["errors"]
	var warnings: PackedStringArray = result["warnings"]
	if not errors.is_empty():
		_message_kind = &"error"
		_messages.text = "✗ " + errors[0] + ("" if errors.size() == 1 else "   (y %d más)" % (errors.size() - 1))
		_messages.add_theme_color_override("font_color", ERROR_COLOR)
	elif not warnings.is_empty():
		_message_kind = &"warning"
		_messages.text = "⚠ " + warnings[0]
		_messages.add_theme_color_override("font_color", WARNING_COLOR)
	else:
		_message_kind = &"ok"
		_messages.text = "✓ Nivel válido · " + _routes_summary()
		_messages.add_theme_color_override("font_color", OK_COLOR)


## "Entrada A: 30 casillas · Entrada B: 29 casillas"
func _routes_summary() -> String:
	var grid: MapGrid = draft.grid()
	var parts: PackedStringArray = []
	for i: int in grid.routes.size():
		parts.append("Entrada %s: %d casillas" % [MapGrid.ENTRANCE_LETTERS[i], grid.routes[i].size()])
	return " · ".join(parts)


func _build_tools() -> void:
	var group := ButtonGroup.new()
	for i: int in TOOL_NAMES.size():
		var button := Button.new()
		button.text = "%s (%d)" % [TOOL_NAMES[i], i + 1]
		button.toggle_mode = true
		button.button_group = group
		button.focus_mode = Control.FOCUS_NONE  # las teclas 1 a 5 no se las come el botón
		button.custom_minimum_size = Vector2(112, 0)
		_style_selected(button)
		button.pressed.connect(set_tool.bind(i))
		_tools_row.add_child(button)
		_tool_buttons.append(button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tools_row.add_child(spacer)
	_undo_button = _action_button("Deshacer", undo)
	_redo_button = _action_button("Rehacer", redo)


## La herramienta elegida se ve con marco y letras doradas (sobre la barra oscura, el gris no alcanza).
func _style_selected(button: Button) -> void:
	var selected := StyleBoxFlat.new()
	selected.bg_color = Color(0.22, 0.19, 0.08)
	selected.set_border_width_all(2)
	selected.border_color = SELECTED_COLOR
	selected.set_corner_radius_all(4)
	for style_name: String in ["pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(style_name, selected)
	for color_name: String in ["font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(color_name, SELECTED_COLOR)


func _action_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(100, 0)
	button.pressed.connect(action)
	_tools_row.add_child(button)
	return button


# --- Mouse y teclado ---

func _on_map_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell: Vector2i = MapView.cell_at((event as InputEventMouseMotion).position)
		_view.hover_cell = cell
		stroke_to(cell)
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.button_index != MOUSE_BUTTON_LEFT and click.button_index != MOUSE_BUTTON_RIGHT:
			return
		if click.pressed:
			# El botón derecho borra, sea cual sea la herramienta.
			var stroke_tool: LevelDraft.Tool = tool if click.button_index == MOUSE_BUTTON_LEFT else LevelDraft.Tool.GRASS
			begin_stroke(MapView.cell_at(click.position), stroke_tool)
		else:
			end_stroke()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		leave()
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.ctrl_pressed and key.keycode == KEY_Z:
		get_viewport().set_input_as_handled()
		redo() if key.shift_pressed else undo()
	elif key.ctrl_pressed and key.keycode == KEY_Y:
		get_viewport().set_input_as_handled()
		redo()
	elif not key.ctrl_pressed and TOOL_KEYS.has(key.keycode):
		get_viewport().set_input_as_handled()
		set_tool(TOOL_KEYS.find(key.keycode) as LevelDraft.Tool)


## Las casillas de la línea de `from` a `to`, sin `from` (para no repetirla) y con `to`.
static func _cells_between(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var steps: int = maxi(absi(to.x - from.x), absi(to.y - from.y))
	for i: int in range(1, steps + 1):
		var t: float = float(i) / steps
		cells.append(Vector2i(roundi(lerpf(from.x, to.x, t)), roundi(lerpf(from.y, to.y, t))))
	return cells
