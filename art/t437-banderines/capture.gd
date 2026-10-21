# Capturas de las dos variantes del poste en el mapa real del nivel 6.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const OUTPUT: String = "res://art/t437-banderines/capturas/"
const TEST_SAVE: String = "user://t437_banner_capture.json"

var stage: SubViewport


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")


func run() -> void:
	stage = SubViewport.new()
	stage.size = Vector2i(1280, 720)
	stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(stage)
	var screen := TextureRect.new()
	screen.texture = stage.get_texture()
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)

	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	SaveManager.save_path = TEST_SAVE
	SaveManager.backup_save_path = TEST_SAVE
	SaveManager.backup_prefix = "user://test_t437_capture_backup_"
	SaveManager.load_save()
	GameFlow.current_index = 5
	await _capture_variant(false, "level_06_enemy.png")

	SaveManager.record_victory(&"level_06", 15)
	assert(SaveManager.save())
	await _capture_variant(true, "level_06_player.png")

	var audio: Node = get_node("/root/Audio")
	audio.set_process(false)
	for child: Node in audio.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	for frame: int in 5:
		await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit()


func _capture_variant(conquered: bool, filename: String) -> void:
	var game: Variant = (load(GAME_PATH) as PackedScene).instantiate()
	stage.add_child(game)
	await get_tree().process_frame
	game.level_intro.close()
	get_tree().paused = true
	var expected: Texture2D = MapDrawings.POST_PLAYER if conquered else MapDrawings.POST_ENEMY
	print("T437 capture: expected=", conquered, ", campaign index=", GameFlow.current_index,
			", level=", GameFlow.current_level().id if GameFlow.current_level() != null else "null",
			", completed=", SaveManager.is_completed(&"level_06"), ", actual=", game.level.post_conquered)
	assert(game.level.post_conquered == conquered)
	for cell: Vector2i in game.level.legend_cells:
		if game.level.legend_cells[cell] == MapDrawings.POST_DRAWING:
			assert(game.level.get_node("Decor").object_texture(cell, MapDrawings.POST_DRAWING) == expected)
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUTPUT + filename) == OK)
	get_tree().paused = false
	game.queue_free()
	await get_tree().process_frame
