"""T261: fuentes vectoriales periódicas, rasterización y bancos comparativos."""
from pathlib import Path
import hashlib, json, math, random, shutil
import gi
gi.require_version('Rsvg', '2.0')
from gi.repository import Rsvg
from PIL import Image, ImageDraw, ImageStat
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
IDS = ['pradera', 'desierto', 'nieve', 'volcan', 'bosque', 'pantano', 'ruinas', 'path']
PATHS = [f'assets/tiles/rendered/{"path" if k == "path" else "ground_" + k}.png' for k in IDS] + ['assets/sprites/map/flores.svg']

def render(svg, dest, size):
    import re
    svg = re.sub(r'width="[0-9]+"', f'width="{size}"', svg, count=1)
    svg = re.sub(r'height="[0-9]+"', f'height="{size}"', svg, count=1)
    # Los originales históricos no declaran dimensiones.
    if 'width=' not in svg.split('>')[0]:
        svg = svg.replace('<svg ', f'<svg width="{size}" height="{size}" ', 1)
    handle = Rsvg.Handle.new_from_data(svg.encode())
    handle.get_pixbuf().savev(str(dest), 'png', [], [])

def color(rgb, shift=0):
    return '#%02x%02x%02x' % tuple(max(0, min(255, round(c + shift))) for c in rgb)

def svg_ground(k, index, rgb):
    rng = random.Random(261 + index)
    b, light, dark = color(rgb), color(rgb, 15), color(rgb, -17)
    elements = []
    def add(s): elements.append(s)
    # Manchas anchas de material; bordes blandos por poco contraste, sin blur.
    for i in range(14):
        x,y = rng.randrange(256),rng.randrange(256)
        rx,ry = rng.randrange(14,36),rng.randrange(7,18)
        add(f'<path d="M{x-rx} {y} Q{x-rx/2} {y-ry*1.4} {x+rx/3} {y-ry} Q{x+rx*1.3} {y-ry/2} {x+rx} {y+ry/2} Q{x} {y+ry*1.3} {x-rx} {y}Z" fill="{light if i%2 else dark}" opacity=".22"/>')
    for i in range(40 if k in ('pradera','bosque') else 25):
        x,y = rng.randrange(256),rng.randrange(256)
        if k in ('pradera','bosque'):
            # Brotes bajos con tres hojas, tallos asimétricos y un brillo.
            s=rng.uniform(.7,1.3)
            add(f'<g transform="translate({x} {y}) scale({s:.3f})"><path d="M-8 4 Q-4 -3 -5 -7 Q0 -3 1 3 Q3 -8 7 -10 Q5 -2 6 4 Q9 -2 13 -3 Q10 3 9 5Z" fill="{dark}" opacity=".57"/><path d="M-3 -4 Q0 0 1 3 M7 -6 L5 2" fill="none" stroke="{light}" stroke-width="1.7" stroke-linecap="round" opacity=".65"/></g>')
            if k=='bosque' and i%3==0:
                add(f'<path d="M{x+9} {y+7} Q{x+19} {y+1} {x+26} {y+8} Q{x+18} {y+16} {x+9} {y+7}Z" fill="#9a8450" opacity=".5"/><path d="M{x+11} {y+8} L{x+23} {y+8}" stroke="{dark}" stroke-width="1"/>')
        elif k=='desierto':
            add(f'<path d="M{x-16} {y+4} Q{x} {y-8} {x+22} {y-1}" fill="none" stroke="{dark}" stroke-width="3" opacity=".25" stroke-linecap="round"/><path d="M{x-15} {y+1} Q{x} {y-10} {x+21} {y-4}" fill="none" stroke="{light}" stroke-width="2" opacity=".7" stroke-linecap="round"/>')
        elif k=='nieve':
            add(f'<path d="M{x-13} {y+3} Q{x} {y-5} {x+16} {y+2} Q{x+6} {y+9} {x-13} {y+3}Z" fill="{dark}" opacity=".2"/><path d="M{x-12} {y+1} Q{x} {y-7} {x+13} {y-1}" fill="none" stroke="{light}" stroke-width="3" stroke-linecap="round"/>')
        elif k=='volcan':
            add(f'<path d="M{x-12} {y-9} L{x-3} {y-3} L{x+8} {y-6} L{x+14} {y+3} L{x+3} {y+10}" fill="none" stroke="{dark}" stroke-width="2.6" opacity=".85" stroke-linejoin="round"/><path d="M{x-11} {y-11} L{x-2} {y-5} L{x+8} {y-8}" fill="none" stroke="{light}" stroke-width="1" opacity=".5"/>')
        elif k=='pantano':
            add(f'<path d="M{x-12} {y} Q{x-6} {y-7} {x+11} {y-4} Q{x+24} {y} {x+12} {y+6} Q{x-4} {y+9} {x-12} {y}Z" fill="{dark}" opacity=".6"/><path d="M{x-6} {y-2} Q{x+2} {y-5} {x+12} {y-2}" fill="none" stroke="#92a394" opacity=".4" stroke-width="1.5" stroke-linecap="round"/>')
        elif k=='path':
            add(f'<path d="M{x-4} {y+2} L{x-3} {y-2} L{x+2} {y-3} L{x+5} {y+1} L{x+2} {y+4}Z" fill="url(#material)"/><path d="M{x-3} {y-2} L{x+1} {y-2}" stroke="{light}" stroke-width="1" stroke-linecap="round"/>')
    if k=='ruinas':
        # Dovelas alternadas: mismo periodo exacto en ambas direcciones.
        for row in range(8):
            for col in range(6):
                x=col*(256/6)+(256/12 if row%2 else 0);y=row*32
                add(f'<path d="M{x+3} {y+4} L{x+34} {y+2} L{x+40} {y+10} L{x+37} {y+28} L{x+8} {y+29} L{x+1} {y+23}Z" fill="{color(rgb,rng.randrange(-7,8))}" stroke="{dark}" stroke-width="1.3"/><path d="M{x+5} {y+5} L{x+33} {y+4}" fill="none" stroke="{light}" stroke-width="1.3" stroke-linecap="round"/>')
    # Granulado vectorial mínimo, subordinado al patrón principal.
    for i in range(75):
        x,y=rng.randrange(256),rng.randrange(256)
        add(f'<ellipse cx="{x}" cy="{y}" rx="{rng.uniform(.5,1.7):.2f}" ry=".7" fill="{light if i%2 else dark}" opacity=".28"/>')
    content=''.join(elements)
    # Muestras de todo el motivo trasladadas: lo que sale por un lado entra por el otro.
    repeats=''.join(f'<g transform="translate({dx} {dy})">{content}</g>' for dx in (-256,0,256) for dy in (-256,0,256))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
<!-- Suelo {k}: material vectorial periódico, reflejos discretos y paleta original. -->
<defs><linearGradient id="material" x2=".25" y2="1"><stop stop-color="{light}"/><stop offset=".5" stop-color="{b}"/><stop offset="1" stop-color="{dark}"/></linearGradient></defs><path d="M0 0H256V256H0Z" fill="{b}"/>{repeats}</svg>'''

def flowers():
    defs=[]
    for name,cs in [('leaf',['#86b86b','#4f9a48','#326438']),('pink',['#ffd2e4','#f4a3c4','#b86591']),('gold',['#fff3b5','#ffe27a','#c69947']),('violet',['#e4d8ff','#bfa8f2','#8771ba']),('white',['#ffffff','#edf0ef','#b9c7ca'])]:
        defs.append(f'<linearGradient id="{name}" x2=".25" y2="1">'+''.join(f'<stop offset="{offset}" stop-color="{c}"/>' for offset,c in zip(['0','.5','1'],cs))+'</linearGradient>')
    parts=['<ellipse cx="32" cy="53" rx="23" ry="3.4" fill="#2b2233" opacity=".12"/>']
    for x,y in [(13,50),(23,53),(36,51),(46,52),(31,55)]:
        parts.append(f'<path d="M{x} {y} Q{x-13} {y-2} {x-11} {y-10} Q{x-3} {y-11} {x} {y} Q{x+1} {y-13} {x+11} {y-11} Q{x+14} {y-4} {x} {y}Z" fill="url(#leaf)" stroke="#2b2233" stroke-width=".7"/><path d="M{x-8} {y-7} L{x-2} {y-2}" stroke="#b4d994" stroke-width=".8" stroke-linecap="round"/>')
    for x,y,r,name in [(14,32,5,'pink'),(29,26,6,'gold'),(40,36,5,'violet'),(51,40,4.8,'white'),(24,44,4.4,'pink')]:
        parts.append(f'<path d="M{x-1} 51 Q{x+2} 41 {x} {y}" fill="none" stroke="#326438" stroke-width="1.8" stroke-linecap="round"/>')
        parts.append(f'<g transform="translate({x} {y})" fill="url(#{name})" stroke="#2b2233" stroke-width=".65" stroke-linejoin="round">')
        for angle in range(0,360,72):
            parts.append(f'<path transform="rotate({angle})" d="M0 1 C{-r} {-r*.2} {-r*.55} {-r*1.2} 0 {-r} C{r*.65} {-r*1.2} {r} {-r*.2} 0 1Z"/>')
        parts.append(f'<circle r="1.9" fill="#c38b36"/><circle cx="-.5" cy="-.6" r=".9" fill="#fff0ab" stroke="none"/></g>')
    return '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">\n<!-- Flores de pradera: pétalos abiertos, centros cálidos y follaje bajo; fondo transparente. -->\n<defs>'+''.join(defs)+'</defs>'+''.join(parts)+'</svg>\n'

def main():
    for rel in PATHS:
        old=OUT/'sources/before'/rel
        if not old.exists(): old.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,old)
    for index,k in enumerate(IDS):
        old=Image.open(OUT/'sources/before'/PATHS[index]).convert('RGB')
        rgb=ImageStat.Stat(old).mean
        source=OUT/'sources/after'/f'{k}.svg';source.write_text(svg_ground(k,index,rgb))
        render(source.read_text(),ROOT/PATHS[index],256)
        # Igualdad exacta de las muestras límite; evita diferencias de rasterización subpíxel.
        im=Image.open(ROOT/PATHS[index]).convert('RGBA')
        for n in range(256):
            a,b=im.getpixel((0,n)),im.getpixel((255,n));c=tuple(round((a[j]+b[j])/2) for j in range(4));im.putpixel((0,n),c);im.putpixel((255,n),c)
            a,b=im.getpixel((n,0)),im.getpixel((n,255));c=tuple(round((a[j]+b[j])/2) for j in range(4));im.putpixel((n,0),c);im.putpixel((n,255),c)
        corner=im.getpixel((0,0))
        for p in [(0,255),(255,0),(255,255)]: im.putpixel(p,corner)
        im.save(ROOT/PATHS[index])
    (ROOT/PATHS[-1]).write_text(flowers())
    shutil.copyfile(ROOT/PATHS[-1],OUT/'sources/after/flowers.svg')
    manifest=[]
    for rel in PATHS:
        old=OUT/'sources/before'/rel;new=ROOT/rel
        manifest.append({'archivo':rel,'sha256_antes':hashlib.sha256(old.read_bytes()).hexdigest(),'sha256_despues':hashlib.sha256(new.read_bytes()).hexdigest()})
    (OUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    for phase in ['before','after']:
        for size in [220,34]:
            cellw=max(size+20,180);cellh=size+48
            sheet=Image.new('RGB',(cellw*3,cellh*3+35),'#222630');draw=ImageDraw.Draw(sheet)
            draw.text((12,10),f'T261 · {"ANTES" if phase=="before" else "DESPUÉS"} · {size} px · PROVISIONAL',fill='white')
            for i,rel in enumerate(PATHS):
                src=OUT/'sources/before'/rel if phase=='before' else ROOT/rel
                if src.suffix=='.svg':
                    render(src.read_text(),OUT/f'{phase}/flowers.png',256);im=Image.open(OUT/f'{phase}/flowers.png')
                else: im=Image.open(src)
                x=i%3*cellw+(cellw-size)//2;y=i//3*cellh+35
                if i==8:draw.rectangle((x,y,x+size-1,y+size-1),fill=color(ImageStat.Stat(Image.open(OUT/'sources/before'/PATHS[0]).convert('RGB')).mean))
                small=im.resize((size,size),Image.Resampling.LANCZOS);sheet.paste(small,(x,y),small if i==8 else None)
                draw.text((i%3*cellw+10,y+size+7),IDS[i] if i<8 else 'flores',fill='white')
            sheet.save(OUT/f'{phase}/contact_{size}.png')
        tile=64;w=3*tile+16;h=3*tile+40
        mosaics=Image.new('RGB',(w*4,h*2),'#222630');draw=ImageDraw.Draw(mosaics)
        for i,rel in enumerate(PATHS[:8]):
            im=Image.open(OUT/'sources/before'/rel if phase=='before' else ROOT/rel).resize((tile,tile),Image.Resampling.LANCZOS)
            for row in range(3):
                for col in range(3): mosaics.paste(im,(i%4*w+8+col*tile,i//4*h+8+row*tile))
            draw.text((i%4*w+8,i//4*h+3*tile+15),IDS[i],fill='white')
        mosaics.save(OUT/f'{phase}/seam_mosaic.png')
    (OUT/'comparison.html').write_text('''<!doctype html><html lang="es"><meta charset="utf-8"><title>T261 · Revisión provisional</title><style>body{background:#222630;color:#eee;font:16px sans-serif;margin:24px}section{display:flex;gap:20px}img{max-width:47vw}a{color:#bedaff}</style><h1>T261 · Suelos y flores</h1><p>Arte provisional: falta la aprobación de Lucas. Bancos de muestras; no son capturas de partida.</p>'''+''.join(f'<h2>{label}</h2><section><a href="before/{name}.png"><img src="before/{name}.png" alt="Antes"></a><a href="after/{name}.png"><img src="after/{name}.png" alt="Después"></a></section>' for name,label in [('contact_220','Antes / después · 220 px'),('contact_34','Antes / después · 34 px'),('seam_mosaic','Repetición 3×3 · 64 px')])+'</html>')
if __name__=='__main__': main()
