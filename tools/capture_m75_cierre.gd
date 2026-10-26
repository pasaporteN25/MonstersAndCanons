# Verificación de cierre de M75 (T465 y T467) en una ventana real de la PC, sin tocar el guardado del jugador.
# - T465 (RF-677, RF-686): captura a 1920 × 1080 del panel de torre con Cañón, Tesla, Hielo y Disruptora en los
#   niveles 1, 2 y 3, y medición del ancho de cada línea del panel contra su columna y contra los 270 px.
# - T467 (RF-680): «Mejorar» con el mouse encima usando un movimiento de mouse real que entra por el viewport
#   (`push_input`), no la señal emitida a mano; al sacar el mouse la ampliación tiene que irse.
# Se corre con ventana (no `--headless`) y con la carpeta de salida FUERA del repo:
#   DISPLAY=:0 godot --path . -s res://tools/capture_m75_cierre.gd -- /ruta/de/salida [fullscreen|1280x720]
# Usa un guardado temporal (`user://capture_m75_cierre.json`) que borra al terminar.
extends SceneTree

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_m75_cierre.json"
const TOWER_IDS: Array[String] = ["cannon", "tesla", "frost", "disruptor"]
const PANEL_WIDTH: float = 270.0

var _out: String = "user://capturas"
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	var size_arg: String = args[1] if args.size() > 1 else "fullscreen"
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
	save.set_setting("ui_mode", 2)  # PC
	save.mark_tutorial_done()
	save.set_setting("tutorial_enabled", false)
	save.set_setting("upgrade_fx", false)  # que la captura muestre el panel, no el efecto
	flow.current_index = 0
	flow.intro_pending = false
	var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
	root.add_child(game)
	await _frames(8)
	if game.level_intro.is_open():
		game.level_intro.close()
	game.session.earn(1000000)
	var suffix: String = "%dx%d" % [root.size.x, root.size.y]
	print("M75: ventana %s" % suffix)
	for id: String in TOWER_IDS:
		var tower: Node = _build(game, id)
		if tower == null:
			push_error("No se pudo construir %s" % id)
			_failures += 1
			continue
		for level_number: int in [1, 2, 3]:
			while tower.level_number() < level_number:
				game.build_controller.try_upgrade(tower)
			game.build_controller.select_placed(tower)
			await _frames(4)
			_measure(game.hud.tower_panel, "%s nivel %d" % [id, level_number])
			_shot("T465-panel-%s-n%d-%s.png" % [id, level_number, suffix])
		game.build_controller.deselect_placed()
		await _frames(2)
	save.set_setting("upgrade_fx", true)
	await _check_real_hover(game, suffix)
	game.queue_free()
	await _frames(3)
	await _range_sheets(save, flow, suffix)
	await _check_mobile_view_all(save, flow, suffix)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("M75: fallas=%d · capturas en %s" % [_failures, _out])
	quit(1 if _failures > 0 else 0)


## Construye `id` en la casilla libre más cercana al centro del mapa (cargado directo del recurso).
func _build(game: Node, id: String) -> Node:
	var data: Resource = load("res://data/towers/%s.tres" % id)
	game.session.add_resources(100000)  # la Disruptora se paga también con recursos
	if not game.build_controller._tower_types.has(data):
		game.build_controller._tower_types.append(data)  # solo para la captura: la Disruptora pide su colección
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


## Mide cada renglón de cada texto visible del panel con su propia fuente. Un texto sin ajuste de línea que no entra
## en su columna, o un panel de más de 270 px, cuenta como falla.
func _measure(panel: Control, label_text: String) -> void:
	var widest: float = 0.0
	var widest_text: String = ""
	var problems: PackedStringArray = []
	for node: Node in panel.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree():
			continue
		var text: String = ""
		var wraps: bool = false
		if control is Label:
			text = (control as Label).text
			wraps = (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
		elif control is Button:
			text = (control as Button).text
		else:
			continue
		var font: Font = control.get_theme_font("font")
		var font_size: int = control.get_theme_font_size("font_size")
		for line: String in text.split("\n"):
			if line.is_empty():
				continue
			var width: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			if width > widest:
				widest = width
				widest_text = line
			if not wraps and width > control.size.x + 0.5:
				problems.append("«%s» %.1f > %.1f px (%s)" % [line, width, control.size.x, control.name])
	if panel.size.x > PANEL_WIDTH + 0.5:
		problems.append("panel de %.1f px" % panel.size.x)
	print("T465 ancho · %s · panel %.0f px · renglón más ancho %.1f px: «%s» · %s" % [label_text, panel.size.x,
		widest, widest_text, "OK" if problems.is_empty() else "NO ENTRA: " + "; ".join(problems)])
	if not problems.is_empty():
		_failures += 1


## RF-680 con un movimiento de mouse que entra por el viewport, como uno real.
func _check_real_hover(game: Node, suffix: String) -> void:
	var tower: Node = _build(game, "cannon")
	game.build_controller.try_upgrade(tower)  # nivel 2: el alcance pasa de 3 a 3,5 casillas
	game.build_controller.select_placed(tower)
	await _frames(4)
	var button: Button = game.hud.tower_panel.upgrade_button()
	var inside: Vector2 = button.get_global_rect().get_center()
	_move_mouse(inside + Vector2(1, 0))
	_move_mouse(inside)
	await _frames(40)  # la ampliación crece en 0,5 s
	var preview: Node = game.effects.range_preview()
	var shown: bool = preview != null
	print("T467 hover real · mouse sobre «Mejorar» (%s) → ampliación %s" % [inside, "visible" if shown else "NO aparece"])
	if not shown:
		_failures += 1
	_shot("T467-pc-hover-real-%s.png" % suffix)
	_move_mouse(Vector2(inside.x - 400.0, 300.0))
	await _frames(4)
	var gone: bool = game.effects.range_preview() == null
	print("T467 hover real · mouse fuera → ampliación %s" % ["se fue" if gone else "SIGUE"])
	if not gone:
		_failures += 1
	print("T467 hover real · nivel después de mirar: %d (tiene que seguir en 2)" % tower.level_number())
	if tower.level_number() != 2:
		_failures += 1


## T466 (RF-678, RF-686): el círculo Sutil y el Completo de una torre elegida sobre el fondo de cada uno de los 15
## mapas, recortado a tamaño real (sin achicar) para poder juzgar si se lee. Arma una hoja por estilo.
func _range_sheets(save: Node, flow: Node, suffix: String) -> void:
	var crops: Dictionary = {1: [], 2: []}
	var crop_side: int = 0
	for index: int in 15:
		save.set_setting("range_display", 0)
		flow.current_index = index
		var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
		game.level_data = flow.level(index)
		root.add_child(game)
		await _frames(8)
		if game.level_intro.is_open():
			game.level_intro.close()
		game.session.earn(1000000)
		var tower: Node = _build(game, "basic")
		if tower == null:
			push_error("Nivel %d: no se pudo construir la Ametralladora" % (index + 1))
			_failures += 1
			game.queue_free()
			await _frames(3)
			continue
		game.build_controller.select_placed(tower)
		var to_screen: Transform2D = root.get_final_transform() * game.get_viewport().get_canvas_transform()
		var center: Vector2 = to_screen * tower.global_position
		var radius: float = (to_screen * (tower.global_position + Vector2(Rules.tiles_to_px(tower.stats().range_tiles), 0)) - center).x
		crop_side = int(ceil(radius * 2.0 + 40.0))
		for style: int in [1, 2]:
			save.set_setting("range_display", style)
			await _frames(3)
			var image: Image = root.get_texture().get_image()
			var rect := Rect2i(Vector2i(center) - Vector2i.ONE * (crop_side / 2), Vector2i.ONE * crop_side)
			var crop := Image.create(crop_side, crop_side, false, image.get_format())
			crop.fill(Color.BLACK)
			var clipped: Rect2i = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
			crop.blit_rect(image, clipped, clipped.position - rect.position)
			crops[style].append(crop)
		print("T466 nivel %d: Ametralladora en %s, radio %.0f px en pantalla" % [index + 1, center, radius])
		game.queue_free()
		await _frames(3)
	save.set_setting("range_display", 0)
	for style: int in [1, 2]:
		var images: Array = crops[style]
		if images.is_empty():
			continue
		var side: int = (images[0] as Image).get_width()
		var sheet := Image.create(side * 5 + 4 * 6, side * 3 + 2 * 6, false, (images[0] as Image).get_format())
		sheet.fill(Color(0.1, 0.1, 0.12))
		for i: int in images.size():
			var tile: Image = images[i]
			tile.resize(side, side)
			sheet.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i((i % 5) * (side + 6), (i / 5) * (side + 6)))
		var name: String = "T466-alcance-%s-15-niveles-recorte-%s.png" % ["sutil" if style == 1 else "completo", suffix]
		sheet.save_png("%s/%s" % [_out, name])
		print("Hoja %s: %dx%d (fila 1 = niveles 1-5, fila 2 = 6-10, fila 3 = 11-15)" % [name, sheet.get_width(), sheet.get_height()])


## T464 (RF-675): en la interfaz de celular simulada, el botón «Ver todo» con zoom tiene que quedar dentro de la
## pantalla y sin pisar el carrito, la X ni la demolición en sus lugares por omisión.
func _check_mobile_view_all(save: Node, flow: Node, suffix: String) -> void:
	save.set_setting("ui_mode", 1)
	flow.current_index = 14
	var game: Node = (load(GAME_PATH) as PackedScene).instantiate()
	game.level_data = flow.level(14)
	root.add_child(game)
	await _frames(8)
	if game.level_intro.is_open():
		game.level_intro.close()
	game.camera_controller._zoom_at(Vector2(640, 360), 1.3)
	await _frames(4)
	var hud: Node = game.mobile_hud
	var button: Control = hud._view_all_button
	var rect: Rect2 = button.get_global_rect()
	var screen := Rect2(Vector2.ZERO, Vector2(1280, 720))
	var inside: bool = screen.encloses(rect)
	print("T464 celular · «Ver todo» visible=%s · rect %s · dentro de 1280×720: %s" % [button.visible, rect, inside])
	for other: Control in [hud._cart_button, hud._exit_button, hud._demolish_button]:
		if other != null and other.visible:
			print("T464 celular · pisa %s: %s" % [other.name, rect.intersects(other.get_global_rect())])
	_shot("T464-celular-simulado-ver-todo-%s.png" % suffix)
	game.queue_free()
	await _frames(3)
	save.set_setting("ui_mode", 2)


func _move_mouse(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	root.push_input(motion, true)


func _frames(count: int) -> void:
	for _i: int in count:
		await process_frame


func _shot(filename: String) -> void:
	var image: Image = root.get_texture().get_image()
	image.save_png("%s/%s" % [_out, filename])
	print("Captura %s: %dx%d" % [filename, image.get_width(), image.get_height()])
