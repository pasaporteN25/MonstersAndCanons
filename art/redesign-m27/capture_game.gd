# Revisión en escenas reales usando copias de datos; no modifica recursos originales.
extends Node
const ROOT: String = "res://art/redesign-m27/"
const TOWERS: Array[String] = ["cannon", "basic", "multi", "sniper", "burst", "fire", "mortar", "frost", "tesla"]
const MONSTERS: Array[String] = ["guardian", "healer", "shaman", "mirror", "boss"]
func _ready() -> void:
	call_deferred("capture")
func capture() -> void:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	for index: int in TOWERS.size():
		for level: int in 3:
			var data: TowerData = (load("res://data/towers/" + TOWERS[index] + ".tres") as TowerData).duplicate()
			if level > 0:
				data.turret_atlas = ImageTexture.create_from_image(Image.load_from_file(ROOT + "atlases/" + TOWERS[index] + "_level_" + str(level + 1) + ".png"))
			var tower: Tower = (load("res://scenes/towers/tower.tscn") as PackedScene).instantiate()
			tower.setup(data)
			tower.level_index = level
			tower.position = Vector2(75 + index * 137, 190 + level * 145)
			tower.aim_angle = 0.0
			game.add_child(tower)
			tower.set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ROOT + "previews/evolutions_map.png")
	game.queue_free()
	await get_tree().process_frame
	game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	game.add_child(path)
	for index: int in MONSTERS.size():
		var data: EnemyData = (load("res://data/enemies/" + MONSTERS[index] + ".tres") as EnemyData).duplicate()
		data.texture = ImageTexture.create_from_image(Image.load_from_file(ROOT + "monsters/" + MONSTERS[index] + ".png"))
		data.flip_when_walking_left = false
		var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
		enemy.setup(data, path, data.max_health)
		game.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.position = Vector2(250 + index * 185, 350)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ROOT + "previews/special_monsters_map.png")
	get_tree().quit()
