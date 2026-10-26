# T513: captura y mide el panel de torre de la PC (ficha PC-A, RF-721) para las capturas de RF-686.
# Variante de `capture_t510_panel.gd` (T510) con las medidas del panel nuevo. No cambia nada del juego: arma una partida en
# memoria con un guardado temporal que borra al terminar. Se corre con ventana, desde la carpeta del proyecto y con la
# salida FUERA del repo (ruta absoluta):
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t513_panel.gd -- /ruta/de/salida fullscreen
#   DISPLAY=:0 godot --path . -s /ruta/absoluta/capture_t513_panel.gd -- /ruta/de/salida 1280x720
# Escribe `T513-<caso>-<WxH>.png` (recorte del panel, tamaño real de pantalla) y `medidas-pc-<WxH>.tsv`
# (ancho y alto en px lógicos, si hay barra de desplazamiento y el renglón más ancho).
extends SceneTree

const GAME_PATH: String = "res://scenes/game/game.tscn"
const TEMP_SAVE: String = "user://capture_t513_panel.json"

## [id, nivel, con oro]. «sin oro» deja el oro por debajo del costo de la mejora para ver «Mejorar» apagado.
const PC_CASES: Array = [
	["cannon", 1, true], ["cannon", 2, true], ["cannon", 3, true],
	["tesla", 1, true], ["tesla", 2, true], ["tesla", 3, true],
	["frost", 1, true], ["frost", 2, true], ["frost", 3, true],
	["disruptor", 1, true], ["disruptor", 2, true], ["disruptor", 3, true],
	["fire", 1, true], ["mortar", 2, true], ["sniper", 1, true], ["multi", 2, true], ["burst", 1, true],
	["basic", 1, false], ["mechanical_standard", 1, true], ["mechanical_standard", 3, true],
]

var _out: String = "user://capturas"
var _tsv: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else _out
	var mode: String = "pc"
	var size_arg: String = args[1] if args.size() > 1 else "fullscreen"
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
	save.set_setting("ui_mode", 2)
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
	print("T513: modo %s · ventana %s · escala %s" % [mode, suffix, root.get_final_transform().get_scale()])
	_tsv.append("caso\tancho_logico\talto_logico\tdesplazamiento\talto_contenido\talto_lista\ttextos")
	var cases: Array = PC_CASES
	for case: Array in cases:
		await _case(game, mode, String(case[0]), int(case[1]), bool(case[2]), suffix)
	var file := FileAccess.open("%s/medidas-%s-%s.tsv" % [_out, mode, suffix], FileAccess.WRITE)
	file.store_string("\n".join(_tsv) + "\n")
	file.close()
	game.queue_free()
	await _frames(3)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.save_path = save.DEFAULT_PATH
	save.load_save()
	print("T513: listo · %s" % _out)
	quit(0)


func _case(game: Node, mode: String, id: String, level: int, with_gold: bool, suffix: String) -> void:
	game.session.gold = 1000000
	var tower: Node = _build(game, id)
	if tower == null:
		print("T513: no se pudo construir %s (se omite)" % id)
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
	var panel: Control = game.hud.tower_panel
	_measure_pc(panel, name)
	_shot_rect(_screen_rect(panel).grow(6), "T513-%s-%s.png" % [name, suffix])
	if (id == "tesla" and level == 1) or (id == "frost" and level == 3):
		_shot_full("T513-pantalla-%s-%s.png" % [name, suffix])
	game.build_controller.deselect_placed()
	await _frames(2)


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


## Alto y ancho del panel en px lógicos, si la lista tiene barra de desplazamiento y el renglón más ancho sin cortar.
func _measure_pc(panel: Control, name: String) -> void:
	var details: ScrollContainer = panel.get_node("%Details")
	var content: Control = panel.get_node("%Content")
	var scroll_bar: bool = details.get_v_scroll_bar().visible
	var widest: float = 0.0
	var texts: PackedStringArray = []
	for label: Label in panel.find_children("*", "Label", true, false):
		if not label.is_visible_in_tree():
			continue
		var font: Font = label.get_theme_font("font")
		var font_size: int = label.get_theme_font_size("font_size")
		for line: String in label.text.split("\n"):
			widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		texts.append(label.text.replace("\n", " ⏎ "))
	_tsv.append("%s\t%.0f\t%.0f\t%s\t%.0f\t%.0f\t%s" % [name, panel.size.x, panel.size.y, "CON BARRA" if scroll_bar else "sin barra",
		content.get_combined_minimum_size().y, details.size.y, " | ".join(texts)])
	print("T513 pc · %s · panel %.0f × %.0f px lógicos · %s" % [name, panel.size.x, panel.size.y, "CON BARRA" if scroll_bar else "sin barra"])


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
