# Tests de la pantalla de récords (T91, spec RF-195).
extends GutTest

const RECORDS_SCENE: PackedScene = preload("res://scenes/ui/records_screen.tscn")
const TEST_PATH: String = "user://test_save.json"

var screen: Control


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	SaveManager.add_score(&"level_01", "ANA", 900)
	SaveManager.add_score(&"level_01", "LUC", 700)
	screen = RECORDS_SCENE.instantiate()
	add_child_autofree(screen)


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _level_name() -> String:
	return (screen.get_node("%LevelName") as Label).text


func test_starts_with_the_first_level() -> void:
	assert_eq(_level_name(), "Nivel 1 · Pradera")
	assert_eq(screen.table_rows(), 2, "los dos récords del nivel 1")


func test_arrows_change_level_and_wrap_around() -> void:
	screen.show_level(1)
	assert_eq(_level_name(), "Nivel 2 · Desfiladero")
	assert_eq(screen.table_rows(), 1, "sin récords: una fila que lo dice")
	screen.show_level(-1)
	assert_eq(screen.current_level_index(), GameFlow.level_count() - 1, "antes del primero, el último")


func test_hall_of_fame_opens_and_closes() -> void:
	screen.open_hall_of_fame()
	assert_true(screen.is_hall_open(), "RF-195")
	screen.close_hall_of_fame()
	assert_false(screen.is_hall_open())
