## Genera una propuesta original de combate con osciladores y envolventes.
## No carga archivos de audio ni toca los recursos activos del juego.
extends SceneTree

const SAMPLE_RATE: int = 44100
const BPM: float = 108.0
const BEAT: float = 60.0 / BPM
const BAR: float = BEAT * 4.0
const BAR_COUNT: int = 32
const OUTPUT_PATH: String = "res://combat_proposal.wav"

const ROOTS: Array[int] = [38, 39, 46, 41, 43, 46, 36, 45]
const CHORDS: Array = [
	[62, 65, 69, 76], # Dm(add9)
	[63, 67, 70, 77], # Ebmaj7
	[58, 62, 65, 72], # Bb(add9)
	[53, 58, 60, 67], # Fsus2
	[55, 58, 62, 69], # Gm9
	[58, 62, 65, 72], # Bb(add9)
	[60, 65, 67, 74], # C(add9)
	[57, 62, 64, 70], # Asus4(b7)
]
const MOTIF: Array[int] = [0, 7, 3, 10, 5, 2, 9, 7, 12, 10, 3, 5, 14, 9, 2, 0]
const MOTIF_RHYTHM: Array[int] = [0, 3, 4, 7, 10, 12, 15, 18, 20, 23, 25, 28, 30]

var _left := PackedFloat32Array()
var _right := PackedFloat32Array()


func _init() -> void:
	var frames: int = int(BAR * BAR_COUNT * SAMPLE_RATE)
	_left.resize(frames)
	_right.resize(frames)
	for bar_index: int in BAR_COUNT:
		_add_bar(bar_index)
	_normalize_and_save()
	quit()


func _add_bar(bar_index: int) -> void:
	var bar_start: float = float(bar_index) * BAR
	var chord_index: int = bar_index % CHORDS.size()
	var chord: Array = CHORDS[chord_index]
	var root: int = ROOTS[chord_index]
	var section: int = bar_index / 8
	var energy: float = [0.62, 0.82, 0.72, 0.92][section]
	var pad_pan: float = -0.16 if bar_index % 2 == 0 else 0.16

	# Capa armónica con novenas/suspensiones y un movimiento lento de filtro simulado.
	for voice_index: int in chord.size():
		var midi: int = int(chord[voice_index])
		var amplitude: float = 0.037 if voice_index < 3 else 0.022
		_add_voice(bar_start, BAR, midi, amplitude * energy, pad_pan * (1.0 if voice_index % 2 == 0 else -1.0), 0)
		_add_voice(bar_start, BAR, midi + 12, amplitude * 0.18 * energy, -pad_pan, 0)

	# Bajo sincopado; las frases cambian cada ocho compases para evitar un loop plano.
	var bass_beats: Array = [0.0, 1.5, 2.5] if section % 2 == 0 else [0.0, 1.0, 2.5, 3.25]
	for hit_index: int in bass_beats.size():
		var beat_offset: float = bass_beats[hit_index]
		var octave: int = 12 if hit_index == bass_beats.size() - 1 and bar_index % 4 == 3 else 0
		_add_voice(bar_start + beat_offset * BEAT, 0.34 if hit_index == 0 else 0.24, root + octave, 0.12 * energy, -0.1, 2)

	# Motivo propio de 16 corcheas con silencios y cambios de registro entre secciones.
	var motif_shift: int = [0, 2, -2, 5][section]
	var motif_scale: Array[int] = [74, 75, 77, 79, 81, 82, 84, 86, 87, 89, 91, 93, 94, 96, 98, 101]
	for note_index: int in MOTIF_RHYTHM.size():
		var step: int = MOTIF_RHYTHM[note_index]
		if (bar_index + note_index + section) % 7 == 0:
			continue
		var pitch_index: int = posmod(MOTIF[(note_index + bar_index * 2) % MOTIF.size()] + motif_shift, motif_scale.size())
		var midi: int = motif_scale[pitch_index]
		if bar_index % 8 >= 4 and note_index % 3 == 1:
			midi += 12
		var duration: float = 0.22 if note_index % 4 == 0 else 0.14
		var pan: float = -0.38 if note_index % 2 == 0 else 0.38
		_add_voice(bar_start + float(step) * (BEAT / 8.0), duration, midi, 0.048 * energy, pan, 1)

	# Arpegio quebrado, con desplazamiento estéreo y notas tomadas del acorde del compás.
	if bar_index % 4 != 3:
		for pulse: int in 6:
			var pulse_steps: Array[int] = [0, 3, 5, 8, 11, 14]
			var degree: int = pulse_steps[(pulse + bar_index + section) % pulse_steps.size()]
			var chord_voice: int = posmod(degree + bar_index, chord.size())
			var arp_pitch: int = int(chord[chord_voice]) + 12 + (12 if degree > 8 else 0)
			var arp_pan: float = -0.58 if pulse % 2 == 0 else 0.58
			var start: float = bar_start + float(pulse) * (BEAT / 2.0) + (BEAT / 8.0 if section == 2 and pulse % 3 == 1 else 0.0)
			_add_voice(start, 0.11, arp_pitch, 0.027 * energy, arp_pan, 1)

	# Percusión electrónica sintética, más aireada que una batería constante.
	_add_percussion(bar_start, 46.0, 0.22, 0.22 * energy, 0)
	if bar_index % 2 == 1 or section == 3:
		_add_percussion(bar_start + 2.0 * BEAT, 44.0, 0.20, 0.16 * energy, 0)
	for beat_index: int in [1, 3]:
		_add_percussion(bar_start + float(beat_index) * BEAT, 185.0, 0.16, 0.052 * energy, 1)
	for hat_index: int in 8:
		if hat_index % 2 == 0 and section < 2:
			continue
		_add_percussion(bar_start + float(hat_index) * (BEAT / 2.0), 7100.0 + float(hat_index % 3) * 680.0, 0.035, 0.014 * energy, 2)


func _add_voice(start_seconds: float, duration: float, midi: int, amplitude: float, pan: float, timbre: int) -> void:
	var start_frame: int = maxi(int(start_seconds * SAMPLE_RATE), 0)
	if start_frame >= _left.size():
		return
	var frame_count: int = mini(int(duration * SAMPLE_RATE), _left.size() - start_frame)
	var frequency: float = 440.0 * pow(2.0, float(midi - 69) / 12.0)
	var left_gain: float = sqrt((1.0 - pan) * 0.5)
	var right_gain: float = sqrt((1.0 + pan) * 0.5)
	var attack: float = 0.18 if timbre == 0 else (0.006 if timbre == 1 else 0.004)
	var release: float = 0.24 if timbre == 0 else (0.045 if timbre == 1 else 0.07)
	for offset: int in frame_count:
		var elapsed: float = float(offset) / SAMPLE_RATE
		var remaining: float = duration - elapsed
		var envelope: float = minf(elapsed / attack, 1.0) * minf(remaining / release, 1.0)
		if timbre == 1:
			envelope *= exp(-elapsed * 3.8)
		elif timbre == 2:
			envelope *= exp(-elapsed * 2.6)
		var phase: float = TAU * frequency * elapsed
		var sample: float
		if timbre == 0:
			var vibrato: float = sin(TAU * 0.24 * elapsed) * 0.0008
			sample = sin(phase) * 0.72 + sin(phase * 2.003 * (1.0 + vibrato)) * 0.18 + sin(phase * 3.01) * 0.07
		elif timbre == 1:
			sample = sin(phase) * 0.72 + sin(phase * 2.01) * 0.22 + sin(phase * 4.02) * 0.07
		else:
			var bend: float = exp(-elapsed * 14.0)
			sample = sin(TAU * (frequency * elapsed - frequency * 0.11 * (1.0 - bend) / 14.0)) * exp(-elapsed * 3.1)
		var index: int = start_frame + offset
		_left[index] += sample * amplitude * envelope * left_gain
		_right[index] += sample * amplitude * envelope * right_gain


func _add_percussion(start_seconds: float, base_hz: float, duration: float, amplitude: float, kind: int) -> void:
	var start_frame: int = int(start_seconds * SAMPLE_RATE)
	if start_frame >= _left.size():
		return
	var frame_count: int = mini(int(duration * SAMPLE_RATE), _left.size() - start_frame)
	for offset: int in frame_count:
		var elapsed: float = float(offset) / SAMPLE_RATE
		var envelope: float = exp(-elapsed * (17.0 if kind == 0 else 24.0))
		var phase: float = TAU * base_hz * elapsed
		var sample: float
		match kind:
			0:
				var drop: float = exp(-elapsed * 18.0)
				sample = sin(TAU * (base_hz * elapsed - 22.0 * (1.0 - drop) / 18.0)) * envelope
			1:
				sample = (sin(phase) + sin(phase * 1.47) * 0.6 + sin(phase * 2.21) * 0.25) * envelope
			_:
				sample = (sin(phase) + sin(phase * 1.342) * 0.7 + sin(phase * 1.731) * 0.45) * envelope
		var index: int = start_frame + offset
		var pan: float = 0.0 if kind == 0 else (0.55 if int(start_seconds * 16.0) % 2 == 0 else -0.55)
		_left[index] += sample * amplitude * sqrt((1.0 - pan) * 0.5)
		_right[index] += sample * amplitude * sqrt((1.0 + pan) * 0.5)


func _normalize_and_save() -> void:
	# El último instante llega a cero, para empalmar con el cero inicial del loop.
	var fade_frames: int = int(SAMPLE_RATE * 0.12)
	for frame: int in fade_frames:
		var index: int = _left.size() - fade_frames + frame
		var progress: float = float(frame) / maxi(fade_frames - 1, 1)
		var fade: float = cos(progress * PI * 0.5)
		_left[index] *= fade
		_right[index] *= fade
	var peak: float = 0.0
	var raw_energy: float = 0.0
	var energy: float = 0.0
	for frame: int in _left.size():
		peak = maxf(peak, maxf(absf(_left[frame]), absf(_right[frame])))
		raw_energy += (_left[frame] * _left[frame] + _right[frame] * _right[frame]) * 0.5
	var raw_rms: float = sqrt(raw_energy / _left.size())
	var gain: float = minf(0.068 / maxf(raw_rms, 0.001), 0.72 / maxf(peak, 0.001))
	var bytes := PackedByteArray()
	bytes.resize(_left.size() * 4)
	for frame: int in _left.size():
		var left_sample: float = clampf(_left[frame] * gain, -1.0, 1.0)
		var right_sample: float = clampf(_right[frame] * gain, -1.0, 1.0)
		energy += (left_sample * left_sample + right_sample * right_sample) * 0.5
		bytes.encode_s16(frame * 4, int(left_sample * 32767.0))
		bytes.encode_s16(frame * 4 + 2, int(right_sample * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = true
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = _left.size()
	var error: Error = stream.save_to_wav(OUTPUT_PATH)
	var rms: float = sqrt(energy / _left.size())
	print("Propuesta: %.2f s, %.1f BPM, peak %.3f, RMS %.3f, salida %s" % [float(_left.size()) / SAMPLE_RATE, BPM, peak * gain, rms, error])
