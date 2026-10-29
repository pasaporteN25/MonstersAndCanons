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
	"end_defeat",
	"end_victory",
	"res://scenes/game/hud.tscn",
	"res://scenes/editor/map_editor.tscn",
	"editor_settings",
	"editor_waves",
	"editor_objects",
	"editor_open",
	"editor_save_mode",
	"editor_error",
	"res://scenes/editor/banner_editor.tscn",
	"dev_panel",
	"res://scenes/ui/exit_dialog.tscn",
	"res://scenes/ui/level_intro.tscn",
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
		if args.size() > 3 and args[3] == "en":
			_report_spanish(screen, holder)
		holder.queue_free()
		await get_tree().process_frame
	get_node("/root/DevMode").call("set_enabled", false, "user://save.json")
	get_tree().quit()


func _open(screen: String) -> Node:
	var path: String = screen
	if screen.begins_with("options"):
		path = "res://scenes/ui/main_menu.tscn"
	elif screen == "pause_options":
		path = "res://scenes/ui/pause_menu.tscn"
	elif screen == "credits":
		path = ""
	elif screen == "end_defeat" or screen == "end_victory":
		path = "res://scenes/ui/end_screen.tscn"
	elif screen.begins_with("editor_"):
		path = "res://scenes/editor/map_editor.tscn"
		get_node("/root/GameFlow").set("editor_draft", null)  # cada captura arranca con un borrador nuevo (si no, queda «con cambios sin guardar»)
	elif screen == "dev_panel":
		path = "res://scenes/game/game.tscn"
		get_node("/root/DevMode").call("set_enabled", true, "user://capture_pruebas.json")
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
	elif screen == "res://scenes/ui/exit_dialog.tscn":
		node.call("open", "Cántaro")
	elif screen == "res://scenes/ui/level_intro.tscn":
		node.call("open", "Level", "Place", "Text")
	elif screen == "editor_settings":
		node.call("show_panel", node.call("settings_panel"), true)
	elif screen == "editor_waves":
		node.call("show_panel", node.call("waves_panel"), true)
	elif screen == "editor_objects":
		for pair: Array in [[7, Vector2i(2, 1)], [5, Vector2i(3, 1)], [8, Vector2i(4, 1)]]:  # escombro, árbol, mina
			node.call("set_tool", pair[0])
			node.call("paint_at", pair[1])
		node.call("show_panel", node.call("objects_panel"), true)
	elif screen == "editor_open":
		node.call("open_level")
	elif screen == "editor_save_mode":
		node.call("save_to_mode")
	elif screen == "editor_error":
		node.get("draft").call("apply_tool", 1, Vector2i(0, (node.get("draft").call("rows") as PackedStringArray).size() / 2))  # un camino tapa la entrada A
		node.call("refresh")
	elif screen == "dev_panel":
		node.get("dev_panel").call("toggle")
	elif screen == "end_defeat":
		node.call("show_defeat", 7, 10, true, 320, "Against flyers, try Machine Gun and Sniper.")
	elif screen == "end_victory":
		node.call("show_victory", 4, 3, true, true, 540, "")
	return node


const SPANISH_MARKS: PackedStringArray = ["á", "é", "í", "ó", "ú", "ñ", "¿", "¡"]
const SPANISH_WORDS: PackedStringArray = [" de ", " el ", " la ", " los ", " las ", " para ", " que ", " con ", " una ", " del ", " y ", " en ", " no ",
		"nivel", "torre", "oleada", "guardar", "volver", "cancelar", "aceptar", "salir", "abrir", "oro", "vidas"]


## T534: en modo inglés, lista los textos visibles (y los tooltips) que parecen españoles, para revisarlos a mano: el Lore
## (lugares, nombres de nivel, Cántaro y Compañía Meridiana) aparece acá a propósito.
func _report_spanish(screen: String, holder: Node) -> void:
	var found: Array[String] = []
	for node: Node in holder.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree():
			continue
		var texts: Array[String] = [control.tooltip_text]
		if control is Label or control is BaseButton:
			texts.append(String(control.get("text")))
		elif control is RichTextLabel:
			texts.append((control as RichTextLabel).get_parsed_text())
		elif control is LineEdit:
			texts.append((control as LineEdit).placeholder_text)
		for text: String in texts:
			var padded: String = " " + text.to_lower() + " "
			var spanish: bool = false
			for mark: String in SPANISH_MARKS:
				spanish = spanish or padded.contains(mark)
			for word: String in SPANISH_WORDS:
				spanish = spanish or padded.contains(word if word.begins_with(" ") else " " + word)
			if spanish and text.strip_edges() != "":
				found.append("%s: %s" % [control.name, text.replace("\n", " ⏎ ").left(80)])
	print("  ESPAÑOL en %s: %d %s" % [screen, found.size(), found.slice(0, 12)])


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
