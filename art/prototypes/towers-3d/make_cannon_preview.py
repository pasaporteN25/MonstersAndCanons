"""Comparación de las torretas B y C sobre las bases B elegidas."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE=Path(__file__).resolve().parent
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',22)
small=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',16)
title=ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf',34)
board=Image.new('RGB',(1000,900),'#17202c')
d=ImageDraw.Draw(board)
d.text((28,18),'CAÑÓN / Opción C',font=title,fill='#f3efe4')
d.text((30,68),'B actual frente a C nueva, sobre las bases B de madera y oro',font=font,fill='#acbac0')

def asset(prefix,name,size):
    return Image.open(HERE/f'{prefix}_{name}.png').convert('RGBA').resize((size,size),Image.Resampling.LANCZOS)

def card(x,y,label,base,turret):
    d.rounded_rectangle((x,y,x+455,y+357),16,fill='#263541')
    d.text((x+19,y+13),label,font=font,fill='#ecebe4')
    tile=Image.new('RGBA',(222,222),'#69a34e')
    tile.alpha_composite(asset('b',base,222))
    tile.alpha_composite(asset(turret,'turret_cannon',222))
    board.paste(tile,(x+20,y+59),tile)
    d.text((x+257,y+78),'64 px',font=small,fill='#bccbd0')
    d.text((x+257,y+211),'34 px',font=small,fill='#bccbd0')
    for i in range(2):
        normal=Image.new('RGBA',(64,64),'#69a34e')
        normal.alpha_composite(asset('b',base,64))
        normal.alpha_composite(asset(turret,'turret_cannon',64))
        board.paste(normal,(x+260+i*72,y+111),normal)
        mini=Image.new('RGBA',(34,34),'#69a34e')
        mini.alpha_composite(asset('b',base,34))
        mini.alpha_composite(asset(turret,'turret_cannon',34))
        board.paste(mini,(x+260+i*50,y+245),mini)

card(25,125,'B · madera','base_1','b')
card(520,125,'C · madera','base_1','c')
card(25,505,'B · oro','base_3','b')
card(520,505,'C · oro','base_3','c')
board.save(HERE/'comparativa_canon_c.png')
