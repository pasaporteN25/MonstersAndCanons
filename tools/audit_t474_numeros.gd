# Auditoría real de números con cero inicial (T474, RF-695). Con ventana (no `--headless`):
#   godot --path . res://tools/audit_t474_numeros.tscn -- /ruta/de/salida 1280x720 pc|mobile
# Abre cada pantalla con números (selector en mapa y en tarjetas, comunidad y modos, récords, Wiki, final de nivel,
# entrada, juego con su HUD, editor), la guarda en PNG y escribe una línea por pantalla con los ceros iniciales
# que encontró en sus textos y tooltips (`LeadingZeroAudit`). Usa un guardado temporal con todo desbloqueado.
extends Node

const TEMP_SAVE: String = "user://test_audit_t474.json"

var _out: String = "user://capturas"
var _mode: String = "pc"
var _total: int = 0


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else _out
	_mode = args[2] if args.size() > 2 else _mode
	DirAccess.make_dir_recursive_absolute(_out)
	if args.size() > 1:
		var parts: PackedStringArray = args[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		var resolution := Vector2i(int(parts[0]), int(parts[1]))
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_window().content_scale_size = Vector2i(1280, 720)
		get_window().size = resolution
		get_window().position = Vector2i.ZERO
		for _i: int in 10:
			await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var original_path: String = String(save.get("save_path"))
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	save.set("save_path", TEMP_SAVE)
	save.call("load_save")
	save.call("set_setting", "ui_mode", 1 if _mode == "mobile" else 2)
	var flow: Node = get_node("/root/GameFlow")
	for i: int in int(flow.call("level_count")):
		var level: Object = flow.call("level", i)
		save.call("unlock", level.get("id"))
		if i < 9:
			save.call("record_victory", level.get("id"), 20 if i % 3 == 0 else (10 if i % 3 == 1 else 1), 500 + i)
	await _select("campaign_map", 1)
	await _select("campaign_cards", 0)
	for page: StringName in [&"community", &"mode:asedio"]:
		await _select(String(page), 2, page)
	await _records()
	await _wiki()
	await _end_screens()
	await _game()
	print("TOTAL con cero inicial: %d" % _total)
	save.set("save_path", original_path)
	save.call("load_save")
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	get_tree().quit()


func _show(name: String, node: Node) -> void:
	for _i: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [_out, _mode, name])
	var problems: PackedStringArray = LeadingZeroAudit.scan(node)
	_total += problems.size()
	print("%s: %s" % [name, "OK (sin ceros iniciales)" if problems.is_empty() else "%d problemas" % problems.size()])
	for line: String in problems:
		print("   ", line)


func _select(name: String, style: int, page: StringName = &"campaign") -> void:
	get_node("/root/SaveManager").call("set_setting", "selector_style", style)
	var select: Control = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child(select)
	await get_tree().process_frame
	select.call("show_page", page)
	await _show("selector_" + name, select)
	select.queue_free()
	await get_tree().process_frame


func _records() -> void:
	var records: Control = (load("res://scenes/ui/records_screen.tscn") as PackedScene).instantiate()
	add_child(records)
	await get_tree().process_frame
	for i: int in int(records.call("map_count")):
		records.call("show_level", i)
		var problems: PackedStringArray = LeadingZeroAudit.scan(records)
		_total += problems.size()
		for line: String in problems:
			print("records nivel %d: %s" % [i + 1, line])
	records.call("show_level", 8)
	await _show("records_nivel9", records)
	records.call("show_level", 9)
	await _show("records_nivel10", records)
	records.queue_free()
	await get_tree().process_frame


func _wiki() -> void:
	var wiki: Control = (load("res://scenes/ui/wiki_screen.tscn") as PackedScene).instantiate()
	add_child(wiki)
	await get_tree().process_frame
	var seen: int = 0
	for category: StringName in wiki.call("category_ids"):
		wiki.call("show_category", category)
		for entry: StringName in wiki.call("entry_ids"):
			wiki.call("show_entry", entry)
			seen += 1
			var problems: PackedStringArray = LeadingZeroAudit.scan(wiki)
			_total += problems.size()
			for line: String in problems:
				print("wiki %s/%s: %s" % [category, entry, line])
	print("wiki: %d artículos recorridos" % seen)
	await _show("wiki", wiki)
	wiki.queue_free()
	await get_tree().process_frame


func _end_screens() -> void:
	var end: Node = (load("res://scenes/ui/end_screen.tscn") as PackedScene).instantiate()
	add_child(end)
	await get_tree().process_frame
	end.call("show_victory", 7, 2, true, true, 1234, "Nivel 5 ganado")
	await _show("fin_victoria", end)
	end.call("show_defeat", 9, 10, true, 345, "")
	await _show("fin_derrota", end)
	end.queue_free()
	var intro: Node = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
	add_child(intro)
	await get_tree().process_frame
	intro.call("open", "Nivel 5 · Nido", "El lindero", "Texto de entrada.", &"bosque")
	await _show("entrada_nivel", intro)
	intro.queue_free()
	await get_tree().process_frame


func _game() -> void:
	var flow: Node = get_node("/root/GameFlow")
	for index: int in [4, 9]:
		var game: Node = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
		game.set("level_data", flow.call("level", index))
		add_child(game)
		for _i: int in 8:
			await get_tree().process_frame
		await _show("juego_nivel%d" % (index + 1), game)
		game.queue_free()
		await get_tree().process_frame
