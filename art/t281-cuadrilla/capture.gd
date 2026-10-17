# Partida real del nivel 7, oleada 8; avance controlado y sustitución visual en memoria.
extends Node

const OUT: String = "res://art/t281-cuadrilla/captures/"
const R_BODY: Texture2D = preload("res://art/t281-cuadrilla/derived/ratero.png")
const R_WALK: Texture2D = preload("res://art/t281-cuadrilla/derived/ratero_walk.png")
const C_BODY: Texture2D = preload("res://art/t281-cuadrilla/derived/cargador.png")
const C_WALK: Texture2D = preload("res://art/t281-cuadrilla/derived/cargador_walk.png")
var stage: SubViewport
var metadata: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func run() -> void:
	seed(281)
	stage = SubViewport.new()
	stage.size = Vector2i(1280, 720)
	stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(stage)
	var screen: TextureRect = TextureRect.new()
	screen.texture = stage.get_texture()
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	SaveManager.save_path = "user://test_t281_capture.json"
	GameFlow.current_index = -1
	for id: StringName in [&"ratero", &"cargador", &"armored", &"tank"]:
		SaveManager.mark_enemy_seen(id)
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(6)
	stage.add_child(game)
	await get_tree().process_frame
	game.level_intro.close()
	get_tree().paused = true
	game.session.jump_to_wave(8)
	game.start_next_wave()
	# La oleada avanza con el reloj real. Solo se pausa al comparar el mismo instante.
	for second: int in [3, 6, 9]:
		get_tree().paused = false
		await get_tree().create_timer(3.0, false).timeout
		get_tree().paused = true
		game.hud.process_mode = Node.PROCESS_MODE_DISABLED
		await shot("level_07_wave_08_%02ds_before" % second)
		var actors: Array[Dictionary] = []
		for child: Node in game.enemies.get_children():
			if child is Enemy:
				var enemy: Enemy = child as Enemy
				if enemy.data.id in [&"ratero", &"cargador"]:
					var original: EnemyData = enemy.data
					enemy.set_meta("review_original", original)
					enemy.data = original.duplicate()
					enemy.data.texture = R_BODY if original.id == &"ratero" else C_BODY
					enemy.data.walk_atlas = R_WALK if original.id == &"ratero" else C_WALK
					enemy.queue_redraw()
					var origin: Vector2 = enemy.get_global_transform_with_canvas() * Vector2.ZERO
					actors.append({"id": String(original.id), "origin": [origin.x, origin.y], "distance": enemy.distance, "frame": [enemy.visual_frame_region().position.x, enemy.visual_frame_region().position.y]})
		assert(not actors.is_empty())
		metadata.append({"second": second, "actors": actors})
		await shot("level_07_wave_08_%02ds_after" % second)
		for child: Node in game.enemies.get_children():
			if child is Enemy and child.has_meta("review_original"):
				(child as Enemy).data = child.get_meta("review_original")
				child.remove_meta("review_original")
				(child as Enemy).queue_redraw()
		await get_tree().process_frame
		game.hud.process_mode = Node.PROCESS_MODE_INHERIT
	var file: FileAccess = FileAccess.open("res://art/t281-cuadrilla/capture_metadata.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(metadata, "\t"))
	file.close()
	get_tree().paused = false
	get_tree().quit()

func shot(label: String) -> void:
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(stage.get_texture().get_image().save_png(OUT + label + ".png") == OK)
	print("T281: ", label)
