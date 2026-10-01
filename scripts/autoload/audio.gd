# Sonidos y música (RF-116, plan §7). Es un autoload: se usa como `Audio`.
# - Efectos por el bus "SFX", música por el bus "Music" (RF-113: volumen de cada uno).
# - La música sigue sonando al cambiar de pantalla, porque este nodo nunca se borra.
extends Node

## Máximo de efectos sonando a la vez. Si se llena, se corta el más viejo.
const MAX_VOICES: int = 12
## Un mismo sonido no se repite antes de este tiempo: con 40 torres disparando,
## reproducir cada disparo sería ensordecedor.
const MIN_REPEAT_SECONDS: float = 0.05
const SOUNDS_DIR: String = "res://assets/audio/"
const SFX_BUS: StringName = &"SFX"
const MUSIC_BUS: StringName = &"Music"

var _streams: Dictionary = {}      # { &"shot_basic": AudioStream }
var _last_played: Dictionary = {}  # { &"shot_basic": segundos desde el inicio }
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _music: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # los clics suenan también en pausa
	_load_streams()
	for i: int in MAX_VOICES:
		var voice := AudioStreamPlayer.new()
		voice.bus = SFX_BUS
		add_child(voice)
		_voices.append(voice)
	_music = AudioStreamPlayer.new()
	_music.bus = MUSIC_BUS
	add_child(_music)
	apply_volumes()
	play_music()


## Al cerrar el juego: cortar la música y soltar los sonidos, así no quedan en memoria.
func _exit_tree() -> void:
	_music.stop()
	_music.stream = null
	for voice: AudioStreamPlayer in _voices:
		voice.stop()
		voice.stream = null


## Reproduce un efecto por su nombre (el nombre del .wav sin extensión).
## `min_repeat` = cuánto tiene que pasar desde la última vez que sonó (RF-316: el combo pide más).
## Devuelve false si no se reprodujo (no existe, o sonó hace muy poco).
func play(sound: StringName, min_repeat: float = MIN_REPEAT_SECONDS) -> bool:
	var stream: AudioStream = _streams.get(sound)
	if stream == null:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - float(_last_played.get(sound, -1.0)) < min_repeat:
		return false
	_last_played[sound] = now
	var voice: AudioStreamPlayer = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = stream
	voice.play()
	return true


func has_sound(sound: StringName) -> bool:
	return _streams.has(sound)


func play_music() -> void:
	var loop: AudioStream = _streams.get(&"music_loop")
	if loop != null and not _music.playing:
		_music.stream = loop
		_music.play()


## RF-113: aplica los volúmenes guardados (0 = silencio, 1 = máximo).
func apply_volumes() -> void:
	_set_bus_volume(MUSIC_BUS, float(SaveManager.get_setting("music_volume")))
	_set_bus_volume(SFX_BUS, float(SaveManager.get_setting("sfx_volume")))


## Conecta el sonido de clic a todos los botones dentro de `root` (y sus hijos).
func add_click_sounds(root: Node) -> void:
	for node: Node in root.find_children("*", "BaseButton", true, false):
		var button := node as BaseButton
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	play(&"click")


func _set_bus_volume(bus_name: StringName, linear: float) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	if bus < 0:
		return
	AudioServer.set_bus_mute(bus, linear <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(linear, 0.0001)))


func _load_streams() -> void:
	for file: String in ResourceLoader.list_directory(SOUNDS_DIR):
		if file.ends_with(".wav"):
			_streams[StringName(file.get_basename())] = load(SOUNDS_DIR + file)
