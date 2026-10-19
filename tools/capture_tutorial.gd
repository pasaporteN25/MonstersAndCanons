# Capturas reales del tutorial del nivel 1 (M63, T331): abre la partida del nivel 1 en modo PC y en modo celular,
# recorre el tutorial haciendo cada acción y guarda un PNG por paso. Se corre con ventana (no `--headless`: sin
# dibujo no hay imagen) y con la carpeta de salida FUERA del repo:
#   godot --path . res://tools/capture_tutorial.tscn -- /ruta/de/salida [1280x720]
# Usa un guardado temporal (`user://capture_tutorial.json`) que borra al terminar: no toca el guardado real.
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_tutorial.json"

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
		save.reset_tutorial()
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
	var controller: Node = _game.get("tutorial")
	if controller == null:
		print("%s: no hay tutorial" % tag)
		return
	var index: int = 0
	var safety: int = 0
	while controller.is_active() and safety < 40:
		safety += 1
		var id: String = controller.flow.current_id()
		await _frames(4)
		_shot("%s_%02d_%s" % [tag, index, id])
		index += 1
		await _do(id, controller, mobile)
	_game.queue_free()
	await _frames(3)
	var gf: Node = get_node("/root/GameFlow")
	get_tree().paused = false
	Engine.time_scale = 1.0
	gf.intro_pending = false


## Hace lo que el paso pide (los pasos de lectura se pasan con «Siguiente»).
func _do(id: String, controller: Node, mobile: bool) -> void:
	var hud: Node = _game.get("hud")
	var build: Node = _game.get("build_controller")
	var mobile_hud: Node = _game.get("mobile_hud")
	match id:
		"pick_tower":
			hud.target_control(&"tower_1").pressed.emit()
		"place_tower":
			build.try_build(_game.available_towers[0], controller.suggested_cell())
		"open_cart":
			mobile_hud.target_control(&"cart").pressed.emit()
		"pick_card":
			mobile_hud.target_control(&"first_card").pressed.emit()
		"confirm_tower":
			mobile_hud.target_control(&"confirm").pressed.emit()
		"start_wave":
			hud.target_control(&"start_wave").pressed.emit()
		"select_tower":
			build.cancel()
			build.select_placed(_game.tower_container.get_child(0))
		"speed":
			hud.target_control(&"speed").pressed.emit()
		"pause", "resume":
			hud.target_control(&"pause").pressed.emit()
		_:
			controller.overlay.next_button().pressed.emit()
	await _frames(3)


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _shot(name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [_out, name])
	print("captura %s (%dx%d)" % [name, image.get_width(), image.get_height()])
