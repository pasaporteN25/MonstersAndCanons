#!/usr/bin/env python3
"""Hoja de contacto y comprobación estructural de los atlas provisionales."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib, json
ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parents[1]
OUT = PROJECT/'assets/sprites/enemies/rendered'
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
small = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
manifest = {'estado':'PROVISIONAL — pendiente de aprobación de Lucas', 'formato':{'estatica':[256,256],'atlas':[1024,1024],'cuadro':[256,256],'direcciones':['derecha','abajo','izquierda','arriba'],'fases':4,'apoyo_y':191},'criaturas':{}}
for kind in ['ratero','cargador']:
    atlas = Image.open(OUT/f'{kind}_walk.png').convert('RGBA')
    assert atlas.size == (1024,1024)
    hashes=[]; bounds=[]
    for row in range(4):
        for phase in range(4):
            frame=atlas.crop((phase*256,row*256,(phase+1)*256,(row+1)*256))
            box=frame.getchannel('A').getbbox()
            assert box and box[0]>0 and box[1]>0 and box[2]<256 and box[3]<256, box
            assert box[3] == 191, box
            bounds.append(box)
            hashes.append(hashlib.sha256(frame.tobytes()).hexdigest())
    assert len(set(hashes)) == 16
    static = Image.open(OUT/f'{kind}.png').convert('RGBA')
    assert static.tobytes() == atlas.crop((0,0,256,256)).tobytes()
    manifest['criaturas'][kind]={'texture':f'res://assets/sprites/enemies/rendered/{kind}.png','walk_atlas':f'res://assets/sprites/enemies/rendered/{kind}_walk.png','poses_unicas':16,'limites_alfa':bounds,'paleta': {'ratero':['#f6c3a9','#c98269','#76453f'],'cargador':['#dca58f','#a5614c','#583c36']}[kind], 'sha256':{name:hashlib.sha256((OUT/name).read_bytes()).hexdigest() for name in [f'{kind}.png',f'{kind}_walk.png']},'parametros_visuales_propuestos':{'walk_stride_tiles':0.45 if kind=='ratero' else 0.9,'walk_art_scale':1.0,'visual_scale':1.2,'flip_when_walking_left':False}}
manifest['fuentes_sha256'] = {f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted((ROOT/'sources').glob('*.svg'))}
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
# Comparación a alto visible igual, además del encuadre contractual y tamaño relativo.
images=[Image.open(OUT/f'{kind}.png').convert('RGBA') for kind in ['ratero','cargador','thief_m43']]
sheet=Image.new('RGB',(900,950),'#202330'); d=ImageDraw.Draw(sheet)
d.text((24,15),'T257 · La Cuadrilla · ARTE PROVISIONAL',font=font,fill='white')
d.text((24,40),'Sin capucha, capa, símbolo A ni marcas de las comunidades. Pendiente de Lucas.',font=small,fill='white')
for col,label in enumerate(['Ratero · bajo y veloz','Cargador · bolsa dominante','Ladrón · referencia aprobada']):
    x=col*300
    d.text((x+16,75),label,font=font,fill='white')
    d.rectangle((x,103,x+299,345),fill='#8baf60')
    img=images[col].resize((220,220),Image.Resampling.LANCZOS)
    sheet.paste(img,(x+40,115),img)
    d.text((x+15,354),'Encuadre de 220 px',font=small,fill='white')
    for y,side in [(382,112),(550,34)]:
        d.rectangle((x,y,x+299,y+side+14),fill='#d2b383')
        im=images[col].resize((side,side),Image.Resampling.LANCZOS)
        sheet.paste(im,(x+(300-side)//2,y+6),im)
        d.text((x+16,y+side+20),f'Encuadre de {side} px',font=small,fill='white')
    d.rectangle((x,645,x+299,705),fill='#8baf60')
    cropped=images[col].crop(images[col].getchannel('A').getbbox())
    im=cropped.resize((round(cropped.width*34/cropped.height),34),Image.Resampling.LANCZOS)
    sheet.paste(im,(x+(300-im.width)//2,658),im)
    d.text((x+16,715),'Silueta: 34 px de alto visible',font=small,fill='white')
    mask=im.getchannel('A'); silhouette=Image.new('RGBA',im.size,'#202330'); silhouette.putalpha(mask)
    d.rectangle((x,750,x+299,806),fill='#d2b383')
    sheet.paste(silhouette,(x+(300-im.width)//2,760),silhouette)
# Tamaños relativos RF-485: no equivalen a captura del juego.
d.text((24,825),'Tamaños relativos propuestos (0,20 / 0,33 / 0,30; escala visual 1,2):',font=small,fill='white')
for col,(img,side) in enumerate(zip(images,[46,76,69])):
    im=img.resize((side,side),Image.Resampling.LANCZOS)
    sheet.paste(im,(col*300+125,850+(76-side)),im)
sheet.save(ROOT/'captures/contact_sheet.png')
# Todas las fases juntas y una animación de revisión; sin lógica ni captura falsa de partida.
cycles=Image.new('RGB',(640,730),'#d2b383'); dr=ImageDraw.Draw(cycles)
for col,kind in enumerate(['ratero','cargador']):
    dr.text((col*320+10,10),kind.capitalize(),font=font,fill='#202330')
    atlas=Image.open(OUT/f'{kind}_walk.png')
    for row in range(4):
        dr.text((col*320+10,38+row*170),['Derecha','Abajo','Izquierda','Arriba'][row],font=small,fill='#202330')
        for phase in range(4):
            frame=atlas.crop((phase*256,row*256,(phase+1)*256,(row+1)*256)).resize((80,80),Image.Resampling.LANCZOS)
            cycles.paste(frame,(col*320+phase*80,65+row*170),frame)
cycles.save(ROOT/'captures/walk_cycles.png')
frames=[]
for phase in range(4):
    canvas=Image.new('RGB',(440,520),'#d2b383'); dr=ImageDraw.Draw(canvas)
    dr.text((10,8),'Caminata provisional · cuatro direcciones',font=font,fill='#202330')
    for col,kind in enumerate(['ratero','cargador']):
        atlas=Image.open(OUT/f'{kind}_walk.png')
        for row in range(4):
            fr=atlas.crop((phase*256,row*256,(phase+1)*256,(row+1)*256)).resize((112,112),Image.Resampling.LANCZOS)
            canvas.paste(fr,(col*220+54,row*120+35),fr)
    frames.append(canvas)
frames[0].save(ROOT/'captures/walk_preview.gif',save_all=True,append_images=frames[1:],duration=180,loop=0)
print('OK: 2 estáticas, 2 atlas, 32 poses únicas; alfa, márgenes, pies y estática/fase 0 verificados.')
