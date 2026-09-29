# Genera los sonidos y la música del juego SINTETIZÁNDOLOS con código (T48).
# No se descarga nada: cada sonido es una suma de ondas (seno, cuadrada, triángulo,
# ruido) con su "envolvente" (cómo sube y se apaga el volumen).
#
# Uso (desde la carpeta del proyecto):
#   godot --headless --path . -s tools/make_sounds.gd
#   godot --headless --path . -s tools/make_sounds.gd -- shot_fire shot_tesla   (solo esos)
#
# Escribe los .wav en assets/audio/. Para cambiar un sonido por uno mejor,
# basta con reemplazar el .wav con el mismo nombre.
#
# OJO con la música: al importar el .wav, Godot NO respeta el bucle guardado.
# El bucle se pide en assets/audio/music_loop.wav.import (edit/loop_mode=2,
# o en el editor: panel Importar → Loop Mode: Forward). Lo vigila un test.
extends SceneTree

const RATE: int = 22050
const OUT_DIR: String = "res://assets/audio/"

enum Wave { SINE, SQUARE, TRIANGLE, NOISE }

## Si se pasan nombres después de `--`, solo se escriben esos sonidos (los demás no se tocan).
var _only: PackedStringArray = []


func _init() -> void:
	_only = OS.get_cmdline_user_args()
	seed(20260929)  # el ruido sale siempre igual: regenerar no cambia los archivos
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	# --- Disparos (uno por torre) ---
	_save("shot_basic", _tone(Wave.SQUARE, 900.0, 600.0, 0.05, 0.25))
	_save("shot_cannon", _mix([_tone(Wave.SINE, 130.0, 55.0, 0.28, 0.7), _tone(Wave.NOISE, 0.0, 0.0, 0.18, 0.35)]))
	_save("shot_frost", _mix([_tone(Wave.SINE, 1400.0, 1300.0, 0.16, 0.25), _tone(Wave.SINE, 2100.0, 2000.0, 0.12, 0.15)]))
	_save("shot_sniper", _mix([_tone(Wave.NOISE, 0.0, 0.0, 0.07, 0.5), _tone(Wave.SQUARE, 320.0, 160.0, 0.1, 0.3)]))
	# M5: soplido de fuego (ruido que se apaga) con un tono grave.
	_save("shot_fire", _mix([_tone(Wave.NOISE, 0.0, 0.0, 0.22, 0.35), _tone(Wave.TRIANGLE, 220.0, 140.0, 0.18, 0.3)]))
	# M5: tres chasquidos seguidos (dispara a varios a la vez).
	_save("shot_multi", _notes(Wave.SQUARE, [1500.0, 1300.0, 1100.0], 0.025, 0.2))
	# --- Partida ---
	_save("enemy_death", _mix([_tone(Wave.SINE, 520.0, 180.0, 0.13, 0.45), _tone(Wave.NOISE, 0.0, 0.0, 0.06, 0.2)]))
	_save("life_lost", _tone(Wave.SQUARE, 190.0, 110.0, 0.28, 0.35))
	_save("build", _tone(Wave.TRIANGLE, 420.0, 840.0, 0.1, 0.45))
	_save("upgrade", _notes(Wave.TRIANGLE, [523.3, 659.3, 784.0], 0.07, 0.4))
	_save("sell", _notes(Wave.SQUARE, [988.0, 1318.5], 0.07, 0.25))
	_save("wave_start", _notes(Wave.SQUARE, [392.0, 523.3], 0.18, 0.3))
	_save("victory", _notes(Wave.SQUARE, [523.3, 659.3, 784.0, 1046.5], 0.16, 0.3))
	_save("defeat", _notes(Wave.SQUARE, [392.0, 349.2, 311.1, 261.6], 0.2, 0.3))
	_save("click", _tone(Wave.SQUARE, 1200.0, 1000.0, 0.025, 0.2))
	# --- Música (bucle) ---
	_save("music_loop", _music(), true)
	quit()


# --- Síntesis ---

## Un tono que desliza su frecuencia de `from_hz` a `to_hz`, con ataque corto y caída.
func _tone(wave: Wave, from_hz: float, to_hz: float, seconds: float, volume: float) -> PackedFloat32Array:
	var count: int = int(seconds * RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i: int in count:
		var t: float = float(i) / count
		phase += lerpf(from_hz, to_hz, t) / RATE
		var attack: float = minf(1.0, t * 40.0)
		var decay: float = pow(1.0 - t, 2.0)
		samples[i] = _oscillator(wave, phase) * volume * attack * decay
	return samples


## Notas seguidas (un arpegio), cada una de `note_seconds`.
func _notes(wave: Wave, frequencies: Array, note_seconds: float, volume: float) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	for hz: float in frequencies:
		result.append_array(_tone(wave, hz, hz, note_seconds, volume))
	return result


func _oscillator(wave: Wave, phase: float) -> float:
	var p: float = fposmod(phase, 1.0)
	match wave:
		Wave.SQUARE:
			return 1.0 if p < 0.5 else -1.0
		Wave.TRIANGLE:
			return 4.0 * absf(p - 0.5) - 1.0
		Wave.NOISE:
			return randf_range(-1.0, 1.0)
		_:
			return sin(p * TAU)


## Suma varias capas (se alargan con silencio a la más larga).
func _mix(layers: Array) -> PackedFloat32Array:
	var length: int = 0
	for layer: PackedFloat32Array in layers:
		length = maxi(length, layer.size())
	var result := PackedFloat32Array()
	result.resize(length)
	for layer: PackedFloat32Array in layers:
		for i: int in layer.size():
			result[i] += layer[i]
	return result


## Un bucle tranquilo de 16 compases: bajo + arpegio sobre 4 acordes (La m, Fa, Do, Sol).
func _music() -> PackedFloat32Array:
	var beat: float = 60.0 / 96.0  # 96 pulsos por minuto
	var chords: Array = [[220.0, 261.6, 329.6], [174.6, 220.0, 261.6], [261.6, 329.6, 392.0], [196.0, 246.9, 293.7]]
	var result := PackedFloat32Array()
	for bar: int in 16:
		var chord: Array = chords[bar % chords.size()]
		var bass := _tone(Wave.TRIANGLE, chord[0] / 2.0, chord[0] / 2.0, beat * 4.0, 0.22)
		var arpeggio := PackedFloat32Array()
		for step: int in 8:
			var hz: float = chord[step % 3] * (2.0 if step >= 4 else 1.0)
			arpeggio.append_array(_tone(Wave.SQUARE, hz, hz, beat / 2.0, 0.06))
		result.append_array(_mix([bass, arpeggio]))
	return result


# --- Guardar como .wav de 16 bits ---

func _save(file_name: String, samples: PackedFloat32Array, loop: bool = false) -> void:
	if not _only.is_empty() and not _only.has(file_name):
		return
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i: int in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = samples.size()
	var path: String = OUT_DIR + file_name + ".wav"
	print(file_name, ": ", stream.save_to_wav(path), " (%.2f s)" % (float(samples.size()) / RATE))
