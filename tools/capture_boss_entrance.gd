# Capturas reales de la entrada del Jefe en el nivel 1 (M66, T368): en modo PC y en modo celular, el destello al
# nacer el Jefe, el cartel de oleada, el cartel de aparición ya quieto y la tarjeta «Nuevo enemigo» que sale
# después. Se corre con ventana (no `--headless`: sin dibujo no hay imagen) y con la carpeta de salida FUERA del
# repo:
#   godot --path . res://tools/capture_boss_entrance.tscn -- /ruta/de/salida [1280x720]
# Usa un guardado temporal (`user://capture_boss_entrance.json`) que borra al terminar: no toca el guardado real.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_boss_entrance.json"

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
	var save: Node = get_node("/root/SaveManager")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.load_save()  # un guardado vacío: el Jefe es «nuevo» y la tarjeta tiene que esperar
	save.set_setting("ui_mode", 1 if mobile else 2)
	save.set_setting("tutorial_enabled", false)
	_game = (load(GAME_PATH) as PackedScene).instantiate()
	add_child(_game)
	await _frames(8)
	_game.session.begin_wave()  # el cartel de «Oleada N»
	_game.spawner.spawn_now(load("res://data/enemies/boss.tres"))
	await get_tree().create_timer(0.2).timeout
	_shot("%s_1_destello_y_cartel_de_oleada" % tag)
	await get_tree().create_timer(1.9).timeout
	_shot("%s_2_cartel_de_aparicion" % tag)
	await get_tree().create_timer(1.3).timeout
	_shot("%s_3_tarjeta_nuevo_enemigo" % tag)
	_game.queue_free()
	await _frames(3)
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_node("/root/GameFlow").intro_pending = false


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _shot(name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [_out, name])
	print("captura %s (%dx%d)" % [name, image.get_width(), image.get_height()])
