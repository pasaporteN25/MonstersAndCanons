#!/usr/bin/env python3
"""Chequeos de dimensiones, transparencia, integridad y alcance de T523."""
from pathlib import Path
import hashlib, json
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
registered={e['file'] for e in m['pngs']}
assert registered=={str(p.relative_to(OUT)) for p in OUT.rglob('*.png')}
result={'variants':12,'rgba_128':True,'transparent_corners':True,'partial_alpha':True,'png_hashes_checked':len(m['pngs']),'source_hashes_checked':len(m['inputs']),'result':'PASS','runtime_tested':False,'mobile_tested':False,'performance_tested':False}
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))
