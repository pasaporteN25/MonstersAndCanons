"""Recorta por alfa y prepara derivados y hojas; no genera ni repinta arte."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw, ImageFont
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
FONT=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
records=[]
for source in sorted((HERE/'sources').glob('*.png')):
    image=Image.open(source).convert('RGBA')
    assert image.getextrema()[3][0]==0, f'Sin transparencia: {source}'
    bbox=image.getchannel('A').getbbox()
    cropped=image.crop(bbox)
    side=256 if source.stem=='central_master' else 128
    cropped.thumbnail((round(side*.88),round(side*.84)),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(side,side))
    out.alpha_composite(cropped,((side-cropped.width)//2,round(side*.92)-cropped.height))
    out.save(HERE/'sprites'/source.name)
    if source.stem=='central_master':
        for i,(x,y) in enumerate([(0,0),(128,0),(0,128),(128,128)],1):
            out.crop((x,y,x+128,y+128)).save(HERE/'sprites'/f'central_{i}.png')
    records.append({'id':source.stem,'source':str(source.relative_to(HERE)),'source_size':image.size,'alpha_bbox':bbox,'output_size':[side,side],'sha256':hashlib.sha256(source.read_bytes()).hexdigest()})
(HERE/'manifest.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
labels={'mine_idle':'Mina · sin activar','mine_active':'Mina · activa','mine_depleted':'Mina · agotada','forest_idle':'Bosque · sin activar','forest_active':'Bosque · activo','forest_depleted':'Bosque · agotado','rubble_idle':'Escombros · reposo','rubble_working':'Escombros · trabajo','central_master':'Central · 2×2','statue_cannon_moss':'Cañón · musgo','statue_sniper_moss':'Francotirador · musgo','statue_basic_moss':'Ametralladora · musgo','statue_cannon_frost':'Cañón · escarcha','statue_sniper_frost':'Francotirador · escarcha','statue_basic_frost':'Ametralladora · escarcha'}
items=list(labels.items())+[('tree','Árbol actual'),('rock_a','Roca actual'),('turret_cannon','Cañón actual'),('turret_sniper','Francotirador actual'),('turret_basic','Ametralladora actual'),('mechanical_standard_m43','Estandarte actual')]
for size in (220,34):
    w=max(244,size*2+24); h=size*2+52
    sheet=Image.new('RGB',(w*3,h*((len(items)+2)//3)),'#1d2227')
    draw=ImageDraw.Draw(sheet)
    for index,(name,label) in enumerate(items):
        x=index%3*w; y=index//3*h
        ground='nieve' if name.endswith('frost') else 'pradera'
        texture=Image.open(ROOT/'assets/tiles/rendered'/f'ground_{ground}.png').convert('RGB').resize((w,h-28))
        sheet.paste(texture,(x,y+28))
        path=HERE/'sprites'/f'{name}.png'
        if not path.exists(): path=ROOT/'assets/sprites'/('towers' if (name.startswith('turret') or name.startswith('mechanical')) else 'map')/'rendered'/f'{name}.png'
        image=Image.open(path).convert('RGBA')
        side=size*2 if name=='central_master' else size
        image=image.resize((side,side),Image.Resampling.LANCZOS)
        sheet.paste(image,(x+(w-side)//2,y+28+(h-28-side)//2),image)
        draw.text((x+8,y+6),label,font=FONT,fill='white')
    sheet.save(HERE/'review'/f'contact_{size}.png')
print(f'{len(records)} fuentes preparadas; hojas 220/34 px')
# Comparación compacta de estados, sin ampliar los 34 px de cada casilla.
names=['mine_idle','mine_active','mine_depleted','forest_idle','forest_active','forest_depleted','rubble_idle','rubble_working','statue_cannon_moss']
sheet=Image.new('RGB',(660,240),'#243025'); draw=ImageDraw.Draw(sheet)
for index,name in enumerate(names):
    image=Image.open(HERE/'sprites'/f'{name}.png').resize((34,34),Image.Resampling.LANCZOS)
    x=index%3*220; y=index//3*80
    sheet.paste(image,(x+90,y+30),image)
    draw.text((x+8,y+5),labels[name],font=FONT,fill='white')
sheet.save(HERE/'review'/'extraction_34.png')
master=Image.open(HERE/'sprites'/'central_master.png').convert('RGBA')
assembled=Image.new('RGBA',(256,256))
for index,(x,y) in enumerate([(0,0),(128,0),(0,128),(128,128)],1):
    assembled.paste(Image.open(HERE/'sprites'/f'central_{index}.png'),(x,y))
assert assembled.tobytes()==master.tobytes(), 'Los cuartos no reconstruyen el máster.'
assert len(records)==15, f'Faltan fuentes: {len(records)}/15'
(HERE/'validation'/'art_check.json').write_text(json.dumps({'sources':len(records),'central_quarters_pixel_identical':True,'sprite_size':[128,128],'central_size':[256,256],'transparent_sources':True},indent=2)+'\n')
