# T549: captura real 1280×720 del nivel 15. Uso: godot --path . art/t549-abastecimiento/capture_level15.tscn -- antes|despues
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"

var stage: SubViewport

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func run() -> void:
	var label: String = "despues"
	for arg: String in OS.get_cmdline_user_args():
		label = arg
	stage = SubViewport.new()
	stage.size = Vector2i(1280, 720)
	stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(stage)
	var screen: TextureRect = TextureRect.new()
	screen.texture = stage.get_texture()
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	var flow: Node = get_node("/root/GameFlow")
	var save: Node = get_node("/root/SaveManager")
	save.save_path = "user://test_t549_capture.json"
	flow.current_index = -1
	var game: Variant = (load(GAME_PATH) as PackedScene).instantiate()
	game.level_data = flow.level(14)
	stage.add_child(game)
	await get_tree().process_frame
	game.level_intro.close()
	get_tree().paused = true
	for frame: int in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png("res://art/t549-abastecimiento/level_15_%s_1280x720.png" % label) == OK)
	print("T549: ", label)
	var audio: Node = get_node("/root/Audio")
	audio.set_process(false)
	for child: Node in audio.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	for frame: int in 5:
		await get_tree().process_frame
	get_tree().quit()
