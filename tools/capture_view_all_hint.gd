extends Node

const TEMP_SAVE: String = "user://capture_view_all_hint.json"

var _game: Game
var _output: String = "user://captures"


func _ready() -> void:
	call_deferred("capture")


func capture() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if not args.is_empty():
		_output = args[0]
	DirAccess.make_dir_recursive_absolute(_output)
	var original_path: String = SaveManager.save_path
	SaveManager.save_path = TEMP_SAVE
	SaveManager.load_save()
	SaveManager.mark_tutorial_done()
	SaveManager.set_setting("tutorial_enabled", false)
	GameFlow.current_index = 14
	GameFlow.intro_pending = false
	for mobile: bool in [false, true]:
		var prefs: UiPrefs = SaveManager.get_ui_prefs()
		prefs.view_all_hint_seen = false
		SaveManager.set_ui_prefs(prefs)
		SaveManager.set_setting("ui_mode", UiMode.MOBILE if mobile else UiMode.PC)
		_game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate() as Game
		add_child(_game)
		await _frames(4)
		if _game.level_intro.is_open():
			_game.level_intro.close()
		_game.camera_controller._zoom_at(Vector2(640, 360), 1.2)
		await _frames(2)
		var capture_name: String = "celular" if mobile else "pc"
		var image: Image = get_viewport().get_texture().get_image()
		image.save_png("%s/T464-ver-todo-%s.png" % [_output, capture_name])
		_game.queue_free()
		await _frames(3)
		get_tree().paused = false
		Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	SaveManager.save_path = original_path
	SaveManager.load_save()
	get_tree().quit()


func _frames(count: int) -> void:
	for _index: int in count:
		await get_tree().process_frame
