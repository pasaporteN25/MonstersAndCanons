extends Node
func _ready() -> void:
	SaveManager.save_path = "user://test_m37_progress_capture.json"
	SaveManager.load_save()
	GameFlow.current_index = 0
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.collectible.carrier_index = 0
	game.session.begin_wave()
	game.spawner._spawn_enemy(preload("res://data/enemies/normal.tres"), game.level.get_ground_path(0), 0.0, true)
	game._carrier.take_hit(10000)
	await get_tree().create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/progression-m37/avance_pendiente.png")
	game.session.complete_wave()
	await get_tree().create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/progression-m37/avance_confirmado.png")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
