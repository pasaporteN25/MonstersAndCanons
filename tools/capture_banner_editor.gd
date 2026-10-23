## T443 RF-665: captura el hub y el editor a resoluciones de escritorio.
extends Node

const SCREENS: Dictionary = {
	"hub": "res://scenes/ui/tools_hub.tscn",
	"editor": "res://scenes/editor/banner_editor.tscn",
}


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://capturas_t443"
	var dimensions: PackedStringArray = (args[1] if args.size() > 1 else "1280x720").split("x")
	var resolution := Vector2i(int(dimensions[0]), int(dimensions[1]))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_window().content_scale_size = resolution
	get_window().size = resolution
	get_window().position = Vector2i.ZERO
	for _i: int in 10:
		await get_tree().process_frame
	for screen: String in SCREENS:
		var node: Control = (load(SCREENS[screen]) as PackedScene).instantiate()
		add_child(node)
		for _i: int in 10:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var path: String = "%s/%s_%s.png" % [out, resolution.x, screen]
		var error: Error = get_viewport().get_texture().get_image().save_png(path)
		if error != OK:
			push_error("No se pudo guardar %s: %s" % [path, error])
		else:
			print("Captura: %s" % path)
		node.queue_free()
		await get_tree().process_frame
	get_tree().quit()
