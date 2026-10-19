"""Verifica el contrato de entrega de las muestras, sin ejecutar Godot."""
from pathlib import Path
from PIL import Image, ImageChops, ImageStat
from html.parser import HTMLParser
import json, hashlib
OUT=Path(__file__).resolve().parent
checks={}
def check(name,condition,details=None):
 checks[name]={'ok':bool(condition),'detail':details}
 if not condition: raise AssertionError(name)
for name,size,limit in [('boss_burst.png',(1024,512),250000),('boss_crack.png',(192,96),30000),('boss_card_frame.png',(192,128),40000)]:
 im=Image.open(OUT/name)
 check(name,im.size==size and im.mode=='RGBA' and (OUT/name).stat().st_size<limit,{'size':size,'bytes':(OUT/name).stat().st_size,'mode':im.mode})
a=Image.open(OUT/'boss_burst.png')
frame_details=[]
for i in range(8):
 im=a.crop((i%4*256,i//4*256,i%4*256+256,i//4*256+256)); alpha=im.getchannel('A'); bbox=alpha.getbbox(); frame_details.append({'frame':i+1,'alpha_bbox':bbox,'max_alpha':alpha.getextrema()[1]})
 check(f'frame_{i+1}_margin',bbox is None or (bbox[0]>=8 and bbox[1]>=8 and bbox[2]<=248 and bbox[3]<=248),bbox)
 r,g,b,_=im.split(); check(f'frame_{i+1}_neutral',ImageChops.difference(r,g).getbbox() is None and ImageChops.difference(g,b).getbbox() is None)
check('frame_8_empty',frame_details[-1]['alpha_bbox'] is None)
check('frame_1_nearly_empty',frame_details[0]['max_alpha']<20,frame_details[0])
fr=Image.open(OUT/'boss_card_frame.png'); check('frame_center_transparent',fr.getchannel('A').crop((32,32,160,96)).getbbox() is None)
stretched=Image.open(OUT/'review/frame_720.png')
for name,src,dst in [('nw',(0,0,32,32),(0,0,32,32)),('ne',(160,0,192,32),(688,0,720,32)),('sw',(0,96,32,128),(0,88,32,120)),('se',(160,96,192,128),(688,88,720,120))]:
 check('corner_'+name,fr.crop(src).tobytes()==stretched.crop(dst).tobytes())
base=Image.open(OUT/'sources/level_01_reference.png').convert('RGBA')
for i in range(1,9):
 im=Image.open(OUT/f'review/level_frame_{i:02}.png').convert('RGBA'); check(f'hud_unmodified_{i}',im.crop((0,0,1280,48)).tobytes()==base.crop((0,0,1280,48)).tobytes())
for name,size in [('card_720.png',(720,120)),('card_pc_1280.png',(1280,720)),('card_phone_2400.png',(2400,1080))]: check(name,Image.open(OUT/'review'/name).size==size)
gif=Image.open(OUT/'review/entrance_loop.gif'); durations=[]
for i in range(gif.n_frames): gif.seek(i); durations.append(gif.info['duration'])
check('gif_cycle_2100ms',sum(durations)==2100,{'durations_ms':durations,'total_ms':sum(durations),'effect_ms':700,'wait_ms':1400})
m=json.loads((OUT/'manifest.json').read_text())
for name,ref in m['references'].items(): check('reference_'+name,hashlib.sha256((OUT/'sources'/name).read_bytes()).hexdigest()==ref['sha256'])
class Links(HTMLParser):
 def __init__(self): super().__init__(); self.links=[]
 def handle_starttag(self,tag,attrs):
  for key,val in attrs:
   if key in ['src','href'] and val and not val.startswith(('#','http','data:')): self.links.append(val)
p=Links(); p.feed((OUT/'comparison.html').read_text())
check('html_local_links',all((OUT/v).exists() or v=='validation.json' for v in p.links),len(p.links))
report={'passed':True,'check_count':len(checks),'checks':checks,'frames':frame_details,'limits':'Validación mecánica y de montajes; no es validación dentro de Godot.'}
(OUT/'validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(f'{len(checks)} verificaciones correctas; ver validation.json')
