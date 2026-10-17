"""Compone el informe visual con recortes de capturas, sin repintar el juego."""
from pathlib import Path
import json
import math
import re
from PIL import Image, ImageChops, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
CAP = HERE / 'captures'
OUT = HERE / 'review'
OUT.mkdir(exist_ok=True)
META = json.loads((HERE / 'map_metadata.json').read_text())
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 14)
SMALL = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 12)
BG = '#191d22'
FG = '#eee8da'

def canvas(size):
    return Image.new('RGB', size, BG)

def label(image, xy, text, font=FONT):
    ImageDraw.Draw(image).text(xy, text, fill=FG, font=font)

def capture(level, phase='current'):
    return Image.open(CAP / f'level_{level:02d}_{phase}.png').convert('RGB')

# Resumen reducido explícito; los originales se conservan intactos.
primary = [1, 3, 5, 11, 13, 15]
overview = canvas((1280, 1170))
for i, level in enumerate(primary):
    x, y = i % 2 * 640, i // 2 * 390
    label(overview, (x+12, y+8), f'Nivel {level} · estado actual · vista reducida al 50 %')
    overview.paste(capture(level).resize((640, 360), Image.Resampling.LANCZOS), (x, y+30))
overview.save(OUT / 'current_overview.png')

# Selección de cinco piezas; la Central se trata como un conjunto indivisible de cuatro cuartos.
selected = [(11, 'mina', '01_mine'), (13, 'bosque_explotable', '02_forest'), (15, 'central_1', '03_central'), (11, 'escombro', '04_rubble'), (1, 'estatua', '05_statue')]
contact = canvas((740, 5*100+45))
label(contact, (12, 8), 'Prueba de lectura: una casilla = 34 px; Central = 2×2 casillas')
rows = []
for i, (level, drawing, name) in enumerate(selected):
    meta = META[str(level)]
    cell = next(x for x in meta['legend'] if x['drawing'] == drawing)
    tile = meta['tile_screen_px']
    footprint = tile * (2 if drawing == 'central_1' else 1)
    x, y = cell['screen_origin']
    # Recorte nativo de contexto; sin ampliar ni cambiar proporciones.
    cx, cy = x+footprint/2, y+footprint/2
    left = max(0, min(1280-224, round(cx-112)))
    top = max(48, min(624-160, round(cy-80)))
    rect = (left, top, left+224, top+160)
    pair = canvas((464, 190))
    label(pair, (5, 5), f'ANTES · nivel {level}')
    label(pair, (241, 5), 'MUESTRA · sin integrar')
    for j, phase in enumerate(['current', 'proposal']):
        image = capture(level, phase)
        pair.paste(image.crop(rect), (j*240, 30))
        cut = image.crop((round(x), round(y), round(x+footprint), round(y+footprint)))
        side = 68 if drawing == 'central_1' else 34
        small = cut.resize((side, side), Image.Resampling.LANCZOS)
        px, py = 340 + j*160, 45+i*100
        contact.paste(small, (px, py))
        label(contact, (px, py+71), 'ANTES' if j == 0 else 'MUESTRA', SMALL)
    label(contact, (12, 53+i*100), f'{i+1}. {drawing} · nivel {level}')
    pair.save(OUT / f'{name}_native.png')
    rows.append({'pieza': drawing, 'nivel': level, 'casilla': cell['cell'], 'casilla_px': tile, 'recorte_nativo': list(rect), 'imagen': f'review/{name}_native.png'})
contact.save(OUT / 'comparison_34.png')
(HERE / 'review_metadata.json').write_text(json.dumps(rows, ensure_ascii=False, indent=2)+'\n')

# Vecinos: amplitud de repetición y cambio de lenguaje. Solo el resumen se reduce.
neighbors = canvas((1280, 780))
for i, level in enumerate([2, 4, 12, 14]):
    x, y = i%2*640, i//2*390
    label(neighbors, (x+12,y+8), f'Vecino: nivel {level} · reducido al 50 %')
    neighbors.paste(capture(level).resize((640,360), Image.Resampling.LANCZOS), (x,y+30))
neighbors.save(OUT / 'neighbors_overview.png')

# Enemigos: recortes del juego al tamaño REAL, separados de la normalización de lectura.
actors = []
for level in [13, 15]:
    image = capture(level, 'diagnostic')
    for n, actor in enumerate(META[str(level)]['diagnostic']):
        x,y=actor['screen_position']
        left=max(0,min(1280-160,round(x-80)))
        top=max(48,min(624-120,round(y-75)))
        actors.append((level,actor['enemy'],image.crop((left,top,left+160,top+120))))
actor_sheet=canvas((4*180,math.ceil(len(actors)/4)*160))
for i,(level,name,image) in enumerate(actors):
    x,y=i%4*180,i//4*160
    label(actor_sheet,(x+4,y+4),f'{name} · nivel {level}',SMALL)
    actor_sheet.paste(image,(x+10,y+30))
actor_sheet.save(OUT/'enemies_native.png')

names=['ratero','cargador','thief','colossus','guardian','normal','tank']
normalized=canvas((740,150))
label(normalized,(12,8),'Lectura normalizada: CUERPO de 34 px, no tamaño relativo en partida')
for i,name in enumerate(names):
    resource=(ROOT/'data/enemies'/f'{name}.tres').read_text()
    texture=re.search(r'type="Texture2D" path="res://([^"]+)"', resource).group(1)
    image=Image.open(ROOT/texture).convert('RGBA')
    image=image.crop(image.getbbox())
    image.thumbnail((34,34),Image.Resampling.LANCZOS)
    x=20+i*102
    normalized.paste(image,(x,50),image)
    label(normalized,(x-5,100),name,SMALL)
normalized.save(OUT/'enemies_34.png')

# Verifica que no se haya modificado el resto del mapa en la sustitución visual.
allowed={'mina','bosque_explotable','escombro','estatua','central_1','central_2','central_3','central_4'}
checks=[]
for level in [1,2,3,4,5,11,12,13,14,15]:
    diff=ImageChops.difference(capture(level),capture(level,'proposal'))
    mask=Image.new('L',(1280,720),255)
    draw=ImageDraw.Draw(mask)
    tile=META[str(level)]['tile_screen_px']
    for cell in META[str(level)]['legend']:
        if cell['drawing'] in allowed:
            x,y=cell['screen_origin']
            draw.rectangle((math.floor(x)-1,math.floor(y)-1,math.ceil(x+tile)+1,math.ceil(y+tile)+1),fill=0)
    outside=ImageChops.multiply(diff.convert('RGB'),Image.merge('RGB',(mask,mask,mask)))
    checks.append({'nivel':level,'diferencias_fuera_de_piezas':outside.getbbox()})
(HERE/'validation/comparison_check.json').write_text(json.dumps(checks,indent=2)+'\n')
assert all(x['diferencias_fuera_de_piezas'] is None for x in checks), checks

# Las fuentes vectoriales nuevas también se revisan ampliadas y a tamaño de Wiki.
for side in [220,112]:
    sheet=canvas((2*(side+30),2*(side+70)+35))
    label(sheet,(10,8),f'Fuentes a {side} px · no son capturas de partida',SMALL)
    for row,name in enumerate(['estatua','central']):
        for column,phase in enumerate(['before','after']):
            x=column*(side+30)+10
            y=row*(side+70)+60
            label(sheet,(x,y-22),f'{name} · '+('ANTES' if column==0 else 'MUESTRA'),SMALL)
            ground=Image.open(ROOT/'assets/tiles/rendered/ground_pradera.png').convert('RGB').resize((side,side),Image.Resampling.LANCZOS)
            source=Image.open(OUT/f'source_{name}_{phase}_{side}.png').convert('RGBA')
            ground.paste(source,(0,0),source)
            sheet.paste(ground,(x,y))
    sheet.save(OUT/f'source_contact_{side}.png')

options=''.join(f'<option value="{n}">Nivel {n}</option>' for n in [1,2,3,4,5,11,12,13,14,15])
blocks=''.join(f'<h2>{i+1}. {drawing} · nivel {level}</h2><img src="review/{name}_native.png" width="464" height="190" alt="Antes y muestra a escala nativa">' for i,(level,drawing,name) in enumerate(selected))
html='''<!doctype html><html lang="es"><meta charset="utf-8"><title>T267a · Comparación sin integrar</title><style>
body{background:#191d22;color:#eee8da;font:16px system-ui;margin:24px}button,select{font:inherit;padding:8px;margin:4px}button:focus{outline:3px solid #e1b86d} .map{overflow:auto;border:1px solid #596069;width:100%;max-width:1280px}.map img{display:block;width:1280px;height:720px;max-width:none}p{max-width:85ch}h2{font-size:19px;margin-top:28px}a{color:#9ccef3}</style>
<h1>T267a · Elegir antes de producir</h1><p>Capturas del juego real a 1280×720. Se conserva el suelo y la ubicación de cada pieza. Las muestras solo existen en la escena de revisión; la campaña sigue igual. Esta vista mantiene píxeles nativos: desplazá horizontalmente si no entra el mapa.</p>
<p><a href="../../specs/tareas/informes/T267a-propuesta-assets.md">Informe completo</a> · <a href="review/comparison_34.png">Lectura a 34 px por casilla</a> · <a href="review/enemies_native.png">Enemigos a tamaño real</a></p>
<label>Nivel <select id="level">OPTIONS</select></label><button onclick="phase='current';show()">Antes</button><button onclick="phase='proposal';show()">Muestra aislada</button><strong id="status"></strong><div class="map"><img id="map" alt="Captura de partida"></div>
<p>Mina, bosque y escombros prueban SVG ya existentes; no están conectados hoy. La estatua y la Central son bocetos nuevos de volumen, sin aprobación. Una elección puede combinar piezas o conservar el antes; no hace falta aprobar el grupo entero.</p>BLOCKS
<script>let phase='current';const level=document.getElementById('level');function show(){document.getElementById('map').src=`captures/level_${level.value.padStart(2,'0')}_${phase}.png`;document.getElementById('status').textContent=phase==='current'?'Estado actual':'Muestra sin integrar'}level.onchange=show;show();</script></html>'''.replace('OPTIONS',options).replace('BLOCKS',blocks)
(HERE/'comparison.html').write_text(html)
print('Hojas, HTML y validación contextual generados; sin diferencias fuera de las piezas.')
