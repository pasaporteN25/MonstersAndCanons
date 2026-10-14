extends Node

const CAPTURE_DIR: String = "res://art/t250-tarjeta-nivel/captures/after/"
const TARGETS: Array[int] = [0, 5, 7, 9]

func _ready() -> void:
	call_deferred("capture")

func capture() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var select: Control = get_tree().current_scene
	var save_path: String = SaveManager.save_path
	SaveManager.save_path = "user://test_t250_capture.json"
	for index: int in TARGETS:
		var states: Array[bool] = []
		if index == 0:
			states.append(true)
		else:
			states.append(false)
			states.append(true)
		for unlocked: bool in states:
			SaveManager.load_save()
			if index == 0 or unlocked:
				SaveManager.unlock(GameFlow.level(index).id)
				SaveManager.record_victory(GameFlow.level(index).id, 15)
				if index > 0:
					SaveManager.record_victory(GameFlow.level(index - 1).id, 18)
			select.show_page(&"campaign")
			for frame: int in 8:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var state: String = "unlocked" if index == 0 or unlocked else "locked"
			var path: String = CAPTURE_DIR + "level_%02d_%s.png" % [index + 1, state]
			var image: Image = select.get_viewport().get_texture().get_image()
			image.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
			print("T250 capture: ", path, " ", image.get_size(), " -> ", image.save_png(path))
	SaveManager.save_path = save_path
	if FileAccess.file_exists("user://test_t250_capture.json"):
		DirAccess.remove_absolute("user://test_t250_capture.json")
	get_tree().quit()
