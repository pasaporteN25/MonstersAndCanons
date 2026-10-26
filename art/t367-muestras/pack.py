"""Genera muestras nativas y montajes; no ejecuta ni modifica el juego."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageChops
import math, json, random, shutil, hashlib
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
S=3
FONT='/usr/share/fonts/truetype/lato/Lato-Regular.ttf'
def save(im,path): im.save(OUT/path,optimize=True)
def canvas(w,h): return Image.new('RGBA',(w*S,h*S))
def poly(d,pts,c): d.polygon([(round(x*S),round(y*S)) for x,y in pts], fill=c)
def line(d,pts,c,w=1): d.line([(round(x*S),round(y*S)) for x,y in pts], fill=c,width=max(1,round(w*S)),joint='curve')
def ellipse(d,box,c,w=None):
 b=tuple(round(v*S) for v in box)
 if w: d.ellipse(b,outline=c,width=round(w*S))
 else: d.ellipse(b,fill=c)
def finish(im):
 im=im.resize((im.width//S,im.height//S),Image.Resampling.LANCZOS)
 # El RGB de los texeles sin cobertura queda neutro: evita bordes oscuros al modular.
 px=im.load()
 for y in range(im.height):
  for x in range(im.width):
   if px[x,y][3]==0: px[x,y]=(255,255,255,0)
 return im
frames=[]
strength=[.05,.65,1,.85,.62,.38,.17,0]
for i,a in enumerate(strength):
 im=canvas(256,256); d=ImageDraw.Draw(im)
 if a:
  r=12+i*14; ry=r*.30
  ellipse(d,(128-r,176-ry,128+r,176+ry),(238,238,238,int(180*a)),2.5)
  # Halo ascendente estratificado, sin filtros ni fuego; centro despejado.
  for j in range(5):
   rx=12+i*4+j*3; cy=170-i*3-j*3
   ellipse(d,(128-rx,cy-8,128+rx,cy+5),(242,242,242,int(14*a)))
  # Polvo abierto en dos bancos: el hueco central permite leer el cuerpo.
  for side in [-1,1]:
   for bank in range(4):
    cx=128+side*(19+i*7+bank*6); cy=173-bank*7-i*2
    rx=9+bank*2; ry=5+bank*2
    ellipse(d,(cx-rx,cy-ry,cx+rx,cy+ry),(235,235,235,int((70-bank*10)*a)))
  # Columna baja de luz: el resplandor sale del suelo y se extingue pronto.
  if i<4:
   for band in range(7):
    rx=19-band*1.4; cy=173-band*5
    ellipse(d,(128-rx,cy-4,128+rx,cy+4),(255,255,255,int((115-band*12)*a*(1-i/5))))
  rng=random.Random(367)
  for k in range(18):
   angle=rng.uniform(0,math.tau); spread=14+i*11
   x=128+math.cos(angle)*spread
   y=176+math.sin(angle)*spread*.23-math.sin((i+1)/8*math.pi)*rng.uniform(12,67)
   size=rng.uniform(3,7)*(1-i*.035)
   # Polvo facetado, sin borde oscuro para admitir tinte multiplicativo.
   poly(d,[(x-size,y),(x-size*.3,y-size*.65),(x+size*.8,y-size*.4),(x+size,y+2),(x,y+size*.5)],(219,219,219,int(58*a)))
   if k%2==0:
    poly(d,[(x-3,y-4),(x+3,y-5),(x+5,y),(x-1,y+3)],(179,179,179,int(230*a)))
    line(d,[(x-3,y-4),(x+3,y-5)],(255,255,255,int(245*a)),1)
 im=finish(im); frames.append(im); save(im,f'sources/burst_{i+1:02}.png')
atlas=Image.new('RGBA',(1024,512),(255,255,255,0))
for i,im in enumerate(frames): atlas.paste(im,((i%4)*256,(i//4)*256))
save(atlas,'boss_burst.png')
cr=canvas(192,96); d=ImageDraw.Draw(cr); rng=random.Random(99)
for k in range(9):
 angle=k*math.tau/9+.14; pts=[(96,48)]
 for j in range(1,5):
  x=96+math.cos(angle)*j*18; y=48+math.sin(angle)*j*8+rng.uniform(-3,3); pts.append((x,y))
 line(d,pts,(99,92,80,40),6)
 line(d,pts,(58,54,49,155),1.4)
 branch=pts[2]; line(d,[branch,(branch[0]+rng.uniform(-12,12),branch[1]-9)],(71,65,56,110),1)
cr=finish(cr); save(cr,'boss_crack.png'); save(cr,'sources/crack_original.png')
fr=canvas(192,128); d=ImageDraw.Draw(fr)
# Aro de hierro, contorno continuo y un bisel claro superior/izquierdo.
for inset,color in [(1,'#2b2233'),(3,'#88623d'),(5,'#b18a52'),(7,'#2b2233'),(9,'#50535a'),(14,'#2b2233')]:
 d.rectangle((inset*S,inset*S,(192-inset-1)*S,(128-inset-1)*S),outline=color,width=2*S)
line(d,[(10,115),(10,10),(181,10)],'#8b8c90',1)
for x,y in [(18,18),(174,18),(18,110),(174,110)]:
 poly(d,[(x-9,y-9),(x+8,y-9),(x+9,y+7),(x+6,y+9),(x-9,y+9)],'#2b2233')
 poly(d,[(x-7,y-7),(x+6,y-7),(x+7,y+6),(x-7,y+7)],'#866140')
 ellipse(d,(x-4,y-4,x+4,y+4),'#2b2233')
 ellipse(d,(x-3,y-3,x+3,y+3),'#bc945b')
 line(d,[(x-2,y-2),(x+1,y-2)],'#ead0a0',1)
fr=finish(fr); save(fr,'boss_card_frame.png'); save(fr,'sources/frame_original.png')
def nine(im,w,h):
 out=Image.new('RGBA',(w,h)); a=[0,32,160,192]; b=[0,32,96,128]; xx=[0,32,w-32,w]; yy=[0,32,h-32,h]
 for y in range(3):
  for x in range(3):
   part=im.crop((a[x],b[y],a[x+1],b[y+1])).resize((xx[x+1]-xx[x],yy[y+1]-yy[y]),Image.Resampling.BILINEAR)
   out.paste(part,(xx[x],yy[y]))
 return out
save(nine(fr,720,120),'review/frame_720.png')
# Copias exactas de referencias: todos los vínculos de la hoja funcionan sin salir de esta carpeta.
refs={'level_01_reference.png':'art/t277-integracion/level_01_initial.png','boss_reference.png':'assets/sprites/enemies/rendered/boss.png','boss_walk_reference.png':'assets/sprites/enemies/rendered/boss_walk.png'}
for dst,src in refs.items(): shutil.copyfile(ROOT/src,OUT/'sources'/dst)
base=Image.open(OUT/'sources/level_01_reference.png').convert('RGBA')
boss=Image.open(OUT/'sources/boss_reference.png').convert('RGBA')
walk=Image.open(OUT/'sources/boss_walk_reference.png').convert('RGBA')
def tint(im,color):
 c=Image.new('RGBA',im.size,color); result=ImageChops.multiply(im,c); result.putalpha(im.getchannel('A')); return result
colors={'neutral':'#ffffff','crimson':'#ba403e','steel':'#547ea9','green':'#72954e','data_red':'#c0392b'}
# Contacto en ocho columnas, 256 px exactos; suelo/camino tomados de la captura real.
for label,color in colors.items():
 sheet=Image.new('RGBA',(8*256,304)); small=Image.new('RGBA',(8*76,94))
 for i,im in enumerate(frames):
  tile=base.crop((640,48,896,304)); tile.alpha_composite(tint(im,color)); tile.alpha_composite(boss.resize((34,34)),(214,208))
  ImageDraw.Draw(tile).text((10,232),f'{i+1} · {i*.0875:.3f} s',font=ImageFont.truetype(FONT,16),fill='white')
  sheet.paste(tile,(i*256,36));
  t=base.crop((400,80,476,174)); t.alpha_composite(tint(im,color).resize((34,34)),(2,32)); t.alpha_composite(boss.resize((34,34)),(40,32)); small.paste(t,(i*76,0))
 ImageDraw.Draw(sheet).text((10,8),label+' · 256 px · referencia Jefe 34 px',font=ImageFont.truetype(FONT,18),fill='white')
 save(sheet,f'review/contact_{label}_256.png'); save(small,f'review/contact_{label}_34.png')
montages=[]
for i,im in enumerate(frames):
 comp=base.copy(); crack=cr.copy(); crack.putalpha(cr.getchannel('A').point(lambda v:int(v*(1-i/7))))
 comp.alpha_composite(crack,(-64,96)); comp.alpha_composite(tint(im,'#ba403e'),(-96,-32))
 # La velocidad solo sirve para el montaje: 0,6 casillas/s, sin cambiar datos.
 sprite=walk.crop(((i%4)*256,0,(i%4+1)*256,256)).resize((56,56),Image.Resampling.LANCZOS)
 comp.alpha_composite(sprite,(4+round(i*.0875*.6*64),102))
 save(comp,f'review/level_frame_{i+1:02}.png'); montages.append(comp)
# GIF: ocho cuadros en 700 ms y una espera final de 1,4 s; sin alterar el atlas.
gifs=[x.convert('RGB').quantize(colors=128) for x in montages]
gifs.append(gifs[-1].copy()); gifs[0].save(OUT/'review/entrance_loop.gif',save_all=True,append_images=gifs[1:],duration=[90,90,80,90,90,80,90,90,1400],loop=0,optimize=False)
card=Image.new('RGBA',(720,120),'#202126'); card.alpha_composite(nine(fr,720,120)); card.alpha_composite(boss.resize((96,96)),(12,12))
d=ImageDraw.Draw(card); d.text((120,10),'¡Llega el Jefe!',font=ImageFont.truetype(FONT,23),fill='#f0d2a1'); d.text((120,38),'Jefe',font=ImageFont.truetype(FONT,20),fill='white')
description='Mucha vida y armadura; el Hielo lo frena a medias. ¡Si llega, quita 10 vidas!'
words=description.split(); lines=['']
for word in words:
 trial=(lines[-1]+' '+word).strip()
 if d.textlength(trial,font=ImageFont.truetype(FONT,20))>572: lines.append(word)
 else: lines[-1]=trial
for j,txt in enumerate(lines): d.text((120,63+j*23),txt,font=ImageFont.truetype(FONT,20),fill='#e5dfd4')
save(card,'review/card_720.png'); comp=base.copy(); comp.alpha_composite(card,(280,56)); save(comp,'review/card_pc_1280.png')
phone=Image.new('RGBA',(2400,1080),'#141619'); phone.alpha_composite(comp.resize((1920,1080)),(240,0)); save(phone,'review/card_phone_2400.png')
manifest={'task':'T367','status':'MUESTRAS — pendiente de aprobación','integrated':False,'generator':'pack.py (Pillow; fuentes nativas, sin IA generativa)','burst':{'file':'boss_burst.png','size':[1024,512],'grid':[4,2],'frame_size':[256,256],'anchor':[128,176],'duration_seconds':.7,'fps':8/.7,'order':'izquierda a derecha, arriba a abajo','minimum_margin':8,'tinted':True,'mipmaps':False},'crack':{'file':'boss_crack.png','size':[192,96],'anchor':[96,48],'tinted':False,'duration_seconds':.7,'mipmaps':False},'frame':{'file':'boss_card_frame.png','size':[192,128],'slice_margins':[32,32,32,32],'display_size':[720,120],'transparent_center':True,'mipmaps':False},'references':{k:{'source':v,'sha256':hashlib.sha256((ROOT/v).read_bytes()).hexdigest()} for k,v in refs.items()},'mockup':{'foot_screen':[32,144],'effect_top_left':[-96,-32],'hud_bottom_y':48,'phone_scale':1.5,'phone_sidebars':240,'game_capture_is_historical':True,'walking_preview_is_approximate':True},'tints':colors,'files':{n:{'bytes':(OUT/n).stat().st_size,'size':Image.open(OUT/n).size,'mode':Image.open(OUT/n).mode} for n in ['boss_burst.png','boss_crack.png','boss_card_frame.png']}}
(OUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(manifest['files'],indent=2))
