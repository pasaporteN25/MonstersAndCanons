# Editor de mapas (spec §10.3, RF-210 a RF-213, RF-392): una pantalla para dibujar el mapa de un nivel.
# Cambia el borrador (LevelDraft), lo muestra (MapView) y explica los errores; no sabe nada de las
# reglas de los mapas: esas las revisa LevelFile (spec §7.8). Guarda mapas sueltos (Comunidad) o dentro
# de un modo propio (ModePacks).
class_name MapEditor
extends Control

const OK_COLOR := Color(0.6, 1.0, 0.65)
const WARNING_COLOR := Color(1.0, 0.85, 0.4)
const ERROR_COLOR := Color(1.0, 0.5, 0.5)
const SELECTED_COLOR := Color(1.0, 0.84, 0.3)
## RF-212: nombre y tecla de cada herramienta, en el orden de LevelDraft.Tool.
## RF-434: los últimos cinco son los pinceles de objetos (árbol y roca removibles, escombro, mina y bosque explotable).
const TOOL_NAMES: Array[String] = ["Pasto", "Camino", "Bloqueada", "Entrada", "Salida", "Árbol", "Roca", "Escombro", "Mina", "Bosque"]
const TOOL_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
const TOOL_TIPS: Array[String] = ["", "", "", "", "",
	"Árbol removible: se despeja pagando oro (Demoler)", "Roca removible: se despeja pagando oro (Demoler)",
	"Escombro: ruinas removibles; en la campaña pueden esconder una pieza",
	"Mina: punto de extracción de recursos", "Bosque explotable: punto de extracción de recursos"]

## Se sale del editor (GameFlow lleva al menú). Es una señal para poder probarlo sin cambiar de pantalla.
signal left
## RF-217: piden jugar el nivel del editor (GameFlow abre la partida). Igual: una señal, para los tests.
signal test_requested(level: LevelData)

var draft: LevelDraft
var tool: LevelDraft.Tool = LevelDraft.Tool.PATH
## RF-216: dónde se guardan y se buscan los mapas propios. Los tests usan otra carpeta.
var maps_dir: String = LevelDraft.MAPS_DIR
## RF-392: dónde están los modos propios (y dónde se crean). Los tests usan otra carpeta.
var modes_dir: String = ModePacks.USER_DIR
## Los modos oficiales: un modo nuevo no puede llamarse como uno de ellos.
var official_modes_dir: String = ModePacks.OFFICIAL_DIR

var _stroking: bool = false
var _stroke_tool: LevelDraft.Tool = LevelDraft.Tool.PATH
var _last_cell := Vector2i(-1, -1)
## Por qué no pintó el pincel durante el trazo en curso ("" = nada que avisar).
var _stroke_problem: String = ""
var _tool_buttons: Array[Button] = []
var _undo_button: Button
var _redo_button: Button
var _message_kind: StringName = &"ok"
var _settings_panel := SettingsPanel.new()
var _waves_panel := WavesPanel.new()
var _objects_panel := ObjectsPanel.new()
var _dialog := EditorDialog.new()
## Lo que se hace cuando la persona acepta el diálogo que está abierto (null = nada).
var _pending: Callable
## Aviso que se suma al mensaje de abajo hasta el próximo cambio ("Guardado en …").
var _notice: String = ""

@onready var _view: MapView = %MapView
@onready var _area: Control = %MapArea
@onready var _title: Label = %Title
@onready var _back_button: Button = %BackButton
@onready var _new_button: Button = %NewButton
@onready var _open_button: Button = %OpenButton
@onready var _save_button: Button = %SaveButton
@onready var _save_mode_button: Button = %SaveModeButton
@onready var _try_button: Button = %TryButton
@onready var _settings_button: Button = %SettingsButton
@onready var _waves_button: Button = %WavesButton
@onready var _objects_button: Button = %ObjectsButton
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
	_new_button.pressed.connect(new_level)
	_open_button.pressed.connect(open_level)
	_save_button.pressed.connect(save_level)
	_save_mode_button.pressed.connect(save_to_mode)
	_try_button.pressed.connect(try_level)
	left.connect(GameFlow.go_to_main_menu)
	test_requested.connect(GameFlow.play_test)
	_style_selected(_settings_button)
	_style_selected(_waves_button)
	_style_selected(_objects_button)
	_add_panel(_settings_panel, _settings_button)
	_add_panel(_waves_panel, _waves_button)
	_add_panel(_objects_panel, _objects_button)
	add_child(_dialog)  # último: se dibuja encima de todo
	_dialog.accepted.connect(_on_dialog_accepted)
	_dialog.cancelled.connect(func() -> void: _pending = Callable())
	Audio.add_click_sounds(self)
	set_tool(LevelDraft.Tool.PATH)
	refresh()


# --- Herramientas (RF-212) ---

func set_tool(new_tool: LevelDraft.Tool) -> void:
	tool = new_tool
	for i: int in _tool_buttons.size():
		_tool_buttons[i].set_pressed_no_signal(i == new_tool)


## Abre o cierra un panel (ajustes, oleadas u objetos). Hay uno solo abierto a la vez.
func show_panel(panel: EditorPanel, on: bool) -> void:
	for other: EditorPanel in [_settings_panel, _waves_panel, _objects_panel]:
		other.visible = on and other == panel
	_settings_button.set_pressed_no_signal(_settings_panel.visible)
	_waves_button.set_pressed_no_signal(_waves_panel.visible)
	_objects_button.set_pressed_no_signal(_objects_panel.visible)
	if on:
		panel.refresh()


func settings_panel() -> SettingsPanel:
	return _settings_panel


func waves_panel() -> WavesPanel:
	return _waves_panel


func objects_panel() -> ObjectsPanel:
	return _objects_panel


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
	_stroke_problem = ""
	if draft.apply_tool(stroke_tool, cell):
		refresh()
	elif draft.last_problem != "":
		_stroke_problem = draft.last_problem


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
		if draft.last_problem != "":
			_stroke_problem = draft.last_problem
	_last_cell = cell
	if changed:
		refresh()


func end_stroke() -> void:
	if not _stroking:
		return
	_stroking = false
	draft.end_stroke()
	refresh()
	if _stroke_problem != "":
		# RF-434: si el pincel no pudo pintar (la leyenda llegó al tope), se dice debajo del estado del nivel.
		_notice = "⚠ " + _stroke_problem
		_stroke_problem = ""
		_update_messages()


func undo() -> void:
	if draft.undo():
		refresh()


func redo() -> void:
	if draft.redo():
		refresh()


# --- Nuevo, abrir, guardar, probar y salir (RF-216, RF-217, RF-218) ---

func dialog() -> EditorDialog:
	return _dialog


## RF-215: un nivel en blanco. Con cambios sin guardar, pregunta antes (RF-218).
func new_level() -> void:
	_when_safe("Nuevo nivel", func() -> void: _use_draft(LevelDraft.new_level(), "Nivel nuevo"))


## RF-216: abre un mapa propio o un nivel oficial (como plantilla).
func open_level() -> void:
	_when_safe("Abrir otro nivel", _ask_which_to_open)


## RF-216: guarda en \`maps_dir\` (o en su modo, RF-392). Si todavía no tiene nombre de archivo, lo pide.
func save_level() -> void:
	if draft.file_id == "":
		_ask_file_name()
	else:
		_write()


## RF-392: guarda el mapa dentro de un modo propio. Se elige uno existente o se crea uno nuevo, y
## después el nombre del archivo. Desde ahí, "Guardar" sigue guardando en ese modo.
func save_to_mode() -> void:
	var items: Array[Dictionary] = [{"text": "— Mis modos —", "selectable": false}]
	for mode_id: String in ModePacks.user_ids(modes_dir):
		items.append({"text": "%s (%s)" % [ModePacks.display_name(modes_dir, mode_id), mode_id], "value": mode_id})
	items.append({"text": "+ Nuevo modo…", "value": ""})
	_pending = _on_mode_chosen
	_dialog.ask_choice("Guardar en un modo", "Elegí el modo donde se guarda este mapa.", items, "Elegir")


func _on_mode_chosen(value: Variant) -> void:
	var mode_id: String = str(value)
	if mode_id != "":
		_ask_file_name_in(mode_id)
		return
	_pending = func(name: Variant) -> void:
		var result: Dictionary = ModePacks.create(modes_dir, str(name), official_modes_dir)
		if result["error"] != "":
			_show_error("✗ No se creó el modo: " + str(result["error"]))
			return
		_ask_file_name_in(result["id"])
	_dialog.ask_text("Nuevo modo", "Nombre del modo (se ve como una solapa en la selección de nivel):",
		"", "Crear", _check_mode_name)


## Revisa el nombre del modo nuevo mientras se escribe (RF-392).
func _check_mode_name(text: String) -> Dictionary:
	var problem: String = ModePacks.name_problem(modes_dir, text, official_modes_dir)
	if problem != "":
		return {"ok": false, "note": problem, "kind": &"error"}
	var folder: String = ModePacks.dir_of(modes_dir, LevelDraft.clean_file_id(text))
	return {"ok": true, "note": "Se crea la carpeta " + ProjectSettings.globalize_path(folder), "kind": &"info"}


## RF-217: juega el nivel del editor. Un nivel con errores no se puede probar.
func try_level() -> void:
	var result: Dictionary = draft.check()
	if result["level"] == null:
		_show_error("✗ No se puede probar todavía: " + str(result["errors"][0]))
		return
	test_requested.emit(result["level"])


## RF-210, RF-218: vuelve al menú. El borrador queda en GameFlow: si se vuelve al editor, se retoma.
func leave() -> void:
	if not draft.dirty:
		left.emit()
		return
	_pending = func(_value: Variant) -> void: left.emit()
	_dialog.ask_confirm("Salir del editor",
		"Hay cambios sin guardar. Si cerrás el juego se pierden.\n(Mientras el juego siga abierto, el borrador se conserva y se retoma al volver.)",
		"Salir igual")


## Hace \`action\` ya, o después de confirmar si hay cambios sin guardar (RF-218).
func _when_safe(title: String, action: Callable) -> void:
	if not draft.dirty:
		action.call()
		return
	_pending = func(_value: Variant) -> void: action.call()
	_dialog.ask_confirm(title, "Hay cambios sin guardar. Si seguís, se pierden.", "Descartar y seguir")


func _on_dialog_accepted(value: Variant) -> void:
	# Se suelta ANTES de ejecutar: la acción puede abrir otro diálogo y dejar su propio pendiente.
	var action: Callable = _pending
	_pending = Callable()
	if action.is_valid():
		action.call(value)


## Cambia el borrador que se edita (nuevo o abierto) y vuelve a armar la pantalla.
func _use_draft(new_draft: LevelDraft, notice: String) -> void:
	draft = new_draft
	GameFlow.editor_draft = new_draft
	_settings_panel.bind(draft)
	_waves_panel.bind(draft)
	_objects_panel.bind(draft)
	_waves_panel.show_wave(0)
	refresh()
	_notice = notice
	_update_messages()


func _ask_file_name() -> void:
	_ask_file_name_in(draft.mode_id)


## Pide el nombre del archivo para guardar en `mode_id` ("" = mapa suelto). El borrador cambia de destino
## recién al aceptar: si se cancela, sigue donde estaba.
func _ask_file_name_in(mode_id: String) -> void:
	var suggestion: String = draft.file_id if draft.file_id != "" else draft.suggested_id
	if suggestion == "":
		suggestion = LevelDraft.clean_file_id(draft.level_name())
	_pending = func(value: Variant) -> void:
		draft.mode_id = mode_id
		draft.file_id = str(value)
		_write()
	var title: String = "Guardar el mapa" if mode_id == "" else "Guardar el mapa en el modo '%s'" % mode_id
	_dialog.ask_text(title, "Nombre del archivo (minúsculas, números y _):",
		suggestion, "Guardar", _check_file_name.bind(mode_id))


## Revisa el nombre mientras se escribe (RF-216, RF-392).
func _check_file_name(text: String, mode_id: String = "") -> Dictionary:
	if text == "":
		return {"ok": false, "note": "Escribí un nombre.", "kind": &"error"}
	if not LevelDraft.is_valid_file_id(text):
		return {"ok": false, "note": "Solo minúsculas, números y _ (hasta %d letras)." % LevelDraft.FILE_ID_MAX, "kind": &"error"}
	if LevelDraft.is_official_id(text):
		return {"ok": false, "note": "'%s' es el nombre de un nivel oficial: elegí otro para no pisarlo." % text, "kind": &"error"}
	if mode_id != "" and text == ModePacks.RESERVED_MAP_ID:
		return {"ok": false, "note": "'%s' está reservado para el archivo del modo: elegí otro." % text, "kind": &"error"}
	if LevelDraft.saved_ids(_dir_for(mode_id)).has(text):
		return {"ok": true, "note": "Ya hay un mapa con ese nombre: se va a reemplazar.", "kind": &"warning"}
	return {"ok": true, "note": "Se guarda en " + _file_path(text, mode_id), "kind": &"info"}


func _write() -> void:
	var dir: String = _dir_for(draft.mode_id)
	var problem: String = draft.save(dir)
	if problem == "" and draft.mode_id != "":
		problem = ModePacks.add_map(dir, draft.file_id)  # RF-392: el mapa entra en la lista del modo
	if problem != "":
		draft.file_id = ""  # no quedó guardado: la próxima vez vuelve a pedir el nombre
		_show_error("✗ No se guardó: " + problem)
		return
	refresh()
	_notice = "Guardado en " + _file_path(draft.file_id, draft.mode_id)
	_update_messages()


## La carpeta donde se guarda: la de mapas sueltos o la de un modo propio (RF-392).
func _dir_for(mode_id: String) -> String:
	return maps_dir if mode_id == "" else ModePacks.dir_of(modes_dir, mode_id)


func _ask_which_to_open() -> void:
	var items: Array[Dictionary] = [{"text": "— Mis mapas —", "selectable": false}]
	var saved: PackedStringArray = LevelDraft.saved_ids(maps_dir)
	if saved.is_empty():
		items.append({"text": "(todavía no guardaste ninguno)", "selectable": false})
	for id: String in saved:
		items.append({"text": id, "value": {"kind": "saved", "id": id}})
	# RF-392: los mapas guardados dentro de cada modo propio.
	for mode_id: String in ModePacks.user_ids(modes_dir):
		var mode_maps: PackedStringArray = LevelDraft.saved_ids(ModePacks.dir_of(modes_dir, mode_id))
		mode_maps.erase(ModePacks.RESERVED_MAP_ID)  # el modo.json no es un mapa
		if mode_maps.is_empty():
			continue
		items.append({"text": "— Modo %s —" % ModePacks.display_name(modes_dir, mode_id), "selectable": false})
		for id: String in mode_maps:
			items.append({"text": id, "value": {"kind": "mode", "mode": mode_id, "id": id}})
	items.append({"text": "— Niveles oficiales (se abren como plantilla) —", "selectable": false})
	for id: String in LevelFile.campaign_ids():
		var official: LevelData = LevelFile.load_level(LevelFile.LEVELS_DIR + id + ".json")["level"]
		items.append({"text": "%s · %s" % [id, official.display_name if official != null else "?"],
			"value": {"kind": "official", "id": id}})
	_pending = _open_choice
	_dialog.ask_choice("Abrir un nivel", "", items, "Abrir")


func _open_choice(value: Variant) -> void:
	var choice: Dictionary = value
	var opened: LevelDraft
	if choice["kind"] == "saved":
		opened = LevelDraft.open_saved(choice["id"], maps_dir)
	elif choice["kind"] == "mode":
		opened = LevelDraft.open_saved(choice["id"], ModePacks.dir_of(modes_dir, choice["mode"]))
		if opened != null:
			opened.mode_id = choice["mode"]  # RF-392: "Guardar" sigue guardando en su modo
	else:
		opened = LevelDraft.open_official(choice["id"])
	if opened == null:
		_show_error("✗ No se pudo abrir " + str(choice["id"]))
		return
	var notice: String = "Abierto: %s" % choice["id"]
	if choice["kind"] == "official":
		notice = "Abierto como plantilla: %s (al guardarlo pide otro nombre)" % choice["id"]
	_use_draft(opened, notice)


func _file_path(id: String, mode_id: String = "") -> String:
	return ProjectSettings.globalize_path(_dir_for(mode_id) + id + ".json")


func _show_error(text: String) -> void:
	_message_kind = &"error"
	_messages.text = text
	_messages.add_theme_color_override("font_color", ERROR_COLOR)


# --- Lo que se ve ---

## Vuelve a dibujar el mapa y los mensajes después de un cambio.
func refresh() -> void:
	_notice = ""
	_view.show_map(draft.rows(), draft.grid(), draft.theme())
	_update_messages()
	_title.text = "Editor de mapas · %s%s" % [draft.level_name(), " *" if draft.dirty else ""]
	_undo_button.disabled = not draft.can_undo()
	_redo_button.disabled = not draft.can_redo()
	for panel: EditorPanel in [_settings_panel, _waves_panel, _objects_panel]:
		if panel.visible:
			panel.refresh()  # después de deshacer o de pintar, lo que muestran puede haber cambiado


## Un panel cambió el borrador: se revisa el nivel, pero el panel no se vuelve a armar
## (si no, se perdería el foco del campo que se está escribiendo).
func _on_panel_edited() -> void:
	_notice = ""
	_view.show_map(draft.rows(), draft.grid(), draft.theme())
	_update_messages()
	_title.text = "Editor de mapas · %s%s" % [draft.level_name(), " *" if draft.dirty else ""]
	_undo_button.disabled = not draft.can_undo()
	_redo_button.disabled = not draft.can_redo()


func _add_panel(panel: EditorPanel, button: Button) -> void:
	# Pegado arriba a la derecha, debajo de la barra: el mapa de la izquierda sigue a la vista.
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = 0.0
	panel.offset_right = -8.0
	panel.offset_top = 56.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.visible = false
	add_child(panel)
	panel.bind(draft)
	panel.edited.connect(_on_panel_edited)
	button.toggled.connect(func(on: bool) -> void: show_panel(panel, on))


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
	if _notice != "":
		_messages.text += "\n" + _notice


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
		button.text = "%s (%d)" % [TOOL_NAMES[i], (i + 1) % 10]
		button.toggle_mode = true
		button.button_group = group
		button.focus_mode = Control.FOCUS_NONE  # las teclas 1 a 5 no se las come el botón
		button.tooltip_text = TOOL_TIPS[i]
		_style_selected(button)
		button.pressed.connect(set_tool.bind(i))
		_tools_row.add_child(button)
		_tool_buttons.append(button)
	var hint := Label.new()
	hint.text = "Clic der.: borra · Ctrl+Z/Y · Ctrl+S"
	hint.clip_text = true
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", EditorPanel.HEADER_COLOR)
	_tools_row.add_child(hint)
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
		var cell: Vector2i = _view.cell_at_area((event as InputEventMouseMotion).position)
		_view.hover_cell = cell
		stroke_to(cell)
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.button_index != MOUSE_BUTTON_LEFT and click.button_index != MOUSE_BUTTON_RIGHT:
			return
		if click.pressed:
			get_viewport().gui_release_focus()  # si se estaba escribiendo un nombre, se guarda
			# El botón derecho borra, sea cual sea la herramienta.
			var stroke_tool: LevelDraft.Tool = tool if click.button_index == MOUSE_BUTTON_LEFT else LevelDraft.Tool.GRASS
			begin_stroke(_view.cell_at_area(click.position), stroke_tool)
		else:
			end_stroke()


func _unhandled_input(event: InputEvent) -> void:
	if _dialog.is_open():
		return  # con un diálogo abierto, el teclado es del diálogo
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
	elif key.ctrl_pressed and key.keycode == KEY_S:
		get_viewport().set_input_as_handled()
		save_level()
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
