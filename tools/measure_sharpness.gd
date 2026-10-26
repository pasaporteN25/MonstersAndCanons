# Medición de nitidez de T476 (RF-707): captura las mismas pantallas con la presentación nueva ("host":
# SubViewportContainer con render adaptado al marco) y con la anterior ("native": contenido directo bajo
# la ventana con stretch canvas_items), para compararlas luego con tools/compare_sharpness.py.
# Necesita ventana real (no `--headless`) y se corre una vez por modo:
#   DISPLAY=:0 godot --path . --windowed --resolution 1920x1080 --position 0,0 res://tools/measure_sharpness.tscn -- /ruta/salida host
#   DISPLAY=:0 godot --path . --windowed --resolution 1920x1080 --position 0,0 res://tools/measure_sharpness.tscn -- /ruta/salida native
#   python3 tools/compare_sharpness.py /ruta/salida
# Opcional, 3.er argumento: "WxH" (tamaño forzado), "fs" (pantalla completa) o "xfs" (completa exclusiva),
# si el compositor no respeta --resolution.
# Escribe <modo>_<pantalla>.png y <modo>_info.json (resolución pedida/reportada, render target, hardware,
# build, uptime y carga). No mide rendimiento: solo nitidez de lo que se dibuja.
extends Node

const HOST_SCENE: PackedScene = preload("res://scenes/host/presentation_host.tscn")
const SCREENS: Array[String] = [
	"res://scenes/ui/main_menu.tscn",
	"res://scenes/ui/level_select.tscn",
	"res://scenes/ui/wiki_screen.tscn",
	"res://scenes/game/game.tscn",
]

var _out: String = "user://nitidez"
var _mode: String = "host"
var _host: Node
var _info: Dictionary = {}
var _lever: String = "base"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_mode = args[1]
	if args.size() > 3:
		_lever = args[3]
	DirAccess.make_dir_recursive_absolute(_out)
	var window: Window = get_window()
	if args.size() > 2 and args[2] == "fs":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif args.size() > 2 and args[2] == "xfs":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif args.size() > 2:
		var parts: PackedStringArray = args[2].split("x")
		window.size = Vector2i(int(parts[0]), int(parts[1]))
	for _i: int in 20:
		await get_tree().process_frame
	_info = {
		"modo": _mode,
		"ventana_tamano": [window.size.x, window.size.y],
		"ventana_modo": DisplayServer.window_get_mode(),
		"pantalla_tamano": [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y],
		"pantalla_escala": DisplayServer.screen_get_scale(),
		"cmdline": Array(OS.get_cmdline_args()),
		"godot": Engine.get_version_info().get("string", ""),
		"driver": RenderingServer.get_video_adapter_name(),
		"driver_version": RenderingServer.get_video_adapter_api_version(),
		"renderer": str(ProjectSettings.get_setting("rendering/renderer/rendering_method")),
		"display_driver": DisplayServer.get_name(),
		"pantallas": {},
	}
	for screen: String in SCREENS:
		await _capture(screen)
	var file: FileAccess = FileAccess.open("%s/%s_info.json" % [_out, _mode], FileAccess.WRITE)
	file.store_string(JSON.stringify(_info, "\t"))
	file.close()
	get_tree().quit()


# Palancas de nitidez a probar (T476 seguimiento). "base" no toca nada. Solo experimento: lo que
# resulte útil se aplica en el host, no aquí.
func _apply_lever(viewport: SubViewport) -> void:
	var frame: Control = viewport.get_parent() as Control
	var scale: float = frame.size.x / 1280.0
	match _lever:
		"os_scale":
			viewport.oversampling_override = scale
		"os_x2":
			viewport.oversampling_override = 2.0
		"os_x3":
			viewport.oversampling_override = 3.0
		"os_flag_off":
			viewport.oversampling = false
		"os_flag_on":
			viewport.oversampling = true
		"filter_linear_mip":
			viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		"filter_nearest":
			viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST


func _capture(path: String) -> void:
	var name: String = path.get_file().get_basename()
	var packed: PackedScene = load(path) as PackedScene
	var content: Node
	var render: Vector2i = Vector2i.ZERO
	var scale: float = 1.0
	if _mode == "host":
		_host = HOST_SCENE.instantiate()
		add_child(_host)
		await get_tree().process_frame
		_host.install_scene(packed)
		_apply_lever(_host.get_content_viewport())
		content = _host.get_active_screen()
	else:
		content = packed.instantiate()
		add_child(content)
	for _i: int in 30:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var root_image: Image = get_viewport().get_texture().get_image()
	root_image.save_png("%s/%s_%s.png" % [_out, _mode, name])
	if _mode == "host":
		var viewport: SubViewport = _host.get_content_viewport()
		render = viewport.size
		var frame: Control = viewport.get_parent() as Control
		scale = frame.size.x / 1280.0
		_info["pantallas"][name] = {
			"raiz_viewport": [root_image.get_width(), root_image.get_height()],
			"subviewport_size": [render.x, render.y],
			"size_2d_override": [viewport.size_2d_override.x, viewport.size_2d_override.y],
			"marco_pos": [frame.position.x, frame.position.y],
			"marco_size": [frame.size.x, frame.size.y],
			"escala_2d": scale,
			"palanca": _lever,
			"oversampling": viewport.get_oversampling(),
			"oversampling_override": viewport.oversampling_override,
			"oversampling_flag": viewport.oversampling,
			"root_oversampling": get_tree().root.get_oversampling(),
		}
	else:
		var win: Window = get_window()
		_info["pantallas"][name] = {
			"raiz_viewport": [root_image.get_width(), root_image.get_height()],
			"content_scale_mode": win.content_scale_mode,
			"content_scale_size": [win.content_scale_size.x, win.content_scale_size.y],
			"canvas_transform_escala": get_viewport().get_final_transform().get_scale().x,
			"oversampling": get_viewport().get_oversampling(),
		}
	if _host != null:
		_host.queue_free()
		_host = null
	else:
		content.queue_free()
	for _i: int in 5:
		await get_tree().process_frame
