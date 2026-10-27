# Captura comparativa de T267 sobre el estado integrado actual de la campaña.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const OUT: String = "res://art/t529-review-t267/captures/"
const LEVELS: Array[int] = [1, 3, 5, 11, 13, 15]

var stage: SubViewport
var metadata: Dictionary = {}

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
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	var flow: Node = get_node("/root/GameFlow")
	var save: Node = get_node("/root/SaveManager")
	save.save_path = "user://test_t529_review.json"
	flow.current_index = -1
	for enemy_id: String in ["normal", "fast", "tank", "armored", "boss", "flyer", "ratero", "cargador", "colossus", "guardian", "thief"]:
		save.mark_enemy_seen(StringName(enemy_id))
	for number: int in LEVELS:
		var game: Game = (load(GAME_PATH) as PackedScene).instantiate() as Game
		game.level_data = flow.level(number - 1)
		stage.add_child(game)
		await get_tree().process_frame
		game.level_intro.close()
		get_tree().paused = true
		await shot("level_%02d_current" % number)
		var cells: Array[Dictionary] = []
		for cell: Vector2i in game.level.legend_cells:
			var origin: Vector2 = game.level.get_global_transform_with_canvas() * (Vector2(cell) * Rules.TILE_SIZE)
			cells.append({"drawing": game.level.legend_cells[cell], "cell": [cell.x, cell.y], "screen_origin": [origin.x, origin.y]})
		metadata[str(number)] = {"theme": game.level.theme, "tile_screen_px": Rules.TILE_SIZE * Rules.map_zoom(game.level.map_size().x, game.level.map_size().y), "legend": cells}
		var old_decor: LevelDecor = game.level.get_node("Decor")
		old_decor.visible = false
		var sample_decor: LevelDecor = preload("res://art/t529-review-t267/sample_decor_current_canon.gd").new()
		game.level.add_child(sample_decor)
		sample_decor.paint(game.level.ground, game.level.inner_exit_cells(), game.level.theme, game.level.legend_cells, game.level.removable_cells)
		await shot("level_%02d_proposal" % number)
		old_decor.visible = true
		get_tree().paused = false
		game.queue_free()
		await get_tree().process_frame
	var metadata_file: FileAccess = FileAccess.open("res://art/t529-review-t267/map_metadata.json", FileAccess.WRITE)
	metadata_file.store_string(JSON.stringify(metadata, "\t"))
	metadata_file.close()
	get_tree().quit()

func shot(label: String) -> void:
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUT + label + ".png") == OK)
	print("T529: ", label)
