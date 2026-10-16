# Capturas del juego real; las apariciones de diagnóstico no son oleadas de campaña.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const OUT: String = "res://art/t267a/captures/"

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
	save.save_path = "user://test_t267a_capture.json"
	flow.current_index = -1
	for enemy_id: String in ["normal", "fast", "tank", "armored", "boss", "flyer", "ratero", "cargador", "colossus", "guardian", "thief"]:
		save.mark_enemy_seen(StringName(enemy_id))
	for number: int in [1, 2, 3, 4, 5, 11, 12, 13, 14, 15]:
		var game = (load(GAME_PATH) as PackedScene).instantiate()
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
		var sample_decor: LevelDecor = preload("res://art/t267a/sample_decor.gd").new()
		game.level.add_child(sample_decor)
		sample_decor.paint(game.level.ground, game.level.inner_exit_cells(), game.level.theme, game.level.legend_cells, game.level.removable_cells)
		await shot("level_%02d_proposal" % number)
		sample_decor.visible = false
		old_decor.visible = true
		get_tree().paused = false
		game.session.earn(2000)
		var built: int = 0
		for cell: Vector2i in game.level.ground.get_used_cells():
			if built >= 3:
				break
			if cell.y >= 2 and cell.x >= 3 and cell.x % 4 == 0 and game.build_controller.try_build(game.available_towers[built % game.available_towers.size()], cell):
				built += 1
		game.start_next_wave()
		await get_tree().create_timer(3.0).timeout
		get_tree().paused = true
		await shot("level_%02d_combat" % number)
		if number >= 11:
			for site: Vector2i in game.infrastructure.field.extraction_cells():
				game.infrastructure.enable(site)
			for obstacle: ObstacleSpec in game.level_data.obstacles:
				if game.infrastructure.field.is_removable(obstacle.cell):
					game.infrastructure.order(obstacle.cell)
					game.infrastructure.field.tick(game.infrastructure.field.seconds_of(obstacle.cell) * 0.4)
					break
			await shot("level_%02d_working_current" % number)
			old_decor.visible = false
			sample_decor.visible = true
			await shot("level_%02d_working_proposal" % number)
			sample_decor.visible = false
			old_decor.visible = true
		if number in [13, 15]:
			var diagnostic_ids: Array[String] = ["ratero", "cargador", "ratero", "thief", "guardian"]
			if number == 15:
				diagnostic_ids = ["colossus", "guardian", "tank", "normal"]
			var positions: Array[Dictionary] = []
			for i: int in diagnostic_ids.size():
				var enemy_data: EnemyData = load("res://data/enemies/%s.tres" % diagnostic_ids[i])
				game.spawner.spawn_now(enemy_data)
				var enemy: Node = game.enemies.get_child(game.enemies.get_child_count() - 1)
				var fraction: float = 0.5 + i * 0.12 if number == 15 else 0.2 + i * 0.14
				enemy.distance = game.level.get_ground_path(0).curve.get_baked_length() * fraction
				enemy._update_position()
				enemy._animate(0.1)
				if diagnostic_ids[i] == "colossus":
					enemy.take_hit(40)
					enemy._animate(1.0)
				positions.append({"enemy": diagnostic_ids[i], "screen_position": [enemy.get_global_transform_with_canvas().origin.x, enemy.get_global_transform_with_canvas().origin.y]})
			metadata[str(number)]["diagnostic"] = positions
			await shot("level_%02d_diagnostic" % number)
		if number == 11:
			game.hud.show_tab(&"infrastructure")
			for site: Vector2i in game.infrastructure.field.extraction_cells():
				game.infrastructure.select(site)
				break
			await shot("level_11_infrastructure")
		get_tree().paused = false
		game.queue_free()
		await get_tree().process_frame
	var metadata_file: FileAccess = FileAccess.open("res://art/t267a/map_metadata.json", FileAccess.WRITE)
	metadata_file.store_string(JSON.stringify(metadata, "\t"))
	metadata_file.close()
	get_tree().quit()

func shot(label: String) -> void:
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUT + label + ".png") == OK)
	print("T267a: ", label)
