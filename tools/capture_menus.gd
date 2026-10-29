# Capturas reales de los menús (M61, T310): instancia cada pantalla en el tamaño de ventana que se pida,
# con la interfaz forzada a celular o a PC, y guarda un PNG por pantalla. Se corre con ventana (no `--headless`):
#   godot --path . res://tools/capture_menus.tscn -- /ruta/de/salida 1280x720 mobile|pc [es|en]
# El idioma (T534) es opcional y solo vale para esta corrida (no se guarda): sin él, el de siempre.
# Imprime, por pantalla, qué botones quedan fuera de la ventana virtual (1280 × 720).
extends Node

const SCREENS: Array[String] = [
	"res://scenes/ui/main_menu.tscn",
	"res://scenes/ui/tools_hub.tscn",
	"options",
	"options_admin",
	"res://scenes/ui/level_select.tscn",
	"res://scenes/ui/records_screen.tscn",
	"res://scenes/ui/wiki_screen.tscn",
	"res://scenes/ui/pause_menu.tscn",
	"pause_options",
	"credits",
]


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://capturas"
	DirAccess.make_dir_recursive_absolute(out)
	var mode: String = args[2] if args.size() > 2 else "mobile"
	if args.size() > 1:
		var parts: PackedStringArray = args[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		var resolution := Vector2i(int(parts[0]), int(parts[1]))
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_window().content_scale_size = resolution
		get_window().size = resolution
		get_window().position = Vector2i.ZERO
		for _i: int in 10:
			await get_tree().process_frame
	get_node("/root/SaveManager").call("set_setting", "ui_mode", 1 if mode == "mobile" else 2)
	if args.size() > 3:
		get_node("/root/SaveManager").call("set_setting", "language", args[3])
	print("ventana %s, contenido %s, modo %s" % [get_window().size, get_window().content_scale_size, mode])
	for screen: String in SCREENS:
		var holder: Node = await _open(screen)
		for _i: int in 4:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_%s%s.png" % [out, mode, screen.get_file().get_basename(), "_" + args[3] if args.size() > 3 else ""])
		_report(screen, holder, get_viewport().get_visible_rect().size)
		holder.queue_free()
		await get_tree().process_frame
	get_tree().quit()


func _open(screen: String) -> Node:
	var path: String = screen
	if screen.begins_with("options"):
		path = "res://scenes/ui/main_menu.tscn"
	elif screen == "pause_options":
		path = "res://scenes/ui/pause_menu.tscn"
	elif screen == "credits":
		path = ""
	var node: Node
	if path == "":
		node = (load("res://scenes/ui/credits_screen.gd") as GDScript).new()
	else:
		node = (load(path) as PackedScene).instantiate()
	add_child(node)
	await get_tree().process_frame
	if screen == "options":
		node.get("_options").open()
	elif screen == "options_admin":
		node.get("_options").admin_available = true
		node.get("_options")._refresh_admin()
		node.get("_options").open()
	elif screen == "pause_options" or screen == "res://scenes/ui/pause_menu.tscn":
		node.open()
		if screen == "pause_options":
			node.call("_open_options")
	elif screen == "credits":
		node.open()
	return node


## Lo que está dentro de un `ScrollContainer` se alcanza desplazando: no cuenta como recorte.
func _inside_scroll(control: Control, holder: Node) -> bool:
	var parent: Node = control.get_parent()
	while parent != null and parent != holder:
		if parent is ScrollContainer:
			return true
		parent = parent.get_parent()
	return false


func _report(screen: String, holder: Node, bounds: Vector2) -> void:
	var bad: Array[String] = []
	var small: Array[String] = []
	for node: Node in holder.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree() or _inside_scroll(control, holder):
			continue
		var rect: Rect2 = control.get_global_rect()
		if control is Button and (rect.end.y > bounds.y + 0.5 or rect.end.x > bounds.x + 0.5 or rect.position.y < -0.5):
			bad.append("%s %s" % [control.name, rect])
	for node: Node in holder.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and button.size.y < 55.5:
			small.append("%s %.0f" % [button.name, button.size.y])
	for node: Node in holder.find_children("*", "ScrollContainer", true, false):
		var scroll: ScrollContainer = node as ScrollContainer
		if scroll.is_visible_in_tree() and scroll.get_child_count() > 0 and scroll.get_child(0) is Control:
			var content: Control = scroll.get_child(0) as Control
			print("  desplazable %s: %s, contenido %s (mínimo %s), barra %s visible=%s" % [scroll.name, scroll.size, content.size, content.get_combined_minimum_size(), scroll.get_v_scroll_bar().size.x, scroll.get_v_scroll_bar().visible])
	print("%s: botones fuera = %d %s; menores de 56 px = %d %s" % [screen, bad.size(), bad.slice(0, 4), small.size(), small.slice(0, 5)])
