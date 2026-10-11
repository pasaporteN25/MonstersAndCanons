# Galería rotulada sobre partidas reales; no representa decoración integrada en esas casillas.
extends Node

var entries: Array = []

func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t260_capture.json")
	GameFlow.current_index = -1
	var parser: JSON = JSON.new()
	assert(parser.parse(FileAccess.get_file_as_string("res://art/t260-decoration/manifest.json")) == OK)
	entries = parser.data
	for phase: String in ["before", "after"]:
		for number: int in [1, 6, 8, 10]:
			var game: Game = preload("res://scenes/game/game.tscn").instantiate()
			game.level_data = GameFlow.level(number - 1)
			add_child(game)
			await get_tree().process_frame
			for frame: int in 4:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			if phase == "after":
				assert(get_viewport().get_texture().get_image().save_png("res://art/t260-decoration/%s/level_%02d.png" % [phase, number]) == OK)
			var tray: Control = Control.new()
			tray.position = Vector2(12, 110)
			tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(tray)
			var title: Label = Label.new()
			title.text = "T260 · MUESTRAS PROVISIONALES · " + ("ANTES" if phase == "before" else "DESPUÉS") + " · no son objetos de esta partida"
			title.add_theme_color_override("font_shadow_color", Color.BLACK)
			title.add_theme_constant_override("shadow_offset_x", 2)
			title.add_theme_constant_override("shadow_offset_y", 2)
			tray.add_child(title)
			for i: int in entries.size():
				var path: String = entries[i]["archivo"]
				if phase == "before":
					path = "art/t260-decoration/sources/before/" + path.get_file()
				var sample: Image = Image.new()
				assert(sample.load_svg_from_string(FileAccess.get_file_as_string("res://" + path)) == OK)
				var icon: TextureRect = TextureRect.new()
				icon.texture = ImageTexture.create_from_image(sample)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.position = Vector2(i % 7 * 180, 45 + i / 7 * 112)
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
			assert(get_viewport().get_texture().get_image().save_png("res://art/t260-decoration/%s/gallery_level_%02d.png" % [phase, number]) == OK)
			tray.queue_free()
			game.queue_free()
			await get_tree().process_frame
	get_tree().quit()
