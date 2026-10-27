#!/usr/bin/env python3
"""T536: partitura y síntesis originales; solo biblioteca estándar de Python 3.

Uso: python3 art/t536-combat-music/generate.py [--output /tmp/frontier.wav]
No lee audio, archivos del juego ni recursos externos. No modifica producción.
"""

import argparse
from array import array
import hashlib
import json
import math
from pathlib import Path
import random
import struct
import wave

RATE = 44100
BPM = 112
BEAT = 60 / BPM
BAR = 4 * BEAT
DURATION = 48 * BAR + 3.2
SEED = 5362026
TAU = math.tau

# Alturas MIDI, inicio y duración en negras. Frase de dos compases,
# con anacrusa interna, salto de quinta y caída que deja respirar al pulso.
MOTIF = [(0, 0.75, 74), (1, 0.5, 81), (1.75, 1.0, 77),
         (3, 1.25, 76), (4.5, 0.5, 72), (5.25, 0.5, 70),
         (6, 1.65, 69)]
ANSWER = [(0.5, 0.5, 77), (1.25, 0.75, 79), (2.5, 1.25, 76),
          (4, 0.75, 74), (5, 0.5, 72), (6, 1.6, 74)]
CONTRAST = [(0, 1.5, 69), (2, 0.75, 72), (3.25, 1.25, 79),
            (5, 0.75, 77), (6.25, 1.25, 76)]
# Voicings abiertos: raíz del bajo y cuatro voces superiores.
HARMONY = [(38, (57, 60, 64, 65)), (34, (57, 60, 62, 65)),
           (43, (58, 62, 65, 69)), (33, (55, 58, 62, 64))]
BRIDGE = [(41, (57, 60, 64, 67)), (36, (55, 60, 62, 64)),
          (39, (55, 58, 62, 65)), (33, (55, 58, 62, 64))]


def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)


def render(output):
    rng = random.Random(SEED)
    count = round(DURATION * RATE)
    left = array('f', [0.0]) * count
    right = array('f', [0.0]) * count

    def voice(start, duration, note, gain, pan=0, kind='lead', echo=False):
        begin = round(start * RATE)
        size = round(duration * RATE)
        freq = frequency(note)
        step = TAU * freq / RATE
        gl = math.sqrt((1 - pan) / 2) * gain
        gr = math.sqrt((1 + pan) / 2) * gain
        # Ecos cruzados finitos: espacio sin acumular energía indefinidamente.
        taps = [(0, gl, gr)]
        if echo:
            taps += [(round(BEAT * .75 * RATE), gr * .23, gl * .23),
                     (round(BEAT * 1.5 * RATE), gl * .10, gr * .10)]
        for i in range(size):
            t = i / RATE
            p = step * i
            release = min(1.0, (duration - t) / (.45 if kind == 'pad' else .07))
            if kind == 'pad':
                env = min(1, t / .7) * release
                sample = (.54 * math.sin(p) + .22 * math.sin(p * 1.002)
                          + .13 * math.sin(2*p + .3*math.sin(t*2))) * env
            elif kind == 'bass':
                env = min(1, t / .008) * math.exp(-t * 3.8) * release
                sample = (math.sin(p) + .22 * math.sin(2*p)
                          + .09 * math.sin(3*p)) * env
            elif kind == 'bell':
                env = min(1, t / .006) * math.exp(-t * 3) * release
                sample = math.sin(p + 1.6 * math.exp(-t*5) * math.sin(p*2.01)) * env
            else:
                env = min(1, t / .025) * (.67 + .33 * math.exp(-t*5)) * release
                vibrato = .012 * math.sin(t * TAU * 4.6) * min(1, t*3)
                sample = (math.sin(p + vibrato + .55*math.exp(-t*2)*math.sin(2*p))
                          + .16*math.sin(2*p) + .07*math.sin(3*p)) * env
            for delay, l_gain, r_gain in taps:
                at = begin + i + delay
                if 0 <= at < count:
                    left[at] += sample * l_gain
                    right[at] += sample * r_gain

    def drum(start, kind, gain, pan=0):
        duration = {'kick': .48, 'snare': .24, 'hat': .085, 'tom': .32}[kind]
        begin = round(start * RATE)
        filtered = 0.0
        phase = 0.0
        for i in range(round(duration * RATE)):
            t = i / RATE
            noise = rng.uniform(-1, 1)
            previous = filtered
            filtered += .23 * (noise - filtered)
            if kind == 'kick':
                phase += TAU * (47 + 105 * math.exp(-t * 30)) / RATE
                sample = math.sin(phase)*math.exp(-t*10) + .07*noise*math.exp(-t*180)
            elif kind == 'snare':
                sample = (.72*(noise-filtered)*math.exp(-t*24)
                          + .28*math.sin(TAU*178*t)*math.exp(-t*30))
            elif kind == 'tom':
                phase += TAU*(105+60*math.exp(-t*25))/RATE
                sample = (.85*math.sin(phase)+.12*filtered)*math.exp(-t*14)
            else:
                sample = (noise-previous)*math.exp(-t*65)*.45
            sample *= min(1, t/.0015) * min(1, (duration-t)/.015) * gain
            at = begin+i
            if 0 <= at < count:
                left[at] += sample * math.sqrt((1-pan)/2)
                right[at] += sample * math.sqrt((1+pan)/2)

    for bar in range(48):
        section = bar // 8
        local = bar % 8
        start = bar * BAR
        root, chord = (BRIDGE if section == 2 else HARMONY)[local // 2]
        energy = [.52, .82, .66, .76, 1.0, .58][section]
        if section == 0:
            energy *= .55 + .45 * local/7
        if section == 5:
            energy *= 1 - .65 * local/7
        # Textura armónica sostenida: las voces no duplican el ritmo del motivo.
        if bar % 2 == 0:
            for j, note in enumerate(chord):
                voice(start, BAR*2+.55, note, .042*energy,
                      [-.68, .55, -.32, .72][j], 'pad')
        bass_steps = [(0, .65), (1.5, .35), (2.75, .55)]
        if local % 2:
            bass_steps = [(0, .8), (1.75, .4), (3.25, .45)]
        if section == 3:
            bass_steps += [(2.25, .25)]
        if section == 5 and local >= 6:
            bass_steps = [(0, 1.8)]
        for beat, length in bass_steps:
            voice(start+beat*BEAT, length*BEAT, root, .25*energy, 0, 'bass')
        # Pulso con anticipaciones y acentos 3+3+2; no un bombo a negras permanente.
        if not (section == 5 and local >= 6):
            kicks = [0, 1.75, 2.5] if local % 2 == 0 else [0, 1.5, 3.25]
            if section == 0 and local < 4:
                kicks = [0, 2.5]
            for beat in kicks:
                drum(start+beat*BEAT, 'kick', .39*energy)
            if section > 0 or local >= 4:
                for beat in [1, 3]:
                    drum(start+beat*BEAT+.008, 'snare', .19*energy, -.08)
            for tick in range(8):
                if (tick+local) % 5 == 0:
                    continue
                beat = tick*.5 + (.035 if tick % 2 else 0)
                drum(start+beat*BEAT, 'hat', (.11 if tick % 2 else .075)*energy,
                     .35 if tick % 2 else -.3)
            if local in (3, 7):
                for j, beat in enumerate([2.75, 3.375, 3.75]):
                    drum(start+beat*BEAT, 'tom', .17*energy*(1-j*.12), -.4+j*.4)
        # Exposición, respuesta y transformación de una frase escrita, con silencios.
        phrase = None
        if section == 0 and local == 6:
            phrase = MOTIF[:4]
        elif section == 1 and local % 2 == 0:
            phrase = MOTIF if local in (0, 4) else ANSWER
        elif section == 2 and local in (0, 4):
            phrase = CONTRAST
        elif section == 2 and local in (2, 6):
            phrase = ANSWER
        elif section == 3 and local in (0, 4):
            phrase = [(b, d*.65, n-12) for b, d, n in MOTIF[:4]]
        elif section == 4 and local % 2 == 0:
            phrase = MOTIF if local in (0, 4) else ANSWER
        elif section == 5 and local in (0, 4):
            phrase = ANSWER if local == 0 else [(0, 1, 77), (1.5, 1, 76), (3, 3, 74)]
        if phrase:
            for beat, length, note in phrase:
                voice(start+beat*BEAT, length*BEAT, note,
                      .145*energy, -.13 if section == 2 else .12, echo=True)
        # Contracanto de campanas, nunca el mismo patrón que la voz principal.
        if section in (2, 4) and local % 2:
            for beat, note in [(0.75, chord[2]+12), (2.25, chord[1]+12), (3.5, chord[0]+12)]:
                voice(start+beat*BEAT, .8, note, .065*energy, -.55, 'bell', True)
        # Balizas FM irregulares, presentes también en los huecos de la melodía.
        if local in (1, 5, 7):
            voice(start+2.4*BEAT, 1.7, chord[3]+12, .045,
                  .65 if local == 1 else -.65, 'bell', True)
        if section == 3 and local >= 4:
            for beat in [0.5, 1.25, 2.5, 3.25]:
                voice(start+beat*BEAT, .21, chord[local % 4]+12,
                      .052*(1+(local-4)*.12), -.38, 'bell', True)
    # Resolución final Dm(add9), sin forzar un empalme circular todavía no aprobado.
    for j, note in enumerate([50, 57, 60, 64, 65]):
        voice(47*BAR, BAR+2.9, note, .028, (j-2)*.3, 'pad')

    # Reverberación corta de alimentación directa; lectura de mezcla seca.
    dry_left, dry_right = array('f', left), array('f', right)
    for seconds, gain in [(.071, .08), (.113, .065), (.173, .045)]:
        delay = round(seconds*RATE)
        for i in range(delay, count):
            left[i] += dry_right[i-delay]*gain
            right[i] += dry_left[i-delay]*gain
    del dry_left, dry_right
    # Ganancia lineal global: sin limitador ni recorte para esconder sobrecargas.
    peak = max(max(abs(x) for x in left), max(abs(x) for x in right))
    scale = 10**(-2/20) / peak
    dither = random.Random(SEED+1)
    output.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(output), 'wb') as wav:
        wav.setparams((2, 2, RATE, count, 'NONE', 'not compressed'))
        chunk = bytearray()
        for i in range(count):
            fade = min(1, i/(RATE*.04), (count-1-i)/(RATE*1.8))
            for value in (left[i], right[i]):
                value = value*scale*fade
                quantized = round(value*32767 + (dither.random()-dither.random())*.5)
                chunk.extend(struct.pack('<h', quantized))
            if len(chunk) >= 65536:
                wav.writeframesraw(chunk)
                chunk.clear()
        wav.writeframesraw(chunk)
    print(json.dumps(inspect(output), ensure_ascii=False, indent=2))


def inspect(path):
    with wave.open(str(path), 'rb') as wav:
        params = wav.getparams()
        samples = array('h', wav.readframes(wav.getnframes()))
    import sys
    if sys.byteorder != 'little':
        samples.byteswap()
    channels = [samples[::2], samples[1::2]]
    peak = max(abs(s) for s in samples)
    report = {
        'file': path.name, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'frames': params.nframes, 'seconds': params.nframes/params.framerate,
        'sample_rate': params.framerate, 'channels': params.nchannels,
        'bits': params.sampwidth*8, 'bytes': path.stat().st_size,
        'peak_dbfs': round(20*math.log10(max(1, peak)/32768), 4),
        'full_scale_samples': sum(abs(s) >= 32767 for s in samples),
        'rms_dbfs': [round(20*math.log10(math.sqrt(sum(s*s for s in ch)/len(ch))/32768), 3)
                     for ch in channels],
        'dc_offset': [round(sum(ch)/len(ch)/32768, 8) for ch in channels],
        'stereo_difference_rms': round(math.sqrt(sum((l-r)**2 for l, r in zip(*channels))/len(channels[0]))/32768, 6),
        'window_rms_dbfs': [],
    }
    for start in range(0, params.nframes, RATE*8):
        block = samples[2*start:2*min(params.nframes, start+RATE*8)]
        report['window_rms_dbfs'].append(round(20*math.log10(max(1e-12, math.sqrt(sum(s*s for s in block)/len(block))/32768)), 2))
    assert params.nchannels == 2 and params.sampwidth == 2 and params.framerate == RATE
    assert 90 <= report['seconds'] <= 120 and peak > 1000
    assert report['full_scale_samples'] == 0 and report['peak_dbfs'] < -1.9
    assert max(abs(x) for x in report['dc_offset']) < .001
    assert report['stereo_difference_rms'] > .001
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().with_name('frontier-vigil.wav'))
    parser.add_argument('--inspect', type=Path, help='Analiza un WAV sin regenerarlo.')
    args = parser.parse_args()
    if args.inspect:
        print(json.dumps(inspect(args.inspect), ensure_ascii=False, indent=2))
    else:
        render(args.output)
