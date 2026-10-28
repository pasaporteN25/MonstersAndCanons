# T267: captura de niveles 1, 14 y 15 a 1280x720 para la comparación antes/después.
# Uso: godot --path <proyecto> res://art/t267-comparacion/capture.tscn -- out=/ruta/salida/
# Funciona igual en el commit anterior a T277 y en main: solo usa estados reales del campo de infraestructura.
extends Node

var stage: SubViewport
var out: String = ""

func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("out="):
			out = arg.substr(4)
	call_deferred("run")

func run() -> void:
	stage = SubViewport.new()
	stage.size = Vector2i(1280, 720)
	stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(stage)
	var screen: TextureRect = TextureRect.new()
	screen.texture = stage.get_texture()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	var flow: Node = get_node("/root/GameFlow")
	var save: Node = get_node("/root/SaveManager")
	save.save_path = "user://test_t267_capture.json"
	flow.current_index = -1
	for enemy_id: String in ["normal", "fast", "tank", "armored", "boss", "flyer", "ratero", "cargador", "colossus", "guardian", "thief"]:
		save.mark_enemy_seen(StringName(enemy_id))
	for number: int in [1, 14, 15]:
		var game: Variant = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
		game.level_data = flow.level(number - 1)
		stage.add_child(game)
		await get_tree().process_frame
		game.level_intro.close()
		get_tree().paused = true
		await shot("level_%02d_initial" % number)
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
		if rubble != InfrastructureController.NONE:
			game.infrastructure.field.tick(100.0)
		await shot("level_%02d_depleted" % number)
		get_tree().paused = false
		game.queue_free()
		await get_tree().process_frame
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
	assert(stage.get_texture().get_image().save_png(out + label + ".png") == OK)
	print("T267: ", label)
