# T225: captura del nivel 10 a escala de juego. No es una partida humana: torres en casillas
# legales, la mina habilitada, un Mortero comprado con sus recursos y enemigos congelados.
extends Node

const MINE: Vector2i = Vector2i(10, 2)


func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t225_capture.json")
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(9)
	add_child(game)
	await get_tree().process_frame
	game.session.earn(2000)
	game.session.add_resources(3)
	assert(game.infrastructure.enable(MINE))
	var builds: Array = [["basic", Vector2i(4, 3)], ["cannon", Vector2i(8, 3)], ["frost", Vector2i(12, 3)],
		["sniper", Vector2i(16, 3)], ["fire", Vector2i(6, 7)], ["multi", Vector2i(10, 7)],
		["mortar", Vector2i(5, 2)], ["tesla", Vector2i(18, 7)]]
	for build: Array in builds:
		assert(game.build_controller.try_build(load("res://data/towers/%s.tres" % build[0]), build[1]), String(build[0]))
	for tower: Node in game.tower_container.get_children():
		tower.set_physics_process(false)
	var path: Path2D = game.level.get_ground_path(0)
	var distance: float = Rules.tiles_to_px(8)
	for id: String in ["guardian", "healer", "rammer", "troll", "normal", "normal"]:
		var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
		enemy.setup(load("res://data/enemies/" + id + ".tres"), path, 200)
		game.enemies.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.distance = distance
		enemy.global_position = path.to_global(path.curve.sample_baked(distance))
		distance += Rules.tiles_to_px(1)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/campaign-t225/level_10.png")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
