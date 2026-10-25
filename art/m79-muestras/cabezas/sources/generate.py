"""T494: propuestas originales, modeladas y rasterizadas con PIL, sin motor.

Ejecutar desde cualquier carpeta: python3 art/m79-muestras/cabezas/sources/generate.py
Las coordenadas de modelado usan un lienzo de 128; z apunta a la cámara.
Los elipsoides positivos forman hueso; los negativos excavan cavidades reales.
"""
from pathlib import Path
from math import sin, cos, sqrt, pi
import json
import random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE = Path(__file__).resolve().parents[1]
ROOT = BASE.parents[2]
SCALE = 2
SIZE = 128 * SCALE
NAMES = ['Dos pares de cuernos', 'Cuernos curvos y mandíbula abierta',
         'Una cuenca grande', 'Placas y mandíbulas', 'Ganado · línea de base']
FILES = ['01_four_horns', '02_open_jaw', '03_single_socket', '04_insect_mandibles', '05_cattle_baseline']
BONE = (239, 218, 178)
HORN = (177, 151, 109)
SAND = (211, 167, 98)

def shape(x,y,z,rx,ry,rz,angle=0,color=BONE,cut=False):
    return dict(x=x,y=y,z=z,rx=rx,ry=ry,rz=rz,angle=angle,color=color,cut=cut)

def horn(points, radius=7, color=HORN):
    result=[]
    # Curva de Bézier cúbica con diámetro decreciente, sin contorno vectorial.
    for i in range(38):
        t=i/37
        p=[sum(points[j][k]*[ (1-t)**3,3*(1-t)**2*t,3*(1-t)*t*t,t**3 ][j] for j in range(4)) for k in range(3)]
        r=radius*(1-t)**.8+.45
        result.append(shape(*p,r,r*.94,r*.85,color=color))
    return result

def model(index):
    a=[]
    def add(*args,**kw): a.append(shape(*args,**kw))
    if index==0:
        a+=horn([(42,61,7),(21,56,9),(13,36,8),(17,24,6)],7)
        a+=horn([(69,55,3),(83,46,5),(88,31,5),(81,22,3)],6)
        a+=horn([(41,50,14),(29,38,13),(32,25,10),(39,19,5)],5)
        a+=horn([(66,48,10),(67,34,12),(61,27,9),(58,20,6)],4)
        add(54,65,7,25,23,13,-12)
        add(75,78,10,24,13,10,21)
        add(53,55,17,19,9,5,-15)
        add(49,67,20,10,9,12,-12,cut=True)
        add(91,78,18,5,3,8,15,cut=True)
        add(68,88,19,11,3,8,-3,cut=True)
    elif index==1:
        a+=horn([(40,58,5),(7,57,8),(15,16,3),(41,27,4)],7)
        a+=horn([(64,54,0),(88,43,5),(80,19,1),(65,28,2)],6)
        add(51,60,6,24,21,12,-15)
        add(78,67,9,26,10,9,6)
        add(54,60,20,10,8,12,-8,cut=True)
        add(95,65,17,4,2.5,8,cut=True)
        # Mandíbula separada, baja y rota: el hueco sigue siendo transparente.
        add(51,85,5,9,17,6,-35)
        add(73,94,7,25,6,6,-4)
        for x,y in [(73,79),(86,79),(95,77)]:
            add(x,y,8,2.5,6,3,-12)
        for x in [70,81,91]: add(x,87,7,2.5,6,3,12)
    elif index==2:
        add(47,63,7,24,26,13,-23)
        add(75,79,6,28,12,10,22)
        add(93,84,10,10,7,6,23)
        add(48,61,19,14,15,15,-20,cut=True)
        add(67,48,16,4,13,9,-35,cut=True)
        add(96,82,15,4,2,6,20,cut=True)
        add(78,89,15,12,3,7,15,cut=True)
        # Cresta baja y hocico largo para evitar una cara humana.
        add(32,46,6,7,16,6,-26)
        add(57,83,11,13,7,6,35)
    elif index==3:
        # Cabeza alargada sin abdomen, patas, cúpula ni cuerno de rinoceronte.
        add(46,58,4,20,28,10,-33,color=(198,179,139))
        add(49,49,13,13,22,6,-33)
        add(62,66,9,16,18,8,-33)
        a+=horn([(63,75,10),(95,58,13),(113,72,7),(91,83,8)],7,BONE)
        a+=horn([(60,81,5),(74,112,8),(105,106,6),(98,91,8)],6,BONE)
        add(35,60,12,8,12,7,-35,cut=True)
        add(63,49,14,7,11,7,-35,cut=True)
        for x,y in [(31,53),(33,61),(38,67),(59,44),(63,50)]:
            add(x,y,10,2.4,3.1,3,color=(111,91,64))
        add(60,70,17,9,4,8,30,cut=True)
    else:
        a+=horn([(39,58,5),(18,51,8),(10,31,4),(14,25,3)],7)
        a+=horn([(66,54,0),(83,43,3),(89,28,3),(84,23,1)],6)
        add(49,61,6,23,21,12,-16)
        add(72,77,8,27,12,10,28)
        add(88,83,10,14,8,7,20)
        add(45,60,18,9,8,11,-20,cut=True)
        add(91,82,15,5,3,7,20,cut=True)
        add(74,88,15,10,2,7,15,cut=True)
        add(40,47,16,15,6,4,-20)
    # Fracturas de erosión: sin runas, letras ni símbolos.
    for x,y,angle in [(54,43,20),(77,74,-20)]:
        add(x,y,21,.65,6,4,angle,cut=True)
    return a

def render(index):
    shapes=model(index)
    (BASE/'sources'/f'{FILES[index]}.json').write_text(json.dumps(shapes,ensure_ascii=False,indent=2)+'\n')
    positives=[s for s in shapes if not s['cut']]
    negatives=[s for s in shapes if s['cut']]
    # Cada píxel conserva intervalos de intersección analíticos con el sólido.
    intervals=[[] for _ in range(SIZE*SIZE)]
    for s in positives+negatives:
        c=cos(s['angle']*pi/180); q=sin(s['angle']*pi/180)
        bound=max(s['rx'],s['ry'])
        for iy in range(max(0,int((s['y']-bound)*SCALE)),min(SIZE,int((s['y']+bound)*SCALE)+1)):
            dy=(iy+.5)/SCALE-s['y']
            for ix in range(max(0,int((s['x']-bound)*SCALE)),min(SIZE,int((s['x']+bound)*SCALE)+1)):
                dx=(ix+.5)/SCALE-s['x']; u=c*dx+q*dy; v=-q*dx+c*dy
                k=1-u*u/s['rx']**2-v*v/s['ry']**2
                if k>0:
                    dz=s['rz']*sqrt(k)
                    intervals[iy*SIZE+ix].append((s['z']-dz,s['z']+dz,s,u,v,c,q))
    pixels=[(0,0,0,0)]*(SIZE*SIZE)
    heights=[-100.]*(SIZE*SIZE)
    normals=[None]*(SIZE*SIZE)
    for i,entries in enumerate(intervals):
        pos=[e for e in entries if not e[2]['cut']]; neg=[e for e in entries if e[2]['cut']]
        best=None
        for e in pos:
            z=e[1]; edge=e; inverted=False
            for n in sorted(neg,key=lambda n:-n[1]):
                if n[0]<z<n[1]: z=n[0]; edge=n; inverted=True
            if z>e[0] and (best is None or z>best[0]): best=(z,edge,inverted)
        if best is None: continue
        z,e,inv=best; s=e[2]; u,v,c,q=e[3:]
        nx=c*u/s['rx']**2-q*v/s['ry']**2
        ny=q*u/s['rx']**2+c*v/s['ry']**2
        nz=(z-s['z'])/s['rz']**2
        if inv: nx=-nx; ny=-ny; nz=-nz
        length=sqrt(nx*nx+ny*ny+nz*nz); nx/=length; ny/=length; nz/=length
        lit=max(0,-.46*nx-.62*ny+.64*nz)
        x=(i%SIZE)/SCALE; y=(i//SIZE)/SCALE
        grain=(sin(x*17.3+y*31.1+z*9.2)+sin(x*4.7-y*7.3+z*3.1))*1.7
        weather=sin(x*.71+y*.37+z*.83)*4.1
        pores=sin(x*5.41+y*7.31+z*2.19)*sin(x*9.1-y*2.17)
        if pores>.82: weather-=13
        shade=.43+.61*lit
        if inv: shade*=.68
        col=s['color'] if not inv else BONE
        pixels[i]=tuple(max(0,min(255,int(ch*shade+grain+weather))) for ch in col)+(255,)
        heights[i]=z; normals[i]=(nx,ny,nz)
    # Sombra local y oclusión entre piezas con luz desde arriba a la izquierda.
    for i,p in enumerate(pixels):
        if not p[3]: continue
        x=i%SIZE; y=i//SIZE; h=heights[i]
        shade=1.
        for step in [3,7,13,22]:
            xx=x-int(step*.6); yy=y-int(step*.8)
            if xx>=0 and yy>=0 and heights[yy*SIZE+xx]>h+step*.52/SCALE:
                shade=.63; break
        pixels[i]=tuple(int(c*shade) for c in p[:3])+(255,)
    image=Image.new('RGBA',(SIZE,SIZE)); image.putdata(pixels)
    # Grietas cortas irregulares con labio iluminado. La máscara de altura
    # impide dibujarlas en el vacío de las cuencas o fuera del hueso.
    cracks=Image.new('RGBA',(SIZE,SIZE)); cd=ImageDraw.Draw(cracks)
    rng=random.Random(79+index)
    for x,y in [(38,43),(55,48),(33,70),(72,77),(86,83)]:
        pts=[(x*SCALE,y*SCALE)]
        for j in range(4):
            x+=rng.uniform(-1.6,2.3); y+=rng.uniform(1,2.1)
            pts.append((x*SCALE,y*SCALE))
        cd.line([(x-1,y-1) for x,y in pts],fill=(255,237,194,115),width=1)
        cd.line(pts,fill=(91,66,42,150),width=1)
    alpha=cracks.getchannel('A')
    alpha.putdata([v if heights[i]>17 else 0 for i,v in enumerate(alpha.tobytes())])
    cracks.putalpha(alpha); image.alpha_composite(cracks)
    shadow=Image.new('RGBA',(SIZE,SIZE)); d=ImageDraw.Draw(shadow)
    d.ellipse(tuple(int(v*SCALE) for v in (24,84,109,103)),fill=(65,43,24,55))
    shadow=shadow.filter(ImageFilter.GaussianBlur(3*SCALE)); shadow.alpha_composite(image)
    # Arena de apoyo: pequeñas lenguas y granos, no una peana.
    d=ImageDraw.Draw(shadow); rng=random.Random(494+index)
    buried=95 if index==1 else 88
    # Una lengua de arena cubre el borde inferior; no funciona como pedestal.
    pts=[(34,buried+2),(42,buried),(49,buried+2),(58,buried-1),
         (67,buried+1),(77,buried),(88,buried+2),(97,buried+4),
         (88,buried+8),(47,buried+7)]
    d.polygon([(x*SCALE,y*SCALE) for x,y in pts],fill=(218,174,106,240))
    for j in range(100):
        x=rng.uniform(29,101); y=rng.uniform(buried,buried+9)
        if ((x-66)/38)**2+((y-buried-4)/5)**2>1: continue
        r=rng.uniform(.3,1.2)
        col=rng.choice([(216,173,105,210),(232,191,122,190),(184,139,78,170)])
        d.ellipse(((x-r)*SCALE,(y-r*.4)*SCALE,(x+r)*SCALE,(y+r*.4)*SCALE),fill=col)
    shadow.save(BASE/'sources'/f'{FILES[index]}_work.png')
    final=shadow.resize((128,128),Image.Resampling.LANCZOS)
    final.save(BASE/'variants'/f'{FILES[index]}.png',optimize=True)
    return final

def font(size): return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',size)

def ground(w,h):
    tile=Image.open(ROOT/'assets/tiles/rendered/ground_desierto.png').convert('RGBA')
    out=Image.new('RGBA',(w,h))
    for y in range(0,h,tile.height):
        for x in range(0,w,tile.width): out.alpha_composite(tile,(x,y))
    return out

def board(variants,size):
    w=1460; h=470 if size==220 else 260
    out=Image.new('RGB',(w,h),(29,32,35)); d=ImageDraw.Draw(out)
    d.text((28,18),f'T494 · Cabezas del desierto · {size} px',font=font(25),fill=(245,222,174))
    d.text((28,55),'PROPUESTAS · Fauna sin nombre · Sin integrar · La elección queda para Lucas',font=font(15),fill=(198,200,197))
    screenshot=Image.open(ROOT/'art/m79-inventario/antes-nivel-10-1280x720.png')
    # Vecinos vigentes extraídos de la captura; se conserva su suelo original.
    cactus=screenshot.crop((12,413,64,465)); rock=screenshot.crop((12,466,64,518))
    entries=[cactus,rock]+variants
    labels=['Cactus vigente','Roca roja vigente']+[f'{i+1:02d} · '+['Cuatro cuernos','Mandíbula abierta','Cuenca única','Mandíbulas','Ganado'][i] for i in range(5)]
    width=198
    for i,im in enumerate(entries):
        x=30+i*203; y=105
        panel=ground(width,260 if size==220 else 85)
        if size==220:
            # Las celdas de 220 se organizan en una segunda hoja de ancho mayor.
            pass
        display=im.resize((size,size),Image.Resampling.LANCZOS)
        panel.alpha_composite(display,((width-size)//2,15 if size==220 else 22))
        out.paste(panel.convert('RGB'),(x,y))
        d.text((x,y+panel.height+12),labels[i],font=font(13),fill=(228,222,209))
    if size==220:
        # Hoja grande sin recortar el lienzo de 220 px de cada pieza.
        out=Image.new('RGB',(1800,440),(29,32,35)); d=ImageDraw.Draw(out)
        d.text((28,18),'T494 · Cabezas del desierto · 220 px',font=font(25),fill=(245,222,174))
        d.text((28,56),'PROPUESTAS · Vecinos vigentes como referencia · Luz arriba a la izquierda · Sin integrar',font=font(15),fill=(198,200,197))
        for i,im in enumerate(entries):
            x=25+i*253; panel=ground(235,260)
            panel.alpha_composite(im.resize((220,220),Image.Resampling.LANCZOS),(7,18))
            out.paste(panel.convert('RGB'),(x,100))
            d.text((x,375),labels[i],font=font(15),fill=(228,222,209))
    out.save(BASE/'sheets'/f'contact_{size}.png',optimize=True)

def compositions(variants):
    original=Image.open(ROOT/'art/m79-inventario/antes-nivel-10-1280x720.png').convert('RGBA')
    # Casillas verificadas visualmente contra la captura T491, origen (12,47).
    cells=[(2,0),(5,0),(8,0),(13,0),(16,0),(23,1),(2,2),(7,2),(17,2),(23,2),
           (2,4),(10,4),(16,4),(23,4),(1,5),(13,6),(15,6),(7,8),(11,8),(12,8),
           (1,9),(4,10),(11,10),(14,10),(19,10),(20,10)]
    clean=original.copy()
    # Un parche de suelo sin decoración tomado del mismo mapa. Solo se reemplaza
    # el interior de estas 26 casillas; camino, UI y poste quedan intactos.
    patch=original.crop((275,210,327,262))
    for x,y in cells:
        left=round(12+x*1256/24); top=round(47+y*576/11)
        right=round(12+(x+1)*1256/24); bottom=round(47+(y+1)*576/11)
        clean.paste(patch.resize((right-left,bottom-top)),(left,top))
    for i,variant in enumerate(variants):
        out=clean.copy()
        for x,y in cells:
            left=round(12+x*1256/24); top=round(47+y*576/11)
            right=round(12+(x+1)*1256/24); bottom=round(47+(y+1)*576/11)
            out.alpha_composite(variant.resize((right-left,bottom-top),Image.Resampling.LANCZOS),(left,top))
        # Rótulo en una franja agregada, fuera de la captura y de su UI.
        page=Image.new('RGB',(1280,766),(29,32,35)); page.paste(out.convert('RGB'),(0,46))
        ImageDraw.Draw(page).text((18,12),f'PROPUESTA {i+1:02d} · {NAMES[i]} · Nivel 10 · Montaje, sin motor',font=font(18),fill=(245,222,174))
        page.save(BASE/'compositions'/f'level10_{FILES[i]}.png',optimize=True)
    (BASE/'sources'/'replacement_cells.json').write_text(json.dumps(dict(origin=[12,47],map_size=[1256,576],grid=[24,11],cells=cells),indent=2)+'\n')

if __name__=='__main__':
    for folder in ['sources','variants','sheets','compositions']: (BASE/folder).mkdir(exist_ok=True)
    variants=[]
    for i in range(5):
        variants.append(render(i)); print(f'Variante {i+1:02d} generada.',flush=True)
    board(variants,220); board(variants,34); compositions(variants)
    print('Hojas y montajes generados. Sin integración.',flush=True)
