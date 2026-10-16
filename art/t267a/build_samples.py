"""Arma solo muestras vectoriales aisladas; nunca escribe en assets/."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
for name in ['mina', 'bosque_explotable', 'escombro', 'estatua', *[f'central_{i}' for i in range(1, 5)]]:
    original = ROOT / 'assets/sprites/map' / f'{name}.svg'
    (HERE / 'sources' / original.name).write_bytes(original.read_bytes())
    if name in ['mina', 'bosque_explotable', 'escombro']:
        (HERE / 'samples' / original.name).write_bytes(original.read_bytes())

# Bocetos de volumen: geometría nueva acotada, sin texturizar ni fabricar una tanda final.
def gradient(name, colors, height=64):
    return f'<linearGradient id="{name}" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="{height/4}" y2="{height}">' + ''.join(f'<stop offset="{pos}" stop-color="{color}"/>' for pos, color in zip(['0', '.5', '1'], colors)) + '</linearGradient>'

def svg(body, defs, comment, transform=''):
    return f'<!-- {comment}; muestra provisional; fondo transparente. -->\n<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><defs>{defs}</defs><g {transform} stroke="#2b2233" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">{body}</g></svg>\n'

defs = gradient('stone', ['#e4dfce', '#aaa694', '#625f55']) + gradient('side', ['#a5a28f', '#79796c', '#4e514c'])
statue = '''<ellipse cx="32" cy="56" rx="21" ry="4" fill="#2b2233" opacity=".18" stroke="none"/>
<path d="M12 48 22 44H44L52 49 42 57H19Z" fill="url(#side)"/>
<path d="M12 48 22 44H44L52 49 41 52H19Z" fill="url(#stone)"/>
<path d="M24 44 25 34 24 29 29 25 36 26 40 32 41 45 34 48Z" fill="url(#stone)"/>
<path d="M34 28 40 32 41 45 34 48 32 37Z" fill="url(#side)" stroke="none"/>
<path d="M25 30 21 39 23 45 28 43 29 32Z" fill="url(#side)"/>
<path d="M35 28 40 27 45 20 48 22 44 32 38 35Z" fill="url(#stone)"/>
<path d="M29 24 26 18 28 12 35 10 40 15 39 23 34 27Z" fill="url(#stone)"/>
<path d="M35 11 40 15 39 23 34 27 33 20Z" fill="url(#side)" stroke="none"/>
<path d="M27 17 29 13 35 12" fill="none" stroke="#f4ecda"/>
<path d="M46 22 45 9 48 3 50 10 49 22Z" fill="url(#stone)"/>
<path d="M42 23 52 22" fill="none" stroke-width="2"/>
<path d="M29 30 29 36 31 39" fill="none" stroke="#eeead9"/>
<path d="M35 36 33 40 35 44" fill="none" stroke="#575a52"/>
<path d="M15 49 23 46H30" fill="none" stroke="#efead7"/>
<path d="M19 52 24 52 25 54 20 54Z" fill="#62734b" stroke="none"/>'''
(HERE / 'samples/estatua.svg').write_text(svg(statue, defs, 'Estatua pétrea facetada con espada en alto, vista elevada hacia la derecha'))

defs = ''.join(gradient(n, c, 128) for n, c in [
    ('stone', ['#d4ccb6', '#9b9584', '#615f56']),
    ('metal', ['#b0babc', '#67777b', '#343e45']),
    ('copper', ['#d3b380', '#95734c', '#584333'])])
central = '''<ellipse cx="65" cy="114" rx="55" ry="7" fill="#2b2233" opacity=".18" stroke="none"/>
<path d="M12 96 36 83 116 96 95 116 15 111Z" fill="url(#stone)"/>
<path d="M15 105 95 110 116 94V102L95 120 15 114Z" fill="#626257"/>
<path d="M17 54 39 41 98 47V99L76 111 17 101Z" fill="url(#stone)"/>
<path d="M76 60 98 47V99L76 111Z" fill="#656b65"/>
<path d="M11 53 36 30 93 35 106 48 77 65Z" fill="url(#copper)"/>
<path d="M36 30 93 35 77 55 11 53Z" fill="#b49a6d"/>
<path d="M77 55 106 48 77 65 11 59 11 53Z" fill="#68543d"/>
<path d="M19 50 39 34 84 38" fill="none" stroke="#eee0bc" stroke-width="1.5"/>
<path d="M29 36V15L39 11 46 15V34L39 39Z" fill="url(#metal)"/>
<path d="M29 15 39 11 46 15 37 19Z" fill="#b3b8ac"/>
<path d="M24 64 40 65V91L24 89Z" fill="#3b4747"/>
<path d="M28 67 36 68V86L28 85Z" fill="#e0c28b"/>
<path d="M47 72 56 65 70 67V100L47 98Z" fill="url(#metal)"/>
<path d="M47 72 56 65 70 67 61 74Z" fill="#a7aea5"/>
<path d="M61 74 70 67V100L61 104Z" fill="#344349"/>
<path d="M48 78 60 79V84L48 83Z" fill="url(#copper)"/>
<path d="M49 89 59 90M49 94 59 95" fill="none" stroke-width="1.8"/>
<path d="M87 85 106 78V63L115 59V91L88 102Z" fill="url(#metal)"/>
<path d="M106 64 115 60 119 64 109 68Z" fill="url(#copper)"/>
<path d="M22 96 42 99" fill="none" stroke="#e9ddc0"/>
<path d="M79 72 94 64M79 88 94 80" fill="none" stroke="#535d58"/>'''
(HERE / 'sources/central_master_sample.svg').write_text(svg(central, defs, 'Central industrial facetada en perspectiva elevada').replace('width="64" height="64" viewBox="0 0 64 64"', 'width="128" height="128" viewBox="0 0 128 128"'))
for i, (x, y) in enumerate([(0, 0), (64, 0), (0, 64), (64, 64)], 1):
    (HERE / f'samples/central_{i}.svg').write_text(svg(central, defs, f'Cuarto {i} de la Central, mismo orden NO NE SO SE', f'transform="translate({-x} {-y})"'))
entries = []
for sample in sorted((HERE / 'samples').glob('*.svg')):
    target = 'assets/sprites/map/' + sample.name
    entries.append({'muestra': str(sample.relative_to(ROOT)), 'destino_futuro_no_conectado': target, 'lienzo': [64, 64], 'sha256_muestra': hashlib.sha256(sample.read_bytes()).hexdigest(), 'sha256_actual': hashlib.sha256((ROOT / target).read_bytes()).hexdigest(), 'procedencia': 'SVG existente sin cambios; prueba de conexión visual' if sample.stem in ['mina', 'bosque_explotable', 'escombro'] else 'boceto vectorial nativo aislado'})
(HERE / 'manifest.json').write_text(json.dumps(entries, ensure_ascii=False, indent=2) + '\n')
