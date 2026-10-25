"""T492: propuestas reproducibles; no escribe fuera de esta carpeta.

Requiere Pillow y NumPy. Ejecutar desde cualquier directorio.
Las coordenadas del glifo son las del SVG vigente, sin rediseñarlo.
"""
from pathlib import Path
import json
import math
import hashlib
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SIZE = 512
S = SIZE / 64
Y, X = np.mgrid[:SIZE, :SIZE].astype(float) / S
THEMES = ['pradera', 'bosque', 'desierto', 'nieve', 'ruinas']
NAMES = ['Tallado sobrio', 'Tallado profundo', 'Superficie erosionada']
PIECES = ['marked_rock', 'ruin_symbol']
LABELS = ['Roca marcada', 'Piedra de ruina']
GLYPH = [((23, 42), (32, 24)), ((32, 24), (41, 42)), ((27, 35), (37, 35))]
RESAMPLE = Image.Resampling.LANCZOS
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'


def font(size):
    return ImageFont.truetype(FONT, size)


def polygon_mask(points):
    im = Image.new('L', (SIZE, SIZE))
    ImageDraw.Draw(im).polygon([(round(x*S), round(y*S)) for x,y in points], fill=255)
    return np.asarray(im).astype(float) / 255


def noise(seed, grid):
    rng = np.random.default_rng(seed)
    im = Image.fromarray(np.uint8(rng.random((grid, grid)) * 255))
    return np.asarray(im.resize((SIZE, SIZE), Image.Resampling.BICUBIC)).astype(float)/255 - .5


def segment_distance(a, b):
    dx,dy = b[0]-a[0],b[1]-a[1]
    t = np.clip(((X-a[0])*dx+(Y-a[1])*dy)/(dx*dx+dy*dy), 0, 1)
    return np.hypot(X-a[0]-t*dx,Y-a[1]-t*dy)


def render(piece, variant):
    """Relieve de caras biseladas, normales, oclusión y ruido mineral multiescala."""
    ruin = piece == 'ruin_symbol'
    if ruin:
        outer = [(8,49),(9,25),(18,16),(35,17),(40,12),(53,17),(57,49),(45,53),(36,50),(28,54),(19,50)]
        inner = [(12,46),(13,28),(21,21),(34,22),(41,19),(48,22),(51,45),(43,48),(36,46),(28,50),(21,46)]
    else:
        outer = [(9,48),(7,35),(13,25),(22,18),(38,15),(51,23),(56,37),(51,49),(39,53),(20,52)]
        inner = [(14,44),(12,35),(17,29),(25,23),(37,21),(46,27),(49,37),(46,45),(37,49),(22,48)]
    mask = polygon_mask(outer)
    height = np.zeros_like(X)
    shade = np.zeros_like(X)
    # Cada cara conserva un plano diferente; el frente tiene una curvatura tenue.
    front = polygon_mask(inner)
    height += front * (6.7 - .012*(X-30)**2 - .006*(Y-34)**2)
    shade += front * (1.0 + .04*(32-X)/24)
    for i in range(len(outer)):
        j = (i+1)%len(outer)
        a,b,c,d = outer[i],outer[j],inner[j],inner[i]
        region = polygon_mask([a,b,c,d]) * (1-front)
        distance = segment_distance(a,b)
        ramp = np.clip(distance/4.9,0,1)
        height += region*(1.1+5*ramp)
        mx,my = (a[0]+b[0])/2,(a[1]+b[1])/2
        light = np.clip(.82 + (31-mx)*.011 + (34-my)*.016,.47,1.30)
        shade += region*light
    # Fisuras de material: no cruzan ni reemplazan el símbolo.
    cracks = ([[(35,17),(32,21),(35,24),(34,28)],[(52,31),(48,34),(50,39)],[(15,40),(19,42),(18,46)],[(39,50),(40,45),(44,43)]] if ruin else
              [[(15,27),(21,30),(22,32)],[(49,28),(45,32),(47,36)],[(20,49),(23,46)],[(42,49),(44,44)]])
    crack_distance = np.full_like(X,100)
    for line in cracks:
        for a,b in zip(line,line[1:]):
            crack_distance = np.minimum(crack_distance,segment_distance(a,b))
    eroded = variant == 3
    rough = noise(2026,11)*.50 + noise(742,45)*.15 + noise(492,180)*.05
    height += rough*(1.7 if eroded else 1)
    height -= np.exp(-(crack_distance/.23)**2)*(1.0 if ruin else .65)
    # Misma A, posición y ancho central (3 unidades) en las seis piezas.
    distance = np.minimum.reduce([segment_distance(a,b) for a,b in GLYPH])
    depth = [0, .80, 1.55, 1.15][variant]
    profile = np.clip((1.9-distance)/.72,0,1)
    height -= depth*profile
    gy,gx = np.gradient(height,1/S)
    nx,ny,nz = -gx*.42,-gy*.42,np.ones_like(X)
    norm = np.sqrt(nx*nx+ny*ny+nz*nz)
    light = np.clip((nx*-.42+ny*-.53+nz*.74)/norm,0,1)
    illumination = (.53+.57*light)*shade
    base = np.array(([158,150,132] if ruin else [150,147,135]),float)
    if variant==1: base += [1,0,-1]
    if variant==2: base += [9,9,10]
    if variant==3: base += [3,0,-4]
    mineral = noise(491,8)*31+noise(492,24)*19+noise(493,100)*7
    colors = base[None,None,:]*illumination[:,:,None]+mineral[:,:,None]
    # Oscuridad dentro del surco, con reborde iluminado por las normales.
    colors *= (1-profile*(.48 if variant==2 else .36))[:,:,None]
    # El labio inferior/derecho del tallado recibe luz; la pared opuesta queda ocluida.
    shifted = np.minimum.reduce([
        # Traslación del muestreo: conserva el trazado y hace visible el bisel físico.
        segment_distance((a[0]+.55,a[1]+.70),(b[0]+.55,b[1]+.70))
        for a,b in GLYPH])
    rim = np.clip((1.95-shifted)/.60,0,1)*(1-profile)
    colors += rim[:,:,None]*np.array([38,34,25])*(1 if variant==2 else .65)
    colors *= (1-.24*np.exp(-(crack_distance/.19)**2))[:,:,None]
    # Desgaste mineral y líquenes discretos en bordes, sin nueva marca narrativa.
    boundary = np.minimum.reduce([segment_distance(a,b) for a,b in zip(outer,outer[1:]+outer[:1])])
    edge = (boundary<.38)*(.4+.6*np.clip((36-X)/26,0,1))
    colors += edge[:,:,None]*np.array([21,19,14])
    lichen = np.clip((noise(299,25)+noise(46,71)*.4-.14)*5,0,.6)
    lichen *= np.clip((distance-3)/5,0,1)*np.clip((Y-38)/10,0,1)
    colors = colors*(1-lichen[:,:,None]) + np.array([105,110,64])*lichen[:,:,None]
    if eroded:
        pits = np.clip((noise(384,55)-.23)*6,0,.55)
        colors *= (1-pits*.22)[:,:,None]
    # La sombra no excede la huella histórica y se desvanece hasta alfa cero.
    shadow = np.exp(-(((X-33)/19.5)**2+((Y-54.5)/2.5)**2)*1.6)*.25
    shadow[(X<7)|(X>57)|(Y<49)|(Y>59)] = 0
    bg = Image.fromarray(np.uint8(np.dstack([X*0+35,X*0+31,X*0+26,shadow*255])))
    rock = Image.fromarray(np.uint8(np.dstack([np.clip(colors,0,255),mask*255])))
    bg.alpha_composite(rock)
    bg.save(HERE/'sources'/f'{piece}_v{variant:02}_work.png')
    final = bg.resize((128,128),RESAMPLE)
    final.save(HERE/'variants'/f'{piece}_v{variant:02}.png',optimize=True)
    return final


def ground(theme, size):
    tile = Image.open(ROOT/f'assets/tiles/rendered/ground_{theme}.png').convert('RGBA').resize((size,size),RESAMPLE)
    return tile


def sheet(samples, theme, scale):
    # A 34 px el sprite conserva su tamaño real; los rótulos quedan fuera del suelo.
    tile = scale if scale==220 else 86
    col = max(tile+20,228 if scale==220 else 190)
    width = 3*col+32
    row = tile+70
    im = Image.new('RGBA',(width,2*row+100),(24,27,29,255))
    d = ImageDraw.Draw(im)
    d.text((20,14),f'T492 · {theme.capitalize()} · {scale} px',font=font(23),fill='#eadcc3')
    d.text((20,48),'PROPUESTA · misma A y misma huella · sin integrar',font=font(13),fill='#b6b7b1')
    for p,piece in enumerate(PIECES):
        for v in range(1,4):
            x = 16+(v-1)*col+(col-tile)//2
            y = 86+p*row
            im.alpha_composite(ground(theme,tile),(x,y))
            sprite=samples[piece,v].resize((scale,scale),RESAMPLE)
            im.alpha_composite(sprite,(x+(tile-scale)//2,y+(tile-scale)//2))
            d.text((16+(v-1)*col,y+tile+8),f'{LABELS[p]} · {v:02}',font=font(14),fill='#e4dac7')
            d.text((16+(v-1)*col,y+tile+29),NAMES[v-1],font=font(12),fill='#b6b7b1')
    im.convert('RGB').save(HERE/'sheets'/f'{theme}_{scale}.png')


def compose(samples, level, variant, post=False):
    capture=ROOT/f'art/m79-inventario/antes-nivel-{level:02}-1280x720.png'
    im=Image.open(capture).convert('RGBA')
    data=json.loads((ROOT/f'data/levels/level_{level:02}.json').read_text())
    # Encuadre de las capturas T491: área útil 1280 × 576 desde y=48.
    rows,cols=len(data['mapa']),len(data['mapa'][0])
    tile=min(1280/cols,576/rows)
    ox=(1280-cols*tile)/2
    oy=48+(576-rows*tile)/2
    changed=[]
    for y,row in enumerate(data['mapa']):
        for x,c in enumerate(row):
            drawing=data.get('leyenda',{}).get(c,{}).get('dibujo')
            if drawing not in ['roca_marcada','simbolo_ruina']:continue
            piece=PIECES[0 if drawing=='roca_marcada' else 1]
            box=(round(ox+x*tile),round(oy+y*tile),round(ox+(x+1)*tile),round(oy+(y+1)*tile))
            # El parche repone solo el suelo de esa casilla con el material vigente.
            patch=Image.open(ROOT/f"assets/tiles/rendered/ground_{data['tema']}.png").convert('RGBA').resize((box[2]-box[0],box[3]-box[1]),Image.Resampling.BILINEAR)
            patch.alpha_composite(samples[piece,variant].resize(patch.size,RESAMPLE))
            if post and (x,y)==(0,4):
                # T475 omite la señal: el mapa muestra solo el poste sobre el suelo.
                patch=Image.open(ROOT/f"assets/tiles/rendered/ground_{data['tema']}.png").convert('RGBA').resize(patch.size,Image.Resampling.BILINEAR)
                pole=Image.open(ROOT/'assets/sprites/map/rendered/banner_post_enemy.png').convert('RGBA')
                patch.alpha_composite(pole.resize(patch.size,RESAMPLE))
            im.paste(patch,box[:2]); changed.append({'casilla':[x,y],'rectangulo':list(box)})
    d=ImageDraw.Draw(im)
    text=f'PROPUESTA T492 · variante {variant:02} · composición sobre captura · sin motor'
    if post:text+=' · poste hipotético (0, 4), señal omitida'
    d.rectangle((8,593,1250 if post else 820,621),fill='#181b1eee')
    d.text((16,599),text,font=font(14),fill='#ffdc98')
    tag='_with_post' if post else ''
    name=f'level_{level:02}_v{variant:02}{tag}.png'
    im.convert('RGB').save(HERE/'composites'/name)
    return {'archivo':name,'origen':str(capture.relative_to(ROOT)),'casillas':changed,'poste_hipotetico':post}


def post_comparison(samples):
    im=Image.new('RGBA',(1080,1000),'#181b1e');d=ImageDraw.Draw(im)
    d.text((20,16),'Señal y poste · niveles 8 y 9 · casilla (0, 4)',font=font(23),fill='#eadcc3')
    d.text((20,51),'PROPUESTA · superposición hipotética · no hay poste allí en los datos vigentes',font=font(15),fill='#cebea2')
    for v in range(1,4):
        x=30+(v-1)*350
        d.text((x,88),f'Variante {v:02} · {NAMES[v-1]}',font=font(16),fill='#e5d3ad')
        for i,with_post in enumerate([False,True,True]):
            tile=ground('ruinas',220)
            if i!=2:tile.alpha_composite(samples['ruin_symbol',v].resize((220,220),RESAMPLE))
            if with_post:
                tile.alpha_composite(Image.open(ROOT/'assets/sprites/map/rendered/banner_post_enemy.png').convert('RGBA').resize((220,220),RESAMPLE))
            y=123+i*265
            label=['Sin poste','Superposición pedida (diagnóstico)','T475 vigente: señal omitida'][i]
            im.alpha_composite(tile,(x,y));d.text((x,y+226),label,font=font(14),fill='#d6d2c7')
            small=tile.resize((34,34),RESAMPLE)
            im.alpha_composite(small,(x+240,y+88))
            d.text((x+235,y+130),'34 px',font=font(12),fill='#b6b7b1')
    d.text((20,955),'T475 no dibuja la señal bajo el poste. La fila central solo ensaya la superposición.',font=font(17),fill='#ffdc98')
    im.convert('RGB').save(HERE/'sheets/post_overlap_220_34.png')


def main():
    original_glyph='M23 42 32 24 41 42M27 35h10'
    for name in ['roca_marcada','simbolo_ruina']:
        assert original_glyph in (ROOT/f'assets/sprites/map/{name}.svg').read_text()
    for folder in ['sources','variants','sheets','composites']:(HERE/folder).mkdir(exist_ok=True)
    samples={(p,v):render(p,v) for p in PIECES for v in range(1,4)}
    for theme in THEMES:
        for scale in [220,34]:sheet(samples,theme,scale)
    post_comparison(samples)
    captures=[]
    for level in [8,9,11]:
        for variant in range(1,4):
            captures.append(compose(samples,level,variant))
            if level in [8,9]:captures.append(compose(samples,level,variant,True))
    (HERE/'sources/composition_manifest.json').write_text(json.dumps(captures,ensure_ascii=False,indent=2)+'\n')
    records=[]
    for f in sorted((HERE/'variants').glob('*.png')):
        im=Image.open(f)
        assert im.size==(128,128) and im.mode=='RGBA'
        assert im.getchannel('A').getextrema()==(0,255)
        records.append({'archivo':str(f.relative_to(HERE)),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'modo':im.mode,'tamano':list(im.size),'caja_alfa':list(im.getbbox())})
    (HERE/'sources/validation.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
    inputs=[ROOT/f'assets/sprites/map/{name}.svg' for name in ['roca_marcada','simbolo_ruina']]
    inputs += [ROOT/f'assets/tiles/rendered/ground_{t}.png' for t in THEMES]
    inputs += [ROOT/'assets/sprites/map/rendered/banner_post_enemy.png']
    inputs += [ROOT/f'art/m79-inventario/antes-nivel-{n:02}-1280x720.png' for n in [8,9,11]]
    inputs += [ROOT/f'data/levels/level_{n:02}.json' for n in [8,9,11]]
    provenance=[{'archivo':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in inputs]
    (HERE/'sources/input_manifest.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2)+'\n')
    print('Generadas seis piezas RGBA, once hojas y quince composiciones. Validación guardada.')


if __name__=='__main__':main()
