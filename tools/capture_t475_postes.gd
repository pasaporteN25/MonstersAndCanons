# T475 (RF-696, RF-698): capturas reales de la partida de campaña con los postes, los 15 niveles, con 0 o 3 estrellas.
# Se corre con ventana (no `--headless`) y con la carpeta de salida FUERA del repo (se copian solo las que van al PR):
#   godot --path . res://tools/capture_t475_postes.tscn -- /ruta/de/salida [1280x720] [stars=0,3] [levels=1,2,...]
# Usa un guardado temporal (`user://capture_t475.json`) que borra al terminar: no toca el guardado real.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_t475.json"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var out: String = "user://capturas"
	var resolution := Vector2i(1280, 720)
	var star_list: Array[int] = [0, 3]
	var level_list: Array[int] = []
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("stars="):
			star_list.clear()
			for part: String in arg.substr(6).split(","):
				star_list.append(int(part))
		elif arg.begins_with("levels="):
			for part: String in arg.substr(7).split(","):
				level_list.append(int(part))
		elif arg.contains("x") and arg.split("x").size() == 2 and arg.split("x")[0].is_valid_int():
			var parts: PackedStringArray = arg.split("x")
			resolution = Vector2i(int(parts[0]), int(parts[1]))
		else:
			out = arg
	DirAccess.make_dir_recursive_absolute(out)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = resolution
	get_window().position = Vector2i.ZERO
	for _i: int in 10:
		await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var flow: Node = get_node("/root/GameFlow")
	if level_list.is_empty():
		for number: int in flow.level_count():
			level_list.append(number + 1)
	for number: int in level_list:
		for stars: int in star_list:
			if FileAccess.file_exists(TEMP_SAVE):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
			save.save_path = TEMP_SAVE
			save.load_save()
			save.mark_tutorial_done()
			save.set_setting("tutorial_enabled", false)
			var index: int = number - 1
			var data: LevelData = flow.level(index)
			if stars > 0:
				for lives: int in range(data.starting_lives, 0, -1):
					if Rules.stars_for(lives, data.starting_lives, flow.BALANCE) == stars:
						save.record_victory(data.id, lives)
						break
			flow.current_index = index
			flow.intro_pending = false
			var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
			add_child(game)
			for _i: int in 12:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var path: String = "%s/T475-nivel%02d-%dest-%dx%d.png" % [out, number, stars, resolution.x, resolution.y]
			var error: Error = get_viewport().get_texture().get_image().save_png(path)
			assert(error == OK, "no se pudo guardar %s" % path)
			print("Captura: %s (estrellas reales: %d)" % [path, flow.level_stars(index)])
			game.queue_free()
			await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	flow.current_index = -1
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	get_tree().quit()
