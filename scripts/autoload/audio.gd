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
## Extensiones que se cargan de `assets/audio/`. Los efectos y la música de menú son `.wav` sintetizados;
## la música de combate son `.mp3` de terceros (RF-751, D-235).
const AUDIO_EXTENSIONS: PackedStringArray = ["wav", "mp3", "ogg"]
const MENU_TRACK: StringName = &"music_menu"
const GAME_SCENE_PATH: String = "res://scenes/game/game.tscn"
## RF-751: las pistas de combate, en el orden en que se turnan. Cada vez que se entra a una partida suena la
## siguiente. Son «Tower Defense Theme» y «Tower Defense Theme 3», de DST (CC0; ver LICENCIAS-TERCEROS.md).
const COMBAT_TRACKS: Array[StringName] = [&"music_combat_dst_theme", &"music_combat_dst_theme_3"]
## Volumen de la música antes del bus del usuario. Es de mezcla, no de balance.
const MUSIC_VOLUME_DB: float = -5.0
## Las pistas grabadas vienen masterizadas mucho más fuerte que la síntesis propia: se bajan para que
## los efectos y los avisos se sigan oyendo (RF-354). Medido en T591: su volumen medio (RMS) es unos 7 dB más
## alto que el de la música de menú; con -12 dB quedan parejas. Una pista que no figura acá usa MUSIC_VOLUME_DB.
const TRACK_VOLUME_DB: Dictionary = {
	&"music_combat_dst_theme": -12.0,
	&"music_combat_dst_theme_3": -12.0,
}

var _streams: Dictionary = {}      # { &"shot_basic": AudioStream }
var _last_played: Dictionary = {}  # { &"shot_basic": segundos desde el inicio }
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _music: AudioStreamPlayer
var _music_track: StringName = &""
var _music_tween: Tween
var _next_alert_voice: int = 9
var _screen_check_left: float = 0.0
var _variation: int = 0
var _in_combat: bool = false
var _combat_index: int = -1


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


## Reproduce un efecto por su nombre (el nombre del archivo de audio sin extensión).
## `min_repeat` = cuánto tiene que pasar desde la última vez que sonó (RF-316: el combo pide más).
## Devuelve false si no se reprodujo (no existe, o sonó hace muy poco).
func play(sound: StringName, min_repeat: float = MIN_REPEAT_SECONDS) -> bool:
	var stream: AudioStream = _streams.get(sound)
	if stream == null:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	var shot: bool = String(sound).begins_with("shot_") or sound == &"impact"
	var gap: float = maxf(min_repeat, 0.08 if shot else 0.0)
	if now - float(_last_played.get(sound, -1.0)) < gap:
		return false
	_last_played[sound] = now
	var voice: AudioStreamPlayer = _voices[_next_voice if shot else _next_alert_voice]
	if shot:
		_next_voice = (_next_voice + 1) % 9
	else:
		_next_alert_voice = 9 + (_next_alert_voice - 9 + 1) % 3
	_variation += 1
	voice.pitch_scale = [0.97, 1.0, 1.03][_variation % 3] if shot else 1.0
	voice.volume_db = -9.0 if shot else (-5.0 if sound == &"heal" else -2.0)
	voice.stream = stream
	voice.play()
	return true


func has_sound(sound: StringName) -> bool:
	return _streams.has(sound)


func play_music(track: StringName = MENU_TRACK) -> void:
	var loop: AudioStream = _streams.get(track)
	if loop == null or (_music_track == track and _music.playing):
		return
	_music_track = track
	var volume: float = music_volume_db(track)
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if not _music.playing:
		_music.stream = loop
		_music.volume_db = volume
		_music.play()
		return
	_music_tween = create_tween()
	_music_tween.tween_property(_music, "volume_db", -35.0, 0.2)
	_music_tween.tween_callback(func() -> void:
		_music.stream = loop
		_music.play())
	_music_tween.tween_property(_music, "volume_db", volume, 0.3)


## El volumen de mezcla de una pista (antes del bus «Music» que maneja el jugador).
func music_volume_db(track: StringName) -> float:
	return float(TRACK_VOLUME_DB.get(track, MUSIC_VOLUME_DB))


## RF-751: qué pista le toca a la pantalla actual. Fuera de la partida, la de menú. Al **entrar** a una partida
## se pasa a la siguiente pista de combate, y esa misma sigue mientras no se salga (reintentar no la cambia).
func music_for_screen(in_game: bool) -> StringName:
	if not in_game:
		_in_combat = false
		return MENU_TRACK
	if not _in_combat:
		_in_combat = true
		_combat_index = (_combat_index + 1) % COMBAT_TRACKS.size()
	return COMBAT_TRACKS[_combat_index]


func _process(delta: float) -> void:
	_screen_check_left -= delta
	if _screen_check_left > 0.0:
		return
	_screen_check_left = 0.25
	var screen: Node = GameFlow.current_screen()
	if screen != null:
		play_music(music_for_screen(screen.scene_file_path == GAME_SCENE_PATH))


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
		if AUDIO_EXTENSIONS.has(file.get_extension()):
			_streams[StringName(file.get_basename())] = load(SOUNDS_DIR + file)
