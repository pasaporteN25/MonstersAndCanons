#!/usr/bin/env python3
"""T523: muestras reproducibles; escribe exclusivamente bajo adornos/."""
from pathlib import Path
import json, hashlib, shutil, sys
from PIL import Image, ImageDraw, ImageFont, __version__ as PIL_VERSION
OUT=Path(__file__).resolve().parents[1]
ROOT=OUT.parents[2]
REF=OUT/'sources/references'
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
KINDS=['cactus','red_rock','column','block','statue','empty_camp']
LABELS=['Cactus','Roca roja','Columna','Bloque','Estatua','Campamento vacío']
PIECES={}
PROTECTED=json.loads((OUT/'sources/iterations/initial/protected_hashes.json').read_text())
for path,expected in PROTECTED.items():
 assert hashlib.sha256((OUT/path).read_bytes()).hexdigest()==expected, path
for kind in KINDS:
 for v in [1,2]:
  name=f'{kind}_{v:02}'
  if kind in ['cactus','empty_camp']:
   # Sólo reducción uniforme del raster generado; conserva alfa, luz y proporción.
   source=Image.open(OUT/f'sources/generated/{name}.png').convert('RGBA')
   source.thumbnail((112,112),R)
   im=Image.new('RGBA',(128,128));im.alpha_composite(source,((128-source.width)//2,(128-source.height)//2))
   save(im,f'variants/{name}.png')
  else:
   im=Image.open(OUT/f'variants/{name}.png').convert('RGBA')
  PIECES[name]=im

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
d.text((15,280),'Material y luz T277 · cactus/campamento revisados con IA; ocho variantes preservadas.',font=font(15),fill='white')
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
dump(OUT/'manifest.json',{'task':'T523','status':'Sin integrar; cactus y campamento revisados pendientes de Lucas; otros cuatro motivos con visto bueno 2026-10-26','date':DATE,'author':'Codex (OpenAI)','model':'gpt-6.1-sol','reasoning_effort':'medium','tool':{'python':sys.version.split()[0],'pillow':PIL_VERSION,'renderer':'Revisión cactus/campamento: image_gen nativo, raster original preservado y reducción uniforme Pillow a caja 112x112 en RGBA 128x128; ocho PNG aprobados leídos sin reescritura','resampling':'Lanczos, aproximación de revisión; no emula GPU de Godot'},'sprite_size':[128,128],'intended_tile_size':[64,64],'review_sizes':[220,64,34],'seed_policy':'Reproducción determinista desde fuentes raster preservadas; regenerar con IA desde prompts no garantiza el mismo raster', 'revision_provenance':json.loads((OUT/'sources/generation.json').read_text()), 'protected_variants':PROTECTED, 'source_files':[{'file':str(p.relative_to(OUT)), 'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(list((OUT/'sources').rglob('*'))+[OUT/'prompts.md',OUT/'report.md']) if p.is_file() and p.suffix!='.png'],'inputs':[{'original_path':n,'snapshot':'sources/references/'+Path(n).name,'sha256':hashlib.sha256((REF/Path(n).name).read_bytes()).hexdigest()} for n in INPUTS],'pngs':entries})
print(f'{len(PIECES)} variantes; {len(entries)} PNG registrados.')
