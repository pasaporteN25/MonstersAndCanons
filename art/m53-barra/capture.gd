# T248 · Capturas reales de la barra con pestañas y la flecha (M53), con ventana y clics REALES.
# Se corre con ventana (no sirve --headless) y con un guardado aparte, para no tocar el del jugador:
#   godot --path . --resolution 1280x720 art/m53-barra/capture.tscn -- nivel=10 pruebas=1 pasos="shot:a;tab;shot:b"
#
# `nivel` = número de nivel oficial (1 a 10). `pruebas=1` activa el modo de pruebas y «Habilitar todas las
# colecciones» (RF-436), para tener las 11 torres. `colecciones=technology` completa esa colección en el guardado de la
# captura (con ella el nivel 10 ofrece 10 torres, con el Mecánico). `pasos` = lista separada por «;»:
#   shot:nombre      guarda art/m53-barra/nombre.png (la ventana, tal cual)
#   wait:N           espera N cuadros
#   click:x,y        clic real del mouse en el lienzo base (1280×720)
#   cell:x,y         clic real sobre la casilla (x,y) del mapa
#   btn:nombre       clic real en el centro de un botón: tab1, tab2, buy, cancel, demolish, exit, keep, leave, tower3…
#   key:nombre       tecla real (tab, 0..9, esc, p)
#   gold:N           suma oro; res:N suma recursos
#   tower:i,x,y      construye la torre i en la casilla (x,y)
#   measure          imprime el rectángulo de cada botón de torre y de las pestañas
#   focus:nombre     da el foco del teclado a un ícono de arriba (oro, vidas…)
extends Node

const GAME: PackedScene = preload("res://scenes/game/game.tscn")
const OUT := "res://art/m53-barra/"

var game: Game
var _args: Dictionary = {}


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	for raw: String in OS.get_cmdline_user_args():
		var pair: PackedStringArray = raw.split("=", true, 1)
		_args[pair[0]] = pair[1] if pair.size() > 1 else "1"
	SaveManager.save_path = "user://capture_m53.json"
	SaveManager.load_save()
	_set_testing(false)
	for collection: String in String(_args.get("colecciones", "")).split(",", false):  # p. ej. colecciones=technology
		for source: String in CollectionDefinitions.sources(StringName(collection)):
			SaveManager.collect_source(StringName(collection), StringName(source))
	var number: int = int(_args.get("nivel", "6"))
	var loaded: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % number)
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [loaded["level"]] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	if _args.get("pruebas", "0") == "1":
		_set_testing(true)
	game = GAME.instantiate()
	add_child(game)
	Input.warp_mouse(Vector2(600, 400))  # el puntero real del escritorio, lejos de los botones (si no, uno sale «hover»)
	await get_tree().process_frame
	await get_tree().process_frame
	if _args.get("pruebas", "0") == "1":
		game.dev_enable_collections(true)
	for step: String in String(_args.get("pasos", "shot:captura")).split(";"):
		await _step(step.strip_edges())
	_set_testing(false)  # sin modo de pruebas no se escribe el informe al salir
	for file: String in ["user://capture_m53.json", "user://capture_m53_dev.json", "user://capture_m53_dev_stats.json"]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)
	get_tree().quit()


## El modo de pruebas de verdad (con sus atajos en el InputMap), pero con un guardado aparte.
func _set_testing(on: bool) -> void:
	DevMode.set_enabled(on, "user://capture_m53_dev.json" if on else "user://capture_m53.json")


func _step(step: String) -> void:
	var parts: PackedStringArray = step.split(":", true, 1)
	var arg: String = parts[1] if parts.size() > 1 else ""
	match parts[0]:
		"shot":
			await _shot(arg)
		"wait":
			for i: int in int(arg):
				await get_tree().process_frame
		"click":
			var xy: PackedStringArray = arg.split(",")
			await _click(Vector2(float(xy[0]), float(xy[1])))
		"cell":
			var xy: PackedStringArray = arg.split(",")
			var target: Vector2 = _cell_pos(Vector2i(int(xy[0]), int(xy[1])))
			await _click(target)
			print("clic en la casilla ", arg, " → ", target, "; elegido: ", game.infrastructure.selected_cell(), "; mouse del juego: ", game.get_global_mouse_position(), "; ventana: ", get_window().size)
		"btn":
			await _click(_button(arg).get_global_rect().get_center())
		"key":
			await _key(arg)
		"gold":
			game.session.earn(int(arg))
		"res":
			game.session.add_resources(int(arg))
		"tower":
			var xyz: PackedStringArray = arg.split(",")
			game.build_controller.try_build(game.available_towers[int(xyz[0])], Vector2i(int(xyz[1]), int(xyz[2])))
		"measure":
			_measure()
		"focus":
			var icon: Control = game.hud.get_node("TopBar/Stats/%sStat/%sIcon" % [arg.capitalize(), arg.capitalize()])
			icon.grab_focus()
			print("foco en ", game.get_viewport().gui_get_focus_owner())
	await get_tree().process_frame
	await get_tree().process_frame


func _button(name: String) -> Button:
	var hud: Hud = game.hud
	match name:
		"tab1":
			return hud.bar_tabs.button_of(&"cannons")
		"tab2":
			return hud.bar_tabs.button_of(&"infrastructure")
		"buy":
			return hud.infrastructure_tab._buy_button
		"cancel":
			return hud.infrastructure_tab._cancel_button
		"demolish":
			return hud.obstacle_panel._button
		"exit":
			return hud._exit_button
		"keep":
			return game.exit_dialog._keep_button
		"leave":
			return game.exit_dialog._leave_button
	return hud._tower_buttons[int(name.trim_prefix("tower")) - 1]


func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT + file_name + ".png")
	print("guardada ", file_name)


func _cell_pos(cell: Vector2i) -> Vector2:
	return game.get_viewport().get_canvas_transform() * game.level.cell_center(cell)


func _click(pos: Vector2) -> void:
	var window_pos: Vector2 = get_viewport().get_final_transform() * pos
	Input.warp_mouse(window_pos)  # el puntero real del escritorio, para que sus eventos coincidan con los falsos
	await get_tree().process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = window_pos
	motion.global_position = window_pos
	Input.parse_input_event(motion)
	await get_tree().process_frame
	await get_tree().process_frame
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = window_pos
		click.global_position = window_pos
		Input.parse_input_event(click)
		await get_tree().process_frame


func _key(name: String) -> void:
	var code: int = KEY_TAB if name == "tab" else KEY_ESCAPE if name == "esc" else KEY_P if name == "p" else KEY_0 + int(name)
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await get_tree().process_frame


func _measure() -> void:
	if game.hud.bar_tabs != null:
		var tab: Button = game.hud.bar_tabs.button_of(&"infrastructure")
		var font: Font = tab.get_theme_font("font")
		for size: int in [11, 12, 13, 14]:
			print("«Infraestructura» a %d pt: %s px (la pestaña mide %s)" % [size, font.get_string_size("Infraestructura", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x, tab.size.x])
	print("flecha: ", game.hud._exit_button.get_global_rect(), "  contadores: ", game.hud.get_node("TopBar/Stats").get_global_rect(), "  pausa: ", game.hud._pause_button.get_global_rect())
	var buttons: Array[Button] = game.hud._tower_buttons
	for i: int in buttons.size():
		print("botón %d: %s" % [i + 1, buttons[i].get_global_rect()])
	if game.hud.bar_tabs != null:
		for id: StringName in game.hud.bar_tabs.ids():
			print("pestaña %s: %s" % [id, game.hud.bar_tabs.button_of(id).get_global_rect()])
