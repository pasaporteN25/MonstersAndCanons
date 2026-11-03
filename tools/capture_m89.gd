# Capturas reales de M89 (T579): celular simulado (ui_mode celular) en el host real, con rieles. Se corre con ventana:
#   godot --path . res://tools/capture_m89.tscn -- /ruta/de/salida 1280x720 [escenarios,separados,por,coma]
# Escenarios: marca, zoom, rieles, jefe, tutorial. Usa un guardado temporal que borra al terminar.
extends Node

const HOST: PackedScene = preload("res://scenes/host/presentation_host.tscn")
const TEMP_SAVE: String = "user://capture_m89.json"

var _out: String = "user://capturas"
var _tag: String = ""
var _host: Node


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	var parts: PackedStringArray = args[1].split("x")
	_tag = args[1]
	var wanted: PackedStringArray = (args[2] if args.size() > 2 else "marca,zoom,rieles,jefe,tutorial").split(",")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().size = Vector2i(int(parts[0]), int(parts[1]))
	get_window().position = Vector2i.ZERO
	await _frames(10)
	var save: Node = get_node("/root/SaveManager")
	save.save_path = TEMP_SAVE
	save.load_save()
	save.set_setting("ui_mode", 1)
	_host = HOST.instantiate()
	add_child(_host)
	await _frames(10)
	for scenario: String in wanted:
		match scenario:
			"marca", "zoom", "rieles":
				save.mark_tutorial_done()
				await _start_level()
				await call("_s_" + scenario)
			"jefe":
				save.mark_tutorial_done()
				await _start_level()
				await _s_jefe()
			"cuad":
				save.mark_tutorial_done()
				save.set_setting("map_grid", true)
				await _start_level()
				_game().build_controller.try_build(_game().available_towers[0], _cell(_game(), 0))
				await _frames(4)
				_shot("T565-cuadricula-zoom-minimo")
				for _i: int in 8:
					_game().camera_controller.zoom_in_step()
				await _frames(8)
				_shot("T565-cuadricula-zoom-maximo")
				save.set_setting("map_grid", false)
			"niveles":
				save.mark_tutorial_done()
				for idx: int in [2, 5, 8, 11, 14]:
					save.unlock(get_node("/root/GameFlow").level(idx).id)
					await _start_level(idx)
					for _i: int in 8:
						_game().camera_controller.zoom_in_step()
					await _frames(8)
					_shot("T568-zoom-maximo-nivel%02d" % (idx + 1))
			"tutorial":
				save.reset_tutorial()
				await _start_level()
				await _s_tutorial()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("listo: capturas en %s" % _out)
	get_tree().quit()


func _start_level(index: int = 0) -> void:
	var flow: Node = get_node("/root/GameFlow")
	get_tree().paused = false
	Engine.time_scale = 1.0
	flow.start_level(index)
	var tries: int = 0
	while tries < 200 and (_game() == null or _game().get("level_intro") == null or flow.is_changing()):
		tries += 1
		await _frames(2)
	await _frames(20)
	var g: Node = _game()
	if g.level_intro.is_open():
		g.level_intro.close()
	await _frames(20)


func _game() -> Node:
	return get_node("/root/GameFlow").current_screen()


func _first_cell() -> Vector2i:
	var g: Node = _game()
	return g.level.get_buildable_cells()[3] if g.level.has_method("get_buildable_cells") else Vector2i(5, 4)


func _s_marca() -> void:
	var g: Node = _game()
	g.build_controller.try_build(g.available_towers[0], _cell(g, 0))
	g.build_controller.try_build(g.available_towers[0], _cell(g, 1))
	await _frames(6)
	g.build_controller.select_placed(g.tower_container.get_child(0))
	await _frames(8)
	_shot("T564-marca-torre-elegida")


func _cell(g: Node, i: int) -> Vector2i:
	var cells: Array = []
	for x: int in g.level.map_size().x:
		for y: int in g.level.map_size().y:
			var c := Vector2i(x, y)
			if g.level.is_buildable(c):
				cells.append(c)
	return cells[(i * 7 + 3) % cells.size()]


func _s_zoom() -> void:
	var g: Node = _game()
	g.build_controller.try_build(g.available_towers[0], _cell(g, 0))
	await _frames(4)
	_shot("T568-zoom-1-0-sin-acercar")
	for _i: int in 6:
		g.camera_controller.zoom_in_step()
	await _frames(8)
	_shot("T568-zoom-maximo")
	g.camera_controller.pan_with_one_finger(Vector2(-300, -80))
	await _frames(8)
	_shot("T568-zoom-maximo-desplazado")


func _s_rieles() -> void:
	var g: Node = _game()
	g.build_controller.try_build(g.available_towers[0], _cell(g, 0))
	g.build_controller.try_build(g.available_towers[0], _cell(g, 1))
	await _frames(6)
	_shot("T570-rieles-inicio")
	g.build_controller.select_placed(g.tower_container.get_child(0))
	await _frames(8)
	_shot("T570-rieles-torre-elegida")
	g.build_controller.cancel()
	g.mobile_hud.target_control(&"cart").pressed.emit()
	await _frames(8)
	_shot("T570-rieles-carrito")
	await _frames(20)
	_shot("T570-rieles-carrito-abierto")
	var card: Control = g.mobile_hud.target_control(&"first_card")
	if card != null:
		card.pressed.emit()
	await _frames(8)
	_shot("T570-rieles-fantasma")


func _s_jefe() -> void:
	var g: Node = _game()
	var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
	enemy.data = load("res://data/enemies/boss.tres")
	g._maybe_boss_presentation(enemy)
	await _frames(30)
	_shot("T571-jefe-presentacion-inicio")
	await get_tree().create_timer(1.5).timeout
	_shot("T571-jefe-presentacion-medio")
	if g.presentation != null:
		g.presentation.skip(false)
	await _frames(20)
	_shot("T571-jefe-cierre-partida")
	enemy.free()


func _s_tutorial() -> void:
	var g: Node = _game()
	var controller: Node = g.get("tutorial")
	if controller == null:
		print("sin tutorial")
		return
	var index: int = 0
	var safety: int = 0
	while controller.is_active() and safety < 40:
		safety += 1
		var id: String = controller.flow.current_id()
		await _frames(6)
		_shot("T574-tutorial-%02d-%s" % [index, id])
		index += 1
		await _do(id, controller)


func _do(id: String, controller: Node) -> void:
	var g: Node = _game()
	var hud: Node = g.get("hud")
	var build: Node = g.get("build_controller")
	var mh: Node = g.get("mobile_hud")
	match id:
		"pick_tower":
			hud.target_control(&"tower_1").pressed.emit()
		"place_tower":
			build.try_build(g.available_towers[0], controller.suggested_cell())
		"open_cart":
			mh.target_control(&"cart").pressed.emit()
		"pick_card":
			mh.target_control(&"first_card").pressed.emit()
		"confirm_tower":
			mh.target_control(&"confirm").pressed.emit()
		"start_wave":
			hud.target_control(&"start_wave").pressed.emit()
		"select_tower":
			build.cancel()
			build.select_placed(g.tower_container.get_child(0))
		"speed":
			hud.target_control(&"speed").pressed.emit()
		"pause", "resume":
			hud.target_control(&"pause").pressed.emit()
		_:
			controller.overlay.next_button().pressed.emit()
	await _frames(4)


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _shot(shot_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var path: String = "%s/%s-%s.png" % [_out, shot_name, _tag]
	image.save_png(path)
	print("captura %s (%dx%d)" % [path, image.get_width(), image.get_height()])
