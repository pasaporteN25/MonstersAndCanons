## T443 RF-665: captura el poste personalizado sobre el mapa real del nivel 6.
extends Node


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var dimensions: PackedStringArray = (args[1] if args.size() > 1 else "1280x720").split("x")
	var resolution := Vector2i(int(dimensions[0]), int(dimensions[1]))
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_window().content_scale_size = resolution
	get_window().size = resolution
	get_window().position = Vector2i.ZERO
	var level_data: LevelData = GameFlow.level(5)
	assert(level_data.id == &"level_06", "el índice 5 debe ser el nivel 6 de campaña")
	var level: Level = level_data.build_map(true, BannerRecipe.make("marea", "estrella"))
	add_child(level)
	for _i: int in 10:
		await get_tree().process_frame
	var map_size: Vector2 = Vector2(level.map_size()) * Rules.TILE_SIZE
	level.position = Vector2((resolution.x - map_size.x) * 0.5, 90)
	await RenderingServer.frame_post_draw
	var out: String = args[0] if not args.is_empty() else "art/t443-banderines/capturas"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var path: String = "%s/%s_level06.png" % [out, resolution.x]
	var error: Error = get_viewport().get_texture().get_image().save_png(path)
	assert(error == OK, "no se pudo guardar %s" % path)
	print("Captura: %s" % path)
	get_tree().quit()
