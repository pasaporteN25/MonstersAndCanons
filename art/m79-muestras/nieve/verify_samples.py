#!/usr/bin/env python3
"""Comprueba los artefactos T493 sin abrir Godot; escribe sólo en esta carpeta."""

from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
import hashlib
import json
import re

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    sprites=[]
    for kind in ['pine','fir','snow_rock']:
        for variant in range(1,4):
            path=OUT/f'{kind}_{variant:02}.png'
            with Image.open(path) as im:
                assert im.size==(128,128) and im.mode=='RGBA',path
                bbox=im.getchannel('A').getbbox()
                assert bbox and bbox[0]>0 and bbox[1]>0 and bbox[2]<128 and bbox[3]<128,path
                sprites.append({'file':path.name,'alpha_bbox':list(bbox),'border_transparent':True})
    checked=[]
    for path in sorted(OUT.glob('*.png')):
        with Image.open(path) as im:
            im.verify()
        checked.append(path.name)
    before=Image.open(ROOT/'art/m79-inventario/antes-nivel-13-1280x720.png').convert('RGB')
    manifest=json.loads((OUT/'map_manifest.json').read_text())
    results=[]
    for variant in range(1,4):
        cells=manifest[str(variant)]
        assert len(cells)==115
        mask=Image.new('L',before.size)
        draw=ImageDraw.Draw(mask)
        for cell in cells:
            x,y=cell['cell']
            px,py=16+x*48,48+y*48
            draw.rectangle((px,py,px+47,py+47),fill=255)
        draw.rectangle((354,632,916,668),fill=255)
        after=Image.open(OUT/f'level_13_proposal_{variant:02}.png').convert('RGB')
        assert after.size==(1280,720)
        delta=ImageChops.difference(before,after)
        outside=Image.composite(Image.new('RGB',before.size),delta,mask)
        assert outside.getbbox() is None, 'Se modificaron píxeles fuera del alcance del montaje'
        for x,y in [(23,2),(24,9)]:
            box=(16+x*48,48+y*48,16+(x+1)*48,48+(y+1)*48)
            assert ImageChops.difference(before.crop(box),after.crop(box)).getbbox() is None
        results.append({'variant':variant,'replaced_cells':len(cells),'outside_changes':False,'posts_preserved':True})
    (OUT/'verification.json').write_text(json.dumps({
        'status':'Verificación de archivos y composición correcta; sin motor.',
        'sprites':sprites,'png_readable':checked,'map_checks':results,
        'engine_run':False,'phone_tested':False,'performance_measured':False,
    },indent=2,ensure_ascii=False)+'\n')
    sources={
        'assets/tiles/rendered/ground_nieve.png','assets/tiles/rendered/path.png',
        'assets/sprites/map/rendered/rock_a.png','assets/sprites/map/rendered/rock_b.png',
        'assets/sprites/map/rendered/tree.png','assets/sprites/map/rendered/forest_idle.png',
        'assets/sprites/map/rendered/statue_basic_frost.png',
        'assets/sprites/map/rendered/banner_post_enemy.png',
        'art/m79-inventario/antes-nivel-13-1280x720.png',
        'data/levels/level_13.json','data/ui/postes_campana.json',
    }
    enemy_ids=['normal','fast','tank','armored','flyer','boss','troll','spider','spiderling',
               'guardian','healer','shaman','mirror','colossus','colossus_shard','ratero','cargador']
    for enemy_id in enemy_ids:
        resource=f'data/enemies/{enemy_id}.tres'
        sources.add(resource)
        text=(ROOT/resource).read_text()
        texture_id=re.search(r'texture = ExtResource\("([^"]+)"\)',text).group(1)
        for path,rid in re.findall(r'\[ext_resource[^\n]*path="([^"]+)"[^\n]*id="([^"]+)"',text):
            if rid==texture_id:
                sources.add(path.replace('res://',''))
    provenance={
        'method':'Python 3 y Pillow; dibujo procedural original de árboles y derivación de rocas T277.',
        'image_model_used':False,
        'inputs':[{'path':p,'sha256':digest(ROOT/p)} for p in sorted(sources)],
        'editable_sources':[{'file':p,'sha256':digest(OUT/p)} for p in ['generate_samples.py','verify_samples.py']],
    }
    (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2,ensure_ascii=False)+'\n')
    print('Verificación correcta: nueve RGBA con margen, PNG legibles, tres montajes sin cambios fuera de sus casillas y rótulo, postes conservados.')


if __name__=='__main__':
    main()
