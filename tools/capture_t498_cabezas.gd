# T498 (RF-714): capturas reales del niveles 10 a 12 (desierto) con la decoración vigente, con enemigos puestos sobre el camino
# (Normal, Rápido, Troll, Blindado, Araña, Ladrón, Guardián y Embestidor, para ver si las cabezas se confunden con alguno). No es una oleada real: los enemigos se colocan con
# `WaveSpawner._spawn_enemy` a distintas distancias de cada entrada. Se corre con ventana y salida FUERA del repo:
#   godot --path . res://tools/capture_t498_cabezas.tscn -- /ruta/de/salida prefijo 1280x720 nivel [mobile] [sin_enemigos]
# Usa un guardado temporal (`user://capture_t498.json`) y no toca el guardado real.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_t498.json"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0]
	var prefix: String = args[1]
	var parts: PackedStringArray = args[2].split("x")
	var resolution := Vector2i(int(parts[0]), int(parts[1]))
	var level_index: int = int(args[3])
	var mobile: bool = args.has("mobile")
	var with_enemies: bool = not args.has("sin_enemigos")
	DirAccess.make_dir_recursive_absolute(out)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = resolution
	get_window().position = Vector2i.ZERO
	for _i: int in 10:
		await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var flow: Node = get_node("/root/GameFlow")
	save.save_path = TEMP_SAVE
	save.load_save()
	save.mark_tutorial_done()
	save.set_setting("tutorial_enabled", false)
	save.set_setting("ui_mode", 1 if mobile else 2)
	flow.current_index = level_index - 1
	flow.intro_pending = false
	var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
	add_child(game)
	for _i: int in 12:
		await get_tree().process_frame
	if with_enemies:
		var spawner: WaveSpawner = game.get("spawner")
		var level: Level = game.get("level")
		var ids: Array[String] = ["normal", "fast", "troll", "armored", "spider", "thief", "guardian", "rammer"]
		for entrance: int in 2:
			var path: Path2D = level.get_ground_path(entrance)
			if path == null:
				continue
			var length: float = path.curve.get_baked_length()
			for i: int in ids.size():
				var data: EnemyData = load("res://data/enemies/%s.tres" % ids[i])
				spawner._spawn_enemy(data, path, length * (0.10 + 0.09 * i + 0.04 * entrance))
		for _i: int in 6:
			await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var file_path: String = "%s/%s.png" % [out, prefix]
	var error: Error = get_viewport().get_texture().get_image().save_png(file_path)
	assert(error == OK, "no se pudo guardar %s" % file_path)
	print("Captura: %s (%s)" % [file_path, "celular simulado" if mobile else "PC"])
	game.queue_free()
	await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	flow.current_index = -1
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	get_tree().quit()
