# T263: muestras de la mejora de torre en el celular. NO es un test ni cambia el juego: abre una ventana con la
# proporción de un celular, carga la partida real del nivel 1, construye torres y, encima del HUD, dibuja tres
# alternativas de panel (A, B y C) hechas con controles de Godot, para compararlas con el panel actual («antes») en
# las mismas situaciones. Los botones de las muestras funcionan: mejoran, cambian el apuntado y venden de verdad
# (con la protección que propone cada una), así que los toques simulados miden lo mismo que mediría un dedo exacto.
# No toca el guardado del jugador: usa `user://t263_upgrade_mock.json` y lo borra al terminar.
#
#   XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1600x720 res://tools/t263_upgrade_mock.tscn -- res=1600x720 tag=20x9
#
#   res=WxH      tamaño de la ventana (por omisión 1600x720, 20:9)
#   tag=texto    sufijo de los archivos (por omisión el tamaño)
#   out=ruta     carpeta de salida (por omisión res://art/t263-mejora-torre/)
#   target=WxH   pantalla del celular para traducir a mm (por omisión 2400x1080, el 1080 × 2400 acostado)
#   ppi=N        píxeles por pulgada del celular supuesto (por omisión 405)
#   sheets=0     no arma las láminas de comparación (por omisión las arma)
#
# Imprime líneas «T263 …» y deja en `out`: una captura por alternativa y situación, las láminas `lamina_*.png` y
# `medidas_<tag>.csv`. Límite honesto: un toque simulado acierta al píxel; no hay dedo, ni temblor, ni oclusión.
extends Node

## Se cargan en tiempo de ejecución, no con preload: la revisión de sintaxis (--check-only -s) compila este script sin
## los autoloads, y la partida los usa.
const GAME_SCENE_PATH: String = "res://scenes/game/game.tscn"
const THEME_PATH: String = "res://assets/ui/menu_theme.tres"
const GOLD_ICON_PATH: String = "res://assets/sprites/ui/stat_gold.svg"
const SAVE_PATH: String = "user://t263_upgrade_mock.json"
const MIN_TOUCH_MM: float = 7.6
const LOGICAL := Vector2(1280.0, 720.0)
## El mapa en la pantalla lógica (Rules: barra de arriba de 48 px y de abajo de 96 px).
const MAP_RECT := Rect2(0.0, 48.0, 1280.0, 576.0)
## Protección de Vender que proponen A, B y C: el segundo toque cuenta solo entre 0,4 y 3 s después del primero.
const SELL_CONFIRM_MIN: float = 0.4
const SELL_CONFIRM_MAX: float = 3.0
## Después de mejorar, Mejorar no responde durante 0,35 s (evita el doble toque que mejora dos veces).
const UPGRADE_LOCK: float = 0.35
const DESIGNS: Array[String] = ["antes", "a", "b", "c"]
const DESIGN_TITLES: Dictionary = {
	"antes": "Antes · panel actual",
	"a": "A · barra de la torre abajo",
	"b": "B · ficha junto a la torre",
	"c": "C · panel compacto que se corre",
}
const GOLD := Color(1.0, 0.84, 0.45)
const TEXT := Color(0.93, 0.91, 0.86)
const MUTED := Color(0.72, 0.70, 0.66)
const WARN := Color(1.0, 0.68, 0.35)
const BROWN := Color(0.52, 0.36, 0.17)

var res := Vector2i(1600, 720)
var tag: String = ""
var out_dir: String = "res://art/t263-mejora-torre/"
var target := Vector2i(2400, 1080)
var ppi: float = 405.0
var sheets: bool = true
## Sin tipo a propósito: Game, Tower y los autoloads no existen cuando se compila este script.
var game
var hud
var save_manager
var game_flow
var design: String = "antes"
## false: los botones solo anotan qué habrían hecho (para la prueba de toques corridos).
var live: bool = true
var actions: Array[String] = []
var _theme: Theme
var _gold_icon: Texture2D
var _layer: CanvasLayer
var _ui: Control
var _buttons: Dictionary = {}
var _details_open: bool = false
var _sell_armed_at: float = -1.0
var _upgrade_locked_until: float = 0.0
var _antes_saved: Dictionary = {}
var _antes_mine: Dictionary = {}
var _tower_main
var _tower_right
var _csv: PackedStringArray = ["alternativa,situacion,control,ancho_virtual,alto_virtual,ancho_mm,alto_mm,menor_a_7_6_mm"]
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
			"sheets": sheets = parts[1] != "0"
	if tag == "":
		tag = "%dx%d" % [res.x, res.y]
	if not out_dir.ends_with("/"):
		out_dir += "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	DisplayServer.window_set_size(res)
	_theme = load(THEME_PATH)
	_gold_icon = load(GOLD_ICON_PATH)
	run.call_deferred()


func _parse_size(text: String, fallback: Vector2i) -> Vector2i:
	var parts: PackedStringArray = text.split("x")
	return Vector2i(int(parts[0]), int(parts[1])) if parts.size() == 2 else fallback


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


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
	await _start_game()
	await _situations()
	await _tap_tests()
	await _flows()
	var file := FileAccess.open(out_dir + "medidas_%s.csv" % tag, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(_csv) + "\n")
	game.queue_free()
	await _frames(3)
	if sheets:
		await _make_sheets()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("T263 fin")
	get_tree().quit()


# --- Partida ---

func _start_game() -> void:
	game_flow.current_index = 0
	game_flow.current_community = null
	game_flow.intro_pending = false
	game_flow.forced_seed = 3
	game = (load(GAME_SCENE_PATH) as PackedScene).instantiate()
	add_child(game)
	await _frames(6)
	hud = game.hud
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	game.session.set_gold(4000)
	var data = game.available_towers[0]
	# Tres torres: la que se mira (columna 8), una en la columna 17 (donde el panel actual la tapa) y otra a la izquierda.
	_tower_main = _build(data, _free_cell(Vector2i(8, 4)))
	_tower_right = _build(data, _free_cell(Vector2i(17, 5)))
	_build(data, _free_cell(Vector2i(3, 6)))
	_build(game.available_towers[2], _free_cell(Vector2i(14, 2)))
	game.build_controller.placed_selection_changed.connect(func(_t) -> void: _on_selection())
	game.build_controller.tower_upgraded.connect(func(_t) -> void: _rebuild())
	game.session.gold_changed.connect(func(_g: int) -> void: _rebuild())
	await _frames(3)


func _build(data, cell: Vector2i):
	game.build_controller.try_build(data, cell)
	return game.build_controller.tower_at(cell)


func _free_cell(near: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d: float = INF
	var size: Vector2i = game.level.map_size()
	for y: int in size.y:
		for x: int in size.x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and not game.build_controller.is_occupied(cell) and Vector2(cell - near).length() < best_d:
				best_d = Vector2(cell - near).length()
				best = cell
	return best


func _tower_screen(tower) -> Vector2:
	return get_viewport().get_canvas_transform() * tower.global_position


func _selected():
	return game.build_controller.selected_placed()


func _select(tower) -> void:
	game.build_controller.deselect_placed()
	game.build_controller.select_placed(tower)
	await _frames(3)


func _set_level(tower, level: int) -> void:
	while tower.level_number() < level and tower.can_upgrade():
		tower.apply_upgrade()
	game._refresh_tower_panel()


func _set_design(name: String) -> void:
	if design == "antes" and name != "antes":
		_disconnect_antes(false)
	design = name
	_upgrade_locked_until = 0.0
	_details_open = false
	_sell_armed_at = -1.0
	_rebuild()


# --- Cada alternativa en cada situación ---

func _situations() -> void:
	for name: String in DESIGNS:
		_set_design(name)
		game.session.set_gold(4000)
		await _select(_tower_main)
		await _shot(name, "normal")
		_measure(name, "normal")
		await _select(_tower_right)
		await _shot(name, "derecha")
		_report_cover(name, "derecha", _tower_right)
		await _select(_tower_main)
		_report_cover(name, "normal", _tower_main)
		game.session.set_gold(35)
		await _frames(2)
		await _shot(name, "sin_oro")
		game.session.set_gold(4000)
		_set_level(_tower_main, 3)
		_rebuild()
		await _frames(2)
		await _shot(name, "maximo")
		_reset_level(_tower_main)
		await get_tree().create_timer(1.6).timeout  # que se borre el «+oro» de la venta antes de la próxima captura
		await _select(_tower_main)
		if name != "antes":
			_sell_armed_at = _now()
			_rebuild()
			await _frames(2)
			await _shot(name, "vender_armado")
			_sell_armed_at = -1.0
			_details_open = true
			_rebuild()
			await _frames(2)
			await _shot(name, "detalles")
			_measure(name, "detalles")
			_details_open = false
			_rebuild()
		game.build_controller.deselect_placed()
		await _frames(2)


## Vuelve la torre principal al nivel 1 reemplazándola por una nueva en la misma casilla (Tower no baja de nivel).
func _reset_level(tower) -> void:
	if tower.level_number() == 1:
		return
	var cell: Vector2i = tower.origin_cell
	var data = tower.data
	var was_main: bool = tower == _tower_main
	game.build_controller.sell(tower)
	game.session.set_gold(4000)
	var fresh = _build(data, cell)
	if was_main:
		_tower_main = fresh
	else:
		_tower_right = fresh


func _report_cover(name: String, situation: String, tower) -> void:
	var rects: Array[Rect2] = _covering_rects()
	var map_area: float = MAP_RECT.size.x * MAP_RECT.size.y
	var covered: float = 0.0
	for r: Rect2 in rects:
		covered += r.intersection(MAP_RECT).get_area()
	var pos: Vector2 = _tower_screen(tower)
	var tower_hidden: bool = false
	for r: Rect2 in rects:
		if r.has_point(pos):
			tower_hidden = true
	print("T263 tapa %s %s: %.0f %% del mapa · la torre queda debajo=%s" % [name, situation, covered / map_area * 100.0, tower_hidden])


## Los rectángulos de la interfaz de la torre que quedan encima del mapa.
func _covering_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if design == "antes":
		if hud.tower_panel.visible:
			rects.append(hud.tower_panel.get_global_rect())
		return rects
	for child: Node in _ui.get_children():
		var panel := child as Control
		if panel != null and panel.has_meta("covers"):
			rects.append(panel.get_global_rect())
	return rects


# --- La muestra: se rehace entera cada vez que cambia algo (selección, oro, nivel, Vender armado) ---

func _on_selection() -> void:
	_details_open = false
	_sell_armed_at = -1.0
	_rebuild()


func _process(_delta: float) -> void:
	if design == "antes" or game == null or not is_instance_valid(game):
		return
	hud.tower_panel.visible = false
	var redo: bool = false
	if _sell_armed_at > 0.0 and _now() - _sell_armed_at > SELL_CONFIRM_MAX:
		_sell_armed_at = -1.0  # pasó el plazo: Vender vuelve a su estado normal
		redo = true
	if _upgrade_locked_until > 0.0 and _now() > _upgrade_locked_until:
		_upgrade_locked_until = 0.0
		redo = true
	if redo:
		_rebuild()


func _rebuild() -> void:
	if _ui != null:
		_ui.queue_free()
		_ui = null
	_buttons.clear()
	if game == null or not is_instance_valid(game):
		return
	hud.get_node("BottomBar").visible = not (design == "a" and _selected() != null)
	if design == "antes":
		return
	hud.tower_panel.visible = false
	var tower = _selected()
	if tower == null:
		return
	_ui = Control.new()
	_ui.theme = _theme
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.size = LOGICAL
	_layer.add_child(_ui)
	match design:
		"a": _build_a(tower)
		"b": _build_b(tower)
		"c": _build_c(tower)


func _info(tower) -> Dictionary:
	var next = tower.next_level_stats()
	var gold: int = game.session.gold
	var s = tower.stats()
	var info: Dictionary = {
		"name": tower.data.display_name,
		"level": tower.level_number(),
		"levels": tower.data.levels.size(),
		"max": next == null,
		"cost": 0 if next == null else next.cost,
		"missing": 0 if next == null else maxi(0, next.cost - gold),
		"sell": TowerText.refund_text(game.build_controller.sell_value(tower), game.build_controller.sell_resource_value(tower)),
		"aim": tower.targeting_name(),
		"can_aim": not tower.data.support_only and not tower.is_pulse_tower(),
		"locked": _upgrade_locked_until > 0.0,
		"armed": _sell_armed_at > 0.0,
		"now": "Daño %d · %.1f/s · alcance %.1f" % [s.damage, s.fire_rate, s.range_tiles],
		"gain": "",
	}
	if next != null:
		var gains: PackedStringArray = []
		if next.damage != s.damage:
			gains.append("daño %d → %d" % [s.damage, next.damage])
		if not is_equal_approx(next.fire_rate, s.fire_rate):
			gains.append("%.1f → %.1f/s" % [s.fire_rate, next.fire_rate])
		if not is_equal_approx(next.range_tiles, s.range_tiles):
			gains.append("alcance %.1f → %.1f" % [s.range_tiles, next.range_tiles])
		info["gain"] = " · ".join(gains)
	return info


func _details_text(tower) -> String:
	var lines: PackedStringArray = [tower.data.description, "Voladores: %s" % ("sí" if tower.data.can_hit_air else "no")]
	for line: String in TowerText.effects(tower.stats()):
		lines.append(line)
	for line: String in TowerText.combo_partners(tower.data, game.available_towers):
		lines.append(line)
	return "\n".join(lines)


# Alternativa A: mientras hay una torre elegida, la barra de abajo deja de mostrar la tienda y muestra la torre.
# No tapa el mapa. Mejorar es el botón grande, Vender queda en la otra punta y pide un segundo toque.
func _build_a(tower) -> void:
	var i: Dictionary = _info(tower)
	var bar: Panel = _panel(Rect2(0, 624, 1280, 96), false)
	bar.set_meta("covers", false)
	_tower_badge(tower, Vector2(14, 632), i)
	_upgrade_button(Rect2(300, 630, 360, 84), i, 22, true)
	_buttons["info"] = _action_button("Detalles" if not _details_open else "Ocultar", Rect2(672, 630, 116, 84), 18, "normal", _toggle_details)
	var aim: Button = _action_button("Apuntar\n%s" % i["aim"], Rect2(800, 630, 150, 84), 17, "normal", _cycle_aim)
	aim.disabled = not i["can_aim"]
	_buttons["apuntar"] = aim
	_sell_button(Rect2(1032, 630, 152, 84), i, 18)
	_buttons["cerrar"] = _action_button("Cerrar", Rect2(1194, 630, 80, 84), 17, "normal", _close)
	if _details_open:
		var screen: Vector2 = _tower_screen(tower)
		var x: float = 16.0 if screen.x > 640.0 else 1280.0 - 16.0 - 420.0
		_details_panel(tower, Rect2(x, 436, 420, 180))


# Alternativa B: una ficha chica al lado de la torre (del lado con más lugar), que nunca la tapa.
func _build_b(tower) -> void:
	var i: Dictionary = _info(tower)
	var size := Vector2(300, 212)
	var screen: Vector2 = _tower_screen(tower)
	var gap: float = 44.0
	var x: float = screen.x + gap if screen.x < 640.0 else screen.x - gap - size.x
	var y: float = clampf(screen.y - size.y / 2.0, MAP_RECT.position.y + 6.0, MAP_RECT.end.y - size.y - 6.0)
	var card: Panel = _panel(Rect2(Vector2(x, y), size), true)
	card.set_meta("covers", true)
	_title_row(Vector2(x + 14, y + 10), i, size.x - 28)
	_upgrade_button(Rect2(x + 12, y + 48, size.x - 24, 84), i, 20, false)
	_buttons["info"] = _action_button("Detalles", Rect2(x + 12, y + 146, 92, 56), 16, "normal", _toggle_details)
	var aim: Button = _action_button("Apuntar\n%s" % i["aim"], Rect2(x + 112, y + 146, 82, 56), 14, "normal", _cycle_aim)
	aim.disabled = not i["can_aim"]
	aim.tooltip_text = "Apuntar"
	_buttons["apuntar"] = aim
	_sell_button(Rect2(x + size.x - 12 - 92, y + 146, 92, 56), i, 15)
	if _details_open:
		var dy: float = y + size.y + 8.0 if y + size.y + 8.0 + 150.0 < MAP_RECT.end.y else y - 8.0 - 150.0
		_details_panel(tower, Rect2(x, dy, size.x, 150))


# Alternativa C: el panel de hoy, más corto, con Mejorar grande, detalles plegados, Vender apartado y con segundo
# toque; se corre a la izquierda si la torre está en el tercio derecho del mapa.
func _build_c(tower) -> void:
	var i: Dictionary = _info(tower)
	var screen: Vector2 = _tower_screen(tower)
	var w: float = 290.0
	var h: float = 312.0 if not _details_open else 478.0
	var x: float = 1280.0 - 10.0 - w if screen.x < 853.0 else 10.0
	var y: float = 616.0 - h
	var panel: Panel = _panel(Rect2(x, y, w, h), true)
	panel.set_meta("covers", true)
	_title_row(Vector2(x + 14, y + 10), i, w - 28)
	_label(i["now"], Vector2(x + 14, y + 44), 16, MUTED, w - 28)
	var cy: float = y + 72.0
	if _details_open:
		_label(_details_text(tower), Vector2(x + 14, cy), 16, TEXT, w - 28)
		cy += 166.0
	_upgrade_button(Rect2(x + 12, cy, w - 24, 84), i, 20, false)
	_buttons["info"] = _action_button("Ver menos" if _details_open else "Ver más", Rect2(x + 12, cy + 92, (w - 32) / 2.0, 56), 16, "normal", _toggle_details)
	var aim: Button = _action_button("Apuntar\n%s" % i["aim"], Rect2(x + 20 + (w - 32) / 2.0, cy + 92, (w - 32) / 2.0, 56), 15, "normal", _cycle_aim)
	aim.disabled = not i["can_aim"]
	_buttons["apuntar"] = aim
	_sell_button(Rect2(x + w - 12 - 140, cy + 92 + 56 + 24, 140, 52), i, 16)


# --- Piezas de las muestras ---

func _style(color: Color, border: Color, width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(8)
	box.content_margin_left = 6
	box.content_margin_right = 6
	return box


func _panel(rect: Rect2, shadow: bool) -> Panel:
	var panel := Panel.new()
	var box: StyleBoxFlat = _style(Color(0.105, 0.11, 0.125, 0.97), BROWN, 2)
	if shadow:
		box.shadow_color = Color(0, 0, 0, 0.4)
		box.shadow_size = 5
	else:
		box.set_corner_radius_all(0)
	panel.add_theme_stylebox_override("panel", box)
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP  # un toque en el fondo del panel no pasa al mapa
	_ui.add_child(panel)
	return panel


func _label(text: String, pos: Vector2, font: int, color: Color, width: float = -1.0) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if width > 0.0:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(width, 0)
	_ui.add_child(label)
	label.position = pos
	if width > 0.0:
		label.size = Vector2(width, 0)
	return label


## Nivel con puntos: lleno los alcanzados, vacío los que faltan.
func _pips(pos: Vector2, filled: int, total: int, d: float = 12.0) -> void:
	for n: int in total:
		var dot := Panel.new()
		var box: StyleBoxFlat = _style(GOLD if n < filled else Color(0, 0, 0, 0), GOLD, 2)
		box.set_corner_radius_all(int(d / 2.0))
		dot.add_theme_stylebox_override("panel", box)
		dot.position = pos + Vector2(n * (d + 5.0), 0)
		dot.size = Vector2(d, d)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui.add_child(dot)


func _title_row(pos: Vector2, i: Dictionary, width: float) -> void:
	_label(i["name"], pos, 20, GOLD, width - 70.0)
	_pips(pos + Vector2(width - 46.0, 9.0), i["level"], i["levels"])


func _tower_badge(tower, pos: Vector2, i: Dictionary) -> void:
	var index: int = game.available_towers.find(tower.data)
	if index >= 0:
		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = hud._tower_buttons[index].icon
		icon.position = pos + Vector2(0, 14)
		icon.size = Vector2(52, 52)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui.add_child(icon)
	_label(i["name"], pos + Vector2(66, 2), 20, GOLD, 210)
	_label("Nivel %d de %d" % [i["level"], i["levels"]], pos + Vector2(66, 30), 16, TEXT)
	_pips(pos + Vector2(180, 36), i["level"], i["levels"])
	_label(i["now"], pos + Vector2(66, 56), 14, MUTED, 220)


func _action_button(text: String, rect: Rect2, font: int, kind: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font)
	var base: Color = Color(0.16, 0.17, 0.19)
	var border: Color = BROWN
	var font_color: Color = TEXT
	match kind:
		"primary":
			base = Color(0.80, 0.56, 0.18)
			border = Color(1.0, 0.82, 0.45)
			font_color = Color(0.10, 0.07, 0.03)
		"blocked":
			base = Color(0.20, 0.20, 0.22)
			border = Color(0.45, 0.40, 0.33)
			font_color = WARN
		"done":
			base = Color(0.14, 0.15, 0.17)
			border = Color(0.45, 0.40, 0.33)
			font_color = GOLD
		"danger":
			border = Color(0.72, 0.28, 0.22)
			font_color = Color(1.0, 0.66, 0.6)
		"danger_armed":
			base = Color(0.66, 0.16, 0.12)
			border = Color(1.0, 0.5, 0.4)
			font_color = Color.WHITE
	for state: String in ["normal", "hover", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, _style(base, border, 3 if kind == "primary" else 2))
	button.add_theme_stylebox_override("pressed", _style(base.darkened(0.25), border, 2))
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		button.add_theme_color_override(state, font_color if state != "font_disabled_color" or kind != "normal" else MUTED)
	button.pressed.connect(callback)
	_ui.add_child(button)
	return button


## Mejorar: dice qué pasa (a qué nivel), cuánto cuesta con el ícono del oro y, si no alcanza, cuánto falta.
## El texto va en etiquetas propias (no en el del botón) para ordenar dos renglones y el costo a la derecha.
func _upgrade_button(rect: Rect2, i: Dictionary, font: int, show_gain: bool) -> void:
	var kind: String = "primary"
	var title: String = "Mejorar"
	var sub: String = "A nivel %d" % [i["level"] + 1]
	if i["gain"] != "":
		sub += " · " + i["gain"] if show_gain else "\n" + i["gain"]
	if i["max"]:
		kind = "done"
		title = "Nivel máximo"
		sub = "Ya no se puede mejorar"
	elif i["missing"] > 0:
		kind = "blocked"
		sub = "Faltan %d de oro" % i["missing"]
		title = "Mejorar a nivel %d" % [i["level"] + 1] if show_gain else "Mejorar"
	elif i["locked"]:
		title = "¡Nivel %d!" % i["level"]
		sub = ""
	var button: Button = _action_button("", rect, font, kind, _press_upgrade)
	_buttons["mejorar"] = button
	var ink: Color = Color(0.10, 0.07, 0.03) if kind == "primary" else (WARN if kind == "blocked" else GOLD)
	_label(title, rect.position + Vector2(12, 8), font + 2, ink)
	if sub != "":
		_label(sub, rect.position + Vector2(12, 10 + font * 1.4), font - 6, ink if kind != "primary" else Color(0.22, 0.15, 0.05), rect.size.x - 24)
	if not i["max"]:
		# El costo, grande y a la derecha, con el ícono del oro.
		var cost: Label = _label(str(i["cost"]), Vector2(rect.end.x - 76, rect.position.y + 6), font + 8, ink)
		cost.size.x = 64
		cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _gold_icon
		icon.size = Vector2(28, 28)
		icon.position = Vector2(rect.end.x - 108, rect.position.y + 13)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui.add_child(icon)


func _sell_button(rect: Rect2, i: Dictionary, font: int) -> void:
	var armed: bool = i["armed"]
	var text: String = "¿Vender?\nTocá otra vez" if armed else "Vender\n+%s" % i["sell"]
	_buttons["vender"] = _action_button(text, rect, font, "danger_armed" if armed else "danger", _press_sell)


func _details_panel(tower, rect: Rect2) -> void:
	var panel: Panel = _panel(rect, true)
	panel.set_meta("covers", true)
	_label(_details_text(tower), rect.position + Vector2(14, 12), 16, TEXT, rect.size.x - 28)


# --- Lo que hacen los botones de las muestras ---

func _press_upgrade() -> void:
	if _upgrade_locked_until > 0.0:
		actions.append("mejorar_bloqueado")
		return
	actions.append("mejorar")
	if live and game.build_controller.try_upgrade(_selected()):
		_upgrade_locked_until = _now() + UPGRADE_LOCK
		_rebuild()


func _press_sell() -> void:
	var now: float = _now()
	if _sell_armed_at > 0.0 and now - _sell_armed_at >= SELL_CONFIRM_MIN and now - _sell_armed_at <= SELL_CONFIRM_MAX:
		actions.append("vender")
		_sell_armed_at = -1.0
		if live:
			game.build_controller.sell(_selected())
		_rebuild()
		return
	if _sell_armed_at > 0.0:
		actions.append("vender_muy_rapido")  # segundo toque antes de 0,4 s: no vende y sigue armado
		return
	actions.append("vender_armado")
	_sell_armed_at = now
	_rebuild()


func _toggle_details() -> void:
	actions.append("detalles")
	_details_open = not _details_open
	_rebuild()


func _cycle_aim() -> void:
	actions.append("apuntar")
	if live:
		_selected().cycle_targeting()
	_rebuild()


func _close() -> void:
	actions.append("cerrar")
	game.build_controller.deselect_placed()


## En «antes» los botones son los del panel real: para anotar sin mejorar ni vender, se cambian sus conexiones.
func _disconnect_antes(record: bool) -> void:
	var panel = hud.tower_panel
	if record and _antes_saved.is_empty():
		for signal_name: String in ["upgrade_pressed", "sell_pressed", "targeting_pressed"]:
			var saved: Array = []
			for connection: Dictionary in panel.get(signal_name).get_connections():
				saved.append(connection["callable"])
				panel.get(signal_name).disconnect(connection["callable"])
			_antes_saved[signal_name] = saved
		var mine: Dictionary = {"upgrade_pressed": _record.bind("mejorar"), "sell_pressed": _record.bind("vender"),
			"targeting_pressed": _record.bind("apuntar")}
		for signal_name: String in mine:
			panel.get(signal_name).connect(mine[signal_name])
		_antes_mine = mine
	elif not record and not _antes_saved.is_empty():
		for signal_name: String in _antes_mine:
			panel.get(signal_name).disconnect(_antes_mine[signal_name])
		_antes_mine = {}
		for signal_name: String in _antes_saved:
			for callable: Callable in _antes_saved[signal_name]:
				panel.get(signal_name).connect(callable)
		_antes_saved.clear()


func _record(action: String) -> void:
	actions.append(action)


# --- Toques simulados ---

func _frames(count: int) -> void:
	for n: int in count:
		await get_tree().process_frame


func _to_window(pos: Vector2) -> Vector2:
	return get_viewport().get_final_transform() * pos


func _touch(logical: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = pressed
	event.position = _to_window(logical)
	Input.warp_mouse(event.position)  # BuildController lee el mouse (ver T262, prueba A0)
	await _frames(1)
	Input.parse_input_event(event)
	await _frames(2)


func _tap(logical: Vector2) -> void:
	await _touch(logical, true)
	await _touch(logical, false)


func _sell_rect() -> Rect2:
	if design == "antes":
		return hud.tower_panel.get_node("%SellButton").get_global_rect()
	return (_buttons["vender"] as Control).get_global_rect()


func _upgrade_rect() -> Rect2:
	if design == "antes":
		return hud.tower_panel.get_node("%UpgradeButton").get_global_rect()
	return (_buttons["mejorar"] as Control).get_global_rect()


## Un dedo que apunta a Mejorar y cae corrido 0 a 96 px virtuales (0 a 9 mm en el celular supuesto) hacia cada lado. Se anota qué hizo
## cada toque, sin mejorar ni vender de verdad. Después, el doble toque en Mejorar y la venta a propósito.
func _tap_tests() -> void:
	for name: String in DESIGNS:
		_set_design(name)
		game.session.set_gold(4000)
		live = false
		if name == "antes":
			_disconnect_antes(true)
		await _select(_tower_main)
		var center: Vector2 = _upgrade_rect().get_center()
		var counts: Dictionary = {}
		var detail: PackedStringArray = []
		for direction: Vector2 in [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2(1, 1).normalized(), Vector2(-1, 1).normalized()]:
			for d: int in [0, 12, 24, 36, 48, 60, 72, 84, 96]:
				if d == 0 and direction != Vector2.DOWN:
					continue
				await _select(_tower_main)
				_sell_armed_at = -1.0
				_details_open = false
				_rebuild()
				await _frames(2)
				actions.clear()
				await _tap(center + direction * d)
				var result: String = ",".join(actions) if not actions.is_empty() else ("mapa:deselecciona" if _selected() == null else ("mapa:otra_torre" if _selected() != _tower_main else "nada"))
				counts[result] = counts.get(result, 0) + 1
				detail.append("%s%d=%s" % [_dir_name(direction), d, result])
		print("T263 toques corridos %s (49 toques alrededor de Mejorar): %s" % [name, counts])
		print("T263 toques corridos %s detalle: %s" % [name, " ".join(detail)])
		# Un toque suelto en Vender, y dos toques seguidos a 3 cuadros (el dedo que «rebota»): ¿vende?
		for repeat: int in [1, 2]:
			await _select(_tower_main)
			_sell_armed_at = -1.0
			_rebuild()
			await _frames(2)
			actions.clear()
			var sell_center: Vector2 = _sell_rect().get_center()
			for n: int in repeat:
				await _tap(sell_center)
			print("T263 %d toque(s) seguidos en Vender %s: %s" % [repeat, name, actions])
		# Doble toque rápido en Mejorar (dos toques a 3 cuadros): cuántas mejoras haría.
		live = true
		if name == "antes":
			_disconnect_antes(false)
		_reset_level(_tower_main)
		await _select(_tower_main)
		var level_before: int = _tower_main.level_number()
		center = _upgrade_rect().get_center()
		await _tap(center)
		await _tap(center)
		await _frames(2)
		print("T263 doble toque en Mejorar %s: nivel %d -> %d" % [name, level_before, _tower_main.level_number()])
		_reset_level(_tower_main)
		game.session.set_gold(4000)
		game.build_controller.deselect_placed()
		await _frames(2)


func _dir_name(direction: Vector2) -> String:
	if direction.x > 0.0 and direction.y > 0.0:
		return "abajo_der"
	if direction.x < 0.0 and direction.y > 0.0:
		return "abajo_izq"
	return {Vector2.DOWN: "abajo", Vector2.UP: "arriba", Vector2.LEFT: "izq", Vector2.RIGHT: "der"}[direction]


## Los flujos con toques de verdad: mejorar dos veces, ver detalles, vender a propósito. Cuenta los toques.
func _flows() -> void:
	for name: String in DESIGNS:
		_set_design(name)
		live = true
		game.session.set_gold(4000)
		game.build_controller.deselect_placed()
		await _frames(2)
		var taps: int = 0
		# Mejorar una vez y otra: tocar la torre, Mejorar, esperar, Mejorar.
		await _tap(_tower_screen(_tower_main))
		taps += 1
		await _tap(_upgrade_rect().get_center())
		taps += 1
		var after_one: int = _tower_main.level_number()
		await get_tree().create_timer(0.5).timeout
		await _tap(_upgrade_rect().get_center())
		taps += 1
		print("T263 flujo mejorar %s: nivel 1 -> %d con 2 toques, -> %d con %d toques" % [name, after_one, _tower_main.level_number(), taps])
		# Vender a propósito la torre de la derecha.
		game.build_controller.deselect_placed()
		await _frames(2)
		var towers_before: int = game.tower_container.get_child_count()
		actions.clear()
		taps = 0
		await _tap(_tower_screen(_tower_right))
		taps += 1
		var sell_rect: Rect2 = hud.tower_panel.get_node("%SellButton").get_global_rect() if name == "antes" else (_buttons["vender"] as Control).get_global_rect()
		var visible: bool = _selected() == _tower_right
		await _tap(sell_rect.get_center())
		taps += 1
		if game.tower_container.get_child_count() == towers_before:
			await get_tree().create_timer(0.6).timeout
			await _tap(sell_rect.get_center())
			taps += 1
		await _frames(3)
		print("T263 flujo vender %s: torre elegida=%s · vendida=%s con %d toques · botones: %s" % [name, visible,
			game.tower_container.get_child_count() < towers_before, taps, actions])
		_tower_right = _build(game.available_towers[0], _free_cell(Vector2i(17, 5)))
		_reset_level(_tower_main)
		game.build_controller.deselect_placed()
		await _frames(2)


# --- Capturas, medidas y láminas ---

func _shot(name: String, situation: String) -> void:
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
	var path: String = out_dir + "%s_%s_%s.png" % [name, situation, tag]
	framed.save_png(path)
	_shots["%s_%s" % [name, situation]] = framed
	print("T263 captura ", path)


func _measure(name: String, situation: String) -> void:
	var scale_target: float = minf(target.x / LOGICAL.x, target.y / LOGICAL.y)
	var controls: Dictionary = {}
	if name == "antes":
		for key: String in ["TargetingButton", "UpgradeButton", "SellButton"]:
			controls[key] = hud.tower_panel.get_node("%" + key)
	else:
		controls = _buttons
	for key: String in controls:
		var rect: Rect2 = (controls[key] as Control).get_global_rect()
		var mm: Vector2 = rect.size * scale_target / ppi * 25.4
		_csv.append("%s,%s,%s,%.0f,%.0f,%.1f,%.1f,%s" % [name, situation, key, rect.size.x, rect.size.y, mm.x, mm.y,
			"sí" if minf(mm.x, mm.y) < MIN_TOUCH_MM else "no"])
	var up: Rect2 = _upgrade_rect()
	var sell: Rect2 = hud.tower_panel.get_node("%SellButton").get_global_rect() if name == "antes" else (_buttons["vender"] as Control).get_global_rect()
	var gap: float = _rect_gap(up, sell)
	print("T263 medidas %s %s: Mejorar %.1f × %.1f mm · distancia Mejorar–Vender %.0f px virtuales = %.1f mm" % [name, situation,
		up.size.x * scale_target / ppi * 25.4, up.size.y * scale_target / ppi * 25.4, gap, gap * scale_target / ppi * 25.4])


func _rect_gap(a: Rect2, b: Rect2) -> float:
	var dx: float = maxf(0.0, maxf(b.position.x - a.end.x, a.position.x - b.end.x))
	var dy: float = maxf(0.0, maxf(b.position.y - a.end.y, a.position.y - b.end.y))
	return Vector2(dx, dy).length()


## Láminas de comparación: la misma situación en las cuatro alternativas (2 × 2), y todos los estados de cada una.
func _make_sheets() -> void:
	for situation: String in ["normal", "derecha", "sin_oro", "maximo"]:
		var keys: Array[String] = []
		var titles: Array[String] = []
		for name: String in DESIGNS:
			keys.append("%s_%s" % [name, situation])
			titles.append(DESIGN_TITLES[name])
		await _sheet("lamina_%s" % situation, keys, titles, 2)
	for name: String in ["a", "b", "c"]:
		var keys: Array[String] = []
		var titles: Array[String] = []
		for situation: String in ["normal", "sin_oro", "maximo", "vender_armado", "detalles", "derecha"]:
			keys.append("%s_%s" % [name, situation])
			titles.append("%s · %s" % [DESIGN_TITLES[name], situation.replace("_", " ")])
		await _sheet("lamina_estados_%s" % name, keys, titles, 2)


func _sheet(file_name: String, keys: Array[String], titles: Array[String], columns: int) -> void:
	var first: Image = _shots[keys[0]]
	var cell := Vector2i(first.get_width() / 2, first.get_height() / 2)
	var caption: int = 34
	var rows: int = ceili(keys.size() / float(columns))
	var root := Control.new()
	root.size = Vector2(columns * cell.x, rows * (cell.y + caption))
	var background := ColorRect.new()
	background.color = Color(0.06, 0.06, 0.07)
	background.size = root.size
	root.add_child(background)
	for n: int in keys.size():
		var image: Image = (_shots[keys[n]] as Image).duplicate()
		image.resize(cell.x, cell.y, Image.INTERPOLATE_LANCZOS)
		var pos := Vector2((n % columns) * cell.x, (n / columns) * (cell.y + caption))
		var title := Label.new()
		title.text = titles[n]
		title.position = pos + Vector2(12, 4)
		title.add_theme_font_size_override("font_size", 20)
		title.add_theme_color_override("font_color", GOLD)
		root.add_child(title)
		var texture := TextureRect.new()
		texture.texture = ImageTexture.create_from_image(image)
		texture.position = pos + Vector2(0, caption)
		root.add_child(texture)
	# La lámina se dibuja en una SubViewport de su tamaño exacto, sin el marco de la ventana.
	var viewport := SubViewport.new()
	viewport.size = Vector2i(root.size)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.add_child(root)
	add_child(viewport)
	await _frames(2)
	await RenderingServer.frame_post_draw
	var path: String = out_dir + "%s_%s.png" % [file_name, tag]
	viewport.get_texture().get_image().save_png(path)
	print("T263 lámina ", path)
	viewport.queue_free()
	await _frames(1)
