"""Verificación del paquete de muestras; no importa ni ejecuta el juego."""
from pathlib import Path
import hashlib
import json
from html.parser import HTMLParser
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = Path(__file__).resolve().parent
manifest = json.loads((ROOT/'manifest.json').read_text())
checks = 0


def check(condition, description):
    global checks
    assert condition, description
    checks += 1


for item in manifest['assets']:
    path = ROOT/item['file']
    atlas = Image.open(path)
    check(atlas.mode == 'RGBA' and atlas.size == (768,384), f'Formato {path.name}')
    check(path.stat().st_size == item['bytes'] < 150000, f'Peso {path.name}')
    check(item['center'] == [96,96] and item['frames'] == 8, 'Anclaje y cuadros')
    level = 2 if 'l2' in path.name else 3
    for i in range(8):
        tile = atlas.crop((i%4*192,i//4*192,i%4*192+192,i//4*192+192))
        source = ROOT/'sources'/f'upgrade_l{level}_{i+1:02}.png'
        check(tile.tobytes() == Image.open(source).tobytes(), f'Fuente intacta {source.name}')
        box = tile.getbbox()
        check(box is None or (min(box[:2]) >= 8 and max(box[2:]) <= 184), f'Margen {i+1}')
        check(all(px[:3] == (0,0,0) for px in tile.get_flattened_data() if px[3] == 0), 'Sin residuos RGB transparentes')
        if i == 0:
            check(tile.getchannel('A').getextrema()[1] < 48, 'Inicio casi vacío')
        if i == 7:
            check(box is None, 'Último cuadro transparente')
        svg = ET.parse(source.with_suffix('.svg'))
        check(not any(e.tag.rsplit('}',1)[-1] in ['text','image','filter','feGaussianBlur'] for e in svg.iter()), 'SVG sin texto, raster incrustado ni filtro')
    gif = Image.open(ROOT/'preview'/f'upgrade_l{level}.gif')
    total = 0
    for i in range(gif.n_frames):
        gif.seek(i)
        total += gif.info['duration']
    check(total == round(item['duration_seconds']*1000)+1000, 'Duración GIF con descanso')

for ref in manifest['references']:
    check(hashlib.sha256((ROOT/ref['copy']).read_bytes()).hexdigest() == ref['sha256'], 'Copia de referencia intacta')


class Links(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key,value in attrs:
            if key in ['src','href'] and value:
                check(not value.startswith(('https:', 'http:')), 'HTML sin dependencia externa')
                check((ROOT/value).is_file(), f'Enlace local {value}')


Links().feed((ROOT/'comparison.html').read_text())
for theme in ['pradera','nieve','volcan','desierto']:
    check(Image.open(ROOT/'contact'/f'{theme}.png').size == (1600,3424), 'Hoja completa')
print(f'{checks} verificaciones de arte correctas. No verifica Godot ni render del navegador.')
