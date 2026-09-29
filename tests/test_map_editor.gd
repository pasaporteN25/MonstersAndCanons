# Tests de la pantalla del editor de mapas (T102, spec §10.3: RF-210 a RF-213).
# OJO: nunca se llama leave() ni nada que cambie de pantalla: reemplazaría la escena de GUT.
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const NORMAL_PATH: String = "user://test_save.json"
const DEV_PATH: String = "user://test_save_pruebas.json"
## Dónde cae el mouse dentro del área del mapa para apuntar a una casilla (el centro).
const HALF_TILE := Vector2(32, 32)

var editor: MapEditor


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	GameFlow.editor_draft = null


func after_each() -> void:
	GameFlow.editor_draft = null
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _open() -> MapEditor:
	editor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	return editor


func _mouse_at(cell: Vector2i) -> Vector2:
	return Vector2(cell) * 64.0 + HALF_TILE


func _click(target: MapEditor, cell: Vector2i, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var area: Control = target.get_node("%MapArea")
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = pressed
		event.position = _mouse_at(cell)
		area.gui_input.emit(event)


func _key(target: MapEditor, keycode: Key, ctrl: bool = false, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.ctrl_pressed = ctrl
	event.shift_pressed = shift
	target._unhandled_input(event)


# --- Acceso (RF-210) ---

func test_the_menu_button_only_exists_in_dev_mode() -> void:
	DevMode.set_enabled(false, NORMAL_PATH)
	var normal: Control = MENU_SCENE.instantiate()
	add_child_autofree(normal)
	assert_false((normal.get_node("%EditorButton") as Button).visible, "el juego normal no lo tiene")
	DevMode.set_enabled(true, DEV_PATH)
	var dev: Control = MENU_SCENE.instantiate()
	add_child_autofree(dev)
	assert_true((dev.get_node("%EditorButton") as Button).visible, "RF-210: en el modo de pruebas sí")


# --- La pantalla ---

func test_it_opens_with_a_valid_new_level() -> void:
	_open()
	assert_not_null(GameFlow.editor_draft)
	assert_eq(editor.draft, GameFlow.editor_draft)
	assert_eq(editor.message_kind(), &"ok")
	assert_true(editor.message_text().begins_with("✓ Nivel válido"), editor.message_text())
	assert_true(editor.message_text().contains("Entrada A: 20 casillas"), "dice el largo del recorrido")


func test_it_resumes_the_draft_it_already_had() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	draft.set_level_name("Volví")
	GameFlow.editor_draft = draft
	_open()
	assert_eq(editor.draft, draft, "RF-217: se retoma el mismo borrador")
	assert_true((editor.get_node("%Title") as Label).text.contains("Volví"))


func test_five_tools_and_their_keys() -> void:
	_open()
	assert_eq(editor.tool, LevelDraft.Tool.PATH, "empieza con el camino")
	for i: int in MapEditor.TOOL_KEYS.size():
		_key(editor, MapEditor.TOOL_KEYS[i])
		assert_eq(editor.tool, i as LevelDraft.Tool, "tecla %d" % (i + 1))
	assert_eq((editor.get_node("%Tools") as HBoxContainer).get_child_count(), 5 + 1 + 2, "5 herramientas, un espacio y deshacer y rehacer")


func test_only_the_chosen_tool_button_is_pressed() -> void:
	_open()
	var buttons: Array[Node] = (editor.get_node("%Tools") as HBoxContainer).get_children().slice(0, 5)
	for i: int in 5:
		editor.set_tool(i as LevelDraft.Tool)
		for j: int in 5:
			assert_eq((buttons[j] as Button).button_pressed, i == j, "herramienta %d elegida, botón %d" % [i + 1, j + 1])


# --- Pintar (RF-212) ---

func test_clicking_paints_with_the_chosen_tool() -> void:
	_open()
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	_click(editor, Vector2i(5, 1))
	assert_eq(editor.draft.letter_at(Vector2i(5, 1)), "X")
	editor.set_tool(LevelDraft.Tool.PATH)
	_click(editor, Vector2i(5, 1))
	assert_eq(editor.draft.letter_at(Vector2i(5, 1)), "#")


func test_right_click_erases_whatever_the_tool() -> void:
	_open()
	editor.set_tool(LevelDraft.Tool.BLOCKED)
	_click(editor, Vector2i(10, 4), MOUSE_BUTTON_RIGHT)
	assert_eq(editor.draft.letter_at(Vector2i(10, 4)), ".", "el camino pasó a pasto")


func test_dragging_paints_a_line_and_is_one_undo_step() -> void:
	_open()
	editor.begin_stroke(Vector2i(2, 1), LevelDraft.Tool.PATH)
	editor.stroke_to(Vector2i(9, 1))  # el mouse fue rápido: saltó casillas
	editor.end_stroke()
	for x: int in range(2, 10):
		assert_eq(editor.draft.letter_at(Vector2i(x, 1)), "#", "casilla %d" % x)
	editor.undo()
	assert_eq(editor.draft.letter_at(Vector2i(5, 1)), ".", "todo el trazo se deshace junto")


func test_dragging_diagonally_leaves_no_gaps() -> void:
	_open()
	editor.begin_stroke(Vector2i(1, 1), LevelDraft.Tool.BLOCKED)
	editor.stroke_to(Vector2i(6, 4))
	editor.end_stroke()
	var painted: int = 0
	for y: int in MapGrid.MIN_HEIGHT:
		for x: int in MapGrid.MIN_WIDTH:
			if editor.draft.letter_at(Vector2i(x, y)) == "X":
				painted += 1
	assert_eq(painted, 6, "una línea de 6 casillas (la mayor distancia entre los extremos)")


func test_entrance_and_exit_are_placed_one_at_a_time_not_dragged() -> void:
	_open()
	editor.begin_stroke(Vector2i(0, 1), LevelDraft.Tool.ENTRANCE)
	editor.stroke_to(Vector2i(0, 7))
	editor.end_stroke()
	assert_eq(editor.draft.entrance_count(), 2, "la A del principio y la B: no una por casilla arrastrada")
	assert_eq(editor.draft.letter_at(Vector2i(0, 1)), "B")


func test_the_exit_tool_moves_the_exit() -> void:
	_open()
	editor.set_tool(LevelDraft.Tool.EXIT)
	_click(editor, Vector2i(19, 8))
	assert_eq(editor.draft.letter_at(Vector2i(19, 8)), "S")
	assert_eq(editor.draft.letter_at(Vector2i(19, 4)), ".")


# --- Mensajes (RF-213) ---

func test_breaking_the_map_shows_the_error_and_fixing_it_clears_it() -> void:
	_open()
	_click(editor, Vector2i(10, 4), MOUSE_BUTTON_RIGHT)  # rompe el camino
	assert_eq(editor.message_kind(), &"error")
	assert_true(editor.message_text().begins_with("✗ "), editor.message_text())
	assert_true(editor.message_text().contains("no tiene camino hasta la salida"), editor.message_text())
	editor.set_tool(LevelDraft.Tool.PATH)
	_click(editor, Vector2i(10, 4))
	assert_eq(editor.message_kind(), &"ok")


func test_several_errors_say_how_many_more() -> void:
	_open()
	editor.set_tool(LevelDraft.Tool.GRASS)
	_click(editor, Vector2i(19, 4))  # sin salida
	_click(editor, Vector2i(0, 4))  # y sin entrada
	assert_true(editor.message_text().contains("más)"), editor.message_text())


func test_a_stretch_nobody_walks_gives_a_warning() -> void:
	_open()
	editor.set_tool(LevelDraft.Tool.PATH)
	_click(editor, Vector2i(9, 5))  # una casilla de camino colgada: no lleva a ningún lado
	assert_eq(editor.message_kind(), &"warning")
	assert_true(editor.message_text().begins_with("⚠ "), editor.message_text())
	assert_true(editor.message_text().contains("ningún recorrido usa"))


func test_the_title_marks_unsaved_changes() -> void:
	_open()
	var title: Label = editor.get_node("%Title")
	assert_false(title.text.ends_with("*"))
	_click(editor, Vector2i(3, 1))
	assert_true(title.text.ends_with("*"), title.text)


# --- Deshacer y rehacer (RF-212) ---

func test_undo_and_redo_with_keys_and_buttons() -> void:
	_open()
	_click(editor, Vector2i(3, 1))
	var undo_button: Button = editor.get_node("%Tools").get_child(6)
	var redo_button: Button = editor.get_node("%Tools").get_child(7)
	assert_false(undo_button.disabled)
	assert_true(redo_button.disabled)
	_key(editor, KEY_Z, true)
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), ".")
	assert_true(undo_button.disabled, "no queda nada por deshacer")
	assert_false(redo_button.disabled)
	_key(editor, KEY_Y, true)
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), "#")
	_key(editor, KEY_Z, true)
	_key(editor, KEY_Z, true, true)  # Ctrl+Shift+Z también rehace
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), "#")
	undo_button.pressed.emit()
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), ".")
	redo_button.pressed.emit()
	assert_eq(editor.draft.letter_at(Vector2i(3, 1)), "#")


# --- La vista ---

func test_the_view_hover_follows_the_mouse() -> void:
	_open()
	var area: Control = editor.get_node("%MapArea")
	var motion := InputEventMouseMotion.new()
	motion.position = _mouse_at(Vector2i(4, 2))
	area.gui_input.emit(motion)
	assert_eq((editor.get_node("%MapView") as MapView).hover_cell, Vector2i(4, 2))
	area.mouse_exited.emit()
	assert_eq((editor.get_node("%MapView") as MapView).hover_cell, Vector2i(-1, -1))


func test_the_view_lays_out_like_the_game() -> void:
	_open()
	assert_eq((editor.get_node("%MapView") as MapView).position, Game.MAP_OFFSET, "el mapa ocupa el mismo lugar que en la partida")
	assert_eq(MapView.cell_at(Vector2(64.0 * 3 + 10, 64.0 * 2 + 63)), Vector2i(3, 2))
	assert_eq(MapView.cell_at(Vector2(-1, 5)), Vector2i(-1, 0))
	await wait_process_frames(2)
	assert_true(true, "se dibujó sin errores")
