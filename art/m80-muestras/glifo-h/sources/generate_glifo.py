#!/usr/bin/env python3
"""T505: materiales originales con Python y Pillow; no usa NumPy ni servicios.

Ejecutar este archivo y después marcas/sources/generate_marcas.py.
Solo escribe en glifo-h. Importar no produce archivos ni cachés.
"""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import importlib.util
import hashlib
import json
import math
import random
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageFont
from glyphs import GLYPHS, NAMES, export_svg

OUT = Path(__file__).resolve().parents[1]
ROOT = OUT.parents[2]
S = 3
N = 128*S
LANCZOS = Image.Resampling.LANCZOS
SEED = 50526
spec = importlib.util.spec_from_file_location('rocks_source',ROOT/'art/m80-muestras/rocas/sources/generate_rocks.py')
ROCKS = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ROCKS)


def dump(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')


def font(size):
    return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',size)


def save(im, name, folder=OUT):
    im.save(folder/name, optimize=True)


def poly(im, pts, color):
    ImageDraw.Draw(im).polygon([(round(x*S),round(y*S)) for x,y in pts],fill=color)


def line(im, pts, color, width=1):
    ImageDraw.Draw(im).line([(round(x*S),round(y*S)) for x,y in pts],fill=color,width=max(1,round(width*S)))


def shadow(im, cx=65, cy=111, rx=35):
    layer=Image.new('RGBA',im.size)
    ImageDraw.Draw(layer).ellipse(((cx-rx)*S,(cy-4)*S,(cx+rx)*S,(cy+4)*S),fill=(29,26,23,60))
    im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(1.3*S)))


def cloth_light(u,v):
    a=.38*u+.09*v;b=.17*u-.13*v
    zx=.76*math.cos(a)+.17*math.cos(b)
    zy=.18*math.cos(a)-.13*math.cos(b)
    norm=math.sqrt(zx*zx+zy*zy+1)
    diffuse=max(0,(.55*zx+.7*zy+.65)/norm)
    return .40+.85*diffuse


def surface(im, pts, base, material='stone', seed=SEED, strength=1):
    """Plano con bisel direccional, grano multiescala y vetas de madera/tela."""
    rng=random.Random(seed)
    mask=Image.new('L',im.size);poly(mask,pts,255)
    layer=Image.new('RGBA',im.size);px=layer.load();mp=mask.load()
    noise=Image.new('L',(40,40));noise.putdata([rng.randrange(256) for _ in range(1600)])
    noise=noise.resize(im.size,Image.Resampling.BICUBIC).load()
    box=mask.getbbox()
    for y in range(box[1],box[3]):
        for x in range(box[0],box[2]):
            if not mp[x,y]: continue
            u,v=x/S,y/S
            grain=(noise[x,y]-128)*.075+rng.uniform(-3,3)
            if material=='wood':
                groove=math.sin(u*2.5+math.sin(v*.09)*1.2)
                grain+=groove*6+math.sin(u*7+v*.08)*2
            elif material=='cloth':
                grain+=3*math.sin(u*.48+v*.12)+2*math.sin(u*.16-v*.10)
                grain+=((x%3)-1)*.65+((y%3)-1)*.65
            grad=(60-u)*.16+(65-v)*.12
            # El bisel tiene ancho real: luz superior izquierda y oclusión opuesta.
            step=round(1.15*S)
            if not mp[max(0,x-step),max(0,y-step)]: grad+=15
            if not mp[min(N-1,x+step),min(N-1,y+step)]: grad-=13
            shade=cloth_light(u,v) if material=='cloth' else 1
            px[x,y]=tuple(max(0,min(255,int(c*shade+(grain+grad)*strength))) for c in base)+(255,)
    im.alpha_composite(layer)
    # Bisel discontinuo; la arista orientada hacia arriba recibe luz.
    for i,(x,y) in enumerate(pts):
        nx,ny=pts[(i+1)%len(pts)]
        dx,dy=nx-x,ny-y
        bright=(dy-dx)>0
        c=tuple(min(255,int(v*(1.3 if bright else .62))) for v in base)+(230,)
        line(im,[(x,y),(nx,ny)],c,.65 if material=='cloth' else .9)


def glyph_mask(key, quad):
    """Interpolación bilineal en el plano inclinado: no pega texto frontal."""
    mask=Image.new('L',(N,N));d=ImageDraw.Draw(mask)
    def mapped(x,y):
        u=x/60;v=y/64
        a,b,c,e=quad
        return ((a[0]*(1-u)*(1-v)+b[0]*u*(1-v)+c[0]*u*v+e[0]*(1-u)*v)*S,
                (a[1]*(1-u)*(1-v)+b[1]*u*(1-v)+c[1]*u*v+e[1]*(1-u)*v)*S)
    for points in GLYPHS[key]: d.polygon([mapped(x,y) for x,y in points],fill=255)
    return mask


def offset(mask, x,y):
    out=Image.new('L',mask.size);out.paste(mask,(round(x*S),round(y*S)));return out


def pigment(im,key,quad,style='paint',seed=SEED):
    mask=glyph_mask(key,quad)
    rng=random.Random(seed)
    # Descascarado fino: conserva montantes y travesaño en miniatura.
    wear=Image.new('L',im.size,255);d=ImageDraw.Draw(wear)
    box=mask.getbbox()
    for _ in range(65 if style=='carve' else 65):
        x=rng.randrange(box[0],box[2]);y=rng.randrange(box[1],box[3]);r=rng.uniform(.12,.4)*S
        d.ellipse((x-r,y-r,x+r,y+r),fill=rng.choice([0,65,125]))
    mask=ImageChops.multiply(mask,wear)
    if style=='carve':
        # Labio exterior inferior derecho; interior alto izquierdo en sombra.
        lip=ImageChops.subtract(offset(mask,.75,.95),mask)
        im.paste((192,182,151,255),(0,0),lip)
        im.paste((40,40,34,255),(0,0),mask)
        inner=ImageChops.multiply(mask,offset(mask,1.1,1.25))
        im.paste((70,66,49,255),(0,0),inner)
    else:
        edge=ImageChops.subtract(offset(mask,.55,.7),mask)
        im.paste((48,43,27,255),(0,0),edge)
        layer=Image.new('RGBA',im.size);p=layer.load();m=mask.load()
        base=(202,180,117) if style=='cloth' else (102,73,33)
        for y in range(box[1],box[3]):
            for x in range(box[0],box[2]):
                if m[x,y]:
                    lum=math.sin(x/S*.48+y/S*.12)*9+rng.uniform(-6,6)
                    shade=.62+.38*cloth_light(x/S,y/S) if style=='cloth' else 1
                    p[x,y]=tuple(max(0,min(255,round(c*shade+lum))) for c in base)+(round(m[x,y]*.91),)
        im.alpha_composite(layer)
    return im


def finish(im):
    return im.resize((128,128),LANCZOS)


def engraved(key,model='a',color='caliza',snow=False):
    if snow:
        im=Image.open(ROOT/'art/m79-muestras/nieve/snow_rock_01.png').convert('RGBA').resize((N,N),LANCZOS)
        # Un plano desgastado en la roca trasera recibe el tallado. Conserva nieve,
        # silueta y piedras vecinas de snow_rock_01; no atraviesa los tres bloques.
        front=Image.new('RGBA',(N,N))
        surface(front,[(51,54),(77,51),(98,59),(100,79),(90,94),(53,91),(48,73)],(119,123,113),seed=50598)
        a=ImageChops.multiply(front.getchannel('A'),im.getchannel('A'))
        fp=front.load();ip=im.load();ap=a.load()
        for y in range(N):
            for x in range(N):
                if ap[x,y] and min(ip[x,y][:3])>151:ap[x,y]=0
        front.putalpha(a);im.alpha_composite(front)
        return finish(pigment(im,key,[(55,55),(94,58),(94,91),(52,88)],'carve'))
    # T504 permite ampliar la cara receptora usando su propia geometría.
    original=ROCKS.mesh
    def receiver(model,seed):
        vs,fs=original(model,seed)
        if model=='a':
            front=[(30,56),(77,53),(86,77),(78,103),(29,100),(23,78)]
            for i,(x,y) in enumerate(front): vs[11+i]=(x,y,53-.10*x-.26*y)
        return vs,fs
    ROCKS.mesh=receiver
    try:
        im=Image.new('RGBA',(N,N));shadow(im,64,108,42)
        im.alpha_composite(ROCKS.body(model,color,ROCKS.SEEDS[model]))
    finally: ROCKS.mesh=original
    quad=[(32,57),(76,55),(79,101),(30,98)] if model=='a' else [(40,56),(82,58),(82,94),(39,93)]
    return finish(pigment(im,key,quad,'carve'))


def ruin(key):
    im=Image.new('RGBA',(N,N));shadow(im,65,106,47)
    surface(im,[(17,75),(91,69),(109,85),(96,109),(23,107),(14,92)],(86,83,68))
    surface(im,[(18,51),(88,43),(106,65),(95,96),(22,95),(12,72)],(149,143,118))
    surface(im,[(22,95),(95,96),(96,108),(25,106)],(107,103,85))
    surface(im,[(95,96),(106,65),(109,85),(96,108)],(74,74,64))
    surface(im,[(18,51),(36,49),(31,53),(17,60),(12,72)],(171,162,131),seed=50594)
    surface(im,[(91,47),(106,65),(101,71),(97,59)],(129,123,101),seed=50595)
    line(im,[(50,47),(51,51),(48,54)],(79,78,64),.6)
    line(im,[(93,82),(99,78),(102,74)],(63,63,52),.7)
    rng=random.Random(50597)
    for _ in range(60):
        x=rng.uniform(25,93);y=rng.choice([rng.uniform(94,99),rng.uniform(104,106)])
        line(im,[(x,y),(x+rng.uniform(.4,1.6),y-.3)],rng.choice([(145,135,108),(70,70,57),(177,164,130)]),.4)
    # La inscripción recorre el techo inclinado de un sillar tumbado.
    pigment(im,key,[(28,53),(77,48),(91,92),(29,88)],'paint')
    line(im,[(19,57),(28,61),(26,68)],(68,65,53),.6)
    line(im,[(78,92),(70,97),(72,103)],(57,58,48),.9)
    moss(im,[(18,82),(30,100),(92,94)],50580)
    return finish(im)


def moss(im, centers,seed):
    rng=random.Random(seed);d=ImageDraw.Draw(im)
    for cx,cy in centers:
        for _ in range(90):
            x=cx+rng.gauss(0,3);y=cy+rng.gauss(0,1.4);r=rng.uniform(.15,.8)
            d.ellipse(((x-r)*S,(y-r*.6)*S,(x+r)*S,(y+r*.6)*S),fill=rng.choice([(76,82,32,255),(109,112,45,255),(138,135,60,255)]))


def timber(im,start,end,radius,seed=50577):
    """Tronco cilíndrico: normal transversal y veta longitudinal sinuosa."""
    rng=random.Random(seed);ax,ay=start;bx,by=end
    dx,dy=bx-ax,by-ay;length=math.hypot(dx,dy);ux,uy=dx/length,dy/length;nx,ny=-uy,ux
    left=[];right=[]
    for i in range(19):
        t=i/18;cx=ax+dx*t;cy=ay+dy*t
        r=radius*(1+.065*math.sin(i*2.3)+.03*math.cos(i*5.1))
        left.append((cx+nx*r,cy+ny*r));right.append((cx-nx*r,cy-ny*r))
    mask=Image.new('L',im.size);poly(mask,left+right[::-1],255);mp=mask.load()
    layer=Image.new('RGBA',im.size);px=layer.load();box=mask.getbbox()
    for y in range(box[1],box[3]):
        for x in range(box[0],box[2]):
            if not mp[x,y]:continue
            a=x/S-ax;b=y/S-ay;t=(a*ux+b*uy)/length
            v=max(-1,min(1,(a*nx+b*ny)/radius))
            nz=math.sqrt(max(0,1-v*v));light=.34+.67*nz+(-.55*nx-.7*ny)*v*.38
            grain=math.sin(v*21+math.sin(t*15)*.7)*5+math.sin(v*47+t*2)*2+rng.uniform(-2,2)
            scar=max(0,math.sin(v*35+math.sin(t*11))-.88)*45
            px[x,y]=tuple(max(0,min(255,int(c*light+grain-scar))) for c in (153,108,57))+(255,)
    im.alpha_composite(layer)
    line(im,left,(192,150,88),.55)
    # Corte de madera: pequeña cara superior, nunca una esfera lisa.
    cap=[(ax+nx*radius,ay+ny*radius),(ax+ux*2,ay+uy*2),(ax-nx*radius,ay-ny*radius),(ax-ux*1.4,ay-uy*1.4)]
    poly(im,cap,(187,146,82))
    line(im,[(ax+nx*radius*.45,ay+ny*radius*.45),(ax-nx*radius*.4,ay-ny*radius*.4)],(110,77,37),.6)


def stake(im, top=(54,17), bottom=(57,111),thin=False):
    x,y=top;bx,by=bottom;w=3 if thin else 4
    surface(im,[(x-w,y+2),(x+1,y-2),(x+w,y+1),(bx+w,by-4),(bx+7,by),(bx,by-1),(bx-7,by+2),(bx-w,by-7)],(106,73,37),'wood')
    timber(im,(x,y+1),(bx,by-5),w*.84)
    line(im,[(x-2,y+5),(bx-2,by-7)],(180,141,78),1)
    line(im,[(x+2,y+18),(bx+2,by-4)],(61,44,26),.9)
    line(im,[(bx-1,by-12),(bx-3,by-3),(bx-7,by+2)],(157,112,56),1.2)
    line(im,[(bx+2,by-9),(bx+3,by-3),(bx+6,by)],(67,46,25),1.1)
    for yy in [y+16,y+42,by-16]:
        line(im,[(x-2,yy),(x+2,yy+2),(x,yy+4)],(65,46,26),.7)


def rope(im, start,end,width=2):
    line(im,[start,end],(55,42,25),width+1)
    line(im,[(start[0]-.4,start[1]-.5),(end[0]-.4,end[1]-.5)],(163,134,82),width)
    dx,dy=end[0]-start[0],end[1]-start[1];length=math.hypot(dx,dy)
    for i in range(int(length/2.0)):
        t=i/max(1,int(length/2.0));x=start[0]+dx*t;y=start[1]+dy*t
        line(im,[(x-.7,y+.6),(x+.7,y-.6)],(207,174,111),.5)


def banner(key):
    im=Image.new('RGBA',(N,N));shadow(im,61,112,26)
    # Misma altura, travesaño descendente, madera y ataduras que la referencia.
    stake(im,(59,16),(58,111))
    surface(im,[(22,22),(26,19),(103,46),(105,51),(99,53),(23,27)],(128,88,44),'wood')
    timber(im,(24,23),(102,49),3.1,50578)
    # Un paño ancho de una sola pieza diferencia la marca de las dos banderas.
    cloth=[(31,29),(87,48),(89,92),(80,86),(77,96),(65,89),(59,93),(49,84),(44,88),(39,78),(35,80)]
    surface(im,cloth,(100,103,56),'cloth',50541)
    for x in [39,51,67,80]:
        line(im,[(x,34+(x-31)*.33),(x+1,54),(x+5,81)],(66,71,39,220),.75)
        line(im,[(x+1,36+(x-31)*.33),(x+3,59),(x+6,81)],(140,137,75,180),.6)
    pigment(im,key,[(42,40),(77,50),(80,87),(45,78)],'cloth')
    # Costura superior interrumpida y hebras sueltas: tela, no tabla.
    for x in range(35,84,3):
        yy=32+(x-31)*.34
        line(im,[(x,yy),(x+1,yy+.3)],(166,151,89),.4)
    for x,y in [(44,88),(59,93),(77,96),(86,90)]:
        line(im,[(x,y-2),(x+.5,y+2.0)],(110,113,63),.45)
    for x in [32,49,68,84]:
        y=25+(x-22)*.35
        rope(im,(x,y-1),(x+2,y+9),2)
    rope(im,(55,29),(64,36),2.5);rope(im,(57,27),(62,40),2)
    rope(im,(58,36),(64,49),1)
    return finish(im)


def tablet(key):
    im=Image.new('RGBA',(N,N));shadow(im,62,110,35)
    stake(im,(63,55),(59,111))
    surface(im,[(23,53),(83,35),(99,43),(99,88),(91,96),(71,100),(33,108),(24,99)],(66,45,28),'wood')
    surface(im,[(22,49),(36,46),(39,42),(81,34),(91,40),(88,53),(94,58),(89,85),(75,89),(71,94),(33,102),(29,91),(22,89),(26,72),(20,65)],(126,88,44),'wood')
    line(im,[(24,68),(93,55)],(64,43,25),1.1)
    line(im,[(25,69),(91,56)],(174,124,65),.65)
    pigment(im,key,[(36,45),(77,39),(80,87),(37,94)],'carve')
    for x,y in [(28,52),(86,46),(31,89)]:
        ImageDraw.Draw(im).ellipse(((x-1)*S,(y-1)*S,(x+1)*S,(y+1)*S),fill=(49,41,30))
        line(im,[(x-1,y-1),(x,y-1)],(191,157,99),.6)
    line(im,[(87,80),(81,83),(84,90)],(54,38,26),.8)
    line(im,[(30,94),(34,88),(33,80)],(59,39,23),.8)
    line(im,[(88,53),(81,54),(77,60)],(60,41,25),.8)
    line(im,[(26,50),(36,48),(41,44)],(191,143,80),.7)
    line(im,[(74,94),(80,90),(87,89)],(173,124,66),.7)
    rope(im,(60,94),(70,92),1.8)
    return finish(im)


def cairn(key,snow=False):
    im=Image.new('RGBA',(N,N));shadow(im,65,111,43)
    # Cinco piedras T504: dos bases, apoyo, roca frontal y coronación.
    for i,tr in enumerate([(39,101,.43,.27),(83,101,.40,.27),(83,77,.37,.35)]):
        im.alpha_composite(ROCKS.body('b','caliza' if i%2 else 'arenisca',50417,tr))
    main=engraved(key,color='caliza').resize((round(N*.89),round(N*.89)),LANCZOS)
    im.alpha_composite(main,(round(7*S),round(4*S)))
    im.alpha_composite(ROCKS.body('b','arenisca',50417,(64,30,.30,.23)))
    if snow:
        surface(im,[(34,47),(43,42),(61,43),(73,49),(58,51),(45,50)],(222,232,233))
    return finish(im)


def ribbon(key):
    im=Image.new('RGBA',(N,N));shadow(im,61,111,23)
    stake(im,(47,19),(50,110),True)
    # Cinta ancha y larga, sin travesaño: el borde libre ondula hacia la derecha.
    pts=[(48,29),(68,26),(89,35),(91,58),(84,78),(94,100),(80,96),(64,105),(49,85),(47,65),(56,47),(50,43)]
    surface(im,pts,(105,107,59),'cloth',50593)
    line(im,[(66,29),(71,45),(67,68),(68,86),(73,96)],(152,145,83),1.2)
    line(im,[(80,38),(79,56),(74,76),(80,96)],(65,73,40),1.4)
    pigment(im,key,[(54,39),(87,44),(82,88),(50,83)],'cloth')
    for x,y in [(64,104),(81,98),(92,100)]:
        line(im,[(x,y-2),(x+.3,y+1.5)],(111,115,61),.4)
    rope(im,(45,29),(56,34),2.6)
    rope(im,(48,31),(43,43),1.3)
    return finish(im)


BUILDERS={'banderin':banner,'tablilla':tablet,'hito':cairn,'cinta':ribbon}


def sheet(assets,rows,prefix,folder,size):
    cw=350;ch=280 if size==220 else 215
    im=Image.new('RGBA',(3*cw,72+len(rows)*ch),'#282e2b');d=ImageDraw.Draw(im)
    d.text((18,12),f'T505 · {prefix} · {size} px · propuestas sin integrar',font=font(23),fill='white')
    d.text((18,44),'Tres contornos estables; desgaste y proyección según el soporte.',font=font(17),fill='#e0dcc6')
    for j,(kind,biome,label) in enumerate(rows):
        for i,key in enumerate(GLYPHS):
            x=i*cw;y=72+j*ch
            tile=Image.open(ROOT/f'assets/tiles/rendered/ground_{biome}.png').convert('RGBA').resize((cw,ch),LANCZOS)
            im.alpha_composite(tile,(x,y))
            d.rectangle((x,y,x+cw,y+29),fill='#292f2a')
            d.text((x+8,y+5),f'{key} · {label}',font=font(17),fill='white')
            sprite=assets[(kind,key)]
            side=220 if size==220 else 34
            small=ROCKS.map_filter(sprite,side) if size==34 else sprite.resize((side,side),LANCZOS)
            im.alpha_composite(small,(x+13,y+45 if size==220 else y+75))
            if size==34: im.alpha_composite(small.resize((136,136),Image.Resampling.NEAREST),(x+90,y+40))
            if prefix=='marcas':
                post=Image.open(ROOT/'assets/sprites/map/rendered/banner_post_enemy.png').convert('RGBA')
                post=post.resize((side,side),LANCZOS)
                im.alpha_composite(post,(x+(234 if side==220 else 282),y+45 if side==220 else y+75)) if side==34 else None
                # La referencia grande se incluye en una fila propia para evitar recortarla.
            if size==34: d.text((x+13,y+185),'34 px · ampliación x4 a la derecha',font=font(14),fill='white',stroke_width=1,stroke_fill='#242a24')
    save(im,f'{prefix}_hoja_{size:03}.png',folder)


def review(assets,folder):
    items=list(assets.items());w=3*420;h=math.ceil(len(items)/3)*425
    im=Image.new('RGBA',(w,h),'#c9c7b6');d=ImageDraw.Draw(im)
    for i,((kind,key),sprite) in enumerate(items):
        x=(i%3)*420;y=(i//3)*425
        im.alpha_composite(sprite.resize((384,384),Image.Resampling.NEAREST),(x+12,y+25))
        d.text((x+10,y+4),f'{key} · {kind} · x3',font=font(18),fill='#242921')
        im.alpha_composite(ROCKS.map_filter(sprite,34),(x+374,y+380))
    save(im,'revision_x3.png',folder)


def manifest(folder, assets):
    records=[]
    for path in sorted(folder.rglob('*')):
        if not path.is_file() or path.name in ['manifest.json','prompts.md','validation.json'] or '__pycache__' in path.parts: continue
        info={'archivo':str(path.relative_to(folder)),'tipo':'fuente' if path.suffix in ['.py','.svg'] else 'documentación' if path.suffix in ['.md','.json'] else 'hoja o composición','glifo':None,'semilla':SEED,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        if path.name in assets:
            kind,key=assets[path.name];info.update(tipo=kind,glifo=key)
            im=Image.open(path);a=im.getchannel('A');box=a.getbbox()
            assert im.mode=='RGBA' and im.size==(128,128),(path,im.mode,im.size)
            assert box and box[0]>0 and box[1]>0 and box[2]<128 and box[3]<128,(path,box)
            assert all(a.getpixel(p)==0 for p in [(0,0),(127,0),(0,127),(127,127)])
            info.update(tamaño=[128,128],bbox_alfa=list(box))
        records.append(info)
    dump(folder/'sources/manifest.json',records)
    dump(folder/'manifest.json',records)


def main():
    export_svg(OUT/'sources');assets={};files={}
    for kind,fn in [('grabada_roca',engraved),('relieve_ruina',ruin),('banderin',banner)]:
        for key in GLYPHS:
            im=fn(key);name=f'{key}_{kind}.png';save(im,name);assets[(kind,key)]=im;files[name]=(kind,key)
    rows=[('grabada_roca','pradera','grabado en caliza'),('relieve_ruina','ruinas','sillar caído'),('banderin','pradera','tela oliva')]
    for side in [220,34]:sheet(assets,rows,'glifo',OUT,side)
    review(assets,OUT)
    solo=Image.new('RGBA',(1050,360),'#e8e3cf');d=ImageDraw.Draw(solo)
    for i,key in enumerate(GLYPHS):
        d.text((i*350+15,12),f'{key} · {NAMES[key]}',font=font(18),fill='#22251b')
        m=glyph_mask(key,[(0,0),(127,0),(127,127),(0,127)]);black=Image.new('RGBA',(N,N));black.putalpha(m)
        solo.alpha_composite(black.resize((220,220),LANCZOS),(i*350+20,45))
        solo.alpha_composite(black.resize((34,34),LANCZOS),(i*350+265,130))
        d.text((i*350+20,286),'220 px                        34 px',font=font(17),fill='#25281d')
    save(solo,'glifo_solo.png')
    text='''# Ficha de glifos T505

G1: dos pilares con espolones, gancho izquierdo en el pilar derecho y barra quebrada.
G2: doble pilar izquierdo, cambios de grosor, lazo abierto y remates en rombo.
G3: alturas desiguales, travesaño saliente y muescas de fractura.
Ninguna variante recibe significado; los tres contornos son alternativas, no tres alfabetos.
La elección final debe repetir un único contorno en todos los soportes.

La cara A de T504 se amplía mediante su malla original para alojar un signo de
unos 44 × 46 px; el grabado se proyecta sobre ese plano inclinado. La roca no
se modifica en origen. El sillar cae a ras del suelo y muestra su techo: no es estela.
El banderín conserva escala, madera y soga de la referencia, con un solo paño oliva.
Las fuentes SVG son polígonos editables; ninguna fuente tipográfica dibuja el signo.
DejaVu se usa exclusivamente para los rótulos de las hojas.
'''
    (OUT/'ficha.md').write_text(text,encoding='utf-8')
    (OUT/'procedencia.md').write_text(PROVENANCE,encoding='utf-8')
    (OUT/'sources/procedencia.md').write_text(PROVENANCE,encoding='utf-8')
    (OUT/'revision.md').write_text(REVIEW,encoding='utf-8')
    manifest(OUT,files)
    print('Glifos: nueve piezas, SVG, hojas, siluetas y controles de alfa generados.')


PROVENANCE='''# Procedencia · T505

Codex; atribución solicitada: gpt-6.1-sol, esfuerzo medio; fecha 2026-10-26.
Python 3 + Pillow, sin NumPy, servicios de imágenes, imágenes generativas ni material ajeno.
Codex definió los tres signos con polígonos originales y programó todos los materiales,
proyecciones, desgaste, hojas y controles. No participaron otros agentes.
Las rocas derivan del generador procedural original T504 del repositorio, leído sin escribirlo.
Las referencias PNG del juego se observaron para escala, luz, material y perspectiva;
los suelos y las capturas se reutilizan como fondos del propio proyecto.
El método sigue generate_samples.py: supersampling x3 y reducción Lanczos a 128 px.
Las miniaturas usan la aproximación trilineal de T504; no certifican el filtro de GPU.
Semilla principal 50526; constantes locales en las fuentes para materiales y musgo.
El manifiesto registra SHA-256, tipo, glifo y semilla de cada archivo generado y fuente.
Reproducir: python3 art/m80-muestras/glifo-h/sources/generate_glifo.py
Después: python3 art/m80-muestras/marcas/sources/generate_marcas.py
Solo se escriben las dos carpetas autorizadas. prompts.md se conserva intacto.
La revisión visual y sus límites quedan en revision.md. Propuestas sujetas a Lucas.
'''

REVIEW = """# Revisión de las muestras T505

Se observaron rock_a, ambos postes, rubble_idle y statue_basic_moss antes de
producir arte. Se vieron las nueve piezas de glifos y doce marcas en hojas x3,
a 220 px y a 34 px sobre sus suelos reales. Se observaron también las seis
composiciones completas y los recortes por casilla. No es una aprobación de Lucas.

## Descartes y correcciones
- El pigmento ocre claro del sillar desaparecía: se oscureció y se agrandó el techo.
- La cinta inicial era angosta: se ensanchó el paño para conservar los dos pilares.
- El desgaste punteado regular parecía perforación: se redujeron cantidad y tamaño.
- La tablilla de cantos regulares parecía un cartel: ahora tiene espesor lateral,
  madera astillada, roturas y vetas. Sigue siendo deliberadamente una tablilla.
- El hito tenía un hueco entre cuerpo y base: las piedras ahora se apoyan entre sí.
- El tallado nevado cruzaba varias rocas: ahora ocupa una cara de la roca trasera,
  aclarada proceduralmente, conservando nieve, silueta y piedras de snow_rock_01.
- La madera plana se reemplazó por troncos con normales cilíndricas, grano y raíces.
- Se agregó luz por normales a los pliegues de tela y al pigmento que los sigue.

## Lectura y límites
G1 destaca por la barra quebrada; G2 por el montante doble y gancho abierto;
G3 por la diagonal saliente. A 34 px se conserva la estructura general de H,
pero el segundo trazo fino de G2 y las muescas se fusionan parcialmente. No
se promete reconocer cada detalle del contorno a ese tamaño. G3 es el más simple.
Las siluetas de cinta, tablilla e hito son distintas; el banderín se distingue del
poste enemigo por un paño único oliva y por su emblema claro. Ninguna elección
recibe un significado ni se introduce como canon.

La comparación a 220 px deja visible que las referencias de campaña son más
pictóricas y tienen más irregularidad orgánica. La producción procedural nueva
sigue siendo más geométrica; no certifico paridad artística con las referencias.
Los controles técnicos no sustituyen esa evaluación visual de Lucas.

No se corrió ni importó Godot, ni GUT, ni se integraron recursos. No se probó
el filtro real de GPU, animación, teléfono ni rendimiento. Los montajes parten
de capturas reales previas: no son capturas del motor con estos recursos cargados.
No se modificaron mapas, leyendas, postes, tablero, CHANGELOG ni canon. Se respetó
el alcance de dos carpetas y no se hizo git add, commit ni push.
"""

if __name__=='__main__': main()
