# T262: sondeo de la experiencia en celular, en ESCRITORIO y con la proporción de un celular. NO es un test: abre una
# ventana, carga las escenas reales (menú, selección de niveles, partida, pausa, Wiki), saca capturas, mide el tamaño
# de cada control que se toca y simula toques (InputEventScreenTouch / InputEventScreenDrag) para ver qué hace el juego
# con ellos. No toca el guardado del jugador: usa `user://mobile_probe.json` y lo borra al terminar (igual conviene
# correrlo con XDG_DATA_HOME apuntando a una carpeta temporal).
#
#   XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1600x720 res://tools/mobile_probe.tscn -- res=1600x720 tag=20x9
#
#   res=WxH      tamaño de la ventana (por omisión 1600x720, 20:9). Se fija también desde el script.
#   tag=texto    sufijo de los archivos (por omisión el tamaño)
#   out=ruta     carpeta de salida (por omisión res://art/t262-mobile/)
#   target=WxH   pantalla del celular a la que se traducen las medidas (por omisión 2400x1080, el 1080 × 2400 acostado)
#   ppi=N        píxeles por pulgada del celular supuesto (por omisión 405: 1080 × 2400 en 6,5")
#   only=lista   partes a correr, separadas por coma: menu,select,game,big,tabs,wiki (por omisión todas)
#
# Imprime líneas «PROBE …» y deja en `out`: capturas PNG y `sizes_<tag>.csv` (control, tamaño virtual, físico y en mm).
# Límite honesto: un toque simulado con Input.parse_input_event pasa por la emulación de mouse de Godot igual que en
# Android, pero no hay dedo (ni su tamaño, ni el temblor, ni la oclusión) ni el gestor de gestos de Android.
extends Node

## Se cargan en tiempo de ejecución, no con preload: la revisión de sintaxis (--check-only -s) compila este script sin
## los autoloads, y estas escenas los usan.
const GAME_SCENE_PATH: String = "res://scenes/game/game.tscn"
const MENU_SCENE_PATH: String = "res://scenes/ui/main_menu.tscn"
const SELECT_SCENE_PATH: String = "res://scenes/ui/level_select.tscn"
const WIKI_SCENE_PATH: String = "res://scenes/ui/wiki_screen.tscn"
const SAVE_PATH: String = "user://mobile_probe.json"
## Material Design pide 48 dp como mínimo para algo que se toca: 48/160 de pulgada = 7,6 mm.
const MIN_TOUCH_MM: float = 7.6
const LOGICAL := Vector2(1280.0, 720.0)

var res := Vector2i(1600, 720)
var tag: String = ""
var out_dir: String = "res://art/t262-mobile/"
var target := Vector2i(2400, 1080)
var ppi: float = 405.0
var only: PackedStringArray = []
var _csv: PackedStringArray = ["pantalla,control,ancho_virtual,alto_virtual,ancho_px_celular,alto_px_celular,ancho_mm,alto_mm,menor_a_7_6_mm"]
## Sin tipo a propósito: Game y los autoloads no existen cuando se compila este script (ver GAME_SCENE_PATH).
var game
var save_manager
var game_flow
## Antes de cada toque del dedo 0 se lleva el cursor del sistema al dedo. Hace falta en escritorio: BuildController
## construye en get_global_mouse_position(), que acá sigue al cursor real y no al toque emulado (prueba A0).
var warp: bool = true


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"res": res = _parse_size(parts[1], res)
			"tag": tag = parts[1]
			"out": out_dir = parts[1]
			"target": target = _parse_size(parts[1], target)
			"ppi": ppi = float(parts[1])
			"only": only = parts[1].split(",")
	if tag == "":
		tag = "%dx%d" % [res.x, res.y]
	if not out_dir.ends_with("/"):
		out_dir += "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	DisplayServer.window_set_size(res)
	run.call_deferred()


func _parse_size(text: String, fallback: Vector2i) -> Vector2i:
	var parts: PackedStringArray = text.split("x")
	return Vector2i(int(parts[0]), int(parts[1])) if parts.size() == 2 else fallback


func _wants(part: String) -> bool:
	return only.is_empty() or only.has(part)


func run() -> void:
	# Los autoloads se piden por ruta: este script se compila antes que ellos en la revisión de sintaxis.
	var dev_mode = get_node("/root/DevMode")
	save_manager = get_node("/root/SaveManager")
	game_flow = get_node("/root/GameFlow")
	dev_mode.enabled = false
	save_manager.save_path = SAVE_PATH
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_manager.load_save()
	save_manager.mark_intro_seen()
	# Campaña a medio jugar: 1 a 9 ganados, el 10 abierto. Así la selección muestra estrellas, abiertos y bloqueados.
	for i: int in 9:
		save_manager.unlock(game_flow.level(i).id)
		save_manager.record_victory(game_flow.level(i).id, 15)
	save_manager.unlock(game_flow.level(9).id)
	await _frames(3)
	var scale_now: float = minf(float(get_window().size.x) / LOGICAL.x, float(get_window().size.y) / LOGICAL.y)
	var scale_target: float = minf(target.x / LOGICAL.x, target.y / LOGICAL.y)
	var used: Vector2 = LOGICAL * scale_target
	print("PROBE ventana %s · escala ahora %.3f · celular supuesto %s a %.0f ppi: escala %.3f, se usa %dx%d (%.0f %% del ancho, %.0f %% del alto) · aspecto %s" % [
		get_window().size, scale_now, target, ppi, scale_target, used.x, used.y, used.x / target.x * 100.0, used.y / target.y * 100.0,
		ProjectSettings.get_setting("display/window/stretch/aspect")])
	print("PROBE emulate_mouse_from_touch=%s · emulate_touch_from_mouse=%s" % [
		ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"),
		ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse")])
	if _wants("menu"):
		await _probe_menu()
	if _wants("select"):
		await _probe_select()
	if _wants("game"):
		await _probe_game()
	if _wants("big"):
		await _probe_big_map()
	if _wants("tabs"):
		await _probe_tabs()
	if _wants("wiki"):
		await _probe_wiki()
	var file := FileAccess.open(out_dir + "sizes_%s.csv" % tag, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(_csv) + "\n")
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("PROBE fin")
	get_tree().quit()


# --- Herramientas ---

func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


## Guarda la pantalla lógica (1280 × 720) dentro de un marco negro con la proporción de la ventana, que es lo que hace
## `stretch/aspect = keep` en un celular más ancho que 16:9. Con `marks` dibuja el borde de cada control medido: rojo si
## en el celular supuesto mide menos de 7,6 mm de lado, verde si no.
func _shot(file_name: String, marks: Array = []) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	for mark: Array in marks:
		_outline(image, mark[0], Color(0.95, 0.15, 0.15) if mark[1] else Color(0.2, 0.9, 0.3))
	var aspect: float = float(res.x) / float(res.y)
	var frame_size := Vector2i(image.get_width(), image.get_height())
	if aspect > LOGICAL.x / LOGICAL.y + 0.01:
		frame_size.x = roundi(image.get_height() * aspect)
	elif aspect < LOGICAL.x / LOGICAL.y - 0.01:
		frame_size.y = roundi(image.get_width() / aspect)
	var framed: Image = Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	framed.fill(Color.BLACK)
	framed.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (frame_size - image.get_size()) / 2)
	var path: String = out_dir + "%s_%s.png" % [file_name, tag]
	framed.save_png(path)
	print("PROBE captura ", path)


func _outline(image: Image, rect: Rect2, color: Color) -> void:
	var r := Rect2i(rect.position.round(), rect.size.round()).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if r.size.x <= 0 or r.size.y <= 0:
		return
	for t: int in 2:
		image.fill_rect(Rect2i(r.position.x, r.position.y + t, r.size.x, 1), color)
		image.fill_rect(Rect2i(r.position.x, r.end.y - 1 - t, r.size.x, 1), color)
		image.fill_rect(Rect2i(r.position.x + t, r.position.y, 1, r.size.y), color)
		image.fill_rect(Rect2i(r.end.x - 1 - t, r.position.y, 1, r.size.y), color)


## De coordenadas de la pantalla lógica (1280 × 720) a la ventana real.
func _to_window(pos: Vector2) -> Vector2:
	return get_viewport().get_final_transform() * pos


## Del mundo (el mapa, con la cámara si la hay) a la pantalla lógica.
func _world_to_screen(world: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world


func _touch(index: int, logical: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = _to_window(logical)
	if warp and index == 0:
		Input.warp_mouse(event.position)
		await _frames(1)
	Input.parse_input_event(event)
	await _frames(2)


func _drag(index: int, from: Vector2, to: Vector2, steps: int) -> void:
	var last: Vector2 = _to_window(from)
	for step: int in range(1, steps + 1):
		var now: Vector2 = _to_window(from.lerp(to, float(step) / steps))
		if warp and index == 0:
			Input.warp_mouse(now)
		var event := InputEventScreenDrag.new()
		event.index = index
		event.position = now
		event.relative = now - last
		Input.parse_input_event(event)
		last = now
		await _frames(1)


func _tap(logical: Vector2) -> void:
	await _touch(0, logical, true)
	await _touch(0, logical, false)


func _center(control: Control) -> Vector2:
	return control.get_global_rect().get_center()


## Mide cada control que se puede tocar y está visible (botones, deslizadores, casillas de marcar). Devuelve
## [rectángulo, es_chico] por control, para marcarlos en una captura.
func _measure(screen: String, root: Node) -> Array:
	var marks: Array = []
	var scale_target: float = minf(target.x / LOGICAL.x, target.y / LOGICAL.y)
	var small: int = 0
	var total: int = 0
	for node: Node in _all_children(root):
		var control := node as Control
		if control == null or not control.is_visible_in_tree():
			continue
		if not (control is BaseButton or (control is Range and not (control is ProgressBar)) or control is LineEdit):
			continue
		if _clipped_out(control):
			continue  # una tarjeta fuera del área visible de su ScrollContainer no se puede tocar ahora
		var size_v: Vector2 = control.get_global_rect().size
		var size_px: Vector2 = size_v * scale_target
		var size_mm: Vector2 = size_px / ppi * 25.4
		var is_small: bool = minf(size_mm.x, size_mm.y) < MIN_TOUCH_MM
		total += 1
		if is_small:
			small += 1
		marks.append([control.get_global_rect(), is_small])
		var label: String = control.name
		if control is Button and (control as Button).text != "":
			label += " «%s»" % (control as Button).text.replace("\n", " ").replace(",", " ").left(28)
		_csv.append("%s,%s,%.0f,%.0f,%.0f,%.0f,%.1f,%.1f,%s" % [screen, label, size_v.x, size_v.y, size_px.x, size_px.y,
			size_mm.x, size_mm.y, "sí" if is_small else "no"])
	print("PROBE medidas %s: %d controles, %d por debajo de %.1f mm en el celular supuesto" % [screen, total, small, MIN_TOUCH_MM])
	return marks


func _clipped_out(control: Control) -> bool:
	var parent: Node = control.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			return not (parent as Control).get_global_rect().has_point(control.get_global_rect().get_center())
		parent = parent.get_parent()
	return false


func _all_children(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in node.get_children():
		result.append(child)
		result.append_array(_all_children(child))
	return result


# --- Menú principal ---

func _probe_menu() -> void:
	var menu: Control = (load(MENU_SCENE_PATH) as PackedScene).instantiate()
	add_child(menu)
	await get_tree().create_timer(0.6).timeout
	await _shot("menu")
	await _shot("menu_objetivos", _measure("menu", menu))
	menu.get_node("%OptionsMenu").open()
	await get_tree().create_timer(0.3).timeout
	await _shot("opciones")
	_measure("opciones", menu.get_node("%OptionsMenu"))
	menu.queue_free()
	await _frames(2)


# --- Selección de niveles ---

func _probe_select() -> void:
	var select: Control = (load(SELECT_SCENE_PATH) as PackedScene).instantiate()
	add_child(select)
	await get_tree().create_timer(0.5).timeout
	await _shot("seleccion")
	await _shot("seleccion_objetivos", _measure("seleccion", select))
	var scroll: ScrollContainer = select.get_node("%Scroll")
	var cards: Array[Node] = select.get_node("%Cards").get_children()
	# Las tarjetas ya no abren la partida: se cuenta qué tarjeta «se habría abierto».
	var started: Array[int] = []
	for i: int in cards.size():
		var card := cards[i] as BaseButton
		if card == null:
			continue
		for connection: Dictionary in card.pressed.get_connections():
			card.pressed.disconnect(connection["callable"])
		card.pressed.connect(func() -> void: started.append(i))
	print("PROBE seleccion: %d tarjetas · área visible %s · contenido %s" % [cards.size(), scroll.size, select.get_node("%Cards").size])
	# 1) Un toque simple en la tarjeta del nivel 1.
	await _tap(_center(cards[0]))
	print("PROBE seleccion toque simple en «Nivel 1»: abre %s" % [started])
	started.clear()
	# 2) Deslizar el dedo hacia arriba empezando sobre la tarjeta del nivel 6, para ver la tercera fila.
	var before: int = scroll.scroll_vertical
	var from: Vector2 = _center(cards[5])
	await _touch(0, from, true)
	await _drag(0, from, from + Vector2(0, -160), 12)
	await _touch(0, from + Vector2(0, -160), false)
	await _frames(10)
	print("PROBE seleccion deslizar 160 px hacia arriba sobre una tarjeta: scroll %d -> %d · abre %s" % [before, scroll.scroll_vertical, started])
	started.clear()
	# 3) La rueda (lo de escritorio) para comparar.
	scroll.scroll_vertical = 0
	await _frames(2)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	wheel.position = _to_window(_center(cards[5]))
	Input.parse_input_event(wheel)
	await _frames(6)
	print("PROBE seleccion rueda del mouse: scroll 0 -> %d" % scroll.scroll_vertical)
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	await _frames(4)
	await _shot("seleccion_abajo")
	select.queue_free()
	await _frames(2)


# --- Partida: nivel 1 (20 × 9, sin cámara) ---

func _start_game(index: int, intro: bool) -> void:
	game_flow.current_index = index
	game_flow.current_community = null
	game_flow.intro_pending = intro
	game_flow.forced_seed = 3
	game = (load(GAME_SCENE_PATH) as PackedScene).instantiate()
	add_child(game)
	await _frames(6)


func _end_game() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	game.queue_free()
	game = null
	await _frames(3)


func _free_cell(near: Vector2i, footprint: int = 1) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d: float = INF
	var size: Vector2i = game.level.map_size()
	var data: TowerData = game.available_towers[0]
	for y: int in size.y:
		for x: int in size.x:
			var cell := Vector2i(x, y)
			var ok: bool = true
			for c: Vector2i in game.build_controller.footprint_cells(cell, footprint):
				if not game.level.is_buildable(c) or game.build_controller.is_occupied(c):
					ok = false
			if ok and data != null and Vector2(cell - near).length() < best_d:
				best_d = Vector2(cell - near).length()
				best = cell
	return best


func _cell_screen(cell: Vector2i) -> Vector2:
	return _world_to_screen(game.level.cell_center(cell))


func _towers() -> int:
	return game.tower_container.get_child_count()


func _probe_game() -> void:
	# El cartel de entrada, como lo ve quien entra al nivel 1 desde la selección.
	await _start_game(0, true)
	await get_tree().create_timer(0.4).timeout
	if game.level_intro.is_open():
		await _shot("cartel_entrada")
		_measure("cartel_entrada", game.level_intro)
	await _end_game()

	await _start_game(0, false)
	var hud = game.hud
	game.session.earn(5000)
	await _frames(3)
	await _shot("partida_n01")
	await _shot("partida_n01_objetivos", _measure("partida_n01", hud))
	var buttons: Array = hud._tower_buttons
	print("PROBE partida n01: %d botones de torre · celda %.0f px virtuales" % [buttons.size(), Rules.TILE_SIZE])

	# A0) Lo mismo que A, sin llevar el cursor del sistema al dedo: muestra de qué depende la casilla elegida.
	warp = false
	Input.warp_mouse(_to_window(Vector2(798, 586)))
	await _frames(2)
	await _tap(_center(buttons[0]))
	var cell_a0: Vector2i = _free_cell(Vector2i(8, 4))
	await _tap(_cell_screen(cell_a0))
	var where: Array = []
	for tower: Node in game.tower_container.get_children():
		where.append(tower.origin_cell)
	print("PROBE A0 sin mover el cursor: dedo en la casilla %s · torres en %s · el juego lee el mouse en la casilla %s" % [cell_a0, where,
		game.level.cell_at(game.build_controller.get_global_mouse_position())])
	for tower: Node in game.tower_container.get_children():
		game.build_controller.sell(tower)
	game.build_controller.cancel()
	await _frames(3)
	warp = true

	# A) Tocar el botón de la primera torre y después una casilla libre.
	await _tap(_center(buttons[0]))
	var picked: bool = game.build_controller.selected_tower() != null
	var cell: Vector2i = _free_cell(Vector2i(8, 4))
	var before: int = _towers()
	await _touch(0, _cell_screen(cell), true)
	var built_on_press: bool = _towers() > before
	await _touch(0, _cell_screen(cell), false)
	var built = game.build_controller.tower_at(cell)  # sin tipo: Tower usa los autoloads
	where.clear()
	for tower: Node in game.tower_container.get_children():
		where.append(tower.origin_cell)
	print("PROBE A dónde quedó: torres en %s · mouse del juego en %s (pantalla lógica %s) · dedo en %s" % [where,
		game.level.cell_at(game.build_controller.get_global_mouse_position()), game.build_controller.get_global_mouse_position(), _cell_screen(cell)])
	print("PROBE A toque en botón de torre: elegida=%s · toque en casilla %s: construye en el apoyo del dedo=%s · torre en esa casilla=%s · toques=2 · diálogos=0" % [
		picked, cell, built_on_press, built != null])
	await _frames(2)
	await _shot("partida_n01_vista_previa")

	# B) Con la torre elegida, apoyar el dedo y arrastrarlo 2 casillas (como quien quiere mover el mapa).
	var cell_b: Vector2i = _free_cell(Vector2i(4, 6))
	before = _towers()
	var from: Vector2 = _cell_screen(cell_b)
	await _touch(0, from, true)
	await _drag(0, from, from + Vector2(128, 0), 10)
	await _touch(0, from + Vector2(128, 0), false)
	print("PROBE B arrastre de 128 px con la torre elegida: torres %d -> %d (en %s: %s)" % [before, _towers(), cell_b, game.build_controller.tower_at(cell_b) != null])

	# C) Pinza con dos dedos (el gesto de zoom) con la torre elegida.
	var cell_c: Vector2i = _free_cell(Vector2i(12, 2))
	before = _towers()
	var p1: Vector2 = _cell_screen(cell_c)
	var p2: Vector2 = p1 + Vector2(160, 96)
	await _touch(0, p1, true)
	await _touch(1, p2, true)
	for step: int in 8:
		var e0 := InputEventScreenDrag.new()
		e0.index = 0
		e0.position = _to_window(p1 - Vector2(step * 8, step * 5))
		Input.parse_input_event(e0)
		var e1 := InputEventScreenDrag.new()
		e1.index = 1
		e1.position = _to_window(p2 + Vector2(step * 8, step * 5))
		Input.parse_input_event(e1)
		await _frames(1)
	await _touch(1, p2, false)
	await _touch(0, p1, false)
	print("PROBE C pinza con la torre elegida: torres %d -> %d · zoom de la cámara %s" % [before, _towers(),
		"sin cámara" if game.camera == null else str(game.camera.zoom)])

	# D) Dejar de construir: tocar otra vez el botón de la torre (RF-143).
	await _tap(_center(buttons[0]))
	print("PROBE D segundo toque en el botón: sigue elegida=%s" % [game.build_controller.selected_tower() != null])

	# E) Mejorar y vender: tocar la torre, tocar Mejorar, tocar Vender.
	var panel: Control = hud.get_node("TowerPanel")
	await _tap(_cell_screen(cell))
	print("PROBE E toque en la torre: panel visible=%s · rect del panel %s" % [panel.visible, panel.get_global_rect()])
	await _frames(2)
	await _shot("partida_n01_panel_torre")
	await _shot("partida_n01_panel_objetivos", _measure("panel_torre", panel) + _measure("panel_torre_hud", hud.get_node("BottomBar")))
	var upgrade: Button = panel.get_node("%UpgradeButton")
	var sell: Button = panel.get_node("%SellButton")
	var gap: float = sell.get_global_rect().position.y - upgrade.get_global_rect().end.y
	print("PROBE E Mejorar %s · Vender %s · separación %.0f px virtuales" % [upgrade.get_global_rect(), sell.get_global_rect(), gap])
	var level_before: int = built.level_number() if built != null else -1
	await _tap(_center(upgrade))
	print("PROBE E toque en Mejorar: nivel %d -> %d · diálogos de confirmación=0" % [level_before, built.level_number() if built != null else -1])
	# Un toque apenas debajo del borde de Mejorar, como un dedo que cae un poco más abajo.
	var edge: Vector2 = Vector2(_center(upgrade).x, upgrade.get_global_rect().end.y + gap + 2.0)
	before = _towers()
	await _tap(edge)
	print("PROBE E toque %.0f px debajo del borde de Mejorar: torres %d -> %d (vendida sin confirmar=%s)" % [gap + 2.0, before, _towers(), _towers() < before])

	# F) Una torre en la columna de la derecha: ¿la tapa su propio panel?
	var cell_f: Vector2i = _free_cell(Vector2i(17, 5))
	game.build_controller.try_build(game.available_towers[0], cell_f)
	await _frames(2)
	await _tap(_cell_screen(cell_f))
	await _frames(2)
	var covers: bool = panel.visible and panel.get_global_rect().has_point(_cell_screen(cell_f))
	print("PROBE F torre en %s (pantalla %s): el panel la tapa=%s" % [cell_f, _cell_screen(cell_f), covers])
	await _shot("partida_n01_panel_tapa")
	game.build_controller.deselect_placed()

	# G) En pausa: elegir una torre y tocar el mapa.
	await _tap(_center(hud.get_node("TopBar/PauseButton")))
	var paused: bool = get_tree().paused
	await _tap(_center(buttons[0]))
	var cell_g: Vector2i = _free_cell(Vector2i(10, 6))
	before = _towers()
	await _tap(_cell_screen(cell_g))
	print("PROBE G pausa=%s · elegir torre en pausa: elegida=%s · toque en el mapa: torres %d -> %d" % [paused,
		game.build_controller.selected_tower() != null, before, _towers()])
	await _tap(_center(hud.get_node("TopBar/PauseButton")))

	# H) Menú de pausa (lo abre el «atrás» de Android, RF-142) y diálogo de la flecha.
	game.open_pause_menu()
	await _frames(3)
	await _shot("pausa")
	_measure("pausa", game.pause_menu)
	game.close_pause_menu()
	await _tap(_center(hud.get_node("TopBar/ExitButton")))
	await _frames(3)
	if game.exit_dialog.is_open():
		await _shot("dialogo_salir")
		_measure("dialogo_salir", game.exit_dialog)
		game.exit_dialog.handle_cancel()
	await _end_game()


# --- Partida: nivel 15 (26 × 12, con cámara) ---

func _probe_big_map() -> void:
	await _start_game(14, false)
	game.session.earn(5000)
	await _frames(3)
	var zoom: float = 1.0 if game.camera == null else game.camera.zoom.x
	var tile_v: float = Rules.TILE_SIZE * zoom
	var scale_target: float = minf(target.x / LOGICAL.x, target.y / LOGICAL.y)
	print("PROBE nivel 15: mapa %s · zoom %.3f · casilla %.1f px virtuales = %.0f px en el celular = %.1f mm" % [
		game.level.map_size(), zoom, tile_v, tile_v * scale_target, tile_v * scale_target / ppi * 25.4])
	await _shot("partida_n15_objetivos", _measure("partida_n15", game.hud))
	var buttons: Array = game.hud._tower_buttons
	await _tap(_center(buttons[0]))
	var cell: Vector2i = _free_cell(Vector2i(13, 6))
	var screen: Vector2 = _cell_screen(cell)
	await _tap(screen)
	var ok: bool = game.build_controller.tower_at(cell) != null
	# El mismo toque desplazado 0,6 casillas: ¿en qué casilla cae?
	var off: Vector2 = screen + Vector2(tile_v * 0.6, 0)
	var cell_off: Vector2i = game.level.cell_at(get_viewport().get_canvas_transform().affine_inverse() * off)
	print("PROBE nivel 15 toque con cámara: construye en la casilla tocada=%s · %.0f px virtuales de corrimiento ya es la casilla %s" % [
		ok, tile_v * 0.6, cell_off])
	await _frames(2)
	await _shot("partida_n15")
	await _end_game()


# --- Partida con pestañas (nivel 7: demoledora) ---

func _probe_tabs() -> void:
	await _start_game(6, false)
	await _frames(3)
	await _shot("partida_n07_pestanas")
	_measure("partida_n07", game.hud)
	print("PROBE nivel 7: pestañas=%s · %d botones de torre" % [game.hud.has_tabs(), game.hud._tower_buttons.size()])
	# La pestaña «Infraestructura», tocada como la tocaría el dedo.
	var tab: Control = game.hud.find_child("Tab_infrastructure", true, false)
	if tab != null:
		await _tap(_center(tab))
		await _frames(3)
		print("PROBE nivel 7: pestaña actual tras tocar «Infraestructura» = %s" % game.hud.current_tab())
		await _shot("partida_n07_infraestructura", _measure("partida_n07_infraestructura", game.hud))
	await _end_game()


# --- Wiki ---

func _probe_wiki() -> void:
	var wiki: Control = (load(WIKI_SCENE_PATH) as PackedScene).instantiate()
	wiki.is_seen = func(_enemy_id: StringName) -> bool: return true
	add_child(wiki)
	await get_tree().create_timer(0.4).timeout
	wiki.show_target(&"enemigos", &"tank")
	await get_tree().create_timer(0.3).timeout
	await _shot("wiki")
	_measure("wiki", wiki)
	wiki.queue_free()
	await _frames(2)
