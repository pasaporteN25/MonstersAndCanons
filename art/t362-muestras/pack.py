"""Genera muestras originales de luz, atlas y comparativas. No escribe fuera de esta carpeta."""
from pathlib import Path
import hashlib
import json
import math
import shutil
from PIL import Image, ImageDraw, ImageFont, ImageChops

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
S = 4
SIZE = 192
THEMES = ['pradera', 'nieve', 'volcan', 'desierto']
TINTS = {'neutral': (1, 1, 1), 'amber': (1, .7, .28), 'frost': (.25, .8, 1),
         'tesla': (.75, .4, 1), 'fire': (1, .36, .08), 'multi': (.3, .65, 1)}
LABELS = {'neutral': 'Neutro', 'amber': 'Ámbar / por omisión', 'frost': 'Hielo',
          'tesla': 'Tesla', 'fire': 'Fuego', 'multi': 'Múltiple'}
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
SMALL = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 12)


def save(im, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, optimize=True)


def frame(level, index):
    """Trazos de luz con envolventes alfa, sin filtros ni sombras."""
    im = Image.new('RGBA', (SIZE*S, SIZE*S))
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192" viewBox="0 0 192 192">',
           '<!-- Luz de mejora, anillos ascendentes y chispas; fondo transparente. -->']

    def stroke_ellipse(cx, cy, rx, ry, strength, width=2):
        for w, a, rgb in [(width+7, .025, (255, 246, 224)), (width+4, .07, (255, 248, 232)),
                          (width+2, .23, (255, 250, 237)), (width, .95, (255, 253, 247)),
                          (.75, 1, (255, 255, 252))]:
            alpha = max(0, min(255, round(255*a*strength)))
            layer = Image.new('RGBA', im.size)
            d = ImageDraw.Draw(layer)
            d.ellipse(tuple(round(v*S) for v in (cx-rx, cy-ry, cx+rx, cy+ry)),
                      outline=(*rgb, alpha), width=max(1, round(w*S)))
            im.alpha_composite(layer)
            svg.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="none" stroke="rgb{rgb}" stroke-width="{w}" opacity="{alpha/255:.5f}"/>')

    def diamond(cx, cy, rx, ry, strength):
        for scale, a in [(1.5, .09), (1.15, .26), (1, .95), (.45, 1)]:
            points = [(cx, cy-ry*scale), (cx+rx*scale, cy), (cx, cy+ry*scale), (cx-rx*scale, cy)]
            alpha = round(255*strength*a)
            layer = Image.new('RGBA', im.size)
            ImageDraw.Draw(layer).polygon([(round(x*S), round(y*S)) for x,y in points], fill=(255, 252, 242, alpha))
            im.alpha_composite(layer)
            svg.append(f'<polygon points="{" ".join(f"{x:.3f},{y:.3f}" for x,y in points)}" fill="#fffcf2" opacity="{alpha/255:.5f}"/>')

    envelope = [.035, .46, .88, 1, .82, .48, .16, 0][index]
    t = index/6
    if index < 7:
        cy = 125 - 64*t
        rx = (29 + 29*min(1, t*1.5)) if level == 2 else (34 + 40*min(1, t*1.5))
        stroke_ellipse(96, round(cy, 3), round(rx, 3), round(10+9*t, 3), envelope, 2.2 if level == 2 else 3.1)
        if level == 3 and index > 0:
            stroke_ellipse(96, round(cy+22, 3), round(rx*.82, 3), round(9+8*t, 3), envelope*.82, 2.5)
        if index > 0:
            count = 6 if level == 2 else 8
            for j in range(count):
                angle = math.radians(198+j*144/(count-1))
                reach = (37+24*t) if level == 2 else (48+31*t)
                x = 96+math.cos(angle)*reach
                y = 109+math.sin(angle)*reach*.78-16*t
                strength = envelope * (.72 if j % 2 else .95)
                diamond(x, y, 1.5 if level == 2 else 2.1, 3.3 if level == 2 else 4.7, strength)
        if level == 3 and index in (2, 3, 4):
            # Cruz de luz desplazada hacia arriba: deja visible el mecanismo.
            peak = {2: .55, 3: 1, 4: .4}[index]
            diamond(118, 62, 2.1, 14, peak)
            diamond(118, 62, 12, 1.7, peak)
    svg.append('</svg>')
    (ROOT/'sources'/f'upgrade_l{level}_{index+1:02}.svg').write_text('\n'.join(svg)+'\n')
    im = im.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    # Los píxeles transparentes se ponen a cero (alfa recto).
    im.putdata([px if px[3] else (0,0,0,0) for px in im.get_flattened_data()])
    save(im, ROOT/'sources'/f'upgrade_l{level}_{index+1:02}.png')
    return im


def tint(im, color):
    r,g,b,a = im.split()
    return Image.merge('RGBA', tuple(c.point(lambda v: round(v*k)) for c,k in zip((r,g,b), color))+(a,))


def ground(theme, size):
    tile = Image.open(ROOT/'reference'/f'ground_{theme}.png').convert('RGBA').resize((64,64), Image.Resampling.LANCZOS)
    im = Image.new('RGBA', size)
    for y in range(0,size[1],64):
        for x in range(0,size[0],64):
            im.paste(tile,(x,y))
    return im


def tower(im, name, center, level):
    factor = 2 if name == 'mortar' else 1
    side = 64*factor
    base = Image.open(ROOT/'reference'/f'base_{level}.png').convert('RGBA').resize((side,side), Image.Resampling.LANCZOS)
    turret = Image.open(ROOT/'reference'/f'{name}_level_{level}.png').convert('RGBA').crop((0,0,128,128)).resize((side,side), Image.Resampling.LANCZOS)
    x,y = center
    im.alpha_composite(base,(x-side//2,y-side//2))
    im.alpha_composite(turret,(x-side//2,y-side//2-12*factor))


def legacy(factor, t, color):
    im = Image.new('RGBA',(384,384))
    if t < .3:
        p = t/.3
        r = (16+(44.8-16)*(1-(1-p)**3))*factor
        d = ImageDraw.Draw(im)
        d.ellipse((192-r,192-r,192+r,192+r), outline=tuple(round((v+(1-v)*.5)*255) for v in color)+(round(255*(1-p)),), width=3*factor)
    return im


def make_gif(level, frames):
    # GIF admite centésimas; el HTML usa los tiempos exactos de cada cuadro.
    duration = 500 if level == 2 else 700
    images = []
    for ms in range(0, duration+1000, 10):
        im = ground('pradera',(1152,432))
        d = ImageDraw.Draw(im)
        for col,(name,old) in enumerate([('basic',True),('basic',False),('mortar',True),('mortar',False)]):
            x=144+288*col; y=246
            factor=2 if name=='mortar' else 1
            tower(im,name,(x,y),level)
            if old:
                fx=legacy(factor,ms/1000,(.48,.35,.21) if name=='mortar' else (.47843137,)*3)
                im.alpha_composite(fx,(x-192,y-192))
            elif ms<duration:
                idx=min(7,ms*8//duration)
                fx=tint(frames[idx],TINTS['amber']).resize((192*factor,192*factor),Image.Resampling.LANCZOS)
                im.alpha_composite(fx,(x-96*factor,y-12*factor-96*factor))
            d.rectangle((col*288,0,(col+1)*288,56),fill=(20,27,33,255))
            d.text((col*288+12,12),('Actual · 0,3 s' if old else f'Nivel {level} · {duration/1000:g} s'),font=FONT,fill='white')
            d.text((col*288+12,34),('Mortero 2×2' if factor==2 else 'Ametralladora 1×1'),font=SMALL,fill='#d9e1e7')
        images.append(im.convert('RGB'))
    # Paleta común: evita parpadeos del suelo entre cuadros.
    palette = images[duration//20].quantize(colors=255)
    images = [im.quantize(palette=palette, dither=Image.Dither.NONE) for im in images]
    images[0].save(ROOT/'preview'/f'upgrade_l{level}.gif',save_all=True,append_images=images[1:],duration=10,loop=0,optimize=True,disposal=1)


def main():
    refs = []
    paths = [f'assets/tiles/rendered/ground_{t}.png' for t in THEMES]
    paths += [f'assets/sprites/towers/rendered/{n}_level_{l}.png' for n in ['basic','mortar'] for l in [2,3]]
    paths += [f'assets/sprites/towers/rendered/base_{l}.png' for l in [2,3]]
    paths += [f'assets/sprites/effects/rendered/{n}.png' for n in ['frost','explosion']]
    for path in paths:
        src=REPO/path; dest=ROOT/'reference'/src.name
        shutil.copyfile(src,dest)
        refs.append({'source':path,'copy':str(dest.relative_to(ROOT)),'sha256':hashlib.sha256(src.read_bytes()).hexdigest()})
    all_frames = {}
    records = []
    for level in [2,3]:
        frames=[frame(level,i) for i in range(8)]
        all_frames[level]=frames
        atlas=Image.new('RGBA',(768,384))
        for i,im in enumerate(frames): atlas.paste(im,((i%4)*192,(i//4)*192))
        dest=ROOT/f'upgrade_l{level}.png'; save(atlas,dest)
        for key,color in TINTS.items():
            if key != 'neutral': save(tint(atlas,color),ROOT/'preview'/'tinted'/f'upgrade_l{level}_{key}.png')
        records.append({'file':dest.name,'size':[768,384],'mode':'RGBA','frame_size':[192,192],
                        'columns':4,'rows':2,'frames':8,'center':[96,96],
                        'duration_seconds':.5 if level==2 else .7,'fps':16 if level==2 else 80/7,
                        'spark_count':6 if level==2 else 8,'bytes':dest.stat().st_size,
                        'alpha_bounds':[im.getbbox() for im in frames]})
        make_gif(level,frames)
    for theme in THEMES:
        sheet=Image.new('RGBA',(1600,12*280+64),(21,27,34,255))
        d=ImageDraw.Draw(sheet)
        d.text((24,18),f'T362 · {theme} · Cuadros 192 px y 34 px · columnas 1 a 8 · muestra sin aprobar',font=FONT,fill='white')
        row=0
        for level in [2,3]:
            for key,color in TINTS.items():
                y=64+row*280
                strip=ground(theme,(1536,244))
                for i,im in enumerate(all_frames[level]):
                    fx=tint(im,color)
                    strip.alpha_composite(fx,(i*192,0))
                    strip.alpha_composite(fx.resize((34,34),Image.Resampling.LANCZOS),(i*192+79,202))
                sheet.paste(strip,(32,y+24))
                d.text((32,y+3),f'Nivel {level} · {LABELS[key]} · 192 px arriba / 34 px abajo',font=SMALL,fill='white')
                row+=1
        save(sheet.convert('RGB'),ROOT/'contact'/f'{theme}.png')
    manifest={'task':'T362','status':'muestras para aprobación; sin integración',
              'source_spec':'M65 / RF-590, RF-592, RF-595 / D-135 propuesta',
              'coordinate_system':'Origen arriba a la izquierda; orden fila a fila; píxeles',
              'assets':records,'tints':TINTS,'references':refs,
              'preview':{'tile_px':64,'tower_mount_offset':[0,-12],'mortar_footprint':2,
                         'html_scales':[.7,1,1.5],'gif_quantization_ms':10,'loop_gap_ms':1000},
              'open_decisions':['P-65-6: confirmar efecto único teñido o por familia','Aprobación artística de Lucas'],
              'game_logic_changed':False}
    (ROOT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(records,ensure_ascii=False,indent=2))


if __name__=='__main__': main()
