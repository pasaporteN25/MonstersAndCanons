extends Node

const GAME = preload("res://scenes/game/game.tscn")

func _ready() -> void:
	call_deferred("capture")

func capture() -> void:
	var game: Game = GAME.instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	var cells: Array[Vector2i] = [Vector2i(1, 2), Vector2i(4, 2), Vector2i(8, 2), Vector2i(11, 2), Vector2i(5, 6), Vector2i(8, 6), Vector2i(15, 6), Vector2i(18, 6)]
	for i in game.tower_types.size():
		var data: TowerData = game.tower_types[i]
		var cell: Vector2i = cells[i] if i < cells.size() else Vector2i(-1, -1)
		if i >= cells.size():
			for y in range(8):
				for x in range(19):
					if cell.x < 0 and game.build_controller.cells_free(data, Vector2i(x, y)):
						cell = Vector2i(x, y)
		if not game.build_controller.try_build(data, cell):
			push_error("No se pudo colocar: " + str(data.id))
			get_tree().quit(1)
			return
		var tower: Tower = game.build_controller.tower_at(cell)
		tower.aim_angle = -0.25 if i % 2 == 0 else -PI / 2
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png("res://art/prototypes/full-pass/torretas_v3_en_juego.png")
	print("Captura de juego: ", result)
	get_tree().quit(result)
