# Cuándo sale «Novedades de esta versión» (M67, RF-603, T371): la tabla de decisión, sin escenas.
extends GutTest

const APPROVED: Dictionary = {"id": "1.0.0", "tipo": "presentacion", "borrador": false}
const DRAFT: Dictionary = {"id": "1.0.0", "tipo": "presentacion", "borrador": true}
const IMPROVEMENTS: Dictionary = {"id": "1.1.0", "tipo": "mejoras", "borrador": false}


func _decide(version: String, seen: String, entry: Dictionary, valid: bool = true, dev: bool = false,
		editor: bool = false, standalone: bool = false, new_save: bool = false) -> NewsFlow.Decision:
	return NewsFlow.decide(version, seen, entry, valid, dev, editor, standalone, new_save)


func test_shows_for_a_new_version_with_an_approved_entry() -> void:
	assert_eq(_decide("1.0.0", "", APPROVED), NewsFlow.Decision.SHOW)
	assert_eq(_decide("1.0.0", "0.9.0", APPROVED), NewsFlow.Decision.SHOW)


func test_does_not_show_again_for_the_same_version() -> void:
	assert_eq(_decide("1.0.0", "1.0.0", APPROVED), NewsFlow.Decision.NOTHING)


func test_beta_and_empty_version_never_show() -> void:
	assert_eq(_decide("beta", "", {}), NewsFlow.Decision.NOTHING)
	assert_eq(_decide("", "", APPROVED), NewsFlow.Decision.NOTHING)


func test_draft_missing_entry_and_invalid_file_do_not_show() -> void:
	assert_eq(_decide("1.0.0", "", DRAFT), NewsFlow.Decision.NOTHING)
	assert_eq(_decide("1.0.0", "", {}), NewsFlow.Decision.NOTHING)
	assert_eq(_decide("1.0.0", "", APPROVED, false), NewsFlow.Decision.NOTHING)


func test_never_in_dev_mode_editor_or_standalone_scene() -> void:
	assert_eq(_decide("1.0.0", "", APPROVED, true, true), NewsFlow.Decision.NOTHING)
	assert_eq(_decide("1.0.0", "", APPROVED, true, false, true), NewsFlow.Decision.NOTHING)
	assert_eq(_decide("1.0.0", "", APPROVED, true, false, false, true), NewsFlow.Decision.NOTHING)


func test_presentation_shows_to_new_saves_too() -> void:
	assert_eq(_decide("1.0.0", "", APPROVED, true, false, false, false, true), NewsFlow.Decision.SHOW)


func test_improvements_show_to_old_saves_and_are_marked_silently_for_new_ones() -> void:
	assert_eq(_decide("1.1.0", "1.0.0", IMPROVEMENTS), NewsFlow.Decision.SHOW)
	assert_eq(_decide("1.1.0", "", IMPROVEMENTS, true, false, false, false, true), NewsFlow.Decision.MARK_SILENTLY)


func test_improvements_in_new_save_in_dev_mode_mark_nothing() -> void:
	assert_eq(_decide("1.1.0", "", IMPROVEMENTS, true, true, false, false, true), NewsFlow.Decision.NOTHING)


func test_should_auto_show_matches_decide() -> void:
	assert_true(NewsFlow.should_auto_show("1.0.0", "", APPROVED, true, false, false, false, false))
	assert_false(NewsFlow.should_auto_show("1.1.0", "", IMPROVEMENTS, true, false, false, false, true))


func test_is_new_save() -> void:
	assert_true(NewsFlow.is_new_save(false, false))
	assert_false(NewsFlow.is_new_save(true, false))
	assert_false(NewsFlow.is_new_save(false, true))
