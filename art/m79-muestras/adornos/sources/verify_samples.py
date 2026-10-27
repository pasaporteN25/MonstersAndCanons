#!/usr/bin/env python3
"""Chequeos de dimensiones, transparencia, integridad y alcance de T523."""
from pathlib import Path
import hashlib, json, shutil, subprocess, sys, tempfile
from PIL import ImageChops, ImageDraw
from PIL import Image
OUT=Path(__file__).resolve().parents[1]
m=json.loads((OUT/'manifest.json').read_text())
variants=sorted((OUT/'variants').glob('*.png'))
assert len(variants)==12
for p in variants:
 im=Image.open(p)
 assert im.mode=='RGBA' and im.size==(128,128),p
 a=im.getchannel('A');assert a.getextrema()==(0,255),p
 assert all(a.getpixel(pos)==0 for pos in [(0,0),(127,0),(0,127),(127,127)]),p
 assert any(0<x<255 for x in a.tobytes()),p
for e in m['pngs']:
 p=OUT/e['file'];im=Image.open(p)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==e['sha256'],p
 assert list(im.size)==e['size'] and im.mode==e['mode'],p
for e in m['inputs']:
 assert hashlib.sha256((OUT/e['snapshot']).read_bytes()).hexdigest()==e['sha256'],e
for e in m['source_files']:
 assert hashlib.sha256((OUT/e['file']).read_bytes()).hexdigest()==e['sha256'],e['file']
protected=json.loads((OUT/'sources/iterations/initial/protected_hashes.json').read_text())
initial=json.loads((OUT/'sources/iterations/initial/manifest.json').read_text())
original={e['file']:e['sha256'] for e in initial['pngs']}
assert len(protected)==8
for path,expected in protected.items():
 assert expected==original[path]
 assert hashlib.sha256((OUT/path).read_bytes()).hexdigest()==expected,path
revised=['cactus_01','cactus_02','empty_camp_01','empty_camp_02']
for name in revised:
 archived=OUT/f'sources/iterations/initial/{name}.png'
 assert hashlib.sha256(archived.read_bytes()).hexdigest()==original[f'variants/{name}.png']
 assert hashlib.sha256((OUT/f'variants/{name}.png').read_bytes()).hexdigest()!=original[f'variants/{name}.png']
for p in variants:
 a=Image.open(p).getchannel('A')
 assert a.crop((0,0,128,1)).getbbox() is None and a.crop((0,127,128,128)).getbbox() is None,p
 assert a.crop((0,0,1,128)).getbbox() is None and a.crop((127,0,128,128)).getbbox() is None,p
comps=json.loads((OUT/'sources/compositions.json').read_text())
for comp in comps:
 before=Image.open(OUT/'sources/references'/comp['source']).convert('RGB')
 after=Image.open(OUT/comp['output']).convert('RGB').crop((0,60,1280,780))
 mask=Image.new('L',before.size);d=ImageDraw.Draw(mask)
 for change in comp['changes']:
  x0,y0,x1,y1=change['rect'];d.rectangle((x0,y0,x1-1,y1-1),fill=255)
 delta=ImageChops.difference(before,after)
 assert Image.composite(Image.new('RGB',before.size),delta,mask).getbbox() is None,comp['output']
reproduced=False
if '--reproduce' in sys.argv:
 with tempfile.TemporaryDirectory(prefix='t523-art-',dir='/tmp') as temp:
  target=Path(temp)/'adornos';shutil.copytree(OUT,target)
  subprocess.run([sys.executable,str(target/'sources/generate_samples.py')],cwd='/tmp',check=True)
  for path in OUT.rglob('*'):
   if path.is_file() and path.name!='verification.json':
    assert path.read_bytes()==(target/path.relative_to(OUT)).read_bytes(),path
  reproduced=True
registered={e['file'] for e in m['pngs']}
assert registered=={str(p.relative_to(OUT)) for p in OUT.rglob('*.png')}
result={'variants':12,'rgba_128':True,'transparent_corners':True,'partial_alpha':True,'png_hashes_checked':len(m['pngs']),'source_hashes_checked':len(m['inputs']),'protected_variants_unchanged':8,'initial_versions_preserved':4,'revised_variants':4,'transparent_borders':True,'composition_outside_cells_unchanged':6,'reproduced_from_tmp':reproduced,'asset_output_scope':'Solo art/m79-muestras/adornos/','result':'PASS','runtime_tested':False,'mobile_tested':False,'performance_tested':False}
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))
