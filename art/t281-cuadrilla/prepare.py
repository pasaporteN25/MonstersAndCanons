"""Normaliza fuentes por alfa y arma atlas/hojas; no repinta ni inventa fases."""
from pathlib import Path
from collections import deque
import hashlib
import json
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 13)
records = {}

def extract_actors(source):
    # La grilla generada tiene filas desalineadas: separar cuerpos por alfa,
    # nunca cortar por cuartos geométricos que podrían amputar una pose.
    width,height=source.size
    pixels=bytearray(source.getchannel('A').point(lambda v: 255 if v>8 else 0).tobytes())
    components=[]
    for start in range(len(pixels)):
        if not pixels[start]:
            continue
        pixels[start]=0
        queue=deque([start]);count=0
        left=right=start%width;top=bottom=start//width
        while queue:
            pos=queue.popleft();x=pos%width;y=pos//width;count+=1
            left=min(left,x);right=max(right,x);top=min(top,y);bottom=max(bottom,y)
            neighbors=[]
            if x>0:neighbors.append(pos-1)
            if x<width-1:neighbors.append(pos+1)
            if y>0:neighbors.append(pos-width)
            if y<height-1:neighbors.append(pos+width)
            for neighbor in neighbors:
                if pixels[neighbor]:pixels[neighbor]=0;queue.append(neighbor)
        if count>500:
            components.append((left,top,right+1,bottom+1))
    assert len(components)==16,components
    components.sort(key=lambda b:(b[1]+b[3])/2)
    ordered=[]
    for row in range(4):
        ordered.extend(sorted(components[row*4:row*4+4],key=lambda b:(b[0]+b[2])/2))
    # Tres píxeles de borde conservan el antialias del original sin repintar.
    boxes=[(max(0,l-3),max(0,t-3),min(width,r+3),min(height,b+3)) for l,t,r,b in ordered]
    return [source.crop(box) for box in boxes],boxes

def normalized(im, factor=None):
    box = im.getchannel('A').getbbox()
    assert box
    crop = im.crop(box)
    scale = factor or min(162 / crop.height, 218 / crop.width)
    crop = crop.resize((round(crop.width * scale), round(crop.height * scale)), Image.Resampling.LANCZOS)
    crop = crop.crop(crop.getchannel('A').getbbox())
    out = Image.new('RGBA', (256, 256))
    out.alpha_composite(crop, ((256-crop.width)//2, 192-crop.height))
    return out

for name in ['ratero_b', 'ratero_c', 'cargador_a', 'cargador_b']:
    im = Image.open(HERE/'sources'/f'{name}.png').convert('RGBA')
    assert im.getchannel('A').getextrema()[0] == 0
    normalized(im).save(HERE/'derived'/f'{name}.png')

for name in ['ratero', 'cargador']:
    source = Image.open(HERE/'sources'/f'{name}_walk.png').convert('RGBA')
    assert source.width == source.height
    frames,source_boxes = extract_actors(source)
    boxes = [im.getchannel('A').getbbox() for im in frames]
    factor = min(162/max(b[3]-b[1] for b in boxes),218/max(b[2]-b[0] for b in boxes))
    atlas = Image.new('RGBA',(1024,1024))
    normalized_frames = []
    for i, im in enumerate(frames):
        out = normalized(im, factor)
        b = out.getchannel('A').getbbox()
        assert b[0]>0 and b[1]>0 and b[2]<256 and b[3]==192
        atlas.alpha_composite(out,((i%4)*256,(i//4)*256))
        normalized_frames.append(out)
    atlas.save(HERE/'derived'/f'{name}_walk.png')
    normalized_frames[0].save(HERE/'derived'/f'{name}.png')
    hashes = [hashlib.sha256(im.tobytes()).hexdigest() for im in normalized_frames]
    assert len(set(hashes)) == 16
    assert normalized_frames[0].tobytes() == Image.open(HERE/'derived'/f'{name}.png').tobytes()
    records[name]={'source_size':source.size,'source_actor_boxes':source_boxes,'extraction':'16 connected alpha components, threshold 8 and 3px crop padding','atlas_size':atlas.size,'rows':['right','down','left','up'], 'phases':4,'unique_frames':len(set(hashes)),'baseline_alpha_exclusive':192,'uniform_source_scale':factor,'bounds': [im.getchannel('A').getbbox() for im in normalized_frames], 'source_sha256':hashlib.sha256((HERE/'sources'/f'{name}_walk.png').read_bytes()).hexdigest()}
    # Cada GIF muestra las cuatro direcciones a la vez, no la velocidad jugable.
    previews=[]
    for phase in range(4):
        canvas=Image.new('RGB',(512,180),'#91aa69')
        d=ImageDraw.Draw(canvas)
        for row,label in enumerate(['derecha','abajo','izquierda','arriba']):
            im=normalized_frames[row*4+phase].resize((128,128),Image.Resampling.LANCZOS)
            canvas.paste(im,(row*128,30),im)
            d.text((row*128+8,8),label,font=FONT,fill='black')
        previews.append(canvas)
    previews[0].save(HERE/'review'/f'{name}_walk.gif',save_all=True,append_images=previews[1:],duration=140 if name=='ratero' else 260,loop=0)

items=[('Ratero B · concepto',HERE/'derived/ratero_b.png'),('Ratero C · alternativo',HERE/'derived/ratero_c.png'),('Cargador A · mochila',HERE/'derived/cargador_a.png'),('Cargador B · abrazo',HERE/'derived/cargador_b.png'),('Ratero B · ciclo',HERE/'derived/ratero.png'),('Cargador A · ciclo',HERE/'derived/cargador.png')]
for name,label in [('thief_m43','Ladrón aprobado'),('fast','Rápido'),('rammer_m43','Embestidor aprobado'),('colossus','Coloso'),('ratero','Ratero actual'),('cargador','Cargador actual')]:
    items.append((label,ROOT/'assets/sprites/enemies/rendered'/f'{name}.png'))
for size in [220,34]:
    width=244; height=size+52
    sheet=Image.new('RGB',(width*4,height*3),'#22262b'); d=ImageDraw.Draw(sheet)
    for i,(label,path) in enumerate(items):
        x=i%4*width;y=i//4*height
        bg=Image.open(ROOT/'assets/tiles/rendered/ground_pradera.png').convert('RGB').resize((width,height-26))
        sheet.paste(bg,(x,y+26))
        im=Image.open(path).convert('RGBA').resize((size,size),Image.Resampling.LANCZOS)
        sheet.paste(im,(x+(width-size)//2,y+30),im)
        d.text((x+6,y+5),label,font=FONT,fill='white')
    sheet.save(HERE/'review'/f'contact_{size}.png')

# Siluetas de altura visible 34 px: escala distinta de las hojas de lienzo 34.
sil=Image.new('RGB',(240*4,110*3),'#ddd6c4'); d=ImageDraw.Draw(sil)
for i,(label,path) in enumerate(items):
    im=Image.open(path).convert('RGBA');im=im.crop(im.getchannel('A').getbbox())
    im=im.resize((round(im.width*34/im.height),34),Image.Resampling.LANCZOS)
    ink=Image.new('RGBA',im.size,'#202330');ink.putalpha(im.getchannel('A'))
    x=i%4*240;y=i//4*110;sil.paste(ink,(x+90,y+45),ink);d.text((x+6,y+8),label,font=FONT,fill='black')
sil.save(HERE/'review/silhouettes_visible_34.png')
(HERE/'validation/art_check.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps({name:{'unique_frames':r['unique_frames'],'atlas_size':r['atlas_size']} for name,r in records.items()}))
