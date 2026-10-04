# Capturas de una escena de juego real, con guardados aislados por APPDATA.
extends Node

const GAME: PackedScene = preload("res://scenes/game/game.tscn")

func _ready() -> void:
	call_deferred("capture")

func capture() -> void:
	var game: Game = GAME.instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	var cells: Array[Vector2i] = [Vector2i(1, 2), Vector2i(4, 2), Vector2i(8, 2), Vector2i(11, 2), Vector2i(5, 6), Vector2i(8, 6), Vector2i(15, 6), Vector2i(18, 6)]
	for i: int in game.tower_types.size():
		var data: TowerData = game.tower_types[i]
		var cell: Vector2i = cells[i] if i < cells.size() else Vector2i(-1, -1)
		if i >= cells.size():
			for y: int in range(8):
				for x: int in range(19):
					if cell.x < 0 and game.build_controller.cells_free(data, Vector2i(x, y)):
						cell = Vector2i(x, y)
		if not game.build_controller.try_build(data, cell):
			push_error("No se pudo colocar: " + str(data.id))
			get_tree().quit(1)
			return
		var tower: Tower = game.build_controller.tower_at(cell)
		tower.aim_angle = 0.0 if i % 2 == 0 else -PI / 2
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m23/en_juego.png")
	# Revisión de mejoras dentro del motor, no una composición externa.
	for tower: Tower in game.tower_container.get_children():
		game.build_controller.try_upgrade(tower)
		game.build_controller.try_upgrade(tower)
	game.start_next_wave()
	await get_tree().create_timer(3.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m23/combate.png")
	# Comparar los impactos juntos: escena real, a tamaño de juego.
	game.effects.projectile_impacted(Vector2(380, 300), game.tower_types[1].levels[0])
	game.effects.projectile_impacted(Vector2(480, 300), game.tower_types[2].levels[0])
	game.effects.projectile_impacted(Vector2(580, 300), game.tower_types[4].levels[0])
	game.effects.lightning(PackedVector2Array([Vector2(680, 300), Vector2(780, 310), Vector2(860, 280)]))
	await get_tree().create_timer(0.06).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m23/efectos_en_juego.png")
	print("Tres capturas guardadas")
	get_tree().quit()
