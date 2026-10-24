# Capturas reales del efecto de mejora de torres (M65, T363): abre el nivel 1 en modo PC y en modo celular, construye una
# Tesla en la fila de abajo y otra en el medio, las mejora (nivel 2 y nivel 3) y guarda un PNG a mitad del efecto.
# Se corre con ventana (no `--headless`) y con la carpeta de salida FUERA del repo:
#   godot --path . res://tools/capture_upgrade.tscn -- /ruta/de/salida [1280x720]
# Usa un guardado temporal (`user://capture_upgrade.json`) que borra al terminar: no toca el guardado real.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_upgrade.json"

var _out: String = "user://capturas"
var _game: Node


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	if args.size() > 1:
		var parts: PackedStringArray = args[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		get_window().size = Vector2i(int(parts[0]), int(parts[1]))
		get_window().position = Vector2i.ZERO
		for _i: int in 10:
			await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var flow: Node = get_node("/root/GameFlow")
	save.save_path = TEMP_SAVE
	save.load_save()
	for mobile: bool in [false, true]:
		save.set_setting("ui_mode", 1 if mobile else 2)
		save.mark_tutorial_done()
		save.set_setting("tutorial_enabled", false)
		flow.current_index = 0
		flow.intro_pending = false
		await _run_mode(mobile)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("listo: capturas en %s" % _out)
	get_tree().quit()


func _run_mode(mobile: bool) -> void:
	var tag: String = "celular" if mobile else "pc"
	_game = (load(GAME_PATH) as PackedScene).instantiate()
	add_child(_game)
	await _frames(6)
	_game.session.earn(5000)
	var build: Node = _game.get("build_controller")
	var tesla: Resource
	for data in _game.tower_types:
		if data.id == &"tesla":
			tesla = data
	if tesla == null:
		tesla = _game.tower_types[0]
	var map_size: Vector2i = _game.level.map_size()
	var spots: Array = []
	for row: int in [map_size.y - 1, map_size.y / 2]:
		for x: int in map_size.x:
			var cell := Vector2i(x, row)
			if _game.level.is_buildable(cell) and build.cells_free(tesla, cell) and build.try_build(tesla, cell):
				spots.append(build.tower_at(cell))
				break
	await _frames(4)
	var index: int = 0
	for tower in spots:
		build.select_placed(tower)
		await _frames(3)
		for level: int in [2, 3]:
			build.try_upgrade(tower)
			await get_tree().create_timer(0.3).timeout
			_shot("%s_%d_torre%d_nivel%d_a_0.3s" % [tag, index, index, level])
			await get_tree().create_timer(0.4).timeout
			_shot("%s_%d_torre%d_nivel%d_a_0.7s" % [tag, index, index, level])
			await get_tree().create_timer(0.6).timeout
		index += 1
	_game.queue_free()
	await _frames(3)
	get_tree().paused = false
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _shot(name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [_out, name])
	print("captura %s (%dx%d)" % [name, image.get_width(), image.get_height()])
