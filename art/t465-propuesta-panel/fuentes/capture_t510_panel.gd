# T510: captura y mide el panel de torre ACTUAL (PC) y la barra de la torre elegida del celular simulado,
# para la propuesta de rediseño de T465. No cambia nada del juego: arma una partida en memoria, con un guardado
# temporal (`user://capture_t510_panel.json`) que borra al terminar.
# Se corre con ventana (no `--headless`), desde la carpeta del proyecto y con la salida FUERA del repo:
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t510_panel.gd -- /ruta/de/salida pc fullscreen
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t510_panel.gd -- /ruta/de/salida pc 1280x720
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t510_panel.gd -- /ruta/de/salida celular 1280x720
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t510_panel.gd -- /ruta/de/salida celular 1600x720
# Escribe recortes PNG del panel (tamaño real de pantalla, sin achicar), una captura entera por resolución y un
# `medidas-<modo>-<WxH>.tsv` con el alto de cada bloque en píxeles lógicos (1280 × 720) y de pantalla.
extends SceneTree

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_t510_panel.json"

## [id, nivel, con oro]. «sin oro» deja el oro por debajo del costo de la mejora para ver «Mejorar» apagado.
const PC_CASES: Array = [
	["cannon", 1, true], ["cannon", 2, true], ["cannon", 3, true],
	["tesla", 1, true], ["tesla", 2, true],
	["frost", 1, true], ["frost", 2, true], ["frost", 3, true],
	["disruptor", 1, true], ["fire", 1, true], ["mortar", 2, true],
	["basic", 1, false], ["mechanical_standard", 1, true],
]
const MOBILE_CASES: Array = [
	["cannon", 1, true], ["tesla", 1, true], ["frost", 1, true], ["frost", 3, true],
	["disruptor", 1, true], ["basic", 1, false],
]

var _out: String = "user://capturas"
var _tsv: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else _out
	var mode: String = args[1] if args.size() > 1 else "pc"
	var size_arg: String = args[2] if args.size() > 2 else "fullscreen"
	DirAccess.make_dir_recursive_absolute(_out)
	if size_arg == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		var parts: PackedStringArray = size_arg.split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		root.size = Vector2i(int(parts[0]), int(parts[1]))
		root.position = Vector2i.ZERO
	await _frames(15)
	var save: Node = root.get_node("/root/SaveManager")
	var flow: Node = root.get_node("/root/GameFlow")
	save.save_path = TEMP_SAVE
	save.load_save()
	save.set_setting("ui_mode", 1 if mode == "celular" else 2)
	save.mark_tutorial_done()
	save.set_setting("tutorial_enabled", false)
	save.set_setting("upgrade_fx", false)
	flow.current_index = 0
	flow.intro_pending = false
	var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
	root.add_child(game)
	await _frames(8)
	if game.level_intro.is_open():
		game.level_intro.close()
	var suffix: String = "%dx%d" % [root.size.x, root.size.y]
	print("T510: modo %s · ventana %s · escala %s" % [mode, suffix, root.get_final_transform().get_scale()])
	_tsv.append("caso\tbloque\ty_logico\talto_logico\tancho_logico\talto_pantalla\tnota")
	var cases: Array = MOBILE_CASES if mode == "celular" else PC_CASES
	for case: Array in cases:
		await _case(game, mode, String(case[0]), int(case[1]), bool(case[2]), suffix)
	if mode == "celular":
		await _armed_case(game, suffix)
	var file := FileAccess.open("%s/medidas-%s-%s.tsv" % [_out, mode, suffix], FileAccess.WRITE)
	file.store_string("\n".join(_tsv) + "\n")
	file.close()
	game.queue_free()
	await _frames(3)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("T510: listo · %s" % _out)
	quit(0)


func _case(game: Node, mode: String, id: String, level: int, with_gold: bool, suffix: String) -> void:
	game.session.gold = 1000000
	var tower: Node = _build(game, id)
	if tower == null:
		print("T510: no se pudo construir %s (se omite)" % id)
		return
	while tower.level_number() < level:
		if not game.build_controller.try_upgrade(tower):
			break
	if not with_gold and tower.can_upgrade():
		game.session.gold = maxi(0, tower.next_level_stats().cost - 25)
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	await _frames(5)
	var name: String = "%s-n%d%s" % [id, level, "" if with_gold else "-sin-oro"]
	if mode == "celular":
		_measure_mobile(game, name)
		_shot_rect(_mobile_bar_rect(game), "T510-actual-celular-%s-%s.png" % [name, suffix])
		if id == "frost" and level == 1:
			_shot_full("T510-actual-celular-pantalla-%s-%s.png" % [name, suffix])
	else:
		var panel: Control = game.hud.tower_panel
		_measure_pc(panel, name)
		_shot_rect(_screen_rect(panel).grow(6), "T510-actual-pc-%s-%s.png" % [name, suffix])
		if (id == "tesla" and level == 1) or (id == "frost" and level == 3):
			_shot_full("T510-actual-pc-pantalla-%s-%s.png" % [name, suffix])
		if id == "tesla" and level == 1:
			panel.hide()  # fondo para poner encima las maquetas, con la Eléctrica elegida y sin panel
			await _frames(3)
			_shot_full("T510-fondo-pc-sin-panel-%s.png" % suffix)
			panel.show()
	game.build_controller.deselect_placed()
	await _frames(2)


## RF-681: el primer toque en «Mejorar» del celular deja el botón armado (pide confirmar).
func _armed_case(game: Node, suffix: String) -> void:
	game.session.gold = 1000000
	var tower: Node = _build(game, "cannon")
	if tower == null:
		return
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	await _frames(3)
	game.mobile_hud._on_upgrade_pressed()
	await _frames(40)
	_measure_mobile(game, "cannon-n1-armado")
	_shot_rect(_mobile_bar_rect(game), "T510-actual-celular-cannon-n1-armado-%s.png" % suffix)
	_shot_full("T510-actual-celular-pantalla-cannon-n1-armado-%s.png" % suffix)


func _build(game: Node, id: String) -> Node:
	var data: Resource = load("res://data/towers/%s.tres" % id)
	game.session.add_resources(100000)
	if not game.build_controller._tower_types.has(data):
		game.build_controller._tower_types.append(data)
	var center: Vector2 = Vector2(game.level.map_size()) / 2.0
	var cells: Array[Vector2i] = []
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			cells.append(Vector2i(x, y))
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).distance_squared_to(center) < Vector2(b).distance_squared_to(center))
	for cell: Vector2i in cells:
		if game.level.is_buildable(cell) and game.build_controller.cells_free(data, cell) \
				and game.build_controller.try_build(data, cell):
			return game.build_controller.tower_at(cell)
	return null


## Alto de cada bloque visible del panel de PC, en px lógicos y de pantalla, y si la lista de efectos necesita scroll.
func _measure_pc(panel: Control, name: String) -> void:
	var scale: float = root.get_final_transform().get_scale().y
	var rows: Control = panel.get_node("Margin/Rows")
	_tsv.append("%s\tPANEL\t%.0f\t%.0f\t%.0f\t%.0f\t" % [name, panel.global_position.y, panel.size.y, panel.size.x, panel.size.y * scale])
	for child: Node in rows.get_children():
		var control: Control = child as Control
		if control == null or not control.visible:
			continue
		var note: String = ""
		if control is Label:
			note = (control as Label).text.replace("\n", " ⏎ ")
		elif control is Button:
			note = (control as Button).text + (" (apagado)" if (control as Button).disabled else "")
		elif control is ScrollContainer:
			var content: Control = control.get_child(0) as Control
			var needed: float = content.get_combined_minimum_size().y
			var lines: PackedStringArray = []
			for inner: Node in content.get_children():
				if inner is Label and (inner as Label).visible:
					lines.append((inner as Label).text.replace("\n", " ⏎ "))
			note = "contenido %.0f px · %s · %s" % [needed, "NECESITA SCROLL" if needed > control.size.y + 0.5 else "entra (sobra %.0f px)" % (control.size.y - needed), " | ".join(lines)]
		elif control.name == "TitleRow":
			note = (control.get_node("Title") as Label).text
		elif control.name == "Metrics":
			note = "%s | %s | %s" % [(control.get_node("Damage") as Label).text, (control.get_node("Rate") as Label).text, (control.get_node("Range") as Label).text]
		_tsv.append("%s\t%s\t%.0f\t%.0f\t%.0f\t%.0f\t%s" % [name, control.name, control.global_position.y - panel.global_position.y,
			control.size.y, control.size.x, control.size.y * scale, note])
	print("T510 pc · %s · panel %.0f × %.0f px lógicos" % [name, panel.size.x, panel.size.y])


func _measure_mobile(game: Node, name: String) -> void:
	var hud: Node = game.mobile_hud
	var label: Label = hud._status_label
	var scale: float = root.get_final_transform().get_scale().y
	var font: Font = label.get_theme_font("font")
	var font_size: int = label.get_theme_font_size("font_size")
	var widest: float = 0.0
	for line: String in label.text.split("\n"):
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
	var overflow: bool = label.get_line_count() > label.get_visible_line_count() or label.get_combined_minimum_size().y > label.size.y + 0.5
	_tsv.append("%s\tStatusText\t%.0f\t%.0f\t%.0f\t%.0f\trenglones %d (visibles %d) · renglón más ancho sin cortar %.0f px · %s · %s" % [name,
		label.global_position.y, label.size.y, label.size.x, label.size.y * scale, label.get_line_count(),
		label.get_visible_line_count(), widest, "SE CORTA/DESBORDA" if overflow else "entra", label.text.replace("\n", " ⏎ ")])
	for button: Button in [hud._bottom_cancel, hud._target_button, hud._upgrade_button, hud._sell_button]:
		if button.visible:
			_tsv.append("%s\t%s\t%.0f\t%.0f\t%.0f\t%.0f\t%s" % [name, button.name, button.global_position.y, button.size.y,
				button.size.x, button.size.y * scale, button.text.replace("\n", " ⏎ ") + (" (apagado)" if button.disabled else "")])
	print("T510 celular · %s · texto %.0f × %.0f px, %d renglones" % [name, label.size.x, label.size.y, label.get_line_count()])


func _mobile_bar_rect(game: Node) -> Rect2:
	var bar: Control = game.mobile_hud._status_bar
	var rect: Rect2 = _screen_rect(bar)
	return Rect2(rect.position - Vector2(0, 40), rect.size + Vector2(0, 40))


func _screen_rect(control: Control) -> Rect2:
	return root.get_final_transform() * (control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, control.size))


func _shot_rect(rect: Rect2, file_name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var clipped: Rect2i = Rect2i(rect).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	image.get_region(clipped).save_png("%s/%s" % [_out, file_name])


func _shot_full(file_name: String) -> void:
	root.get_texture().get_image().save_png("%s/%s" % [_out, file_name])


func _frames(count: int) -> void:
	for _i: int in count:
		await process_frame
