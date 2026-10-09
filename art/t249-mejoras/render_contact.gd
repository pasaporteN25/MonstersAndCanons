# Hojas a tamaño de juego y Wiki, rasterizadas por el mismo motor que importa los SVG.
extends SceneTree

func _initialize() -> void:
	var paths: Array = JSON.parse_string(FileAccess.get_file_as_string("res://art/t249-mejoras/asset_paths.json"))
	for phase: String in ["before", "after"]:
		for size: int in [34, 64, 112, 220]:
			var slot: int = size + 16
			var sheet: Image = Image.create(slot * 8, slot * ceili(paths.size() / 8.0), false, Image.FORMAT_RGBA8)
			sheet.fill(Color("#383b36"))
			for i: int in paths.size():
				var path: String = "res://" + paths[i]
				if phase == "before":
					path = "res://art/t249-mejoras/sources/before/" + paths[i]
				var source: Image = Image.new()
				if path.ends_with(".svg"):
					assert(source.load_svg_from_string(FileAccess.get_file_as_string(path)) == OK)
				else:
					source = Image.load_from_file(path)
					if source.get_width() == 512:
						source = source.get_region(Rect2i(0, 0, 128, 128))
				source.resize(size, size, Image.INTERPOLATE_LANCZOS)
				var origin: Vector2i = Vector2i(i % 8 * slot, i / 8 * slot)
				var grounds: Array[Color] = [Color("#8baf60"), Color("#59794b"), Color("#777365"), Color("#a8946b")]
				sheet.fill_rect(Rect2i(origin, Vector2i(slot, slot)), grounds[i / 8 % 4])
				sheet.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), origin + Vector2i(8, 8))
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/t249-mejoras/" + phase))
			assert(sheet.save_png("res://art/t249-mejoras/%s/contact_%d.png" % [phase, size]) == OK)
	quit()
