# Capturas de la ampliación del alcance (M75, T467): hover en PC y primer toque en interfaz móvil simulada.
# Uso con ventana y salida fuera del repo:
#   godot --path . res://tools/capture_range_preview.tscn -- /ruta/de/salida [1280x720]
extends Node

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_range_preview.json"
var _out: String = "user://capturas"

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	if args.size() > 1:
		var dimensions := args[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		get_window().size = Vector2i(int(dimensions[0]), int(dimensions[1]))
		get_window().position = Vector2i.ZERO
		await _frames(10)
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
		await _capture_mode(mobile)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("T467: capturas guardadas en %s" % _out)
	get_tree().quit()

func _capture_mode(mobile: bool) -> void:
	var game: Game = (load(GAME_PATH) as PackedScene).instantiate() as Game
	add_child(game)
	await _frames(6)
	game.session.earn(100000)
	var tower_data: TowerData
	for data: TowerData in game.tower_types:
		if data.id == "cannon":
			tower_data = data
			break
	var tower: Tower
	var best_cell: Vector2i = Vector2i(-1, -1)
	var map_center: Vector2 = Vector2(game.level.map_size()) / 2.0
	var best_distance: float = INF
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if not game.level.is_buildable(cell) or not game.build_controller.cells_free(tower_data, cell):
				continue
			var distance: float = Vector2(cell).distance_squared_to(map_center)
			if distance < best_distance:
				best_cell = cell
				best_distance = distance
	if best_cell.x >= 0 and game.build_controller.try_build(tower_data, best_cell):
		var footprint: int = tower_data.footprint
		tower = game.build_controller.tower_at(best_cell + Vector2i(footprint - 1, footprint - 1) / 2)
	if tower == null:
		push_error("No se pudo construir el cañón para la captura")
		return
	# Prepara el nivel 2 sin el efecto de mejora para que las capturas muestren solo la ampliación.
	SaveManager.set_setting("upgrade_fx", false)
	game.build_controller.try_upgrade(tower)
	SaveManager.set_setting("upgrade_fx", true)
	game.build_controller.select_placed(tower)
	await _frames(4)
	if mobile:
		game.mobile_hud._on_upgrade_pressed()
		await _frames(2)
		_shot("t467-celular-simulado-primer-toque.png")
	else:
		game.hud.tower_panel.upgrade_button().mouse_entered.emit()
		await _frames(12)
		_shot("t467-pc-hover-mejorar.png")
	game.queue_free()
	await _frames(3)
	get_tree().paused = false
	Engine.time_scale = 1.0

func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame

func _shot(filename: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s" % [_out, filename])
	print("Captura %s: %dx%d" % [filename, image.get_width(), image.get_height()])
