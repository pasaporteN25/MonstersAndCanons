# Captura de ventana1080; mantiene el lienzo lógico y no cambia project.godot.
extends Node
const ROOT: String = "res://art/redesign-m28/"
func _ready() -> void:
	call_deferred("capture")
func capture() -> void:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	for index: int in 6:
		game.build_controller.try_build(game.tower_types[index], Vector2i(3 + (index % 3) * 4, 2 + (index / 3) * 4))
	for tower: Node in game.get_node("Towers").get_children():
		tower.set_physics_process(false)
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	game.add_child(path)
	for index: int in 8:
		var id: String = ["normal", "fast", "tank", "armored", "troll", "flyer", "spider", "boss"][index]
		var data: EnemyData = (load("res://data/enemies/" + id + ".tres") as EnemyData).duplicate()
		var proposed: String = "res://art/redesign-m26/monsters/" + id + ".png"
		if FileAccess.file_exists(proposed):
			data.texture = ImageTexture.create_from_image(Image.load_from_file(proposed))
		data.flip_when_walking_left = false
		var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
		enemy.setup(data, path, data.max_health)
		game.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.position = Vector2(270 + index * 95, 345)
		# Muestra visual de A (+20 %), sin tocar los datos ni colisiones de producción.
		enemy.scale = Vector2.ONE * 1.2
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(ROOT + "previews/desktop_" + str(image.get_width()) + "x" + str(image.get_height()) + ".png")
	get_tree().quit()
