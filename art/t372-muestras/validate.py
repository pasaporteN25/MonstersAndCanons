"""Comprueba la entrega completa sin abrir ni importar el proyecto del juego."""
from pathlib import Path
from html.parser import HTMLParser
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parent
NAMES = ['map', 'tower', 'monster', 'siege', 'editor', 'mobile', 'book', 'upgrade']
checks = {}

def check(name, condition, detail=None):
    checks[name] = {'ok': bool(condition), 'detail': detail}
    if not condition:
        raise AssertionError(name)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

manifest = json.loads((ROOT / 'manifest.json').read_text())
expected = {'news_header_1_0.png', 'news_header_plain.png'} | {f'news_icon_{n}.png' for n in NAMES}
check('manifest_complete', len(manifest['assets']) == 10 and {a['file'] for a in manifest['assets']} == expected)
check('no_missing_icons', manifest['missing_icons'] == [] and manifest['optional_icons'] == ['upgrade'])
for item in manifest['assets']:
    path = ROOT / item['file']
    image = Image.open(path)
    size, mode, limit = ((96, 96), 'RGBA', 20000) if item['file'].startswith('news_icon_') else (
        ((1280, 320), 'P', 350000) if item['file'] == 'news_header_1_0.png' else ((1280, 160), 'RGB', 100000))
    check(item['file'] + '_format', image.format == 'PNG' and image.size == size and image.mode == mode)
    check(item['file'] + '_weight', path.stat().st_size < limit, path.stat().st_size)
    check(item['file'] + '_manifest', item['size'] == list(size) and item['mode'] == mode and item['bytes'] == path.stat().st_size and item['limit_bytes'] == limit and item['sha256'] == digest(path) and (ROOT / item['source']).is_file())
    if mode == 'RGBA':
        alpha = image.getchannel('A')
        check(item['file'] + '_alpha', alpha.getextrema() == (0, 255) and alpha.getpixel((0, 0)) == 0 and alpha.getpixel((48, 48)) == 255)
    else:
        check(item['file'] + '_opaque', image.convert('RGBA').getchannel('A').getextrema() == (255, 255))

for name, sha in manifest['approved_baseline_sha256'].items():
    check('approved_unchanged_' + name, digest(ROOT / name) == sha)

ns = {'s': 'http://www.w3.org/2000/svg'}
base_tree = ET.parse(ROOT / 'sources/news_icon_map.svg')
base_group = base_tree.getroot().find('s:g', ns)
base_medal = [ET.tostring(e) for e in list(base_group)[:7]]
base_image = Image.open(ROOT / 'news_icon_map.png')
ring = Image.new('L', (96, 96))
ring.putdata([255 if (x - 48)**2 + (y - 48)**2 >= 40**2 else 0 for y in range(96) for x in range(96)])
for name in NAMES:
    path = ROOT / f'sources/news_icon_{name}.svg'
    tree = ET.parse(path)
    root = tree.getroot()
    group = root.find('s:g', ns)
    check(name + '_svg_contract', root.attrib['viewBox'] == '0 0 96 96' and group.attrib['stroke'] == '#2b2233' and group.attrib['stroke-width'] == '2')
    check(name + '_same_medal', [ET.tostring(e) for e in list(group)[:7]] == base_medal)
    check(name + '_same_materials', ET.tostring(root.find('s:defs', ns)) == ET.tostring(base_tree.getroot().find('s:defs', ns)) and all(len(list(g)) == 3 for g in root.findall('s:defs/s:linearGradient', ns)))
    check(name + '_no_text_filters_images', all(e.tag.split('}')[-1] not in ['text', 'image', 'filter', 'foreignObject'] and not any(k in e.attrib for k in ['filter', 'href']) for e in root.iter()))
    image = Image.open(ROOT / f'news_icon_{name}.png')
    difference = ImageChops.difference(image, base_image)
    check(name + '_same_rendered_ring', all(ImageChops.multiply(c, ring).getbbox() is None for c in difference.split()))
    check(name + '_same_alpha', image.getchannel('A').tobytes() == base_image.getchannel('A').tobytes())

plain = Image.open(ROOT / 'news_header_plain.png')
check('plain_repeat_160px', plain.crop((0, 0, 1120, 160)).tobytes() == plain.crop((160, 0, 1280, 160)).tobytes())
for name, size in [('contact_sheet.png', (760, 1120)), ('all_rows.png', (880, 848)), ('mockup_pc.png', (1280, 720)), ('mockup_pc_end.png', (1280, 720)), ('mockup_mobile.png', (1280, 720)), ('mockup_mobile_real.png', (2400, 1080)), ('mockup_mobile_real_end.png', (2400, 1080))]:
    check(name + '_size', Image.open(ROOT / name).size == size)
# Verifica que los ocho montajes usan sus PNG, incluidos los nuevos; no quedan reservas.
for name, canvas, x, y, size in [('contact', 'contact_sheet.png', 30, 62, 96), ('rows', 'all_rows.png', 20, 15, 64)]:
    sheet = Image.open(ROOT / canvas)
    for i, icon in enumerate(NAMES):
        scaled = Image.open(ROOT / f'news_icon_{icon}.png').resize((size, size), Image.Resampling.LANCZOS)
        expected_tile = Image.new('RGB', (size, size), '#1b1c20')
        expected_tile.paste(scaled, (0, 0), scaled)
        yy = y + i * (132 if name == 'contact' else 106)
        check(name + '_' + icon, sheet.crop((x, yy, x + size, yy + size)).tobytes() == expected_tile.tobytes())

class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ['src', 'href'] and value and not value.startswith(('#', 'http', 'data:')):
                self.links.append(value)

parser = Links()
page = (ROOT / 'comparison.html').read_text()
parser.feed(page)
links = parser.links + re.findall(r'url\(([^)]+)\)', page)
check('html_local_links', all((ROOT / link).is_file() or link == 'validation.json' for link in links), len(links))
check('excluded_from_game_import', (ROOT / '.gdignore').is_file())
report = {'passed': True, 'check_count': len(checks), 'checks': checks, 'limits': 'Validación de archivos y montajes. No prueba el juego, Android ni la aprobación artística de Lucas.'}
(ROOT / 'validation.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(f'{len(checks)} verificaciones correctas; ver validation.json')
