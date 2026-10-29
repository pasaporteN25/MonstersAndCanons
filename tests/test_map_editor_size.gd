# Tests del editor con mapas de otro tamaño (T118, RF-254, D-037).
# OJO: nunca se llama leave() ni nada que cambie de pantalla: reemplazaría la escena de GUT.
extends GutTest

const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
var NORMAL_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)
const DEV_PATH: String = "user://test_save_pruebas.json"
const TEST_DIR: String = "user://test_maps_size/"


func before_each() -> void:
	DevMode.set_enabled(true, DEV_PATH)
	GameFlow.editor_draft = null


func after_each() -> void:
	GameFlow.editor_draft = null
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if DirAccess.dir_exists_absolute(TEST_DIR):
		for file: String in DirAccess.get_files_at(TEST_DIR):
			DirAccess.remove_absolute(TEST_DIR + file)
		DirAccess.remove_absolute(TEST_DIR)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _rows(w: int, h: int) -> Array:
	var rows: Array = []
	for y: int in h:
		rows.append(".".repeat(w))
	rows[h / 2] = "A" + "#".repeat(w - 2) + "S"
	return rows


func _text(w: int, h: int) -> String:
	return JSON.stringify({
		"version": 1, "nombre": "Grande", "oro": 300, "vidas": 15, "mapa": _rows(w, h),
		"oleadas": [[{"enemigo": "normal", "cantidad": 4, "cada": 1.0}]],
	})


func _open(w: int, h: int) -> MapEditor:
	GameFlow.editor_draft = LevelDraft.from_text(_text(w, h), "grande")
	var editor: MapEditor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	return editor


## Dónde cae el mouse, dentro del área del mapa, para apuntar al centro de una casilla.
func _mouse_at(editor: MapEditor, cell: Vector2i) -> Vector2:
	var view: MapView = editor.get_node("%MapView")
	return view.position - Rules.MAP_AREA.position + (Vector2(cell) + Vector2(0.5, 0.5)) * Rules.TILE_SIZE * view.scale.x


func _click(editor: MapEditor, cell: Vector2i) -> void:
	var area: Control = editor.get_node("%MapArea")
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = _mouse_at(editor, cell)
		area.gui_input.emit(event)


# --- El borrador conserva el tamaño ---

func test_a_draft_keeps_the_size_of_the_map_it_opens() -> void:
	var draft: LevelDraft = LevelDraft.from_text(_text(26, 12), "grande")
	assert_eq(draft.map_width(), 26)
	assert_eq(draft.map_height(), 12)
	assert_eq(draft.rows().size(), 12)
	assert_eq(draft.rows()[0].length(), 26)
	assert_true(draft.in_bounds(Vector2i(25, 11)))
	assert_false(draft.in_bounds(Vector2i(26, 11)))
	assert_false(draft.in_bounds(Vector2i(25, 12)))
	assert_true(draft.grid().is_valid())


func test_a_new_level_is_still_twenty_by_nine() -> void:
	var draft: LevelDraft = LevelDraft.new_level()
	assert_eq(Vector2i(draft.map_width(), draft.map_height()), Vector2i(20, 9))


func test_an_impossible_size_is_corrected_to_the_nearest_allowed() -> void:
	var too_big: LevelDraft = LevelDraft.from_text(_text(40, 20), "x")
	assert_eq(Vector2i(too_big.map_width(), too_big.map_height()), Vector2i(26, 12))
	var too_small: LevelDraft = LevelDraft.from_text('{"version": 1, "mapa": ["A#S", "..."]}', "y")
	assert_eq(Vector2i(too_small.map_width(), too_small.map_height()), Vector2i(20, 9))


func test_editing_and_saving_a_big_map_does_not_crop_it() -> void:
	var draft: LevelDraft = LevelDraft.from_text(_text(26, 12), "grande")
	draft.begin_stroke()
	draft.apply_tool(LevelDraft.Tool.BLOCKED, Vector2i(25, 11))
	draft.end_stroke()
	assert_eq(draft.letter_at(Vector2i(25, 11)), "X", "se puede pintar la última casilla")
	assert_eq(draft.save(TEST_DIR), "", "se guardó sin errores")
	var reopened: LevelDraft = LevelDraft.open_saved("grande", TEST_DIR)
	assert_eq(Vector2i(reopened.map_width(), reopened.map_height()), Vector2i(26, 12))
	assert_eq(reopened.letter_at(Vector2i(25, 11)), "X")
	assert_true(reopened.grid().is_valid())


func test_removing_the_exit_and_entrance_works_in_a_big_map() -> void:
	var draft: LevelDraft = LevelDraft.from_text(_text(26, 12), "grande")
	draft.begin_stroke()
	draft.apply_tool(LevelDraft.Tool.EXIT, Vector2i(25, 3))  # la salida se mueve: la vieja pasa a pasto
	draft.end_stroke()
	assert_eq(draft.letter_at(Vector2i(25, 6)), ".", "la salida vieja, que estaba en la última columna de 26, ya no está")
	assert_eq(draft.letter_at(Vector2i(25, 3)), "S")


# --- La vista ---

func test_a_usual_map_is_laid_out_exactly_as_before() -> void:
	var editor: MapEditor = _open(20, 9)
	var view: MapView = editor.get_node("%MapView")
	assert_eq(view.position, Game.MAP_OFFSET)
	assert_eq(view.scale, Vector2.ONE)


func test_a_big_map_is_shown_whole_and_centered() -> void:
	var editor: MapEditor = _open(26, 12)
	var view: MapView = editor.get_node("%MapView")
	assert_almost_eq(view.scale.x, 0.75, 0.0001)
	var top_left: Vector2 = view.position
	var bottom_right: Vector2 = view.position + Vector2(26, 12) * Rules.TILE_SIZE * view.scale.x
	assert_true(Rules.MAP_AREA.grow(0.01).has_point(top_left))
	assert_true(Rules.MAP_AREA.grow(0.01).has_point(bottom_right))
	assert_almost_eq((top_left + bottom_right) / 2.0, Rules.MAP_AREA.get_center(), Vector2(0.01, 0.01))


func test_the_view_refits_when_a_map_of_another_size_is_opened() -> void:
	var editor: MapEditor = _open(26, 12)
	var view: MapView = editor.get_node("%MapView")
	view.show_map(PackedStringArray(_rows(20, 9)), MapGrid.parse(PackedStringArray(_rows(20, 9))))
	assert_eq(view.scale, Vector2.ONE)
	assert_eq(view.position, Game.MAP_OFFSET)


# --- El mouse con zoom ---

func test_clicks_land_on_the_right_cell_with_zoom() -> void:
	var editor: MapEditor = _open(26, 12)
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(25, 11), Vector2i(13, 3), Vector2i(20, 9)]:
		assert_eq(editor.get_node("%MapView").cell_at_area(_mouse_at(editor, cell)), cell, "el centro de %s" % cell)
	editor.tool = LevelDraft.Tool.BLOCKED
	_click(editor, Vector2i(25, 11))
	assert_eq(editor.draft.letter_at(Vector2i(25, 11)), "X", "se pintó justo esa casilla")
	_click(editor, Vector2i(2, 2))
	assert_eq(editor.draft.letter_at(Vector2i(2, 2)), "X")
	assert_eq(editor.draft.letter_at(Vector2i(3, 3)), ".", "y ninguna vecina")


func test_hover_follows_the_cell_under_the_mouse_with_zoom() -> void:
	var editor: MapEditor = _open(26, 12)
	var area: Control = editor.get_node("%MapArea")
	var motion := InputEventMouseMotion.new()
	motion.position = _mouse_at(editor, Vector2i(22, 8))
	area.gui_input.emit(motion)
	assert_eq((editor.get_node("%MapView") as MapView).hover_cell, Vector2i(22, 8))


func test_the_usual_map_keeps_the_old_click_math() -> void:
	var editor: MapEditor = _open(20, 9)
	assert_eq(editor.get_node("%MapView").cell_at_area(Vector2(64.0 * 3 + 10, 64.0 * 2 + 63)), Vector2i(3, 2))
	assert_eq(editor.get_node("%MapView").cell_at_area(Vector2(-1, 5)), Vector2i(-1, 0))
