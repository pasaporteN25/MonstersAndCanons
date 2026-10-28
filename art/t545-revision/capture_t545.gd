# T545: capturas reales (1280x720) del registro de lore: selector, entrada, victoria, epílogo y créditos.
# Se corre con ventana: godot --path . res://art/t545-revision/capture_t545.tscn
extends Node

const OUT: String = "res://art/t545-revision/captures/"
const SAVE: String = "user://test_t545_capture.json"


func _ready() -> void:
	call_deferred("run")


func shot(name_: String) -> void:
	for _i: int in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: String = ProjectSettings.globalize_path(OUT + name_ + ".png")
	get_viewport().get_texture().get_image().save_png(path)
	print("captura ", path)


func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	get_window().position = Vector2i.ZERO
	for _i: int in 10:
		await get_tree().process_frame
	var save: Node = get_node("/root/SaveManager")
	var flow: Node = get_node("/root/GameFlow")
	save.set("save_path", SAVE)
	save.call("load_save")
	save.call("set_setting", "ui_mode", 2)
	for n: int in range(1, 15):
		save.call("record_victory", StringName("level_%02d" % n), 15, 1000)
	var select: Node = (load("res://scenes/ui/level_select.tscn") as PackedScene).instantiate()
	add_child(select)
	await shot("selector")
	select.queue_free()
	await get_tree().process_frame
	for n: int in range(1, 16):
		var data: LevelData = flow.level(n - 1)
		var intro: LevelIntro = (load("res://scenes/ui/level_intro.tscn") as PackedScene).instantiate()
		add_child(intro)
		intro.open(data.display_name, data.place_text, data.intro_text, data.theme)
		await shot("entrada_%02d" % n)
		intro.queue_free()
		await get_tree().process_frame
	for n: int in [1, 8, 10, 15]:
		var data2: LevelData = flow.level(n - 1)
		var end: Node = (load("res://scenes/ui/end_screen.tscn") as PackedScene).instantiate()
		add_child(end)
		end.call("show_victory", 15, 3, n < 15, true, 1000, data2.win_text, n == 15)
		await shot("victoria_%02d" % n)
		end.queue_free()
		await get_tree().process_frame
	var ep: EpilogueScreen = EpilogueScreen.new()
	add_child(ep)
	ep.open(flow.level(14).epilogue_text)
	await shot("epilogo")
	ep.open_credits()
	await shot("creditos")
	ep.queue_free()
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	get_tree().quit()
