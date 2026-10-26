# T514: captura y mide la barra de la torre elegida del celular SIMULADO (ui_mode celular, ventana de 1280 × 720).
# Sirve para el «antes» (barra de T511) y para el «después» (CEL-B, RF-722). No cambia nada del juego: arma una
# partida en memoria con un guardado temporal (`user://capture_t514_bar.json`) que borra al terminar.
# Se corre con ventana, desde la carpeta del proyecto y con la salida FUERA del repo (ruta absoluta):
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t514_bar.gd -- /ruta/de/salida antes
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t514_bar.gd -- /ruta/de/salida despues
# Escribe `T514-<etiqueta>-<caso>-1280x720.png` (la barra, con 40 px de mapa encima) y `medidas-<etiqueta>.tsv` con
# el rectángulo de cada hijo de la barra (px lógicos) y la distancia entre «Mejorar» y «Vender».
extends SceneTree

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_t514_bar.json"

## [id, nivel, "oro" | "sin_oro" | "armado"]
const CASES: Array = [
	["tesla", 1, "oro"], ["frost", 1, "oro"], ["frost", 3, "oro"], ["cannon", 3, "oro"],
	["mechanical_standard", 1, "oro"], ["disruptor", 1, "oro"],
	["tesla", 1, "armado"], ["basic", 1, "sin_oro"],
]

var _out: String = "user://capturas"
var _label: String = "despues"
var _tsv: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else _out
	_label = args[1] if args.size() > 1 else _label
	DirAccess.make_dir_recursive_absolute(_out)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	root.size = Vector2i(1280, 720)
	root.position = Vector2i.ZERO
	await _frames(15)
	var save: Node = root.get_node("/root/SaveManager")
	var flow: Node = root.get_node("/root/GameFlow")
	save.save_path = TEMP_SAVE
	save.load_save()
	save.set_setting("ui_mode", 1)
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
	print("T514: %s · escala %s" % [_label, root.get_final_transform().get_scale()])
	_tsv.append("caso\tnodo\tx\ty\tancho\talto\tnota")
	for case: Array in CASES:
		await _case(game, String(case[0]), int(case[1]), String(case[2]))
	var file := FileAccess.open("%s/medidas-%s.tsv" % [_out, _label], FileAccess.WRITE)
	file.store_string("\n".join(_tsv) + "\n")
	file.close()
	game.queue_free()
	await _frames(3)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	quit(0)


func _case(game: Node, id: String, level: int, mode: String) -> void:
	game.session.gold = 1000000
	var tower: Node = _build(game, id)
	if tower == null:
		print("T514: no se pudo construir %s" % id)
		return
	while tower.level_number() < level:
		if not game.build_controller.try_upgrade(tower):
			break
	if mode == "sin_oro" and tower.can_upgrade():
		game.session.gold = maxi(0, tower.next_level_stats().cost - 25)
	game.build_controller.select_placed(tower)
	game._refresh_tower_panel()
	await _frames(5)
	if mode == "armado":
		game.mobile_hud._on_upgrade_pressed()
		await _frames(10)
	var name: String = "%s-n%d%s" % [id, level, "" if mode == "oro" else "-" + mode.replace("_", "-")]
	_measure(game, name)
	var bar: Control = game.mobile_hud._status_bar
	var rect: Rect2 = root.get_final_transform() * (bar.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, bar.size))
	var image: Image = root.get_texture().get_image()
	var clipped := Rect2i(Rect2(rect.position - Vector2(0, 40), rect.size + Vector2(0, 40))).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	image.get_region(clipped).save_png("%s/T514-%s-celular-%s-1280x720.png" % [_out, _label, name])
	if (id == "tesla" and mode == "armado") or (id == "frost" and level == 1):
		image.save_png("%s/T514-%s-celular-pantalla-%s-1280x720.png" % [_out, _label, name])
	game.build_controller.deselect_placed()
	await _frames(2)


func _measure(game: Node, name: String) -> void:
	var hud: Node = game.mobile_hud
	var nodes: Array = [hud._status_label, hud._bottom_cancel, hud._target_button, hud._upgrade_button, hud._sell_gap, hud._sell_button]
	for control: Control in nodes:
		if control == null or not control.visible:
			continue
		var text: String = ""
		if control is Label:
			text = (control as Label).text.replace("\n", " ⏎ ") + " · letra %d" % (control as Label).get_theme_font_size("font_size")
		elif control is Button:
			text = (control as Button).text.replace("\n", " ⏎ ") + (" (apagado)" if (control as Button).disabled else "")
		_tsv.append("%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%s" % [name, control.name, control.global_position.x, control.global_position.y,
			control.size.x, control.size.y, text])
	var up: Control = hud._upgrade_button
	var sell: Control = hud._sell_button
	var gap: float = sell.global_position.x - (up.global_position.x + up.size.x)
	_tsv.append("%s\tseparacion_mejorar_vender\t\t\t%.1f\t\t borde a borde, px lógicos" % [name, gap])
	print("T514 · %s · Mejorar→Vender %.1f px · barra %.0f×%.0f" % [name, gap, hud._status_bar.size.x, hud._status_bar.size.y])


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


func _frames(count: int) -> void:
	for _i: int in count:
		await process_frame
