# Muestra del menú: modifica solo esta instancia, no la escena de producción.
extends Node

func _ready() -> void:
	call_deferred("capture")

func capture() -> void:
	var menu: Control = (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	add_child(menu)
	var rows: VBoxContainer = menu.get_node("Center/Rows")
	rows.get_node("Title").hide()
	rows.get_node("Subtitle").hide()
	var image: Image = Image.load_from_file("res://art/redesign-m24/sources/logo_corrected.png")
	var logo := TextureRect.new()
	logo.texture = ImageTexture.create_from_image(image)
	logo.custom_minimum_size = Vector2(500, 210)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rows.add_child(logo)
	rows.move_child(logo, 0)
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m24/menu_preview.png")
	menu.queue_free()
	await get_tree().process_frame
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	for i: int in 3:
		game.build_controller.try_build(game.tower_types[i], Vector2i(3 + i * 4, 2))
	var names: Array[String] = ["normal", "fast", "tank"]
	var labels: Array[String] = ["Normal", "Rápido", "Tanque"]
	var sizes: Array[float] = [45.0, 36.0, 63.0]
	for row: int in 2:
		for col: int in 3:
			var variant: String = "A" if row == 0 else "B"
			var source: Image = Image.load_from_file("res://art/redesign-m24/sources/%s_%s.png" % [names[col], variant])
			var creature := Sprite2D.new()
			creature.texture = ImageTexture.create_from_image(source)
			creature.scale = Vector2.ONE * sizes[col] / source.get_height()
			creature.position = Vector2(350 + col * 150, 340 + row * 110)
			game.add_child(creature)
			var label := Label.new()
			label.text = labels[col] + " · " + variant
			label.position = creature.position + Vector2(-35, 36)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_shadow_color", Color.BLACK)
			label.add_theme_constant_override("shadow_offset_x", 1)
			label.add_theme_constant_override("shadow_offset_y", 1)
			game.add_child(label)
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m24/map_preview.png")
	get_tree().quit()
