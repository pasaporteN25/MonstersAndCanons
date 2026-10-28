# T547 (muestra): capturas a 1280x720 del nivel 15 y del epílogo, para decidir qué arte viejo de T233 se retira.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const OUT: String = "res://art/t547-muestra/"

var stage: SubViewport

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func run() -> void:
	stage = SubViewport.new()
	stage.size = Vector2i(1280, 720)
	stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(stage)
	var screen: TextureRect = TextureRect.new()
	screen.texture = stage.get_texture()
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	var flow: Node = get_node("/root/GameFlow")
	var save: Node = get_node("/root/SaveManager")
	save.save_path = "user://test_t547_capture.json"
	flow.current_index = -1
	var report: Dictionary = {}
	var prefix: String = OS.get_environment("T547_PREFIX")
	for number: int in [14, 15]:
		var game: Variant = (load(GAME_PATH) as PackedScene).instantiate()
		game.level_data = flow.level(number - 1)
		stage.add_child(game)
		await get_tree().process_frame
		game.level_intro.close()
		get_tree().paused = true
		await shot("%s1_nivel_%02d" % [prefix, number])
		var cells: Array = []
		for cell: Vector2i in game.level.legend_cells:
			var id: String = game.level.legend_cells[cell]
			if id.begins_with("supply") or id == "hito":
				var origin: Vector2 = game.level.get_global_transform_with_canvas() * (Vector2(cell) * Rules.TILE_SIZE)
				cells.append({"drawing": id, "cell": [cell.x, cell.y], "screen_origin": [origin.x, origin.y]})
		report[str(number)] = {"tile_px": Rules.TILE_SIZE * Rules.map_zoom(game.level.map_size().x, game.level.map_size().y), "supply": cells}
		get_tree().paused = false
		game.queue_free()
		await get_tree().process_frame
	var epilogue: EpilogueScreen = EpilogueScreen.new()
	stage.add_child(epilogue)
	epilogue.open("La máquina sigue avanzando,\npero ¿por cuánto tiempo más?\n¿A qué costo?")
	await shot("%s2_epilogo" % prefix)
	var file: FileAccess = FileAccess.open(OUT + prefix + "metadata.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	var audio: Node = get_node("/root/Audio")
	audio.set_process(false)
	for child: Node in audio.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	for frame: int in 5:
		await get_tree().process_frame
	get_tree().quit()

func shot(label: String) -> void:
	for frame: int in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUT + label + ".png") == OK)
	print("T547: ", label)
