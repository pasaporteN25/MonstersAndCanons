"""Compone comparaciones desde capturas reales; verifica alcance de las diferencias."""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFont
import json, html
HERE=Path(__file__).resolve().parent
META=json.loads((HERE/'map_metadata.json').read_text())
FONT=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
checks=[]
selected=[(11,'mina','mine'),(13,'bosque_explotable','forest'),(11,'escombro','rubble'),(15,'central_1','central'),(1,'estatua','statue')]
for level,drawing,name in selected:
    m=META[str(level)]; tile=m['tile_screen_px']
    cell=next(c for c in m['legend'] if c['drawing']==drawing)
    x,y=cell['screen_origin']; side=tile*(2 if name=='central' else 1)
    left=max(0,min(1280-240,round(x+side/2-120)))
    top=max(48,min(624-180,round(y+side/2-90)))
    crop=(left,top,left+240,top+180)
    sheet=Image.new('RGB',(1008,210),'#1d2227'); draw=ImageDraw.Draw(sheet)
    for j,phase in enumerate(['current','proposal','proposal_state_1','proposal_state_2']):
        image=Image.open(HERE/'captures'/f'level_{level:02d}_{phase}.png')
        sheet.paste(image.crop(crop),(j*252,30))
        label=['ANTES','PROPUESTA · reposo','PROPUESTA · activa','PROPUESTA · agotada'][j]
        if name=='statue': label=['ANTES','Cañón','Francotirador','Ametralladora'][j]
        if name in ['rubble','central'] and j==3: label='Mismo estado anterior'
        draw.text((j*252+5,6),label,font=FONT,fill='white')
    sheet.save(HERE/'review'/f'{name}_native.png')
for level,m in META.items():
    before=Image.open(HERE/'captures'/f'level_{int(level):02d}_current.png').convert('RGB')
    tile=m['tile_screen_px']
    mask=Image.new('L',before.size); draw=ImageDraw.Draw(mask)
    for cell in m['legend']:
        if cell['drawing'] in ['mina','bosque_explotable','escombro','estatua','central_1','central_2','central_3','central_4']:
            x,y=cell['screen_origin']
            draw.rectangle((int(x)-1,int(y)-1,round(x+tile)+1,round(y+tile)+1),fill=255)
    for phase in ['proposal','proposal_state_1','proposal_state_2']:
        after=Image.open(HERE/'captures'/f'level_{int(level):02d}_{phase}.png').convert('RGB')
        assert before.size==after.size==(1280,720)
        difference=ImageChops.difference(before,after)
        difference.paste((0,0,0),(0,0),mask)
        bbox=difference.getbbox()
        checks.append({'level':int(level),'phase':phase,'outside_selected_cells':bbox,'size':before.size})
        assert bbox is None, f'Diferencias externas: {level} {phase} {bbox}'
(HERE/'validation'/'comparison_check.json').write_text(json.dumps(checks,indent=2)+'\n')
page='''<!doctype html><html lang="es"><meta charset="utf-8"><title>T267b · Revisión</title><style>body{background:#171c20;color:#eee;font:16px sans-serif;margin:24px}img.map{width:1280px;height:720px;max-width:none}button,select{font:inherit;margin:8px;padding:10px}a{color:#edc76b}p{max-width:1000px}</style><h1>T267b · Propuesta aislada</h1><p>Mapas reales de 1280×720. No hay integración ni aprobación artística. Elegí nivel y estado; la reserva y el velo son los actuales y no se avanzó el ciclo jugable.</p><select id="level">'''
for level in sorted(META,key=int): page+=f'<option>{level}</option>'
page+='</select><button onclick="phase=\'current\';show()">Antes</button><button onclick="phase=\'proposal\';show()">Reposo / Cañón</button><button onclick="phase=\'proposal_state_1\';show()">Activa / Francotirador</button><button onclick="phase=\'proposal_state_2\';show()">Agotada / Ametralladora</button><p id="caption"></p><img class="map" id="map"><p><a href="review/contact_220.png">Hoja a 220 px</a> · <a href="review/contact_34.png">Hoja a 34 px</a></p><script>let phase="current";function show(){let n=String(level.value).padStart(2,"0");map.src=`captures/level_${n}_${phase}.png`;caption.textContent=`Nivel ${level.value} · ${{current:"Antes",proposal:"Propuesta en reposo / Cañón",proposal_state_1:"Propuesta activa / Francotirador",proposal_state_2:"Propuesta agotada / Ametralladora"}[phase]} · 1280×720`};level.onchange=show;show()</script></html>'
(HERE/'comparison.html').write_text(page)
print(f'{len(checks)} comparaciones sin diferencias fuera de las casillas seleccionadas')
# Resumen reducido al 25 %; no reemplaza los originales de 1280×720.
levels=sorted(META,key=int)
overview=Image.new('RGB',(1280,len(levels)*208),'#1d2227'); draw=ImageDraw.Draw(overview)
phases=['current','proposal','proposal_state_1','proposal_state_2']
for row,level in enumerate(levels):
    for col,phase in enumerate(phases):
        draw.text((col*320+5,row*208+5),f'Nivel {level} · '+['antes','reposo / Cañón','activa / Francotirador','agotada / Ametralladora'][col],font=FONT,fill='white')
        image=Image.open(HERE/'captures'/f'level_{int(level):02d}_{phase}.png').convert('RGB').resize((320,180),Image.Resampling.LANCZOS)
        overview.paste(image,(col*320,row*208+28))
overview.save(HERE/'review'/'overview_25_percent.png')
