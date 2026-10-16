# T264: maquetas del zoom táctil y de la compra y colocación de torres, en ESCRITORIO y con la proporción de un
# celular. NO es un test ni cambia el juego: abre la partida real (nivel 1 y nivel 15), mueve la cámara, elige torres
# con BuildController y dibuja ENCIMA, en una capa propia, los controles que todavía no existen (tilde y cruz, tienda,
# barra grande, «Deshacer», el dedo). Todo lo que dibuja la capa propia es una MAQUETA: lo dice cada captura.
# Además corre un modelo de los gestos (TouchBuildModel, abajo) con los mismos toques para el flujo de hoy y los
# propuestos, y cuenta toques, compras buenas y compras por error. No toca el guardado del jugador: usa
# `user://t264_touch_mockups.json` y lo borra (igual conviene correrlo con XDG_DATA_HOME apuntando a una carpeta temporal).
#
#   XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1600x720 res://tools/t264_touch_mockups.tscn -- res=1600x720 tag=20x9
#
#   res=WxH      tamaño de la ventana (por omisión 1600x720, 20:9)
#   tag=texto    sufijo de los archivos (por omisión el tamaño)
#   out=ruta     carpeta de salida (por omisión res://art/t264-zoom-compra/)
#   target=WxH   pantalla del celular supuesto (por omisión 2400x1080, el 1080 × 2400 acostado de T262)
#   ppi=N        píxeles por pulgada del celular supuesto (por omisión 405)
#   only=lista   partes: zoom,shop,place,model (por omisión todas)
#
# Imprime líneas «T264 …» y deja en `out`: capturas PNG, hojas de comparación y `medidas_<tag>.csv`.
# Límite honesto: no hay dedo. El dedo dibujado es un círculo de 10 mm (la yema apoyada) con la sombra del pulgar; un
# dedo real cambia de tamaño, tiembla y no siempre viene desde abajo a la derecha.
extends Node

## Se carga en tiempo de ejecución, no con preload: la revisión de sintaxis (--check-only -s) compila este script sin
## los autoloads, y la partida los usa.
const GAME_SCENE_PATH: String = "res://scenes/game/game.tscn"
const SAVE_PATH: String = "user://t264_touch_mockups.json"
const LOGICAL := Vector2(1280.0, 720.0)
const MAP_TOP: float = 48.0
const MAP_BOTTOM: float = 624.0
## Material Design: 48 dp = 7,6 mm como mínimo para algo que se toca (el mismo criterio de T262).
const MIN_TOUCH_MM: float = 7.6
## Yema del dedo apoyada: 10 mm de ancho es lo habitual para un índice o un pulgar adulto (supuesto, no medido).
const FINGER_MM: float = 10.0
## Ancho de la sombra del pulgar que tapa la pantalla desde abajo.
const THUMB_MM: float = 16.0
## Zoom máximo propuesto: una casilla de 96 px virtuales (9,0 mm en el celular supuesto, 8,3 mm en el 16:9 chico).
const MAX_ZOOM_CELL_PX: float = 96.0

var res := Vector2i(1600, 720)
var tag: String = ""
var out_dir: String = "res://art/t264-zoom-compra/"
var target := Vector2i(2400, 1080)
var ppi: float = 405.0
var only: PackedStringArray = []
var _scale_target: float = 1.5
var _csv: PackedStringArray = ["captura,control,ancho_virtual,alto_virtual,ancho_mm,alto_mm,alto_mm_16x9_chico,llega_a_7_6_mm"]
## Sin tipo a propósito: Game y los autoloads no existen cuando se compila este script.
var game
var save_manager
var game_flow
var _camera: Camera2D
var _layer: CanvasLayer
var _overlay: Control
var _marks: Array[Dictionary] = []
var _shot_name: String = ""
## Capturas sacadas en esta corrida: nombre → archivo. Las usan las hojas de comparación.
var _shots: Dictionary = {}


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
	_scale_target = minf(target.x / LOGICAL.x, target.y / LOGICAL.y)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	DisplayServer.window_set_size(res)
	run.call_deferred()


func _parse_size(text: String, fallback: Vector2i) -> Vector2i:
	var parts: PackedStringArray = text.split("x")
	return Vector2i(int(parts[0]), int(parts[1])) if parts.size() == 2 else fallback


func _wants(part: String) -> bool:
	return only.is_empty() or only.has(part)


func run() -> void:
	var dev_mode = get_node("/root/DevMode")
	save_manager = get_node("/root/SaveManager")
	game_flow = get_node("/root/GameFlow")
	dev_mode.enabled = false
	save_manager.save_path = SAVE_PATH
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_manager.load_save()
	save_manager.mark_intro_seen()
	for i: int in 15:
		save_manager.unlock(game_flow.level(i).id)
	_layer = CanvasLayer.new()
	_layer.layer = 90
	add_child(_layer)
	_overlay = Control.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.size = LOGICAL
	_overlay.draw.connect(_draw_marks)
	_layer.add_child(_overlay)
	await _frames(3)
	print("T264 ventana %s · celular supuesto %s a %.0f ppi (escala %.2f): 1 px virtual = %.3f mm · dedo %.0f mm = %.0f px virtuales" % [
		get_window().size, target, ppi, _scale_target, _mm(1.0), FINGER_MM, _px(FINGER_MM)])
	if _wants("zoom"):
		await _zoom_shots()
	if _wants("shop"):
		await _shop_shots()
	if _wants("place"):
		await _place_shots()
	if _wants("model"):
		_run_model()
		_print_hit_model()
	_sheets()
	var file := FileAccess.open(out_dir + "medidas_%s.csv" % tag, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(_csv) + "\n")
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("T264 fin")
	get_tree().quit()


# --- Medidas ---

## Píxeles virtuales → milímetros en el celular supuesto.
func _mm(px: float) -> float:
	return px * _scale_target / ppi * 25.4


## Milímetros en el celular supuesto → píxeles virtuales.
func _px(mm: float) -> float:
	return mm / 25.4 * ppi / _scale_target


## Lo mismo en el 16:9 chico de T262 (720 × 1280 a 294 ppi, escala 1).
func _mm_small(px: float) -> float:
	return px / 294.0 * 25.4


func _record(control: String, rect: Rect2) -> void:
	var w: float = _mm(rect.size.x)
	var h: float = _mm(rect.size.y)
	_csv.append("%s,%s,%.0f,%.0f,%.1f,%.1f,%.1f,%s" % [_shot_name, control.replace(",", " "), rect.size.x, rect.size.y, w, h,
		_mm_small(rect.size.y), "sí" if minf(w, h) >= MIN_TOUCH_MM else "no"])


# --- Partida y cámara ---

func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func _start_game(index: int) -> void:
	game_flow.current_index = index
	game_flow.current_community = null
	game_flow.intro_pending = false
	game_flow.forced_seed = 3
	game = (load(GAME_SCENE_PATH) as PackedScene).instantiate()
	add_child(game)
	await _frames(6)
	game.session.earn(5000)
	game.session.add_resources(20)  # el mortero (2 × 2) pide recursos: sin ellos su fantasma sale rojo
	_camera = game.camera
	if _camera == null:  # los niveles de 20 × 9 no tienen cámara: se agrega una que no cambia nada (zoom 1)
		_camera = Camera2D.new()
		_camera.position = LOGICAL / 2.0
		game.add_child(_camera)
		_camera.make_current()
	await _frames(3)


func _end_game() -> void:
	_marks.clear()
	_overlay.queue_redraw()
	get_tree().paused = false
	game.queue_free()
	game = null
	_camera = null
	await _frames(3)


## Zoom de la cámara y punto del mundo que queda en `screen` (pantalla lógica).
func _view(zoom: float, world: Vector2, screen: Vector2) -> void:
	_camera.zoom = Vector2(zoom, zoom)
	_camera.position = world - (screen - LOGICAL / 2.0) / zoom
	await _frames(3)


## El encuadre de hoy (RF-251): todo el mapa en el área del mapa.
func _view_fit() -> void:
	var size: Vector2i = game.level.map_size()
	var zoom: float = Rules.map_zoom(size.x, size.y)
	_camera.zoom = Vector2(zoom, zoom)
	_camera.position = Rules.map_camera_center(size.x, size.y) if zoom < 1.0 else LOGICAL / 2.0
	await _frames(3)


func _zoom_for_max() -> float:
	return MAX_ZOOM_CELL_PX / Rules.TILE_SIZE


func _cell_px() -> float:
	return Rules.TILE_SIZE * _camera.zoom.x


func _to_screen(world: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world


## Rectángulo en pantalla de una torre de lado `footprint` con casilla de arriba a la izquierda `origin`.
func _cells_rect(origin: Vector2i, footprint: int) -> Rect2:
	var tile: float = Rules.TILE_SIZE
	var top_left: Vector2 = game.level.cell_center(origin) - Vector2(tile, tile) / 2.0
	return get_viewport().get_canvas_transform() * Rect2(top_left, Vector2(tile, tile) * footprint)


func _free_cell(near: Vector2i, footprint: int = 1, buildable: bool = true) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d: float = INF
	var size: Vector2i = game.level.map_size()
	for y: int in size.y - footprint + 1:
		for x: int in size.x - footprint + 1:
			var cell := Vector2i(x, y)
			var ok: bool = true
			for dy: int in footprint:
				for dx: int in footprint:
					var c: Vector2i = cell + Vector2i(dx, dy)
					if game.level.is_buildable(c) != buildable or game.build_controller.is_occupied(c):
						ok = false
			if ok and Vector2(cell - near).length() < best_d:
				best_d = Vector2(cell - near).length()
				best = cell
	return best


func _tower_index(footprint: int) -> int:
	for i: int in game.available_towers.size():
		if (game.available_towers[i] as TowerData).footprint == footprint:
			return i
	return -1


## La vista previa real de BuildController (verde/roja, torre fantasma y alcance) en una casilla fija, sin depender
## del cursor: se apaga su _process, que la pondría donde está el mouse.
func _ghost(index: int, origin: Vector2i) -> void:
	var bc = game.build_controller
	if bc.selected_tower() != game.available_towers[index]:
		bc.select(index)
	game.hud.show_selected_tower(index)
	bc.set_process(false)
	bc._hover_cell = origin
	bc.queue_redraw()
	await _frames(2)


func _clear_ghost() -> void:
	game.build_controller.cancel()
	game.build_controller.set_process(true)
	await _frames(2)


func _bar(visible: bool) -> void:
	game.hud.get_node("BottomBar").visible = visible
	game.hud.get_node("%BuildInfo").visible = visible


# --- Capa de maqueta ---

func _mark(kind: String, data: Dictionary) -> void:
	data["t"] = kind
	_marks.append(data)
	if kind == "button":
		_record(data.get("text", "") if data.get("text", "") != "" else data.get("kind", ""), data["r"])
	_overlay.queue_redraw()


func _caption(text: String) -> void:
	_mark("caption", {"text": text})


func _finger(pos: Vector2, lifted: bool = false) -> void:
	_mark("finger", {"p": pos, "lifted": lifted})


func _button(rect: Rect2, text: String, kind: String = "normal", icon: Texture2D = null, sub: String = "", font: int = 18) -> void:
	_mark("button", {"r": rect, "text": text, "kind": kind, "icon": icon, "sub": sub, "fs": font})


func _note(pos: Vector2, text: String, font: int = 16, color: Color = Color(1, 0.92, 0.6)) -> void:
	_mark("note", {"p": pos, "text": text, "fs": font, "c": color})


func _shot(file_name: String) -> void:
	_overlay.queue_redraw()
	await _frames(2)
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	var aspect: float = float(res.x) / float(res.y)
	var frame_size := Vector2i(image.get_width(), image.get_height())
	if aspect > LOGICAL.x / LOGICAL.y + 0.01:
		frame_size.x = roundi(image.get_height() * aspect)
	var framed: Image = Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	framed.fill(Color.BLACK)
	framed.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (frame_size - image.get_size()) / 2)
	var path: String = out_dir + "%s_%s.png" % [file_name, tag]
	framed.save_png(path)
	_shots[file_name] = path
	print("T264 captura ", path)


## Empieza una captura nueva: borra la maqueta anterior y anota el nombre para las medidas.
func _begin(file_name: String) -> void:
	_marks.clear()
	_shot_name = file_name
	_overlay.queue_redraw()


func _draw_marks() -> void:
	var font: Font = ThemeDB.fallback_font
	for m: Dictionary in _marks:
		match m["t"]:
			"finger":
				_draw_finger(m["p"], m["lifted"])
			"button":
				_draw_button(font, m)
			"panel":
				var box := StyleBoxFlat.new()
				box.bg_color = m.get("c", Color(0.1, 0.11, 0.14, 0.94))
				box.set_corner_radius_all(10)
				box.set_border_width_all(2)
				box.border_color = Color(0.85, 0.6, 0.25, 0.9)
				_overlay.draw_style_box(box, m["r"])
			"ring":
				var r: Rect2 = m["r"]
				_overlay.draw_rect(r, m.get("c", Color(1, 0.9, 0.2)), false, 3.0)
			"line":
				_overlay.draw_line(m["a"], m["b"], m.get("c", Color(1, 0.9, 0.2, 0.8)), m.get("w", 3.0))
			"note":
				_draw_note(font, m["p"], m["text"], m["fs"], m["c"])
			"progress":
				var r: Rect2 = m["r"]
				_overlay.draw_rect(r, Color(1, 1, 1, 0.15))
				_overlay.draw_rect(Rect2(r.position, Vector2(r.size.x * float(m["v"]), r.size.y)), Color(0.95, 0.75, 0.3))
			"minimap":
				_draw_minimap(m["r"], m["view"])
			"caption":
				var text: String = m["text"]
				var size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
				var rect := Rect2(Vector2((LOGICAL.x - size.x) / 2.0 - 12.0, MAP_TOP + 4.0), Vector2(size.x + 24.0, 30.0))
				_overlay.draw_rect(rect, Color(0.08, 0.06, 0.02, 0.88))
				_overlay.draw_rect(rect, Color(1, 0.8, 0.2), false, 2.0)
				_overlay.draw_string(font, rect.position + Vector2(12.0, 21.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(1, 0.88, 0.45))


func _draw_finger(p: Vector2, lifted: bool) -> void:
	var radius: float = _px(FINGER_MM) / 2.0
	if lifted:  # dónde estuvo el dedo: solo el contorno, ya no tapa
		_overlay.draw_arc(p, radius, 0.0, TAU, 48, Color(1, 0.85, 0.7, 0.8), 2.0)
		return
	var dir := Vector2(0.42, 1.0).normalized()  # el pulgar derecho viene desde abajo a la derecha
	var skin := Color(0.93, 0.74, 0.6, 0.78)
	_overlay.draw_line(p + dir * radius * 0.6, p + dir * 520.0, skin, _px(THUMB_MM))
	_overlay.draw_circle(p, radius, skin)
	_overlay.draw_arc(p, radius, 0.0, TAU, 48, Color(0.55, 0.35, 0.25, 0.9), 2.0)


func _draw_button(font: Font, m: Dictionary) -> void:
	var r: Rect2 = m["r"]
	var kind: String = m["kind"]
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(8)
	box.set_border_width_all(2)
	box.bg_color = Color(0.16, 0.17, 0.21, 0.97)
	box.border_color = Color(0.85, 0.6, 0.25)
	match kind:
		"ok":
			box.bg_color = Color(0.17, 0.5, 0.24, 0.97)
			box.border_color = Color(0.6, 1.0, 0.6)
		"no":
			box.bg_color = Color(0.42, 0.16, 0.14, 0.97)
			box.border_color = Color(1.0, 0.6, 0.55)
		"off":
			box.bg_color = Color(0.25, 0.25, 0.27, 0.9)
			box.border_color = Color(0.5, 0.5, 0.5)
		"sel":
			box.border_color = Color(1.0, 0.85, 0.3)
			box.set_border_width_all(4)
	_overlay.draw_style_box(box, r)
	var text: String = m["text"]
	var sub: String = m["sub"]
	var fs: int = m["fs"]
	var icon: Texture2D = m["icon"]
	var c: Vector2 = r.get_center()
	var ink := Color(1, 1, 1) if kind != "off" else Color(0.7, 0.7, 0.7)
	if text == "":
		var s: float = minf(r.size.x, r.size.y) * 0.22
		var mid: Vector2 = c - Vector2(0, 10.0 if sub != "" else 0.0)
		if kind == "ok" or (kind == "off" and m.get("glyph", "ok") == "ok"):
			_overlay.draw_polyline(PackedVector2Array([mid + Vector2(-s, 0), mid + Vector2(-s * 0.3, s * 0.7), mid + Vector2(s, -s * 0.7)]), ink, 6.0)
		elif kind == "no":
			_overlay.draw_line(mid + Vector2(-s, -s), mid + Vector2(s, s), ink, 6.0)
			_overlay.draw_line(mid + Vector2(-s, s), mid + Vector2(s, -s), ink, 6.0)
	if icon != null:
		var side: float = minf(r.size.y * 0.5, 56.0)
		var top: float = r.position.y + 6.0
		_overlay.draw_texture_rect(icon, Rect2(Vector2(c.x - side / 2.0, top), Vector2(side, side)), false)
		if text != "":
			_center_text(font, Vector2(c.x, top + side + fs * 0.9), text, fs, r.size.x - 6.0, ink)
		if sub != "":
			_center_text(font, Vector2(c.x, r.end.y - 8.0), sub, fs - 2, r.size.x - 6.0, Color(1, 0.85, 0.4))
		return
	if text != "":
		_center_text(font, c + Vector2(0, fs * 0.35 - (8.0 if sub != "" else 0.0)), text, fs, r.size.x - 6.0, ink)
	if sub != "":
		_center_text(font, Vector2(c.x, r.end.y - 9.0), sub, fs - 2, r.size.x - 6.0, Color(1, 0.88, 0.5))


func _center_text(font: Font, baseline_center: Vector2, text: String, fs: int, width: float, color: Color) -> void:
	_overlay.draw_string(font, Vector2(baseline_center.x - width / 2.0, baseline_center.y), text, HORIZONTAL_ALIGNMENT_CENTER, width, fs, color)


func _draw_note(font: Font, p: Vector2, text: String, fs: int, color: Color) -> void:
	var lines: PackedStringArray = text.split("\n")
	var width: float = 0.0
	for line: String in lines:
		width = maxf(width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	var rect := Rect2(p, Vector2(width + 16.0, lines.size() * (fs + 6.0) + 8.0))
	_overlay.draw_rect(rect, Color(0.05, 0.05, 0.07, 0.85))
	for i: int in lines.size():
		_overlay.draw_string(font, p + Vector2(8.0, 4.0 + fs + i * (fs + 6.0)), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)


## Mapa en miniatura (opcional en Z1): el rectángulo amarillo es la parte que se ve con el zoom.
func _draw_minimap(r: Rect2, view: Rect2) -> void:
	_overlay.draw_rect(r, Color(0.2, 0.3, 0.18, 0.9))
	_overlay.draw_rect(r, Color(1, 1, 1, 0.6), false, 2.0)
	_overlay.draw_rect(view, Color(1, 0.85, 0.3), false, 2.0)


# --- Posición de la tilde y la cruz (C1) ---

## La tilde (grande, con el costo) y la cruz van ARRIBA del fantasma, separadas, para que el pulgar que viene de
## abajo no las tape ni las toque al ajustar. Si no entran arriba, van abajo; nunca salen del área del mapa.
func _confirm_rects(ghost: Rect2) -> Array[Rect2]:
	var ok_size := Vector2(96, 88)
	var no_size := Vector2(84, 84)
	var gap: float = 14.0
	var top: float = ghost.position.y - gap - ok_size.y
	if top < MAP_TOP + 40.0:
		top = ghost.end.y + gap
	var ok := Rect2(Vector2(ghost.get_center().x + 12.0, top), ok_size)
	var no := Rect2(Vector2(ghost.get_center().x - 12.0 - no_size.x - 24.0, top + (ok_size.y - no_size.y) / 2.0), no_size)
	var shift: float = 0.0
	if ok.end.x > LOGICAL.x - 12.0:
		shift = LOGICAL.x - 12.0 - ok.end.x
	if no.position.x + shift < 12.0:
		shift = 12.0 - no.position.x
	ok.position.x += shift
	no.position.x += shift
	return [ok, no]


func _confirm_buttons(ghost: Rect2, cost: String, enabled: bool = true) -> void:
	var rects: Array[Rect2] = _confirm_rects(ghost)
	if enabled:
		_button(rects[0], "", "ok", null, cost, 18)
	else:
		_mark("button", {"r": rects[0], "text": "", "kind": "off", "icon": null, "sub": cost, "fs": 18, "glyph": "ok"})
	_button(rects[1], "", "no")


# --- A · Zoom (nivel 15 y nivel 1) ---

func _zoom_shots() -> void:
	await _start_game(14)
	var index: int = 0
	var cell: Vector2i = _free_cell(Vector2i(13, 6))
	var cost: String = game.hud._tower_buttons[index].text
	# Z0 · hoy: el encuadre fijo, casilla de 4,5 mm. El dedo apoyado en la casilla y la vista previa debajo.
	_begin("z0_n15_hoy")
	await _ghost(index, cell)
	var rect: Rect2 = _cells_rect(cell, 1)
	_caption("HOY · nivel 15 sin zoom · casilla %.0f px = %.1f mm · el dedo (%.0f mm) tapa la casilla y sus vecinas" % [rect.size.x, _mm(rect.size.x), FINGER_MM])
	_finger(rect.get_center())
	await _shot("z0_n15_hoy")
	# Z1 · zoom con pinza al máximo propuesto, centrado en la misma casilla, que queda en el mismo lugar de la pantalla.
	_begin("z1_n15_zoom")
	await _view(_zoom_for_max(), game.level.cell_center(cell), rect.get_center())
	await _ghost(index, cell)
	rect = _cells_rect(cell, 1)
	_caption("MAQUETA Z1 · pinza a ×%.1f · casilla %.0f px = %.1f mm · el mismo dedo tapa una casilla" % [_zoom_for_max() / Rules.map_zoom(26, 12), rect.size.x, _mm(rect.size.x)])
	_finger(rect.get_center())
	_zoom_controls()
	await _shot("z1_n15_zoom")
	# Z1 sin dedo: lo que se ve con el zoom (cuánto mapa entra).
	_begin("z1_n15_zoom_vista")
	await _clear_ghost()
	_caption("MAQUETA Z1 · con zoom máximo entra la cuarta parte del mapa: hace falta desplazar y «Ver todo»")
	_zoom_controls()
	await _shot("z1_n15_zoom_vista")
	await _view_fit()
	await _end_game()

	await _start_game(0)
	cell = _free_cell(Vector2i(9, 4))
	_begin("z0_n01_hoy")
	await _ghost(index, cell)
	rect = _cells_rect(cell, 1)
	_caption("HOY · nivel 1 sin zoom · casilla %.0f px = %.1f mm" % [rect.size.x, _mm(rect.size.x)])
	_finger(rect.get_center())
	await _shot("z0_n01_hoy")
	_begin("z1_n01_zoom")
	await _view(_zoom_for_max(), game.level.cell_center(cell), rect.get_center())
	await _ghost(index, cell)
	rect = _cells_rect(cell, 1)
	_caption("MAQUETA Z1 · nivel 1 a ×%.1f · casilla %.0f px = %.1f mm" % [_zoom_for_max(), rect.size.x, _mm(rect.size.x)])
	_finger(rect.get_center())
	_zoom_controls()
	await _shot("z1_n01_zoom")
	await _end_game()


## Lo que agrega Z1 en la pantalla: «Ver todo» (vuelve al encuadre de hoy) y el mapa en miniatura (opcional).
func _zoom_controls() -> void:
	_button(Rect2(Vector2(1148, 512), Vector2(120, 96)), "Ver todo", "normal", null, "×%.1f" % (_camera.zoom.x / Rules.map_zoom(game.level.map_size().x, game.level.map_size().y)), 18)
	var size: Vector2i = game.level.map_size()
	var mini := Rect2(Vector2(1148, 96), Vector2(120, 120.0 * size.y / size.x))
	# La parte visible del mundo, pasada a la miniatura.
	var inv: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	var world_view: Rect2 = inv * Rect2(Vector2(0, MAP_TOP), Vector2(LOGICAL.x, MAP_BOTTOM - MAP_TOP))
	var world_map := Rect2(Vector2(0, MAP_TOP), Vector2(size) * Rules.TILE_SIZE)
	var k: float = mini.size.x / world_map.size.x
	var view := Rect2(mini.position + (world_view.position - world_map.position) * k, world_view.size * k).intersection(mini)
	_mark("minimap", {"r": mini, "view": view})


# --- B · Dónde se elige la torre (nivel 15, 8 torres) ---

func _shop_shots() -> void:
	await _start_game(14)
	var buttons: Array = game.hud._tower_buttons
	var types: Array = game.available_towers
	# S0 · hoy.
	_begin("s0_n15_barra_hoy")
	for b: Button in buttons:
		_record("botón de torre (hoy) " + b.text, b.get_global_rect())
	_caption("HOY · barra fija de %d torres · botones %.0f × %.0f px = %.1f × %.1f mm" % [buttons.size(),
		buttons[0].size.x, buttons[0].size.y, _mm(buttons[0].size.x), _mm(buttons[0].size.y)])
	await _shot("s0_n15_barra_hoy")
	# S1 · botones más grandes en la misma barra (se saca «Próxima oleada» de la barra para que entren).
	_begin("s1_n15_botones_grandes")
	game.hud.get_node("BottomBar/TowerButtons").visible = false
	game.hud.get_node("BottomBar/NextWave").visible = false
	var left: float = game.hud.get_node("BottomBar/TowerButtons").get_global_rect().position.x
	var size := Vector2(100, 88)
	var gap: float = 6.0
	for i: int in buttons.size():
		var r := Rect2(Vector2(left + i * (size.x + gap), 628), size)
		_button(r, "", "normal", buttons[i].icon, buttons[i].text, 18)
	_caption("MAQUETA S1 · la misma barra con botones de %.0f × %.0f px = %.1f × %.1f mm (sin teclas; «Próxima oleada» sale de la barra)" % [
		size.x, size.y, _mm(size.x), _mm(size.y)])
	await _shot("s1_n15_botones_grandes")
	# S3 · la barra de S1, plegable con una lengüeta.
	_marks = _marks.filter(func(m: Dictionary) -> bool: return m["t"] != "caption")
	_shot_name = "s3_n15_plegable_abierta"
	_button(Rect2(Vector2(1176, 536), Vector2(92, 84)), "Plegar", "normal", null, "", 18)
	_caption("MAQUETA S3 · barra grande de S1 con «Plegar» (92 × 84 px = %.1f × %.1f mm)" % [_mm(92), _mm(84)])
	await _shot("s3_n15_plegable_abierta")
	game.hud.get_node("BottomBar/TowerButtons").visible = true
	game.hud.get_node("BottomBar/NextWave").visible = true
	# S2 · tienda cerrada: no hay barra; el mapa gana la franja de abajo.
	_begin("s2_n15_tienda_cerrada")
	_bar(false)
	# Sin barra, el área del mapa va de y = 48 a 720; el encuadre sigue limitado por el ancho (26 casillas en 1280 px).
	var zoom_open: float = minf(1.0, minf(LOGICAL.x / (26 * Rules.TILE_SIZE), (720.0 - MAP_TOP) / (12 * Rules.TILE_SIZE)))
	await _view(zoom_open, Vector2(26 * 32.0, MAP_TOP + 12 * 32.0), Vector2(640, (MAP_TOP + 720.0) / 2.0))
	_button(Rect2(Vector2(12, 620), Vector2(150, 88)), "Torres", "normal", buttons[0].icon, "", 18)
	_button(Rect2(Vector2(1036, 620), Vector2(232, 88)), "Empezar oleada", "normal", null, "", 20)
	_caption("MAQUETA S2 · tienda cerrada: el mapa usa toda la altura (casilla %.0f → %.0f px, +%.0f %%)" % [
		48.0, _cell_px(), (_cell_px() / 48.0 - 1.0) * 100.0])
	await _shot("s2_n15_tienda_cerrada")
	# S2 · tienda abierta: tarjetas grandes con nombre y costo; tapan la mitad de abajo del mapa.
	_begin("s2_n15_tienda_abierta")
	_mark("panel", {"r": Rect2(Vector2(8, 404), Vector2(1264, 312))})
	_note(Vector2(24, 414), "Torres · tocá una para elegirla", 18)
	_button(Rect2(Vector2(1180, 408), Vector2(84, 84)), "", "no")
	var card := Vector2(196, 108)
	for i: int in types.size():
		var col: int = i % 6
		var row: int = i / 6
		var r := Rect2(Vector2(24 + col * (card.x + 8), 492 + row * (card.y + 8)), card)
		_button(r, (types[i] as TowerData).display_name, "normal", buttons[i].icon, buttons[i].text, 17)
	_caption("MAQUETA S2 · tienda abierta: tarjetas de %.0f × %.0f px = %.1f × %.1f mm con nombre y costo" % [card.x, card.y, _mm(card.x), _mm(card.y)])
	await _shot("s2_n15_tienda_abierta")
	# S2 · después de elegir: la tienda se cierra y queda una pastilla con la torre elegida (tocarla la cancela).
	_begin("s2_n15_elegida")
	var cell: Vector2i = _free_cell(Vector2i(13, 6))
	await _ghost(0, cell)
	_bar(false)
	_button(Rect2(Vector2(12, 620), Vector2(150, 88)), "Torres", "normal", buttons[0].icon, "", 18)
	_button(Rect2(Vector2(176, 620), Vector2(300, 88)), (types[0] as TowerData).display_name + " (soltar)", "sel", null, buttons[0].text + " de oro · tocá para soltarla", 18)
	_button(Rect2(Vector2(1036, 620), Vector2(232, 88)), "Empezar oleada", "normal", null, "", 20)
	_caption("MAQUETA S2 · torre elegida: la tienda se cerró sola; la pastilla dice qué se está construyendo")
	await _shot("s2_n15_elegida")
	await _clear_ghost()
	# S3 · plegada: como S2 cerrada, pero «Torres» vuelve a abrir la barra de S1 (una fila, sin nombres).
	_begin("s3_n15_plegable_cerrada")
	_button(Rect2(Vector2(12, 620), Vector2(150, 88)), "Torres", "normal", buttons[0].icon, "", 18)
	_button(Rect2(Vector2(1036, 620), Vector2(232, 88)), "Empezar oleada", "normal", null, "", 20)
	_caption("MAQUETA S3 · plegada: igual que S2 cerrada; «Torres» despliega la barra de S1 y queda abierta")
	await _shot("s3_n15_plegable_cerrada")
	await _end_game()


# --- C · Comprar y colocar ---

func _place_shots() -> void:
	await _start_game(0)
	var buttons: Array = game.hud._tower_buttons
	var cell: Vector2i = _free_cell(Vector2i(9, 4))
	var rect: Rect2 = _cells_rect(cell, 1)
	var gold_before: int = game.session.gold
	# C0 · hoy: el toque ya compró (la vista previa queda sobre la torre recién comprada, debajo del dedo).
	_begin("c0_n01_hoy")
	await _ghost(0, cell)
	game.build_controller.try_build(game.available_towers[0], cell)
	await _frames(2)
	_caption("HOY · al apoyar el dedo ya se compró (oro %d → %d) · el dedo tapa la torre y su vista previa" % [gold_before, game.session.gold])
	_finger(rect.get_center())
	await _shot("c0_n01_hoy")
	game.build_controller.sell(game.build_controller.tower_at(cell))
	game.session.earn(gold_before - game.session.gold)
	await get_tree().create_timer(2.0).timeout  # que se borre el «+35» de la venta antes de la captura siguiente
	# C1 · el toque deja un fantasma (no cobra); la tilde compra, la cruz suelta.
	_begin("c1_n01_fantasma")
	await _ghost(0, cell)
	_confirm_buttons(rect, buttons[0].text)
	_finger(rect.get_center(), true)
	_caption("MAQUETA C1 · el toque solo pone el fantasma (oro %d sin cambiar) · tilde = comprar, cruz = soltar" % game.session.gold)
	await _shot("c1_n01_fantasma")
	# C1 · ajustar: arrastrar un dedo desde cualquier lado mueve el fantasma lo mismo que el dedo (no el mapa).
	_begin("c1_n01_ajuste")
	var moved: Vector2i = cell + Vector2i(1, 0)
	await _ghost(0, moved)
	var moved_rect: Rect2 = _cells_rect(moved, 1)
	var finger_at: Vector2 = moved_rect.get_center() + Vector2(0, 110)
	_mark("line", {"a": finger_at, "b": moved_rect.get_center(), "c": Color(1, 0.9, 0.3, 0.7), "w": 2.0})
	_finger(finger_at)
	_caption("MAQUETA C1 · ajuste: el dedo arrastra por debajo y el fantasma se corre igual, a la vista; la tilde vuelve al soltar")
	await _shot("c1_n01_ajuste")
	await _clear_ghost()
	await _end_game()

	await _start_game(14)
	buttons = game.hud._tower_buttons
	cell = _free_cell(Vector2i(13, 6))
	rect = _cells_rect(cell, 1)
	# C1 en el nivel 15 sin zoom.
	_begin("c1_n15_sin_zoom")
	await _ghost(0, cell)
	_confirm_buttons(rect, buttons[0].text)
	_finger(rect.get_center(), true)
	_caption("MAQUETA C1 · nivel 15 sin zoom: se puede, pero el fantasma mide %.1f mm; se ve y se corrige antes de pagar" % _mm(rect.size.x))
	await _shot("c1_n15_sin_zoom")
	# C1 · torre de 2 × 2 con zoom.
	var mortar: int = _tower_index(2)
	if mortar >= 0:
		var origin: Vector2i = _free_cell(Vector2i(12, 6), 2)
		await _view(_zoom_for_max(), game.level.cell_center(origin) + Vector2.ONE * Rules.TILE_SIZE / 2.0, Vector2(560, 380))
		_begin("c1_n15_2x2_zoom")
		await _ghost(mortar, origin)
		var big: Rect2 = _cells_rect(origin, 2)
		_confirm_buttons(big, buttons[mortar].text)
		_finger(big.get_center(), true)
		_caption("MAQUETA C1 · %s (2 × 2) con zoom: el fantasma mide %.0f mm y la tilde va arriba del cuadrado" % [
			(game.available_towers[mortar] as TowerData).display_name, _mm(big.size.x)])
		await _shot("c1_n15_2x2_zoom")
		_begin("c0_n15_2x2_hoy")
		await _view_fit()
		await _ghost(mortar, origin)
		big = _cells_rect(origin, 2)
		_finger(big.get_center())
		_caption("HOY · 2 × 2 sin zoom: el cuadrado se centra en el dedo, que lo tapa entero (%.0f mm de lado)" % _mm(big.size.x))
		await _shot("c0_n15_2x2_hoy")
		await _clear_ghost()
	else:
		print("T264 el nivel 15 no tiene una torre de 2 × 2: no hay capturas de 2 × 2")
	await _view_fit()
	# C1 · casos de error: casilla no construible y borde de arriba a la derecha.
	_begin("c1_n15_invalida")
	var bad: Vector2i = _free_cell(Vector2i(13, 5), 1, false)
	await _ghost(0, bad)
	var bad_rect: Rect2 = _cells_rect(bad, 1)
	_confirm_buttons(bad_rect, "Ahí no", false)
	_caption("MAQUETA C1 · error: casilla que no se construye; fantasma rojo, la tilde apagada dice por qué; nada se cobra")
	await _shot("c1_n15_invalida")
	_begin("c1_n15_borde")
	var edge: Vector2i = _free_cell(Vector2i(25, 0))
	await _ghost(0, edge)
	var edge_rect: Rect2 = _cells_rect(edge, 1)
	_confirm_buttons(edge_rect, buttons[0].text)
	_caption("MAQUETA C1 · borde: arriba no entra la tilde, va abajo y corrida hacia adentro; nunca encima del fantasma")
	await _shot("c1_n15_borde")
	await _clear_ghost()
	# C2 · colocación automática protegida. Sin zoom, el toque NO compra: acerca el mapa alrededor del dedo.
	_begin("c2_n15_toque_acerca")
	await _view(_zoom_for_max(), game.level.cell_center(cell), rect.get_center())
	var near_rect: Rect2 = _cells_rect(cell, 1)
	_mark("ring", {"r": near_rect.grow(4.0), "c": Color(1, 0.9, 0.2)})
	_finger(near_rect.get_center(), true)
	_note(Vector2(near_rect.position.x - 140, near_rect.end.y + 16), "Casilla chica: se acercó el mapa.\nTocá de nuevo para construir.", 18)
	_zoom_controls()
	_caption("MAQUETA C2 · sin zoom el toque no compra: acerca ×%.1f alrededor del dedo (oro %d sin cambiar)" % [
		_zoom_for_max() / Rules.map_zoom(26, 12), game.session.gold])
	await _shot("c2_n15_toque_acerca")
	# C2 · con zoom suficiente, el toque construye al soltar y ofrece «Deshacer» unos segundos (devuelve todo).
	_begin("c2_n15_deshacer")
	game.build_controller.try_build(game.available_towers[0], cell)
	await _frames(2)
	_mark("panel", {"r": Rect2(Vector2(380, 516), Vector2(520, 100))})
	_note(Vector2(396, 534), "%s construido · %s de oro" % [(game.available_towers[0] as TowerData).display_name, buttons[0].text], 18)
	_button(Rect2(Vector2(726, 524), Vector2(160, 84)), "Deshacer", "normal", null, "", 20)
	_mark("progress", {"r": Rect2(Vector2(396, 590), Vector2(310, 8)), "v": 0.6})
	_zoom_controls()
	_finger(near_rect.get_center(), true)
	_caption("MAQUETA C2 · con zoom el toque construye al soltar · «Deshacer» 3 s devuelve el 100 %%")
	await _shot("c2_n15_deshacer")
	await _view_fit()
	await _end_game()


# --- Hojas de comparación: varias capturas juntas, a la mitad, en una sola imagen ---

func _sheets() -> void:
	_sheet("comparar_zoom", ["z0_n15_hoy", "z1_n15_zoom", "z0_n01_hoy", "z1_n01_zoom"])
	_sheet("comparar_tienda", ["s0_n15_barra_hoy", "s1_n15_botones_grandes", "s2_n15_tienda_cerrada", "s2_n15_tienda_abierta",
		"s3_n15_plegable_abierta", "s3_n15_plegable_cerrada"])
	_sheet("comparar_colocacion", ["c0_n01_hoy", "c1_n01_fantasma", "c1_n01_ajuste", "c1_n15_sin_zoom", "c2_n15_toque_acerca", "c2_n15_deshacer"])
	_sheet("comparar_2x2_y_errores", ["c0_n15_2x2_hoy", "c1_n15_2x2_zoom", "c1_n15_invalida", "c1_n15_borde"])


func _sheet(file_name: String, names: Array) -> void:
	var images: Array[Image] = []
	for n: String in names:
		if not _shots.has(n):
			continue
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(_shots[n]))
		if image == null:
			continue
		image.resize(image.get_width() / 2, image.get_height() / 2, Image.INTERPOLATE_LANCZOS)
		images.append(image)
	if images.is_empty():
		return
	var cell := Vector2i(images[0].get_width(), images[0].get_height())
	var margin: int = 8
	var rows: int = ceili(images.size() / 2.0)
	var sheet: Image = Image.create(cell.x * 2 + margin * 3, rows * cell.y + (rows + 1) * margin, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.25, 0.25, 0.28))
	for i: int in images.size():
		var at := Vector2i(margin + (i % 2) * (cell.x + margin), margin + (i / 2) * (cell.y + margin))
		sheet.blit_rect(images[i], Rect2i(Vector2i.ZERO, images[i].get_size()), at)
	var path: String = out_dir + "%s_%s.png" % [file_name, tag]
	sheet.save_png(path)
	print("T264 hoja ", path, " (", images.size(), " capturas)")


# --- D · Modelo de los gestos: toques y compras por error ---

## Prototipo de las reglas de gestos de T264, sin escena: recibe toques en la pantalla (px virtuales) y decide qué
## pasa. Sirve para contar y para fijar las reglas antes de la spec; NO es el código que se va a implementar.
## Modos: "C0" = hoy (compra al apoyar el primer dedo, T262 pruebas A a C); "C1" = fantasma + tilde/cruz;
## "C2" = colocación automática protegida (compra al soltar si la casilla en pantalla mide al menos `auto_px`; si no,
## el toque acerca el mapa alrededor del dedo; «Deshacer» devuelve todo).
class TouchBuildModel:
	extends RefCounted
	var mode: String = "C1"
	## Tamaño de la casilla en pantalla con el zoom actual, y dónde cae la casilla (0, 0).
	var scale: float = 48.0
	var origin := Vector2.ZERO
	var slop_px: float = 20.0
	var auto_px: float = 80.0
	var zoom_step: float = 2.0
	var armed: bool = true
	var ghost := Vector2i(-1, -1)
	var builds: Array[Vector2i] = []
	var taps: int = 0
	var gestures: int = 0
	## Correcciones: ventas (C0) o «Deshacer» (C2) por una compra en la casilla equivocada.
	var fixes: int = 0
	var _down: Dictionary = {}
	var _max_fingers: int = 0
	var _start := Vector2.ZERO
	var _moved: bool = false
	## Casillas que no se pueden construir (el camino).
	var blocked: Array[Vector2i] = []

	func cell_at(p: Vector2) -> Vector2i:
		var local: Vector2 = (p - origin) / scale
		return Vector2i(floori(local.x), floori(local.y))

	func screen_of(cell: Vector2i, offset_px: Vector2 = Vector2.ZERO) -> Vector2:
		return origin + (Vector2(cell) + Vector2(0.5, 0.5)) * scale + offset_px

	func zoom_at(p: Vector2, k: float) -> void:
		origin = p - (p - origin) * k
		scale *= k

	func press(i: int, p: Vector2) -> void:
		taps += 1
		if _down.is_empty():
			_start = p
			_moved = false
			_max_fingers = 0
		_down[i] = p
		_max_fingers = maxi(_max_fingers, _down.size())
		if mode == "C0" and armed and i == 0 and _down.size() == 1:
			_try(cell_at(p))  # hoy: cobra al apoyar (build_controller.gd:272-280, 315-317)

	func move(i: int, p: Vector2) -> void:
		if not _down.has(i):
			return
		_down[i] = p
		if (p - _start).length() > slop_px:
			_moved = true

	func release(i: int, p: Vector2) -> void:
		if not _down.has(i):
			return
		_down.erase(i)
		if not _down.is_empty():
			return  # el gesto termina cuando se levanta el último dedo
		if _max_fingers >= 2:
			gestures += 1  # pinza o arrastre de dos dedos: zoom o desplazamiento, nunca compra ni elige
			return
		if _moved:
			gestures += 1
			if (mode == "C1" or mode == "C2") and ghost.x >= 0:
				# arrastre relativo: el fantasma se corre lo mismo que el dedo
				ghost += Vector2i(roundi((p - _start).x / scale), roundi((p - _start).y / scale))
			return  # sin fantasma: un dedo que se mueve desplaza el mapa
		if not armed or mode == "C0":
			return
		var cell: Vector2i = cell_at(p)
		if mode == "C1":
			ghost = cell
		elif scale >= auto_px:
			_try(cell)
		else:
			zoom_at(p, zoom_step)
			gestures += 1

	func confirm() -> void:
		taps += 1
		if ghost.x >= 0 and _try(ghost):
			ghost = Vector2i(-1, -1)

	func undo() -> void:
		taps += 1
		if not builds.is_empty():
			builds.pop_back()

	func _try(cell: Vector2i) -> bool:
		if blocked.has(cell) or builds.has(cell):
			return false
		builds.append(cell)
		return true


func _new_model(mode: String, cell_px: float) -> TouchBuildModel:
	var m := TouchBuildModel.new()
	m.mode = mode
	m.scale = cell_px
	m.origin = Vector2(0, MAP_TOP)
	m.slop_px = _px(2.0)  # 2 mm: un toque que se mueve más es un arrastre
	m.auto_px = _px(7.6)  # C2: construye directo solo si la casilla en pantalla mide al menos 7,6 mm
	m.zoom_step = MAX_ZOOM_CELL_PX / cell_px
	m.taps = 1  # el toque en el botón de la torre
	return m


## Un toque del dedo 0 en `p`, con un pequeño movimiento `wobble` (el temblor, menor que el umbral).
func _tap_model(m: TouchBuildModel, p: Vector2, wobble: Vector2 = Vector2.ZERO) -> void:
	m.press(0, p)
	if wobble != Vector2.ZERO:
		m.move(0, p + wobble)
	m.release(0, p + wobble)


func _drag_model(m: TouchBuildModel, from: Vector2, to: Vector2) -> void:
	m.press(0, from)
	for s: int in range(1, 9):
		m.move(0, from.lerp(to, s / 8.0))
	m.release(0, to)


func _pinch_model(m: TouchBuildModel, p: Vector2, late_finger: bool) -> void:
	m.press(0, p)
	m.press(1, p + Vector2(160, 90))
	for s: int in 8:
		m.move(0, p - Vector2(s * 8, s * 5))
		m.move(1, p + Vector2(160 + s * 8, 90 + s * 5))
	if late_finger:  # un dedo se levanta antes y el otro queda apoyado un momento: sigue siendo la pinza
		m.release(1, p + Vector2(216, 125))
		m.release(0, p - Vector2(56, 35))
	else:
		m.release(0, p - Vector2(56, 35))
		m.release(1, p + Vector2(216, 125))


## Corre cada caso con los tres modos. «Persona» = lo que haría quien juega viendo la pantalla: si el fantasma quedó en
## la casilla de al lado, lo corre antes de la tilde (C1); si compró mal, vende (C0) o deshace (C2) y vuelve a tocar.
func _run_model() -> void:
	var rows: PackedStringArray = []
	var err_mm: float = 2.7  # la medida de T262: 0,6 casilla del nivel 15
	for level_name: String in ["n01", "n15"]:
		var cell_px: float = 64.0 if level_name == "n01" else 48.0
		var target_cell := Vector2i(9, 4)
		for mode: String in ["C0", "C1", "C2"]:
			for id: String in CASES:
				var m: TouchBuildModel = _new_model(mode, cell_px)
				var wanted: int = _run_case(m, id, target_cell, err_mm)
				var wrong: int = 0
				for b: Vector2i in m.builds:
					if wanted == 0 or b.y != target_cell.y or b.x < target_cell.x or b.x >= target_cell.x + wanted:
						wrong += 1
				rows.append("%s · %s · %s: toques %d · construidas %d (querían %d) · por error %d · gestos %d · ventas o deshacer %d" % [
					level_name, mode, CASES[id], m.taps, m.builds.size(), wanted, wrong, m.gestures, m.fixes])
	for r: String in rows:
		print("T264 MODELO ", r)


const CASES: Dictionary = {
	"exacto": "una torre, toque justo",
	"corrido": "una torre, el dedo cae 2,7 mm al costado",
	"temblor": "una torre, toque con temblor de 1 mm",
	"arrastre": "arrastrar 2 casillas para mover el mapa",
	"pinza": "pinza para hacer zoom",
	"rezagado": "pinza con un dedo que se levanta después",
	"cinco": "cinco torres iguales en fila (en oleada)",
	"camino": "toque en una casilla que no se puede construir",
}


## Corre un caso y devuelve cuántas torres quería construir la persona.
func _run_case(m: TouchBuildModel, id: String, cell: Vector2i, err_mm: float) -> int:
	match id:
		"exacto":
			_person_place(m, cell, Vector2.ZERO)
			return 1
		"corrido":
			_person_place(m, cell, Vector2(_px(err_mm), 0))
			return 1
		"temblor":
			_person_place(m, cell, Vector2.ZERO, Vector2(_px(1.0), 0))
			return 1
		"arrastre":
			_drag_model(m, m.screen_of(cell), m.screen_of(cell) + Vector2(m.scale * 2.0, 0))
		"pinza":
			_pinch_model(m, m.screen_of(cell), false)
		"rezagado":
			_pinch_model(m, m.screen_of(cell), true)
		"cinco":
			for k: int in 5:
				_person_place(m, cell + Vector2i(k, 0), Vector2.ZERO)
			return 5
		"camino":
			m.blocked.append(cell)
			_person_place(m, cell, Vector2.ZERO, Vector2.ZERO, false)
	return 0


## Lo que haría la persona para poner una torre en `cell` si el dedo cae con un corrimiento `offset` (px virtuales a
## zoom de hoy; con zoom se achica en casillas porque el error del dedo se mide en mm).
func _person_place(m: TouchBuildModel, cell: Vector2i, offset: Vector2, wobble: Vector2 = Vector2.ZERO, valid: bool = true) -> void:
	_tap_model(m, m.screen_of(cell, offset), wobble)
	match m.mode:
		"C0":
			if valid and not m.builds.has(cell) and not m.builds.is_empty():
				# compró en la casilla de al lado. Con la torre elegida, tocar otra torre no abre su panel: hay que soltar
				# la elección (botón), tocar la torre, «Vender» (pierde el 30 %) y volver a elegir: 4 toques más.
				m.builds.pop_back()
				m.taps += 4
				m.fixes += 1
				_tap_model(m, m.screen_of(cell))
		"C1":
			if m.ghost != cell and m.ghost.x >= 0 and valid:
				var from: Vector2 = m.screen_of(m.ghost) + Vector2(0, m.scale * 2.0)
				_drag_model(m, from, from + Vector2(cell - m.ghost) * m.scale)
			if valid:
				m.confirm()
			else:
				m.taps += 1  # ve el fantasma rojo y toca la cruz
				m.ghost = Vector2i(-1, -1)
		"C2":
			if m.builds.is_empty() or not m.builds.has(cell):
				if m.scale >= MAX_ZOOM_CELL_PX - 0.5 and not m.builds.is_empty() and valid:
					m.undo()  # construyó mal con zoom: «Deshacer» y otra vez
					m.fixes += 1
				if valid:
					_tap_model(m, m.screen_of(cell, offset), wobble)  # el mismo error en mm, ahora con la casilla grande


## Cuántos toques aciertan una casilla cuadrada de `s` mm si el dedo cae con un error normal de desvío `sigma` mm en
## cada eje, apuntando al centro: P = erf(s / (2·√2·σ))². Es un modelo para comparar tamaños, no una medición.
func _print_hit_model() -> void:
	for s: float in [4.5, 4.9, 6.0, 7.6, 9.0, 10.5]:
		var line: String = "casilla %.1f mm:" % s
		for sigma: float in [1.0, 1.5, 2.0]:
			var p: float = pow(_erf(s / (2.0 * sqrt(2.0) * sigma)), 2.0)
			line += " σ %.1f → %.0f %%" % [sigma, p * 100.0]
		print("T264 ACIERTO ", line)


## Abramowitz y Stegun 7.1.26 (error menor que 1,5e-7).
func _erf(x: float) -> float:
	var t: float = 1.0 / (1.0 + 0.3275911 * absf(x))
	var y: float = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * exp(-x * x)
	return y if x >= 0.0 else -y
