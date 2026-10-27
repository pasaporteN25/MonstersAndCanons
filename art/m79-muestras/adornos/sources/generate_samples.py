#!/usr/bin/env python3
"""T523: muestras reproducibles; escribe exclusivamente bajo adornos/."""
from pathlib import Path
import math, random, json, hashlib, shutil, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont, __version__ as PIL_VERSION
OUT=Path(__file__).resolve().parents[1]
ROOT=OUT.parents[2]
REF=OUT/'sources/references'
S=3; N=128*S
R=Image.Resampling.LANCZOS
DATE='2026-10-26'
INPUTS=[f'assets/sprites/towers/rendered/{n}.png' for n in ['cannon_atlas','basic_atlas','base_1','mechanical_standard_m43']]+[f'assets/sprites/map/rendered/{n}.png' for n in ['rock_a','rock_b','rubble_idle','statue_cannon_moss','statue_basic_moss']]+[f'assets/tiles/rendered/ground_{b}.png' for b in ['desierto','ruinas','volcan','pradera']]+[f'art/m79-inventario/antes-nivel-{n}-1280x720.png' for n in ['10','14','15']]+[f'data/levels/level_{n}.json' for n in ['10','14','15']]
for name in INPUTS:
 target=REF/Path(name).name
 if not target.exists(): shutil.copyfile(ROOT/name,target)

def dump(path,data): path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def save(im,name): im.save(OUT/name,optimize=True)
def font(n): return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',n)
def load(name): return Image.open(REF/(name+'.png')).convert('RGBA')
def line(im,pts,c,w=1): ImageDraw.Draw(im).line([(round(x*S),round(y*S)) for x,y in pts],fill=c,width=max(1,round(w*S)),joint='curve')
def polygon(im,pts,c): ImageDraw.Draw(im).polygon([(round(x*S),round(y*S)) for x,y in pts],fill=c)
def ellipse(im,box,c): ImageDraw.Draw(im).ellipse(tuple(round(t*S) for t in box),fill=c)
def shadow(im,cx=65,cy=108,rx=40,ry=7):
 layer=Image.new('RGBA',im.size);ellipse(layer,(cx-rx,cy-ry,cx+rx,cy+ry),(27,23,27,56));im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(1.8*S)))
 ellipse(im,(cx-rx*.65,cy-ry*.4,cx+rx*.65,cy+ry*.4),(32,25,27,32))

def face(im,pts,base,seed=0,shade=1,material='stone'):
 """Caras pintadas: gradiente direccional, inclusiones y grano multiescala."""
 mask=Image.new('L',im.size);ImageDraw.Draw(mask).polygon([(round(x*S),round(y*S)) for x,y in pts],fill=255)
 box=mask.getbbox()
 if not box:return
 rng=random.Random(seed);p=im.load();m=mask.load()
 for y in range(box[1],box[3]):
  for x in range(box[0],box[2]):
   if not m[x,y]:continue
   xx=x/S;yy=y/S
   noise=rng.uniform(-7,7)+3*math.sin(xx*.51+math.sin(yy*.7)*3)+3*math.sin(yy*.39+math.cos(xx*.6)*2)
   grain=3.5*math.sin(xx*.16+yy*.24)*math.cos(yy*.3-xx*.21)
   grad=1+.055*(64-xx)/64+.045*(70-yy)/64
   if material=='cloth':noise*=.25;grain=1.6*math.sin(xx*9)+1.8*math.sin(yy*8)
   elif rng.random()<.015:noise-=20
   rgb=tuple(max(0,min(255,round(c*shade*grad+noise+grain))) for c in base)
   p[x,y]=(*rgb,255)
 # Luz fragmentada, sin contorno vectorial grueso.
 a,b=pts[0],pts[1];line(im,[a,((a[0]+b[0])*.5,(a[1]+b[1])*.5)],tuple(min(255,int(c*shade+24)) for c in base)+(255,),.55)

def shard(im,x,y,w,h,seed=1,base=(137,133,122)):
 pts=[(x,y),(x+w*.5,y-h*.4),(x+w,y-h*.1),(x+w*.9,y+h*.65),(x+w*.35,y+h),(x-w*.06,y+h*.6)]
 face(im,[pts[0],pts[1],pts[2],(x+w*.58,y+h*.4)],base,seed,1.22)
 face(im,[pts[0],(x+w*.58,y+h*.4),pts[4],pts[5]],base,seed+1,.86)
 face(im,[(x+w*.58,y+h*.4),pts[2],pts[3],pts[4]],base,seed+2,.60)

def prism(im,x,y,w,h,depth=12,seed=0):
 b=(143,140,132)
 face(im,[(x,y-h),(x+depth,y-h-depth*.6),(x+w,y-h-depth*.4),(x+w-4,y-h+4),(x+w-depth,y-h+depth*.7)],b,seed,1.22)
 face(im,[(x,y-h),(x+w-depth,y-h+depth*.7),(x+w-depth,y+depth*.7),(x+2,y+2)],b,seed+1,.90)
 face(im,[(x+w-depth,y-h+depth*.7),(x+w-4,y-h+4),(x+w,y-h-depth*.4),(x+w-1,y),(x+w-depth,y+depth*.7)],b,seed+2,.60)
 face(im,[(x+3,y-h+2),(x+8,y-h+4),(x+5,y-h+10),(x+1,y-h+7)],(100,103,96),seed+8,.8)
 line(im,[(x+w*.3,y-h+5),(x+w*.38,y-h+12),(x+w*.26,y-h+17)],'#56574f',.8)

def ruin(kind,v):
 im=Image.new('RGBA',(N,N));shadow(im)
 if kind=='column':
  if v==1:
   prism(im,34,99,57,10,12,10)
   # Fuste octogonal roto; coronamiento irregular sin plataforma entera.
   face(im,[(46,88),(43,39),(49,28),(57,34),(61,26),(67,31),(66,90)],(159,157,145),22,1.08)
   face(im,[(66,90),(67,31),(75,37),(79,34),(83,43),(80,91)],(132,132,126),23,.72)
   face(im,[(43,39),(49,28),(57,34),(61,26),(67,31),(75,37),(64,41),(56,38)],(174,171,156),24,1.18)
   for x in [49,57,65]:
    line(im,[(x,45),(x+1,83)],'#73756b',1.6);line(im,[(x-1.3,45),(x-.3,80)],'#bcbbaa',.65)
   line(im,[(66,54),(61,63),(65,70),(61,77)],'#515750',.9)
   shard(im,86,97,22,12,30);shard(im,27,103,13,7,31)
  else:
   # Tambor de columna caído: acanaladuras longitudinales y fractura maciza.
   face(im,[(23,86),(40,65),(88,79),(105,92),(85,107),(39,100)],(147,146,136),41,.84)
   face(im,[(23,86),(30,69),(44,58),(91,72),(88,79),(40,78)],(167,164,150),42,1.12)
   face(im,[(88,79),(91,72),(104,81),(108,93),(97,102),(85,107)],(122,125,120),43,.69)
   for y in [77,84,92]:
    line(im,[(37,y),(83,y+13)],'#646b64',1.6);line(im,[(37,y-1),(81,y+11)],'#b7b7a6',.7)
   shard(im,18,103,20,10,44);shard(im,99,105,13,7,45)
 else:
  if v==1:
   prism(im,24,97,69,34,17,50);shard(im,84,101,24,11,51);shard(im,18,103,17,7,52)
   # Esquinas faltantes y fracturas que interrumpen la forma intacta.
   face(im,[(43,66),(49,68),(46,78),(39,77)],(78,79,73),55,.9)
   line(im,[(69,81),(63,88),(66,96)],'#515851',1.1)
   face(im,[(75,66),(89,67),(84,75),(79,78),(72,74)],(104,107,99),56,.82)
   face(im,[(24,91),(34,94),(39,102),(26,99)],(107,109,99),57,.8)
   shard(im,73,104,15,8,58)
  else:
   prism(im,26,101,65,19,15,60);prism(im,37,80,55,22,15,63)
   shard(im,16,103,20,9,66);shard(im,88,99,24,12,67)
   line(im,[(48,73),(61,74),(65,81)],'#535951',1)
   face(im,[(70,62),(86,61),(82,70),(77,73)],(93,98,91),68,.88)
   shard(im,64,106,18,7,69)
 return im.resize((128,128),R)

def cactus(v):
 im=Image.new('RGBA',(N,N));shadow(im,65,111,30,5)
 # Ramas como cápsulas curvas en volumen, con costillas.
 paths=([([(61,108),(60,70),(60,27)],12), ([(58,77),(36,73),(32,63),(32,47)],8), ([(66,65),(86,60),(89,49),(89,36)],8)] if v==1 else [([(72,109),(72,67),(70,40)],13), ([(65,82),(43,79),(37,65),(37,31)],10), ([(78,86),(94,83),(99,74),(99,59)],7)])
 for idx,(pts,radius) in enumerate(paths):
  segments=[]
  for a,b in zip(pts,pts[1:]):
   length=math.dist(a,b)
   for i in range(int(length*2)+1):
    t=i/max(1,int(length*2));segments.append((a[0]*(1-t)+b[0]*t,a[1]*(1-t)+b[1]*t))
  mask=Image.new('L',im.size);md=ImageDraw.Draw(mask)
  md.line([(int(x*S),int(y*S)) for x,y in pts],fill=255,width=radius*2*S,joint='curve')
  for x,y in pts:md.ellipse(((x-radius)*S,(y-radius)*S,(x+radius)*S,(y+radius)*S),fill=255)
  p=im.load();m=mask.load();box=mask.getbbox();rng=random.Random(523+v*10+idx)
  for y in range(box[1],box[3]):
   for x in range(box[0],box[2]):
    if not m[x,y]:continue
    px,py=x/S,y/S
    cx,cy=min(segments,key=lambda q:(q[0]-px)**2+(q[1]-py)**2)
    u=(px-cx)/radius;vv=(py-cy)/radius;rr=min(.999,u*u+vv*vv)
    z=math.sqrt(1-rr);light=max(0,-.52*u-.45*vv+.71*z)
    rib=math.cos(math.asin(max(-1,min(1,u)))*10)*8+2*math.sin(py*.9+px*.3)
    shade=.34+.70*(round(light*8)/8);grain=rng.uniform(-2.2,2.2)
    p[x,y]=tuple(max(0,min(255,int(c*shade+rib+grain))) for c in (104,131,65))+(255,)
  for x,y in segments[::16]:
   for off in [-.55,.15,.65]:
    line(im,[(x+radius*off,y),(x+radius*off-1,y-1.3)],'#c4bb8a',.45)
 shard(im,45,109,13,5,75,(147,113,79));shard(im,77,110,11,5,76,(147,113,79))
 return im.resize((128,128),R)

def derivative(kind,v):
 name=('rock_a' if v==1 else 'rock_b') if kind=='red_rock' else ('statue_cannon_moss' if v==1 else 'statue_basic_moss')
 im=load(name);p=im.load();rng=random.Random(52300+v)
 for y in range(128):
  for x in range(128):
   r,g,b,a=p[x,y]
   if not a:continue
   if a<180:continue # sombra original conservada
   lum=.25*r+.57*g+.18*b
   if kind=='red_rock':
    # Reemplaza también el musgo por polvo mineral, sin verde.
    lum=lum*.95+4
    vals=(lum*1.29,lum*.77,lum*.57)
    strata=2.4*math.sin(y*1.9+x*.055)
    vals=tuple(c+strata for c in vals)
   else:
    # Gris mate, sin color metálico ni colonias verdes.
    lum=43+lum*.66
    mineral=5*math.sin(x*.53+math.sin(y*.4)*2)+4*math.sin(y*.9+x*.2)+rng.uniform(-7,7)
    vals=(lum+mineral,lum+1+mineral,lum+2+mineral)
    dust=max(0,(y-76)/52)*.11
    vals=tuple(c*(1-dust)+t*dust for c,t in zip(vals,(153,141,124)))
   p[x,y]=tuple(max(0,min(255,round(c))) for c in vals)+(a,)
 return im

def camp(v):
 im=Image.new('RGBA',(N,N));shadow(im,65,107,43,6)
 # Lona caída al suelo con pliegues bajos.
 if v==1:
  shapes=[([(23,94),(38,69),(54,74),(73,89),(95,96),(78,102),(54,93),(34,101)],1), ([(38,69),(51,80),(73,89),(61,90),(47,85)],1.25), ([(34,101),(45,83),(54,93),(50,100)],.56), ([(61,90),(73,89),(95,96),(78,102)],.75)]
 else:
  shapes=[([(20,94),(30,82),(48,78),(62,87),(78,79),(101,93),(90,102),(68,96),(47,103)],1), ([(30,82),(48,78),(62,87),(50,88)],1.25), ([(62,87),(78,79),(101,93),(79,91)],1.16), ([(47,103),(50,88),(68,96)],.58)]
 # Estacas quebradas caídas, sin mástil vertical.
 for a,b in [((19,98),(35,77)),((83,102),(108,91))]:
  line(im,[a,b],'#49392b',4);line(im,[(a[0]-1,a[1]-1),(b[0]-1,b[1]-1)],'#b09368',1)
 for i,(pts,s) in enumerate(shapes):face(im,pts,(132,105,76) if v==1 else (112,108,88),90+i,s,'cloth')
 line(im,[(39,73),(51,83),(70,91)],'#c5b18c',.6)
 # Fogón apagado con ceniza, sin fuego, botín ni objeto interactivo.
 ellipse(im,(61,96,89,111),'#48453e');ellipse(im,(65,99,85,107),'#69675e')
 for i in range(8):
  t=i*math.tau/8;x=74+13*math.cos(t);y=103+6*math.sin(t)
  shard(im,x-3,y-2,6,4,110+i,(133,131,119))
 line(im,[(69,102),(80,105)],'#302d2a',2);line(im,[(72,106),(78,100)],'#35312c',1.6)
 return im.resize((128,128),R)

KINDS=['cactus','red_rock','column','block','statue','empty_camp']
LABELS=['Cactus','Roca roja','Columna','Bloque','Estatua','Campamento vacío']
PIECES={}
for kind in KINDS:
 for v in [1,2]:
  im=cactus(v) if kind=='cactus' else derivative(kind,v) if kind in ['red_rock','statue'] else camp(v) if kind=='empty_camp' else ruin(kind,v)
  name=f'{kind}_{v:02}';PIECES[name]=im;save(im,f'variants/{name}.png')

def ground(b,size):return load('ground_'+b).resize((size,size),R)
# Hojas: cada miniatura mide exactamente el tamaño nominal; rótulos fuera del sprite.
for size in [220,64,34]:
 pad=18;cw=max(145,size+20);ch=size+45
 for bg in ['transparent','context']:
  sheet=Image.new('RGBA',(cw*4+pad*2,ch*6+65),(0,0,0,0) if bg=='transparent' else (30,34,38,255));d=ImageDraw.Draw(sheet)
  d.text((pad,9),f'T523 · MUESTRAS SIN INTEGRAR · lienzos a {size} px',font=font(14),fill='#9a805e' if bg=='transparent' else '#f1e8d1')
  for k,kind in enumerate(KINDS):
   biomes=['desierto','desierto','ruinas','ruinas','ruinas','pradera'];b=biomes[k]
   for v in [1,2]:
    # Dos fondos por variante: contexto primario y camino/volcán secundario.
    for j in [0,1]:
     col=(v-1)*2+j;x=pad+col*cw+(cw-size)//2;y=43+k*ch
     if bg=='context':
      tile=ground('volcan' if j and kind in ['column','block','statue'] else 'ruinas' if j and kind=='empty_camp' else b,size)
      if j and kind in ['cactus','red_rock']:
       tile=Image.new('RGBA',(size,size),'#ab9067')
      sheet.alpha_composite(tile,(x,y))
     sheet.alpha_composite(PIECES[f'{kind}_{v:02}'].resize((size,size),R),(x,y))
     d.text((pad+col*cw+4,y+size+4),f'{LABELS[k]} {v:02}',font=font(11),fill='#9a805e' if bg=='transparent' else '#efe5d0')
     if bg=='context':d.text((pad+col*cw+4,y+size+20),('volcán (compat.)' if j and kind in ['column','block','statue'] else 'ruinas' if j and kind=='empty_camp' else 'camino neutro*' if j else b),font=font(10),fill='#b8b8ad')
  save(sheet,f'contact_{size:03}_{bg}.png')
# Comparación con referencias originales sin modificar.
board=Image.new('RGBA',(900,340),'#33363a');d=ImageDraw.Draw(board)
for i,n in enumerate(['rock_a','rock_b','rubble_idle','statue_cannon_moss','statue_basic_moss']):
 x=10+i*176;board.alpha_composite(load(n).resize((170,170),R),(x,40));d.text((x,225),n,font=font(11),fill='white')
d.text((15,10),'Referencias existentes T277 · originales, sin modificación',font=font(17),fill='white')
d.text((15,280),'Rocas y estatuas: derivados cromáticos. Resto: geometría procedural original.',font=font(15),fill='white')
save(board,'reference_board.png')
# Montajes en casillas existentes; no agregan posiciones ni alteran JSON.
# Nivel 10: 24 columnas, tile 576/11; 14/15: 26 columnas, tile 48.
placements={10:[('cactus',(0,0)),('cactus',(1,0)),('red_rock',(7,0)),('red_rock',(11,0)),('column',(1,3))],14:[('column',(0,0)),('block',(1,0)),('statue',(1,1)),('empty_camp',(16,1)),('column',(4,2)),('block',(6,1)),('statue',(14,1))],15:[]}
for n in [15]:
 data=json.loads((REF/f'level_{n}.json').read_text())
 placements[n]=[('empty_camp',(x,y)) for y,row in enumerate(data['mapa']) for x,ch in enumerate(row) if ch=='c']
comps=[]
for n,items in placements.items():
 data=json.loads((REF/f'level_{n}.json').read_text());tile=576/11 if n==10 else 48;ox=(1280-len(data['mapa'][0])*tile)/2;oy=48
 for v in [1,2]:
  im=load(f'antes-nivel-{n:02}-1280x720');changes=[]
  for kind,(x,y) in items:
   ch=data['mapa'][y][x];assert ch=='X' or data['leyenda'].get(ch,{}).get('dibujo') in ['columna','campamento_vacio'],(n,kind,x,y,ch)
   x0,y0,x1,y1=round(ox+x*tile),round(oy+y*tile),round(ox+(x+1)*tile),round(oy+(y+1)*tile)
   # Repone solamente la casilla de suelo debajo del adorno anterior.
   im.alpha_composite(load('ground_'+data['tema']).resize((x1-x0,y1-y0),R),(x0,y0))
   im.alpha_composite(PIECES[f'{kind}_{v:02}'].resize((x1-x0,y1-y0),R),(x0,y0))
   changes.append({'piece':f'{kind}_{v:02}','cell':[x,y],'original_character':ch,'rect':[x0,y0,x1,y1]})
  canvas=Image.new('RGBA',(1280,780),'#23272c');canvas.alpha_composite(im,(0,60));d=ImageDraw.Draw(canvas)
  d.text((18,8),f'COMPOSICIÓN DE MUESTRA · nivel {n} · variantes {v:02} · SIN INTEGRAR',font=font(20),fill='#f4dcac')
  d.text((18,35),'Superposición Pillow sobre captura real T491; suelo repuesto en casillas listadas. El motor no dibujó estas muestras.',font=font(15),fill='white')
  name=f'context_level_{n:02}_{v:02}.png';save(canvas,name)
  comps.append({'output':name,'source':f'antes-nivel-{n:02}-1280x720.png','theme':data['tema'],'tile_screen_px':tile,'origin':[ox,oy],'changes':changes,'note':'Composición externa; coordenadas de celda x,y desde cero; captura desplazada 60 px por rótulo.'})
dump(OUT/'sources/compositions.json',comps)
# Revisión comparada de estatuas, armas activas y Estandarte a escala de lienzo.
comparison=Image.new('RGBA',(940,315),'#272b2f');d=ImageDraw.Draw(comparison)
d.text((16,10),'Revisión de lectura · estatuas de piedra frente a torres activas',font=font(17),fill='white')
refs=[('Estatua 01',PIECES['statue_01']),('Estatua 02',PIECES['statue_02'])]
for name,label in [('cannon_atlas','Cañón activo'),('basic_atlas','Básica activa')]:
 active=load('base_1');active.alpha_composite(load(name).crop((0,0,128,128)));refs.append((label,active))
refs.append(('Estandarte',load('mechanical_standard_m43')))
for i,(label,sprite) in enumerate(refs):
 x=15+i*184;d.text((x,48),label,font=font(14),fill='white')
 for y,size in [(82,64),(194,34)]:
  comparison.alpha_composite(ground('ruinas',size),(x,y));comparison.alpha_composite(sprite.resize((size,size),R),(x,y))
  d.text((x+size+7,y+10),str(size)+' px',font=font(12),fill='white')
d.text((15,280),'Comparación de texturas a igual lienzo; no simula escalas relativas ni funcionamiento del juego.',font=font(13),fill='#ddcbae')
save(comparison,'statue_comparison.png')
# Manifiesto de todas las imágenes, fuentes incluidas; no se incluye a sí mismo.
entries=[]
for p in sorted(OUT.rglob('*.png')):
 im=Image.open(p);alpha=im.getchannel('A') if im.mode=='RGBA' else None
 entries.append({'file':str(p.relative_to(OUT)),'size':list(im.size),'mode':im.mode,'alpha_extrema':list(alpha.getextrema()) if alpha else None,'alpha_bbox':list(alpha.getbbox()) if alpha and alpha.getbbox() else None,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
dump(OUT/'manifest.json',{'task':'T523','status':'Muestras sin integrar; aprobación de Lucas pendiente','date':DATE,'author':'Codex (OpenAI)','model':'gpt-6.1-sol','reasoning_effort':'medium','tool':{'python':sys.version.split()[0],'pillow':PIL_VERSION,'renderer':'Pillow procedural supersampling 3x + derivados cromáticos de PNG propios','resampling':'Lanczos, aproximación de revisión; no emula GPU de Godot'},'sprite_size':[128,128],'intended_tile_size':[64,64],'review_sizes':[220,64,34],'seed_policy':'Semillas fijas literales en generate_samples.py; sin aleatoriedad global','inputs':[{'original_path':n,'snapshot':'sources/references/'+Path(n).name,'sha256':hashlib.sha256((REF/Path(n).name).read_bytes()).hexdigest()} for n in INPUTS],'pngs':entries})
print(f'{len(PIECES)} variantes; {len(entries)} PNG registrados.')
