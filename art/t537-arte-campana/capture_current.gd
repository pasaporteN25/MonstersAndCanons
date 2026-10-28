# Capturas de la integración real, con transiciones controladas del campo de infraestructura.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const OUT: String = "res://art/t537-arte-campana/captures/"

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
	save.save_path = "user://test_t277_capture.json"
	flow.current_index = -1
	for enemy_id: String in ["normal", "fast", "tank", "armored", "boss", "flyer", "ratero", "cargador", "colossus", "guardian", "thief"]:
		save.mark_enemy_seen(StringName(enemy_id))
	for number: int in [1, 14, 15]:
		var game: Variant = (load(GAME_PATH) as PackedScene).instantiate()
		game.level_data = flow.level(number - 1)
		stage.add_child(game)
		await get_tree().process_frame
		game.level_intro.close()
		get_tree().paused = true
		for cell: Vector2i in game.level.legend_cells:
			if game.level.legend_cells[cell] == "estatua":
				game.build_controller._mobile_map_tap(game.level.cell_center(cell), Time.get_ticks_msec())
				assert(game.build_controller.selected_placed() == null)
				assert(not game.infrastructure.has_selection())
				assert(not game.level.is_buildable(cell))
				assert(game.build_controller.tower_at(cell) == null)
				print("T537: estatua sin selección ni torre en ", number, " ", cell)
		await shot("level_%02d_initial" % number)
		var cells: Array[Dictionary] = []
		for cell: Vector2i in game.level.legend_cells:
			var origin: Vector2 = game.level.get_global_transform_with_canvas() * (Vector2(cell) * Rules.TILE_SIZE)
			cells.append({"drawing": game.level.legend_cells[cell], "cell": [cell.x, cell.y], "screen_origin": [origin.x, origin.y]})
		metadata[str(number)] = {"theme": game.level.theme, "tile_screen_px": Rules.TILE_SIZE * Rules.map_zoom(game.level.map_size().x, game.level.map_size().y), "legend": cells}
		# Se usan los estados reales, sin reemplazar la decoración del juego.
		for cell: Vector2i in game.infrastructure.field.extraction_cells():
			game.infrastructure.field.enable_site(cell)
		var rubble: Vector2i = InfrastructureController.NONE
		for cell: Vector2i in game.level.removable_cells:
			if game.level.legend_cells.get(cell) == "escombro":
				rubble = cell
				break
		if rubble != InfrastructureController.NONE:
			game.infrastructure.field.order(rubble)
			game.infrastructure.field.tick(0.4)
		await shot("level_%02d_active" % number)
		for wave: int in 100:
			game.infrastructure.field.complete_wave()
		await shot("level_%02d_depleted" % number)
		if rubble != InfrastructureController.NONE:
			game.infrastructure.field.tick(100.0)
		await shot("level_%02d_cleared" % number)
		get_tree().paused = false
		game.queue_free()
		await get_tree().process_frame
	var metadata_file: FileAccess = FileAccess.open("res://art/t537-arte-campana/captures/map_metadata.json", FileAccess.WRITE)
	metadata_file.store_string(JSON.stringify(metadata, "\t"))
	metadata_file.close()
	# Cortar la reproducción antes del cierre para soltar el playback del backend de audio.
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
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUT + label + ".png") == OK)
	print("T537: ", label)
