# Tests de sonido, opciones y menú de pausa (T46-T48, RF-113, RF-114, RF-116).
extends GutTest

const TEST_PATH: String = "user://test_save.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()
	Audio.apply_volumes()


# --- Sonidos (RF-116) ---

func test_every_game_event_has_a_sound() -> void:
	var needed: Array[StringName] = [&"enemy_death", &"life_lost", &"build", &"upgrade", &"sell",
		&"wave_start", &"victory", &"defeat", &"click", &"music_loop"]
	var game: Node = GAME_SCENE.instantiate()
	for tower: TowerData in game.get("tower_types"):
		needed.append(StringName("shot_%s" % tower.id))
	game.free()  # solo se creó para leer la lista de torres
	for sound: StringName in needed:
		assert_true(Audio.has_sound(sound), "falta el sonido %s" % sound)


func test_music_loops() -> void:
	# Al importar el .wav, Godot pierde el bucle si no se lo pide en music_loop.wav.import.
	var music: AudioStreamWAV = load("res://assets/audio/music_loop.wav")
	assert_eq(music.loop_mode, AudioStreamWAV.LOOP_FORWARD, "la música no se corta a los 40 s")


func test_play_returns_false_for_unknown_sounds() -> void:
	assert_false(Audio.play(&"no_existe"))


func test_same_sound_is_not_repeated_too_fast() -> void:
	assert_true(Audio.play(&"shot_basic"))
	assert_false(Audio.play(&"shot_basic"), "con 40 torres sería ensordecedor")


func test_music_and_sfx_have_their_own_buses() -> void:
	assert_ne(AudioServer.get_bus_index(&"Music"), -1)
	assert_ne(AudioServer.get_bus_index(&"SFX"), -1)


# --- Opciones (RF-113) ---

func test_volume_zero_mutes_the_bus() -> void:
	SaveManager.set_setting("music_volume", 0.0)
	Audio.apply_volumes()
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Music")))
	SaveManager.set_setting("music_volume", 0.5)
	Audio.apply_volumes()
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Music")))
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), linear_to_db(0.5), 0.01)


func test_options_menu_saves_on_close() -> void:
	var options: OptionsMenu = (load("res://scenes/ui/options_menu.tscn") as PackedScene).instantiate()
	add_child_autofree(options)
	options.open()
	(options.get_node("%SfxSlider") as HSlider).value = 0.3
	options.close()
	SaveManager.load_save()  # como si se cerrara el juego
	assert_almost_eq(float(SaveManager.get_setting("sfx_volume")), 0.3, 0.001)


# --- Menú de pausa (RF-114) ---

func test_escape_opens_the_pause_menu_and_pauses() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.open_pause_menu()
	var paused: bool = get_tree().paused
	var menu_open: bool = game.pause_menu.is_open()
	game.close_pause_menu()
	assert_true(paused)
	assert_true(menu_open)
	assert_false(get_tree().paused, "Continuar quita la pausa")
	assert_false(game.pause_menu.is_open())


## RF-142: el botón "atrás" de Android hace lo mismo que Esc (no cierra el juego).
func test_android_back_button_opens_the_pause_menu() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	GameFlow.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await wait_process_frames(2)  # el Esc simulado se entrega en el frame siguiente
	var menu_open: bool = game.pause_menu.is_open()
	game.close_pause_menu()
	assert_true(menu_open)
	assert_false(ProjectSettings.get_setting("application/config/quit_on_go_back"),
		"Android no cierra el juego de golpe")


func test_pause_menu_does_not_open_after_game_over() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.lose_lives(100)
	game.open_pause_menu()
	var menu_open: bool = game.pause_menu.is_open()
	get_tree().paused = false
	assert_false(menu_open)
