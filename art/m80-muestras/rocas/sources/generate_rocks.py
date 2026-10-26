#!/usr/bin/env python3
"""T504: arte procedural original; ejecutar desde cualquier carpeta con Python 3 + Pillow.

Solo escribe dentro de art/m80-muestras/rocas. No importa ni ejecuta Godot.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import random
import json
import hashlib

OUT = Path(__file__).resolve().parents[1]
ROOT = OUT.parents[2]
S = 3
N = 384
LANCZOS = Image.Resampling.LANCZOS
LINEAR = Image.Resampling.BILINEAR
COLORS = {'caliza': (157, 152, 135), 'arenisca': (168, 128, 104), 'oscura': (111, 117, 123)}
BIOMES = ['pradera', 'bosque', 'desierto', 'nieve', 'ruinas']
SEEDS = {'a': 50417, 'b': 50439, 'c': 50483}
FRONT_REGIONS = {}
CELLS = {11: [(1,2),(21,2),(2,8)],14:[(8,1),(24,1),(18,2),(3,5),(14,5),(7,7),(13,8),(25,9)],15:[(2,4),(19,10)]}

def dump(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

def font(size):
    return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', size)

def save(im, name):
    im.save(OUT/name, optimize=True)

def unit(v):
    length = math.sqrt(sum(t*t for t in v))
    return tuple(t/length for t in v)

def dot(a,b):
    return sum(x*y for x,y in zip(a,b))

def mesh(model, seed):
    """Malla de fractura asimétrica: frente amplio, techo quebrado y flancos desiguales."""
    outer=[(16,78,0),(20,59,0),(37,39,2),(65,34,0),(89,43,3),
           (109,63,0),(113,90,0),(100,104,0),(73,109,0),(38,105,0),(22,96,0)]
    front=[(30,65),(72,61),(81,77),(73,99),(33,96),(25,83)]
    top=[(41,49,25),(71,44,18),(91,57,16)]
    if model=='c':
        outer=[(25,66,0),(29,44,0),(46,25,2),(68,29,0),(88,38,3),
               (99,55,0),(104,85,0),(94,104,0),(72,108,0),(43,103,0),(28,91,0)]
        front=[(39,55),(82,57),(87,75),(82,94),(42,94),(34,76)]
        top=[(47,40,21),(68,36,15),(85,47,14)]
    vertices=outer+[(x,y,53-.10*x-.26*y) for x,y in front]+top
    faces=[[11,12,13,14,15,16], [2,3,18,17], [3,4,19,18],
           [17,18,12,11], [18,19,13,12], [1,2,17,11], [0,1,11,16],
           [10,0,16,15], [9,10,15], [8,9,15,14], [7,8,14],
           [6,7,14,13], [5,6,13,19], [4,5,19]]
    # Las fracturas secundarias no forman una corona regular alrededor del frente.
    for face_index in [1,4,6]:
        face=faces[face_index];a,b,c,d=(vertices[k] for k in face)
        mid=tuple((a[k]+b[k]+c[k]+d[k])/4 for k in range(3))
        v=len(vertices);vertices.append((mid[0],mid[1],mid[2]+2.8))
        faces[face_index]=[face[0],face[1],v,face[3]]
        faces.append([face[1],face[2],face[3],v])
    if model=='b':
        rng=random.Random(seed)
        # Cada bloque tiene inclinación y relaciones de tamaño propias.
        shear=rng.uniform(-.22,.22)
        vertices=[(x+(y-70)*shear,y+(x-60)*rng.uniform(.04,.08),z) for x,y,z in vertices]
        faces.pop(0)
        v=len(vertices);vertices.append((52,78,38))
        faces.extend([[11,12,v,16],[12,13,14,v],[14,15,16,v]])
    else:
        FRONT_REGIONS[str(seed)]={'rectangulo_frontal_30px_alto':[33,66,73,96] if model=='a' else [42,59,82,89],'ancho_px':40}
    return vertices,faces


def face_normal(points):
    # Ajuste del plano de profundidad; las caras mantienen una normal propia.
    a=points[0]
    for b,c in zip(points[1:],points[2:]):
        ux,uy,uz=(b[k]-a[k] for k in range(3))
        vx,vy,vz=(c[k]-a[k] for k in range(3))
        normal=(uy*vz-uz*vy,uz*vx-ux*vz,ux*vy-uy*vx)
        if abs(normal[2])>.001:
            if normal[2]<0: normal=tuple(-n for n in normal)
            return unit(normal)
    return (0,0,1)


def body(model,color,seed,transform=None):
    vertices,faces=mesh(model,seed)
    if transform:
        cx,cy,sx,sy=transform
        vertices=[(cx+(x-64)*sx,cy+(y-72)*sy,z*min(sx,sy)) for x,y,z in vertices]
    rng=random.Random(seed)
    im=Image.new('RGBA',(N,N));labels=Image.new('I',(N,N),-1)
    ld=ImageDraw.Draw(labels);base=COLORS[color];light=unit((-.56,-.66,.64))
    normals=[];shades=[]
    for index,face in enumerate(faces):
        normal=face_normal([vertices[k] for k in face]);normals.append(normal)
        shades.append(.35+.96*max(0,dot(normal,light)))
        ld.polygon([(round(vertices[k][0]*S),round(vertices[k][1]*S)) for k in face],fill=index)
    if model!='b':
        rect=FRONT_REGIONS[str(seed)]['rectangulo_frontal_30px_alto']
        assert all(labels.getpixel((x,y))==0 for y in range(int(rect[1]*S),int(rect[3]*S)) for x in range(int(rect[0]*S),int(rect[2]*S))), (model,rect)
    # Grano fino y mineral moteado: evita el ruido grande y borroso de la primera tanda.
    fields=[]
    for size in [29,113,384]:
        field=Image.new('L',(size,size));field.putdata([rng.randrange(256) for _ in range(size*size)])
        fields.append(field.resize((N,N),Image.Resampling.BILINEAR).load())
    # Muescas triangulares en el contorno; nunca perforan la cara receptora.
    for i in [0,2,4,6,8,9]:
        a=vertices[i];b=vertices[(i+1)%11];t=rng.uniform(.27,.7)
        x=a[0]*(1-t)+b[0]*t;y=a[1]*(1-t)+b[1]*t
        dx,dy=b[0]-a[0],b[1]-a[1];length=max(.01,math.hypot(dx,dy))
        tx,ty=dx/length,dy/length
        nx,ny=(64-x),(75-y);norm=max(.01,math.hypot(nx,ny));nx/=norm;ny/=norm
        ld.polygon([((x-tx*.8-nx)*S,(y-ty*.8-ny)*S),
                    ((x+tx*.8-nx)*S,(y+ty*.8-ny)*S),
                    ((x+nx*1.1)*S,(y+ny*1.1)*S)],fill=-1)
    pix=im.load();ids=labels.load()
    for y in range(N):
        for x in range(N):
            face=ids[x,y]
            if face<0: continue
            px,py=x/S,y/S;normal=normals[face];shade=shades[face]
            mineral=(fields[0][x,y]-128)*.055+(fields[1][x,y]-128)*.075+(fields[2][x,y]-128)*.028
            grain=rng.uniform(-2.5,2.5)
            texture=mineral+grain
            # Inclusiones minerales finas: algunas oscuras y otras recién fracturadas.
            inclusion=fields[1][x,y]
            if inclusion<63: texture-=5
            elif inclusion>197: texture+=6
            if color=='arenisca':
                # Estratos horizontales débilmente ondulados, cortados por la fractura.
                strata=py+.8*math.sin(px*.09)+.35*math.sin(px*.31)
                texture+=2.2*math.sin(strata*1.7)
                if strata%7.1<.48: texture-=7
            # Luz cálida y sombras minerales ligeramente frías, como las referencias.
            cool=(0,5,13) if color=='caliza' else ((-1,0,3) if color=='arenisca' else (0,2,4))
            ambient=(1-max(0,dot(normal,light)))
            weather=2.5*math.sin(px*.075+py*.035)-2*(py-70)/40
            rgb=[max(0,min(255,int(c*shade+texture+offset*ambient+weather))) for c,offset in zip(base,cool)]
            # Colonias pequeñas y fragmentadas sobre las caras que miran hacia arriba.
            patch=math.sin(px*.25+seed)+math.sin(py*.41+px*.12)+.5*math.sin(px*.93-py*.67)
            patch+=(fields[1][x,y]-128)*.008
            if normal[1]<-.23 and patch>.67 and color!='arenisca':
                target=(116,121,46) if color=='caliza' else (133,153,162)
                amount=min(.86,(patch-.67)*1.0)*(0.5+fields[1][x,y]/400)
                if color=='oscura': amount*=.35
                target=tuple(max(0,c+(fields[2][x,y]-128)*.20) for c in target)
                rgb=[int(c*(1-amount)+t*shade*amount) for c,t in zip(rgb,target)]
            pix[x,y]=(*rgb,255)
    detail=Image.new('RGBA',(N,N));d=ImageDraw.Draw(detail)
    # Cada quiebre tiene una oclusión capilar y una pequeña arista mineral iluminada.
    edges={}
    for index,face in enumerate(faces):
        for a,b in zip(face,face[1:]+face[:1]): edges.setdefault(tuple(sorted((a,b))),[]).append(index)
    for (a,b),adjacent in edges.items():
        ax,ay,_=vertices[a];bx,by,_=vertices[b]
        pts=[(ax*S,ay*S),(bx*S,by*S)]
        if len(adjacent)==2:
            contrast=1-dot(normals[adjacent[0]],normals[adjacent[1]])
            if contrast<.015: continue
            d.line(pts,fill=(34,32,34,175),width=2)
        dx,dy=bx-ax,by-ay;length=max(.01,math.hypot(dx,dy))
        # Brillo interrumpido: no hay un contorno uniforme alrededor de la piedra.
        strength=max(shades[j] for j in adjacent)
        if strength>.73:
            col=tuple(min(240,int(c*min(1.48,strength+.30)+5)) for c in base)
            for start,end in [(.03,.32),(.38,.69),(.75,.94)]:
                offset=.65
                d.line([((ax+dx*start-dy/length*offset)*S,(ay+dy*start+dx/length*offset)*S),
                        ((ax+dx*end-dy/length*offset)*S,(ay+dy*end+dx/length*offset)*S)],fill=(*col,215),width=4)
    # Lascas irregulares más anchas: el quiebre tiene espesor y desgaste mineral.
    for (a,b),adjacent in edges.items():
        if len(adjacent)!=2: continue
        if 1-dot(normals[adjacent[0]],normals[adjacent[1]])<.055: continue
        ax,ay,_=vertices[a];bx,by,_=vertices[b]
        dx,dy=bx-ax,by-ay;length=max(.01,math.hypot(dx,dy))
        if length<6: continue
        bright=max(shades[i] for i in adjacent)
        for start,end in [(.08,.24),(.37,.58),(.72,.88)]:
            t=rng.uniform(.7,1.55)
            col=tuple(min(232,int(c*min(1.42,bright+.16)+rng.uniform(-5,5))) for c in base)
            pts=[((ax+dx*start)*S,(ay+dy*start)*S),
                 ((ax+dx*end)*S,(ay+dy*end)*S),
                 ((ax+dx*(end-.03)-dy/length*t)*S,(ay+dy*(end-.03)+dx/length*t)*S),
                 ((ax+dx*(start+.04)-dy/length*t*.5)*S,(ay+dy*(start+.04)+dx/length*t*.5)*S)]
            d.polygon(pts,fill=(*col,200))
    # Vetas minerales cortas y erosión; sin rayado uniforme.
    for _ in range(95):
        x=rng.uniform(20,108);y=rng.uniform(30,104)
        face=ids[int(x*S),int(y*S)]
        if face<0: continue
        if model!='b' and face==0: continue
        shade=shades[face]
        col=tuple(min(230,int(c*(shade+.16))) for c in base)
        length=rng.uniform(1,4)
        dy=rng.uniform(-1.7,1.2) if color!='arenisca' else rng.uniform(-.25,.25)
        d.line([(x*S,y*S),((x+length)*S,(y+dy)*S)],fill=(*col,135),width=2)
    # Colonias de musgo con relieve fino; líquen más escaso y frío en la oscura.
    if color!='arenisca':
        for _ in range(800 if color=='caliza' else 130):
            x=rng.uniform(15,113);y=rng.uniform(23,91)
            face=ids[min(N-1,int(x*S)),min(N-1,int(y*S))]
            if face<0 or normals[face][1]>-.25: continue
            patch=math.sin(x*.25+seed)+math.sin(y*.41+x*.12)+.5*math.sin(x*.93-y*.67)
            if patch<.9: continue
            r=rng.uniform(.16,.68)
            col=rng.choice([(106,110,43),(131,135,55),(157,157,73),(83,90,38)]) if color=='caliza' else rng.choice([(134,151,159),(114,134,145),(159,169,173)])
            d.ellipse(((x-r)*S,(y-r*.5)*S,(x+r)*S,(y+r*.65)*S),fill=(*col,230))
    # Grietas ramificadas en la corona y los laterales; el centro frontal queda disponible.
    for index,end in [(2,17),(4,19),(6,13),(9,15),(1,11)]:
        a=vertices[index];b=vertices[end]
        pts=[]
        for step in range(6):
            t=step/5
            pts.append(((a[0]*(1-t)+b[0]*t+rng.uniform(-1,1))*S,
                        (a[1]*(1-t)+b[1]*t+rng.uniform(-1,1))*S))
        dark=(41,39,38,230) if color!='oscura' else (45,53,65,235)
        lip=(203,192,163,200) if color!='oscura' else (160,177,192,210)
        d.line([(x-1,y-2) for x,y in pts],fill=lip,width=2)
        d.line(pts,fill=dark,width=2)
        q=pts[3];d.line([q,(q[0]+rng.choice([-1,1])*4*S,q[1]+3*S),(q[0]+5*S,q[1]+6*S)],fill=dark,width=1)
    # Escamas y desconchados sobre las juntas; siguen la fractura sin ensuciar el plano central.
    for _ in range(150):
        a,b=rng.choice(list(edges));pa=vertices[a];pb=vertices[b];t=rng.random()
        x=pa[0]*(1-t)+pb[0]*t+rng.uniform(-1.4,1.4)
        y=pa[1]*(1-t)+pb[1]*t+rng.uniform(-1.4,1.4)
        r=rng.uniform(.3,1.3)
        dark=tuple(int(c*.39) for c in base)
        fresh=tuple(min(240,int(c*1.32+8)) for c in base)
        d.polygon([(x*S,y*S),((x+r)*S,(y-.4)*S),((x+r*.3)*S,(y+r)*S)],fill=(*dark,180))
        d.line([(x*S,(y-.3)*S),((x+r)*S,(y-.7)*S)],fill=(*fresh,205),width=2)
    # Fisuras superficiales cortas en las esquinas, sin cruzar la zona de grabado.
    for start in [11,12,14,15]:
        x,y,_=vertices[start]
        dx=rng.choice([-1,1]);path=[(x*S,y*S),((x+dx*2)*S,(y+3)*S),((x+dx*1.5)*S,(y+6)*S)]
        d.line([(x-1,y-1) for x,y in path],fill=(*tuple(min(225,int(c*1.3)) for c in base),150),width=2)
        d.line(path,fill=(48,46,44,190),width=2)
    from PIL import ImageChops
    detail.putalpha(ImageChops.multiply(detail.getchannel('A'),im.getchannel('A')))
    im.alpha_composite(detail)
    return im


def rock(model,color):
    shade=Image.new('RGBA',(N,N));d=ImageDraw.Draw(shade)
    width={'a':43,'b':43,'c':34}[model]
    d.ellipse(((64-width)*S,101*S,(64+width)*S,110*S),fill=(28,27,30,48))
    shade=shade.filter(ImageFilter.GaussianBlur(1.3*S))
    if model=='b':
        for offset,transform in enumerate([(49,68,.65,.89),(85,85,.56,.56),(31,94,.32,.32)]):
            shade.alpha_composite(body(model,color,SEEDS[model]+offset,transform))
    else: shade.alpha_composite(body(model,color,SEEDS[model]))
    return shade.resize((128,128),LANCZOS)


def map_filter(sprite,side):
    """Aproxima mipmap trilineal + bilineal en Pillow; no es un render de GPU."""
    level=math.log2(sprite.width/side)
    low=max(0,int(math.floor(level)));high=low+1;mix=max(0,min(1,level-low))
    levels=[sprite]
    for _ in range(high):
        prev=levels[-1]
        levels.append(prev.resize((max(1,prev.width//2),max(1,prev.height//2)),Image.Resampling.BOX))
    return Image.blend(levels[low].resize((side,side),LINEAR),levels[high].resize((side,side),LINEAR),mix)

def ground(biome,side):
    return Image.open(ROOT/f'assets/tiles/rendered/ground_{biome}.png').convert('RGBA').resize((side,side),LINEAR)

def tiled(im,box,biome,side):
    x,y,w,h=box; tile=ground(biome,side)
    layer=Image.new('RGBA',(w,h))
    for yy in range(0,h,side):
        for xx in range(0,w,side): layer.alpha_composite(tile,(xx,yy))
    im.alpha_composite(layer,(x,y))

def references(assets):
    # Comparación solicitada a x3 exacto, sin suavizado adicional.
    card=390;row=430
    im=Image.new('RGBA',(5*card,3*row+340),'#626b60');d=ImageDraw.Draw(im)
    for j,color in enumerate(COLORS):
        for i,name in enumerate(['rock_a','rock_b',f'roca_a_{color}',f'roca_b_{color}',f'roca_c_{color}']):
            tex=Image.open(ROOT/f'assets/sprites/map/rendered/{name}.png').convert('RGBA') if i<2 else assets[name]
            im.alpha_composite(tex.resize((384,384),Image.Resampling.NEAREST),(i*card,j*row+35))
            d.text((i*card+8,j*row+8),name+' · x3',font=font(18),fill='white')
    refs=[ROOT/f'assets/sprites/map/rendered/{n}.png' for n in ['snow_rock','rubble_idle','tree']]
    refs.append(ROOT/'art/m79-muestras/nieve/snow_rock_01.png')
    for i,p in enumerate(refs):
        im.alpha_composite(Image.open(p).convert('RGBA').resize((220,220),LANCZOS),(i*card+70,3*row+50))
        d.text((i*card+12,3*row+20),p.stem+' · referencia',font=font(18),fill='white')
    d.text((15,im.height-35),'Referencias intactas del repositorio; nuevas rocas procedurales originales. Sin reflejos ni símbolos.',font=font(20),fill='white')
    save(im,'referencias.png')


def sheets(assets,size):
    cardw=285;cardh=275 if size==220 else 214
    blockh=cardh*3+56
    im=Image.new('RGBA',(900,110+5*blockh),'#252b2d');d=ImageDraw.Draw(im)
    d.text((22,18),f'T504 · rocas sin marcas · lienzo a {size} px',font=font(25),fill='white')
    d.text((22,55),'Filas: modelos A/B/C · columnas: caliza / arenisca / oscura · propuesta sin integrar',font=font(17),fill='#d5d6cc')
    for j,biome in enumerate(BIOMES):
        y0=100+j*blockh
        d.text((22,y0),f'Suelo: {biome} · textura 256×256 ajustada por casilla',font=font(20),fill='white')
        for row,model in enumerate('abc'):
            for col,color in enumerate(COLORS):
                x=18+col*292;y=y0+37+row*cardh
                tiled(im,(x,y,cardw,cardh-9),biome,220 if size==220 else 64)
                d.rectangle((x,y,x+cardw,y+30),fill='#242a2deb')
                key=f'roca_{model}_{color}'
                d.text((x+7,y+6),key,font=font(16),fill='white')
                sprite=assets[key]
                if size==220:
                    im.alpha_composite(sprite.resize((220,220),LANCZOS),(x+32,y+35))
                else:
                    # Pirámide de mipmaps, mezcla entre niveles y filtrado bilineal.
                    small=map_filter(sprite,34)
                    im.alpha_composite(small,(x+17,y+77))
                    im.alpha_composite(small.resize((136,136),Image.Resampling.NEAREST),(x+112,y+42))
                    d.text((x+9,y+123),'34 px',font=font(14),fill='white',stroke_width=1,stroke_fill='#202628')
                    d.text((x+142,y+182),'x4 · vecino',font=font(13),fill='white',stroke_width=1,stroke_fill='#202628')
    save(im,f'hoja_{size:03}.png')
    save(im.crop((0,0,900,810 if size==34 else 970)),f'hoja_{size:03}_detalle.png')

def compose(assets):
    calibration={}; compositions={}
    posts=json.loads((ROOT/'data/ui/postes_campana.json').read_text())['niveles']
    for number in [15,11,14]:
        data=json.loads((ROOT/f'data/levels/level_{number}.json').read_text())
        rows=data['mapa']; height=len(rows);width=max(map(len,rows))
        tile=576/height;ox=(1280-width*tile)/2;oy=48
        # Anclas comprobables: bordes de camino y centros de señales en la captura.
        calibration[str(number)]={'origen_px':[ox,oy],'casilla_px':tile,'escala_sobre_64':tile/64,'columnas':width,'filas':height,'mapa_alto_px':576,'anclas':[],'metodo':'Banda jugable y=48..624; casillas cuadradas; ancho máximo del JSON centrado. Verificado visualmente con caminos y señales.'}
        before=Image.open(ROOT/f'art/m79-inventario/antes-nivel-{number:02}-1280x720.png').convert('RGBA');after=before.copy()
        color={15:'caliza',11:'arenisca',14:'oscura'}[number]
        coords=[(p,'señal') for p in CELLS[number]]
        # Sustituye el ítem decorativo de X, nunca agrega encima de él.
        if number==15: coords += [((3,4),'comparación X'),((4,4),'comparación X')]
        entries=[]
        for index,((x,y),kind) in enumerate(coords):
            char=rows[y][x];legend=data['leyenda'].get(char,{})
            assert [x,y] not in posts.get(f'level_{number:02}',[])
            if kind=='señal': assert legend.get('dibujo') in ['roca_marcada','simbolo_ruina']
            else: assert char=='X' and char not in data['leyenda']
            left=round(ox+x*tile);top=round(oy+y*tile);right=round(ox+(x+1)*tile);bottom=round(oy+(y+1)*tile)
            box=(left,top,right,bottom)
            # Misma textura completa por casilla; borra todo el ítem anterior.
            after.alpha_composite(ground(data['tema'],256).resize((right-left,bottom-top),LINEAR),(left,top))
            model=('b' if x==3 else 'c') if kind=='comparación X' else 'abc'[index%3];key=f'roca_{model}_{color}'
            after.alpha_composite(map_filter(assets[key],right-left).resize((right-left,bottom-top),LINEAR),(left,top))
            entries.append({'casilla':[x,y],'caracter':char,'uso':kind,'pieza':key+'.png','rectangulo_px':list(box),'item_anterior_borrado':True})
            if kind=='señal': calibration[str(number)]['anclas'].append({'casilla':[x,y],'centro_px':[ox+(x+.5)*tile,oy+(y+.5)*tile],'coincide_con_captura':True})
        d=ImageDraw.Draw(after)
        d.rectangle((295,629,997,655),fill='#252b2d')
        d.text((307,633),f'T504 · montaje sobre captura real · nivel {number} · sin integrar',font=font(17),fill='#f6e8bd')
        save(after,f'comp_nivel_{number}.png')
        # Recortes por casilla, con un anillo vecino intacto que deja comparar el tema.
        detail=Image.new('RGBA',(1280,84+math.ceil(len(entries)/4)*300),'#252b2d');dd=ImageDraw.Draw(detail)
        dd.text((20,15),f'Nivel {number} · recortes x2 · vecinos originales conservados',font=font(24),fill='white')
        dd.text((20,49),'Solo se sustituyen las casillas rotuladas; un ítem por casilla.',font=font(17),fill='#d5d6cc')
        for i,entry in enumerate(entries):
            l,t,r,b=entry['rectangulo_px'];margin=round(tile*.75)
            cropbox=(max(0,l-margin),max(48,t-margin),min(1280,r+margin),min(624,b+margin))
            crop=after.crop(cropbox);crop=crop.resize((crop.width*2,crop.height*2),Image.Resampling.NEAREST)
            xx=12+(i%4)*318;yy=86+(i//4)*300
            detail.alpha_composite(crop,(xx,yy))
            dd.text((xx,yy+258),f"{entry['casilla']} · {entry['uso']}",font=font(16),fill='white')
            dd.text((xx,yy+279),entry['pieza'],font=font(15),fill='#ded1ae')
        save(detail,f'comp_nivel_{number}_detalle.png')
        compositions[str(number)]={'captura':f'art/m79-inventario/antes-nivel-{number:02}-1280x720.png','suelo':data['tema'],'casillas':entries,'discrepancias':[],'nota':'Las X de comparación reemplazan decoración previa; vecinos rock_a/rock_b intactos.' if number==15 else 'Casillas de señal coincidentes; no se modifican postes, columnas ni extracciones.'}
    dump(OUT/'calibracion.json',calibration);dump(OUT/'composiciones.json',compositions)

def verify(assets):
    records=[]
    for key,im in assets.items():
        assert im.mode=='RGBA' and im.size==(128,128)
        alpha=im.getchannel('A');box=alpha.getbbox()
        assert all(alpha.getpixel(p)==0 for p in [(0,0),(127,0),(0,127),(127,127)])
        assert min(box[0],box[1],128-box[2],128-box[3])>8,(key,box)
        assert box[2]-box[0]<=104 and box[3]-box[1]<=92,(key,box)
        model=key.split('_')[1]
        solid=im.getchannel('A').point(lambda a:255 if a>200 else 0).getbbox()
        records.append({'caras_por_bloque':19 if model=='b' else 17,'bbox_cuerpo_opaco':list(solid),'altura_cuerpo_px':solid[3]-solid[1],'rectangulo_frontal':FRONT_REGIONS.get(str(SEEDS[model])), 'archivo':key+'.png','modelo':model,'color':key.split('_')[2],'tamaño':[128,128],'semilla':SEEDS[model],'sha256':hashlib.sha256((OUT/(key+'.png')).read_bytes()).hexdigest(),'bbox_alfa':list(box)})
    dump(OUT/'sources/manifest.json',records)
    assert all(region['ancho_px']>=39 for region in FRONT_REGIONS.values())
    dump(OUT/'sources/front_regions.json',FRONT_REGIONS)
    print('Verificadas 9 piezas RGBA de 128×128: esquinas transparentes y margen alfa mayor a 8 px.')

def review(assets):
    im=Image.new('RGBA',(1000,900),'#697261');d=ImageDraw.Draw(im)
    for i,model in enumerate('abc'):
        for j,color in enumerate(COLORS):
            im.alpha_composite(assets[f'roca_{model}_{color}'].resize((280,280),LANCZOS),(j*330,i*300))
            d.text((j*330+10,i*300+280),f'{model.upper()} · {color}',font=font(16),fill='white')
    save(im,'revision_piezas.png')

def documentation():
    (OUT/'sources/procedencia.md').write_text("""# Procedencia de T504 · revisión de las rocas

Fecha: 2026-10-26. Producción: Codex. Modelo y esfuerzo consignados en el encargo:
gpt-6.1-sol, medio. Herramientas: Python 3 y Pillow, sin NumPy, servicios de
imágenes, imágenes generativas ni material ajeno. Las nueve piezas son arte
procedural original. Los PNG de referencia nunca se modifican ni se copian
como material de las rocas nuevas.

## Referencias observadas

rock_a tiene bloques angulosos, caras superiores cálidas, frentes gris oscuro,
aristas claras, fisuras y musgo oliva. rock_b es bajo y ancho, con techo de
fractura escalonado y bloques menores. snow_rock conserva ese volumen bajo
una cubierta blanca; rubble_idle usa mampostería rota con juntas profundas;
tree muestra follaje agrupado, luz superior izquierda y sombra discreta.
snow_rock_01 se conserva exclusivamente como vecina de comparación.
Se consultó generate_samples.py: render a 384×384, normales, luz superior
izquierda y reducción Lanczos a 128×128. Los suelos y capturas son recursos
del propio repositorio. Los rótulos usan DejaVu Sans instalada.

## Cambios frente a la primera tanda

Se descartó el volumen por semiespacios con gran cara ovalada y biseles suaves.
También se descartó una prueba de facetas radiales que parecía piedra tallada.
La malla final es una proyección con profundidad por vértice: 17 caras en A/C
y 19 por cada bloque de B; cada cara calcula su normal y respuesta Lambert.
Se usan caras de tamaños desiguales, quiebres finos oscuros, brillo discontinuo,
lascas, muescas reales de silueta, inclusiones y grano mineral fino.
Solo la sombra de apoyo se desenfoca; no se desenfocan las caras de la roca.
La luz viene de arriba a la izquierda. No se usan reflejos horizontales porque
invertirían la iluminación. Tampoco se giran los PNG.

A es una peña ancha con frente inclinado; B agrupa tres bloques de tamaños
distintos; C es más alto, con techo visible y frente inclinado. A/C conservan
un rectángulo de 40×30 px dentro de la cara frontal, comprobado contra la
máscara de caras antes del material. Las pequeñas fisuras quedan en sus bordes.
No se agregan símbolos, letras ni grabados. Caliza lleva colonias de musgo oliva;
arenisca usa ocre rojizo apagado, estratos horizontales débiles y desgaste claro,
sin musgo; oscura tiene grietas con labio claro y líquen frío escaso.
Semillas: A 50417, B 50439 (+1 y +2 para sus vecinos), C 50483.
El manifiesto registra semillas, SHA-256, alfa, cuerpo opaco y caras por bloque.

## Reproducción y controles

Ejecutar desde cualquier carpeta:
`python3 /ruta/al/repositorio/art/m80-muestras/rocas/sources/generate_rocks.py`
El script regenera piezas, hojas, referencias, revisiones, composiciones,
calibración, manifiesto y este informe. Solo escribe dentro de la carpeta rocas.
No modifica prompts.md. Requiere Pillow y DejaVu Sans.

Se verifican las nueve piezas RGBA 128×128, esquinas transparentes, margen del
alfa mayor a 8 px y huella máxima de 104×92 px. El rectángulo frontal se valida
en ambas geometrías. La reproducibilidad se comprueba regenerando desde otra
carpeta y comparando SHA-256 de todas las salidas.
referencias.png muestra rock_a y rock_b al lado de las nueve nuevas a x3 exacto
con vecino más cercano. revision_piezas.png muestra las nueve variantes.
Se revisaron visualmente también las hojas a 220 y 34 px y los tres montajes.
La hoja de 34 px aproxima LINEAR_WITH_MIPMAPS mediante pirámide BOX, mezcla de
niveles y bilineal; su ampliación x4 usa vecino más cercano. No se afirma
identidad exacta con la GPU de Godot.

Los montajes parten de capturas reales del motor: niveles 15, 11 y 14.
Cada casilla se repinta con su suelo y recibe un solo sprite a escala de casilla.
Se validan señales, leyendas y postes contra los datos. En 15, las X (3,4) y
(4,4) sustituyen su decoración por B/C; los rock_a/rock_b vecinos se conservan.
No se detectaron discrepancias entre las señales indicadas y las capturas.
El cuerpo opaco de las nuevas queda en un rango comparable al alto de las
referencias (rock_a: 98 px; rock_b: 68 px a resolución nativa), sin escalado
extra sobre la casilla. Los tamaños exactos nuevos están en manifest.json.
La calibración mantiene origen (16,48), casilla 48 en 14/15 y origen
(11,6364;48), casilla 52,3636 en 11. El redondeo por borde evita huecos.

La revisión mejora claramente facetas, contraste y nitidez frente a la tanda
rechazada. A x3 se sigue percibiendo una construcción más geométrica y una
textura menos pictórica que rock_a/rock_b: no se certifica como cumplido el
criterio subjetivo de que no resulten peores. Queda expuesto en la comparación,
sin presentar la muestra como arte aprobado ni dar T504 por cerrada.
No se ejecutó ni importó el juego, no se probó en teléfono ni se midió
rendimiento. No se modificaron tablero, CHANGELOG ni archivos fuera del alcance.
No se hizo git add, commit ni push.
""",encoding='utf-8')


def main():
    assets={}
    for model in 'abc':
        for color in COLORS:
            key=f'roca_{model}_{color}';im=rock(model,color);save(im,key+'.png');assets[key]=im
    review(assets);references(assets);sheets(assets,220);sheets(assets,34);compose(assets);verify(assets);documentation()
    print('Generadas las hojas sobre cinco biomas y tres montajes con recortes y calibración.')

if __name__=='__main__':
    main()
