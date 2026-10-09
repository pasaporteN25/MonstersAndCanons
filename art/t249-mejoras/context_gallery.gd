# Banco visual sobre el terreno real: muestras explícitas, sin alterar la campaña.
extends Node

var sample_paths: Array = []

func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t249_capture.json")
	GameFlow.current_index = -1
	sample_paths = JSON.parse_string(FileAccess.get_file_as_string("res://art/t249-mejoras/asset_paths.json"))
	sample_paths = sample_paths.filter(func(path: String) -> bool: return not ("reserva_" in path or "suppression" in path or "pulse_ring" in path))
	for phase: String in ["before", "after"]:
		for number: int in [1, 6, 8, 10]:
			var game: Game = preload("res://scenes/game/game.tscn").instantiate()
			game.level_data = GameFlow.level(number - 1)
			add_child(game)
			await get_tree().process_frame
			var tray: Control = Control.new()
			tray.position = Vector2(12, 110)
			tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(tray)
			var title: Label = Label.new()
			title.text = "T249 · MUESTRAS PROVISIONALES · " + ("ANTES" if phase == "before" else "DESPUÉS") + " · no son objetos de esta partida"
			title.add_theme_color_override("font_color", Color.WHITE)
			title.add_theme_color_override("font_shadow_color", Color.BLACK)
			title.add_theme_constant_override("shadow_offset_x", 2)
			title.add_theme_constant_override("shadow_offset_y", 2)
			tray.add_child(title)
			for i: int in sample_paths.size():
				var path: String = "res://" + sample_paths[i]
				if phase == "before":
					path = "res://art/t249-mejoras/sources/before/" + sample_paths[i]
				var image: Image = Image.new()
				if path.ends_with(".svg"):
					assert(image.load_svg_from_string(FileAccess.get_file_as_string(path)) == OK)
				else:
					image = Image.load_from_file(path)
					if image.get_width() == 512:
						image = image.get_region(Rect2i(0, 0, 128, 128))
				var icon: TextureRect = TextureRect.new()
				icon.texture = ImageTexture.create_from_image(image)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.position = Vector2(i % 8 * 150, 45 + i / 8 * 125)
				icon.size = Vector2(64, 64)
				tray.add_child(icon)
				var label: Label = Label.new()
				label.text = path.get_file().get_basename().replace("_", "\n")
				label.add_theme_font_size_override("font_size", 12)
				label.add_theme_color_override("font_shadow_color", Color.BLACK)
				label.add_theme_constant_override("shadow_offset_x", 1)
				label.add_theme_constant_override("shadow_offset_y", 1)
				label.position = icon.position + Vector2(65, 0)
				tray.add_child(label)
			for frame: int in 5:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			assert(get_viewport().get_texture().get_image().save_png("res://art/t249-mejoras/%s/gallery_level_%02d.png" % [phase, number]) == OK)
			tray.queue_free()
			game.queue_free()
			await get_tree().process_frame
	get_tree().quit()
