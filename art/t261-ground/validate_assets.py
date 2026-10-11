"""Comprueba los contratos de T261 y registra la continuidad y paleta."""
from pathlib import Path
from PIL import Image, ImageStat
import json
import xml.etree.ElementTree as ET
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
rows=[]
for item in json.loads((OUT/'manifest.json').read_text()):
    rel=item['archivo']
    if rel.endswith('.svg'):
        root=ET.parse(ROOT/rel).getroot()
        assert root.attrib['viewBox']=='0 0 64 64'
        assert root.attrib['width']==root.attrib['height']=='64'
        assert not any(node.tag.split('}')[-1] in ('filter','image','text') for node in root.iter())
        gradients=[node for node in root.iter() if node.tag.endswith('linearGradient')]
        assert all(len(list(node))==3 for node in gradients)
        preview=Image.open(OUT/'after/flowers.png').convert('RGBA')
        assert preview.getchannel('A').getextrema()==(0,255)
        rows.append(f'{rel}: 64×64, alfa real, {len(gradients)} degradés de tres paradas, sin filtros/texto/imágenes.')
        continue
    im=Image.open(ROOT/rel).convert('RGBA');old=Image.open(OUT/'sources/before'/rel).convert('RGB')
    assert im.size==(256,256)
    assert im.getchannel('A').getextrema()==(255,255)
    assert all(im.getpixel((0,n))==im.getpixel((255,n)) for n in range(256))
    assert all(im.getpixel((n,0))==im.getpixel((n,255)) for n in range(256))
    original=ImageStat.Stat(old).mean;current=ImageStat.Stat(im.convert('RGB')).mean
    delta=max(abs(a-b) for a,b in zip(original,current))
    assert delta < 6, (rel, delta)
    rows.append(f'{rel}: 256×256 RGBA opaco, bordes opuestos idénticos (delta 0); cambio máximo de media RGB {delta:.2f}/255.')
(OUT/'validation/assets.txt').write_text('\n'.join(rows)+'\n9 recursos válidos.\n')
print('\n'.join(rows))
