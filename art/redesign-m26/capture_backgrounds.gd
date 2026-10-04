# Muestras reales de Godot. Solo se alteran las instancias temporales del mapa.
extends Node

const PREVIEW: Script = preload("res://art/redesign-m26/preview_decor.gd")

func _ready() -> void:
	call_deferred("capture")

func capture() -> void:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	for i: int in 6:
		game.build_controller.try_build(game.tower_types[i], Vector2i(3 + (i % 3) * 4, 2 + (i / 3) * 4))
	# Retratos aprobados en el mapa: sirven para revisar contraste, no simulan combate.
	for i: int in 3:
		var id: String = ["normal", "fast", "tank"][i]
		var creature := Sprite2D.new()
		creature.texture = load("res://assets/sprites/enemies/rendered/" + id + ".png")
		creature.scale = Vector2.ONE * [45.0, 36.0, 63.0][i] / 256.0
		creature.position = Vector2(380 + i * 160, 350)
		game.add_child(creature)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m26/before.png")
	game.level.ground.hide()
	game.level.get_node("Decor").hide()
	var decor: Node2D = PREVIEW.new()
	decor.ground = game.level.ground
	decor.position = game.level.ground.position
	game.level.add_child(decor)
	game.level.move_child(decor, 0)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m26/map_preview.png")
	game.queue_free()
	await get_tree().process_frame
	var menu: Control = (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	add_child(menu)
	await get_tree().process_frame
	var map: Node2D = menu.get_node("Background").get_child(0)
	map.ground.hide()
	map.get_node("Decor").hide()
	var menu_decor: Node2D = PREVIEW.new()
	menu_decor.ground = map.ground
	menu_decor.position = map.ground.position
	map.add_child(menu_decor)
	map.move_child(menu_decor, 0)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m26/menu_preview.png")
	get_tree().quit()
