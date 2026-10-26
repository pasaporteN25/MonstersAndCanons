#!/usr/bin/env python3
"""T493: muestras editables y composiciones; solo escribe junto a este archivo.

Ejecutar desde cualquier carpeta: python3 art/m79-muestras/nieve/generate_samples.py
Requiere solamente Python 3 y Pillow. No importa recursos en Godot.
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops
import hashlib
import json
import math
import random
import re

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
SCALE = 3
SIZE = 128 * SCALE
LANCZOS = Image.Resampling.LANCZOS
GROUND_PATH = ROOT / 'assets/tiles/rendered/ground_nieve.png'
PATH_PATH = ROOT / 'assets/tiles/rendered/path.png'
BEFORE_PATH = ROOT / 'art/m79-inventario/antes-nivel-13-1280x720.png'
GROUND = Image.open(GROUND_PATH).convert('RGBA')
PATH = Image.open(PATH_PATH).convert('RGBA')
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'


def font(size, bold=False):
    return ImageFont.truetype(BOLD if bold else FONT, size)


def save(im, name):
    im.save(OUT / name, optimize=True)


def poly(im, points, color):
    ImageDraw.Draw(im).polygon([(int(x*SCALE), int(y*SCALE)) for x, y in points], fill=color)


def line(im, points, color, width=1):
    ImageDraw.Draw(im).line([(int(x*SCALE), int(y*SCALE)) for x, y in points], fill=color, width=max(1, int(width*SCALE)))


def shadow(im, cx, cy, rx, ry):
    layer = Image.new('RGBA', im.size)
    d = ImageDraw.Draw(layer)
    d.ellipse(((cx-rx)*SCALE, (cy-ry)*SCALE, (cx+rx)*SCALE, (cy+ry)*SCALE), fill=(35, 35, 43, 42))
    im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(1.6*SCALE)))
    d = ImageDraw.Draw(im)
    d.ellipse(((cx-rx*.46)*SCALE, (cy-ry*.45)*SCALE, (cx+rx*.46)*SCALE, (cy+ry*.45)*SCALE), fill=(37, 39, 43, 48))


def bough(im, cx, cy, rx, ry, seed, snow=.12, angle=0, stone=False):
    """Volumen local elipsoidal: normales, luz superior izquierda y material rugoso.

    El borde dentado y las pinceladas se generan de forma determinista. La nieve
    ocupa la superficie superior y deja un labio sombreado; no es un relleno plano.
    """
    rng = random.Random(seed)
    phase = rng.random()*6.28
    ca, sa = math.cos(angle), math.sin(angle)
    extent = int((rx+ry)*SCALE+3)
    x0, y0 = int(cx*SCALE), int(cy*SCALE)
    pixels = im.load()
    for y in range(max(0, y0-extent), min(SIZE, y0+extent)):
        for x in range(max(0, x0-extent), min(SIZE, x0+extent)):
            dx, dy = (x-x0)/SCALE, (y-y0)/SCALE
            u, v = (dx*ca+dy*sa)/rx, (-dx*sa+dy*ca)/ry
            theta = math.atan2(v, u)
            edge = 1 + .045*math.sin(theta*13+phase) + .025*math.cos(theta*23-phase)
            rr = (u*u+v*v)/(edge*edge)
            if rr > 1:
                continue
            nz = math.sqrt(max(0, 1-rr))
            diffuse = max(0, -.47*u-.58*v+.65*nz)
            grain = (rng.random()-.5)*7
            ridge = math.sin(u*31+v*14+phase)*2.3 + math.sin(v*40-u*17)*1.6
            threshold = snow-.12*u+.09*math.sin(u*9+phase)+.035*math.sin(u*23)
            if v < threshold and snow > -1:
                height = max(0, min(1, (threshold-v)/.65))
                lum = min(1, diffuse)
                base = (143+109*lum, 157+96*lum, 173+79*lum)
                if height < .14:
                    base = tuple(t-20*(1-height/.14) for t in base)
                rgb = tuple(int(max(0,min(255,t+grain*.65+ridge*.55))) for t in base)
            else:
                lum = .36+.64*diffuse
                base = (17+74*lum, 27+77*lum, 13+43*lum)
                if v-threshold < .18 and snow > -1:
                    base = tuple(t*.66 for t in base)
                rgb = tuple(int(max(0,min(255,t+grain+ridge))) for t in base)
            pixels[x,y] = (*rgb, 255)
    # Agujas agrupadas: sólo en el bajo de las ramas, sin ensuciar la nieve.
    for _ in range(int(rx*3)):
        u = rng.uniform(-.88,.88)
        v = rng.uniform(max(.3, snow+.24), .8)
        if u*u+v*v > .94:
            continue
        px, py = u*rx, v*ry
        x, y = cx+px*ca-py*sa, cy+px*sa+py*ca
        c = rng.choice([(85,99,55,255), (43,56,31,255), (106,114,64,255)])
        line(im, [(x,y),(x+u*1.8,y+1.6)], c, .35)


TREE_NAMES = {
    'pine': ['Copa abierta', 'Nieve asentada', 'Copa irregular'],
    'fir': ['Abeto compacto', 'Manto continuo', 'Ramas desparejas'],
}


def tree(kind, variant):
    rng = random.Random(500+variant+(0 if kind=='pine' else 100))
    im = Image.new('RGBA', (SIZE,SIZE))
    shadow(im, 66, 111, 29 if kind=='pine' else 35, 5)
    # Tronco y raíces: cálidos, sin pedestal ni emblema.
    poly(im, [(60,64),(68,64),(70,106),(78,112),(66,110),(56,113),(59,104)], '#4b3625')
    poly(im, [(60,68),(64,67),(64,106),(59,110),(61,101)], '#a2824b')
    poly(im, [(64,69),(66,67),(67,107),(72,109),(64,107)], '#755733')
    for x in [61,64,67]:
        line(im, [(x,77),(x-1,89),(x+1,102)], '#413323', .55)
    # El abeto conserva el carácter más bajo y ancho del dibujo vigente.
    if kind=='pine':
        tiers = [(91,31,12),(71,26,11),(53,19,10),(36,12,8),(22,6,6)]
    else:
        tiers = [(94,37,13),(76,31,11),(59,23,10),(43,16,9),(29,8,7)]
    for index, (y, radius, height) in enumerate(tiers):
        drift = (math.sin(index*1.6)*3 if variant==3 else 0)
        center = 64+drift
        # Tres ramas traseras y tres delanteras; las capas superiores ocluyen a las de abajo.
        for j, offset in enumerate([-.6,.55,-.87,.88,-.31,.3,0]):
            dx = offset*radius
            by = y+(-3 if j<2 else 0)+(4 if j>=4 else 0)
            rx = radius*(.49 if j<4 else .44)
            if abs(offset)>.8:
                rx = radius*.37
            ry = height*(.75 if j<2 else 1)
            snow = {1:-.27,2:.22,3:-.08}[variant]+rng.uniform(-.23,.15)
            if kind=='fir':
                snow += .05
            bough(im, center+dx*.72, by+rng.uniform(-3,3), max(3,rx), ry,
                  9000+index*71+j+variant*100+(500 if kind=='fir' else 0), snow, angle=offset*.22)
    # Aguja terminal, con un lateral en sombra que separa el blanco del suelo.
    tip = 9 if kind=='pine' else 14
    poly(im, [(62,tip+7),(64,tip),(67,tip+8),(66,tip+12),(61,tip+12)], '#5d6b45')
    poly(im, [(62,tip+7),(64,tip),(65,tip+7),(64,tip+10)], '#f5f5ef')
    return im.resize((128,128), LANCZOS)


def snow_patch(im, points, seed):
    """Nieve pintada sobre las caras superiores de una roca T277 existente."""
    rng = random.Random(seed)
    mask = Image.new('L', im.size)
    # Redondea las acumulaciones con dos pasadas de subdivisión, respetando las caras.
    for _ in range(2):
        smooth=[]
        for i,a in enumerate(points):
            b=points[(i+1)%len(points)]
            smooth.extend([(a[0]*.8+b[0]*.2,a[1]*.8+b[1]*.2),
                           (a[0]*.2+b[0]*.8,a[1]*.2+b[1]*.8)])
        points=smooth
    pts = [(int(x*SCALE),int(y*SCALE)) for x,y in points]
    ImageDraw.Draw(mask).polygon(pts, fill=255)
    # Oclusión bajo el labio de nieve, sin contorno de historieta.
    edge = Image.new('RGBA', im.size)
    edge.putalpha(ImageChops.subtract(ImageChops.offset(mask,0,2*SCALE),mask))
    dark = Image.new('RGBA', im.size, (47,48,55,0))
    dark.putalpha(edge.getchannel('A').point(lambda a:int(a*.5)))
    im.alpha_composite(dark)
    fill = Image.new('RGBA', im.size)
    pix, alpha = fill.load(), mask.load()
    relief=mask.filter(ImageFilter.GaussianBlur(2.8*SCALE)).load()
    miny,maxy = min(y for x,y in pts),max(y for x,y in pts)
    for y in range(miny,maxy+1):
        for x in range(min(x for x,y in pts),max(x for x,y in pts)+1):
            if not alpha[x,y]:
                continue
            t=(y-miny)/max(1,maxy-miny)
            dx=(relief[min(SIZE-1,x+SCALE),y]-relief[max(0,x-SCALE),y])/55
            dy=(relief[x,min(SIZE-1,y+SCALE)]-relief[x,max(0,y-SCALE)])/55
            lighting=max(-.7,min(.6,-dx*.48-dy*.65))
            shade = t*24 + x/SIZE*8 - lighting*35 + rng.uniform(-3,3)
            pix[x,y] = (int(min(255,250-shade)),int(min(255,251-shade*.9)),int(min(255,252-shade*.7)),255)
    im.alpha_composite(fill)


def rock(variant):
    # Derivación de los PNG dimensionales aprobados; conserva material y luz.
    source = 'rock_b.png' if variant==3 else 'rock_a.png'
    base = Image.open(ROOT/'assets/sprites/map/rendered'/source).convert('RGBA')
    # El conjunto cabe en la misma casilla, con margen transparente.
    im = Image.new('RGBA',(SIZE,SIZE))
    width,height = (100,96) if variant==1 else (107,101)
    if variant==3:
        width,height=101,92
    x,y=(128-width)//2, 113-height
    im.alpha_composite(base.resize((width*SCALE,height*SCALE),LANCZOS),(x*SCALE,y*SCALE))
    # Coordenadas de las manchas sobre el espacio original de la referencia.
    def transform(points):
        return [(x+px*width/128,y+py*height/128) for px,py in points]
    if variant!=3:
        patches = [
            [(43,40),(50,29),(67,22),(83,21),(96,33),(103,45),(96,42),(91,50),(81,43),(73,47),(66,40),(56,45)],
            [(13,78),(17,68),(29,58),(42,57),(54,63),(59,76),(51,73),(43,80),(35,74),(27,80),(20,77)],
            [(84,91),(89,83),(101,80),(112,86),(117,97),(108,95),(102,100),(94,94)],
        ]
        if variant==2:
            patches[0]=[(40,43),(50,29),(67,22),(83,21),(96,33),(106,49),(109,62),(101,60),(94,68),(83,57),(74,65),(66,55),(57,59),(51,49)]
            patches[1]=[(13,78),(17,68),(29,58),(42,57),(54,63),(61,83),(52,79),(45,88),(36,81),(29,86),(20,79)]
    else:
        patches = [
            [(22,57),(30,36),(48,23),(65,27),(77,42),(73,55),(62,49),(56,57),(45,50),(34,59)],
            [(65,75),(76,61),(92,55),(110,65),(116,80),(104,77),(97,85),(89,78),(79,84)],
        ]
    # Nieve recortada por el alfa de la piedra: nunca aparecen parches flotantes.
    original_alpha=im.getchannel('A')
    for n,patch in enumerate(patches):
        snow_patch(im,transform(patch),400+variant*10+n)
    im.putalpha(original_alpha)
    return im.resize((128,128),LANCZOS)


ENEMIES = [
    ('normal','Normal'),('fast','Rápido'),('tank','Tanque'),('armored','Blindado'),
    ('flyer','Volador'),('boss','Soberano'),('troll','Troll'),('spider','Araña'),
    ('spiderling','Cría'),('guardian','Guardián'),('healer','Curandero'),
    ('shaman','Chamán'),('mirror','Espejo'),('colossus','Coloso'),
    ('colossus_shard','Pedazo'),('ratero','Ratero'),('cargador','Cargador')]


def enemy_texture(enemy_id):
    # Resuelve la textura estática declarada por el recurso; no asume SVG ni atlas.
    resource = (ROOT/f'data/enemies/{enemy_id}.tres').read_text()
    match=re.search(r'texture = ExtResource\("([^"]+)"\)',resource)
    texture_id=match.group(1)
    for path, rid in re.findall(r'\[ext_resource[^\n]*path="([^"]+)"[^\n]*id="([^"]+)"',resource):
        if rid==texture_id:
            return Image.open(ROOT/path.replace('res://','')).convert('RGBA'),path
    raise ValueError(f'No se encontró la textura de {enemy_id}')


def panel(im, box, tile):
    x,y,w,h=box
    im.alpha_composite(tile.resize((w,h),LANCZOS),(x,y))


def heading(im,title,subtitle):
    d=ImageDraw.Draw(im)
    d.text((28,20), title,font=font(27,True),fill='#f1eddf')
    d.text((28,61),subtitle,font=font(15),fill='#b8c4c5')


def contact(assets,size):
    large=size==220
    width=1280
    cardw=398 if large else 398
    cardh=287 if large else 100
    deco_top=108
    enemy_top=deco_top+cardh*3+48
    enemy_cols=4 if large else 6
    enemy_w=300 if large else 200
    enemy_h=292 if large else 100
    rows=math.ceil(len(ENEMIES)/enemy_cols)
    height=enemy_top+rows*enemy_h+78
    im=Image.new('RGBA',(width,height),'#20272b')
    heading(im,f'T493 · Nieve · muestras a {size} px',
            'PROPUESTA SIN INTEGRAR · tamaño del lienzo completo · suelo y camino vigentes · luz arriba a la izquierda')
    d=ImageDraw.Draw(im)
    for row,(kind,label) in enumerate([('pine','Pino'),('fir','Abeto'),('snow_rock','Roca nevada')]):
        for col in range(3):
            x,y=28+col*408,deco_top+row*cardh
            panel(im,(x,y,cardw,cardh-12),GROUND)
            d.text((x+12,y+8),f'{label} · {col+1:02}',font=font(17,True),fill='#27313a')
            tilex=x+(cardw-size)//2
            tiley=y+36 if large else y+34
            im.alpha_composite(assets[f'{kind}_{col+1:02}'].resize((size,size),LANCZOS),(tilex,tiley))
            if not large:
                ImageDraw.Draw(im).rectangle((tilex-1,tiley-1,tilex+size,tiley+size),outline='#a5b4bd')
                d.text((x+12,y+71), '01–03: alternativas; ninguna aprobada',font=font(12),fill='#44505a')
    d.text((28,enemy_top-37),'Enemigos de la guía · sobre nieve; hoja de camino en archivo aparte' if large else 'Enemigos de la guía · izquierda/suelo y derecha/camino',font=font(19,True),fill='#f1eddf')
    for i,(enemy_id,label) in enumerate(ENEMIES):
        x=28+(i%enemy_cols)*(enemy_w+8)
        y=enemy_top+(i//enemy_cols)*enemy_h
        texture,_=enemy_texture(enemy_id)
        if large:
            # La vista sobre camino se guarda después en una hoja complementaria.
            panel(im,(x,y,enemy_w,enemy_h-12),GROUND)
            im.alpha_composite(texture.resize((size,size),LANCZOS),(x+(enemy_w-size)//2,y+35))
        else:
            panel(im,(x,y,enemy_w//2,enemy_h-12),GROUND)
            panel(im,(x+enemy_w//2,y,enemy_w//2,enemy_h-12),PATH)
            im.alpha_composite(texture.resize((size,size),LANCZOS),(x+33,y+34))
            im.alpha_composite(texture.resize((size,size),LANCZOS),(x+133,y+34))
        d.text((x+8,y+8),label,font=font(14,True),fill='#27313a')
    d.text((28,height-47),'Escala comparativa de texturas; no reproduce size_tiles, animación ni render del motor.',font=font(15),fill='#b8c4c5')
    if large:
        # La lámina principal usa suelo; una segunda ofrece los mismos 220 px sobre camino.
        save(im,'contact_220.png')
        heading_text='PROPUESTA SIN INTEGRAR · mismos 220 px completos · enemigos sobre el camino vigente'
        draw=ImageDraw.Draw(im)
        draw.rectangle((0,54,width,90),fill='#20272b')
        draw.text((28,61),heading_text,font=font(15),fill='#b8c4c5')
        for i,(enemy_id,label) in enumerate(ENEMIES):
            x=28+(i%enemy_cols)*(enemy_w+8)
            y=enemy_top+(i//enemy_cols)*enemy_h
            panel(im,(x,y,enemy_w,enemy_h-12),PATH)
            im.alpha_composite(enemy_texture(enemy_id)[0].resize((size,size),LANCZOS),(x+(enemy_w-size)//2,y+35))
            ImageDraw.Draw(im).text((x+8,y+8),label,font=font(14,True),fill='#171b20')
        save(im,'contact_220_path.png')
    else:
        save(im,'contact_034.png')


def references():
    im=Image.new('RGBA',(1280,440),'#20272b')
    heading(im,'T493 · Referencias vigentes, sin modificar','T277 · materiales, volumen y luz; T437/T475 · poste; M76/T471 · atlas y UI consultados en capturas')
    refs=['tree','rock_a','rock_b','forest_idle','statue_basic_frost','banner_post_enemy']
    for i,name in enumerate(refs):
        x=28+i*206
        panel(im,(x,115,194,250),GROUND)
        texture=Image.open(ROOT/f'assets/sprites/map/rendered/{name}.png').convert('RGBA')
        im.alpha_composite(texture.resize((184,184),LANCZOS),(x+5,145))
        ImageDraw.Draw(im).text((x+5,378),name,font=font(13),fill='#f1eddf')
    save(im,'reference_board.png')


def compose_map(assets,variant):
    before=Image.open(BEFORE_PATH).convert('RGBA')
    after=before.copy()
    level=json.loads((ROOT/'data/levels/level_13.json').read_text())
    posts=json.loads((ROOT/'data/ui/postes_campana.json').read_text())['niveles']['level_13']
    posted={tuple(p) for p in posts}
    manifest=[]
    # La captura T491 tiene origen (16,48) y casilla de 48 px. Los ids se
    # reconocen por color y ancho del SVG anterior; no se simula hash(Vector2i).
    for y,row in enumerate(level['mapa']):
        for x,char in enumerate(row):
            if char!='X' or (x,y) in posted:
                continue
            px,py=16+x*48,48+y*48
            tile=before.crop((px,py,px+48,py+48))
            green=[]
            for yy in range(48):
                for xx in range(48):
                    r,g,b,a=tile.getpixel((xx,yy))
                    if g>r*1.12 and g>b*1.05 and g<150:
                        green.append((xx,yy))
            if not green:
                kind='snow_rock'
            else:
                span=max(xx for xx,yy in green)-min(xx for xx,yy in green)
                kind='fir' if span>=32 else 'pine'
            after.alpha_composite(GROUND.resize((48,48),LANCZOS),(px,py))
            after.alpha_composite(assets[f'{kind}_{variant:02}'].resize((48,48),LANCZOS),(px,py))
            manifest.append({'cell':[x,y],'piece':kind,'variant':variant})
    # Rótulo explícito en la franja inferior; no se presenta como captura del motor.
    d=ImageDraw.Draw(after)
    d.rounded_rectangle((354,632,916,668),radius=5,fill='#20272b',outline='#c5a76b',width=1)
    d.text((366,641),f'PROPUESTA T493 · montaje, serie {variant:02} · sin motor',font=font(15,True),fill='#f4edda')
    save(after,f'level_13_proposal_{variant:02}.png')
    return manifest


def details(assets):
    im=Image.new('RGBA',(1280,590),'#20272b')
    heading(im,'T493 · Lectura junto a la Araña y la Cría','PROPUESTA · serie 01 · casillas de 64 px a la izquierda; texturas a 34 px a la derecha')
    spider=enemy_texture('spider')[0]
    child=enemy_texture('spiderling')[0]
    for i,(kind,label) in enumerate([('pine','Pino'),('fir','Abeto'),('snow_rock','Roca nevada')]):
        y=115+i*140
        for col,size in enumerate([64,34]):
            x=28+col*615
            panel(im,(x,y,594,123),GROUND)
            d=ImageDraw.Draw(im)
            d.text((x+12,y+8),f'{label} 01 · {size} px',font=font(16,True),fill='#27313a')
            for n,sprite in enumerate([assets[f'{kind}_01'],spider,child]):
                xx=x+75+n*160
                im.alpha_composite(sprite.resize((size,size),LANCZOS),(xx,y+43))
                d.text((xx,y+109),['Muestra','Araña','Cría'][n],font=font(11),fill='#3a434b')
    save(im,'spider_comparison.png')


def main():
    assets={}
    for kind in ['pine','fir','snow_rock']:
        for variant in range(1,4):
            key=f'{kind}_{variant:02}'
            im=rock(variant) if kind=='snow_rock' else tree(kind,variant)
            assert im.mode=='RGBA' and im.size==(128,128)
            assets[key]=im
            save(im,f'{key}.png')
    references()
    contact(assets,220)
    contact(assets,34)
    details(assets)
    maps={str(v):compose_map(assets,v) for v in range(1,4)}
    detail=Image.open(OUT/'contact_220.png')
    save(detail.crop((0,0,1280,970)),'decoration_detail.png')
    (OUT/'map_manifest.json').write_text(json.dumps(maps,indent=2,ensure_ascii=False)+'\n')
    inventory=[]
    for p in sorted(OUT.glob('*.png')):
        with Image.open(p) as im:
            inventory.append({'file':p.name,'bytes':p.stat().st_size,'size':list(im.size),'mode':im.mode,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    (OUT/'file_manifest.json').write_text(json.dumps(inventory,indent=2,ensure_ascii=False)+'\n')
    print('Se generaron 9 piezas RGBA, 3 hojas, referencias, comparativa y 3 montajes del nivel 13.')
    print('Casillas visibles reemplazadas por montaje:',len(maps['1']))
    print('Reparto reconocido:',{k:sum(p['piece']==k for p in maps['1']) for k in ['pine','fir','snow_rock']})


if __name__=='__main__':
    main()
