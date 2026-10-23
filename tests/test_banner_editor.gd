extends GutTest
## T443 (RF-663–RF-665): cambios en borrador, aplicar, cancelar, restaurar y error de guardado.

const SCENE: PackedScene = preload("res://scenes/editor/banner_editor.tscn")
const TEST_PATH: String = "user://test_banner_editor.json"

var _closed: int = 0


func before_each() -> void:
	_closed = 0
	_remove(TEST_PATH)


func after_each() -> void:
	_remove(TEST_PATH)
	_remove(TEST_PATH + ".tmp")


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _editor(path: String = TEST_PATH) -> BannerEditor:
	var editor: BannerEditor = SCENE.instantiate()
	editor.store_path = path
	editor.close_editor = func() -> void: _closed += 1
	add_child_autofree(editor)
	return editor


func test_selecting_updates_both_previews_without_saving() -> void:
	var editor := _editor()
	await get_tree().process_frame
	editor.select_palette("brasa")
	editor.select_emblem("rombo")
	assert_eq(editor.draft.palette, "brasa")
	assert_eq(editor.draft.emblem, "rombo")
	assert_eq(editor.get_node("%LargePreview").texture, MapDrawings.post_texture(true, editor.draft))
	assert_eq(editor.get_node("%TilePreview").texture, MapDrawings.post_texture(true, editor.draft))
	assert_false(FileAccess.file_exists(TEST_PATH), "editar no persiste automáticamente")


func test_cancel_discards_draft_and_keeps_existing_recipe() -> void:
	var saved := BannerRecipe.make("marea", "estrella")
	assert_true(BannerRecipeStore.save_recipe(saved, TEST_PATH))
	var editor := _editor()
	await get_tree().process_frame
	editor.select_palette("brasa")
	editor.cancel_editing()
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).equals(saved))
	assert_eq(_closed, 1)


func test_escape_discards_draft() -> void:
	var editor := _editor()
	await get_tree().process_frame
	editor.select_emblem("franja")
	var event := InputEventAction.new()
	event.action = "cancel"
	event.pressed = true
	editor._unhandled_input(event)
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default())
	assert_eq(_closed, 1)


func test_restore_selects_default_until_apply() -> void:
	assert_true(BannerRecipeStore.save_recipe(BannerRecipe.make("musgo", "estrella"), TEST_PATH))
	var editor := _editor()
	await get_tree().process_frame
	editor.restore_default()
	assert_true(editor.draft.is_default())
	assert_eq(BannerRecipeStore.load_recipe(TEST_PATH).palette, "musgo")
	assert_true(editor.apply_draft())
	assert_true(BannerRecipeStore.load_recipe(TEST_PATH).is_default())


func test_apply_saves_and_closes() -> void:
	var editor := _editor()
	await get_tree().process_frame
	editor.select_palette("brasa")
	assert_true(editor.apply_draft())
	assert_eq(BannerRecipeStore.load_recipe(TEST_PATH).palette, "brasa")
	assert_eq(_closed, 1)


func test_failed_save_keeps_editor_open_and_reports_error() -> void:
	var editor := _editor("user://missing_banner_editor_dir/banner.json")
	await get_tree().process_frame
	assert_false(editor.apply_draft())
	assert_eq(_closed, 0)
	assert_true(editor.get_node("%Message").text.contains("No se pudo guardar"))
